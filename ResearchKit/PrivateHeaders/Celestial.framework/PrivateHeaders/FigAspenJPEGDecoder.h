/*
	File:		FigAspenJPEGDecoder.h

	Description: Interface to JPEG decoder for Aspen devices.

	Author:		Brandon Corey

	Copyright: 	Copyright 2009-2016 Apple Inc. All rights reserved.

	$Id: $
	$Log$
	26jan2016 jpap
	[23582917] Move FigAspen JPEG to MediaToolbox; leave wrappers in Celestial. <lbarnes, linus_nilsson>
*/

#ifndef _FIG_ASPEN_JPEG_DECODER_H_
#define _FIG_ASPEN_JPEG_DECODER_H_

#include <CoreFoundation/CoreFoundation.h>
#include <IOSurface/IOSurface.h>
#include <ImageIO/CGImageProperties.h>
#include <CoreGraphics/CGImage.h>

#if defined(__cplusplus)
extern "C"
{
#endif
    
#pragma pack(push, 4)

/*!
	 @constant  kFigJPEGBackCGImageWithIOSurface
	 @abstract  Back CGImages with IOSurface buffers.
	 @discussion
	 When generating a CGImage, this optionally backs it with an IOSurface as opposed
	 to malloced memory.  This saves a buffer copy, but IOSurface memory is now
	 retained over the life of the CGImage.
 */
extern const CFStringRef kFigJPEGBackCGImageWithIOSurface;	// CFNumber, default false

/*!
	 @constant  kFigJPEGCacheInputSurface
	 @abstract  Cache input surfaces.
	 @discussion
	 Cache input surfaces between calls, which decodes faster, but retains extra
	 memory for the lifetime of the process.
 */
extern const CFStringRef kFigJPEGCacheInputSurface;	// CFNumber, default false

/*!
	 @constant  kFigJPEGHighSpeedDecode
	 @abstract  Enable high speed decoding.
	 @discussion
	 Decode images as fast as possible.  Note that this has power implications.
 */
extern const CFStringRef kFigJPEGHighSpeedDecode;	// CFNumber, default false

/*!
	 @constant	kFigJPEGColorSpaceAware
	 @abstract	Specifies if the decoder should make use of encountered ICC profiles.
	 @discussion
	 When true the decoder will extract any found ICC profile, create a CGColorSpace
	 from it and attach it to the output surface. This may decrease performance.
 */
extern const CFStringRef kFigJPEGColorSpaceAware; // CFBoolean, default true
	
/*!
	 Other applicable keys (from CGImageSource.h):
	 @constant  kCGImageSourceThumbnailMaxPixelSize
	 @abstract  Specifies the maximum width and height in pixels of the output image.
 */

/*!
	 @constant  kFigJPEGRelaxMaxPixelSize
	 @abstract  Relax requirements for post processing scale.
	 @discussion
	 If kCGImageSourceThumbnailMaxPixelSize is specified, setting this can avoid a post
	 processing scale operation, if the output image is within a reasonable tolerance.
*/
extern const CFStringRef kFigJPEGRelaxMaxPixelSize;	// CFBoolean, default false

/*!
	 @function   FigCreateCGImageFromJPEG
	 @abstract   Decodes a JPEG into a CGImage.
 */
extern OSStatus FigCreateCGImageFromJPEG( CFDataRef jpegdata, CFDictionaryRef options, CGImageRef *outputImage );

/*!
	 @function   FigCreateIOSurfaceFromJPEG
	 @abstract   Decodes a JPEG into an IOSurface.
 */
extern OSStatus FigCreateIOSurfaceFromJPEG( CFDataRef jpegdata, CFDictionaryRef options, IOSurfaceRef *outputSurface );

/*!
	 @function   FigCreateCGImageFromIOSurface
	 @abstract   Creates CGImage from IOSurface.
	@discussion
	If IOSurface is not BGRA it will be converted to BGRA. If backWithSurface is false the backing buffer is 
	allocated using CGBitmapAllocateData and memcpy'd into, else the passed in or converted IOSurface is used.
 */
extern OSStatus FigCreateCGImageFromIOSurface( IOSurfaceRef surface, Boolean backWithSurface, CGImageRef *outputImage );

#pragma pack(pop)
	
#if defined(__cplusplus)
}
#endif

#endif // _FIG_ASPEN_JPEG_DECODER_H_
