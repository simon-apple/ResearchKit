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

#import "ORKTinnitusTypeStepViewController.h"

#import "ORKActiveStepView.h"
#import "ORKTinnitusAudioGenerator.h"
#import "ORKTinnitusTypeContentView.h"
#import "ORKTinnitusTypeResult.h"
#import "ORKTinnitusButtonView.h"
#import "ORKTinnitusAudioSample.h"

#import "ORKActiveStepViewController_Internal.h"
#import "ORKStepViewController_Internal.h"

#import "ORKTinnitusTypeStep.h"
#import "ORKStepContainerView_Private.h"
#import "ORKNavigationContainerView_Internal.h"

@interface ORKTinnitusTypeStepViewController () <ORKTinnitusButtonViewDelegate>

@property (nonatomic, strong) ORKTinnitusTypeContentView *contentView;
@property (nonatomic, strong) ORKTinnitusAudioGenerator *audioGenerator;

- (ORKTinnitusTypeStep *)tinnitusTypeStep;

@end

#define ORKTinnitusTypeDefaultFrequency 1000.0

@implementation ORKTinnitusTypeStepViewController

- (instancetype)initWithStep:(ORKStep *)step {
    self = [super initWithStep:step];
    
    if (self) {
        self.suspendIfInactive = YES;
    }
    
    return self;
}

- (ORKTinnitusTypeStep *)tinnitusTypeStep {
    return (ORKTinnitusTypeStep *)self.step;
}

- (void)setNavigationFooterView {
    self.activeStepView.navigationFooterView.continueButtonItem = self.continueButtonItem;
    self.activeStepView.navigationFooterView.continueEnabled = NO;
    [self.activeStepView.navigationFooterView updateContinueAndSkipEnabled];
}

- (void)setupButtons {
    self.continueButtonItem  = self.internalContinueButtonItem;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setNavigationFooterView];
    [self setupButtons];
    
    self.contentView = [[ORKTinnitusTypeContentView alloc] init];
    self.activeStepView.activeCustomView = self.contentView;
    self.activeStepView.customContentFillsAvailableSpace = YES;
    
    self.contentView.pureToneButtonView.delegate = self;
    self.contentView.whiteNoiseButtonView.delegate = self;
    
    ORKTaskResult *taskResults = [[self taskViewController] result];
    
    // if no headphone is detected (simulator) this will be used for debugging purposes
    ORKHeadphoneTypeIdentifier headphoneType = ORKHeadphoneTypeIdentifierAirPodsGen1;
    
    for (ORKStepResult *result in taskResults.results) {
        if (result.results > 0) {
            ORKStepResult *firstResult = (ORKStepResult *)[result.results firstObject];
            if ([firstResult isKindOfClass:[ORKHeadphoneDetectResult class]]) {
                ORKHeadphoneDetectResult *hedphoneResult = (ORKHeadphoneDetectResult *)firstResult;
                headphoneType = hedphoneResult.headphoneType;
                break;
            }
        }
    }
    
    self.audioGenerator = [[ORKTinnitusAudioGenerator alloc] initWithHeadphoneType:headphoneType];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.audioGenerator stop];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear: animated];
    
    self.audioGenerator = nil;
}

- (ORKStepResult *)result {
    ORKStepResult *parentResult = [super result];
    
    NSMutableArray *results = [NSMutableArray arrayWithArray:parentResult.results];
    
    ORKTinnitusTypeResult *typeResult = [[ORKTinnitusTypeResult alloc] initWithIdentifier:self.step.identifier];
    
    typeResult.type = _contentView.pureToneButtonView.isSelected ? ORKTinnitusTypePureTone : ORKTinnitusTypeWhiteNoise;
    
    [results addObject:typeResult];
    
    parentResult.results = results;
    
    return parentResult;
}

// ORKTinnitusButtonViewDelegate
- (void)tinnitusButtonViewPressed:(nonnull ORKTinnitusButtonView *)tinnitusButtonView {
    [self.audioGenerator stop];

    if (tinnitusButtonView == _contentView.pureToneButtonView) {
        [_contentView.whiteNoiseButtonView restoreButton];
        if (tinnitusButtonView.isShowingPause) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)((_audioGenerator.fadeDuration + 0.05) * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.audioGenerator playSoundAtFrequency:ORKTinnitusTypeDefaultFrequency];
            });
        }
        if (_contentView.whiteNoiseButtonView.playedOnce) {
            self.activeStepView.navigationFooterView.continueEnabled = YES;
        }
    } else {
        [_contentView.pureToneButtonView restoreButton];
        if (tinnitusButtonView.isShowingPause) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)((_audioGenerator.fadeDuration + 0.05) * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.audioGenerator playWhiteNoise];
            });
        }
        if (_contentView.pureToneButtonView.playedOnce) {
            self.activeStepView.navigationFooterView.continueEnabled = YES;
        }
    }
}

@end
