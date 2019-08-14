/*
	File:			FigCaptureSessionConfiguration.h
	Description: 	Configuration object for FigCaptureSession. Designed to impedance match AVCaptureSession
	Authors:		Brad Ford and Walker Eagleston
	Creation Date:	10/11/13
	Copyright: 		© Copyright 2013-2018 Apple, Inc. All rights reserved.
*/

// This is conceptually a wrapper for a dictionary, with formalized API, so required fields are known.

#import <Celestial/FigCaptureCommon.h>
#import <Celestial/FigCaptureSource.h>
#import <Celestial/FigCaptureSourceFormat.h>
#import <Celestial/FigXPCCoding.h>

#import <CoreMedia/CMFormatDescription.h>
#import <CoreMedia/CMSync.h>
#import <CoreMedia/FigCaptureHideFeatures.h>

@class FigCaptureConnectionConfiguration, FigCaptureSourceConfiguration, FigCaptureSinkConfiguration;

#pragma mark - Session

@interface FigCaptureSessionConfiguration : NSObject <FigXPCCoding, NSCopying>

- (instancetype)init; // designated initializer

@property(nonatomic) int64_t configurationID;

- (void)addConnectionConfiguration:(FigCaptureConnectionConfiguration *)connectionConfiguration;
- (void)removeConnectionConfiguration:(FigCaptureConnectionConfiguration *)connectionConfiguration;

@property(nonatomic, readonly) NSArray *connectionConfigurations; // array of FigCaptureConnectionConfigurations
@property(nonatomic, readonly) NSArray *sourceConfigurations; // array of FigCaptureSourceConfigurations (all sources used in connections)
@property(nonatomic, readonly) NSArray *sinkConfigurations; // array of FigCaptureSinkConfigurations (all sinks used in connections)

// Properties global to the session
@property(nonatomic) BOOL usesAppAudioSession;
@property(nonatomic) BOOL configuresAppAudioSession;
@property(nonatomic) BOOL allowedToRunInWindowedLayout;
@property(nonatomic, getter=isMultiCamSession) BOOL multiCamSession;
@property(nonatomic) BOOL xctestAuthorizedToStealDevice;

@end


#pragma mark - Connection

@class FigCaptureIrisSinkConfiguration, FigCaptureStillImageSinkConfiguration, FigCaptureVideoDataSinkConfiguration, FigCaptureVideoPreviewSinkConfiguration, FigCaptureDepthDataSinkConfiguration, FigCaptureVideoThumbnailSinkConfiguration;

@interface FigCaptureConnectionConfiguration : NSObject <FigXPCCoding, NSCopying>

- (instancetype)init; // designated initializer

@property(nonatomic, copy) NSString *connectionID; // unique identifier for this connection within the session.

@property(nonatomic) CMMediaType mediaType;
@property(nonatomic) FigCaptureSourceDeviceType underlyingDeviceType; // underlying device type is used to specify a physical sub-device on an aggregate (i.e. sourceConfiguration.sourceDeviceType=Bravo + connection.underlyingDeviceType=Telephoto means want to run synchronized bravo and specifically connect the tele device to this output, and it never switches)

@property(nonatomic, retain) FigCaptureSourceConfiguration *sourceConfiguration; // From...
@property(nonatomic, retain) FigCaptureSinkConfiguration *sinkConfiguration; // To...

@property(nonatomic) BOOL enabled;

// Readonly methods

// All of these methods return .sinkConfiguration with the right type cast, or nil if .sinkConfiguration is not of this type
@property(readonly) FigCaptureIrisSinkConfiguration *irisSinkConfiguration;
@property(readonly) FigCaptureStillImageSinkConfiguration *stillImageSinkConfiguration;
@property(readonly) FigCaptureVideoDataSinkConfiguration *videoDataSinkConfiguration;
@property(readonly) FigCaptureVideoPreviewSinkConfiguration *videoPreviewSinkConfiguration;
@property(readonly) FigCaptureDepthDataSinkConfiguration *depthDataSinkConfiguration;
@property(readonly) FigCaptureVideoThumbnailSinkConfiguration *thumbnailSinkConfiguration;

@end


@interface FigVideoCaptureConnectionConfiguration : FigCaptureConnectionConfiguration

