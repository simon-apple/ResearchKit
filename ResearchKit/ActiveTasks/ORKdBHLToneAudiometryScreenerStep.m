/*
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
 */


#import "ORKdBHLToneAudiometryScreenerStep.h"
#import "ORKStep_Private.h"
#import "ORKdBHLToneAudiometryScreenerStepViewController.h"

#import "ORKHelpers_Internal.h"

#define ORKdBHLToneAudiometryTaskToneDuration 100
#define ORKdBHLToneAudiometryTaskTonePauseDuration 100
#define ORKdBHLToneAudiometryTaskInitialdBHLValue 30.925
#define ORKdBHLToneAudiometryTaskdBHLRateUp 2.5
#define ORKdBHLToneAudiometryTaskdBHLRateDown 2.5
#define ORKdBHLToneAudiometryTaskOctaveRate 0
#define ORKdBHLToneAudiometryTaskdBHLMinimumThreshold -10.0
#define ORKdBHLToneAudiometryTaskdBHLMaximumThreshold 75
#define ORKdBHLToneAudiometryTaskNumberOfInversions 8
#define ORKdBHLToneAudiometryTaskStepSize 5.0

@implementation ORKdBHLToneAudiometryScreenerStep

+ (Class)stepViewControllerClass {
    return [ORKdBHLToneAudiometryScreenerStepViewController class];
}

- (instancetype)initWithIdentifier:(NSString *)identifier {
    self = [super initWithIdentifier:identifier];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    self.initialdBHLValue = ORKdBHLToneAudiometryTaskInitialdBHLValue;
    self.dBHLRateUp = ORKdBHLToneAudiometryTaskdBHLRateUp;
    self.dBHLRateDown = ORKdBHLToneAudiometryTaskdBHLRateDown;
    self.dBHLMinimumThreshold = ORKdBHLToneAudiometryTaskdBHLMinimumThreshold;
    self.dBHLMaximumThreshold = ORKdBHLToneAudiometryTaskdBHLMaximumThreshold;
    self.numberOfInversions = ORKdBHLToneAudiometryTaskNumberOfInversions;
    self.toneDuration = ORKdBHLToneAudiometryTaskToneDuration;
    self.postStimulusDelay = ORKdBHLToneAudiometryTaskTonePauseDuration;
    self.octaveRate = ORKdBHLToneAudiometryTaskOctaveRate;
    self.stepSize = ORKdBHLToneAudiometryTaskStepSize;
    
    self.frequencyList = @[@1000.0, @2000.0, @3000.0, @4000.0, @6000.0, @8000.0, @500.0];

    self.stepDuration = CGFLOAT_MAX;
    self.shouldShowDefaultTimer = NO;
    
    // TODO: review the final parameters
    self.isMOA = YES;
    self.usePicker = YES;
}

- (void)validateParameters {
    [super validateParameters];
    
    if (self.toneDuration <= 0) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:[NSString stringWithFormat:@"pulse duration cannot be 0 seconds."]  userInfo:nil];
    }
    if ((self.dBHLRateUp <= 0) || self.dBHLRateUp <=0) {
       @throw [NSException exceptionWithName:NSInvalidArgumentException reason:[NSString stringWithFormat:@"step size cannot be less than or equal to 0"]  userInfo:nil];
    }
    if (self.octaveRate < 0) {
       @throw [NSException exceptionWithName:NSInvalidArgumentException reason:[NSString stringWithFormat:@"octave rate cannot be less than 0"]  userInfo:nil];
    }
    if (self.numberOfInversions < 1) {
       @throw [NSException exceptionWithName:NSInvalidArgumentException reason:[NSString stringWithFormat:@"number of inversions cannot be less than 1"]  userInfo:nil];
    }
    if (self.frequency == 0) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:[NSString stringWithFormat:@"frequency cannot be 0"]  userInfo:nil];
    }
}

- (BOOL)startsFinished {
    return NO;
}

- (BOOL)allowsBackNavigation {
    return NO;
}

