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

#import "ORKdBHLFitTestStepViewController.h"
#import "ORKdBHLFitTestStep.h"
#import "ORKdBHLFitTestStepContentView.h"
#import "ORKdBHLFitTestResult.h"

#import "ORKActiveStepView.h"
#import "ORKActiveStep_Internal.h"
#import "ORKStepHeaderView_Internal.h"
#import "ORKNavigationContainerView.h"
#import "ORKStepContainerView.h"

#import "ORKStepContainerView_Private.h"
#import "ORKStepContentView_Private.h"
#import "ORKStepView_Private.h"

#import "ORKActiveStepViewController_Internal.h"
#import "ORKStepViewController_Internal.h"

#import "ORKCollectionResult_Private.h"

#import "ORKHelpers_Internal.h"
#import "ORKTaskViewController_Private.h"
#import "ORKTaskViewController_Internal.h"
#import "ORKOrderedTask.h"

#import "ORKCelestialSoftLink.h"
#import "ORKAVFoundationSoftLink.h"
#import "ORKBluetoothManagerSoftLink.h"

#import <AVFAudio/AVFAudio.h>
#import <MediaPlayer/MPVolumeView.h>

#import <ResearchKit/ResearchKit-Swift.h>
#import "ORKNavigationContainerView_Internal.h"

#import "ORKHelpers_Internal.h"

#if !USE_LEGACY_TONEPLAYER
#import "ORKCelestialSoftLink.h"
#import "ORKAVFoundationSoftLink.h"
#import "ORKBluetoothManagerSoftLink.h"
#import <MediaPlayer/MediaPlayer.h>
#include <MediaExperience/AVAudioCategories.h>
#endif

#define FIT_TEST_MIN_VOLUME            0.50f

typedef NS_ENUM(NSUInteger, ORKdBHLFitTestStage) {
    ORKdBHLFitTestStageNotInEars,
    ORKdBHLFitTestStageEnableHearingTestMode,
    ORKdBHLFitTestStageStart,
    ORKdBHLFitTestStagePlaying,
    ORKdBHLFitTestStageResultConfidenceLow,
    ORKdBHLFitTestStageResultLeftSealGoodRightSealBad,
    ORKdBHLFitTestStageResultLeftSealBadRightSealGood,
    ORKdBHLFitTestStageResultLeftSealBadRightSealBad,
    ORKdBHLFitTestStageResultLeftSealGoodRightSealGood,
    ORKdBHLFitTestStageResultTriesExceeded,
};

@interface ORKdBHLFitTestStepViewController () <AVAudioPlayerDelegate> {
    bool _testActive;

    bool _darkMode;
    bool _volumeModified;
    float _initialVolume;
    
    AVAudioPlayer *_player;
    
    ORKdBHLFitTestStage _stage;
    
    NSMutableArray <ORKdBHLFitTestResultSample *> *_fitTestResultSamples;
    
    NSInteger _triesCounter;
}

@property (nonatomic, strong) ORKdBHLFitTestStepContentView* fitTestContentView;

@end

@implementation ORKdBHLFitTestStepViewController

- (ORKdBHLFitTestStep *)fitTestStep {
    return (ORKdBHLFitTestStep *)self.step;
}

