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

#import "ORKISpeechInNoiseStepViewController.h"
#import "ORKISpeechInNoiseStep.h"
#import "ORKIUtils.h"
#import "ORKHeadphoneDetector.h"
#import "ORKHeadphoneDetectResult.h"

#import <ResearchKitInternal/ORKIHelpers_Internal.h>
#import <ResearchKitInternal/ORKContext.h>

#import "ResearchKitUI/ORKStepViewController.h"
#import "ResearchKitUI/ORKTaskViewController_Internal.h"

#import "ResearchKitActiveTask/ORKSpeechInNoiseStepViewController_Private.h"
#import "ResearchKitActiveTask/ResearchKitActiveTask_Private.h"

#import "ResearchKit/ORKHelpers_Internal.h"


static const NSTimeInterval ORKSpeechInNoiseStepFinishDelay = 0.75;

@interface ORKISpeechInNoiseStepViewController () <ORKHeadphoneDetectorDelegate> {
    NSObject *_headphoneDetector;
    ORKHeadphoneTypeIdentifier _headphoneType;
    BOOL _showingAlert;
}

@end

@implementation ORKISpeechInNoiseStepViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    _showingAlert = NO;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    _showingAlert = NO;

    ORKTaskResult *taskResults = [[self taskViewController] result];
    
    BOOL foundHeadphoneDetectorResult = NO;
    
    for (ORKStepResult *result in taskResults.results) {
        if (result.results > 0) {
            ORKStepResult *firstResult = (ORKStepResult *)[result.results firstObject];
            if ([firstResult isKindOfClass:[ORKHeadphoneDetectResult class]]) {
                ORKHeadphoneDetectResult *headphoneDetectResult = (ORKHeadphoneDetectResult *)firstResult;
                _headphoneType = headphoneDetectResult.headphoneType;
                foundHeadphoneDetectorResult = YES;
            }
        }
    }
    
    if (foundHeadphoneDetectorResult) {
        _headphoneDetector = [[ORKHeadphoneDetector alloc] initWithDelegate:self
                                             supportedHeadphoneChipsetTypes:nil];
    }
}

- (void)setupContentView {
    [super setupContentView];
    
    [self.speechInNoiseContentView useInternalGraphView];
}

- (void)tapButtonPressed {
    [super tapButtonPressed];
}

- (NSString *)filename {
    NSObject<ORKContext> *context = [self predefinedSpeechInNoiseContext];
    
    if (context) {
        return [super filename];
    }
     
    return nil;
}

- (NSObject<ORKContext> * _Nullable)predefinedSpeechInNoiseContext {
    Class ORKSpeechInNoisePredefinedTaskContext = NSClassFromString(@"ORKSpeechInNoisePredefinedTaskContext");
    if ([self.step.context isKindOfClass:ORKSpeechInNoisePredefinedTaskContext]) {
        return self.step.context;
    }

    return nil;
}

- (void)finish {
    [_headphoneDetector performSelector:@selector(discard)];
    _headphoneDetector = nil;
    
    NSObject<ORKContext> *context = [self predefinedSpeechInNoiseContext];
    if (context) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(ORKSpeechInNoiseStepFinishDelay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{ [super finish]; });
    } else {
        [super finish];
    }
}

- (BOOL)isPracticeTest {
    NSObject<ORKContext> *context = [self predefinedSpeechInNoiseContext];
    if (context && ((NSNumber *)[context valueForKey:@"isPracticeTest"]).boolValue) {
        return YES;
    }
    
    return NO;
}

- (BOOL)shouldBlockFinishOfStep {
    return _showingAlert;
}

#pragma mark - Headphone Monitoring

- (void)headphoneTypeDetected:(nonnull ORKHeadphoneTypeIdentifier)headphoneType vendorID:(nonnull NSString *)vendorID productID:(nonnull NSString *)productID deviceSubType:(NSInteger)deviceSubType isSupported:(BOOL)isSupported {
    if (![headphoneType isEqualToString:_headphoneType]) {
        [self showAlert];
    }
}

- (void)oneAirPodRemoved {
    [self showAlert];
}

- (void)podLowBatteryLevelDetected {
    [self showAlert];
}

- (void)showAlert {
    if (!_showingAlert) {
        _showingAlert = YES;
        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertController *alertController = [UIAlertController
                                                  alertControllerWithTitle:ORKILocalizedString(@"PACHA_ALERT_TITLE_TASK_INTERRUPTED", nil)
                                                  message:ORKILocalizedString(@"PACHA_ALERT_TEXT_TASK_INTERRUPTED", nil)
                                                  preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *startOver = [UIAlertAction
                                        actionWithTitle:ORKILocalizedString(@"SPEECH_IN_NOISE_PREDEFINED_START_OVER", nil)
                                        style:UIAlertActionStyleDefault
                                        handler:^(UIAlertAction *action) {
                [[self taskViewController] restartTask];
            }];
            [alertController addAction:startOver];
            [alertController addAction:[UIAlertAction
                                        actionWithTitle:ORKILocalizedString(@"SPEECH_IN_NOISE_PREDEFINED_CANCEL_TEST", nil)
                                        style:UIAlertActionStyleDefault
                                        handler:^(UIAlertAction *action) {
                ORKStrongTypeOf(self.taskViewController.delegate) strongDelegate = self.taskViewController.delegate;
                if ([strongDelegate respondsToSelector:@selector(taskViewController:didFinishWithReason:error:)]) {
                    [strongDelegate taskViewController:self.taskViewController didFinishWithReason:ORKTaskFinishReasonDiscarded error:nil];
                    [self finish];
                }
            }]];
            alertController.preferredAction = startOver;
            [self presentViewController:alertController animated:YES completion:nil];
        });
    }
}

@end
