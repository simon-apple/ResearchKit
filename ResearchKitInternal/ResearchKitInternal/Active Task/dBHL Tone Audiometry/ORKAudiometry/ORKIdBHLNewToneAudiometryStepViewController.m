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

#import "ORKIdBHLNewToneAudiometryStepViewController.h"
#import "ORKdBHLToneAudiometryPulsedAudioGenerator.h"

#import <MediaPlayer/MPVolumeView.h>

#import "ResearchKitInternal.h"
#import "ResearchKitInternal_Private.h"

#import "ORKIUtils.h"

@import ResearchKitActiveTask;
@import ResearchKitActiveTask_Private;
@import ResearchKitUI;
@import ResearchKitUI_Private;

#import "ResearchKitInternal/ResearchKitInternal-Swift.h"

static const double ORKdBHLPulsePauseMillisecondsDuration = 200.0;
static const double ORKdBHLNewToneAudiometryStepVolumeLevel = 0.8125;
static const double ORKdBHLVolumeViewAlpha = 0.001;

typedef NS_ENUM(NSInteger, ORKdBHLToneAudiometryTrialResponse) {
    ORKdBHLToneAudiometryTapBeforeResponseWindow = -1,
    
    ORKdBHLToneAudiometryNoTapOnResponseWindow = 0,
    
    ORKdBHLToneAudiometryTapOnResponseWindow = 1,
} ORK_ENUM_AVAILABLE;

@interface ORKIdBHLNewToneAudiometryStepViewController () <ORKdBHLToneAudiometryPulsedAudioGeneratorDelegate> {
    ORKAudioChannel _audioChannel;

    ORKdBHLToneAudiometryPulsedAudioGenerator *_audioGenerator;
    ORKHeadphoneDetector *_headphoneDetector; // TODO: implement
    UIImpactFeedbackGenerator *_hapticFeedback;
    
    dispatch_block_t _preStimulusDelayWorkBlock;
    dispatch_block_t _pulseDurationWorkBlock;
    dispatch_block_t _postStimulusDelayWorkBlock;
    
    ORKdBHLToneAudiometryUnit * _currentUnit;
    
    BOOL _showingAlert;
}

@property (nonatomic, strong) ORKdBHLToneAudiometryContentView *dBHLToneAudiometryContentView;
@property (nonatomic, assign) ORKdBHLToneAudiometryTrialResponse currentResponse;

@end

@implementation ORKIdBHLNewToneAudiometryStepViewController

- (instancetype)initWithStep:(ORKStep *)step {
    self = [super initWithStep:step];
    
    if (self) {
        self.suspendIfInactive = YES;
        
        _showingAlert = NO;
        _headphoneDetector = nil;
        
        ORKWeakTypeOf(self) weakSelf = self;
        if (@available(iOS 14, *)) {
            self.audiometryEngine.timestampProvider = ^NSTimeInterval{
                ORKStrongTypeOf(self) strongSelf = weakSelf;
                return strongSelf ? strongSelf.runtime : 0;
            };
        }

        self.currentResponse = ORKdBHLToneAudiometryTapBeforeResponseWindow;
    }
    return self;
}

- (void)initializeInternalButtonItems {
    [super initializeInternalButtonItems];
    
    // Don't show next button
    self.internalContinueButtonItem = nil;
    self.internalDoneButtonItem = nil;
    self.internalSkipButtonItem = nil;
}

- (ORKIdBHLToneAudiometryStep *)newdBHLToneAudiometryStep {
    return (ORKIdBHLToneAudiometryStep *)self.step;
}

- (ORKNewAudiometry *)audiometryEngine  API_AVAILABLE(ios(14)){
    return (ORKNewAudiometry *)self.newdBHLToneAudiometryStep.audiometryEngine;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configureStep];
}

- (void)setupVolumeView {
    MPVolumeView *volumeView = [[MPVolumeView alloc] initWithFrame:CGRectNull];
    [volumeView setAlpha:ORKdBHLVolumeViewAlpha];
    [volumeView setIsAccessibilityElement:NO];
    [self.view addSubview:volumeView];
}