- (instancetype)initWithStep:(ORKStep *)step {
    self = [super initWithStep:step];
    
    if (self) {
        self.suspendIfInactive = YES;
        _fitTestResultSamples = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _triesCounter = 0;

    [self configureStep];
    
    [self addObservers];
}

- (void)configureStep {
    self.fitTestContentView = [[ORKdBHLFitTestStepContentView alloc] init];
    [self.view addSubview:self.fitTestContentView];
    self.fitTestContentView.translatesAutoresizingMaskIntoConstraints = false;
    
    NSMutableArray *constraints = [NSMutableArray new];
    [constraints addObject:[self.fitTestContentView.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor]];
    [constraints addObject:[self.fitTestContentView.widthAnchor constraintEqualToAnchor:self.view.widthAnchor]];
    [constraints addObject:[self.fitTestContentView.heightAnchor constraintEqualToConstant:400]];
    [constraints addObject:[self.fitTestContentView.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor constant:30]];
    
    [NSLayoutConstraint activateConstraints:constraints];
    
    self.activeStepView.stepHeaderTextAlignment = NSTextAlignmentCenter;

    _testActive = FALSE;
    _initialVolume = 0.0;
    _volumeModified = false;

    bool success = [[getAVSystemControllerClass() sharedAVSystemController] getVolume:&_initialVolume forCategory:(NSString *)CFSTR("Audio/Video")];
    if (!success) {
        ORK_Log_Error("Unable to fetch volume before test");
    }
    ORK_Log_Info("Volume before fit test : %0.9f", _initialVolume);
    
    [self setNavigationFooterView];
    [self headphonesStatusChanged:nil];
//        if (self.taskViewController.hearingModeStatus != ORKdBHLHeadphonesStatusHearingTestEnabled) {
//            // If the HTMode is not enabled, enable it.
//            [self setStage:ORKdBHLFitTestStageEnableHearingTestMode];
//        } else {
//            [self setStage:ORKdBHLFitTestStageStart];
//        }
}

// helper function
- (void)printCurrentStage {
    switch (_stage) {
        case ORKdBHLFitTestStageNotInEars:
            ORK_Log_Info("Current Stage = ORKdBHLFitTestStageNotInEars");
            break;
        case ORKdBHLFitTestStageStart:
            ORK_Log_Info("Current Stage = ORKdBHLFitTestStageStart");
            break;
        case ORKdBHLFitTestStagePlaying:
            ORK_Log_Info("Current Stage = ORKdBHLFitTestStagePlaying");
            break;
        case ORKdBHLFitTestStageResultConfidenceLow:
            ORK_Log_Info("Current Stage = ORKdBHLFitTestStageResultConfidenceLow");
            break;
        case ORKdBHLFitTestStageResultTriesExceeded:
            ORK_Log_Info("Current Stage = ORKdBHLFitTestStageResultTriesExceeded");
            break;
        case ORKdBHLFitTestStageEnableHearingTestMode:
            ORK_Log_Info("Current Stage = ORKdBHLFitTestStageEnableHearingTestMode");
            break;
        case ORKdBHLFitTestStageResultLeftSealBadRightSealBad:
            ORK_Log_Info("Current Stage = ORKdBHLFitTestStageResultLeftSealBadRightSealBad");
            break;
        case ORKdBHLFitTestStageResultLeftSealBadRightSealGood:
            ORK_Log_Info("Current Stage = ORKdBHLFitTestStageResultLeftSealBadRightSealGood");
            break;
        case ORKdBHLFitTestStageResultLeftSealGoodRightSealBad:
            ORK_Log_Info("Current Stage = ORKdBHLFitTestStageResultLeftSealGoodRightSealBad");
            break;
        case ORKdBHLFitTestStageResultLeftSealGoodRightSealGood:
            ORK_Log_Info("Current Stage = ORKdBHLFitTestStageResultLeftSealGoodRightSealGood");
            break;
        default:
            break;
    }
}

- (void)adjustNavigationButtons {
    ORKWeakTypeOf(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        ORKStrongTypeOf(self) strongSelf = weakSelf;
        ORKTaskViewController *taskVC = strongSelf.taskViewController;
        BOOL budsInEars = taskVC.headphonesInEars;
        BOOL hearingModeEnabled = taskVC.hearingModeStatus == ORKdBHLHeadphonesStatusHearingTestEnabled;
        BOOL continueEnabled = YES;
        if (_stage == ORKdBHLFitTestStageEnableHearingTestMode || _stage == ORKdBHLFitTestStagePlaying) {
            continueEnabled = NO;
        }
        [strongSelf setContinueButtonTitle: _stage!= ORKdBHLFitTestStageResultLeftSealGoodRightSealGood ? ORKLocalizedString(@"PLAY", nil) : ORKLocalizedString(@"NEXT", nil)];
        [strongSelf.activeStepView.navigationFooterView showActivityIndicator:(!hearingModeEnabled || !budsInEars || !continueEnabled)];
        strongSelf.activeStepView.navigationFooterView.continueEnabled = (hearingModeEnabled && budsInEars && continueEnabled);
        strongSelf.activeStepView.navigationFooterView.optional = _fitTestResultSamples.count > 0 && _stage != ORKdBHLFitTestStageResultLeftSealGoodRightSealGood;
        [strongSelf.activeStepView.navigationFooterView updateContinueAndSkipEnabled];
    });
}

