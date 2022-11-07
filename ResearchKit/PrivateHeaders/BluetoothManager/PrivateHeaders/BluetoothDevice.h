//
//  BluetoothDevice.h
//  Bluetooth Settings
//
//  Created by jsantamaria on 2/12/07
//  Copyright 2007 Apple Inc. All rights reserved.
//
//  This was originally developed for SkankPhone and
//  adapted for Heavenly settings

#import <Foundation/Foundation.h>
#import "BTDevice.h"
#import "BTAccessory.h"

#define BT_DEV_CLASS_MAJOR_DEVICE_MASK  0x001F00    /**< Bits 8-12 contain major device class value. */
#define BT_DEV_CLASS_MINOR_DEVICE_MASK  0x0000FC    /**< Bits 2-7 contain minor device class value. */
#define BT_MAJOR_DEVICE_CLASS(x) ((x) << 8)
#define BT_MINOR_DEVICE_CLASS(x) ((x) << 2)

#define GYRO_INFO_LEFT_BUD_IS_JAMMED    "GYRO_INFO_LEFT_BUD_IS_JAMMED"
#define GYRO_INFO_RIGHT_BUD_IS_JAMMED   "GYRO_INFO_RIGHT_BUD_IS_JAMMED"
#define GYRO_INFO_VERSION               "GYRO_INFO_VERSION"

typedef struct {
    BOOL supported;
    BOOL enabled;
    BOOL favorites;
    BOOL recents;
    BOOL userPermissionGranted;
} BluetoothDeviceSyncSettings;

@interface BluetoothDevice : NSObject {
    NSString *_name;
    NSString *_productName;
    NSString *_address;
    BTDevice _device;
    BTServiceMask   _connectingServiceMask;
}

- (id) initWithDevice:(BTDevice)device address:(NSString *)address;
- (id) copyWithZone:(NSZone *)zone;
- (NSComparisonResult) compare:(BluetoothDevice *)other;
- (void) dealloc;

- (BTDevice) device;
- (void) setDevice:(BTDevice)device;

- (NSString *) name;
- (NSString *) productName;
- (NSString *) address;
- (BTDeviceType) type;
- (uint32_t) majorClass;
- (uint32_t) minorClass;
- (NSString *) description;
- (NSString *) scoUID;
- (NSString *) aclUID;
- (uint32_t) vendorId;
- (uint32_t) productId;

- (BOOL) paired;
- (BOOL) cloudPaired;
- (BOOL) magicPaired;
- (BOOL) isTemporaryPaired;
- (BOOL) connected;
- (NSUInteger) connectedServices;
- (NSUInteger) connectedServicesCount;
- (BOOL) supportsBatteryLevel;
- (int) batteryLevel;
//- (BOOL) batteryStatus:(BTDeviceBatteryStatus *)status;

- (BOOL) setIsHidden:(BOOL) hidden;
- (BOOL) inEarDetectEnabled;
- (BOOL) setInEarDetectEnabled:(BOOL) enabled;
- (BOOL) setSpatialAudioMode:(uint8_t)spMode;
- (uint8_t) spatialAudioMode;
- (BOOL) spatialAudioConfig:(NSString *)bundleID spatialMode:(BTAccessorySpatialModeType *)mode headTracking:(BOOL *)headTracking;
- (BOOL) headTrackingAvailable;
- (BOOL) setSpatialAudioConfig:(NSString *)bundleID spatialMode:(BTAccessorySpatialModeType )mode headTracking:(BOOL)headTracking;
- (BOOL) setSpatialAudioAllowed:(BOOL) enabled;
- (BOOL) spatialAudioAllowed;
- (BOOL) spatialAudioActive;
- (uint32_t) micMode;
- (BOOL) setMicMode:(uint32_t) mode;
- (uint32_t) doubleTapAction;
- (uint32_t) doubleTapActionEx: (uint32_t *)leftAction rightAction:(uint32_t *)rightAction;
- (BOOL) setDoubleTapAction:(uint32_t) action;
- (BOOL) setDoubleTapActionEx: (uint32_t)leftAction rightAction:(uint32_t)rightAction;
- (uint32_t) doubleTapCapability;
- (BOOL) featureCapability:(FeatureDBEntry_t)feature;
- (uint32_t) listeningMode;
- (BOOL) setListeningMode:(uint32_t)mode;
- (BOOL) inEarStatusPrimary:(BTAccessoryInEarStatus *)primary secondary:(BTAccessoryInEarStatus *)secondary;
- (uint32_t) listeningModeConfigs;
- (BOOL) setListeningModeConfigs:(uint32_t)modeConfigs;
- (BTAccessoryUIGestureMode) singleClickMode;
- (BOOL) setSingleClickMode:(BTAccessoryUIGestureMode)mode;
- (BTAccessoryUIGestureMode) doubleClickMode;
- (BOOL) setDoubleClickMode:(BTAccessoryUIGestureMode)mode;

