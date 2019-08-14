/*
 *  FigMotionProcessingUtilities.h
 *	Motion processing routines for rotation, quaternion, and perspective transform computation.
 *
 */

#ifndef _FIG_MOTION_PROCESSING_UTILITIES_H_
#define _FIG_MOTION_PROCESSING_UTILITIES_H_

#ifndef DEBUG_ALL_MOTION_DATA
#define DEBUG_ALL_MOTION_DATA 0
#endif

#ifndef LOG_LIMIT_TRANSFORM
#define LOG_LIMIT_TRANSFORM 0
#endif

#if TARGET_OS_IPHONE
#define	TEST_MATRIX	0
#else
#define	TEST_MATRIX	0
#endif

enum {
	kMotionAttachmentsTransformMatrixSize = 9
};

#include <CoreVideo/CoreVideo.h>
#include <CoreMedia/FigDebugPlatform.h>
#include <CoreMedia/FigCFUtilitiesFigOnly.h>	// for FigCFReleaseAndClear
#if TARGET_OS_IPHONE
#include <CoreMedia/FigEmbeddedCaptureDevice.h>
#include <CoreMedia/FigCaptureSampleBufferProcessorCommon.h>
#include <CoreMedia/FigCaptureISPProcessingSession.h>
#else
#include "FigEmbeddedCaptureDevice.h"
#include "FigCaptureSampleBufferProcessorCommon.h"
#endif

//
//Note: This piece code is copied and adapted from <H9ISPServices/CISPOutputMetadata.h>.
//		It is used in debugging and testing, but not in the shipping products.
// 		CoreMedia SW does not want to have dependency on H9ISPServices, and thus we cannot link the header file directly.
#define OIS_SAMPLE_MAX  510
#define MOTION_SAMPLE_MAX 110

/*
 * Size of the motion data sample in bytes.
 */
#define MOTION_RAW_DATA_SIZE (64)

#define QUATERNION_FRAC_FACTOR (1 << 30)
#define ROTATION_RATE_FRAC_FACTOR (1 << 16)
#define GRAVITY_FRAC_FACTOR (1 << 16)
#define ABWC_FRAC_FACTOR (1<<24)
#define APS_PFL_FACTOR (1 << 16)

#define CISP_VIS_INFO_MAX_SLICE_NBR (48)

#define FIGMOTION_TRANSFORM_LIMIT_MARGIN (0.5f) // Safety margin, in pixels, used to limit the transformed point to a specific rectangle (overscan)

#pragma pack(4)

struct sCIspGyroData {
    uint16_t temperature;
    uint16_t reserved;
    
    int32_t rotationRateX; /*!< Wx, calibrated gyro rotation rate in degree per second, in 16.16 format \refROTATION_RATE_FRAC_FACTOR . */
    int32_t rotationRateY; /*!< Wy, calibrated gyro rotation rate in degree per second, in 16.16 format \refROTATION_RATE_FRAC_FACTOR. */
    int32_t rotationRateZ; /*!< Wz, calibrated gyro rotation rate in degree per second, in 16.16 format \refROTATION_RATE_FRAC_FACTOR. */
    
    int32_t quaternionW;  /*!< 2.30 format, \ref QUATERNION_FRAC_FACTOR */
    int32_t quaternionX;  /*!< 2.30 format, \ref QUATERNION_FRAC_FACTOR */
    int32_t quaternionY;  /*!< 2.30 format, \ref QUATERNION_FRAC_FACTOR */
    int32_t quaternionZ;  /*!< 2.30 format, \ref QUATERNION_FRAC_FACTOR */
    
    int32_t tiptiltX; /*!< predicted tip/tilt/rotation data. */
    int32_t tiptiltY; /*!< predicted tip/tilt/rotation data. */
    int32_t tiptiltZ; /*!< predicted tip/tilt/rotation data. */
}; /* Reformatted. */

struct sCIspMotionData {
	uint16_t temperature;
	uint16_t convergence; /*!< 0x01 = legacy/non-convergent data
						   0x02 = dynamic bias estimate converged
						   0x04 = abandon (worst case gyro bias conditions)
						   0x40 = dynamic bias estimation disabled (for testing via defaults)
						   */
	
	int32_t quaternionW;  /*!< 2.30 format, \ref QUATERNION_FRAC_FACTOR */
	int32_t quaternionX;  /*!< 2.30 format, \ref QUATERNION_FRAC_FACTOR */
	int32_t quaternionY;  /*!< 2.30 format, \ref QUATERNION_FRAC_FACTOR */
	int32_t quaternionZ;  /*!< 2.30 format, \ref QUATERNION_FRAC_FACTOR */
	
	int32_t gravityX; /*!< gravity vector x value s14.16*/
	int32_t gravityY; /*!< gravity vector x value s14.16*/
	int32_t gravityZ; /*!< gravity vector x value s14.16*/
	
	int32_t predQuaternionW;  /*!< 2.30 format, \ref QUATERNION_FRAC_FACTOR */
	int32_t predQuaternionX;  /*!< 2.30 format, \ref QUATERNION_FRAC_FACTOR */
	int32_t predQuaternionY;  /*!< 2.30 format, \ref QUATERNION_FRAC_FACTOR */
	int32_t predQuaternionZ;  /*!< 2.30 format, \ref QUATERNION_FRAC_FACTOR */
	
	int32_t accelX; /*!< Acceleration vector x values s14.16*/
	int32_t accelY; /*!< Acceleration vector y values s14.16*/
	int32_t accelZ; /*!< Acceleration vector z values s14.16*/
	int32_t accelFlags; /*!< Acceleration valid flag */
	int32_t biasErrorEstimate; /*!< bias error estimate value s14.16*/
	
	int32_t rotationrateY; /*!< Rotationrate vector[0] values s14.16*/
	int32_t rotationrateP; /*!< Rotationrate vector[1] values s14.16*/
	int32_t rotationrateR; /*!< Rotationrate vector[2] values s14.16*/
};

struct sCIspABWCDebugData {
    int32_t pitch;  /*!< pitch cut off frequncy in 8.24 format. */
    int32_t roll;  /*!< roll cut off frequncy in 8.24 format. */
    int32_t yaw;  /*!< yaw cut off frequncy  in 8.24 format. */
    
    /*!<
  * Following item are used to store the ABWC output Quaternions
  * The high pass filter resul.
  **/
    
    int32_t outFilteredQw;  /*!< 2.30 format, \ref QUATERNION_FRAC_FACTOR */
    int32_t outFilteredQx;  /*!< 2.30 format, \ref QUATERNION_FRAC_FACTOR */
    int32_t outFilteredQy;  /*!< 2.30 format, \ref QUATERNION_FRAC_FACTOR */
    int32_t outFilteredQz;  /*!< 2.30 format, \ref QUATERNION_FRAC_FACTOR */
}; /* Reformatted. */

struct sCIspMotionDataSample {
	
	uint64_t ispTimeStamp; /*!< receiver (ISP) timestamp. */
	uint64_t motionTimeStamp; /*!< sender (OSCAR2) timestamp. */
	uint16_t packetType; /*!< specify the metadata type. 0: raw data, 1. gyro, 2. motion data*/
	union {
		uint8_t data[MOTION_RAW_DATA_SIZE]; /*!< motion packet raw data. */
		struct sCIspGyroData gyro; /*!< proto-p gyro data. */
		struct sCIspMotionData motionData;
		
	} packet; /*!< Motion data sample. */
};

struct sCIspOisSample {
	uint64_t ispTimeStamp;
	
	int32_t xTarget; /*!< Desired X displacement projected on to the image plane, in units of microns (Q24.8) */
	int32_t yTarget; /*!< Desired Y displacement projected on to the image plane, in units of microns (Q24.8) */
	int16_t hallH1; /*!< raw hall sensor readback value. */
	int16_t hallH2; /*!< raw hall sensor readback value. */
	
