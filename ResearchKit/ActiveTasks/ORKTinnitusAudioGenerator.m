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

#import "ORKTinnitusAudioGenerator.h"
#import "ORKTinnitusAudioSample.h"
#import "ORKTinnitusHeadphoneTable.h"
#import "ORKHelpers_Internal.h"

@import AudioToolbox;

@interface ORKTinnitusAudioGenerator () {
  @public
    AudioComponentInstance _unit;
    double _frequency;
    double _theta;
    double _bufferAmplitude;
    float _systemVolume;
    ORKAudioChannel _activeChannel;
    BOOL _rampUp;
    double _fadeFactor;
    NSTimeInterval _fadeDuration;
    NSNumberFormatter *_numberFormatter;
    ORKTinnitusType _type;
}

@property (assign) NSTimeInterval fadeDuration;
@property (nonatomic, assign) ORKTinnitusType type;
@property (nonatomic, strong) ORKTinnitusHeadphoneTable *headphoneTable;

- (void)setupAudioSession;
- (void)createUnit;
- (void)play;
- (void)handleInterruption:(id)sender;

@end

const double ORKTinnitusFadeDuration = 0.05;
const double ORKTinnitusAudioGeneratorAmplitudeDefault = 0.03f;
const double ORKTinnitusAudioGeneratorSampleRateDefault = 44100.0f;
const double ORKTinnitusAudioGeneratorIncrementVolumeDefault = 0.0625f;

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
        NSDecimalNumber *offsetDueToVolume = [NSDecimalNumber decimalNumberWithString:table.volumeCurve[[NSString stringWithFormat:@"%.4f",audioGenerator->_systemVolume]]];
        NSDecimalNumber *attenuationOffset = [dbAmplitudePerFrequency decimalNumberByAdding:offsetDueToVolume];
        attenuation =  (powf(10, 0.05 * attenuationOffset.doubleValue));
    }
    double amplitude = audioGenerator->_bufferAmplitude + attenuation;
    double theta = audioGenerator->_theta;
    double theta_increment = 2.0 * M_PI * audioGenerator->_frequency / ORKTinnitusAudioGeneratorSampleRateDefault;

    double fadeFactor = audioGenerator->_fadeFactor;

    Float32 *bufferActive    = (Float32 *)ioData->mBuffers[audioGenerator->_activeChannel].mData;
    Float32 *bufferNonActive = (Float32 *)ioData->mBuffers[1 - audioGenerator->_activeChannel].mData;
    
    // Generate the samples
    for (UInt32 frame = 0; frame < inNumberFrames; frame++) {
        double bufferValue;
        if (audioGenerator->_type == ORKTinnitusTypePureTone) {
            bufferValue = sin(theta) * amplitude * pow(10, 2 * fadeFactor - 2);
        } else {
            // white noise
            bufferValue = ((((double) (arc4random() % ((unsigned)RAND_MAX + 1)) / RAND_MAX) * (2 * audioGenerator->_bufferAmplitude)) - audioGenerator->_bufferAmplitude) * fadeFactor;
        }
        bufferActive[frame] = bufferValue;
        bufferNonActive[frame] = bufferValue;
        
        theta += theta_increment;
        if (theta > 2.0 * M_PI) {
            theta -= 2.0 * M_PI;
        }

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
    }

    // Store the theta back in the view controller
    audioGenerator->_theta = theta;
    audioGenerator->_fadeFactor = fadeFactor;

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
	
    _playing = NO;
    _type = ORKTinnitusTypeUnknown;
    _bufferAmplitude = ORKTinnitusAudioGeneratorAmplitudeDefault;

    _numberFormatter = [[NSNumberFormatter alloc] init];
    _numberFormatter.numberStyle = NSNumberFormatterDecimalStyle;
    
    [self setupAudioSession];
    
    // Automatically stop and then restart audio playback when the app resigns active.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
}

- (void)dealloc {
    [self stop];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)applicationDidBecomeActive:(NSNotification *)notification {
    if (_unit) {
        __unused OSErr error = AudioOutputUnitStart(_unit);
        NSAssert1(error == noErr, @"Error starting unit: %hd", error);
    }
}

- (void)applicationWillResignActive:(NSNotification *)notification {
    if (_unit) {
        __unused OSErr error = AudioOutputUnitStop(_unit);
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
    return (int)([[AVAudioSession sharedInstance] outputVolume] / ORKTinnitusAudioGeneratorIncrementVolumeDefault) * ORKTinnitusAudioGeneratorIncrementVolumeDefault;
}

- (float)getCurrentSystemVolumeInDecibels {
    float vol = [[AVAudioSession sharedInstance] outputVolume];
    return 20.f*log10f(vol+FLT_MIN);
}

- (float)getPuretoneSystemVolumeIndBSPL {
    _systemVolume = [self getCurrentSystemVolume];
    NSDecimalNumber *offsetDueToVolume = [NSDecimalNumber decimalNumberWithString:_headphoneTable.volumeCurve[[NSString stringWithFormat:@"%.4f",_systemVolume]]];
    NSDecimalNumber *dbSPLAmplitudePerFrequency =  [NSDecimalNumber decimalNumberWithString:_headphoneTable.dbSPLAmplitudePerFrequency[[NSString stringWithFormat:@"%.0f",_frequency]]];
    NSDecimalNumber *equalLoudness =  [NSDecimalNumber decimalNumberWithString:_headphoneTable.dbAmplitudePerFrequency[[NSString stringWithFormat:@"%.0f",_frequency]]];
    
    NSDecimalNumberHandler *behavior = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundPlain
                                                                                              scale:2
                                                                                   raiseOnExactness:NO
                                                                                    raiseOnOverflow:NO
                                                                                   raiseOnUnderflow:NO
                                                                                raiseOnDivideByZero:NO];
    
    NSDecimalNumber *resultNumber = [offsetDueToVolume decimalNumberByAdding:dbSPLAmplitudePerFrequency];
    resultNumber = [resultNumber decimalNumberByAdding:equalLoudness withBehavior:behavior];
    return [resultNumber floatValue];
}

