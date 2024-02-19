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

@implementation ORKIdBHLToneAudiometryResult

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
  
    ORK_ENCODE_OBJ(aCoder, discreteUnits);
    ORK_ENCODE_OBJ(aCoder, fitMatrix);
    ORK_ENCODE_INTEGER(aCoder, algorithmVersion);
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        ORK_DECODE_OBJ_ARRAY(aDecoder, discreteUnits, ORKdBHLToneAudiometryFrequencySample);
        ORK_DECODE_OBJ_DICTIONARY(aDecoder, fitMatrix, NSString, NSNumber);
        ORK_DECODE_INTEGER(aDecoder, algorithmVersion);
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
            );
}

- (NSUInteger)hash {
    NSUInteger resultsHash = self.discreteUnits.hash ^ self.fitMatrix.hash ^ self.algorithmVersion;
    
    return super.hash ^ resultsHash;
}

- (instancetype)copyWithZone:(NSZone *)zone {
    ORKIdBHLToneAudiometryResult *result = [super copyWithZone:zone];
    result.discreteUnits = [self.discreteUnits copy];
    result.fitMatrix = [self.fitMatrix copy];
    result.algorithmVersion = self.algorithmVersion;

    return result;
}

- (NSString *)descriptionWithNumberOfPaddingSpaces:(NSUInteger)numberOfPaddingSpaces {
    return [NSString stringWithFormat:@"%@; algorithm: %ld, outputvolume: %.1lf; samples: %@; tones: %@; fitMatrix: %@; headphoneType: %@; tonePlaybackDuration: %.1lf; postStimulusDelay: %.1lf%@", [self descriptionPrefixWithNumberOfPaddingSpaces:numberOfPaddingSpaces], (long)self.algorithmVersion, self.outputVolume, self.samples, self.discreteUnits, self.fitMatrix, self.headphoneType, self.tonePlaybackDuration, self.postStimulusDelay, self.descriptionSuffix];
}


@end
