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

#import "ORKTinnitusPureToneStepViewController.h"
#import "ORKTinnitusButtonView.h"
#import "ORKActiveStepView.h"
#import "ORKTinnitusAudioGenerator.h"
#import "ORKTinnitusPureToneContentView.h"

#import "ORKActiveStepViewController_Internal.h"
#import "ORKStepViewController_Internal.h"

#import "ORKTinnitusPureToneResult.h"
#import "ORKTinnitusPureToneStep.h"
#import "ORKStepContainerView_Private.h"
#import "ORKNavigationContainerView_Internal.h"
#import "ORKHelpers_Internal.h"
#import <ResearchKit/ResearchKit_Private.h>

#define ORKTinnitusFadeInDuration 0.1

static const NSTimeInterval PLAY_DELAY = 1.0;
static const NSTimeInterval PLAY_DELAY_VOICEOVER = 1.3;
static const NSTimeInterval PLAY_DURATION = 1.0;
static const NSTimeInterval PLAY_DURATION_VOICEOVER = 4.0;

@interface ORKTinnitusPureToneStepViewController () <ORKTinnitusPureToneContentViewDelegate> {
    ORKTinnitusSelectedPureTonePosition _currentSelectedPosition;

    double _lastChosenFrequency;
    int _octaveConfusionIteration;
    int _indexOffset;
    int _interactionCounter;
    BOOL _isLastIteraction;
    int _sampleIndex;
    NSTimer *_timer;
    
    NSString *_lastError;
    
    NSDate *_choseStepStartTime;
}

@property (nonatomic, strong) ORKTinnitusPureToneContentView *tinnitusContentView;
@property (nonatomic, strong) ORKTinnitusAudioGenerator *audioGenerator;
@property (nonatomic, assign) BOOL expired;

@property (nonatomic) NSArray *frequencies;
@property (nonatomic) NSMutableArray<ORKTinnitusUnit *> *chosenUnits;
@property (nonatomic, assign) NSInteger aFrequencyIndex;
@property (nonatomic, assign) NSInteger bFrequencyIndex;
@property (nonatomic, assign) NSInteger cFrequencyIndex;
@property (nonatomic, assign) NSInteger higherThresholdIndex;
@property (nonatomic, assign) NSInteger lowerThresholdIndex;

- (ORKTinnitusPureToneStep *)tinnitusPuretoneStep;

@end


@implementation ORKTinnitusPureToneStepViewController

- (instancetype)initWithStep:(ORKStep *)step {
    self = [super initWithStep:step];
    
    if (self) {
        self.suspendIfInactive = YES;
    }
    
    return self;
}

- (ORKTinnitusPureToneStep *)tinnitusPuretoneStep {
    return (ORKTinnitusPureToneStep *)self.step;
}

- (void)headphoneChanged:(NSNotification *)note {
    if (self.step.context && [self.step.context isKindOfClass:[ORKTinnitusPredefinedTaskContext class]]) {
        [super headphoneChanged:note];
        [self stopAutomaticPlay];
        [self.audioGenerator stop];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [_tinnitusContentView restoreButtons];
        });
    }
}

- (void)setContinueButtonItem:(UIBarButtonItem *)continueButtonItem {
    continueButtonItem.target = self;
    continueButtonItem.action = @selector(continueButtonTapped:);
    
    [super setContinueButtonItem:continueButtonItem];
}

- (void)startAutomaticPlay {
    _sampleIndex = 0;
    _timer = [[NSTimer alloc] initWithFireDate:[NSDate date]
                                      interval:UIAccessibilityIsVoiceOverRunning() ? PLAY_DURATION_VOICEOVER : PLAY_DURATION
                                        target:self
                                      selector:@selector(playNextSample)
                                      userInfo:nil
                                       repeats:YES];
    NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
    [runLoop addTimer:_timer forMode:NSRunLoopCommonModes];
}


