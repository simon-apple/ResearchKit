/*
	File:			FigCaptureSource.h
	Description: 	Abstraction for a source that can provide capture data (video/audio/metadata, etc)
	Author:			Brad Ford
	Creation Date:	01/22/2014
	Copyright: 		© Copyright 2014-2018 Apple, Inc. All rights reserved.
*/

#ifndef FIGCAPTURESOURCE_H
#define FIGCAPTURESOURCE_H

#import <Celestial/FigCaptureSourceFormat.h>
#import <Celestial/FigCaptureObfuscation.h>

#import <CoreMedia/CMBase.h>
#import <CoreMedia/CMBaseObject.h>


#ifdef __cplusplus
extern "C" {
#endif
    
#pragma pack(push, 4)

#define kFigCaptureSourceAttributeKey_TrackingAutoFocus				FIG_HIDE_OBJECT_TRACKING_SYMBOL( kFigCaptureSourceAttributeKey_TrackingAutoFocus, kFigCaptureSourceAttributeKey_Option25 )
#define kFigCaptureSourceFocusOperationKey_Tracking					FIG_HIDE_OBJECT_TRACKING_SYMBOL( kFigCaptureSourceFocusOperationKey_Tracking, kFigCaptureSourceOperationKey_Option25 )
#define kFigCaptureSourceFocusOperationKey_TrackingDrivesExposure	FIG_HIDE_OBJECT_TRACKING_SYMBOL( kFigCaptureSourceFocusOperationKey_TrackingDrivesExposure, kFigCaptureSourceOperationKey_Option25SubOption0 )
#define kFigCaptureSourceProperty_TrackingAutoFocusSubjectRect		FIG_HIDE_OBJECT_TRACKING_SYMBOL( kFigCaptureSourceProperty_TrackingAutoFocusSubjectRect, kFigCaptureSourceProperty_Option25Changed )
#define kFigCaptureSourceProperty_TrackingAutoFocusSubjectAcquired	FIG_HIDE_OBJECT_TRACKING_SYMBOL( kFigCaptureSourceProperty_TrackingAutoFocusSubjectAcquired, kFigCaptureSourceProperty_Option25Changed2 )
#define kFigCaptureSourceAttributeKey_ObjectsDetection FIG_HIDE_SYMBOL_BEFORE_H12_RELEASE( kFigCaptureSourceAttributeKey_ObjectsDetection, kFigCaptureSourceAttributeKey_LowFeature42Rate )

#pragma mark < < < FigCaptureSource > > >

/*
	A FigCaptureSource is a read/write property interface intended to be used from a client 
	process to enumerate devices, query device capabilities, set properties, and receive notifications 
	about properties changing.  Its property set mirrors the feature set required by kFigCaptureSourceDevice. 
*/

typedef struct OpaqueFigCaptureSource *FigCaptureSourceRef;	// a CF type (FBO)

extern CMBaseClassID FigCaptureSourceGetClassID( void );

extern CFTypeID FigCaptureSourceGetTypeID( void );
	
// CopyCaptureSources - Clients may iterate through the list of FigCaptureSource objects
// by calling this function. The array must be released.  FigCaptureSources are never instantiated directly by clients.
typedef CF_OPTIONS( uint32_t, FigCaptureSourceTypeMask ) {
	kFigCaptureSourceTypeMask_Camera        = 1, // (FigCaptureDevice, DAL device, etc)
	kFigCaptureSourceTypeMask_Microphone    = 2, // (AURemoteIO-based FigCaptureDevice, HAL device, etc)
	kFigCaptureSourceTypeMask_ScreenGrab    = 4, // (Maybe rewrite the Tundra Screen Grabber input unit as a FigCaptureSource?)
	// kFigCaptureSourceTypeMask_MotionData ... etc (Other sources of data that could act as input to a BWGraph)
	kFigCaptureSourceTypeMask_All           = 0xFFFFFFF,
};
extern CFArrayRef FigCaptureSourceCopySources( FigCaptureSourceTypeMask sourceTypes );

	
	
// Errors
// FigCaptureSource owns -16450 to -16469
enum {
	kFigCaptureSourceError_SourceDisconnected   = -16450,
	kFigCaptureSourceError_SourceAlreadyLocked  = -16451, // returned from FigCaptureSourceLockForConfiguration
	kFigCaptureSourceError_SourceNotLocked      = -16452, // returned from FigCaptureSourceSetProperty
    kFigCaptureSourceError_ServerConnectionDied = -16453,
    kFigCaptureSourceError_OperationNotAvailableInBackground = -16454,
    kFigCaptureSourceError_ClientAuditTokenRequired = -16455,
	// etc.
};

// Errors not "owned" by FigCaptureSource, passing through from setting a property on underlying device
enum {
	kFigCaptureSourceError_TorchLevelUnavailable = -16540, // aka BWFigVideoCaptureDeviceErrorTorchLevelUnavailable
};


typedef CF_ENUM( int32_t, FigCaptureSourcePosition ) {
	kFigCaptureSourcePosition_Unspecified = 0,
	kFigCaptureSourcePosition_BackCamera  = 1,
	kFigCaptureSourcePosition_FrontCamera = 2,
};
#define kFigCaptureSourcePosition_Count ( kFigCaptureSourcePosition_FrontCamera + 1 )
	
typedef CF_ENUM( int32_t, FigCaptureSourceType ) {
	kFigCaptureSourceType_Camera	= 1,
	kFigCaptureSourceType_Microphone,
	kFigCaptureSourceType_ScreenGrab,
	kFigCaptureSourceType_Metadata
};

// This enum corresponds to the BWCaptureDeviceType enum.
typedef CF_ENUM( int32_t, FigCaptureSourceDeviceType )
{
	kFigCaptureSourceDeviceType_Unspecified = 0,
	kFigCaptureSourceDeviceType_Microphone  = 1,
	kFigCaptureSourceDeviceType_WideCamera  = 2,
	kFigCaptureSourceDeviceType_TeleCamera  = 3,
	kFigCaptureSourceDeviceType_BravoCamera = 4, // wide + tele
	kFigCaptureSourceDeviceType_InfraredCamera = 5,
	kFigCaptureSourceDeviceType_PearlCamera = 6, // RGB + IR
	kFigCaptureSourceDeviceType_SuperWideCamera = 7,
	kFigCaptureSourceDeviceType_WideBravoCamera = 8, // super-wide + wide
	kFigCaptureSourceDeviceType_SuperBravoCamera = 9, // super-wide + wide + tele
};
#define kFigCaptureSourceDeviceType_Count ( kFigCaptureSourceDeviceType_SuperBravoCamera + 1 )

// Client may call FigCaptureSourceCopyProperty at any time (always OK to read, even if another process has locked for configuration)
CM_INLINE OSStatus FigCaptureSourceCopyProperty( FigCaptureSourceRef captureSource, CFStringRef propertyKey, CFAllocatorRef allocator, void *propertyValueOut );
CM_INLINE OSStatus FigCaptureSourceSetProperty( FigCaptureSourceRef captureSource, CFStringRef propertyKey, CFTypeRef propertyValue );
	
// Before calling FigCaptureSourceSetProperty, you must call FigCaptureSourceLockForConfiguration, and it must return noErr.
// If it returns kFigCaptureSourceError_SourceAlreadyLocked, you may FigCaptureSourceCopyProperty(_OwningProcess) to discover the
// pid of the owning process.  LockForConfiguration/UnlockForConfiguration are no-ops on iOS, since only one client can access a device at a time.
CM_INLINE OSStatus FigCaptureSourceLockForConfiguration( FigCaptureSourceRef captureSource );
CM_INLINE OSStatus FigCaptureSourceUnlockForConfiguration( FigCaptureSourceRef captureSource );
	
CM_INLINE OSStatus FigCaptureSourceCheckTCCAccess( FigCaptureSourceRef captureSource );

// PROPERTIES
extern const CFStringRef kFigCaptureSourceProperty_AttributesDictionary; // read-only. dictionary(keys below)
	extern const CFStringRef kFigCaptureSourceAttributeKey_UniqueID; // CFString.
	extern const CFStringRef kFigCaptureSourceAttributeKey_ModelID; // CFString.
	extern const CFStringRef kFigCaptureSourceAttributeKey_NonLocalizedName; // CFString.
	extern const CFStringRef kFigCaptureSourceAttributeKey_Position; // CFNumber(FigCaptureSourcePosition).
	extern const CFStringRef kFigCaptureSourceAttributeKey_DeviceType; // CFNumber(FigCaptureSourceDeviceType)
	extern const CFStringRef kFigCaptureSourceAttributeKey_SourceType; // CFNumber(FigCaptureSourceType).
	extern const CFStringRef kFigCaptureSourceAttributeKey_MinFrameRate; // boolean. Can min frame rate be set at all?
	extern const CFStringRef kFigCaptureSourceAttributeKey_MaxFrameRate; // boolean. Can max frame rate be set at all?
	extern const CFStringRef kFigCaptureSourceAttributeKey_Focus; // boolean. Can it do focus?
	extern const CFStringRef kFigCaptureSourceAttributeKey_ManualFocus; // boolean. Can it do manual focus?
	extern const CFStringRef kFigCaptureSourceAttributeKey_DefaultContinuousAutoFocusWindowSize; // dictionary(CGSize). If not present, use the below sizes as appropriate.
	extern const CFStringRef kFigCaptureSourceAttributeKey_DefaultAutoFocusCenterWindowSize; // dictionary(CGSize).
	extern const CFStringRef kFigCaptureSourceAttributeKey_DefaultAutoFocusTapWindowSize; // dictionary(CGSize).
	extern const CFStringRef kFigCaptureSourceAttributeKey_AutoFocusRangeRestriction; // boolean. Can it do near/far focus?
	extern const CFStringRef kFigCaptureSourceAttributeKey_SmoothFocus; // boolean. Can it do smooth focus?
	extern const CFStringRef kFigCaptureSourceAttributeKey_AutoFocusPositionSensorMode; // FigCaptureStreamAutoFocusPositionSensorMode. APS mode.
	extern const CFStringRef kFigCaptureSourceAttributeKey_TrackingAutoFocus; // boolean. Can it do tracking auto focus?
	extern const CFStringRef kFigCaptureSourceAttributeKey_Exposure; // boolean. Can it do exposure?
	extern const CFStringRef kFigCaptureSourceAttributeKey_ManualExposure; // boolean. Can it do manual exposure?
	extern const CFStringRef kFigCaptureSourceAttributeKey_FocalLength; // CFNumber (kCFNumberDoubleType). What is the distance in millimeters between the sensor and the lens at inifinity focus?
	extern const CFStringRef kFigCaptureSourceAttributeKey_LensAperture; // CFNumber (kCFNumberDoubleType). What is the aperture size (expressed as the ratio of focal length to lens diameter, or f-number) of the lens diaphragm?
	extern const CFStringRef kFigCaptureSourceAttributeKey_DefaultAutoExposureCenterWindowSize; // dictionary(CGSize).
	extern const CFStringRef kFigCaptureSourceAttributeKey_DefaultAutoExposureTapWindowSize; // dictionary(CGSize).
	extern const CFStringRef kFigCaptureSourceAttributeKey_AppliesSessionPresetMaxIntegrationTimeOverrideToActiveFormat; // boolean. As of iOS 12 hardware, we have no max integration time difference between setSessionPreset: and setActiveFormat:.
	extern const CFStringRef kFigCaptureSourceAttributeKey_WhiteBalance; // boolean. Can it do wb?
	extern const CFStringRef kFigCaptureSourceAttributeKey_ManualWhiteBalance; // boolean. Can it do manual wb?
	extern const CFStringRef kFigCaptureSourceAttributeKey_DefaultWhiteBalanceGains; // CFData (FigCaptureSourceWhiteBalanceGains)
	extern const CFStringRef kFigCaptureSourceAttributeKey_Flash; // boolean. Does it have a flash?
	extern const CFStringRef kFigCaptureSourceAttributeKey_Torch; // boolean. Does it have a torch?
	extern const CFStringRef kFigCaptureSourceAttributeKey_VideoZoom; // boolean. Can it do video zoom?
	extern const CFStringRef kFigCaptureSourceAttributeKey_BravoSwitchOverVideoZoomFactors; // CFArray of floats
	extern const CFStringRef kFigCaptureSourceAttributeKey_BravoSwitchOverVideoZoomFactor; // *** DEPRECATED! WILL BE REMOVED SOON ***
	extern const CFStringRef kFigCaptureSourceAttributeKey_VideoStabilization; // boolean. Can it do VIS?
	extern const CFStringRef kFigCaptureSourceAttributeKey_RawStillImageCapture; // boolean. Can it take raw still images?
	extern const CFStringRef kFigCaptureSourceAttributeKey_FaceDetectionDuringVideoPreview; // boolean. Is this a powerful enough device to do FD while in video preview mode? (Camera.app specific property)
	extern const CFStringRef kFigCaptureSourceAttributeKey_FaceTracking; // boolean. Is face tracking using FaceKit supported?
	extern const CFStringRef kFigCaptureSourceAttributeKey_ObjectsDetection; // boolean.
	extern const CFStringRef kFigCaptureSourceAttributeKey_HDR; // boolean. Can it do HDR in general?
	extern const CFStringRef kFigCaptureSourceAttributeKey_HDRSceneDetection; // boolean. Can it detect HDR scenes?
	extern const CFStringRef kFigCaptureSourceAttributeKey_SIS; // boolean. Can it do SIS/OIS?
	extern const CFStringRef kFigCaptureSourceAttributeKey_ISPAPSData; // boolean; Does it have APS data from ISP?
	extern const CFStringRef kFigCaptureSourceAttributeKey_ISPMotionData; // boolean; Does it have motion data from ISP?
	extern const CFStringRef kFigCaptureSourceAttributeKey_Sphere; // boolean; Does it have Sphere?
	extern const CFStringRef kFigCaptureSourceAttributeKey_SphereVideo; // boolean; Does it support Sphere Video?
	extern const CFStringRef kFigCaptureSourceAttributeKey_SphereStillActivePreview; // boolean; Does it support Sphere Still Active Preview?
	extern const CFStringRef kFigCaptureSourceAttributeKey_FocalLengthCharacterization; // boolean; Does it have focal length characterization data?
	extern const CFStringRef kFigCaptureSourceAttributeKey_HEVC; // boolean; Does it support HEVC encoding?
	extern const CFStringRef kFigCaptureSourceAttributeKey_PrefersHEVC; // boolean; Is HEVC the preferred (default) video encoding for this device?
	extern const CFStringRef kFigCaptureSourceAttributeKey_WideColor; // boolean; Does it have wide gamut colorspace support?
	extern const CFStringRef kFigCaptureSourceAttributeKey_HEIF; // boolean; Does it support the HEIF file format?
	extern const CFStringRef kFigCaptureSourceAttributeKey_AutoFocusPositionSensorCalibrationSupported; // boolean; does it support auto focus position sensor calibration?
	extern const CFStringRef kFigCaptureSourceAttributeKey_RedEyeReduction;	// boolean; Does it do red eye reduction
	extern const CFStringRef kFigCaptureSourceAttributeKey_MultiPassIspMBNRSupported; // boolean; does ISP hardware supports MBNR in multi pass mode in FW
	extern const CFStringRef kFigCaptureSourceAttributeKey_IspMBNRSupported; // boolean; does ISP hardware supports MBNR
	extern const CFStringRef kFigCaptureSourceAttributeKey_RoundingOfBackEndScalersOutputHeightToMultipleOfTwoEnabled; // boolean; should we round BES output height to multiple of 2. defaults to 4 if SBS is enabled.
	extern const CFStringRef kFigCaptureSourceAttributeKey_GraphReconfigurationWhileStreamingSupported; // boolean; does the device support graph reconfiguration while the ISP keeps streaming
	extern const CFStringRef kFigCaptureSourceAttributeKey_SmartCameraSupported; // boolean; is smart camera processing supported?
	extern const CFStringRef kFigCaptureSourceAttributeKey_PowerConsumptionInSphereModeLock; // CFNumber( int32_t ). Power (in mW) consumed by the sphere module, in kFigCaptureStreamSphereMode_Lock.
	extern const CFStringRef kFigCaptureSourceAttributeKey_PowerConsumptionInSphereModeVideo; // CFNumber( int32_t ). Power (in mW) consumed by the sphere module, in kFigCaptureStreamSphereMode_Video.
	extern const CFStringRef kFigCaptureSourceAttributeKey_PowerConsumptionInSphereModeVideoHighRange; // CFNumber( int32_t ). Power (in mW) consumed by the sphere module, in kFigCaptureStreamSphereMode_VideoHighRange.
#if FIG_SHOW_H12_FEATURES
	extern const CFStringRef kFigCaptureSourceAttributeKey_GeometricDistortionCorrection; // boolean; does the source support GDC.
#endif // FIG_SHOW_H12_FEATURES
	extern const CFStringRef kFigCaptureSourceAttributeKey_CameraPoseMatrix; // CFData(matrix_float4x3 - column major)
	extern const CFStringRef kFigCaptureSourceAttributeKey_ConstituentPhotoCalibrationData; // boolean; does the source support generating calibration data for constituent photo without running disparity
	
	// AUDIO-ONLY ATTRIBUTES
	extern const CFStringRef kFigCaptureSourceAttributeKey_AudioSettingsForPresetsMap; // A dictionary whose keys are AVCapturePreset strings, and values are a dictionaries of settings.
		// Settings keys may include any of the following:
		extern const CFStringRef kFigCaptureSourceAudioSettingsKey_PreferredSampleRate; // CFNumber(int) (ex: 44100)
		extern const CFStringRef kFigCaptureSourceAudioSettingsKey_BitRatePerChannelForPreferredSampleRate; // CFNumber(int) (ex: 96000), the preferred bit rate is only used if the preferred sampling rate is the active rate.
		extern const CFStringRef kFigCaptureSourceAudioSettingsKey_BitRateStrategyForPreferredSampleRate; // CFString(AVAudioBitRateStrategy_{Constant/LongTermAverage/VariableConstrained/Variable}), only used if the preferred bitrate is being used.
		extern const CFStringRef kFigCaptureSourceAudioSettingsKey_VBRCodecQualityForPreferredSampleRate; // CFNumber(int) (ex: 91), the codec quality to use if the preferred bit rate strategy in use is VBR. Quality is an unsigned int in the range of 0-127 (see kAudioCodecPropertySoundQualityForVBR).
		// _Required keys trump _Preferred keys
		extern const CFStringRef kFigCaptureSourceAudioSettingsKey_RequiredNumChannels; // CFNumber(int) (ex: 1)
		extern const CFStringRef kFigCaptureSourceAudioSettingsKey_RequiredSampleRate; // CFNumber(int) (ex: 22050)
		extern const CFStringRef kFigCaptureSourceAudioSettingsKey_RequiredBitRatePerChannel; // CFNumber(int) (ex: 64000)
	extern const CFStringRef kFigCaptureSourceAttributeKey_PrefersDecoupledIO; // boolean. (Audio-only) True if the device benefits from running input as a separate vad instance (power gain)
	extern const CFStringRef kFigCaptureSourceAttributeKey_BuiltInMicrophoneStereoAudioCaptureSupported; // boolean. does it support stereo audio


// Properties common to all capture sources
extern const CFStringRef kFigCaptureSourceProperty_SourceToken; // read-only. CFNumber (Every FigCaptureSource created in mediaserverd is assigned a monotonically increasing number as a token. FigCaptureSessionConfiguration uses this token to cheaply serialize/deserialize a FigCaptureSource).
extern const CFStringRef kFigCaptureSourceProperty_Clock; // read-only.  CMClock.
extern const CFStringRef kFigCaptureSourceProperty_OwningProcess; // read, notify. CFNumber (pid_t of owning process).  NULL == no owning process.
extern const CFStringRef kFigCaptureSourceProperty_Connected; // read, notify.  boolean.
extern const CFStringRef kFigCaptureSourceProperty_Streaming; // read, notify.  boolean.
extern const CFStringRef kFigCaptureSourceProperty_MediaType; // read-only.  CFNumber (4cc).
extern const CFStringRef kFigCaptureSourceProperty_LockedForConfiguration; // read-only. boolean.
	
// Format selection
extern const CFStringRef kFigCaptureSourceProperty_ActiveFormat; // read-only. FigCaptureSourceVideoFormat. ActiveFormat is only set via FigCaptureSessionConfigurations.
extern const CFStringRef kFigCaptureSourceProperty_Formats; // read-only.  CFArray of FigCaptureSourceFormats.
extern const CFStringRef kFigCaptureSourceProperty_ActiveMinFrameRate; // RW. CFNumber (float).
extern const CFStringRef kFigCaptureSourceProperty_ActiveMaxFrameRate; // RW. CFNumber (float).
extern const CFStringRef kFigCaptureSourceProperty_ActiveDepthDataMaxFrameRate; // write-only. CFNumber (float).

// Focus
typedef CF_ENUM( int32_t, FigCaptureSourceFocusMode ) {
	kFigCaptureSourceFocusMode_Locked			= 0,
	kFigCaptureSourceFocusMode_Auto				= 1,
	kFigCaptureSourceFocusMode_ContinuousAuto	= 2,
};
typedef CF_ENUM( int32_t, FigCaptureSourceAutoFocusRangeRestriction ) {
	kFigCaptureSourceAutoFocusRangeRestriction_None = 0,
	kFigCaptureSourceAutoFocusRangeRestriction_Near = 1,
	kFigCaptureSourceAutoFocusRangeRestriction_Far  = 2,
};
extern const CFStringRef kFigCaptureSourceProperty_AdjustingFocus; // read, notify.  boolean.
extern const CFStringRef kFigCaptureSourceProperty_FocusOperation; // RW. CFDictionary (keys below).
	extern const CFStringRef kFigCaptureSourceFocusOperationKey_Mode; // CFNumber (FigCaptureSourceFocusMode).
	extern const CFStringRef kFigCaptureSourceFocusOperationKey_Rect; // dictionary (CGRect). (0.->1. coordinates).
	extern const CFStringRef kFigCaptureSourceFocusOperationKey_RangeRestriction; // CFNumber (FigCaptureSourceAutoFocusRangeRestriction).
	extern const CFStringRef kFigCaptureSourceFocusOperationKey_Smooth; // boolean.
	extern const CFStringRef kFigCaptureSourceFocusOperationKey_Tracking; // boolean. (for kFigCaptureSourceFocusMode_ContinuousAuto only)
	extern const CFStringRef kFigCaptureSourceFocusOperationKey_TrackingDrivesExposure; // boolean. (only present if kFigCaptureSourceFocusOperationKey_Tracking=YES)
	extern const CFStringRef kFigCaptureSourceFocusOperationKey_Position; // float (for manual).
	extern const CFStringRef kFigCaptureSourceFocusOperationKey_RequestID; // int32_t (for manual).
extern const CFStringRef kFigCaptureSourceProperty_FocusLensPosition; // read, notify.  float.
extern const CFStringRef kFigCaptureSourceProperty_TrackingAutoFocusSubjectRect; // dictionary (CGRect). (0.->1. device coordinates), notify only
extern const CFStringRef kFigCaptureSourceProperty_TrackingAutoFocusSubjectAcquired; // boolean. notify only
extern const CFStringRef kFigCaptureSourceProperty_ObservedPropertyCounts; // RW. dict
    
// Exposure
typedef CF_ENUM( int32_t, FigCaptureSourceExposureMode ) {
	kFigCaptureSourceExposureMode_Locked            = 0,
	kFigCaptureSourceExposureMode_Auto              = 1,
	kFigCaptureSourceExposureMode_ContinuousAuto    = 2,
	kFigCaptureSourceExposureMode_Custom            = 3,
};
extern const CFStringRef kFigCaptureSourceProperty_AdjustingExposure; // read, notify.  boolean.
extern const CFStringRef kFigCaptureSourceProperty_ExposureOperation; // RW. CFDictionary (keys below).
	extern const CFStringRef kFigCaptureSourceExposureOperationKey_Mode; // CFNumber (FigCaptureSourceExposureMode).
	extern const CFStringRef kFigCaptureSourceExposureOperationKey_Rect; // dictionary (CGRect). (0.->1. coordinates).
	extern const CFStringRef kFigCaptureSourceExposureOperationKey_Duration; // dictionary (CMTime). (For custom mode only).
	extern const CFStringRef kFigCaptureSourceExposureOperationKey_ActiveMinFrameRate; // double. (For custom mode only).
	extern const CFStringRef kFigCaptureSourceExposureOperationKey_ActiveMaxFrameRate; // double. (For custom mode only).
    extern const CFStringRef kFigCaptureSourceExposureOperationKey_ISO; // float. (For custom mode only).
	extern const CFStringRef kFigCaptureSourceExposureOperationKey_RequestID; // int32_t (for custom mode only).
extern const CFStringRef kFigCaptureSourceProperty_ActiveMaxExposureDuration; // read, notify. dictionary (CMTime).
extern const CFStringRef kFigCaptureSourceProperty_ExposureDuration; // read, notify.  dictionary (CMTime).
extern const CFStringRef kFigCaptureSourceProperty_ISO; // read, notify.  float.
extern const CFStringRef kFigCaptureSourceProperty_ExposureTargetBiasOperation; // RW. CFDictionary (keys below).
	extern const CFStringRef kFigCaptureSourceExposureTargetBiasOperationKey_Bias; // float.
	extern const CFStringRef kFigCaptureSourceExposureTargetBiasOperationKey_RequestID; // int32_t.
extern const CFStringRef kFigCaptureSourceProperty_ExposureTargetBias; // read, notify.  float.
extern const CFStringRef kFigCaptureSourceProperty_ExposureTargetOffset; // read, notify.  float.
	
// White-balance
typedef CF_ENUM( int32_t, FigCaptureSourceWhiteBalanceMode ) {
	kFigCaptureSourceWhiteBalanceMode_Locked            = 0,
	kFigCaptureSourceWhiteBalanceMode_Auto              = 1, // Not currently implemented
	kFigCaptureSourceWhiteBalanceMode_ContinuousAuto    = 2,
};
	
typedef struct {
	float redGain;
	float greenGain;
	float blueGain;
} FigCaptureSourceWhiteBalanceGains;
	
extern const CFStringRef kFigCaptureSourceProperty_AdjustingWhiteBalance; // read, notify.  boolean.
extern const CFStringRef kFigCaptureSourceProperty_WhiteBalanceOperation; // RW. CFDictionary (keys below).
	extern const CFStringRef kFigCaptureSourceWhiteBalanceOperationKey_Mode; // CFNumber (FigCaptureSourceWhiteBalanceMode).
	extern const CFStringRef kFigCaptureSourceWhiteBalanceOperationKey_DeviceWhiteBalanceGains; // CFData (FigCaptureSourceWhiteBalanceGains)
	extern const CFStringRef kFigCaptureSourceWhiteBalanceOperationKey_RequestID; // int32_t (for manual)
extern const CFStringRef kFigCaptureSourceProperty_DeviceWhiteBalanceGains; // read, notify. CFData (FigCaptureSourceWhiteBalanceGains)
extern const CFStringRef kFigCaptureSourceProperty_GrayWorldDeviceWhiteBalanceGains; // read, notify. CFData (FigCaptureSourceWhiteBalanceGains)
extern const CFStringRef kFigCaptureSourceProperty_WhiteBalanceCalibrations; // read-only constant. CFArray ( CFDictionaries ( kFigCaptureSourceWhiteBalanceCalibrationsKey_* ) ), see kFigCaptureStreamProperty_WhiteBalanceCalibrations
	extern const CFStringRef kFigCaptureSourceWhiteBalanceCalibrationsKey_Temperature; // read-only constant. CFNumber (SInt32), see kFigCaptureStreamWhiteBalanceCalibrationKey_Temperature
	extern const CFStringRef kFigCaptureSourceWhiteBalanceCalibrationsKey_DeviceRGBToXYZMatrix; // read-only constant. CFData (float[9], 3x3 matrix in row-major order), see kFigCaptureStreamWhiteBalanceCalibrationKey_DeviceRGBToXYZMatrix
	
// Flash
extern const CFStringRef kFigCaptureSourceProperty_FlashOverheated; // read, notify.  boolean.
// *NOTE* flashMode (on/off/auto) is now specified in the still image configuration when calling FigCaptureSessionCaptureStillImage()
	
// Torch
extern const CFStringRef kFigCaptureSourceProperty_TorchActive; // read, notify.  boolean. Will it fire? (for auto-torch)
extern const CFStringRef kFigCaptureSourceProperty_TorchOverheated; // read, notify.  boolean.
extern const CFStringRef kFigCaptureSourceProperty_TorchLevel; // RW, notify. float.
extern const CFStringRef kFigCaptureSourceProperty_AutoTorchEnabled; // RW. boolean.  Set this to true to receive "torch active" notifications, and turn on torch during video recording.
// How to handle "auto" torch (so that it works correctly for VDO and/or multiple MFOs)

// Digital Flash
#if FIG_CAPTURE_LOW_LIGHT_SUPPORTED
extern const CFStringRef kFigCaptureSourceProperty_DigitalFlashMode; // write-only. FigCaptureDigitalFlashMode.
#endif // FIG_CAPTURE_LOW_LIGHT_SUPPORTED
	
// Subject area monitoring
extern const CFStringRef kFigCaptureSourceProperty_SubjectAreaChangeMonitoringEnabled; // RW. boolean.

// Client-specified metadata
extern const CFStringRef kFigCaptureSourceProperty_ProvidesStortorgetMetadata; // RW. boolean.

// Image control mode
typedef CF_ENUM( int32_t, FigCaptureSourceImageControlMode ) {
	kFigCaptureSourceImageControlMode_StillImagePreview  = 0,
	kFigCaptureSourceImageControlMode_VideoPreview       = 1,
	kFigCaptureSourceImageControlMode_VideoRecording     = 2,
	kFigCaptureSourceImageControlMode_VideoConferencing  = 3,
	kFigCaptureSourceImageControlMode_Panorama           = 4,
};
extern const CFStringRef kFigCaptureSourceProperty_AutoAdjustImageControlMode; // RW. boolean.
extern const CFStringRef kFigCaptureSourceProperty_ImageControlMode; // RW, notify. CFNumber (FigCaptureSourceImageControlMode).
	
// Face Detection Configuration
extern const CFStringRef kFigCaptureSourceProperty_SupportedOptionalFaceDetectionFeatures; // Read-only. CFDictionary.
	extern const CFStringRef kFigCaptureSourceOptionalFaceDetectionFeatureKey_EyeDetection; // CFBooleanTrue if source supports eye detection
	extern const CFStringRef kFigCaptureSourceOptionalFaceDetectionFeatureKey_BlinkDetection; // CFBooleanTrue if source supports blink detection (requires eye detection to be enabled)
	extern const CFStringRef kFigCaptureSourceOptionalFaceDetectionFeatureKey_SmileDetection; // CFBooleanTrue if source supports smile detection
	
extern const CFStringRef kFigCaptureSourceProperty_FaceDetectionConfiguration; // RW. CFDictionary (keys below).
	extern const CFStringRef kFigCaptureSourceFaceDetectionConfigurationKey_EyeDetectionEnabled; // RW. boolean
	extern const CFStringRef kFigCaptureSourceFaceDetectionConfigurationKey_BlinkDetectionEnabled; // RW. boolean
	extern const CFStringRef kFigCaptureSourceFaceDetectionConfigurationKey_SmileDetectionEnabled; // RW. boolean
	
// Face driven ae/af
extern const CFStringRef kFigCaptureSourceProperty_FaceDrivenImageProcessingEnabled; // RW. boolean.
	
// Scene Monitoring
extern const CFStringRef kFigCaptureSourceProperty_StillImageSceneMonitoringConfiguration; // RW. CFDictionary (kFigCaptureSourceStillImageSceneMonitoringConfigurationKey*).
	extern const CFStringRef kFigCaptureSourceStillImageSceneMonitoringConfigurationKey_FlashMode; // RW. CFNumber (FigCaptureFlashMode)
	extern const CFStringRef kFigCaptureSourceStillImageSceneMonitoringConfigurationKey_HDRMode; // RW. CFNumber (FigCaptureHDRMode)
	extern const CFStringRef kFigCaptureSourceStillImageSceneMonitoringConfigurationKey_QualityPrioritization; // RW. CFNumber (FigCaptureQualityPrioritization)
#if FIG_CAPTURE_LOW_LIGHT_SUPPORTED
	extern const CFStringRef kFigCaptureSourceStillImageSceneMonitoringConfigurationKey_DigitalFlashMode; // RW. CFNumber (FigCaptureDigitalFlashMode)
#endif // FIG_CAPTURE_LOW_LIGHT_SUPPORTED
	
extern const CFStringRef kFigCaptureSourceProperty_IsHDRScene; // read. boolean.
extern const CFStringRef kFigCaptureSourceProperty_IsStillImageStabilizationScene; // read. boolean. (legacy -- AVF property has been deprecated, without replacement)
#if FIG_CAPTURE_LOW_LIGHT_SUPPORTED
extern const CFStringRef kFigCaptureSourceProperty_DigitalFlashStatus; // read. CFNumber(int32_t), same values as AVCaptureDigitalFlashStatus
extern const CFStringRef kFigCaptureSourceProperty_DigitalFlashExposureTimes; // read. CFDictionary( kFigCaptureSourceDigitalFlashExposureTimesProperty_* -> CFNumber( double ) )
	extern const CFStringRef kFigCaptureSourceDigitalFlashExposureTimesProperty_Min; // CFNumber( double )
	extern const CFStringRef kFigCaptureSourceDigitalFlashExposureTimesProperty_Max; // CFNumber( double )
#endif // FIG_CAPTURE_LOW_LIGHT_SUPPORTED
	
// Zoom
extern const CFStringRef kFigCaptureSourceProperty_VideoZoomFactor; // RW, notify. CFNumber (float) / CFDictionary(kFigCaptureSourceVideoZoomFactorPropertyKey_*) for ramps.
	extern const CFStringRef kFigCaptureSourceVideoZoomFactorPropertyKey_ZoomFactor; // CFNumber (float)
	extern const CFStringRef kFigCaptureSourceVideoZoomFactorPropertyKey_ZoomRampRate; // CFNumber (float)
	extern const CFStringRef kFigCaptureSourceVideoZoomFactorPropertyKey_ZoomRampDuration; // CFNumber (double)
	extern const CFStringRef kFigCaptureSourceVideoZoomFactorPropertyKey_ZoomRampType; // CFNumber (FigCaptureSourceVideoZoomRampType)
	typedef CF_ENUM( int32_t, FigCaptureSourceVideoZoomRampType ) {
		kFigCaptureSourceVideoZoomRampType_None						= 0,
		kFigCaptureSourceVideoZoomRampType_DoublingRateBased		= 1,
		kFigCaptureSourceVideoZoomRampType_ExponentialDurationBased	= 2,
	};
	extern const CFStringRef kFigCaptureSourceVideoZoomFactorPropertyKey_ZoomRampCommandID; // CFNumber (SInt32)
extern const CFStringRef kFigCaptureSourceProperty_VideoZoomRampAcceleration; // RW. CFNumber (float).
// *NOTE* max video zoom factor and upscale threshold are in the FigCaptureSourceVideoFormat object
	
extern const CFStringRef kFigCaptureSourceProperty_AvailableMetadataKeyGroups; // read.
	
extern const CFStringRef kFigCaptureSourceProperty_AVCaptureSessionPresetCompressionSettings; // read. CFDictionary(keys are @"AVCaptureSessionPreset*", values are AVVideoSettings dictionaries).
extern const CFStringRef kFigCaptureSourceProperty_AVH264Settings; // read. CFDictionary (Photo and Video max sizes that are safe to encode/decode on the platform).
extern const CFStringRef kFigCaptureSourceProperty_AVHEVCSettings; // read. CFDictionary HEVC Encoder limitations.

// Calibrations
extern const CFStringRef kFigCaptureSourceProperty_AutoFocusPositionSensorCalibration; // read. CFDictionary .
	
// System pressure
	
// Keep this in sync with BWSystemPressureLevel.
typedef CF_ENUM( int32_t, FigCaptureSourceSystemPressureLevel )
{
	kFigCaptureSourceSystemPressureLevel_Nominal  = 0,
	kFigCaptureSourceSystemPressureLevel_Fair     = 1,
	kFigCaptureSourceSystemPressureLevel_Serious  = 2,
	kFigCaptureSourceSystemPressureLevel_Critical = 3,
	kFigCaptureSourceSystemPressureLevel_Shutdown = 4,
};
	
// Keep this enum in sync with AVCaptureSystemPressureFactors.
typedef CF_OPTIONS( uint32_t, FigCaptureSourceSystemPressureFactors )
{
    kFigCaptureSourceSystemPressureFactorNone                   = 0UL,
    kFigCaptureSourceSystemPressureFactorSystemTemperature      = (1UL << 0),
    kFigCaptureSourceSystemPressureFactorPeakPower              = (1UL << 1),
    kFigCaptureSourceSystemPressureFactorDepthModuleTemperature = (1UL << 2),
};
	
extern const CFStringRef kFigCaptureSourceProperty_SystemPressureState; // read. CFDictionary.
	extern const CFStringRef kFigCaptureSourceSystemPressureStatePropertyKey_Level; // CFNumber (FigCaptureSourceSystemPressureLevel)
	extern const CFStringRef kFigCaptureSourceSystemPressureStatePropertyKey_Factors; // CFNumber (FigCaptureSourceSystemPressureFactors)
	
// NOTIFICATIONS
extern const CFStringRef kFigCaptureSourceNotificationKey_OldPropertyValue;
extern const CFStringRef kFigCaptureSourceNotificationKey_NewPropertyValue;
extern const CFStringRef kFigCaptureSourceNotificationKey_ManualControlRequestID; // int32_t
	
// Notifications have the same names as the kFigCaptureSourceProperty_'s, except for the following notifications, which have no accompanying property
extern const CFStringRef kFigCaptureSourceNotification_ServerConnectionDied; // no payload
extern const CFStringRef kFigCaptureSourceNotification_SubjectAreaChanged; // Only gets delivered when SubjectAreaChangedMonitoringEnabled is set to true
extern const CFStringRef kFigCaptureSourceNotification_FaceDrivenImageProcessingFaceChanged; // (for camera app). payload is a face object of some kind.
extern const CFStringRef kFigCaptureSourceNotification_ManualFocusComplete; // CMTime dictionary(_NewPropertyValue) + RequestID(_ManualControlRequestID)
extern const CFStringRef kFigCaptureSourceNotification_ManualExposureComplete; // CMTime dictionary(_NewPropertyValue) + RequestID(_ManualControlRequestID)
extern const CFStringRef kFigCaptureSourceNotification_BiasedExposureComplete; // CMTime dictionary(_NewPropertyValue) + RequestID(_ManualControlRequestID)
extern const CFStringRef kFigCaptureSourceNotification_ManualWhiteBalanceComplete; // CMTime dictionary(_NewPropertyValue) + RequestID(_ManualControlRequestID)
	extern const CFStringRef kFigCaptureSourceFaceDrivenImageProcessingFaceChangedNotificationPayloadKey_Rect; // dictionary (CGRect). (0.->1. coordinates).
	extern const CFStringRef kFigCaptureSourceFaceDrivenImageProcessingFaceChangedNotificationPayloadKey_Angle; // CFNumber (int)
	extern const CFStringRef kFigCaptureSourceNotification_SourceDeactivated; // no payload
	extern const CFStringRef kFigCaptureSourceNotification_DeviceDisconnected; // no payload

extern const CFStringRef kFigCaptureSourceNotification_VideoZoomRampUpdate; // CFDictionary (kFigCaptureSourceVideoZoomRampUpdateNotificationPayloadKey_*)
	extern const CFStringRef kFigCaptureSourceVideoZoomRampUpdateNotificationPayloadKey_ZoomFactor; // CFNumber (float)
	extern const CFStringRef kFigCaptureSourceVideoZoomRampUpdateNotificationPayloadKey_ZoomRampCommandID; // CFNumber (int32_t)
	extern const CFStringRef kFigCaptureSourceVideoZoomRampUpdateNotificationPayloadKey_ZoomRampComplete; // CFNumber (boolean)

extern const CFStringRef kFigCaptureSourceNotification_StillImageSceneChanged; // CFDictionary (kFigCaptureSourceStillImageSceneChangedPayloadKey*)
	extern const CFStringRef kFigCaptureSourceStillImageSceneChangedPayloadKey_FlashScene; // CFNumber (boolean)
	extern const CFStringRef kFigCaptureSourceStillImageSceneChangedPayloadKey_HDRScene; // CFNumber (boolean)
	extern const CFStringRef kFigCaptureSourceStillImageSceneChangedPayloadKey_SISScene; // CFNumber (boolean)
#if FIG_CAPTURE_LOW_LIGHT_SUPPORTED
	extern const CFStringRef kFigCaptureSourceStillImageSceneChangedPayloadKey_DigitalFlashScene; // CFDictionary( kFigCaptureSourceStillImageDigitalFlashSceneChangedPayloadKey_* )
		extern const CFStringRef kFigCaptureSourceStillImageDigitalFlashSceneChangedPayloadKey_Status; // CFNumber (int32_t), same values as AVCaptureDigitalFlashStatus
		extern const CFStringRef kFigCaptureSourceStillImageDigitalFlashSceneChangedPayloadKey_ExposureTimes; // CFDictionary( kFigCaptureSourceStillImageDigitalFlashSceneChangedExposureTimesPayloadKey_* -> CFNumber( double ) )
			extern const CFStringRef kFigCaptureSourceStillImageDigitalFlashSceneChangedExposureTimesPayloadKey_Min; // CFNumber( double )
			extern const CFStringRef kFigCaptureSourceStillImageDigitalFlashSceneChangedExposureTimesPayloadKey_Max; // CFNumber( double )
#endif // FIG_CAPTURE_LOW_LIGHT_SUPPORTED

extern const CFStringRef kFigCaptureSourceNotification_ShallowDepthOfFieldStatusChanged; // CFDictionary (int32_t) (kFigCaptureSourceShallowDepthOfFieldStatusChangedPayloadKey*)
	extern const CFStringRef kFigCaptureSourceShallowDepthOfFieldStatusChangedPayloadKey_EffectStatus; // CFNumber (int32_t), same values as AVCaptureShallowDepthOfFieldEffectStatus
	extern const CFStringRef kFigCaptureSourceShallowDepthOfFieldStatusChangedPayloadKey_StagePreviewStatus; // CFNumber (int32_t), same values as AVCaptureShallowDepthOfFieldStagePreviewStatus
	
// Bravo
extern const CFStringRef kFigCaptureSourceProperty_BravoCameraSelectionBehavior; // RW, notify. CFNumber (FigCaptureBravoCameraSelectionBehavior).
extern const CFStringRef kFigCaptureSourceNotificationKey_MinAvailableVideoZoomFactor; // CFNumber (float)

extern const CFStringRef kFigCaptureSourceProperty_NonDestructiveCropSize; // RW. CFDictionary( CGSize )

// VideoHDR
extern const CFStringRef kFigCaptureSourceProperty_VideoHDRSuspended; // write-only, CFNumber (boolean).
	
// Deprecated; can be removed once the rev-locked AVF changes land that no longer use these keys.
extern const CFStringRef kFigCaptureSourceProperty_AutoFlashEnabled; // RW. boolean.  Set this to true to receive "flash active" notifications.
extern const CFStringRef kFigCaptureSourceProperty_FlashActive; // read, notify.  boolean. Will it fire? Used by auto-flash mode.
extern const CFStringRef kFigCaptureSourceProperty_HDRSceneDetectionEnabled; // RW. boolean.
// Still Image Stabilization
extern const CFStringRef kFigCaptureSourceProperty_StillImageStabilizationAutomaticallyEnabled; // RW.  boolean.  YES == automatically engages SIS or OIS to improve low light still image captures when appropriate


#pragma pack(pop)
    
#ifdef __cplusplus
}
#endif

// Glue is implemented inline to allow clients to step through it
#include <Celestial/FigCaptureSourceDispatch.h>

#endif // FIGCAPTURESOURCE_H