// clickHoldModes: and clickHoldMode:rightAction: are identical except that clickHoldModes: includes the 2 extra bytes sent by the accessory.
// The accessory sends over a uint32_t, and the 2 most significant bytes are used by some Beats products to send previous click hold modes.
// The values of prevRightMode and prevLeftMode as returned by clickHoldModes: for non-Beats products is undefined.
- (uint32_t) clickHoldModes:(BTAccessoryUIGestureModeInformation *)clickHoldModes;
- (BOOL) setClickHoldModes:(BTAccessoryUIGestureModeInformation)clickHoldModes;

- (uint32_t) clickHoldMode:(BTAccessoryUIGestureMode *)leftMode rightAction:(BTAccessoryUIGestureMode *)rightMode;
- (BOOL) setClickHoldMode:(BTAccessoryUIGestureMode)leftMode rightMode:(BTAccessoryUIGestureMode)rightMode;
#if !RC_HIDE_B515
- (BTAccessoryCrownRotationDirection) crownRotationDirection;
- (BOOL) setCrownRotationDirection:(BTAccessoryCrownRotationDirection)crownRotationDir;
#endif
#ifdef ENABLE_LIVE_LISTEN_VERSIONING
- (BOOL) setLiveListenVersion:(BTAccessoryLiveListenVersion)mode;
#endif // ENABLE_LIVE_LISTEN_VERSIONING
#if !RC_HIDE_B372
- (BTAccessoryGenericConfigMode) autoAnswerMode;
- (BOOL) setAutoAnswerMode:(BTAccessoryGenericConfigMode)mode;
#endif
- (BTAccessoryChimeVolume)chimeVolume;
- (BOOL) setChimeVolume:(BTAccessoryChimeVolume)chimeVolume;
- (uint32_t) SendSetupCommand:(uint8_t) operationType;
- (BTAccessorySettingFeatureBitMask) accessorySettingFeatureBitMask;
- (BOOL) pairedDeviceNameUpdated;
- (NSDictionary *) accessoryInfo;
- (BOOL) getAACPCapabilityBit:(BTAccessoryAACPCapabilityBit)bit;
- (NSData *) getAACPCapabilityBits;
- (uint32_t) getAACPCapabilityInteger:(BTAccessoryAACPCapabilityInteger)index;

- (BOOL) isAccessory;
- (BOOL) isServiceSupported:(BTServiceID)service;
- (NSString *) getServiceSetting:(BTServiceID)service key:(NSString *)key;
- (void) setServiceSetting:(BTServiceID)service key:(NSString *)key value:(NSString *)value;

- (void) connect;
- (void) connectWithServices:(BTServiceMask)services;
- (void) disconnect;
- (void) setPIN:(NSString *) pin;
- (void) acceptSSP:(NSInteger)error;
- (void) unpair;
- (void) startVoiceCommand;
- (void) endVoiceCommand;

- (BluetoothDeviceSyncSettings) syncSettings;
- (void) setSyncSettings:(BluetoothDeviceSyncSettings)settings;
- (NSArray *) syncGroups;
- (void) setSyncGroup:(int)groupID enabled:(BOOL)enabled;

- (BOOL) isAppleAudioDevice;
- (BOOL) supportsHS;
- (BOOL) isProController;

- (BOOL) setUserName:(NSString *)name;
- (void) setConnectingServicemask:(BTServiceMask)servicemask;
- (BTServiceMask) getConnectingServiceMask;

- (BTLowSecurityStatus) getLowSecurityStatus;
- (BTHIDDeviceBehavior) getBehaviorForHIDDevice;

- (BOOL) setSmartRouteMode:(uint8_t) srMode;
- (uint8_t) smartRouteMode;
- (BOOL) smartRouteSupport;

- (uint8_t) getSpatialAudioPlatformSupport;
- (BOOL) getDeviceSoundProfileSupport;
- (BOOL) getDeviceSoundProfileAllowed;
- (void) setDeviceSoundProfileAllowed:(BOOL) enable;

- (BTAccessoryStereoHFPStatus) getStereoHFPSupport;

//- (BTUserSelectedDeviceType) getUserSelectedDeviceType;
//- (BOOL) setUserSelectedDeviceType:(BTUserSelectedDeviceType)type;

- (NSDictionary *) gyroInformation;

- (BTResult) getHexDeviceAddress:(BTDeviceAddress *)address;

- (BTResult) getDeviceColor:(uint32_t *)color;

#if APPLE_FEATURE_COUNTERFEIT_DETECTION
- (BOOL) isGenuineAirPods;
#endif // APPLE_FEATURE_COUNTERFEIT_DETECTION

- (BTAccessoryCallManagementMessage) getCallManagementConfig;
- (BOOL) setCallConfig:(BTAccessoryCallManagementMessage)config;

@end