- (void)configureStep {
    ORKdBHLToneAudiometryStep *dBHLTAStep = [self newdBHLToneAudiometryStep];
    ORKITaskViewController *taskVC = (ORKITaskViewController *)[self taskViewController];

    self.dBHLToneAudiometryContentView = [[ORKdBHLToneAudiometryContentView alloc] init];
    self.activeStepView.activeCustomView = self.dBHLToneAudiometryContentView;
    self.activeStepView.customContentFillsAvailableSpace = YES;
    [self.activeStepView.navigationFooterView setHidden:YES];

    [self.dBHLToneAudiometryContentView.tapButton addTarget:self action:@selector(tapButtonPressed) forControlEvents:UIControlEventTouchDown];
    
    [self addObservers];
    
    if ([taskVC isKindOfClass:[ORKITaskViewController class]]) {
        [taskVC lockDeviceVolume:ORKdBHLNewToneAudiometryStepVolumeLevel];
    } else {
        // rdar://107531448 (all internal classes should throw error if parent is not ORKITaskViewController)
        @throw ([NSException exceptionWithName:@"New dBHL lockDeviceVolume"
                                        reason:@"The task is using the public version of ORKTaskViewController, please instantiate the task with ORKITaskViewController."
                                      userInfo:nil]);
    }

    ORKTaskResult *taskResults = [[self taskViewController] result];

    for (ORKStepResult *result in taskResults.results) {
        if (result.results > 0) {
            ORKStepResult *firstResult = (ORKStepResult *)[result.results firstObject];
            if ([firstResult isKindOfClass:[ORKHeadphoneDetectResult class]]) {
                ORKHeadphoneDetectResult *headphoneDetectResult = (ORKHeadphoneDetectResult *)firstResult;
                dBHLTAStep.headphoneType = headphoneDetectResult.headphoneType;
            }
        }
    }

    _audioChannel = dBHLTAStep.earPreference;
    _audioGenerator = [[ORKdBHLToneAudiometryPulsedAudioGenerator alloc]
                       initForHeadphoneType:dBHLTAStep.headphoneType
                       pulseMillisecondsDuration:ORKdBHLPulsePauseMillisecondsDuration
                       pauseMillisecondsDuration:ORKdBHLPulsePauseMillisecondsDuration];
    _audioGenerator.delegate = self;
    _hapticFeedback = [[UIImpactFeedbackGenerator alloc] initWithStyle: UIImpactFeedbackStyleHeavy];
    
    _headphoneDetector = [[ORKHeadphoneDetector alloc] initWithDelegate:self
                                                supportedHeadphoneChipsetTypes:[ORKHeadphoneDetectStep dBHLTypes]];
}

- (void)addObservers {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(appWillTerminate:) name:UIApplicationWillTerminateNotification object:nil];
}

- (void)removeObservers {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center removeObserver:self name:UIApplicationWillTerminateNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // Fix for dark mode
    if (@available(iOS 13.0, *)) {
        self.view.backgroundColor = UIColor.systemBackgroundColor;
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self setupVolumeView];
    [self start];
}

-(void)appWillTerminate:(NSNotification*)note {
    [self stopAudio];
    [self removeObservers];
}

- (void)animatedBHLButton {
    [self.dBHLToneAudiometryContentView.layer removeAllAnimations];
    [UIView animateWithDuration:0.1
                          delay:0.0
         usingSpringWithDamping:0.1
          initialSpringVelocity:0.0
                        options:UIViewAnimationOptionCurveEaseOut|UIViewAnimationOptionAllowUserInteraction
                     animations:^{
        [self.dBHLToneAudiometryContentView.tapButton setTransform:CGAffineTransformMakeScale(0.88, 0.88)];
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:1.0
                              delay:0.0
             usingSpringWithDamping:0.4
              initialSpringVelocity:0.0
                            options:UIViewAnimationOptionCurveLinear|UIViewAnimationOptionAllowUserInteraction
                         animations:^{
            [self.dBHLToneAudiometryContentView.tapButton setTransform:CGAffineTransformMakeScale(1.0, 1.0)];
        } completion:nil];
    }];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    _audioGenerator.delegate = nil;
    _audioGenerator = nil;
    
    [_headphoneDetector discard];
    _headphoneDetector.delegate = nil;
    _headphoneDetector = nil;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self removeObservers];
    [self stopAudio];
}

