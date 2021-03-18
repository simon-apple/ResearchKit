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

#import "ORKTinnitusHeadphoneTable.h"

@implementation ORKTinnitusHeadphoneTable

- (instancetype)initWithHeadphoneType:(ORKHeadphoneTypeIdentifier)headphoneType {
    self = [super init];
    if (self) {
        self.headphoneType = headphoneType;
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    NSString *headphoneTypeUppercased = [_headphoneType uppercaseString];
    NSString *dbAmplitudePerFrequencyFilename;
    NSString *dbSPLAmplitudePerFrequencyFilename;
    NSString *volumeCurveFilename;
    
    if ([headphoneTypeUppercased isEqualToString:ORKHeadphoneTypeIdentifierAirPodsGen1] ||
        [headphoneTypeUppercased isEqualToString:ORKHeadphoneTypeIdentifierAirPodsGen2]) {
        dbAmplitudePerFrequencyFilename = @"dbAmplitudePerFrequency_AIRPODS";
        dbSPLAmplitudePerFrequencyFilename = @"dbSPLAmplitudePerFrequency_AIRPODS";
        volumeCurveFilename = @"volume_curve_AIRPODS";
    } else if ([headphoneTypeUppercased isEqualToString:ORKHeadphoneTypeIdentifierAirPodsPro]) {
        dbAmplitudePerFrequencyFilename = @"dbAmplitudePerFrequency_AIRPODSPRO";
        dbSPLAmplitudePerFrequencyFilename = @"dbSPLAmplitudePerFrequency_AIRPODSPRO";
        volumeCurveFilename = @"volume_curve_AIRPODSPRO";
    } else if ([headphoneTypeUppercased isEqualToString:ORKHeadphoneTypeIdentifierAirPodsMax]) {
         dbAmplitudePerFrequencyFilename = @"dbAmplitudePerFrequency_AIRPODSMAX";
         dbSPLAmplitudePerFrequencyFilename = @"dbSPLAmplitudePerFrequency_AIRPODSMAX";
         volumeCurveFilename = @"volume_curve_AIRPODSMAX";
    } else if ([headphoneTypeUppercased isEqualToString:ORKHeadphoneTypeIdentifierEarPods]) {
        dbAmplitudePerFrequencyFilename = @"dbAmplitudePerFrequency_EARPODS";
        dbSPLAmplitudePerFrequencyFilename = @"dbSPLAmplitudePerFrequency_EARPODS";
        volumeCurveFilename = @"volume_curve_WIRED";
    } else {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"A valid headphone route identifier must be provided" userInfo:nil];
    }
    
    self.volumeCurve = [NSDictionary
                    dictionaryWithContentsOfFile:[[NSBundle bundleForClass:[self class]]
                                                  pathForResource:volumeCurveFilename
                                                  ofType:@"plist"]];
    
    self.dbAmplitudePerFrequency = [NSDictionary
                                dictionaryWithContentsOfFile:[[NSBundle bundleForClass:[self class]]
                                                              pathForResource:dbAmplitudePerFrequencyFilename
                                                              ofType:@"plist"]];
    
    self.dbSPLAmplitudePerFrequency = [NSDictionary
                                   dictionaryWithContentsOfFile:[[NSBundle bundleForClass:[self class]]
                                                                 pathForResource:dbSPLAmplitudePerFrequencyFilename
                                                                 ofType:@"plist"]];
}

- (float)gainForSystemVolume:(float)systemVolume {
    NSDecimalNumber *resultNumber = [NSDecimalNumber decimalNumberWithString:_volumeCurve[[NSString stringWithFormat:@"%.4f",systemVolume]]];
    return [resultNumber floatValue];
}

@end
