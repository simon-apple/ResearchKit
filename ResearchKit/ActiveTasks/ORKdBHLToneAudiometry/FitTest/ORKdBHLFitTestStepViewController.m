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

#define FIT_TEST_MIN_VOLUME            0.5f

typedef NS_ENUM(NSUInteger, ORKdBHLFitTestStage) {
    ORKdBHLFitTestStageStart,
    ORKdBHLFitTestStagePlaying,
    ORKdBHLFitTestStageResultConfidenceLow,
    ORKdBHLFitTestStageResultLeftSealGoodRightSealBad,
    ORKdBHLFitTestStageResultLeftSealBadRightSealGood,
    ORKdBHLFitTestStageResultLeftSealBadRightSealBad,
    ORKdBHLFitTestStageResultLeftSealGoodRightSealGood,
};

@interface ORKdBHLFitTestStepViewController () <AVAudioPlayerDelegate> {
    bool _budsInEar;
    bool _testActive;
    bool _callActive;

    bool _darkMode;
    bool _volumeModified;
    float _initialVolume;
    
    AVAudioPlayer *_player;
    
    ORKdBHLFitTestStage _stage;
    
    float _confidenceValL;
    float _confidenceValR;
    float _sealValL;
    float _sealValR;
    
    NSInteger _triesCounter;
    
    BluetoothDevice *_currentDevice;
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
    }
    
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    _triesCounter = 0;
    
    if (![[self bluetoothManager] available] || ![[self bluetoothManager] enabled]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(powerChangedHandler:) name:@"BluetoothAvailabilityChangedNotification" object:nil];
        [[self bluetoothManager] setEnabled:YES];
    } else {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(inEarStatusChanged:) name:@"BluetoothAccessoryInEarStatusNotification" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sealValueChanged:) name:@"BluetoothAccessorySealValueStatusNotification" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceDisconnectedHandler:) name:@"BluetoothDeviceDisconnectSuccessNotification" object:nil];
        
        NSArray * connectedDevices = [[self bluetoothManager] connectedDevices];
        
        if (connectedDevices.count > 0) {
            for (BluetoothDevice *connectedDevice in connectedDevices) {
                NSLog(@"device %@",connectedDevice);
                _currentDevice = connectedDevice;
                BTAccessoryInEarStatus primaryInEar = BT_ACCESSORY_IN_EAR_STATUS_UNKNOWN;
                BTAccessoryInEarStatus secondaryInEar = BT_ACCESSORY_IN_EAR_STATUS_UNKNOWN;

                [connectedDevice inEarStatusPrimary:&primaryInEar secondary:&secondaryInEar];
                _budsInEar = (primaryInEar == BT_ACCESSORY_IN_EAR_STATUS_IN_EAR) && (secondaryInEar == BT_ACCESSORY_IN_EAR_STATUS_IN_EAR);
                NSNumber *callIsActiveNumber = [[getAVSystemControllerClass() sharedAVSystemController] attributeForKey:@"AVSystemController_CallIsActive"];
                _callActive = [callIsActiveNumber boolValue];
            }
        }
    }
    
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
    
    //self.activeStepView.activeCustomView = self.fitTestContentView;
    
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
    [self setStage:ORKdBHLFitTestStageStart];
}

