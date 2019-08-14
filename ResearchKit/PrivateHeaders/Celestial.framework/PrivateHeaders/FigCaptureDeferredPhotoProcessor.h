/*
	File:			FigCaptureDeferredPhotoProcessor.h
	Authors:		Rob Simutis
	Creation Date:	08/30/2018
	Copyright: 		© Copyright 2018-2019 Apple, Inc. All rights reserved.
*/


#ifndef FIGCAPTUREDEFERREDPHOTOPROCESSOR_H
#define FIGCAPTUREDEFERREDPHOTOPROCESSOR_H

#import <Celestial/FigCaptureCommon.h>
#import <CoreMedia/CMBase.h>
#import <CoreMedia/CMBaseObject.h>
#import <CoreMedia/FigXPCClientServer.h>

#if FIG_CAPTURE_DEFERRED_PROCESSING_SUPPORTED

#ifdef __cplusplus
extern "C" {
#endif
	
#pragma pack(push, 4)


#pragma mark < < < FigCaptureDeferredPhotoProcessor > > >


typedef struct OpaqueFigCaptureDeferredPhotoProcessor *FigCaptureDeferredPhotoProcessorRef;	// a CF type and a CMBO

extern CMBaseClassID FigCaptureDeferredPhotoProcessorGetClassID( void );

extern CFTypeID FigCaptureDeferredPhotoProcessorGetTypeID( void );
	
// Errors
// FigCaptureDeferredPhotoProcessor owns -16820 to -16829
enum {
	kFigCaptureDeferredPhotoProcessorError_UnsupportedDevice = -16820, // Attempting to use deferred processing on a device where it's not supported
	kFigCaptureDeferredPhotoProcessorError_ProcessorDisconnected = -16821,
    kFigCaptureDeferredPhotoProcessorError_ServerConnectionDied = -16822,
	kFigCaptureDeferredPhotoProcessorError_AccessToPhotoIdentifierDenied = -16823, // tsk tsk, bad app trying to get identifier(s) it doesn't have access to.
	kFigCaptureDeferredPhotoProcessorError_AssetsNotFoundForIdentifier = -16824,
	kFigCaptureDeferredPhotoProcessorError_CaptureRequestIdentifierNotParsed = -16825,
	kFigCaptureDeferredPhotoProcessorError_PhotoIdentifierNotParsed = -16826,
	kFigCaptureDeferredPhotoProcessorError_IntermediateAssetIncompatibility = -16827, // The intermediate assets are from a revision of an algorithm that's no longer compatible.
	kFigCaptureDeferredPhotoProcessorError_InvalidContainerArchive = -16828, // one or more of the container's expected files is missing
	kFigCaptureDeferredPhotoProcessorError_PhotoIdentifierAlreadyProcessing = -16829, // 
};

CM_INLINE OSStatus FigCaptureDeferredPhotoProcessorCopyProperty( FigCaptureDeferredPhotoProcessorRef captureSource, CFStringRef propertyKey, CFAllocatorRef allocator, void *propertyValueOut );
CM_INLINE OSStatus FigCaptureDeferredPhotoProcessorSetProperty( FigCaptureDeferredPhotoProcessorRef captureSource, CFStringRef propertyKey, CFTypeRef propertyValue );
	
// Each array element is a dictionary containing kFigCaptureDeferredPhotoProcessorUnfinishedPhotoIdentifierKey_CaptureRequestIdentifier and kFigCaptureDeferredPhotoProcessorUnfinishedPhotoIdentifierKey_PhotoIdentifier key/value pairs to uniquely identify a promised AVCapturePhoto object, where each photo capture request may return multiple photo objects (for example, one request yielding non-SDOF and SDOF AVCapturePhoto objects).
CM_INLINE CFArrayRef FigCaptureDeferredPhotoProcessorCopyUnfinishedPhotoIdentifiers( FigCaptureDeferredPhotoProcessorRef processor ); // CFArrayRef<CFDictionaryRef<CFStringRef, CFStringRef>>
	
extern const CFStringRef kFigCaptureDeferredPhotoProcessorUnfinishedPhotoIdentifierKey_CaptureManifestVersion; // CFNumberRef(uint32)

extern const CFStringRef kFigCaptureDeferredPhotoProcessorUnfinishedPhotoIdentifierKey_CaptureRequestIdentifier; // CFStringRef(UUID)
extern const CFStringRef kFigCaptureDeferredPhotoProcessorUnfinishedPhotoIdentifierKey_PhotoIdentifier; // CFStringRef(UUID), alias for kFigCaptureDeferredPhotoProcessorUnfinishedPhotoIdentifierKey_PhotoManifest_PhotoIdentifier

extern const CFStringRef kFigCaptureDeferredPhotoProcessorUnfinishedPhotoIdentifierKey_PhotoManifest; // CFArrayRef<CFDictionaryRef> containing kFigCaptureDeferredPhotoProcessorUnfinishedPhotoIdentifierKey_PhotoManifest keys, one entry for each photo delivered to the client.
extern const CFStringRef kFigCaptureDeferredPhotoProcessorUnfinishedPhotoIdentifierKey_PhotoManifest_PhotoIdentifier; // CFStringRef(UUID)
extern const CFStringRef kFigCaptureDeferredPhotoProcessorUnfinishedPhotoIdentifierKey_PhotoManifest_PresentationTimeStamp; // CMTime as CFDictionary
extern const CFStringRef kFigCaptureDeferredPhotoProcessorUnfinishedPhotoIdentifierKey_PhotoManifest_PhotoProcessingFlags; // CFNumber<FigAppleMakerNoteStillImageProcessingFlags>

// TODO: there'll likely be a FigCaptureDeferredPhotoProcessorCopyUnfinishedPhotoProperty( captureRequestIdentifier, photoIdentifier, propertyName, allocator, propertyValueOut ) to lazily fetch the proxy image, metadata, etc.

// This is SPI for stuff that should require an entitlement of some sort, and/or an array of bundle IDs.
CM_INLINE CFArrayRef FigCaptureDeferredPhotoProcessorCopyUnfinishedPhotoIdentifiersForApplicationID( FigCaptureDeferredPhotoProcessorRef processor, CFStringRef bundleID ); // CFArrayRef<CFDictionaryRef<CFStringRef, CFStringRef>>

typedef CFStringRef FigCaptureDeferredPhotoProcessorQueuePosition CF_STRING_ENUM;

/*!
	@constant	kFigCaptureDeferredPhotoProcessorQueuePosition_Head
	@discussion	This constant, when used with FigCaptureDeferredPhotoProcessorProcessPhoto(), will move the photo to the head of the internal processing queue.  If another photo is already being processed, then this photo will be processed immediately afterwards.
*/
CM_EXPORT const FigCaptureDeferredPhotoProcessorQueuePosition kFigCaptureDeferredPhotoProcessorQueuePosition_Head;
	
/*!
	@constant	kFigCaptureDeferredPhotoProcessorQueuePosition_Tail
	@discussion	This constant, when used with FigCaptureDeferredPhotoProcessorProcessPhoto() will move the photo to the tail of the internal processing queue.  If the photo is already being processed, this will have no effect on its position.
*/
CM_EXPORT const FigCaptureDeferredPhotoProcessorQueuePosition kFigCaptureDeferredPhotoProcessorQueuePosition_Tail;

CM_INLINE OSStatus FigCaptureDeferredPhotoProcessorProcessPhoto( FigCaptureDeferredPhotoProcessorRef processor, CFStringRef captureRequestIdentifier, CFStringRef photoIdentifier, FigCaptureDeferredPhotoProcessorQueuePosition queuePosition, xpc_object_t message );
	
CM_INLINE OSStatus FigCaptureDeferredPhotoProcessorCancelPhotoProcessing( FigCaptureDeferredPhotoProcessorRef processor, CFStringRef captureRequestIdentifier, CFStringRef photoIdentifier );
	
// TODO: need to figure out how this would work for a multi-image capture (e.g. over-captured Wide and SuperWide-stiched assets; they're all tied to a unique captureRequestIdentifier across all intermediates but deliver multiple AVCapturePhoto objects.  This might have to be exposed as deleting the captureRequestIdentifier to keep it simpler.
CM_INLINE OSStatus FigCaptureDeferredPhotoProcessorDeletePersistentStorageForPhoto( FigCaptureDeferredPhotoProcessorRef processor, CFStringRef captureRequestIdentifier, CFStringRef photoIdentifier );

// PROPERTIES (not needed for the processor just yet)

// The following may be present in any notification
extern const CFStringRef kFigCaptureDeferredPhotoProcessorNotificationPayloadKey_ErrorStatus; // OSStatus (int32_t)
extern const CFStringRef kFigCaptureDeferredPhotoProcessorNotificationPayloadKey_ErrorReason; // int32_t with a unique enum for each error code, for example kFigCaptureSessionInterruptionErrorReason
extern const CFStringRef kFigCaptureDeferredPhotoProcessorNotificationPayloadKey_CaptureRequestIdentifier; // CFStringRef(UUID)
extern const CFStringRef kFigCaptureDeferredPhotoProcessorNotificationPayloadKey_PhotoIdentifier; // CFStringRef(UUID)

extern const CFStringRef kFigCaptureDeferredPhotoProcessorNotification_WillBeginProcessingPhotoProxy; // payload contains _CaptureRequestIdentifier + _PhotoIdentifier
	
extern const CFStringRef kFigCaptureDeferredPhotoProcessorNotification_DidFinishProcessingPhotoProxy; // payload contains _ErrorStatus OR _CaptureRequestIdentifier + _PhotoIdentifier + _Surface + _SurfaceSize + _PreviewSurface + _PreviewSurfaceSize + _Metadata
extern const CFStringRef kFigCaptureDeferredPhotoProcessorNotificationPayloadKey_Surface; // IOSurfaceRef
extern const CFStringRef kFigCaptureDeferredPhotoProcessorNotificationPayloadKey_SurfaceSize; // size_t
extern const CFStringRef kFigCaptureDeferredPhotoProcessorNotificationPayloadKey_PhotoCodec; // OSType
extern const CFStringRef kFigCaptureDeferredPhotoProcessorNotificationPayloadKey_PhotoFileType; // FigCaptureStillImageSettingsFileType
extern const CFStringRef kFigCaptureDeferredPhotoProcessorNotificationPayloadKey_PreviewSurface; // IOSurfaceRef
extern const CFStringRef kFigCaptureDeferredPhotoProcessorNotificationPayloadKey_PreviewSurfaceSize; // size_t
extern const CFStringRef kFigCaptureDeferredPhotoProcessorNotificationPayloadKey_ThumbnailSurface; // IOSurfaceRef
extern const CFStringRef kFigCaptureDeferredPhotoProcessorNotificationPayloadKey_Metadata; // CFDictionaryRef
extern const CFStringRef kFigCaptureDeferredPhotoProcessorNotificationPayloadKey_PresentationTimestamp; // CFDictionaryRef(CMTime)

extern const CFStringRef kFigCaptureDeferredPhotoProcessorNotification_PhotoProcessingCancelled; // Will contain an ErrorStatus of noErr (or nil) if the processing could be cancelled + _CaptureRequestIdentifier + _PhotoIdentifier

extern const CFStringRef kFigCaptureDeferredPhotoProcessorNotification_ServerConnectionDied; // No payload

extern const CFStringRef kFigCaptureDeferredPhotoProcessorProperty_ProcessingPaused; // r/w.  CFBooleanRef.  Defaults to kCFBooleanFalse.  When set to kCFBooleanTrue, processing of the items in the queue will be paused.  If a photo is in the middle of processing it will finish before the ProcessingPaused value will take effect.  Not CM_TESTABLE because it needs to be called by AVFoundation code.

#pragma pack(pop)
	
#ifdef __cplusplus
}
#endif

// Glue is implemented inline to allow clients to step through it
#import <Celestial/FigCaptureDeferredPhotoProcessorDispatch.h>

#endif // FIG_CAPTURE_DEFERRED_PROCESSING_SUPPORTED

#endif // FIGCAPTUREDEFERREDPHOTOPROCESSOR_H
