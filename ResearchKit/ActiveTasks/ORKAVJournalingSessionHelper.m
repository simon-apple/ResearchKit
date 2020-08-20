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

#import "ORKAVJournalingSessionHelper.h"
#import "ORKHelpers_Internal.h"
#import <ARKit/ARKit.h>

@interface ORKAVJournalingSessionHelper ()

@property (nonatomic, weak) id<AVCaptureAudioDataOutputSampleBufferDelegate> audioOutputSampleBufferDelegate;
@property (nonatomic, weak) id<AVCaptureVideoDataOutputSampleBufferDelegate> videoOutputSampleBufferDelegate;

@end

@implementation ORKAVJournalingSessionHelper {
    id<ORKAVJournalingSessionHelperDelegate> _sessionHelperDelegate;
    
    AVCaptureSessionPreset _sessionPreset;
    NSDictionary *_videoSettings;
    
    NSURL *_tempOutputURL;
    
    AVCaptureAudioDataOutput *_audioDataOutput;
    AVCaptureVideoDataOutput *_videoDataOutput;
    
    AVAssetWriterInput *_audioAssetWriterInput;
    AVAssetWriterInput *_videoAssetWriterInput;
    
    AVAssetWriter *_videoAssetWriter;
    
    AVCaptureSession *_audioCaptureSession;
    
    AVCaptureDevice *_audioCaptureDevice;
    AVCaptureDevice *_frontCameraCaptureDevice;
    
    dispatch_queue_t _dataOutputQueue;
    
    BOOL _capturing;
    BOOL _startTimeSet;
    BOOL _sessionSetUp;
    BOOL _readyToRecord;
    
    CMTime _startTime;
    
    void (^captureSessionFinishedWriting)(void);
}

- (instancetype)initWithSampleBufferDelegate:(id<AVJournalingSessionHelperProtocol>)sampleBufferDelegate sessionHelperDelegate:(id<ORKAVJournalingSessionHelperDelegate>)sessionHelperDelegate {
    self = [super init];
    if (self) {
        _dataOutputQueue = dispatch_queue_create("com.apple.hrs.captureOutput", nil);
        _capturing = NO;
        
        if ([sampleBufferDelegate conformsToProtocol:@protocol(AVCaptureAudioDataOutputSampleBufferDelegate)] && [sampleBufferDelegate conformsToProtocol:@protocol(AVCaptureVideoDataOutputSampleBufferDelegate)]) {
            _audioOutputSampleBufferDelegate = sampleBufferDelegate;
            _videoOutputSampleBufferDelegate = sampleBufferDelegate;
        } else {
            @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"The delegate passed in must conform to the AVCaptureAudioDataOutputSampleBufferDelegate and AVCaptureVideoDataOutputSampleBufferDelegate protocols." userInfo:nil];
        }
        
        if ([sessionHelperDelegate conformsToProtocol:@protocol(ORKAVJournalingSessionHelperDelegate)]) {
            _sessionHelperDelegate = sessionHelperDelegate;
        } else {
            @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"The delegate passed in must conform to the AVCaptureAudioDataOutputSampleBufferDelegate and AVCaptureVideoDataOutputSampleBufferDelegate protocols." userInfo:nil];
        }
        
    }
    
    return self;
}

#pragma mark Methods

- (BOOL)startSession:(NSError **)error {    
    //Setup AVCaptureSession to record audio/video
    _captureSession = [AVCaptureSession new];
    [_captureSession beginConfiguration];
    
    //Setup front camera device
    BOOL success = [self setupFrontCameraOnSession:error];
    
    if (!success) {
        return NO;
    }
    
    //Setup audio device
    success = [self setupAudioOnSession:error];
    
    if (!success) {
        return NO;
    }
    
    //Setup output data for session
    success = [self setupDataOutputForSession:error];
    
    if (!success) {
        return NO;
    }
    
    [_captureSession commitConfiguration];
    
    _sessionSetUp = YES;
    _readyToRecord = YES;
    
    if (_sessionSetUp && _readyToRecord) {
        [_captureSession startRunning];
    }
    
    return error;
}

