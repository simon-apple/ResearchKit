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

#import "ORKFaceDetectionStepViewController.h"
#import "ORKActiveStepView.h"
#import "ORKFaceDetectionStepContentView.h"
#import "ORKActiveStepViewController_Internal.h"
#import "ORKStepViewController_Internal.h"
#import "ORKStepContainerView_Private.h"
#import "ORKResult_Private.h"
#import "ORKCollectionResult_Private.h"
#import "ORKFaceDetectionStep.h"
#import "ORKHelpers_Internal.h"
#import "ORKBorderedButton.h"
#import "ORKNavigationContainerView_Internal.h"
#import "ORKContext_Internal.h"
#import "ORKTaskViewController_Internal.h"
#import <AVFoundation/AVFoundation.h>
#import <CoreImage/CoreImage.h>
#import <SceneKit/SceneKit.h>
#import <ARKit/ARKit.h>


@interface ORKFaceDetectionStepViewController () <AVCaptureVideoDataOutputSampleBufferDelegate, ARSCNViewDelegate, ARSessionDelegate>

@property (nonatomic, strong) ORKFaceDetectionStepContentView *videoJournalFaceDetectionContentView;

@end


@implementation ORKFaceDetectionStepViewController {
    AVCaptureDevice *_frontCameraCaptureDevice;
    AVCaptureSession *_captureSession;
    ORKFaceDetectionStep *_faceDetectionStep;
    
    ORKFaceDetectionStepContentView *_contentView;
}

- (instancetype)initWithStep:(ORKStep *)step {
    self = [super initWithStep:step];
    
    if (self) {
        _faceDetectionStep = (ORKFaceDetectionStep *)self.step;
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
    
    [self setupContentView];
    [self setupConstraints];
    [self startSession];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [_contentView layoutSubviews];
}

- (void)setupContentView {
    _contentView = [[ORKFaceDetectionStepContentView alloc] init];
    __weak typeof(self) weakSelf = self;
    [_contentView setViewEventHandler:^(ORKFaceDetectionStepContentViewEvent event) {
        [weakSelf handleContentViewEvent:event];
    }];
    _contentView.layer.cornerRadius = 10.0;
    _contentView.layer.maskedCorners = kCALayerMinXMinYCorner | kCALayerMaxXMinYCorner;
    _contentView.clipsToBounds = YES;
    
    [self.view addSubview:_contentView];
}

- (void)handleContentViewEvent:(ORKFaceDetectionStepContentViewEvent)event {
    
    switch (event) {
        case ORKFaceDetectionStepContentViewEventTimeLimitHit:
            if ([self.step.context isKindOfClass:[ORKAVJournalingPredfinedTaskContext class]]) {
                [(ORKAVJournalingPredfinedTaskContext *)self.step.context didReachDetectionTimeLimitForTask:self.step.task];
            }
            
            [self clearSession];
            [[self taskViewController] flipToPageWithIdentifier:@"ORKAVJournalingMaxLimitHitCompletionStepIdentifierHeadphonesRequired" forward:YES animated:NO];
            break;
            
        case ORKFaceDetectionStepContentViewEventContinueButtonPressed:
            [self clearSession];
            [self finish];
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
    _frontCameraCaptureDevice = [AVCaptureDevice defaultDeviceWithDeviceType:AVCaptureDeviceTypeBuiltInWideAngleCamera mediaType:AVMediaTypeVideo position:AVCaptureDevicePositionFront];
    _captureSession = [AVCaptureSession new];
    
    if (_frontCameraCaptureDevice) {
        NSError *error;
        
        AVCaptureDeviceInput *deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:_frontCameraCaptureDevice error:&error];
        
        [_captureSession beginConfiguration];
        
        if (error) {
            [self handleError:[NSError errorWithDomain:NSCocoaErrorDomain code:NSFeatureUnsupportedError userInfo:@{NSLocalizedDescriptionKey:ORKLocalizedString(@"CAPTURE_ERROR_CAMERA_NOT_FOUND", nil)}]];
            return;
        }
        
        if ([_captureSession canAddInput:deviceInput]) {
            [_captureSession addInput:deviceInput];
        }
        
        if ([_captureSession canSetSessionPreset:AVCaptureSessionPreset640x480]) {
            [_captureSession setSessionPreset:AVCaptureSessionPreset640x480];
        }
        
        AVCaptureVideoDataOutput *output = [AVCaptureVideoDataOutput new];
        
        NSString* key = (NSString*)kCVPixelBufferPixelFormatTypeKey;
        NSNumber* value = [NSNumber numberWithUnsignedInt:kCVPixelFormatType_32BGRA];
        NSDictionary* videoSettings = [NSDictionary dictionaryWithObject:value forKey:key];
        [output setVideoSettings:videoSettings];
        output.alwaysDiscardsLateVideoFrames = YES;
        
        if ([_captureSession canAddOutput:output]) {
            [_captureSession addOutput:output];
        }
        
        AVCaptureConnection *connection = [output connectionWithMediaType:AVMediaTypeVideo];
        if ([connection isVideoOrientationSupported]) {
            connection.videoOrientation = AVCaptureVideoOrientationPortrait;
        }
        
        if ([connection isVideoMirroringSupported]) {
            [connection setVideoMirrored:NO];
        }
        
        [_captureSession commitConfiguration];
        
        dispatch_queue_attr_t qos = dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_SERIAL, QOS_CLASS_USER_INITIATED, -1);
        dispatch_queue_t recordingQueue = dispatch_queue_create("output.queue", qos);
        
        [output setSampleBufferDelegate:self queue:recordingQueue];
        
        [_contentView setPreviewLayerWithSession:_captureSession];
        
        [_captureSession startRunning];
    }
    
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
    }
}

#pragma mark - AVCaptureVideoDataOutputSampleBufferDelegate methods

- (void)captureOutput:(AVCaptureOutput *)output didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    CIDetector *faceDetector = [CIDetector detectorOfType:CIDetectorTypeFace context:nil options:@{ CIDetectorAccuracy : CIDetectorAccuracyHigh}];
    
    //create CIImage
    CVImageBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    CGSize imageSize = CVImageBufferGetDisplaySize(pixelBuffer);
    CFDictionaryRef attachments = CMCopyDictionaryOfAttachments(kCFAllocatorDefault, sampleBuffer, kCMAttachmentMode_ShouldPropagate);
    CIImage *image = [[CIImage alloc] initWithCVImageBuffer:pixelBuffer options:CFBridgingRelease(attachments)];
    
    //check for features. If the count is greater than one it means a face was detected
    NSArray<CIFeature *> *features = [faceDetector featuresInImage:image];
    
    if (features.count > 0) {
        CIFaceFeature *faceFeature = (CIFaceFeature *)features.firstObject;
        [_contentView setFaceDetected:YES faceRect:faceFeature.bounds originalSize:imageSize];
        [_contentView updateFacePositionCircleWithCGRect:faceFeature.bounds originalSize:imageSize];
    } else {
        [_contentView setFaceDetected:NO faceRect:CGRectNull originalSize:CGSizeZero];
    }
}

@end




