/*
 Copyright (c) 2015, Shazino SAS. All rights reserved.
 Copyright (c) 2018, Apple Inc. All rights reserved.
 
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


#import "ORKdBHLToneAudiometryPulsedAudioGenerator.h"
#import "ORKHelpers_Internal.h"

#if RK_APPLE_INTERNAL
#import <ResearchKit/ResearchKit-Swift.h>
#endif

@import AudioToolbox;

typedef NSString * ORKVolumeCurvePulsedFilename NS_STRING_ENUM;
ORKVolumeCurvePulsedFilename const ORKVolumeCurvePulsedFilenameAirPods = @"volume_curve_AIRPODS";
ORKVolumeCurvePulsedFilename const ORKVolumeCurvePulsedFilenameAirPodsGen3 = @"volume_curve_AIRPODSV3";
ORKVolumeCurvePulsedFilename const ORKVolumeCurvePulsedFilenameAirPodsPro = @"volume_curve_AIRPODSPRO";
ORKVolumeCurvePulsedFilename const ORKVolumeCurvePulsedFilenameAirPodsProGen2 = @"volume_curve_AIRPODSPROV2";
ORKVolumeCurvePulsedFilename const ORKVolumeCurvePulsedFilenameAirPodsMax = @"volume_curve_AIRPODSMAX";
ORKVolumeCurvePulsedFilename const ORKVolumeCurvePulsedFilenameWired = @"volume_curve_WIRED";

NSString * const pulsedFrequencydBSPLBaseFilename = @"frequency_dBSPL_%@";
NSString * const pulsedRetsplBaseFilename = @"retspl_%@";
NSString * const pulsedRetspldBFSBaseFilename = @"retspl_dBFS_%@";
NSString * const pulsedFilenameExtension = @"plist";

@interface ORKdBHLToneAudiometryPulsedAudioGenerator () {
@public
    AUGraph _mGraph;
    AUNode _outputNode;
    AUNode _mixerNode;
    AudioUnit _mMixer;
    unsigned long _thetaIndex;
    ORKAudioChannel _activeChannel;
    BOOL _playsStereo;
    double _globaldBHL;
    NSDictionary *_sensitivityPerFrequency;
    NSDictionary *_volumeCurve;
    NSDictionary *_retspl;
    NSDictionary *_retspldBFS;
    int _lastNodeInput;
    
    int _pulseFrameCounter;
    int _nPulsesFramesOn; // pulse duration
    int _nPulsesFramesOff; // pause duration
    BOOL _stopAfterPulse; // signal to stop after the next pulse
    BOOL _pulsesStopped; // indicates the generator stopped after a pulse
}

@property (atomic, retain) NSNumber *amplitudeGain;
@property (atomic, retain) NSNumber *nextAmplitudeGain;
@property (atomic, assign) double frequency;
;

- (NSNumber *)dbHLtoAmplitude: (double)dbHL atFrequency:(double)frequency;

@end

#define PULSE_RAMP_MS 35
const double ORKdBHLSineWaveToneGeneratorPulsedSampleRateDefault = 44100.0f;
const int ORKdBHLSineWaveToneGeneratorPulseRampFrames = ORKdBHLSineWaveToneGeneratorPulsedSampleRateDefault/(1000/PULSE_RAMP_MS);

static OSStatus ORKdBHLAudioGeneratorRenderTone(void *inRefCon,
                                                AudioUnitRenderActionFlags *ioActionFlags,
                                                const AudioTimeStamp         *inTimeStamp,
                                                UInt32                     inBusNumber,
                                                UInt32                     inNumberFrames,
                                                AudioBufferList             *ioData) {
    // Get the tone parameters out of the view controller
    ORKdBHLToneAudiometryPulsedAudioGenerator *audioGenerator = (__bridge ORKdBHLToneAudiometryPulsedAudioGenerator *)inRefCon;
    double amplitude = [audioGenerator.amplitudeGain doubleValue];
    double nextAmplitudeGain = [audioGenerator.nextAmplitudeGain doubleValue];
    double theta_increment = audioGenerator.frequency / ORKdBHLSineWaveToneGeneratorPulsedSampleRateDefault;
    unsigned long theta_index = audioGenerator->_thetaIndex;
    double pulseFrameCounter = audioGenerator->_pulseFrameCounter;
    
    BOOL stopAfterPulse = audioGenerator->_stopAfterPulse;
    BOOL stopped = audioGenerator->_pulsesStopped;
    
    // This is a mono tone generator so we only need the first buffer
    Float32 *bufferActive    = (Float32 *)ioData->mBuffers[audioGenerator->_activeChannel].mData;
    Float32 *bufferNonActive = (Float32 *)ioData->mBuffers[1 - audioGenerator->_activeChannel].mData;
    
    // Generate the samples
    for (UInt32 frame = 0; frame < inNumberFrames; frame++) {
        double theta = theta_index * theta_increment;
        double bufferValue = sin(theta * 2.0 * M_PI) * amplitude;
        theta_index++;
        pulseFrameCounter++;
        
        if (!stopped) {
            if (pulseFrameCounter > 0) { //Positive is the "pulse" phase, ramp-up happens at this phase
                if (pulseFrameCounter <= audioGenerator->_nPulsesFramesOn) { //Check if the pulse are still going on
                    if (pulseFrameCounter < ORKdBHLSineWaveToneGeneratorPulseRampFrames) { //Ramp-up
                        bufferActive[frame] = bufferValue * (pulseFrameCounter / (double)ORKdBHLSineWaveToneGeneratorPulseRampFrames);
                    } else { //No ramp phase, just use plain bufferValue
                        bufferActive[frame] = bufferValue;
                    }
                } else { //Pulse ended, ramp-down happens at this phase
                    if (pulseFrameCounter < (audioGenerator->_nPulsesFramesOn + ORKdBHLSineWaveToneGeneratorPulseRampFrames)) { //Ramp-down
                        bufferActive[frame] = bufferValue * ((audioGenerator->_nPulsesFramesOn + ORKdBHLSineWaveToneGeneratorPulseRampFrames - pulseFrameCounter) / (double)ORKdBHLSineWaveToneGeneratorPulseRampFrames);
                    } else { // Ramp-down ended, reset pulseFrameCounter to -(_nPulsesOff-ORKdBHLSineWaveToneGeneratorPulseRampFrames)
                        pulseFrameCounter = -(audioGenerator->_nPulsesFramesOff - ORKdBHLSineWaveToneGeneratorPulseRampFrames);
                        bufferActive[frame] = 0;
                        
                        if (stopAfterPulse) {
                            stopped = YES;
                        }
                    }
                }
            } else { //Negative pulseFrameCounter means we are in the pause
                bufferActive[frame] = 0;
                
                if (nextAmplitudeGain != amplitude) {
                    amplitude = nextAmplitudeGain;
                    audioGenerator.amplitudeGain = audioGenerator.nextAmplitudeGain;
                    audioGenerator->_pulsesStopped = NO;
                    audioGenerator->_stopAfterPulse = NO;
                    audioGenerator->_thetaIndex = 0;
                }
            }
        } else { //Stopped, dont add any more pulses
            bufferActive[frame] = 0;
        }
        
        if (audioGenerator->_playsStereo) {
            bufferNonActive[frame] = bufferActive[frame];
        } else {
            bufferNonActive[frame] = 0;
        }
    }
    
    // Store the thetaIndex back in the view controller
    audioGenerator->_thetaIndex = theta_index;
    audioGenerator->_pulseFrameCounter = pulseFrameCounter;
    audioGenerator->_pulsesStopped = stopped;
    
    return noErr;
}

static OSStatus ORKdBHLAudioGeneratorZeroTone(void *inRefCon,
                                             AudioUnitRenderActionFlags *ioActionFlags,
                                             const AudioTimeStamp         *inTimeStamp,
                                             UInt32                     inBusNumber,
                                             UInt32                     inNumberFrames,
                                             AudioBufferList             *ioData) {
    // Get the tone parameters out of the view controller
    ORKdBHLToneAudiometryPulsedAudioGenerator *audioGenerator = (__bridge ORKdBHLToneAudiometryPulsedAudioGenerator *)inRefCon;
 
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

@implementation ORKdBHLToneAudiometryPulsedAudioGenerator

- (instancetype)initForHeadphoneType:(ORKHeadphoneTypeIdentifier)headphoneType pulseMillisecondsDuration:(NSInteger)pulseDuration pauseMillisecondsDuration:(NSInteger)pauseDuration {
    self = [super init];
    if (self) {
        _lastNodeInput = 0;
        _sweepDirectionUp = YES;
        _pulseFrameCounter = 0;
        _nPulsesFramesOn = ORKdBHLSineWaveToneGeneratorPulsedSampleRateDefault / (1000.0 / (double)pulseDuration);
        _nPulsesFramesOff = ORKdBHLSineWaveToneGeneratorPulsedSampleRateDefault / (1000.0 / (double)pauseDuration);

        NSString *headphoneTypeUppercased = [headphoneType uppercaseString];
        ORKHeadphoneTypeIdentifier headphoneTypeIdentifier;
        ORKVolumeCurvePulsedFilename volumeCurveFilename;
        
        if ([headphoneTypeUppercased isEqualToString:ORKHeadphoneTypeIdentifierAirPodsGen1] ||
            [headphoneTypeUppercased isEqualToString:ORKHeadphoneTypeIdentifierAirPodsGen2]) {
            headphoneTypeIdentifier = ORKHeadphoneTypeIdentifierAirPods;
            volumeCurveFilename = ORKVolumeCurvePulsedFilenameAirPods;
        } else if ([headphoneTypeUppercased isEqualToString:ORKHeadphoneTypeIdentifierAirPodsPro]) {
            headphoneTypeIdentifier = ORKHeadphoneTypeIdentifierAirPodsPro;
            volumeCurveFilename = ORKVolumeCurvePulsedFilenameAirPodsPro;
        } else if ([headphoneTypeUppercased isEqualToString:ORKHeadphoneTypeIdentifierAirPodsProGen2]) {
            headphoneTypeIdentifier = ORKHeadphoneTypeIdentifierAirPodsProGen2;
            volumeCurveFilename = ORKVolumeCurvePulsedFilenameAirPodsProGen2;
        } else if ([headphoneTypeUppercased isEqualToString:ORKHeadphoneTypeIdentifierAirPodsGen3]) {
            headphoneTypeIdentifier = ORKHeadphoneTypeIdentifierAirPodsGen3;
            volumeCurveFilename = ORKVolumeCurvePulsedFilenameAirPodsGen3;
        } else if ([headphoneTypeUppercased isEqualToString:ORKHeadphoneTypeIdentifierAirPodsMax]) {
            headphoneTypeIdentifier = ORKHeadphoneTypeIdentifierAirPodsMax;
            volumeCurveFilename = ORKVolumeCurvePulsedFilenameAirPodsMax;
        } else if ([headphoneTypeUppercased isEqualToString:ORKHeadphoneTypeIdentifierEarPods]) {
            headphoneTypeIdentifier = ORKHeadphoneTypeIdentifierEarPods;
            volumeCurveFilename = ORKVolumeCurvePulsedFilenameWired;
        } else {
            @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"A valid headphone route identifier must be provided" userInfo:nil];
        }
        
        _sensitivityPerFrequency = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle bundleForClass:[self class]] pathForResource:[NSString stringWithFormat:pulsedFrequencydBSPLBaseFilename, headphoneTypeIdentifier]  ofType:pulsedFilenameExtension]];

        _retspl = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle bundleForClass:[self class]] pathForResource:[NSString stringWithFormat:pulsedRetsplBaseFilename, headphoneTypeIdentifier] ofType:pulsedFilenameExtension]];
        _retspldBFS = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle bundleForClass:[self class]] pathForResource:[NSString stringWithFormat:pulsedRetspldBFSBaseFilename, headphoneTypeIdentifier] ofType:pulsedFilenameExtension]];

        _volumeCurve = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle bundleForClass:[self class]] pathForResource:volumeCurveFilename ofType:pulsedFilenameExtension]];
        
        [self setupGraph];
    }
    return self;
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
}

- (void)playSoundAtFrequency:(double)playFrequency
                   onChannel:(ORKAudioChannel)playChannel
                        dBHL:(double)dBHL
{
    self.frequency = playFrequency;
    _activeChannel = playChannel;
    _pulseFrameCounter = 0;
    _stopAfterPulse = NO;
    _pulsesStopped = NO;
    _globaldBHL = dBHL;
    _thetaIndex = 0;
    self.amplitudeGain = [self dbHLtoAmplitude:dBHL atFrequency:playFrequency];
    self.nextAmplitudeGain = [self dbHLtoAmplitude:dBHL atFrequency:playFrequency];

    [self play];
}

- (float)currentdBHL {
    return _globaldBHL;
}

- (void)setCurrentdBHL:(double)value {
    if (_frequency != 0 && _globaldBHL != value) {
        _globaldBHL = value;
        self.amplitudeGain = [self dbHLtoAmplitude:_globaldBHL atFrequency:self.frequency];
        ORK_Log_Debug("setCurrentdBHL: %f", value);
    }
}

- (void)setCurrentdBHLAndRamp:(double)value {
    if (_frequency != 0 && _globaldBHL != value) {
        _globaldBHL = value;
        self.nextAmplitudeGain = [self dbHLtoAmplitude:_globaldBHL atFrequency:self.frequency];
    }
}

- (void)setupGraph {
    if (!_mGraph) {
        NewAUGraph(&_mGraph);
        AudioComponentDescription mixer_desc;
        mixer_desc.componentType = kAudioUnitType_Mixer;
        mixer_desc.componentSubType = kAudioUnitSubType_MultiChannelMixer;
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
                renderCallbackStruct.inputProc = ORKdBHLAudioGeneratorZeroTone;
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
            
            desc.mSampleRate = ORKdBHLSineWaveToneGeneratorPulsedSampleRateDefault;
            desc.mFormatID = kAudioFormatLinearPCM;
            desc.mFormatFlags = kAudioFormatFlagsNativeFloatPacked | kAudioFormatFlagIsNonInterleaved;
            desc.mBytesPerPacket = four_bytes_per_float;
            desc.mFramesPerPacket = 1;
            desc.mBytesPerFrame = four_bytes_per_float;
            desc.mChannelsPerFrame = 2;
            desc.mBitsPerChannel = four_bytes_per_float * eight_bits_per_byte;
            
            AudioUnitSetProperty(  _mMixer,
                                    kAudioUnitProperty_StreamFormat,
                                    kAudioUnitScope_Input,
                                    i,
                                    &desc,
                                    sizeof(desc));
        }
        
        AudioUnitSetProperty(  _mMixer,
                                kAudioUnitProperty_StreamFormat,
                                kAudioUnitScope_Output,
                                0,
                                &desc,
                                sizeof(desc));
        AUGraphInitialize(_mGraph);
        AUGraphStart(_mGraph);
    }
}

- (void)play {
    AURenderCallbackStruct renderCallbackStruct;
    renderCallbackStruct.inputProcRefCon = (__bridge void *)(self);
    renderCallbackStruct.inputProc = ORKdBHLAudioGeneratorRenderTone;
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
}

- (void)stop {
    if (_mGraph) {
        _stopAfterPulse = YES;
        int nodeInput = (_lastNodeInput % 2) + 1;
        double stopDelay = (double)(_nPulsesFramesOn + _nPulsesFramesOff) / ORKdBHLSineWaveToneGeneratorPulsedSampleRateDefault;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(stopDelay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (_mGraph) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    AUGraphDisconnectNodeInput(_mGraph, _mixerNode, nodeInput);
                    AUGraphUpdate(_mGraph, NULL);
                });
            }
        });
    }
}

- (double)dBToAmplitude:(double)dB {
    return (powf(10, 0.05 * dB));
}

- (float)getCurrentSystemVolume {
    return [[AVAudioSession sharedInstance] outputVolume];
}

- (NSNumber *)dbHLtoAmplitude: (double)dbHL atFrequency:(double)frequency {
    if (_retspldBFS) {
        return [self dbHLtoAmplitudeUsingdBFSTable:dbHL atFrequency:frequency];
    }
    
#if RK_APPLE_INTERNAL
    NSArray *sortedfrequencies = [[_sensitivityPerFrequency allKeys] sortedArrayUsingComparator:^NSComparisonResult(NSString*  _Nonnull obj1, NSString*  _Nonnull obj2) {
        return [obj1 doubleValue] > [obj2 doubleValue];
    }];
    NSArray *sortedValues = [_sensitivityPerFrequency objectsForKeys:sortedfrequencies notFoundMarker:@""];
    NSArray *frequencies = [sortedfrequencies valueForKey:@"doubleValue"];
    NSArray *values = [sortedValues valueForKey:@"doubleValue"];

    double sensitivity = [Interpolators interp1dWithXValues:frequencies yValues:values xPoint:frequency];
    NSDecimalNumber *dBSPL =  [NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%lf",sensitivity]];
#else
    NSDecimalNumber *dBSPL =  [NSDecimalNumber decimalNumberWithString:_sensitivityPerFrequency[[NSString stringWithFormat:@"%.0f",frequency]]];
#endif
    
    // get current volume
    float currentVolume = [self getCurrentSystemVolume];
    
    currentVolume = (int)(currentVolume / 0.0625) * 0.0625;
    currentVolume = currentVolume == 0 ? 0.0625 : currentVolume;
    
    // check in volume curve table for offset
    NSDecimalNumber *offsetDueToVolume = [NSDecimalNumber decimalNumberWithString:_volumeCurve[[NSString stringWithFormat:@"%.4f",currentVolume]]];
    
    NSDecimalNumber *updated_dBSPLForVolumeCurve = [dBSPL decimalNumberByAdding:offsetDueToVolume];
    
    NSDecimalNumber *dBFSCalibration = [NSDecimalNumber decimalNumberWithString:@"30"];
    
    NSDecimalNumber *updated_dBSPLFor_dBFS = [updated_dBSPLForVolumeCurve decimalNumberByAdding:dBFSCalibration];
    
#if RK_APPLE_INTERNAL
    NSArray *sortedRetspls = [_retspl objectsForKeys:sortedfrequencies notFoundMarker:@""];
    NSArray *retspls = [sortedRetspls valueForKey:@"doubleValue"];
   
    double retspl = [Interpolators interp1dWithXValues:frequencies yValues:retspls xPoint:frequency];
    NSDecimalNumber *baselinedBSPL = [NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%lf",retspl]];
#else
    NSDecimalNumber *baselinedBSPL = [NSDecimalNumber decimalNumberWithString:_retspl[[NSString stringWithFormat:@"%.0f",frequency]]];
#endif

    NSDecimalNumber *tempdBHL = [NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%f", dbHL]];
    NSDecimalNumber *attenuationOffset = [baselinedBSPL decimalNumberByAdding:tempdBHL];

    NSDecimalNumber *attenuation = [attenuationOffset decimalNumberBySubtracting:updated_dBSPLFor_dBFS];

    // if the signal starts clipping
    if ([attenuation doubleValue] >= -1) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(toneWillStartClipping)]) {
            [self.delegate toneWillStartClipping];
            return nil;
        }
    }
    
    double linearAttenuation = [self dBToAmplitude:attenuation.doubleValue];
    
    return [NSNumber numberWithDouble:linearAttenuation];
    
}

- (NSNumber *)dbHLtoAmplitudeUsingdBFSTable: (double)dbHL atFrequency:(double)frequency {
    float currentVolume = [self getCurrentSystemVolume];
    
    currentVolume = (int)(currentVolume / 0.0625) * 0.0625;
    currentVolume = currentVolume == 0 ? 0.0625 : currentVolume;
    
    // check in volume curve table for offset
    NSDecimalNumber *offsetDueToVolume = [NSDecimalNumber decimalNumberWithString:_volumeCurve[[NSString stringWithFormat:@"%.4f",currentVolume]]];
    
    NSArray *sortedRetsplfrequencies = [[_retspldBFS allKeys] sortedArrayUsingComparator:^NSComparisonResult(NSString*  _Nonnull obj1, NSString*  _Nonnull obj2) {
        return [obj1 doubleValue] > [obj2 doubleValue];
    }];
    NSArray *frequencies = [sortedRetsplfrequencies valueForKey:@"doubleValue"];
    
    NSArray *sortedRetspls = [_retspldBFS objectsForKeys:sortedRetsplfrequencies notFoundMarker:@""];
    NSArray *retspls = [sortedRetspls valueForKey:@"doubleValue"];
   
    double retspl = [Interpolators interp1dWithXValues:frequencies yValues:retspls xPoint:frequency];
    NSDecimalNumber *baselinedbFS = [NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%lf",retspl]];

    NSDecimalNumber *tempdBHL = [NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%f", dbHL]];
    NSDecimalNumber *attenuationOffset = [baselinedbFS decimalNumberByAdding:tempdBHL];

    ORK_Log_Debug("dbHLtoAmplitudeUsingdBFSTable: %lf - frenquency: %lf", dbHL, frequency);
    ORK_Log_Debug("baselinedbFS = %@", baselinedbFS);

    NSDecimalNumber *attenuation = [attenuationOffset decimalNumberBySubtracting:offsetDueToVolume];
    ORK_Log_Debug("attenuation = %f", attenuation.doubleValue);

    double linearAttenuation = [self dBToAmplitude:attenuation.doubleValue];  // (powf(10, 0.05 * dB));
    
    ORK_Log_Debug("linearAttenuation = %f", linearAttenuation);
    
    return [NSNumber numberWithDouble:linearAttenuation];
}

@end

