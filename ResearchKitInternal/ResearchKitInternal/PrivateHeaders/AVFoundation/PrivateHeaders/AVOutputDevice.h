/*
	File:  AVOutputDevice.h
 
	Framework:  AVFoundation
 
	Copyright 2015-2019 Apple Inc. All rights reserved.
 
 */

#import <Foundation/Foundation.h>
#import "AVOutputDeviceDiscoverySession.h"
#import "AVOutputDeviceModelSpecificKeys.h"

@class AVOutputDeviceInternal;
@class AVPairedDevice;
@class AVPairedDeviceInternal;
@protocol AVOutputDeviceConfigurationModification;
@protocol AVOutputDeviceConfigurationRetrieval;
@class AVOutputDeviceAuthorizedPeer;
@class AVOutputDeviceAuthorizedPeerInternal;

// See FIG_MATCHPOINT_ENABLE

#define AVF_OBFUSCATE_MATCHPOINT	( 0 )

#if AVF_OBFUSCATE_MATCHPOINT
	#define AVF_HIDE_MATCHPOINT_SYMBOL( RealSymbol, ReplacementSymbol )	ReplacementSymbol
#else
	#define AVF_HIDE_MATCHPOINT_SYMBOL( RealSymbol, ReplacementSymbol ) RealSymbol
#endif

NS_ASSUME_NONNULL_BEGIN

/*!
 @class			AVOutputDevice
 @abstract		An instance of AVOutputDevice represents a destination for media data.
 @discussion
	Output devices are typically discovered using AVOutputDeviceDiscoverySession.  For example, if there is an AppleTV on the local network then AVOutputDeviceDiscoverySession will vend an instance of AVOutputDevice representing that AppleTV.
 */
SPI_AVAILABLE(macos(10.11), ios(9.0), tvos(9.0), watchos(2.0))
@interface AVOutputDevice : NSObject
{
@private
	AVOutputDeviceInternal		*_outputDevice;
}
AV_INIT_UNAVAILABLE

/*!
 @method		sharedLocalDevice
 @abstract		Returns an instance of AVOutputDevice that represents the endpoint of the local CLCD.
 @result
	An instance of AVOutputDevice.
 */
+ (AVOutputDevice *)sharedLocalDevice;

@end

/*!
 @protocol		AVOutputDeviceDescription
 @abstract		Properties for describing an output device
 @discussion
	An object that conforms to this protocol can be used to examine an output device but cannot be used to route to, send data to, or configure the output device.  A concrete instance of AVOutputDevice is required to perform these operations.
 */
SPI_AVAILABLE(macos(10.14.5), ios(12.3), tvos(12.3), watchos(5.2.1))
@protocol AVOutputDeviceDescription <NSObject>

/*!
 @property		deviceName
 @abstract		The name of the device.
 @discussion
	This property is not key-value observable.
 */
@property (nonatomic, readonly, nullable) NSString *deviceName;

/*!
 @property		deviceID
 @abstract		The unique identifier for the device.
 @discussion
	The value of this property may be nil. This property is not key-value observable.
 */
@property (nonatomic, readonly, nullable) NSString *deviceID;

@optional

// Future properties must be made optional, to preserve compatibility with clients implementing this protocol

@end

@interface AVOutputDevice (AVOutputDeviceDescription) <AVOutputDeviceDescription>

/*!
 @enum			AVOutputDeviceType
 @abstract		Constants describing the various types of devices represented by AVOutputDevice
 @constant		AVOutputDeviceTypeAirPlay
	An AirPlay device.
 @constant		AVOutputDeviceTypeBluetooth
	A Bluetooth device, such as Bluetooth headphones.
 @constant		AVOutputDeviceTypeCarPlay
	A CarPlay device.
 @constant		AVOutputDeviceTypeBuiltIn
	A built-in device, such as the built-in speakers on an iPhone.
 @constant		AVOutputDeviceTypeWired
	A wired device, such as wired headphones.
 */
typedef NS_ENUM(NSInteger, AVOutputDeviceType) {
	AVOutputDeviceTypeAirPlay = 0,
	AVOutputDeviceTypeBluetooth = 1,
	AVOutputDeviceTypeCarPlay SPI_AVAILABLE(macos(10.13), ios(11.0), tvos(11.0), watchos(4.0)) = 2,
	AVOutputDeviceTypeBuiltIn SPI_AVAILABLE(macos(10.13), ios(11.0), tvos(11.0), watchos(4.0)) = 3,
	AVOutputDeviceTypeWired SPI_AVAILABLE(macos(10.13), ios(11.0), tvos(11.0), watchos(4.0)) = 4
} SPI_AVAILABLE(macos(10.12), ios(11.0), tvos(11.0), watchos(4.0));

/*!
 @property		deviceType
 @abstract		The device type of an instance of AVOutputDevice.
 */
@property (nonatomic, readonly) AVOutputDeviceType deviceType SPI_AVAILABLE(macos(10.12), ios(11.0), tvos(11.0), watchos(4.0));

/*!
 @enum			AVOutputDeviceSubType
 @abstract		Constants for further refining the devices types defined by AVOutputDeviceType
 @constant		AVOutputDeviceSubTypeStandard,
	This sub type is used when there is no need to refine the device type.
 @constant		AVOutputDeviceSubTypeSpeaker,
	A speaker, such as the built-in speaker on an iPhone.
 @constant		AVOutputDeviceSubTypeHeadphones,
	A set of headphones, such as wired headphones.
 @constant		AVOutputDeviceSubTypeHeadset,
	A headset.
 @constant		AVOutputDeviceSubTypeReceiver,
	A receiver, such as the speaker that phone calls route to by default.
 @constant		AVOutputDeviceSubTypeLineOut,
	A device connected by a line out cable.
 @constant		AVOutputDeviceSubTypeUSB,
	A device connected by a USB cable.
 @constant		AVOutputDeviceSubTypeDisplayPort,
	A device connected by a Display Port cable.
 @constant		AVOutputDeviceSubTypeHDMI,
	A device connected by an HDMI cable.
 @constant		AVOutputDeviceSubTypeLowEnergy,
	A Bluetooth Low Energy device.
 @constant		AVOutputDeviceSubTypeSPDIF
	A device connected by an S/PDIF cable.
 */
