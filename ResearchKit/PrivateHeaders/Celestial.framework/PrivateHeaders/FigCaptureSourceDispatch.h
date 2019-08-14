/*
	File:			FigCaptureSourceDispatch.h
	Description:	Declares the FigCaptureSourceClass vtable
	Creation Date:	01/22/14
	Copyright: 		© Copyright 2014-2017 Apple, Inc. All rights reserved.
*/

#ifndef FIGCAPTURESOURCEDISPATCH_H
#define FIGCAPTURESOURCEDISPATCH_H

#ifdef __cplusplus
extern "C" {
#endif

#pragma pack(push)
#pragma pack()

enum {
	kFigCaptureSource_ClassVersion_1 = 1
};

/*!
	@interface	FigCaptureSourceClass
	@abstract	FigCaptureSourceClass contains FigCaptureSource-specific methods.
	@discussion	Function pointers are set to NULL if a particular capture source does not support them.
*/
typedef struct {
	CMBaseClassVersion version; 			// must be kFigCaptureSource_ClassVersion_1
	
	OSStatus (*lockForConfiguration)( FigCaptureSourceRef source );
	OSStatus (*unlockForConfiguration)( FigCaptureSourceRef source );
	OSStatus (*checkTCCAccess)( FigCaptureSourceRef source );
} FigCaptureSourceClass;
	
/*!
	@interface	FigCaptureSourceVTable
	@abstract	A VTable provides an instance with access to class data.
*/
typedef struct {
	CMBaseVTable base;
	const FigCaptureSourceClass *captureSourceClass;
} FigCaptureSourceVTable;


CM_INLINE CMBaseObjectRef FigCaptureSourceGetCMBaseObject( FigCaptureSourceRef source )
{
	return (CMBaseObjectRef)source;
}

CM_INLINE const FigCaptureSourceClass *FigCaptureSourceGetVTable( FigCaptureSourceRef p )
{
	CMBaseObjectRef baseObject = FigCaptureSourceGetCMBaseObject( p );
	return ( baseObject ? ( (const FigCaptureSourceVTable*)CMBaseObjectGetVTable( baseObject ) )->captureSourceClass : NULL );
}

CM_INLINE OSStatus FigCaptureSourceInvalidate( FigCaptureSourceRef source )
{
	CMBaseObjectRef baseObject = FigCaptureSourceGetCMBaseObject( source );
	return CMBaseObjectInvalidate( baseObject );
}

CM_INLINE OSStatus FigCaptureSourceCopyProperty( FigCaptureSourceRef source, CFStringRef propertyKey, CFAllocatorRef allocator, void *propertyValueOut )
{
	CMBaseObjectRef baseObject = FigCaptureSourceGetCMBaseObject( source );
	return CMBaseObjectCopyProperty( baseObject, propertyKey, allocator, propertyValueOut );
}
	
CM_INLINE OSStatus FigCaptureSourceLockForConfiguration( FigCaptureSourceRef source )
{
	const FigCaptureSourceClass *vTable = FigCaptureSourceGetVTable( source );
	if ( vTable->lockForConfiguration ) {
		return vTable->lockForConfiguration( source );
	}
	else {
		return kCMBaseObjectError_UnsupportedOperation;
	}
}
	
CM_INLINE OSStatus FigCaptureSourceSetProperty( FigCaptureSourceRef source, CFStringRef propertyKey, CFTypeRef propertyValue )
{
	CMBaseObjectRef baseObject = FigCaptureSourceGetCMBaseObject( source );
	return CMBaseObjectSetProperty( baseObject, propertyKey, propertyValue );
}

CM_INLINE OSStatus FigCaptureSourceUnlockForConfiguration( FigCaptureSourceRef source )
{
	const FigCaptureSourceClass *vTable = FigCaptureSourceGetVTable( source );
	if ( vTable->unlockForConfiguration ) {
		return vTable->unlockForConfiguration( source );
	}
	else {
		return kCMBaseObjectError_UnsupportedOperation;
	}
}
    
CM_INLINE OSStatus FigCaptureSourceCheckTCCAccess( FigCaptureSourceRef source )
{
	const FigCaptureSourceClass *vTable = FigCaptureSourceGetVTable( source );
	if ( vTable->checkTCCAccess ) {
		return vTable->checkTCCAccess( source );
	}
	else {
		return kCMBaseObjectError_UnsupportedOperation;
	}
}

#pragma pack(pop)
    
#ifdef __cplusplus
}
#endif

#endif // FIGCAPTURESOURCEDISPATCH_H
