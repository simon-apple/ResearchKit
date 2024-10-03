//
//  HUComfortSoundsSettings.h
//  HearingUtilities
//
//  Created by Ian Fisch on 10/16/20.
//  Copyright © 2020 Apple Inc. All rights reserved.
//

#import "HearingCore.h"

#if AX_HAS_COMFORT_SOUNDS

@class AXAsset;

// typedef NS_ENUM(NSUInteger, HUComfortSoundGroup) {
//     HUComfortSoundGroupUnknown = 0,
//     HUComfortSoundGroupPinkNoise,
//     HUComfortSoundGroupWhiteNoise,
//     HUComfortSoundGroupBrownNoise,
//     HUComfortSoundGroupOcean,
//     HUComfortSoundGroupRain,
//     HUComfortSoundGroupStream,
//     
//     HUComfortSoundGroupCount
// };

@interface HUComfortSound : NSObject
@property(nonatomic, strong, readonly, nonnull) NSString *name;
// @property(nonatomic, strong, readonly, nonnull) NSURL *path;
// @property(nonatomic, assign, readonly) HUComfortSoundGroup soundGroup;
// @property(nonatomic, strong, readonly, nullable) AXAsset *asset;
// 
// + (nonnull HUComfortSound *)comfortSoundWithAsset:(nonnull AXAsset *)asset;
// + (nonnull HUComfortSound *)defaultComfortSoundForGroup:(HUComfortSoundGroup)group;
// 
// - (nonnull NSString *)localizedName;
// - (nullable NSURL *)nextFilePath;
@end

@interface HUComfortSoundsSettings : HCSettings
+ (nonnull HUComfortSoundsSettings *)sharedInstance;

@property(nonatomic, assign) BOOL comfortSoundsEnabled;
@property(nonatomic, assign) BOOL mixesWithMedia;
@property(nonatomic, assign) BOOL stopsOnLock;
@property(nonatomic, strong, nonnull) HUComfortSound *selectedComfortSound;
@property(nonatomic, assign) CGFloat relativeVolume;
@property(nonatomic, assign) CGFloat mediaVolume;
// @property(nonatomic, assign) NSTimeInterval lastEnablementTimestamp;
// 
// @property(nonatomic, assign) BOOL forceMixingBehavior;
// 
// - (BOOL)comfortSoundsAvailable;
// - (void)reset;

@end

#endif
