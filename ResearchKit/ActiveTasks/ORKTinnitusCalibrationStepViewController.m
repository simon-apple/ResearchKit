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

#import "ORKTinnitusCalibrationStepViewController.h"

#import "ORKActiveStepView.h"
#import "ORKTinnitusCalibrationContentView.h"
#import "ORKTinnitusAudioGenerator.h"
#import "ORKTinnitusAudioSample.h"

#import "ORKActiveStepViewController_Internal.h"
#import "ORKStepViewController_Internal.h"

#import "ORKTinnitusTypeResult.h"
#import "ORKTinnitusVolumeResult.h"
#import "ORKTinnitusCalibrationStep.h"
#import "ORKStepContainerView_Private.h"
#import "ORKNavigationContainerView_Internal.h"
#import "ORKTinnitusButtonView.h"
#import "ORKTinnitusTypes.h"

@interface ORKTinnitusCalibrationStepViewController () <ORKTinnitusButtonViewDelegate> {
    ORKHeadphoneTypeIdentifier _headphoneType;
}

@property (nonatomic, strong) ORKTinnitusCalibrationContentView *contentView;
@property (nonatomic, strong) ORKTinnitusAudioGenerator *audioGenerator;
@property (nonatomic, copy) ORKTinnitusType type;
@property (nonatomic, assign) double frequency;
@property (nonatomic, assign) BOOL isLoudnessMatching;


- (ORKTinnitusCalibrationStep *)tinnitusCalibrationStep;

@end

@implementation ORKTinnitusCalibrationStepViewController

- (instancetype)initWithStep:(ORKStep *)step
{
    self = [super initWithStep:step];
    
    if (self) {
        self.isLoudnessMatching = NO;
        self.type = ORKTinnitusTypeWhiteNoise;
        self.suspendIfInactive = YES;
    }
    
    return self;
}

- (ORKTinnitusCalibrationStep *)tinnitusCalibrationStep {
    return (ORKTinnitusCalibrationStep *)self.step;
}

- (void)setNavigationFooterView {
    self.activeStepView.navigationFooterView.continueButtonItem = self.continueButtonItem;
    self.activeStepView.navigationFooterView.continueEnabled = NO;
    [self.activeStepView.navigationFooterView updateContinueAndSkipEnabled];
}

- (void)setupButtons
{
    self.continueButtonItem  = self.internalContinueButtonItem;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    ORKTaskResult *taskResults = [[self taskViewController] result];
    
    // defining a default value here because headphone detect step is bypassed when testing on simulator
    _headphoneType = ORKHeadphoneTypeIdentifierAirPodsGen1;
    
    for (ORKStepResult *result in taskResults.results) {
        if (result.results > 0) {
            ORKStepResult *firstResult = (ORKStepResult *)[result.results firstObject];
            if ([firstResult isKindOfClass:[ORKTinnitusTypeResult class]]) {
                ORKTinnitusTypeResult *tinnitusTypeResult = (ORKTinnitusTypeResult *)firstResult;
                self.type = tinnitusTypeResult.type;
            }
            if ([firstResult isKindOfClass:[ORKHeadphoneDetectResult class]]) {
                ORKHeadphoneDetectResult *headphoneResult = (ORKHeadphoneDetectResult *)firstResult;
                _headphoneType = headphoneResult.headphoneType;
            }
        }
    }
    
    [self setNavigationFooterView];
    [self setupButtons];
    
    self.contentView = [[ORKTinnitusCalibrationContentView alloc] initWithType:self.type isLoudnessMatching:self.isLoudnessMatching];

    self.frequency = [[self tinnitusCalibrationStep] frequency];
    
    self.activeStepView.activeCustomView = self.contentView;
    self.activeStepView.customContentFillsAvailableSpace = YES;
    
    self.contentView.playButtonView.delegate = self;
    
    self.audioGenerator = [[ORKTinnitusAudioGenerator alloc] initWithType:self.type headphoneType:_headphoneType];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.audioGenerator stop];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear: animated];
    
    self.audioGenerator = nil;
}

- (ORKStepResult *)result
{
    ORKStepResult *sResult = [super result];
    NSDate *now = sResult.endDate;
 
    NSMutableArray *results = [NSMutableArray arrayWithArray:sResult.results];
    
    ORKTinnitusVolumeResult *tinnitusCalibrationResult = [[ORKTinnitusVolumeResult alloc] initWithIdentifier:self.step.identifier];
    tinnitusCalibrationResult.startDate = sResult.startDate;
    tinnitusCalibrationResult.endDate = now;
    tinnitusCalibrationResult.type = self.type;
    tinnitusCalibrationResult.volumeCurve = [self.audioGenerator gainFromCurrentSystemVolume];
    
    if ([self.type isEqualToString: ORKTinnitusTypePureTone]) {
        tinnitusCalibrationResult.amplitude = [self.audioGenerator getPuretoneSystemVolumeIndBSPL];
        tinnitusCalibrationResult.frequency = _frequency;
        tinnitusCalibrationResult.noiseType = @"none";
    } else {
        tinnitusCalibrationResult.amplitude = [self.audioGenerator gainFromCurrentSystemVolume];
        tinnitusCalibrationResult.frequency = 0.0;
        tinnitusCalibrationResult.noiseType = ORKTinnitusTypeWhiteNoise;
    }
    
    [results addObject:tinnitusCalibrationResult];
    sResult.results = [results copy];
    
    return sResult;
}


// ORKTinnitusButtonViewDelegate
- (void)tinnitusButtonViewPressed:(nonnull ORKTinnitusButtonView *)tinnitusButtonView
{
    if (tinnitusButtonView.isShowingPause) {
        int64_t delay = (int64_t)((_audioGenerator.fadeDuration + 0.05) * NSEC_PER_SEC);
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, delay), dispatch_get_main_queue(), ^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    if ([self.type isEqualToString:ORKTinnitusTypePureTone]) {
                        [self.audioGenerator playSoundAtFrequency:_frequency];
                    } else {
                        [self.audioGenerator playWhiteNoise];
                    }
                });
        });
    } else {
        [self.audioGenerator stop];
    }
    self.activeStepView.navigationFooterView.continueEnabled = YES;
}

@end
