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

#import "ORKAVJournalingARSessionHelper.h"
#import "ORKHelpers_Internal.h"
#import <ARKit/ARKit.h>
#import <VideoToolbox/VTCompressionSession.h>


static const CGFloat AudioSampleRate = 44100;

@interface ORKAVJournalingARSessionHelper ()

@property (nonatomic, weak) id<AVCaptureAudioDataOutputSampleBufferDelegate> sampleBufferDelegate;

@end

@implementation ORKAVJournalingARSessionHelper {
    NSURL *_tempOutputURL;
    
    AVCaptureAudioDataOutput *_audioDataOutput;
    
    AVAssetWriterInput *_audioAssetWriterInput;
    AVAssetWriterInput *_videoAssetWriterInput;
    AVAssetWriterInput *_depthDataAssetWriterInput;
    
    AVAssetWriter *_videoAssetWriter;
    
    AVAssetWriterInputPixelBufferAdaptor *_pixelBufferAdaptor;
    
    AVCaptureSession *_audioCaptureSession;
    
    AVCaptureDevice *_audioCaptureDevice;
    
    dispatch_queue_t _dataOutputQueue;
    
    BOOL _capturing;
    BOOL _startTimeSet;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _dataOutputQueue = dispatch_queue_create("com.apple.hrs.captureOutput", nil);
        _capturing = NO;
        _startTimeSet = NO;
    }
    return self;
}

#pragma mark Methods

- (BOOL)startSessionWithDelegate:(id<AVCaptureAudioDataOutputSampleBufferDelegate>)delegate error:(NSError **)error {
    if (error != NULL) {
        error = nil;
    }
    
    if ([delegate conformsToProtocol:@protocol(AVCaptureAudioDataOutputSampleBufferDelegate)]) {
        _sampleBufferDelegate = delegate;
    } else {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"The delegate passed in must conform to the AVCaptureAudioDataOutputSampleBufferDelegate protocol." userInfo:nil];
    }
    
    //setup videoAssetWriter
    BOOL success = [self setupVideoAssetWritter:error];
    
    if (!success) {
        return NO;
    }
    
    _depthDataAssetWriterInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo outputSettings:nil];
    _depthDataAssetWriterInput.expectsMediaDataInRealTime = YES;
        
    if ([_videoAssetWriter canAddInput:_depthDataAssetWriterInput]) {
        [_videoAssetWriter addInput:_depthDataAssetWriterInput];
    }
    
    
    //setup audioAssetWriterInput
    AVAudioFormat *audioFormat = [[AVAudioFormat alloc] initWithCommonFormat:AVAudioPCMFormatFloat32
                                                                  sampleRate:AudioSampleRate
                                                                    channels:1
                                                                 interleaved:YES];
    
    _audioAssetWriterInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeAudio
                                                                outputSettings:audioFormat.settings];
    
    _audioAssetWriterInput.expectsMediaDataInRealTime = YES;
    
    if ([_videoAssetWriter canAddInput:_audioAssetWriterInput]) {
        [_videoAssetWriter addInput:_audioAssetWriterInput];
    }
    
    //setup and configure audioCaptureSession
    _audioCaptureSession = [[AVCaptureSession alloc] init];
    [_audioCaptureSession beginConfiguration];
    
    success = [self setupAudioOnSession:error];
    
    if (!success) {
        return NO;
    }
    
    success = [self setupAudioDataOutputForSession:error];
    
    if (!success) {
        return NO;
    }
    
    [_audioCaptureSession commitConfiguration];
    [_audioCaptureSession startRunning];
    
    return YES;
}

- (BOOL)startCapturing:(NSError **)error {
    error = nil;
    
    if (_videoAssetWriter == nil) {
        if (_sampleBufferDelegate == nil) {
            if (error != NULL) {
                *error = [NSError errorWithDomain:NSCocoaErrorDomain code:NSFeatureUnsupportedError userInfo:@{NSLocalizedDescriptionKey:ORKLocalizedString(@"AV_JOURNALING_STEP_CAMERA_ERROR", nil)}];
            }
            return NO;
        }
        
        BOOL success = [self startSessionWithDelegate:_sampleBufferDelegate error:error];
        
        if (!success) {
            return NO;
        }
    }
    
    _capturing = YES;
    
    return YES;
}

