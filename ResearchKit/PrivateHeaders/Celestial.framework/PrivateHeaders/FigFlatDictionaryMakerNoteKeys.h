/*
	File:			FigFlatDictionaryMakerNoteKeys.h
	Description: 	Predefined keys/keyspace for still and video MakerNote keys
	Author:			Ben Olson
	Creation Date:	04/20/14
	Copyright: 		© Copyright 2013-2019 Apple, Inc. All rights reserved.
*/

#ifndef FIGFLATDICTIONARY_MAKERNOTEKEYS_H
#define FIGFLATDICTIONARY_MAKERNOTEKEYS_H

#include <CoreMedia/FigFlatDictionaryKey.h>

/*!
 @constant kFigCaptureFlatDictionaryAppleMakerNote_Version
 @abstract
 @discussion
		Value is stored as a kFigFlatDictionaryValueType_Int32
 */
extern FigFlatDictionaryKey *const kFigCaptureFlatDictionaryAppleMakerNote_Version;

/*!
 @constant kFigCaptureFlatDictionaryAppleMakerNote_AEMatrix
 @abstract
 @discussion
		Value is stored as a kFigFlatDictionaryValueType_Data
 */
extern FigFlatDictionaryKey *const kFigCaptureFlatDictionaryAppleMakerNote_AEMatrix;

/*!
 @constant kFigCaptureFlatDictionaryAppleMakerNote_Timestamp
 @abstract
 @discussion
		Value is stored as a kFigFlatDictionaryValueType_CMTime
 */
extern FigFlatDictionaryKey *const kFigCaptureFlatDictionaryAppleMakerNote_Timestamp;

/*!
 @constant kFigCaptureFlatDictionaryAppleMakerNote_AEStable
 @abstract
 @discussion
		Value is stored as a kFigFlatDictionaryValueType_Int32
 */
extern FigFlatDictionaryKey *const kFigCaptureFlatDictionaryAppleMakerNote_AEStable;

/*!
 @constant kFigCaptureFlatDictionaryAppleMakerNote_AETarget
 @abstract
 @discussion
		Value is stored as a kFigFlatDictionaryValueType_Int32
 */
extern FigFlatDictionaryKey *const kFigCaptureFlatDictionaryAppleMakerNote_AETarget;

/*!
 @constant kFigCaptureFlatDictionaryAppleMakerNote_AEAverage
 @abstract
 @discussion
		Value is stored as a kFigFlatDictionaryValueType_Int32
 */
extern FigFlatDictionaryKey *const kFigCaptureFlatDictionaryAppleMakerNote_AEAverage;

/*!
 @constant kFigCaptureFlatDictionaryAppleMakerNote_AFStable
 @abstract
 @discussion
		Value is stored as a kFigFlatDictionaryValueType_Int32
 */
extern FigFlatDictionaryKey *const kFigCaptureFlatDictionaryAppleMakerNote_AFStable;

/*!
 @constant kFigCaptureFlatDictionaryAppleMakerNote_FocusAccelerometerVector
 @abstract
 @discussion
		Value is stored as a kFigFlatDictionaryValueType_ArrayData (array of 3 floats)
 */
extern FigFlatDictionaryKey *const kFigCaptureFlatDictionaryAppleMakerNote_FocusAccelerometerVector;

/*!
 @constant kFigCaptureFlatDictionaryAppleMakerNote_SISMethod
 @abstract
 @discussion
		Value is stored as a kFigFlatDictionaryValueType_Int32
 */
extern FigFlatDictionaryKey *const kFigCaptureFlatDictionaryAppleMakerNote_SISMethod;

/*!
 @constant kFigCaptureFlatDictionaryAppleMakerNote_HDRMethod
 @abstract
 @discussion
		Value is stored as a kFigFlatDictionaryValueType_Int16
 */
extern FigFlatDictionaryKey *const kFigCaptureFlatDictionaryAppleMakerNote_HDRMethod;

