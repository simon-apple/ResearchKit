/*
	File:			FigXPCCoding.h
	Description: 	Protocol to serialize/deserialize an object using XPC
	Author:			Geoffrey Anneheim
	Creation Date:	06/03/14
	Copyright:		© Copyright 2014 Apple, Inc. All rights reserved.
 */

#import <Foundation/Foundation.h>
#import <xpc/xpc.h>

@protocol FigXPCCoding <NSObject>

- (id)initWithXPCEncoding:(xpc_object_t)encoding;
- (xpc_object_t)copyXPCEncoding;

@end