- (void)stopCapturing {
    dispatch_async(_dataOutputQueue, ^{
        _capturing = NO;
    });
}

- (void)saveAudioSampleBuffer:(CMSampleBufferRef)sampleBuffer {
    if(_capturing && _startTimeSet && [_audioAssetWriterInput isReadyForMoreMediaData]) {
        [_audioAssetWriterInput appendSampleBuffer:sampleBuffer];
    }
}

- (void)savePixelBufferFromARFrame:(ARFrame *)frame {
    if(_videoAssetWriter.status == AVAssetWriterStatusFailed) {
        NSLog(@"error from AVAssetWriter: %@", _videoAssetWriter.error);
        return;
    }
    
    CVPixelBufferRef pixelBuffer = frame.capturedImage;
    
    if (_capturing) {
        if (!_startTimeSet) {
            [_videoAssetWriter startWriting];
            [_videoAssetWriter startSessionAtSourceTime:CMTimeMakeWithSeconds(frame.timestamp, NSEC_PER_SEC)];
            _startTimeSet = YES;
            //started capturing ARKit video output
        } else {
            if (_pixelBufferAdaptor.assetWriterInput.readyForMoreMediaData) {
                CMTime presentationTime = CMTimeMakeWithSeconds(frame.timestamp, NSEC_PER_SEC);
                [_pixelBufferAdaptor appendPixelBuffer:pixelBuffer withPresentationTime:presentationTime];
                 
                if (frame.capturedDepthData.depthDataMap && [_depthDataAssetWriterInput isReadyForMoreMediaData]) {
                    CMSampleBufferRef sbuf = NULL;
                    OSStatus err = [self attachDepthPixelBuffer: frame.capturedDepthData.depthDataMap toSampleBuffer:&sbuf withPresentationTime:presentationTime];
                    
                    if (err == noErr) {
                        [_depthDataAssetWriterInput appendSampleBuffer:sbuf];
                    }
                    
                    if (sbuf) {
                        CFRelease(sbuf);
                    }
                }
                
            }
        }
    } else {
        if (_startTimeSet && _videoAssetWriter.status != AVAssetWriterStatusUnknown) {
            _startTimeSet = NO;
            
            [_pixelBufferAdaptor.assetWriterInput markAsFinished];
            [_audioAssetWriterInput markAsFinished];
            
            CMTime time = CMTimeMakeWithSeconds(frame.timestamp, NSEC_PER_SEC);
            [_videoAssetWriter endSessionAtSourceTime:time];
            
            [_videoAssetWriter finishWritingWithCompletionHandler:^{
                //video has finished writing on background thread
                _videoAssetWriter = nil;
                if (_delegate) {
                    [_delegate capturingEndedWithTemporaryURL:_tempOutputURL];
                }
                
            }];
        }
    }
}

- (void)tearDownSession {
    if ([_audioCaptureSession isRunning]) {
        [_audioCaptureSession stopRunning];
        _audioCaptureSession = nil;
    }
}

#pragma mark Helper Methods (private)

