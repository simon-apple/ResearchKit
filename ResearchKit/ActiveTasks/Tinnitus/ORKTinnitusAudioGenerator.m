/*
 Copyright (c) 2020, Apple Inc. All rights reserved.
 
 Redistribution and use in source and binary forms, with or without modification,
 are permitted provided that the following conditions are met:
 
 1.  Redistributions of source code must retain the above copyright notice, this
 list of conditions and the following disclaimer.
 
 2.  Redistributions in binary form must reproduce the above copyright notice,
 this list of conditions and the following disclaimer in the documentation and/or
 other materials provided with the distribution.
 
 3.  Neither the name of the copyright holder(s) nor the names of any contributors
 may be used to endorse or promote products derived from this software without
 specific prior written permission. No license is granted to the trademarks of
 the copyright holders even if such marks are included in this software.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
 FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 
 ---
 
 This software is based on the original source by Matt Gallagher.
 http://www.cocoawithlove.com/2010/10/ios-tone-generator-introduction-to.html
 
 Copyright (c) 2009-2011 Matt Gallagher. All rights reserved.
 
 This software is provided 'as-is', without any express or implied warranty. In
 no event will the authors be held liable for any damages arising from the use
 of this software. Permission is granted to anyone to use this software for any
 purpose, including commercial applications, and to alter it and redistribute it
 freely, subject to the following restrictions:
 
 1. The origin of this software must not be misrepresented; you must not claim
 that you wrote the original software. If you use this software in a product,
 an acknowledgment in the product documentation would be appreciated but is
 not required.
 2. Altered source versions must be plainly marked as such, and must not be
 misrepresented as being the original software.
 3. This notice may not be removed or altered from any source distribution.
 */

// apple-internal

#if RK_APPLE_INTERNAL

#import "ORKTinnitusAudioGenerator.h"
#import "ORKTinnitusAudioSample.h"
#import "ORKTinnitusHeadphoneTable.h"
#import "ORKHelpers_Internal.h"

@import AudioToolbox;

@interface ORKTinnitusAudioGenerator () {
  @public
    double _frequency;
    unsigned long _thetaIndex;
    double _bufferAmplitude;
    float _systemVolume;
    ORKAudioChannel _activeChannel;
    BOOL _rampUp;
    double _fadeFactor;
    NSTimeInterval _fadeDuration;
    NSNumberFormatter *_numberFormatter;
    ORKTinnitusType _type;
    
    int _lastNodeInput;
    AudioComponentInstance _toneUnit;
    AUGraph _mGraph;
    AUNode _outputNode;
    AUNode _mixerNode;
    AudioUnit _mMixer;
}

@property (assign) NSTimeInterval fadeDuration;

- (void)play;
- (void)handleInterruption:(id)sender;

@end

const double ORKTinnitusFadeDuration = 0.05;
const double ORKTinnitusAudioGeneratorAmplitudeDefault = 0.03f;
const double ORKTinnitusAudioGeneratorSampleRateDefault = 44100.0f;

