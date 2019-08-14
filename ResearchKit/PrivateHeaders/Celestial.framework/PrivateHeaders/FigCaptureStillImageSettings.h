/*
	File:			FigCaptureStillImageSettings.h
	Description: 	Abstraction for still image settings designed to impedance match AVCaptureStillImageOutput
	Authors:		Brad Ford and Walker Eagleston
	Creation Date:	10/11/13
	Copyright: 		Copyright © 2013-2018 Apple Inc. All rights reserved.
*/

// This is conceptually a wrapper for a dictionary, with formalized API, so required fields are known.
// The object supports NSCoding, so it can be easily serialized, making it usable on both client and server.

#import <CoreMedia/CMBasePrivate.h>
#import <CoreMedia/FigTimePlatform.h>
#import <CoreMedia/FigCaptureHideFeatures.h>

#import <Celestial/FigCaptureCommon.h>
#import <Celestial/FigXPCCoding.h>

#import <CoreGraphics/CGGeometry.h>
#import <CoreMedia/FigCaptureHideFeatures.h>

typedef NS_ENUM( int32_t, FigCaptureWideColorMode ) {
	FigCaptureWideColorModeOff	= 0,
	FigCaptureWideColorModeOn	= 1,
	FigCaptureWideColorModeAuto	= 2
};

typedef NS_ENUM( int32_t, FigCaptureBracketType ) {
	FigCaptureBracketTypeNone				= 0,
	FigCaptureBracketTypeManualExposure		= 1,
	FigCaptureBracketTypeAutoExposure		= 2,
};

typedef NS_ENUM( int32_t, FigCaptureStillImagePayloadType ) {
	FigCaptureStillImagePayloadTypeSampleBuffer	= 0,
	FigCaptureStillImagePayloadTypeIOSurfaces	= 1,
};

typedef NS_ENUM( int32_t, FigCaptureStillImageSettingsProvider ) {
	FigCaptureStillImageSettingsProviderStillImageOutput	 = 0,
	FigCaptureStillImageSettingsProviderIrisStillImageOutput = 1,
};

typedef NS_ENUM( int32_t, FigCaptureStillImageSettingsFileType ) {
	FigCaptureStillImageSettingsFileTypeJFIF	= 'jfif',
	FigCaptureStillImageSettingsFileTypeHEIF	= 'heif',
	FigCaptureStillImageSettingsFileTypeHEIC	= 'heic',
	FigCaptureStillImageSettingsFileTypeAVCI	= 'avci',
	FigCaptureStillImageSettingsFileTypeTIFF	= 'tiff',
	FigCaptureStillImageSettingsFileTypeDNG		= 'dneg',
};

@class FigCaptureIrisPreparedSettings;

@interface FigCaptureStillImageSettings : NSObject <NSSecureCoding, NSCopying>

// FigCaptureStillImageSettings must be initialized with initWithSettingsID:
CM_INIT_UNAVAILABLE

// The settingsID must be non-zero
- (instancetype)initWithSettingsID:(int64_t)settingsID /* NS_DESIGNATED_INITIALIZER */;

@property(nonatomic, readonly) int64_t settingsID; // unique identifier used by the client to track this still image capture request

@property(nonatomic) FigCaptureStillImagePayloadType payloadType;
@property(nonatomic) FigCaptureStillImageSettingsProvider settingsProvider;

// When the width/height don't match the source aspect ratio we will crop to make up the difference

@property(nonatomic) uint32_t outputFormat; // 'jpeg', '420f', etc.
@property(nonatomic) FigCaptureStillImageSettingsFileType outputFileType;
@property(nonatomic) uint32_t rawOutputFormat; // 'bgg4', etc. outputFormat will be set to 0 if only raw output is desired
@property(nonatomic) FigCaptureStillImageSettingsFileType rawOutputFileType;

// The default value of 0,0 means take a still at native resolution.
// For now 0,0 is used by AVF when requesting high res stills.
// For normal stills the output width/height are specified by AVF and will equal the active video format's streaming dimensions.
// In the future an enum with high res vs regular would be better.
@property(nonatomic) uint32_t outputWidth;
@property(nonatomic) uint32_t outputHeight;

// When YES the output image is cropped so that it is square.
// The output dimensions are used as a starting point when they are specified.
// The longer dimensions will be shrunk to equal the shorter.
@property(nonatomic) BOOL squareCropEnabled;

@property(nonatomic) BOOL outputMirroring;
@property(nonatomic) FigCaptureVideoOrientation outputOrientation;
@property(nonatomic, readonly) NSDictionary *outputPixelBufferAttributes; // if the format can be expressed as pba's, this property is non-nil
@property(nonatomic, readonly, getter=isOutputFormatCompressed) BOOL outputFormatCompressed;