- (float)gainFromCurrentSystemVolume {
    _systemVolume = [self getCurrentSystemVolume];
    return [_headphoneTable gainForSystemVolume:_systemVolume];
}

- (void)playSoundAtFrequency:(double)playFrequency {
    _type = ORKTinnitusTypePureTone;
    _frequency = playFrequency;
    _fadeFactor = self.fadeDuration;
    _fadeDuration = self.fadeDuration;
    _rampUp = YES;
    
    [self play];
}

- (void)play {
    if (!_unit) {
        [self createUnit];

        _systemVolume = [self getCurrentSystemVolume];

        // Stop changing parameters on the unit
        OSErr error = AudioUnitInitialize(_unit);
        NSAssert1(error == noErr, @"Error initializing unit: %hd", error);

        // Start playback
        error = AudioOutputUnitStart(_unit);
        NSAssert1(error == noErr, @"Error starting unit: %hd", error);
    }
}

- (void)playWhiteNoise {
    _type = ORKTinnitusTypeWhiteNoise;
    _fadeFactor = self.fadeDuration;
    _fadeDuration = self.fadeDuration;
    _rampUp = YES;

    if (!_unit) {
        [self createUnit];

        // Stop changing parameters on the unit
        OSErr error = AudioUnitInitialize(_unit);
        NSAssert1(error == noErr, @"Error initializing unit: %hd", error);

        // Start playback
        error = AudioOutputUnitStart(_unit);
        NSAssert1(error == noErr, @"Error starting unit: %hd", error);
    }
}

- (void)stop {
    if (_unit) {
        _rampUp = NO;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(_fadeDuration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            AudioOutputUnitStop(_unit);
            AudioUnitUninitialize(_unit);
            AudioComponentInstanceDispose(_unit);
            _unit = nil;
            _playing = NO;
        });
        
    }
}

- (void)setupAudioSession {
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    BOOL ok;
    NSError *setCategoryError = nil;
    ok = [audioSession setCategory:AVAudioSessionCategoryPlayback error:&setCategoryError];
    NSAssert1(ok, @"Audio error %@", setCategoryError);
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleInterruption:)
                                                 name:AVAudioSessionInterruptionNotification
                                               object:audioSession];
}

- (void)createUnit {
    AudioComponentDescription defaultOutputDescription;
    defaultOutputDescription.componentType = kAudioUnitType_Output;
    defaultOutputDescription.componentSubType = kAudioUnitSubType_RemoteIO;
    defaultOutputDescription.componentManufacturer = kAudioUnitManufacturer_Apple;
    defaultOutputDescription.componentFlags = 0;
    defaultOutputDescription.componentFlagsMask = 0;

    // Get the default playback output unit
    AudioComponent defaultOutput = AudioComponentFindNext(NULL, &defaultOutputDescription);
    NSAssert(defaultOutput, @"Can't find default output");

    // Create a new unit based on this that we'll use for output
    OSErr error = AudioComponentInstanceNew(defaultOutput, &_unit);
    NSAssert1(_unit, @"Error creating unit: %hd", error);

    // Set our tone rendering function on the unit
    AURenderCallbackStruct input;
    input.inputProc = ORKTinnitusAudioGeneratorRenderTone;
    input.inputProcRefCon = (__bridge void *)(self);
    error = AudioUnitSetProperty(_unit,
                               kAudioUnitProperty_SetRenderCallback,
                               kAudioUnitScope_Input,
                               0,
                               &input,
                               sizeof(input));
    NSAssert1(error == noErr, @"Error setting callback: %hd", error);

    // Set the format to 32 bit, single channel, floating point, linear PCM
    const int four_bytes_per_float = 4;
    const int eight_bits_per_byte = 8;
    AudioStreamBasicDescription streamFormat;
    streamFormat.mSampleRate = ORKTinnitusAudioGeneratorSampleRateDefault;
    streamFormat.mFormatID = kAudioFormatLinearPCM;
    streamFormat.mFormatFlags = kAudioFormatFlagsNativeFloatPacked | kAudioFormatFlagIsNonInterleaved;
    streamFormat.mBytesPerPacket = four_bytes_per_float;
    streamFormat.mFramesPerPacket = 1;
    streamFormat.mBytesPerFrame = four_bytes_per_float;
    streamFormat.mChannelsPerFrame = 2;
    streamFormat.mBitsPerChannel = four_bytes_per_float * eight_bits_per_byte;
    error = AudioUnitSetProperty (_unit,
                                kAudioUnitProperty_StreamFormat,
                                kAudioUnitScope_Input,
                                0,
                                &streamFormat,
                                sizeof(AudioStreamBasicDescription));
    NSAssert1(error == noErr, @"Error setting stream format: %hd", error);
    
    _playing = YES;
}

- (void)handleInterruption:(id)sender {
    [self stop];
}

- (void)adjustBufferAmplitude:(double) newAmplitude {
    _bufferAmplitude = MIN(MAX(newAmplitude, 0), 1);
}

@end
