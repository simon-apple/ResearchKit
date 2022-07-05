/*
 Copyright (c) 2019, Apple Inc. All rights reserved.
 
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

#import "ORKHeadphoneDetectResult.h"

#import "ORKResult_Private.h"
#import "ORKHelpers_Internal.h"

@implementation ORKHeadphoneDetectResult

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    ORK_ENCODE_OBJ(aCoder, headphoneType);
    ORK_ENCODE_OBJ(aCoder, vendorID);
    ORK_ENCODE_OBJ(aCoder, productID);
    ORK_ENCODE_INTEGER(aCoder, deviceSubType);
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        ORK_DECODE_OBJ_CLASS(aDecoder, headphoneType, NSString);
        ORK_DECODE_OBJ_CLASS(aDecoder, vendorID, NSString);
        ORK_DECODE_OBJ_CLASS(aDecoder, productID, NSString);
        ORK_DECODE_INTEGER(aDecoder, deviceSubType);
    }
    return self;
}

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (BOOL)isEqual:(id)object {
    BOOL isParentSame = [super isEqual:object];
    
    __typeof(self) castObject = object;
    return (isParentSame
            && ORKEqualObjects(self.headphoneType, castObject.headphoneType)
            && ORKEqualObjects(self.vendorID, castObject.vendorID)
            && ORKEqualObjects(self.productID, castObject.productID)
            && self.deviceSubType == castObject.deviceSubType
            );
}

- (NSUInteger)hash {
    return super.hash ^ self.headphoneType.hash ^ self.vendorID.hash ^ self.productID.hash;
}

- (instancetype)copyWithZone:(NSZone *)zone {
    ORKHeadphoneDetectResult *result = [super copyWithZone:zone];
    result.headphoneType = [self.headphoneType copy];
    result.vendorID = [self.vendorID copy];
    result.productID = [self.productID copy];
    result.deviceSubType = self.deviceSubType;
    return result;
}

- (NSString *)descriptionWithNumberOfPaddingSpaces:(NSUInteger)numberOfPaddingSpaces {
    return [NSString stringWithFormat:@"%@; headphoneType: %@; vendorId: %@; productId: %@; deviceSubType: %li;%@", [self descriptionPrefixWithNumberOfPaddingSpaces:numberOfPaddingSpaces], self.headphoneType, self.vendorID, self.productID, self.deviceSubType, self.descriptionSuffix];
}

@end

#endif
