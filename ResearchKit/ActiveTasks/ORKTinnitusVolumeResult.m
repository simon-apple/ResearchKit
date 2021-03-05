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

#import "ORKTinnitusVolumeResult.h"
#import "ORKResult_Private.h"
#import "ORKHelpers_Internal.h"
#import "ORKTinnitusTypes.h"

@implementation ORKTinnitusVolumeResult

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    ORK_ENCODE_DOUBLE(aCoder, amplitude);
    ORK_ENCODE_DOUBLE(aCoder, frequency);
    ORK_ENCODE_DOUBLE(aCoder, volumeCurve);
    ORK_ENCODE_ENUM(aCoder, type);
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        ORK_DECODE_DOUBLE(aDecoder, amplitude);
        ORK_DECODE_DOUBLE(aDecoder, volumeCurve);
        ORK_DECODE_DOUBLE(aDecoder, frequency);
        ORK_DECODE_ENUM(aDecoder, type);
    }
    return self;
}

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (BOOL)isEqual:(id)object {
    BOOL isParentSame = [super isEqual:object];
    
    __typeof(self) castObject = object;
    return (isParentSame &&
            (self.amplitude == castObject.amplitude) &&
            (self.frequency == castObject.frequency) &&
            (self.volumeCurve == castObject.volumeCurve) &&
            (self.type == castObject.type) ) ;
}

- (NSUInteger)hash {
    return super.hash;
}

- (instancetype)copyWithZone:(NSZone *)zone {
    ORKTinnitusVolumeResult *result = [super copyWithZone:zone];
    result.amplitude = self.amplitude;
    result.frequency = self.frequency;
    result.volumeCurve = self.volumeCurve;
    result.type = self.type;
    return result;
}

- (NSString *)descriptionWithNumberOfPaddingSpaces:(NSUInteger)numberOfPaddingSpaces {
    return [NSString stringWithFormat:@"%@; Type: %li; Amplitude: %0.6f; VolumeCurve: %0.6f; Frequency: %0.1f;", [self descriptionPrefixWithNumberOfPaddingSpaces:numberOfPaddingSpaces], (long)self.type, self.amplitude, self.volumeCurve, self.frequency];
}


@end
