/*
	File:			BWSensorConfiguration.h
	Description: 	Configuration object containing sensor information
	Author:			Tuomas Viitanen
	Creation Date:	11/06/2018
	Copyright: 		© Copyright 2018 Apple, Inc. All rights reserved.
*/

#import <Foundation/Foundation.h>

@interface BWSensorConfiguration : NSObject

- (instancetype)initWithPortType:(NSString *)portType sensorIDString:(NSString *)sensorIDString sensorIDDictionary:(NSDictionary *)sensorIDDictionary cameraInfo:(NSDictionary *)cameraInfo;

@property(nonatomic, readonly) NSString *portType;
@property(nonatomic, readonly) NSString *sensorIDString;
@property(nonatomic, readonly) NSDictionary *sensorIDDictionary;
@property(nonatomic, readonly) NSDictionary *cameraInfo;

@end
