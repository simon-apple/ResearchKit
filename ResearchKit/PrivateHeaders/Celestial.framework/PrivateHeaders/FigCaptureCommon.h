/*
	File:			FigCaptureCommon.h
	Description: 	Common data types for FigCaptureSession and its friends
	Authors:		Brad Ford and Walker Eagleston
	Creation Date:	10/11/13
	Copyright: 		© Copyright 2013-2018 Apple, Inc. All rights reserved.
*/


#ifndef FIGCAPTURECOMMON_H
#define FIGCAPTURECOMMON_H

#import <CoreMedia/CMBasePrivate.h> // CM_INIT_UNAVAILABLE

#import <Foundation/Foundation.h>
#import <CoreFoundation/CoreFoundation.h>

#import <CoreMedia/CMTime.h>
#import <CoreMedia/FigCaptureHideFeatures.h>

#import <Foundation/NSString.h>

#ifdef __cplusplus
extern "C" {
#endif
    
#pragma pack(push, 4)

typedef NS_ENUM( int32_t, FigCaptureVideoOrientation ) {
	FigCaptureVideoOrientationUnspecified		 = 0,
	FigCaptureVideoOrientationPortrait           = 1,
	FigCaptureVideoOrientationPortraitUpsideDown = 2,
	FigCaptureVideoOrientationLandscapeRight     = 3, // home button on the right
	FigCaptureVideoOrientationLandscapeLeft      = 4, // home button on the left
};
// Our naming convention of right vs left for the landscape orientations lines up with AVCaptureVideoOrientation and UIInterfaceOrientation
// This is just a naming convention, all of the orientation enums (UIDeviceOrientation, UIInterfaceOrientation, AVCaptureVideoOrientation, and FigCaptureVideoOrientation) use the same enum value to refer to the same physical orientation of the device.
// In other words 4 always means landscape with the home button on the left, and 3 always means landscape with the home button is on the right

CM_EXPORT NSString *FigCaptureVideoOrientationToString( FigCaptureVideoOrientation orientation );

typedef NS_ENUM( int32_t, FigCaptureTorchMode ) {
	FigCaptureTorchModeOff	= 0,
	FigCaptureTorchModeOn	= 1,
	FigCaptureTorchModeAuto = 2
};
	
typedef NS_ENUM( int32_t, FigCaptureFlashMode ) {
	FigCaptureFlashModeOff	= 0,
	FigCaptureFlashModeOn	= 1,
	FigCaptureFlashModeAuto	= 2
};

#if FIG_CAPTURE_LOW_LIGHT_SUPPORTED
typedef NS_ENUM( int32_t, FigCaptureDigitalFlashMode ) {
	FigCaptureDigitalFlashModeOff	= 0,
	FigCaptureDigitalFlashModeMin	= 1,
	FigCaptureDigitalFlashModeMax	= 2
};
#endif // FIG_CAPTURE_LOW_LIGHT_SUPPORTED
	
typedef NS_ENUM( int32_t, FigCaptureHDRMode ) {
	FigCaptureHDRModeOff	= 0,
	FigCaptureHDRModeOn		= 1,
	FigCaptureHDRModeAuto	= 2
};
    
typedef NS_ENUM( int32_t, FigCaptureQualityPrioritization ) {
    FigCaptureQualityPrioritizationSpeed    = 1,
    FigCaptureQualityPrioritizationBalanced = 2,
    FigCaptureQualityPrioritizationQuality  = 3,
};

typedef NS_ENUM( int32_t, FigCaptureBravoImageFusionMode ) {
	FigCaptureBravoImageFusionModeOff	= 0,
	FigCaptureBravoImageFusionModeOn	= 1, // not a shipping configuration.
	FigCaptureBravoImageFusionModeAuto	= 2
};

/*!
	@enum FigCaptureVideoStabilizationMethod
	@abstract
		Constants indicating the modes of video stabilization supported by the device's format.
		It is configured by the application.

	@constant FigCaptureVideoStabilizationMethodOff
		Indicates that video should not be stabilized.
	@constant FigCaptureVideoStabilizationMethodStandard
		Standard video stabilization has a reduced field of view compared to FigCaptureVideoStabilizationMethodOff.
		The amount of overscan is 10%.
		Enabling video stabilization may introduce additional latency into the video capture pipeline.
	@constant FigCaptureVideoStabilizationMethodCinematic
		Cinematic video stabilization has a reduced field of view compared to FigCaptureVideoStabilizationMethodOff and it may have lesser field of view compared to FigCaptureVideoStabilizationMethodStandard.
		Enabling cinematic video stabilization introduces much more latency into the video capture pipeline than standard video stabilization and consumes significantly more system memory.
		The amount of overscan is 20%, it can be overridden using VideoStabilizationOverscanPercentageOverrideForCinematic key for each AVCaptureDeviceFormats in AVCaptureSession.plist.
 	@constant FigCaptureVideoStabilizationMethodCinematicExtended
		Cinematic extended video stabilization has a reduced field of view compared to FigCaptureVideoStabilizationMethodOff and it may have lesser field of view compared to FigCaptureVideoStabilizationMethodStandard.
		Enabling cinematic extended video stabilization introduces much more latency into the video capture pipeline than regular cinematic video stabilization and consumes significantly more system memory.
		The amount of overscan is 20% for video, or 10% for CTM LivePhoto if video stitching is disabled. It can be overridden using VideoStabilizationOverscanPercentageOverrideForCinematic key for each AVCaptureDeviceFormats in AVCaptureSession.plist.
 */
typedef NS_ENUM( int32_t, FigCaptureVideoStabilizationMethod ) {
	FigCaptureVideoStabilizationMethodOff       		= 0,
	FigCaptureVideoStabilizationMethodStandard  		= 1,
	FigCaptureVideoStabilizationMethodCinematic 		= 2,
#if FIG_CAPTURE_EXTENDED_CVIS_SUPPORTED
	FigCaptureVideoStabilizationMethodCinematicExtended	= 3
#endif // FIG_CAPTURE_EXTENDED_CVIS_SUPPORTED
};

/*!
	@enum FigCaptureVideoStabilizationType
	@abstract
		Constants indicating the types of video stabilization supported by the device's format.
		The following table lists the default behavior for each FigCaptureVideoStabilizationMethod unless it is overridden using VideoStabilizationTypeOverrideForStandard/Cinematic keys for the AVCaptureDeviceFormats present in AVCaptureSession.plist.
		|------------------------------------------------|-------------------------------------------------------|
		|   FigCaptureVideoStabilizationMethod           |    FigCaptureVideoStabilizationType (default)         |
		|------------------------------------------------|-------------------------------------------------------|
		|   FigCaptureVideoStabilizationMethodOff        |    FigCaptureVideoStabilizationMethodOff              |
		|------------------------------------------------|-------------------------------------------------------|
		|   FigCaptureVideoStabilizationMethodStandard   |    FigCaptureVideoStabilizationTypeISP                |
		|------------------------------------------------|-------------------------------------------------------|
		|   FigCaptureVideoStabilizationMethodCinematic  |    FigCaptureVideoStabilizationTypeGPU                |
		|------------------------------------------------|-------------------------------------------------------|

	@constant FigCaptureVideoStabilizationTypeNone
		Indicates that video should not be stabilized.
	@constant FigCaptureVideoStabilizationTypeISP
		Indicates ISP VIS based stabilization where the ISP calculates the transform matrices and applies it to the video output and delivered the stabilized frames to CM.
	@constant FigCaptureVideoStabilizationTypeGPU
		Indicates GPU based stabilization where CM receives unstabilized video frames and GyroVideoStabilization SBP calculates the transform matrices and uses GPU for processing.
	@constant FigCaptureVideoStabilizationTypeISPStrip
		Indicates ISP based stabilization where CM receives unstabilized video frames and GyroVideoStabilization SBP calculates the transform matrices and uses ISP BES for processing using FigCaptureDeviceCreateISPProcessingSession.
 */
typedef NS_ENUM( int32_t, FigCaptureVideoStabilizationType ) {
	FigCaptureVideoStabilizationTypeNone		= 0,
	FigCaptureVideoStabilizationTypeISP			= 1,
	FigCaptureVideoStabilizationTypeGPU			= 2,
	FigCaptureVideoStabilizationTypeISPStrip	= 3,
};

typedef NS_ENUM( int32_t, FigCaptureMotionAttachmentsSource ) {
	FigCaptureMotionAttachmentsSourceNone					= 0,	// none
	FigCaptureMotionAttachmentsSourceISPMotion				= 1,	// isp motion data
	FigCaptureMotionAttachmentsSourceISPMotionSphere		= 2,	// isp/sphere motion data
	FigCaptureMotionAttachmentsSourceCoreMotion				= 3,	// core motion data
};

typedef NS_ENUM( int32_t, FigCaptureStillImageNoiseReductionAndStabilizationScheme ) {
	FigCaptureStillImageNoiseReductionAndStabilizationSchemeSeparateFusionAndNoiseReduction = 0,
	FigCaptureStillImageNoiseReductionAndStabilizationSchemeTemporalMultiBandNoiseReduction = 1,
	FigCaptureStillImageNoiseReductionAndStabilizationSchemeGeneralNoiseReductionAndFusion	= 2,
	FigCaptureStillImageNoiseReductionAndStabilizationSchemeUnifiedBracketing				= 3,
};

// Overscan percentages used for time-lapse offline stabilization. These are extern since AVFoundation relies on them.
CM_EXPORT const float kFigCaptureOfflineStillImageVideoStabilizationOverscanPercentage_BackCamera;
CM_EXPORT const float kFigCaptureOfflineStillImageVideoStabilizationOverscanPercentage_FrontCamera;
	
typedef NS_ENUM( int32_t, FigCaptureColorSpace ) {
	FigCaptureColorSpace_sRGB		= 0,
	FigCaptureColorSpace_P3_D65 	= 1,
	FigCaptureColorSpace_HLG_P3_D65	= 2,
};
	
typedef NS_ENUM( int32_t, FigCaptureBravoCameraSelectionBehavior )
{
	FigCaptureBravoCameraSelectionBehaviorUnsupported              = 0,
	FigCaptureBravoCameraSelectionBehaviorEvaluatesContinuously    = 1,
	FigCaptureBravoCameraSelectionBehaviorEvaluatesOnZoomChange    = 2,
	FigCaptureBravoCameraSelectionBehaviorEvaluatesNever           = 3,
};

typedef NS_ENUM( int32_t, FigCaptureImageQueueSyncStrategy ) {
	FigCaptureImageQueueSyncStrategyNone				= 0,// For undefined
	FigCaptureImageQueueSyncStrategyDisplayImmediately	= 1, // For < 60fps preview where the frame delivery cadence is even.
	FigCaptureImageQueueSyncStrategyNextVSync			= 2, // For 60fps preview. Retimes each frame to hit the next vsync. Can only be set if we were intialized with HFRSupport = YES.
	FigCaptureImageQueueSyncStrategyHonorPTS			= 3  // For < 60fps preview where the frame delivery cadence is uneven. Honors frame durations when possible.
};
	
@interface FigCaptureMachPortSendRight : NSObject

CM_INIT_UNAVAILABLE;
- (instancetype)initWithPort:(mach_port_t)machPort; // Takes ownership of machPort

@property(nonatomic, readonly) mach_port_t port;

// Force the mach port right to be released now instead of dealloc.
// Invalidate is not safe to call from multiple threads at once.
// Use of port after invalidate is undefined.
- (void)invalidate;

@end

#pragma pack(pop)

#ifdef __cplusplus
}
#endif

#endif // FIGCAPTURECOMMON_H