- (void)setTitleAndDetailForStage:(ORKdBHLFitTestStage)stage {
    switch (stage) {
        case ORKdBHLFitTestStageNotInEars: {
            self.activeStepView.stepTitle = @"Fit Test";
            self.activeStepView.stepDetailText = @"Please check that both headphones are in the ears.";
            break;
        }
        case ORKdBHLFitTestStageEnableHearingTestMode: {
            self.activeStepView.stepTitle = @"Fit Test";
            self.activeStepView.stepDetailText = @"Please wait while we are preparing your study headphones for the test.";
            break;
        }
        case ORKdBHLFitTestStageStart: {
            self.activeStepView.stepTitle = @"Ear Tip Fit Test";
            self.activeStepView.stepDetailText = @"Make sure headphones in both ears are comfortable and secure, then press play to test fit.";
            break;
        }
        case ORKdBHLFitTestStagePlaying: {
            self.activeStepView.stepTitle = @"Do not remove headphones until you see the fit test results";
            self.activeStepView.stepDetailText = @"";
            break;
        }
        case ORKdBHLFitTestStageResultConfidenceLow: {
            self.activeStepView.stepTitle = @"Unable to Complete Ear Tip Fit Test";
            self.activeStepView.stepDetailText = @"Make sure to find a quiet location and remain still during ear tip fit test.";
            break;
        }
        case ORKdBHLFitTestStageResultLeftSealBadRightSealBad: {
            self.activeStepView.stepTitle = @"Ear Fit Test Results";
            self.activeStepView.stepDetailText = @"Adjust both headphones in your ears, or try another ear tip size and run the test again.\n\nYou should use the ear tips that are most comfortable in each ear.";
            break;
        }
        case ORKdBHLFitTestStageResultLeftSealGoodRightSealBad: {
            self.activeStepView.stepTitle = @"Ear Fit Test Results";
            self.activeStepView.stepDetailText = @"Try adjusting the right headphone in your ear, or change the ear tip size and try the test again.\n\nYou should use the ear tip that is most comfortable in each ear.";
            break;
        }
        case ORKdBHLFitTestStageResultLeftSealBadRightSealGood: {
            self.activeStepView.stepTitle = @"Ear Fit Test Results";
            self.activeStepView.stepDetailText = @"Try adjusting the left headphone in your ear, or change the ear tip size and try the test again.\n\nYou should use the ear tip that is most comfortable in each ear.";
            break;
        }
        case ORKdBHLFitTestStageResultLeftSealGoodRightSealGood: {
            self.activeStepView.stepTitle = @"Ear Fit Test Results";
            self.activeStepView.stepDetailText = @"The ear tips you’re using are a good fit for both ears.";
            break;
        }
        case ORKdBHLFitTestStageResultTriesExceeded: {
            self.activeStepView.stepTitle = @"Unable to Complete Ear Tip Fit Test";
            break;
        }
        default:
            break;
    }
    [self adjustTriesCounterLabel];
}

- (void)adjustTriesCounterLabel {
    [self.fitTestContentView setResultDetailLabelText:_triesCounter > 0 ? [NSString stringWithFormat:@"Try %li",_triesCounter] : @""];
}