/*
 @constant		AVOutputDeviceSubTypeTV
 	A television.
 */
/*
 @constant		AVOutputDeviceSubTypeHomePod
 	A HomePod.
 @constant		AVOutputDeviceSubTypeAppleTV
 	An AppleTV.
 @constant		AVOutputDeviceSubTypeVehicle
	A vehicle's head unit, usually connected via Bluetooth.
 */
typedef NS_ENUM(NSInteger, AVOutputDeviceSubType) {
	AVOutputDeviceSubTypeStandard = 0,
	AVOutputDeviceSubTypeSpeaker = 1,
	AVOutputDeviceSubTypeHeadphones = 2,
	AVOutputDeviceSubTypeHeadset = 3,
	AVOutputDeviceSubTypeReceiver = 4,
	AVOutputDeviceSubTypeLineOut = 5,
	AVOutputDeviceSubTypeUSB = 6,
	AVOutputDeviceSubTypeDisplayPort = 7,
	AVOutputDeviceSubTypeHDMI = 8,
	AVOutputDeviceSubTypeLowEnergy = 9,
	AVOutputDeviceSubTypeSPDIF = 10,
	#define AVOutputDeviceSubTypeTV AVF_HIDE_MATCHPOINT_SYMBOL( AVOutputDeviceSubTypeTV, AVOutputDeviceSubTypeAppleTV4k )
	AVOutputDeviceSubTypeTV SPI_AVAILABLE(macos(10.14), ios(12.0), tvos(12.0), watchos(5.0)) = 11,
	AVOutputDeviceSubTypeHomePod SPI_AVAILABLE(macos(10.13.4), ios(11.3), tvos(11.3), watchos(4.3)) = 12,
	AVOutputDeviceSubTypeAppleTV SPI_AVAILABLE(macos(10.13.4), ios(11.3), tvos(11.3), watchos(4.3)) = 13,
	AVOutputDeviceSubTypeVehicle SPI_AVAILABLE(macos(10.15.1), ios(13.2), tvos(13.1), watchos(6.1)) = 14,
} SPI_AVAILABLE(macos(10.13), ios(11.0), tvos(11.0), watchos(4.0));

/*!
 @property		deviceSubType
 @abstract		The device sub type of an instance of AVOutputDevice.
 */
@property (nonatomic, readonly) AVOutputDeviceSubType deviceSubType SPI_AVAILABLE(macos(10.13), ios(11.0), tvos(11.0), watchos(4.0));

/*!
 @property		manufacturer
 @abstract		The manufacturer of the output device.
 @discussion
	May be nil if the output device does not have manufacturer information.  The manufacturer name is not localized.
 */
@property (nonatomic, readonly, nullable) NSString *manufacturer SPI_AVAILABLE(macos(10.13.2), ios(11.2), tvos(11.2), watchos(4.2));

/*!
 @property		modelID
 @abstract		The model identifier of the output device.
 @discussion
	It may be nil if the output device does not have model information.
 */
@property (nonatomic, readonly, nullable) NSString *modelID SPI_AVAILABLE(macos(10.12), ios(11.0), tvos(11.0), watchos(4.0));

/*!
 @property		serialNumber
 @abstract		The serial number of the output device.
 @discussion
	May be nil if the output device does not have serial number information.
 */
@property (nonatomic, readonly, nullable) NSString *serialNumber SPI_AVAILABLE(macos(10.13.2), ios(11.2), tvos(11.2), watchos(4.2));

/*!
 @property		firmwareVersion
 @abstract		The firmware version of the output device.
 @discussion
	May be nil if the output device does not have firmware version information.
 */
@property (nonatomic, readonly, nullable) NSString *firmwareVersion SPI_AVAILABLE(macos(10.13.2), ios(11.2), tvos(11.2), watchos(4.2));

/*!
 @property		identifyingMACAddress
 @abstract		A MAC address that can be used to identify the output device.
 @discussion
	This property may be nil if the output device does not have any MAC addresses.
 */
@property (nonatomic, readonly, nullable) NSData *identifyingMACAddress SPI_AVAILABLE(macos(10.13), ios(11.0), tvos(11.0), watchos(4.0));

@end

@interface AVOutputDevice (AVOutputDeviceStatus)

/*!
 @property		hasBatteryLevel
 @abstract		Indicates whether the output device has battery level information.
 @discussion
	The value of this property is a BOOL indicating whether the output device has battery level information. The output device's batteryLevel property should only be accessed when this property is YES.
 */
@property (nonatomic, readonly) BOOL hasBatteryLevel SPI_AVAILABLE(macos(10.12), ios(11.0), tvos(11.0), watchos(4.0));

/*!
 @property		batteryLevel
 @abstract		Indicates the output device's current battery level as a float value.
 @discussion
	The value of this property is a float from 0.0 (empty) to 1.0 (full) indicating the output device's battery level. If hasBatteryLevel property is NO, behavior is undefined when this property is read.
 */
@property (nonatomic, readonly) float batteryLevel SPI_AVAILABLE(macos(10.12), ios(11.0), tvos(11.0), watchos(4.0));

/*!
 @property		modelSpecificInformation
 @abstract		Contains the output device's model specific information.
 @discussion
	If the output device has no model-specific information, it returns an empty dictionary. See AVOutputDeviceModelSpecificKeys.h for keys.
 */