/*!
 @constant kFigCaptureFlatDictionaryAppleMakerNote_BurstUUID
 @abstract
 @discussion
 Value is stored as a kFigFlatDictionaryValueType_String
 */
extern FigFlatDictionaryKey *const kFigCaptureFlatDictionaryAppleMakerNote_BurstUUID;

/*!
 @constant kFigCaptureFlatDictionaryAppleMakerNote_SphereHealthTrackingError
 @abstract
 @discussion
		Value is stored as a kFigFlatDictionaryValueType_ArrayData (array of 2 floats)
 */
extern FigFlatDictionaryKey *const kFigCaptureFlatDictionaryAppleMakerNote_SphereHealthTrackingError;

/*!
 @constant kFigCaptureFlatDictionaryAppleMakerNote_SphereHealthAverageCurrent
 @abstract
 @discussion
		Value is stored as a kFigFlatDictionaryValueType_Int16
 */
extern FigFlatDictionaryKey *const kFigCaptureFlatDictionaryAppleMakerNote_SphereHealthAverageCurrent;

/*!
 @constant kFigCaptureFlatDictionaryAppleMakerNote_SphereMotionDataStatus
 @abstract
 @discussion
		Value is stored as a kFigFlatDictionaryValueType_Int32
 */
extern FigFlatDictionaryKey *const kFigCaptureFlatDictionaryAppleMakerNote_SphereMotionDataStatus;

/*!
 @constant kFigCaptureFlatDictionaryAppleMakerNote_OISMode
 @abstract
 @discussion
		Value is stored as a kFigFlatDictionaryValueType_Int32
 */
extern FigFlatDictionaryKey *const kFigCaptureFlatDictionaryAppleMakerNote_OISMode;

/*!
 @constant kFigCaptureFlatDictionaryAppleMakerNote_SphereStatus
 @abstract
 @discussion
		Value is stored as a kFigFlatDictionaryValueType_Int32
 */
extern FigFlatDictionaryKey *const kFigCaptureFlatDictionaryAppleMakerNote_SphereStatus;

/*!
 @constant kFigCaptureFlatDictionaryAppleMakerNote_AssetIdentifier
 @abstract
 @discussion
 Value is stored as a kFigFlatDictionaryValueType_String
 */
extern FigFlatDictionaryKey *const kFigCaptureFlatDictionaryAppleMakerNote_AssetIdentifier;

/*!
 @constant kFigCaptureFlatDictionaryAppleMakerNote_QRMOutputType
 @abstract
 @discussion
		Value is stored as a kFigFlatDictionaryValueType_Int32
 */
extern FigFlatDictionaryKey *const kFigCaptureFlatDictionaryAppleMakerNote_QRMOutputType;

/*!
 @constant kFigCaptureFlatDictionaryAppleMakerNote_SphereExternalForceOffset
 @abstract
 @discussion
 Value is stored as a kFigFlatDictionaryValueType_ArrayData (array of 2 floats)
 */
extern FigFlatDictionaryKey *const kFigCaptureFlatDictionaryAppleMakerNote_SphereExternalForceOffset;

/*!
 @constant kFigCaptureFlatDictionaryAppleMakerNote_StillImageCaptureType
 @abstract
 @discussion
 Value is stored as a kFigFlatDictionaryValueType_Int32
 */
extern FigFlatDictionaryKey *const kFigCaptureFlatDictionaryAppleMakerNote_StillImageCaptureType;

/*!
 @constant kFigCaptureFlatDictionaryAppleMakerNote_ImageGroupIdentifier
 @abstract
 @discussion
 Value is stored as a kFigFlatDictionaryValueType_String
 */
extern FigFlatDictionaryKey *const kFigCaptureFlatDictionaryAppleMakerNote_ImageGroupIdentifier;

/*!
 @constant kFigCaptureFlatDictionaryAppleMakerNote_PhotosOriginatingSignature
 @abstract
 @discussion
 Value is stored as a kFigFlatDictionaryValueType_String
 */