- (BOOL)setupVideoAssetWritter:(NSError **)error {
    error = nil;
    
    NSString *tempVideoFilePath = [[NSTemporaryDirectory() stringByAppendingPathComponent:[NSUUID new].UUIDString] stringByAppendingPathExtension:@"mov"];
    _tempOutputURL = [NSURL fileURLWithPath:tempVideoFilePath];
    
    _videoAssetWriter = [AVAssetWriter assetWriterWithURL:_tempOutputURL fileType:AVFileTypeQuickTimeMovie error:error];
    
    if(error) {
        *error = [NSError errorWithDomain:NSCocoaErrorDomain code:NSFeatureUnsupportedError userInfo:@{NSLocalizedDescriptionKey:ORKLocalizedString(@"AV_JOURNALING_STEP_CAMERA_ERROR", nil)}];
        return NO;
    }
    
    //Set video settings - based on ARSession.configuration which is 1080p 60fps
    NSDictionary* videoSettings = @{
        AVVideoCodecKey: AVVideoCodecTypeH264,
        AVVideoWidthKey: @1440,
        AVVideoHeightKey: @1080,
    };
    
    _videoAssetWriterInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo outputSettings:videoSettings];
    _videoAssetWriterInput.expectsMediaDataInRealTime = YES;
    _videoAssetWriterInput.transform = CGAffineTransformMakeRotation(M_PI);
    
    NSDictionary *sourcePixelBufferAttributesDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                                           [NSNumber numberWithInt: kCVPixelFormatType_32RGBA], kCVPixelBufferPixelFormatTypeKey,
                                                           [NSNumber numberWithInt:1440], kCVPixelBufferWidthKey,
                                                           [NSNumber numberWithInt:1080], kCVPixelBufferHeightKey,
                                                           nil];
    
    _pixelBufferAdaptor = [AVAssetWriterInputPixelBufferAdaptor
                           assetWriterInputPixelBufferAdaptorWithAssetWriterInput:_videoAssetWriterInput
                           sourcePixelBufferAttributes:sourcePixelBufferAttributesDictionary];
    
    if ([_videoAssetWriter canAddInput:_videoAssetWriterInput]) {
        [_videoAssetWriter addInput:_videoAssetWriterInput];
    } else {
        if (error != NULL) {
            *error = [NSError errorWithDomain:NSCocoaErrorDomain code:NSFeatureUnsupportedError userInfo:@{NSLocalizedDescriptionKey:ORKLocalizedString(@"AV_JOURNALING_STEP_CAMERA_ERROR", nil)}];
        }
        return NO;
    }
    
    return YES;
}

- (BOOL)setupAudioOnSession:(NSError **)error {
    _audioCaptureDevice = [AVCaptureDevice defaultDeviceWithMediaType: AVMediaTypeAudio];
    AVCaptureDeviceInput *audioInput = [AVCaptureDeviceInput deviceInputWithDevice:_audioCaptureDevice error:error];
    
    if ([_audioCaptureSession canAddInput: audioInput]) {
        [_audioCaptureSession addInput: audioInput];
    } else {
        if (error != NULL) {
            *error = [NSError errorWithDomain:NSCocoaErrorDomain code:NSFeatureUnsupportedError userInfo:@{NSLocalizedDescriptionKey:ORKLocalizedString(@"AV_JOURNALING_STEP_AUDIO_ERROR", nil)}];
        }
        return NO;
    }
    
    return YES;
}

- (BOOL)setupAudioDataOutputForSession:(NSError **)error {
    // add data outputs:
    _audioDataOutput = [[AVCaptureAudioDataOutput alloc] init];
    if ([_audioCaptureSession canAddOutput:_audioDataOutput]) {
        [_audioCaptureSession  addOutput:_audioDataOutput];
        
        [_audioDataOutput setSampleBufferDelegate:_sampleBufferDelegate queue:_dataOutputQueue];
    } else {
        if (error != NULL) {
            *error = [NSError errorWithDomain:NSCocoaErrorDomain code:NSFeatureUnsupportedError userInfo:@{NSLocalizedDescriptionKey:ORKLocalizedString(@"AV_JOURNALING_STEP_CAMERA_ERROR", nil)}];
        }
        return NO;
    }
    
    return YES;
}

- (OSStatus)attachDepthPixelBuffer:(CVPixelBufferRef)pixelBuffer toSampleBuffer:(CMSampleBufferRef *)sbuf withPresentationTime:(CMTime)presentationTime {
    OSStatus err = noErr;
    CMFormatDescriptionRef formatDescription = NULL;
    CMSampleTimingInfo sampleTiming;
    err = CMVideoFormatDescriptionCreateForImageBuffer(kCFAllocatorDefault, pixelBuffer, &formatDescription);
    
     if ( err != noErr){
      goto bail;
    }
    
    sampleTiming.presentationTimeStamp = presentationTime;
    sampleTiming.decodeTimeStamp    = kCMTimeInvalid;
    sampleTiming.duration       = kCMTimeInvalid;
    err = CMSampleBufferCreateReadyWithImageBuffer(kCFAllocatorDefault,pixelBuffer, formatDescription, &sampleTiming, sbuf);
    if (( err != noErr) || ( *sbuf == NULL )) {
      goto bail;
    }
bail:
    if ( formatDescription ) {
        CFRelease( formatDescription );
    }
    return err;
}

@end
