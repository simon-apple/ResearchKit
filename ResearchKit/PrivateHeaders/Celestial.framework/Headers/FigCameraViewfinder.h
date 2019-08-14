/*
	File:			FigCameraViewfinder.h
	Description: 	Observe system wide camera use and stream live preview to another device
	Author:			Walker Eagleston
	Creation Date:	10/17/13
	Copyright: 		© Copyright 2013- Apple, Inc. All rights reserved.
*/

#import <Foundation/Foundation.h>
#import <CoreMedia/CMTime.h>
#import <CoreGraphics/CGGeometry.h>


@protocol FigCameraViewfinderDelegate, FigCameraViewfinderSessionDelegate;
@class FigCameraViewfinderSession;

@interface FigCameraViewfinder : NSObject

+ (instancetype)cameraViewfinder;

- (void)setDelegate:(id <FigCameraViewfinderDelegate, FigCameraViewfinderSessionDelegate>)delegate queue:(dispatch_queue_t)queue; // a queue must be provided except when clearing the delegate (setting the delegate to nil)
// The provided delegate is also messaged by active FigCameraViewfinderSessions via the FigCameraViewfinderSessionDelegate protocol
@property(atomic, readonly) id <FigCameraViewfinderDelegate, FigCameraViewfinderSessionDelegate> delegate;
@property(atomic, readonly) dispatch_queue_t queue;

- (void)startWithOptions:(NSDictionary *)options;
- (void)stop; // Once started the viewfinder must be stopped before the client releases its last reference (otherwise the viewfinder will live on)

// Options keys
extern NSString * const FigCameraViewfinderPhotoThumbnailMaxDimensionKey; // int32_t, constrain the largest dimension of the thumbnail to a specific size
extern NSString * const FigCameraViewfinderPhotoThumbnailQualityKey; // float with a range from 0.0-1.0

@end

@protocol FigCameraViewfinderDelegate <NSObject>
@required

// Only one viewfinder session will ever be active at a time
- (void)cameraViewfinder:(FigCameraViewfinder *)viewfinder viewfinderSessionDidBegin:(FigCameraViewfinderSession *)viewfinderSession;
- (void)cameraViewfinder:(FigCameraViewfinder *)viewfinder viewfinderSessionDidEnd:(FigCameraViewfinderSession *)viewfinderSession; // at this point the viewfinder session is dead, throw it out

@end

enum {
	kFigCameraViewfinderSessionError_InvalidParameter	= -16290,
	kFigCameraViewfinderSessionError_SessionNotRunning	= -16291,
	kFigCameraViewfinderSessionError_ServerDied			= -16292,
};

// FigCameraViewfinderSession
@interface FigCameraViewfinderSession : NSObject

// no initializer, clients don't create these, they are vended by FigCameraViewfinderDelegate

// Only one preview stream can be open at a time
- (void)openPreviewStreamWithOptions:(NSDictionary *)options; // asynchronous
// if opening fails the delegate will be called with cameraViewfinderSession:previewStreamDidCloseWithStatus:
// kFigCameraViewfinderSessionError_SessionNotRunning is returned if you try to open a preview stream after the viewfinder session has ended

extern NSString * const FigCameraViewfinderSessionPreviewStreamDestinationKey; // NSString. This can be a Bonjour service identifier, DNS name, or IP address, like AirPlayScreenClient_SetDestination()
// destination should be running airplay receiver

- (void)closePreviewStream; // asynchronous
// if the stream is open the delegate will receive cameraViewfinderSession:previewStreamDidCloseWithStatus:
@end

@protocol FigCameraViewfinderSessionDelegate <NSObject>
@optional

// Photo Taking
- (void)cameraViewfinderSession:(FigCameraViewfinderSession *)session didCapturePhotoWithStatus:(OSStatus)errorStatus thumbnailData:(NSData *)jpegThumbnailData timestamp:(CMTime)photoTimestamp;
// Not supported on the new capture stack. This method will not be called.

// Preview stream
- (void)cameraViewfinderSessionPreviewStreamDidOpen:(FigCameraViewfinderSession *)session; // if there is an error opening then cameraViewfinderSession:previewStreamDidCloseWithStatus: will be called instead, with an error indicating why opening failed
- (void)cameraViewfinderSession:(FigCameraViewfinderSession *)session previewStreamDidCloseWithStatus:(OSStatus)errorStatus; // closing can happen due to a client call to -[FigCameraViewfinderSession closePreviewStream] or due to an external event like a network error. The stream will also automatically close when the camera session ends (due to the user exiting the app, or at least the camera portion). If the openPreviewStreamWithOptions: call fails this method will be called instead of cameraPreviewStreamDidOpen:

@end
