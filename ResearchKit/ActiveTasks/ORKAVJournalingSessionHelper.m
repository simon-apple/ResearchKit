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

// FigFormat metadata keys
NSString *const CMMetadataFormatDescriptionMetadataSpecificationKey_Identifier = @"MetadataIdentifier";
NSString *const CMMetadataFormatDescriptionMetadataSpecificationKey_DataType = @"MetadataDataType";

NSString *const TrackStreamTypeIdentifierKey              = @"mdta/com.apple.trackStreamType"; // metadata key to store track id
NSString *const RawSampleBufferAttachmentDictionary    = @"mdta/com.apple.rawSampleBufferAttachmentDict"; // metadata key to store CVPixelBuffer attachments
NSString *const MIOFrameAttachmentSerializationMode = @"FrameMetadataFormat";
NSString *const MIOTimestampWhenWrittenToFileKey = @"OriginalTimestampWhenWrittenToFile";

NSString *const TrackStreamTypeIdentifierFrontColor = @"FrontColor";
NSString *const TrackStreamTypeIdentifierFrontDepth = @"FrontDepth";


CMPixelFormatType const DepthCapturePixelFormatType = kCVPixelFormatType_32BGRA;

typedef struct __attribute__((__packed__)) DepthPacket {
    uint16_t depth;
    uint16_t padding;
} DepthPacket;

@interface ORKAVJournalingSessionHelper ()

@property (nonatomic, weak) id<AVCaptureDataOutputSynchronizerDelegate> synchronizerDelegate;

@end

@implementation ORKAVJournalingSessionHelper {
    id<ORKAVJournalingSessionHelperDelegate> _sessionHelperDelegate;
    
    AVCaptureSessionPreset _sessionPreset;
    NSDictionary *_videoSettings;
    
    NSURL *_outputURL;
    
    AVCaptureAudioDataOutput *_audioDataOutput;
    AVCaptureVideoDataOutput *_videoDataOutput;
    AVCaptureDepthDataOutput *_depthDataOutput;
    AVCaptureMetadataOutput *_metaDataOutput;
    
    AVCaptureDataOutputSynchronizer *_outputSynchronizer;
    
    CIContext *_context;
    
    CVPixelBufferPoolRef _bufferPool;
    
    AVAssetWriter *_videoAssetWriter;
    
    AVAssetWriterInput *_audioAssetWriterInput;
    AVAssetWriterInput *_videoAssetWriterInput;
    AVAssetWriterInput *_depthAssetWriterInput;
    AVAssetWriterInput *_videoMetadataAssetWriterInput;
    AVAssetWriterInput *_depthMetadataAssetWriterInput;

    AVAssetWriterInputPixelBufferAdaptor *_depthPixelBufferAdaptor;
    AVAssetWriterInputMetadataAdaptor *_videoMetadataAdaptor;
    AVAssetWriterInputMetadataAdaptor *_depthMetadataAdaptor;
    
    AVCaptureDevice *_audioCaptureDevice;
    AVCaptureDevice *_frontCameraCaptureDevice;
    
    UIInterfaceOrientation _interfaceOrientation;
    
    CGSize _originalFrameSize;
    
    dispatch_queue_t _dataOutputQueue;
    
    BOOL _capturing;
    BOOL _startTimeSet;
    BOOL _sessionSetUp;
    BOOL _readyToRecord;
    BOOL _storeDepthData;
    
    CMTime _startTime;
    
    void (^captureSessionFinishedWriting)(void);
}

- (instancetype)initWithSampleBufferDelegate:(id<AVCaptureDataOutputSynchronizerDelegate>)sampleBufferDelegate
                       sessionHelperDelegate:(id<ORKAVJournalingSessionHelperDelegate>)sessionHelperDelegate
                   storeDepthDataIfAvailable:(BOOL)storeDepthData{
    self = [super init];
    if (self) {
        _dataOutputQueue = dispatch_queue_create("com.apple.hrs.captureOutput", nil);
        _capturing = NO;
        _originalFrameSize = CGSizeZero;
        _interfaceOrientation = [UIApplication sharedApplication].statusBarOrientation;
        _storeDepthData = storeDepthData;
        
        if ([sampleBufferDelegate conformsToProtocol:@protocol(AVCaptureDataOutputSynchronizerDelegate)]) {
            _synchronizerDelegate = sampleBufferDelegate;
        } else {
            @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"The delegate passed in must conform to the AVCaptureDataOutputSynchronizerDelegate protocol." userInfo:nil];
        }
        
        if ([sessionHelperDelegate conformsToProtocol:@protocol(ORKAVJournalingSessionHelperDelegate)]) {
            _sessionHelperDelegate = sessionHelperDelegate;
        } else {
            @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"The delegate passed in must conform to the ORKAVJournalingSessionHelperDelegate protocol." userInfo:nil];
        }
        
    }
    
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark Methods