- (void)setStage:(ORKdBHLFitTestStage)stage {
    if (_triesCounter > [[self fitTestStep] numberOfTries] - 1 && stage != ORKdBHLFitTestStageResultLeftSealGoodRightSealGood) {
        [self.fitTestContentView setResultDetailLabelText:@""];
        self.activeStepView.stepTitle = @"Unable to Complete Ear Tip Fit Test";
        self.activeStepView.stepDetailText = @"Let's continue to the last dBHL test.";
        self.activeStepView.navigationFooterView.continueEnabled = YES;
        [self.activeStepView.navigationFooterView showActivityIndicator:NO];
        [self setContinueButtonTitle:ORKLocalizedString(@"BUTTON_NEXT", nil)];
        [self.activeStepView.navigationFooterView updateContinueAndSkipEnabled];
        _stage = ORKdBHLFitTestStageResultLeftSealGoodRightSealGood;
    } else {
        switch (stage) {
            case ORKdBHLFitTestStageStart: {
                [self.fitTestContentView setStart];
                self.activeStepView.navigationFooterView.continueEnabled = YES;
                [self.activeStepView.navigationFooterView showActivityIndicator:NO];
                [self setContinueButtonTitle:ORKLocalizedString(@"PLAY", nil)];
                [self.activeStepView.navigationFooterView updateContinueAndSkipEnabled];
                self.activeStepView.stepTitle = @"Ear Tip Fit Test";
                self.activeStepView.stepDetailText = @"Make sure AirPods in both ears are comfortable and secure, then press play to test fit.";
                break;
            }
            case ORKdBHLFitTestStagePlaying: {
                _triesCounter ++;
                [self.fitTestContentView setResultDetailLabelText:[NSString stringWithFormat:@"Try %li of %li",_triesCounter,self.fitTestStep.numberOfTries]];
                self.activeStepView.stepTitle = @"Do not remove AirPods until you see the fit test results";
                self.activeStepView.stepDetailText = @"";
                break;
            }
            case ORKdBHLFitTestStageResultConfidenceLow: {
                [self.fitTestContentView setWithLeftOk:NO rightOk:NO];
                self.activeStepView.stepTitle = @"Unable to Complete Ear Tip Fit Test";
                self.activeStepView.stepDetailText = @"Make sure to find a quiet location and remain still during ear tip fit test.";
                _triesCounter ++;
                [self.fitTestContentView setResultDetailLabelText:[NSString stringWithFormat:@"Try %li of %li",_triesCounter,self.fitTestStep.numberOfTries]];
                break;
            }
            case ORKdBHLFitTestStageResultLeftSealBadRightSealBad: {
                [self.fitTestContentView setWithLeftOk:NO rightOk:NO];
                self.activeStepView.stepTitle = @"Ear Fit Test Results";
                self.activeStepView.stepDetailText = @"Adjust both AirPods in your ears, or try another ear tip size and run the test again.\n\nYou should use the ear tips that are most comfortable in each ear.";
                _triesCounter ++;
                [self.fitTestContentView setResultDetailLabelText:[NSString stringWithFormat:@"Try %li of %li",_triesCounter,self.fitTestStep.numberOfTries]];
                break;
            }
            case ORKdBHLFitTestStageResultLeftSealGoodRightSealBad: {
                [self.fitTestContentView setWithLeftOk:YES rightOk:NO];
                self.activeStepView.stepTitle = @"Ear Fit Test Results";
                self.activeStepView.stepDetailText = @"Try adjusting the right AirPod in your ear, or change the ear tip size and try the test again.\n\nYou should use the ear tip that is most comfortable in each ear.";
                _triesCounter ++;
                [self.fitTestContentView setResultDetailLabelText:[NSString stringWithFormat:@"Try %li of %li",_triesCounter,self.fitTestStep.numberOfTries]];
                break;
            }
            case ORKdBHLFitTestStageResultLeftSealBadRightSealGood: {
                [self.fitTestContentView setWithLeftOk:NO rightOk:YES];
                self.activeStepView.stepTitle = @"Ear Fit Test Results";
                self.activeStepView.stepDetailText = @"Try adjusting the left AirPod in your ear, or change the ear tip size and try the test again.\n\nYou should use the ear tip that is most comfortable in each ear.";
                _triesCounter ++;
                [self.fitTestContentView setResultDetailLabelText:[NSString stringWithFormat:@"Try %li of %li",_triesCounter,self.fitTestStep.numberOfTries]];
                break;
            }
            case ORKdBHLFitTestStageResultLeftSealGoodRightSealGood: {
                self.activeStepView.navigationFooterView.continueEnabled = YES;
                [self.activeStepView.navigationFooterView showActivityIndicator:NO];
                [self setContinueButtonTitle:ORKLocalizedString(@"BUTTON_NEXT", nil)];
                [self.activeStepView.navigationFooterView updateContinueAndSkipEnabled];
                [self.fitTestContentView setWithLeftOk:YES rightOk:YES];
                self.activeStepView.stepTitle = @"Ear Fit Test Results";
                self.activeStepView.stepDetailText = @"The ear tips you’re using are a good fit for both ears.";
                [self.fitTestContentView setResultDetailLabelText:@""];
                break;
            }
            default:
                break;
        }
        _stage = stage;
    }
}