	int16_t driveB1; /*!< raw data written to the ois driver. */
	int16_t driveB2; /*!< raw data written to the ois driver. */
	int32_t xEstimate; /*!< Estimated X displacement projected on to the image plane, in units of microns (Q24.8) */
	int32_t yEstimate; /*!< Estimated Y displacement projected on to the image plane, in units of microns (Q24.8) */
	
	uint16_t temperature;
	
	int32_t sphBzH1Corr; /*!< Corrected H1 signal with Bz compensation (LSB) (Q24.8) */
	int32_t sphBzH2Corr; /*!< Corrected H2 signal ith Bz compensation (LSB) (Q24.8) */
	
	int32_t H1toMicrons[2]; /*!< H1*cos(theta1) and H1*sine(theta1) (Q24.8) */
	int32_t H2toMicrons[2]; /*!< H2*cos(theta2) and H2*sine(theta2) (Q24.8) */
	int32_t B1toMicrons[2]; /*!< B1*cos(theta1) and B1*sine(theta1) (Q24.8) */
	int32_t B2toMicrons[2]; /*!< B2*cos(theta2) and B2*sine(theta2) (Q24.8) */
	
	uint16_t powerVal; /*!< power manual conversion voltage/current reading */
};

/**
 * OIS Debug parameters .
 * \brief Debug parameters for OIS.
 */
struct sCIspMetaDataSharedOIS
{
	uint16_t oisMetaVersion; /*!< OIS metadata version. */
	uint16_t oisSampleCount;  /*!< Number of valid samples in array oisSample. */
	uint16_t motionSampleCount;  /*!< Number of valid samples in array motionSample and abwcDebug. */
	uint16_t reserved0; /*!< reserved field for alignment. */
	struct sCIspOisSample oisSample[OIS_SAMPLE_MAX]; /*!< ois controller samples. */
	struct sCIspMotionDataSample motionSample[MOTION_SAMPLE_MAX]; /*!< motion data samples. */
	struct sCIspABWCDebugData abwcDebug[MOTION_SAMPLE_MAX]; /*!< ABWC debug data.  */
	
};

// For H9 devices
struct sCH9IspMotionData {
	uint16_t temperature;
	uint16_t convergence; /*!< 0x01 = legacy/non-convergent data
						   0x02 = dynamic bias estimate converged
						   0x04 = abandon (worst case gyro bias conditions)
						   0x40 = dynamic bias estimation disabled (for testing via defaults)
						   */
	
	int32_t quaternionW;  /*!< 2.30 format, \ref QUATERNION_FRAC_FACTOR */
	int32_t quaternionX;  /*!< 2.30 format, \ref QUATERNION_FRAC_FACTOR */
	int32_t quaternionY;  /*!< 2.30 format, \ref QUATERNION_FRAC_FACTOR */
	int32_t quaternionZ;  /*!< 2.30 format, \ref QUATERNION_FRAC_FACTOR */
	
	int32_t gravityX; /*!< gravity vector x value s14.16*/
	int32_t gravityY; /*!< gravity vector x value s14.16*/
	int32_t gravityZ; /*!< gravity vector x value s14.16*/
	
	int32_t predQuaternionW;  /*!< 2.30 format, \ref QUATERNION_FRAC_FACTOR */
	int32_t predQuaternionX;  /*!< 2.30 format, \ref QUATERNION_FRAC_FACTOR */
	int32_t predQuaternionY;  /*!< 2.30 format, \ref QUATERNION_FRAC_FACTOR */
	int32_t predQuaternionZ;  /*!< 2.30 format, \ref QUATERNION_FRAC_FACTOR */
	
	int32_t accelX; /*!< Acceleration vector x values s14.16*/
	int32_t accelY; /*!< Acceleration vector y values s14.16*/
	int32_t accelZ; /*!< Acceleration vector z values s14.16*/
	int32_t accelFlags; /*!< Acceleration valid flag */
	int32_t biasErrorEstimate; /*!< bias error estimate value s14.16*/
	int32_t reserved[3];
};

struct sCH9IspMotionDataSample {
	uint64_t ispTimeStamp; /*!< receiver (ISP) timestamp. */
	uint64_t motionTimeStamp; /*!< sender (OSCAR2) timestamp. */
	union {
		uint8_t data[MOTION_RAW_DATA_SIZE]; /*!< motion packet raw data. */
		struct sCIspGyroData gyro; /*!< proto-p gyro data. */
		struct sCH9IspMotionData motionData;
		
	} packet; /*!< Motion data sample. */
	
	uint16_t packetType; /*!< specify the metadata type. 0: raw data, 1. gyro, 2. motion data*/
}; /* Reformatted. */

struct sCH6H9IspOisSample {
	uint64_t ispTimeStamp;
	
	int32_t xTarget; /*!< Desired X displacement projected on to the image plane, in units of microns (Q24.8) */
	int32_t yTarget; /*!< Desired Y displacement projected on to the image plane, in units of microns (Q24.8) */
	int16_t hallH1; /*!< raw hall sensor readback value. */
	int16_t hallH2; /*!< raw hall sensor readback value. */
	
	int16_t driveB1; /*!< raw data written to the ois driver. */
	int16_t driveB2; /*!< raw data written to the ois driver. */
	int32_t xEstimate; /*!< Estimated X displacement projected on to the image plane, in units of microns (Q24.8) */
	int32_t yEstimate; /*!< Estimated Y displacement projected on to the image plane, in units of microns (Q24.8) */
	
	uint16_t temperature;
} ;

/**
 * OIS Debug parameters .
 * \brief Debug parameters for OIS.
 */
struct sCH9IspMetaDataSharedOIS
{
	uint16_t oisMetaVersion; /*!< OIS metadata version. */
	uint16_t oisSampleCount;  /*!< Number of valid samples in array oisSample. */
	uint16_t motionSampleCount;  /*!< Number of valid samples in array motionSample and abwcDebug. */
	uint16_t reserved0; /*!< reserved field for alignment. */
	struct sCH6H9IspOisSample oisSample[OIS_SAMPLE_MAX]; /*!< ois controller samples. */
	struct sCH9IspMotionDataSample motionSample[MOTION_SAMPLE_MAX]; /*!< motion data samples. */
	struct sCIspABWCDebugData abwcDebug[MOTION_SAMPLE_MAX]; /*!< ABWC debug data.  */
}; /* Reformatted. */

// For devices older than H9.
// Adapted from <H6ISPServices/CISPOutputMetadata.h>
struct sCH6IspMotionData {
	uint16_t temperature;
	uint16_t convergence; /*!< 0x01 = legacy/non-convergent data
						   0x02 = dynamic bias estimate converged
						   0x04 = abandon (worst case gyro bias conditions)
						   0x40 = dynamic bias estimation disabled (for testing via defaults)
						   */
	
	int32_t quaternionW;  /*!< 2.30 format, \ref QUATERNION_FRAC_FACTOR */
	int32_t quaternionX;  /*!< 2.30 format, \ref QUATERNION_FRAC_FACTOR */
	int32_t quaternionY;  /*!< 2.30 format, \ref QUATERNION_FRAC_FACTOR */
	int32_t quaternionZ;  /*!< 2.30 format, \ref QUATERNION_FRAC_FACTOR */
	
	int32_t gravityX; /*!< gravity vector x value s14.16*/
	int32_t gravityY; /*!< gravity vector x value s14.16*/
	int32_t gravityZ; /*!< gravity vector x value s14.16*/
	
