/*
	File:			FigCaptureDeferredPhotoProcessorRemote.h
	Authors:		Rob Simutis
	Creation Date:	08/30/2018
	Copyright: 		© Copyright 2018-2019 Apple, Inc. All rights reserved.
*/

#ifndef FIGCAPTUREDEFERREDPHOTOPROCESSORCLIENT_H
#define FIGCAPTUREDEFERREDPHOTOPROCESSORCLIENT_H

#import <CoreMedia/CMBasePrivate.h>
#import <Celestial/FigCaptureDeferredPhotoProcessor.h>

#ifdef __cplusplus
extern "C" {
#endif
	
#pragma pack(push, 4)

#if FIG_CAPTURE_DEFERRED_PROCESSING_SUPPORTED

typedef void (*FigCaptureDeferredPhotoProcessorXPCNotificationCallback)( CFTypeRef notificationData, CFStringRef notificationName, CFDictionaryRef payload );
	
extern OSStatus FigCaptureDeferredPhotoProcessorRemoteCopyPhotoProcessor( FigCaptureDeferredPhotoProcessorXPCNotificationCallback notificationCallback, CFTypeRef notificationData, FigCaptureDeferredPhotoProcessorRef *processorOut );

#endif // FIG_CAPTURE_DEFERRED_PROCESSING_SUPPORTED

#pragma pack(pop)
	
#ifdef __cplusplus
}
#endif

#endif	// FIGCAPTUREDEFERREDPHOTOPROCESSORCLIENT_H