- (ORKStepResult *)result {
    ORKStepResult *sResult = [super result];
    
    if (@available(iOS 14, *)) {
        if ([self.audiometryEngine isKindOfClass:[ORKNewAudiometry class]]) {
            // "Now" is the end time of the result, which is either actually now,
            // or the last time we were in the responder chain.
            NSDate *now = sResult.endDate;
            
            NSMutableArray *results = [NSMutableArray arrayWithArray:sResult.results];
            
            ORKIdBHLToneAudiometryResult *toneResult = [[ORKIdBHLToneAudiometryResult alloc] initWithIdentifier:self.step.identifier];
            toneResult.startDate = sResult.startDate;
            toneResult.endDate = now;
            NSArray *legacySamples = [self.audiometryEngine resultSamples];
            NSMutableArray *newSamples = [NSMutableArray array];
            for (ORKdBHLToneAudiometryFrequencySample *parentSample in legacySamples) {
                ORKIdBHLToneAudiometryFrequencySample *newSample = [[ORKIdBHLToneAudiometryFrequencySample alloc] init];
                newSample.frequency = parentSample.frequency;
                newSample.calculatedThreshold = parentSample.calculatedThreshold;
                newSample.channel = parentSample.channel;
                [newSamples addObject:newSample];
            }
            toneResult.samples = newSamples;
            toneResult.algorithmVersion = 1;
            toneResult.measurementMethod = ORKdBHLToneAudiometryMeasurementMethodLimits;
            toneResult.discreteUnits = self.audiometryEngine.resultUnits;
            toneResult.fitMatrix = self.audiometryEngine.fitMatrix;
            toneResult.outputVolume = [AVAudioSession sharedInstance].outputVolume;
            toneResult.headphoneType = self.newdBHLToneAudiometryStep.headphoneType;
            toneResult.tonePlaybackDuration = [self newdBHLToneAudiometryStep].toneDuration;
            toneResult.postStimulusDelay = [self newdBHLToneAudiometryStep].postStimulusDelay;
            [results addObject:toneResult];
            
            sResult.results = [results copy];
        }
    }

    return sResult;
}

- (void)stepDidFinish {
    if (@available(iOS 14, *)) {
        [self.dBHLToneAudiometryContentView setProgress:self.audiometryEngine.progress animated:YES];
        [super stepDidFinish];
        [self stopAudio];
        [self.dBHLToneAudiometryContentView finishStep:self];
        [self goForward];
    }
}

- (void)start {
    [super start];
    [self runTestTrial];
}
    
- (void)stopAudio {
    [_audioGenerator stop];
    if (_preStimulusDelayWorkBlock) {
        dispatch_block_cancel(_preStimulusDelayWorkBlock);
        dispatch_block_cancel(_pulseDurationWorkBlock);
        dispatch_block_cancel(_postStimulusDelayWorkBlock);
    }
}

- (void)runTestTrial {
    [self stopAudio];
    if (@available(iOS 14, *)) {
        if (!_showingAlert) {
            [self.dBHLToneAudiometryContentView setProgress:self.audiometryEngine.progress animated:YES];
            
            ORKWeakTypeOf(self) weakSelf = self;
            [self.audiometryEngine nextStatus:^(BOOL testEnded, ORKAudiometryStimulus *stimulus) {
                ORKStrongTypeOf(self) strongSelf = weakSelf;
                if (testEnded) {
                    [strongSelf finish];
                    return;
                }
                
                self.currentResponse = ORKdBHLToneAudiometryTapBeforeResponseWindow;
                const NSTimeInterval toneDuration = [self newdBHLToneAudiometryStep].toneDuration;
                const NSTimeInterval postStimulusDelay = [self newdBHLToneAudiometryStep].postStimulusDelay;
                double delay1 = arc4random_uniform([self newdBHLToneAudiometryStep].maxRandomPreStimulusDelay - 1);
                double delay2 = (double)arc4random_uniform(10)/10;
                double preStimulusDelay = delay1 + delay2 + 1;
                NSTimeInterval startOfUnitTS = self.runtime; // storing the start of the tone stimulus
                
                strongSelf->_preStimulusDelayWorkBlock = dispatch_block_create(DISPATCH_BLOCK_INHERIT_QOS_CLASS, ^{
                    [strongSelf.audiometryEngine registerStimulusPlayback];
                    ORKdBHLToneAudiometryUnit *unit = [strongSelf.audiometryEngine createUnitWith:preStimulusDelay startOfUnitTimeStamp:startOfUnitTS];
                    [strongSelf->_audioGenerator playSoundAtFrequency:stimulus.frequency onChannel:stimulus.channel dBHL:stimulus.level];
                    strongSelf->_currentUnit = unit;
                    strongSelf.currentResponse= ORKdBHLToneAudiometryTapOnResponseWindow;
                });
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(preStimulusDelay * NSEC_PER_SEC)), dispatch_get_main_queue(), strongSelf->_preStimulusDelayWorkBlock);

                strongSelf->_pulseDurationWorkBlock = dispatch_block_create(DISPATCH_BLOCK_INHERIT_QOS_CLASS, ^{
                    [strongSelf->_audioGenerator stop];
                });
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)((preStimulusDelay + toneDuration - 0.1) * NSEC_PER_SEC)), dispatch_get_main_queue(), strongSelf->_pulseDurationWorkBlock);
                
                strongSelf->_postStimulusDelayWorkBlock = dispatch_block_create(DISPATCH_BLOCK_INHERIT_QOS_CLASS, ^{
                    strongSelf.currentResponse = ORKdBHLToneAudiometryNoTapOnResponseWindow;
                                
                    [strongSelf.audiometryEngine registerResponse:NO forUnit:strongSelf->_currentUnit];
                    [strongSelf nextTrial];
                });
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)((preStimulusDelay + toneDuration + postStimulusDelay) * NSEC_PER_SEC)), dispatch_get_main_queue(), strongSelf->_postStimulusDelayWorkBlock);
            }];
        }
    }
}

