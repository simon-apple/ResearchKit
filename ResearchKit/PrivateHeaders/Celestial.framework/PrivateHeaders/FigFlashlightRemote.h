/*
	File:			FigFlashlightRemote.h
	Description:	Remote side of FigFlashlight
	Author:			Ethan Tira-Thompson
	Copyright: 		© Copyright 2014 Apple, Inc. All rights reserved.
*/

#ifndef FIGFLASHLIGHTREMOTE_H
#define FIGFLASHLIGHTREMOTE_H

#ifndef __OBJC__
#  error FigFlashlight requires Objective-C compilation
#endif

#import <CoreMedia/CMBasePrivate.h>
#import <Celestial/FigFlashlight.h>

#ifdef __cplusplus
extern "C" {
#endif
	
#pragma pack(push, 4)

extern OSStatus FigFlashlightRemoteCreate(  CFAllocatorRef allocator, FigFlashlightRef *flashlightOut );

#pragma pack(pop)
    
#ifdef __cplusplus
}
#endif

#endif	// FIGFLASHLIGHTSERVER_H
