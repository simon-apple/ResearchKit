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

#import "ORKStepNavigationRule.h"
#import "ORKSecondaryActionStepNavigationRule.h"
#import "ORKHelpers_Internal.h"

@implementation ORKSecondaryActionStepNavigationRule

- (instancetype)initWithDestinationStepIdentifier:(NSString *)destinationStepIdentifier {
    ORKThrowMethodUnavailableException();
}

- (instancetype)initWithDestinationStepIdentifier:(NSString *)destinationStepIdentifier
                                             text:(NSString *)text {
    ORKThrowInvalidArgumentExceptionIfNil(destinationStepIdentifier);
    ORKThrowInvalidArgumentExceptionIfNil(text);
    self = [super initWithDestinationStepIdentifier:destinationStepIdentifier];
    if (self) {
        _text = [text copy];
    }
    
    return self;
}

- (instancetype)init {
    return [self initWithDestinationStepIdentifier:ORKSkipStepIdentifier text:ORKLocalizedString(@"BUTTON_SKIP", nil)];
}

- (NSString *)identifierForDestinationStepWithTaskResult:(ORKTaskResult *)ORKTaskResult {
    return self.destinationStepIdentifier;
}

- (BOOL)isSkipMode {
    return [self.destinationStepIdentifier isEqualToString:ORKSkipStepIdentifier];
}

#pragma mark NSSecureCoding

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        ORK_DECODE_OBJ_CLASS(aDecoder, text, NSString);
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    ORK_ENCODE_OBJ(aCoder, text);
}

#pragma mark NSCopying

- (instancetype)copyWithZone:(NSZone *)zone {
    __typeof(self) rule = [super copyWithZone:zone];
    rule->_text = [_text copy];

    return rule;
}

- (BOOL)isEqual:(id)object {
    BOOL isParentSame = [super isEqual:object];
    __typeof(self) castObject = object;
    return (isParentSame
            && ORKEqualObjects(_text, castObject->_text));
}

- (NSUInteger)hash {
    return super.hash ^ _text.hash;
}

@end
