/*
	File:			FigCaptureSourceRemote.h
	Description:	Remote side of FigCaptureSource
	Author:			Ethan Tira-Thompson
	Copyright: 		© Copyright 2014 Apple, Inc. All rights reserved.
*/

#ifndef FIGCAPTURESOURCEREMOTE_H
#define FIGCAPTURESOURCEREMOTE_H

#ifndef __OBJC__
#  error FigCaptureSource requires Objective-C compilation
#endif

#import <CoreMedia/CMBasePrivate.h>
#import <Celestial/FigCaptureSource.h>

#ifdef __cplusplus
extern "C" {
#endif
	
#pragma pack(push, 4)

// no remote 'create' call, remote only gets an array of available sources from the server
extern CFArrayRef FigCaptureSourceRemoteCopyCaptureSources( FigCaptureSourceTypeMask deviceTypes );
	
// returns the maximum size of a still image capture in JPEG
extern size_t FigCaptureSourceRemoteMaxStillImageJPEGDataSize( void );

#if TARGET_OS_EMBEDDED

OSStatus FigCaptureSourceRemoteBeginGeneratingConnectionDiedNotifications( void );

extern const CFStringRef kFigCaptureSourceRemoteProperty_LockedForConfigurationCount; // CFNumber(int32_t), read-only, the number of times the device has been locked for configuration.  Only used by AVCaptureDevice in crash recovery to restore the lock count on a new instance of FigCaptureSource.
extern const CFStringRef kFigCaptureSourceRemoteProperty_ServerConnectionDied; // CFBoolean, read-only, indicate whether the capture source's server connection has died.

// This notification gets posted once after all source notifications (kFigCaptureSourceNotification_ServerConnectionDied) have been queued up to be posted.
// The AVCaptureDevice singleton registers for this notification to synchronize the recovery of all capture sources and then inform the capture sessions.
// This notification carries no payload.
extern const CFStringRef kFigCaptureSourceNotification_CaptureSourceConnectionDied;

#endif
	
#pragma pack(pop)
    
#ifdef __cplusplus
}
#endif

#endif	// FIGCAPTURESOURCESERVER_H