static OSStatus ORKTinnitusAudioGeneratorRenderTone(void *inRefCon,
                                            AudioUnitRenderActionFlags *ioActionFlags,
                                            const AudioTimeStamp         *inTimeStamp,
                                            UInt32                     inBusNumber,
                                            UInt32                     inNumberFrames,
                                            AudioBufferList             *ioData) {
    
    // Get the tone parameters out of the view controller
    ORKTinnitusAudioGenerator *audioGenerator = (__bridge ORKTinnitusAudioGenerator *)inRefCon;
    ORKTinnitusHeadphoneTable *table = audioGenerator.headphoneTable;
    double attenuation = 0.0;

    if (audioGenerator->_type == ORKTinnitusTypePureTone) {
        NSDecimalNumber *dbAmplitudePerFrequency =  [NSDecimalNumber decimalNumberWithString:table.dbAmplitudePerFrequency[[NSString stringWithFormat:@"%.0f",audioGenerator->_frequency]]];
        float systemVolume = [[AVAudioSession sharedInstance] outputVolume];
        
        NSNumber *volume = [[NSNumber alloc] initWithFloat:systemVolume];

        NSMutableDictionary *decimalVolumeCurve = [[NSMutableDictionary alloc] init];
        
        NSDictionary *volumeCurvePerFrequency = table.loudnessEQ[[NSString stringWithFormat:@"%.0f",audioGenerator->_frequency]];
                                                                
        for (NSString *key in volumeCurvePerFrequency.allKeys) {
            NSDecimalNumber *fKey = [NSDecimalNumber decimalNumberWithString:key];
            NSDecimalNumber *fValue = [NSDecimalNumber decimalNumberWithString:volumeCurvePerFrequency[key]];
            [decimalVolumeCurve setObject:fValue forKey:fKey];
        }
        
        NSDecimalNumber *loudnessEQCompensation;
        
        if ([decimalVolumeCurve.allKeys containsObject:volume]) {
            loudnessEQCompensation = [[NSDecimalNumber alloc] initWithFloat:[[decimalVolumeCurve objectForKey:volume] floatValue]];
        } else {
            // interpolate
            NSArray *sortedKeys = [decimalVolumeCurve.allKeys sortedArrayUsingSelector:@selector(compare:)];
            NSUInteger topIndex = [sortedKeys indexOfObjectPassingTest:^BOOL(NSNumber *obj, NSUInteger idx, BOOL * _Nonnull stop) {
                return [obj compare:volume] == NSOrderedDescending;
            }];

            NSNumber *topKey = [sortedKeys objectAtIndex:topIndex];
            NSNumber *topValue = [decimalVolumeCurve objectForKey:topKey];
            NSNumber *bottomKey = [sortedKeys objectAtIndex:topIndex-1];
            NSNumber *bottomValue = [decimalVolumeCurve objectForKey:bottomKey];

            double top = [topValue doubleValue];
            double bottom = [bottomValue doubleValue];
            double baselinedTopVolume = [topKey doubleValue] - [bottomKey doubleValue];
            double baselinedSystemVolume = systemVolume - [bottomKey doubleValue];
            double range = (top- bottom);
            double volumeOffset = (baselinedSystemVolume/baselinedTopVolume) * range;
            double adjustedVolume = bottom + volumeOffset;
            
            loudnessEQCompensation = [[NSDecimalNumber alloc] initWithDouble:adjustedVolume];
        }
        
        NSDecimalNumberHandler *behavior = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundPlain
                                                                                                  scale:2
                                                                                       raiseOnExactness:NO
                                                                                        raiseOnOverflow:NO
                                                                                       raiseOnUnderflow:NO
                                                                                    raiseOnDivideByZero:NO];
        
        NSDecimalNumber *updated_dbAmplitudePerFrequency = [dbAmplitudePerFrequency decimalNumberByAdding:loudnessEQCompensation withBehavior:behavior];
        
        attenuation =  (powf(10, 0.05 * updated_dbAmplitudePerFrequency.doubleValue));
    }
    
    double amplitude = audioGenerator->_bufferAmplitude * attenuation;
    double theta_increment = audioGenerator->_frequency / ORKTinnitusAudioGeneratorSampleRateDefault;
    unsigned long theta_index = audioGenerator->_thetaIndex;

    double fadeFactor = audioGenerator->_fadeFactor;

    Float32 *bufferActive    = (Float32 *)ioData->mBuffers[audioGenerator->_activeChannel].mData;
    Float32 *bufferNonActive = (Float32 *)ioData->mBuffers[1 - audioGenerator->_activeChannel].mData;
    
    // Generate the samples
    for (UInt32 frame = 0; frame < inNumberFrames; frame++) {
        if (audioGenerator->_rampUp) {
            fadeFactor += 1.0 / (ORKTinnitusAudioGeneratorSampleRateDefault * audioGenerator->_fadeDuration);
            if (fadeFactor >= 1) {
                fadeFactor = 1;
            }
        } else {
            fadeFactor -= 1.0 / (ORKTinnitusAudioGeneratorSampleRateDefault * audioGenerator->_fadeDuration);
            if (fadeFactor <= 0) {
                fadeFactor = 0;
            }
        }
        double bufferValue;
        if (audioGenerator->_type == ORKTinnitusTypePureTone) {
            double theta = theta_index * theta_increment;
            bufferValue = sin(theta * 2.0 * M_PI) * amplitude * pow(10, 2.0 * fadeFactor - 2);
            theta_index++;
        } else {
            // white noise
            bufferValue = ((((double) (arc4random() % ((unsigned)RAND_MAX + 1)) / RAND_MAX) * (2 * audioGenerator->_bufferAmplitude)) - audioGenerator->_bufferAmplitude) * fadeFactor;
        }
        bufferActive[frame] = bufferValue;
        bufferNonActive[frame] = bufferValue;
    }

    // Store the thetaIndex back in the view controller
    audioGenerator->_thetaIndex = theta_index;
    audioGenerator->_fadeFactor = fadeFactor;

    return noErr;
}

