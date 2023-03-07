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
#import "ORKdBHLToneAudiometryScreenerContentSliderView.h"
#import <MediaPlayer/MPVolumeView.h>

#import <ResearchKit/ResearchKit-Swift.h>
#import "ORKNavigationContainerView_Internal.h"

#import "ORKAudiometry.h"

@interface ORKdBHLToneAudiometryScreenerStepViewController () <ORKdBHLToneAudiometryPulsedAudioGeneratorDelegate, ORKHeadphoneDetectorDelegate> {
    double _prevFreq;
    double _currentdBHL;
    double _dBHLStepUpSize;
    double _dBHLStepDownSize;
    double _dBHLMinimumThreshold;
    double _dBHLMaximumThreshold;
    int _currentTestIndex;
    int _indexOfFreqLoopList;
    NSUInteger _indexOfStepUpMissingList;
    int _numberOfTransitionsPerFreq;
    NSInteger _maxNumberOfTransitionsPerFreq;
    BOOL _initialDescent;
    BOOL _ackOnce;
    BOOL _usingMissingList;
    ORKdBHLToneAudiometryPulsedAudioGenerator *_audioGenerator;
    //NSArray *_freqLoopList;
    NSArray *_stepUpMissingList;
    //NSMutableArray *_arrayOfResultSamples;
    NSMutableArray *_arrayOfResultUnits;
    NSMutableDictionary *_transitionsDictionary;
    ORKdBHLToneAudiometryFrequencySample *_resultSample;
    ORKdBHLToneAudiometryUnit *_resultUnit;
    
    ORKHeadphoneDetector *_headphoneDetector;
    BOOL _showingAlert;
    BOOL _isTouching;
    
    NSString *_caseSerial;
    NSString *_leftSerial;
    NSString *_rightSerial;
    
    id<ORKAudiometryProtocol> _audiometry;
    double _currentFreq;
    float _initialLevel;
    float _finalLevel;
    float _maxSelectedLevel;
    float _minSelectedLevel;
    
    int _counter;
    BOOL _isRefinementStep;
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
        //_arrayOfResultSamples = [NSMutableArray array];
        _arrayOfResultUnits = [NSMutableArray array];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
             selector:@selector(receiveNextButtonTappedNotification:)
             name:@"nextButtonTapped"
             object:nil];
        
        _counter = 0;
        _isRefinementStep = NO;
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

    // TODO: - plumb this through properly
//    _currentdBHL = dBHLTAStep.minimumdBHL;
//    _dBHLMinimumThreshold = dBHLTAStep.minimumdBHL;
//    _dBHLMaximumThreshold = dBHLTAStep.maximumdBHL;
    
    _currentdBHL = 30.925;
    _dBHLMinimumThreshold = -10;
    _dBHLMaximumThreshold = 75;
    
    if (self.dBHLToneAudiometryStep.useSlider) {
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
    
    if (self.dBHLToneAudiometryStep.useSlider) {
        float stepSize = dBHLTAStep.stepSize;// [[NSUserDefaults standardUserDefaults] floatForKey:@"kagra_alt_ui_step"];
        stepSize = (stepSize == 0) ? 5.0 : stepSize;
        
        // plumb through configuration here
        
        // Disable back-swiping during the test
        if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
            self.navigationController.interactivePopGestureRecognizer.enabled = NO;
        }
        
        if (@available(iOS 14.0, *)) {
            self.dBHLToneAudiometryContentView = [[ORKdBHLToneAudiometryScreenerContentSliderView alloc] initWithValue:_currentdBHL
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
    self.activeStepView.activeCustomView = self.dBHLToneAudiometryContentView;
    [self.activeStepView removeCustomContentPadding];
    [self.activeStepView pinNavigationContainerToBottom];
    self.activeStepView.customContentFillsAvailableSpace = YES;
    
    self.internalDoneButtonItem.enabled = YES;
//    [self.activeStepView.navigationFooterView setHidden:YES];

    _headphoneDetector = [[ORKHeadphoneDetector alloc] initWithDelegate:self
                                                supportedHeadphoneChipsetTypes:[ORKHeadphoneDetectStep dBHLTypes]];
    
    //KAGRATODO:- change to the correct volume level
    [[self taskViewController] lockDeviceVolume:1.0];
    
    ORKWeakTypeOf(self) weakSelf = self;
    _audiometry.timestampProvider = ^NSTimeInterval{
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

    _audioGenerator = [[ORKdBHLToneAudiometryPulsedAudioGenerator alloc] initForHeadphoneType:dBHLTAStep.headphoneType pulseMillisecondsDuration:200 pauseMillisecondsDuration:50];
    _audioGenerator.delegate = self;
//    [_navigationFooterView.continueButton removeTarget:_navigationFooterView action:nil forControlEvents:UIControlEventTouchUpInside];
//    [_navigationFooterView.continueButton addTarget:self action:@selector(continueButtonAction:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)receiveNextButtonTappedNotification:(NSNotification *) notification {
    if ([[notification name] isEqualToString:@"nextButtonTapped"]) {
        [self continueButtonAction:self];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self start];
    _navigationFooterView = nil;
    //_navigationFooterView.continueEnabled = YES;
    [self.dBHLToneAudiometryContentView setProgress:0 animated:YES];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_headphoneDetector discard];
    _headphoneDetector.delegate = nil;
    _headphoneDetector = nil;
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
    toneResult.caseSerial = _caseSerial.length > 1 ? _caseSerial : @"";
    toneResult.leftSerial = _leftSerial.length > 1 ? _leftSerial : @"";
    toneResult.rightSerial = _rightSerial.length > 1 ? _rightSerial : @"";
    
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
        } else if([_audiometry isKindOfClass:[ORKAudiometry class]]) {
//            toneResult.dBHLValue =
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
        NSLog(@"Starting Frequency: %f", dBHLTAStep.frequency);
    }];
}
    