@property (nonatomic, readonly, nullable) NSDictionary<AVOutputDeviceModelSpecificKey, id> *modelSpecificInformation SPI_AVAILABLE(macos(10.12), ios(11.0), tvos(11.0), watchos(4.0));

/*!
 @property		airPlayProperties
 @abstract		Provides a dictionary of AirPlay-specific properties for the output device.
 @discussion
	Dictionary keys can be found in <AirPlaySupport/APSEndpointProperties.h>.  If the device does not have AirPlay properties (e.g. because it is a Bluetooth device), the value of this property will be nil.
 */
@property (nonatomic, readonly, nullable) NSDictionary *airPlayProperties SPI_AVAILABLE(macos(10.13.5), ios(11.4), tvos(11.4), watchos(4.3));

/*!
 @property		inUseByPairedDevice
 @abstract		Indicates whether the AVOutputDevice has been picked as a destination for media data on another device that is paired with the current device.
 @discussion
	For example, if the current process is running on an iPhone and the output device represented by the receiver is picked on an Apple Watch that is paired with this iPhone, this property will return YES.
 
	To get more information about paired devices, see +[AVPairedDevice pairedDevicesConnectedToOutputDevice:].
 */
@property (nonatomic, readonly, getter=isInUseByPairedDevice) BOOL inUseByPairedDevice SPI_AVAILABLE(macos(10.13), ios(11.0), tvos(11.0), watchos(4.0));

@end

@interface AVOutputDevice (AVOutputDeviceCapabilities)

/*!
 @property		deviceFeatures
 @abstract		A bitmask indicating the combination of features supported by the receiver.
 */
@property (nonatomic, readonly) AVOutputDeviceFeatures deviceFeatures SPI_AVAILABLE(macos(10.13), ios(11.0), tvos(11.0), watchos(4.0));

/*!
 @property		requiresAuthorization
 @abstract		Indicates whether the receiver requires authorization.
 */
@property (nonatomic, readonly) BOOL requiresAuthorization SPI_AVAILABLE(macos(10.13), ios(11.0), tvos(11.0), watchos(4.0));

/*!
 @property		automaticallyAllowsConnectionsFromPeersInHomeGroup
 @abstract		Indicates whether the output device automatically allows connections from peers in the "home" group.
 @discussion
	When the value of this property is YES, an authorized peer in the "home" group can connect to the device without triggering an authorization request.  Authorized peers can be set up using -configureUsingBlock:options:completionHandler:.
 */
@property (nonatomic, readonly) BOOL automaticallyAllowsConnectionsFromPeersInHomeGroup SPI_AVAILABLE(macos(10.13.5), ios(11.4), tvos(11.4), watchos(4.3));

/*!
 @property		onlyAllowsConnectionsFromPeersInHomeGroup
 @abstract		Indicates whether the output device only allows connections from peers in the "home" group.
 @discussion
	When the value of this property is YES, connections to the output device are only allowed by authorized peers in the "home" group (i.e. password/PIN auth is turned off).  Authorized peers can be set up using -configureUsingBlock:options:completionHandler:.
 */
@property (nonatomic, readonly) BOOL onlyAllowsConnectionsFromPeersInHomeGroup SPI_AVAILABLE(macos(10.13.5), ios(11.4), tvos(11.4), watchos(4.3));

/*!
 @property		canAccessRemoteAssets
 @abstract		Indicates whether the receiver can access remote assets.
 @discussion
	Access to a remote asset (i.e. an asset stored neither on the AVOutputDevice itself nor the current device) typically requires a connection to the internet.
 */
@property (nonatomic, readonly) BOOL canAccessRemoteAssets SPI_AVAILABLE(macos(10.13), ios(11.0), tvos(11.0), watchos(4.0));

/*!
 @property		canAccessAppleMusic
 @abstract		Indicates whether the output device is configured with the ability to access Apple Music content.
 @discussion
	For example, this property will be YES if the device is signed in to an iTunes account that is subscribed to Apple Music.
 */
@property (nonatomic, readonly) BOOL canAccessAppleMusic SPI_AVAILABLE(macos(10.13.5), ios(11.4), tvos(11.4), watchos(4.3));

/*!
 @property		canAccessiCloudMusicLibrary
 @abstract		Indicates whether the output device is configured with the ability to access the user's iCloud Music Library.
	For example, this property will be YES if the device is signed in to an iTunes account that is subscribed to iTunes Match or Apple Music.
 */
@property (nonatomic, readonly) BOOL canAccessiCloudMusicLibrary SPI_AVAILABLE(macos(10.13.5), ios(11.4), tvos(11.4), watchos(4.3));

/*!
 @property		supportsBufferedAirPlay
 @abstract		Indicates whether the output device supports buffered AirPlay.
 */
@property (nonatomic, readonly) BOOL supportsBufferedAirPlay SPI_AVAILABLE(macos(10.13.5), ios(11.4), tvos(11.4), watchos(4.3));

/*!
 @property		canPlayEncryptedProgressiveDownloadAssets
 @abstract		Indicates whether the output device can play non-HLS encrypted content stored on a remote server.
 @discussion
	If the value of this property is NO, and AVPlayer is being used to play an encrypted progressive-download asset, setting AVPlayer's allowsExternalPlayback property to NO may help avoid playback errors.
 */
@property (nonatomic, readonly) BOOL canPlayEncryptedProgressiveDownloadAssets SPI_AVAILABLE(macos(10.14), ios(12.0), tvos(12.0), watchos(5.0));

/*!
 @property		canFetchMediaDataFromSender
 @abstract		Indicates whether the output device can play a stream of media data from an asset stored on the sending device.
 @discussion
	If the value of this property is NO, and AVPlayer is being used to play a local asset, setting AVPlayer's allowsExternalPlayback property to NO may help avoid playback errors.
 */
