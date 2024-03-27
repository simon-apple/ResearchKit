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

#import <Foundation/Foundation.h>
#import "ORKIdBHLToneAudiometryAudioGenerator.h"
#import "ResearchKitInternal/ResearchKitInternal-Swift.h"

@implementation ORKIdBHLToneAudiometryAudioGenerator

- (NSDecimalNumber *)calculatedBSPLFromSensitivities:(NSDictionary *)sensitivityPerFrequency atFrequency:(double)frequency {
    NSArray *sortedfrequencies = [[sensitivityPerFrequency allKeys] sortedArrayUsingComparator:^NSComparisonResult(NSString*  _Nonnull obj1, NSString*  _Nonnull obj2) {
        return [obj1 doubleValue] > [obj2 doubleValue];
    }];
    NSArray *sortedValues = [sensitivityPerFrequency objectsForKeys:sortedfrequencies notFoundMarker:@""];
    NSArray *frequencies = [sortedfrequencies valueForKey:@"doubleValue"];
    NSArray *values = [sortedValues valueForKey:@"doubleValue"];

    double sensitivity = [Interpolators interp1dWithXValues:frequencies yValues:values xPoint:frequency];
    return [NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%lf",sensitivity]];
}

- (NSDecimalNumber *)calculateBaselinedBSPLFromSensitivities:(NSDictionary *)sensitivityPerFrequency retspls:(NSDictionary *)retsplMap frequency:(double)frequency {
    NSArray *sortedfrequencies = [[sensitivityPerFrequency allKeys] sortedArrayUsingComparator:^NSComparisonResult(NSString*  _Nonnull obj1, NSString*  _Nonnull obj2) {
        return [obj1 doubleValue] > [obj2 doubleValue];
    }];
    NSArray *frequencies = [sortedfrequencies valueForKey:@"doubleValue"];
    NSArray *sortedRetspls = [retsplMap objectsForKeys:sortedfrequencies notFoundMarker:@""];
    NSArray *retspls = [sortedRetspls valueForKey:@"doubleValue"];
   
    double retspl = [Interpolators interp1dWithXValues:frequencies yValues:retspls xPoint:frequency];
    return [NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%lf",retspl]];
}

@end
