/*
    FaceDetector.h

    Entry points for the face detection algorithms.

    Copyright Apple, Inc. 2009. All rights reserved.

    $Log$
	08dec2009 jim
	Merged changes from iPhone-Wildcat to trunk.

		04dec2009 rbrunner
		Add IOSurface based SPI for face detection <fdoepke>
	
		019nov2009 rbrunner
		Make detector build on PhoneOS and MacOS X <fdoepke>
	
    20oct2009 rbrunner
    File created <bcorey, narianischulze>
*/

#ifndef FACEDETECTOR_H
#define FACEDETECTOR_H

#include <math.h>
#include <stdlib.h>
#include <TargetConditionals.h>

#if TARGET_OS_IPHONE
#  include <CoreGraphics/CoreGraphics.h>
#  include <IOSurface/IOSurface.h>
#else
#  include <ApplicationServices/ApplicationServices.h>
#endif


#ifdef __cplusplus
extern "C" {
#endif

OSStatus FigDetectFacesInCGImage(CGImageRef sourceImage, size_t ccwOrientation,
    CGRect *faces, size_t *faceCount, size_t maxFaceCount);

#if TARGET_OS_IPHONE
OSStatus FigDetectFacesInIOSurface(IOSurfaceRef sourceSurface, size_t ccwOrientation,
    CGRect *faces, size_t *faceCount, size_t maxFaceCount);
#endif

#ifdef __cplusplus
}
#endif

#endif // FACEDETECTOR_H
