/*
 	File:				BWPersonSemanticsInferenceConfiguration.h
 	Description: 		BWInferenceConfiguration subclass for Person Semantics
 	Author:				Tuomas Viitanen
 	Creation Date:		12/5/2018
 	Copyright: 			© Copyright 2018-2019 Apple, Inc. All rights reserved.
*/

#import "BWInferenceConfiguration.h"
#import "BWInferenceIntegration.h"

#if FIG_CAPTURE_SEMANTIC_SEGMENTATION_ENABLED

typedef NS_OPTIONS( uint32_t, BWPersonSemantic )
{
	BWPersonSemanticPerson = ( 1 << 0 ),
	BWPersonSemanticHair   = ( 1 << 1 ),
	BWPersonSemanticSkin   = ( 1 << 2 ),
	BWPersonSemanticTeeth  = ( 1 << 3 ),
};

@interface BWPersonSemanticsConfiguration : BWInferenceConfiguration

#pragma Versioning

/*!
 @method semanticsVersion
 @abstract Returns the version of Person Semantics which should be used
*/
+ (BWInferenceVersion)semanticsVersion;

#pragma Configuration

/*!
 @property enabledSemantics
 @abstract Property defining which semantics are enabled in the person semantic segmentation.
*/
@property(nonatomic, assign) BWPersonSemantic enabledSemantics; // default 0 (i.e. None)

@end

#endif // FIG_CAPTURE_SEMANTIC_SEGMENTATION_ENABLED
