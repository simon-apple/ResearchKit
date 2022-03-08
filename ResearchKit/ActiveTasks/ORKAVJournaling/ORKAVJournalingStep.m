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
// apple-internal

#if RK_APPLE_INTERNAL

#import "ORKAVJournalingStep.h"

#if ORK_FEATURE_AV_JOURNALING

#import "ORKAVJournalingStepViewController.h"
#import "ORKHelpers_Internal.h"

static const NSTimeInterval MIN_RECORDING_DURATION = 30.0;
static const NSTimeInterval MAX_RECORDING_DURATION = 7260.0;

@implementation ORKAVJournalingStep

+ (Class)stepViewControllerClass {
    return [ORKAVJournalingStepViewController class];
}

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (instancetype)initWithIdentifier:(NSString *)identifier {
    self = [super initWithIdentifier:identifier];
    if (self) {
        _maximumRecordingLimit = 60.0;
        _countDownStartTime = 30;
        
#if ORK_FEATURE_AV_JOURNALING_DEPTH_DATA_COLLECTION
        _saveDepthDataIfAvailable = YES;
#else
        _saveDepthDataIfAvailable = NO;
#endif
    }
    return self;
}

- (void)validateParameters {
    [super validateParameters];
    
    if (self.maximumRecordingLimit < MIN_RECORDING_DURATION || self.maximumRecordingLimit > MAX_RECORDING_DURATION) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException
                                       reason:[NSString stringWithFormat:@"maxRecordingDuration must be greater than %f seconds and less than %f seconds.",
                                               MIN_RECORDING_DURATION,
                                               MAX_RECORDING_DURATION]
                                     userInfo:nil];
    }
    
    if (self.countDownStartTime > self.maximumRecordingLimit) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException
                                       reason:@"countDownStartTime must be less than or equal to the maximumRecordingLimit"
                                     userInfo: nil];
    }
}

- (BOOL)startsFinished {
    return NO;
}

- (BOOL)allowsBackNavigation {
    return NO;
}

- (instancetype)copyWithZone:(NSZone *)zone {
    ORKAVJournalingStep *step = [super copyWithZone:zone];
    step.maximumRecordingLimit = self.maximumRecordingLimit;
    step.countDownStartTime = self.countDownStartTime;
    step.saveDepthDataIfAvailable = self.saveDepthDataIfAvailable;
    return step;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self )
    {
        ORK_DECODE_DOUBLE(aDecoder, maximumRecordingLimit);
        ORK_DECODE_INTEGER(aDecoder, countDownStartTime);
        ORK_DECODE_BOOL(aDecoder, saveDepthDataIfAvailable);
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    ORK_ENCODE_DOUBLE(aCoder, maximumRecordingLimit);
    ORK_ENCODE_INTEGER(aCoder, countDownStartTime);
    ORK_ENCODE_BOOL(aCoder, saveDepthDataIfAvailable);
}

- (BOOL)isEqual:(id)object {
    BOOL isParentSame = [super isEqual:object];
    __typeof(self) castObject = object;
    
    return (isParentSame &&
            (self.maximumRecordingLimit == castObject.maximumRecordingLimit) &&
            (self.countDownStartTime == castObject.countDownStartTime) &&
            (self.saveDepthDataIfAvailable == castObject.saveDepthDataIfAvailable));
}

@end

#endif

#endif