- (void)startCapturing {
    
    NSString *tempVideoFilePath = [[NSTemporaryDirectory() stringByAppendingPathComponent:[NSUUID new].UUIDString] stringByAppendingPathExtension:@"mov"];
    _tempOutputURL = [NSURL fileURLWithPath:tempVideoFilePath];
    
    AVAudioFormat *audioFormat = [[AVAudioFormat alloc] initWithCommonFormat:AVAudioPCMFormatFloat32
                                                                  sampleRate:44100
                                                                    channels:1
                                                                 interleaved:YES];
    
    // Writer input needs to be synched so we don't have issues starting/stopping video capture.
    dispatch_async(_dataOutputQueue, ^{
        
        NSError *error = nil;
        
        _videoAssetWriter = [AVAssetWriter assetWriterWithURL:_tempOutputURL fileType:AVFileTypeQuickTimeMovie error:&error];
        _videoAssetWriterInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo
                                                                    outputSettings:[_videoDataOutput
                                                                                    recommendedVideoSettingsForAssetWriterWithOutputFileType:AVFileTypeQuickTimeMovie]];
        
        [_videoAssetWriterInput setExpectsMediaDataInRealTime:YES];
        
        if ([_videoAssetWriter canAddInput:_videoAssetWriterInput]) {
            [_videoAssetWriter addInput:_videoAssetWriterInput];
        }
        
        _audioAssetWriterInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeAudio
                                                                    outputSettings:audioFormat.settings];
        [_audioAssetWriterInput setExpectsMediaDataInRealTime:YES];
        
        if ([_videoAssetWriter canAddInput:_audioAssetWriterInput]) {
            [_videoAssetWriter addInput:_audioAssetWriterInput];
        }
        
        _capturing = YES;
    });
}

- (void)stopCapturing {
    [self stopCaptureTaskWithCompletion:^{
        if (_sessionHelperDelegate) {
            [_sessionHelperDelegate capturingEndedWithTemporaryURL:_tempOutputURL];
        }
    }];
}

- (void)stopCaptureTaskWithCompletion:(void (^)(void))completion {
    if (captureSessionFinishedWriting == nil && _capturing) {
        // save the block parameter to be called when file write is complete in AVCaptureVideoDataOutputSampleBufferDelegate
        captureSessionFinishedWriting = completion;
        
        dispatch_async(_dataOutputQueue, ^{
            _capturing = NO;
        });
    }
}

- (void)saveSampleBuffer:(CMSampleBufferRef)sampleBuffer {
    FourCharCode mediaType = CMFormatDescriptionGetMediaType(CMSampleBufferGetFormatDescription(sampleBuffer));
    
    if (_capturing) {
        if (!_startTimeSet) {
            // start and end video using time from video sample buffers rather than audio
            if(mediaType == kCMMediaType_Video) {
                _startTime = CMSampleBufferGetPresentationTimeStamp(sampleBuffer);
                [_videoAssetWriter startWriting];
                [_videoAssetWriter startSessionAtSourceTime:_startTime];
                _startTimeSet = YES;
            }
        } else {
            if (mediaType == kCMMediaType_Audio) {
                if ([_audioAssetWriterInput isReadyForMoreMediaData]) {
                    [_audioAssetWriterInput appendSampleBuffer:sampleBuffer];
                }
            }
            
            if (mediaType == kCMMediaType_Video) {
                if ([_videoAssetWriterInput isReadyForMoreMediaData]) {
                    [_videoAssetWriterInput appendSampleBuffer:sampleBuffer];
                }
            }
        }
        
    } else {
        if (_startTimeSet && mediaType == kCMMediaType_Video && _videoAssetWriter.status != AVAssetWriterStatusUnknown) {
            _startTimeSet = NO;
            
            [_videoAssetWriterInput markAsFinished];
            [_audioAssetWriterInput markAsFinished];
            
            CMTime time = CMSampleBufferGetPresentationTimeStamp(sampleBuffer);
            [_videoAssetWriter endSessionAtSourceTime:time];
            
            [_videoAssetWriter finishWritingWithCompletionHandler:^{
                [self capturedFileHasFinishedWriting];
                _videoAssetWriter = nil;
            }];
        }
    }
}

- (void)tearDownSession {
    if ([_captureSession isRunning]) {
        [_captureSession stopRunning];
        _captureSession = nil;
    }
}

#pragma mark Helper Methods (private)

- (BOOL)setupFrontCameraOnSession:(NSError **)error {
    
    _frontCameraCaptureDevice = [AVCaptureDevice defaultDeviceWithDeviceType:AVCaptureDeviceTypeBuiltInWideAngleCamera mediaType:AVMediaTypeVideo position:AVCaptureDevicePositionFront];
    AVCaptureDeviceInput *frontCameraInput = [AVCaptureDeviceInput deviceInputWithDevice: _frontCameraCaptureDevice error: error];
    if (frontCameraInput) {
        if ([_captureSession canAddInput: frontCameraInput]) {
            [_captureSession addInput: frontCameraInput];
            
            [self configureCameraForHighestFrameRate: _frontCameraCaptureDevice];
            
            _sessionPreset = AVCaptureSessionPreset1920x1080;
            
            if ([_captureSession canSetSessionPreset: _sessionPreset]) {
                [_captureSession setSessionPreset: _sessionPreset];
            } else {
                *error = [NSError errorWithDomain:NSCocoaErrorDomain code:NSFeatureUnsupportedError userInfo:@{NSLocalizedDescriptionKey:ORKLocalizedString(@"AV_JOURNALING_STEP_CAMERA_ERROR", nil)}];
                return NO;
            }
        } else {
            *error = [NSError errorWithDomain:NSCocoaErrorDomain code:NSFeatureUnsupportedError userInfo:@{NSLocalizedDescriptionKey:ORKLocalizedString(@"AV_JOURNALING_STEP_CAMERA_ERROR", nil)}];
            return NO;
        }
    }
    
    return YES;
}

