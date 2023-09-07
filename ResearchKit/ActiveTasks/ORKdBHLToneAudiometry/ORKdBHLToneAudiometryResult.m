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


#import "ORKdBHLToneAudiometryResult.h"

#import "ORKResult_Private.h"
#import "ORKHelpers_Internal.h"

const double ORKInvalidDBHLValue = DBL_MAX;

@implementation ORKdBHLToneAudiometryTap

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    ORK_ENCODE_DOUBLE(aCoder, dBHLValue);
    ORK_ENCODE_DOUBLE(aCoder, frequency);
    ORK_ENCODE_DOUBLE(aCoder, channel);
    ORK_ENCODE_DOUBLE(aCoder, timeStamp);
    ORK_ENCODE_DOUBLE(aCoder, response);
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        ORK_DECODE_DOUBLE(aDecoder, dBHLValue);
        ORK_DECODE_DOUBLE(aDecoder, frequency);
        ORK_DECODE_DOUBLE(aDecoder, channel);
        ORK_DECODE_DOUBLE(aDecoder, timeStamp);
        ORK_DECODE_DOUBLE(aDecoder, response);
    }
    return self;
}

- (BOOL)isEqual:(id)object {
    if ([self class] != [object class]) {
        return NO;
    }
    
    __typeof(self) castObject = object;
    
    return ((self.dBHLValue == castObject.dBHLValue) &&
            (self.frequency == castObject.frequency) &&
            (self.channel == castObject.channel) &&
            (self.timeStamp == castObject.timeStamp) &&
            (self.response == castObject.response));
}

- (instancetype)copyWithZone:(NSZone *)zone {
    ORKdBHLToneAudiometryTap *tap = [[[self class] allocWithZone:zone] init];
    tap.dBHLValue = self.dBHLValue;
    tap.frequency = self.frequency;
    tap.channel = self.channel;
    tap.timeStamp = self.timeStamp;
    tap.response = self.response;
    return tap;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@; dBHLValue: %.1lf; frequency %.1lf; channel %ld; timeStamp: %.5lf; response %ld>", self.class.description, self.dBHLValue, self.frequency, (long)self.channel, self.timeStamp, (long)self.response];
}

@end

@implementation ORKdBHLToneAudiometryMOAInteraction

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    ORK_ENCODE_DOUBLE(aCoder, dBHLValue);
    ORK_ENCODE_DOUBLE(aCoder, timeStamp);
    ORK_ENCODE_DOUBLE(aCoder, sourceOfChange);
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        ORK_DECODE_DOUBLE(aDecoder, dBHLValue);
        ORK_DECODE_DOUBLE(aDecoder, timeStamp);
        ORK_DECODE_DOUBLE(aDecoder, sourceOfChange);
    }
    return self;
}

- (BOOL)isEqual:(id)object {
    if ([self class] != [object class]) {
        return NO;
    }
    
    __typeof(self) castObject = object;
    
    return ((self.dBHLValue == castObject.dBHLValue) &&
            (self.timeStamp == castObject.timeStamp) &&
            (self.sourceOfChange == castObject.sourceOfChange));
}

- (instancetype)copyWithZone:(NSZone *)zone {
    ORKdBHLToneAudiometryMOAInteraction *interaction = [[[self class] allocWithZone:zone] init];
    interaction.dBHLValue = self.dBHLValue;
    interaction.timeStamp = self.timeStamp;
    interaction.sourceOfChange = self.sourceOfChange;
    return interaction;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@; dBHLValue: %.1lf; timeStamp: %.5lf; sourceOfChange %ld>", self.class.description, self.dBHLValue, self.timeStamp, (long)self.sourceOfChange];
}

@end

@implementation ORKdBHLToneAudiometryResult

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    ORK_ENCODE_DOUBLE(aCoder, outputVolume);
    ORK_ENCODE_DOUBLE(aCoder, tonePlaybackDuration);
    ORK_ENCODE_DOUBLE(aCoder, postStimulusDelay);
    ORK_ENCODE_OBJ(aCoder, headphoneType);
    ORK_ENCODE_OBJ(aCoder, samples);
    
