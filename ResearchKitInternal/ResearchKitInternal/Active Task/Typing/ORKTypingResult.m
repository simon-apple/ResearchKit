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

// apple-internal
#import "ORKTypingResult.h"

#import <ResearchKit/ORKResult_Private.h>
#import <ResearchKit/ORKHelpers_Internal.h>

@interface ORKTypingResult ()
@end

@implementation ORKTypingResult

#pragma mark - NSSecureCoding

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        ORK_DECODE_OBJ_CLASS(coder, errors, NSMutableArray);
        ORK_DECODE_INTEGER(coder, finalErrorCount);
        ORK_DECODE_INTEGER(coder, numDeletes);
        ORK_DECODE_INTEGER(coder, totalCharacterCount);
        ORK_DECODE_DOUBLE(coder, timeTakenToType);
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [super encodeWithCoder:coder];
    ORK_ENCODE_OBJ(coder, errors);
    ORK_ENCODE_INTEGER(coder, finalErrorCount);
    ORK_ENCODE_INTEGER(coder, numDeletes);
    ORK_ENCODE_INTEGER(coder, totalCharacterCount);
    ORK_ENCODE_DOUBLE(coder, timeTakenToType);
}


#pragma mark - NSCopying

- (instancetype)copyWithZone:(NSZone *)zone {
    ORKTypingResult *result = [super copyWithZone:zone];
    result.errors = self.errors;
    result.finalErrorCount = self.finalErrorCount;
    result.numDeletes = self.numDeletes;
    result.totalCharacterCount = self.totalCharacterCount;
    result.timeTakenToType = self.timeTakenToType;
    return result;
}

- (BOOL)isEqual:(id)object {
    BOOL isParentSame = [super isEqual:object];
    
    __typeof(self) castObject = object;
    return (isParentSame
            && ORKEqualObjects(self.errors, castObject.errors)
            && self.finalErrorCount == castObject.finalErrorCount
            && self.numDeletes == castObject.numDeletes
            && self.totalCharacterCount == castObject.totalCharacterCount
            && self.timeTakenToType == castObject.timeTakenToType);
}

- (NSUInteger)hash {
    return [super hash] ^
        (self.errors ? 0xf : 0x0) ^
        @(self.finalErrorCount).hash ^
        @(self.numDeletes).hash ^
        @(self.totalCharacterCount).hash ^
        @(self.timeTakenToType).hash;
}

#pragma mark - ResearchKit

- (NSString *)descriptionWithNumberOfPaddingSpaces:(NSUInteger)numberOfPaddingSpaces {
    return [NSString stringWithFormat:@"%@; errors: %@; finalErrorCount: %i; numDeletes: %i, totalCharacterCount: %i, timeTakenToType: %.3f; %@",
            [self descriptionPrefixWithNumberOfPaddingSpaces:numberOfPaddingSpaces],
            self.errors,
            self.finalErrorCount,
            self.numDeletes,
            self.totalCharacterCount,
            self.timeTakenToType,
            self.descriptionSuffix];
}

@end