- (void)playNextSample {
    switch (_tinnitusContentView.currentStage) {
        case PureToneButtonsStageOne:
            switch (_sampleIndex) {
                case 0:
                    [_tinnitusContentView simulateTapForPosition:ORKTinnitusSelectedPureTonePositionA];
                    break;
                case 1:
                    [_tinnitusContentView simulateTapForPosition:ORKTinnitusSelectedPureTonePositionB];
                    break;
                case 2:
                case 3:
                    [_tinnitusContentView simulateTapForPosition:ORKTinnitusSelectedPureTonePositionC];
                    break;
                default:
                    break;
            }
            if (_sampleIndex == 3) {
                [self stopAutomaticPlay];
            }
            break;
        case PureToneButtonsStageTwo:
            switch (_sampleIndex) {
                case 0:
                    [_tinnitusContentView simulateTapForPosition:ORKTinnitusSelectedPureTonePositionA];
                    break;
                case 1:
                case 2:
                    [_tinnitusContentView simulateTapForPosition:ORKTinnitusSelectedPureTonePositionB];
                    break;
                default:
                    break;
            }
            if (_sampleIndex == 2) {
                [self stopAutomaticPlay];
            }
            break;
        case PureToneButtonsStageThree:
            switch (_sampleIndex) {
                case 0:
                    [_tinnitusContentView simulateTapForPosition:ORKTinnitusSelectedPureTonePositionA];
                    break;
                case 1:
                case 2:
                    [_tinnitusContentView simulateTapForPosition:ORKTinnitusSelectedPureTonePositionB];
                    break;
                default:
                    break;
            }
            if (_sampleIndex == 2) {
                [self stopAutomaticPlay];
            }
            break;
        default:
            break;
    }
    
    _sampleIndex = _sampleIndex + 1;
}

- (void)stopAutomaticPlay {
    [_tinnitusContentView enableButtonsAnnouncements:YES];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIAccessibilityAnnouncementDidFinishNotification object:nil];
    [NSObject cancelPreviousPerformRequestsWithTarget:self
                                             selector:@selector(startAutomaticPlay)
                                               object:nil];
    [_timer invalidate];
    _timer = nil;
}

- (void)setNavigationFooterView {
    self.activeStepView.navigationFooterView.continueButtonItem = self.continueButtonItem;
    [self.activeStepView.navigationFooterView updateContinueAndSkipEnabled];
}

- (void)continueButtonTapped:(id)sender {
    if (!_isLastIteraction) {
        self.activeStepView.navigationFooterView.continueEnabled = NO;
        [self fineTunePressed];
    } else {
        [self finish];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = [NSString stringWithFormat:ORKLocalizedString(@"TINNITUS_PURETONE_BAR_TITLE1", nil), self.tinnitusPuretoneStep.roundNumber];
    
    [self setNavigationFooterView];
    [self setupButtons];
    
    self.expired = NO;
    
    [self resetVariables];
    
    self.tinnitusContentView = [[ORKTinnitusPureToneContentView alloc] init];
    self.activeStepView.activeCustomView = self.tinnitusContentView;
    self.activeStepView.customContentFillsAvailableSpace = YES;

    self.tinnitusContentView.delegate = self;
    
    [_tinnitusContentView resetButtons];
    
    
    ORKTaskResult *taskResults = [[self taskViewController] result];
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
    
    self.isAccessibilityElement = YES;
    
    if (UIAccessibilityIsVoiceOverRunning()) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(PLAY_DELAY_VOICEOVER * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self setupAutoPlay];
        });
    } else {
        [self setupAutoPlay];
    }
}

- (void)setupAutoPlay {
    if (UIAccessibilityIsVoiceOverRunning()) {
        UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, self.activeStepView.stepTitle);
        UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, self.tinnitusPuretoneStep.title);
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(announcementFinished:) name:UIAccessibilityAnnouncementDidFinishNotification object:nil];
    } else {
        [self performSelector:@selector(startAutomaticPlay) withObject:nil afterDelay:PLAY_DELAY];
    }
}

- (void)announcementFinished:(NSNotification*)notification {
    BOOL success = [notification.userInfo[UIAccessibilityAnnouncementKeyWasSuccessful] boolValue];
    if (success) {
        if ([notification.userInfo[UIAccessibilityAnnouncementKeyStringValue] isEqualToString:self.tinnitusPuretoneStep.title]) {
            UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, ORKLocalizedString(@"TINNITUS_TYPE_ACCESSIBILITY_ANNOUNCEMENT", nil));
        } else {
            [[NSNotificationCenter defaultCenter] removeObserver:self name:UIAccessibilityAnnouncementDidFinishNotification object:nil];
            [self performSelector:@selector(startAutomaticPlay) withObject:nil afterDelay:PLAY_DELAY];
        }
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (@available(iOS 13.0, *)) {
        self.view.backgroundColor = UIColor.systemGroupedBackgroundColor;
        self.taskViewController.navigationBar.barTintColor = UIColor.systemGroupedBackgroundColor;
        [self.taskViewController.navigationBar setTranslucent:NO];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self stopAutomaticPlay];
    [self.audioGenerator stop];
}

