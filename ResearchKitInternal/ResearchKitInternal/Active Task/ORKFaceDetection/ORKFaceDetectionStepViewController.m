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

#import "ORKFaceDetectionStepViewController.h"

#if ORK_FEATURE_AV_JOURNALING

#import "ORKAVJournalingPredefinedTask_Internal.h"
#import "ORKFaceDetectionStep.h"
#import "ORKFaceDetectionStepContentView.h"

#import "ORKContext.h"

#import <ResearchKit/ORKResult_Private.h>
#import <ResearchKit/ORKCollectionResult_Private.h>
#import <ResearchKit/ORKHelpers_Internal.h>

#import <ResearchKitActiveTask/ORKActiveStepView.h>
#import <ResearchKitActiveTask/ORKActiveStepViewController_Internal.h>

#import <ResearchKitUI/ORKBorderedButton.h>
#import <ResearchKitUI/ORKNavigationContainerView_Internal.h>
#import <ResearchKitUI/ORKStepViewController_Internal.h>
#import <ResearchKitUI/ORKStepContainerView_Private.h>
#import <ResearchKitUI/ORKTaskViewController_Internal.h>

#import <AVFoundation/AVFoundation.h>
#import <CoreImage/CoreImage.h>


@interface ORKFaceDetectionStepViewController () <AVCaptureDataOutputSynchronizerDelegate>

@property (nonatomic, strong) ORKFaceDetectionStepContentView *videoJournalFaceDetectionContentView;

@end


@implementation ORKFaceDetectionStepViewController {
    ORKFaceDetectionStep *_faceDetectionStep;
    
    AVCaptureDevice *_frontCameraCaptureDevice;
    AVCaptureSession *_captureSession;
    AVCaptureSessionPreset _sessionPreset;
    AVCaptureDataOutputSynchronizer *_outputSynchronizer;
    
    NSDictionary *_videoSettings;
    
    AVCaptureVideoDataOutput *_videoDataOutput;
    AVCaptureMetadataOutput *_metaDataOutput;
    
    AVCaptureVideoOrientation _videoOrientation;
    UIInterfaceOrientation _interfaceOrientation;
    
    CGSize _frameSize;
    
    ORKFaceDetectionStepContentView *_contentView;
    
    dispatch_queue_t _dataOutputQueue;
}

- (instancetype)initWithStep:(ORKStep *)step {
    self = [super initWithStep:step];
    
    if (self) {
        _faceDetectionStep = (ORKFaceDetectionStep *)self.step;
        _dataOutputQueue = dispatch_queue_create("com.apple.hrs.captureOutput", NULL);
        _frameSize = CGSizeZero;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (@available(iOS 13.0, *)) {
        [self.navigationController.navigationBar setBarTintColor:[UIColor secondarySystemBackgroundColor]];
    } else {
        [self.navigationController.navigationBar setBarTintColor:[UIColor whiteColor]];
    }
    
    //Check for video authorization
    [self checkAuthorizationForMediaType:AVMediaTypeVideo completion:^(BOOL granted, AVAuthorizationStatus authStatus) {
        if (granted) {
            //Check for audio authorization of video accces was granted
            [self checkAuthorizationForMediaType:AVMediaTypeAudio completion:^(BOOL audioAccessGranted, AVAuthorizationStatus audioAuthStatus) {
                if (audioAccessGranted) {
                    [self setupContentAndSession];
                } else {
                    [self videoOrAudioAccessDenied];
                }
            }];
        } else {
            [self videoOrAudioAccessDenied];
        }
    }];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [_contentView layoutSubviews];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
     
    [_navigationFooterView.continueButton removeTarget:nil
                                                action:NULL
                                      forControlEvents:UIControlEventAllEvents];
    
    [_navigationFooterView.continueButton addTarget:self
                                             action:@selector(nextButtonPressed)
                                   forControlEvents:UIControlEventTouchUpInside];
}

- (void)checkAuthorizationForMediaType:(AVMediaType)mediaType completion:(void(^)(BOOL granted,AVAuthorizationStatus authStatus))handler {
    NSString *mediaTypeString = mediaType;
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaTypeString];
    
    switch (authStatus) {
        case AVAuthorizationStatusAuthorized:
            handler(YES, authStatus);
            break;
        case AVAuthorizationStatusDenied:
        case AVAuthorizationStatusRestricted:
            handler(NO, authStatus);
            break;
        case AVAuthorizationStatusNotDetermined:
            [AVCaptureDevice requestAccessForMediaType:mediaType completionHandler:^(BOOL granted) {
                if(granted){
                    handler(YES, authStatus);
                } else {
                    handler(NO, authStatus);
                }
            }];
            break;
    }
}

- (void)setupContentAndSession {
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        [self setupContentView];
        [self setupContentViewConstraints];
        [self startSession];
    });
}