#if RK_APPLE_INTERNAL
    ORK_ENCODE_OBJ(aCoder, deletedSamples);
    ORK_ENCODE_OBJ(aCoder, discreteUnits);
    ORK_ENCODE_OBJ(aCoder, fitMatrix);
    ORK_ENCODE_INTEGER(aCoder, algorithmVersion);
    ORK_ENCODE_OBJ(aCoder, caseSerial);
    ORK_ENCODE_OBJ(aCoder, leftSerial);
    ORK_ENCODE_OBJ(aCoder, rightSerial);
    ORK_ENCODE_OBJ(aCoder, fwVersion);
    ORK_ENCODE_OBJ(aCoder, allTaps);
    ORK_ENCODE_INTEGER(aCoder, numberOfdBHLRetries);
    ORK_ENCODE_OBJ(aCoder, hearingTestFrameworkVersion);
#endif
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        ORK_DECODE_DOUBLE(aDecoder, outputVolume);
        ORK_DECODE_DOUBLE(aDecoder, tonePlaybackDuration);
        ORK_DECODE_DOUBLE(aDecoder, postStimulusDelay);
        ORK_DECODE_OBJ_CLASS(aDecoder, headphoneType, NSString);
        ORK_DECODE_OBJ_ARRAY(aDecoder, samples, ORKdBHLToneAudiometryFrequencySample);
        
#if RK_APPLE_INTERNAL
        ORK_DECODE_OBJ_ARRAY(aDecoder, deletedSamples, ORKdBHLToneAudiometryDeletedSample);
        ORK_DECODE_OBJ_ARRAY(aDecoder, discreteUnits, ORKdBHLToneAudiometryFrequencySample);
        ORK_DECODE_OBJ_DICTIONARY(aDecoder, fitMatrix, NSString, NSNumber);
        ORK_DECODE_INTEGER(aDecoder, algorithmVersion);
        ORK_DECODE_OBJ_CLASS(aDecoder, caseSerial, NSString);
        ORK_DECODE_OBJ_CLASS(aDecoder, leftSerial, NSString);
        ORK_DECODE_OBJ_CLASS(aDecoder, rightSerial, NSString);
        ORK_DECODE_OBJ_CLASS(aDecoder, fwVersion, NSString);
        ORK_DECODE_OBJ_ARRAY(aDecoder, allTaps, ORKdBHLToneAudiometryTap);
        ORK_DECODE_INTEGER(aDecoder, numberOfdBHLRetries);
        ORK_DECODE_OBJ_CLASS(aDecoder, hearingTestFrameworkVersion, NSString);
#endif
    }
    return self;
}

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (BOOL)isEqual:(id)object {
    BOOL isParentSame = [super isEqual:object];
    
    __typeof(self) castObject = object;
    return (isParentSame
            && self.outputVolume == castObject.outputVolume
            && self.tonePlaybackDuration == castObject.tonePlaybackDuration
            && self.postStimulusDelay == castObject.postStimulusDelay
            && ORKEqualObjects(self.headphoneType, castObject.headphoneType)
            && ORKEqualObjects(self.samples, castObject.samples)
#if RK_APPLE_INTERNAL
            && ORKEqualObjects(self.deletedSamples, castObject.deletedSamples)
            && ORKEqualObjects(self.discreteUnits, castObject.discreteUnits)
            && ORKEqualObjects(self.fitMatrix, castObject.fitMatrix)
            && self.algorithmVersion == castObject.algorithmVersion
            && ORKEqualObjects(self.caseSerial, castObject.caseSerial)
            && ORKEqualObjects(self.leftSerial, castObject.leftSerial)
            && ORKEqualObjects(self.rightSerial, castObject.rightSerial)
            && ORKEqualObjects(self.fwVersion, castObject.fwVersion)
            && ORKEqualObjects(self.allTaps, castObject.allTaps)
            && self.numberOfdBHLRetries == castObject.numberOfdBHLRetries
            && ORKEqualObjects(self.hearingTestFrameworkVersion, castObject.hearingTestFrameworkVersion)
#endif
            );
}

- (NSUInteger)hash {
    NSUInteger resultsHash = self.samples.hash ^ self.headphoneType.hash;
    
#if RK_APPLE_INTERNAL
    resultsHash = resultsHash ^ self.deletedSamples.hash ^ self.discreteUnits.hash ^ self.fitMatrix.hash ^ self.algorithmVersion ^ self.caseSerial.hash ^ self.leftSerial.hash ^ self.rightSerial.hash ^ self.fwVersion.hash ^ self.allTaps.hash;
#endif
    
    return super.hash ^ resultsHash;
}

