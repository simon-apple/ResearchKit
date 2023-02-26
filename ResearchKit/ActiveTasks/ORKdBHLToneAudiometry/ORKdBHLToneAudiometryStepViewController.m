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

@interface ORKdBHLToneAudiometryStepViewController () <ORKdBHLToneAudiometryPulsedAudioGeneratorDelegate, ORKHeadphoneDetectorDelegate> {
    ORKdBHLToneAudiometryFrequencySample *_resultSample;
    ORKAudioChannel _audioChannel;

    ORKdBHLToneAudiometryPulsedAudioGenerator *_audioGenerator;
    UIImpactFeedbackGenerator *_hapticFeedback;
    
    dispatch_block_t _preStimulusDelayWorkBlock;
    dispatch_block_t _pulseDurationWorkBlock;
    dispatch_block_t _postStimulusDelayWorkBlock;
    
    NSMutableArray<ORKdBHLToneAudiometryTap *> *_taps;
    
    ORKHeadphoneDetector *_headphoneDetector;
    
    NSString *_caseSerial;
    NSString *_leftSerial;
    NSString *_rightSerial;
    
#if QA_DISTRIBUTION
     BOOL _debugEnabled;
#endif
}

@property (nonatomic, strong) ORKdBHLToneAudiometryContentView *dBHLToneAudiometryContentView;
@property (nonatomic, strong) ORKdBHLToneAudiometryTap *currentTap;

@end

@implementation ORKdBHLToneAudiometryStepViewController