- (void)nextTrial {
    if (@available(iOS 14, *)) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.audiometryEngine.testEnded) {
                [self finish];
            } else {
                [self runTestTrial];
            }
        });
    }
}

- (void)tapButtonPressed {
    if (@available(iOS 14, *)) {
        [self animatedBHLButton];
        [_hapticFeedback impactOccurred];
        
        if (_preStimulusDelayWorkBlock && dispatch_block_testcancel(_preStimulusDelayWorkBlock) == 0) {
            [self.audiometryEngine registerResponse:YES forUnit:_currentUnit];
        }
        
        [self nextTrial];
    }
}

- (void)toneWillStartClipping {
    if (@available(iOS 14, *)) {
        if ([self.audiometryEngine respondsToSelector:@selector(signalClipped)]) {
            [self.audiometryEngine signalClipped];
        }
        [self nextTrial];
    }
}

#pragma mark - Headphone Monitoring

- (NSString *)headphoneType {
    return [[self newdBHLToneAudiometryStep].headphoneType uppercaseString];
}

- (void)bluetoothModeChanged:(ORKBluetoothMode)bluetoothMode {
    if ([self.headphoneType isEqualToString:ORKHeadphoneTypeIdentifierAirPodsPro] ||
        [self.headphoneType isEqualToString:ORKHeadphoneTypeIdentifierAirPodsProGen2] ||
        [self.headphoneType isEqualToString:ORKHeadphoneTypeIdentifierAirPodsMax]) {
            
        BOOL newModeIsNoiseCancellingMode = (bluetoothMode == ORKBluetoothModeNoiseCancellation);
        if (!newModeIsNoiseCancellingMode) {
            [self showAlert];
        }
    }
}

- (void)headphoneTypeDetected:(nonnull ORKHeadphoneTypeIdentifier)headphoneType vendorID:(nonnull NSString *)vendorID productID:(nonnull NSString *)productID deviceSubType:(NSInteger)deviceSubType isSupported:(BOOL)isSupported {
    if (![headphoneType isEqualToString:self.headphoneType]) {
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
            [self stopAudio];
            UIAlertController *alertController = [UIAlertController
                                                  alertControllerWithTitle:ORKILocalizedString(@"PACHA_ALERT_TITLE_TASK_INTERRUPTED", nil)
                                                  message:ORKILocalizedString(@"PACHA_ALERT_TEXT_TASK_INTERRUPTED", nil)
                                                  preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *startOver = [UIAlertAction
                                        actionWithTitle:ORKILocalizedString(@"dBHL_ALERT_TITLE_START_OVER", nil)
                                        style:UIAlertActionStyleDefault
                                        handler:^(UIAlertAction *action) {
                [self.newdBHLToneAudiometryStep resetAudiometryEngine];
                [[self taskViewController] restartTask];
            }];
            [alertController addAction:startOver];
            [alertController addAction:[UIAlertAction
                                        actionWithTitle:ORKILocalizedString(@"dBHL_ALERT_TITLE_CANCEL_TEST", nil)
                                        style:UIAlertActionStyleDefault
                                        handler:^(UIAlertAction *action) {
                ORKStrongTypeOf(self.taskViewController.delegate) strongDelegate = self.taskViewController.delegate;
                if ([strongDelegate respondsToSelector:@selector(taskViewController:didFinishWithReason:error:)]) {
                    [strongDelegate taskViewController:self.taskViewController didFinishWithReason:ORKTaskFinishReasonDiscarded error:nil];
                }
            }]];
            alertController.preferredAction = startOver;
            [self presentViewController:alertController animated:YES completion:nil];
        });
    }
}


@end
