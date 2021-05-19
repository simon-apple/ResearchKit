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
        if (![self commonInit]) {
            return nil;
        }
    }
    return self;
}

- (BOOL)commonInit {
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
        NSAssert(NO, @"A valid headphone route identifier must be provided");
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
    
    return (_headphoneType && _volumeCurve && _dbAmplitudePerFrequency && _dbSPLAmplitudePerFrequency);
}

- (float)gainForSystemVolume:(float)systemVolume interpolated:(BOOL)isInterpolated {
    NSNumber *volume = [[NSNumber alloc] initWithFloat:systemVolume];

    NSMutableDictionary *decimalVolumeCurve = [[NSMutableDictionary alloc] init];
    for (NSString *key in self.volumeCurve.allKeys) {
        NSDecimalNumber *fKey = [NSDecimalNumber decimalNumberWithString:key];
        NSDecimalNumber *fValue = [NSDecimalNumber decimalNumberWithString:self.volumeCurve[key]];
        [decimalVolumeCurve setObject:fValue forKey:fKey];
    }
    
    if ([decimalVolumeCurve.allKeys containsObject:volume]) {
        // Value included on the table, no interpolation needed
        return [[decimalVolumeCurve objectForKey:volume] floatValue];
    }
    
    NSArray *sortedKeys = [decimalVolumeCurve.allKeys sortedArrayUsingSelector:@selector(compare:)];
    NSUInteger topIndex = [sortedKeys indexOfObjectPassingTest:^BOOL(NSNumber *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        return [obj compare:volume] == NSOrderedDescending;
    }];

    // The smallest volume key that is bigger than systemVolume
    NSNumber *topKey = [sortedKeys objectAtIndex:topIndex];
    NSNumber *topValue = [decimalVolumeCurve objectForKey:topKey];

    if (topIndex == 0 || !isInterpolated) {
        // No interpolation or bottomValue available, returning topValue
        return [topValue floatValue];
    }
    
    // The biggest volume key that is smaller than systemVolume
    NSNumber *bottomKey = [sortedKeys objectAtIndex:topIndex-1];
    NSNumber *bottomValue = [decimalVolumeCurve objectForKey:bottomKey];

    // Convert top and botton gains to linear scale
    double topLinear = pow(10.0, ([topValue doubleValue]/20.0));
    double bottomLinear = pow(10.0, ([bottomValue doubleValue]/20.0));
    
    // Calculate baselined keys based on bottomKey
    double baselinedTopVolume = [topKey doubleValue] - [bottomKey doubleValue];
    double baselinedSystemVolume = systemVolume - [bottomKey doubleValue];
    
    // Calculate the volume linear offset, apply over the bottomLinear and convert again to dB scale
    double linearRange = (topLinear - bottomLinear);
    double volumeLinearOffset = (baselinedSystemVolume/baselinedTopVolume) * linearRange;
    double adjustedLinearVolume = bottomLinear + volumeLinearOffset;
    double adjustedGain = 20 * log10(adjustedLinearVolume);

    return adjustedGain;
}

@end
