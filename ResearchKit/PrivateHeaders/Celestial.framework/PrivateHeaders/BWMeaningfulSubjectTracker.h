/*
 File:				BWMeaningfulSubjectTracker.h
 Description: 		Component which integrates face/object detection and tracking of "meaningful" subjects
 Author:			Elliott Harris
 Creation Date:		2/13/19
 Copyright: 		© Copyright 2019 - Apple, Inc. All rights reserved.
*/

#import <Foundation/Foundation.h>
#import <CoreMedia/CMSampleBuffer.h>

@interface BWMeaningfulSubjectTracker : NSObject

#pragma mark Processing

/*!
 @method prepare
 @abstract Allocates the required resources for subject tracking
 @discussion Must be called before sample buffers can be processed by -processSampleBuffer:
 
 @param inputPixelBufferAttributes The pixel buffer attributes of pixel buffers the tracker will process
*/
- (void)prepareWithInputPixelBufferAttributes:(NSDictionary *)inputPixelBufferAttributes;

/*!
 @method newInputPixelBufferFromSampleBuffer
 @abstract Allocates and returns a new tracker input from the given sample buffer
 @discussion The pixel buffer returned from this method must be released by the caller
 
 @param sampleBuffer The sample buffer which provides input to the tracker
 
 @return A pixel buffer with a format type of kCVPixelFormatType_32BGRA, suitable for input to processPixelBuffer:
*/
- (CVPixelBufferRef)newInputPixelBufferFromSampleBuffer:(CMSampleBufferRef)sampleBuffer;

/*!
 @method processPixelBuffer:
 @abstract Identifies meaningful subjects present in inputPixelBuffer
 @discussion The tracker must be prepared before it can process pixel buffers.
 
 @param inputPixelBuffer A pixel buffer in which to track subjects; must have a format type of kCVPixelFormatType_32BGRA
 
 @return A dictionary containing replacement metadata for kFigCaptureStreamMetadata_DetectedFacesArray and kFigCaptureStreamMetadata_DetectedObjectsInfo
*/
- (NSDictionary *)processPixelBuffer:(CVPixelBufferRef)inputPixelBuffer;

/*!
 @method terminate
 @abstract Terminates tracking for all meaningful subjects
 @discussion Since tracking is inherently stateful, you can call terminate to flush the tracker of all subjects
*/
- (void)terminate;

@end
