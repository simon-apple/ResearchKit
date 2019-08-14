/*
	File:			FigCaptureDeferredPhotoProcessorDispatch.h
	Authors:		Rob Simutis
	Creation Date:	09/22/18
	Copyright: 		© Copyright 2018-2019 Apple, Inc. All rights reserved.
*/


#ifndef FIGCAPTUREDEFERREDPHOTOPROCESSORDISPATCH_H
#define FIGCAPTUREDEFERREDPHOTOPROCESSORDISPATCH_H

#ifdef __cplusplus
extern "C" {
#endif

#pragma pack(push, 4)

enum {
	kFigCaptureDeferredPhotoProcessor_ClassVersion_1 = 1
};

/*!
	@struct		FigCaptureDeferredPhotoProcessorClass
	@abstract	FigCaptureDeferredPhotoProcessorClass contains FigCaptureDeferredPhotoProcessor-specific methods.
	@discussion	Function pointers are set to NULL if a particular capture processor does not support them.
*/
typedef struct {
	CMBaseClassVersion version; 			// must be kFigCaptureDeferredPhotoProcessor_ClassVersion_1
	
	CFArrayRef (*copyUnfinishedPhotoIdentifiers)( FigCaptureDeferredPhotoProcessorRef processor );
	CFArrayRef (*copyUnfinishedPhotoIdentifiersForApplicationID)( FigCaptureDeferredPhotoProcessorRef processor, CFStringRef bundleID );
	OSStatus (*processPhoto)( FigCaptureDeferredPhotoProcessorRef processor, CFStringRef captureRequestIdentifier, CFStringRef photoIdentifier, FigCaptureDeferredPhotoProcessorQueuePosition queuePosition, xpc_object_t message );
	OSStatus (*cancelPhotoProcessing)( FigCaptureDeferredPhotoProcessorRef processor, CFStringRef captureRequestIdentifier, CFStringRef photoIdentifier );
	OSStatus (*deletePersistentStorageForPhoto)( FigCaptureDeferredPhotoProcessorRef processor, CFStringRef captureRequestIdentifier, CFStringRef photoIdentifier );
} FigCaptureDeferredPhotoProcessorClass;
	
/*!
	@struct		FigCaptureDeferredPhotoProcessorVTable
	@abstract	A VTable provides an instance with access to class data.
*/
typedef struct {
	CMBaseVTable base;
	const FigCaptureDeferredPhotoProcessorClass *processorClass;
} FigCaptureDeferredPhotoProcessorVTable;


CM_INLINE CMBaseObjectRef FigCaptureDeferredPhotoProcessorGetCMBaseObject( FigCaptureDeferredPhotoProcessorRef processor )
{
	return (CMBaseObjectRef)processor;
}

CM_INLINE const FigCaptureDeferredPhotoProcessorClass *FigCaptureDeferredPhotoProcessorGetVTable( FigCaptureDeferredPhotoProcessorRef p )
{
	CMBaseObjectRef baseObject = FigCaptureDeferredPhotoProcessorGetCMBaseObject( p );
	return ( baseObject ? ( (const FigCaptureDeferredPhotoProcessorVTable*)CMBaseObjectGetVTable( baseObject ) )->processorClass : NULL );
}

CM_INLINE OSStatus FigCaptureDeferredPhotoProcessorInvalidate( FigCaptureDeferredPhotoProcessorRef processor )
{
	CMBaseObjectRef baseObject = FigCaptureDeferredPhotoProcessorGetCMBaseObject( processor );
	return CMBaseObjectInvalidate( baseObject );
}

CM_INLINE OSStatus FigCaptureDeferredPhotoProcessorCopyProperty( FigCaptureDeferredPhotoProcessorRef processor, CFStringRef propertyKey, CFAllocatorRef allocator, void *propertyValueOut )
{
	CMBaseObjectRef baseObject = FigCaptureDeferredPhotoProcessorGetCMBaseObject( processor );
	return CMBaseObjectCopyProperty( baseObject, propertyKey, allocator, propertyValueOut );
}

CM_INLINE OSStatus FigCaptureDeferredPhotoProcessorSetProperty( FigCaptureDeferredPhotoProcessorRef processor, CFStringRef propertyKey, CFTypeRef propertyValue )
{
	CMBaseObjectRef baseObject = FigCaptureDeferredPhotoProcessorGetCMBaseObject( processor );
	return CMBaseObjectSetProperty( baseObject, propertyKey, propertyValue );
}

CM_INLINE CFArrayRef FigCaptureDeferredPhotoProcessorCopyUnfinishedPhotoIdentifiers( FigCaptureDeferredPhotoProcessorRef processor )
{
	const FigCaptureDeferredPhotoProcessorClass *vTable = FigCaptureDeferredPhotoProcessorGetVTable( processor );
	if ( vTable->copyUnfinishedPhotoIdentifiers ) {
		return vTable->copyUnfinishedPhotoIdentifiers( processor );
	}
	else {
		return NULL;
	}
}

CM_INLINE CFArrayRef FigCaptureDeferredPhotoProcessorCopyUnfinishedPhotoIdentifiersForApplicationID( FigCaptureDeferredPhotoProcessorRef processor, CFStringRef bundleID )
{
	const FigCaptureDeferredPhotoProcessorClass *vTable = FigCaptureDeferredPhotoProcessorGetVTable( processor );
	if ( vTable->copyUnfinishedPhotoIdentifiersForApplicationID ) {
		return vTable->copyUnfinishedPhotoIdentifiersForApplicationID( processor, bundleID );
	}
	else {
		return NULL;
	}
}

CM_INLINE OSStatus FigCaptureDeferredPhotoProcessorProcessPhoto( FigCaptureDeferredPhotoProcessorRef processor, CFStringRef captureRequestIdentifier, CFStringRef photoIdentifier, FigCaptureDeferredPhotoProcessorQueuePosition queuePosition, xpc_object_t message )
{
	const FigCaptureDeferredPhotoProcessorClass *vTable = FigCaptureDeferredPhotoProcessorGetVTable( processor );
	if ( vTable->processPhoto ) {
		return vTable->processPhoto( processor, captureRequestIdentifier, photoIdentifier, queuePosition, message );
	}
	else {
		return kCMBaseObjectError_UnsupportedOperation;
	}
}
	
CM_INLINE OSStatus FigCaptureDeferredPhotoProcessorCancelPhotoProcessing( FigCaptureDeferredPhotoProcessorRef processor, CFStringRef captureRequestIdentifier, CFStringRef photoIdentifier )
{
	const FigCaptureDeferredPhotoProcessorClass *vTable = FigCaptureDeferredPhotoProcessorGetVTable( processor );
	if ( vTable->cancelPhotoProcessing ) {
		return vTable->cancelPhotoProcessing( processor, captureRequestIdentifier, photoIdentifier );
	}
	else {
		return kCMBaseObjectError_UnsupportedOperation;
	}
}

CM_INLINE OSStatus FigCaptureDeferredPhotoProcessorDeletePersistentStorageForPhoto( FigCaptureDeferredPhotoProcessorRef processor, CFStringRef captureRequestIdentifier, CFStringRef photoIdentifier )
{
	const FigCaptureDeferredPhotoProcessorClass *vTable = FigCaptureDeferredPhotoProcessorGetVTable( processor );
	if ( vTable->deletePersistentStorageForPhoto ) {
		return vTable->deletePersistentStorageForPhoto( processor, captureRequestIdentifier, photoIdentifier );
	}
	else {
		return kCMBaseObjectError_UnsupportedOperation;
	}
}

#pragma pack(pop)
	
#ifdef __cplusplus
}
#endif

#endif // FIGCAPTUREDEFERREDPHOTOPROCESSORDISPATCH_H