	int32_t predQuaternionW;  /*!< 2.30 format, \ref QUATERNION_FRAC_FACTOR */
	int32_t predQuaternionX;  /*!< 2.30 format, \ref QUATERNION_FRAC_FACTOR */
	int32_t predQuaternionY;  /*!< 2.30 format, \ref QUATERNION_FRAC_FACTOR */
	int32_t predQuaternionZ;  /*!< 2.30 format, \ref QUATERNION_FRAC_FACTOR */
};

struct sCH6IspMotionDataSample {
	uint64_t ispTimeStamp; /*!< receiver (ISP) timestamp. */
	uint64_t motionTimeStamp; /*!< sender (OSCAR2) timestamp. */
	union {
		uint8_t data[MOTION_RAW_DATA_SIZE]; /*!< motion packet raw data. */
		struct sCIspGyroData gyro; /*!< proto-p gyro data. */
		struct sCH6IspMotionData motionData;
	} packet; /*!< Motion data sample. */
	
	uint16_t packetType; /*!< specify the metadata type. 0: raw data, 1. gyro, 2. motion data*/
}; /* Reformatted. */

struct sCH6IspMetaDataSharedOIS
{
	uint16_t oisMetaVersion; /*!< OIS metadata version. */
	uint16_t oisSampleCount;  /*!< Number of valid samples in array oisSample. */
	uint16_t motionSampleCount;  /*!< Number of valid samples in array motionSample and abwcDebug. */
	uint16_t reserved0; /*!< reserved field for alignment. */
	struct sCH6H9IspOisSample oisSample[OIS_SAMPLE_MAX]; /*!< ois controller samples. */
	struct sCH6IspMotionDataSample motionSample[MOTION_SAMPLE_MAX]; /*!< motion data samples. */
	struct sCIspABWCDebugData abwcDebug[MOTION_SAMPLE_MAX]; /*!< ABWC debug data.  */
}; /* Reformatted. */

struct    sCIspMetaDataSharedVISInfo
{
	uint32_t    visMetaVersion;    /*Version Number for the format of the data*/
	uint32_t    nbrOfSlice;       /*Number of the slice supported */
	float       derivedVector[CISP_VIS_INFO_MAX_SLICE_NBR][9];    /*The result vector*/
};

#pragma options align=reset


extern const CFStringRef kFigCameraCharacterization_MicronsPerPixel;

enum {
	kTransformCPU = 0, //CPU implementation
	kTransformGPU = 1, //GPU implementation
	kTransformISP = 2, //ISP strip processing implementation
	kTransformISPMesh = 3, //ISP mesh warper implementation
};

enum {
	kAffine = 0,						// Affine transform, for experiments
	kTranslationOnly = 1,				// Translation only, for experiments
	kIntegerTranslationOnly = 2, 		// Integer translation only, for experiments
	// Above transforms are derived from the affine transforms
	// ================================================================
	// Below transforms are derived from the perspective transforms
	kPerspective = 3,						// Perspective transform, default for GPU implementation
	kTransformInsideRow = 4,				// Transform limited within a row, for simple ISP wrapper simulation
	kTransformInsideLineBuffers = 5,		// Transform limited within HW line buffers, for ISP VIS simulation
	kRollingShutterTranslationOnly = 6,		// Rolling shutter adaptive translation only, for OIS simulation
	kTransformInsideStripLineBuffers = 7,	// Strip transform limited within HW line buffers, default for ISP implementation
}; 

enum {
	kMotionError_NoMotionSample = -1,
	kMotionError_RingMutxFailed = -2,
	kMotionError_MissingStartSample = -3,
	kMotionError_MissingEndSample = -4,
	kMotionError_ComputationFailed = -5
};

// Bit masks for Bravo shift mitigation configuration
enum {
	kBravoShift_Sphere = 0x1,
	kBravoShift_Alignment = 0x2,
	kBravoShift_Parallax = 0x4
};

// these serve as indices into CameraCharacterizationData.lensCoefficients
typedef enum {
	kFigPortIndex_BackFacingCamera = 0,
	kFigPortIndex_BackFacingTelephotoCamera = 1,
	kFigPortIndex_BackFacingSuperWideCamera = 2,
	kFigPortIndex_FrontFacingCamera = 3,
	kFigPortIndex_FrontFacingInfraredCamera = 4,
} FigPortIndex;

extern OSStatus portIndexFromPortType( CFStringRef portType, FigPortIndex *portIndex );

typedef float FigMotionTypeFloat;
typedef CFTimeInterval FigMotionTypeTimestamp;

typedef struct {
	FigMotionTypeFloat x;
	FigMotionTypeFloat y;
	FigMotionTypeFloat z;
} FigMotionTypeVector3;


// Gyro data
/*
 FigRotationRate
 
 Discussion:
 A structure containing 3-axis rotation rate data.
 
 Fields:
 x    - X-axis rotation rate, in degrees per second.
 y	  -	Y-axis rotation rate, in degrees per second.
 z 	  - Z-axis rotation rate, in degrees per second.
 */
typedef FigMotionTypeVector3 FigRotationRate;


// Accelerometer data
/*
 FigAcceleration
 
 Discussion:
 A structure containing 3-axis acceleration data.
 
 Fields:
 x    - X-axis acceleration, in G-force.
 y	  -	Y-axis acceleration, in G-force.
 z 	  - Z-axis acceleration, in G-force.
 */
typedef FigMotionTypeVector3 FigAcceleration;


// Hall sensor data
/*
 FigPosition
 
 Discussion:
 A structure containing 2-axis position data.
 
 Fields:
 x    - X-axis position, in micrometers.
 y	  -	Y-axis position, in micrometers.
 */
typedef struct {
	FigMotionTypeFloat x;
	FigMotionTypeFloat y;
} FigPosition;

typedef struct {
	FigMotionTypeTimestamp timestamp;		//in seconds
	FigMotionTypeFloat temperature;			//in Celsius degrees
	FigPosition hallPosition;				//in micrometers
	FigPosition targetPosition;				//in micrometers
} FigHallPositionMotionEvent;


#define RING_BITS  (8)
#define RING_BITS_HALL  (9)
#define RING_BITS_APS   (9)
#define RING_SIZE  (1 << RING_BITS)
#define RING_SIZE_HALL  (1 << RING_BITS_HALL)
#define RING_SIZE_APS   (1 << RING_BITS_APS)
#define CAPTURE_TIME_ARRAY_SIZE 3
#define MOTION_DATA_DELAY_MOTION_FILTER 1

#define GRAVITY_FACTOR_DEFAULT 36.67f
#define MACRO_FOCUS_POSITION 255

#define DEFAULT_GYRO_GROUP_DELAY	(0.005)

#if TARGET_OS_EMBEDDED
#if (__IPHONE_OS_VERSION_MIN_REQUIRED >= 70000)
#import <CoreMotion/CLMotionTypes.h>
#else
#import <CoreMotion/MotionTypes.h>
#endif

#else
typedef float CLMotionTypeFloat;

typedef struct {
	CLMotionTypeFloat x;
	CLMotionTypeFloat y;
	CLMotionTypeFloat z;
} CLMotionTypeVector3;

typedef struct {
	CLMotionTypeFloat w;
	CLMotionTypeFloat x;
	CLMotionTypeFloat y;
	CLMotionTypeFloat z;
} CLMotionTypeVector4;

typedef struct {
	double w;
	double x;
	double y;
	double z;
} CLMotionTypeDoubleVector4;

typedef CLMotionTypeVector3 CLMotionTypeAcceleration;
typedef CLMotionTypeVector3 CLMotionTypeRotationRate;
typedef CLMotionTypeDoubleVector4 CLMotionTypeQuaternion;
#endif



/*!
    @struct      FigMotionPoint
    @abstract    Structure representing an integer-based point
    @field       x    Horizontal position
    @field       y    Vertical position
*/
typedef struct{
	int32_t x;
	int32_t y;
} FigMotionPoint;

