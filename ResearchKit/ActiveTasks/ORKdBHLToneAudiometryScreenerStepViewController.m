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


#import "ORKdBHLToneAudiometryScreenerStepViewController.h"

#import "ORKActiveStepView.h"
#import "ORKActiveStep_Internal.h"
#import "ORKStepHeaderView_Internal.h"
#import "ORKNavigationContainerView.h"
#import "ORKStepContainerView.h"

#import "ORKInstructionStepContainerView.h"

#import "ORKdBHLToneAudiometryPulsedAudioGenerator.h"
#import "ORKRoundTappingButton.h"
#import "ORKStepContainerView_Private.h"

#import "ORKActiveStepViewController_Internal.h"
#import "ORKStepViewController_Internal.h"

#import "ORKCollectionResult_Private.h"
#import "ORKdBHLToneAudiometryResult.h"
#import "ORKdBHLToneAudiometryScreenerStep.h"
#import "ORKHeadphoneDetectStep.h"

#import "ORKHelpers_Internal.h"
#import "ORKTaskViewController_Private.h"
#import "ORKTaskViewController_Internal.h"
#import "ORKOrderedTask.h"
#import "ORKHeadphoneDetectResult.h"
#import "ORKdBHLToneAudiometryTransitions.h"

#import "ORKCelestialSoftLink.h"

#import "ORKdBHLToneAudiometryScreenerContentViewA.h"
#import "ORKdBHLToneAudiometryScreenerContentViewB.h"
#import "ORKdBHLToneAudiometryScreenerContentMOAView.h"
#import <MediaPlayer/MPVolumeView.h>

#import <ResearchKit/ResearchKit-Swift.h>
#import "ORKNavigationContainerView_Internal.h"

#import "ORKAudiometry.h"

@interface ORKdBHLToneAudiometryScreenerStepViewController () <ORKdBHLToneAudiometryPulsedAudioGeneratorDelegate> {
    double _prevFreq;
    double _currentdBHL;
    double _dBHLStepUpSize;
    double _dBHLStepDownSize;
    double _dBHLMinimumThreshold;
    double _dBHLMaximumThreshold;
    double _dBHLCalculatedThreshold;
    int _currentTestIndex;
    int _indexOfFreqLoopList;
    NSUInteger _indexOfStepUpMissingList;
    int _numberOfTransitionsPerFreq;
    NSInteger _maxNumberOfTransitionsPerFreq;
    BOOL _initialDescent;
    BOOL _ackOnce;
    BOOL _usingMissingList;
    ORKdBHLToneAudiometryPulsedAudioGenerator *_audioGenerator;
    NSArray *_stepUpMissingList;
    NSMutableArray *_arrayOfResultUnits;
    NSMutableDictionary *_transitionsDictionary;
    ORKdBHLToneAudiometryFrequencySample *_resultSample;
    ORKdBHLToneAudiometryUnit *_resultUnit;
    
    BOOL _showingAlert;
    BOOL _isTouching;
    
    id<ORKAudiometryProtocol> _audiometry;
    double _currentFreq;
    float _initialLevel;
    float _finalLevel;
    float _maxSelectedLevel;
    float _minSelectedLevel;
    
    int _counter;
}

@property (nonatomic, strong) ORKdBHLToneAudiometryScreenerContentView *dBHLToneAudiometryContentView;

@end

@implementation ORKdBHLToneAudiometryScreenerStepViewController

- (instancetype)initWithStep:(ORKStep *)step {
    self = [super initWithStep:step];
    
    if (self) {
        self.suspendIfInactive = YES;
        _indexOfFreqLoopList = 0;
        _indexOfStepUpMissingList = 0;
        _initialDescent = YES;
        _ackOnce = NO;
        _usingMissingList = YES;
        _prevFreq = 0;
        _currentTestIndex = 0;
        _showingAlert = NO;
        _isTouching = NO;
        _transitionsDictionary = [NSMutableDictionary dictionary];
        _arrayOfResultUnits = [NSMutableArray array];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
             selector:@selector(receiveNextButtonTappedNotification:)
             name:@"nextButtonTapped"
             object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
             selector:@selector(receiveSkipButtonTappedNotification:)
             name:@"skipButtonTapped"
             object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
             selector:@selector(bluetoothChanged:)
             name:ORKdBHLBluetoothChangedNotification
             object:nil];
        
        _counter = 0;
    }
    
    return self;
}

- (ORKdBHLToneAudiometryScreenerStep *)dBHLToneAudiometryStep {
    return (ORKdBHLToneAudiometryScreenerStep *)self.step;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self configureStep];
    [self setupVolumeView];
}