// Pixel or compressed video type + width + height should be enough to figure out buffer pool requirements.
@property(nonatomic) int32_t outputFormat; // avc1, jpeg, 420f, etc.  May be 0 if there is no output format requirement

@property(nonatomic) int32_t outputWidth; // may be 0 if there is no output width requirement
@property(nonatomic) int32_t outputHeight; // may be 0, if there is no output height requirement
// The output dimensions are specified after the orientation transform is applied
// So if you have 640x480 video and want to rotate from native landscape right to portrait then specify 480x640 as opposed to 640x480

// Not used yet, this for the desktop with its fancy framerate governers
//@property(nonatomic) float outputMaxFrameRate; // may be 0. Only needed if this output requires a different frame rate than the source provides
//@property(nonatomic) float outputMinFrameRate; // may be 0. Only needed if this output requires a different frame rate than the source provides

// For still capture, fully-formed output settings are delivered when one takes a still image
// For file outputs, fully-formed output settings are delivered when one starts capturing to a file.
// For video data output, fully-formed output settings must be specified here and now.
// TEMPORARILY REMOVING as we don't support compressed VDO on iOS.
//@property(nonatomic, copy) NSDictionary *videoSettings; // like the AVF keys.

@property(nonatomic) FigCaptureVideoStabilizationMethod videoStabilizationMethod;
@property(nonatomic) BOOL mirroringEnabled;
@property(nonatomic) FigCaptureVideoOrientation orientation; // May be unspecified (value = 0)

@property(nonatomic) int32_t retainedBufferCount; // should be 0 if client has no retained buffer count requirement

@property(nonatomic) BOOL cameraIntrinsicMatrixDeliveryEnabled;

// This property allows the writing of FigLivePhotoMetadata for any video, not just a LivePhoto.
// NOTE:  this property does not effect the writing of Live Photo movies, which always get a
// timed metadata track containing FigLivePhotoMetadata.
@property(nonatomic) BOOL livePhotoMetadataWritingEnabled;

@end


@interface FigAudioCaptureConnectionConfiguration : FigCaptureConnectionConfiguration
// For audio data output, fully-formed output settings must be specified here and now.
// @property(nonatomic, copy) NSDictionary *audioSettings; // like the AVF keys.
// Used on the desktop

// These properties are on the connection and not the FigCaptureSourceConfiguration because in iOS, the system only has one audio FigCaptureSource (just as the system has one VAD). In order to get different microphone beam-forms, we have to process the mics on the audio capture source differently within our graph.
@property(nonatomic) BOOL builtInMicrophoneStereoAudioCaptureEnabled;
@property(nonatomic) FigCaptureSourcePosition builtInMicrophonePosition; // Unspecified = omni (default), Back = beam-form to the back, Front = beam-form to the front.

@end


@interface FigMetadataObjectCaptureConnectionConfiguration : FigCaptureConnectionConfiguration

@property(nonatomic, copy) NSArray *metadataIdentifiers; // array of kCMMetadataIdentifier_*
@property(nonatomic) CGRect metadataRectOfInterest;

@end


@interface FigMetadataItemCaptureConnectionConfiguration : FigCaptureConnectionConfiguration

typedef NS_ENUM( int32_t, FigCaptureMetadataSourceSubType ) {
	FigCaptureMetadataSourceSubTypeClientSupplied  = 1,
	FigCaptureMetadataSourceSubTypeCoreMotion = 2,
	FigCaptureMetadataSourceSubTypeCamera = 3,	// Camera supplying something like detected faces
};

// For connections involving a metadata source, this format description describes the metadata to be delivered
@property(nonatomic, retain) CMFormatDescriptionRef __attribute__((NSObject)) formatDescription;
@property(nonatomic, retain) CMClockRef __attribute__((NSObject)) clock;
@property(nonatomic) FigCaptureMetadataSourceSubType sourceSubType;

@end


@interface FigDepthDataCaptureConnectionConfiguration : FigVideoCaptureConnectionConfiguration
// Depth data connections have all the same properties as video connections. We'll add new depth specific properties here as needed.
@end