- (instancetype)copyWithZone:(NSZone *)zone {
    ORKdBHLToneAudiometryResult *result = [super copyWithZone:zone];
    result.outputVolume = self.outputVolume;
    result.headphoneType = [self.headphoneType copy];
    result.tonePlaybackDuration = self.tonePlaybackDuration;
    result.postStimulusDelay = self.postStimulusDelay;
    result.samples = [self.samples copy];
    
#if RK_APPLE_INTERNAL
    result.deletedSamples = [self.deletedSamples copy];
    result.discreteUnits = [self.discreteUnits copy];
    result.fitMatrix = [self.fitMatrix copy];
    result.algorithmVersion = self.algorithmVersion;
    result.caseSerial = [self.caseSerial copy];
    result.leftSerial = [self.leftSerial copy];
    result.rightSerial = [self.rightSerial copy];
    result.fwVersion = [self.fwVersion copy];
    result.numberOfdBHLRetries = self.numberOfdBHLRetries;
    result.allTaps = [self.allTaps copy];
    result.hearingTestFrameworkVersion = [self.hearingTestFrameworkVersion copy];
#endif

    return result;
}

- (NSString *)descriptionWithNumberOfPaddingSpaces:(NSUInteger)numberOfPaddingSpaces {
#if RK_APPLE_INTERNAL
    return [NSString stringWithFormat:@"%@; algorithm: %ld, outputvolume: %.1lf; samples: %@; deletedSamples: %@; tones: %@; fitMatrix: %@; headphoneType: %@; tonePlaybackDuration: %.1lf; postStimulusDelay: %.1lf%@; caseSerial: %@; leftSerial: %@; rightSerial: %@; firmwareVersion: %@; allTaps: %@; numberOfdBHLRetries: %lu", [self descriptionPrefixWithNumberOfPaddingSpaces:numberOfPaddingSpaces], (long)self.algorithmVersion, self.outputVolume, self.samples,self.deletedSamples, self.discreteUnits, self.fitMatrix, self.headphoneType, self.tonePlaybackDuration, self.postStimulusDelay, self.descriptionSuffix, self.caseSerial, self.leftSerial, self.rightSerial, self.fwVersion, self.allTaps, self.numberOfdBHLRetries];
#else
    return [NSString stringWithFormat:@"%@; outputvolume: %.1lf; samples: %@; headphoneType: %@; tonePlaybackDuration: %.1lf; postStimulusDelay: %.1lf%@", [self descriptionPrefixWithNumberOfPaddingSpaces:numberOfPaddingSpaces], self.outputVolume, self.samples, self.headphoneType, self.tonePlaybackDuration, self.postStimulusDelay, self.descriptionSuffix];
#endif
}

@end


@implementation ORKdBHLToneAudiometryFrequencySample

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    ORK_ENCODE_DOUBLE(aCoder, frequency);
    ORK_ENCODE_DOUBLE(aCoder, calculatedThreshold);
    ORK_ENCODE_INTEGER(aCoder, channel);
    ORK_ENCODE_OBJ(aCoder, units);
    ORK_ENCODE_OBJ(aCoder, allInteractions);
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        ORK_DECODE_DOUBLE(aDecoder, frequency);
        ORK_DECODE_DOUBLE(aDecoder, calculatedThreshold);
        ORK_DECODE_INTEGER(aDecoder, channel);
        ORK_DECODE_OBJ_ARRAY(aDecoder, units, ORKdBHLToneAudiometryUnit);
        ORK_DECODE_OBJ_ARRAY(aDecoder, allInteractions, ORKdBHLToneAudiometryMOAInteraction);
    }
    return self;
}

- (BOOL)isEqual:(id)object {
    if ([self class] != [object class]) {
        return NO;
    }
    
    __typeof(self) castObject = object;
    
    return ((self.frequency == castObject.frequency) &&
            (self.calculatedThreshold == castObject.calculatedThreshold) &&
            (self.channel == castObject.channel) &&
            ORKEqualObjects(self.units, castObject.units) &&
            ORKEqualObjects(self.allInteractions, castObject.allInteractions));
}

- (instancetype)copyWithZone:(NSZone *)zone {
    ORKdBHLToneAudiometryFrequencySample *sample = [[[self class] allocWithZone:zone] init];
    sample.frequency = self.frequency;
    sample.calculatedThreshold = self.calculatedThreshold;
    sample.channel = self.channel;
    sample.units = self.units;
    sample.allInteractions = self.allInteractions;
    return sample;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: %p; frequency: %.1lf; calculatedThreshold: %.1lf; channel: %ld; units: %@; allInteractions: %@>", self.class.description, self, self.frequency, self.calculatedThreshold, (long)self.channel, self.units, self.allInteractions];
}

@end

