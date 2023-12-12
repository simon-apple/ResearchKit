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
// apple-internal

#import "ORKContext.h"
#import "ORKHeadphoneDetectResult.h"
#import "ORKTinnitusAudioGenerator.h"
#import "ORKTinnitusButtonView.h"
#import "ORKTinnitusPredefinedTask.h"
#import "ORKTinnitusPureToneContentView.h"
#import "ORKTinnitusPureToneResult.h"
#import "ORKTinnitusPureToneStep.h"
#import "ORKTinnitusPureToneStepViewController.h"
#import "ORKTinnitusPureToneStepViewController_Private.h"

#import "AAPLUtils.h"

#import <MediaPlayer/MPVolumeView.h>

#import <ResearchKit/ORKHelpers_Internal.h>
#import <ResearchKitActiveTask/ORKActiveStepView.h>
#import <ResearchKitActiveTask/ORKActiveStepViewController_Internal.h>
#import <ResearchKitUI/ORKNavigationContainerView_Internal.h>
#import <ResearchKitUI/ORKStepContainerView_Private.h>
#import <ResearchKitUI/ORKStepViewController_Internal.h>
#import <ResearchKitUI/ORKTaskViewController_Internal.h>

#import "ORKCelestialSoftLink.h"

#define ORKTinnitusFadeInDuration 0.1

static const NSTimeInterval PLAY_DELAY = 1.0;
static const NSTimeInterval PLAY_DELAY_VOICEOVER = 1.3;
static const NSTimeInterval PLAY_DURATION = 1.3;
static const NSTimeInterval PLAY_DURATION_VOICEOVER = 4.0;
static const NSUInteger OCTAVE_CONFUSION_THRESHOLD_INDEX = 6;

@interface ORKTinnitusPureToneStepViewController () <ORKTinnitusPureToneContentViewDelegate> {
    int _octaveConfusionIteration;
    int _iteractionCounter;
    BOOL _isLastIteraction;
    int _sampleIndex;
    NSTimer *_timer;
    
    NSDate *_choseStepStartTime;
    MPVolumeView *_volumeView;
}

@property (nonatomic, strong) ORKTinnitusPureToneContentView *tinnitusContentView;
@property (nonatomic, strong) ORKTinnitusAudioGenerator *audioGenerator;
@property (nonatomic, assign) BOOL wasSkipped;
@property (nonatomic, assign) BOOL expired;
@property (nonatomic, assign, setter=setVolumeHUDHidden:) BOOL shouldHideVolumeHUD;

- (ORKTinnitusPureToneStep *)tinnitusPuretoneStep;
- (ORKTinnitusPredefinedTaskContext *)tinnitusPredefinedTaskContext;

@end

@implementation ORKTinnitusPureToneStepViewController

@synthesize wasSkipped;

- (instancetype)initWithStep:(ORKStep *)step {
    self = [super initWithStep:step];
    
    if (self) {
        self.suspendIfInactive = YES;
        self.wasSkipped = NO;
    }
    
    return self;
}

- (ORKTinnitusPureToneStep *)tinnitusPuretoneStep {
    return (ORKTinnitusPureToneStep *)self.step;
}

- (ORKTinnitusPredefinedTaskContext *)tinnitusPredefinedTaskContext {
    if (self.step.context && [self.step.context isKindOfClass:[ORKTinnitusPredefinedTaskContext class]]) {
        return (ORKTinnitusPredefinedTaskContext *)self.step.context;
    }
    return nil;
}

- (void)suspend:(NSNotification *)note {
    if (self.tinnitusPredefinedTaskContext != nil) {
        [self stopAutomaticPlay];
        [self.audioGenerator stop: ^{
#if defined(DEBUG)
            ORK_Log_Debug("ORKTinnitusPureToneSVC suspend: generator stopped");
#endif
        }];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [_tinnitusContentView restoreButtons];
        });
    }
}

- (void)setSkipButtonItem:(UIBarButtonItem *)skipButtonItem
{
    [skipButtonItem setTitle:AAPLLocalizedString(@"TINNITUS_PURETONE_SKIP", nil)];
    skipButtonItem.target = self;
    skipButtonItem.action = @selector(skipButtonTapped:);
    
    self.activeStepView.navigationFooterView.optional = YES;
    self.activeStepView.navigationFooterView.skipButtonItem = skipButtonItem;
    self.activeStepView.navigationFooterView.skipEnabled = NO;

    [super setSkipButtonItem:skipButtonItem];
}

