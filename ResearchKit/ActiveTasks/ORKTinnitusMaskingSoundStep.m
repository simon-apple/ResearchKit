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

#import "ORKTinnitusMaskingSoundStep.h"
#import "ORKTinnitusMaskingSoundStepViewController.h"

#import "ORKHelpers_Internal.h"

#define ORKTinnitusTaskMaskingBandwidth 0.34
#define ORKTinnitusTaskMaskingGain -96.0

@implementation ORKTinnitusMaskingSoundStep

+ (Class)stepViewControllerClass {
    return [ORKTinnitusMaskingSoundStepViewController class];
}

- (instancetype)initWithIdentifier:(NSString *)identifier
                  maskingSoundType:(ORKTinnitusMaskingSoundType)maskingSoundType {
    self = [super initWithIdentifier:identifier];
    if (self) {
        [self commonInit];
        self.maskingSoundType = maskingSoundType;
    }
    return self;
}

- (instancetype)initWithIdentifier:(NSString *)identifier
                  maskingSoundType:(ORKTinnitusMaskingSoundType)maskingSoundType
                    notchFrequency:(double)notchFrequency {
    self = [super initWithIdentifier:identifier];
    if (self) {
        [self commonInit];
        self.maskingSoundType = maskingSoundType;
        self.notchFrequency = notchFrequency;
    }
    return self;
}

- (void)commonInit {
    self.notchFrequency = 0.0;
    self.bandwidth = ORKTinnitusTaskMaskingBandwidth;
    self.gain = ORKTinnitusTaskMaskingGain;
}

- (void)validateParameters {
    [super validateParameters];
    
    if ( !self.maskingSoundType || self.maskingSoundType.length == 0) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Matching soundtype cannot be nil or empty" userInfo:nil];
    }
}

- (BOOL)startsFinished {
    return NO;
}

- (BOOL)shouldContinueOnFinish {
    return YES;
}

- (instancetype)copyWithZone:(NSZone *)zone {
    ORKTinnitusMaskingSoundStep *step = [super copyWithZone:zone];
    step.maskingSoundType = [self.maskingSoundType copy];
    step.notchFrequency = self.notchFrequency;
    step.bandwidth = self.bandwidth;
    step.gain = self.gain;
    return step;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [aDecoder decodeFloatForKey:@"bandwidth"];
        [aDecoder decodeFloatForKey:@"gain"];
        ORK_DECODE_OBJ(aDecoder, maskingSoundType);
        ORK_DECODE_DOUBLE(aDecoder, notchFrequency);
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    [aCoder encodeFloat:self.bandwidth forKey:@"bandwidth"];
    [aCoder encodeFloat:self.gain forKey:@"gain"];
    ORK_ENCODE_OBJ(aCoder, maskingSoundType);
    ORK_ENCODE_DOUBLE(aCoder, notchFrequency);
}

+ (BOOL)supportsSecureCoding {
    return YES;
}
- (NSUInteger)hash {
    return super.hash ^ self.maskingSoundType.hash;
}

- (BOOL)isEqual:(id)object {
    BOOL isParentSame = [super isEqual:object];
    
    __typeof(self) castObject = object;
    return (isParentSame
            && ORKEqualObjects(self.maskingSoundType, castObject.maskingSoundType)
            && (self.notchFrequency == castObject.notchFrequency)
            && (self.bandwidth == castObject.bandwidth)
            && (self.gain == castObject.gain)
            );
}


@end