- (void)setNavigationFooterView {
    self.activeStepView.navigationFooterView.continueButtonItem = self.continueButtonItem;
    self.activeStepView.navigationFooterView.continueEnabled = YES;
    [self.activeStepView.navigationFooterView showActivityIndicator:NO];
    [self.activeStepView.navigationFooterView updateContinueAndSkipEnabled];

    [self setContinueButtonTitle:ORKLocalizedString(@"PLAY", nil)];
    
    [self.activeStepView.navigationFooterView.continueButton removeTarget:self.activeStepView.navigationFooterView action:nil forControlEvents:UIControlEventTouchUpInside];
    [self.activeStepView.navigationFooterView.continueButton addTarget:self action:@selector(continueButtonAction:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)continueButtonAction:(id)sender {
    switch (_stage) {
        case ORKdBHLFitTestStageStart: {
            self.activeStepView.navigationFooterView.continueEnabled = NO;
            [self.activeStepView.navigationFooterView showActivityIndicator:YES];
            [self.activeStepView.navigationFooterView updateContinueAndSkipEnabled];
            [self setStage:ORKdBHLFitTestStagePlaying];
            
            [self startFitTest];
            break;
        }
        case ORKdBHLFitTestStageResultLeftSealBadRightSealBad:
        case ORKdBHLFitTestStageResultLeftSealBadRightSealGood:
        case ORKdBHLFitTestStageResultConfidenceLow:
        case ORKdBHLFitTestStageResultLeftSealGoodRightSealBad: {
            [self.fitTestContentView setStart];
            self.activeStepView.navigationFooterView.continueEnabled = NO;
            [self.activeStepView.navigationFooterView showActivityIndicator:YES];
            [self setContinueButtonTitle:ORKLocalizedString(@"PLAY", nil)];
            [self.activeStepView.navigationFooterView updateContinueAndSkipEnabled];
            
            [self startFitTest];
            break;
        }
            
        case ORKdBHLFitTestStageResultLeftSealGoodRightSealGood: {
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

- (BluetoothManager *)bluetoothManager {
    return (BluetoothManager *)[getBluetoothManagerClass() sharedInstance];
}

-(void)addObservers {
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(powerChangedHandler:) name:@"BluetoothAvailabilityChangedNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleAudioSessionInterruption:) name:AVAudioSessionInterruptionNotification object:[AVAudioSession sharedInstance]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleMediaServerConnectionDied:) name:@"AVSystemController_ServerConnectionDiedNotification" object:[AVAudioSession sharedInstance]];
    NSError *error = nil;
    if (![[getAVSystemControllerClass() sharedAVSystemController] setAttribute: @[@"CallIsActiveDidChange"] forKey:@"AVSystemController_NotificationsToRegisterAttribute" error:&error]) {
        ORK_Log_Error("Failed to subscribe to AVSystemController notifications due to error: %@", error);
    } else {
        ORK_Log_Info("Successfully set AVSC attribute. Register listener for Call Active notification");
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleCallIsActiveDidChangeNotification:) name:@"AVSystemController_CallIsActiveDidChangeNotification" object:nil];
    }
}

- (void)startFitTest {
    if (!_budsInEar || _callActive) {
        ORK_Log_Info("budsInEar: %d, callActive: %d", _budsInEar, _callActive);
        [self setStage:ORKdBHLFitTestStageStart];
        UIAlertController *alert;
        if (!_budsInEar) {
            alert = [UIAlertController alertControllerWithTitle:@"Place AirPods In Both Ears" message:@"" preferredStyle:UIAlertControllerStyleAlert];
        } else {
            alert = [UIAlertController alertControllerWithTitle:@"End Call To Continue Test" message:@"" preferredStyle:UIAlertControllerStyleAlert];
        }
        [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            ORK_Log_Info("No action needed");
        }]];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }

    ORK_Log_Info("Start Fit Test");
    //[_playButton setUserInteractionEnabled:FALSE];
    [_currentDevice SendSetupCommand:BT_ACCESSORY_SETUP_SEAL_OP_START];

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // Audio related steps take more time, so handle them in a separate thread to avoid blocking main thread

        float currentVolume = 0.0f;
        bool success = [[getAVSystemControllerClass() sharedAVSystemController] getVolume:&currentVolume forCategory:(NSString *)CFSTR("Audio/Video")];
        if (!success) {
            ORK_Log_Error("Unable to fetch current volume");
        } else {
            ORK_Log_Info("Current volume : %f", currentVolume);
        }
        
        if (currentVolume != FIT_TEST_MIN_VOLUME) {
            ORK_Log_Info("Adjust volume for AudioVideo for fit test");
            [[getAVSystemControllerClass() sharedAVSystemController] setVolumeTo:FIT_TEST_MIN_VOLUME forCategory:(NSString *)CFSTR("Audio/Video")];
            _volumeModified = TRUE;
        }

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

- (void) resetVolume {
    if (_volumeModified && _initialVolume <= FIT_TEST_MIN_VOLUME) {
        ORK_Log_Info("Cleanup audio. Set audioVideo volume to: %f", _initialVolume);
        [[getAVSystemControllerClass() sharedAVSystemController] setVolumeTo:_initialVolume forCategory:(NSString *)CFSTR("Audio/Video")];
        _volumeModified = FALSE;
    }
}

- (void) cleanupAudio {
    ORK_Log_Info("Clean up fit test audio");
    [_player setVolume:0.0 fadeDuration:1.0];
    NSError *error;
    [[AVAudioSession sharedInstance] setActive:NO withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:&error];
    if (error) {
        ORK_Log_Error("Failed to deactivate AVAudioSession with AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation : %@", error);
    }
}

- (void) fitTestStopped {
    _testActive = FALSE;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self resetVolume];
        [self cleanupAudio];
    });
    [self setStage:ORKdBHLFitTestStageStart];
}