static OSStatus ORKTinnitusAudioGeneratorZeroTone(void *inRefCon,
                                             AudioUnitRenderActionFlags *ioActionFlags,
                                             const AudioTimeStamp         *inTimeStamp,
                                             UInt32                     inBusNumber,
                                             UInt32                     inNumberFrames,
                                             AudioBufferList             *ioData) {
    // Get the tone parameters out of the view controller
    ORKTinnitusAudioGenerator *audioGenerator = (__bridge ORKTinnitusAudioGenerator *)inRefCon;
 
    // This is a mono tone generator so we only need the first buffer
    Float32 *bufferActive    = (Float32 *)ioData->mBuffers[audioGenerator->_activeChannel].mData;
    Float32 *bufferNonActive = (Float32 *)ioData->mBuffers[1 - audioGenerator->_activeChannel].mData;
    
    // Generate the samples
    for (UInt32 frame = 0; frame < inNumberFrames; frame++) {
        double bufferValue = 0;
        bufferActive[frame] = bufferValue;
        bufferNonActive[frame] = bufferValue;
    }

    return noErr;
}



@implementation ORKTinnitusAudioGenerator

- (instancetype)initWithHeadphoneType:(ORKHeadphoneTypeIdentifier)headphoneType
{
    self = [super init];
    if (self) {
        self.headphoneTable = [[ORKTinnitusHeadphoneTable alloc] initWithHeadphoneType:headphoneType];
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithHeadphoneType:(ORKHeadphoneTypeIdentifier)headphoneType fadeDuration:(NSTimeInterval)fadeDuration
{
    self = [super init];
    if (self) {
        self.headphoneTable = [[ORKTinnitusHeadphoneTable alloc] initWithHeadphoneType:headphoneType];
        [self commonInit];
        self.fadeDuration = fadeDuration;
    }
    return self;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    self.fadeDuration = ORKTinnitusFadeDuration;
    
    _lastNodeInput = 0;
	
    _playing = NO;
    _type = ORKTinnitusTypeUnknown;
    _bufferAmplitude = ORKTinnitusAudioGeneratorAmplitudeDefault;

    _numberFormatter = [[NSNumberFormatter alloc] init];
    _numberFormatter.numberStyle = NSNumberFormatterDecimalStyle;
    
    [self setupGraph];
    
    // Automatically stop and then restart audio playback when the app resigns active.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
}

- (void)dealloc {
    if (_mGraph) {
        int nodeInput = (_lastNodeInput % 2) + 1;
        AUGraphDisconnectNodeInput(_mGraph, _mixerNode, nodeInput);
        AUGraphUpdate(_mGraph, NULL);
        AUGraphStop(_mGraph);
        AUGraphUninitialize(_mGraph);
        _mGraph = nil;
    }
    
    _mMixer = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)applicationDidBecomeActive:(NSNotification *)notification {
    if (_toneUnit) {
        __unused OSErr error = AudioOutputUnitStart(_toneUnit);
        NSAssert1(error == noErr, @"Error starting unit: %hd", error);
    }
}

- (void)applicationWillResignActive:(NSNotification *)notification {
    if (_toneUnit) {
        __unused OSErr error = AudioOutputUnitStop(_toneUnit);
        NSAssert1(error == noErr, @"Error stopping unit: %hd", error);
    }
}

- (double)dBToAmplitude:(double)dB {
    return (powf(10, 0.05 * dB));
}

- (double)volumeInDecibels {
    return 20 * log(self.volumeAmplitude);
}

- (double)volumeAmplitude {
    return _bufferAmplitude * pow(10, 2 * _fadeFactor - 2);
}

- (float)getCurrentSystemVolume {
    return [[AVAudioSession sharedInstance] outputVolume];
}

- (float)getCurrentSystemVolumeInDecibels {
    float vol = [[AVAudioSession sharedInstance] outputVolume];
    return 20.f*log10f(vol+FLT_MIN);
}

- (float)getPuretone_dBSPL {
    _systemVolume = [self getCurrentSystemVolume];
    if (_systemVolume == 0.0) {
        return 0.0;
    }
    
    return [_headphoneTable dbSPLForSystemVolume:_systemVolume frequency:_frequency interpolated:YES];
}

- (void)playSoundAtFrequency:(double)playFrequency {
    _type = ORKTinnitusTypePureTone;
    _frequency = playFrequency;
    _fadeFactor = self.fadeDuration;
    _fadeDuration = self.fadeDuration;
    _rampUp = YES;
    _thetaIndex = 0;
    
    [self play];
}

- (void)play {
    AURenderCallbackStruct renderCallbackStruct;
    renderCallbackStruct.inputProcRefCon = (__bridge void *)(self);
    renderCallbackStruct.inputProc = ORKTinnitusAudioGeneratorRenderTone;
    _lastNodeInput += 1;
    int connect = 0;
    int disconnect = 0;
    if ((_lastNodeInput % 2) == 0) {
        connect = 1;
        disconnect = 2;
    } else {
        connect = 2;
        disconnect = 1;
    }
    AUGraphDisconnectNodeInput(_mGraph, _mixerNode, disconnect);
    AUGraphSetNodeInputCallback(_mGraph, _mixerNode, connect, &renderCallbackStruct);
    AUGraphUpdate(_mGraph, NULL);
    _playing = YES;
}

- (void)playWhiteNoise {
    _type = ORKTinnitusTypeWhiteNoise;
    _fadeFactor = self.fadeDuration;
    _fadeDuration = self.fadeDuration;
    _rampUp = YES;
    
    [self play];
}

- (void)stop {
    if (_mGraph) {
        _rampUp = NO;
        int nodeInput = (_lastNodeInput % 2) + 1;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(_fadeDuration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (_mGraph) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    AUGraphDisconnectNodeInput(_mGraph, _mixerNode, nodeInput);
                    AUGraphUpdate(_mGraph, NULL);
                    _playing = NO;
                });
            }
        });
    }
}

