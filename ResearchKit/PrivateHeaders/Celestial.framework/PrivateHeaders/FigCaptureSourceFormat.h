/*
	File:			FigCaptureSourceFormat.h
	Description: 	Abstraction for a device format (CMFormatDesc + some other stuff)
	Authors:		Brad Ford and Walker Eagleston
	Creation Date:	10/11/13
	Copyright: 		© Copyright 2013-2018 Apple, Inc. All rights reserved.
*/

// This is conceptually a wrapper for a dictionary, with formalized API, so required fields are known.

#import <CoreMedia/CMBasePrivate.h>
#import <CoreMedia/FigCaptureHideFeatures.h>
#import <Foundation/Foundation.h>

#import <CoreMedia/CMFormatDescription.h>

#import <Celestial/FigXPCCoding.h>
#import <Celestial/FigCaptureCommon.h>
#import <Celestial/FigCaptureObfuscation.h>

typedef NS_ENUM( int32_t, FigCaptureSourceFormatAutoFocusSystem ) {
	FigCaptureSourceFormatAutoFocusSystemNone = 0,
	FigCaptureSourceFormatAutoFocusSystemContrastDetection = 1,
	FigCaptureSourceFormatAutoFocusSystemPhaseDetection = 2,
};


@interface FigCaptureSourceFormat: NSObject <FigXPCCoding, NSSecureCoding>

- (instancetype)initWithFigCaptureStreamFormatDictionary:(NSDictionary *)formatDictionary; // designated initializer

@property(atomic, readonly) CMMediaType mediaType; // 'vide', 'soun', 'dpth', etc.
@property(atomic, readonly) __attribute__((NSObject)) CMFormatDescriptionRef formatDescription;
@property(atomic, readonly) FourCharCode format; // derived from format description
@property(atomic, readonly, getter=isDefaultActiveFormat) BOOL defaultActiveFormat;
@property(atomic, readonly, getter=isExperimental) BOOL experimental;

@end


@interface FigCaptureSourceVideoFormat : FigCaptureSourceFormat

// VIDEO
@property(atomic, readonly) int32_t formatIndex; // the FigCaptureStream format index
@property(atomic, readonly) CMVideoDimensions dimensions; // derived from format description
@property(atomic, readonly) CMVideoDimensions sensorDimensions; // This is the actual sensor width/height.
@property(atomic, readonly) CMVideoDimensions previewDimensions; // The optimal preview dimensions (based on main screen size) for this format
@property(atomic, readonly) float minSupportedFrameRate; // 0 if unknown.
@property(atomic, readonly) float maxSupportedFrameRate; // 0 if unknown.
@property(atomic, readonly) float defaultMinFrameRate; // 0 if unknown.
@property(atomic, readonly) float defaultMaxFrameRate; // 0 if unknown.
@property(atomic, readonly) float fieldOfView; // 0 if unknown.
#if FIG_SHOW_H12_FEATURES
@property(atomic, readonly) float geometricDistortionCorrectedFieldOfView;
#endif // FIG_SHOW_H12_FEATURES
@property(atomic, readonly, getter=isBinned) BOOL binned;
- (BOOL)isStabilizationModeSupported:(FigCaptureVideoStabilizationMethod)stabilizationMode;
@property(atomic, readonly, getter=isZoomSupported) BOOL zoomSupported;
@property(atomic, readonly) float maxZoomFactor; // conservatively accounts for VIS overscan when available (including cinematic)
@property(atomic, readonly) float zoomFactorUpscaleThreshold; // conservatively accounts for VIS overscan when available (NOT including cinematic)
@property(atomic, readonly, getter=isZoomDynamicSensorCropSupported) BOOL zoomDynamicSensorCropSupported;
@property(atomic, readonly) int32_t rawBitDepth; // 0 if unknown.
@property(atomic, readonly) float minISO;
@property(atomic, readonly) float maxISO;
@property(atomic, readonly) CMTime minExposureDuration;
@property(atomic, readonly) CMTime maxExposureDuration;
@property(atomic, readonly) BOOL hasSensorHDRCompanionIndex;
@property(atomic, readonly) BOOL prefersSensorHDREnabled;
@property(atomic, readonly, getter=isSIFRSupported) BOOL SIFRSupported;
@property(atomic, readonly, getter=isLowLightVideoCaptureSupported) BOOL lowLightVideoCaptureSupported;
#if FIG_CAPTURE_60FPS_VARIABLE_FRAMERATE_SUPPORTED
@property(atomic, readonly, getter=isVariableFrameRateVideoCaptureSupported) BOOL variableFrameRateVideoCaptureSupported;
#endif // FIG_CAPTURE_60FPS_VARIABLE_FRAMERATE_SUPPORTED
@property(atomic, readonly, getter=isVisionDataDeliverySupported) BOOL visionDataDeliverySupported;
@property(atomic, readonly, getter=isSecondaryScalerUnavailable) BOOL secondaryScalerUnavailable;
@property(atomic, readonly, getter=isStudioAndContourPreviewRenderingSupported) BOOL studioAndContourPreviewRenderingSupported;
@property(atomic, readonly, getter=isStagePreviewRenderingSupported) BOOL stagePreviewRenderingSupported;
@property(atomic, readonly, getter=isWideAsStatsMasterEnabled) BOOL wideAsStatsMasterEnabled;

