/*
	File:		FigAspenJPEGEncoderPrivate.h
	
	Description: Private interface to JPEG encoder for Aspen devices.

	Author:		Jonathan Coxhead

	Copyright: 	© Copyright 2011-2016 Apple Inc. All rights reserved.
	
	$Id: $
	$Log$
	31may2016 linus_nilsson
	[26567924] Add kFigJPEGPhotoQuality_q800n to legacy wrappers <lbarnes>

	26jan2016 jpap
	[23582917] Move FigAspen JPEG to MediaToolbox; leave wrappers in Celestial. <lbarnes, linus_nilsson>
*/

#ifndef _FIG_ASPEN_JPEG_ENCODER_PRIVATE_H_
#define _FIG_ASPEN_JPEG_ENCODER_PRIVATE_H_

#include <CoreMedia/FigDebugPlatform.h>
#include <CoreMedia/FigSampleBuffer.h>
#include <CoreFoundation/CoreFoundation.h>
#include <IOSurface/IOSurface.h>

#if defined(__cplusplus)
extern "C" {
#endif

#pragma pack(push, 4)

typedef struct FigAspenJPEGEncodeTiming {
	uint64_t vtPixelTransferSessionCreateTime;
	uint64_t createYuvfTime;
	uint64_t convertToYuvfTime;
	uint64_t softwareJPEGEncodeTime;
	uint64_t createJPEGOutputSurfaceTime;
	uint64_t JPEGEncodeTime;
	uint64_t bzeroTime;
} FigAspenJPEGEncodeTiming_t;

/*!
	@constant  TestEncodeTiming
	@abstract  Requests timing statistics to be filled into an internal buffer.
	           Available in experimental builds only.
 */
extern const CFStringRef kFigJPEGTestEncodeTiming;		// CFBoolean, default false

/*!
 @constant   kFigJPEGPhotoQuality
 @abstract   Use one of the pre-defined quantization matrices suitable for camera capture
 @discussion Overrides kCGImageDestinationLossyCompressionQuality
 */
extern const CFStringRef kFigJPEGPhotoQuality; // CFNumber, FigJPEGPhotoQuality enum

/*!
 @enum Quality levels suitable for camera capture
 @discussion Used with the kFigJPEGPhotoQuality key
 */
typedef enum {
	kFigJPEGPhotoQuality_q750n    = '750n', // q0.75  Normal
	kFigJPEGPhotoQuality_q800n    = '800n', // q0.80  Normal
	kFigJPEGPhotoQuality_q825s    = '825s', // q0.825 Special
	kFigJPEGPhotoQuality_q850s    = '850s', // q0.85  Special
	kFigJPEGPhotoQuality_q900s    = '900s', // q0.90  Special
	kFigJPEGPhotoQuality_q900n    = '900n', // q0.90  Normal
} FigJPEGPhotoQuality;

/*!
	@constant  CustomLumaQuantTable
	@abstract  Custom luma quantization table.
 */
extern const CFStringRef kFigJPEGCustomLumaQuantTable;	// CFData containing 64 bytes representing the luma quantization matrix

/*!
	@constant  CustomChromaQuantTable
	@abstract  Custom chroma quantization table.
 */
extern const CFStringRef kFigJPEGCustomChromaQuantTable;// CFData containing 64 bytes representing the chroma quantization matrix

/*!
	@constant   kFigJPEGAllowHardwareEvenCrop
	@abstract   Allow hardware to crop images with odd dimensions to even values.
	@discussion Some platforms cannot encode odd width (4:2:2) or odd width and height (4:2:0).  If this option is
	            set to true, the hardware will crop to even dimensions on some platforms.  If this option is set
	            to false, images with odd dimensions will fallback to software encoding on some platforms.
 */
extern const CFStringRef kFigJPEGAllowHardwareEvenCrop; // CFBoolean, default true.

/*!
	@constant   kFigJPEGUse601YCbCrMatrix
	@abstract   When a format conversion is required use a 601 YCbCr matrix for the result of the conversion.
	@discussion The JPEG standard expects that YUV encoded JPEGs use a 601 matrix.
				When performing a format conversion FigAspenJPEGDecoder by default does not specify a YCbCr matrix
				for the intermediate buffer. When kFigJPEGUse601YCbCrMatrix is provided with a value of kCFBooleanTrue
				the intermediate buffer will use a 601 matrix.
 */
extern const CFStringRef kFigJPEGUse601YCbCrMatrix; // CFBoolean, default false.

/*!
	@function   FigAspenGetJPEGEncodeTiming
	@abstract   Returns a pointer to the internal buffer used to capture timing statistics, or NULL if
	            no such buffer is available.
	@discussion There is only 1 such buffer, and it is static. No attempt at thread-safety is made.
 */
extern FigAspenJPEGEncodeTiming_t *FigAspenGetJPEGEncodeTiming (void);

#pragma pack(pop)

#if defined(__cplusplus)
}
#endif

#endif // _FIG_ASPEN_JPEG_ENCODER_PRIVATE_H_