/*!
    @struct      FigMotionSize
    @abstract    Structure representing an integer-based size
    @field       width     Horizontal size
    @field       height    Vertical size
*/
typedef struct{
	int32_t width;
	int32_t height;
} FigMotionSize;

/*!
    @struct      FigMotionRect
    @abstract    Structure representing an rectangle with integer-based position and size
    @field       origin    Coordinate of the top left corner
    @field       size      Size
*/
typedef struct{
	FigMotionPoint origin;
	FigMotionSize size;
} FigMotionRect;

typedef struct {
	bool   doingBiasEstimation;
	double timestamp;
	CLMotionTypeQuaternion quaternion;
} RawQuaternion;

// Encapsulates state of a camera for a given frame
typedef struct {
	int focusPosition;			// 0~255 (units: autofocus actuator current index)
	float lensPosition;			// varies by lens configuration (units: pixels)
	float lensPositionScalingFactor; // To adjust for calibration resolution vs current resolution; varies from frame to frame based on current zoom/crop
	Boolean sphereAvailable;	// indicates whether the frame is coming from a camera with a sphere module; does not indicate if sphere is currently active
	float sphereScaling; 		// pixels per micron
	float digitalZoomFactor;	// amount of digital zoom to apply
	double actualPTS;			// actual presentation timestamp, in seconds
	double outputPTS;			// effective presentation timestamp of output rectangle, in seconds
	double exposureTime;		// in seconds
	double rollingShutterSkew;	// Rolling shutter total readout delay, including last row, in seconds
	double outputFrameReadoutDelay;	// effective readout delay of output rectangle, in seconds
	double currentCaptureTime;	// in seconds
	FigPosition averageBlurVector;	// Average motion blur vector (not accounting for digitalZoomFactor)
	FigMotionRect validBufferRect;	// The region in the frame with valid pixels
	FigPortIndex currentPort;	// current port index
} CameraMetadata;

typedef struct {
	int							fusedRingIndex;
	double						fusedRingTime[RING_SIZE];
	CLMotionTypeQuaternion		fusedRingQuaternion[RING_SIZE];
	double						motionTimeShift;
	Boolean						ignoreMotionDataForPowerTest;
	Boolean						relaxMotionDataLoggingThreshold;
	Boolean						didHaveMotionData;
	Boolean						prevDidHaveMotionData;
	Boolean						usingMotionDataFromISP;	// Select between MotionAttachmentsISPMotionData (true) and MotionData (false)
} MotionDataContext;

#define MAX_NUM_CAMERAS 5 // max number of concurrent cameras on any device

typedef struct {
	int							fusedRingIndex[MAX_NUM_CAMERAS];
	double						fusedRingTime[MAX_NUM_CAMERAS][RING_SIZE_HALL];
	FigPosition					fusedRingHallPosition[MAX_NUM_CAMERAS][RING_SIZE_HALL];
	double						hallTimeShift;
	Boolean						isFirstSample[MAX_NUM_CAMERAS];
	Boolean						bypassHighPassFilter;
	float						lowpassParameter;
	FigPosition					lowpassHallPosition[MAX_NUM_CAMERAS];
} HallDataContext;

// Camera Intrinsic Parameters. Ignore skew by now.
typedef struct{
    float						 lensPosition;
    double                       opticalCenterX;
    double                       opticalCenterY;
} IntrinsicParameter;

#if ! FIG_DISABLE_ALL_EXPERIMENTS
// Ring buffer for APS data
typedef struct {
	double						ringTime[RING_SIZE_APS];				// Time stamp
	float						ringPFLPosition[RING_SIZE_APS];		// Practical focal length in millimeters
	int oldestIndex;											// Index for oldest sample
	int inputIndex;												// Index for next input sample
	int count;													// The number of valid samples
} APSRingBuffer;
#endif

// Encapsulates characterization parameters of a camera. These values remain constant frame to frame.
#define FOCAL_LENGTH_PARAMETERS	5
typedef struct {
	double  centerx;
	double  centery;
	bool lensCoefficientsValid;                      // flag for valid lens coefficients
	float lensCoefficients[FOCAL_LENGTH_PARAMETERS]; // Piece-wise linear coefficients
	float gravityFactor;
	float pixelsPerMicron;	// Raw sensor pixel size in microns
	bool isFrontCamera;	// This flag is used to convert the quaternion orientation to the camera coordinate space (different for front vs back camera)
} CameraCharacterizationData;

typedef struct {
	int32_t width;			// Source pixel buffer dimensions
	int32_t height;			// Source pixel buffer dimensions
	int32_t overscanWidth;	// Available overscan on each side
	int32_t overscanHeight;	// Available overscan on each side
	int32_t method;			// Affine, perspective, translation only, integer translation only
	int32_t platform;		// CPU, GPU, or ISP
	int32_t baseTransformCount;
	int32_t derivedTransformCount;
	int32_t derivedTransformStep;
#if LOG_LIMIT_TRANSFORM
	int32_t numLimitedFrames;
	int32_t numLimitedTransforms;
#endif
	Float32 limitFactor;
	Boolean limitTransform;
	Boolean prevTransformLimited; // Flag indicating whether any transform of the previous frame is limited.
	Boolean forceIdentity;
	uint16_t lineBufferCount;	// HW line buffer count, for ISP warp processing
	float digitalZoomFactorOverride;	// amount of digital zoom to apply
	
	int32_t ISPStripOffsetX;        // ISP strip position horizontal offset relative to the regular transform coordinate system (blackbar mode based).
	int32_t ISPStripOffsetY;        // ISP strip position vertical offset relative to the regular transform coordinate system (blackbar mode based).
	int32_t ISPHorizontalTileCount; // Number of horizontal tiles used for ISP strip/mesh transforms
	int32_t ISPVerticalTileCount;   // Number of vertical tiles used for ISP strip/mesh transforms
	bool    isUsing1kLineBuffers;   // True when using 1k input line buffers (ISP Strip or simulation), false for 2k line buffers.
#if TARGET_OS_IPHONE
	FigCaptureISPProcessingSessionParameterVideoStabilization *visStripParams;
	size_t visStripParamsSize;
#endif
} TransformContext;

#define EXTRINSICMATRIXSIZE 12	// Extrinsic matrix is 3x4 in float
#define MAX_BRAVO_TRANSITION_CAMERA 3
#define BRAVO_EXTRINSIC_MATRIX_ARRAY_SIZE ( 1 + MAX_BRAVO_TRANSITION_CAMERA * ( MAX_BRAVO_TRANSITION_CAMERA - 1 ) )

// Given the [referenceCamera, currentCamera] pair, locate the index of scaling factor and extrinsicMatrix
// Here is the detailed mapping
// Reference   Current    Index
// wide        wide        6
// wide        tele        0
// wide        superWide   1
// tele        wide        2
// tele        tele        6
// tele        superWide   3
// superWide   wide        4
// superWide   tele        5
// superWide   superWide   6
static int BravoCurrentToReferenceMapping[MAX_BRAVO_TRANSITION_CAMERA][MAX_BRAVO_TRANSITION_CAMERA] = {
	{6,0,1},
	{2,6,3},
	{4,5,6}
};