- (void)setupVolumeView {
    MPVolumeView *volumeView = [[MPVolumeView alloc] initWithFrame:CGRectNull];
    [volumeView setAlpha:0.001];
    [volumeView setIsAccessibilityElement:NO];
    [self.view addSubview:volumeView];
}

- (void)configureStep {
    ORKdBHLToneAudiometryScreenerStep *dBHLTAStep = [self dBHLToneAudiometryStep];
    
    dBHLTAStep.headphoneType = ORKHeadphoneTypeIdentifierAirPodsProGen2;
    
    _dBHLCalculatedThreshold = dBHLTAStep.dBHLMinimumThreshold;
    
    _currentdBHL = dBHLTAStep.initialdBHLValue;
    _dBHLMinimumThreshold = dBHLTAStep.dBHLMinimumThreshold;
    _dBHLMaximumThreshold = dBHLTAStep.dBHLMaximumThreshold;
    
    if (self.dBHLToneAudiometryStep.isMOA) {
        _audiometry = [[ORKAudiometry alloc] initWithScreenerStep:self.dBHLToneAudiometryStep];
    } else {
        if (@available(iOS 14, *)) {
            _audiometry = [[ORKNewAudiometry alloc] initWithChannel:dBHLTAStep.earPreference
                                                       initialLevel:_currentdBHL
                                                           minLevel:_dBHLMinimumThreshold
                                                           maxLevel:_dBHLMaximumThreshold
                                                        frequencies:dBHLTAStep.frequencyList];
        }
    }
    
    if (self.dBHLToneAudiometryStep.isMOA) {
        float stepSize = dBHLTAStep.stepSize;// [[NSUserDefaults standardUserDefaults] floatForKey:@"kagra_alt_ui_step"];
        stepSize = (stepSize == 0) ? 5.0 : stepSize;
        
        // plumb through configuration here
        
        // Disable back-swiping during the test
        if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
            self.navigationController.interactivePopGestureRecognizer.enabled = NO;
        }
        
        if (@available(iOS 14.0, *)) {
            self.dBHLToneAudiometryContentView = [[ORKdBHLToneAudiometryScreenerContentMOAView alloc] initWithValue:_currentdBHL
                                                                                                            minimum:_dBHLMinimumThreshold
                                                                                                            maximum:_dBHLMaximumThreshold
                                                                                                           stepSize:stepSize
                                                                                                     numFrequencies:dBHLTAStep.frequencyList.count
                                                                                                       audioChannel:dBHLTAStep.earPreference];
        }
        
    } else {
        if (self.dBHLToneAudiometryStep.usePicker) {
            float stepSize = dBHLTAStep.stepSize;// [[NSUserDefaults standardUserDefaults] floatForKey:@"kagra_alt_ui_step"];
            stepSize = (stepSize == 0) ? 5.0 : stepSize;
            self.dBHLToneAudiometryContentView = [[ORKdBHLToneAudiometryScreenerContentViewB alloc] initWithValue:_currentdBHL minimum:_dBHLMinimumThreshold maximum:_dBHLMaximumThreshold stepSize:stepSize];
        } else {
            self.dBHLToneAudiometryContentView = [[ORKdBHLToneAudiometryScreenerContentViewA alloc] initWithValue:_currentdBHL minimum:_dBHLMinimumThreshold maximum:_dBHLMaximumThreshold stepSize:0];
        }
    }
    self.dBHLToneAudiometryContentView.delegate = self;
    [self.view addSubview:self.dBHLToneAudiometryContentView];
    self.dBHLToneAudiometryContentView.translatesAutoresizingMaskIntoConstraints = false;
    
    NSMutableArray *constraints = [NSMutableArray new];
    [constraints addObject:[self.dBHLToneAudiometryContentView.leftAnchor constraintEqualToAnchor:self.view.leftAnchor]];
    [constraints addObject:[self.dBHLToneAudiometryContentView.rightAnchor constraintEqualToAnchor:self.view.rightAnchor]];
    [constraints addObject:[self.dBHLToneAudiometryContentView.topAnchor constraintEqualToAnchor:self.view.topAnchor constant:160.0]];
    [constraints addObject:[self.dBHLToneAudiometryContentView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor constant:0]];
    
    [NSLayoutConstraint activateConstraints:constraints];
    
    self.internalDoneButtonItem.enabled = YES;
    
    //KAGRATODO:- change to the correct volume level
    [[self taskViewController] lockDeviceVolume:0.75];
    
    ORKWeakTypeOf(self) weakSelf = self;
    _audiometry.timestampProvider = ^NSTimeInterval{
        ORKStrongTypeOf(self) strongSelf = weakSelf;
        return strongSelf ? strongSelf.runtime : 0;
    };

    _dBHLToneAudiometryContentView.timestampProvider = ^NSTimeInterval{
        ORKStrongTypeOf(self) strongSelf = weakSelf;
        return strongSelf ? strongSelf.runtime : 0;
    };
    
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
                    BOOL suitableResult = (dBHLToneAudiometryResult.samples.count > 0);
                    
                    // Only use audiograms from ORKNewAudiometry generated results
                    if (suitableResult) {
                        NSMutableDictionary *audiogram = [[NSMutableDictionary alloc] init];
                        
                        for (ORKdBHLToneAudiometryFrequencySample *sample in dBHLToneAudiometryResult.samples) {
                            NSNumber *frequency = [NSNumber numberWithDouble:sample.frequency];
                            NSNumber *threshold = [NSNumber numberWithDouble:sample.calculatedThreshold];
                            audiogram[frequency] = threshold;
                        }
                        
                        if ([_audiometry isKindOfClass:[ORKNewAudiometry class]]) {
                            [(ORKNewAudiometry *)_audiometry setPreviousAudiogram:audiogram];
                        }
                    }
                }
            }
        }
    }

    _audioGenerator = [[ORKdBHLToneAudiometryPulsedAudioGenerator alloc] initForHeadphoneType:dBHLTAStep.headphoneType pulseMillisecondsDuration:200 pauseMillisecondsDuration:200];
    _audioGenerator.delegate = self;
}