- (BOOL)startSession:(NSError **)error {
    _context = [CIContext contextWithOptions:nil];
    
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(sessionWasInterrupted:)
                                                 name:AVCaptureSessionWasInterruptedNotification
                                               object:_captureSession];
    
    return error;
}

- (void)startCapturingWithURL:(NSURL *)url {
    _outputURL = url;
        
    // Writer input needs to be synched so we don't have issues starting/stopping video capture.
    dispatch_async(_dataOutputQueue, ^{
        
        NSError *error = nil;
        
        _videoAssetWriter = [AVAssetWriter assetWriterWithURL:_outputURL fileType:AVFileTypeQuickTimeMovie error:&error];
        
        //create video asset writer input
        _videoAssetWriterInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo
                                                                    outputSettings:[_videoDataOutput
                                                                                    recommendedVideoSettingsForAssetWriterWithOutputFileType:AVFileTypeQuickTimeMovie]];
        
        [_videoAssetWriterInput setExpectsMediaDataInRealTime:YES];
        
        if ([_videoAssetWriter canAddInput:_videoAssetWriterInput]) {
            [_videoAssetWriter addInput:_videoAssetWriterInput];
        }
        
        //create audio asset writer input
        AVAudioFormat *audioFormat = [[AVAudioFormat alloc] initWithCommonFormat:AVAudioPCMFormatFloat32
                                                                      sampleRate:44100
                                                                        channels:1
                                                                     interleaved:YES];
        
        _audioAssetWriterInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeAudio
                                                                    outputSettings:audioFormat.settings];
        [_audioAssetWriterInput setExpectsMediaDataInRealTime:YES];
        
        if ([_videoAssetWriter canAddInput:_audioAssetWriterInput]) {
            [_videoAssetWriter addInput:_audioAssetWriterInput];
        }

        // create depth asset writer input
        [self setupAssetWriterInputDepth];

        // create metadata asset writer input for depth and video
        [self setupAssetWriterInputVideoMetadata];
        [self setupAssetWriterInputDepthMetadata];
        
        _capturing = YES;
    });
}