- (void)setStage:(ORKdBHLFitTestStage)stage {
    switch (stage) {
        case ORKdBHLFitTestStageNotInEars: {
            [self setTitleAndDetailForStage:stage];
            break;
        }
        case ORKdBHLFitTestStageEnableHearingTestMode: {
            [self setTitleAndDetailForStage:stage];
            ORK_Log_Info("FitTest Enabling Hearing Test Mode");
            ORKWeakTypeOf(self) weakSelf = self;
            [self.taskViewController enableHearingTestModeWithCompletion:^(BOOL hearingModeEnabled) {
                ORK_Log_Info("Hearing Mode Enabled %@", hearingModeEnabled ?@"YES":@"NO");
                dispatch_async(dispatch_get_main_queue(), ^{
                    ORKStrongTypeOf(weakSelf) strongSelf = weakSelf;
                    if (hearingModeEnabled) {
                        [strongSelf setStage:ORKdBHLFitTestStageStart];
                        strongSelf.activeStepView.navigationFooterView.optional = (hearingModeEnabled && _fitTestResultSamples.count > 0);
                    } else {
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                            [strongSelf setStage:ORKdBHLFitTestStageEnableHearingTestMode];
                        });
                    }
                });
            }];
            break;
        }
        case ORKdBHLFitTestStageStart: {
            [self setTitleAndDetailForStage:stage];
            ORK_Log_Info("FitTest Start");
            break;
        }
        case ORKdBHLFitTestStagePlaying: {
            [self setTitleAndDetailForStage:stage];
            ORK_Log_Info("FitTest Playing");
            break;
        }
        case ORKdBHLFitTestStageResultConfidenceLow: {
            [self.fitTestContentView setWithLeftOk:NO rightOk:NO];
            [self setTitleAndDetailForStage:stage];
            ORK_Log_Info("FitTest Confidence Low");
            break;
        }
        case ORKdBHLFitTestStageResultLeftSealBadRightSealBad: {
            [self.fitTestContentView setWithLeftOk:NO rightOk:NO];
            [self setTitleAndDetailForStage:stage];
            ORK_Log_Info("FitTest Two Bad Seals");
            break;
        }
        case ORKdBHLFitTestStageResultLeftSealGoodRightSealBad: {
            [self.fitTestContentView setWithLeftOk:YES rightOk:NO];
            [self setTitleAndDetailForStage:stage];
            ORK_Log_Info("FitTest Right Seal Bad");
            break;
        }
        case ORKdBHLFitTestStageResultLeftSealBadRightSealGood: {
            [self.fitTestContentView setWithLeftOk:NO rightOk:YES];
            [self setTitleAndDetailForStage:stage];
            ORK_Log_Info("FitTest Left Seal Bad");
            break;
        }
        case ORKdBHLFitTestStageResultLeftSealGoodRightSealGood: {
            [self.fitTestContentView setWithLeftOk:YES rightOk:YES];
            [self setTitleAndDetailForStage:stage];

            ORK_Log_Info("FitTest Two Good Seals");
            break;
        }
        case ORKdBHLFitTestStageResultTriesExceeded: {
            // Again not used ;)
            self.activeStepView.stepTitle = @"Unable to Complete Ear Tip Fit Test";
            [self.activeStepView.navigationFooterView showActivityIndicator:NO];
        }
        default:
            break;
    }
    _stage = stage;
    [self adjustNavigationButtons];
}

