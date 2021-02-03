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
 */

#import "ORKTinnitusPureToneResult.h"

#import "ORKResult_Private.h"
#import "ORKHelpers_Internal.h"
#import "ORKTinnitusTypes.h"

@implementation ORKTinnitusPureToneResult

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    ORK_ENCODE_DOUBLE(aCoder, chosenFrequency);
    ORK_ENCODE_OBJ(aCoder, samples);
    ORK_ENCODE_OBJ(aCoder, errorMessage);
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        ORK_DECODE_DOUBLE(aDecoder, chosenFrequency);
        ORK_DECODE_OBJ_ARRAY(aDecoder, samples, ORKTinnitusUnit);
        ORK_DECODE_OBJ(aDecoder, errorMessage);
    }
    return self;
}

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (BOOL)isEqual:(id)object {
    BOOL isParentSame = [super isEqual:object];

    __typeof(self) castObject = object;
    return (isParentSame &&
            self.chosenFrequency == castObject.chosenFrequency &&
            ORKEqualObjects(self.errorMessage, castObject.errorMessage) &&
            ORKEqualObjects(self.samples, castObject.samples)) ;
}

- (NSUInteger)hash {
    return super.hash ^ self.samples.hash ^ self.errorMessage.hash;
}

- (instancetype)copyWithZone:(NSZone *)zone {
    ORKTinnitusPureToneResult *result = [super copyWithZone:zone];
    result.chosenFrequency = self.chosenFrequency;
    result.samples = [self.samples copy];
    result.errorMessage = [self.errorMessage copy];
    return result;
}

- (NSString *)descriptionWithNumberOfPaddingSpaces:(NSUInteger)numberOfPaddingSpaces {
    return [NSString stringWithFormat:@"%@; samples: %@; userChosenFrequency: %.1lf; errorMessage: %@;",
            [self descriptionPrefixWithNumberOfPaddingSpaces:numberOfPaddingSpaces],
            self.samples, self.chosenFrequency, self.errorMessage];
}

@end

@implementation ORKTinnitusUnit

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    ORK_ENCODE_DOUBLE(aCoder, chosenFrequency);
    ORK_ENCODE_DOUBLE(aCoder, elapsedTime);
    ORK_ENCODE_OBJ(aCoder, availableFrequencies);
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        ORK_DECODE_DOUBLE(aDecoder, chosenFrequency);
        ORK_DECODE_DOUBLE(aDecoder, elapsedTime);
        ORK_DECODE_OBJ_CLASS(aDecoder, availableFrequencies, NSArray);
    }
    return self;
}

- (NSUInteger)hash {
    return super.hash ^ self.availableFrequencies.hash;
}

- (BOOL)isEqual:(id)object {
    if ([self class] != [object class]) {
        return NO;
    }
    
    __typeof(self) castObject = object;
    
    return ((self.chosenFrequency == castObject.chosenFrequency) &&
            (self.elapsedTime == castObject.elapsedTime) &&
            ORKEqualObjects(self.availableFrequencies, castObject.availableFrequencies));
}

- (instancetype)copyWithZone:(NSZone *)zone {
    ORKTinnitusUnit *unit = [[[self class] allocWithZone:zone] init];
    unit.chosenFrequency = self.chosenFrequency;
    unit.elapsedTime = self.elapsedTime;
    unit.availableFrequencies = [self.availableFrequencies copy];
    return unit;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@; userChosenFrequency: %.1lf; availableFrequencies: %@; elapsedTime: %.1lf;>", self.class.description, self.chosenFrequency, self.availableFrequencies, self.elapsedTime];
}

@end