@property(atomic, readonly) FigCaptureSourceFormatAutoFocusSystem autoFocusSystem;

// PHOTO
@property(atomic, readonly, getter=isPhotoFormat) BOOL photoFormat; // not sure if we need this one any more
@property(atomic, readonly, getter=isHighResPhotoFormat) BOOL highResPhotoFormat;
@property(atomic, readonly) BOOL needsPreviewDPCC; // dead pixel correction
@property(atomic, readonly, getter=isStillImageStabilizationSupported) BOOL stillImageStabilizationSupported;
@property(atomic, readonly) BOOL configureForStillImageStabilizationSupport;
@property(atomic, readonly, getter=isIrisSupported) BOOL irisSupported;
@property(atomic, readonly, getter=isIrisVideoStabilizationSupported) BOOL irisVideoStabilizationSupported;
@property(atomic, readonly, getter=isHDRSupported) BOOL hdrSupported;
@property(atomic, readonly, getter=isHighResStillImageSupported) BOOL highResStillImageSupported;
@property(atomic, readonly, getter=isQuadraHighResStillImageSupported) BOOL quadraHighResStillImageSupported; // when YES, highResStillImageSupported will also return YES.
@property(atomic, readonly, getter=isStereoFusionSupported) BOOL stereoFusionSupported;
@property(atomic, readonly, getter=isISPMultiBandNoiseReductionSupported) BOOL ispMultiBandNoiseReductionSupported; // ISP MBNR for streaming
@property(atomic, readonly, getter=isStillImageISPMultiBandNoiseReductionSupported) BOOL stillImageISPMultiBandNoiseReductionSupported; // ISP MBNR for still image
@property(atomic, readonly, getter=isZeroShutterLagSupported) BOOL zeroShutterLagSupported;
@property(atomic, readonly) BOOL zeroShutterLagRequiresUserInitiatedCaptureRequestTime;
@property(atomic, readonly, getter=isRedEyeReductionSupported) BOOL redEyeReductionSupported;
#if FIG_CAPTURE_LOW_LIGHT_SUPPORTED
@property(atomic, readonly, getter=isDigitalFlashSupported) BOOL digitalFlashSupported;
#endif // FIG_CAPTURE_LOW_LIGHT_SUPPORTED
#if FIG_CAPTURE_DEEP_FUSION_SUPPORTED
@property(atomic, readonly, getter=isDeepFusionSupported) BOOL deepFusionSupported;
#endif // FIG_CAPTURE_DEEP_FUSION_SUPPORTED
@property(atomic, readonly) CMVideoDimensions highResStillImageDimensions;
@property(atomic, readonly, getter=isWideColorSupported) BOOL wideColorSupported;
@property(atomic, readonly) NSArray *supportedColorSpaces;
@property(atomic, readonly) OSType supportedRawPixelFormat; // 0 if not supported
@property(atomic, readonly) float defaultSimulatedAperture; // The simulated aperture (1/F) that drives the amount of blur applied to Portrait photos taken in this format. 0 on formats / devices where Portrait mode is not supported.
@property(atomic, readonly) float minSimulatedAperture; // The minimum simulated aperture allowed to be applied to Portraits photos taken in this format. 0 on formats / devices where Portrait mode is not supported.
@property(atomic, readonly) float maxSimulatedAperture; // The maximum simulated aperture allowed to be applied to Portrait photos taken in in this format. 0 on formats / devices where Portrait mode is not supported.
#if FIG_CAPTURE_ADJUSTABLE_PORTRAIT_LIGHTING_STRENGTH
@property(atomic, readonly) float defaultPortraitLightingEffectStrength; // The default value for the Portrait Lighting effect strength.  NAN on formats / devices where adjustable Portrait Lighting effect strength is not supported.
@property(atomic, readonly) float minPortraitLightingEffectStrength; // The minimum Portrait Lighting effect strength allowed to be applied to Portraits photos taken in this format. NAN on formats / devices where adjustable Portrait Lighting effect strength is not supported.
@property(atomic, readonly) float maxPortraitLightingEffectStrength; // The maximum Portrait Lighting effect strength allowed to be applied to Portrait photos taken in in this format. NAN on formats / devices where adjustable Portrait Lighting effect strength is not supported.
#endif // FIG_CAPTURE_ADJUSTABLE_PORTRAIT_LIGHTING_STRENGTH

