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


#import "ORKdBHLToneAudiometryMethodOfAdjustmentStepViewController.h"
#import "ORKdBHLToneAudiometryMethodOfAdjustmentContentView.h"
#import "ORKdBHLToneAudiometryMethodOfAdjustmentStep.h"
#import "ORKIdBHLToneAudiometryResult.h"
#import "ORKdBHLToneAudiometryPulsedAudioGenerator.h"
#import "ORKHeadphoneDetectResult.h"
#import "ORKIUtils.h"
#import <ResearchKitInternal/ORKHeadphoneDetector.h>
#import <ResearchKitInternal/ORKHeadphoneDetectStep.h>
#import <ResearchKitInternal/ORKITaskViewController.h>
#import <ResearchKitActiveTask/ORKActiveStepViewController_Internal.h>
#import <SwiftUI/SwiftUI.h>
#import <ResearchKitInternal/ResearchKitInternal-Swift.h>

#import <MediaPlayer/MPVolumeView.h>

static const double ORKdBHLToneAudiometryMethodOfAdjustmentStepViewControllerTopMargin = 160.0;
static const double ORKdBHLToneAudiometryMethodOfAdjustmentStepPulseDuration = 200.0;
static const double ORKdBHLToneAudiometryMethodOfAdjustmentStepVolumeLevel = 0.8125;
static const double ORKdBHLVolumeViewAlpha = 0.001;

@interface ORKdBHLToneAudiometryMethodOfAdjustmentStepViewController () <ORKdBHLToneAudiometryPulsedAudioGeneratorDelegate> {
    ORKHeadphoneDetector *_headphoneDetector;
    ORKdBHLToneAudiometryPulsedAudioGenerator *_audioGenerator;
    
    int _currentTestIndex;
    
    BOOL _showingAlert;
    
    double _currentFreq;
    float _currentLevel;
    
    NSMutableArray *_arrayOfResultSamples;
}

@property (nonatomic, strong) ORKdBHLToneAudiometryMethodOfAdjustmentContentView *dBHLToneAudiometryContentView;

@end

@implementation ORKdBHLToneAudiometryMethodOfAdjustmentStepViewController

- (instancetype)initWithStep:(ORKStep *)step {
    self = [super initWithStep:step];
    
    if (self) {
        self.suspendIfInactive = YES;
        _currentTestIndex = 0;
        _showingAlert = NO;
        _arrayOfResultSamples = [NSMutableArray array];
        _headphoneDetector = nil;
        
        [[NSNotificationCenter defaultCenter] addObserver:self
             selector:@selector(receiveNextButtonTappedNotification:)
             name:@"nextButtonTapped"
             object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
             selector:@selector(receiveSkipButtonTappedNotification:)
             name:@"skipButtonTapped"
             object:nil];
    }
    
    return self;
}

- (ORKdBHLToneAudiometryMethodOfAdjustmentStep *)dBHLToneAudiometryStep {
    return (ORKdBHLToneAudiometryMethodOfAdjustmentStep *)self.step;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setNavigationFooterViewHidden:YES];
    
    [self setupContentView];
    [self setupContentViewConstraints];
}

- (void)setupContentView {
    ORKdBHLToneAudiometryMethodOfAdjustmentStep *dBHLTAStep = [self dBHLToneAudiometryStep];
    
    // Disable back-swiping during the test
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
    
    self.dBHLToneAudiometryContentView = [[ORKdBHLToneAudiometryMethodOfAdjustmentContentView alloc] initWithValue:_currentLevel
                                                                                                           minimum:dBHLTAStep.dBHLMinimumThreshold
                                                                                                           maximum:dBHLTAStep.dBHLMaximumThreshold
                                                                                                          stepSize:dBHLTAStep.stepSize
                                                                                                    numFrequencies:dBHLTAStep.frequencyList.count
                                                                                                      audioChannel:dBHLTAStep.earPreference];
    self.dBHLToneAudiometryContentView.delegate = self;
    [self.view addSubview:self.dBHLToneAudiometryContentView];
    self.dBHLToneAudiometryContentView.translatesAutoresizingMaskIntoConstraints = false;
}

