/*
	File:			FigFlashlight.h
	Description:	Provides an interface to control torch
	Author:			Ethan Tira-Thompson
	Creation Date:	02/26/2014
	Copyright: 		© Copyright 2014-2018 Apple, Inc. All rights reserved.
 */

#ifndef FIGFLASHLIGHT_H
#define FIGFLASHLIGHT_H

#import <CoreMedia/CMBase.h>
#import <CoreMedia/CMBaseObject.h>
#import <MacTypes.h>

#ifdef __cplusplus
extern "C" {
#endif
    
#pragma pack(push, 4)
	
#pragma mark < < < FigFlashlight > > >

// Errors, claimed -16530 to -16539
enum {
	kFigFlashlightError_TorchLevelUnavailable = -16530,
};

/*!
 @enum FigFlashlightClientType
 @abstract
    Constants describing the client's usage of the flashlight.
 
 @constant FigFlashlightClientTypeAVCaptureDeviceTorch
    A 3rd party client (controlled through -[AVCaptureDevice torchMode]) that may not run in the background.
 @constant FigFlashlightClientTypeRemoteAVFlashlight
    A system client using a shared, global flashlight, i.e. SpringBoard's ControlCenter and Siri.
 @constant FigFlashlightClientTypeFaceTimeAccessibilityTorch
    FaceTime using the flashlight in mediaserverd through AVConference for visual alert accessibility notifications.
 */
typedef CF_ENUM( CFIndex, FigFlashlightClientType ) {
	FigFlashlightClientTypeAVCaptureDeviceTorch = 0,
	FigFlashlightClientTypeRemoteAVFlashlight = 1,
	FigFlashlightClientTypeFaceTimeAccessibilityTorch = 2,
};

typedef struct OpaqueFigFlashlight *FigFlashlightRef;	// a CF type (FBO)

extern CMBaseClassID FigFlashlightGetClassID( void );

extern CFTypeID FigFlashlightGetTypeID( void );
	
// Control Center instantiates FigFlashlight with additional privileges (it's allowed to run the flashlight with the screen off while third-parties cannot).
extern OSStatus FigFlashlightCreate( CFAllocatorRef allocator, FigFlashlightClientType clientType, pid_t clientPID, CFStringRef clientApplicationID, FigFlashlightRef *newFlashlightOut );

// The flashlight is available if no capture session has opened the corresponding device
// You can check availability before turning on power
// Changes are notified by kFigFlashlightNotification_Available
CM_INLINE Boolean FigFlashlightIsAvailable( FigFlashlightRef flashlight );

// Indicates thermal restrictions
CM_INLINE Boolean FigFlashlightIsOverheated( FigFlashlightRef flashlight );
	
// Controls power state of the capture hardware which owns the flashlight.
// Another client may still steal the device after power is on, making it then unavailable.
// Returns kIOReturnNoDevice if the device could not be powered on (another client is using it)
// This can block for significant time.
CM_INLINE OSStatus FigFlashlightPowerOn( FigFlashlightRef flashlight );
CM_INLINE OSStatus FigFlashlightPowerOff( FigFlashlightRef flashlight );

// Controls the flashlight level, powers on the device if unprepared; level is 0-1.  Levels above 1 are "max available".
// Non-zero level will power on the device as needed, which may cause delay (use FigFlashlightPowerOn in advance)
// The level is cleared when stolen, if called when unavailable returns kIOReturnNoDevice and ignores the call
// Returns kFigFlashlightError_TorchLevelUnavailable if the specified level is unavailable due to thermal mitigation.
CM_INLINE OSStatus FigFlashlightSetLevel( FigFlashlightRef flashlight, float level );

// Returns the current flashlight level as range 0-1
// This only reflects this flashlight's level, does not query the live stream level as controlled by another client.
CM_INLINE float FigFlashlightGetLevel( FigFlashlightRef flashlight );

// Sends kFigFlashlightNotification_Overheated, kFigFlashlightNotification_Available and kFigFlashlightNotification_Level with the current values.
// Allows the caller to asynchronously query the initial values for IsOverheated, IsAvailable and Level after they have registered their notification handlers.
CM_INLINE void FigFlashlightNotifyForCurrentState( FigFlashlightRef flashlight );

// NOTIFICATIONS
extern const CFStringRef kFigFlashlightNotification_Overheated; // Sent when thermal constraints start/stop
extern const CFStringRef kFigFlashlightNotification_Level; // If another client steals/releases the device, or as thermal constraints increase, limiting level to lower values
extern const CFStringRef kFigFlashlightNotification_Available; // When another client steals/drops the device (If flashlight were globally accessible, available would always be true, wouldn't change)
extern const CFStringRef kFigFlashlightNotification_ServerDied; // indicates IPC issues
	
extern const CFStringRef kFigFlashlightNotificationPayloadKey_Value; // for overheated, level, and available notifications: the new value
	
#pragma pack(pop)
    
#ifdef __cplusplus
}
#endif

// Glue is implemented inline to allow clients to step through it
#include <Celestial/FigFlashlightDispatch.h>

#endif // FIGFlashlight_H
