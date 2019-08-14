/*
	File:			FigCaptureSession.h
	Description: 	High-level live-preview/still image/recording object
	Authors:		Brad Ford and Walker Eagleston
	Creation Date:	10/11/13
	Copyright: 		© Copyright 2013-2019 Apple, Inc. All rights reserved.
*/

#ifndef FIGCAPTURESESSION_H
#define FIGCAPTURESESSION_H

#import <Celestial/FigCaptureCommon.h>

#import <Celestial/FigCaptureSessionConfiguration.h>
#import <Celestial/FigCaptureStillImageSettings.h>
#import <Celestial/FigCaptureRecordingSettings.h>
#import <Celestial/FigMomentCaptureSettings.h>

#import <CoreMedia/CMBase.h>
#import <CoreMedia/CMBaseObject.h>

#import <CoreMedia/CMNotificationCenter.h>
#import <CoreMedia/FigCaptureHideFeatures.h>


#ifdef __cplusplus
extern "C" {
#endif
    
#pragma pack(push, 4)


#pragma mark - FigCaptureSession

// FigCaptureSession.h owns:
//	-15430 to -15439
//	-16400 to -16419
//	-16950 to -16959
enum {
	kFigCaptureSessionError_InvalidSectionID				= -16400,
	kFigCaptureSessionError_InvalidConfiguration			= -16401,
	kFigCaptureSessionError_Interrupted						= -16402,
	// 16403 and 16404 are used internally
	kFigCaptureSessionError_ServerConnectionDied			= -16405,
	kFigCaptureSessionError_FrameReceiveTimeout				= -16406,
	// 16407 and 16408 are used internally
	kFigCaptureSessionError_SessionNotRunning				= -16409,
	// 16410 is used internally
};

typedef struct OpaqueFigCaptureSession *FigCaptureSessionRef;	// a CF type (FBO)

extern CMBaseClassID FigCaptureSessionGetClassID( void );
extern CFTypeID FigCaptureSessionGetTypeID( void );

extern OSStatus FigCaptureSessionCreate( CFAllocatorRef allocator, FigCaptureSessionRef *captureSessionOut );

CM_INLINE OSStatus FigCaptureSessionInvalidate( FigCaptureSessionRef session );


#pragma mark Properties

CM_INLINE OSStatus FigCaptureSessionSetProperty( FigCaptureSessionRef session, CFStringRef propertyKey, CFTypeRef propertyValue );
CM_INLINE OSStatus FigCaptureSessionSetSectionProperty( FigCaptureSessionRef session, CFStringRef sectionID, CFStringRef propertyKey, CFTypeRef propertyValue );

CM_INLINE OSStatus FigCaptureSessionCopyProperty( FigCaptureSessionRef session, CFStringRef propertyKey, CFAllocatorRef allocator, void *propertyValueOut );
CM_INLINE OSStatus FigCaptureSessionCopySectionProperty( FigCaptureSessionRef session, CFStringRef sectionID, CFStringRef propertyKey, CFAllocatorRef allocator, void *propertyValueOut );


#pragma mark Session Properties
	
extern const CFStringRef kFigCaptureSessionProperty_ClientAuditToken; // write only, audit_token_t in a CFData.  Set by FigCaptureSessionServer (never by a client process).
extern const CFStringRef kFigCaptureSessionProperty_ClientIsAVConference; // write only, BOOL. Set by AVConference with an AVCaptureSession created in mediaserverd.
extern const CFStringRef kFigCaptureSessionProperty_ClientVersionOfLinkedSDK; // write only, uint32_t. Set by FigCaptureSessionRemote. Used by FigCaptureSession for linked-on-or-after checks.
extern const CFStringRef kFigCaptureSessionProperty_ForegroundAutoResumeStopTime; // write only, NSTimeInterval. Set by FigCaptureSessionRemote. Used by FigCaptureSession to stop foreground auto resume after a specified time.
	

#pragma mark Configuration

// The configuration is a description of the graph
// Sources, sinks, and connections (source->sink) are described. The client can specify a unqiue section ID for each source/sink/connection and message them with the above Set/CopySectionProperty methods.
CM_INLINE void FigCaptureSessionSetConfiguration( FigCaptureSessionRef session, FigCaptureSessionConfiguration *configuration );
// When the configuration has been committed kFigCaptureSessionNotification_ConfigurationCommitted will fire
// At this point it is okay to message the new sections via FigCaptureSessionSet/CopySectionProperty()
// If the specified configuration is invalid kFigCaptureSessionNotification_ConfigurationCommitted still fires, but the notification contains an error payload
// In this case the session will remain in its current configuration and the new sections are not available
// If a configuration is valid but we fail to bring it live then the session will stop running and kFigCaptureSessionNotification_DidStopRunning will fire containing an error payload
// kFigCaptureSessionNotification_ConfigurationDidBecomeLive will not be sent in this case (I don't want to have to define the ordering between that notification and kFigCaptureSessionNotification_DidStopRunning)
// If the session is not yet running the configuration is still committed, but it will not become live until the session starts running.
// In this case kFigCaptureSessionNotification_ConfigurationDidBecomeLive will fire immediately before kFigCaptureSessionNotification_DidStartRunning.
extern const CFStringRef kFigCaptureSessionNotification_ConfigurationCommitted; // payload includes configurationID and potentially an error, safe to message the new section IDs now if no error
extern const CFStringRef kFigCaptureSessionNotification_ConfigurationDidBecomeLive; // payload includes configurationID, this is when AVF should stop blocking in its _buildAndRunGraph method (if we aren't using Sylvain's non-blocking variant)
extern const CFStringRef kFigCaptureSessionNotification_ServerConnectionDied; // no payload


#pragma mark Start/Stop

CM_INLINE void FigCaptureSessionStartRunning( FigCaptureSessionRef session );
CM_INLINE void FigCaptureSessionStopRunning( FigCaptureSessionRef session );

// Think about this more later, non-ending interruptions are the tricky part
extern const CFStringRef kFigCaptureSessionNotification_DidStartRunning;
extern const CFStringRef kFigCaptureSessionNotification_DidStopRunning; // error payload if it stopped due to an interruption or other runtime problem
// As with FigCaptureSessionSetConfiguration() these notifications mark when AVF should stop blocking in its _buildAndRunGraph method (if we aren't using Sylvain's non-blocking variant)

// During interruptions (background app transtition, music, alarm, phone call) the session will send kFigCaptureSessionNotification_DidStopRunning with an error payload of kFigCaptureSessionError_Interrupted
// The sesion will attempt to auto-resume when the interruption ends
// If the client attempts to restart the session while its interrupted they'll get another didStop notification with an eror payload of kFigCaptureSessionError_Interrupted
// Autoresume will continue to work
// If the client explicitly calls FigCaptureSessionStopRunning while the capture session is interrupted then auto-resume will be disabled

// When kFigCaptureSessionNotification_DidStopRunning fires with an error payload of kFigCaptureSessionError_Interrupted there will also be an error reason payload with the following possible values:
typedef CF_ENUM( int32_t, FigCaptureSessionInterruptionErrorReason ) {
	kFigCaptureSessionInterruptionErrorReason_VideoDeviceNotAvailableInBackground	= 1, // will auto-resume when the app enters the foreground again
	kFigCaptureSessionInterruptionErrorReason_AudioDeviceTemporarilyUnavailable, // will auto-resume when the interruption ends
	kFigCaptureSessionInterruptionErrorReason_AudioDeviceUnavailable, // non-resumable interruption, but we get to poll when the app is foregrounded, need to see if the CMSession guys can give us a notification for the non-resumable kind (or does that defeat the purpose?)
	kFigCaptureSessionInterruptionErrorReason_VideoDeviceInUseByOtherClient, // will auto-resume when device is available again
	kFigCaptureSessionInterruptionErrorReason_VideoDeviceNotAvailableInWindowedMode, // will auto-resume when app runs in fullscreen mode
	kFigCaptureSessionInterruptionErrorReason_VideoDeviceNotAvailableDueToSystemPressure, // will auto-resume when system pressure abates
};


#pragma mark Notifications

// All notifications are serialized on a dispatch_queue.
// But apparently we don't give you access to it? How can a client serialize unregistration?
// Maybe we want to mirror our setDelegate:queue: API interfaces and provide a queue setter/getter? --walker
	
// All notifications posted to CMNotificationCenterGetDefaultLocalCenter()
	
// Common Notification Payload Keys
extern const CFStringRef kFigCaptureSessionNotificationPayloadKey_SectionID; // CFStringRef, always present when the notification comes from a specific section

extern const CFStringRef kFigCaptureSessionNotificationPayloadKey_ConfigurationID; // int64_t, included in the payloads of kFigCaptureSessionNotification_ConfigurationCommitted/Live

extern const CFStringRef kFigCaptureSessionNotificationPayloadKey_SettingsID; // int64_t, included in the payloads of sink notifications where the sink takes a settings object for each request. This allows the client can track when a given recording/image capture completes or fails.
	
extern const CFStringRef kFigCaptureSessionNotificationPayloadKey_ErrorStatus; // OSStatus (int32_t)
extern const CFStringRef kFigCaptureSessionNotificationPayloadKey_ErrorReason; // int32_t with a unique enum for each error code, for example kFigCaptureSessionInterruptionErrorReason

extern const CFStringRef kFigCaptureSessionNotificationPayloadKey_FormatDescription; // CMFormatDescriptionRef

extern const CFStringRef kFigCaptureSessionNotificationPayloadKey_SampleBuffer; // CMSampleBufferRef
extern const CFStringRef kFigCaptureSessionNotificationPayloadKey_PreviewSampleBuffer; // CMSampleBufferRef

extern const CFStringRef kFigCaptureSessionNotificationPayloadKey_MasterClock;     // CMClockRef
extern const CFStringRef kFigCaptureSessionNotificationPayloadKey_MasterClockType; // CFNumber(FigCaptureSourceClockType)
	

// The following PayloadKeys may be present in the kFigCaptureSessionStillImageSinkNotification_StillImageComplete, kFigCaptureSessionIrisStillImageSinkNotification_StillImageComplete, or kFigCaptureSessionIrisStillImageSinkNotification_RawStillImageComplete notifications.
extern const CFStringRef kFigCaptureSessionNotificationPayloadKey_Surface; // IOSurfaceRef
extern const CFStringRef kFigCaptureSessionNotificationPayloadKey_SurfaceSize; // size_t
extern const CFStringRef kFigCaptureSessionNotificationPayloadKey_PhotoCodec; // OSType
extern const CFStringRef kFigCaptureSessionNotificationPayloadKey_PhotoFileType; // FigCaptureStillImageSettingsFileType
extern const CFStringRef kFigCaptureSessionNotificationPayloadKey_PreviewSurface; // IOSurfaceRef
extern const CFStringRef kFigCaptureSessionNotificationPayloadKey_PreviewSurfaceSize; // size_t
extern const CFStringRef kFigCaptureSessionNotificationPayloadKey_ThumbnailSurface; // IOSurfaceRef
extern const CFStringRef kFigCaptureSessionNotificationPayloadKey_Metadata; // CFDictionaryRef
extern const CFStringRef kFigCaptureSessionNotificationPayloadKey_PresentationTimestamp; // CFDictionaryRef(CMTime)
extern const CFStringRef kFigCaptureSessionNotificationPayloadKey_DepthDataSurface; // IOSurfaceRef
extern const CFStringRef kFigCaptureSessionNotificationPayloadKey_DepthMetadata; // CFDictionaryRef containing the same keys as kFigSampleBufferAttachmentKey_DepthMetadata (see <CoreMedia/FigDepthUtilities.h>)
extern const CFStringRef kFigCaptureSessionNotificationPayloadKey_PortraitEffectsMatteSurface; // IOSurfaceRef
extern const CFStringRef kFigCaptureSessionNotificationPayloadKey_PortraitEffectsMatteMetadata; // CFDictionaryRef containing the same keys as kFigSampleBufferAttachmentKey_PortraitEffectsMatteMetadata (see <CoreMedia/FigDepthUtilities.h>)
#if FIG_CAPTURE_SEMANTIC_SEGMENTATION_ENABLED
extern const CFStringRef kFigCaptureSessionNotificationPayloadKey_HairSegmentationMatteSurface; // IOSurfaceRef
extern const CFStringRef kFigCaptureSessionNotificationPayloadKey_HairSegmentationMatteMetadata; // CFDictionaryRef containing the same keys as kFigSampleBufferAttachmentKey_SemanticSegmentationMatteMetadata (see <CoreMedia/FigDepthUtilities.h>)
extern const CFStringRef kFigCaptureSessionNotificationPayloadKey_SkinSegmentationMatteSurface; // IOSurfaceRef
extern const CFStringRef kFigCaptureSessionNotificationPayloadKey_SkinSegmentationMatteMetadata; // CFDictionaryRef containing the same keys as kFigSampleBufferAttachmentKey_SemanticSegmentationMatteMetadata (see <CoreMedia/FigDepthUtilities.h>)
extern const CFStringRef kFigCaptureSessionNotificationPayloadKey_TeethSegmentationMatteSurface; // IOSurfaceRef
extern const CFStringRef kFigCaptureSessionNotificationPayloadKey_TeethSegmentationMatteMetadata; // CFDictionaryRef containing the same keys as kFigSampleBufferAttachmentKey_SemanticSegmentationMatteMetadata (see <CoreMedia/FigDepthUtilities.h>)
#endif // FIG_CAPTURE_SEMANTIC_SEGMENTATION_ENABLED
#if FIG_CAPTURE_DEFERRED_PROCESSING_SUPPORTED
extern const CFStringRef kFigCaptureSessionNotificationPayloadKey_DeferredPhotoProxySurface; // IOSurfaceRef
extern const CFStringRef kFigCaptureSessionNotificationPayloadKey_DeferredPhotoProxySurfaceSize; // size_t
extern const CFStringRef kFigCaptureSessionNotificationPayloadKey_DeferredPhotoProxyCodec; // OSType
extern const CFStringRef kFigCaptureSessionNotificationPayloadKey_DeferredPhotoProxyFileType; // FigCaptureStillImageSettingsFileType

// These next two match the constants for the strings in FigCaptureDeferredPhotoProcessor.h.
// For deferred photos, the captureRequestIdentifier is used to refer to all photos delivered from the FigCaptureStillImageSettings, and each photo has its own unique identifier; when invoking the Deferred Processor's APIs, both identifiers are used to resolve intermediate files in an <app bundle id>/<CaptureRequestIdentifier>/<PhotoIdentifier> directory structure.
extern const CFStringRef kFigCaptureSessionNotificationPayloadKey_CaptureRequestIdentifier; // UUID (CFStringRef)
extern const CFStringRef kFigCaptureSessionNotificationPayloadKey_PhotoIdentifier; // UUID (CFStringRef)
#endif // FIG_CAPTURE_DEFERRED_PROCESSING_SUPPORTED
extern const CFStringRef kFigCaptureSessionNotificationPayloadKey_DebugMetadataSidecarFilePath; // CFString specifying the path to an associated debug metadata sidecar file
	
extern const CFStringRef kFigCaptureSessionNotificationPayloadKey_RecordingSucceeded; // CFBooleanRef (only present in the kFigCaptureSessionFileSinkNotification_DidStopRecording and kFigCaptureSessionIrisStillImageSinkNotification_DidFinishRecordingIrisMovie notifications if kFigCaptureSessionNotificationPayloadKey_ErrorStatus is also present and non-zero.
	
#pragma mark - Sources

//extern const CFStringRef kFigCaptureSessionSourceNotification_SourceDidStart;
//extern const CFStringRef kFigCaptureSessionSourceNotification_SourceDidStop;
// Not needed, unless we still need to support the AVF source started notification SPI for Camera app, need to figure out if this is necessary
extern const CFStringRef kFigCaptureSessionSourceNotification_SourceFormatDidChange; // payload contains a format description
	
#pragma mark Audio
extern const CFStringRef kFigCaptureSessionAudioSourceProperty_AudioMeteringLevels; // readonly, CFArray of floating point values in dB.  Two levels per channel (Average, then peak power).  Poll as frequently as you'd like.

// For now the source aren't dynamically controllable, only via the capture session configuration
// Need to figure out what we are doing with FigCaptureSource before we invest a lot of implementation effort here --walker

#pragma mark Metadata

extern const CFStringRef kFigCaptureSessionMetadataSourceProperty_MetadataSampleBuffer; // writeonly, CMSampleBuffer representing boxed metadata sample buffer
extern const CFStringRef kFigCaptureSessionMetadataSourceProperty_MetadataFormatDescription; // readonly, CMMetadataFormatDescription, called internally by captureSessionServer_handleSessionSetSectionPropertyMessage
																							 //		to get the format description for a buffer it is deserializing (metadata format descriptions are static, so
																							 //		we don't bother sending them over with the sbuf.

#pragma mark - Connections

#pragma mark Video Connections

// Video connection specific properties
extern const CFStringRef kFigCaptureSessionVideoConnectionProperty_VideoOrientation; // writeonly, a FigCaptureVideoOrientation
extern const CFStringRef kFigCaptureSessionVideoConnectionProperty_VideoMirrored; // writeonly, a BOOL


#pragma mark - Sinks

extern const CFStringRef kFigCaptureSessionSinkNotification_RemoteQueueUpdated;  // Sent to clients running outside mediaserverd
	extern const CFStringRef kFigCaptureSessionRemoteQueueUpdatedNotificationPayloadKey_RemoteQueueReceiver; // FigRemoteQueueReceiverRef

extern const CFStringRef kFigCaptureSessionSinkNotification_LocalQueueUpdated;  // Sent to clients running inside mediaserverd
	extern const CFStringRef kFigCaptureSessionLocalQueueUpdatedNotificationPayloadKey_LocalQueue; // FigLocalQueueRef


#pragma mark Preview
	
extern const CFStringRef kFigCaptureSessionPreviewSinkProperty_Filters; // writeonly, CFArray of CIFilters to apply to video preview.
extern const CFStringRef kFigCaptureSessionPreviewSinkProperty_SimulatedAperture; // writeonly, CFNumber (float) to apply to the preview
#if FIG_CAPTURE_ADJUSTABLE_PORTRAIT_LIGHTING_STRENGTH
	extern const CFStringRef kFigCaptureSessionPreviewSinkProperty_PortraitLightingEffectStrength; // writeonly, CFNumber (float) to apply to the preview
#endif // FIG_CAPTURE_ADJUSTABLE_PORTRAIT_LIGHTING_STRENGTH

#if FIG_CAPTURE_OVERCAPTURE_SUPPORTED
// Over Capture
extern const CFStringRef kFigCaptureSessionPreviewSinkProperty_PrimaryCaptureRect; // writeonly, CFDictionary
	extern const CFStringRef kFigCaptureSessionPreviewSinkPrimaryCaptureRectKey_AspectRatio; // float, use 0.f for native aspect
	extern const CFStringRef kFigCaptureSessionPreviewSinkPrimaryCaptureRectKey_CenterX;
	extern const CFStringRef kFigCaptureSessionPreviewSinkPrimaryCaptureRectKey_CenterY;
	// Fence to set on CAContext(s) involved in rendering the updated aspect ratio to sync the presentation of their CATransactions with the client's.
	extern const CFStringRef kFigCaptureSessionPreviewSinkPrimaryCaptureRectKey_CAContextFencePortSendRight; // FigCaptureMachPortSendRight
extern const CFStringRef kFigCaptureSessionPreviewSinkProperty_PrimaryAndOverCaptureCompositingEnabled; // writeonly, CFBooleanRef, default YES
#endif // FIG_CAPTURE_OVERCAPTURE_SUPPORTED

extern const CFStringRef kFigCaptureSessionPreviewSinkNotification_DidStartPreviewing;
extern const CFStringRef kFigCaptureSessionPreviewSinkNotification_DidStopPreviewing; // can contain error payload if there was an error. Do we need to define the ordering with respect to kFigCaptureSessionNotification_DidStopRunning? --walker
//extern const CFStringRef kFigCaptureSessionPreviewSinkNotification_PreviewFormatWillChange; // start of the discontinuity, preview will hang on the most recently displayed frame (should we include that here?) --walker
extern const CFStringRef kFigCaptureSessionPreviewSinkNotification_PreviewFormatDidChange; // payload contains a CMFormatDescriptionRef
// FigCaptureSession is responsible for determining the preview size, it is not specified by the client in the configuration

extern const CFStringRef kFigCaptureSessionProperty_RemoteVideoPreviewEnabled; // write only, default false, session property, remote/server should not change this property after setting the first configuration which includes a preview sink

extern const CFStringRef kFigCaptureSessionVideoPreviewSinkNotification_ImageQueueUpdated; // updated image queue or slot included in notification payload, along with the rotation degrees applied to all buffers in the queue
	extern const CFStringRef kFigCaptureSessionImageQueueUpdatedNotificationPayloadKey_ImageQueue; // CAImageQueueRef
	extern const CFStringRef kFigCaptureSessionImageQueueUpdatedNotificationPayloadKey_ImageQueueSlot; // uint32_t
	// Applied so backboardd doesn't need to do an additional m2m pass before sending the IOSurfaces to the YUV layer of the display pipe
	// To get back to the native sensor orientation you must reverse this transformation
	// This value is constant for a given device, but will be sent with each kFigCaptureSessionVideoPreviewSinkNotification_ImageQueueUpdated
	extern const CFStringRef kFigCaptureSessionImageQueueUpdatedNotificationPayloadKey_RotationDegrees; // int32_t, the number of degrees of clockwise rotation that have been burned into the buffers in this image queue
	// These are the initial image queue dimensions. Updated dimensions are provided through kFigCaptureSessionPreviewSinkNotification_PreviewFormatDidChange.
	extern const CFStringRef kFigCaptureSessionImageQueueUpdatedNotificationPayloadKey_ImageQueueWidth; // int32_t, the initial width of the image queue
	extern const CFStringRef kFigCaptureSessionImageQueueUpdatedNotificationPayloadKey_ImageQueueHeight; // int32_t, the initial height of the image queue

#if FIG_CAPTURE_OVERCAPTURE_SUPPORTED
extern const CFStringRef kFigCaptureSessionVideoPreviewSinkNotification_OverCaptureStatusDidChange;
	extern const CFStringRef kFigCaptureSessionOverCaptureStatusDidChangeNotificationPayloadKey_Status; // AVSpatialOverCaptureVideoPreviewStatus/BWPreviewOverCaptureStatus
#endif // FIG_CAPTURE_OVERCAPTURE_SUPPORTED
	
// payload is either a dictionary containing a dictionary with kFigCaptureSessionImageQueueUpdatedNotificationPayloadKey_ImageQueueSlot, containing a slot number for the thumbnail output image queue,
// or NULL indicating any previously provided slots are no longer valid
extern const CFStringRef kFigCaptureSessionVideoThumbnailSinkNotification_ImageQueueUpdated;
	
#pragma mark Recording

enum {
	kFigCaptureSessionFileSinkError_FileAlreadyExists			= -16410,
	kFigCaptureSessionFileSinkError_OutOfDiskSpace				= -16411,
	kFigCaptureSessionFileSinkError_MaximumFileSizeReached		= -16412,
	kFigCaptureSessionFileSinkError_MaximumDurationReached		= -16413,
	kFigCaptureSessionFileSinkError_InputRanDry					= -16414, // the session stopped running due to a client calling stopRuning, or due to an interruption/runtime error
	// -16415-16416 are still image sink errors.
	kFigCaptureSessionFileSinkError_RecordingNotAllowedInWindowedMode	= -16417, // the session stopped running due to resource contention
	kFigCaptureSessionFileSinkError_RecordingNeverStarted		= -16418, // we were told to stop recording before recording was ever started
	kFigCaptureSessionFileSinkError_RecordingAlreadyInProgress	= -16419, // we were told to start a new recording when a previous recording is still underway
	
	// note jump to discontinuous error code block: -15430 to -15439
	kFigCaptureSessionFileSinkError_PointlessOverCapture		= -15430, // the over capture asset was skipped because it does not provide substantial content beyond the primary (e.g. fully zoomed out)
};
	
// If you wish to capture a series of gapless recordings on a particular sink, you can call start recording a second time with a new url.
// If another recording is already in progress, it will be stopped and the new one started without dropping frames.
CM_INLINE void FigCaptureSessionFileSinkStartRecording( FigCaptureSessionRef session, CFStringRef fileSinkID, FigCaptureRecordingSettings *settings );
CM_INLINE void FigCaptureSessionFileSinkStopRecording( FigCaptureSessionRef session, CFStringRef fileSinkID );
CM_INLINE void FigCaptureSessionFileSinkPauseRecording( FigCaptureSessionRef session, CFStringRef fileSinkID );
CM_INLINE void FigCaptureSessionFileSinkResumeRecording( FigCaptureSessionRef session, CFStringRef fileSinkID );

// For all file sync notifications the payload contains the settingsID from the FigCaptureRecordingSettings* which was used to initiate the recording
extern const CFStringRef kFigCaptureSessionFileSinkNotification_DidStartRecording;
#if FIG_CAPTURE_THE_MOMENT_SUPPORTED
	extern const CFStringRef kFigCaptureSessionDidStartRecordingNotificationPayloadKey_MovieWidth; // int32_t
	extern const CFStringRef kFigCaptureSessionDidStartRecordingNotificationPayloadKey_MovieHeight; // int32_t
	extern const CFStringRef kFigCaptureSessionDidStartRecordingNotificationPayloadKey_TorchEnabled; // boolean
#endif // FIG_CAPTURE_THE_MOMENT_SUPPORTED
extern const CFStringRef kFigCaptureSessionFileSinkNotification_DidStopRecording;
#if FIG_CAPTURE_THE_MOMENT_SUPPORTED
	extern const CFStringRef kFigCaptureSessionDidStopRecordingNotificationPayloadKey_IsSpatialOverCaptureMovie; // BOOL
	extern const CFStringRef kFigCaptureSessionDidStopRecordingNotificationPayloadKey_MovieDuration; // dictionary(CMTime)
#endif // FIG_CAPTURE_THE_MOMENT_SUPPORTED
extern const CFStringRef kFigCaptureSessionFileSinkNotification_DidPauseRecording;
extern const CFStringRef kFigCaptureSessionFileSinkNotification_DidResumeRecording;
// When the DidStopRecording notification is received the file has written to disk, payload will contain a thumabnail surface + size if requested, or an error if recording fails
// the capture session has also de-moof'd the file, and updated metadata if kFigCaptureSessionMovieFileSinkProperty_MovieLevelMetadata is set
// if mediaserverd dies the remote version of the capture session should demoof and update metadata, based on a cache of kFigCaptureSessionMovieFileSinkProperty_MovieLevelMetadata and the output URL
// if the client app dies, then the capture session in mediaserverd can demoof, and leave them a nice movie, yay!
// if both the app and mediaserverd are killed before demoof can complete then the client will have to do it next time -- for example when SpringBoard gets jetsam'd because the app switcher is taking too much memory (mediaserverd is jetsam'd before SpringBoard I think)
// client may still need to update the movie level metadata in that case, hmm.

extern const CFStringRef kFigCaptureSessionFileSinkProperty_RecordedDuration; // readonly, CMTime as CFDictionary, must be directed to a file sink section
extern const CFStringRef kFigCaptureSessionFileSinkProperty_RecordedSize; // readonly, int64_t, must be directed to a file sink section

// Movie file specific properties
extern const CFStringRef kFigCaptureSessionMovieFileSinkProperty_MovieLevelMetadata; // writeonly, CFArray (same structure as FigFormatWriter's kFigFormatWriterProperty_MetadataToWrite property (see FigFormatWriter.h)
// do this before calling stopRecording

	
#pragma mark Vision Data Output
	
extern const CFStringRef kFigCaptureSessionVisionDataSinkProperty_KeypointDetectionThreshold; // writeonly, CFNumber (float), must be directed to a vision data sink section
CM_INLINE void FigCaptureSessionVisionDataSinkTriggerBurst( FigCaptureSessionRef session, CFStringRef visionDataSinkID );


#pragma mark Still Image Capture

enum {
	// Still Image Sink Errors
	kFigCaptureSessionStillImageSinkError_ImageCaptureFailed						= -16415,
	kFigCaptureSessionStillImageSinkError_ImageProcessingFailed						= -16416,
	kFigCaptureSessionIrisStillImageSinkError_StillImageTimeOutsideMovieBoundaries	= -16950,
	kFigCaptureSessionIrisStillImageSinkError_PreparationCancelled					= -16951,
	// -16952 is used internally
	kFigCaptureSessionIrisStillImageSinkError_RetryEnqueuingLivePhotoRequest		= -16953,
	kFigCaptureSessionIrisStillImageSinkError_NewerLivePhotoSeriesWasStarted		= -16954,
	kFigCaptureSessionIrisStillImageSinkError_LivePhotoRequestedTooSoon				= -16955,
	kFigCaptureSessionIrisStillImageSinkError_LivePhotoRequestedTooLate				= -16956,
};

CM_INLINE void FigCaptureSessionStillImageSinkCaptureImage( FigCaptureSessionRef session, CFStringRef stillImageSinkID, FigCaptureStillImageSettings *settings );
	
CM_INLINE void FigCaptureSessionStillImageSinkPrepareToCaptureBracket( FigCaptureSessionRef session, CFStringRef stillImageSinkID, FigCaptureStillImageSettings *bracketSettings );
	
// For all still image sync notifications the payload contains the settingsID from the FigCaptureStillImageSettings* which was used to initiate the capture
extern const CFStringRef kFigCaptureSessionStillImageSinkNotification_WillCaptureStillImage;
	extern const CFStringRef kFigCaptureSessionWillCaptureStillImageNotificationPayloadKey_StillImageStabilizationActive; // BOOL, value is YES for images where still image stabilization is being used.

extern const CFStringRef kFigCaptureSessionStillImageSinkNotification_DidCaptureStillImage;
extern const CFStringRef kFigCaptureSessionStillImageSinkNotification_StillImageComplete; // payload contains _ErrorStatus OR _SampleBuffer OR _Surface + _SurfaceSize + _PreviewSurface + _PreviewSurfaceSize + _Metadata
extern const CFStringRef kFigCaptureSessionStillImageSinkNotification_BracketPreparationComplete; // payload contains kFigCaptureSessionNotificationPayloadKey_SettingsID and error (if preparation failed)


#pragma mark Iris Still Image Capture
	
CM_INLINE void FigCaptureSessionIrisStillImageSinkCaptureImage( FigCaptureSessionRef session, CFStringRef stillImageSinkID, FigCaptureIrisStillImageSettings *settings );
	
CM_INLINE void FigCaptureSessionIrisStillImageSinkPrepareToCapture( FigCaptureSessionRef session, CFStringRef stillImageSinkID, FigCaptureIrisPreparedSettings *preparedSettings );
	
#if FIG_CAPTURE_THE_MOMENT_SUPPORTED
CM_INLINE void FigCaptureSessionIrisStillImageSinkBeginMomentCapture( FigCaptureSessionRef session, CFStringRef stillImageSinkID, FigMomentCaptureSettings *momentCaptureSettings );
CM_INLINE void FigCaptureSessionIrisStillImageSinkCommitMomentCaptureToStillImageCapture( FigCaptureSessionRef session, CFStringRef stillImageSinkID, FigCaptureIrisStillImageSettings *stillImageSettings );
CM_INLINE void FigCaptureSessionIrisStillImageSinkCommitMomentCaptureToMovieRecording( FigCaptureSessionRef session, CFStringRef stillImageSinkID, FigCaptureMovieFileRecordingSettings *movieRecordingSettings );
CM_INLINE void FigCaptureSessionIrisStillImageSinkCancelMomentCapture( FigCaptureSessionRef session, CFStringRef stillImageSinkID, int64_t momentCaptureSettingsID );
CM_INLINE void FigCaptureSessionIrisStillImageSinkEndMomentCapture( FigCaptureSessionRef session, CFStringRef stillImageSinkID, int64_t momentCaptureSettingsID );
#endif // FIG_CAPTURE_THE_MOMENT_SUPPORTED
	
// All Iris notifications contain kFigCaptureSessionNotificationPayloadKey_SettingsID in their payload.

extern const CFStringRef kFigCaptureSessionIrisStillImageSinkNotification_WillBeginCapture;
	// Sent with the above notification are:
	extern const CFStringRef kFigCaptureSessionWillBeginCaptureNotificationPayloadKey_StillWidth; // int32_t
	extern const CFStringRef kFigCaptureSessionWillBeginCaptureNotificationPayloadKey_StillHeight; // int32_t
	// The following are optionally sent.
	extern const CFStringRef kFigCaptureSessionWillBeginCaptureNotificationPayloadKey_PreviewWidth; // int32_t
	extern const CFStringRef kFigCaptureSessionWillBeginCaptureNotificationPayloadKey_PreviewHeight; // int32_t
	
	extern const CFStringRef kFigCaptureSessionWillBeginCaptureNotificationPayloadKey_ThumbnailWidth; // int32_t
	extern const CFStringRef kFigCaptureSessionWillBeginCaptureNotificationPayloadKey_ThumbnailHeight; // int32_t
	
	extern const CFStringRef kFigCaptureSessionWillBeginCaptureNotificationPayloadKey_RawThumbnailWidth; // int32_t
	extern const CFStringRef kFigCaptureSessionWillBeginCaptureNotificationPayloadKey_RawThumbnailHeight; // int32_t
	
	extern const CFStringRef kFigCaptureSessionWillBeginCaptureNotificationPayloadKey_RawStillWidth; // int32_t
	extern const CFStringRef kFigCaptureSessionWillBeginCaptureNotificationPayloadKey_RawStillHeight; // int32_t
	
	extern const CFStringRef kFigCaptureSessionWillBeginCaptureNotificationPayloadKey_IrisMovieWidth; // int32_t
	extern const CFStringRef kFigCaptureSessionWillBeginCaptureNotificationPayloadKey_IrisMovieHeight; // int32_t
	
	extern const CFStringRef kFigCaptureSessionWillBeginCaptureNotificationPayloadKey_PortraitEffectsMatteWidth; // int32_t
	extern const CFStringRef kFigCaptureSessionWillBeginCaptureNotificationPayloadKey_PortraitEffectsMatteHeight; // int32_t
	
#if FIG_CAPTURE_SEMANTIC_SEGMENTATION_ENABLED
	extern const CFStringRef kFigCaptureSessionWillBeginCaptureNotificationPayloadKey_HairSegmentationMatteWidth; // int32_t
	extern const CFStringRef kFigCaptureSessionWillBeginCaptureNotificationPayloadKey_HairSegmentationMatteHeight; // int32_t
	extern const CFStringRef kFigCaptureSessionWillBeginCaptureNotificationPayloadKey_SkinSegmentationMatteWidth; // int32_t
	extern const CFStringRef kFigCaptureSessionWillBeginCaptureNotificationPayloadKey_SkinSegmentationMatteHeight; // int32_t
	extern const CFStringRef kFigCaptureSessionWillBeginCaptureNotificationPayloadKey_TeethSegmentationMatteWidth; // int32_t
	extern const CFStringRef kFigCaptureSessionWillBeginCaptureNotificationPayloadKey_TeethSegmentationMatteHeight; // int32_t
#endif // FIG_CAPTURE_SEMANTIC_SEGMENTATION_ENABLED
	
#if FIG_CAPTURE_THE_MOMENT_SUPPORTED
	extern const CFStringRef kFigCaptureSessionWillBeginCaptureNotificationPayloadKey_SpatialOverCaptureStillWidth; // int32_t
	extern const CFStringRef kFigCaptureSessionWillBeginCaptureNotificationPayloadKey_SpatialOverCaptureStillHeight; // int32_t
	extern const CFStringRef kFigCaptureSessionWillBeginCaptureNotificationPayloadKey_SpatialOverCaptureMovieEnabled; // BOOL
#endif // FIG_CAPTURE_THE_MOMENT_SUPPORTED

#if FIG_CAPTURE_DEFERRED_PROCESSING_SUPPORTED
	extern const CFStringRef kFigCaptureSessionWillBeginCaptureNotificationPayloadKey_DeferredPhotoProxyWidth; // int32_t
	extern const CFStringRef kFigCaptureSessionWillBeginCaptureNotificationPayloadKey_DeferredPhotoProxyHeight; // int32_t
#endif // FIG_CAPTURE_DEFERRED_PROCESSING_SUPPORTED

	extern const CFStringRef kFigCaptureSessionWillBeginCaptureNotificationPayloadKey_NoiseReductionEnabled; // BOOL
	extern const CFStringRef kFigCaptureSessionWillBeginCaptureNotificationPayloadKey_FlashActive; // BOOL
	extern const CFStringRef kFigCaptureSessionWillBeginCaptureNotificationPayloadKey_RedEyeReductionEnabled; // BOOL
	extern const CFStringRef kFigCaptureSessionWillBeginCaptureNotificationPayloadKey_WideColorEnabled; // BOOL
	extern const CFStringRef kFigCaptureSessionWillBeginCaptureNotificationPayloadKey_HDRActive; // BOOL
	extern const CFStringRef kFigCaptureSessionWillBeginCaptureNotificationPayloadKey_ProcessedFiltersEnabled; // BOOL
	extern const CFStringRef kFigCaptureSessionWillBeginCaptureNotificationPayloadKey_OriginalPhotoDeliveryEnabled; // BOOL
	extern const CFStringRef kFigCaptureSessionWillBeginCaptureNotificationPayloadKey_SISActive; // BOOL
	extern const CFStringRef kFigCaptureSessionWillBeginCaptureNotificationPayloadKey_BravoImageFusionActive; // BOOL
	extern const CFStringRef kFigCaptureSessionWillBeginCaptureNotificationPayloadKey_SquareCropEnabled; // BOOL
	extern const CFStringRef kFigCaptureSessionWillBeginCaptureNotificationPayloadKey_PhotoProcessingTimeRange; // CMTimeRange
	extern const CFStringRef kFigCaptureSessionWillBeginCaptureNotificationPayloadKey_PhotoManifest; // NSArray<FigAppleMakerNoteStillImageProcessingFlags>
extern const CFStringRef kFigCaptureSessionIrisStillImageSinkNotification_WillCaptureStillImage;
extern const CFStringRef kFigCaptureSessionIrisStillImageSinkNotification_DidCaptureStillImage;
extern const CFStringRef kFigCaptureSessionIrisStillImageSinkNotification_StillImageComplete; // payload contains _ErrorStatus OR _SampleBuffer + (optional) _PreviewSampleBuffer OR _Surface + _SurfaceSize + _Metadata + (optional) _PreviewSurface and _PreviewSurfaceSize
extern const CFStringRef kFigCaptureSessionIrisStillImageSinkNotification_RawStillImageComplete; // payload contains _ErrorStatus OR _SampleBuffer + (optional) _PreviewSampleBuffer OR _Surface + _SurfaceSize + _Metadata + (optional) _PreviewSurface and _PreviewSurfaceSize
#if FIG_CAPTURE_DEFERRED_PROCESSING_SUPPORTED
extern const CFStringRef kFigCaptureSessionIrisStillImageSinkNotification_DeferredPhotoProxyImageComplete; // payload contains _ErrorStatus OR _DeferredPhotoProxySurface + _DeferredPhotoProxySurfaceSize + _Metadata + _CaptureRequestIdentifier + _PhotoIdentifier
#endif // FIG_CAPTURE_DEFERRED_PROCESSING_SUPPORTED

extern const CFStringRef kFigCaptureSessionIrisStillImageSinkNotification_DidRecordIrisMovie; // Make the "Live" badge go away
extern const CFStringRef kFigCaptureSessionIrisStillImageSinkNotification_DidFinishRecordingIrisMovie;
	// Sent with the above notification are:
	extern const CFStringRef kFigCaptureSessionDidFinishRecordingIrisMovieNotificationPayloadKey_MovieDuration; // CMTime(dictionary)
	extern const CFStringRef kFigCaptureSessionDidFinishRecordingIrisMovieNotificationPayloadKey_StillImageDisplayTime; // CMTime(dictionary)
	extern const CFStringRef kFigCaptureSessionDidFinishRecordingIrisMovieNotificationPayloadKey_MasterMoviePath; // CFString
	extern const CFStringRef kFigCaptureSessionDidFinishRecordingIrisMovieNotificationPayloadKey_IsFinalReferenceMovie; // BOOL
	extern const CFStringRef kFigCaptureSessionDidFinishRecordingIrisMovieNotificationPayloadKey_IsOriginalPhotoMovie; // BOOL
#if FIG_CAPTURE_THE_MOMENT_SUPPORTED
	extern const CFStringRef kFigCaptureSessionDidFinishRecordingIrisMovieNotificationPayloadKey_IsSpatialOverCaptureMovie; // BOOL
#endif // FIG_CAPTURE_THE_MOMENT_SUPPORTED
extern const CFStringRef kFigCaptureSessionIrisStillImageSinkNotification_DidResumeIrisMovieCapture;
extern const CFStringRef kFigCaptureSessionIrisStillImageSinkNotification_DidResumeIrisMovieProcessing;
	
extern const CFStringRef kFigCaptureSessionIrisStillImageSinkProperty_BeginIrisMovieCaptureHostTime; // CFDictionary(CMTime) - chop all iris capture buffers before this time (unless there's a pending iris request with an earlier still time)
extern const CFStringRef kFigCaptureSessionIrisStillImageSinkProperty_EndIrisMovieCaptureHostTime; // CFDictionary(CMTime) - chop all iris capture buffers after this time (unless there's a pending iris request with a later still time)
extern const CFStringRef kFigCaptureSessionIrisStillImageSinkProperty_IrisMovieProcessingSuspended; // CFNumber(BOOL) - suspends writing finished movies from the master movie

// The mach_absolute_time() at the time the user initiated the still image. Used by Camera.app to notify the still image pipeline that the user intended to capture a still image at the specified time, but the actual capture request will be issued at a later time.
extern const CFStringRef kFigCaptureSessionIrisStillImageSinkProperty_UserInitiatedCaptureRequestTime; // CFNumber(uint64_t), or CMTime as CFDictionary. The latter is only used by Crucible

extern const CFStringRef kFigCaptureSessionIrisStillImageSinkNotification_PreparationComplete; // payload contains kFigCaptureSessionNotificationPayloadKey_SettingsID and error (if preparation failed)
	
#if FIG_CAPTURE_THE_MOMENT_SUPPORTED
extern const CFStringRef kFigCaptureSessionIrisStillImageSinkNotification_DidBeginMomentCapture;
extern const CFStringRef kFigCaptureSessionIrisStillImageSinkNotification_DidBeginRecordingMomentCaptureMovie;
	extern const CFStringRef kFigCaptureSessionDidBeginRecordingMomentCaptureMovieNotificationPayloadKey_TorchEnabled; // CFBoolean
extern const CFStringRef kFigCaptureSessionIrisStillImageSinkNotification_DidCancelMomentCapture;
#endif // #if FIG_CAPTURE_THE_MOMENT_SUPPORTED
	
	
#pragma pack(pop)
    
#ifdef __cplusplus
}
#endif

// Glue is implemented inline to allow clients to step through it
#import <Celestial/FigCaptureSessionDispatch.h>

#endif // FIGCAPTURESESSION_H