- (float)getSealThreshold {
    return [[self fitTestStep] sealThreshold];
}

- (float)getConfidenceThreshold {
    return [[self fitTestStep] confidenceThreshold];
}

- (void) inEarStatusChanged: (NSNotification *)note {
    NSDictionary *object = [note object];

    NSNumber *primaryInEarStatus = object[@"primaryInEarStatus"];
    NSNumber *secondaryInEarStatus = object[@"secondaryInEarStatus"];
    bool newPrimaryInEar = ![primaryInEarStatus boolValue];
    bool newSecondaryInEar = ![secondaryInEarStatus boolValue];
    bool newBudsInEar = newPrimaryInEar && newSecondaryInEar;
    ORK_Log_Info("PrimaryInEar: %@, secondaryInEar : %@. newBudsInEar: %d", primaryInEarStatus, secondaryInEarStatus, newBudsInEar);
    
    [self setupInternalVariables];

    bool reloadUI = (newBudsInEar != _budsInEar);
    _budsInEar = newBudsInEar;

    if (reloadUI) {
        ORK_Log_Info("Update UI since in-ear status has changed");
        
        if (_testActive) {
            [self fitTestStopped];
        }
    } else {
        ORK_Log_Info("No change needed based on in-ear status change");
    }
}

- (void) sealValueChanged: (NSNotification *)note {
    if (!_testActive) {
        ORK_Log_Error("Discard results since test is not active");
        return;
    }

    NSDictionary *object = [note object];
    NSNumber *left = object[@"sealLeft"];
    NSNumber *right = object[@"sealRight"];
    _sealValL = [left floatValue];
    _sealValR = [right floatValue];
    ORK_Log_Info("leftSeal : %0.06f", _sealValL);
    ORK_Log_Info("rightSeal : %0.06f", _sealValR);
    NSNumber *confidenceL = object[@"confidenceLeft"];
    NSNumber *confidenceR = object[@"confidenceRight"];
    _confidenceValL = [confidenceL floatValue];
    _confidenceValR = [confidenceR floatValue];
    ORK_Log_Info("confidenceL : %0.06f", _confidenceValL);
    ORK_Log_Info("confidenceR : %0.06f", _confidenceValR);
    bool leftSealGood = false;
    //bool leftSealPoor = false;
    bool rightSealGood = false;
    //bool rightSealPoor = false;

    [self fitTestStopped];

    _darkMode = (self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark);
    if (_darkMode) {
        [self.fitTestContentView resetLabelsBackgroundColors];
    }

    float confidence = [self getConfidenceThreshold];
    if (_confidenceValL < confidence || _confidenceValR < confidence) {
        ORK_Log_Info("Confidence values too low.");
        [self setStage:ORKdBHLFitTestStageResultConfidenceLow];
    } else {
        float sealThreshold = [self getSealThreshold];
        if (_sealValL > sealThreshold) {
            leftSealGood = true;
        }

        if (_sealValR > sealThreshold) {
            rightSealGood = true;
        }

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
}

- (void) dismissFitTest {
    [self cleanupAudio];
    [self resetVolume];
    _triesCounter = 0;
    [self setStage:ORKdBHLFitTestStageStart];
}

- (void) deviceDisconnectedHandler:(NSNotification *)note {
    BluetoothDevice *device = [note object];
    if (([device address] == [_currentDevice address])) {
        [self dismissFitTest];
    }
}

- (void) setupInternalVariables {
    NSArray * connectedDevices = [[self bluetoothManager] connectedDevices];
    
    if (connectedDevices.count > 0) {
        if (connectedDevices.count == 1) {
            
        }
        for (BluetoothDevice *connectedDevice in connectedDevices) {
            ORK_Log_Info("device %@",connectedDevice);
            _currentDevice = connectedDevice;
            BTAccessoryInEarStatus primaryInEar = BT_ACCESSORY_IN_EAR_STATUS_UNKNOWN;
            BTAccessoryInEarStatus secondaryInEar = BT_ACCESSORY_IN_EAR_STATUS_UNKNOWN;

            [connectedDevice inEarStatusPrimary:&primaryInEar secondary:&secondaryInEar];
            _budsInEar = (primaryInEar == BT_ACCESSORY_IN_EAR_STATUS_IN_EAR) && (secondaryInEar == BT_ACCESSORY_IN_EAR_STATUS_IN_EAR);
            NSNumber *callIsActiveNumber = [[getAVSystemControllerClass() sharedAVSystemController] attributeForKey:@"AVSystemController_CallIsActive"];
            _callActive = [callIsActiveNumber boolValue];
        }
    }
}

- (void) powerChangedHandler:(NSNotification *)note {
    if ([[self bluetoothManager] available]) {
        ORK_Log_Info("BluetoothManager is available");
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"BluetoothAvailabilityChangedNotification" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(inEarStatusChanged:) name:@"BluetoothAccessoryInEarStatusNotification" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sealValueChanged:) name:@"BluetoothAccessorySealValueStatusNotification" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceDisconnectedHandler:) name:@"BluetoothDeviceDisconnectSuccessNotification" object:nil];
        [self setupInternalVariables];
    } else {
        // TODO: Alert the User ?
    }
}

