/*
	File:			FigCaptureDeferredPhotoProcessorPrivate.h
	Author:			Rob Simutis
	Creation Date:	08/31/18
	Copyright:		© Copyright 2018-2019 Apple, Inc. All rights reserved.
*/

#ifndef FIGCAPTUREDEFERREDPHOTOPROCESSORPRIVATE_H
#define FIGCAPTUREDEFERREDPHOTOPROCESSORPRIVATE_H

#import <Celestial/FigCaptureDeferredPhotoProcessor.h>

#ifdef __cplusplus
extern "C" {
#endif
	
#pragma pack(push, 4)
	
#pragma mark < < < FigCaptureDeferredPhotoProcessorPrivate > > >


#if FIG_CAPTURE_DEFERRED_PROCESSING_SUPPORTED
// THE FOLLOWING FUNCTIONS ARE FOR FIG CONSUMPTION ONLY (NEVER TO BE CALLED BY AVFOUNDATION)

FigCaptureDeferredPhotoProcessorRef FigCaptureDeferredPhotoProcessorCopyProcessorForPID( pid_t clientPID, audit_token_t clientAuditToken );
	
OSStatus FigCaptureDeferredPhotoProcessorSetXPCConnection( FigCaptureDeferredPhotoProcessorRef processor, xpc_connection_t connection, uint64_t objectID );

// Serialization functions
OSStatus captureDeferredPhotoProcessor_createSerializedNotification( CFStringRef notificationName, CFDictionaryRef originalPayload, xpc_object_t message, CFDictionaryRef *notificationOut );
OSStatus captureDeferredPhotoProcessor_createDeserializedNotification( CFStringRef notificationName, xpc_object_t message, CFDictionaryRef originalPayload, CFDictionaryRef *notificationOut );
	
#endif // FIG_CAPTURE_DEFERRED_PROCESSING_SUPPORTED


#pragma pack(pop)
	
#ifdef __cplusplus
}
#endif


#endif	// #ifndef FIGCAPTUREDEFERREDPHOTOPROCESSORPRIVATE_H