typedef struct {
	// Bravo shift mitigation configuration, using bit masks kBravoShift_*
	unsigned char configuration;

	// Below are for alignment correction
	//The difference between static optical center and raw sensor center (defined by RawSensorWidth and RawSensorHeight).
	// kFigPortIndex_BackFacingCamerawide = 0: wide,
	// kFigPortIndex_BackFacingTelephotoCamera = 1: tele,
	// kFigPortIndex_BackFacingTelephotoCamera = 2: superWide
	FigPosition opticalCenterOffset[MAX_BRAVO_TRANSITION_CAMERA];
	float baseZoomFactor[MAX_BRAVO_TRANSITION_CAMERA];
	// The mapping for [reference, current] pair is defined in BravoCurrentToReferenceMapping
	float currentToReferenceScaleRatio[BRAVO_EXTRINSIC_MATRIX_ARRAY_SIZE];
	float currentToReferenceExtrinsicMatrix[BRAVO_EXTRINSIC_MATRIX_ARRAY_SIZE][EXTRINSICMATRIXSIZE];

	// Below are for parallax mitigation
	FigPortIndex referencePortIndex;
	FigPortIndex previousPortIndex;
	FigPosition parallaxShift;

	// Below are for dual OIS camera module
	FigPosition slaveAverageSpherePos;
} FigMotionBravoData;

/*!
 @struct      FigMotionSphereShiftState
 @abstract    Structure keeping Sphere position values during Bravo transition.
 @field       lastWideSpherePos		Last low pass filtered Sphere position values for wide
 @field       lastTeleSpherePos		Last low pass filtered Sphere position values for tele
 @field       currentTeleSpherePos		Current Sphere positions for tele. It is used to handle missing metadata.
 @field       previousTeleSpherePos;		Previous low pass filtered tele Sphere positions. It is used to handle missing metadata.
 */
typedef struct {
	FigPosition lastWideSpherePos;
	FigPosition lastTeleSpherePos;
	FigPosition currentTeleSpherePos;
	FigPosition previousTeleSpherePos;

	bool supportAverageSpherePositionKey;
} FigMotionSphereShiftState;

extern void FigMotionIncreaseRingIndex( int *index, int ringSize );

// Computes the quaternion's length
extern double FigMotionGetQuaternionLength( CLMotionTypeQuaternion *quaternion);

extern CLMotionTypeQuaternion FigMotionMultiplyQuaternions(const CLMotionTypeQuaternion *a, const CLMotionTypeQuaternion *b);

/*
 Calculates the adjusted focus position given gravity value and gravity factor
 */
extern OSStatus FigMotionCalculateAdjustedFocusPosition( float gravityZ, float gravityFactor,
														int *nFocusPosition);
/*
 Extract gravity factor given moduleInfo and sensorID dictionary.
 moduleInfo		:	contains lensID, ActuatorID and IntegratorID active camera port
 sensorIDDict	:	contains FocalLengthCharacterization from plist for active camera port
 gravityFactor	:	extracted gravity factor
 */
extern OSStatus FigMotionGetGravityFactor( CFDictionaryRef moduleInfo, CFDictionaryRef sensorIDDict, float *gravityFactorOut );

/*
 Extract the gravity (in Z direction only) from the metadata dictionary.
 */
extern OSStatus FigMotionGetGravityZ( CFDictionaryRef metadataDict, float *gravityZOut );

/*
 Calculates the adjusted lens position given the metadata dictionary (for unadjusted focus position, and sensor zoom
 incurred by ISP crop), gravity value and gravity factor (from camera characterization).
 */
extern OSStatus FigMotionCalculateAdjustedLensPosition( CFDictionaryRef metadataDict, float gravityZ,
													    CameraCharacterizationData *cameraData, float lensPositionScalingFactor, float *lensPosition );

/*!
	@function	FigMotionEstimateFocusDistance
	@abstract	This function estimates focus distance using per unit DAC-PFL linear model and Lens Maker's equation
	@param	metadataDict				Metadata dictionary holding motion data, kFigCaptureStreamMetadata_CurrentFocusPosition and kFigCaptureStreamMetadata_EffectiveFocalLength.
	@param	FocusPositionToLensMakersPFLLinearFitDict	The dictionary holding the DAC-PFL linear model parameters.
	@param	gravityZ					The gravity factor in the Z direction.
	@param	focusDistanceOut			The computed focus distance in centimeters.  A value of FLT_MAX means the infinity focus distance.
*/
extern OSStatus FigMotionEstimateFocusDistance( CFDictionaryRef metadataDict,
											    CFDictionaryRef FocusPositionToLensMakersPFLLinearFitDict,
											    float gravityZ,
											    float *focusDistanceOut );

/*!
	@function	FigMotionComputeLensPositionScalingFactor
	@abstract	This function computes the lens position scaling factor based on the total sensor crop rectangle, binning mode, and dimensions of the corresponding image buffer

	@param	metadataDict					Metadata dictionary from the camera driver, it must contain kFigCaptureStreamMetadata_TotalSensorCropRect
											(or kFigCaptureStreamMetadata_RawCropRect on older devices).
	@param	outputWidth						The width in pixels of the image buffer for which the scaling factor is computed.
	@param	outputHeight					The height in pixels of the image buffer for which the scaling factor is computed.
	@param	sensorBinningFactorHorizontal	The sensor binning factor along the horizontal direction.
	@param	sensorBinningFactorVertical		The sensor binning factor along the vertical direction.
	@param	lensPositionScalingFactorOut	The computed lens position scaling factor.
*/
extern OSStatus FigMotionComputeLensPositionScalingFactor( CFDictionaryRef metadataDict, int32_t outputWidth, int32_t outputHeight, int32_t sensorBinningFactorHorizontal, int32_t sensorBinningFactorVertical, float *lensPositionScalingFactorOut );

// Computes the frame PTS offset incurred by the various cropping stages of the ISP (front-end scaler and back-end scalers)
extern OSStatus FigMotionComputeFramePTSOffsetFromISPCrop( CFDictionaryRef metadataDict, double *framePTSOffsetOut );

// Compute homography given intrinsic parameters of two cameras and rotation matrix betweent them
extern void FigMotionComputeTransformFromRotation( IntrinsicParameter *cam1,
												  IntrinsicParameter *cam2,
												  const double rotationMatrix2To1[3][3],
												  Float32 *outTransformMatrix2To1 );

// Compute the transform from a quaternion vector
extern OSStatus FigMotionComputeTransformFromCameraMotion( CLMotionTypeQuaternion *quaternion,
														  CameraCharacterizationData *cameraCharacterization,
														  CameraMetadata *cameraMetadata,
                                                          FigPosition *sphereLensPosition,
														  Float32 *vector );

// Compute translation of a point given two camera intrinsic parameters and extrinsic matrix between them
extern FigPosition FigMotionComputeTranslationBetweenCameras( const IntrinsicParameter *cam1,
													  const IntrinsicParameter *cam2,
													  const float extrinsicMatrix1To2[EXTRINSICMATRIXSIZE],
													  const FigPosition *frameCenter );

/*!
 @function	FigMotionAdjustBravoDataForReferenceCamera
 @abstract	This function adjusts the scaling factors and extrinsic matrices according to the reference camera used. The reference camera used in dual camera transition
			may be different from the reference camera used in camera calibration. When they differ, these values are adjusted in terms of current reference camera.
 @param		FigMotionBravoData		The Bravo data passed into CoreMedia layer
*/
extern void FigMotionAdjustBravoDataForReferenceCamera( FigMotionBravoData *bravoData );

// Get Bravo lens data such as static optical centers and extrinsic matrix from SBP options dictionary
extern OSStatus FigMotionGetBravoDataFromDictionary( CFDictionaryRef dictionary, FigMotionBravoData *bravoData );

// Compute the translation vector from a quaternion vector
extern OSStatus FigMotionComputeTranslationFromCameraMotion( CLMotionTypeQuaternion *quaternion, 
															CameraCharacterizationData *cameraData, 
															CameraMetadata *cameraMetadata,
															Float32 *vector );