- (void)calculateIndexesWhenConverging {
    ORKTinnitusSelectedPureTonePosition currentSelectedPosition = [_tinnitusContentView currentSelectedPosition];
    
    double chosenFrequency;
    
    if (currentSelectedPosition == ORKTinnitusSelectedPureTonePositionA) {
        chosenFrequency = [_frequencies[_aFrequencyIndex] doubleValue];
    } else {
        chosenFrequency = [_frequencies[_bFrequencyIndex] doubleValue];
    }
    
    switch (_octaveConfusionIteration) {
        case 0:
            if (currentSelectedPosition == ORKTinnitusSelectedPureTonePositionA) {
                // the a button has the frequency that converged
                if (_aFrequencyIndex < _frequencies.count - 6) {
                    // we can test for higher octave
                    _bFrequencyIndex = _aFrequencyIndex + 6;
                } else {
                    // frequency is too high testing the lower octave
                    _bFrequencyIndex = _aFrequencyIndex;
                    _aFrequencyIndex = _aFrequencyIndex - 6;
                    // this will bypass phase 1
                    _octaveConfusionIteration = _octaveConfusionIteration + 1;
                    _isLastIteraction = YES;
                }
            } else {
                // the b button has the frequency that converged
                if (_bFrequencyIndex < _frequencies.count - 6) {
                    // we can test for higher octave
                    _aFrequencyIndex = _bFrequencyIndex;
                    _bFrequencyIndex = _aFrequencyIndex + 6;
                    _isLastIteraction = (_aFrequencyIndex <= 6);
                } else {
                    // frequency is too high testing the lower octave
                    _aFrequencyIndex = _bFrequencyIndex - 6;
                    // this will bypass phase 1
                    _octaveConfusionIteration = _octaveConfusionIteration + 1;
                     _isLastIteraction = YES;
                }
            }
            _octaveConfusionIteration = _octaveConfusionIteration + 1;
            break;
        case 1:
            if (_lastChosenFrequency != chosenFrequency) {
                // user is confused the test ends
                _lastChosenFrequency = chosenFrequency;
                self.activeStepView.navigationFooterView.continueEnabled = YES;
            } else if (_aFrequencyIndex >= 6) {
                // we can test lower octave
                _bFrequencyIndex = _aFrequencyIndex;
                _aFrequencyIndex = _aFrequencyIndex - 6;
                _octaveConfusionIteration = _octaveConfusionIteration + 1;
                _isLastIteraction = YES;
            } else {
                _lastChosenFrequency = chosenFrequency;
                self.activeStepView.navigationFooterView.continueEnabled = YES;
            }
            break;
        case 2:
            _lastChosenFrequency = chosenFrequency;
            self.activeStepView.navigationFooterView.continueEnabled = YES;
            break;
    }
}

- (void)addUnitForFrequencies: (NSArray *) frequencies chosen:(double)frequency {
    ORKTinnitusUnit *selectedUnit = [[ORKTinnitusUnit alloc] init];
    selectedUnit.availableFrequencies = frequencies;
    selectedUnit.chosenFrequency = frequency;
    selectedUnit.elapsedTime = [[NSDate date] timeIntervalSinceDate:_choseStepStartTime];
    [_chosenUnits addObject:selectedUnit];
    _choseStepStartTime = [NSDate date];
}

- (void)setupButtons {
    self.continueButtonItem  = self.internalContinueButtonItem;
}

- (void)resetVariables {
    ORKTinnitusPureToneStep *tinnitusPuretoneStep = (ORKTinnitusPureToneStep *)self.step;
    _frequencies = [tinnitusPuretoneStep listOfChoosableFrequencies];
    _indexOffset = 2;
    NSUInteger round = [tinnitusPuretoneStep roundNumber] - 1;
    _cFrequencyIndex = ([tinnitusPuretoneStep lowFrequencyIndex] * _indexOffset) + round;
    _bFrequencyIndex = ([tinnitusPuretoneStep mediumFrequencyIndex] * _indexOffset) + round;
    _aFrequencyIndex = ([tinnitusPuretoneStep highFrequencyIndex] * _indexOffset) + round;
    _higherThresholdIndex = -1;
    _lowerThresholdIndex = -1;
    _lastChosenFrequency = 0;
    _octaveConfusionIteration = 0;
    _interactionCounter = 0;
    _isLastIteraction = NO;
    
    _choseStepStartTime = [NSDate date];
    
    _lastError = ORKTinnitusErrorNone;

    self.chosenUnits = [[NSMutableArray alloc] init];
}

