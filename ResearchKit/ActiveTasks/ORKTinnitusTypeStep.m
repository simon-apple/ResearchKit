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


#import "ORKTinnitusTypeStep.h"
#import "ORKTinnitusTypeStepViewController.h"
#import "ORKLearnMoreItem.h"
#import "ORKAnswerFormat_Internal.h"
#import "ORKStep_Private.h"

#import "ORKHelpers_Internal.h"

#define ORKTinnitusTypeMinimumFrequency 300.0
#define ORKTinnitusTypeMaximumFrequency 12500.0
#define ORKTinnitusTypeDefaultFrequency 1000.0

@implementation ORKTinnitusTypeStep

+ (Class)stepViewControllerClass {
    return [ORKTinnitusTypeStepViewController class];
}

- (instancetype)initWithIdentifier:(NSString *)identifier {
    self = [super initWithIdentifier:identifier];
    if (self) {
        [self commonInit];
    }
    return self;
}

+ (instancetype)stepWithIdentifier:(NSString *)identifier title:(nullable NSString *)title
{
    ORKTinnitusTypeStep *step = [[ORKTinnitusTypeStep alloc] initWithIdentifier:identifier];
    [step commonInit];
    step.title = title;
    return step;
}

+ (instancetype)stepWithIdentifier:(NSString *)identifier title:(nullable NSString *)title frequency:(double)frequency {
    ORKTinnitusTypeStep *step = [[ORKTinnitusTypeStep alloc] initWithIdentifier:identifier];
    [step commonInit];
    step.title = title;
    step.frequency = frequency;
    return step;
}

- (void)commonInit {
    self.frequency = ORKTinnitusTypeDefaultFrequency;
}

- (void)validateParameters {
    [super validateParameters];
    
    if (self.frequency < ORKTinnitusTypeMinimumFrequency) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:[NSString stringWithFormat:@"frequency cannot be lower than %@ hertz.", @(ORKTinnitusTypeMinimumFrequency)]  userInfo:@{@"frequency": [NSNumber numberWithDouble:self.frequency]}];
    }
    
    if (self.frequency > ORKTinnitusTypeMaximumFrequency) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:[NSString stringWithFormat:@"frequency cannot be higher than %@ hertz.", @(ORKTinnitusTypeMaximumFrequency)]  userInfo:@{@"frequency": [NSNumber numberWithDouble:self.frequency]}];
    }
}


- (instancetype)copyWithZone:(NSZone *)zone {
    ORKTinnitusTypeStep *step = [super copyWithZone:zone];
    step.frequency = self.frequency;
    return step;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        ORK_DECODE_DOUBLE(aDecoder, frequency);
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    ORK_ENCODE_DOUBLE(aCoder, frequency);
}

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (BOOL)isEqual:(id)object {
    BOOL isParentSame = [super isEqual:object];
    
    __typeof(self) castObject = object;
    return (isParentSame
            && (self.frequency == castObject.frequency));
}


@end