// Compute line transforms from motion data
extern OSStatus FigMotionComputeTransforms( TransformContext *ctx,
										   CameraCharacterizationData *cameraCharacterization,
										   CameraMetadata *cameraMetadata,
										   CLMotionTypeQuaternion *correctionQuaternions,
										   FigPosition *sphereLensPositions,
										   Float32 (*outVectors)[9] );

extern CLMotionTypeQuaternion FigMotionInverseOfQuaternion(const CLMotionTypeQuaternion *refQ);
extern OSStatus FigMotionInitializeQuaternion(CLMotionTypeQuaternion *quaternion);
extern CLMotionTypeQuaternion FigMotionMultiplyByInverseOfQuaternion(const CLMotionTypeQuaternion *quaternion, const CLMotionTypeQuaternion *refQ);
extern CLMotionTypeQuaternion FigMotionInterpolateQuaternionsByAngle(CLMotionTypeQuaternion *quaternion1, CLMotionTypeQuaternion *quaternion2,
																	 float parameter);

extern OSStatus FigMotionNormalizeQuaternion( CLMotionTypeQuaternion *quaternion );

// FigMotionInterpolateQuaternionsLERP uses linear interpolation instead of spherical interpolation implemented in FigMotionInterpolateQuaternionsByAngle()
// When called with alwaysNormalize = true, the output quaternion will be normalized to the unit sphere, otherwise the normalization will
// only be done if deemed necessary (i.e. if the output quaternion's length is < 0.7). The caller will be responsible for performing
// the final normalization based on wasNormalizedOut.
// A caller could call this function with alwaysNormalize = false when computing the average of multiple quaternions, in which case
// bypassing the intermediate normalizations can considerably reduce the computational cost (at the expense of an increased error).
// Note: this function may internally fallback to SLERP which means that, just like FigMotionInterpolateQuaternionsByAngle, the interpolation
// is not commutative
extern CLMotionTypeQuaternion FigMotionInterpolateQuaternionsLERP( CLMotionTypeQuaternion *quaternion1, CLMotionTypeQuaternion *quaternion2,
																  float parameter, Boolean alwaysNormalize, Boolean *wasNormalizedOut );

extern OSStatus FigMotionGetCameraCharacterizationData( CFDictionaryRef moduleInfo, CFDictionaryRef sensorIDDict, CFStringRef portType, CameraCharacterizationData *cameraData );
extern OSStatus FigMotionComputeAverageQuaternionForTimePeriod( double *fusedRingTime, CLMotionTypeQuaternion *fusedRingQuaternion,
															   double startTimestamp, double endTimestamp, CLMotionTypeQuaternion *quaternion );
// Extract multiple motion data from top to bottom
// If the caller doesn't want to extract the hall sensor data, NULL should be passed for HallPositionData and sphereLensPositions
// If the caller doesn't support Bravo, NULL should be passed for bravoData. Note bravoData will be modified for parallax mitigation
extern OSStatus FigMotionExtractMetadataFromTopToBottomRows( CFDictionaryRef metadataDict,
											  MotionDataContext *motionData,
											  HallDataContext *HallPositionData,	// Optional
											  CameraMetadata *cameraMetadata,
											  CameraCharacterizationData *cameraData,
											  TransformContext *transformContext,
											  CLMotionTypeQuaternion *quaternions,
											  FigPosition *sphereLensPositions,
											  FigMotionBravoData *bravoData,
											  int baseTransformCount );

// Compute quaternion and attitude for a specific capture time
extern OSStatus FigMotionComputeQuaternionAndAttitudeFromArray( CFArrayRef inputArray,
															   double captureTime,
															   CLMotionTypeQuaternion *outQuaternion,
															   FigAttitude *outAttitude );

// Compute average quaternion for a given time range
extern OSStatus FigMotionComputeAverageQuaternionFromArray( CFArrayRef inputArray,
														   double startTimestamp, double endTimestamp,
														   CLMotionTypeQuaternion *outQuaternion );
// Get attitude from quaternion
extern void FigMotionAttitudeFromQuaternion( const CLMotionTypeQuaternion quaternion, FigAttitude *attitude );

// Conversion functions between quaternions and a delta rotation
extern CLMotionTypeQuaternion FigMotionQuaternionFromDeltaRotation( const CLMotionTypeRotationRate *rotation );
extern CLMotionTypeRotationRate FigMotionDeltaRotationFromQuaternion( const CLMotionTypeQuaternion *quaternion );

extern OSStatus FigMotionRotationRateFromDeltaQuaternion( const CLMotionTypeQuaternion *quaternion,
														 double timeInterval,
														 CLMotionTypeRotationRate *rotationRate );

// baseWeights, averageAngle, averageBlur, hallData and motionBlurVector can be null pointers
// When baseWeights is NULL base transforms will use equal weights
extern OSStatus FigMotionComputeMotionBlur( MotionDataContext *motionData,
									CameraMetadata *cameraMetadata,
									CameraCharacterizationData *cameraData,
									HallDataContext *hallData,
									float  *baseWeights,
									int baseCount,
									float *averageAngle,
									float *averageBlur,
									FigPosition *motionBlurVector );

// Coordinate conversion for 3x1 vectors. It can be used to align gyro rotation rates, accelerometer acceleration, gravity vectors, etc.
// The alignment matrix should be orthogonal.
extern FigMotionTypeVector3 FigMotionAlign3x1Vector( const FigMotionTypeVector3 *vectorIn, const double *alignmentMatrix3x3 );

// Extracts the gyro motion data and Hall sensor motion data from the metadata dictionary
// To only decode the gyro motion data the caller may pass NULL values for HallPositionArray, and HallPositionSampleCountOut
// To only decode the hall data the caller may pass NULL values for rawQuaternionArray, rawQuaternionSampleCountOut, and gravityOut
extern OSStatus FigMotionGetMotionDataFromISP( CFDictionaryRef metadataDict,
												   RawQuaternion *rawQuaternionArray,
												   int *rawQuaternionSampleCountOut,
												   FigAcceleration *gravityOut,
												   FigHallPositionMotionEvent *HallPositionArray,
												   int *HallPositionSampleCountOut );


#if ! FIG_DISABLE_ALL_EXPERIMENTS
/*!
 @function	FigMotionAddISPAPSDataToRingBuffer
 @abstract	This function extracts ISPAPSData from metadata dictionary and adds them into a ring buffer
 @param		metadataDict		The metadata dictionary
 @param		apsRingBuffer		The ring buffer for APS data
 */
extern OSStatus FigMotionAddISPAPSDataToRingBuffer( CFDictionaryRef metadataDict, APSRingBuffer *apsRingBuffer );

/*!
 @function	FigMotionComputePFLScore
 @abstract	This function computes a score value based on PFL values
 @param		apsRingBuffer		The ring buffer for APS data
 @param		framePTS			The frame presentation time
 @param		rollingShutterSkew	The rolling shutter skew value
 @param		exposureTime		The exposure time
 @param		startLine			The start line to compute the score
 @param		endLine			The end line to compute the score
 @param		imageHeight		The image height
 @return		The computed PFL score value in microns
 */
extern float FigMotionComputePFLScore( APSRingBuffer *apsRingBuffer,
									  float framePTS,
									  float rollingShutterSkew,
									  float exposureTime,
									  int startLine,
									  int endLine,
									  int imageHeight );
#endif

extern OSStatus FigMotionLogTransform(FILE *file, int frameIndex, Float32 (*vectors)[9], int derivedTransformCount );

/*!
 @function    FigMotionSphereShiftStateInitialize
 @abstract    This function initializes the given FigMotionSphereShiftState structure
 @param       sphereShiftState		The structure holding the Sphere shift values
 */
extern void FigMotionSphereShiftStateInitialize( FigMotionSphereShiftState *sphereShiftState );