- (void)setupContentViewConstraints {
    NSMutableArray *constraints = [NSMutableArray new];
    [constraints addObject:[self.dBHLToneAudiometryContentView.leftAnchor constraintEqualToAnchor:self.view.leftAnchor]];
    [constraints addObject:[self.dBHLToneAudiometryContentView.rightAnchor constraintEqualToAnchor:self.view.rightAnchor]];
    [constraints addObject:[self.dBHLToneAudiometryContentView.topAnchor constraintEqualToAnchor:self.view.topAnchor constant:ORKdBHLToneAudiometryMethodOfAdjustmentStepViewControllerTopMargin]];
    [constraints addObject:[self.dBHLToneAudiometryContentView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor constant:0]];

    [NSLayoutConstraint activateConstraints:constraints];
}

- (void)setupVolumeView {
    MPVolumeView *volumeView = [[MPVolumeView alloc] initWithFrame:CGRectNull];
    [volumeView setAlpha:ORKdBHLVolumeViewAlpha];
    [volumeView setIsAccessibilityElement:NO];
    [self.view addSubview:volumeView];
}

- (void)configureStep {
    ORKITaskViewController *taskVC = (ORKITaskViewController *)[self taskViewController];
    
    if ([taskVC isKindOfClass:[ORKITaskViewController class]]) {
        [taskVC lockDeviceVolume:ORKdBHLToneAudiometryMethodOfAdjustmentStepVolumeLevel];
    } else {
        // rdar://107531448 (all internal classes should throw error if parent is not ORKITaskViewController)
        @throw ([NSException exceptionWithName:@"Method of Adjustment lockDeviceVolume"
                                        reason:@"The task is using the public version of ORKTaskViewController, please instantiate the task with ORKITaskViewController."
                                      userInfo:nil]);
    }
    
    ORKWeakTypeOf(self) weakSelf = self;

    _dBHLToneAudiometryContentView.timestampProvider = ^NSTimeInterval{
        ORKStrongTypeOf(self) strongSelf = weakSelf;
        return strongSelf ? strongSelf.runtime : 0;
    };
    
    [self setupAudioGenerator];
}

- (nullable NSString*)findDetectedHeadphone {
    ORKdBHLToneAudiometryMethodOfAdjustmentStep *dBHLTAStep = [self dBHLToneAudiometryStep];
    if (dBHLTAStep.headphoneType != nil) {
        return dBHLTAStep.headphoneType;
    }
    ORKTaskResult *taskResults = [[self taskViewController] result];
    NSString *headphoneType = nil;
    for (ORKStepResult *result in taskResults.results) {
        if (result.results > 0) {
            ORKStepResult *firstResult = (ORKStepResult *)[result.results firstObject];
            if ([firstResult isKindOfClass:[ORKHeadphoneDetectResult class]]) {
                ORKHeadphoneDetectResult *headphoneDetectResult = (ORKHeadphoneDetectResult *)firstResult;
                headphoneType = headphoneDetectResult.headphoneType;
                dBHLTAStep.headphoneType = headphoneType; // side effect we are storing the result on the step.
                break;
            }
        }
    }
    return headphoneType;
}

- (void)setupAudioGenerator {
    NSString *headphoneType = [self findDetectedHeadphone];
    if (headphoneType) {
        _audioGenerator = [[ORKdBHLToneAudiometryPulsedAudioGenerator alloc] initForHeadphoneType:headphoneType
                                                                        pulseMillisecondsDuration:ORKdBHLToneAudiometryMethodOfAdjustmentStepPulseDuration
                                                                        pauseMillisecondsDuration:ORKdBHLToneAudiometryMethodOfAdjustmentStepPulseDuration];
        _audioGenerator.delegate = self;
    }
}