- (void)setupContentView {
    _contentView = [[ORKFaceDetectionStepContentView alloc] initForRecalibration:NO stopFaceDetectionExit:NO];
    __weak typeof(self) weakSelf = self;
    [_contentView setViewEventHandler:^(ORKFaceDetectionStepContentViewEvent event) {
        [weakSelf handleContentViewEvent:event];
    }];
    _contentView.layer.cornerRadius = 10.0;
    _contentView.layer.maskedCorners = kCALayerMinXMinYCorner | kCALayerMaxXMinYCorner;
    _contentView.clipsToBounds = YES;
    
    self.activeStepView.activeCustomView = _contentView;
    self.activeStepView.customContentFillsAvailableSpace = YES;
    
    _navigationFooterView = self.activeStepView.navigationFooterView;
    [_navigationFooterView setContinueEnabled:NO];
}

- (void)videoOrAudioAccessDenied {
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        if ([self.step.context isKindOfClass:[ORKAVJournalingPredfinedTaskContext class]]) {
            [(ORKAVJournalingPredfinedTaskContext *)self.step.context videoOrAudioAccessDeniedForTask:self.step.task];
            [self clearSession];
            [[self taskViewController] flipToPageWithIdentifier:ORKAVJournalingStepIdentifierVideoAudioAccessDeniedCompletion forward:YES animated:NO];
        }
    });
}

- (void)handleContentViewEvent:(ORKFaceDetectionStepContentViewEvent)event {
    
    switch (event) {
        case ORKFaceDetectionStepContentViewEventTimeLimitHit:
            if ([self.step.context isKindOfClass:[ORKAVJournalingPredfinedTaskContext class]]) {
                [(ORKAVJournalingPredfinedTaskContext *)self.step.context didReachDetectionTimeLimitForTask:self.step.task currentStepIdentifier:self.step.identifier];
            }
            
            [self clearSession];
            [[self taskViewController] flipToPageWithIdentifier:ORKAVJournalingStepIdentifierMaxLimitHitCompletion forward:YES animated:NO];
            
            break;
    }
}

- (void)setupContentViewConstraints {
    _contentView.translatesAutoresizingMaskIntoConstraints = NO;

    [[_contentView.topAnchor constraintEqualToAnchor:self.activeStepView.topAnchor] setActive:YES];
    [[_contentView.leadingAnchor constraintEqualToAnchor:self.activeStepView.leadingAnchor] setActive:YES];
    [[_contentView.trailingAnchor constraintEqualToAnchor:self.activeStepView.trailingAnchor] setActive:YES];
}

- (BOOL)interfaceIsLandscape {
    return _interfaceOrientation == UIInterfaceOrientationLandscapeLeft || _interfaceOrientation == UIInterfaceOrientationLandscapeRight;
}

- (CGRect)getUpdatedFaceRectFromFaceBounds:(CGRect)faceBounds {
    
    //updated bounds for when the phone's orientation is in portrait
    CGRect updatedFaceBounds = CGRectMake(faceBounds.origin.y * _frameSize.height,
                                          faceBounds.origin.x * _frameSize.width,
                                          faceBounds.size.height * _frameSize.height,
                                          faceBounds.size.width * _frameSize.width);
    
    //updated bounds for when the phone's orientation is in landscape
    if ([self interfaceIsLandscape]) {
        updatedFaceBounds = CGRectMake(faceBounds.origin.x * _frameSize.width,
                                       faceBounds.origin.y * _frameSize.height,
                                       faceBounds.size.width * _frameSize.width,
                                       faceBounds.size.height * _frameSize.height);

    }
    
    return updatedFaceBounds;
}

- (CGSize)getUpdatedSize {
    //updated size for portrait
    CGSize size = CGSizeMake(_frameSize.height, _frameSize.width);
    
    if ([self interfaceIsLandscape]) {
        return _frameSize;
    }
    
    return size;
}

- (void)nextButtonPressed {
    [self clearSession];
    [self finish];
}

