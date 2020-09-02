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
#import "ORKAVJournalingStepResult.h"
#import "ORKResult_Private.h"
#import "ORKCollectionResult_Private.h"
#import "ORKAVJournalingStep.h"
#import "ORKHelpers_Internal.h"
#import "ORKBorderedButton.h"
#import "ORKNavigationContainerView_Internal.h"
#import "ORKAVJournalingStepContentView.h"
#import <AVFoundation/AVFoundation.h>
#import <CoreImage/CoreImage.h>
#import <SceneKit/SceneKit.h>
#import <ARKit/ARKit.h>
#import <AVKit/AVKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import "ORKAVJournalingARSessionHelper.h"
#import "ORKAVJournalingSessionHelper.h"


@interface ORKAVJournalingStepViewController () <AVCaptureDataOutputSynchronizerDelegate, ARSCNViewDelegate, ARSessionDelegate, ORKAVJournalingSessionHelperDelegate>
@end

@implementation ORKAVJournalingStepViewController {
    NSMutableArray *_results;
    NSMutableArray *_cameraIntrinsics;
    
    NSInteger _retryCount;
    
    ORKAVJournalingStepContentView *_contentView;
    ORKAVJournalingStep *_avJournalingStep;
    
    ARSCNView *_arSceneView;
    
    NSString *_savedFileName;
    
    NSURL *_tempFileURL;
    NSURL *_savedFileURL;
    
    BOOL _waitingOnUserToStartRecording;
    
    ORKAVJournalingARSessionHelper *_arSessionHelper;
    ORKAVJournalingSessionHelper *_sessionHelper;
}

- (instancetype)initWithStep:(ORKStep *)step {
    self = [super initWithStep:step];
    
    if (self) {
        _retryCount = 0;
        _avJournalingStep = (ORKAVJournalingStep *)step;
    }
    
    return self;
}

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    _results = [NSMutableArray new];
    _waitingOnUserToStartRecording = YES;
    
   [self setupContentView];
   [self setupConstraints];
   [self startSession];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [_contentView layoutSubviews];
}

- (void)handleError:(NSError *)error {
    // Shut down the session, if running
    [self tearDownSession];
    [self deleteTempVideoFile];
    
    _savedFileURL = nil;
    
    // Handle error in the UI.
    [_contentView handleError:error];
}

- (void)stepDidFinish {
    [super stepDidFinish];

    [self deleteTempVideoFile];
    
    if (_arSceneView) {
        [_arSceneView.session pause];
        [_arSceneView removeFromSuperview];
        _arSceneView = nil;
    }
    
    [self tearDownSession];
   
    [self goForward];
}

#pragma mark - Methods

- (void)setupContentView {
    _contentView = [[ORKAVJournalingStepContentView alloc] initWithTitle:_avJournalingStep.title text:_avJournalingStep.text];
    _contentView.layer.cornerRadius = 10.0;
    _contentView.layer.maskedCorners = kCALayerMinXMinYCorner | kCALayerMaxXMinYCorner;
    _contentView.clipsToBounds = YES;
    __weak typeof(self) weakSelf = self;
    [_contentView setViewEventHandler:^(ORKAVJournalingStepContentViewEvent event) {
        [weakSelf handleContentViewEvent:event];
    }];
    
    [self.view addSubview:_contentView];
}

- (void)handleContentViewEvent:(ORKAVJournalingStepContentViewEvent)event {
    switch (event) {
        case ORKAVJournalingStepContentViewEventStartRecording:
            [self startVideoRecording];
            break;
            
        case ORKAVJournalingStepContentViewEventStopRecording:
            [self stopVideoRecording];
            break;
            
        case ORKAVJournalingStepContentViewEventReviewRecording:
        {
            AVPlayerItem* playerItem = [AVPlayerItem playerItemWithURL:_tempFileURL];
            AVPlayer *playVideo = [[AVPlayer alloc] initWithPlayerItem:playerItem];
            AVPlayerViewController *playerViewController = [[AVPlayerViewController alloc] init];
            playerViewController.player = playVideo;
            playerViewController.player.volume = 1.0;
            [self presentViewController:playerViewController animated:YES completion:nil];
            [playVideo play];
            break;
        }
        case ORKAVJournalingStepContentViewEventRetryRecording:
            [self deleteTempVideoFile];
            _retryCount++;
            break;
        case ORKAVJournalingStepContentViewEventSubmitRecording:
        {
            [self submitVideo];
            break;
        }
        case ORKAVJournalingStepContentViewEventError:
            break;
    }
}

