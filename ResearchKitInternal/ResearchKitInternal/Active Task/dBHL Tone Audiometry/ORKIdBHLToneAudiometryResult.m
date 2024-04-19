/*
 Copyright (c) 2023, Apple Inc. All rights reserved.
 
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

#import "ORKIdBHLToneAudiometryResult.h"

#import <ResearchKit/ORKResult_Private.h>
#import <ResearchKit/ORKHelpers_Internal.h>

@implementation ORKdBHLToneAudiometryMethodOfAdjustmentInteraction

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    ORK_ENCODE_DOUBLE(aCoder, dBHLValue);
    ORK_ENCODE_DOUBLE(aCoder, timeStamp);
    ORK_ENCODE_DOUBLE(aCoder, sourceOfInteraction);
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        ORK_DECODE_DOUBLE(aDecoder, dBHLValue);
        ORK_DECODE_DOUBLE(aDecoder, timeStamp);
        ORK_DECODE_DOUBLE(aDecoder, sourceOfInteraction);
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
            (self.sourceOfInteraction == castObject.sourceOfInteraction));
}

- (instancetype)copyWithZone:(NSZone *)zone {
    ORKdBHLToneAudiometryMethodOfAdjustmentInteraction *interaction = [[[self class] allocWithZone:zone] init];
    interaction.dBHLValue = self.dBHLValue;
    interaction.timeStamp = self.timeStamp;
    interaction.sourceOfInteraction = self.sourceOfInteraction;
    return interaction;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@; dBHLValue: %.1lf; timeStamp: %.5lf; sourceOfInteraction %ld>", self.class.description, self.dBHLValue, self.timeStamp, (long)self.sourceOfInteraction];
}

@end

@implementation ORKIdBHLToneAudiometryFrequencySample

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    
    ORK_ENCODE_OBJ(aCoder, methodOfAdjustmentInteractions);
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        ORK_DECODE_OBJ_ARRAY(aDecoder, methodOfAdjustmentInteractions, ORKdBHLToneAudiometryMethodOfAdjustmentInteraction);
    }
    return self;
}

- (BOOL)isEqual:(id)object {
    BOOL isParentSame = [super isEqual:object];
    
    __typeof(self) castObject = object;
    return (isParentSame
            && ORKEqualObjects(self.methodOfAdjustmentInteractions, castObject.methodOfAdjustmentInteractions)
            );
}

- (instancetype)copyWithZone:(NSZone *)zone {
    ORKIdBHLToneAudiometryFrequencySample *sample = [super copyWithZone:zone];
    sample.methodOfAdjustmentInteractions = self.methodOfAdjustmentInteractions;
    return sample;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: %p; frequency: %.1lf; calculatedThreshold: %.1lf; channel: %ld; units: %@; methodOfAdjustmentInteractions: %@>", self.class.description, self, self.frequency, self.calculatedThreshold, (long)self.channel, self.units, self.methodOfAdjustmentInteractions];
}

@end

@implementation ORKIdBHLToneAudiometryResult

@dynamic samples;

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
  
    ORK_ENCODE_OBJ(aCoder, discreteUnits);
    ORK_ENCODE_OBJ(aCoder, fitMatrix);
    ORK_ENCODE_INTEGER(aCoder, algorithmVersion);
    ORK_ENCODE_INTEGER(aCoder, measurementMethod);
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        ORK_DECODE_OBJ_ARRAY(aDecoder, discreteUnits, ORKIdBHLToneAudiometryFrequencySample);
        ORK_DECODE_OBJ_DICTIONARY(aDecoder, fitMatrix, NSString, NSNumber);
        ORK_DECODE_INTEGER(aDecoder, algorithmVersion);
        ORK_DECODE_INTEGER(aDecoder, measurementMethod);
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
            && ORKEqualObjects(self.discreteUnits, castObject.discreteUnits)
            && ORKEqualObjects(self.fitMatrix, castObject.fitMatrix)
            && self.algorithmVersion == castObject.algorithmVersion
            && self.measurementMethod == castObject.measurementMethod
            );
}

- (NSUInteger)hash {
    NSUInteger resultsHash = self.discreteUnits.hash ^ self.fitMatrix.hash ^ self.algorithmVersion ^ self.measurementMethod;
    
    return super.hash ^ resultsHash;
}

- (instancetype)copyWithZone:(NSZone *)zone {
    ORKIdBHLToneAudiometryResult *result = [super copyWithZone:zone];
    result.discreteUnits = [self.discreteUnits copy];
    result.fitMatrix = [self.fitMatrix copy];
    result.algorithmVersion = self.algorithmVersion;
    result.measurementMethod = self.measurementMethod;

    return result;
}

- (NSString *)descriptionWithNumberOfPaddingSpaces:(NSUInteger)numberOfPaddingSpaces {
    return [NSString stringWithFormat:@"%@; algorithm: %ld, outputvolume: %.1lf; samples: %@; tones: %@; fitMatrix: %@; headphoneType: %@; tonePlaybackDuration: %.1lf; postStimulusDelay: %.1lf%@, measurementMethod: %@", [self descriptionPrefixWithNumberOfPaddingSpaces:numberOfPaddingSpaces], (long)self.algorithmVersion, self.outputVolume, self.samples, self.discreteUnits, self.fitMatrix, self.headphoneType, self.tonePlaybackDuration, self.postStimulusDelay, self.descriptionSuffix, self.measurementMethod == ORKdBHLToneAudiometryMeasurementMethodLimits ? @"Method of Limits" : @"Method of Adjustment"];
}


@end
