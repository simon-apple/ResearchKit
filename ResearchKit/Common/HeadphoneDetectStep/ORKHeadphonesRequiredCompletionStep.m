/*
 Copyright (c) 2021, Apple Inc. All rights reserved.
 
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
// apple-internal

#if RK_APPLE_INTERNAL

#import "ORKHeadphonesRequiredCompletionStep.h"
#import "ORKHeadphonesRequiredCompletionStepViewController.h"
#import "ORKHelpers_Internal.h"

@implementation ORKHeadphonesRequiredCompletionStep

+ (Class)stepViewControllerClass {
    return [ORKHeadphonesRequiredCompletionStepViewController class];
}

- (instancetype)initWithIdentifier:(NSString *)identifier requiredHeadphoneTypes:(ORKHeadphoneTypes)requiredHeadphoneTypes {
    self = [super initWithIdentifier:identifier];
    if (self) {
        self.requiredHeadphoneTypes = requiredHeadphoneTypes;
        
        switch (self.requiredHeadphoneTypes) {
            case ORKHeadphoneTypesAny:
                self.title = ORKLocalizedString(@"SPEECH_IN_NOISE_PREDEFINED_HEADPHONES_REQUIRED_TITLE", nil);
                self.text = ORKLocalizedString(@"SPEECH_IN_NOISE_PREDEFINED_HEADPHONES_REQUIRED_TEXT", nil);
                break;
            case ORKHeadphoneTypesSupported:
                self.title = ORKLocalizedString(@"dBHL_NO_COMPATIBLE_HEADPHONES_COMPLETION_TITLE", nil);
                self.text = ORKLocalizedString(@"dBHL_NO_COMPATIBLE_HEADPHONES_COMPLETION_TEXT", nil);
                break;
        }
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        ORK_DECODE_INTEGER(aDecoder, requiredHeadphoneTypes);
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    ORK_ENCODE_INTEGER(aCoder, requiredHeadphoneTypes);
}

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (instancetype)copyWithZone:(NSZone *)zone {
    ORKHeadphonesRequiredCompletionStep *step = [super copyWithZone:zone];
    step.requiredHeadphoneTypes = self.requiredHeadphoneTypes;
    return step;
}

- (BOOL)isEqual:(id)object {
    BOOL isParentSame = [super isEqual:object];

        __typeof(self) castObject = object;
        return (isParentSame
                && (self.requiredHeadphoneTypes == castObject.requiredHeadphoneTypes));
}

- (NSUInteger)hash {
    return super.hash ^ self.requiredHeadphoneTypes;
}

@end

#endif
