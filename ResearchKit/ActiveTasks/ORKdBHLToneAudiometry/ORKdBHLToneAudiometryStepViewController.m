/*
 Copyright (c) 2018, Apple Inc. All rights reserved.
 
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


#import "ORKdBHLToneAudiometryStepViewController.h"

#import "ORKActiveStepView.h"
#import "ORKActiveStep_Internal.h"
#import "ORKStepHeaderView_Internal.h"
#import "ORKNavigationContainerView.h"
#import "ORKStepContainerView.h"

#import "ORKdBHLToneAudiometryPulsedAudioGenerator.h"
#import "ORKRoundTappingButton.h"
#import "ORKdBHLToneAudiometryContentView.h"
#import "ORKStepContainerView_Private.h"

#import "ORKActiveStepViewController_Internal.h"
#import "ORKStepViewController_Internal.h"

#import "ORKCollectionResult_Private.h"
#import "ORKdBHLToneAudiometryResult.h"
#import "ORKdBHLToneAudiometryStep.h"

#if RK_APPLE_INTERNAL
#import "ORKHeadphoneDetectStep.h"
#import "ORKHeadphoneDetectResult.h"
#import "ORKHeadphoneDetector.h"
#import <ResearchKit/ResearchKit-Swift.h>
#endif

#import "ORKHelpers_Internal.h"
#import "ORKTaskViewController_Private.h"
#import "ORKTaskViewController_Internal.h"
#import "ORKOrderedTask.h"

#import "ORKNavigableOrderedTask.h"
#import "ORKStepNavigationRule.h"

#import "ORKHearingTestSoftLink.h"

// defines how many samples we should rollback before resuming the task
#define NUMBER_OF_TRAILS_TO_DROP 2

@interface ORKdBHLToneAudiometryStepViewController () <ORKdBHLToneAudiometryPulsedAudioGeneratorDelegate> {
    ORKdBHLToneAudiometryFrequencySample *_resultSample;
    ORKAudioChannel _audioChannel;

    ORKdBHLToneAudiometryPulsedAudioGenerator *_audioGenerator;
    UIImpactFeedbackGenerator *_hapticFeedback;
    
    dispatch_block_t _preStimulusDelayWorkBlock;
    dispatch_block_t _pulseDurationWorkBlock;
    dispatch_block_t _postStimulusDelayWorkBlock;
    
    NSMutableArray<ORKdBHLToneAudiometryTap *> *_taps;
    
    BOOL _showingAlert;
    
    BOOL _didSkipStep;
    
    ORKTonePlayer *_tonePlayer;
}

@property (nonatomic, strong) ORKdBHLToneAudiometryContentView *dBHLToneAudiometryContentView;
@property (nonatomic, strong) ORKdBHLToneAudiometryTap *currentTap;

@end

@implementation ORKdBHLToneAudiometryStepViewController

- (instancetype)initWithStep:(ORKStep *)step {
    self = [super initWithStep:step];
    
    if (self) {
        self.suspendIfInactive = YES;
        
        ORKWeakTypeOf(self) weakSelf = self;
        self.audiometryEngine.timestampProvider = ^NSTimeInterval{
            ORKStrongTypeOf(self) strongSelf = weakSelf;
            return strongSelf ? strongSelf.runtime : 0;
        };
        _taps = [[NSMutableArray alloc] init];
        self.currentTap = [[ORKdBHLToneAudiometryTap alloc] init];
        self.currentTap.response = ORKdBHLToneAudiometryTapBeforeResponseWindow;
        _showingAlert = NO;
        _didSkipStep = NO;
        
        _tonePlayer = [getORKTonePlayerClass() new];
    }
    return self;
}

- (void)initializeInternalButtonItems {
    [super initializeInternalButtonItems];
    
    // Don't show next button
    self.internalContinueButtonItem = nil;
    self.internalDoneButtonItem = nil;
}

- (ORKdBHLToneAudiometryStep *)dBHLToneAudiometryStep {
    return (ORKdBHLToneAudiometryStep *)self.step;
}

- (id<ORKAudiometryProtocol>)audiometryEngine {
    return self.dBHLToneAudiometryStep.audiometryEngine;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureStep];
}

- (void)configureStep {
    ORKdBHLToneAudiometryStep *dBHLTAStep = [self dBHLToneAudiometryStep];

    self.dBHLToneAudiometryContentView = [[ORKdBHLToneAudiometryContentView alloc] initWithAudioChannel:dBHLTAStep.earPreference];
    [self.view addSubview:self.dBHLToneAudiometryContentView];
    self.dBHLToneAudiometryContentView.translatesAutoresizingMaskIntoConstraints = false;
    
    NSMutableArray *constraints = [NSMutableArray new];
    [constraints addObject:[self.dBHLToneAudiometryContentView.leftAnchor constraintEqualToAnchor:self.view.leftAnchor]];
    [constraints addObject:[self.dBHLToneAudiometryContentView.rightAnchor constraintEqualToAnchor:self.view.rightAnchor]];
    [constraints addObject:[self.dBHLToneAudiometryContentView.topAnchor constraintEqualToAnchor:self.view.topAnchor]];
    [constraints addObject:[self.dBHLToneAudiometryContentView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor constant:0]];
    
    [NSLayoutConstraint activateConstraints:constraints];
    
    [self.activeStepView updateTitle:nil text:nil];
    self.activeStepView.customContentFillsAvailableSpace = YES;
    [self.activeStepView.navigationFooterView setHidden:YES];
    
    [self addObservers];
    
#if RK_APPLE_INTERNAL
    // HearingTest.framework handles the lock
    //[[self taskViewController] lockDeviceVolume:0.8125];
    
    dBHLTAStep.headphoneType = ORKHeadphoneTypeIdentifierAirPodsProGen2;

    ORKTaskResult *taskResults = [[self taskViewController] result];

    for (ORKStepResult *result in taskResults.results) {
        if (result.results > 0) {
            ORKStepResult *firstResult = (ORKStepResult *)[result.results firstObject];
            if ([firstResult isKindOfClass:[ORKHeadphoneDetectResult class]]) {
                ORKHeadphoneDetectResult *headphoneDetectResult = (ORKHeadphoneDetectResult *)firstResult;
                dBHLTAStep.headphoneType = headphoneDetectResult.headphoneType;
        
            } else if ([firstResult isKindOfClass:[ORKdBHLToneAudiometryResult class]] && dBHLTAStep.injectPreviousAudiogram) {
                if (@available(iOS 14.0, *)) {
                    ORKdBHLToneAudiometryResult *dBHLToneAudiometryResult = (ORKdBHLToneAudiometryResult *)firstResult;
                    BOOL suitableResult = (dBHLToneAudiometryResult.algorithmVersion == 1 &&
                                           [self.audiometryEngine isKindOfClass:[ORKNewAudiometry class]] &&
                                           dBHLToneAudiometryResult.samples.count > 0);
                    
                    // Only use audiograms from ORKNewAudiometry generated results
                    if (suitableResult) {
                        NSMutableDictionary *audiogram = [[NSMutableDictionary alloc] init];
                        
                        for (ORKdBHLToneAudiometryFrequencySample *sample in dBHLToneAudiometryResult.samples) {
                            NSNumber *frequency = [NSNumber numberWithDouble:sample.frequency];
                            NSNumber *threshold = [NSNumber numberWithDouble:sample.calculatedThreshold];
                            audiogram[frequency] = threshold;
                        }
                        [(ORKNewAudiometry *)self.audiometryEngine setPreviousAudiogram:audiogram];
                    }
                }
            }
        }
    }
#endif

    _audioChannel = dBHLTAStep.earPreference;
    _audioGenerator = [[ORKdBHLToneAudiometryPulsedAudioGenerator alloc] initForHeadphoneType:dBHLTAStep.headphoneType pulseMillisecondsDuration:200 pauseMillisecondsDuration:200];
    _audioGenerator.delegate = self;
    _hapticFeedback = [[UIImpactFeedbackGenerator alloc] initWithStyle: UIImpactFeedbackStyleHeavy];
}

- (void)addObservers {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(bluetoothChanged:) name:ORKdBHLBluetoothChangedNotification object:nil];
    [center addObserver:self selector:@selector(appWillTerminate:) name:UIApplicationWillTerminateNotification object:nil];
    [center addObserver:self selector:@selector(tapButtonPressed) name:@"buttonTapped" object:nil];
    [center addObserver:self selector:@selector(skipButtonPressed) name:@"skipTapped" object:nil];
    [center addObserver:self selector:@selector(appWillTerminate:) name:UIApplicationWillResignActiveNotification object:nil];
}

- (void)removeObservers {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center removeObserver:self name:UIApplicationWillTerminateNotification object:nil];
    [center removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
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
    
    [_tonePlayer startSessionFor:5 completion:^(BOOL startedSession) {
        NSLog(@"ORKTonePlayer session started: %@", startedSession ? @"true" : @"false");
        
        [_tonePlayer enableANCHearingTestModeFor:5 completion:^(BOOL startedANC) {
            NSLog(@"ORKTonePlayer ANCHearingTestMode enabled: %@", startedANC ? @"true" : @"false");
            
            [self start];
        }];
    }];
}

-(void)appWillTerminate:(NSNotification*)note {
    [self stopAudio];
    [self removeObservers];
}

// will remove all taps from the _taps array that has the same frequency and level and drop the samples from kagra algorithm
- (void)removeLastTapWithSameLevelAndFrequency:(NSUInteger)numberOfRemovals {
    if (@available(iOS 14, *)) {
        if ([self.audiometryEngine isKindOfClass:[ORKNewAudiometry class]]) {
            ORKNewAudiometry *engine = (ORKNewAudiometry *)self.audiometryEngine;
            [engine dropTrials:numberOfRemovals];
            for (int i = 0; i < numberOfRemovals; i++) {
                ORKdBHLToneAudiometryTap *tap = [_taps lastObject];
                if (tap) {
                    double searchdBHL = tap.dBHLValue;
                    double searchdBHLFrequency = tap.frequency;

                    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"dBHLValue == %lf AND frequency == %lf", searchdBHL, searchdBHLFrequency];
                    NSIndexSet *indexes = [_taps indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
                        return [predicate evaluateWithObject:obj];
                    }];
                    [_taps removeObjectsAtIndexes:indexes];
                }
            }
        }
    }
}

- (void)pauseTask {
    [self stopAudio];
    [self removeLastTapWithSameLevelAndFrequency:NUMBER_OF_TRAILS_TO_DROP];
}

- (void)resumeTask {
    if (@available(iOS 14, *)) {
        if ([self.audiometryEngine isKindOfClass:[ORKNewAudiometry class]]) {
            [self runTestTrial];
        }
    }
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
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self removeObservers];
    [self stopAudio];
}

#if KAGRA_PROTO
- (NSNumber *)simulatedHLForKey:(NSString *)key {
    NSString *masterDbStr = [NSUserDefaults.standardUserDefaults valueForKey:@"masterdB"];
    masterDbStr = masterDbStr ? masterDbStr : @"0";
    masterDbStr = [masterDbStr stringByReplacingOccurrencesOfString:@"," withString:@"."];

    NSNumber *masterDb = [NSNumber numberWithDouble:[masterDbStr doubleValue]];
    masterDb = masterDb ?: @(0.0);
    return masterDb;
}

- (NSDictionary *)simulatedHLTable {
    return @{
        @"250": [self simulatedHLForKey:@"simulatedHL250"],
        @"500": [self simulatedHLForKey:@"simulatedHL500"],
        @"1000": [self simulatedHLForKey:@"simulatedHL1000"],
        @"2000": [self simulatedHLForKey:@"simulatedHL2000"],
        @"3000": [self simulatedHLForKey:@"simulatedHL3000"],
        @"4000": [self simulatedHLForKey:@"simulatedHL4000"],
        @"6000": [self simulatedHLForKey:@"simulatedHL6000"],
        @"8000": [self simulatedHLForKey:@"simulatedHL8000"],
    };
}
#endif

- (ORKStepResult *)result {
    ORKStepResult *sResult = [super result];
    // "Now" is the end time of the result, which is either actually now,
    // or the last time we were in the responder chain.
    NSDate *now = sResult.endDate;
    
    NSMutableArray *results = [NSMutableArray arrayWithArray:sResult.results];
    
    ORKdBHLToneAudiometryResult *toneResult = [[ORKdBHLToneAudiometryResult alloc] initWithIdentifier:self.step.identifier];
    toneResult.startDate = sResult.startDate;
    toneResult.endDate = now;

    NSArray<ORKdBHLToneAudiometryFrequencySample *> *samples = [self.audiometryEngine resultSamples];
    bool enableRealDataNumber = [[NSUserDefaults standardUserDefaults] boolForKey:@"enable_realData"];
    if (!enableRealDataNumber) {
        [samples enumerateObjectsUsingBlock:^(ORKdBHLToneAudiometryFrequencySample * _Nonnull sample, NSUInteger idx, BOOL * _Nonnull stop) {
            double min = -15;
            double max = 15;
            double precision = 1e8;
            double maskValue = (double)((min * precision) + arc4random_uniform((max - min) * precision)) / precision;
            sample.calculatedThreshold += maskValue;
            
        }];
    }
    toneResult.samples = samples;
    
    toneResult.allTaps = [_taps copy];
#if RK_APPLE_INTERNAL
    toneResult.caseSerial = self.taskViewController.caseSerial.length > 1 ? self.taskViewController.caseSerial : @"";
    toneResult.leftSerial = self.taskViewController.leftBudSerial.length > 1 ? self.taskViewController.leftBudSerial : @"";
    toneResult.rightSerial = self.taskViewController.rightBudSerial.length > 1 ? self.taskViewController.rightBudSerial : @"";
    toneResult.fwVersion = self.taskViewController.fwVersion.length > 1 ? self.taskViewController.fwVersion : @"";
    if (@available(iOS 14.0, *)) {
        if ([self.audiometryEngine isKindOfClass:[ORKNewAudiometry class]]) {
            ORKNewAudiometry *engine = (ORKNewAudiometry *)self.audiometryEngine;
            toneResult.algorithmVersion = 1;
            toneResult.discreteUnits = engine.resultUnits;
            toneResult.fitMatrix = engine.fitMatrix;
            toneResult.deletedSamples = engine.deletedSamples;
#if KAGRA_PROTO
            const NSUInteger numEntries = engine.previousAudiogram.count;
            if (engine.previousAudiogram && numEntries > 0) {
                NSMutableDictionary *previousAudiogram = [NSMutableDictionary dictionaryWithCapacity:numEntries];
                [engine.previousAudiogram enumerateKeysAndObjectsUsingBlock:^(NSNumber *key, NSNumber *value, BOOL* stop) {
                    [previousAudiogram setValue:value forKey:key.stringValue];
                }];
                toneResult.userInfo = @{@"simulatedHL": [self simulatedHLTable], @"previousAudiogram": previousAudiogram};
            } else {
                toneResult.userInfo = @{@"simulatedHL": [self simulatedHLTable]};
            }
#endif
        } else {
            toneResult.userInfo = @{@"simulatedHL": [self simulatedHLTable]};
        }
    }
#endif
    toneResult.outputVolume = [AVAudioSession sharedInstance].outputVolume;
    toneResult.headphoneType = self.dBHLToneAudiometryStep.headphoneType;
    toneResult.tonePlaybackDuration = [self dBHLToneAudiometryStep].toneDuration;
    toneResult.postStimulusDelay = [self dBHLToneAudiometryStep].postStimulusDelay;
    [results addObject:toneResult];
    
    sResult.results = [results copy];
    
    return sResult;
}

- (void)stepDidFinish {
    [self.dBHLToneAudiometryContentView setProgress:self.audiometryEngine.progress animated:YES];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)((_didSkipStep ? 1 : 5) * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [super stepDidFinish];
        [self stopAudio];
        [self.dBHLToneAudiometryContentView finishStep:self];
        [self goForward];
    });
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
    ORKTaskViewController *taskVC = self.taskViewController;
    if (!_showingAlert && taskVC.budsInEars) {
        [self stopAudio];
        
        [self.dBHLToneAudiometryContentView setProgress:self.audiometryEngine.progress animated:YES];

        [self.audiometryEngine nextStatus:^(BOOL testEnded, ORKAudiometryStimulus *stimulus) {
            if (testEnded) {
                [self finish];
            }
            
            self.currentTap = [[ORKdBHLToneAudiometryTap alloc] init];
            self.currentTap.dBHLValue = stimulus.level;
            self.currentTap.frequency = stimulus.frequency;
            self.currentTap.channel = stimulus.channel;
            self.currentTap.response = ORKdBHLToneAudiometryTapBeforeResponseWindow;
            
            const NSTimeInterval toneDuration = [self dBHLToneAudiometryStep].toneDuration;
            const NSTimeInterval postStimulusDelay = [self dBHLToneAudiometryStep].postStimulusDelay;
            
            double delay1 = arc4random_uniform([self dBHLToneAudiometryStep].maxRandomPreStimulusDelay - 1);
            double delay2 = (double)arc4random_uniform(10)/10;
            double preStimulusDelay = delay1 + delay2 + 1;
            [self.audiometryEngine registerPreStimulusDelay:preStimulusDelay];
            
            _preStimulusDelayWorkBlock = dispatch_block_create(DISPATCH_BLOCK_INHERIT_QOS_CLASS, ^{
                if ([[self audiometryEngine] respondsToSelector:@selector(registerStimulusPlayback)]) {
                    [self.audiometryEngine registerStimulusPlayback];
                }
//                [_audioGenerator playSoundAtFrequency:stimulus.frequency onChannel:stimulus.channel dBHL:stimulus.level];
                
//                dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{
                    [_tonePlayer playWithFrequency:stimulus.frequency level:stimulus.level channel:stimulus.channel completion:^(NSError * _Nonnull error) {
                        if (error) {
                            NSLog(@"tonePlayer playWithFrequency error: %@", error);
                        }
                    }];
//                }
                self.currentTap.response = ORKdBHLToneAudiometryTapOnResponseWindow;
            });
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(preStimulusDelay * NSEC_PER_SEC)), dispatch_get_main_queue(), _preStimulusDelayWorkBlock);
            
            _pulseDurationWorkBlock = dispatch_block_create(DISPATCH_BLOCK_INHERIT_QOS_CLASS, ^{
//                [_audioGenerator stop];
                [_tonePlayer stop];
            });
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)((preStimulusDelay + toneDuration - 0.1) * NSEC_PER_SEC)), dispatch_get_main_queue(), _pulseDurationWorkBlock);
            
            _postStimulusDelayWorkBlock = dispatch_block_create(DISPATCH_BLOCK_INHERIT_QOS_CLASS, ^{
                self.currentTap.response = ORKdBHLToneAudiometryNoTapOnResponseWindow;
                [self logCurrentTap];
                            
                [self.audiometryEngine registerResponse:NO];
                [self nextTrial];
            });
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)((preStimulusDelay + toneDuration + postStimulusDelay) * NSEC_PER_SEC)), dispatch_get_main_queue(), _postStimulusDelayWorkBlock);
        }];
    }
}

- (void)nextTrial {
    if (self.audiometryEngine.testEnded) {
        [self finish];
    } else {
        [self runTestTrial];
    }
}

- (void)skipButtonPressed {
    _didSkipStep = YES;
    [self stopAudio];
    [self finish];
}

- (void)tapButtonPressed {

    [self animatedBHLButton];
    [_hapticFeedback impactOccurred];
    
    if (_preStimulusDelayWorkBlock && dispatch_block_testcancel(_preStimulusDelayWorkBlock) == 0) {
        [self.audiometryEngine registerResponse:YES];
    }
    
    [self logCurrentTap];
    [self nextTrial];
}

- (void)toneWillStartClipping {
    if ([self.audiometryEngine respondsToSelector:@selector(signalClipped)]) {
        [self.audiometryEngine signalClipped];
    }
    [self nextTrial];
}

- (void)logCurrentTap {
    if ([_taps containsObject:self.currentTap]) {
        self.currentTap = [self.currentTap copy];
    }
    
    self.currentTap.timeStamp = self.runtime;
    [_taps addObject:self.currentTap];
    ORK_Log_Info("Log tap: %@", self.currentTap);
}

#pragma mark - Headphone Monitoring

- (NSString *)headphoneType {
    return [[self dBHLToneAudiometryStep].headphoneType uppercaseString];
}

- (void)bluetoothChanged: (NSNotification *)note {
    // check if budsInEars
//    ORKTaskViewController *taskVC = self.taskViewController;
//    if (!taskVC.budsInEars) {
//        [self showAlertWithTitle:@"Hearing Test" andMessage:@"Make sure you have both buds in ears."];
//    } else if (taskVC.callActive) {
//        [self showAlertWithTitle:@"Hearing Test" andMessage:@"Please finish the call and try the task again."];
//    } else if (taskVC.ancStatus != ORKdBHLHeadphonesANCStatusEnabled) {
//        [self showAlertWithTitle:@"Hearing Test" andMessage:@"ANC mode must be turned ON to take this test."];
//    } else if (taskVC.leftBattery < LOW_BATTERY_LEVEL_THRESHOLD_VALUE || taskVC.rightBattery < LOW_BATTERY_LEVEL_THRESHOLD_VALUE) {
//        [self showAlertWithTitle:@"Hearing Test" andMessage:@"Headphones battery level are low. Please charge it and take the test again."];
//    }
}

- (void)showAlertWithTitle:(NSString *)title andMessage:(NSString *)message {
    if (!_showingAlert) {
        _showingAlert = YES;
        ORKWeakTypeOf(self) weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self stopAudio];
            UIAlertController *alertController = [UIAlertController
                                                  alertControllerWithTitle:title
                                                  message:message
                                                  preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *startOver = [UIAlertAction
                                        actionWithTitle:ORKLocalizedString(@"dBHL_ALERT_TITLE_START_OVER", nil)
                                        style:UIAlertActionStyleDefault
                                        handler:^(UIAlertAction *action) {
                ORKStrongTypeOf(weakSelf) strongSelf = weakSelf;
                [[strongSelf taskViewController] flipToPageWithIdentifier:[strongSelf identiferForLastFitTest] forward:NO animated:NO];
            }];
            [alertController addAction:startOver];
            [alertController addAction:[UIAlertAction
                                        actionWithTitle:ORKLocalizedString(@"dBHL_ALERT_TITLE_CANCEL_TEST", nil)
                                        style:UIAlertActionStyleDefault
                                        handler:^(UIAlertAction *action) {
                ORKStrongTypeOf(self.taskViewController.delegate) strongDelegate = self.taskViewController.delegate;
                if ([strongDelegate respondsToSelector:@selector(taskViewController:didFinishWithReason:error:)]) {
                    [strongDelegate taskViewController:self.taskViewController didFinishWithReason:ORKTaskViewControllerFinishReasonDiscarded error:nil];
                }
            }]];
            alertController.preferredAction = startOver;
            [self presentViewController:alertController animated:YES completion:nil];
        });
    }
}

- (NSString *)identiferForLastFitTest {
    ORKTaskResult *taskResults = [[self taskViewController] result];
    
    NSString *identifier = @"";

    for (ORKStepResult *result in taskResults.results) {
        if (result.results > 0) {
            ORKStepResult *firstResult = (ORKStepResult *)[result.results firstObject];
            if ([firstResult isKindOfClass:[ORKdBHLFitTestResult class]]) {
                ORKdBHLFitTestResult *fitTestResult = (ORKdBHLFitTestResult *)firstResult;
                identifier = fitTestResult.identifier;
            }
        }
    }
    
    return identifier;
}

@end
