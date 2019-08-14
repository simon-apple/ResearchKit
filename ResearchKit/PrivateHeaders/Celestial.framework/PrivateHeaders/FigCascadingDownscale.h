/*
	File:		FigCascadingDownscale.h

	Description: Cascading downscaler.
 
	Author:		Brandon Corey
 
	Copyright: 	(c) Copyright 2013 Apple Inc. All rights reserved.
*/

#ifndef _FIG_CASCADE_H_
#define _FIG_CASCADE_H_

#include <CoreMedia/CMFormatDescription.h>
#include <IOSurface/IOSurface.h>

typedef struct _FigCascadeContext *FigCascadeContext;

enum {
    kDestCropMode_AspectFit = 1,
    kDestCropMode_AspectFill = 2,
};

/*!
	@function   FigCascadingDownscaleCreate
	@abstract   Creates a context for a cascading downscaler.
	@discussion Creating a context is optional.  Any of the parameters passed will pre-load intermediate
	            buffers that will be required for the operations.  If the buffer parameters passed to
	            FigCascadingDownscale() later are different, they will be re-created then.

	Returns a context that can be used with FigCascadingDownscale().
*/
extern FigCascadeContext FigCascadingDownscaleCreate(
	CMVideoDimensions sourceSize,    /*! @param Dimensions of source if known. Can be 0x0 if unknown. */
	OSType sourcePixelFormat,        /*! @param PixelFormat of source if known. Pass 0 if unknown. */
	CMVideoDimensions *destSizeArray,/*! @param Array of destination sizes if known. Pass NULL if unknown. */
	int *destCropModeArray,          /*! @param Array of destination crop modes. Pass NULL if unknown. */
	int destCount,                   /*! @param Entries in desintation size array. Can be 0. */
	OSType destPixelFormat);         /*! @param PixelFormat of desintation if known. Pass 0 if unknown. */

/*!
	@function   FigCascadingDownscaleDestroy
	@abstract   Destroys a context for a cascading downscaler.
	@discussion Optional sourceSize, sourcePixelFormat, destPixelFormat and destSize hints (if you know them).
 
	Returns a context that can be used with FigCascadingDownscale().
*/
extern void FigCascadingDownscaleDestroy(
	FigCascadeContext ctx);         /*! @param Context created with FigCascadingDownscaleCreate(). */

/*!
	@function   FigCascadingDownscale
	@abstract   Creates a cascaded downscale of various sizes from an IOSurface source image.
	@discussion Takes the input surface and downscales into destCount output blocks of memory pointed
	            to via destData[], each being the respective destSize[], using the respective destCropMode[]
	            and the specified destPixelFormat.  If the context is passed, the scaler connections and
	            buffers will be re-used if possible.  The context may be updated by the function.

	            Note: Is *not* thread safe if the same context is used from both threads.
 
	Returns noErr if successful, or an error on failure.
*/
extern OSStatus FigCascadingDownscale(
	FigCascadeContext ctx,           /*! @param Context created with FigCascadingDownscaleCreate(). */
	IOSurfaceRef sourceSurface,      /*! @param Source surface. */
	OSType destPixelFormat,          /*! @param Destination pixel format. */
	int destBytesPerRowAlignment,    /*! @param Destination bytes per row alignment multiple. */
	CMVideoDimensions *destSizeArray,/*! @param Array of destination sizes. */
	uint8_t **destDataArray,         /*! @param Array of destination buffers. */
	int *destCropModeArray,          /*! @param Array of destination crop modes. */
	int destCount);                  /*! @param Entries in desintation size, data, and cropMode arrays. */

#endif /* _FIG_CASCADE_H_ */