- (void)setNavigationFooterView {
    self.activeStepView.navigationFooterView.continueButtonItem = self.continueButtonItem;
    UIBarButtonItem *skipButton = [[UIBarButtonItem alloc] initWithTitle:@"Skip Fit Test" style:UIBarButtonItemStylePlain target:self action:@selector(endHearingTest:)];
    self.activeStepView.navigationFooterView.skipButtonItem = skipButton;
    
    [self.activeStepView.navigationFooterView setSkipButtonColor:[UIColor blackColor]];
    
    //self.activeStepView.navigationFooterView.optional = NO;
   // [self.activeStepView.navigationFooterView showActivityIndicator:NO];
   // [self.activeStepView.navigationFooterView updateContinueAndSkipEnabled];

    //[self setContinueButtonTitle:ORKLocalizedString(@"PLAY", nil)];
    
    [self.activeStepView.navigationFooterView.continueButton removeTarget:self.activeStepView.navigationFooterView action:nil forControlEvents:UIControlEventTouchUpInside];
    [self.activeStepView.navigationFooterView.continueButton addTarget:self action:@selector(continueButtonAction:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)endHearingTest:(id)sender {
    ORK_Log_Info("Skip Hearing Test");
    [self finish];
}

- (void)continueButtonAction:(id)sender {
    ORKTaskViewController *taskVC = [self taskViewController];
    switch (_stage) {
        case ORKdBHLFitTestStageStart:
        case ORKdBHLFitTestStageResultLeftSealBadRightSealBad:
        case ORKdBHLFitTestStageResultLeftSealBadRightSealGood:
        case ORKdBHLFitTestStageResultConfidenceLow:
        case ORKdBHLFitTestStageResultLeftSealGoodRightSealBad: {
            if ([taskVC headphonesInEars] && ![taskVC callActive] && [taskVC currentDevice]) {
                [self.fitTestContentView setStart];
                [self setStage:ORKdBHLFitTestStagePlaying];
                [self startFitTest];
            } else {
                [self showHeadphonesOrCallAlert];
            }
            break;
        }
            
        case ORKdBHLFitTestStageResultLeftSealGoodRightSealGood:
        case ORKdBHLFitTestStageResultTriesExceeded: {
            [self finish];
            break;
        }
        default:
            break;
    }
}

- (void)stepDidFinish {
    [super stepDidFinish];

    [self goForward];
}

-(void)addObservers {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(handleAudioSessionInterruption:) name:AVAudioSessionInterruptionNotification object:[AVAudioSession sharedInstance]];
    [center addObserver:self selector:@selector(handleMediaServerConnectionDied:) name:@"AVSystemController_ServerConnectionDiedNotification" object:[AVAudioSession sharedInstance]];
    [center addObserver:self selector:@selector(headphonesStatusChanged:) name:ORKdBHLHeadphonesInEarsNotification object:nil];
    [center addObserver:self selector:@selector(sealValueChanged:) name:ORKdBHLBluetoothSealValueChangedNotification object:nil];
}

- (void)showHeadphonesOrCallAlert {
    ORK_Log_Info("headphones InEar: %d, callActive: %d", self.taskViewController.headphonesInEars, self.taskViewController.callActive);
    NSString *alertTitle = self.taskViewController.callActive ? @"End Call To Continue Test." : @"Please check that both headphones are in the ears.";
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:alertTitle message:@"" preferredStyle:UIAlertControllerStyleAlert];

    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
    
    ORKWeakTypeOf(self) weakSelf = self;
    [self presentViewController:alert animated:YES completion:^{
        ORKStrongTypeOf(self) strongSelf = weakSelf;
        // The best flow is disable the hearing test mode after the alert is shown
        [strongSelf.taskViewController disableHearingTestMode];
        [strongSelf adjustNavigationButtons];
    }];
}

- (void)startFitTest {
    ORK_Log_Info("Start Fit Test");
    _triesCounter ++;
#if USE_LEGACY_TONEPLAYER
    [[self taskViewController] lockDeviceVolume:FIT_TEST_MIN_VOLUME];
#endif
    [self.taskViewController.currentDevice SendSetupCommand:BT_ACCESSORY_SETUP_SEAL_OP_START];

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
#if !USE_LEGACY_TONEPLAYER
        float currentVolume = 0.0f;
        bool success = [[getAVSystemControllerClass() sharedAVSystemController] getVolume:&currentVolume forCategory:@"Audio/Video"];
        if (!success) {
            ORK_Log_Error("Fit Test: Unable to fetch current volume");
        } else {
            ORK_Log_Error("Fit Test: Current volume : %f", currentVolume);
            if (currentVolume != FIT_TEST_MIN_VOLUME) {
                ORK_Log_Info("Fit Test: Increase volume for AudioVideo for fit test");
                [[getAVSystemControllerClass() sharedAVSystemController] setVolumeTo:FIT_TEST_MIN_VOLUME forCategory:@"Audio/Video"];
                _volumeModified = TRUE;
            }
        }
#endif
        NSString *mediaPath = [[NSBundle bundleForClass:[self class]] pathForResource:@"E+D-US_ML" ofType:@"wav"];
        NSURL *soundFileURL = [NSURL fileURLWithPath:mediaPath];
        NSError *error = nil;

        [[AVAudioSession sharedInstance] setActive:YES error:&error];
        if (error) {
            ORK_Log_Error("Unable to activate AVAudioSession : %@", error);
        }
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:&error];

        if (error != nil) {
            ORK_Log_Error("Couldn't set session's audio category %@", error);
            error = nil;
        } else {
            _player = [[AVAudioPlayer alloc] initWithContentsOfURL:soundFileURL error:&error];
            _player.delegate = self;
            _player.numberOfLoops = 2;
            [_player prepareToPlay];
            [_player play];
        }
        _testActive = TRUE;
    });
}

