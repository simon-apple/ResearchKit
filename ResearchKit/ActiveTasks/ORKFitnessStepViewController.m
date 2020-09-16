/*
 Copyright (c) 2015, Apple Inc. All rights reserved.
 
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


#import "ORKFitnessStepViewController.h"

#import "ORKActiveStepTimer.h"
#import "ORKActiveStepView.h"
#import "ORKFitnessContentView.h"
#import "ORKVerticalContainerView.h"

#import "ORKStepViewController_Internal.h"
#import "ORKHealthQuantityTypeRecorder.h"
#import "ORKPedometerRecorder.h"

#import "ORKActiveStepViewController_Internal.h"
#import "ORKFitnessStep.h"
#import "ORKStep_Private.h"

#import "ORKHelpers_Internal.h"


@interface ORKFitnessStepViewController () <ORKPedometerRecorderDelegate> {
    ORKFitnessContentView *_contentView;
}

@end


@implementation ORKFitnessStepViewController

- (instancetype)initWithStep:(ORKStep *)step {    
    self = [super initWithStep:step];
    if (self) {
        self.suspendIfInactive = NO;
    }
    return self;
}

- (ORKFitnessStep *)fitnessStep {
    return (ORKFitnessStep *)self.step;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _contentView = [ORKFitnessContentView new];
    _contentView.timeLeft = self.fitnessStep.stepDuration;

    self.activeStepView.activeCustomView = _contentView;
}

- (void)stepDidChange {
    [super stepDidChange];
    _contentView.timeLeft = self.fitnessStep.stepDuration;
}

- (void)countDownTimerFired:(ORKActiveStepTimer *)timer finished:(BOOL)finished {
    _contentView.timeLeft = finished ? 0 : (timer.duration - timer.runtime);
    [super countDownTimerFired:timer finished:finished];
}

@end