// optional preview image requirements
@property(nonatomic) BOOL previewEnabled;
@property(nonatomic) uint32_t previewFormat; // '420f', 'BGRA', etc.
@property(nonatomic) uint32_t previewWidth;
@property(nonatomic) uint32_t previewHeight;
@property(nonatomic) BOOL previewMirroring;
@property(nonatomic) FigCaptureVideoOrientation previewOrientation;
@property(nonatomic, readonly) NSDictionary *previewPixelBufferAttributes; // if the format can be expressed as pba's, this property is non-nil

//optional embedded thumbnail image requirements
@property(nonatomic) BOOL thumbnailEnabled;
@property(nonatomic) uint32_t thumbnailFormat; // 'jpeg', 'hvc1', etc.
@property(nonatomic) uint32_t thumbnailWidth;
@property(nonatomic) uint32_t thumbnailHeight;
// thumbnail mirroring/orientation should always mimic the main output

//optional raw embedded thumbnail image requirements
@property(nonatomic) BOOL rawThumbnailEnabled;
@property(nonatomic) uint32_t rawThumbnailFormat; // 'jpeg', 'hvc1', etc.
@property(nonatomic) uint32_t rawThumbnailWidth;
@property(nonatomic) uint32_t rawThumbnailHeight;
// thumbnail mirroring/orientation should always mimic the main output

@property(nonatomic) BOOL noiseReductionEnabled; // TODO: might need an algorithm to specify (Chroma/MultiBand/etc.)
@property(nonatomic) BOOL burstQualityCaptureEnabled; // This photo request is part of a burst capture

@property(nonatomic) float scaleFactor; // This aligns with the AVCaptureConnection.videoScaleAndCropFactor, so it's actually a crop and upscale (unless zoomWithoutUpscalingEnabled is YES, in which case it just crops)
#if FIG_SHOW_H12_FEATURES
@property(nonatomic, getter=isZoomWithoutUpscalingEnabled) BOOL zoomWithoutUpscalingEnabled; // when enabled, the still image pipeline returns a cropped, but not upscaled image.
#endif // FIG_SHOW_H12_FEATURES

@property(nonatomic) uint32_t shutterSound; // sound to play when taking still image

@property(nonatomic) FigCaptureFlashMode flashMode;
@property(nonatomic) BOOL autoRedEyeReductionEnabled;

#if FIG_CAPTURE_LOW_LIGHT_SUPPORTED
@property(nonatomic) FigCaptureDigitalFlashMode digitalFlashMode;
#endif // FIG_CAPTURE_LOW_LIGHT_SUPPORTED

@property(nonatomic) FigCaptureWideColorMode wideColorMode;

@property(nonatomic) FigCaptureHDRMode HDRMode;
@property(nonatomic) BOOL depthDataDeliveryEnabled;
@property(nonatomic) BOOL embedsDepthDataInImage;
@property(nonatomic) BOOL depthDataFiltered;
@property(nonatomic) BOOL cameraCalibrationDataDeliveryEnabled;
@property(nonatomic) BOOL portraitEffectsMatteDeliveryEnabled;
@property(nonatomic) BOOL embedsPortraitEffectsMatteInImage;
#if FIG_CAPTURE_SEMANTIC_SEGMENTATION_ENABLED
@property(nonatomic, retain) NSArray *enabledSemanticSegmentationMatteURNs; // valid URNs are enumerated in FigPhotoTypes.h (kFigPhotoAuxiliaryImageTypeURN_SemanticXXXMatte)
@property(nonatomic) BOOL embedsSemanticSegmentationMattesInImage;
#endif // FIG_CAPTURE_SEMANTIC_SEGMENTATION_ENABLED
@property(nonatomic, copy) NSDictionary *metadata; // can be nil, a dictionary of CGImageProperties keys
@property(nonatomic, copy) NSDictionary *metadataForOriginalImage; // can be nil, a dictionary of CGImageProperties keys
@property(nonatomic, copy) NSArray *originalImageFilters; // can be nil, this is actually NSArray<CIFilter *> *
@property(nonatomic, copy) NSArray *processedImageFilters; // can be nil, this is actually NSArray<CIFilter *> *
@property(nonatomic) float simulatedAperture; // defaults to 0.
#if FIG_CAPTURE_ADJUSTABLE_PORTRAIT_LIGHTING_STRENGTH
@property(nonatomic) float portraitLightingEffectStrength; // defaults to NAN.
#endif // FIG_CAPTURE_ADJUSTABLE_PORTRAIT_LIGHTING_STRENGTH
@property(nonatomic) BOOL providesOriginalImage;
@property(nonatomic, copy) NSArray *bravoConstituentImageDeliveryDeviceTypes; // can be nil, this is actually NSArray<FigCaptureSourceDeviceType> (as NSNumbers)
#if FIG_CAPTURE_THE_MOMENT_SUPPORTED
@property(nonatomic) BOOL autoSpatialOverCaptureEnabled; // enable spatial overcapture for photos, if conditions are suitable.
@property(nonatomic, copy) NSDictionary *spatialOverCaptureMetadata;
@property(nonatomic, copy) NSDictionary *spatialOverCaptureMetadataForOriginalImage;
#endif // FIG_CAPTURE_THE_MOMENT_SUPPORTED
#if FIG_CAPTURE_DEFERRED_PROCESSING_SUPPORTED
@property(nonatomic) BOOL autoDeferredProcessingEnabled;
#endif // FIG_CAPTURE_DEFERRED_PROCESSING_SUPPORTED