- (void)receiveNextButtonTappedNotification:(NSNotification *) notification {
    if ([[notification name] isEqualToString:@"nextButtonTapped"]) {
        [self continueButtonAction:self];
    }
}

- (void)receiveSkipButtonTappedNotification:(NSNotification *) notification {
    if ([[notification name] isEqualToString:@"skipButtonTapped"]) {
        [self stopAudio];
        [self finish];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self start];
    _navigationFooterView = nil;
    [self.dBHLToneAudiometryContentView setProgress:0 animated:YES];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    _audioGenerator.delegate = nil;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self stopAudio];
}

- (ORKStepResult *)result {
    ORKStepResult *sResult = [super result];
    // "Now" is the end time of the result, which is either actually now,
    // or the last time we were in the responder chain.
    NSDate *now = sResult.endDate;
    
    NSMutableArray *results = [NSMutableArray arrayWithArray:sResult.results];
    
    ORKdBHLToneAudiometryResult *toneResult = [[ORKdBHLToneAudiometryResult alloc] initWithIdentifier:self.step.identifier];
    toneResult.startDate = sResult.startDate;
    toneResult.endDate = now;
    toneResult.samples = [_audiometry resultSamples];
    toneResult.caseSerial = self.taskViewController.caseSerial.length > 1 ? self.taskViewController.caseSerial : @"";
    toneResult.leftSerial = self.taskViewController.leftBudSerial.length > 1 ? self.taskViewController.leftBudSerial : @"";
    toneResult.rightSerial = self.taskViewController.rightBudSerial.length > 1 ? self.taskViewController.rightBudSerial : @"";
    toneResult.fwVersion = self.taskViewController.fwVersion.length > 1 ? self.taskViewController.fwVersion : @"";
    
    if (@available(iOS 14.0, *)) {
        if ([_audiometry isKindOfClass:[ORKNewAudiometry class]]) {
            ORKNewAudiometry *engine = _audiometry;
            toneResult.algorithmVersion = 1;
            toneResult.discreteUnits = engine.resultUnits;
            toneResult.fitMatrix = engine.fitMatrix;
            toneResult.deletedSamples = engine.deletedSamples;
            
            if (engine.previousAudiogram && engine.previousAudiogram.count > 0) {
                NSMutableDictionary *previousAudiogram = [NSMutableDictionary new];
                [engine.previousAudiogram enumerateKeysAndObjectsUsingBlock:^(NSNumber *key, NSNumber *value, BOOL* stop) {
                    [previousAudiogram setValue:value forKey:key.stringValue];
                }];
                toneResult.userInfo = @{@"previousAudiogram": previousAudiogram};
            }
        }
    }

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
    ORKdBHLToneAudiometryScreenerStep *dBHLTAStep = [self dBHLToneAudiometryStep];
    
    [_audiometry nextStatus:^(BOOL testEnded, ORKAudiometryStimulus *sti) {
        [_audioGenerator playSoundAtFrequency:sti.frequency onChannel:dBHLTAStep.earPreference dBHL:sti.level];
        [_audiometry registerStimulusPlayback];
        [self resetLevel:sti.level];
        _currentFreq = sti.frequency;
        ORK_Log_Info("Starting Frequency: %f", dBHLTAStep.frequency);
    }];
}
    
