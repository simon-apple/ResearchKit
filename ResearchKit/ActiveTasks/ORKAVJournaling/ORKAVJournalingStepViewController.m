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

#import "ORKAVJournalingStepViewController.h"
#import "ORKActiveStepView.h"
#import "ORKAVJournalingStepContentView.h"
#import "ORKActiveStepViewController_Internal.h"
#import "ORKStepViewController_Internal.h"
#import "ORKStepContainerView_Private.h"
#import "ORKAVJournalingResult.h"
#import "ORKResult_Private.h"
#import "ORKCollectionResult_Private.h"
#import "ORKAVJournalingStep.h"
#import "ORKHelpers_Internal.h"
#import "ORKBorderedButton.h"
#import "ORKNavigationContainerView_Internal.h"
#import "ORKAVJournalingStepContentView.h"
#import "ORKAVJournalingARSessionHelper.h"
#import "ORKAVJournalingSessionHelper.h"
#import "ORKAVJournalingPredefinedTask_Internal.h"
#import "ORKTaskViewController_Internal.h"
#import "ORKContext.h"

#import <AVFoundation/AVFoundation.h>
#import <CoreImage/CoreImage.h>
#import <SceneKit/SceneKit.h>
#import <ARKit/ARKit.h>
#import <AVKit/AVKit.h>
#import <MediaPlayer/MediaPlayer.h>

static const CGFloat FramesToSkipTotal = 5.0;

@interface ORKAVJournalingStepViewController () <AVCaptureDataOutputSynchronizerDelegate, ARSCNViewDelegate, ARSessionDelegate, ORKAVJournalingSessionHelperDelegate, AVCaptureAudioDataOutputSampleBufferDelegate>
@end

@implementation ORKAVJournalingStepViewController {
    NSMutableArray *_results;
    
    ORKAVJournalingStepContentView *_contentView;
    ORKAVJournalingStep *_avJournalingStep;
    
    ARSCNView *_arSceneView;
    
    NSString *_savedFileName;
    
    NSURL *_savedFileURL;
    
    NSMutableArray<NSString *> *_fileNames;
    NSArray *_cameraIntrinsicsArray;
    NSArray<NSDictionary *> *_recalibrationTimeStamps;
    
    BOOL _waitingOnUserToStartRecording;
    BOOL _submitVideoAfterStopping;
    BOOL _shouldDeleteVideoFile;
    
    ORKAVJournalingARSessionHelper *_arSessionHelper;
    ORKAVJournalingSessionHelper *_sessionHelper;
    
    int _skippedFrameTotal;
}

- (instancetype)initWithStep:(ORKStep *)step {
    self = [super initWithStep:step];
    
    if (self) {
        _avJournalingStep = (ORKAVJournalingStep *)step;
        _skippedFrameTotal = 0;
        _shouldDeleteVideoFile = YES;
    }
    
    return self;
}

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _results = [NSMutableArray new];
    _fileNames = [NSMutableArray new];
    _waitingOnUserToStartRecording = YES;
    _submitVideoAfterStopping = NO;
    
   [self setupContentView];
   [self setupContentViewConstraints];
   [self startSession];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    [self updateNavFooterText];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [_contentView layoutSubviews];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
    [self cleanupSession];
}

- (void)stepDidFinish {
    [super stepDidFinish];

    [self cleanupSession];
    [self goForward];
}

#pragma mark - Methods

- (void)handleError:(NSError *)error {
    // Shut down the session, if running
    [self tearDownSession];
    [self deleteVideoFile];
    
    _savedFileURL = nil;
    
    // Handle error in the UI.
    [_contentView handleError:error];
}

- (void)setupContentView {
    _contentView = [[ORKAVJournalingStepContentView alloc] initWithTitle:_avJournalingStep.title text:_avJournalingStep.text];
    _contentView.translatesAutoresizingMaskIntoConstraints = NO;
    _contentView.layer.cornerRadius = 10.0;
    _contentView.layer.maskedCorners = kCALayerMinXMinYCorner | kCALayerMaxXMinYCorner;
    _contentView.clipsToBounds = YES;
    
    __weak typeof(self) weakSelf = self;
    [_contentView setViewEventHandler:^(ORKAVJournalingStepContentViewEvent event) {
        [weakSelf handleContentViewEvent:event];
    }];
    
    self.activeStepView.activeCustomView = _contentView;
    self.activeStepView.customContentFillsAvailableSpace = YES;
    
    _navigationFooterView = self.activeStepView.navigationFooterView;
    [_navigationFooterView setContinueEnabled:YES];
    [_navigationFooterView setSkipEnabled:YES];
    _navigationFooterView.optional = YES;
}