/*!
 @function	FigMotionComputeWideToNarrowShift
 @abstract	This function computes the Bravo translation vector.  An internal state sphereShiftStateInOut may be used to handle preview shaking and keep narrower camera Sphere positions. The unit used in sphereShiftStateInOut is microns so the function may be called by multiple streams from the same camera.
 @param		wideMetadataDict					The metadata dictionary for the wider camera
 @param		narrowMetadataDict					The metadata dictionary for the narrower camera
 @param		wideToNarrowExtrinsicMatrix			The extrinsic matrix between the wider camera and the narrower camera.
 @param		wideOpticalCenterOffset				The difference between static optical center and raw sensor center (defined by RawSensorWidth and RawSensorHeight) for the wider camera
 @param		narrowOpticalCenterOffset			The difference between static optical center and raw sensor center (defined by RawSensorWidth and RawSensorHeight) for the narrower camera
 @param		wideToNarrowScaleRatio				The scaling ratio of the wider camera to the narrower camera
 @param		widePixelsPerMicron					How many pixels per micron on the wider camera
 @param		narrowPixelsPerMicron				How many pixels per micron on the narrower camera
 @param		wideFramePTS						Frame presentation time stamp for the wider camera
 @param		narrowFramePTS						Frame presentation time stamp for the narrower camera
 @param		widePixelBufferWidth				Pixel buffer width for the wider camera
 @param		widePixelBufferHeight				Pixel buffer height for the wider camera
 @param		wideSensorBinningFactorHorizontal	sensor binning factor in horizontal direction for the wider camera
 @param		wideSensorBinningFactorVertical		sensor binning factor in vertical direction for the narrower camera
 @param		configuration						Used to control active corrections. It is a combination of kBravoShift_Sphere, kBravoShift_Alignment and kBravoShift_Parallax.
 @param		parallaxMitigationStrength			Parallax ramp mitigation strength. Valid values are between 0.0 and 1.0.
 @param		sphereShiftStateInOut				Used to keep Sphere shift values and narrow Sphere positions. The unit is microns. Its value can be NULL.
 @param		wideToNarrowShiftOut				The computed Bravo translation vector.
 */
extern OSStatus FigMotionComputeWideToNarrowShift( CFDictionaryRef wideMetadataDict,
												CFDictionaryRef narrowMetadataDict,
												CFDataRef wideToNarrowExtrinsicMatrix,
												CGPoint *wideOpticalCenterOffset,
												CGPoint *narrowOpticalCenterOffset,
												float wideToNarrowScaleRatio,
												float widePixelsPerMicron,
												float narrowPixelsPerMicron,
												double wideFramePTS,
												double narrowFramePTS,
												int32_t pixelBufferWidth,
												int32_t pixelBufferHeight,
												int32_t sensorBinningFactorHorizontal,
												int32_t sensorBinningFactorVertical,
												unsigned char configuration,
												float parallaxMitigationStrength,
												FigMotionSphereShiftState *sphereShiftStateInOut,
												CGPoint *wideToNarrowShiftOut );

/*!
	@function	FigMotionSphereShiftStateUpdateWithMetadata
	@abstract	This function updates the Sphere shift states using given Metadata dictionary.
	@param		sphereShiftState			Pointer to a FigMotionSphereShiftState object.
	@param		metadataDict				Metadata dictionary.
 */
extern OSStatus FigMotionSphereShiftStateUpdateWithMetadata( FigMotionSphereShiftState *sphereShiftState,
															 CFDictionaryRef metadataDict );

/*!
 @function FigMotionComputeParallaxShift
 @abstract This function computes the parallax shift between Bravo cameras for the objects at the focus distance. It uses the APS metadata: PracticalFocalLength and EffectiveFocalLength.
 @param    metadataDict				Metadata dictionary
 @param    translationX				The translation in X direction between current camera and the reference camera in millimeters
 @param    translationY				The translation in Y direction between current camera and the reference camera in millimeters
 @param    framePixelsPerMicron		How many frame pixels per micron
 @param    parallaxShift			The parallax values in pixels
 */
extern void FigMotionComputeParallaxShift( CFDictionaryRef metadataDict,
										   float translationX,
										   float translationY,
										   float framePixelsPerMicron,
										   FigPosition *parallaxShift );

/*!
 @function	FigMotionAdjustPointForSphereMovement
 @abstract	This function adjusts a point for sphere movement (when available); if sphere is not available, point is not modified. It uses physical position measured in microns, and converts it to pixels in the output dimension.
 @param	metadataDict				Metadata dictionary holding kFigCaptureStreamMetadata_ExposureTime, kFigCaptureStreamMetadata_FrameRollingShutterSkew
 also kFigCaptureStreamMetadata_ISPHallData (when sphere is available).
 @param	sensorPixelsPerMicron		Reciprocal of the sensor pixel size in microns (i.e. 1/1.2 for a sensor with 1.2 micron pixels).
 @param	scalingFactorPixel2Pixel	The scaling factor from sensor pixels to frame pixels. It already takes into account of the binning factors.
 @param	framePTS					The frame Presentation Time Stamp.
 @param	pointInOut					The point to adjust.
 */
extern OSStatus FigMotionAdjustPointForSphereMovement( CFDictionaryRef metadataDict,
													  float sensorPixelsPerMicron,
													  float scalingFactorPixel2Pixel,
													  double framePTS,
													  CGPoint *pointInOut );

/*!
 @function FigMotionComputeBlurScores
 @abstract This function computes an array of blurScores from an array of metadata. The blurScores are used in reference frame selection.
 @param	   frameMetadataArray			An array of metadata. One metadata corresponds to one frame, and should contain ISPMotionData.
 @param    portIndex					Port index for current camera
 @param    practicalFocalLength			The default fixed practical focal length in microns. If the value is less than 0,
										kFigCaptureStreamMetadata_PracticalFocalLength is expected to be available for use in the metadata dictionary.
 @param    numSectors                   Number of sectors per row used for blur score computation.
 @param    numberOfRows	                Number of rows per frame used for blur score computation.
 @param    blurScores					An array of blurScores in microns corresponding to the array of metadata.
  */
extern OSStatus FigMotionComputeBlurScores( CFArrayRef frameMetadataArray,
										   FigPortIndex portIndex,
										   float practicalFocalLength,
										   unsigned int numSectors,
										   unsigned int numberOfRows,
										   Float32 *blurScores );

/*!
 @function	FigMotionComputeAverageSpherePosition
 @abstract	This function averages Sphere samples over the duration of a frame to obtain the average Sphere position for that frame.
 @param		metadataDict			Metadata dictionary holding kFigCaptureStreamMetadata_ExposureTime, kFigCaptureStreamMetadata_FrameRollingShutterSkew
 									also kFigCaptureStreamMetadata_ISPHallData (when Sphere is available).
 @param		framePTS				The frame presentation time stamp.
 @param 	outPosition				The output average Sphere position.
 */
extern OSStatus FigMotionComputeAverageSpherePosition( CFDictionaryRef metadataDict,
													  double framePTS,
													  FigPosition *outPosition );

/*!
	@function	FigMotionComputePrincipalPoint
	@abstract	This function computes principal point adjusted for sphere (when available); if sphere is not available, the principal point is returned
	@param	metadataDict				Metadata dictionary holding kFigCaptureStreamMetadata_ExposureTime, kFigCaptureStreamMetadata_FrameRollingShutterSkew
                                        also kFigCaptureStreamMetadata_ISPHallData (when sphere is available).
	@param	sensorPixelsPerMicron		Reciprocal of the sensor pixel size in microns (i.e. 1/1.2 for a sensor with 1.2 micron pixels).
	@param	scalingFactorPixel2Pixel	The scaling factor from sensor pixels to frame pixels. This can be calculated using FigMotionComputeLensPositionScalingFactor(). For binned modes, the sensor pixel refers to the original sensor pixel prior to binning.
	@param	framePTS					The frame Presentation Time Stamp.
	@param	pixelBufferWidth			Frame width.
	@param  pixelBufferHeight			Frame height.
	@param	sensorBinningFactorHorizontal  Sensor binning factor in horizontal direction.
	@param	sensorBinningFactorVertical	   Sensor binning factor in vertical direction.
	@param  hasSphere					Should the principal point be corrected for sphere.
	@param	adjustedPrincipalPointOut	The adjusted principal point position.
 */
