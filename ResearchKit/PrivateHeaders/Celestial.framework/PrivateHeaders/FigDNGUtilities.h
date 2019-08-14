/*
	File:           FigDNGUtilities.h
	Description:    Utilities for reading and writing DNG files
	Author:         Anders Holtsberg
	Copyright:      © Copyright 2014 Apple Inc. All rights reserved.
 */

#ifndef FIGDNGUTIL_H
#define FIGDNGUTIL_H

#include <CoreMedia/CMBasePrivate.h>
#include <CoreFoundation/CoreFoundation.h>
#include <CoreVideo/CVPixelBuffer.h>
#include <ImageIO/ImageIO.h>

#if defined( __cplusplus )
extern "C" {
#endif


#pragma mark - Error codes

// Errors, claimed -16550 to -16559
enum {
	kFigDNGError_Parameters                    = -16550,
	kFigDNGError_NoMemory                      = -16551,
	kFigDNGError_UnsupportedCompressionFormat  = -16552,
	kFigDNGError_DataIsCorrupt                 = -16553,
	kFigDNGError_NotLittleEndian               = -16554,
	kFigDNGError_RequiredInfoMissing           = -16555,
	kFigDNGError_InfoWrongFormat               = -16556,
	kFigDNGError_Internal                      = -16557,
};


#pragma mark - Option keys

/** SIF Raw
    Option to specify if the raw data is comming directly from the sensor.
 */
extern const CFStringRef kFigDNGOptionKey_InternalSensorRaw; // Type: CFBooleanRef

/**
    @constant   kFigDNGOptionKey_AuxiliaryImagePreserveValue
    @abstract   Instructs the encoder to preserve a certain value in the auxiliary image through compression.
		This value is always read by FigDNG as an integer with size matching the auxiliary image's sample size.
		When passing a floating point value the caller is responsible for doing an integer conversion that exactly preserves the
		bits. (Example: int32_t myInt = *((int32_t *)&myFloat); )
 */
extern const CFStringRef kFigDNGOptionKey_AuxiliaryImagePreserveValue; // Type: CFNumberRef


#pragma mark - FigDNGUtilities introspection

/** The version of the DNG specification that FigDNGUtilities is written against.
	This is the DNG version where the input metadata is defined and can be
    used by clients for detailed definitions.
    This is not the same as the DNGBackwardVersion.
 */
extern const CFStringRef kFigDNG_TargetDNGVersion; // Format: "1.4.0.0"


#pragma mark - Exported functions (DNG Writer)

/** Pack RAW data from a CVPixelBuffer into a DNG.
 *
 * @param[in]  imageProperties  Dictionary containing the RAW image properties
 * @param[in]  pixelBuffer      A CVPixelBuffer containing the RAW bayer data
 * @param[in]  jpegPreview      A JPEG encoded preview version of the image
 * @param[in]  options          DNG writer options
 * @param[out] DNGDataOut       The DNG wrapped in a CFData, ownership follows the create rule
 *
 * @return  0 on sucess or a non-zero error code on failure
 *
 * @discussion
 *		The imageProperties dictionary is required to contain:
 *
 *			kCGImagePropertyOrientation // CFNumber (int32)
 *			kCGImagePropertyTIFFDictionary
 *				kCGImagePropertyTIFFMake  // CFString
 *				kCGImagePropertyTIFFModel // CFString
 *				kCGImagePropertyTIFFSoftware // CFString
 *				kCGImagePropertyTIFFDateTime  // CFDate or CFString
 *			kCGImagePropertyDNGDictionary
 *				kCGImagePropertyDNGUniqueCameraModel // CFString
 *				kCGImagePropertyDNGAsShotNeutral // (R,G,B) as a CFArray of 3 CFNumber (float)
 *				kCGImagePropertyDNGCalibrationIlluminant1 // CFNumber (short)
 *				kCGImagePropertyDNGCalibrationIlluminant2 // CFNumber (short)
 *				kCGImagePropertyDNGColorMatrix1 // CFArray of the matrix elements as 9 CFNumber (float) in row-major order
 *				kCGImagePropertyDNGColorMatrix2 // CFArray of the matrix elements as 9 CFNumber (float) in row-major order
 *				kCGImagePropertyDNGBlackLevel // CFNumber (int32)
 *				kCGImagePropertyDNGWhiteLevel // CFNumber (int32)
 *
 *		Alternatively, the orientation can be in the TIFF sub-dictionary as kCGImagePropertyTIFFOrientation.
 */
extern
OSStatus FigDNGCreateDNGFromRAWPixelBuffer(
	CFDictionaryRef imageProperties,
	CVPixelBufferRef pixelBuffer,
	CFDataRef jpegPreview,
	CFDictionaryRef options,
	CFDataRef *DNGDataOut );

/** Pack RAW data and and auxiliary image into a DNG.
 *
 * @param[in]  imageProperties         Dictionary containing the RAW image properties
 * @param[in]  pixelBuffer             The RAW bayer data
 * @param[in]  jpegPreview             A JPEG encoded preview version of the image
 * @param[in]  auxiliaryImage          The auxiliary image
 * @param[in]  auxiliaryImageMetadata  Metadata associated with the auxiliary image
 * @param[in]  auxiliaryImageType      Auxiliary image type, one of ImageIO's kCGImageAuxiliaryDataType* from CGImageProperties.h
 * @param[in]  options                 DNG writer options
 * @param[out] DNGDataOut              The DNG wrapped in a CFData, ownership follows the create rule
 *
 * @return  0 on sucess or a non-zero error code on failure
 *
 * @discussion
 *		See @link FigDNGCreateDNGFromRAWPixelBuffer @/link for requirements on the imageProperties dictionary.
 */
extern
OSStatus FigDNGCreateDNGFromRAWPixelBufferAndAuxiliaryImage(
	CFDictionaryRef imageProperties,
	CVPixelBufferRef pixelBuffer,
	CFDataRef jpegPreview,
	CVPixelBufferRef auxiliaryImage,
	CGImageMetadataRef auxiliaryImageMetadata,
	CFStringRef auxiliaryImageType,
	CFDictionaryRef options,
	CFDataRef *DNGDataOut );

/** Pack compressed RAW data into a DNG.
 *
 * @param[in]  imageProperties    Dictionary containing the RAW image properties
 * @param[in]  compressedData     The compressed RAW data
 * @param[in]  jpegPreview        A JPEG encoded preview version of the image
 * @param[in]  options            DNG writer options
 * @param[out] DNGDataOut         The DNG wrapped in a CFData, ownership follows the create rule
 *
 * @return  0 on sucess or a non-zero error code on failure
 *
 * @discussion
 *		The imageProperties dictionary is required to contain:
 *
 *			kCGImagePropertyOrientation // CFNumber (int32)
 *			kCGImagePropertyTIFFDictionary
 *				kCGImagePropertyTIFFMake  // CFString
 *				kCGImagePropertyTIFFModel // CFString
 *				kCGImagePropertyTIFFSoftware // CFString
 *				kCGImagePropertyTIFFDateTime  // CFDate or CFString
 *			kCGImagePropertyDNGDictionary
 *				kCGImagePropertyDNGUniqueCameraModel // CFString
 *				kCGImagePropertyDNGAsShotNeutral // (R,G,B) as a CFArray of 3 CFNumber (float)
 *				kCGImagePropertyDNGCalibrationIlluminant1 // CFNumber (short)
 *				kCGImagePropertyDNGCalibrationIlluminant2 // CFNumber (short)
 *				kCGImagePropertyDNGColorMatrix1 // CFArray of the matrix elements as 9 CFNumber (float) in row-major order
 *				kCGImagePropertyDNGColorMatrix2 // CFArray of the matrix elements as 9 CFNumber (float) in row-major order
 *				kCGImagePropertyDNGBlackLevel // CFNumber (int32)
 *				kCGImagePropertyDNGWhiteLevel // CFNumber (int32)
 *
 *		Alternatively, the orientation can be in the TIFF sub-dictionary as kCGImagePropertyTIFFOrientation.
 */
extern
OSStatus FigDNGCreateDNGFromCompressedData(
	CFDictionaryRef imageProperties,
	CFDataRef compressedData,
	CFDataRef jpegPreview,
	CFDictionaryRef options,
	CFDataRef *DNGDataOut );

/** Compress RAW data using lossless JPEG
 *
 * @param[in]  pixelBuffer        A CVPixelBuffer containing the RAW bayer data
 * @param[in]  options            Compression options
 * @param[out] compressedDataOut  The compressed RAW data
 *
 * @return  0 on sucess or a non-zero error code on failure
 */
extern
OSStatus FigDNGCreateCompressedDataFromRAWPixelBuffer(
	CVPixelBufferRef pixelBuffer,
	CFDictionaryRef options,
	CFDataRef *compressedDataOut );

/** Translate a color temperature into an EXIF defined LightSource value
 *
 * @param[in] temperature  Color temperature in Kelvin
 *
 * @return  The value of the closest matching EXIF LightSource
 */
extern
short FigDNGGetLightSourceTagFromTemp( float temperature );


#pragma mark - Exported functions (DNG Reader)

/** Unpacks a DNG file to uncompressed RAW data, preview and info dictionary
 *
 * @param[in]  dngData              The DNG file
 * @param[in]  options              Reader options
 * @param[out] imagePropertiesOut   Dictionary containing the RAW image properties
 * @param[out] pixelBufferOut       The uncompressed RAW
 * @param[out] jpegPreviewOut       The embedded preview JPEG
 *
 * @return  0 on sucess or a non-zero error code on failure
 *
 * @discussion
 * 1. The caller takes ownership of the three output parameters according to
 * the create rule.
 *
 * 2. This function should not be used as a general purpose DNG reader. It is only
 * garantueed to read DNG files that were created with FigDNGCreateDNGFrom*
 */
extern
OSStatus FigDNGCreateUncompressedRAWFromDNG(
	CFDataRef dngData,
	CFDictionaryRef options,
	CFDictionaryRef *imagePropertiesOut,
	CVPixelBufferRef *pixelBufferOut,
	CFDataRef *jpegPreviewOut );

	
/** Behaves like FigDNGCreateUncompressedRAWFromDNG but also
 *  decodes an auxiliary image if present.
 */
extern
OSStatus FigDNGUnpack(
	CFDataRef dngData,
	CFDictionaryRef options,
	CFDictionaryRef *imagePropertiesOut,
	CVPixelBufferRef *pixelBufferOut,
	CFDataRef *jpegPreviewOut,
	CVPixelBufferRef *auxiliaryImageOut,
	CGImageMetadataRef *auxiliaryImageMetadataOut,
	CFStringRef *auxiliaryImageTypeOut );

#if defined( __cplusplus )
}
#endif

#endif // FIGDNGUTIL_H