- (void)handleContentViewEvent:(ORKAVJournalingStepContentViewEvent)event {
    switch (event) {
        case ORKAVJournalingStepContentViewEventStopAndSubmitRecording:
            _submitVideoAfterStopping = YES;
            [self stopVideoRecording];
            break;
            
        case ORKAVJournalingStepContentViewEventEnableContinueButton:
            [_navigationFooterView setContinueEnabled:YES];
            [self updateNavFooterText];
            break;
            
        case ORKAVJournalingStepContentViewEventDisableContinueButton:
            [_navigationFooterView setContinueEnabled:NO];
            [self updateNavFooterText];
            break;
            
        case ORKAVJournalingStepContentViewEventRecalibrationTimeLimitHit:
            [self invokeFinishLaterContext];
            break;
        case ORKAVJournalingStepContentViewEventError:
            break;
    }
}

- (void)setupContentViewConstraints {
    [[_contentView.topAnchor constraintEqualToAnchor:self.activeStepView.topAnchor] setActive:YES];
    [[_contentView.leadingAnchor constraintEqualToAnchor:self.activeStepView.leadingAnchor] setActive:YES];
    [[_contentView.trailingAnchor constraintEqualToAnchor:self.activeStepView.trailingAnchor] setActive:YES];
}

- (void)updateNavFooterText {
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        [_navigationFooterView.skipButton setTitle:ORKLocalizedString(@"AV_JOURNALING_STEP_FINISH_LATER_BUTTON_TEXT", "") forState:UIControlStateNormal];
        
        [_navigationFooterView.continueButton removeTarget:nil
                                                    action:NULL
                                          forControlEvents:UIControlEventAllEvents];
        
        [_navigationFooterView.skipButton removeTarget:nil
                                                action:NULL
                                      forControlEvents:UIControlEventAllEvents];
        
        
        [_navigationFooterView.continueButton addTarget:self
                                                 action:@selector(nextButtonPressed)
                                       forControlEvents:UIControlEventTouchUpInside];
        
        [_navigationFooterView.skipButton addTarget:self
                                             action:@selector(finishLaterButtonPressed)
                                   forControlEvents:UIControlEventTouchUpInside];
    });
}

- (void)startSession {
    //Setup SessionHelper
    _sessionHelper = [[ORKAVJournalingSessionHelper alloc] initWithSampleBufferDelegate:self
                                                                  sessionHelperDelegate:self
                                                              storeDepthDataIfAvailable:_avJournalingStep.saveDepthDataIfAvailable];
    
    NSError *error = nil;
    
    BOOL success = [_sessionHelper startSession:&error];
    
    if (!success) {
        [self handleError:error];
    } else {
        [_contentView layoutSubviews];
    }

    [self startVideoRecording];
}

- (void)startVideoRecording {
    //Save video to permanant file
    NSString *fileNameFormat = @"%@_%@_rgb";
    
    if ([ARFaceTrackingConfiguration isSupported] && _avJournalingStep.saveDepthDataIfAvailable) {
        fileNameFormat = @"%@_%@_rgb_depth";
    }
    
    NSString *outputFileName = [NSString stringWithFormat:fileNameFormat, self.step.identifier, self.taskViewController.taskRunUUID.UUIDString];
    _savedFileName = [outputFileName stringByAppendingPathExtension:@"mov"];
    
    NSURL *docURL = self.taskViewController.outputDirectory;
    
    if (!docURL) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"The presented ORKTaskViewController must provide an outputDirectory for the ORKAVJournalingStep to save it's videos within." userInfo:nil];
    }
    
    docURL = [docURL URLByAppendingPathComponent:_savedFileName];
    
    [_sessionHelper startCapturingWithURL:docURL];
    _waitingOnUserToStartRecording = NO;
    
    [_contentView startTimerWithMaximumRecordingLimit:_avJournalingStep.maximumRecordingLimit
                                   countDownStartTime:_avJournalingStep.countDownStartTime];
    
    [_contentView layoutSubviews];
}

- (void)nextButtonPressed {
    _submitVideoAfterStopping = YES;
    [self stopVideoRecording];
}