@implementation ORKdBHLToneAudiometryDeletedSample

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    ORK_ENCODE_DOUBLE(aCoder, frequency);
    ORK_ENCODE_DOUBLE(aCoder, level);
    ORK_ENCODE_INTEGER(aCoder, channel);
    ORK_ENCODE_INTEGER(aCoder, originalIndex);
    ORK_ENCODE_BOOL(aCoder, response);
    ORK_ENCODE_DOUBLE(aCoder, deletionTimestamp);
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        ORK_DECODE_DOUBLE(aDecoder, frequency);
        ORK_DECODE_DOUBLE(aDecoder, level);
        ORK_DECODE_INTEGER(aDecoder, channel);
        ORK_DECODE_INTEGER(aDecoder, originalIndex);
        ORK_DECODE_BOOL(aDecoder, response);
        ORK_DECODE_DOUBLE(aDecoder, deletionTimestamp);
    }
    return self;
}

- (BOOL)isEqual:(id)object {
    if ([self class] != [object class]) {
        return NO;
    }
    
    __typeof(self) castObject = object;
    
    return ((self.frequency == castObject.frequency) &&
            (self.level == castObject.level) &&
            (self.channel == castObject.channel) &&
            (self.originalIndex == castObject.originalIndex) &&
            (self.response == castObject.response) &&
            (self.deletionTimestamp == castObject.deletionTimestamp));
}

- (instancetype)copyWithZone:(NSZone *)zone {
    ORKdBHLToneAudiometryDeletedSample *sample = [[[self class] allocWithZone:zone] init];
    sample.frequency = self.frequency;
    sample.level = self.level;
    sample.channel = self.channel;
    sample.originalIndex = self.originalIndex;
    sample.response = self.response;
    sample.deletionTimestamp = self.deletionTimestamp;
    return sample;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: %p; frequency: %.1lf; level: %.1lf; channel: %ld; originalIndex: %ld; response: %d; deletionTimestamp: %lf>", self.class.description, self, self.frequency, self.level, (long)self.channel, (long)self.originalIndex, self.response, self.deletionTimestamp];
}

@end


@implementation ORKdBHLToneAudiometryUnit

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    ORK_ENCODE_DOUBLE(aCoder, dBHLValue);
    ORK_ENCODE_DOUBLE(aCoder, timeoutTimeStamp);
    ORK_ENCODE_DOUBLE(aCoder, userTapTimeStamp);
    ORK_ENCODE_DOUBLE(aCoder, startOfUnitTimeStamp);
    ORK_ENCODE_DOUBLE(aCoder, preStimulusDelay);
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        ORK_DECODE_DOUBLE(aDecoder, dBHLValue);
        ORK_DECODE_DOUBLE(aDecoder, timeoutTimeStamp);
        ORK_DECODE_DOUBLE(aDecoder, userTapTimeStamp);
        ORK_DECODE_DOUBLE(aDecoder, startOfUnitTimeStamp);
        ORK_DECODE_DOUBLE(aDecoder, preStimulusDelay);
    }
    return self;
}

- (BOOL)isEqual:(id)object {
    if ([self class] != [object class]) {
        return NO;
    }
    
    __typeof(self) castObject = object;
    
    return ((self.dBHLValue == castObject.dBHLValue) &&
            (self.timeoutTimeStamp == castObject.timeoutTimeStamp) &&
            (self.userTapTimeStamp == castObject.userTapTimeStamp) &&
            (self.preStimulusDelay == castObject.preStimulusDelay) &&
            (self.startOfUnitTimeStamp == castObject.startOfUnitTimeStamp));
}

- (instancetype)copyWithZone:(NSZone *)zone {
    ORKdBHLToneAudiometryUnit *unit = [[[self class] allocWithZone:zone] init];
    unit.dBHLValue = self.dBHLValue;
    unit.timeoutTimeStamp = self.timeoutTimeStamp;
    unit.userTapTimeStamp = self.userTapTimeStamp;
    unit.startOfUnitTimeStamp = self.startOfUnitTimeStamp;
    unit.preStimulusDelay = self.preStimulusDelay;
    return unit;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@; dBHLValue: %.1lf; timeoutTimeStamp %.5lf; userTapTimeStamp %.5lf; startOfUnitTimeStamp: %.5lf; preStimulusDelay %.1lf>", self.class.description, self.dBHLValue, self.timeoutTimeStamp, self.userTapTimeStamp, self.startOfUnitTimeStamp, self.preStimulusDelay];
}

@end