@interface FigVisionDataCaptureConnectionConfiguration : FigVideoCaptureConnectionConfiguration
// Vision data connections have all the same properties as video connections.
@end


#pragma mark - Source

@interface FigCaptureSourceConfiguration : NSObject <FigXPCCoding, NSCopying>

CM_INIT_UNAVAILABLE

- (instancetype)initWithSource:(FigCaptureSourceRef)source;
- (instancetype)initWithSourceType:(FigCaptureSourceType)sourceType; // This initializer is only used for sources that don't have a FigCaptureSourceRef, such as AVCaptureMetadataInput

@property(nonatomic, copy) NSString *sourceID;
@property(nonatomic, readonly) __attribute__((NSObject)) FigCaptureSourceRef source;
@property(nonatomic, retain) FigCaptureSourceVideoFormat *requiredFormat; // must be non-nil
@property(nonatomic) float requiredMaxFrameRate; // must be non-zero
@property(nonatomic) float requiredMinFrameRate; // must be non-zero
@property(nonatomic) float maxFrameRateClientOverride; // the client will not ask for a frame rate higher than this while running (and AVF enforces this)
@property(nonatomic) float maxGainClientOverride;
@property(nonatomic) BOOL hasSetVideoZoomFactorOnCaptureSource; // Fig only, *not* serialized
@property(nonatomic) float videoZoomFactor; // Must be >= 1.
@property(nonatomic) float videoZoomRampAcceleration;
@property(nonatomic, copy) NSDictionary *faceDetectionConfiguration; // contains eye/blink/smile detection enabled switches, uses kFigCaptureSourceOptionalFaceDetectionFeatureKey_[feature]

+ (NSString *)stringForSourceType:(FigCaptureSourceType)sourceType;
+ (FigCaptureSourceType)sourceTypeForString:(NSString *)sourceTypeName;
+ (NSString *)stringForSourcePosition:(FigCaptureSourcePosition)sourcePosition;
+ (NSString *)stringForSourceDeviceType:(FigCaptureSourceDeviceType)sourceDeviceType;
@property(nonatomic, readonly) FigCaptureSourcePosition sourcePosition;
@property(nonatomic, readonly) FigCaptureSourceType sourceType;
@property(nonatomic, readonly) FigCaptureSourceDeviceType sourceDeviceType;

@property(nonatomic) FigCaptureSourceImageControlMode imageControlMode;
@property(nonatomic) BOOL applyMaxExposureDurationFrameworkOverrideWhenAvailable; // This used to be applyMaxIntegrationTimeOverrideWhenAvailable.
@property(nonatomic) CMTime maxExposureDurationClientOverride; // kCMTimeInvalid if no override.
@property(nonatomic) BOOL sensorHDREnabled;
@property(nonatomic) BOOL highlightRecoveryEnabled;
@property(nonatomic) FigCaptureColorSpace colorSpace;
@property(nonatomic) BOOL depthDataDeliveryEnabled; // true if any output is delivering depth
@property(nonatomic) float depthDataMaxFrameRate;

@property(nonatomic, retain) FigCaptureSourceDepthDataFormat *depthDataFormat; // can be nil

@property(nonatomic) BOOL lowLightVideoCaptureEnabled;

#if FIG_CAPTURE_THE_MOMENT_SUPPORTED
@property(nonatomic) BOOL spatialOverCaptureEnabled;
@property(nonatomic) BOOL nonDestructiveCropEnabled;
#endif // FIG_CAPTURE_THE_MOMENT_SUPPORTED

#if FIG_SHOW_H12_FEATURES
@property(nonatomic) BOOL geometricDistortionCorrectionEnabled;
#endif // FIG_SHOW_H12_FEATURES

@end


#pragma mark - Sink