extern FigFlatDictionaryKey *const kFigCaptureFlatDictionaryAppleMakerNote_PhotosOriginatingSignature;

/*!
 @constant kFigCaptureFlatDictionaryAppleMakerNote_StillImageCaptureFlags
 @abstract
 @discussion
 Value is stored as a kFigFlatDictionaryValueType_Int64
 */
extern FigFlatDictionaryKey *const kFigCaptureFlatDictionaryAppleMakerNote_StillImageCaptureFlags;

/*!
 @constant kFigCaptureFlatDictionaryAppleMakerNote_PhotosRenderOriginatingSignature
 @abstract
 @discussion
 Value is stored as a kFigFlatDictionaryValueType_String
 */
extern FigFlatDictionaryKey *const kFigCaptureFlatDictionaryAppleMakerNote_PhotosRenderOriginatingSignature;

/*!
 @constant kFigCaptureFlatDictionaryAppleMakerNote_StillImageProcessingFlags
 @abstract
 @discussion
 Value is stored as a kFigFlatDictionaryValueType_Int32
 */
extern FigFlatDictionaryKey *const kFigCaptureFlatDictionaryAppleMakerNote_StillImageProcessingFlags;

/*!
 @constant kFigCaptureFlatDictionaryAppleMakerNote_PhotoTranscodeQualityHint
 @abstract
 @discussion
 Value is stored as a kFigFlatDictionaryValueType_String
 */
extern FigFlatDictionaryKey *const kFigCaptureFlatDictionaryAppleMakerNote_PhotoTranscodeQualityHint;

/*!
 @constant kFigCaptureFlatDictionaryAppleMakerNote_PhotosRenderEffect
 @abstract
 @discussion
 Value is stored as a kFigFlatDictionaryValueType_Int32
 */
extern FigFlatDictionaryKey *const kFigCaptureFlatDictionaryAppleMakerNote_PhotosRenderEffect;

/*!
 @constant kFigCaptureFlatDictionaryAppleMakerNote_BracketedCaptureSequenceNumber
 @abstract
 @discussion
 Value is stored as a kFigFlatDictionaryValueType_Int32
 */
extern FigFlatDictionaryKey *const kFigCaptureFlatDictionaryAppleMakerNote_BracketedCaptureSequenceNumber;

/*!
 @constant kFigCaptureFlatDictionaryAppleMakerNote_LuminanceNoiseAmplitude
 @abstract
 @discussion
 Value is stored as a kFigFlatDictionaryValueType_Float32
 */
extern FigFlatDictionaryKey *const kFigCaptureFlatDictionaryAppleMakerNote_LuminanceNoiseAmplitude;

/*!
 @constant kFigCaptureFlatDictionaryAppleMakerNote_OriginatingAppID
 @abstract
 @discussion
 Value is stored as a kFigFlatDictionaryValueType_Int32
 */
extern FigFlatDictionaryKey *const kFigCaptureFlatDictionaryAppleMakerNote_OriginatingAppID;

/*!
 @constant kFigCaptureFlatDictionaryAppleMakerNote_PhotosAppFeatureFlags
 @abstract
 @discussion
 Value is stored as a kFigFlatDictionaryValueType_Int32
 */
extern FigFlatDictionaryKey *const kFigCaptureFlatDictionaryAppleMakerNote_PhotosAppFeatureFlags;

/*!
 @constant kFigCaptureFlatDictionaryAppleMakerNote_ImageCaptureRequestIdentifier
 @abstract
 @discussion
 Value is stored as a kFigFlatDictionaryValueType_String
 */
extern FigFlatDictionaryKey *const kFigCaptureFlatDictionaryAppleMakerNote_ImageCaptureRequestIdentifier;

/*!
 @constant kFigCaptureFlatDictionaryAppleMakerNote_MeteorHeadroom
 @discussion
 Value is stored as a kFigFlatDictionaryValueType_Float32
 */