- (void)playSoundAt:(double)frequency {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW,
                                 (int64_t)((_audioGenerator.fadeDuration + 0.05) * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.audioGenerator playSoundAtFrequency:frequency];
        });
}

- (ORKStepResult *)result {
    ORKStepResult *sResult = [super result];
    NSDate *now = sResult.endDate;
    
    NSMutableArray *results = [NSMutableArray arrayWithArray:sResult.results];
    
    ORKTinnitusPureToneResult *tinnitusResult = [[ORKTinnitusPureToneResult alloc] initWithIdentifier:self.step.identifier];
    tinnitusResult.startDate = sResult.startDate;
    tinnitusResult.endDate = now;
    tinnitusResult.samples = [_chosenUnits copy];
    tinnitusResult.chosenFrequency = _lastChosenFrequency;
    tinnitusResult.errorMessage = [_lastError copy];
    
    [results addObject:tinnitusResult];
    sResult.results = [results copy];
    
    return sResult;
}

- (void)stepDidFinish {
    [super stepDidFinish];
    
    self.expired = YES;
    [self.tinnitusContentView finishStep:self];
    [self goForward];
}

#pragma mark - ORKTinnitusContentViewDelegate
- (void)playButtonPressedWithNewPosition:(ORKTinnitusSelectedPureTonePosition)newPosition {
    ORKTinnitusButtonView *currentSelectedButtonView = _tinnitusContentView.currentSelectedButtonView;
    if (![currentSelectedButtonView isSimulatedTap]) {
        [self stopAutomaticPlay];
    }
    [self.audioGenerator stop];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)((_audioGenerator.fadeDuration + 0.05) * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSUInteger frequencyIndex = _aFrequencyIndex;
        if (newPosition == ORKTinnitusSelectedPureTonePositionB) {
            frequencyIndex = _bFrequencyIndex;
        } else if (newPosition == ORKTinnitusSelectedPureTonePositionC) {
            frequencyIndex = _cFrequencyIndex;
        }
        if ([_tinnitusContentView hasPlayingButton]) {
            [self playSoundAt:[_frequencies[frequencyIndex] doubleValue]];
        }
        if ([_tinnitusContentView isPlayingLastButton] && _timer == nil && currentSelectedButtonView.isSimulatedTap) {
            [_tinnitusContentView restoreButtons];
        }
        self.activeStepView.navigationFooterView.continueEnabled = [self canEnableFineTune];
    });
}

- (void)animationFinishedForStage:(PureToneButtonsStage)stage {
    if (UIAccessibilityIsVoiceOverRunning()) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)((PLAY_DELAY - 0.05) * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, _tinnitusContentView);
        });
    }
    [self performSelector:@selector(startAutomaticPlay) withObject:nil afterDelay:PLAY_DELAY];
}