#pragma mark Helpers

- (void)resetVolume {
    if (_volumeModified && _initialVolume <= FIT_TEST_MIN_VOLUME) {
        ORK_Log_Info("Cleanup audio. Set audioVideo volume to: %f", _initialVolume);
        [[getAVSystemControllerClass() sharedAVSystemController] setVolumeTo:_initialVolume forCategory:(NSString *)CFSTR("Audio/Video")];
        _volumeModified = FALSE;
    }
}

- (void)cleanupAudio {
    ORK_Log_Info("Clean up fit test audio");
    [_player setVolume:0.0 fadeDuration:1.0];
    NSError *error;
    [[AVAudioSession sharedInstance] setActive:NO withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:&error];
    if (error) {
        ORK_Log_Error("Failed to deactivate AVAudioSession with AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation : %@", error);
    }
}

- (void)fitTestStopped {
    _testActive = FALSE;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self cleanupAudio];
    });
    if (_stage != ORKdBHLFitTestStageResultLeftSealGoodRightSealGood) {
        [self setStage:ORKdBHLFitTestStageStart];
    } else {
        self.activeStepView.stepTitle = @"";
    }
#if USE_LEGACY_TONEPLAYER
        ORKWeakTypeOf(self) weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            ORKStrongTypeOf(self) strongSelf = weakSelf;
            [[strongSelf taskViewController] restoreSavedVolume];
        });
#endif
}

- (float)getSealThreshold {
    return [[self fitTestStep] sealThreshold];
}

- (float)getConfidenceThreshold {
    return [[self fitTestStep] confidenceThreshold];
}

- (void)headphonesStatusChanged: (NSNotification *)note {
    // check if headphones are in ears
    ORKTaskViewController *taskVC = self.taskViewController;
    if (!taskVC.headphonesInEars) {
        _fitTestResultSamples = [[NSMutableArray alloc] init];
        [self interruptTestIfNecessary];
    } else {
        [self setStage:ORKdBHLFitTestStageEnableHearingTestMode];
    }
}

- (void)interruptTestIfNecessary {
    [self.fitTestContentView setStart];
    [self setStage:ORKdBHLFitTestStageNotInEars];
    if (_testActive) {
        [self fitTestStopped];
        [self showHeadphonesOrCallAlert];
    }
}