- (void)setContinueButtonItem:(UIBarButtonItem *)continueButtonItem {
    continueButtonItem.target = self;
    continueButtonItem.action = @selector(continueButtonTapped:);
    
    [super setContinueButtonItem:continueButtonItem];
}

- (BOOL)getShouldHideVolumeHUD {
    return (_volumeView != nil);
}

- (void)setVolumeHUDHidden:(BOOL)hide {
    if (hide) {
        _volumeView = [[MPVolumeView alloc] initWithFrame:CGRectNull];
        [_volumeView setAlpha:0.001];
        [_volumeView setIsAccessibilityElement:NO];
        [self.view addSubview:_volumeView];
    } else {
        [_volumeView removeFromSuperview];
        _volumeView = nil;
    }
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

-(BOOL)isAutoPlaying {
    return _timer != nil;
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

- (void)skipButtonTapped:(id)sender {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:AAPLLocalizedString(@"TINNITUS_PURETONE_SKIP_ALERT_TITLE", nil)
                                                                             message:AAPLLocalizedString(@"TINNITUS_PURETONE_SKIP_ALERT_DETAIL", nil)
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *continueAction = [UIAlertAction actionWithTitle:AAPLLocalizedString(@"TINNITUS_PURETONE_SKIP_ALERT_CANCEL", nil)
                                                             style:UIAlertActionStyleDefault handler:nil];
    [alertController addAction:continueAction];
    
    [alertController addAction:[UIAlertAction actionWithTitle:AAPLLocalizedString(@"TINNITUS_PURETONE_SKIP_ALERT_SKIP", nil)
                                                        style:UIAlertActionStyleDestructive
                                                      handler:^(UIAlertAction *action) {
        self.wasSkipped = YES;
        [[self taskViewController] flipToPageWithIdentifier:ORKTinnitusMaskingSoundInstructionStepIdentifier forward:YES animated:YES];
    }]];
    
    alertController.preferredAction = continueAction;
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)continueButtonTapped:(id)sender {
    [self.navigationItem setHidesBackButton:YES];
    if (!_isLastIteraction) {
        self.shouldHideVolumeHUD = YES;
        self.activeStepView.navigationFooterView.continueEnabled = NO;
        if (self.tinnitusPredefinedTaskContext) {
            ORKTinnitusPredefinedTaskContext *context = self.tinnitusPredefinedTaskContext;
            // small delay waiting for the volume hud hide trick be effective
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.05 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [[getAVSystemControllerClass() sharedAVSystemController] setActiveCategoryVolumeTo:context.userVolume];
            });
        }
        
        [self fineTune];
    } else {
        [self finish];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = [NSString stringWithFormat:AAPLLocalizedString(@"TINNITUS_PURETONE_BAR_TITLE1", nil), self.tinnitusPuretoneStep.roundNumber];
    
    [self setNavigationFooterView];
    [self setupButtons];
    
    self.expired = NO;
    
    [self resetVariables];
    
    self.tinnitusContentView = [[ORKTinnitusPureToneContentView alloc] init];
    self.activeStepView.activeCustomView = self.tinnitusContentView;
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
}


#if !TARGET_IPHONE_SIMULATOR
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:ORKHeadphoneNotificationSuspendActivity object:nil];
}
#endif

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
            UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, AAPLLocalizedString(@"TINNITUS_TYPE_ACCESSIBILITY_ANNOUNCEMENT", nil));
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
    
    if (UIAccessibilityIsVoiceOverRunning()) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(PLAY_DELAY_VOICEOVER * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self setupAutoPlay];
        });
    } else {
        [self setupAutoPlay];
    }
    
#if !TARGET_IPHONE_SIMULATOR
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(suspend:) name:ORKHeadphoneNotificationSuspendActivity object:nil];
#endif
}

- (void)viewWillDisappear:(BOOL)animated {
    [self stopAutomaticPlay];
    [self.audioGenerator stop:^{
#if defined(DEBUG)
        ORK_Log_Debug("ORKTinnitusPureToneSVC viewWillDisappear: generator stopped.");
#endif
    }];
    
    [super viewWillDisappear:animated];
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
    self.skipButtonItem = self.internalSkipButtonItem;
    self.continueButtonItem  = self.internalContinueButtonItem;
}

