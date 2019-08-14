/*
	File:		FigAspenJPEGDecoderPrivate.h

	Description: Private Interface to JPEG decoder for Aspen devices.

	Author:		Brandon Corey

	Copyright: 	Copyright 2009-2016 Apple Inc. All rights reserved.

	$Id: $
	$Log$
	26jan2016 jpap
	[23582917] Move FigAspen JPEG to MediaToolbox; leave wrappers in Celestial. <lbarnes, linus_nilsson>
*/

#ifndef _FIG_ASPEN_JPEG_DECODER_PRIVATE_H_
#define _FIG_ASPEN_JPEG_DECODER_PRIVATE_H_

#include <CoreFoundation/CoreFoundation.h>
#include <IOSurface/IOSurface.h>

#if defined(__cplusplus)
extern "C"
{
#endif
    
#pragma pack(push, 4)

typedef struct FigAspenJPEGDecodeTiming {
	uint64_t createInputBufferTime;
	uint64_t createOutputBufferTime;
	uint64_t inputCopyTime;
	uint64_t JPEGDecodeTime;
	uint64_t scaleConvertTime;
	uint64_t scaleConvertRotateTime;
} FigAspenJPEGDecodeTiming_t;

/*!
	@constant  kFigJPEGOutputPixelFormat
	@abstract  Optional output pixel format for FigCreateIOSurfaceFromJPEG().
 */
extern const CFStringRef kFigJPEGOutputPixelFormat;	// OSType wrapped in CFNumber

/*!
	@constant  kFigJPEGOutputBytesPerRowAlignment
	@abstract  Optional output BytesPerRow alignment for FigCreateIOSurfaceFromJPEG().
*/
extern const CFStringRef kFigJPEGOutputBytesPerRowAlignment;	// CFNumber, default 0

/*!
	@constant  kFigJPEGTestDecodeTiming
	@abstract  Requests timing statistics to be filled into an internal buffer.
	           Available in experimental builds only.
 */
extern const CFStringRef kFigJPEGTestDecodeTiming;		// CFBoolean, default false

/*!
	@constant  kFigJPEGCacheDriverConnection
	@abstract  Request to internally cache connection(s) to the driver in the process.
 */
extern const CFStringRef kFigJPEGCacheDriverConnection;		// CFBoolean, default false

/*!
	@constant  kFigJPEGSingleShotDecode
	@abstract  Hint that the surfaces will only be used once.
*/
extern const CFStringRef kFigJPEGSingleShotDecode;			// CFBoolean, default false

/*!
	@constant  kFigJPEGRequireForegroundRunning
	@abstract  Recognized by FigAspenShouldUseHardwareDecode.  If set, FigAspenShouldUseHardwareDecode
	           will return false if the caller is not the foreground running app.
*/
extern const CFStringRef kFigJPEGRequireForegroundRunning;	// CFBoolean, default false

/*!
	@function   FigAspenCreateJPEGOutputIOSurface
	@abstract   Creates an IOSurface suitable for hardware JPEG decoding.
 */
extern IOSurfaceRef FigAspenCreateJPEGOutputIOSurface(UInt32 width, UInt32 height, UInt32 blockWidth, UInt32 blockHeight);


/*!
	@function   FigAspenGetMaximumOutputDimensionsForJPEG
	@abstract   Return maximum dimensions supported by hardware.
*/
extern CGSize FigAspenGetMaximumOutputDimensionsForJPEG(void);

/*!
	@function   FigAspenShouldUseHardwareDecode
	@abstract   Determines on a per platform basis whether or not using hardware,
				should provide a benefit over software.
	@discussion Hardware can be used in any case, however, this function recommends whether or not using
	            it is beneficial on the runtime platform.  Set rawSurface to true to indicate that this
	            is for the IOSurface API with no kFigJPEGOutputPixelFormat.  If you are setting a custom
	            kFigJPEGOutputPixelFormat, or using the CG API's, rawSurface should be false.  Options
	            should consist of what you would be passing to the appropriate decoder call.
*/
extern bool FigAspenShouldUseHardwareDecode(CGSize dims, bool rawSurface, CFDictionaryRef options);

/*!
	@function   FigAspenGetJPEGDecodeTiming
	@abstract   Returns a pointer to the internal buffer used to capture timing statistics, or NULL if
	            no such buffer is available.
	@discussion There is only 1 such buffer, and it is static. No attempt at thread-safety is made.
 */
extern FigAspenJPEGDecodeTiming_t *FigAspenGetJPEGDecodeTiming (void);

/*!
	 @function   FigAspenDecodeJPEGIntoRGBSurface
	 @abstract   Decodes JPEG into a client provided BGRA/RGBA surface.
	 @discussion Clients should use FigAspenCalculateOutputDimensionsForJPEG() to obtain final surface dimensions.
 */
extern OSStatus FigAspenDecodeJPEGIntoRGBSurface(CFDataRef data, CFDictionaryRef options, IOSurfaceRef finalSurface);

/*!
	 @function   FigAspenCalculateOutputDimensionsForJPEG
	 @abstract   Calculates the output image dimensions from the input image dimensions and decode options.
 */
extern void FigAspenCalculateOutputDimensionsForJPEG(size_t jpegWidth, size_t jpegHeight, CFDictionaryRef options, int orient, size_t *outputWidthOut, size_t *outputHeightOut);

/*!
	 @function   FigAspenCreateJPEGNativeDecodePixelFormatArray
	 @abstract   Returns the formats that are natively supported by the JPEG decoder, for use with the kFigJPEGOutputPixelFormat option to FigCreateCGImageFromJPEG() or FigCreateIOSurfaceFromJPEG().
 */
extern CFArrayRef FigAspenCreateJPEGNativeDecodePixelFormatArray(void);


#pragma pack(pop)
	
#if defined(__cplusplus)
}
#endif

#endif // _FIG_ASPEN_JPEG_DECODER_PRIVATE_H_