typedef NS_ENUM( int32_t, FigCaptureSinkType ) {
	FigCaptureSinkTypeVideoPreview			= 1,
	FigCaptureSinkTypeAudioPreview			= 2,
	FigCaptureSinkTypeStillImage			= 3,
	FigCaptureSinkTypeMovieFile				= 4,
	FigCaptureSinkTypeAudioFile				= 5,
	FigCaptureSinkTypeVideoData				= 6,
	FigCaptureSinkTypeAudioData				= 7,
	FigCaptureSinkTypeMetadataObject		= 8,
	FigCaptureSinkTypeMetadataItemGroup		= 9,
	FigCaptureSinkTypeIris					= 10,
	FigCaptureSinkTypeDepthData				= 11,
	FigCaptureSinkTypeVideoThumbnail		= 12,
	FigCaptureSinkTypeVisionData			= 13,
	// Internal sinks are sinks that created by FigCaptureSessionParsedConfiguration, as opposed to all other sinks which are sent down from AVFoundation.
	// See FigCaptureInternalSinkSubType for the list of internal sinks.
	FigCaptureSinkTypeInternal				= 14,
};

@interface FigCaptureSinkConfiguration : NSObject <FigXPCCoding, NSCopying>

@property(nonatomic, copy) NSString *sinkID; // unique identifier for this sink within the session.
@property(nonatomic, readonly) FigCaptureSinkType sinkType;

+ (NSString *)stringForSinkType:(FigCaptureSinkType)sinkType;

@end


@interface FigCaptureVideoPreviewSinkConfiguration : FigCaptureSinkConfiguration

@property(nonatomic) BOOL depthDataDeliveryEnabled;
@property(nonatomic) BOOL filterRenderingEnabled;
@property(nonatomic, copy) NSArray *filters; // NSArray<CIFilter *> *
@property(nonatomic) float simulatedAperture;
#if FIG_CAPTURE_ADJUSTABLE_PORTRAIT_LIGHTING_STRENGTH
@property(nonatomic) float portraitLightingEffectStrength; // Defaults to NAN
#endif // FIG_CAPTURE_ADJUSTABLE_PORTRAIT_LIGHTING_STRENGTH
#if FIG_CAPTURE_OVERCAPTURE_SUPPORTED
// OverCapture
@property(nonatomic) BOOL primaryCaptureRectModificationEnabled; // When YES the primaryCaptureRect properties below are honored and kFigCaptureSessionPreviewSinkProperty_PrimaryCaptureRect may be set.
@property(nonatomic) CGFloat primaryCaptureRectAspectRatio;
@property(nonatomic) CGPoint primaryCaptureRectCenter;
#endif

@end


@interface FigCaptureVideoThumbnailSinkConfiguration : FigCaptureSinkConfiguration

@property(nonatomic) CGSize thumbnailSize;
@property(nonatomic, copy) NSArray *filters; //NSArray<CIFilter *> *

@end


@interface FigCaptureAudioPreviewSinkConfiguration : FigCaptureSinkConfiguration
@end


@interface FigCaptureStillImageSinkConfiguration : FigCaptureSinkConfiguration

@property(nonatomic) BOOL quadraHighResCaptureEnabled;

@end


@interface FigCaptureMovieFileSinkConfiguration : FigCaptureSinkConfiguration
@end


@interface FigCaptureAudioFileSinkConfiguration : FigCaptureSinkConfiguration
@end


@interface FigCaptureVideoDataSinkConfiguration : FigCaptureSinkConfiguration

@property(nonatomic) BOOL discardsLateVideoFrames;
@property(nonatomic) BOOL derivedFromPreview; // if YES this is a preview video data output
//@property(nonatomic) BOOL sendDroppedFrames; // not supported yet

@end


@interface FigCaptureAudioDataSinkConfiguration : FigCaptureSinkConfiguration
@end


@interface FigCaptureMetadataObjectSinkConfiguration : FigCaptureSinkConfiguration
@end


@interface FigCaptureMetadataItemGroupSinkConfiguration : FigCaptureSinkConfiguration
@end


typedef NS_ENUM( int32_t, FigCaptureInternalSinkSubType ) {
	FigCaptureInternalSinkSubTypePreviewTimeMachine	= 0,
	FigCaptureInternalSinkSubTypeSceneClassifier		= 1,
#if FIG_CAPTURE_OBJECT_TRACKING_SUPPORTED
	FigCaptureInternalSinkSubTypeObjectTracker			= 2,
#endif // FIG_CAPTURE_OBJECT_TRACKING_SUPPORTED
};

@interface FigCaptureInternalSinkConfiguration : FigCaptureSinkConfiguration

CM_INIT_UNAVAILABLE

