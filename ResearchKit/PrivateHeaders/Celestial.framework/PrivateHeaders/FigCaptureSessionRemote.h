/*
	File:			FigCaptureSessionRemote.h
	Description:	Remote side of FigCaptureSession
	Author:			Ethan Tira-Thompson
	Creation Date:	10/14/13
	Copyright: 		© Copyright 2013-2018 Apple, Inc. All rights reserved.
*/

#ifndef FIGCAPTURESESSIONREMOTE_H
#define FIGCAPTURESESSIONREMOTE_H

#ifndef __OBJC__
#  error FigCaptureSession requires Objective-C compilation
#endif

#import <CoreMedia/CMBasePrivate.h>
#import <CoreMedia/FigTimePlatform.h>
#import <Celestial/FigCaptureSession.h>

#ifdef __cplusplus
extern "C" {
#endif
	
#pragma pack(push, 4)
	
extern OSStatus FigCaptureSessionRemoteCreate( CFAllocatorRef allocator, FigCaptureSessionRef *newCaptureSessionOut );

// Dictionary keys for prewarm
extern const CFStringRef kFigCaptureSessionRemotePrewarmKey_Time;	// CFNumber
extern const CFStringRef kFigCaptureSessionRemotePrewarmKey_Reason;	// CFString


// Pre-warm the capture stack in the expectation that Camera.app will be launched soon.
extern OSStatus FigCaptureSessionRemotePrewarmWithOptions( CFStringRef bundleIdentifier, CFDictionaryRef options );
extern OSStatus FigCaptureSessionRemoteCancelPrewarm( CFStringRef bundleIdentifier, CFDictionaryRef options );

#pragma pack(pop)
    
#ifdef __cplusplus
}
#endif

#endif	// FIGCAPTURESESSIONSERVER_H