#define roundIndexBypass 0
- (void)resetVariables {
    ORKTinnitusPureToneStep *tinnitusPuretoneStep = (ORKTinnitusPureToneStep *)self.step;
    _frequencies = [tinnitusPuretoneStep listOfChoosableFrequencies];
    _indexOffset = 2;
    NSUInteger round = [tinnitusPuretoneStep roundNumber] - 1 + roundIndexBypass;
    _aFrequencyIndex = ([tinnitusPuretoneStep highFrequencyIndex] * _indexOffset) + round * 2;
    _bFrequencyIndex = ([tinnitusPuretoneStep mediumFrequencyIndex] * _indexOffset) + round * 2;
    _cFrequencyIndex = ([tinnitusPuretoneStep lowFrequencyIndex] * _indexOffset) + round * 2;
    _higherThresholdIndex = -1;
    _lowerThresholdIndex = -1;
    _lastChosenFrequency = 0;
    _octaveConfusionIteration = 0;
    _iteractionCounter = 0;
    _isLastIteraction = NO;
    
    _choseStepStartTime = [NSDate date];
    
    _lastError = ORKTinnitusErrorNone;

    self.chosenUnits = [[NSMutableArray alloc] init];
}

- (void)playSoundAt:(double)frequency {
// rdar://118245036 (make sure debug check in tinnitus task is working correctly)
#if defined(DEBUG)
    ORK_Log_Debug("ORKTinnitusPureToneSVC playSoundAt:");
#endif
    [self.audioGenerator playSoundAtFrequency:frequency];
}

- (ORKStepResult *)result {
    ORKStepResult *sResult = [super result];
    NSDate *now = sResult.endDate;
    
    NSMutableArray *results = [NSMutableArray arrayWithArray:sResult.results];
    
    ORKTinnitusPureToneResult *tinnitusResult = [[ORKTinnitusPureToneResult alloc] initWithIdentifier:self.step.identifier];
    tinnitusResult.startDate = sResult.startDate;
    tinnitusResult.endDate = now;
    tinnitusResult.samples = [_chosenUnits copy];
    tinnitusResult.chosenFrequency = self.wasSkipped ? 0.0 : _lastChosenFrequency;
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
- (void)playButtonPressedWithNewPosition:(ORKTinnitusSelectedPureTonePosition)newPosition previousPosition:(ORKTinnitusSelectedPureTonePosition)previousPosition {
    ORKTinnitusButtonView *currentSelectedButtonView = _tinnitusContentView.currentSelectedButtonView;
    BOOL isSimulatedTap = [currentSelectedButtonView isSimulatedTap];
    BOOL isUserTap = !isSimulatedTap;
    BOOL isCurrentAutomaticStageButtonSelected = _tinnitusContentView.isCurrentAutoStageButtonSelected;
    BOOL isSelectedPositionTheSameAsPrevious = newPosition == previousPosition;
    BOOL autoPlayIsStoped = _timer == nil;

    if (isUserTap) {
        if ([self isAutoPlaying]) {
            [self stopAutomaticPlay];
        }
    }
    
    void (^playNext)(void) = ^{
        NSUInteger frequencyIndex = _aFrequencyIndex;
        if (newPosition == ORKTinnitusSelectedPureTonePositionB) {
            frequencyIndex = _bFrequencyIndex;
        } else if (newPosition == ORKTinnitusSelectedPureTonePositionC) {
            frequencyIndex = _cFrequencyIndex;
        }

        if (isCurrentAutomaticStageButtonSelected && autoPlayIsStoped && isSimulatedTap) {
            [_tinnitusContentView restoreButtons];
        } else {
            [self playSoundAt:[_frequencies[frequencyIndex] doubleValue]];
        }
        
        self.activeStepView.navigationFooterView.continueEnabled = [self canEnableFineTune];
        self.activeStepView.navigationFooterView.skipEnabled = [self canEnableFineTune];
    };

    if (self.audioGenerator.isPlaying) {
        BOOL userTappedToStop = isUserTap && isSelectedPositionTheSameAsPrevious;
        
        [self.audioGenerator stop:^{
            if (!userTappedToStop) {
                playNext();
            }
        }];
    } else {
        playNext();
    }
}

- (void)animationFinishedForStage:(PureToneButtonsStage)stage {
    self.shouldHideVolumeHUD = NO;
    if (UIAccessibilityIsVoiceOverRunning()) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)((PLAY_DELAY - 0.05) * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, _tinnitusContentView);
        });
    }
    [self performSelector:@selector(startAutomaticPlay) withObject:nil afterDelay:PLAY_DELAY];
}