- (void)setupGraph {
    if (!_mGraph) {
        NewAUGraph(&_mGraph);
        AudioComponentDescription mixer_desc;
        mixer_desc.componentType = kAudioUnitType_Mixer;
        mixer_desc.componentSubType = kAudioUnitSubType_SpatialMixer;
        mixer_desc.componentFlags = 0;
        mixer_desc.componentFlagsMask = 0;
        mixer_desc.componentManufacturer = kAudioUnitManufacturer_Apple;
        
        AudioComponentDescription output_desc;
        output_desc.componentType = kAudioUnitType_Output;
        output_desc.componentSubType = kAudioUnitSubType_RemoteIO;
        output_desc.componentFlags = 0;
        output_desc.componentFlagsMask = 0;
        output_desc.componentManufacturer = kAudioUnitManufacturer_Apple;
        
        AUGraphAddNode(_mGraph, &output_desc, &_outputNode);
        AUGraphAddNode(_mGraph, &mixer_desc, &_mixerNode );
        
        AUGraphConnectNodeInput(_mGraph, _mixerNode, 0, _outputNode, 0);
        
        AUGraphOpen(_mGraph);
        AUGraphNodeInfo(_mGraph, _mixerNode, NULL, &_mMixer);
        
        UInt32 numbuses = 3;
        UInt32 size = sizeof(numbuses);
        AudioUnitSetProperty(_mMixer, kAudioUnitProperty_ElementCount, kAudioUnitScope_Input, 0, &numbuses, size);
        
        AudioStreamBasicDescription desc;
        for (int i = 0; i < numbuses; ++i) {
            AURenderCallbackStruct renderCallbackStruct;
            renderCallbackStruct.inputProcRefCon = (__bridge void *)(self);
            
            if (i == 0) {
                renderCallbackStruct.inputProc = ORKTinnitusAudioGeneratorZeroTone;
                AUGraphSetNodeInputCallback(_mGraph, _mixerNode, 0, &renderCallbackStruct);
            }
            size = sizeof(desc);
            AudioUnitGetProperty(  _mMixer,
                                    kAudioUnitProperty_StreamFormat,
                                    kAudioUnitScope_Input,
                                    i,
                                    &desc,
                                    &size);
            memset (&desc, 0, sizeof (desc));
            const int four_bytes_per_float = 4;
            const int eight_bits_per_byte = 8;
            
            desc.mSampleRate = ORKTinnitusAudioGeneratorSampleRateDefault;
            desc.mFormatID = kAudioFormatLinearPCM;
            desc.mFormatFlags = kAudioFormatFlagsNativeFloatPacked | kAudioFormatFlagIsNonInterleaved;
            desc.mBytesPerPacket = four_bytes_per_float;
            desc.mFramesPerPacket = 1;
            desc.mBytesPerFrame = four_bytes_per_float;
            desc.mChannelsPerFrame = 2;
            desc.mBitsPerChannel = four_bytes_per_float * eight_bits_per_byte;
            
            AudioUnitSetProperty(_mMixer,
                                 kAudioUnitProperty_StreamFormat,
                                 kAudioUnitScope_Input,
                                 i,
                                 &desc,
                                 sizeof(desc));
            
            AUSpatialMixerOutputType outputType = kSpatialMixerOutputType_Headphones;
            AudioUnitSetProperty(_mMixer,
                                 kAudioUnitProperty_SpatialMixerOutputType,
                                 kAudioUnitScope_Global,
                                 i,
                                 &outputType,
                                 sizeof(outputType));
            
            AUSpatializationAlgorithm stereoPassThrough = kSpatializationAlgorithm_StereoPassThrough;
            AudioUnitSetProperty(_mMixer,
                                 kAudioUnitProperty_SpatializationAlgorithm,
                                 kAudioUnitScope_Input,
                                 i,
                                 &stereoPassThrough,
                                 sizeof(stereoPassThrough));
            
            UInt32 bypass = kSpatialMixerSourceMode_Bypass;
            AudioUnitSetProperty(_mMixer,
                                 kAudioUnitProperty_SpatialMixerSourceMode,
                                 kAudioUnitScope_Input,
                                 i,
                                 &bypass,
                                 sizeof(bypass));
        }

        AudioUnitSetProperty(_mMixer,
                             kAudioUnitProperty_StreamFormat,
                             kAudioUnitScope_Output,
                             0,
                             &desc,
                             sizeof(desc));
        
        AUGraphInitialize(_mGraph);
        AUGraphStart(_mGraph);
    }
}

- (void)handleInterruption:(id)sender {
    [self stop];
}

- (void)adjustBufferAmplitude:(double) newAmplitude {
    _bufferAmplitude = MIN(MAX(newAmplitude, 0), 1);
}

@end

#endif