extern OSStatus FigMotionComputePrincipalPoint( CFDictionaryRef metadataDict,
											    float sensorPixelsPerMicron,
											    float scalingFactorPixel2Pixel,
											    double framePTS,
											    int32_t pixelBufferWidth,
											    int32_t pixelBufferHeight,
											    int32_t sensorBinningFactorHorizontal,
											    int32_t sensorBinningFactorVertical,
											    Boolean hasSphere,
											    CGPoint *adjustedPrincipalPointOut );

/*!
	@function	FigMotionComputeDistortionCenter
	@abstract	This function computes distortion center within a reference dimension.
	@param	metadataDict				Metadata dictionary
	@param	sensorPixelsPerMicron		Reciprocal of the sensor pixel size in microns (i.e. 1/1.2 for a sensor with 1.2 micron pixels).
	@param	scalingFactorPixel2Pixel	The scaling factor from sensor pixels to frame pixels. This can be calculated using FigMotionComputeLensPositionScalingFactor(). For binned modes, the sensor pixel refers to the original sensor pixel prior to binning.
	@param	framePTS					The frame Presentation Time Stamp.
	@param	referenceDimensionWidth		Reference dimension width.
	@param	referenceDimensionHeight	Reference dimension height.
	@param	sensorBinningFactorHorizontal  Sensor binning factor in horizontal direction.
	@param	sensorBinningFactorVertical	   Sensor binning factor in vertical direction.
	@param	distortionCenterOut			The distortion center.
 */
extern OSStatus FigMotionComputeDistortionCenter( CFDictionaryRef metadataDict,
												float sensorPixelsPerMicron,
												float scalingFactorPixel2Pixel,
												double framePTS,
												int32_t referenceDimensionWidth,
												int32_t referenceDimensionHeight,
												int32_t sensorBinningFactorHorizontal,
												int32_t sensorBinningFactorVertical,
												CGPoint *distortionCenterOut );


/*!
    @function    FigMotionFindBestPerspectiveTransform
    @abstract    Limits a perspective transform so that all pixels in the specified output rectangle
                 fetch valid input pixels. The transform is limited by interpolating it with a centered
                 scaling transform of equal scaling factor.

    @param      transformInOut          Input/output perspective transform from the output to input images, consisting
                                        of 9 coefficients in row-major order. Coefficients are updated if the transform is limited.

    @param      digitalZoom             The digital zoom from the input image to the output one, it must be equal to the inverse of the zoom
                                        factor already applied to transformInOut (since the transform is expressed from output to input).
                                        It is used to interpolate transformInOut with the centered scaling matrix of scaling factor
                                        1 / digitalZoomApplied.
                                        It must be no smaller than the minimum zoom factor computed by FindMinimumZoomFactor(), otherwise
                                        even the centered scaling matrix won't fit within the overcan and the function will fail.

    @param      validInputRect          Pointer to the valid region rectangle of the input buffer in the input CVPixelBuffer coordinate system.
                                        If all pixels are valid it is equal to CGRectMake( 0, 0, inputDimensions.width, inputDimensions.height )

    @param      outputRect              Pointer to the output rectangle in the input CVPixelBuffer coordinate system.

    @param      forceAffineTransform    When set to true, transformInOut is simplified to an affine transform.

    @param      limitFactorOut          Indicates how much of transformInOut was preserved, the updated transform is equal to:
                                             limitFactorOut * transformInOut + (1-limitFactorOut) * CenteredScalingTransform

    @result     noErr on success, a negative value otherwise.
*/
OSStatus FigMotionFindBestPerspectiveTransform(	Float32 *transformInOut,
												const Float32 digitalZoom,
												const FigMotionRect *validInputRect,
												const FigMotionRect *outputRect,
												const bool forceAffineTransform,
												Float32 *limitFactorOut );

/*!
	@function    FigMotionComputeMinimumZoomFactor
	@abstract    Given an input image and a centered output crop, the function returns the minimum zoom factor that
                 can be applied to the input image in order to only have valid input pixels in the output crop region.
                 The same safety margin as FigMotionFindBestPerspectiveTransform is used during computations (i.e. FIGMOTION_TRANSFORM_LIMIT_MARGIN).

	@param       inputDimensions       Pointer to the input buffer dimensions.
	@param       centeredOutputRect    Pointer to a centered output crop rectangle in the input CVPixelBuffer coordinate system.
	@result      A floating point value representing the minimum zoom factor we can apply.
*/
float FigMotionComputeMinimumZoomFactor( const FigMotionSize *inputDimensions, const FigMotionRect *centeredOutputRect );

/*!
	@function     ComputePerspectiveProjectedPoint
	@abstract     This function computes the floating point location of the transformed point.
	@param        vc       A vector of 9 coefficients representing the transformation matrix
	@param        input   The point being transformed
	@param        	pxp     Pointer to the transformed point x location. The pointer cannot be NULL.
	@param        	pyp     Pointer to the transformed point y location. The pointer cannot be NULL.
 */
extern void ComputePerspectiveProjectedPoint( Float32  *vc, FigMotionPoint input, Float32  *pxp, Float32  *pyp );


#if ! FIG_DISABLE_ALL_EXPERIMENTS && TARGET_OS_IPHONE
// Save ISP strip parameters into a binary file per frame and print out the parameters as well.
extern OSStatus FigMotionLogISPStripParameters( int frameIdx, FigCaptureISPProcessingSessionParameterVideoStabilization *visStripParams );
#endif

// Set identity transform
static __inline__ void setIdentityTransform( Float32 *vector )
{
	vector[0] = 1.0f;
	vector[1] = 0.0f;
	vector[2] = 0.0f;
	vector[3] = 0.0f;
	vector[4] = 1.0f;
	vector[5] = 0.0f;
	vector[6] = 0.0f;
	vector[7] = 0.0f;
	vector[8] = 1.0f;
}

// Force translation only and integer translation only transforms
static __inline__ void forceTranslationOnlyTransform( Float32 *vector, bool integerOnly )
{
	vector[0] = 1.0f;
	vector[1] = 0.0f;
	vector[3] = 0.0f;
	vector[4] = 1.0f;
	vector[6] = 0.0f;
	vector[7] = 0.0f;
	vector[8] = 1.0f;
	
	if ( integerOnly ) {
		vector[2] = roundf( vector[2] );
		vector[5] = roundf( vector[5] );
	}
}

static __inline__ CGPoint computeRectCenter( const FigMotionRect *rect )
{
	CGPoint center;
	center.x = (CGFloat)rect->origin.x + ( (CGFloat)rect->size.width  - 1.0f ) * 0.5f;
	center.y = (CGFloat)rect->origin.y + ( (CGFloat)rect->size.height - 1.0f ) * 0.5f;
	return center;
}

// checks sysctl for dev boards to extrapolate whether we have a functional motion system
extern Boolean FigMotionHardwareAvailable( void );

void FigMotionApplyDigitalZoomToTransform( float digitalZoomFactor, double imageCenterX, double imageCenterY, Float32 *vectorInOut );

#endif  // _FIG_MOTION_PROCESSING_UTILITIES_H_