- (instancetype)initWithStep:(ORKStep *)step {
    self = [super initWithStep:step];
    
    if (self) {
        self.suspendIfInactive = YES;
#if QA_DISTRIBUTION
         _debugEnabled = YES;
#endif
        ORKWeakTypeOf(self) weakSelf = self;
        self.audiometryEngine.timestampProvider = ^NSTimeInterval{
            ORKStrongTypeOf(self) strongSelf = weakSelf;
            return strongSelf ? strongSelf.runtime : 0;
        };
        _taps = [[NSMutableArray alloc] init];
        self.currentTap = [[ORKdBHLToneAudiometryTap alloc] init];
        self.currentTap.response = ORKdBHLToneAudiometryTapBeforeResponseWindow;
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

- (void)dealloc {
    [_headphoneDetector discard];
    _headphoneDetector = nil;
}

- (void)configureStep {
    ORKdBHLToneAudiometryStep *dBHLTAStep = [self dBHLToneAudiometryStep];

    self.dBHLToneAudiometryContentView = [[ORKdBHLToneAudiometryContentView alloc] init];
    self.activeStepView.activeCustomView = self.dBHLToneAudiometryContentView;
    self.activeStepView.customContentFillsAvailableSpace = YES;
    [self.activeStepView.navigationFooterView setHidden:YES];

    [self.dBHLToneAudiometryContentView.tapButton addTarget:self action:@selector(tapButtonPressed) forControlEvents:UIControlEventTouchDown];
    
#if RK_APPLE_INTERNAL
    //TODO:- figure out where this call lives
    [[self taskViewController] lockDeviceVolume:0.625];
    
    dBHLTAStep.headphoneType = ORKHeadphoneTypeIdentifierAirPodsProGen2;
    
    _headphoneDetector = [[ORKHeadphoneDetector alloc] initWithDelegate:self
                                         supportedHeadphoneChipsetTypes:[ORKHeadphoneDetectStep dBHLTypes]];

    ORKTaskResult *taskResults = [[self taskViewController] result];

    for (ORKStepResult *result in taskResults.results) {
        if (result.results > 0) {
            ORKStepResult *firstResult = (ORKStepResult *)[result.results firstObject];
            if ([firstResult isKindOfClass:[ORKHeadphoneDetectResult class]]) {
                ORKHeadphoneDetectResult *headphoneDetectResult = (ORKHeadphoneDetectResult *)firstResult;
                dBHLTAStep.headphoneType = headphoneDetectResult.headphoneType;
        
            } else if ([firstResult isKindOfClass:[ORKdBHLToneAudiometryResult class]]) {
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
    //_audioGenerator = [[ORKdBHLToneAudiometryAudioGenerator alloc] initForHeadphoneType:dBHLTAStep.headphoneType];
    _audioGenerator.delegate = self;
    _hapticFeedback = [[UIImpactFeedbackGenerator alloc] initWithStyle: UIImpactFeedbackStyleHeavy];
}

- (void)addObservers {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(appWillTerminate:) name:UIApplicationWillTerminateNotification object:nil];
}

- (void)removeObservers {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center removeObserver:self name:UIApplicationWillTerminateNotification object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self start];
    [self addObservers];
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
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self removeObservers];
    [self stopAudio];
}

#if KAGRA_PROTO

#define lowerDouble 10.0
#define upperDouble 20.0

- (double)randomDoubleBetween:(double)smallNumber and:(double)bigNumber {
    double diff = bigNumber - smallNumber;
    return (((double) (arc4random() % ((unsigned)RAND_MAX + 1)) / RAND_MAX) * diff) + smallNumber;
}

- (NSNumber *)randomNumberFromRangeMax:(double)aMax Min:(double)aMin {
    return [NSNumber numberWithDouble:[self randomDoubleBetween:aMin and:aMax]];
}

- (NSNumber *)simulatedHLForKey:(NSString *)key {
    NSString *shl = [NSUserDefaults.standardUserDefaults valueForKey:key];
    shl = shl ? shl : @"";
    shl = [shl isEqual:@""] ? @"0" : shl;
    shl = [shl stringByReplacingOccurrencesOfString:@"," withString:@"."];
    
    NSNumber *nshl = [NSNumber numberWithDouble:[shl doubleValue]];
    nshl = nshl ? nshl : [NSNumber numberWithDouble:0];
    return nshl;
}

- (NSDictionary *)simulatedHLTable {
    NSNumber *nshl250  = [self randomNumberFromRangeMax:upperDouble Min:lowerDouble];
    NSNumber *nshl500  = [self randomNumberFromRangeMax:upperDouble Min:lowerDouble];
    NSNumber *nshl1000 = [self randomNumberFromRangeMax:upperDouble Min:lowerDouble];
    NSNumber *nshl2000 = [self randomNumberFromRangeMax:upperDouble Min:lowerDouble];
    NSNumber *nshl3000 = [self randomNumberFromRangeMax:upperDouble Min:lowerDouble];
    NSNumber *nshl4000 = [self randomNumberFromRangeMax:upperDouble Min:lowerDouble];
    NSNumber *nshl8000 = [self randomNumberFromRangeMax:upperDouble Min:lowerDouble];
    
    return @{@"250":nshl250,@"500":nshl500,@"1000":nshl1000,@"2000":nshl2000,
             @"3000":nshl3000,@"4000":nshl4000,@"8000":nshl8000};
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
    toneResult.samples = [self.audiometryEngine resultSamples];
    toneResult.allTaps = [_taps copy];
#if RK_APPLE_INTERNAL
    toneResult.caseSerial = _caseSerial.length > 1 ? _caseSerial : @"";
    toneResult.leftSerial = _leftSerial.length > 1 ? _leftSerial : @"";
    toneResult.rightSerial = _rightSerial.length > 1 ? _rightSerial : @"";
    if (@available(iOS 14.0, *)) {
        if ([self.audiometryEngine isKindOfClass:[ORKNewAudiometry class]]) {
            ORKNewAudiometry *engine = (ORKNewAudiometry *)self.audiometryEngine;
            toneResult.algorithmVersion = 1;
            toneResult.discreteUnits = engine.resultUnits;
            toneResult.fitMatrix = engine.fitMatrix;
            toneResult.deletedSamples = engine.deletedSamples;
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
    [super stepDidFinish];
    [self stopAudio];
    [self.dBHLToneAudiometryContentView finishStep:self];
    [self goForward];
}

- (void)start {
    [super start];
    [self runTestTrial];
}
    
- (void)stopAudio {
    [_audioGenerator stop];
#if RK_APPLE_INTERNAL && QA_DISTRIBUTION
     if (_debugEnabled) {
         [self.dBHLToneAudiometryContentView setDebugPlayText:ORKLocalizedString(@"Not Playing Audio", nil)];
     }
 #endif
    if (_preStimulusDelayWorkBlock) {
        dispatch_block_cancel(_preStimulusDelayWorkBlock);
        dispatch_block_cancel(_pulseDurationWorkBlock);
        dispatch_block_cancel(_postStimulusDelayWorkBlock);
    }
}

- (void)runTestTrial {
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
    #if RK_APPLE_INTERNAL && QA_DISTRIBUTION
             if (_debugEnabled) {
                 [self.dBHLToneAudiometryContentView setDebugPlayText:[NSString stringWithFormat:ORKLocalizedString(@"Playing dBHL: %f\nFrequency: %f",nil), stimulus.level,stimulus.frequency]];
             }
     #endif
            if ([[self audiometryEngine] respondsToSelector:@selector(registerStimulusPlayback)]) {
                [self.audiometryEngine registerStimulusPlayback];
            }
            [_audioGenerator playSoundAtFrequency:stimulus.frequency onChannel:stimulus.channel dBHL:stimulus.level];
            self.currentTap.response = ORKdBHLToneAudiometryTapOnResponseWindow;
        });
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(preStimulusDelay * NSEC_PER_SEC)), dispatch_get_main_queue(), _preStimulusDelayWorkBlock);
        
        _pulseDurationWorkBlock = dispatch_block_create(DISPATCH_BLOCK_INHERIT_QOS_CLASS, ^{
    #if RK_APPLE_INTERNAL && QA_DISTRIBUTION
             if (_debugEnabled) {
                 [self.dBHLToneAudiometryContentView setDebugPlayText:ORKLocalizedString(@"Not Playing Audio", nil)];
             }
     #endif
            [_audioGenerator stop];
        });
        // adding 0.2 seconds to account for the fadeInDuration which is being set in ORKdBHLToneAudiometryAudioGenerator
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)((preStimulusDelay + toneDuration + 0.2) * NSEC_PER_SEC)), dispatch_get_main_queue(), _pulseDurationWorkBlock);
        
        _postStimulusDelayWorkBlock = dispatch_block_create(DISPATCH_BLOCK_INHERIT_QOS_CLASS, ^{
    #if RK_APPLE_INTERNAL && QA_DISTRIBUTION
             if (_debugEnabled) {
                 [self.dBHLToneAudiometryContentView setDebugTapText:ORKLocalizedString(@"Tap missed", nil)];
             }
     #endif
            self.currentTap.response = ORKdBHLToneAudiometryNoTapOnResponseWindow;
            [self logCurrentTap];
                        
            [self.audiometryEngine registerResponse:NO];
            [self nextTrial];
        });
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)((preStimulusDelay + toneDuration + postStimulusDelay) * NSEC_PER_SEC)), dispatch_get_main_queue(), _postStimulusDelayWorkBlock);
    }];
}

- (void)nextTrial {
    if (self.audiometryEngine.testEnded) {
        [self finish];
    } else {
        [self runTestTrial];
    }
}

- (void)tapButtonPressed {
#if RK_APPLE_INTERNAL && QA_DISTRIBUTION
         if (_debugEnabled) {
             [self.audiometryEngine nextStatus:^(BOOL testEnded, ORKAudiometryStimulus *stimulus) {
                 [self.dBHLToneAudiometryContentView setDebugTapText:[NSString stringWithFormat:ORKLocalizedString(@"Tap dBHL: %f",nil), stimulus.level]];
             }];
         }
 #endif
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

- (void)headphoneTypeDetected:(ORKHeadphoneTypeIdentifier)headphoneType
                     vendorID:(NSString *)vendorID productID:(NSString *)productID
                deviceSubType:(NSInteger)deviceSubType isSupported:(BOOL)isSupported {
    
}

- (void)serialNumberCollectedCase:(NSString *)caseSerial left:(NSString *)leftSerial right:(NSString *)rightSerial {
    _caseSerial = caseSerial;
    _leftSerial = leftSerial;
    _rightSerial = rightSerial;
}

@end
