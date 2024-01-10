/*
	File:  AVOutputDeviceDiscoverySession.h
 
	Framework:  AVFoundation
 
	Copyright 2015-2019 Apple Inc. All rights reserved.
 
 */

#import <AVFoundation/AVBase.h>
#import <Foundation/Foundation.h>

@class AVOutputDevice;
@class AVOutputDeviceDiscoverySessionAvailableOutputDevices;
@class AVOutputDeviceDiscoverySessionAvailableOutputDevicesInternal;
@class AVOutputDeviceDiscoverySessionInternal;
@class AVAudioSession;

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, AVOutputDeviceDiscoveryMode) {
	AVOutputDeviceDiscoveryModeDisabled = 0,   // devices will not be discovered even if there are some available
	AVOutputDeviceDiscoveryModePresence = 1,       // only check if there are devices available
	AVOutputDeviceDiscoveryModeDetailed = 2,       // get detailed information about available devices
	AVOutputDeviceDiscoveryModeDetailedInfraOnly SPI_AVAILABLE(macos(10.13.3), ios(11.3), tvos(11.3), watchos(4.3)) = 3 // get detailed information, but only for the subset of available devices that can be discovered on an infrastructure network
} SPI_AVAILABLE(macos(10.11), ios(9.0), tvos(9.0), watchos(2.0));

typedef NS_OPTIONS(NSUInteger, AVOutputDeviceFeatures) {
	AVOutputDeviceFeatureAudio	= (1UL << 0),
	AVOutputDeviceFeatureScreen	= (1UL << 1),
	AVOutputDeviceFeatureVideo	= (1UL << 2),
	AVOutputDeviceFeatureControl SPI_AVAILABLE(macos(10.13), ios(11.0), tvos(11.0), watchos(4.0)) = (1UL << 3), // suitable for adding to an outputContextForControllingOutputDeviceGroupWithID
	AVOutputDeviceFeatureAny	= 0xFFFFUL,
} SPI_AVAILABLE(macos(10.11), ios(9.0), tvos(9.0), watchos(2.0));

AVF_EXPORT NSString *const AVOutputDeviceDiscoverySessionAvailableOutputDevicesDidChangeNotification SPI_AVAILABLE(macos(10.11), ios(9.0), tvos(9.0), watchos(2.0));

SPI_AVAILABLE(macos(10.11), ios(9.0), tvos(9.0), watchos(2.0))
@interface AVOutputDeviceDiscoverySession : NSObject
{
@private
	AVOutputDeviceDiscoverySessionInternal *_outputDeviceDiscoverySession;
}

/*!
	@method			initWithDeviceFeatures:
	@abstract		Creates an instance of AVOutputDeviceDiscoverySession.
	@param			features
		All available output devices vended by an instance of AVOutputDeviceDiscoverySession support at least one of the specified features.
 */
- (instancetype)initWithDeviceFeatures:(AVOutputDeviceFeatures)features;

/*!
	@property		discoveryMode
	@abstract		Discovery mode determines how the system should search for devices in the local area.
	@discussion
		A system-wide discovery mode is maintained internally by CoreMedia, since there might be multiple output device discovery sessions who require different discovery behavior.  "Detailed" discovery modes use extra power and can interfere with other device connectivity features.  Use of AVOutputDeviceDiscoveryModeDetailed and AVOutputDeviceDiscoveryModeDetailedInfraOnly should be limited to only the period of time during which detailed information about output devices is needed, for example when displaying device names in a picker UI.  

		For the picker UI to show an airplay button, mode should be set to presence. If the discovery session detects the presence of at least one output device, an AVOutputDeviceDiscoverySessionAvailableOutputDevicesDidChangeNotification is posted, use the devicePresenceDetected BOOL to check whether there is atleast one device available to enable the route picker button. To get the list of all devices to fill in a menu, mode should be set to detailed. Note that setting mode to detailed is resource intensive and must only be used when the list of all available devices and their properties are required, for example when the user opens a picker menu. The mode must be reset to presence or disabled when the picker menu is dismissed.
 */
@property (nonatomic, assign) AVOutputDeviceDiscoveryMode discoveryMode;

/*!
	@property		targetAudioSession
	@abstract		Indicates the audio session that will be in use when routing to devices discovered by the discovery session.
	@discussion
		The default value of this property is nil, which indicates that the discovery session will track the configuration of the current active audio session.  The discovery session will exclude devices that are not compatible with the given audio session.
 */
@property (nonatomic, retain, nullable) AVAudioSession *targetAudioSession SPI_AVAILABLE(ios(11.0), tvos(11.0), watchos(4.0)) API_UNAVAILABLE(macos);

/*!
	@property		availableOutputDevices
	@abstract		Returns an array of AVOutputDevices that support the features used to create the receiver.
	@discussion		If the outputDevices have not been loaded, then the discovery session fetches these outputDevices synchronously. This property is not key-value observable.
		Use of this method requires the following entitlement:
		"com.apple.avfoundation.allows-access-to-device-list" = true (Boolean)
 */
@property (nonatomic, readonly) NSArray<AVOutputDevice *> *availableOutputDevices;

/*!
	@property		availableOutputDevicesObject
	@abstract		Returns an instance of AVOutputDeviceDiscoverySessionAvailableOutputDevices.
	@discussion		The object contains two lists of AVOutputDevices, which are mutually exclusive, that support the features used to create the receiver.
		This property is not key-value observable.
		Use of this method requires the following entitlement:
		"com.apple.avfoundation.allows-access-to-device-list" = true (Boolean)
 */
@property (nonatomic, readonly) AVOutputDeviceDiscoverySessionAvailableOutputDevices *availableOutputDevicesObject;

/*!
	@property		devicePresenceDetected
	@abstract		Returns a BOOL indicating the presence of at least one device.
	@discussion		Upon receiving AVOutputDeviceDiscoverySessionAvailableOutputDevicesDidChangeNotification, clients can check the value of this BOOL to decide whether to show a route picker UI button. The property value is updated every time AVOutputDeviceDiscoverySessionAvailableOutputDevicesDidChangeNotification is posted. The default value is NO. This property is not key-value observable.
 */
@property (nonatomic, readonly) BOOL devicePresenceDetected;

@end


SPI_AVAILABLE(macos(10.11), ios(9.0), tvos(9.0), watchos(2.0))
@interface AVOutputDeviceDiscoverySessionAvailableOutputDevices : NSObject
{
@private
	AVOutputDeviceDiscoverySessionAvailableOutputDevicesInternal *_availableOutputDevices;
}

/*!
	@property		recentlyUsedDevices
	@abstract		Returns an array of all recently used AVOutputDevices that support the features used to create the AVOutputDeviceDiscoverySession.
	@discussion		The array is sorted alphabetically. The lists of recently used and other devices are mutually exclusive. This property is not key-value observable.
 */
@property (nonatomic, readonly) NSArray<AVOutputDevice *> *recentlyUsedDevices;

/*!
	@property		otherDevices
	@abstract		Returns an array of all AVOutputDevices that have not been recently used and that support the features used to create the AVOutputDeviceDiscoverySession.
	@discussion		The array is sorted alphabetically. The lists of recently used and other devices are mutually exclusive. This property is not key-value observable.
 */
@property (nonatomic, readonly) NSArray<AVOutputDevice *> *otherDevices;

@end

NS_ASSUME_NONNULL_END