- (void)configureCameraForHighestFrameRate:(AVCaptureDevice *)device {
    AVCaptureDeviceFormat *bestFormat = nil;
    AVFrameRateRange *bestFrameRateRange = nil;
    for ( AVCaptureDeviceFormat *format in [device formats] ) {
        for ( AVFrameRateRange *range in format.videoSupportedFrameRateRanges ) {
            if ( range.maxFrameRate > bestFrameRateRange.maxFrameRate ) {
                bestFormat = format;
                bestFrameRateRange = range;
            }
        }
    }
    if (bestFormat && bestFrameRateRange) {
        if ( [device lockForConfiguration:NULL] == YES ) {
            device.activeFormat = bestFormat;
            device.activeVideoMinFrameDuration = bestFrameRateRange.minFrameDuration;
            device.activeVideoMaxFrameDuration = bestFrameRateRange.minFrameDuration;
            [device unlockForConfiguration];
        }
    }
}

- (BOOL)setupAudioOnSession:(NSError **)error {
    _audioCaptureDevice = [AVCaptureDevice defaultDeviceWithMediaType: AVMediaTypeAudio];
    AVCaptureDeviceInput *audioInput = [AVCaptureDeviceInput deviceInputWithDevice:_audioCaptureDevice error:error];
    
    if ([ARFaceTrackingConfiguration isSupported]) {
        if ([_audioCaptureSession canAddInput: audioInput]) {
            [_audioCaptureSession addInput: audioInput];
        } else {
            *error = [NSError errorWithDomain:NSCocoaErrorDomain code:NSFeatureUnsupportedError userInfo:@{NSLocalizedDescriptionKey:ORKLocalizedString(@"AV_JOURNALING_STEP_AUDIO_ERROR", nil)}];
            return NO;
        }
    } else {
        if ([_captureSession canAddInput: audioInput]) {
            [_captureSession addInput: audioInput];
        } else {
            *error = [NSError errorWithDomain:NSCocoaErrorDomain code:NSFeatureUnsupportedError userInfo:@{NSLocalizedDescriptionKey:ORKLocalizedString(@"AV_JOURNALING_STEP_AUDIO_ERROR", nil)}];
            return NO;
        }
    }
    
    return YES;
}

- (BOOL)setupDataOutputForSession:(NSError **)error {
    _videoSettings = [NSDictionary dictionary];
    
    if (!_audioDataOutput) {
        _audioDataOutput = [[AVCaptureAudioDataOutput alloc] init];
        if ([_captureSession canAddOutput:_audioDataOutput]) {
            [_captureSession  addOutput:_audioDataOutput];
        } else {
            *error = [NSError errorWithDomain:NSCocoaErrorDomain code:NSFeatureUnsupportedError userInfo:@{NSLocalizedDescriptionKey:ORKLocalizedString(@"AV_JOURNALING_STEP_AUDIO_ERROR", nil)}];
            return NO;
        }
    }
    
    if (!_videoDataOutput) {
        _videoDataOutput = [[AVCaptureVideoDataOutput alloc] init];
        _videoDataOutput.alwaysDiscardsLateVideoFrames = YES;
        _videoDataOutput.videoSettings = _videoSettings;
        
        // Required for VNFaceTracking
        AVCaptureConnection *connection = [_videoDataOutput connectionWithMediaType: AVMediaTypeVideo];
        connection.cameraIntrinsicMatrixDeliveryEnabled = YES;
        
        if ([_captureSession canAddOutput:_videoDataOutput]) {
            [_captureSession addOutput:_videoDataOutput];
            
        } else {
            *error = [NSError errorWithDomain:NSCocoaErrorDomain code:NSFeatureUnsupportedError userInfo:@{NSLocalizedDescriptionKey:ORKLocalizedString(@"AV_JOURNALING_STEP_CAMERA_ERROR", nil)}];
            return NO;
        }
        
        if ([connection isVideoOrientationSupported]) {
            connection.videoOrientation = AVCaptureVideoOrientationPortrait;
        }
        
        if ([connection isVideoMirroringSupported]) {
            [connection setVideoMirrored:NO];
        }
    }
    
    [_audioDataOutput setSampleBufferDelegate:_audioOutputSampleBufferDelegate queue:_dataOutputQueue];
    [_videoDataOutput setSampleBufferDelegate:_videoOutputSampleBufferDelegate queue:_dataOutputQueue];
    
    return YES;
}

- (void)capturedFileHasFinishedWriting {
    _readyToRecord = YES;
    dispatch_async(dispatch_get_main_queue(), ^{
        @autoreleasepool {
            if (captureSessionFinishedWriting) {
                captureSessionFinishedWriting();
                captureSessionFinishedWriting = nil;
            }
        }
    });
}

@end

