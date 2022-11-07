//
//  BluetoothManager.h
//  Bluetooth Settings
//
//  Created by jsantamaria on 2/12/07
//  Copyright 2007 Apple Inc. All rights reserved.
//
//  This was originally developed for SkankPhone and
//  adapted for Heavenly settings

#import <Foundation/Foundation.h>

#import "BTSession.h"
#import "BTDiscovery.h"
#import "BTPairing.h"
#import "BTAccessory.h"

#define BLUETOOTH_POWER_NOTIFICATION CFSTR("com.apple.bluetooth.power-changed")

// Local device status notifications
extern NSString * const BluetoothAvailabilityChangedNotification;				// object is NSNumber boolean
extern NSString * const BluetoothPowerChangedNotification;						// object is BluetoothManager
extern NSString * const BluetoothConnectabilityChangedNotification;				// object is BluetoothManager
extern NSString * const BluetoothDiscoveryStateChangedNotification;				// object is BluetoothManager
extern NSString * const BluetoothAdvertisingStateChangedNotification;			// object is BluetoothManager
extern NSString * const BluetoothBlacklistStateChangedNotification;				// object is BluetoothManager
extern NSString * const BluetoothFirstDeviceUnlockCompleted;                    // object is BluetoothManager

// User-initiated discovery notifications
extern NSString * const BluetoothDeviceDiscoveredNotification;					// object is BluetoothDevice
extern NSString * const BluetoothDeviceUpdatedNotification;						// object is BluetoothDevice
extern NSString * const BluetoothDeviceRemovedNotification;						// object is BluetoothDevice
extern NSString * const BluetoothDeviceChangedNotification;						// object is BluetoothDevice
extern NSString * const BluetoothDiscoveryStoppedNotification;					// object is BluetoothManager

// Connection status notifications
extern NSString * const BluetoothDeviceConnectSuccessNotification;				// object is BluetoothDevice
extern NSString * const BluetoothDeviceConnectFailedNotification;				// object is BluetoothDevice
extern NSString * const BluetoothConnectionStatusChangedNotification;			// object is connection status
extern NSString * const BluetoothDeviceDisconnectSuccessNotification;			// object is BluetoothDevice
extern NSString * const BluetoothDeviceDisconnectFailedNotification;			// object is BluetoothDevice

// Authentication notifications
extern NSString * const BluetoothPairingPINRequestNotification;					// object is BluetoothDevice
extern NSString * const BluetoothPairingPINResultSuccessNotification;			// object is BluetoothDevice
extern NSString * const BluetoothPairingPINResultFailedNotification;			// object is BluetoothDevice
extern NSString * const BluetoothPairingUserConfirmationNotification;			// object is BluetoothDevice
extern NSString * const BluetoothPairingUserNumericComparisionNotification;		// object is NSDictionary with @"device" and @"value" key
extern NSString * const BluetoothPairingPassKeyDisplayNotification;				// object is NSDictionary with @"device" and @"value" key

// Misc. notifications
extern NSString * const BluetoothDeviceSupportsContactSyncNotification;			// object is BluetoothDevice
extern NSString * const BluetoothDeviceSupportsMAPClientNotification;			// object is BluetoothDevice
extern NSString * const BluetoothDeviceBatteryChangedNotification;				// object is BluetoothDevice
extern NSString * const BluetoothHandsfreeInitiatedVoiceCommand;				// object is BluetoothDevice
extern NSString * const BluetoothHandsfreeEndedVoiceCommand;					// object is BluetoothDevice
extern NSString * const BluetoothDeviceUnpairedNotification;					// object is BluetoothDevice
extern NSString * const BluetoothPairedStatusChangedNotification;				// object is BluetoothManager
extern NSString * const BluetoothMagicPairedDeviceNameChangedNotification;      // object is BluetoothDevice
extern NSString * const BluetoothStateChangedNotification;						// object is BluetoothManager

// High Power
extern NSString * const BluetoothHighPowerEnabled;								// object is BluetoothDevice
extern NSString * const BluetoothHighPowerDisabled;								// object is BluetoothDevice

// Accessory notifications
extern NSString * const BluetoothAccessoryInEarStatusNotification;				// object is NSDictionary with @"device", @"primaryInEarStatus", and @"secondaryInEarStatus" keys
extern NSString * const BluetoothAccessorySealValueStatusNotification;			// object is NSDictionary with @"device", @"sealLeft", and @"sealRight" keys
extern NSString * const BluetoothAccessorySettingsChanged;						// object is NSDictionary with @"device"

// Dictionary keys for notifications
extern NSString * const BluetoothErrorKey;
extern NSString * const BluetoothNotificationNameKey;

typedef enum {
	BluetoothAvailableStateUnavailable,
	BluetoothAvailableStateInTransition,
	BluetoothAvailableStateAvailable
} BluetoothAvailableState;