- (void)sealValueChanged: (NSNotification *)note {
    if (!_testActive) {
        ORK_Log_Error("Discard results since test is not active");
        return;
    }

    NSDictionary *object = [[note object] object];
    NSNumber *left = object[@"sealLeft"];
    NSNumber *right = object[@"sealRight"];
    float sealValL = [left floatValue];
    float sealValR = [right floatValue];
    ORK_Log_Info("leftSeal : %0.06f", sealValL);
    ORK_Log_Info("rightSeal : %0.06f", sealValR);
    NSNumber *confidenceL = object[@"confidenceLeft"];
    NSNumber *confidenceR = object[@"confidenceRight"];
    float confidenceValL = [confidenceL floatValue];
    float confidenceValR = [confidenceR floatValue];
    ORK_Log_Info("confidenceL : %0.06f", confidenceValL);
    ORK_Log_Info("confidenceR : %0.06f", confidenceValR);
    float sealThreshold = [self getSealThreshold];
    ORK_Log_Info("sealThreshold : %0.06f", sealThreshold);
    bool leftSealGood = sealValL >= sealThreshold;
    bool rightSealGood = sealValR >= sealThreshold;

    _darkMode = (self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark);
    if (_darkMode) {
        [self.fitTestContentView resetLabelsBackgroundColors];
    }

    [self fitTestStopped];
    
    float confidence = [self getConfidenceThreshold];
    ORK_Log_Info("confidenceThreshold : %0.06f", confidence);
    bool confidenceLow = (confidenceValL < confidence || confidenceValR < confidence);
    if (confidenceLow) {
        ORK_Log_Info("Confidence values too low.");
        [self setStage:ORKdBHLFitTestStageResultConfidenceLow];
    } else {
        if (leftSealGood && rightSealGood) {
            [self setStage:ORKdBHLFitTestStageResultLeftSealGoodRightSealGood];
        } else if (!leftSealGood && !rightSealGood) {
            [self setStage:ORKdBHLFitTestStageResultLeftSealBadRightSealBad];
        } else if (leftSealGood && !rightSealGood) {
            [self setStage:ORKdBHLFitTestStageResultLeftSealGoodRightSealBad];
        } else if (!leftSealGood && rightSealGood) {
            [self setStage:ORKdBHLFitTestStageResultLeftSealBadRightSealGood];
        } else {
            ORK_Log_Info("leftSealGood: %d, rightSealGood: %d",leftSealGood,rightSealGood);
        }
    }
    
    ORKdBHLFitTestResultSample *fitTestResultSample = [[ORKdBHLFitTestResultSample alloc] init];
    fitTestResultSample.sealLeftEar = left ? sealValL : 0.0;
    fitTestResultSample.sealRightEar = right ? sealValR : 0.0;
    fitTestResultSample.confidenceLeftEar = confidenceL ? confidenceValL : 0.0;
    fitTestResultSample.confidenceRightEar = confidenceR ? confidenceValR : 0.0;
    fitTestResultSample.sealThreshold = sealThreshold;
    fitTestResultSample.confidenceThreshold = confidence;
    fitTestResultSample.leftSealSuccess = leftSealGood;
    fitTestResultSample.rightSealSuccess = rightSealGood;
    fitTestResultSample.lowConfidence = confidenceLow;
    [_fitTestResultSamples addObject:fitTestResultSample];
}

- (void)dismissFitTest {
    [self cleanupAudio];
    [self setStage:ORKdBHLFitTestStageStart];
}

// AVAudioSession interruption
- (void)handleAudioSessionInterruption:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    AVAudioSessionInterruptionType type = [[userInfo objectForKey:AVAudioSessionInterruptionTypeKey] unsignedIntegerValue];

    if(type == AVAudioSessionInterruptionTypeBegan) {
        ORK_Log_Error("Audio session interrupted. Reset Fit Test (Active: %d)",_testActive);
        [self interruptTestIfNecessary];
    }
}

- (void)handleMediaServerConnectionDied:(NSNotification *)notification {
    ORK_Log_Error("Audio session server connection died");
    [self interruptTestIfNecessary];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    _player = nil;
}

- (ORKStepResult *)result {
    ORKStepResult *sResult = [super result];
    
    NSDate *now = sResult.endDate;
    
    NSMutableArray *results = [NSMutableArray arrayWithArray:sResult.results];
    
    ORKdBHLFitTestResult *fitTestResult = [[ORKdBHLFitTestResult alloc] initWithIdentifier:self.step.identifier];
    fitTestResult.startDate = sResult.startDate;
    fitTestResult.endDate = now;
    fitTestResult.fitTestResultSamples = [_fitTestResultSamples copy];
    
    [results addObject:fitTestResult];
    
    sResult.results = [results copy];
    
    return sResult;
}

// AVAudioPlayer delegate methods
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    if (flag) {
        _testActive = FALSE;
        [self dismissFitTest];
    }
}

@end
