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

#import "ORKTinnitusPureToneStep.h"
#import "ORKTinnitusPureToneStepViewController.h"

#import "ORKHelpers_Internal.h"

#define ORKTinnitusPureToneTaskLowIndex 1
#define ORKTinnitusPureToneTaskMediumIndex 5
#define ORKTinnitusPureToneTaskHighIndex 12

@implementation ORKTinnitusPureToneStep

+ (Class)stepViewControllerClass {
    return [ORKTinnitusPureToneStepViewController class];
}

- (instancetype)initWithIdentifier:(NSString *)identifier {
    self = [super initWithIdentifier:identifier];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    self.listOfChoosableFrequencies = @[@315.0, @354.0, @400, @449, @500, @561, @630.0, @707.0, @800.0, @898.0, @1000.0, @1122.0, @1250.0, @1403.0, @1600.0, @1796.0, @2000.0, @2245.0, @2500.0, @2806.0, @3150.0, @3536.0, @4000.0, @4490.0, @5000.0, @5612.0, @6300.0, @7072.0, @8000.0, @8980.0, @10000.0, @11224.0, @12500.0];
    self.lowFrequencyIndex = ORKTinnitusPureToneTaskLowIndex;
    self.mediumFrequencyIndex = ORKTinnitusPureToneTaskMediumIndex;
    self.highFrequencyIndex = ORKTinnitusPureToneTaskHighIndex;
    self.roundNumber = 1;
}

- (void)validateParameters {
    [super validateParameters];
}

- (BOOL)startsFinished {
    return NO;
}

- (BOOL)shouldContinueOnFinish {
    return YES;
}

- (instancetype)copyWithZone:(NSZone *)zone {
    ORKTinnitusPureToneStep *step = [super copyWithZone:zone];
    step.listOfChoosableFrequencies = [self.listOfChoosableFrequencies copy];
    step.lowFrequencyIndex = self.lowFrequencyIndex;
    step.mediumFrequencyIndex = self.mediumFrequencyIndex;
    step.highFrequencyIndex = self.highFrequencyIndex;
    step.roundNumber = self.roundNumber;
    return step;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        ORK_DECODE_OBJ(aDecoder, listOfChoosableFrequencies);
        ORK_DECODE_INTEGER(aDecoder, lowFrequencyIndex);
        ORK_DECODE_INTEGER(aDecoder, mediumFrequencyIndex);
        ORK_DECODE_INTEGER(aDecoder, highFrequencyIndex);
        ORK_DECODE_INTEGER(aDecoder, roundNumber);
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    ORK_ENCODE_OBJ(aCoder, listOfChoosableFrequencies);
    ORK_ENCODE_INTEGER(aCoder, lowFrequencyIndex);
    ORK_ENCODE_INTEGER(aCoder, mediumFrequencyIndex);
    ORK_ENCODE_INTEGER(aCoder, highFrequencyIndex);
    ORK_ENCODE_INTEGER(aCoder, roundNumber);
}

+ (BOOL)supportsSecureCoding {
    return YES;
}
- (NSUInteger)hash {
    return super.hash ^ self.listOfChoosableFrequencies.hash;
}

- (BOOL)isEqual:(id)object {
    BOOL isParentSame = [super isEqual:object];

    __typeof(self) castObject = object;
    return (isParentSame
            && ORKEqualObjects(self.listOfChoosableFrequencies, castObject.listOfChoosableFrequencies)
            && (self.roundNumber == castObject.roundNumber)
            && (self.lowFrequencyIndex == castObject.lowFrequencyIndex)
            && (self.mediumFrequencyIndex == castObject.mediumFrequencyIndex)
            && (self.highFrequencyIndex == castObject.highFrequencyIndex));
}

@end
