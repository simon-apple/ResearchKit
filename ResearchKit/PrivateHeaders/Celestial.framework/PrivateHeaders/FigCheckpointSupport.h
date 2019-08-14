/*
    File:          FigCheckpointSupport.h

    Description:   Produces Checkpoint dictionary for MobileCheckpointd

    Author:        Michel Rynderman

    Copyright:     © Copyright 2017-2018 Apple Computer, Inc. All rights reserved.

	$Id: $
	$Log$
	22aug2018 rsimutis
	<rdar://problem/43243459> ANALYZER FIX FEST: Remove unused instance variable '_priv'. <mrynderman>

	05apr2018 alexb
	<rdar://problem/33064947> Ensure header files include CMBasePrivate.h or CMBaseInternal.h. <jdecoodt>

	02mar2017 mrynderman
	<rdar://problem/29601020> Add HEVC additions to checkpoint <turnquist>
 
	01feb2017 mrynderman
	<rdar://problem/14421081> CoreMedia should provide SPI to back the media-related portions of the checkpoint plist. Initial Checkin <jsam>
*/

#import <CoreMedia/CMBasePrivate.h>
#import <Foundation/Foundation.h>

#if TARGET_OS_IOS
@interface FigCheckpointSupport : NSObject
{
}

+ (NSDictionary*)makeDictionary;

@end
#endif