@property (nonatomic, readonly) BOOL canFetchMediaDataFromSender SPI_AVAILABLE(macos(10.14), ios(12.0), tvos(12.0), watchos(5.0));

/*!
 @property		presentsOptimizedUserInterfaceWhenPlayingFetchedAudioOnlyAssets
 @abstract		Indicates whether the output device can detect that a URL it fetches points to an audio-only asset and present an optimized audio-only user interface while that asset is being played.
 @discussion
	If the value of this property is NO, and AVPlayer is being used to play the asset, setting AVPlayer's allowsExternalPlayback property to NO may allow the output device to display the optimized audio-only user interface.
 */
@property (nonatomic, readonly) BOOL presentsOptimizedUserInterfaceWhenPlayingFetchedAudioOnlyAssets SPI_AVAILABLE(macos(10.14), ios(12.0), tvos(12.0), watchos(5.0));

/*!
 @property		supportsBluetoothSharing
 @abstract		Indicates whether the output device supports Bluetooth sharing.
 @discussion
	An output device for which the value of this property is YES can be added to an output context containing another device for which the value of this property is YES.  See AVOutputContext.supportsMultipleBluetoothOutputDevices.
 */
@property (nonatomic, readonly) BOOL supportsBluetoothSharing SPI_AVAILABLE(macos(10.15), ios(13.0), tvos(13.0), watchos(6.0));

@end

@interface AVOutputDevice (AVOutputDeviceBluetoothListeningModes)

/*!
 @typedef       AVOutputDeviceBluetoothListeningMode
 @abstract      The type of a listening mode of a Bluetooth output device.
 */
typedef NSString *AVOutputDeviceBluetoothListeningMode NS_STRING_ENUM SPI_AVAILABLE(macos(10.15), ios(13.0), tvos(13.0), watchos(6.0));

/*!
 @constant      AVOutputDeviceBluetoothListeningModeNormal
 @abstract      Indicates the normal listening mode.
 */
AVF_EXPORT AVOutputDeviceBluetoothListeningMode const AVOutputDeviceBluetoothListeningModeNormal SPI_AVAILABLE(macos(10.15), ios(13.0), tvos(13.0), watchos(6.0));

/*!
 @constant      AVOutputDeviceBluetoothListeningModeActiveNoiseCancellation
 @abstract      Indicates an active noise cancellation listening mode.
 */
AVF_EXPORT AVOutputDeviceBluetoothListeningMode const AVOutputDeviceBluetoothListeningModeActiveNoiseCancellation SPI_AVAILABLE(macos(10.15), ios(13.0), tvos(13.0), watchos(6.0));

/*!
 @constant      AVOutputDeviceBluetoothListeningModeAudioTransparency
 @abstract      Indicates an audio transparency listening mode.
 @discussion
	When the audio transparency listening mode is active, ambient sounds are amplified so that the user can hear what is happening in the immediate environment without having to remove the Bluetooth device(s).
 */
AVF_EXPORT AVOutputDeviceBluetoothListeningMode const AVOutputDeviceBluetoothListeningModeAudioTransparency SPI_AVAILABLE(macos(10.15), ios(13.0), tvos(13.0), watchos(6.0));

/*!
 @property    availableBluetoothListeningModes
 @abstract    The listening modes supported by a Bluetooth output device.
 */
@property (nonatomic, readonly) NSArray <AVOutputDeviceBluetoothListeningMode> *availableBluetoothListeningModes SPI_AVAILABLE(macos(10.15), ios(13.0), tvos(13.0), watchos(6.0));

/*!
 @property    currentBluetoothListeningMode
 @abstract    The listening mode currently used by a Bluetooth output device.
 */
@property (nonatomic, nullable) AVOutputDeviceBluetoothListeningMode currentBluetoothListeningMode SPI_AVAILABLE(macos(10.15), ios(13.0), tvos(13.0), watchos(6.0));

/*!
 @method	setCurrentBluetoothListeningMode:error:
 @abstract	Set the listening mode to be used by a Bluetooth output device.
 @param	mode
        The desired listening mode for a Bluetooth output device.
 @param	outError
        If an error occurs setting the listening mode, describes the nature of the failure.
 @result	A value indicating the success or failure of the operation.
 */
- (BOOL)setCurrentBluetoothListeningMode:(AVOutputDeviceBluetoothListeningMode)mode error:(NSError **)outError SPI_AVAILABLE(macos(10.15.1), ios(13.2), tvos(13.1), watchos(6.1));

@end

@interface AVOutputDevice (AVOutputDeviceVolumeControl)

/*!
 @property		volume
 @abstract		The current volume of the output device.
 @discussion
	This property is not key-value observable.
 */
@property (readonly) float volume SPI_AVAILABLE(macos(10.13), ios(11.0), tvos(11.0), watchos(4.0));

/*!
 @constant		AVOutputDeviceVolumeDidChangeNotification
 @abstract		A notification that fires when the volume for an output device changes.
 @discussion
	The device's volume can change in response to a call to -setVolume:, either in this process or another process.  It can also change in response to -[AVOutputContext setVolume:] being invoked on the output context that is routing to the device.
 */
AVF_EXPORT NSNotificationName const AVOutputDeviceVolumeDidChangeNotification SPI_AVAILABLE(macos(10.13), ios(11.0), tvos(11.0), watchos(4.0));

/*!
 @property		canSetVolume
 @abstract		Indicates whether the output device supports volume control.
 */
@property (readonly) BOOL canSetVolume SPI_AVAILABLE(macos(10.13), ios(11.0), tvos(11.0), watchos(4.0));

/*!
 @constant		AVOutputDeviceCanSetVolumeDidChangeNotification
 @abstract		A notification that fires when the value of AVOutputDevice.canSetVolume changes.
 */