- (void)startSession {
    //Setup AVCaptureSession to record audio/video
    _captureSession = [AVCaptureSession new];
    [_captureSession beginConfiguration];
    
    NSError *error = nil;
    
    _frontCameraCaptureDevice = [AVCaptureDevice defaultDeviceWithDeviceType:AVCaptureDeviceTypeBuiltInWideAngleCamera
                                                                   mediaType:AVMediaTypeVideo position:AVCaptureDevicePositionFront];
    
    AVCaptureDeviceInput *frontCameraInput = [AVCaptureDeviceInput deviceInputWithDevice: _frontCameraCaptureDevice error: &error];
    
    if (error) {
        [self handleError:error];
        return;
    }
     
    if ([_captureSession canAddInput: frontCameraInput]) {
        [_captureSession addInput: frontCameraInput];
        
        _sessionPreset = AVCaptureSessionPreset1920x1080;
        
        if ([_captureSession canSetSessionPreset: _sessionPreset]) {
            [_captureSession setSessionPreset: _sessionPreset];
        }
    }
    
    if (!_videoDataOutput) {
        NSString* key = (NSString*)kCVPixelBufferPixelFormatTypeKey;
        NSNumber* value = [NSNumber numberWithUnsignedInt:kCVPixelFormatType_32BGRA];
        _videoSettings = [NSDictionary dictionaryWithObject:value forKey:key];
        _videoDataOutput = [[AVCaptureVideoDataOutput alloc] init];
        _videoDataOutput.alwaysDiscardsLateVideoFrames = YES;
        [_videoDataOutput setVideoSettings:_videoSettings];
        
        if ([_captureSession canAddOutput:_videoDataOutput]) {
            [_captureSession addOutput:_videoDataOutput];
        }
        
        // Required for VNFaceTracking
        AVCaptureConnection *connection = [_videoDataOutput connectionWithMediaType: AVMediaTypeVideo];
        connection.cameraIntrinsicMatrixDeliveryEnabled = YES;
        
        _interfaceOrientation = [UIApplication sharedApplication].statusBarOrientation;
        
        if (_interfaceOrientation == UIDeviceOrientationLandscapeLeft) {
            _videoOrientation = AVCaptureVideoOrientationLandscapeLeft;
        } else {
            _videoOrientation = AVCaptureVideoOrientationLandscapeRight;
        }
        
        if ([connection isVideoOrientationSupported]) {
            connection.videoOrientation = _videoOrientation;
            _contentView.videoOrientation = _videoOrientation;
        }
        
        if ([connection isVideoMirroringSupported]) {
            [connection setVideoMirrored:NO];
        }
    }
    
    if (!_metaDataOutput) {
        _metaDataOutput = [[AVCaptureMetadataOutput alloc] init];
        
        if ([_captureSession canAddOutput:_metaDataOutput]) {
            [_captureSession addOutput:_metaDataOutput];
            
            [_metaDataOutput setMetadataObjectTypes:@[AVMetadataObjectTypeFace]];
        }

    }
    
    if (!_outputSynchronizer) {
        _outputSynchronizer = [[AVCaptureDataOutputSynchronizer alloc] initWithDataOutputs:@[_videoDataOutput, _metaDataOutput]];
    }
    
    [_outputSynchronizer setDelegate:self queue:_dataOutputQueue];
    
    [_captureSession commitConfiguration];
    
    [_captureSession startRunning];
    
    [_contentView layoutSubviews];
}

- (void)handleError:(NSError *)error {
    // Shut down the session, if running
    if (_captureSession.isRunning) {
        [_captureSession stopRunning];
    }
    
    // Reset the state to before the capture session was setup.  Order here is important
    _captureSession = nil;
    
    // Handle error in the UI.
    [_contentView handleError:error];
}

- (void)stepDidFinish {
    [super stepDidFinish];
    
    [self clearSession];
    [self goForward];
}

- (void)start {
    [super start];
}

- (void)clearSession {
    if (_captureSession) {
        [_captureSession stopRunning];
        _captureSession = nil;
        [_contentView cleanUpView];
    }
}

#pragma mark - AVCaptureDataOutputSynchronizer

- (void)dataOutputSynchronizer:(AVCaptureDataOutputSynchronizer *)synchronizer didOutputSynchronizedDataCollection:(AVCaptureSynchronizedDataCollection *)synchronizedDataCollection {
    
    //pull out meta data
    AVCaptureSynchronizedMetadataObjectData *syncedMetaData = (AVCaptureSynchronizedMetadataObjectData *)[synchronizedDataCollection synchronizedDataForCaptureOutput:_metaDataOutput];
    CGRect facebounds = CGRectZero;
    
    if (syncedMetaData) {
        for (AVMetadataFaceObject *faceObject in syncedMetaData.metadataObjects) {
            if (faceObject) {
                facebounds = faceObject.bounds;
            }
        }
    }
    
    //pull out video data
    AVCaptureSynchronizedSampleBufferData *syncedVideoSampleBufferData = (AVCaptureSynchronizedSampleBufferData *)[synchronizedDataCollection synchronizedDataForCaptureOutput:_videoDataOutput];
    
    if (syncedVideoSampleBufferData && !syncedVideoSampleBufferData.sampleBufferWasDropped) {
        
        if (_frameSize.height == 0 && _frameSize.width == 0) {
            CVImageBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(syncedVideoSampleBufferData.sampleBuffer);
            _frameSize = CVImageBufferGetDisplaySize(pixelBuffer);
        }
        
        CGRect updatedFaceRect = [self getUpdatedFaceRectFromFaceBounds: facebounds];
        CGSize updatedSize = [self getUpdatedSize];
        
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            BOOL isFaceDetected = (CGRectGetHeight(updatedFaceRect) > 0 && CGRectGetWidth(updatedFaceRect) > 0);
            
            [_contentView setFaceDetected:isFaceDetected faceRect:updatedFaceRect originalSize:updatedSize];
            
            if (isFaceDetected) {
                [_contentView updateFacePositionCircleWithCGRect:updatedFaceRect originalSize:updatedSize];
            }
            
            if (isFaceDetected && [_contentView isFacePositionCircleWithinBox:updatedFaceRect originalSize:updatedSize]) {
                [_navigationFooterView setContinueEnabled:YES];
            } else {
                [_navigationFooterView setContinueEnabled:NO];
            }
        });
    }
}

@end

#endif