- (void)fineTunePressed {
    [_audioGenerator stop];
    ORKTinnitusSelectedPureTonePosition currentSelectedPosition = [_tinnitusContentView currentSelectedPosition];
    
    double aFreq = [_frequencies[_aFrequencyIndex] doubleValue];
    double bFreq = [_frequencies[_bFrequencyIndex] doubleValue];
    double cFreq = [_frequencies[_cFrequencyIndex] doubleValue];
    double chosenFrequency;
    
    if ([_tinnitusContentView currentStage] == PureToneButtonsStageOne) {
        // first step, we have no idea of the frequency match yet, so we offer frequencies values that are far from each other
        if (currentSelectedPosition == ORKTinnitusSelectedPureTonePositionA) {
            chosenFrequency = aFreq;
            _higherThresholdIndex = _frequencies.count - 1;
            _lowerThresholdIndex = _bFrequencyIndex;
            _bFrequencyIndex = _aFrequencyIndex + _indexOffset;
        } else if (currentSelectedPosition == ORKTinnitusSelectedPureTonePositionB) {
            chosenFrequency = bFreq;
            _higherThresholdIndex = _aFrequencyIndex;
            _lowerThresholdIndex = _cFrequencyIndex;
            _aFrequencyIndex = _bFrequencyIndex;
            _bFrequencyIndex = _bFrequencyIndex + _indexOffset;
        } else {
            chosenFrequency = cFreq;
            _higherThresholdIndex = _bFrequencyIndex;
            _lowerThresholdIndex = 0;
            _aFrequencyIndex = _cFrequencyIndex;
            _bFrequencyIndex = _cFrequencyIndex + _indexOffset;
        }
        [self addUnitForFrequencies:@[[NSNumber numberWithDouble:aFreq],
                                      [NSNumber numberWithDouble:bFreq],
                                      [NSNumber numberWithDouble:cFreq]]
                             chosen:chosenFrequency];
    } else {
        if (currentSelectedPosition == ORKTinnitusSelectedPureTonePositionA) {
            chosenFrequency = aFreq;
            if (_lastChosenFrequency == chosenFrequency && _interactionCounter > 1) {
                if (_indexOffset == 2) {
                    // changing to 1/6
                    _indexOffset = 1;
                    _bFrequencyIndex = _aFrequencyIndex + _indexOffset;
                } else {
                    // converge
                    if (_aFrequencyIndex == _bFrequencyIndex - _indexOffset) {
                        // we tested the 1/6 up, let's test it down
                        _bFrequencyIndex = _aFrequencyIndex;
                        _aFrequencyIndex = _bFrequencyIndex - _indexOffset;
                    } else {
                        // testing confusionn
                        [self calculateIndexesWhenConverging];
                    }
                }
            } else if (_octaveConfusionIteration > 0) {
                // it's already converging continue...
                [self calculateIndexesWhenConverging];
            } else {
                if (_indexOffset == 1) {
                    [self calculateIndexesWhenConverging];
                } else {
                    _aFrequencyIndex = _aFrequencyIndex - _indexOffset;
                    _bFrequencyIndex = _aFrequencyIndex + _indexOffset;
                }
            }
        } else {
            chosenFrequency = bFreq;
            if (_lastChosenFrequency == chosenFrequency && _interactionCounter > 1) {
                if (_indexOffset == 2) {
                    // fine tuning
                    _indexOffset = 1;
                    _aFrequencyIndex = _bFrequencyIndex;
                    _bFrequencyIndex = _aFrequencyIndex + _indexOffset;
                } else {
                    // converge
                    [self calculateIndexesWhenConverging];
                }
            } else if (_octaveConfusionIteration > 0) {
                // it's already converging continue...
                [self calculateIndexesWhenConverging];
            }  else {
                if (_indexOffset == 1) {
                    [self calculateIndexesWhenConverging];
                } else {
                    _aFrequencyIndex = _bFrequencyIndex;
                    _bFrequencyIndex = _aFrequencyIndex + _indexOffset;
                }
            }
        }
        
        [self addUnitForFrequencies:@[[NSNumber numberWithDouble:aFreq],
                                      [NSNumber numberWithDouble:bFreq]]
                             chosen:chosenFrequency];
    }
    
    if (_lowerThresholdIndex != -1 && _octaveConfusionIteration == 0) {
        if (_lowerThresholdIndex > 0) {
            if (_aFrequencyIndex < _lowerThresholdIndex) {
                _lastError = ORKTinnitusErrorInconsistency;
                self.activeStepView.navigationFooterView.continueEnabled = YES;
            }
        }
        if (_higherThresholdIndex < _frequencies.count - 1) {
            if (_bFrequencyIndex > _higherThresholdIndex) {
                _lastError = ORKTinnitusErrorInconsistency;
                self.activeStepView.navigationFooterView.continueEnabled = YES;
            }
        }
        if (_aFrequencyIndex < 0 ) {
            _lastError = ORKTinnitusErrorTooLow;
            _lastChosenFrequency = chosenFrequency;
            [self finish];
        }
        if (_bFrequencyIndex > _higherThresholdIndex) {
            _lastError = ORKTinnitusErrorTooHigh;
            _lastChosenFrequency = chosenFrequency;
            [self finish];
        }
    }
    
    _lastChosenFrequency = chosenFrequency;
    _currentSelectedPosition = currentSelectedPosition;
    _interactionCounter = _interactionCounter + 1;
    
    [_tinnitusContentView resetButtons];
    [_tinnitusContentView animateButtons];
    
    self.navigationItem.title = [NSString stringWithFormat:ORKLocalizedString(@"TINNITUS_PURETONE_BAR_TITLE2", nil), _interactionCounter];
}


- (BOOL)canEnableFineTune {
    return ([_tinnitusContentView currentSelectedPosition] != ORKTinnitusSelectedPureTonePositionNone)
    && [_tinnitusContentView atLeastOneButtonIsSelected]
    && _timer == nil;
}

#pragma mark - Utilities
- (double)randomDoubleBetween:(double)smallNumber and:(double)bigNumber {
    double diff = bigNumber - smallNumber;
    return (((double) (arc4random() % ((unsigned)RAND_MAX + 1)) / RAND_MAX) * diff) + smallNumber;
}

@end