- (void)finishLaterButtonPressed {
    UIAlertController * alert = [UIAlertController
                                 alertControllerWithTitle:ORKLocalizedString(@"AV_JOURNALING_STEP_ALERT_TITLE", "")
                                 message:ORKLocalizedString(@"AV_JOURNALING_STEP_ALERT_MESSAGE", "")
                                 preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* finishLaterButton = [UIAlertAction
                                        actionWithTitle:ORKLocalizedString(@"AV_JOURNALING_STEP_ALERT_FINISH_LATER_BUTTON_TEXT", "")
                                        style:UIAlertActionStyleDefault
                                        handler:^(UIAlertAction * action) {
        [self invokeFinishLaterContext];
    }];
    
    UIAlertAction* cancelButton = [UIAlertAction
                                   actionWithTitle:ORKLocalizedString(@"AV_JOURNALING_STEP_ALERT_CANCEL_BUTTON_TEXT", "")
                                   style:UIAlertActionStyleDefault
                                   handler:nil];
    
    [alert addAction:finishLaterButton];
    [alert addAction:cancelButton];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)invokeFinishLaterContext {
    if ([self.step.context isKindOfClass:[ORKAVJournalingPredfinedTaskContext class]]) {
        [(ORKAVJournalingPredfinedTaskContext *)self.step.context finishLaterWasPressedForTask:self.step.task currentStepIdentifier:self.step.identifier];
        [self cleanupSession];
        [[self taskViewController] flipToPageWithIdentifier:ORKAVJournalingStepIdentifierFinishLaterCompletion forward:YES animated:NO];
    }
}

- (void)tearDownSession {
    [_sessionHelper tearDownSession];
}

- (void)stopVideoRecording {
    [_sessionHelper stopCapturing];
}

- (void)submitVideo {
    if ([self videoFileExists]) {
        _shouldDeleteVideoFile = NO;
        [_fileNames addObject:_savedFileName];
        _cameraIntrinsicsArray = [[_sessionHelper cameraIntrinsicsArray] copy];
        _recalibrationTimeStamps = [[_contentView fetchRecalibrationTimeStamps] copy];

        dispatch_async(dispatch_get_main_queue(), ^(void) {
            [self finish];
        });
    }
}

- (void)deleteVideoFile {
    if ([self videoFileExists] && _shouldDeleteVideoFile) {
        NSError *error;
        
        [NSFileManager.defaultManager removeItemAtPath:_savedFileURL.relativePath error:&error];
        
        if (!error) {
            _savedFileURL = nil;
        } else {
            @throw [NSException exceptionWithName:NSGenericException reason:[NSString stringWithFormat:@"There was an error encountered while attempting to remove the saved video at path: %@", _savedFileURL.path]  userInfo:nil];
        }
    }
    
    _savedFileURL = nil;
}

- (BOOL)videoFileExists {
    if (_savedFileURL && [NSFileManager.defaultManager fileExistsAtPath:_savedFileURL.relativePath]) {
        return YES;
    } else {
        return NO;
    }
}

- (ORKStepResult *)result {
    ORKStepResult *stepResult = [super result];
    NSDate *now = stepResult.endDate;
    
    NSMutableArray *results = [NSMutableArray arrayWithArray:stepResult.results];
    ORKAVJournalingResult *videoJournalResult = [[ORKAVJournalingResult alloc] initWithIdentifier:self.step.identifier];
    videoJournalResult.startDate = stepResult.startDate;
    videoJournalResult.endDate = now;
    videoJournalResult.filenames = [_fileNames copy];
    videoJournalResult.cameraIntrinsics = _cameraIntrinsicsArray;
    videoJournalResult.recalibrationTimeStamps = _recalibrationTimeStamps;
    
    [results addObject:videoJournalResult];
    
    stepResult.results = [results copy];
    
    return stepResult;
}

- (void)cleanupSession {
    [self deleteVideoFile];
    [_contentView tearDownContentView];
    _contentView = nil;
    [self tearDownSession];
    _sessionHelper = nil;
}

#pragma mark - ORKAVJournalingSessionHelperDelegate

- (void)capturingEndedWithURL:(nullable NSURL *)url {
    _savedFileURL = url;
    _waitingOnUserToStartRecording = YES;
    if (_submitVideoAfterStopping) {
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            [self submitVideo];
        });
    }
}

- (void)faceDetected:(BOOL)faceDetected faceBounds:(CGRect)faceBounds originalSize:(CGSize)originalSize {
    if (_contentView) {
        if (_skippedFrameTotal > FramesToSkipTotal) {
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                [_contentView setFaceDetected:faceDetected faceBound:faceBounds originalSize:originalSize];
            });
        } else {
            _skippedFrameTotal += 1;
        }
    }
}

- (void)sessionWasInterrupted {
    [self invokeFinishLaterContext];
}

#pragma mark AVCaptureVideoDataOutputSampleBufferDelegate

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    if (_waitingOnUserToStartRecording) {
        return;
    }
}

#pragma mark - AVCaptureDataOutputSynchronizer

- (void)dataOutputSynchronizer:(AVCaptureDataOutputSynchronizer *)synchronizer didOutputSynchronizedDataCollection:(AVCaptureSynchronizedDataCollection *)synchronizedDataCollection {
    if (_waitingOnUserToStartRecording) {
        return;
    }
    
    if (_sessionHelper) {
         [_sessionHelper saveOutputsFromDataCollection:synchronizedDataCollection];
    }
}

#pragma mark - ARSession Methods

- (void)session:(ARSession *)session didUpdateFrame:(ARFrame *)frame {
    if (_waitingOnUserToStartRecording) {
        return;
    }

    if (_arSessionHelper) {
        [_arSessionHelper savePixelBufferFromARFrame:frame];
    }
}

- (void)sessionWasInterrupted:(ARSession *)session {
    //todo: handle iterruption
}

@end




