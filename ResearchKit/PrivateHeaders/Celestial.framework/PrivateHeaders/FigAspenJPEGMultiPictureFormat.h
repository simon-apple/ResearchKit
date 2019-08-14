/*
	File:		FigAspenJPEGMultiPictureFormat.h

	Description: JPEG Multi Picture Format

	Author:		Brandon Corey

	Copyright: 	© Copyright 2010-2016 Apple Inc. All rights reserved.

	To do:

	$Id: $
	$Log$
	11mar2016 smorampudi
	<rdar://24940712> Update file encoding to utf-8 <jdecoodt, jsam, kcalhoun, jalliot>

	26jan2016 jpap
	[23582917] Move FigAspen JPEG to MediaToolbox; leave wrappers in Celestial. <lbarnes, linus_nilsson>
*/

#ifndef _FIGASPENJPEGUTILITIES_H_
#define _FIGASPENJPEGUTILITIES_H_

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
	 @function   FigAspenAddMPDataToJPEG
	 @abstract   Makes an MPF JPEG with an existing JPEG and extra surfaces.
	 @discussion The subImages may contain JPEG, 420v, or 420f data.

	             The resulting JPEG is stored in the JpegSurface and the data size is returned via outJpegSize.
 */
extern OSStatus FigAspenAddMPDataToJPEG(
	IOSurfaceRef inJPEGSource, size_t inJPEGSourceSize,
	IOSurfaceRef *mpSubImageSurfaces, size_t *mpSubImageSizes, int mpSubImageCount,
	IOSurfaceRef *outJpegSurface, size_t *outJpegSize );

/*!
	 @function   FigAspenCopyMPDataFromJPEG
	 @abstract   Extracts subImages from MPF JPEG's.
	 @discussion The subImages may contain JPEG, 420v, or 420f data.

	             The resulting subImage is stored in outSurface.
 */
extern OSStatus FigAspenCopyMPDataFromJPEG(
	IOSurfaceRef inJPEGSource,
	size_t inJPEGSourceSize,
	int mpIndex,
	IOSurfaceRef *outSurface,
	size_t *outSize );

/*!
	 @function   FigAspenCopyMPDataFromJPEG
	 @abstract   Returns number of images contained in an MPF JPEG's.
 */
extern OSStatus FigAspenGetMPDataCountFromJPEG(
	IOSurfaceRef inJPEGSource,
	size_t inJPEGSourceSize,
	int *mpCount );

#pragma pack(pop)

#if defined(__cplusplus)
}
#endif

#endif // _FIGASPENJPEGUTILITIES_H_