- (void)setupConstraints {
    _contentView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [[_contentView.topAnchor constraintEqualToAnchor:self.view.topAnchor] setActive:YES];
    [[_contentView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor] setActive:YES];
    [[_contentView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor] setActive:YES];
    [[_contentView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor] setActive:YES];
}

- (void)startSession {
    if ([ARFaceTrackingConfiguration isSupported]) {
        //Setup ARSession to record video/audio & depth map data
        _arSceneView = [_contentView ARSceneView];
        _arSceneView.delegate = self;
        [_arSceneView.session setDelegate:self];
        
        ARFaceTrackingConfiguration *faceTrackingConfiguration = [ARFaceTrackingConfiguration new];
        [faceTrackingConfiguration setLightEstimationEnabled:YES];
        faceTrackingConfiguration.providesAudioData = YES;
        [_arSceneView.session runWithConfiguration:faceTrackingConfiguration options:ARSessionRunOptionResetTracking | ARSessionRunOptionRemoveExistingAnchors];
        
        //Setup ARSessionHelper
        _arSessionHelper = [[ORKAVJournalingARSessionHelper alloc] init];
        _arSessionHelper.delegate = self;
        NSError *error = nil;
        
        BOOL success = [_arSessionHelper startSessionWithDelegate:self error:&error];
        
        if (!success) {
            [self handleError:error];
            return;
        }
        
    } else {
        //Setup SessionHelper
        _sessionHelper = [[ORKAVJournalingSessionHelper alloc] initWithSampleBufferDelegate:self
                                                                      sessionHelperDelegate:self
                                                                       shouldBlurBackground:_avJournalingStep.shouldBlurBackground];
    
        NSError *error = nil;
        
        BOOL success = [_sessionHelper startSession:&error];
        
        if (!success) {
            [self handleError:error];
        } else {
            [_contentView setPreviewLayerWithSession:_sessionHelper.captureSession];
            [_contentView layoutSubviews];
        }
    }
}

- (void)startVideoRecording {
    
    if ([ARFaceTrackingConfiguration isSupported]) {
        NSError *error = nil;
        BOOL success = [_arSessionHelper startCapturing:&error];
        
        if (!success) {
            [self handleError:error];
            return;
        }
        _waitingOnUserToStartRecording = NO;
        
    } else {
        
       [_sessionHelper startCapturing];
       _waitingOnUserToStartRecording = NO;
    }
    
    [_contentView startTimerWithMaximumRecordingLimit:_avJournalingStep.maximumRecordingLimit];
    [_contentView layoutSubviews];
}

- (void)tearDownSession {
    if ([ARFaceTrackingConfiguration isSupported]) {
        [_arSessionHelper tearDownSession];
    } else {
        [_sessionHelper tearDownSession];
    }
}

- (void)stopVideoRecording {
    if ([ARFaceTrackingConfiguration isSupported]) {
        [_arSessionHelper stopCapturing];
    } else {
        [_sessionHelper stopCapturing];
    }
}

- (void)submitVideo {
    if ([self tempVideoFileExists]) {
        //Save video to permanant file
        NSString *outputFileName = [NSUUID new].UUIDString;
        _savedFileName = [outputFileName stringByAppendingPathExtension:@"mov"];
        
        NSURL *docURL = [NSFileManager.defaultManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask].lastObject;
        docURL = [docURL URLByAppendingPathComponent:_savedFileName];
        
        NSData *data = [NSData dataWithContentsOfURL:_tempFileURL];
        BOOL wasDataSavedToURL = [data writeToURL:docURL atomically:YES];
        
        if (wasDataSavedToURL) {
            //remove video saved to temp directory if it was saved successfully in the document directory
            _savedFileURL = docURL;
            [self deleteTempVideoFile];
            [self finish];
        }
    }
}

- (void)presentOptionsViewIfRequired {
    dispatch_async(dispatch_get_main_queue(), ^{
        [_contentView presentReviewOptionsAllowingReview:_avJournalingStep.allowsReview
                                              allowRetry:_avJournalingStep.allowsRetry];
        
        if (!_avJournalingStep.allowsRetry && !_avJournalingStep.allowsReview) {
            [self submitVideo];
        }
        
    });
}