AVF_EXPORT NSNotificationName const AVOutputDeviceCanSetVolumeDidChangeNotification SPI_AVAILABLE(macos(10.13), ios(11.0), tvos(11.0), watchos(4.0));

/*!
 @method		setVolume:
 @abstract		Set the volume for the output device.
 @discussion
	This operation completes asynchronously.  Listen for AVOutputDeviceVolumeDidChangeNotification to be notified when the the volume changes.
 */
- (void)setVolume:(float)volume SPI_AVAILABLE(macos(10.13), ios(11.0), tvos(11.0), watchos(4.0));

@end

@interface AVOutputDevice (AVOutputDeviceSecondDisplay)

/*!
 @method		setSecondDisplayEnabled:
 @abstract		Enables second display on the output device.
 @param			secondDisplayEnabled
	BOOL indicating whether to enable/disable second display on the output device.
 @discussion
	*** PLEASE contact Core Media Engineering before using this method. ***
 */
- (void)setSecondDisplayEnabled:(BOOL)setSecondDisplayEnabled;

@end

@interface AVOutputDevice (AVOutputDeviceGroup)

/*!
 @property		canBeGrouped
 @abstract		Indicates whether the receiver can receive output that is also being sent to other output devices.
 */
@property (nonatomic, readonly) BOOL canBeGrouped SPI_AVAILABLE(macos(10.13), ios(11.0), tvos(11.0), watchos(4.0));

/*!
 @property		groupID
 @abstract		Indicates whether the receiver is grouped with other output devices and, if so, identifies the output device group of which the receiver is a member.
 */
@property (nonatomic, readonly, nullable) NSString *groupID SPI_AVAILABLE(macos(10.13), ios(11.0), tvos(11.0), watchos(4.0));

/*
 @property		canBeGroupLeader
 @abstract		Indicates whether the receiver can lead playback of an output device group.
 @discussion
	A device acting as group leader is in charge of running a playback engine and distributing media data to other devices in the group.
 
	If the value of this property is YES, you can communicate with this device by invoking +[AVOutputContext outputContextForControllingOutputDevices:] with the receiver as the sole device in the array.
 */
@property (nonatomic, readonly) BOOL canBeGroupLeader SPI_AVAILABLE(macos(10.13), ios(11.0), tvos(11.0), watchos(4.0));

/*!
 @property		isGroupLeader
 @abstract		Indicates whether the receiver is currently the leader of the group it is in.
 */
@property (nonatomic, readonly) BOOL isGroupLeader SPI_AVAILABLE(macos(10.13), ios(11.0), tvos(11.0), watchos(4.0));

/*!
 @property		participatesInGroupPlayback
 @abstract		Indicates whether the device is rendering media data along with the other devices in the group.
 @discussion
	If the value of isGroupLeader is YES, a value of NO for this property indicates that the output device is a "silent" group leader.  A silent group leader distributes media data to other devices in the group but does not render that media data itself.  A device can end up in this state if it was set up as the leader of the group and subsequently removed from group playback by the user.  In this case, the group topology remains the same but the leader simply stops its own playback.

	If the value of isGroupLeader is NO, the value of this property is always YES if groupID is non-nil and NO if groupID is nil.
 */
@property (nonatomic, readonly) BOOL participatesInGroupPlayback SPI_AVAILABLE(macos(10.13.4), ios(11.3), tvos(11.3), watchos(4.3));

/*!
 @property		groupContainsGroupLeader
 @abstract		Indicates whether the leader of the receiver's group is itself a member of the group.
 @discussion
	When the value of this property is YES, you can use an AVOutputDeviceDiscoverySession to find the group leader.  If the value of this property is NO, you can add the receiver to an AVOutputContext and use the context's outgoingCommunicationChannel to communicate with the group leader.
 */
@property (nonatomic, readonly) BOOL groupContainsGroupLeader SPI_AVAILABLE(macos(10.13), ios(11.0), tvos(11.0), watchos(4.0));

/*!
 @property		logicalDeviceID
 @abstract		Indicates whether the output device acts in combination with one or more other physical devices to form one logical device.
 @discussion
	For example, two HomePods can form one logical device when they are set up as a stereo pair during HomePod setup.  When the value of this property is not nil, the value will be the same as other physical devices that are part of the same logical device.
 */
@property (nonatomic, readonly, nullable) NSString *logicalDeviceID SPI_AVAILABLE(macos(10.13.2), ios(11.2), tvos(11.2), watchos(4.2));

/*!
 @property		isLogicalDeviceLeader
 @abstract		Indicates whether the output device is the leader in a group of physical devices that act as one logical device.
 */
@property (nonatomic, readonly) BOOL isLogicalDeviceLeader SPI_AVAILABLE(macos(10.13.5), ios(11.4), tvos(11.4), watchos(4.3));

/*!
 @property		canCommunicateWithAllLogicalDeviceMembers
 @abstract		Indicates whether the output device can communicate with all the other physical devices that act as a single logical device.
 */
@property (nonatomic, readonly) BOOL canCommunicateWithAllLogicalDeviceMembers SPI_AVAILABLE(macos(10.13.5), ios(11.4), tvos(11.4), watchos(4.3));

/*!
 @property		canRelayCommunicationChannel
 @abstract		Indicates whether the output device can act as a relay for a communication channel to another device.
 @discussion
	If the value of this property is YES and the output device has been added to an AVOutputContext created using +outputContextForControllingOutputDeviceGroupWithID:options:, a communication channel can be created on that output context using AVOutputContextCommunicationChannelControlTypeRelayed.
 */
@property (nonatomic, readonly) BOOL canRelayCommunicationChannel SPI_AVAILABLE(macos(10.13.4), ios(11.3), tvos(11.3), watchos(4.3));