- (void)stopCapturing {
    [self stopCaptureTaskWithCompletion:^{
        if (_sessionHelperDelegate) {
            [_sessionHelperDelegate capturingEndedWithURL:_outputURL];
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

- (void)saveOutputsFromDataCollection:(AVCaptureSynchronizedDataCollection *)dataCollection {
    //pull out meta data
    AVCaptureSynchronizedMetadataObjectData *syncedMetaData = (AVCaptureSynchronizedMetadataObjectData *)[dataCollection synchronizedDataForCaptureOutput:_metaDataOutput];
    CGRect facebounds = CGRectZero;
    
    if (syncedMetaData) {
        for (AVMetadataFaceObject *faceObject in syncedMetaData.metadataObjects) {
            if (faceObject) {
                facebounds = faceObject.bounds;
            }
        }
    }
    
    //pull out video data
    AVCaptureSynchronizedSampleBufferData *syncedVideoSampleBufferData = (AVCaptureSynchronizedSampleBufferData *)[dataCollection synchronizedDataForCaptureOutput:_videoDataOutput];
    
    if (syncedVideoSampleBufferData && !syncedVideoSampleBufferData.sampleBufferWasDropped) {
        
        //capture camera intrinsics data
        if (!_cameraIntrinsicsArray) {
            CFTypeRef cameraIntrinsicData = CMGetAttachment(syncedVideoSampleBufferData.sampleBuffer, kCMSampleBufferAttachmentKey_CameraIntrinsicMatrix, nil);
            if (cameraIntrinsicData != nil){
                CFDataRef cfdr = (CFDataRef)(cameraIntrinsicData);
                matrix_float3x3 cameraIntrinsics = *(matrix_float3x3 *)(CFDataGetBytePtr(cfdr));
                //todo: store camera intriniscs
                _cameraIntrinsicsArray = [self arrayFromTransform:cameraIntrinsics];
            }
        }
        
        if (!_startTimeSet) {
            [self saveSampleBuffer:syncedVideoSampleBufferData.sampleBuffer];
        } else {
            
            if (_originalFrameSize.height == 0 && _originalFrameSize.width == 0) {
                CVImageBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(syncedVideoSampleBufferData.sampleBuffer);
                 _originalFrameSize = CVImageBufferGetDisplaySize(pixelBuffer);
            }
            
            
            CGRect updatedFaceRect = [self getUpdatedFaceBounds:facebounds];
            CGSize updatedSize = [self getUpdatedSize];
            
            //let delegate know if face was detected
            BOOL faceDetected = (CGRectGetHeight(updatedFaceRect) > 0 && CGRectGetWidth(updatedFaceRect) > 0) ? YES : NO;
            if (_sessionHelperDelegate != nil && [_sessionHelperDelegate respondsToSelector:@selector(faceDetected:faceBounds:originalSize:)]) {
                [_sessionHelperDelegate faceDetected:faceDetected faceBounds:updatedFaceRect originalSize:updatedSize];
            }
            
            CMTime presentationTime = CMSampleBufferGetPresentationTimeStamp(syncedVideoSampleBufferData.sampleBuffer);
            CVPixelBufferRef pixelBufferRef = [self blurSampleBuffer:syncedVideoSampleBufferData.sampleBuffer faceBounds:facebounds];
            CMSampleBufferRef sbuf = NULL;
            OSStatus err = [self attachDepthPixelBuffer:pixelBufferRef toSampleBuffer:&sbuf withPresentationTime:presentationTime];
            
            if (err == noErr) {
                [self saveSampleBuffer:sbuf];
            }

            [self attachMetadataVideoForPixelBuffer:pixelBufferRef presentationTime:presentationTime];
            
            if (sbuf != NULL) {
                CFRelease(sbuf);
            }
            
            CVPixelBufferRelease(pixelBufferRef);
        }
    }

    // pull out depth data
    AVCaptureSynchronizedDepthData *syncedDepthSampleBufferData = (AVCaptureSynchronizedDepthData *) [dataCollection synchronizedDataForCaptureOutput:_depthDataOutput];
    if (_depthAssetWriterInput && syncedDepthSampleBufferData && !syncedDepthSampleBufferData.depthDataWasDropped && _storeDepthData) {
        
        AVDepthData *depthData = syncedDepthSampleBufferData.depthData;
        if (depthData.depthDataType != kCVPixelFormatType_DepthFloat32) {
            depthData = [depthData depthDataByConvertingToDepthDataType:kCVPixelFormatType_DepthFloat32];
        }

        CVPixelBufferRef depthImage = depthData.depthDataMap;

        if (depthImage) {
            CMTime depthPresentationTime = syncedDepthSampleBufferData.timestamp;
            CVPixelBufferRef quantizedPixelBuffer = [self quantizeDepthPixelBuffer:depthImage];

            CMVideoFormatDescriptionRef formatDesc = NULL;

            CMVideoFormatDescriptionCreateForImageBuffer(kCFAllocatorDefault, quantizedPixelBuffer, &formatDesc);

            if (formatDesc) {
                CMSampleBufferRef depthSampleBuffer = nil;

                CMSampleTimingInfo sampleTiming;

                sampleTiming.presentationTimeStamp = depthPresentationTime;
                sampleTiming.decodeTimeStamp    = kCMTimeInvalid;
                sampleTiming.duration       = kCMTimeInvalid;

                CMSampleBufferCreateReadyWithImageBuffer(kCFAllocatorDefault, quantizedPixelBuffer, formatDesc, &sampleTiming, &depthSampleBuffer);

                if (depthSampleBuffer && _depthAssetWriterInput.isReadyForMoreMediaData) {
                    [_depthPixelBufferAdaptor appendPixelBuffer:quantizedPixelBuffer withPresentationTime:sampleTiming.presentationTimeStamp];

                    CFRelease(depthSampleBuffer);
                }
                CFRelease(formatDesc);
                CFRelease(quantizedPixelBuffer);
            }

            [self attachMetadataDepthForPixelBuffer:quantizedPixelBuffer presentationTime:depthPresentationTime];
        }
    }

    
    //pull out audio data
    AVCaptureSynchronizedSampleBufferData *syncedAudioSampleBufferData = (AVCaptureSynchronizedSampleBufferData *)[dataCollection synchronizedDataForCaptureOutput:_audioDataOutput];
    
    if (syncedAudioSampleBufferData && syncedAudioSampleBufferData.sampleBuffer) {
        [self saveSampleBuffer:syncedAudioSampleBufferData.sampleBuffer];
    }


}

- (void)tearDownSession {
    if ([_captureSession isRunning]) {
        [_captureSession stopRunning];
        _captureSession = nil;
    }
}

#pragma mark Helper Methods (private)

- (BOOL)setupAssetWriterInputDepth {
    // create depth asset writer input
    _depthAssetWriterInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo
                                                                outputSettings:nil];

    [_depthAssetWriterInput setExpectsMediaDataInRealTime:YES];
    
    // add track-level metadata
    NSMutableArray* metadata = [@[[self getTrackMetadataForStream:TrackStreamTypeIdentifierFrontDepth]] mutableCopy];
    _depthAssetWriterInput.metadata = [metadata copy];

    _depthPixelBufferAdaptor = [AVAssetWriterInputPixelBufferAdaptor assetWriterInputPixelBufferAdaptorWithAssetWriterInput:_depthAssetWriterInput
                                                                                                sourcePixelBufferAttributes:@{
                                                                                                    (__bridge NSString*)kCVPixelBufferIOSurfacePropertiesKey : @{},
                                                                                                    (id)kCVPixelBufferPixelFormatTypeKey : @(DepthCapturePixelFormatType),
                                                                                                    (id)kCVPixelBufferWidthKey              : @(640),
                                                                                                    (id)kCVPixelBufferHeightKey             : @(360)}];

    if (!_depthPixelBufferAdaptor) {
        ORK_Log_Error("could not create depth pixel buffer adaptor");
        return NO;
    }

    if ([_videoAssetWriter canAddInput:_depthAssetWriterInput]) {
        [_videoAssetWriter addInput:_depthAssetWriterInput];
    }

    return YES;
}

- (BOOL)setupAssetWriterInputDepthMetadata {
    // create metadata asset writer input
    CMFormatDescriptionRef metadataFormat;
    NSArray *specs = @[@{(__bridge NSString *)kCMMetadataFormatDescriptionMetadataSpecificationKey_Identifier : RawSampleBufferAttachmentDictionary,
                         (__bridge NSString *)kCMMetadataFormatDescriptionMetadataSpecificationKey_DataType : (__bridge NSString *)kCMMetadataBaseDataType_RawData}];

    OSStatus err = CMMetadataFormatDescriptionCreateWithMetadataSpecifications(kCFAllocatorDefault,
                                                                               kCMMetadataFormatType_Boxed,
                                                                               (__bridge CFArrayRef)specs,
                                                                               &metadataFormat);
    if (err) {
        ORK_Log_Error("Error: Can't create metadata format description. Error status: %d", (int)err);
        CFRelease(metadataFormat);
        metadataFormat = nil;
        return NO;
    }

    _depthMetadataAssetWriterInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeMetadata outputSettings:nil sourceFormatHint:metadataFormat];
    if ([_videoAssetWriter canAddInput:_depthMetadataAssetWriterInput]) {
        [_videoAssetWriter addInput:_depthMetadataAssetWriterInput];
    }

    _depthAssetWriterInput.mediaTimeScale = 600;
    _depthMetadataAssetWriterInput.expectsMediaDataInRealTime = YES;
    [_depthMetadataAssetWriterInput addTrackAssociationWithTrackOfInput:_depthAssetWriterInput type:AVTrackAssociationTypeMetadataReferent];

    _depthMetadataAdaptor = [AVAssetWriterInputMetadataAdaptor assetWriterInputMetadataAdaptorWithAssetWriterInput:_depthMetadataAssetWriterInput];
    
    CFRelease(metadataFormat);
    
    return YES;
}

- (BOOL)setupAssetWriterInputVideoMetadata {
    CMFormatDescriptionRef metadataFormat;
    NSArray *specs = @[@{CMMetadataFormatDescriptionMetadataSpecificationKey_Identifier : RawSampleBufferAttachmentDictionary,
                         CMMetadataFormatDescriptionMetadataSpecificationKey_DataType : (__bridge NSString *)kCMMetadataBaseDataType_RawData}];

    OSStatus err = CMMetadataFormatDescriptionCreateWithMetadataSpecifications(kCFAllocatorDefault,
                                                                               kCMMetadataFormatType_Boxed,
                                                                               (__bridge CFArrayRef)specs,
                                                                               &metadataFormat);
    if (err) {
        ORK_Log_Error("Error: Can't create metadata format description. Error status: %d", (int)err);
        
        CFRelease(metadataFormat);
        metadataFormat = nil;
        return NO;
    }

    _videoMetadataAssetWriterInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeMetadata outputSettings:nil sourceFormatHint:metadataFormat];
    
    NSMutableArray* metadata = [@[[self getTrackMetadataForStream:TrackStreamTypeIdentifierFrontColor]] mutableCopy];
    _videoAssetWriterInput.metadata = [metadata copy];
    
    _videoMetadataAssetWriterInput.mediaTimeScale = 600;
    _videoMetadataAssetWriterInput.expectsMediaDataInRealTime = YES;
    [_videoMetadataAssetWriterInput addTrackAssociationWithTrackOfInput:_videoAssetWriterInput type:AVTrackAssociationTypeMetadataReferent];

    _videoMetadataAdaptor = [AVAssetWriterInputMetadataAdaptor assetWriterInputMetadataAdaptorWithAssetWriterInput:_videoMetadataAssetWriterInput];
    
    if ([_videoAssetWriter canAddInput:_videoMetadataAssetWriterInput]) {
        [_videoAssetWriter addInput:_videoMetadataAssetWriterInput];
    }
    
    CFRelease(metadataFormat);

    return YES;
}

- (BOOL)setupFrontCameraOnSession:(NSError **)error {

    if (@available(iOS 11.1, *)) {
        _frontCameraCaptureDevice = [AVCaptureDevice defaultDeviceWithDeviceType:AVCaptureDeviceTypeBuiltInTrueDepthCamera mediaType:AVMediaTypeVideo position:AVCaptureDevicePositionFront];

        [self configureDepthMapCameraFormatFor: _frontCameraCaptureDevice];
    } else {
        // Fallback on earlier versions
        _frontCameraCaptureDevice = [AVCaptureDevice defaultDeviceWithDeviceType:AVCaptureDeviceTypeBuiltInWideAngleCamera mediaType:AVMediaTypeVideo position:AVCaptureDevicePositionFront];
    }

    AVCaptureDeviceInput *frontCameraInput = [AVCaptureDeviceInput deviceInputWithDevice: _frontCameraCaptureDevice error: error];
    if (frontCameraInput) {
        if ([_captureSession canAddInput: frontCameraInput]) {
            [_captureSession addInput: frontCameraInput];
            
            [self configureCameraForHighestFrameRate: _frontCameraCaptureDevice];
            
            _sessionPreset = AVCaptureSessionPreset1920x1080;
            
            if ([_captureSession canSetSessionPreset: _sessionPreset]) {
                [_captureSession setSessionPreset: _sessionPreset];
            } else {
                if (error != NULL) {
                    *error = [NSError errorWithDomain:NSCocoaErrorDomain code:NSFeatureUnsupportedError userInfo:@{NSLocalizedDescriptionKey:ORKLocalizedString(@"AV_JOURNALING_STEP_CAMERA_ERROR", nil)}];
                }
                return NO;
            }
        } else {
            if (error != NULL) {
                *error = [NSError errorWithDomain:NSCocoaErrorDomain code:NSFeatureUnsupportedError userInfo:@{NSLocalizedDescriptionKey:ORKLocalizedString(@"AV_JOURNALING_STEP_CAMERA_ERROR", nil)}];
            }
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

- (void)configureDepthMapCameraFormatFor:(AVCaptureDevice *)device {
    AVCaptureDeviceFormat *selectFormat = nil;

    for (AVCaptureDeviceFormat *format in [device.activeFormat supportedDepthDataFormats]) {
        FourCharCode mediaSubtype = CMFormatDescriptionGetMediaSubType(format.formatDescription);
        if (mediaSubtype == kCVPixelFormatType_DepthFloat32 && format.highResolutionStillImageDimensions.height == 360) {
            selectFormat = format;
        }
    }

    NSError *error;

    [device lockForConfiguration:&error];

    if (!error) {
        device.activeDepthDataFormat = selectFormat;
    }

    [device unlockForConfiguration];
}

- (BOOL)setupAudioOnSession:(NSError **)error {
    _audioCaptureDevice = [AVCaptureDevice defaultDeviceWithMediaType: AVMediaTypeAudio];
    AVCaptureDeviceInput *audioInput = [AVCaptureDeviceInput deviceInputWithDevice:_audioCaptureDevice error:error];
    
    if ([_captureSession canAddInput: audioInput]) {
        [_captureSession addInput: audioInput];
    } else {
        if (error != NULL) {
            *error = [NSError errorWithDomain:NSCocoaErrorDomain code:NSFeatureUnsupportedError userInfo:@{NSLocalizedDescriptionKey:ORKLocalizedString(@"AV_JOURNALING_STEP_AUDIO_ERROR", nil)}];
        }
        return NO;
    }
    
    return YES;
}

- (BOOL)setupDataOutputForSession:(NSError **)error {
    if (!_audioDataOutput) {
        _audioDataOutput = [[AVCaptureAudioDataOutput alloc] init];
        if ([_captureSession canAddOutput:_audioDataOutput]) {
            [_captureSession  addOutput:_audioDataOutput];
        } else {
            if (error != NULL) {
                *error = [NSError errorWithDomain:NSCocoaErrorDomain code:NSFeatureUnsupportedError userInfo:@{NSLocalizedDescriptionKey:ORKLocalizedString(@"AV_JOURNALING_STEP_AUDIO_ERROR", nil)}];
            }
            return NO;
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
        } else {
            if (error != NULL) {
                *error = [NSError errorWithDomain:NSCocoaErrorDomain code:NSFeatureUnsupportedError userInfo:@{NSLocalizedDescriptionKey:ORKLocalizedString(@"AV_JOURNALING_STEP_CAMERA_ERROR", nil)}];
            }
            return NO;
        }
        
        // Required for VNFaceTracking
        AVCaptureConnection *connection = [_videoDataOutput connectionWithMediaType: AVMediaTypeVideo];
        connection.cameraIntrinsicMatrixDeliveryEnabled = YES;
        
        if ([connection isVideoOrientationSupported]) {
            connection.videoOrientation = AVCaptureVideoOrientationLandscapeRight;
        }
        
        if ([connection isVideoMirroringSupported]) {
            [connection setVideoMirrored:NO];
        }
        
        if ([connection isCameraIntrinsicMatrixDeliverySupported]) {
            [connection setCameraIntrinsicMatrixDeliveryEnabled:YES];
        }
    }
    
    if (!_metaDataOutput) {
        _metaDataOutput = [[AVCaptureMetadataOutput alloc] init];
        
        if ([_captureSession canAddOutput:_metaDataOutput]) {
            [_captureSession addOutput:_metaDataOutput];
            
            [_metaDataOutput setMetadataObjectTypes:@[AVMetadataObjectTypeFace]];
        }
    }

    if (!_depthDataOutput) {
        _depthDataOutput = [[AVCaptureDepthDataOutput alloc] init];

        if ([_captureSession canAddOutput:_depthDataOutput]) {
            [_captureSession addOutput:_depthDataOutput];
        }
    }
    
    if (!_outputSynchronizer) {
        _outputSynchronizer = [[AVCaptureDataOutputSynchronizer alloc] initWithDataOutputs:@[_videoDataOutput, _audioDataOutput, _metaDataOutput, _depthDataOutput]];
    }
    
    [_outputSynchronizer setDelegate:_synchronizerDelegate queue:_dataOutputQueue];
    
    return YES;
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
            [_videoMetadataAssetWriterInput markAsFinished];
            [_depthAssetWriterInput markAsFinished];
            [_depthMetadataAssetWriterInput markAsFinished];
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

- (CGRect)getUpdatedFaceBounds:(CGRect)faceBounds {
    
    //updated bounds for when the phone's orientation is in portrait
    CGRect updatedFaceBounds = CGRectMake(faceBounds.origin.y * _originalFrameSize.height,
                                          faceBounds.origin.x * _originalFrameSize.width,
                                          faceBounds.size.height * _originalFrameSize.height,
                                          faceBounds.size.width * _originalFrameSize.width);
    
    //updated bounds for when the phone's orientation is in landscape
    if ([self interfaceIsLandscape]) {
        updatedFaceBounds = CGRectMake(faceBounds.origin.x * _originalFrameSize.width,
                                       faceBounds.origin.y * _originalFrameSize.height,
                                       faceBounds.size.width * _originalFrameSize.width,
                                       faceBounds.size.height * _originalFrameSize.height);

    }
    
    return updatedFaceBounds;
}

- (CGSize)getUpdatedSize {
    //updated size for portrait
    CGSize size = CGSizeMake(_originalFrameSize.height, _originalFrameSize.width);
    
    if ([self interfaceIsLandscape]) {
        return _originalFrameSize;
    }
    
    return size;
}

- (BOOL)interfaceIsLandscape {
    return _interfaceOrientation == UIInterfaceOrientationLandscapeLeft || _interfaceOrientation == UIInterfaceOrientationLandscapeRight;
}

- (CVPixelBufferRef)blurSampleBuffer:(CMSampleBufferRef)sampleBuffer faceBounds:(CGRect)faceBounds {
    //Create Get CVImageBufferRef from sampleBuffer
    CVImageBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    CGSize imageSize = CVImageBufferGetDisplaySize(pixelBuffer);
    
    if (_bufferPool == NULL) {
        CreatePixelBufferPool(imageSize.width, imageSize.height, kCVPixelFormatType_32BGRA, &_bufferPool);
    }
    
    //Create CIImage from CVPixelBufferRef created above
    CFDictionaryRef attachments = CMCopyDictionaryOfAttachments(kCFAllocatorDefault, sampleBuffer, kCMAttachmentMode_ShouldPropagate);
    CIImage *image = [[CIImage alloc] initWithCVImageBuffer:pixelBuffer options:CFBridgingRelease(attachments)];
    
    //Create filter and set value
    CIFilter *filter = [CIFilter filterWithName:@"CIGaussianBlur"];
    [filter setValue:image forKey:kCIInputImageKey];
    [filter setValue:@20.0 forKey:kCIInputRadiusKey];
    
    //Create CIImage with filter applied
    CIImage *imageWithFilter = [filter valueForKey:kCIOutputImageKey];
    CIImage *combinedImage;
    
    if (faceBounds.size.height > 0 && faceBounds.size.width > 0) {
        CIImage *croppedImage;
        CIImage *croppedShouldersImage;
        CGRect shoulderBounds = CGRectZero;
        
        CGFloat faceWidth = faceBounds.size.width * imageSize.width;
        CGFloat faceHeight = faceBounds.size.height * imageSize.height;
        CGFloat faceOriginX = (imageSize.width) - (faceBounds.origin.x * imageSize.width) - faceHeight;
        CGFloat faceOriginY = (faceBounds.origin.y * imageSize.height);
        
        if (_interfaceOrientation == UIInterfaceOrientationLandscapeRight) {
            CGRect updatedFaceBounds = CGRectMake(faceOriginX * 0.8,
                                                  faceOriginY * 0.8,
                                                  faceWidth * 1.5,
                                                  faceHeight * 1.6);
            
            croppedImage = [image imageByCroppingToRect:updatedFaceBounds];
            shoulderBounds = CGRectMake(0,
                                        updatedFaceBounds.origin.y * 0.4,
                                        imageSize.width,
                                        (updatedFaceBounds.origin.y * 0.80));
        } else {
            CGRect updatedFaceBounds = CGRectMake(faceOriginX,
                                                  faceOriginY * 0.70,
                                                  faceWidth * 1.6,
                                                  faceHeight * 1.40);
            
            croppedImage = [image imageByCroppingToRect:updatedFaceBounds];
            shoulderBounds = CGRectMake(updatedFaceBounds.origin.x * 0.80,
                                        0,
                                        (updatedFaceBounds.origin.x * 0.40),
                                        imageSize.height);
        }
        
        croppedShouldersImage = [image imageByCroppingToRect:shoulderBounds];
        combinedImage = [croppedImage imageByCompositingOverImage:imageWithFilter];
        combinedImage = [croppedShouldersImage imageByCompositingOverImage:combinedImage];
    }
    
    //Use CIContext to create a CGImageRef
    CVPixelBufferRef newBuffer = NULL;
    CVPixelBufferPoolCreatePixelBuffer(NULL, _bufferPool, &newBuffer);
    
    if (combinedImage) {
        [_context render:combinedImage toCVPixelBuffer:newBuffer];
    } else {
        [_context render:imageWithFilter toCVPixelBuffer:newBuffer];
    }
    
    return newBuffer;
}

- (NSMutableArray *)arrayFromTransform:(simd_float3x3)transform {
    NSMutableArray *array = [NSMutableArray new];

    [array addObject:[[NSMutableArray alloc] initWithObjects:[NSNumber numberWithFloat:transform.columns[0].x], [NSNumber numberWithFloat:transform.columns[1].x], [NSNumber numberWithFloat:transform.columns[2].x], nil]];

    [array addObject:[[NSMutableArray alloc] initWithObjects:[NSNumber numberWithFloat:transform.columns[0].y], [NSNumber numberWithFloat:transform.columns[1].y], [NSNumber numberWithFloat:transform.columns[2].y], nil]];

    [array addObject:[[NSMutableArray alloc] initWithObjects:[NSNumber numberWithFloat:transform.columns[0].z], [NSNumber numberWithFloat:transform.columns[1].z], [NSNumber numberWithFloat:transform.columns[2].z], nil]];

    return array;
}

- (void)sessionWasInterrupted:(NSNotification *)notification {
    if (_sessionHelperDelegate != nil && [_sessionHelperDelegate respondsToSelector:@selector(sessionWasInterrupted)]) {
        [_sessionHelperDelegate sessionWasInterrupted];
    }
}

static CVReturn CreatePixelBufferPool(size_t width, size_t height, OSType format, CVPixelBufferPoolRef *pool) {
    CVReturn err = kCVReturnError;
    NSDictionary* attributes = @{
                                (id)kCVPixelBufferIOSurfacePropertiesKey : @{},
                                (id)kCVPixelBufferPixelFormatTypeKey : @(format),
                                (id)kCVPixelBufferWidthKey : @(width),
                                (id)kCVPixelBufferHeightKey: @(height),
                                (id)kCVPixelBufferPoolMinimumBufferCountKey : @(3),
                                };
    
    
    err = CVPixelBufferPoolCreate(kCFAllocatorDefault, nil, (__bridge CFDictionaryRef)(attributes), pool);
    if (err != kCVReturnSuccess) {
       //unable to create pool
       *pool = nil;
    }
    return err;
}

//creates CMSampleBuffer from CVPixelBuffer
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

- (void)attachMetadataVideoForPixelBuffer:(CVPixelBufferRef)pixelBufferRef presentationTime:(CMTime)presentationTime {
    if (_videoMetadataAssetWriterInput && [_videoMetadataAssetWriterInput isReadyForMoreMediaData]) {
    // encode special metadata for SaveFrames
        AVMutableMetadataItem *rawAttachmentMetadata = [AVMutableMetadataItem metadataItem];
        rawAttachmentMetadata.identifier = RawSampleBufferAttachmentDictionary;
        rawAttachmentMetadata.dataType = (__bridge NSString *)kCMMetadataBaseDataType_RawData;
        rawAttachmentMetadata.extraAttributes = nil;
        NSMutableDictionary* attachmentsToSave = [NSMutableDictionary new];
        NSData* rawAttachmentData = nil;
        NSDictionary* origTimestamp = (NSDictionary*)CFBridgingRelease(CMTimeCopyAsDictionary(presentationTime, kCFAllocatorDefault));
        [attachmentsToSave setObject:origTimestamp
                              forKey:MIOTimestampWhenWrittenToFileKey];

        // Serialize the metadata dictionary to plist if possible, else error out.
        NSError* error = nil;
        rawAttachmentData = [NSPropertyListSerialization dataWithPropertyList:(id)attachmentsToSave
                                                                       format:NSPropertyListBinaryFormat_v1_0
                                                                      options:0
                                                                        error:&error];
        if (![NSPropertyListSerialization propertyList: (id)rawAttachmentData isValidForFormat: NSPropertyListBinaryFormat_v1_0] || error != nil) {
            ORK_Log_Error("Error: The metadata dictionary is not valid for XML v1.0 plist Format. Error: %@", error);
        }

        rawAttachmentMetadata.value = rawAttachmentData;

        AVTimedMetadataGroup *metadataGroup = [[AVTimedMetadataGroup alloc] initWithItems:@[rawAttachmentMetadata]
                                                                                timeRange:CMTimeRangeMake(presentationTime, kCMTimeInvalid)];

        if (![_videoMetadataAdaptor appendTimedMetadataGroup:metadataGroup]) {
            ORK_Log_Error("Could not append timed video metadata. Error: %@", _videoAssetWriter.error);
        }
    }
}

- (void)attachMetadataDepthForPixelBuffer:(CVPixelBufferRef)pixelBufferRef presentationTime:(CMTime)presentationTime {
    if (_depthMetadataAssetWriterInput && [_depthMetadataAssetWriterInput isReadyForMoreMediaData]) {
        AVMutableMetadataItem *rawAttachmentMetadata = [AVMutableMetadataItem metadataItem];
        rawAttachmentMetadata.identifier = RawSampleBufferAttachmentDictionary;
        rawAttachmentMetadata.dataType = (__bridge NSString *)kCMMetadataBaseDataType_RawData;
        rawAttachmentMetadata.extraAttributes = nil;
        NSMutableDictionary* attachmentsToSave = [NSMutableDictionary new];
        NSData* rawAttachmentData = nil;
        NSDictionary* origTimestamp = (NSDictionary*)CFBridgingRelease(CMTimeCopyAsDictionary(presentationTime, kCFAllocatorDefault));
        [attachmentsToSave setObject:origTimestamp
                              forKey:MIOTimestampWhenWrittenToFileKey];

        // Serialize the metadata dictionary to plist if possible, else error out.
        NSError* error = nil;
        rawAttachmentData = [NSPropertyListSerialization dataWithPropertyList:(id)attachmentsToSave
                                                                       format:NSPropertyListBinaryFormat_v1_0
                                                                      options:0
                                                                        error:&error];
        if (![NSPropertyListSerialization
              propertyList: (id)rawAttachmentData
              isValidForFormat: NSPropertyListBinaryFormat_v1_0]) {
            ORK_Log_Error("Error: The metadata dictionary is not valid for XML v1.0 plist Format");
        }

        rawAttachmentMetadata.value = rawAttachmentData;

        AVTimedMetadataGroup *metadataGroup = [[AVTimedMetadataGroup alloc] initWithItems:@[rawAttachmentMetadata]
                                                                                timeRange:CMTimeRangeMake(presentationTime, kCMTimeInvalid)];

        if (![_depthMetadataAdaptor appendTimedMetadataGroup:metadataGroup]) {
            ORK_Log_Error("Error: Could not append timed depth metadata. Error: %@", _videoAssetWriter.error);
        }
    }
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

- (CVPixelBufferRef)quantizeDepthPixelBuffer:(CVPixelBufferRef)src {
    CVPixelBufferRef dst = NULL;
    if (src && _depthPixelBufferAdaptor) {
        CVPixelBufferCreate(kCFAllocatorDefault, CVPixelBufferGetWidth(src), CVPixelBufferGetHeight(src), DepthCapturePixelFormatType, NULL, &dst);
        if (dst) {
            size_t width  = CVPixelBufferGetWidth(src);
            size_t height = CVPixelBufferGetHeight(src);
            size_t dstStride = CVPixelBufferGetBytesPerRow(dst);

            CVPixelBufferLockBaseAddress(src, kCVPixelBufferLock_ReadOnly);
            CVPixelBufferLockBaseAddress(dst, 0);

            float *pSrc = (float *)CVPixelBufferGetBaseAddress(src);
            DepthPacket *pDst = (DepthPacket *) CVPixelBufferGetBaseAddress(dst);

            DepthPacket tmp[dstStride];
            DepthPacket *pTmp = tmp;

            for (size_t h = 0; h < height; h++) {
                float *pSrcRowStep = (float *)pSrc;
                DepthPacket *pTmpRowStep = pTmp;

                for (size_t w = 0; w < width; w++) {
                    float sourceValue = *pSrcRowStep;
                    sourceValue = (sourceValue / 20.0) * 65535; // normalize to [0, 1.0] and scale to 16-bit
                    pTmpRowStep->depth = sourceValue;
                    pTmpRowStep->padding = 0;

                    pTmpRowStep++;
                    pSrcRowStep++;
                }

                memcpy(pDst, pTmp, width * sizeof(pTmp));

                pSrc += width;
                pDst += width;
            }

            CVPixelBufferUnlockBaseAddress(src, kCVPixelBufferLock_ReadOnly);
            CVPixelBufferUnlockBaseAddress(dst, 0);
        }
    }

    return dst;
}

- (AVMetadataItem*)getTrackMetadataForStream:(NSString*)streamId
{
    AVMutableMetadataItem *trackMetadata = [AVMutableMetadataItem metadataItem];
    trackMetadata.identifier = TrackStreamTypeIdentifierKey;
    trackMetadata.dataType = (__bridge NSString *)kCMMetadataBaseDataType_UTF8;
    trackMetadata.extraAttributes = nil;
    trackMetadata.value = streamId;
    
    return trackMetadata;
}


@end
