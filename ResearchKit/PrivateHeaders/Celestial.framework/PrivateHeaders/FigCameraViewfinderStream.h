/*
	File:			FigCameraViewfinderStream.h
	Description: 	Takes uncompressed video samples and encodes/streams them using FigVirtualDisplay
	Author:			Walker Eagleston
	Creation Date:	11/7/13
	Copyright: 		© Copyright 2013-2014 Apple, Inc. All rights reserved.
*/

#ifdef __OBJC__

#import <Foundation/Foundation.h>

#import <CoreMedia/CMSampleBuffer.h>

@protocol FigCameraViewfinderStreamDelegate;

@interface FigCameraViewfinderStream : NSObject

- (instancetype)init; // designated intializer

// delegate is weak referenced
- (void)setDelegate:(id <FigCameraViewfinderStreamDelegate>)delegate queue:(dispatch_queue_t)queue; // a queue must be provided except when clearing the delegate (setting the delegate to nil)

// Open and close are not safe to call simultaneously from mutliple threads
- (void)openWithDestination:(NSString *)destination;
- (void)close;

// buffer timestamp are assumed to be in the host clock
// buffers should be uncompressed, FigCameraViewfinderStream will compress and send to the destination
- (OSStatus)enqueueVideoSampleBuffer:(CMSampleBufferRef)sbuf;

@end

@protocol FigCameraViewfinderStreamDelegate <NSObject>

@optional
- (void)cameraViewfinderStreamDidOpen:(FigCameraViewfinderStream *)stream; // if there is an error opening then airplayStream:didCloseWithStatus: will be called instead, with an error indicating why opening failed
- (void)cameraViewfinderStream:(FigCameraViewfinderStream *)stream didCloseWithStatus:(OSStatus)errorStatus; // closing can happen due to a client call to -[FigCameraViewfinderStream close] or due to an external event like a network error

@end

#endif // __OBJC__

#include <CoreMedia/FigEndpointManager.h>

extern void FigCameraViewfinderStreamRegisterEndpointManager( FigEndpointManagerRef manager );