@end

@interface AVOutputDevice (AVOutputDeviceAdministrativeConfiguration)

/*!
 @enum			AVOutputDeviceConfigurationOption
 @abstract		Options for device configuration
 @constant		AVOutputDeviceConfigurationOptionCancelConfigurationIfAuthRequired
	If an NSNumber wrapping a boolean YES is used as the value for this key, and authorization is required to connect to the output device, configuring that output device will automatically be cancelled, rather than asking the user for a password.  See AVOutputDeviceConfigurationResultCancelled & AVOutputDeviceConfigurationCancellationReasonAuthorizationSkipped.
 */
typedef NSString *AVOutputDeviceConfigurationOption NS_STRING_ENUM SPI_AVAILABLE(macos(10.13.5), ios(11.4), tvos(11.4), watchos(4.3));
	AVF_EXPORT AVOutputDeviceConfigurationOption const AVOutputDeviceConfigurationOptionCancelConfigurationIfAuthRequired SPI_AVAILABLE(macos(10.13.5), ios(11.4), tvos(11.4), watchos(4.3));

/*!
 @enum			AVOutputDeviceConfigurationResult
 @abstract		The final status of an output device configuration operation
 @constant		AVOutputDeviceConfigurationResultCompleted
	Device configuration completed successfully.
 @constant		AVOutputDeviceConfigurationResultFailed
	Device configuration failed.
 @constant		AVOutputDeviceConfigurationResultCancelled
	Device configuration was cancelled.
 */
typedef NS_ENUM(NSInteger, AVOutputDeviceConfigurationResult) {
	AVOutputDeviceConfigurationResultCompleted = 0,
	AVOutputDeviceConfigurationResultFailed = 1,
	AVOutputDeviceConfigurationResultCancelled = 2
} SPI_AVAILABLE(macos(10.13.5), ios(11.4), tvos(11.4), watchos(4.3));

/*!
 @enum			AVOutputDeviceConfigurationCancellationReason
 @abstract		Reasons for cancellation of device configuration.
 @constant		AVOutputDeviceConfigurationCancellationReasonAuthorizationSkipped
	Authorization is required to connect to the device, but authorization was not performed because AVOutputDeviceConfigurationOptionCancelConfigurationIfAuthRequired was used.
 */
typedef NSString *AVOutputDeviceConfigurationCancellationReason SPI_AVAILABLE(macos(10.13.5), ios(11.4), tvos(11.4), watchos(4.3));
	AVF_EXPORT AVOutputDeviceConfigurationCancellationReason const AVOutputDeviceConfigurationCancellationReasonAuthorizationSkipped SPI_AVAILABLE(macos(10.13.5), ios(11.4), tvos(11.4), watchos(4.3));

/*!
 @method		configureUsingBlock:options:completionHandler:
 @abstract		Synchronously invoke a block that allows administrative configuration to be performed.
 @param			configuratorBlock
	A block that is invoked with an object parameter that allows configuration to be performed.
 @param			options
	Options for the manner in which the configuration is performed.
 @param			completionHandler
	A block that fires when the operation is finished, vending the current device configuration or an error.
 @discussion
	Use the methods defined in the AVOutputDeviceConfigurationModification protocol to set desired configuration options on the device.  When the configurator block exits, the new configuration will be pushed to the device.

	If the output device has enabled automatic acceptance of connections from peers in the "home" group, the configuring device must be a peer with administrator privileges (see the AVOutputDeviceAuthorizedPeer class).  If the output device has not enabled automatic acceptance of connections from peers in the "home" group, an authorization request may be issued using AVOutputDeviceAuthorizationSession.

	In order to retrieve the current configuration without setting any new values, exit the configurator block without setting any new configuration options.

	If the 'result' parameter of the completion handler is AVOutputDeviceConfigurationResultCompleted, the currentConfiguration parameter will be non-null.  If the 'result' parameter is AVOutputDeviceConfigurationResultCancelled, the cancellationReason may be non-nil.  If the 'result' parameter is AVOutputDeviceConfigurationResultFailed, the error parameter will be non-nil.
*/
- (void)configureUsingBlock:(void (^)(id <AVOutputDeviceConfigurationModification>))configuratorBlock options:(nullable NSDictionary<AVOutputDeviceConfigurationOption, id> *)options completionHandler:(void (^)(AVOutputDeviceConfigurationResult result, id <AVOutputDeviceConfigurationRetrieval> _Nullable currentConfiguration, AVOutputDeviceConfigurationCancellationReason _Nullable cancellationReason, NSError * _Nullable error))completionHandler SPI_AVAILABLE(macos(10.13.5), ios(11.4), tvos(11.4), watchos(4.3));

@end

/*!
 @protocol		AVOutputDeviceConfigurationModification
 @abstract		Methods for setting output device configuration.
 */
SPI_AVAILABLE(macos(10.13), ios(11.0), tvos(11.0), watchos(4.0))
@protocol AVOutputDeviceConfigurationModification <NSObject>

/*!
 @method		setDeviceName:
 @abstract		Sets the device name.
 */
- (void)setDeviceName:(NSString *)deviceName;

/*!
 @method		setDevicePassword:
 @abstract		Sets a password that will be requested by the output device when it issues an authorization request.
 @discussion
	The password set here may be required, as the response to an authorization request from AVOutputDeviceAuthorizationSession, in order to set the device on an AVOutputContext or configure the output device.  Setting a password automatically configures the output device to ask for a password (rather than e.g. a PIN) whenever it issues an authorization request.
 */
- (void)setDevicePassword:(NSString *)password;

