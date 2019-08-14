/*
    NoiseReduction.h

    Functions defining an abstract noise reduction interface for YCbCr buffers.

    Copyright Apple, Inc. 2013. All rights reserved.
*/

#ifndef NOISEREDUCTION_H
#define NOISEREDUCTION_H

#include <MediaToolbox/FigSampleBufferProcessor.h>

#ifdef __cplusplus
extern "C" {
#endif

// Opaque type for the generic NoiseReduction context
typedef struct NoiseReductionCtx_s *NoiseReductionCtx;

// Opaque type for algorithm-specific private context - used in the implementations' publc interface
typedef struct NoiseReductionAlgoCtx_s *NoiseReductionAlgoCtx;

extern const CFStringRef kChromaNoiseReductionTuningParameters;
// CFDictionary containing the tuning parameters read from Camera Setup.plist

    extern const CFStringRef kChromaNoiseReductionTuningParameters_Slope;
    // CFNumber IntType
    // Slope tuning parameter.

    extern const CFStringRef kChromaNoiseReductionTuningParameters_Bias;
    // CFNumber IntType
    // Bias tuning parameter.

    extern const CFStringRef kChromaNoiseReductionTuningParameters_SISFusionStrengthFactor;
    // CFNumber Float32Type
    // SISFusionStrengthFactor tuning parameter.

extern const CFStringRef kChromaNoiseReductionClientSpecifiedMetadata;
// client specified metadata CFDictionary.

extern const CFStringRef kChromaNoiseReductionCropRect;
// CGRect-compatible CFDictionary.

extern const CFStringRef kNoiseReductionSynchronization;
// CFNumber IntType
// noiseReduction(), noiseReductionWithTuningOptions(), noiseReductionInOutWithTuningOptions()
// have different default synchronization behaviors, depending on the algorithm used (check sources
// for exact details). The behavior can be changed by using one of these options:
//
// kNoiseReductionSynchronous : Fully synchronous behavior.
//
// kNoiseReductionAsynchronous : Processing may continue in the background when the call
//   returns.  Any remaining work will be completed at hardware access points or when calling
//   CVPixelBufferLockBaseAddress() on the pixelBuffer associated with the input sampleBuffer.
//   This is true even if the pixelBuffer is to be handed off to another h/w unit.  This form of
//   synchronization does not support chaining between h/w units.
//
//   Note: The caller must be sure that the input pixel buffer is not released or modified before
//   processing finishes, since the algorithm may operate directly on the input IOSurface. If the
//   pixelbuffer is released, the backing IOSurface may be assigned to a new pixelbuffer on another
//   thread.

enum {
    kNoiseReductionSynchronous  = 0,
    kNoiseReductionAsynchronous = 1,
};
typedef int NoiseReductionSynchronization;

enum {
    NRCtxGPUPriority_Low    = 0,
    NRCtxGPUPriority_Normal = 1
};
typedef int NRCtxGPUPriority;

enum {
    NRCtxCreateSynchronization_Synchronous              = 0,
    NRCtxCreateSynchronization_Asynchronous_GCD_High    = 1,
    NRCtxCreateSynchronization_Asynchronous_GCD_Default = 2,
    NRCtxCreateSynchronization_Asynchronous_GCD_Low     = 3,
};
typedef int NRCtxCreateSynchronization;

typedef enum {
    PassThroughAlgorithm = 0,
    PowerBlurAlgorithm = 1,
    MultiBandAlgorithm = 2,
    MultiBandAdvancedAlgorithm = 3,
} NoiseReductionAlgorithm;

extern const CFStringRef kTNRFusionAlgorithm;
/*
 CFNumber IntType

     Select the TMBNR fusion algorithm to be used.
     kTNRFusionUniform: all frames are assumed to have equal noise characteristics.
     kTNRFusionLongShort: Last frame is different, and it has better noise characteristics
 */


typedef enum {
    kTNRFusionUniform = 0,
    kTNRFusionLongShort = 1
} TNRFusionAlgorithm;

// Error code return values for noiseReductionGPU()
enum {
    // noErr already defined
    UnspecifiedErr          = -1,
    InitializationFailedErr = -2,
};

/*
**  Header struct for binary output to disk of the input to the
**  noiseReduction() function. Optionally turned on by defaults
**  write enable_bin_output = 1. This header is written to the binary
**  file first, followed by each plane of image data.
**
**  NOTE: This structure shouldn't be exported by the general NoiseReduction API
*/
typedef struct _binOutputHeaderStruct {
    float exposure;
    int gainA;
    int gainS;
    int gainI;
    size_t rowBytes;
    size_t width;
    size_t height;
    size_t yRowBytes;
    size_t yWidth;
    size_t yHeight;
    FigMediaType mediaType;
    FourCharCode mediaSubtype;
} binOutputHeader;
    
/*
** Determines if the noise reduction algorithm from the camera tuning options dictionary
** uses the SPI noiseReductionInOutWithTuningOptions() with an output sample buffer in
** argument.
**
** If this function returns false, the noise reduction algorithm works in-place and uses
** the deprecated SPI, noiseReductionWithTuningOptions().
**
** The noise reduction algorithm can be overriden by the defaults write 'noise_reduction_method'.
*/
extern Boolean noiseReductionRequiresOutputSampleBuffer(CFDictionaryRef options);
    
/*
** Create a context to hold one time initialization data associated with
** noise reduction.  This is primarily used for GPU PowerBlur, but it could be
** extended to cache anything static in use by noiseReduction().
**
** The "synchronization" parameter controls whether noiseReductionContextCreate()
** returns when all work is complete (NRCtxCreateSynchronization_Synchronous),
** or if the context creation work will be spun off on a GCD queue
** (NRCtxCreateSynchronization_Asynchronous_GCD_High/Normal/Low).
** If using a GCD queue is specified, the first invocation of noiseReduction() or
** noiseReductionWithTuningOptions() will wait for the context creation to finish.
**
** The "gpuPriorityRequest" parameter sets the GPU priority in the OpenGL context.
** NRCtxGPUPriority_Low should be used when the GPU is expected to be used and
** the rendering time is expected to be greater than 1/60th of a second.  Otherwise
** NRCtxGPUPriority_Normal can be used.
*/
extern NoiseReductionCtx noiseReductionContextCreate(NRCtxCreateSynchronization synchronization,
                                                     NRCtxGPUPriority gpuPriorityRequest);

extern NoiseReductionCtx noiseReductionContextCreateWithOptions(
        NRCtxCreateSynchronization synchronization, NRCtxGPUPriority gpuPriorityRequest,
        CFDictionaryRef options);

/*
** Destroy a NoiseReduction context previously created with
** noiseReductionContextCreate();
*/
extern void noiseReductionContextDestroy(NoiseReductionCtx nrCtx);

/*
 ** Releases large temporary buffers that can easily be re-created in an effort to reduce
 ** the memory footprint during idle periods.
 */
extern void noiseReductionReleaseBuffers(NoiseReductionCtx nrCtx);

/*
**  Applies the powerblur noise reduction algorithm, reading from the
**  provided sample buffer. The operation is performed in-place, modifying
**  the CVImageBuffer's data in the sample buffer.
**
**  Note that this function utilizes the metadata attached to the sample
**  buffer to determine the amount of noise reduction necessary for this
**  frame, and can choose to not process the image at all if the noise
**  level is already low enough.
**
**  The options dictionary can consist of two dictionaries: one specifying the
**  tuning parameters and/or a dictionary specifying the crop rectangle.
**
**  The tuning dictionary can specify the bias and slope for the level, and also
**  the gains, for cases such as HDR and Pano. For live capture case, the
**  tuning dictionary is initialized from CameraSetup.plist.
**
**  Before H7, only PowerBlur uses this function. Prefers to use
**  noiseReductionInOutWithTuningOptions with MultiBand that performs the noise reduction
**  out of place.
**  <rdar://problem/16450732> [BW] extra frame copy in noise reduction regresses N94 overall picture taking time by 35%
*/
extern OSStatus noiseReductionWithTuningOptions(NoiseReductionCtx nrCtx,
    FigSampleBufferRef sampleBuffer, bool processLuma, bool threaded, CFDictionaryRef options);

/*
**  Wrapper function that calls powerBlurNoiseReduction.
**  For backward compatiblity with legacy software.
**  This call will always run the CPU version of powerblur,
**  which is an older algorithm than the more recent GPU version.
**
**  This function is deprecated. Use instead noiseReductionInOutWithTuningOptions.
*/
extern OSStatus noiseReduction(FigSampleBufferRef sampleBuffer,
                               bool processLuma, bool threaded) DEPRECATED_ATTRIBUTE;
    
/*
**  Applies the multi band noise reduction algorithm, reading from the
**  provided input sample buffer and store the result in the output sample buffer.
**  The input/output sample buffers could support the same metadata attachments.
**  The metadata of the output sample buffer can be modified after the call of this
**  function.
**
**  Note that this function utilizes the metadata attached to the sample
**  buffer to determine the amount of noise reduction necessary for this
**  frame.
**
**  The options dictionary can consist of two dictionaries: one specifying the
**  tuning parameters and/or a dictionary specifying the crop rectangle.
**
**  The tuning dictionary can specify the bias and slope for the level, and also
**  the gains, for cases such as HDR and Pano. For live capture case, the
**  tuning dictionary is initialized from CameraSetup.plist.
**
**  If an error occurs, this function tries to copy the content of the input sample buffer
**  to the output sample buffer. If this operation fails, kCMBaseObjectError_ValueNotAvailable
**  is returned.
*/
extern OSStatus noiseReductionInOutWithTuningOptions(NoiseReductionCtx nrCtx,
    FigSampleBufferRef sampleBufferIn, FigSampleBufferRef sampleBufferOut, bool processLuma, bool threaded, CFDictionaryRef options);

/*
 **  Return the number of pyramid layers used by the denoise algorithm
 */

int noiseReductionPyramidLayers(NoiseReductionCtx nrCtx);

/*
 **  Applies the multi band noise reduction algorithm to data contained in sampleBufferIn,
 **  the output, in pixelBufferOut, can be a single image buffer or a complete image pyramid.
 **
 **  To facilitate working with complex buffers, data is represented as CVImageBufferRef,
 **  not FigSampleBufferRef as the other less specialized functions.
 **  Image metadata must be passed explicitly using srcMetadataDict
 **
 **  pixelBufferOutNum, indicates the number of output buffers in pixelBufferOut.
 **        Should be either 1 (single frame) or the number returned by noiseReductionPyramidLayers (full pyramid.)
 **
 **  options: the dictionary can be used to pass source image metadata, to override metadata being passed along with
 **  sampleBufferIn.
 **     Flags: kTNRFusionAlgorithm: allows to select the fusion algorithm to be used (kTNRFusionUniform : kTNRFusionLongShort)
 **            kNoiseReductionSynchronization: (kNoiseReductionSynchronous, kNoiseReductionAsynchronous) allows to run the
 **                                            fusion synchronously or asynchronously on the GPU.
 **
 **  Symbol being exported for TMBNR.
 */

OSStatus noiseReductionWithPyramid(NoiseReductionCtx nrCtx,
    FigSampleBufferRef sampleBufferIn,
    CVImageBufferRef pixelBufferOut[],
    int pixelBufferOutNum,
    CFDictionaryRef options);

/*
 **  Return the maximum number of images that can be fused by noiseReductionPyramidFusion
 */

int noiseReductionPyramidFusionMaxBuffers(NoiseReductionCtx nrCtx);

/*
 **  Applies TMBNR fusion to an array of image pyramids.
 **
 **  pixelBufferIn: contains the image pyramid, usually obtained from noiseReductionWithPyramid
 **  registrationXforms3x3: an array of registration transforms to be applied during the fusion process
 **  buffers: the number of pyramids to fuse
 **  pixelBufferOut: the output image buffer
 **  srcMetadataDict: reference metadata for the image pyramids
 **
 **  As for noiseReductionWithPyramid, input and output data is represented as CVImageBufferRef
 **
 **  options: kTNRFusionAlgorithm selects the fusion algorithm, and kNoiseReductionSynchronization
 **  allows for asynchronous operation on the GPU.
 **  
 **  Symbol being exported for TMBNR.
 */

OSStatus noiseReductionPyramidFusion(NoiseReductionCtx nrCtx,
   CVImageBufferRef *pixelBufferIn[], float registrationXforms3x3[][9], int buffers,
   CVImageBufferRef pixelBufferOut,
   CFDictionaryRef srcMetadataDict, CFDictionaryRef options);

#if !FIG_DISABLE_ALL_EXPERIMENTS
//
/// Attaches an 'NRParams' key to the metadata dictionary with two keys:
///   'NR2Params': noise reduction metadata, and
///   'BufferParams': extra dictionary
///
/// If either dictionary is NULL, "Missing" string is used instead.
///
/// sampleBufferIn: input sample buffer
/// sampleBufferOut: output sample buffer, can be the same as sampleBufferIn
/// options: extra dictionary to attach
 //
void noiseReductionCopyExperimentalMetadata(NoiseReductionCtx nrCtx, FigSampleBufferRef sampleBufferIn, FigSampleBufferRef sampleBufferOut, CFDictionaryRef options);
#endif

#endif

#ifdef __cplusplus
}

#endif // NOISEREDUCTION_H