@property(nonatomic) FigCaptureQualityPrioritization qualityPrioritization;
@property(nonatomic) FigCaptureBravoImageFusionMode bravoImageFusionMode;

@property(nonatomic, copy) NSDictionary *vtCompressionProperties;
// For JPEGs/HEICs this may include kVTCompressionPropertyKey_Quality

- (void)setBracketType:(FigCaptureBracketType)bracketType imageCount:(uint32_t)bracketImageCount;
@property(nonatomic, readonly) FigCaptureBracketType bracketType;
@property(nonatomic, readonly) uint32_t bracketImageCount;
@property(nonatomic) BOOL lensStabilizationDuringBracketEnabled;

// Manual Exposure Bracket Properties
@property(nonatomic, readonly) CMTime *exposureDurations;
@property(nonatomic, readonly) float *ISOs;

// Auto Exposure Bracket Properties
@property(nonatomic, readonly) float *exposureTargetBiases;

- (FigCaptureIrisPreparedSettings *)figCaptureIrisPreparedSettingsRepresentation;

// The mach_absolute_time() at the time the user initiated the still image. Is only used by Camera.app, and is filled out for Photo and Portrait mode captures, except bursts, and for stills during video.
@property(nonatomic) uint64_t stillImageUserInitiatedRequestTime;

// FIG ONLY (STARTING HERE)
@property(nonatomic) CMTime stillImageUserInitiatedRequestPTS; // The preview PTS at stillImageUserInitiatedRequestTime
@property(nonatomic) FigHostTime stillImageRequestTime; // Time request was received
@property(nonatomic) FigHostTime stillImageCaptureStartTime;   // Time processing was started
// Properties on FigCaptureStillImageSettings are usually set by AVF, but "stillImageStartTime" is set within the FigCapture stack.
// It is only used if FIG_NOTE_ENABLE, but that can have different values in different files, so we'll just burn the 8 bytes
// unconditionally.

// This is used where still image capture start time needs to be converted to local time like NSDate for debug purposes.
// This should not be used for performance measurement as the clock is not guaranteed to be monotonically increasing.
@property(nonatomic) CFAbsoluteTime stillImageCaptureAbsoluteStartTime;

@property(nonatomic, readonly) NSString *imageGroupIdentifier; // Capture requests that result in multiple returned images will be tagged with this identifier in the AppleMakerNote, specifically the EV0 and HDR of an HDR+EV0 pair, the original and SDOF of an SDOF+original pair, the processed and RAW of a RAW+processed pair, and all the images in a client bracket. (not for use in AVF, so this identifier is not serialized)

// This is an identifier used to uniquely identify all images buffers, metadata, etc. from a single FigCaptureStillImageSettings object.
// All photos delivered from this request will have this same identifier associated with them.
// 
// When deferred processing for photos, this is one of two identifiers that must be passed in for each photo being processed to the FigCaptureDeferredPhotoProcessor
// (the other being a unique, per-photo identifier advertised as the AVCaptureDeferredPhotoProxy.persistentStorageUUID).
//
// Note that this is *not* the same as the ImageGroupIdentifier that's stored in the MakerNote -- that is used to pair multiple images in the Camera Roll
// from the same shot, such as an HDR+EV0, or a burst capture sequence.
@property(nonatomic, readonly) NSString *captureRequestIdentifier;