- (void)fineTune {
    [_audioGenerator stop: ^{
#if defined(DEBUG)
        ORK_Log_Debug("ORKTinnitusPureToneSVC fineTune generator stopped");
#endif
    }];
    ORKTinnitusSelectedPureTonePosition currentSelectedPosition = [_tinnitusContentView currentSelectedPosition];
    
    [self getFrequencyAndCalculateIndexesFor:currentSelectedPosition];
    
    if (![_lastError isEqualToString:ORKTinnitusErrorNone] || _octaveConfusionIteration == 3) {
        [self finish];
    } else {
        [_tinnitusContentView resetButtons];
        [_tinnitusContentView animateButtons];

        self.navigationItem.title = [NSString stringWithFormat:AAPLLocalizedString(@"TINNITUS_PURETONE_BAR_TITLE2", nil), _iteractionCounter];
    }
    self.activeStepView.navigationFooterView.continueEnabled = [self canEnableFineTune];
    self.activeStepView.navigationFooterView.skipEnabled = [self canEnableFineTune];    
}

- (void)getFrequencyAndCalculateIndexesFor:(ORKTinnitusSelectedPureTonePosition)position {
    double aFreq = [_frequencies[_aFrequencyIndex] doubleValue];
    double bFreq = [_frequencies[_bFrequencyIndex] doubleValue];
    double cFreq = -1;
    if (_cFrequencyIndex >= 0) {
        cFreq = [_frequencies[_cFrequencyIndex] doubleValue];
    }
    double chosenFrequency;
    
    if (_bFrequencyIndex <= 0 && _lowerThresholdIndex == 0 && position == ORKTinnitusSelectedPureTonePositionB) {
        _lastError = ORKTinnitusErrorTooLow;
    }
    
    if (_aFrequencyIndex >= _frequencies.count - 1 && _higherThresholdIndex == _frequencies.count - 1 && position == ORKTinnitusSelectedPureTonePositionA) {
        _lastError = ORKTinnitusErrorTooHigh;
    }
    
    if (cFreq >= 0) {
        // first step, we have no idea of the frequency match yet, so we offer frequencies values that are far from each other
        if (position == ORKTinnitusSelectedPureTonePositionA) {
            chosenFrequency = aFreq;
            _higherThresholdIndex = _frequencies.count - 1;
            _lowerThresholdIndex = _bFrequencyIndex;
            _bFrequencyIndex = _aFrequencyIndex;
            _aFrequencyIndex = _aFrequencyIndex + _indexOffset;
        } else if (position == ORKTinnitusSelectedPureTonePositionB) {
            chosenFrequency = bFreq;
            _higherThresholdIndex = _aFrequencyIndex;
            _lowerThresholdIndex = _cFrequencyIndex;
            _aFrequencyIndex = _bFrequencyIndex + _indexOffset;
        } else {
            chosenFrequency = cFreq;
            _higherThresholdIndex = _bFrequencyIndex;
            _lowerThresholdIndex = 0;
            _bFrequencyIndex = _cFrequencyIndex;
            _aFrequencyIndex = _cFrequencyIndex + _indexOffset;
        }
        [self addUnitForFrequencies:@[[NSNumber numberWithDouble:aFreq],
                                      [NSNumber numberWithDouble:bFreq],
                                      [NSNumber numberWithDouble:cFreq]]
                             chosen:chosenFrequency];
        _cFrequencyIndex = -1;
    } else {
        if (position == ORKTinnitusSelectedPureTonePositionA) {
            chosenFrequency = aFreq;
            if (_lastChosenFrequency == chosenFrequency && _iteractionCounter > 1) {
                if (_indexOffset == 2) {
                    // changing to 1/6
                    _indexOffset = 1;
                    _bFrequencyIndex = _aFrequencyIndex;
                    _aFrequencyIndex = _aFrequencyIndex + _indexOffset;
                } else {
                    [self calculateIndexesWhenConvergingForPosition:position];
                }
            } else if (_octaveConfusionIteration > 0) {
                // it's already converging continue...
                [self calculateIndexesWhenConvergingForPosition:position];
            } else {
                if (_indexOffset == 1) {
                    [self calculateIndexesWhenConvergingForPosition:position];
                } else {
                    _bFrequencyIndex = _aFrequencyIndex;
                    _aFrequencyIndex = _bFrequencyIndex + _indexOffset;
                }
            }
        } else {
            chosenFrequency = bFreq;
            if (_lastChosenFrequency == chosenFrequency && _iteractionCounter > 1) {
                if (_indexOffset == 2) {
                    // start fine tuning up
                    _indexOffset = 1;
                    _aFrequencyIndex = _bFrequencyIndex + _indexOffset;
                } else {
                    // See if we can fine tune down
                    if (_octaveConfusionIteration > 0) {
                        // was converging
                        [self calculateIndexesWhenConvergingForPosition:position];
                    } else if (_bFrequencyIndex - _indexOffset > _lowerThresholdIndex) {
                        _aFrequencyIndex = _bFrequencyIndex;
                        _bFrequencyIndex = _aFrequencyIndex - _indexOffset;
                    }
                }
            } else if (_octaveConfusionIteration > 0) {
                // it's already converging continue...
                [self calculateIndexesWhenConvergingForPosition:position];
            }  else {
                if (_indexOffset == 1) {
                    [self calculateIndexesWhenConvergingForPosition:position];
                } else {
                    _aFrequencyIndex = _bFrequencyIndex;
                    _bFrequencyIndex = _aFrequencyIndex - _indexOffset;
                }
            }
        }
        
        [self addUnitForFrequencies:@[[NSNumber numberWithDouble:aFreq],
                                      [NSNumber numberWithDouble:bFreq]]
                             chosen:chosenFrequency];
    }
    
    if (_lowerThresholdIndex != -1 && _bFrequencyIndex < _lowerThresholdIndex) {
        // we have a defined the thresholds and the user goes down too much
        if (_octaveConfusionIteration == 0 && [_lastError isEqualToString:ORKTinnitusErrorNone]) {
            // we are not testing convergence
            _lastError = ORKTinnitusErrorInconsistency;
        } else if (_bFrequencyIndex < 0){
            // no error but can't go to octave down
            _octaveConfusionIteration = 3;
        }
    }
    
    
    
    if (_lowerThresholdIndex != -1 && _aFrequencyIndex > _higherThresholdIndex) {
        // we have a defined the thresholds and the user goes up too much
        if (_octaveConfusionIteration == 0 && [_lastError isEqualToString:ORKTinnitusErrorNone]) {
            // we are not testing convergence
            _lastError = ORKTinnitusErrorInconsistency;
        } else if (_aFrequencyIndex > _frequencies.count -1){
            // no error but can't go to octave up
            _octaveConfusionIteration = 3;
        }
    }
    
    _lastChosenFrequency = chosenFrequency;
    _iteractionCounter = _iteractionCounter + 1;
}

