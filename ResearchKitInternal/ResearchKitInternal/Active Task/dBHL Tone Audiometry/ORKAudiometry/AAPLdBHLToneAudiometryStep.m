//
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

#import "AAPLdBHLToneAudiometryStep.h"
#import "ResearchKitInternal/ResearchKitInternal-Swift.h"

#import <ResearchKit/ORKHelpers_Internal.h>

#define ORKdBHLToneAudiometryTaskdBHLDefaultAlgorithm 0
#define ORKdBHLToneAudiometryTaskdBHLMaximumThreshold 75.0

// internal methods for the parent class
@interface ORKdBHLToneAudiometryStep()

- (void)commonInit;
- (id<ORKAudiometryProtocol>)createAudiometryEngine;

@end

@implementation AAPLdBHLToneAudiometryStep

- (void)commonInit {
    [super commonInit];
    self.algorithm = ORKdBHLToneAudiometryTaskdBHLDefaultAlgorithm;
    self.dBHLMaximumThreshold = ORKdBHLToneAudiometryTaskdBHLMaximumThreshold;

}

- (instancetype)copyWithZone:(NSZone *)zone {
    AAPLdBHLToneAudiometryStep *step = [super copyWithZone:zone];
    
    step.algorithm = self.algorithm;
    step.dBHLMaximumThreshold = self.dBHLMaximumThreshold;
    
    return step;
}

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        ORK_DECODE_INTEGER(aDecoder, algorithm);
        ORK_DECODE_DOUBLE(aDecoder, dBHLMaximumThreshold);
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];

    ORK_ENCODE_INTEGER(aCoder, algorithm);
    ORK_ENCODE_DOUBLE(aCoder, dBHLMaximumThreshold);
}

- (BOOL)isEqual:(id)object {
    __typeof(self) castObject = object;

    return [super isEqual:object]
        && (self.algorithm == castObject.algorithm)
        && (self.dBHLMaximumThreshold == castObject.dBHLMaximumThreshold);
}

- (id<ORKAudiometryProtocol>)createAudiometryEngine {
    switch (self.algorithm) {
        case 1:
            if (@available(iOS 14, *)) {
                return [[ORKNewAudiometry alloc] initWithChannel:self.earPreference initialLevel:self.initialdBHLValue minLevel:self.dBHLMinimumThreshold maxLevel:self.dBHLMaximumThreshold frequencies: self.frequencyList];
            }
        default:
            return [super createAudiometryEngine];
    }
}

@end
