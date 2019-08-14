/*
	File:		FigAspenJPEGEncoder.h
	
	Description: Interface to JPEG encoder for Aspen devices.

	Author:		Nikhil Bhogal

	Copyright: 	© Copyright 2008-2016 Apple Inc. All rights reserved.
	
	$Id: $
	$Log$
	11mar2016 smorampudi
	<rdar://24940712> Update file encoding to utf-8 <jdecoodt, jsam, kcalhoun, jalliot>

	26jan2016 jpap
	[23582917] Move FigAspen JPEG to MediaToolbox; leave wrappers in Celestial. <lbarnes, linus_nilsson>
*/

#ifndef FIGASPENJPEGENCODER_H
#define FIGASPENJPEGENCODER_H

#include <CoreMedia/FigDebugPlatform.h>
#include <CoreMedia/FigSampleBuffer.h>
#include <CoreFoundation/CoreFoundation.h>
#include <IOSurface/IOSurface.h>
#if defined(__cplusplus)
extern "C"
{
#endif
    
#pragma pack(push, 4)

/*!
	 Applicable option keys (from CGImageSource.h):
	 @constant   kCGImageDestinationLossyCompressionQuality
	 @abstract   Specifies the compression quality of the output image. (e.g. 0.6 = high, 0.85 = higher, 1.0 = highest)
 */

/*!
	 @constant   kFigJPEGSourceCropRect
	 @abstract   Crop the source image during encode.
	 @discussion Specify the crop rect with a CFDictionary created from a CGRect using CGRectCreateDictionaryRepresentation().
	             The crop rect's origin is offset from the upper left corner of the image. Cropping is only supported on H4 and later.
 */
extern const CFStringRef kFigJPEGSourceCropRect;	// CFDictionary from CGRectCreateDictionaryRepresentation(). Defaults to no crop.

/*!
	 @constant   kFigJPEGAppleQuality
	 @abstract   Use new matrix and adjust compression according to metadata.
	 @discussion If sbuf metadata is present, use it for increasing compression for high gain (i e noisy) images and high 
	             texture images. Now, what happens if you give BOTH this as true AND a at the same time supply an explicit
	             kCGImageDestinationLossyCompressionQuality? Well, if kCGImageDestinationLossyCompressionQuality results
	             in the standard matrix then kFigJPEGAppleQuality will be respected; if not, it will be disregarded and
	             kCGImageDestinationLossyCompressionQuality will be respected. (The one way to get the old standard matrix
	             is to explicitly set kFigJPEGAppleQuality to false).
 */
extern const CFStringRef kFigJPEGAppleQuality;		// CFBoolean, default true.

/*!
	 @constant  kFigJPEGSubsampling
	 @abstract  Encoded JPEG chroma subsampling mode
 */
extern const CFStringRef kFigJPEGSubsampling; // CFNumber from {444, 422, 420, 411, 400}, default is 420.

/*!
	@constant  kFigJPEGSoftwareEncode
	@abstract  When true, force software encoding.  When false, force hardware encoding.  If value is not present/passed, use hardware encoding, and if it fails, fallback to software encoding.
 */
extern const CFStringRef kFigJPEGSoftwareEncode; // CFBoolean, default false

/*!
	 @constant   kFigJPEGSoftwareFallback
	 @abstract   Use a software JPEG codec on hardware encode failure.
	 @discussion Fallback to software encode if hardware encode fails, e.g. unsupported chroma subsampling.
 */
extern const CFStringRef kFigJPEGSoftwareFallback; // CFBoolean, default true.

/*!
	 @function   FigAspenCreateJPEGFromSbuf
	 @abstract   Creates a JPEG encoded image from a FigSampleBuffer.
	 @discussion The input to the JPEG encoder must be in a pixel format of 'yuvf', '420f', or a native format
	             returned by FigAspenCreateJPEGNativePixelFormatArray().  If the sbuf passed is in another format,
	             the image will be converted internally.  The caller may pass an optionalIntermediatePixelBuffer
	             to be used for the output of that conversion.  The intermediate buffer must be an IOSurface that
	             matches the dimensions of the input image and the native pixelFormat.  The utility routine
	             FigCreateIOSurfaceBackedCVPixelBuffer() can be used to create an appropriately formatted buffer.

	             The resulting JPEG is stored in outJpegSurface and the data size is returned via outJpegSize.
 */
extern OSStatus FigAspenCreateJPEGFromSbuf(FigSampleBufferRef sbuf, CFDictionaryRef options, CVPixelBufferRef optionalIntermediatePixelBuffer, IOSurfaceRef *outJpegSurface, int *outJpegSize);

/*!
	 @function   FigAspenCreateJPEGFromCVPixelBuffer
	 @abstract   Creates a JPEG encoded image from a CVPixelBufferRef.
	 @discussion The input to the JPEG encoder must be in a pixel format of 'yuvf', '420f', or a native format
	             returned by FigAspenCreateJPEGNativePixelFormatArray().  If the imageBuffer passed is in another
	             pixel format, the image will be converted internally.  The caller may pass an
	             optionalIntermediatePixelBuffer to be used for the output of that conversion.  That intermediate
	             buffer must be a CVPixelBuffer that matches the dimensions of the input image and the native
	             pixel format.  The utility routine FigCreateIOSurfaceBackedCVPixelBuffer() can be used to create
	             an appropriately formatted buffer.

	             The resulting JPEG is stored in outJpegSurface and the data size is returned via outJpegSize.
 */
extern OSStatus FigAspenCreateJPEGFromCVPixelBuffer( CVPixelBufferRef imageBuffer, CFDictionaryRef options, CVPixelBufferRef optionalIntermediatePixelBuffer, IOSurfaceRef *outJpegSurface, int *outJpegSize );

/*!
	 @function   FigAspenCreateJPEGFromIOSurface
	 @abstract   Creates a JPEG encoded image from an IOSurfaceRef.
	 @discussion The input to the JPEG encoder must be data in a native format returned by FigAspenCreateJPEGNativePixelFormatArray().
	             If the surface passed is in another pixel format, the image will be converted internally.

	             The resulting JPEG is stored in outJpegSurface and the data size is returned via outJpegSize.
 */
extern OSStatus FigAspenCreateJPEGFromIOSurface( IOSurfaceRef imageSurface, CFDictionaryRef options, IOSurfaceRef *outJpegSurface, int *outJpegSize );

/*!
	 @function   FigAspenCreateJPEGNativePixelFormatArray
	 @abstract   Returns the formats that are natively supported by the JPEG encoder.
	 @discussion If anything but one of the formats returned in this array are passed to the encoder, an attempt will be made to
	             convert the image internally internally before the encode.
 */
extern CFArrayRef FigAspenCreateJPEGNativePixelFormatArray( void );

/*!
	 @function   FigAspenCreateJPEGNativeSubsamplingArray
	 @abstract   Returns the subsampling options (AppleJPEGSubsampling enum values) that are natively supported by the JPEG encoder.
	 @discussion If anything but one of the subsampling options returned in this array are requested of the encoder, software fallback will be used, where applicable.
 */
extern CFArrayRef FigAspenCreateJPEGNativeSubsamplingArray( void );

#pragma pack(pop)

#if defined(__cplusplus)
}
#endif

#endif // FIGASPENJPEGENCODER_H