/*!
 @method		startAutomaticallyAllowingConnectionsFromPeersInHomeGroupAndRejectOtherConnections:
 @abstract		Tells the output device to start automatically allowing connections from peers in the "home" group and indicates whether to continue accepting connections from other devices.
 @discussion
	By default, an output device uses authorization requests (see AVOutputDeviceAuthorizationSession) to control access to a device, for both AirPlay connections (i.e. setting the output device on an AVOutputContext) and device configuration (i.e. calling -configureUsingBlock:completionHandler:).  Calling this method will enable access by peers in the "home" group (see the AVOutputDeviceAuthorizedPeer class), without triggering an authorization request.  Once automatic acceptance of connections from peers in the "home" group has been enabled, only peers with administrator privileges are permitted to configure the output device.  Because of this, an output device must be associated with at least one peer with administrator privileges (see -addPeerToHomeGroup:) before automatic acceptance of connections from peers in the "home" group can be enabled.

	If the rejectOtherConnections parameter is NO, the output device will continue to allow AirPlay connections from devices that are not peers in the "home" group.  In this case, AVOutputDeviceAuthorizationSession may be used to prompt the user for an authorization token.
 */
- (void)startAutomaticallyAllowingConnectionsFromPeersInHomeGroupAndRejectOtherConnections:(BOOL)rejectOtherConnections;

/*!
 @method		stopAutomaticallyAllowingConnectionsFromPeersInHomeGroup
 @abstract		Tells the output device to stop automatically allowing connections from peers in the "home" group.
 @discussion
	If -startAutomaticallyAllowingConnectionsFromPeersInHomeGroupAndRejectOtherConnections: had previously been called with a YES parameter, indicating that only peers in the "home" group should be able to access the output device, calling this method will cause the device to resume accepting connections from all devices.  After this method is called, authorization requests may be used for both AirPlay connections (i.e. setting the output device on an AVOutputContext) and device configuration (i.e. calling -configureUsingBlock:completionHandler:).
 */
- (void)stopAutomaticallyAllowingConnectionsFromPeersInHomeGroup;

/*!
 @method		addPeerToHomeGroup:
 @abstract		Adds a peer to the "home" group.
 @discussion
	If the output device is configured to automatically allow connections from peers in the "home" group, a peer in the "home" group can make an AirPlay connection (e.g. by setting the output device on an AVOutputContext) without triggering an authorization request.  A peer with administrator privileges can also configure the output device.
 */
- (void)addPeerToHomeGroup:(AVOutputDeviceAuthorizedPeer *)peer;

/*!
 @method		removePeerWithIDFromHomeGroup:
 @abstract		Removes a peer from the "home" group.
 @discussion
	Removing a peer will fail if that peer was the last administrator and the output device is configured to automatically allow connections from peers in the "home" group.
 */
- (void)removePeerWithIDFromHomeGroup:(NSString *)peerID;

@end

/*!
 @protocol		AVOutputDeviceConfigurationRetrieval
 @abstract		Properties for reading the current administrative configuration of an output device.
 */
SPI_AVAILABLE(macos(10.13), ios(11.0), tvos(11.0), watchos(4.0))
@protocol AVOutputDeviceConfigurationRetrieval <NSObject>

/*!
 @property		deviceName
 @abstract		The name of the output device.
 */
@property (nonatomic, readonly, nullable) NSString *deviceName;

/*!
 @property		devicePassword
 @abstract		The password that will be requested when the output device issues an authorization request.
 */
@property (nonatomic, readonly, nullable) NSString *devicePassword;

/*!
 @property		deviceID
 @abstract		A string identifying the device.
 */
@property (nonatomic, readonly, nullable) NSString *deviceID SPI_AVAILABLE(macos(10.13.3), ios(11.3), tvos(11.3), watchos(4.3));

/*!
 @property		devicePublicKey
 @abstract		An Ed25519 key that can be used to exchange encrypted messages with the device.
 */
@property (nonatomic, readonly, nullable) NSData *devicePublicKey SPI_AVAILABLE(macos(10.13.3), ios(11.3), tvos(11.3), watchos(4.3));

/*!
 @property		automaticallyAllowsConnectionsFromPeersInHomeGroup
 @abstract		Indicates whether the output device automatically allows connections from peers in the "home" group.
 @discussion
	When the value of this property is YES, an authorized peer in the "home" group can connect to the device without triggering an authorization request.  See the peersInHomeGroup property.
 */
@property (nonatomic, readonly) BOOL automaticallyAllowsConnectionsFromPeersInHomeGroup;

/*!
 @property		onlyAllowsConnectionsFromPeersInHomeGroup
 @abstract		Indicates whether the output device only allows connections from peers in the "home" group.
 @discussion
	This property will be YES if -startAutomaticallyAllowingConnectionsFromPeersInHomeGroupAndRejectOtherConnections: was called with a YES parameter.  See -[AVOutputDeviceConfigurationModification addPeerToHomeGroup:] for a way to add peers to the home group.
 */
@property (nonatomic, readonly) BOOL onlyAllowsConnectionsFromPeersInHomeGroup;

/*!
 @property		peersInHomeGroup
 @abstract		The list of authorized peers in the "home" group.
 @discussion
	If the device is configured to automatically allow connections from peers in the "home" group, an authorized peer in the "home" group can make an AirPlay connection (e.g. by setting the output device on an AVOutputContext) without triggering an authorization request.  A peer with administrator privileges can also configure the output device, by calling -configureUsingBlock:completionHandler:.
 */
@property (nonatomic, readonly) NSArray<AVOutputDeviceAuthorizedPeer *> *peersInHomeGroup;

@end

/*!
 @class			AVOutputDeviceAuthorizedPeer
 @abstract		A class representing a peer that has access to an output device.
 @discussion
	An authorized peer of an output device may, depending on the device configuration, be able to make an AirPlay connection (e.g. by setting the device on an AVOutputContext) without triggering an authorization request.  A peer with administrator privileges may also be able to configure the device, by calling -[AVOutputDevice configureUsingBlock:completionHandler:].
 */