extern FigFlatDictionaryKey *const kFigCaptureFlatDictionaryAppleMakerNote_MeteorHeadroom;

/*!
 @constant kFigCaptureFlatDictionaryAppleMakerNote_ARKitPhoto
 @discussion
 Value is stored as a kFigFlatDictionaryValueType_Bool
 */
extern FigFlatDictionaryKey *const kFigCaptureFlatDictionaryAppleMakerNote_ARKitPhoto;

/*!
 @constant kFigCaptureFlatDictionaryAppleMakerNote_AFPerformance
 @discussion
 Value is stored as a kFigFlatDictionaryValueType_ArrayData (array of 2 Int32)
 */
extern FigFlatDictionaryKey *const kFigCaptureFlatDictionaryAppleMakerNote_AFPerformance;

/*!
 @constant kFigCaptureFlatDictionaryAppleMakerNote_AFExternalOffset
 @discussion
 Value is stored as a kFigFlatDictionaryValueType_ArrayData (array of 3 float)
 */
extern FigFlatDictionaryKey *const kFigCaptureFlatDictionaryAppleMakerNote_AFExternalOffset;

/*!
 @constant kFigCaptureFlatDictionaryAppleMakerNote_StillImageSceneFlags
 @discussion
 Value is stored as a kFigFlatDictionaryValueType_Int64
 */
extern FigFlatDictionaryKey *const kFigCaptureFlatDictionaryAppleMakerNote_StillImageSceneFlags;

/*!
 @constant kFigCaptureFlatDictionaryAppleMakerNote_StillImageSNRType
 @discussion
 Value is stored as a kFigFlatDictionaryValueType_Int32
 */
extern FigFlatDictionaryKey *const kFigCaptureFlatDictionaryAppleMakerNote_StillImageSNRType;

/*!
 @constant kFigCaptureFlatDictionaryAppleMakerNote_StillImageSNR
 @discussion
 Value is stored as a kFigFlatDictionaryValueType_Float32
 */
extern FigFlatDictionaryKey *const kFigCaptureFlatDictionaryAppleMakerNote_StillImageSNR;

/*!
 @constant kFigCaptureFlatDictionaryAppleMakerNote_UBMethod
 @discussion
 Value is stored as a kFigFlatDictionaryValueType_Int32
 */
extern FigFlatDictionaryKey *const kFigCaptureFlatDictionaryAppleMakerNote_UBMethod;

#if FIG_CAPTURE_THE_MOMENT_SUPPORTED
/*!
 @constant kFigCaptureFlatDictionaryAppleMakerNote_SpatialOverCaptureGroupIdentifier
 @discussion
 Value is stored as a kFigFlatDictionaryValueType_String
 */
extern FigFlatDictionaryKey *const kFigCaptureFlatDictionaryAppleMakerNote_SpatialOverCaptureGroupIdentifier;
#endif // FIG_CAPTURE_THE_MOMENT_SUPPORTED

/*!
 @constant kFigCaptureFlatDictionaryAppleMakerNote_iCloudServerSoftwareVersionForDynamicallyGeneratedMedia
 @discussion
 Value is stored as a kFigFlatDictionaryValueType_String
 */
extern FigFlatDictionaryKey *const kFigCaptureFlatDictionaryAppleMakerNote_iCloudServerSoftwareVersionForDynamicallyGeneratedMedia;

/*!
 @constant kFigCaptureFlatDictionaryAppleMakerNote_PhotoIdentifier
 @discussion
 Value is stored as a kFigFlatDictionaryValueType_String
 */
extern FigFlatDictionaryKey *const kFigCaptureFlatDictionaryAppleMakerNote_PhotoIdentifier;

// Must be called prior to using any predefined keys
CM_EXPORT FigFlatDictionaryKeySpace FigFlatDictionaryGetMakerNoteKeySpace( void );


#endif // FIGFLATDICTIONARY_MAKERNOTEKEYS_H
