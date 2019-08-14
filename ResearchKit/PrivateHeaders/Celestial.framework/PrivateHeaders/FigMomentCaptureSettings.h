/*
	File:			FigMomentCaptureSettings.h
	Description: 	Settings to indicate the beginning of a CTM request
	Authors:		Brad Ford
	Creation Date:	11/27/18
	Copyright: 		Copyright © 2018-2019 Apple Inc. All rights reserved.
*/

#import <Celestial/FigCaptureCommon.h>

#if FIG_CAPTURE_THE_MOMENT_SUPPORTED

@interface FigMomentCaptureSettings : NSObject <NSSecureCoding, NSCopying>

// FigCaptureStillImageSettings must be initialized with initWithSettingsID:
CM_INIT_UNAVAILABLE

// The settingsID must be non-zero
// init with the mach absolute time of touch down
- (instancetype)initWithSettingsID:(int64_t)settingsID userInitiatedCaptureTime:(uint64_t)userInitiatedCaptureTime;

@property(nonatomic, readonly) int64_t settingsID; // unique identifier
@property(nonatomic, readonly) uint64_t userInitiatedCaptureTime;

// movie related
@property(nonatomic) FigCaptureTorchMode torchMode;

@property(nonatomic) FigCaptureFlashMode flashMode;
@property(nonatomic) BOOL autoRedEyeReductionEnabled;
#if FIG_CAPTURE_LOW_LIGHT_SUPPORTED
@property(nonatomic) FigCaptureDigitalFlashMode digitalFlashMode;
#endif // FIG_CAPTURE_LOW_LIGHT_SUPPORTED
@property(nonatomic) FigCaptureQualityPrioritization qualityPrioritization;
@property(nonatomic) FigCaptureHDRMode HDRMode;
@property(nonatomic, getter=isAutoOriginalPhotoDeliveryEnabled) BOOL autoOriginalPhotoDeliveryEnabled;
@property(nonatomic, getter=isAutoSpatialOverCaptureEnabled) BOOL autoSpatialOverCaptureEnabled;
#if FIG_CAPTURE_DEFERRED_PROCESSING_SUPPORTED
@property(nonatomic, getter=isAutoDeferredProcessingEnabled) BOOL autoDeferredProcessingEnabled;
#endif // FIG_CAPTURE_DEFERRED_PROCESSING_SUPPORTED

@end

#endif // FIG_CAPTURE_THE_MOMENT_SUPPORTED