- (BOOL) isCallActive {
    NSNumber *callIsActiveNumber = [[getAVSystemControllerClass() sharedAVSystemController] attributeForKey:@"AVSystemController_CallIsActive"];
    BOOL isCallActive = [callIsActiveNumber boolValue];
    ORK_Log_Info("Call is active : %d",isCallActive);
    return isCallActive;
}

- (void) handleCallIsActiveDidChangeNotification:(NSNotification *)notification {
    ORK_Log_Info("Call is active did change %@",notification.userInfo);
    // TODO: what to do here?
}

// AVAudioSession interruption
- (void)handleAudioSessionInterruption:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    AVAudioSessionInterruptionType type = [[userInfo objectForKey:AVAudioSessionInterruptionTypeKey] unsignedIntegerValue];

    if(type == AVAudioSessionInterruptionTypeBegan)
    {
        ORK_Log_Error("Audio session interrupted. Reset Fit Test (Active: %d)",_testActive);
        if (_testActive) {
            [self fitTestStopped];
        }
    }
}

- (void)handleMediaServerConnectionDied:(NSNotification *)notification {
    ORK_Log_Error("Audio session server connection died");
    // TODO: reset everything?
}

- (void) dealloc {
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
    fitTestResult.sealLeftEar = _sealValL;
    fitTestResult.sealRightEar = _sealValR;
    fitTestResult.confidenceLeftEar = _confidenceValL;
    fitTestResult.confidenceRightEar = _confidenceValR;
    
    [results addObject:fitTestResult];
    
    sResult.results = [results copy];
    
    return sResult;
}

// AVAudioPlayer delegate methods

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    if (flag) {
        [self dismissFitTest];
        [self setupInternalVariables];
    }
}

@end
