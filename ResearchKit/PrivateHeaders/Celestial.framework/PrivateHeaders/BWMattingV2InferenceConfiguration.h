/*
 	File:				BWMattingV2InferenceConfiguration.h
 	Description: 		Data structure for customizing MattingV2 inference
 	Author:				Tuomas Viitanen
 	Creation Date:		12/20/18
 	Copyright: 			© Copyright 2018-2019 Apple, Inc. All rights reserved.
 */

#import "BWMattingInferenceConfiguration.h"

#if FIG_CAPTURE_SEMANTIC_SEGMENTATION_ENABLED

// This enum is a redefinition of FigMattingTuningConfiguration (FigMatting.h) for BW.
typedef NS_ENUM( int32_t, BWMattingTuningConfiguration )
{
	BWMattingTuningConfigurationFast = 1,
	BWMattingTuningConfigurationFine = 2,
};

// This bitfield is a redefinition of FigMattingOutput (FigMatting.h) for BW.
typedef NS_OPTIONS( uint32_t, BWMattingOutputType )
{
	BWMattingOutputTypeRefinedDepth	= ( 1 << 0 ), // Requires BWMattingOutputTypePerson and depth to be enabled
	BWMattingOutputTypePerson		= ( 1 << 1 ),
	BWMattingOutputTypeHair			= ( 1 << 2 ),
	BWMattingOutputTypeSkin			= ( 1 << 3 ),
	BWMattingOutputTypeTeeth		= ( 1 << 4 ),
};

@class BWSensorConfiguration;

// MattingV2 does all the same things as MattingV1, but allows more flexibility on which outputs are enabled.
// And on top of that it also supports Matting for Person Semantics.

@interface BWMattingV2InferenceConfiguration : BWInferenceConfiguration

#pragma mark Accessors

/*!
 @property sensorConfigurationsByPortType
 @abstract Sensor configurations (inc. tuning parameters) by source port type.
 */
@property(nonatomic, retain) NSDictionary<NSString *, BWSensorConfiguration *> *sensorConfigurationsByPortType;

/*!
 @property enabledMattes
 @abstract Property defining which mattes are enabled.
 */
@property(nonatomic, assign) BWMattingOutputType enabledMattes;

/*!
 @property tuningConfiguration
 @abstract Determines the set of tuning parameters that the matting processor should use.
 */
@property(nonatomic, assign) BWMattingTuningConfiguration tuningConfiguration;

/*!
 @property mainImageDownscalingFactor
 @abstract The downscaling factor that should be used when determining the output resolution for the matting.
 */
@property(nonatomic, assign, readwrite) float mainImageDownscalingFactor;

/*!
 @property depthDataDeliveryEnabled
 @abstract Indicates whether Matting inference will receive depth data as input.
 */
@property(nonatomic, assign) BOOL depthDataDeliveryEnabled;

/*!
 @property metalCommandQueue
 @abstract Metal command queue for GPU processing. This enables sharing the same command queue through the still pipeline.
 */
@property(nonatomic, assign) id<MTLCommandQueue> metalCommandQueue;

@end

#endif // FIG_CAPTURE_SEMANTIC_SEGMENTATION_ENABLED