- (void)deleteTempVideoFile {
    if ([self tempVideoFileExists]) {
        NSError *error;
        
        [NSFileManager.defaultManager removeItemAtPath:_tempFileURL.relativePath error:&error];
        
        if (!error) {
            _tempFileURL = nil;
        } else {
            @throw [NSException exceptionWithName:NSGenericException reason:[NSString stringWithFormat:@"There was an error encountered while attempting to remove the saved video from the temp directory at path: %@", _tempFileURL.path]  userInfo:nil];
        }
    }
    
    _tempFileURL = nil;
}

- (BOOL)tempVideoFileExists {
    if (_tempFileURL && [NSFileManager.defaultManager fileExistsAtPath:_tempFileURL.relativePath]) {
        return YES;
    } else {
        return NO;
    }
}

- (ORKStepResult *)result {
    ORKStepResult *stepResult = [super result];
    NSDate *now = stepResult.endDate;
    
    NSMutableArray *results = [NSMutableArray arrayWithArray:stepResult.results];
    ORKAVJournalingStepResult *videoJournalResult = [[ORKAVJournalingStepResult alloc] initWithIdentifier:self.step.identifier];
    videoJournalResult.startDate = stepResult.startDate;
    videoJournalResult.endDate = now;
    videoJournalResult.contentType = @"video/quicktime";
    videoJournalResult.fileName = _savedFileName;
    videoJournalResult.fileURL = _savedFileURL;
    videoJournalResult.cameraIntrinsics = _cameraIntrinsics;
    videoJournalResult.retryCount = _retryCount;
    [results addObject:videoJournalResult];
    
    stepResult.results = [results copy];
    
    return stepResult;
}

- (void)extractDataFromCurrentFrame:(ARFrame *)frame {
    NSMutableDictionary *dict = [[NSMutableDictionary alloc]initWithCapacity:15];
    [dict setObject:[NSString stringWithFormat:@"%f", frame.timestamp] forKey:@"timeStamp"];
    [dict setObject:@{@"width": [NSString stringWithFormat:@"%f", frame.camera.imageResolution.width], @"height": [NSString stringWithFormat:@"%f", frame.camera.imageResolution.height]} forKey:@"imageResolution"];
    [dict setObject:[NSString stringWithFormat:@"%f", frame.lightEstimate.ambientIntensity] forKey:@"lightEstimate"];
    [dict setObject:[self arrayFromTransform:frame.camera.intrinsics] forKey:@"cameraIntrinsics"];
}

- (NSMutableArray *)arrayFromTransform:(simd_float3x3)transform {
    NSMutableArray *array = [NSMutableArray new];

    [array addObject:[[NSMutableArray alloc] initWithObjects:[NSNumber numberWithFloat:transform.columns[0].x], [NSNumber numberWithFloat:transform.columns[1].x], [NSNumber numberWithFloat:transform.columns[2].x], nil]];

    [array addObject:[[NSMutableArray alloc] initWithObjects:[NSNumber numberWithFloat:transform.columns[0].y], [NSNumber numberWithFloat:transform.columns[1].y], [NSNumber numberWithFloat:transform.columns[2].y], nil]];

    [array addObject:[[NSMutableArray alloc] initWithObjects:[NSNumber numberWithFloat:transform.columns[0].z], [NSNumber numberWithFloat:transform.columns[1].z], [NSNumber numberWithFloat:transform.columns[2].z], nil]];

    return array;
}

#pragma mark - ORKAVJournalingSessionHelperDelegate

- (void)capturingEndedWithTemporaryURL:(NSURL *)tempURL {
    _tempFileURL = tempURL;
    _waitingOnUserToStartRecording = YES;
    [self presentOptionsViewIfRequired];
}

#pragma mark AVCaptureVideoDataOutputSampleBufferDelegate

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    if (_waitingOnUserToStartRecording) {
        return;
    }
    
    if ([ARFaceTrackingConfiguration isSupported]) {
        if (_arSessionHelper) {
            [_arSessionHelper saveAudioSampleBuffer:sampleBuffer];
        }
        
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
        
    if (!_cameraIntrinsics) {
        _cameraIntrinsics = [self arrayFromTransform:frame.camera.intrinsics];
    }
}

- (void)sessionWasInterrupted:(ARSession *)session {
    //todo: handle iterruption
}

@end