- (void)calculateIndexesWhenConvergingForPosition:(ORKTinnitusSelectedPureTonePosition)position {
    double chosenFrequency;
    
    if (position == ORKTinnitusSelectedPureTonePositionA) {
        chosenFrequency = [_frequencies[_aFrequencyIndex] doubleValue];
    } else {
        chosenFrequency = [_frequencies[_bFrequencyIndex] doubleValue];
    }
    
    switch (_octaveConfusionIteration) {
        case 0:
            // first test
            if (_aFrequencyIndex < _frequencies.count - OCTAVE_CONFUSION_THRESHOLD_INDEX) {
                // We can test one octave up
                if (position == ORKTinnitusSelectedPureTonePositionA) {
                    _bFrequencyIndex = _aFrequencyIndex;
                }
                _aFrequencyIndex = _bFrequencyIndex + OCTAVE_CONFUSION_THRESHOLD_INDEX;
            } else {
                // Can't test one octave up but we can test one octave down
                if (position == ORKTinnitusSelectedPureTonePositionB) {
                    _aFrequencyIndex = _bFrequencyIndex;
                }
                _bFrequencyIndex = _aFrequencyIndex - OCTAVE_CONFUSION_THRESHOLD_INDEX;
                _octaveConfusionIteration = _octaveConfusionIteration + 1; // bypassing case 1
                _isLastIteraction = YES;
            }
            _octaveConfusionIteration = _octaveConfusionIteration + 1;
            break;
        case 1:
            // second test (only if we could test one octave up)
            if (_lastChosenFrequency != chosenFrequency) {
                // user is confused the test ends
                if (chosenFrequency < [_frequencies[_higherThresholdIndex] doubleValue]) {
                    _lastError = ORKTinnitusErrorInconsistency;
                } else {
                    _lastError = ORKTinnitusErrorTooHigh;
                }
                _lastChosenFrequency = chosenFrequency;
            } else {
                // Let's try one octave down if possible
                if (_bFrequencyIndex - OCTAVE_CONFUSION_THRESHOLD_INDEX < 0) {
                    // we can't go down and is the same frequency as before
                    _lastChosenFrequency = chosenFrequency;
                    _octaveConfusionIteration = _octaveConfusionIteration + 1;
                } else {
                    _aFrequencyIndex = _bFrequencyIndex;
                    _bFrequencyIndex = _aFrequencyIndex - OCTAVE_CONFUSION_THRESHOLD_INDEX;
                }
            }
            _octaveConfusionIteration = _octaveConfusionIteration + 1;
            break;
        case 2:
            _lastChosenFrequency = chosenFrequency;
            _octaveConfusionIteration = _octaveConfusionIteration + 1;
            break;
    }
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
