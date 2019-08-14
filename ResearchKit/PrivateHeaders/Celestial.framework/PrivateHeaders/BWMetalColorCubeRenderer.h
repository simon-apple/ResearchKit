/*
	File:			BWMetalColorCubeRenderer.h
	Description: 	<BWFilterRenderer> for providing Metal cube-based filter rendering
	Author:			Greg Abbas
	Creation Date:	04/06/17
	Copyright: 		© Copyright 2017 Apple, Inc. All rights reserved.
 */

#import "BWFilterRenderer.h"

#import <Foundation/Foundation.h>
#import <Metal/Metal.h>

@interface BWMetalColorCubeRenderer : NSObject <BWFilterRenderer>

+ (NSBundle*)bundle;

- (instancetype)initWithVideoFormat:(BWVideoFormat *)videoFormat metalCommandQueue:(id<MTLCommandQueue>)mtlCommandQueue; // NS_DESIGNATED_INITIALIZER

@end;