@property(nonatomic, getter=isClientInitiatedPrepareSettings) BOOL clientInitiatedPrepareSettings; // This is set by the FigCaptureSession only at the time the prepare is invoked.
@property(nonatomic, getter=isUserInitiatedRequestSettings) BOOL userInitiatedRequestSettings; // This is only used by the Still Image Coordinator.
#if	FIG_CAPTURE_THE_MOMENT_SUPPORTED
@property(nonatomic, getter=isBeginMomentCaptureSettings) BOOL beginMomentCaptureSettings; // This is only used by the Still Image Coordinator.
#endif // FIG_CAPTURE_THE_MOMENT_SUPPORTED
#if FIG_CAPTURE_OVERCAPTURE_SUPPORTED
@property(nonatomic) float videoStabilizationOverscanCropMultiplier;
#endif // FIG_CAPTURE_OVERCAPTURE_SUPPORTED

// FIG ONLY (ENDING HERE)

@end


typedef NS_ENUM( int32_t, FigCaptureIrisMovieMode ) {
	FigCaptureIrisMovieModeOff		 = 0,
	FigCaptureIrisMovieModeOn		 = 1,
	FigCaptureIrisMovieModeUnbounded = 2, // CTM movie that doesn't end on its own
};

@class FigCaptureMovieFileRecordingSettings;

@interface FigCaptureIrisStillImageSettings : FigCaptureStillImageSettings

@property(nonatomic) FigCaptureIrisMovieMode movieMode;
@property(nonatomic, copy) FigCaptureMovieFileRecordingSettings *movieRecordingSettings; // contains URL for main movie as well as spatial over capture movie.
@property(nonatomic, copy) NSURL *movieURLForOriginalImage;
@property(nonatomic, copy) NSArray *movieLevelMetadataForOriginalImage; // Matches the format accepted by FigAssetWriter's kFigAssetWriterProperty_Metadata property

#if FIG_CAPTURE_THE_MOMENT_SUPPORTED
@property(nonatomic, copy) NSURL *spatialOverCaptureMovieURLForOriginalImage;
@property(nonatomic, copy) NSArray *spatialOverCaptureMovieLevelMetadataForOriginalImage; // Matches the format accepted by FigAssetWriter's kFigAssetWriterProperty_Metadata property
#endif // FIG_CAPTURE_THE_MOMENT_SUPPORTED

@property(nonatomic) CGSize nonDestructiveCropSize; // NOTE that this is currently unused (there's no SPI/API to set a non destructive crop rect on a photo, only on the source device).

@end


// The small subset of features in FigCaptureStillImageSettings that are needed for preparing/reclaiming graph resources.
// Unlike FigCaptureStillImageSettings, this object is FigXPCCoding compliant, so it can be included as part of the payload to FigCaptureSessionSetConfiguration which uses XPCCoding. FigCaptureSessionIrisStillImageSinkPrepareToCapture's implementation also expects XPCCoding.
@interface FigCaptureIrisPreparedSettings : NSObject <FigXPCCoding, NSCopying>

@property(nonatomic) int64_t settingsID; // must be non-zero
@property(nonatomic) uint32_t processedOutputFormat; // client wants the still image render pipeline prepared to deliver processed output in this format
@property(nonatomic) uint32_t rawOutputFormat; // client wants the still image render pipeline prepared to deliver raw output in this format
@property(nonatomic) uint32_t outputWidth; // client wants the still image render pipeline prepared to deliver processed output at this width
@property(nonatomic) uint32_t outputHeight; // client wants the still image render pipeline prepared to deliver processed output at this height
@property(nonatomic) uint32_t bracketedImageCount; // client wants the still image render pipeline prepared to deliver a bracket of n images
@property(nonatomic) FigCaptureQualityPrioritization qualityPrioritization; // the highest quality prioritization level for which the client wants the still image render pipeline prepared
@property(nonatomic) FigCaptureHDRMode HDRMode; // client wants the still image render pipeline prepared for HDR requests
#if FIG_CAPTURE_LOW_LIGHT_SUPPORTED
@property(nonatomic) FigCaptureDigitalFlashMode digitalFlashMode; // client wants the still image render pipeline prepared for Digital Flash requests
#endif // FIG_CAPTURE_LOW_LIGHT_SUPPORTED
@property(nonatomic, copy) NSArray *bravoConstituentImageDeliveryDeviceTypes; // client wants images from n constituent cameras, NSArray<FigCaptureSourceDeviceType>

- (FigCaptureStillImageSettings *)figCaptureStillImageSettingsRepresentation; // BWStillImageCoordinatorNode wants a FigCaptureStillImageSettings for preparation, so PreparedPhotoSettings knows how to create one. 

@end