- (void)startHeadphoneDetector {
    if ([self findDetectedHeadphone] != nil) {
        _headphoneDetector = [[ORKHeadphoneDetector alloc] initWithDelegate:self
                                             supportedHeadphoneChipsetTypes:[ORKHeadphoneDetectStep dBHLTypes]];
        _headphoneDetector.delegate = self;
    } else {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"A valid headphone type must be provided" userInfo:nil];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [self startHeadphoneDetector];

    [self start];
    [self addObservers];
}

- (void)addObservers {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(appWillTerminate:) name:UIApplicationWillTerminateNotification object:nil];
}

- (void)removeObservers {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center removeObserver:self name:UIApplicationWillTerminateNotification object:nil];
}

-(void)appWillTerminate:(NSNotification*)note {
    [self stopAudio];
    [self removeObservers];
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
    [self configureStep];
    [self setupVolumeView];
    [self start];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    _audioGenerator.delegate = nil;
    _audioGenerator = nil;
    [_headphoneDetector discard];
    _headphoneDetector = nil;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self stopAudio];
    [self removeObservers];
}

- (ORKStepResult *)result {
    ORKStepResult *sResult = [super result];
    // "Now" is the end time of the result, which is either actually now,
    // or the last time we were in the responder chain.
    NSDate *now = sResult.endDate;
    
    NSMutableArray *results = [NSMutableArray arrayWithArray:sResult.results];
    
    ORKIdBHLToneAudiometryResult *toneResult = [[ORKIdBHLToneAudiometryResult alloc] initWithIdentifier:self.step.identifier];
    toneResult.startDate = sResult.startDate;
    toneResult.endDate = now;
    toneResult.samples = [_arrayOfResultSamples copy];
    toneResult.outputVolume = [AVAudioSession sharedInstance].outputVolume;
    toneResult.headphoneType = self.dBHLToneAudiometryStep.headphoneType;
    toneResult.algorithmVersion = 0;
    toneResult.measurementMethod = ORKdBHLToneAudiometryMeasurementMethodAdjustment;
    toneResult.discreteUnits = @[];
    toneResult.fitMatrix = @{};

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
    ORKdBHLToneAudiometryMethodOfAdjustmentStep *dBHLTAStep = [self dBHLToneAudiometryStep];
    
    _currentFreq = [(NSNumber *)dBHLTAStep.frequencyList.firstObject doubleValue];
    _currentLevel = dBHLTAStep.initialdBHLValue;
    
    [_audioGenerator playSoundAtFrequency:_currentFreq onChannel:dBHLTAStep.earPreference dBHL:_currentLevel];
    [self resetLevel:_currentLevel];
    
    ORK_Log_Info("Starting Frequency: %f", _currentFreq);
}
    
- (void)stopAudio {
    [_audioGenerator stop];
}

- (void)toneWillStartClipping {
    // not used
}

- (void)didSelected:(float)value {
    if (_currentLevel != value) {
        [_audioGenerator setCurrentdBHLAndRamp:value];
        _currentLevel = value;
    }
}

- (void)continueButtonAction:(id)sender {
    [self stopAudio];
    ORKdBHLToneAudiometryMethodOfAdjustmentStep *dBHLTAStep = [self dBHLToneAudiometryStep];
    ORKIdBHLToneAudiometryFrequencySample *resultSample = [ORKIdBHLToneAudiometryFrequencySample new];
    resultSample.channel = dBHLTAStep.earPreference;
    resultSample.frequency = _currentFreq;
    resultSample.calculatedThreshold = _currentLevel;
    resultSample.methodOfAdjustmentInteractions = _dBHLToneAudiometryContentView.userInteractions;
    
    [_arrayOfResultSamples addObject:resultSample];
    
    if (_currentTestIndex < dBHLTAStep.frequencyList.count -1) {
        [self.dBHLToneAudiometryContentView resetView];
    }
    [self nextTrial];
}