- (void)stopAudio {
    [_audioGenerator stop];
}

- (void)toneWillStartClipping {
}

- (void)didSelected:(float)value {
//    _navigationFooterView.continueEnabled = YES;
    
    if (self.dBHLToneAudiometryStep.dBHLCalculatedThreshold != value) {
        [_audioGenerator setCurrentdBHLAndRamp:value];
        self.dBHLToneAudiometryStep.dBHLCalculatedThreshold = value;
        
        if (value > _maxSelectedLevel) {
            _maxSelectedLevel = value;
        } else if (value < _minSelectedLevel) {
            _minSelectedLevel = value;
        }
        _finalLevel = value;
    }
}

#define CONFIDENCE_REFINEMENT @"Refinement"
#define CONFIDENCE_INFERENCE @"ReversalInference"
#define CONFIDENCE_GUESS @"Guess"

- (void)continueButtonAction:(id)sender {
    
    if (self.dBHLToneAudiometryStep.isMultiStep) {
        if (!_isRefinementStep) {
            _isRefinementStep = YES;
            [self.dBHLToneAudiometryContentView setIsRefinementStep:_isRefinementStep];
            return;

        } else {
            _isRefinementStep = NO;
            [self.dBHLToneAudiometryContentView setIsRefinementStep:_isRefinementStep];
            [self.dBHLToneAudiometryContentView resetView];
            _navigationFooterView.continueEnabled = NO;
            
            [_audiometry stimulusAcknowledgedWithdBHL:_finalLevel];
        }
    } else if (self.dBHLToneAudiometryStep.useSlider) {
        [_audiometry stimulusAcknowledgedWithdBHL:_finalLevel];
    }
    
    //_navigationFooterView.continueEnabled = NO;
    [self stopAudio];

    _counter++;
    NSLog(@"Sliders presented: %d", _counter);

    [self.dBHLToneAudiometryContentView resetView];
    
    [self nextTrial];
}

- (void)nextTrial {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (_audiometry.testEnded) {
            [self finish];
            return;
        }
        //_navigationFooterView.continueEnabled = YES;
        
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
            NSLog(@"Starting Frequency: %lf  -  Level: %lf", sti.frequency, sti.level);
        }];
    });
}

- (void)resetLevel:(float)level {
    [self.dBHLToneAudiometryContentView setValue:level];
    
    _initialLevel = level;
    _finalLevel = level;
    _maxSelectedLevel = level;
    _minSelectedLevel = level;
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
