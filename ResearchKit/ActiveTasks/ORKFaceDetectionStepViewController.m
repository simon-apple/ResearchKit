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
#import "ORKContext.h"
#import "ORKTaskViewController_Internal.h"


@interface ORKFaceDetectionStepViewController () <AVCaptureVideoDataOutputSampleBufferDelegate, ARSCNViewDelegate, ARSessionDelegate>

@property (nonatomic, strong) ORKFaceDetectionStepContentView *videoJournalFaceDetectionContentView;

@end


@implementation ORKFaceDetectionStepViewController {
    NSTimer *_alignFaceTimer;
    int _alignFaceSeconds;
    
    AVCaptureDevice *_frontCameraCaptureDevice;
    AVCaptureSession *_captureSession;
    
    ARSCNView *_arSceneView;
}

- (instancetype)initWithStep:(ORKStep *)step {
    self = [super initWithStep:step];
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.activeStepView.navigationFooterView.neverHasContinueButton = true;
    _videoJournalFaceDetectionContentView = [ORKFaceDetectionStepContentView new];
    self.activeStepView.activeCustomView = _videoJournalFaceDetectionContentView;
    self.activeStepView.customContentFillsAvailableSpace = YES;

    [_videoJournalFaceDetectionContentView.nextButton addTarget:self
                                                         action:@selector(nextButtonPressed)
                                               forControlEvents:UIControlEventTouchUpInside];
    
    _alignFaceTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(alignFaceTimerIncrease) userInfo:nil repeats:YES];
    
    [self startSession];
}

- (void)startSession {
    if ([ARFaceTrackingConfiguration isSupported]) {
        _arSceneView = [_videoJournalFaceDetectionContentView arSceneView];
        _arSceneView.delegate = self;
        [_arSceneView.session setDelegate:self];
        
        ARFaceTrackingConfiguration *faceTrackingConfiguration = [ARFaceTrackingConfiguration new];
        [faceTrackingConfiguration setLightEstimationEnabled:YES];
        [_arSceneView.session runWithConfiguration:faceTrackingConfiguration options:ARSessionRunOptionResetTracking | ARSessionRunOptionRemoveExistingAnchors];
    } else {
        _frontCameraCaptureDevice = [AVCaptureDevice defaultDeviceWithDeviceType:AVCaptureDeviceTypeBuiltInWideAngleCamera mediaType:AVMediaTypeVideo position:AVCaptureDevicePositionFront];
        _captureSession = [AVCaptureSession new];
        
        if (_frontCameraCaptureDevice) {
            NSError *error;
            
            AVCaptureDeviceInput *deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:_frontCameraCaptureDevice error:&error];
            
            [_captureSession beginConfiguration];
            
            if (error) {
                //todo: handle error
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
            
            [_videoJournalFaceDetectionContentView setPreviewLayerWithSession:_captureSession];
            
            [_captureSession startRunning];
        }
        
    }
    
    [_videoJournalFaceDetectionContentView layoutSubviews];
}

- (void)alignFaceTimerIncrease {
    if (!_alignFaceSeconds) {
        _alignFaceSeconds = 1;
    }
    
    [_videoJournalFaceDetectionContentView updateTimerLabelWithSeconds:_alignFaceSeconds];
    
    if (_alignFaceSeconds == 60) {
        [_alignFaceTimer invalidate];
        
        if ([self.step.context isKindOfClass:[ORKAVJournalingPredfinedTaskContext class]]) {
            [(ORKAVJournalingPredfinedTaskContext *)self.step.context didReachDetectionTimeLimitForTask:self.step.task];
            
             [[self taskViewController] flipToPageWithIdentifier:@"MaxLimitHitCompletionStepIdentifierHeadphonesRequired" forward:YES animated:NO];
        }
        
    } else {
        _alignFaceSeconds += 1;
    }
}

- (void)nextButtonPressed {
    if (_arSceneView) {
        [_arSceneView.session pause];
        [_arSceneView removeFromSuperview];
        _arSceneView = nil;
    }
    
    if (_captureSession) {
        [_captureSession stopRunning];
        _captureSession = nil;
    }
    
    [self finish];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.activeStepView.customContentView layoutSubviews];
}

- (void)stepDidFinish {
    [super stepDidFinish];
    [self goForward];
}

- (void)start {
    [super start];
}

#pragma mark - AVCaptureVideoDataOutputSampleBufferDelegate methods

- (void)captureOutput:(AVCaptureOutput *)output didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    CIDetector *faceDetector = [CIDetector detectorOfType:CIDetectorTypeFace context:nil options:@{ CIDetectorAccuracy : CIDetectorAccuracyHigh}];
    
    //create CIImage
    CVImageBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    CFDictionaryRef attachments = CMCopyDictionaryOfAttachments(kCFAllocatorDefault, sampleBuffer, kCMAttachmentMode_ShouldPropagate);
    CIImage *image = [[CIImage alloc] initWithCVImageBuffer:pixelBuffer options:CFBridgingRelease(attachments)];
    
    //check for features. If the count is greater than one it means a face was detected
    NSArray<CIFeature *> *features = [faceDetector featuresInImage:image];
    [_videoJournalFaceDetectionContentView setFaceDetected:(features.count > 0)];
}

#pragma mark - ARSessionDelegate methods

- (void)session:(ARSession *)session didUpdateFrame:(ARFrame *)frame {
    for (ARAnchor *anchor in frame.anchors) {
        ARFaceAnchor *faceAnchor = (ARFaceAnchor *)anchor;
        if (faceAnchor && [faceAnchor isTracked]) {
            [_videoJournalFaceDetectionContentView setFaceDetected:YES];
            return;
        }
    }
    [_videoJournalFaceDetectionContentView setFaceDetected:NO];
}

@end




