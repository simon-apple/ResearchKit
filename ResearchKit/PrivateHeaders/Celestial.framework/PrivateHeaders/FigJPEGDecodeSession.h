/*
	File:		FigJPEGDecodeSession.h

	Description: Session based hardware JPEG decode API.

	Author:		Walker Eagleston

	Copyright: 	Copyright 2012-2016 Apple Inc. All rights reserved.

	To do:

	$Id: $
	$Log$
	26jan2016 jpap
	[23582917] Move FigAspen JPEG to MediaToolbox; leave wrappers in Celestial. <lbarnes, linus_nilsson>
*/

#ifndef _FIG_JPEG_DECODE_SESSION_H_
#define _FIG_JPEG_DECODE_SESSION_H_

#include <CoreFoundation/CoreFoundation.h>
#include <CoreGraphics/CGImage.h>
#include <CoreVideo/CVPixelBuffer.h>

#include <MediaToolbox/FigPhotoJPEGDecodeSession.h>

#if defined(__cplusplus)
extern "C"
{
#endif
    
#pragma pack(push, 4)

/*!
	@enum FigJPEGDecodeSession Errors
	@discussion OSStatus errors returned by FigJPEGDecodeSession APIs.
	@constant	kFigJPEGDecodeSessionError_ParamErr: Invalid parameter.
	@constant	kFigJPEGDecodeSessionError_AllocationFailed: An allocation has failed.
	@constant	kFigJPEGDecodeSessionError_RequestCancelled: The request has been cancelled.
	@constant	kFigJPEGDecodeSessionError_UnknownRequestID: An unknown request ID was specified.
	@constant	kFigJPEGDecodeSessionError_UnsupportedJPEGFormat: The format of the JPEG data is unsupported by the hardware decoder.
					The hardware decoder does not currently support progressive JPEGs and certain chroma sub-sampling modes.
	@constant	kFigJPEGDecodeSessionError_InvalidJPEGData: The JPEG data is corrupt, or does not conform to the JPEG specification.
	@constant	kFigJPEGDecodeSessionError_UnsupportedJPEGSize: The size of the JPEG data is unsupported by the hardware decoded, typically for smaller images where a minimum number of MCUs are required for decoding.
*/
enum {
	kFigJPEGDecodeSessionError_ParamErr					= -16070,
	kFigJPEGDecodeSessionError_AllocationFailed			= -16071,
	kFigJPEGDecodeSessionError_RequestCancelled			= -16072, 
	kFigJPEGDecodeSessionError_UnknownRequestID			= -16073,
	kFigJPEGDecodeSessionError_UnsupportedJPEGFormat	= -16074,
	kFigJPEGDecodeSessionError_InvalidJPEGData			= -16075,
	kFigJPEGDecodeSessionError_UnsupportedJPEGSize		= -16076,
};

typedef FigPhotoJPEGDecodeSessionRef FigJPEGDecodeSessionRef; // CFTypeRef

extern CFTypeID FigJPEGDecodeSessionGetTypeID( void );

/*!
	@function	FigJPEGDecodeSessionCreate
	@abstract	Creates a hardware JPEG decode session.
	@discussion
	@param	allocator
		CFAllocator for the session (not used to allocate CVPixelBuffer or CGImage backings).
	@param	options
		CFDictionary specifying creation time options. The only option currently supported is
		kFigJPEGDecodeSessionOptionKey_EnableAsyncDecode. Pass NULL otherwise.
	@param	sessionOut
		Points to a FigJPEGDecodeSessionRef to receive the created JPEG decode session.
		The caller must CFRelease its retain on this object when it is done with it.
	@result
		Returns noErr if creation was successful.
*/
extern OSStatus FigJPEGDecodeSessionCreate( CFAllocatorRef allocator, CFDictionaryRef options, FigJPEGDecodeSessionRef *sessionOut );

/*!
	@function	FigJPEGDecodeSessionCreateCGImageFromData
	@abstract	Creates a CGImage from JPEG data.
	@discussion
		By default the CGImages created by this method are backed by a '420f' IOSurface
		which CoreAnimation can display natively. If you intend to draw or otherwise interact
		with the image using CoreGraphics APIs you should choose 'BGRA' as your pixel format
		for best performance.
	@param	jpegData
		CFDataRef containing the JPEG data to decode.
	@param	options
		A CFDictionaryRef containing decode options.
	@param imageOut
		Points to a CGImageRef to receive the created image.
		The caller must CFRelease its retain on this object when it is done with it.
	@result
		Returns noErr if creation was successful.
*/
extern OSStatus FigJPEGDecodeSessionCreateCGImageFromData(
					FigJPEGDecodeSessionRef session, 
					CFDataRef jpegData, 
					CFDictionaryRef options, 
					CGImageRef *imageOut );

/*!
	@function	FigJPEGDecodeSessionCreateCVPixelBufferFromData
	@abstract	Creates a CVPixelBuffer from JPEG data.
	@discussion
		CVPixelBuffers are ideal when you plan to do subsequent operations using VideoToolbox
		APIs including VTPixelTransferSession and VTImageRotationSession, or if you plan to
		use the decoded image as an OpenGL texture via CVOpenGLESTextureCache. FigAspenJPEGEncoder
		also works natively with CVPixelBuffers. CVPixelBuffers returned by this method are
		always backed by an IOSurface which can be retrieved with CVPixelBufferGetIOSurface().
		Because these pixel buffers are vended from an internal pool care must be taken when
		using the IOSurface directly to prevent it from being recycled. It is recommended that
		clients keep around the CVPixelBuffer while using the underlying surface, otherwise it
		is necessary to manage the use count of the IOSurface manually.
	@param	jpegData
		CFDataRef containing the JPEG data to decode.
	@param	options
		A CFDictionaryRef containing decode options.
	@param pixelBufferOut
		Points to a CVPixelBufferRef to receive the created pixel buffer.
		The caller must CFRelease its retain on this object when it is done with it.
	@result
		Returns noErr if creation was successful.
*/
extern OSStatus FigJPEGDecodeSessionCreateCVPixelBufferFromData(
					FigJPEGDecodeSessionRef session,
					CFDataRef jpegData,
					CFDictionaryRef options,
					CVPixelBufferRef *pixelBufferOut );

typedef FigPhotoJPEGRequestID FigJPEGRequestID;
	
#define kFigJPEGRequestID_Invalid kFigPhotoJPEGRequestID_Invalid

typedef FigPhotoJPEGDecodeSessionCGImageCompletionHandler FigJPEGDecodeSessionCGImageCompletionHandler;

/*!
	@function	FigJPEGDecodeSessionDecodeDataToCGImageAsynchronously
	@abstract	Asynchronously decodes JPEG data into a CGImage.
	@discussion
		By default the CGImages created by this method are backed by a '420f' IOSurface
		which CoreAnimation can display natively. If you intend to draw or otherwise interact
		with the image using CoreGraphics APIs you should choose 'BGRA' as your pixel format
		for best performance. Decode requests will be queued up if hardware resources are
		busy servicing other JPEG decodes.
	@param	jpegData
		CFDataRef containing the JPEG data to decode.
	@param	options
		A CFDictionaryRef containing decode options.
	@param completionHandler
		A completion handler which will be called asynchronously with the result of the decode.
		The client must retain the resulting CGImage if they want to use it outside of the handler.
	@result
		Returns a unique non-zero request ID that can be later used to cancel the request or identify
		the request from its completion handler.
*/
extern FigJPEGRequestID FigJPEGDecodeSessionDecodeDataToCGImageAsynchronously(
							FigJPEGDecodeSessionRef session,
							CFDataRef jpegData,
							CFDictionaryRef options,
							FigJPEGDecodeSessionCGImageCompletionHandler completionHandler );

typedef FigPhotoJPEGDecodeSessionCVPixelBufferCompletionHandler FigJPEGDecodeSessionCVPixelBufferCompletionHandler;

/*!
	@function	FigJPEGDecodeSessionDecodeDataToCVPixelBufferAsynchronously
	@abstract	Asynchronously decodes JPEG data into a CVPixelBuffer.
	@discussion
		CVPixelBuffers are ideal when you plan to do subsequent operations using VideoToolbox
		APIs including VTPixelTransferSession and VTImageRotationSession, or if you plan to
		use the decoded image as an OpenGL texture via CVOpenGLESTextureCache. FigAspenJPEGEncoder
		also works natively with CVPixelBuffers. CVPixelBuffers returned by this method are
		always backed by an IOSurface which can be retrieved with CVPixelBufferGetIOSurface().
		Because these pixel buffers are vended from an internal pool care must be taken when
		using the IOSurface directly to prevent it from being recycled. It is recommended that
		clients keep around the CVPixelBuffer while using the underlying surface, otherwise it
		is necessary to manage the use count of the IOSurface manually. Decode requests will
		be queued up if hardware resources are busy servicing other JPEG decodes.
	@param	jpegData
		CFDataRef containing the JPEG data to decode.
	@param	options
		A CFDictionaryRef containing decode options.
	@param completionHandler
		A completion handler which will be called asynchronously with the result of the decode.
		The client must retain the resulting CVPixelBuffer if they want to use it outside of the handler.
	@result
		Returns a unique non-zero request ID that can be later used to cancel the request or identify
		the request from its completion handler.
*/
extern FigJPEGRequestID FigJPEGDecodeSessionDecodeDataToCVPixelBufferAsynchronously(
							FigJPEGDecodeSessionRef session,
							CFDataRef jpegData,
							CFDictionaryRef options,
							FigJPEGDecodeSessionCVPixelBufferCompletionHandler completionHandler );

#pragma mark Session Option Keys

/*!
	@constant	kFigJPEGDecodeSessionOptionKey_EnableAsyncDecode
	@abstract	Enable availability of the asynchronous hardware driver path
	@discussion
		Defaults to false. When true the decode session will allocate additional
		resources at creation time that allows the use of kFigJPEGDecodeSessionImageOptionKey_AsyncDecode
		during decode.
*/
extern const CFStringRef kFigJPEGDecodeSessionOptionKey_EnableAsyncDecode; // CFBoolean

/*!
	@constant	kFigJPEGDecodeSessionOptionKey_ColorSpaceAware
	@abstract	Specifies if the session decoder should make use of encountered ICC profiles.
	@discussion
		Defaults to true. When true the decode session will extract any found ICC profile, create
		a CGColorSpace from it and attach it to the output surface. This may decrease performance.
 */
extern const CFStringRef kFigJPEGDecodeSessionOptionKey_ColorSpaceAware; // CFBoolean
	

#pragma mark Image Option Keys

/*!
	@constant	kFigJPEGDecodeSessionImageOptionKey_OutputPixelFormat
	@abstract	Specifies the pixel format of the resulting image.
	@discussion
		Options are '420f', 'BGRA', and 'L565'. Defaults to '420f', which is the native
		pixel format of the hardware decoder.
*/
extern const CFStringRef kFigJPEGDecodeSessionImageOptionKey_OutputPixelFormat;	// OSType wrapped in CFNumber

/*!
	@constant	kFigJPEGDecodeSessionImageOptionKey_OutputBytesPerRowAlignment
	@abstract	Specifies the bytes per row alignment of the resulting image.
	@discussion
		Leave this unspecified unless you have specific alignment requirements. On H3 and
		earlier the hardware decoder has strict alignment requirements so requesting a
		specific alignment may require an additional format conversion.
*/
extern const CFStringRef kFigJPEGDecodeSessionImageOptionKey_OutputBytesPerRowAlignment; // CFNumber

/*!
	@constant	kFigJPEGDecodeSessionImageOptionKey_ApplyTransform
	@abstract	Specifies whether or not to apply the transform specified by the JPEGs embedded orientation flag.
	@discussion
		If you are intending to display the image onscreen its best to apply the transform
		during display rather than during decode. When decoding equi-sized images with different
		orientations (portrait vs landscape) applying the transform will reduce the opportunity
		for buffer re-use. Defaults to false.
*/
extern const CFStringRef kFigJPEGDecodeSessionImageOptionKey_ApplyTransform; // CFBoolean

/*!
	@constant	kFigJPEGDecodeSessionImageOptionKey_MaxPixelSize
	@abstract	Specifies a constraint on the largest dimension for the resulting image.
	@discussion
		Scaling will be performed to constrain the dimensions of the output when the max
		pixel size is smaller than the largest dimension of the JPEG. The default is to
		perform no scaling.
*/
extern const CFStringRef kFigJPEGDecodeSessionImageOptionKey_MaxPixelSize;	// CFNumber

/*!
	@constant	kFigJPEGDecodeSessionImageOptionKey_BackCGImageWithIOSurface
	@abstract	Specifies whether or not to use an IOSurface as the backing for the resulting CGImage.
	@discussion
			Defaults to true. This avoids a copy from the decode surface into malloc'd
			memory. CoreAnimation can use the IOSurface backing directly which also avoids
			a copy when sending the contents to the render server. When false the output
			pixel format must be 'BGRA'.
*/
extern const CFStringRef kFigJPEGDecodeSessionImageOptionKey_BackCGImageWithIOSurface;	// CFBoolean

/*!
	@constant	kFigJPEGDecodeSessionImageOptionKey_AllowNonExactOutputDimensions
	@abstract	Allows buffer re-use when the dimensions do not match exactly.
	@discussion
			Defaults to false. When true a cached output buffer may be reused even if the
			dimensions are not exactly the same as requested. This can be more performant
			when decoding images of different sizes. CVPixelBuffers will contain a clean
			aperture attachment marking the region to display. CGImages are not currently
			supported with this option.
*/
extern const CFStringRef kFigJPEGDecodeSessionImageOptionKey_AllowNonExactOutputDimensions; // CFBoolean

/*!
	@constant	kFigJPEGDecodeSessionImageOptionKey_ForceHighSpeedDecode
	@abstract	Option to force the hardware to run at high speed.
	@discussion
			Defaults to false. When true images are decoded as fast as possible.
			Note that this has power implications. In the future the decode session may
			dynamically switch the hardware speed based on request load. Currently it will
			always run at low speed unless high speed mode is forced.
*/
extern const CFStringRef kFigJPEGDecodeSessionImageOptionKey_ForceHighSpeedDecode; // CFBoolean

/*!
	 @constant	kFigJPEGDecodeSessionImageOptionKey_HighPriority
	 @abstract	Suggests that the request should be processed before any other default priority request.
	 @discussion
			Defaults to false. When true the request will be processed before other default
			(lower) priority requests.
*/
extern const CFStringRef kFigJPEGDecodeSessionImageOptionKey_HighPriority; // CFBoolean

/*!
	 @constant	kFigJPEGDecodeSessionImageOptionKey_AsyncDecode
	 @abstract	Use the asynchronous hardware driver path
	 @discussion
			Defaults to false. When true the decode request will make use of an asynchronous
			driver callback. This option is intended for decode loads of multiple images,
			that can lead to higher concurrency and improved overall decode throughput.

			kFigJPEGDecodeSessionOptionKey_EnableAsyncDecode must also be passed to the
			session when it's created with FigJPEGDecodeSessionCreate(), or this option
			will cause a decode to fail with error.
*/
extern const CFStringRef kFigJPEGDecodeSessionImageOptionKey_AsyncDecode; // CFBoolean

/*!
	@function	FigJPEGDecodeSessionCancelRequest
	@abstract	Cancels an asynchronous decode request.
	@discussion
		Cancelled requests will have their completion handler called with the error code
		kFigJPEGDecodeSessionError_RequestCancelled.
	@param	requestID
		The request ID of the decode request you would like to cancel.
	@result
		Returns kFigJPEGDecodeSessionError_UnknownRequestID if the request has already completed
		or the request ID is invalid.
*/
extern OSStatus FigJPEGDecodeSessionCancelRequest( FigJPEGDecodeSessionRef session, FigJPEGRequestID requestID );

/*!
	@function	FigJPEGDecodeSessionDiscardCachedBuffers
	@abstract	Discards any cached buffers held by the decode session.
	@discussion
		Clients may want to call this in response to a memory warning, or when their app
		transitions from the foreground to the background.
	@result
		Returns noErr if the operation succeeds.
*/
extern OSStatus FigJPEGDecodeSessionDiscardCachedBuffers( FigJPEGDecodeSessionRef session );

#pragma pack(pop)
	
#if defined(__cplusplus)
}
#endif

#endif // _FIG_JPEG_DECODE_SESSION_H_