- (instancetype)copyWithZone:(NSZone *)zone {
    ORKdBHLToneAudiometryScreenerStep *step = [super copyWithZone:zone];
    step.toneDuration = self.toneDuration;
    step.postStimulusDelay = self.postStimulusDelay;
    step.initialdBHLValue = self.initialdBHLValue;
    step.dBHLRateUp = self.dBHLRateUp;
    step.dBHLRateDown = self.dBHLRateDown;
    step.octaveRate = self.octaveRate;
    step.stepSize = self.stepSize;
    step.dBHLMinimumThreshold = self.dBHLMinimumThreshold;
    step.numberOfInversions = self.numberOfInversions;
    step.headphoneType = self.headphoneType;
    step.earPreference = self.earPreference;
    step.frequency = self.frequency;
    step.frequencyList = self.frequencyList;
    return step;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        ORK_DECODE_DOUBLE(aDecoder, toneDuration);
        ORK_DECODE_DOUBLE(aDecoder, postStimulusDelay);
        ORK_DECODE_DOUBLE(aDecoder, initialdBHLValue);
        ORK_DECODE_DOUBLE(aDecoder, dBHLRateUp);
        ORK_DECODE_DOUBLE(aDecoder, dBHLRateDown);
        ORK_DECODE_DOUBLE(aDecoder, octaveRate);
        ORK_DECODE_DOUBLE(aDecoder, stepSize);
        ORK_DECODE_DOUBLE(aDecoder, dBHLMinimumThreshold);
        ORK_DECODE_INTEGER(aDecoder, numberOfInversions);
        ORK_DECODE_INTEGER(aDecoder, earPreference);
        ORK_DECODE_OBJ_CLASS(aDecoder, headphoneType, NSString);
        ORK_DECODE_DOUBLE(aDecoder, frequency);
        ORK_DECODE_OBJ_ARRAY(aDecoder, frequencyList, NSNumber);
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    ORK_ENCODE_DOUBLE(aCoder, toneDuration);
    ORK_ENCODE_DOUBLE(aCoder, postStimulusDelay);
    ORK_ENCODE_DOUBLE(aCoder, initialdBHLValue);
    ORK_ENCODE_DOUBLE(aCoder, dBHLRateUp);
    ORK_ENCODE_DOUBLE(aCoder, dBHLRateDown);
    ORK_ENCODE_DOUBLE(aCoder, octaveRate);
    ORK_ENCODE_DOUBLE(aCoder, stepSize);
    ORK_ENCODE_DOUBLE(aCoder, dBHLMinimumThreshold);
    ORK_ENCODE_INTEGER(aCoder, numberOfInversions);
    ORK_ENCODE_INTEGER(aCoder, earPreference);
    ORK_ENCODE_OBJ(aCoder, headphoneType);
    ORK_ENCODE_DOUBLE(aCoder, frequency);
    ORK_ENCODE_OBJ(aCoder, frequencyList);
}

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (BOOL)isEqual:(id)object {
    BOOL isParentSame = [super isEqual:object];
    
    __typeof(self) castObject = object;
    return (isParentSame
            && (self.toneDuration == castObject.toneDuration)
            && (self.postStimulusDelay == castObject.postStimulusDelay)
            && (self.initialdBHLValue == castObject.initialdBHLValue)
            && (self.dBHLRateUp == castObject.dBHLRateUp)
            && (self.dBHLRateDown == castObject.dBHLRateDown)
            && (self.octaveRate == castObject.octaveRate)
            && (self.stepSize == castObject.stepSize)
            && (self.dBHLMinimumThreshold == castObject.dBHLMinimumThreshold)
            && (self.numberOfInversions == castObject.numberOfInversions)
            && (self.earPreference == castObject.earPreference)
            && ORKEqualObjects(self.headphoneType, castObject.headphoneType)
            && ORKEqualObjects(self.frequencyList, castObject.frequencyList)
            && (self.frequency == castObject.frequency));
}

@end

