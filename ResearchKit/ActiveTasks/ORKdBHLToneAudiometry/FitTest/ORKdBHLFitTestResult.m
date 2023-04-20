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

#import "ORKdBHLFitTestResult.h"

#import "ORKResult_Private.h"
#import "ORKHelpers_Internal.h"

@implementation ORKdBHLFitTestResultSample

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    ORK_ENCODE_DOUBLE(aCoder, sealLeftEar);
    ORK_ENCODE_DOUBLE(aCoder, sealRightEar);
    ORK_ENCODE_DOUBLE(aCoder, confidenceLeftEar);
    ORK_ENCODE_DOUBLE(aCoder, confidenceRightEar);
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        ORK_DECODE_DOUBLE(aDecoder, sealLeftEar);
        ORK_DECODE_DOUBLE(aDecoder, sealRightEar);
        ORK_DECODE_DOUBLE(aDecoder, confidenceLeftEar);
        ORK_DECODE_DOUBLE(aDecoder, confidenceRightEar);
    }
    return self;
}

- (BOOL)isEqual:(id)object {
    BOOL isParentSame = [super isEqual:object];
    __typeof(self) castObject = object;
    return (isParentSame &&
        self.sealLeftEar == castObject.sealLeftEar &&
        self.sealRightEar == castObject.sealRightEar &&
        self.confidenceLeftEar == castObject.confidenceLeftEar &&
        self.confidenceRightEar == castObject.confidenceRightEar
     );
}

- (instancetype)copyWithZone:(NSZone *)zone {
    ORKdBHLFitTestResultSample *result = [[[self class] allocWithZone:zone] init];
    result.sealLeftEar = self.sealLeftEar;
    result.sealRightEar = self.sealRightEar;
    result.confidenceLeftEar = self.confidenceLeftEar;
    result.confidenceRightEar = self.confidenceRightEar;
    return result;
}

- (NSString *)descriptionWithNumberOfPaddingSpaces:(NSUInteger)numberOfPaddingSpaces {
    return [NSString stringWithFormat:@"%@; Seal LeftEar: %f, Seal RightEar: %f, Confidence LeftEar: %f, Confidence RightEar: %f;", [self.class description], self.sealLeftEar, self.sealRightEar, self.confidenceLeftEar, self.confidenceRightEar];
}

@end



@implementation ORKdBHLFitTestResult

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    ORK_ENCODE_OBJ(aCoder, fitTestResultSamples);
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        ORK_DECODE_OBJ_ARRAY(aDecoder, fitTestResultSamples, ORKdBHLFitTestResultSample);
    }
    return self;
}

- (BOOL)isEqual:(id)object {
    BOOL isParentSame = [super isEqual:object];
    __typeof(self) castObject = object;
    return (isParentSame && ORKEqualObjects(self.fitTestResultSamples, castObject.fitTestResultSamples));
}

- (instancetype)copyWithZone:(NSZone *)zone {
    ORKdBHLFitTestResult *result = [super copyWithZone:zone];
    result.fitTestResultSamples = [self.fitTestResultSamples copy];
    return result;
}

- (NSString *)descriptionWithNumberOfPaddingSpaces:(NSUInteger)numberOfPaddingSpaces {
    return [NSString stringWithFormat:@"%@; fitTestResultSamples: %@", [self descriptionPrefixWithNumberOfPaddingSpaces:numberOfPaddingSpaces], self.fitTestResultSamples];
}

@end