- (instancetype)initWithSinkSubType:(FigCaptureInternalSinkSubType)subType;

@property(nonatomic, readonly) FigCaptureInternalSinkSubType subType;

@end


@class FigCaptureIrisPreparedSettings;

@interface FigCaptureIrisSinkConfiguration : FigCaptureSinkConfiguration

typedef NS_ENUM( int32_t, FigIrisMovieAutoTrimMethod ) {
	FigIrisMovieAutoTrimMethodNone			= 0,
	FigIrisMovieAutoTrimMethodDestructive	= 1,
	FigIrisMovieAutoTrimMethodReversible	= 2,
};

// Movie specific options
@property(nonatomic) BOOL irisMovieCaptureEnabled; // if disabled, no need to make the iris movie pipeline and ring buffers
@property(nonatomic) CMTime irisMovieDuration;
@property(nonatomic) CMTime irisMovieVideoFrameDuration; // 1 / the desired frame rate.
@property(nonatomic) FigIrisMovieAutoTrimMethod irisMovieAutoTrimMethod; // Default is FigIrisAutoTrimMethodNone
@property(nonatomic) BOOL irisFrameHarvestingEnabled;
@property(nonatomic, retain) FigCaptureIrisPreparedSettings *irisPreparedSettings;

@property(nonatomic) BOOL optimizesImagesForOfflineVideoStabilization; // for timelapse
@property(nonatomic) BOOL quadraHighResCaptureEnabled;
@property(nonatomic) BOOL depthDataDeliveryEnabled;
@property(nonatomic) BOOL portraitEffectsMatteDeliveryEnabled;
#if FIG_CAPTURE_SEMANTIC_SEGMENTATION_ENABLED
@property(nonatomic, retain) NSArray *enabledSemanticSegmentationMatteURNs; // The superset of segmentation matte types the user might ask for on a per-shot basis. Valid URNs are enumerated in FigPhotoTypes.h (kFigPhotoAuxiliaryImageTypeURN_SemanticXXXMatte)
#endif // FIG_CAPTURE_SEMANTIC_SEGMENTATION_ENABLED
@property(nonatomic) BOOL filterRenderingEnabled;
@property(nonatomic) BOOL bravoConstituentPhotoDeliveryEnabled;
#if FIG_CAPTURE_THE_MOMENT_SUPPORTED
@property(nonatomic) BOOL momentCaptureMovieRecordingEnabled;
#endif // FIG_CAPTURE_THE_MOMENT_SUPPORTED
@property(nonatomic) FigCaptureQualityPrioritization maxQualityPrioritization;
#if FIG_CAPTURE_DEFERRED_PROCESSING_SUPPORTED
@property(nonatomic) BOOL deferredProcessingEnabled;
#endif // FIG_CAPTURE_DEFERRED_PROCESSING_SUPPORTED
#if FIG_CAPTURE_LOW_LIGHT_SUPPORTED
@property(nonatomic) BOOL digitalFlashCaptureEnabled;
#endif // FIG_CAPTURE_LOW_LIGHT_SUPPORTED

@end

@interface FigCaptureDepthDataSinkConfiguration : FigCaptureSinkConfiguration

@property(nonatomic) BOOL discardsLateDepthData;
@property(nonatomic) BOOL filteringEnabled;

@end

@interface FigCaptureVisionDataSinkConfiguration : FigCaptureSinkConfiguration

@property(nonatomic) float maxFrameRate;
@property(nonatomic) float maxBurstFrameRate;
@property(nonatomic) CMTime maxBurstDuration;
@property(nonatomic) uint32_t gaussianPyramidOctavesCount;
@property(nonatomic) float gaussianPyramidBaseOctaveDownscalingFactor;
@property(nonatomic) uint32_t maxKeypointsCount;
@property(nonatomic) float keypointDetectionThreshold;
@property(nonatomic) BOOL featureBinningEnabled;
@property(nonatomic) BOOL featureOrientationAssignmentEnabled;

@property(nonatomic, readonly) NSDictionary *embeddedCaptureDeviceConfiguration; // key/value pairs are listed in FigEmbeddedCaptureDevice.h under kFigCaptureStreamVideoOutputConfigurationKey_VisionDataConfiguration

@end
