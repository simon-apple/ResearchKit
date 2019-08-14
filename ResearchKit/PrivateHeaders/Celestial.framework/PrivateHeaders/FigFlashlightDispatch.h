/*
	File:			FigFlashlightDispatch.h
	Description:	Provides an interface to control torch
	Creation Date:	02/26/2014
	Copyright: 		© Copyright 2014-2017 Apple, Inc. All rights reserved.
*/

#ifndef FIGFLASHLIGHTDISPATCH_H
#define FIGFLASHLIGHTDISPATCH_H

#ifdef __cplusplus
extern "C" {
#endif

#pragma pack(push)
#pragma pack()

enum {
	kFigFlashlight_ClassVersion_1 = 1
};

/*!
	@interface	FigFlashlightClass
	@abstract	FigFlashlightClass contains FigFlashlight-specific methods.
	@discussion	Function pointers are set to NULL if a particular flashlight does not support them.
*/
typedef struct {
	CMBaseClassVersion version; 			// must be kFigFlashlight_ClassVersion_1
	
	Boolean (*isAvailable)( FigFlashlightRef flashlight );
	Boolean (*isOverheated)( FigFlashlightRef flashlight );
	OSStatus (*powerOn)( FigFlashlightRef flashlight );
	OSStatus (*powerOff)( FigFlashlightRef flashlight );
	OSStatus (*setLevel)( FigFlashlightRef flashlight, float level );
	float (*getLevel)( FigFlashlightRef flashlight );
	void (*notifyForCurrentState)( FigFlashlightRef flashlight );
} FigFlashlightClass;
	
/*!
	@interface	FigFlashlightVTable
	@abstract	A VTable provides an instance with access to class data.
*/
typedef struct {
	CMBaseVTable base;
	const FigFlashlightClass *FlashlightClass;
} FigFlashlightVTable;


CM_INLINE CMBaseObjectRef FigFlashlightGetCMBaseObject( FigFlashlightRef flashlight )
{
	return (CMBaseObjectRef)flashlight;
}

CM_INLINE const FigFlashlightClass *FigFlashlightGetVTable( FigFlashlightRef p )
{
	CMBaseObjectRef baseObject = FigFlashlightGetCMBaseObject( p );
	return ( baseObject ? ( (const FigFlashlightVTable *)CMBaseObjectGetVTable( baseObject ) )->FlashlightClass : NULL );
}

CM_INLINE OSStatus FigFlashlightInvalidate( FigFlashlightRef flashlight )
{
	CMBaseObjectRef baseObject = FigFlashlightGetCMBaseObject( flashlight );
	return CMBaseObjectInvalidate( baseObject );
}

CM_INLINE OSStatus FigFlashlightCopyProperty( FigFlashlightRef flashlight, CFStringRef propertyKey, CFAllocatorRef allocator, void *propertyValueOut )
{
	CMBaseObjectRef baseObject = FigFlashlightGetCMBaseObject( flashlight );
	return CMBaseObjectCopyProperty( baseObject, propertyKey, allocator, propertyValueOut );
}
	
CM_INLINE Boolean FigFlashlightIsAvailable( FigFlashlightRef flashlight )
{
	const FigFlashlightClass *vTable = FigFlashlightGetVTable( flashlight );
	if ( vTable->isAvailable ) {
		return vTable->isAvailable( flashlight );
	}
	else {
		return false;
	}
}
	
CM_INLINE Boolean FigFlashlightIsOverheated( FigFlashlightRef flashlight )
{
	const FigFlashlightClass *vTable = FigFlashlightGetVTable( flashlight );
	if ( vTable->isOverheated ) {
		return vTable->isOverheated( flashlight );
	}
	else {
		return false;
	}
}
	
CM_INLINE OSStatus FigFlashlightPowerOn( FigFlashlightRef flashlight )
{
	const FigFlashlightClass *vTable = FigFlashlightGetVTable( flashlight );
	if ( vTable->powerOn ) {
		return vTable->powerOn( flashlight );
	}
	else {
		return kCMBaseObjectError_UnsupportedOperation;
	}
}

CM_INLINE OSStatus FigFlashlightPowerOff( FigFlashlightRef flashlight )
{
	const FigFlashlightClass *vTable = FigFlashlightGetVTable( flashlight );
	if ( vTable->powerOff ) {
		return vTable->powerOff( flashlight );
	}
	else {
		return kCMBaseObjectError_UnsupportedOperation;
	}
}

CM_INLINE OSStatus FigFlashlightSetLevel( FigFlashlightRef flashlight, float level )
{
	const FigFlashlightClass *vTable = FigFlashlightGetVTable( flashlight );
	if ( vTable->setLevel ) {
		return vTable->setLevel( flashlight, level );
	}
	else {
		return kCMBaseObjectError_UnsupportedOperation;
	}
}

CM_INLINE float FigFlashlightGetLevel( FigFlashlightRef flashlight )
{
	const FigFlashlightClass *vTable = FigFlashlightGetVTable( flashlight );
	if ( vTable->getLevel ) {
		return vTable->getLevel( flashlight );
	}
	else {
		return 0;
	}
}
	
CM_INLINE void FigFlashlightNotifyForCurrentState( FigFlashlightRef flashlight )
{
	const FigFlashlightClass *vTable = FigFlashlightGetVTable( flashlight );
	if ( vTable->notifyForCurrentState ) {
		vTable->notifyForCurrentState( flashlight );
	}
}
	
#pragma pack(pop)
    
#ifdef __cplusplus
}
#endif

#endif // FIGFLASHLIGHTDISPATCH_H