typedef enum {
	BluetoothPowerStateOff,
	BluetoothPowerStateTransitioning,
	BluetoothPowerStateOn
} BluetoothPowerState;

typedef enum {
	BluetoothUnavailable,
	BluetoothPoweredOff,
	BluetoothDisconnected,
	BluetoothConnected,
	BluetoothBusy,
} BluetoothState;

typedef void (^BluetoothUserActionCompletionHandler)(BluetoothState state);

@class BluetoothDevice;

@interface BluetoothManager : NSObject
{
	BTLocalDevice			_localDevice;
	BTSession				_session;
	BluetoothAvailableState	_available;
	BluetoothState			_state;

	BOOL					_airplaneMode;
	BOOL					_audioConnected;
	BOOL					_scanningEnabled;
	BOOL					_scanningInProgress;
	BTServiceMask			_scanningServiceMask;

	BTDiscoveryAgent		_discoveryAgent;
	BTPairingAgent			_pairingAgent;
	BTAccessoryManager		_accessoryManager;

	NSMutableDictionary		*_btAddrDict;				// map from MAC addr -> BluetoothDevice
	NSMutableDictionary		*_btDeviceDict;				// map from BTDevice -> BluetoothDevice
}

+ (void) setSharedInstanceQueue:(dispatch_queue_t)queue;
+ (BluetoothManager *) sharedInstance;
+ (BTResult) lastInitError;

- (BOOL) available;
- (BOOL) enabled;
- (BOOL) setEnabled:(BOOL)enable;

// Event masks
- (BTResult) maskLocalDeviceEvents:(BTLocalDeviceEventMask)mask;

// Local Device
- (NSString *) localAddress;
- (void) showPowerPrompt;
- (BOOL) powered;
- (BluetoothPowerState) powerState;
- (BOOL) setPowered:(BOOL) powered;
- (BOOL) isServiceSupported:(BTServiceID)service;
- (BOOL) isAnyoneScanning;
- (BOOL) isAnyoneAdvertising;

// Discovery
- (void) scanForServices:(BTServiceMask)services;
- (void) scanForConnectableDevices:(BTServiceMask)services;
- (void) setDeviceScanningEnabled:(BOOL)enabled;
- (BOOL) deviceScanningEnabled;
- (BOOL) deviceScanningInProgress;
- (BOOL) wasDeviceDiscovered:(BluetoothDevice *)device;
- (void) resetDeviceScanning;

- (void) setDevicePairingEnabled:(BOOL) enabled;
- (BOOL) devicePairingEnabled;
- (void) cancelPairing;

- (NSArray *) connectingDevices;
- (NSArray *) connectedDevices;
- (NSArray *) pairedDevices;
- (BOOL) connected;

// Discoverable
- (BOOL) isDiscoverable;
- (void) setDiscoverable:(BOOL)state;

- (BOOL) blacklistEnabled;
- (void) setBlacklistEnabled:(BOOL)enabled;

// Connectable
- (BOOL) connectable;
- (void) setConnectable:(BOOL)state;

// audio
- (void) startVoiceCommand:(BluetoothDevice *)device;
- (void) endVoiceCommand:(BluetoothDevice *)device;
- (NSArray *) pairedNonAppleHAEDevices;

// test mode
- (void) enableTestMode;

- (void) postNotification:(NSString *)noteName;
- (void) postNotificationName:(NSString *)noteName object:(id)object;
- (void) postNotificationName:(NSString *)noteName object:(id)object error:(NSNumber *)error;

- (BluetoothDevice *)addDeviceIfNeeded:(BTDevice)device;

// Control center state management
- (BluetoothState) bluetoothState;
- (void) bluetoothStateActionWithCompletion:(BluetoothUserActionCompletionHandler)handler;
- (void) bluetoothStateAction NS_DEPRECATED_IOS(11_0, 11_0, "Use bluetoothStateActionWithCompletion: instead");

// Control center bluetooth helper methods
- (NSArray *) connectedDeviceNamesThatMayBeBlacklisted;

// Cross transport devices
- (BluetoothDevice *) deviceFromIdentifier:(NSUUID *)identifier;
@end

@interface BluetoothManager (BluetoothDeviceOnly)
- (void)unpairDevice:(BluetoothDevice *)device;
- (void)connectDevice:(BluetoothDevice *)device;
- (void)connectDevice:(BluetoothDevice *)device withServices:(BTServiceMask)services;
- (void)disconnectDevice:(BluetoothDevice *)device;
- (void)setPincode:(NSString *)pincode forDevice:(BluetoothDevice *)device;
- (void)acceptSSP:(NSInteger)error forDevice:(BluetoothDevice *)device;
@end

NSString *AddressForBTDevice(BTDevice device);
