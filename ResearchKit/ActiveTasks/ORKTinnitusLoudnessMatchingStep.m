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

#import "ORKTinnitusLoudnessMatchingStep.h"
#import "ORKTinnitusLoudnessMatchingStepViewController.h"
#import "ORKHelpers_Internal.h"
#import "ORKTinnitusTypes.h"
#include <math.h>

#define ORKTinnitusCalibrationMinimumFrequency 300.0
#define ORKTinnitusCalibrationMaximumFrequency 12500.0

@implementation ORKTinnitusLoudnessMatchingStep

+ (Class)stepViewControllerClass {
    return [ORKTinnitusLoudnessMatchingStepViewController class];
}

- (instancetype)initWithIdentifier:(NSString *)identifier frequency:(double)freq {
    self = [super initWithIdentifier:identifier];
    if (self) {
        [self commonInit];
        self.frequency = freq;
    }
    return self;
}

- (instancetype)initWithIdentifier:(NSString *)identifier noiseType:(NSString *)noiseType {
    self = [super initWithIdentifier:identifier];
    if (self) {
        [self commonInit];
        self.noiseType = noiseType;
    }
    return self;
}

- (void)commonInit {
    self.frequency = -ORKDoubleInvalidValue;
}

- (void)validateParameters {
    [super validateParameters];
    
    if (self.frequency > 0 && self.frequency < ORKTinnitusCalibrationMinimumFrequency) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:[NSString stringWithFormat:@"frequency cannot be lower than %@ hertz.", @(ORKTinnitusCalibrationMinimumFrequency)]  userInfo:@{@"frequency": [NSNumber numberWithDouble:self.frequency]}];
    }
    
    if (self.frequency > ORKTinnitusCalibrationMaximumFrequency) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:[NSString stringWithFormat:@"frequency cannot be higher than %@ hertz.", @(ORKTinnitusCalibrationMaximumFrequency)]  userInfo:@{@"frequency": [NSNumber numberWithDouble:self.frequency]}];
    }
}

- (instancetype)copyWithZone:(NSZone *)zone {
    ORKTinnitusLoudnessMatchingStep *step = [super copyWithZone:zone];
    step.frequency = self.frequency;
    step.noiseType = [self.noiseType copy];
    return step;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        ORK_DECODE_OBJ(aDecoder, noiseType);
        ORK_DECODE_DOUBLE(aDecoder, frequency);
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    ORK_ENCODE_OBJ(aCoder, noiseType);
    ORK_ENCODE_DOUBLE(aCoder, frequency);
}

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (BOOL)isEqual:(id)object {
    BOOL isParentSame = [super isEqual:object];
    
    __typeof(self) castObject = object;
    return (isParentSame
            && [self.noiseType isEqual:castObject.noiseType]
            && self.frequency == self.frequency
            );
}


@end