- (void)stopAudio {
    [_audioGenerator stop];
}

- (void)toneWillStartClipping {
}

- (void)didSelected:(float)value {
    if (_dBHLCalculatedThreshold != value) {
        [_audioGenerator setCurrentdBHLAndRamp:value];
        _dBHLCalculatedThreshold = value;
        
        if (value > _maxSelectedLevel) {
            _maxSelectedLevel = value;
        } else if (value < _minSelectedLevel) {
            _minSelectedLevel = value;
        }
        _finalLevel = value;
    }
}

- (void)continueButtonAction:(id)sender {
    if (self.dBHLToneAudiometryStep.isMOA) {
        if (@available(iOS 14.0, *)) {
            [_audiometry setInteractions:((ORKdBHLToneAudiometryScreenerContentMOAView *)_dBHLToneAudiometryContentView).userInteractions];
        }
        [_audiometry stimulusAcknowledgedWithdBHL:_finalLevel];
    }
    
    [self stopAudio];

    _counter++;
    ORK_Log_Info("Sliders presented: %d", _counter);
    
    [self.dBHLToneAudiometryContentView resetView];
    
    [self nextTrial];
}

- (void)nextTrial {
    if (!_showingAlert) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (_audiometry.testEnded) {
                [self finish];
                return;
            }
            
            [_audiometry nextStatus:^(BOOL testEnded, ORKAudiometryStimulus *sti) {
                if (testEnded) {
                    [self finish];
                    return;
                }
                
                ORKdBHLToneAudiometryScreenerStep *dBHLTAStep = [self dBHLToneAudiometryStep];
                [self.dBHLToneAudiometryContentView setProgress:_audiometry.progress animated:YES];
                
                [_audioGenerator playSoundAtFrequency:sti.frequency onChannel:dBHLTAStep.earPreference dBHL:sti.level];
                [_audiometry registerStimulusPlayback];
                [self resetLevel:sti.level];
                _currentFreq = sti.frequency;
                ORK_Log_Info("Starting Frequency: %lf  -  Level: %lf", sti.frequency, sti.level);
            }];
        });
    }
}

- (void)resetLevel:(float)level {
    [self.dBHLToneAudiometryContentView setValue:level];
    
    _initialLevel = level;
    _finalLevel = level;
    _maxSelectedLevel = level;
    _minSelectedLevel = level;
}

#pragma mark - Headphone Monitoring

- (NSString *)headphoneType {
    return [[self dBHLToneAudiometryStep].headphoneType uppercaseString];
}

- (void)bluetoothChanged: (NSNotification *)note {
    // check if budsInEars
    ORKTaskViewController *taskVC = self.taskViewController;
    if (!taskVC.budsInEars) {
        [self showAlertWithTitle:@"Hearing Test" andMessage:@"We need the headphones in ears. This test will finish and the results will be saved."];
    } else if (taskVC.callActive) {
        [self showAlertWithTitle:@"Hearing Test" andMessage:@"You have an icomming call. This test will finish and the results will be saved."];
    } else if (taskVC.ancStatus != ORKdBHLHeadphonesANCStatusEnabled) {
        [self showAlertWithTitle:@"Hearing Test" andMessage:@"ANC mode must be turned ON. This test will finish and the results will be saved."];
    } else if (![taskVC.fwVersion isEqualToString:CHAND_FFANC_FWVERSION]) {
        [self showAlertWithTitle:@"Hearing Test" andMessage:@"Wrong firmware version. This test will finish and the results will be saved."];
    }
}

- (void)showAlertWithTitle:(NSString *)title andMessage:(NSString *)message {
    if (!_showingAlert) {
        _showingAlert = YES;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self stopAudio];
            UIAlertController *alertController = [UIAlertController
                                                  alertControllerWithTitle:title
                                                  message:message
                                                  preferredStyle:UIAlertControllerStyleAlert];
            [alertController addAction:[UIAlertAction
                                        actionWithTitle:@"Finish test"
                                        style:UIAlertActionStyleDefault
                                        handler:^(UIAlertAction *action) {
                ORKStrongTypeOf(self.taskViewController.delegate) strongDelegate = self.taskViewController.delegate;
                if ([strongDelegate respondsToSelector:@selector(taskViewController:didFinishWithReason:error:)]) {
                    [strongDelegate taskViewController:self.taskViewController didFinishWithReason:ORKTaskViewControllerFinishReasonCompleted error:nil];
                }
            }]];
            [self presentViewController:alertController animated:YES completion:nil];
        });
    }
}

@end
