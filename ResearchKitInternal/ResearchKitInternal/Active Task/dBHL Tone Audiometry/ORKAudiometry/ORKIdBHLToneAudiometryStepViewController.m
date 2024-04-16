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

#import "ORKIdBHLToneAudiometryStepViewController.h"
#import "ORKIdBHLToneAudiometryAudioGenerator.h"

#import "ResearchKitInternal.h"
#import "ResearchKitInternal_Private.h"

#import "ORKIUtils.h"

@import ResearchKitActiveTask;
@import ResearchKitActiveTask_Private;
@import ResearchKitUI;
@import ResearchKitUI_Private;

#import "ResearchKitInternal/ResearchKitInternal-Swift.h"

// internal methods for the parent class
@interface ORKdBHLToneAudiometryStepViewController ()

- (void)configureStep;
- (ORKdBHLToneAudiometryStep *)dBHLToneAudiometryStep;
- (void)addObservers;
- (void)removeObservers;
- (id<ORKAudiometryProtocol>)audiometryEngine;
- (void)stopAudio;
- (void)runTestTrial;

@end


@implementation ORKIdBHLToneAudiometryStepViewController {
    ORKHeadphoneDetector *_headphoneDetector;
    BOOL _showingAlert;
}

- (instancetype)initWithStep:(ORKStep *)step {
    self = [super initWithStep:step];
    
    if (self) {
        _showingAlert = NO;
        _headphoneDetector = nil;
    }
    
    return self;
}

-(ORKIdBHLToneAudiometryStep *)idBHLToneAudiometryStep {
    return (ORKIdBHLToneAudiometryStep *)self.step;
}

- (ORKdBHLToneAudiometryAudioGenerator *)createAudioGeneratorFromHeadphoneType:(ORKHeadphoneTypeIdentifier)type {
    return [[ORKIdBHLToneAudiometryAudioGenerator alloc] initForHeadphoneType:type];
}

- (void)configureStep {
    ORKIdBHLToneAudiometryStep *dBHLTAStep = [self idBHLToneAudiometryStep];
    
    _headphoneDetector = [[ORKHeadphoneDetector alloc] initWithDelegate:self
                                                supportedHeadphoneChipsetTypes:[ORKHeadphoneDetectStep dBHLTypes]];
    
    ORKITaskViewController *taskViewController = (ORKITaskViewController *)[self taskViewController];
    
    if (taskViewController != nil) {
        [taskViewController lockDeviceVolume:0.625];
    } else {
        // rdar://107531448 (all internal classes should throw error if parent is ORKITaskViewController)
        //todo: throw if parent class not ORKITaskViewController
    }

    ORKTaskResult *taskResults = [taskViewController result];

    for (ORKStepResult *result in taskResults.results) {
        if (result.results > 0) {
            ORKStepResult *firstResult = (ORKStepResult *)[result.results firstObject];
            if ([firstResult isKindOfClass:[ORKHeadphoneDetectResult class]]) {
                ORKHeadphoneDetectResult *headphoneDetectResult = (ORKHeadphoneDetectResult *)firstResult;
                dBHLTAStep.headphoneType = headphoneDetectResult.headphoneType;
        
            } else if ([firstResult isKindOfClass:[ORKIdBHLToneAudiometryResult class]]) {
                if (@available(iOS 14.0, *)) {
                    ORKIdBHLToneAudiometryResult *dBHLToneAudiometryResult = (ORKIdBHLToneAudiometryResult *)firstResult;
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
    
    [super configureStep];
}

- (void)addObservers {
    [super addObservers];

    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(appDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)removeObservers {
    [super removeObservers];
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)appDidBecomeActive:(NSNotification*)note {
    [self showAlert];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [_headphoneDetector discard];
    _headphoneDetector.delegate = nil;
    _headphoneDetector = nil;
}

- (ORKStepResult *)result {
    ORKStepResult *result = [super result];
    
    if (@available(iOS 14.0, *)) {
        if ([self.audiometryEngine isKindOfClass:ORKNewAudiometry.class]) {
            ORKdBHLToneAudiometryResult *parentToneResult = [(ORKdBHLToneAudiometryResult *)result.results.lastObject copy];
            
            ORKIdBHLToneAudiometryResult *toneResult = [[ORKIdBHLToneAudiometryResult alloc] initWithIdentifier:parentToneResult.identifier];
            toneResult.startDate = [parentToneResult.startDate copy];
            toneResult.endDate = [parentToneResult.endDate copy];
            NSMutableArray *newSamples = [NSMutableArray array];
            for (ORKdBHLToneAudiometryFrequencySample *parentSample in [parentToneResult samples]) {
                ORKIdBHLToneAudiometryFrequencySample *newSample = [[ORKIdBHLToneAudiometryFrequencySample alloc] init];
                newSample.frequency = parentSample.frequency;
                newSample.calculatedThreshold = parentSample.calculatedThreshold;
                newSample.channel = parentSample.channel;
                newSample.units = [parentSample.units copy];
                [newSamples addObject:newSample];
            }
            toneResult.samples = newSamples;
            toneResult.outputVolume = parentToneResult.outputVolume;
            toneResult.headphoneType = parentToneResult.headphoneType;
            toneResult.tonePlaybackDuration = parentToneResult.tonePlaybackDuration;
            toneResult.postStimulusDelay = parentToneResult.postStimulusDelay;
            
            ORKNewAudiometry *engine = (ORKNewAudiometry *)self.audiometryEngine;
            toneResult.algorithmVersion = 1;
            toneResult.discreteUnits = engine.resultUnits;
            toneResult.fitMatrix = engine.fitMatrix;
            
            NSMutableArray *updatedResults = [NSMutableArray arrayWithArray:result.results];
            [updatedResults removeLastObject];
            [updatedResults addObject:toneResult];
            
            result.results = updatedResults;
        }
    }
    
    return result;
}

- (void)runTestTrial {
    if (_showingAlert) {
        return;
    }
    
    [super runTestTrial];
}

#pragma mark - Headphone Monitoring

- (NSString *)headphoneType {
    return [[self idBHLToneAudiometryStep].headphoneType uppercaseString];
}

- (void)bluetoothModeChanged:(ORKBluetoothMode)bluetoothMode {
    if ([[[self idBHLToneAudiometryStep].headphoneType uppercaseString] isEqualToString:ORKHeadphoneTypeIdentifierAirPodsPro] ||
        [[[self idBHLToneAudiometryStep].headphoneType uppercaseString] isEqualToString:ORKHeadphoneTypeIdentifierAirPodsMax]) {
            
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
            UIAlertController *alertController = [UIAlertController
                                                  alertControllerWithTitle:ORKILocalizedString(@"PACHA_ALERT_TITLE_TASK_INTERRUPTED", nil)
                                                  message:ORKILocalizedString(@"PACHA_ALERT_TEXT_TASK_INTERRUPTED", nil)
                                                  preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *startOver = [UIAlertAction
                                        actionWithTitle:ORKILocalizedString(@"dBHL_ALERT_TITLE_START_OVER", nil)
                                        style:UIAlertActionStyleDefault
                                        handler:^(UIAlertAction *action) {
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
