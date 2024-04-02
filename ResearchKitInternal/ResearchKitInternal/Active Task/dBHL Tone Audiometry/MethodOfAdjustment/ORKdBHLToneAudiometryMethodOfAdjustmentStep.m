/*
 Copyright (c) 2022, Apple Inc. All rights reserved.
 
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

#import "ORKdBHLToneAudiometryMethodOfAdjustmentStep.h"
#import "ResearchKitInternal/ResearchKitInternal-Swift.h"

#import <ResearchKit/ORKHelpers_Internal.h>

#define ORKdBHLToneAudiometryMethodOfAdjustmentTaskStepSize 5.0
#define ORKdBHLToneAudiometryMethodOfAdjustmentTaskInitialdBHL 30.93

// internal methods for the parent class
@interface ORKIdBHLToneAudiometryStep()

- (void)commonInit;

@end

@implementation ORKdBHLToneAudiometryMethodOfAdjustmentStep

- (void)commonInit {
    [super commonInit];
    self.stepSize = ORKdBHLToneAudiometryMethodOfAdjustmentTaskStepSize;
    self.frequencyList = @[@1000.0, @2000.0, @3000.0, @4000.0, @6000.0, @8000.0, @500.0];
    self.initialdBHLValue = ORKdBHLToneAudiometryMethodOfAdjustmentTaskInitialdBHL;
}

- (instancetype)copyWithZone:(NSZone *)zone {
    ORKdBHLToneAudiometryMethodOfAdjustmentStep *step = [super copyWithZone:zone];
    
    step.stepSize = self.stepSize;
    
    return step;
}

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        ORK_DECODE_DOUBLE(aDecoder, stepSize);
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];

    ORK_ENCODE_DOUBLE(aCoder, stepSize);
}

- (BOOL)isEqual:(id)object {
    __typeof(self) castObject = object;

    return [super isEqual:object]
        && (self.stepSize == castObject.stepSize);
}

@end