- (void)nextTrial {
    if (!_showingAlert) {
        ORKWeakTypeOf(self) weakSelf = self;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            ORKStrongTypeOf(self) strongSelf = weakSelf;
            ORKdBHLToneAudiometryMethodOfAdjustmentStep *dBHLTAStep = [strongSelf dBHLToneAudiometryStep];
            if (self->_currentTestIndex >= dBHLTAStep.frequencyList.count -1) {
                [strongSelf finish];
                return;
            } else {
                self->_currentTestIndex++;
                self->_currentFreq = [(NSNumber *)dBHLTAStep.frequencyList[self->_currentTestIndex] doubleValue];
                self->_currentLevel = dBHLTAStep.initialdBHLValue;
                [self->_audioGenerator playSoundAtFrequency:self->_currentFreq onChannel:dBHLTAStep.earPreference dBHL:self->_currentLevel];
                [strongSelf resetLevel:self->_currentLevel];
                ORK_Log_Info("Starting Frequency: %lf  -  Level: %lf", self->_currentFreq, self->_currentLevel);
                ORK_Log_Info("Sliders presented: %d", self->_currentTestIndex);
            }
        });
    }
}

- (void)resetLevel:(float)level {
    [self.dBHLToneAudiometryContentView setValue:level];
}

#pragma mark - Headphone Monitoring

- (NSString *)headphoneType {
    return [[self dBHLToneAudiometryStep].headphoneType uppercaseString];
}

- (void)bluetoothModeChanged:(ORKBluetoothMode)bluetoothMode {
    if ([[[self dBHLToneAudiometryStep].headphoneType uppercaseString] isEqualToString:ORKHeadphoneTypeIdentifierAirPodsGen4M] ||
        [[[self dBHLToneAudiometryStep].headphoneType uppercaseString] isEqualToString:ORKHeadphoneTypeIdentifierAirPodsGen4CHM] ||
        [[[self dBHLToneAudiometryStep].headphoneType uppercaseString] isEqualToString:ORKHeadphoneTypeIdentifierAirPodsPro] ||
        [[[self dBHLToneAudiometryStep].headphoneType uppercaseString] isEqualToString:ORKHeadphoneTypeIdentifierAirPodsProGen2] ||
        [[[self dBHLToneAudiometryStep].headphoneType uppercaseString] isEqualToString:ORKHeadphoneTypeIdentifierAirPodsMax] ||
        [[[self dBHLToneAudiometryStep].headphoneType uppercaseString] isEqualToString:ORKHeadphoneTypeIdentifierAirPodsMaxUSBC]) {

        BOOL newModeIsNoiseCancellingMode = (bluetoothMode == ORKBluetoothModeNoiseCancellation);

        if (!newModeIsNoiseCancellingMode) {
            [self showAlert];
        }
    }
}

- (void)headphoneTypeDetected:(nonnull ORKHeadphoneTypeIdentifier)headphoneType vendorID:(nonnull NSString *)vendorID productID:(nonnull NSString *)productID deviceSubType:(NSInteger)deviceSubType isSupported:(BOOL)isSupported {
    if (![headphoneType isEqualToString:[self headphoneType]]) {
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
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:ORKILocalizedString(@"PACHA_ALERT_TITLE_TASK_INTERRUPTED", nil)
                                                                                     message:ORKILocalizedString(@"PACHA_ALERT_TEXT_TASK_INTERRUPTED", nil)
                                                                              preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *startOver = [UIAlertAction actionWithTitle:ORKILocalizedString(@"dBHL_ALERT_TITLE_START_OVER", nil)
                                                                style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction *action) {
                [[self taskViewController] restartTask];
            }];
            [alertController addAction:startOver];
            [alertController addAction:[UIAlertAction actionWithTitle:ORKILocalizedString(@"dBHL_ALERT_TITLE_CANCEL_TEST", nil)
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
