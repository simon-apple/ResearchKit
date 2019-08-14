/*
	File:			FigCaptureSessionDispatch.h
	Description:	Declares the FigCaptureSessionClass vtable and connects the FigCaptureSession functions
	Creation Date:	10/14/13
	Copyright: 		© Copyright 2013-2017 Apple, Inc. All rights reserved.
*/

#ifndef FIGCAPTURESESSIONDISPATCH_H
#define FIGCAPTURESESSIONDISPATCH_H

#import <CoreMedia/FigDebugPlatform.h>

#ifdef __cplusplus
extern "C" {
#endif
    
#pragma pack(push)
#pragma pack()

enum {
	kFigCaptureSession_ClassVersion_1 = 1
};

/*!
	@interface	FigCaptureSessionClass
	@abstract	FigCaptureSessionClass contains FigCaptureSession-specific methods.
	@discussion	Function pointers are set to NULL if a particular capture session does not support them.
*/
typedef struct {
	CMBaseClassVersion version; 			// must be kFigCaptureSession_ClassVersion_1

	OSStatus (*setSectionProperty)( FigCaptureSessionRef session, CFStringRef sectionID, CFStringRef propertyKey, CFTypeRef propertyValue );
	OSStatus (*copySectionProperty)( FigCaptureSessionRef session, CFStringRef sectionID, CFStringRef propertyKey, CFAllocatorRef allocator, void *propertyValueOut );
	void (*setConfiguration)( FigCaptureSessionRef session, FigCaptureSessionConfiguration *configuration );
	void (*startRunning)( FigCaptureSessionRef session );
	void (*stopRunning)( FigCaptureSessionRef session );
	void (*fileSinkStartRecording)( FigCaptureSessionRef session, CFStringRef fileSinkID, FigCaptureRecordingSettings *settings );
	void (*fileSinkStopRecording)( FigCaptureSessionRef session, CFStringRef fileSinkID );
	void (*fileSinkPauseRecording)( FigCaptureSessionRef session, CFStringRef fileSinkID );
	void (*fileSinkResumeRecording)( FigCaptureSessionRef session, CFStringRef fileSinkID );
	void (*stillImageSinkCaptureImage)( FigCaptureSessionRef session, CFStringRef stillImageSinkID, FigCaptureStillImageSettings *settings );
	void (*stillImageSinkPrepareToCaptureBracket)( FigCaptureSessionRef session, CFStringRef stillImageSinkID, FigCaptureStillImageSettings *bracketSettings );
	void (*irisStillImageSinkCaptureImage)( FigCaptureSessionRef session, CFStringRef irisStillImageSinkID, FigCaptureIrisStillImageSettings *settings );
	void (*irisStillImageSinkPrepareToCapture)( FigCaptureSessionRef session, CFStringRef stillImageSinkID, FigCaptureIrisPreparedSettings *preparedSettings );
#if FIG_CAPTURE_THE_MOMENT_SUPPORTED
	void (*irisStillImageSinkBeginMomentCapture)( FigCaptureSessionRef session, CFStringRef stillImageSinkID, FigMomentCaptureSettings *momentCaptureSettings );
	void (*irisStillImageSinkCommitMomentCaptureToStillImageCapture)( FigCaptureSessionRef session, CFStringRef stillImageSinkID, FigCaptureIrisStillImageSettings *stillImageSettings );
	void (*irisStillImageSinkCommitMomentCaptureToMovieRecording)( FigCaptureSessionRef session, CFStringRef stillImageSinkID, FigCaptureMovieFileRecordingSettings *movieRecordingSettings );
	void (*irisStillImageSinkCancelMomentCapture)( FigCaptureSessionRef session, CFStringRef stillImageSinkID, int64_t momentCaptureSettingsID );
	void (*irisStillImageSinkEndMomentCapture)( FigCaptureSessionRef session, CFStringRef stillImageSinkID, int64_t momentCaptureSettingsID );
#endif // FIG_CAPTURE_THE_MOMENT_SUPPORTED
	void (*visionDataSinkTriggerBurst)( FigCaptureSessionRef session, CFStringRef sinkID );

} FigCaptureSessionClass;

// TODO: This should really be posted on our notification queue
CM_INLINE void FigCaptureSessionPostUnsupportedOperationNotification( FigCaptureSessionRef session, CFStringRef notificationName )
{
	CFDictionaryRef notificationPayload = (__bridge CFDictionaryRef)@{ (__bridge NSString *)kFigCaptureSessionNotificationPayloadKey_ErrorStatus : @((OSStatus)kCMBaseObjectError_UnsupportedOperation) };
	
	CMNotificationCenterPostNotification( CMNotificationCenterGetDefaultLocalCenter(), notificationName, session, notificationPayload, 0 );
}
	
/*!
	@interface	FigCaptureSessionVTable
	@abstract	A VTable provides an instance with access to class data.
*/
typedef struct {
	CMBaseVTable base;
	const FigCaptureSessionClass *captureSessionClass;
} FigCaptureSessionVTable;


CM_INLINE CMBaseObjectRef FigCaptureSessionGetCMBaseObject( FigCaptureSessionRef session )
{
	return (CMBaseObjectRef)session;
}

CM_INLINE const FigCaptureSessionClass *FigCaptureSessionGetVTable( FigCaptureSessionRef p )
{
	return ( (const FigCaptureSessionVTable*)CMBaseObjectGetVTable( FigCaptureSessionGetCMBaseObject( p ) ) )->captureSessionClass;
}

CM_INLINE OSStatus FigCaptureSessionInvalidate( FigCaptureSessionRef session )
{
	return CMBaseObjectInvalidate( FigCaptureSessionGetCMBaseObject( session ) );
}

CM_INLINE OSStatus FigCaptureSessionSetProperty( FigCaptureSessionRef session, CFStringRef propertyKey, CFTypeRef propertyValue )
{
	return CMBaseObjectSetProperty( FigCaptureSessionGetCMBaseObject( session ), propertyKey, propertyValue );
}

CM_INLINE OSStatus FigCaptureSessionCopyProperty( FigCaptureSessionRef session, CFStringRef propertyKey, CFAllocatorRef allocator, void *propertyValueOut )
{
	return CMBaseObjectCopyProperty( FigCaptureSessionGetCMBaseObject( session ), propertyKey, allocator, propertyValueOut );
}

CM_INLINE OSStatus FigCaptureSessionSetSectionProperty( FigCaptureSessionRef session, CFStringRef sectionID, CFStringRef propertyKey, CFTypeRef propertyValue )
{
	const FigCaptureSessionClass *vTable = FigCaptureSessionGetVTable( session );
	
	if ( vTable->setSectionProperty ) {
		return vTable->setSectionProperty( session, sectionID, propertyKey, propertyValue );
	}
	else {
		return kCMBaseObjectError_UnsupportedOperation;
	}
}

CM_INLINE OSStatus FigCaptureSessionCopySectionProperty( FigCaptureSessionRef session, CFStringRef sectionID, CFStringRef propertyKey, CFAllocatorRef allocator, void *propertyValueOut )
{
	const FigCaptureSessionClass *vTable = FigCaptureSessionGetVTable( session );
	
	if ( vTable->copySectionProperty ) {
		return vTable->copySectionProperty( session, sectionID, propertyKey, allocator, propertyValueOut );
	}
	else {
		return kCMBaseObjectError_UnsupportedOperation;
	}
}

CM_INLINE void FigCaptureSessionSetConfiguration( FigCaptureSessionRef session, FigCaptureSessionConfiguration *configuration )
{
	const FigCaptureSessionClass *vTable = FigCaptureSessionGetVTable( session );
	
	if ( vTable->setConfiguration ) {
		vTable->setConfiguration( session, configuration );
	}
	else {
		FigCaptureSessionPostUnsupportedOperationNotification( session, kFigCaptureSessionNotification_ConfigurationCommitted );
	}
}

CM_INLINE void FigCaptureSessionStartRunning( FigCaptureSessionRef session )
{
	const FigCaptureSessionClass *vTable = FigCaptureSessionGetVTable( session );
	
	if ( vTable->startRunning ) {
		vTable->startRunning( session );
	}
	else {
		FigCaptureSessionPostUnsupportedOperationNotification( session, kFigCaptureSessionNotification_DidStopRunning );
	}
}

CM_INLINE void FigCaptureSessionStopRunning( FigCaptureSessionRef session )
{
	const FigCaptureSessionClass *vTable = FigCaptureSessionGetVTable( session );
	
	if ( vTable->stopRunning ) {
		vTable->stopRunning( session );
	}
	else {
		FigCaptureSessionPostUnsupportedOperationNotification( session, kFigCaptureSessionNotification_DidStopRunning );
	}
}

CM_INLINE void FigCaptureSessionFileSinkStartRecording( FigCaptureSessionRef session, CFStringRef fileSinkID, FigCaptureRecordingSettings *settings )
{
	const FigCaptureSessionClass *vTable = FigCaptureSessionGetVTable( session );
	
	if ( vTable->fileSinkStartRecording ) {
		vTable->fileSinkStartRecording( session, fileSinkID, settings );
	}
	else {
		FigCaptureSessionPostUnsupportedOperationNotification( session, kFigCaptureSessionFileSinkNotification_DidStopRecording );
	}
}

CM_INLINE void FigCaptureSessionFileSinkStopRecording( FigCaptureSessionRef session, CFStringRef fileSinkID )
{
	const FigCaptureSessionClass *vTable = FigCaptureSessionGetVTable( session );
	
	if ( vTable->fileSinkStopRecording ) {
		vTable->fileSinkStopRecording( session, fileSinkID );
	}
	else {
		FigCaptureSessionPostUnsupportedOperationNotification( session, kFigCaptureSessionFileSinkNotification_DidStopRecording );
	}
}

CM_INLINE void FigCaptureSessionFileSinkPauseRecording( FigCaptureSessionRef session, CFStringRef fileSinkID )
{
	const FigCaptureSessionClass *vTable = FigCaptureSessionGetVTable( session );
	
	if ( vTable->fileSinkPauseRecording ) {
		vTable->fileSinkPauseRecording( session, fileSinkID );
	}
	else {
		FigCaptureSessionPostUnsupportedOperationNotification( session, kFigCaptureSessionFileSinkNotification_DidStopRecording );
	}
}

CM_INLINE void FigCaptureSessionFileSinkResumeRecording( FigCaptureSessionRef session, CFStringRef fileSinkID )
{
	const FigCaptureSessionClass *vTable = FigCaptureSessionGetVTable( session );
	
	if ( vTable->fileSinkResumeRecording ) {
		vTable->fileSinkResumeRecording( session, fileSinkID );
	}
	else {
		FigCaptureSessionPostUnsupportedOperationNotification( session, kFigCaptureSessionFileSinkNotification_DidStopRecording );
	}
}

CM_INLINE void FigCaptureSessionStillImageSinkCaptureImage( FigCaptureSessionRef session, CFStringRef stillImageSinkID, FigCaptureStillImageSettings *settings )
{
	const FigCaptureSessionClass *vTable = FigCaptureSessionGetVTable( session );
	
	if ( vTable->stillImageSinkCaptureImage ) {
		vTable->stillImageSinkCaptureImage( session, stillImageSinkID, settings );
	}
	else {
		FigCaptureSessionPostUnsupportedOperationNotification( session, kFigCaptureSessionStillImageSinkNotification_StillImageComplete );
	}
}
	
CM_INLINE void FigCaptureSessionStillImageSinkPrepareToCaptureBracket( FigCaptureSessionRef session, CFStringRef stillImageSinkID, FigCaptureStillImageSettings *bracketSettings )
{
	const FigCaptureSessionClass *vTable = FigCaptureSessionGetVTable( session );
	
	if ( vTable->stillImageSinkPrepareToCaptureBracket ) {
		vTable->stillImageSinkPrepareToCaptureBracket( session, stillImageSinkID, bracketSettings );
	}
	else {
		FigCaptureSessionPostUnsupportedOperationNotification( session, kFigCaptureSessionStillImageSinkNotification_BracketPreparationComplete );
	}
}
	
CM_INLINE void FigCaptureSessionIrisStillImageSinkCaptureImage( FigCaptureSessionRef session, CFStringRef irisStillImageSinkID, FigCaptureIrisStillImageSettings *settings )
{
	const FigCaptureSessionClass *vTable = FigCaptureSessionGetVTable( session );
	
	if ( vTable->irisStillImageSinkCaptureImage ) {
		vTable->irisStillImageSinkCaptureImage( session, irisStillImageSinkID, settings );
	}
	else {
		FigCaptureSessionPostUnsupportedOperationNotification( session, kFigCaptureSessionIrisStillImageSinkNotification_WillBeginCapture );
	}
}
	
CM_INLINE void FigCaptureSessionIrisStillImageSinkPrepareToCapture( FigCaptureSessionRef session, CFStringRef irisStillImageSinkID, FigCaptureIrisPreparedSettings *preparedSettings )
{
	const FigCaptureSessionClass *vTable = FigCaptureSessionGetVTable( session );
	
	if ( vTable->irisStillImageSinkCaptureImage ) {
		vTable->irisStillImageSinkPrepareToCapture( session, irisStillImageSinkID, preparedSettings );
	}
	else {
		FigCaptureSessionPostUnsupportedOperationNotification( session, kFigCaptureSessionIrisStillImageSinkNotification_PreparationComplete );
	}
}
	
#if FIG_CAPTURE_THE_MOMENT_SUPPORTED
CM_INLINE void FigCaptureSessionIrisStillImageSinkBeginMomentCapture( FigCaptureSessionRef session, CFStringRef stillImageSinkID, FigMomentCaptureSettings *momentCaptureSettings )
{
	const FigCaptureSessionClass *vTable = FigCaptureSessionGetVTable( session );
	
	if ( vTable->irisStillImageSinkBeginMomentCapture ) {
		vTable->irisStillImageSinkBeginMomentCapture( session, stillImageSinkID, momentCaptureSettings );
	}
	else {
		FigCaptureSessionPostUnsupportedOperationNotification( session, kFigCaptureSessionIrisStillImageSinkNotification_DidBeginMomentCapture );
	}
}
	
CM_INLINE void FigCaptureSessionIrisStillImageSinkCommitMomentCaptureToStillImageCapture( FigCaptureSessionRef session, CFStringRef stillImageSinkID, FigCaptureIrisStillImageSettings *stillImageSettings )
{
	const FigCaptureSessionClass *vTable = FigCaptureSessionGetVTable( session );
	
	if ( vTable->irisStillImageSinkCommitMomentCaptureToStillImageCapture ) {
		vTable->irisStillImageSinkCommitMomentCaptureToStillImageCapture( session, stillImageSinkID, stillImageSettings );
	}
	else {
		FigCaptureSessionPostUnsupportedOperationNotification( session, kFigCaptureSessionStillImageSinkNotification_StillImageComplete );
	}
}

CM_INLINE void FigCaptureSessionIrisStillImageSinkCommitMomentCaptureToMovieRecording( FigCaptureSessionRef session, CFStringRef stillImageSinkID, FigCaptureMovieFileRecordingSettings *movieRecordingSettings )
{
	const FigCaptureSessionClass *vTable = FigCaptureSessionGetVTable( session );
	
	if ( vTable->irisStillImageSinkCommitMomentCaptureToMovieRecording ) {
		vTable->irisStillImageSinkCommitMomentCaptureToMovieRecording( session, stillImageSinkID, movieRecordingSettings );
	}
	else {
		FigCaptureSessionPostUnsupportedOperationNotification( session, kFigCaptureSessionIrisStillImageSinkNotification_DidFinishRecordingIrisMovie );
	}
}
	
CM_INLINE void FigCaptureSessionIrisStillImageSinkCancelMomentCapture( FigCaptureSessionRef session, CFStringRef stillImageSinkID, int64_t momentCaptureSettingsID )
{
	const FigCaptureSessionClass *vTable = FigCaptureSessionGetVTable( session );
	
	if ( vTable->irisStillImageSinkCancelMomentCapture ) {
		vTable->irisStillImageSinkCancelMomentCapture( session, stillImageSinkID, momentCaptureSettingsID );
	}
	else {
		FigCaptureSessionPostUnsupportedOperationNotification( session, kFigCaptureSessionIrisStillImageSinkNotification_DidCancelMomentCapture );
	}
}
	
CM_INLINE void FigCaptureSessionIrisStillImageSinkEndMomentCapture( FigCaptureSessionRef session, CFStringRef stillImageSinkID, int64_t momentCaptureSettingsID )
{
	const FigCaptureSessionClass *vTable = FigCaptureSessionGetVTable( session );
	
	if ( vTable->irisStillImageSinkEndMomentCapture ) {
		vTable->irisStillImageSinkEndMomentCapture( session, stillImageSinkID, momentCaptureSettingsID );
	}
	else {
		FigCaptureSessionPostUnsupportedOperationNotification( session, kFigCaptureSessionIrisStillImageSinkNotification_DidFinishRecordingIrisMovie );
	}
}
#endif // FIG_CAPTURE_THE_MOMENT_SUPPORTED
	
CM_INLINE void FigCaptureSessionVisionDataSinkTriggerBurst( FigCaptureSessionRef session, CFStringRef visionDataSinkID )
{
	const FigCaptureSessionClass *vTable = FigCaptureSessionGetVTable( session );
	
	if ( vTable->visionDataSinkTriggerBurst ) {
		vTable->visionDataSinkTriggerBurst( session, visionDataSinkID );
	}
	else {
		// silently fail
	}
}
	
#pragma pack(pop)
    
#ifdef __cplusplus
}
#endif

#endif // FIGCAPTURESESSIONGLUE_H
