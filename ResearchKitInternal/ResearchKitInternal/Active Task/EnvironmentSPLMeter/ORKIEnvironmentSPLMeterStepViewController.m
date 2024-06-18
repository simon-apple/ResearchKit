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

#import "ORKIEnvironmentSPLMeterStepViewController.h"
#import "ResearchKitInternal/ORKITaskViewController.h"

#import "ORKIUtils.h"

#import <ResearchKitInternal/ORKContext.h>

#import <ResearchKitActiveTask/ORKEnvironmentSPLMeterStepViewController_Private.h>

#import "ResearchKitUI/ORKTaskViewController_Internal.h"


static const NSTimeInterval SPL_METER_TIMEOUT_IN_SECONDS = 120.0;

@interface ORKIEnvironmentSPLMeterStepViewController () {
    NSTimer *_timeoutTimer;
}

@end

@implementation ORKIEnvironmentSPLMeterStepViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear: animated];
    
    [self registerNotifications];
    [self startTimeoutTimer];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self removeObservers];
}

- (void)registerNotifications {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(appWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
    [center addObserver:self selector:@selector(appWillTerminate:) name:UIApplicationWillTerminateNotification object:nil];
    [center addObserver:self selector:@selector(appDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
}

-(void)appWillResignActive:(NSNotification*)note {
    [self stopTimeoutTimer];
}

-(void)appDidBecomeActive:(NSNotification*)note {
    [self startTimeoutTimer];
}

-(void)appWillTerminate:(NSNotification*)note {
    [self stopTimeoutTimer];
    [self removeObservers];
}

- (void)removeObservers {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
    [center removeObserver:self name:UIApplicationWillTerminateNotification object:nil];
    [center removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)startTimeoutTimer {
    if (_timeoutTimer != nil) {
        [self stopTimeoutTimer];
    }
    _timeoutTimer = [NSTimer scheduledTimerWithTimeInterval:SPL_METER_TIMEOUT_IN_SECONDS target:self selector:@selector(timeoutCheck) userInfo:nil repeats:YES];
}

- (void)timeoutCheck {
    [self stopTimeoutTimer];
    [self.audioEngine stop];
    [self resetAudioSession];
    
    id<ORKTask> task = self.taskViewController.task;
    
    if ([task isKindOfClass:[ORKNavigableOrderedTask class]]) {
        ORKNavigableOrderedTask *currentTask = (ORKNavigableOrderedTask *)task;
        
        ORKStep *timeoutStep = [currentTask stepWithIdentifier:ORKEnvironmentSPLMeterTimeoutIdentifier];
        
        if (timeoutStep == nil) {
            NSUInteger nextStepIndex = [currentTask indexOfStep:[self step]] + 1;
            ORKStep *nextStep = nil;
            
            if (currentTask.steps.count >= nextStepIndex) {
                nextStep = [currentTask steps][nextStepIndex];
                
                ORKDirectStepNavigationRule *nextNavigationRule = [[ORKDirectStepNavigationRule alloc] initWithDestinationStepIdentifier:nextStep.identifier];
                [currentTask setNavigationRule:nextNavigationRule forTriggerStepIdentifier:self.step.identifier];
            }
            
            ORKCompletionStep *step = [[ORKCompletionStep alloc] initWithIdentifier:ORKEnvironmentSPLMeterTimeoutIdentifier];
            step.title = ORKILocalizedString(@"ENVIRONMENTSPL_QUIET_LOCATION_REQUIRED_TITLE", nil);
            step.text = ORKILocalizedString(@"ENVIRONMENTSPL_QUIET_LOCATION_REQUIRED_TEXT", nil);
            step.optional = NO;
            step.reasonForCompletion = ORKTaskFinishReasonDiscarded;
            
            UIImageConfiguration *configuration = [UIImageSymbolConfiguration configurationWithFont:[UIFont preferredFontForTextStyle:UIFontTextStyleBody] scale:UIImageSymbolScaleLarge];
            step.iconImage = [UIImage systemImageNamed:@"waveform.circle.fill" withConfiguration:configuration];
            
            [currentTask insertStep:step atIndex:[currentTask indexOfStep:self.step]];
            
            ORKDirectStepNavigationRule *endNavigationRule = [[ORKDirectStepNavigationRule alloc] initWithDestinationStepIdentifier:ORKNullStepIdentifier];
            [currentTask setNavigationRule:endNavigationRule forTriggerStepIdentifier:ORKEnvironmentSPLMeterTimeoutIdentifier];
        }

        [[self taskViewController] flipToPageWithIdentifier:ORKEnvironmentSPLMeterTimeoutIdentifier forward:YES animated:YES];
    }
}

- (void)stopTimeoutTimer {
    [_timeoutTimer invalidate];
    _timeoutTimer = nil;
}

- (void)setNavigationFooterView {
    [super setNavigationFooterView];
    
    ORKTaskViewController *taskViewController = self.taskViewController;
    ORKStep *nextStep = [taskViewController.task stepAfterStep:self.step withResult:taskViewController.result];
    Class ORKSpeechInNoisePredefinedTaskContext = NSClassFromString(@"ORKSpeechInNoisePredefinedTaskContext");
    
    if (nextStep && [nextStep.context isKindOfClass:ORKSpeechInNoisePredefinedTaskContext])
    {
        NSNumber *isPracticeTest = [(NSObject *)nextStep.context valueForKey:@"isPracticeTest"];
        if (isPracticeTest.boolValue)
        {
            [self setContinueButtonTitle:ORKILocalizedString(@"BUTTON_PRACTICE_TEST", nil)];
        }
        else
        {
            [self setContinueButtonTitle:ORKILocalizedString(@"BUTTON_START_TEST", nil)];
        }
    }
}

- (void)reachedOptimumNoiseLevel {
    [super reachedOptimumNoiseLevel];
    [self stopTimeoutTimer];
}

@end