SPI_AVAILABLE(macos(10.13), ios(11.0), tvos(11.0), watchos(4.0))
@interface AVOutputDeviceAuthorizedPeer : NSObject
{
@private
	AVOutputDeviceAuthorizedPeerInternal *_ivars;
}
AV_INIT_UNAVAILABLE

/*!
 @method		initWithID:publicKey:permissions:
 @abstract		Initialize an instance of AVOutputDeviceAuthorizedPeer.
 */
- (instancetype)initWithID:(NSString *)ID publicKey:(NSData *)publicKey hasAdministratorPrivileges:(BOOL)hasAdministratorPrivileges;

/*!
 @property		peerID
 @abstract		A string identifying the peer.
 */
@property (nonatomic, readonly) NSString *peerID;

/*!
 @property		publicKey
 @abstract		An Ed25519 key that can be used to exchange encrypted messages with the peer.
 */
@property (nonatomic, readonly) NSData *publicKey;

/*!
 @property		hasAdministratorPrivileges
 @abstract		Specifies whether the peer can set administrative configuration on an output device.
 @discussion
	A peer with administrator privileges can configure the device.
 */
@property (nonatomic, readonly) BOOL hasAdministratorPrivileges;

@end


/*!
 @class			AVPairedDevice
 @abstract		A class that describes a device paired with the current device.
 @discussion
	If the current process is running on an iPhone and that iPhone is paired with an Apple Watch, that Apple Watch is considered a "paired device" to the current device.
 */
SPI_AVAILABLE(macos(10.13), ios(11.0), tvos(11.0), watchos(4.0))
@interface AVPairedDevice : NSObject
{
@private
	AVPairedDeviceInternal *_ivars;
}

/*!
 @method		pairedDevicesConnectedToOutputDevice:
 @abstract		Returns the devices paired to the current device that are connected to the given output device.
 */
+ (NSArray<AVPairedDevice *> *)pairedDevicesConnectedToOutputDevice:(AVOutputDevice *)outputDevice;

/*!
 @property		name
 @abstract		The name of the paired device.
 */
@property (nonatomic, readonly, nullable) NSString *name;

/*!
 @property		pairedDeviceID
 @abstract		An identifier for the paired device.
 */
@property (nonatomic, readonly, nullable) NSString *pairedDeviceID;

/*!
 @property		modelID
 @abstract		The modelID of the paired device.
 */
@property (nonatomic, readonly, nullable) NSString *modelID;

/*!
 @property		playing
 @abstract		Indicates whether the paired device is currently playing.
 */
@property (nonatomic, readonly, getter=isPlaying) BOOL playing;

/*!
 @property		productName
 @abstract		The product name of the paired device.
 */
@property (nonatomic, readonly, nullable) NSString *productName;

@end


@interface AVOutputDevice (SpecialAvailability)

/*!
 @property		deviceID
 @abstract		The identifier associated with an instance of AVOutputDevice.
 @discussion
	The value of this property may be nil. This property is not key-value observable.
 */
@property (nonatomic, readonly, nullable) NSString *deviceID SPI_AVAILABLE(macos(10.13), ios(11.0), tvos(11.0), watchos(4.0));

@end


@interface AVOutputDevice (Deprecated)

/*!
 @property		name
 @abstract		The name of the device represented by an instance of AVOutputDevice.
 @discussion
	Use the deviceName property instead.
 */
@property (nonatomic, readonly) NSString *name API_DEPRECATED_WITH_REPLACEMENT("deviceName", macos(10.11, API_TO_BE_DEPRECATED), ios(9.0, API_TO_BE_DEPRECATED), tvos(9.0, API_TO_BE_DEPRECATED), watchos(2.0, API_TO_BE_DEPRECATED));

/*!
 @property		ID
 @abstract		The identifier associated with an instance of AVOutputDevice.
 @discussion
	Use the deviceID property instead.
 */
@property (nonatomic, readonly, nullable) NSString *ID API_DEPRECATED_WITH_REPLACEMENT("deviceID", macos(10.11, API_TO_BE_DEPRECATED), ios(9.0, API_TO_BE_DEPRECATED), tvos(9.0, API_TO_BE_DEPRECATED), watchos(2.0, API_TO_BE_DEPRECATED));

/*!
 @method		configureUsingBlock:completionHandler:
 @abstract		Synchronously invoke a block that allows administrative configuration to be performed.
 @discussion
	Use -configureUsingBlock:options:completionHandler: instead.
 */
- (void)configureUsingBlock:(void (^)(id <AVOutputDeviceConfigurationModification>))configuratorBlock completionHandler:(void (^)(id <AVOutputDeviceConfigurationRetrieval> _Nullable currentConfiguration, NSError * _Nullable error))completionHandler API_DEPRECATED_WITH_REPLACEMENT("-configureUsingBlock:options:completionHandler:", macos(10.13, API_TO_BE_DEPRECATED), ios(11.0, API_TO_BE_DEPRECATED), tvos(11.0, API_TO_BE_DEPRECATED), watchos(4.0, API_TO_BE_DEPRECATED));

@end

@interface AVPairedDevice (Deprecated)
/*!
 @property		ID
 @abstract		An identifier for the paired device.
 @discussion
	Use the property pairedDeviceID instead.
 */
@property (nonatomic, readonly, nullable) NSString *ID API_DEPRECATED_WITH_REPLACEMENT("pairedDeviceID", macos(10.13, API_TO_BE_DEPRECATED), ios(11.0, API_TO_BE_DEPRECATED), tvos(11.0, API_TO_BE_DEPRECATED), watchos(4.0, API_TO_BE_DEPRECATED));
@end

NS_ASSUME_NONNULL_END