// VIDEO RECORDING
@property(atomic, readonly, getter=isHighProfileH264Supported) BOOL highProfileH264Supported;

// AVCaptureSession Reverse-Mapping
@property(atomic, readonly) NSArray *AVCaptureSessionPresets;

// DEPTH
@property(atomic, readonly, getter=isStreamingDisparitySupported) BOOL streamingDisparitySupported;
@property(atomic, readonly, getter=isStreamingDepthSupported) BOOL streamingDepthSupported;
@property(atomic, readonly, getter=isStillImageDisparitySupported) BOOL stillImageDisparitySupported;
@property(atomic, readonly, getter=isStillImageDepthSupported) BOOL stillImageDepthSupported;
@property(atomic, readonly) NSArray *supportedDepthDataFormats; // NSArray<FigCaptureSourceDepthDataFormat *>, may be nil
@property(atomic, readonly) float minZoomFactorForDepthDataDelivery;
@property(atomic, readonly) float maxZoomFactorForDepthDataDelivery;

// CAPTURE THE MOMENT
#if FIG_CAPTURE_THE_MOMENT_SUPPORTED
@property(atomic, readonly, getter=isMomentCaptureMovieRecordingSupported) BOOL momentCaptureMovieRecordingSupported;
@property(atomic, readonly, getter=isSpatialOverCaptureSupported) BOOL spatialOverCaptureSupported;
@property(atomic, readonly) float spatialOverCapturePercentage;
@property(atomic, readonly) CMVideoDimensions spatialOverCaptureHighResStillImageDimensions;
@property(atomic, readonly, getter=isNonDestructiveCropSupported) BOOL nonDestructiveCropSupported;
#endif // FIG_CAPTURE_THE_MOMENT_SUPPORTED

#if FIG_CAPTURE_DEFERRED_PROCESSING_SUPPORTED
@property(atomic, readonly, getter=isDeferredPhotoProcessingSupported) BOOL deferredPhotoProcessingSupported;
#endif // FIG_CAPTURE_DEFERRED_PROCESSING_SUPPORTED

@property(atomic, readonly, getter=isMultiCamSupported) BOOL multiCamSupported;
@property(atomic, readonly) float hardwareCost; // ISP throughput (between 0 and 1) required for maxSupportedFrameRate at Vmid.
@property(atomic, readonly) int32_t sensorPowerConsumption; // DEPRECATED, use the two below. This is only here to avoid breaking existing AVF clients. To be removed in <rdar://problem/52593171>.
@property(atomic, readonly) int32_t baseSensorPowerConsumption; // Sensor base power, independent of frame rate (in mW).
@property(atomic, readonly) int32_t variableSensorPowerConsumption; // Framerate dependent sensor power, at MaxSupportedFrameRate (in mW).
@property(atomic, readonly) int32_t ispPowerConsumption; // ISP power (in mW) at the format's max frame rate.

@end


@interface FigCaptureSourceDepthDataFormat : FigCaptureSourceFormat

@property(atomic, readonly) CMVideoDimensions dimensions; // derived from format description
@property(atomic, readonly) float minSupportedFrameRate; // 0 if unknown.
@property(atomic, readonly) float maxSupportedFrameRate; // 0 if unknown.
@property(atomic, readonly) float fieldOfView;
@property(atomic, readonly) CMVideoDimensions highResStillImageDimensions;
@property(atomic, readonly, getter=isStillImageOnlyDepthData) BOOL stillImageOnlyDepthData;
@property(atomic, readonly) float portraitEffectsMatteMainImageDownscalingFactor; // Portrait effects matte image size depends on the main image size.
@property(atomic, readonly) BOOL RGBIRStereoFusionSupported;
#if FIG_SEMANTIC_SEGMENTATION_MATTE_API_SUPPORTED
@property(atomic, readonly) NSArray<NSString *> *supportedSemanticSegmentationMatteURNs; // kFigPhotoAuxiliaryImageTypeURN_SemanticXXXMatte (see FigPhotoTypes.h)
#endif // FIG_SEMANTIC_SEGMENTATION_MATTE_API_SUPPORTED

@end
