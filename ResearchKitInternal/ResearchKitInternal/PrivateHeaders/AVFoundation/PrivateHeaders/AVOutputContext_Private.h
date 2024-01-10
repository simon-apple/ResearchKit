/*
	File:  AVOutputContext_Private.h
 
	Framework:  AVFoundation
 
	Copyright 2015-2019 Apple Inc. All rights reserved.
 
 */

#import "AVOutputContext.h"
#import "AVOutputDeviceDiscoverySession.h"

@class AVOutputContextCommunicationChannel;
@protocol AVOutputContextCommunicationChannelDelegate;
@class AVOutputContextCommunicationChannelInternal;
@class AVOutputContextDestinationChange;
@class AVOutputContextDestinationChangeInternal;
@protocol AVOutputContextManagerDelegate;
@class AVOutputContextManagerInternal;

NS_ASSUME_NONNULL_BEGIN

// This is used only by Displays menu to know when a device is picked or unpicked for any context on the system. For all other clients, please use AVOutputContextOutputDeviceDidChangeNotification.
AVF_EXPORT NSNotificationName const AVOutputContextGlobalOutputDeviceConfigurationDidChangeNotification SPI_AVAILABLE(macos(10.11), ios(9.0), tvos(9.0), watchos(2.0));

@interface AVOutputContext (AVOutputContext_Private)

/*!
 @method		sharedSystemAudioContext
 @abstract		Returns an output context to be used for picking system wide audio.
 @discussion
	*** PLEASE contact Core Media Engineering before using this method. ***
 
	This is to be used only by clients who are interested in picking audio for the entire system, for example volume menu extra. Clients picking within an application scope should use +outputContext class method. Use of this method requires the following entitlement:
		
		"com.apple.avfoundation.allow-system-wide-context" = true (Boolean)
 */
+ (nullable instancetype)sharedSystemAudioContext;

/*!
 @method		sharedSystemScreenContext
 @abstract		Returns an output context to be used for picking system wide screen.
 @discussion
	*** PLEASE contact Core Media Engineering before using this method. ***
 
	This is to be used only by clients who are interested in picking screen to mirror for the entire system, for example displays menu extra. Clients picking within an application scope should use +outputContext class method. Use of this method requires the following entitlement:
 
		"com.apple.avfoundation.allow-system-wide-context" = true (Boolean)
 */
+ (nullable instancetype)sharedSystemScreenContext;

/*!
 @method		iTunesAudioContext
 @abstract		Creates an instance of an output context to be used by iTunes for picking audio.
 @discussion
	*** PLEASE contact Core Media Engineering before using this method. ***
 
	This is to be used only by iTunes for picking audio.
 */
+ (instancetype)iTunesAudioContext;

/*
 @method		defaultSharedOutputContext
 @abstract		Vends the default context for routing that is shared throughout the calling process.
 @discussion
	*** PLEASE contact Core Media Engineering before using this method. ***

	This currently only returns a non-nil context for iosmac apps
 */
+ (nullable instancetype)defaultSharedOutputContext SPI_AVAILABLE(macos(10.15), ios(13.0), tvos(13.0), watchos(6.0));

/*!
 @enum			AVOutputContextDeviceGroupControlOption
 @abstract		Options used in the creation of output contexts for controlling groups of output devices.
 @constant	AVOutputContextDeviceGroupControlOptionCancelAddDeviceIfAuthRequired
	If an NSNumber wrapping a boolean YES is used as the value for this key, and authorization is required to connect to an output device, adding an output device to an output context created with this option will automatically be cancelled, rather than asking the user for a password.  See AVOutputContextDestinationChangeCancellationReasonAuthorizationSkipped.
 */
typedef NSString *AVOutputContextDeviceGroupControlOption NS_STRING_ENUM SPI_AVAILABLE(macos(10.13.2), ios(11.2), tvos(11.2), watchos(4.2));
	AVF_EXPORT AVOutputContextDeviceGroupControlOption const AVOutputContextDeviceGroupControlOptionCancelAddDeviceIfAuthRequired SPI_AVAILABLE(macos(10.13.2), ios(11.2), tvos(11.2), watchos(4.2));

/*!
 @method		outputContextForControllingOutputDeviceGroupWithID:options:
 @abstract		Creates a new output context for controlling the output device group with the given ID.
 @discussion
	This output context can be used to send and receive arbitrary data to and from the group (actually the group's leader).  This output context cannot be attached to e.g. an AVPlayer.

	When changing the destination of this output context, use -addOutputDevice: and -removeOutputDevice: exclusively.  To examine the current destination of this output context, use the outputDevices property exclusively.
 */
+ (instancetype)outputContextForControllingOutputDeviceGroupWithID:(NSString *)groupID options:(nullable NSDictionary<AVOutputContextDeviceGroupControlOption, id> *)options SPI_AVAILABLE(macos(10.13.2), ios(11.2), tvos(11.2), watchos(4.2));

/*!
 @method		resetOutputDeviceForAllOutputContexts
 @abstract		Resets device selection for all contexts on the system.
 @discussion
	*** PLEASE contact Core Media Engineering before using this property. ***
 
	This is to be used only by clients who need to route back, to the local system, all contexts, example displays menu extra. Clients picking or unpicking within an application scope should use -setOutputDevice:forFeatures: method. Use of this method requires the following entitlement:
 
		"com.apple.avfoundation.allow-system-wide-context" = true (Boolean)
 */
+ (void)resetOutputDeviceForAllOutputContexts;

/*!
 @method		outputContextExistsWithRemoteOutputDevice
 @abstract		Returns a BOOL to indicate whether any context has a device picked.
 @discussion
	*** PLEASE contact Core Media Engineering before using this property. ***
 
	This is to be used only by clients who need to route back, to the local system, all contexts, example displays menu extra.  Use of this method requires the following entitlement:
 
		"com.apple.avfoundation.allow-system-wide-context" = true (Boolean)
 */
+ (BOOL)outputContextExistsWithRemoteOutputDevice;

/*!
 @method		outputContextForID:
 @abstract		Returns the output context with the given ID, or nil if no output context has the given ID.
 */
+ (nullable AVOutputContext *)outputContextForID:(NSString *)ID SPI_AVAILABLE(macos(10.13), ios(11.0), tvos(11.0), watchos(4.0));

/*!
 @property		contextID
 @abstract		A unique identifier for the output context.
 @discussion
	This ID uniquely identifies this output context across all processes on the system.
 */
@property (nonatomic, readonly) NSString *contextID SPI_AVAILABLE(macos(10.13), ios(11.0), tvos(11.0), watchos(4.0));

/*!
 @enum			AVOutputContextType
 @abstract		Values for AVOutputContext.outputContextType
 @constant	AVOutputContextTypeSharedSystemAudio
	An output context fetched via +sharedSystemAudioContext.
 @constant	AVOutputContextTypeSharedSystemScreen
	An output context +sharedSystemScreenContext.
 @constant	AVOutputContextTypeSharedAudioPresentation
	An output context fetched via +sharedAudioPresentationOutputContext.  This is the only context type that supports -setOutputDevices:.
 @constant	AVOutputContextTypeAudio
	An output context created using +iTunesAudioContext.
 @constant	AVOutputContextTypeVideo
	An output context created using +outputContext (on macOS only) or +auxiliaryOutputContext.
 @constant	AVOutputContextTypeScreen
	An output context created using +outputContext (on iOS only).
 @constant	AVOutputContextTypeGroupControl
 An output context created with +outputContextForControllingOutputDeviceGroupWithID:options:.  This is the only context type that supports -addOutputDevice: and -removeOutputDevice:.
 */
typedef NSString *AVOutputContextType NS_STRING_ENUM SPI_AVAILABLE(macos(10.13), ios(11.0), tvos(11.0), watchos(4.0));
	AVF_EXPORT AVOutputContextType const AVOutputContextTypeSharedSystemAudio SPI_AVAILABLE(macos(10.13), ios(11.0), tvos(11.0), watchos(4.0));
	AVF_EXPORT AVOutputContextType const AVOutputContextTypeSharedSystemScreen SPI_AVAILABLE(macos(10.13), ios(11.0), tvos(11.0), watchos(4.0));
	AVF_EXPORT AVOutputContextType const AVOutputContextTypeSharedAudioPresentation SPI_AVAILABLE(macos(10.13), ios(11.0), tvos(11.0), watchos(4.0));
	AVF_EXPORT AVOutputContextType const AVOutputContextTypeAudio SPI_AVAILABLE(macos(10.13), ios(11.0), tvos(11.0), watchos(4.0));
	AVF_EXPORT AVOutputContextType const AVOutputContextTypeVideo SPI_AVAILABLE(macos(10.13), ios(11.0), tvos(11.0), watchos(4.0));
	AVF_EXPORT AVOutputContextType const AVOutputContextTypeScreen SPI_AVAILABLE(macos(10.13), ios(11.0), tvos(11.0), watchos(4.0));
	AVF_EXPORT AVOutputContextType const AVOutputContextTypeGroupControl SPI_AVAILABLE(macos(10.13), ios(11.0), tvos(11.0), watchos(4.0));

/*!
 @property		outputContextType
 @abstract		Indicates the type of context represented by the receiver.
 @discussion
	This property can be used to determine how a context fetched via +outputContextForID: was created.  If the value of this property is nil, the context type could not be determined.

	Different types of contexts have different capabilities.  See the values of AVOutputContextType for details.
 */
@property (nonatomic, readonly, nullable) AVOutputContextType outputContextType SPI_AVAILABLE(macos(10.13), ios(11.0), tvos(11.0), watchos(4.0));

/*!
 @constant		AVOutputContextDestinationChangeInitiatedNotification
 @abstract		A notification that fires when a change to an output context's destination is initiated.
 @discussion
	The payload contains an instance of AVOutputContextDestinationChange, accessible using AVOutputContextDestinationChangeKey, that describes the progress of the destination change.
 
	This notification is not guaranteed to fire in all situations in which the context's destination can change.  For definitive notification of destination change, listen for AVOutputContextOutputDeviceDidChangeNotification and/or AVOutputContextOutputDevicesDidChangeNotification.
 */
AVF_EXPORT NSNotificationName const AVOutputContextDestinationChangeInitiatedNotification SPI_AVAILABLE(macos(10.13), ios(11.0), tvos(11.0), watchos(4.0));
	AVF_EXPORT NSString *const AVOutputContextDestinationChangeKey SPI_AVAILABLE(macos(10.13), ios(11.0), tvos(11.0), watchos(4.0)); // AVOutputContextDestinationChange

/*!
 @property		outputDevice
 @abstract		The device to which objects associated with the context are currently routed. This property is not key-value observable.
 */
@property (nonatomic, readonly, nullable) AVOutputDevice *outputDevice;

/*!
 @enum			AVOutputContextSetOutputDeviceOptionsKey
 @abstract		The type of a key for the set output device options dictionary.
 @constant		AVOutputContextSetOutputDevicePasswordKey
	Indicates the password to be used for authorization while picking an output device.  The value of this key is an NSString.  If the key is not present in the options dictionary, the user is prompted to enter a password.
 @constant		AVOutputContextSetOutputDeviceCancelIfAuthRequiredKey
	If an NSNumber wrapping a boolean YES is used as the value for this key, and authorization is required to connect to an output device, associating an output device with an output context will automatically be cancelled, rather than asking the user for a password.  If the output device is configured to require a PIN, the PIN will not be displayed on the output device.  See AVOutputContextDestinationChangeCancellationReasonAuthorizationSkipped.
 @constant		AVOutputContextSetOutputDeviceSuppressUserInteractionOnSenderOnlyKey
	If an NSNumber wrapping a boolean YES is used as the value for this key, and authorization is required to connect to an output device, associating an output device with an output context will automatically be cancelled, rather than asking the user for a password.  If the output device is configured to require a PIN, the PIN will still be displayed on the output device.  The completion handler will fire with a destination change object carrying AVOutputContextDestinationChangeStatusCancelled / AVOutputContextDestinationChangeCancellationReasonAuthorizationSkipped.
 
	If an error occurs while connecting to the device when this option is used, the user will not be notified but the completion handler will fire with a destination change object carrying AVOutputContextDestinationChangeStatusFailed.
 @constant		AVOutputContextSetOutputDeviceInitiatorKey
	A string describing the user interface that was used to initiate the route change.  Standard strings are defined in <AirPlayRoutePrediction/ARPFeedback.h>.  This value will be included in output device change notifications via AVOutputContextDestinationChangeInitiatorKey, in all processes that share the same output context.
 */
typedef NSString * AVOutputContextSetOutputDeviceOptionsKey NS_STRING_ENUM;
	AVF_EXPORT AVOutputContextSetOutputDeviceOptionsKey const AVOutputContextSetOutputDevicePasswordKey SPI_AVAILABLE(macos(10.13), ios(11.0), tvos(11.0), watchos(4.0));
	AVF_EXPORT AVOutputContextSetOutputDeviceOptionsKey const AVOutputContextSetOutputDeviceCancelIfAuthRequiredKey SPI_AVAILABLE(macos(10.13.2), ios(11.2), tvos(11.2), watchos(4.2));
	AVF_EXPORT AVOutputContextSetOutputDeviceOptionsKey const AVOutputContextSetOutputDeviceSuppressUserInteractionOnSenderOnlyKey SPI_AVAILABLE(macos(10.14.4), ios(12.2), tvos(12.2), watchos(5.2));
	AVF_EXPORT AVOutputContextSetOutputDeviceOptionsKey const AVOutputContextSetOutputDeviceInitiatorKey SPI_AVAILABLE(macos(10.14.5), ios(12.3), tvos(12.3), watchos(5.2.1));

/*!
 @method		setOutputDevice:options:completionHandler:
 @abstract		Sets the output device with options.
 @discussion
	Note that this should only be invoked in response to a user initiated selection from the routing picking UI. See AVOutputContextSetOutputDeviceOptionsKey above for options which can be used while picking. Use of this method requires the following entitlement:

		"com.apple.avfoundation.allows-set-output-device" = true (Boolean)

	The parameter to the completion handler is an AVOutputContextDestinationChange that already has a terminal status.
 */
- (void)setOutputDevice:(nullable AVOutputDevice *)outputDevice options:(nullable NSDictionary<AVOutputContextSetOutputDeviceOptionsKey, id> *)options completionHandler:(nullable void (^)(AVOutputContextDestinationChange *result))completionHandler SPI_AVAILABLE(macos(10.13.2), ios(11.2), tvos(11.2), watchos(4.2));

/*!
 @property		applicationProcessID
 @abstract		Specifies the applicationProcessID associated with an output context.
 @discussion
	For security reasons, the picker UI should be presented out of process, if this property is set, it identifies the application initiating device picking instead of the view service presenting the UI.
 */
@property (nonatomic) pid_t applicationProcessID;

/*!
 @property		associatedAudioDeviceID
 @abstract		The audio device ID associated to the current output device.
 @discussion
	This property is available after an AVOutputDevice has become current when set using this context. Clients can use this property to directly access the audio device using CoreAudio framework.
 */
@property (nonatomic, readonly, nullable) NSString *associatedAudioDeviceID SPI_AVAILABLE(macos(10.12)) API_UNAVAILABLE(ios, tvos, watchos);

@end

@interface AVOutputContext (AVOutputContextOutputDeviceGroup)

/*!
 @property		supportsMultipleOutputDevices
 @abstract		Indicates whether the output context supports routing to multiple output devices.
 @discussion
	When the value of this property is YES, -setOutputDevices: should be used instead of -setOutputDevice: to change the output context's destination.  Multiple AVOutputDevices carrying the value YES for the property canBeGrouped can be present in the output context at the same time.

 */
@property (readonly) BOOL supportsMultipleOutputDevices SPI_AVAILABLE(macos(10.13.4), ios(11.3), tvos(11.3), watchos(4.3));

/*!
 @property		supportsMultipleBluetoothOutputDevices
 @abstract		Indicates whether the output context supports routing to multiple Bluetooth output devices.
 @discussion
	When the value of this property is YES, multiple AVOutputDevices carrying the value YES for the property supportsBluetoothSharing can be present in the output context at the same time.
 */
@property (readonly) BOOL supportsMultipleBluetoothOutputDevices SPI_AVAILABLE(macos(10.15), ios(13.0), tvos(13.0), watchos(6.0));

/*!
 @property		outputDevices
 @abstract		An array of AVOutputDevices.
 @discussion
	This property is not key-value observable.  Listen for AVOutputContextOutputDevicesDidChangeNotification to be notified of changes to this property.

	For an output context that supports this property, this property should always be used instead of the outputDevice property to examine the current destination of the output context.  On iOS, if the output context is routed locally then the value of this property will be an array containing a single built-in output device.  If the value of this property is an empty array, the output context is routing its media data to nowhere.
 */
@property (readonly) NSArray<AVOutputDevice *> *outputDevices SPI_AVAILABLE(macos(10.13), ios(11.0), tvos(11.0), watchos(4.0));

/*!
 @constant		AVOutputContextOutputDevicesDidChangeNotification
 @abstract		A notification that fires when the set of devices changes.
 @discussion
	If an initiator was specified via AVOutputContextSetOutputDevicesOptionInitiator when the output devices were set, the payload for this notification will include AVOutputContextDestinationChangeInitiatorKey.
 */
AVF_EXPORT NSNotificationName const AVOutputContextOutputDevicesDidChangeNotification SPI_AVAILABLE(macos(10.13), ios(11.0), tvos(11.0), watchos(4.0));

/*!
 @enum			AVOutputContextSetOutputDevicesOption
 @abstract		Options for use when setting output devices via -setOutputDevices:options:
 @constant		AVOutputContextSetOutputDevicesOptionInitiator
	A string describing the user interface that was used to initiate the route change.  Standard strings are defined in <AirPlayRoutePrediction/ARPFeedback.h>.  This value will be included in output device change notifications via AVOutputContextDestinationChangeInitiatorKey, in all processes that share the same output context.
 */
typedef NSString *AVOutputContextSetOutputDevicesOption NS_STRING_ENUM SPI_AVAILABLE(macos(10.14.5), ios(12.3), tvos(12.3), watchos(5.2.1));
	AVF_EXPORT AVOutputContextSetOutputDevicesOption const AVOutputContextSetOutputDevicesOptionInitiator SPI_AVAILABLE(macos(10.14.5), ios(12.3), tvos(12.3), watchos(5.2.1));

/*!
 @method	setOutputDevices:options:completionHandler:
 @abstract	Replaces the output context's output devices with the given array of output devices.
 @discussion
	If a device in the array is already associated with another output context, this operation will disassociate the device from that output context and associate it with the receiver.
 
	This operation completes asynchronously.  Listen for AVOutputContextOutputDevicesDidChangeNotification to be notified when the devices are set.  To track the progress of this operation, listen for AVOutputContextDestinationChangeInitiatedNotification.

	For an output context that supports this method, this method should always be used instead of -setOutputDevice:options:completionHandler to change the destination of the output context.  Setting an empty array of devices is not supported.  On iOS, to stop playing to an external device use AVOutputDeviceDiscoverySession to find an appropriate built-in device and call this method with an array containing only that device.
 */
- (void)setOutputDevices:(NSArray<AVOutputDevice *> *)devices options:(nullable NSDictionary<AVOutputContextSetOutputDevicesOption, id> *)options completionHandler:(nullable void (^)(AVOutputContextDestinationChange *result))completionHandler SPI_AVAILABLE(macos(10.14.5), ios(12.3), tvos(12.3), watchos(5.2.1));

/*!
 @method	setOutputDevices:
 @abstract	Replaces the output context's output devices with the given array of output devices.
 @discussion
	If a device in the array is already associated with another output context, this operation will disassociate the device from that output context and associate it with the receiver.
 
	This operation completes asynchronously.  Listen for AVOutputContextOutputDevicesDidChangeNotification to be notified when the devices are set.  To track the progress of this operation, listen for AVOutputContextDestinationChangeInitiatedNotification.

	For an output context that supports this method, this method should always be used instead of -setOutputDevice:options: to change the destination of the output context.  Setting an empty array of devices is not supported.  On iOS, to stop playing to an external device use AVOutputDeviceDiscoverySession to find an appropriate built-in device and call this method with an array containing only that device.
 */
- (void)setOutputDevices:(NSArray<AVOutputDevice *> *)devices SPI_AVAILABLE(macos(10.13), ios(11.0), tvos(11.0), watchos(4.0));

/*!
 @enum			AVOutputContextAddOutputDeviceOption
 @abstract		Options for use when adding an output device via -addOutputDevice:options:completionHandler:.
 @constant		AVOutputContextAddOutputDeviceOptionAuthorizationToken
	Indicates the e.g. password to be used for authorization while adding an output device.  The value of this key is an NSString.  If the key is not present in the options dictionary, the user is prompted to enter a password.
 @constant		AVOutputContextAddOutputDeviceOptionCancelIfAuthRequired
	If an NSNumber wrapping a boolean YES is used as the value for this key, and authorization is required to connect to an output device, associating an output device with an output context will automatically be cancelled, rather than asking the user for a password.  See AVOutputContextDestinationChangeCancellationReasonAuthorizationSkipped.
 @constant		AVOutputContextAddOutputDeviceOptionInitiator
	A string describing the user interface that was used to initiate the route change.  Standard strings are defined in <AirPlayRoutePrediction/ARPFeedback.h>.  This value will be included in output device change notifications via AVOutputContextDestinationChangeInitiatorKey, in all processes that share the same output context.
 */
typedef NSString *AVOutputContextAddOutputDeviceOption NS_STRING_ENUM SPI_AVAILABLE(macos(10.13.2), ios(11.2), tvos(11.2), watchos(4.2));
	AVF_EXPORT AVOutputContextAddOutputDeviceOption const AVOutputContextAddOutputDeviceOptionAuthorizationToken SPI_AVAILABLE(macos(10.13.4), ios(11.3), tvos(11.3), watchos(4.3));
	AVF_EXPORT AVOutputContextAddOutputDeviceOption const AVOutputContextAddOutputDeviceOptionCancelIfAuthRequired SPI_AVAILABLE(macos(10.13.4), ios(11.3), tvos(11.3), watchos(4.3));
	AVF_EXPORT AVOutputContextAddOutputDeviceOption const AVOutputContextAddOutputDeviceOptionInitiator SPI_AVAILABLE(macos(10.15), ios(13.0), tvos(13.0), watchos(6.0));

/*!
 @method	addOutputDevice:options:completionHandler:
 @abstract	Add output device.
 @discussion
	The parameter to the completion handler is an AVOutputContextDestinationChange that already has a terminal status.
 */
- (void)addOutputDevice:(AVOutputDevice *)device options:(nullable NSDictionary<AVOutputContextAddOutputDeviceOption, id> *)options completionHandler:(nullable void (^)(AVOutputContextDestinationChange *result))completionHandler SPI_AVAILABLE(macos(10.13.2), ios(11.2), tvos(11.2), watchos(4.2));

/*!
 @enum			AVOutputContextRemoveOutputDeviceOption
 @abstract		Options for use when removing an output device via -removeOutputDevice:options:completionHandler:.
 @constant		AVOutputContextRemoveOutputDeviceOptionInitiator
	A string describing the user interface that was used to initiate the route change.  Standard strings are defined in <AirPlayRoutePrediction/ARPFeedback.h>.  This value will be included in output device change notifications via AVOutputContextDestinationChangeInitiatorKey, in all processes that share the same output context.
 */
typedef NSString *AVOutputContextRemoveOutputDeviceOption NS_STRING_ENUM SPI_AVAILABLE(macos(10.15), ios(13.0), tvos(13.0), watchos(6.0));
	AVF_EXPORT AVOutputContextRemoveOutputDeviceOption const AVOutputContextRemoveOutputDeviceOptionInitiator SPI_AVAILABLE(macos(10.15), ios(13.0), tvos(13.0), watchos(6.0));

/*!
 @method	removeOutputDevice:options:completionHandler:
 @abstract	Remove output device.
 @discussion
	The parameter to the completion handler is an AVOutputContextDestinationChange that already has a terminal status.
 */
- (void)removeOutputDevice:(AVOutputDevice *)device options:(nullable NSDictionary<AVOutputContextRemoveOutputDeviceOption, id> *)options completionHandler:(nullable void (^)(AVOutputContextDestinationChange *result))completionHandler SPI_AVAILABLE(macos(10.15), ios(13.0), tvos(13.0), watchos(6.0));

/*!
 @method	removeOutputDevice:
 @abstract	Remove output device.
 @discussion
	This operation completes asynchronously.  Listen for AVOutputContextOutputDevicesDidChangeNotification to be notified when the device is removed.  To track the progress of this operation, listen for AVOutputContextDestinationChangeInitiatedNotification.
 */
- (void)removeOutputDevice:(AVOutputDevice *)device SPI_AVAILABLE(macos(10.13), ios(11.0), tvos(11.0), watchos(4.0));

@end

@interface AVOutputContext (AVAudioSession)

/*!
 @method		preferredOutputDevicesForAudioSession:
 @abstract		Indicates the output device(s) preferred by an audio session, as implied by its configuration.
 @discussion
	This method can be used to determine which output device(s) will be chosen for audio output when the audio session becomes active, before actually activating the audio session.  If the given audio session is already active, the returned output devices may or may not still be picked on the output context associated with the audio session.  For example, the user may have selected an AirPlay device after the audio session became active.
 */
+ (NSArray<AVOutputDevice *> *)preferredOutputDevicesForAudioSession:(AVAudioSession *)audioSession SPI_AVAILABLE(ios(12.0), tvos(12.0), watchos(5.0)) API_UNAVAILABLE(macos);

@end

@interface AVOutputContext (AVOutputContextVolumeControl)

/*!
 @property		providesControlForAllVolumeFeatures
 @abstract		Indicates whether the receiver provides control for all volume-related features in its current configuration.
 @discussion
	The set of available volume features, and therefore the value of this property, can change based on the configuration of the AVOutputContext.  For example, certain region-specific volume features become possible when this context is routed to wired headphones.  If not all of these features can be controlled through the AVOutputContext and AVOutputDevice interfaces, the value of this property will be NO.
 
	When the value of this property is YES, the volume operations -[AVOutputContext setVolume:] and -[AVOutputDevice setVolume:] can be used to control the full gamut of volume features available for the current configuration.  When the value of this property is NO, it may be possible to achieve full volume control using interfaces outside of AVFoundation.
 */
@property (readonly) BOOL providesControlForAllVolumeFeatures SPI_AVAILABLE(macos(10.13), ios(11.0), tvos(11.0), watchos(4.0));

/*!
 @constant		AVOutputContextProvidesControlForAllVolumeFeaturesDidChangeNotification
 @abstract		A notification that fires whenever the value of providesControlForAllVolumeFeatures changes.
 */
AVF_EXPORT NSNotificationName const AVOutputContextProvidesControlForAllVolumeFeaturesDidChangeNotification SPI_AVAILABLE(macos(10.13), ios(11.0), tvos(11.0), watchos(4.0));

/*!
 @property	volume
 @abstract	Indicates the master volume for all devices set on the output context.
 @discussion
	This property is not key-value observable.
 */
@property (readonly) float volume SPI_AVAILABLE(macos(10.13), ios(11.0), tvos(11.0), watchos(4.0));

/*!
 @constant	AVOutputContextVolumeDidChangeNotification
 @abstract	A notification that fires when the volume changes on an output context.
 @discussion
	The output context's volume can change in response to a call to -setVolume:, either in this process or another process.  It can also change in response to -[AVOutputDevice setVolume:] being invoked on an output device that is set on the context.
 */
AVF_EXPORT NSNotificationName const AVOutputContextVolumeDidChangeNotification SPI_AVAILABLE(macos(10.13), ios(11.0), tvos(11.0), watchos(4.0));

/*!
 @property		canSetVolume
 @abstract		Indicates whether the output context supports volume control.
 */
@property (readonly) BOOL canSetVolume SPI_AVAILABLE(macos(10.13), ios(11.0), tvos(11.0), watchos(4.0));

/*!
 @constant		AVOutputContextCanSetVolumeDidChangeNotification
 @abstract		A notification that fires when the value of AVOutputContext.canSetVolume changes.
 */
AVF_EXPORT NSNotificationName const AVOutputContextCanSetVolumeDidChangeNotification SPI_AVAILABLE(macos(10.13), ios(11.0), tvos(11.0), watchos(4.0));

/*!
 @method	setVolume:
 @abstract	Sets the master volume for the all devices set on the output context.
 @discussion
	This operation completes asynchronously.  Listen for AVOutputContextVolumeDidChangeNotification to be notified when the volume changes.
 */
- (void)setVolume:(float)volume SPI_AVAILABLE(macos(10.13), ios(11.0), tvos(11.0), watchos(4.0));

@end

@interface AVOutputContext (AVOutputContextPlaybackControl)

/*!
 @method		pausePlaybackOnAllOutputDevicesWithCompletionHandler:
 @abstract		Sends a "pause" message to every device added to the output context.
 @discussion
	This method is only functional on output contexts created using +outputContextForControllingOutputDeviceGroupWithID:.  	This method will fail until -[AVOutputContextCommunicationChannelDelegate outputContextOutgoingCommunicationChannelDidBecomeAvailable:] has been invoked.
 */
- (void)pausePlaybackOnAllOutputDevicesWithCompletionHandler:(nullable void (^)(NSError * _Nullable error))completionHandler SPI_AVAILABLE(macos(10.13.2), ios(11.2), tvos(11.2), watchos(4.2));

/*!
 @method		muteAllOutputDevicesWithCompletionHandler:
 @abstract		Sends a "mute" message to every device added to the output context.
 @discussion
	This method is only functional on output contexts created using +outputContextForControllingOutputDeviceGroupWithID:.  	This method will fail until -[AVOutputContextCommunicationChannelDelegate outputContextOutgoingCommunicationChannelDidBecomeAvailable:] has been invoked.
 */
- (void)muteAllOutputDevicesWithCompletionHandler:(nullable void (^)(NSError * _Nullable error))completionHandler SPI_AVAILABLE(macos(10.13.2), ios(11.2), tvos(11.2), watchos(4.2));

@end

@interface AVOutputContext (AVOutputContextCommunicationChannel)

/*!
 @property		outgoingCommunicationChannel
 @abstract		A channel for communicating with the receiver's output device(s).
 @discussion
	If the value of this property is nil, no such communication is possible.  This property is not key-value observable.
 */
@property (nonatomic, readonly, nullable) AVOutputContextCommunicationChannel *outgoingCommunicationChannel SPI_AVAILABLE(macos(10.13), ios(11.0), tvos(11.0), watchos(4.0));

/*!
 @enum			AVOutputContextCommunicationChannelOption
 @abstract		Options for creating communication channels.
 @constant AVOutputContextCommunicationChannelOptionControlType
	An AVOutputContextCommunicationChannelControlType representing the control type of the communication channel to be created.
 */
typedef NSString *AVOutputContextCommunicationChannelOption NS_STRING_ENUM SPI_AVAILABLE(macos(10.13.2), ios(11.2), tvos(11.2), watchos(4.2));
	AVF_EXPORT AVOutputContextCommunicationChannelOption const AVOutputContextCommunicationChannelOptionControlType SPI_AVAILABLE(macos(10.13.2), ios(11.2), tvos(11.2), watchos(4.2));

/*!
 @enum			AVOutputContextCommunicationChannelControlType
 @abstract		Communication channel control types.
 @constant AVOutputContextCommunicationChannelControlTypeDirect
	The channel communicates directly with the output device.  Only valid when the output context contains a single device for which AVOutputDevice.canBeGroupLeader is YES.
 @constant AVOutputContextCommunicationChannelControlTypeRelayed
	The channel communicates with the group's leader using a connection that is relayed through other devices in the group.  Only output devices for which AVOutputDevice.canRelayCommunicationChannel can participate in the relayed communication channel.
 */
typedef NSString *AVOutputContextCommunicationChannelControlType NS_STRING_ENUM SPI_AVAILABLE(macos(10.13.2), ios(11.2), tvos(11.2), watchos(4.2));
	AVF_EXPORT AVOutputContextCommunicationChannelControlType const AVOutputContextCommunicationChannelControlTypeDirect SPI_AVAILABLE(macos(10.13.2), ios(11.2), tvos(11.2), watchos(4.2));
	AVF_EXPORT AVOutputContextCommunicationChannelControlType const AVOutputContextCommunicationChannelControlTypeRelayed SPI_AVAILABLE(macos(10.13.2), ios(11.2), tvos(11.2), watchos(4.2));

/*!
 @method		openCommunicationChannelWithOptions:
 @abstract		Open a communication channel.
 @discussion
	This method will return nil until -[AVOutputContextCommunicationChannelDelegate outputContextOutgoingCommunicationChannelDidBecomeAvailable:] is invoked.
 */
- (nullable AVOutputContextCommunicationChannel *)openCommunicationChannelWithOptions:(nullable NSDictionary<AVOutputContextCommunicationChannelOption, id> *)options error:(NSError * _Nullable * _Nullable)outError SPI_AVAILABLE(macos(10.13.2), ios(11.2), tvos(11.2), watchos(4.2));

/*!
 @property		communicationChannelDelegate
 @abstract		A delegate for receiving communication channel events.
 */
@property (nonatomic, weak, nullable) id <AVOutputContextCommunicationChannelDelegate> communicationChannelDelegate SPI_AVAILABLE(macos(10.13), ios(11.0), tvos(11.0), watchos(4.0));

@end


/*!
 @class			AVOutputContextCommunicationChannel
 @abstract		An object for sending data from one output context to another.
 */
SPI_AVAILABLE(macos(10.13), ios(11.0), tvos(11.0), watchos(4.0))
@interface AVOutputContextCommunicationChannel : NSObject
{
@private
	AVOutputContextCommunicationChannelInternal *_ivars;
}
AV_INIT_UNAVAILABLE

/*!
 @method		sendData:completionHandler:
 @abstract		Send data through the communication channel.
 */
- (void)sendData:(NSData *)data completionHandler:(nullable void (^)(NSError * _Nullable))completionHandler;

@end


/*!
 @protocol		AVOutputContextCommunicationChannelDelegate
 @abstract		Objects that conform to this protocol can receive events when a communication channel sends data or becomes closed.
 */
SPI_AVAILABLE(macos(10.13), ios(11.0), tvos(11.0), watchos(4.0))
@protocol AVOutputContextCommunicationChannelDelegate <NSObject>

/*!
 @method		outputContextOutgoingCommunicationChannelDidBecomeAvailable:
 @abstract		Invoked whenever the output context's outgoing communication channel becomes available.
 @discussion
	Use this method to discover when it is possible to retrieve a non-nil communication channel from the outgoingCommunicationChannel property, typically after adding the first output device.  At this point, it is also possible to create a new channel via -[AVOutputContext openCommunicationChannelWithOptions:].
 */
@optional
- (void)outputContextOutgoingCommunicationChannelDidBecomeAvailable:(AVOutputContext *)outputContext;

/*!
 @method		outputContext:didReceiveData:fromCommunicationChannel:
 @abstract		Invoked whenever an output context communication channel receives data.
 @discussion
	This method is invoked whenever a new communication channel or existing communication channel sends data.  To reply, use -[AVOutputContextCommunicationChannel sendData:completionHandler:].
 */
@optional
- (void)outputContext:(AVOutputContext *)outputContext didReceiveData:(NSData *)data fromCommunicationChannel:(AVOutputContextCommunicationChannel *)communicationChannel;

/*!
 @method		outputContext:didCloseCommunicationChannel:
 @abstract		Invoked whenever an output context communication channel is closed.
 @discussion
	After the delegate receives this message, no further data will arrive from the given communication channel.  In addition, any further attempts to send data to the communication channel will fail.
 */
@optional
- (void)outputContext:(AVOutputContext *)outputContext didCloseCommunicationChannel:(AVOutputContextCommunicationChannel *)communicationChannel;

@end


/*!
 @class			AVOutputContextDestinationChange
 @abstract		An instance of AVOutputContextDestinationChange represents the progress of an AVOutputContext changing its destination.
 */
SPI_AVAILABLE(macos(10.13), ios(11.0), tvos(11.0), watchos(4.0))
@interface AVOutputContextDestinationChange : NSObject
{
@private
	AVOutputContextDestinationChangeInternal *_ivars;
}

/*!
 @enum			AVOutputContextDestinationChangeStatus
 @abstract		Identifiers for the various states that an AVOutputContextDestinationChange can be in.
 @constant		AVOutputContextDestinationChangeStatusUnknown
	The destination change has not begun.
 @constant		AVOutputContextDestinationChangeStatusInProgress
	The destination change is in progress.
 @constant		AVOutputContextDestinationChangeStatusCompleted
	The destination change completed successfully.
 @constant		AVOutputContextDestinationChangeStatusFailed
	The destination change failed.
 @constant		AVOutputContextDestinationChangeStatusCancelled
	The destination change was cancelled.
 */
typedef NS_ENUM(NSInteger, AVOutputContextDestinationChangeStatus) {
	AVOutputContextDestinationChangeStatusUnknown = 0,
	AVOutputContextDestinationChangeStatusInProgress = 1,
	AVOutputContextDestinationChangeStatusCompleted = 2,
	AVOutputContextDestinationChangeStatusFailed = 3,
	AVOutputContextDestinationChangeStatusCancelled = 4
};

/*!
 @property		status
 @abstract		The status of a destination change operation.
 @discussion
	If the value of this property is AVOutputContextDestinationChangeStatusFailed, the error property will contain more information about the failure.
 
	There is no guarantee that the status will ever progress beyond AVOutputContextDestinationChangeStatusInProgress.  If this class is used to e.g. display progress UI to the user, it is prudent to have an alternate trigger for dismissing that UI, for example a backup timer.
 
	This property is key-value observable.
 */
@property (readonly) AVOutputContextDestinationChangeStatus status;

/*!
 @enum			AVOutputContextDestinationChangeCancellationReason
 @abstract		Reasons for cancellation of a destination change.
 @constant		AVOutputContextDestinationChangeCancellationReasonAuthorizationSkipped
	Authorization is required, but authorization was not performed because AVOutputContextSetOutputDeviceCancelIfAuthRequiredKey, AVOutputContextAddOutputDeviceOptionCancelIfAuthRequired, or AVOutputContextDeviceGroupControlOptionCancelAddDeviceIfAuthRequired was used.
 */
typedef NSString *AVOutputContextDestinationChangeCancellationReason NS_STRING_ENUM SPI_AVAILABLE(macos(10.13.2), ios(11.2), tvos(11.2), watchos(4.2));
	AVF_EXPORT AVOutputContextDestinationChangeCancellationReason const AVOutputContextDestinationChangeCancellationReasonAuthorizationSkipped SPI_AVAILABLE(macos(10.13.2), ios(11.2), tvos(11.2), watchos(4.2));

/*!
 @property		cancellationReason
 @abstract		If status is AVOutputContextDestinationChangeStatusCancelled, provides a reason for the cancellation.
 @discussion
	This property will be nil if the status is not AVOutputContextDestinationChangeStatusCancelled or if no specific cancellation reason is available.
 */
@property (readonly, nullable) AVOutputContextDestinationChangeCancellationReason cancellationReason SPI_AVAILABLE(macos(10.13.2), ios(11.2), tvos(11.2), watchos(4.2));

@end


/*!
 @class			AVOutputContextManager
 @abstract		A class for observing the activities of a collection of AVOutputContext instances.
 @discussion
	*** PLEASE contact Core Media Engineering before using this class.  Unauthorized use will disrupt system UI functionality. ***
 */
SPI_AVAILABLE(macos(10.13), ios(11.0), tvos(11.0), watchos(4.0))
@interface AVOutputContextManager : NSObject
{
@private
	AVOutputContextManagerInternal *_ivars;
}
AV_INIT_UNAVAILABLE

/*!
 @method		outputContextManagerForAllOutputContexts
 @abstract		Gets the manager instance for observing all output contexts in all processes.
 */
+ (AVOutputContextManager *)outputContextManagerForAllOutputContexts;

/*!
 @constant		AVOutputContextManagerOutputContextDidFailToConnectToOutputDeviceNotification
 @abstract		A notification posted when an AVOutputContext fails to connect to an AVOutputDevice.
 @discussion
	If AVOutputContextManagerFailureReasonKey does not appear in the userInfo dictionary, no additional information about why the failure occurred is available.
 */
AVF_EXPORT NSNotificationName const AVOutputContextManagerOutputContextDidFailToConnectToOutputDeviceNotification SPI_AVAILABLE(macos(10.13), ios(11.0), tvos(11.0), watchos(4.0));
	AVF_EXPORT NSString * const AVOutputContextManagerOutputDeviceKey SPI_AVAILABLE(macos(10.13), ios(11.0), tvos(11.0), watchos(4.0)); // AVOutputDevice
	AVF_EXPORT NSString * const AVOutputContextManagerFailureReasonKey SPI_AVAILABLE(macos(10.13), ios(11.0), tvos(11.0), watchos(4.0)); // AVOutputContextConnectionFailureReason

/*!
 @enum			AVOutputContextDeviceConnectionFailureReason
 @constant		AVOutputContextDeviceConnectionFailureReasonDeviceInUse
	The device is already in use by another AVOutputContext.
 @constant		AVOutputContextDeviceConnectionFailureReasonDeviceOutOfRange
	The device is too far away.
 @constant		AVOutputContextDeviceConnectionFailureReasonNotAPeerInHomeGroup
	The device only allows connections from peers in the "home" group, and the current device is not a peer in the "home" group.  See the AVOutputDevice properties automaticallyAllowsConnectionsFromPeersInHomeGroup and onlyAllowsConnectionsFromPeersInHomeGroup for details about an output device's peer configuration.
 @constant		AVOutputContextDeviceConnectionFailureReasonDeviceNotConnectedToInternet
	The device requires an internet connection in order to connect to it, but the device is not connected to the internet.
 @constant		AVOutputContextDeviceConnectionFailureReasonDeviceNotMFiCertified
	The connection to the device failed because its MFi certification is missing or has been revoked.
 */
typedef NSString *AVOutputContextDeviceConnectionFailureReason NS_STRING_ENUM SPI_AVAILABLE(macos(10.13), ios(11.0), tvos(11.0), watchos(4.0));
	AVF_EXPORT AVOutputContextDeviceConnectionFailureReason const AVOutputContextDeviceConnectionFailureReasonDeviceInUse SPI_AVAILABLE(macos(10.13), ios(11.0), tvos(11.0), watchos(4.0));
	AVF_EXPORT AVOutputContextDeviceConnectionFailureReason const AVOutputContextDeviceConnectionFailureReasonDeviceOutOfRange SPI_AVAILABLE(macos(10.13), ios(11.0), tvos(11.0), watchos(4.0));
	AVF_EXPORT AVOutputContextDeviceConnectionFailureReason const AVOutputContextDeviceConnectionFailureReasonNotAPeerInHomeGroup SPI_AVAILABLE(macos(10.13.5), ios(11.4), tvos(11.4), watchos(4.3));
	AVF_EXPORT AVOutputContextDeviceConnectionFailureReason const AVOutputContextDeviceConnectionFailureReasonDeviceNotConnectedToInternet SPI_AVAILABLE(macos(10.14.4), ios(12.2), tvos(12.2), watchos(5.2));
	AVF_EXPORT AVOutputContextDeviceConnectionFailureReason const AVOutputContextDeviceConnectionFailureReasonDeviceNotMFiCertified SPI_AVAILABLE(macos(10.15), ios(13.0), tvos(13.0), watchos(6.0));

@end


@interface AVOutputContext (ToBeDeprecated)

/*!
 @method		outputContextForControllingOutputDeviceGroupWithID:
 @abstract		Creates a new output context for controlling the output device group with the given ID.
 @discussion
	Use +outputContextForControllingOutputDeviceGroupWithID:options: instead.
 */
+ (instancetype)outputContextForControllingOutputDeviceGroupWithID:(NSString *)groupID API_DEPRECATED_WITH_REPLACEMENT("+outputContextForControllingOutputDeviceGroupWithID:options:", macos(10.13, API_TO_BE_DEPRECATED), ios(11.0, API_TO_BE_DEPRECATED), tvos(11.0, API_TO_BE_DEPRECATED), watchos(4.0, API_TO_BE_DEPRECATED));

/*!
 @property		ID
 @abstract		A unique identifier for the output context.
 @discussion
	Use the contextID property instead.
 */
@property (nonatomic, readonly) NSString *ID API_DEPRECATED_WITH_REPLACEMENT("contextID", macos(10.13, API_TO_BE_DEPRECATED), ios(11.0, API_TO_BE_DEPRECATED), tvos(11.0, API_TO_BE_DEPRECATED), watchos(4.0, API_TO_BE_DEPRECATED));

/*!
 @method		setOutputDevice:forFeatures:
 @abstract		Sets the output device for a feature.
 @discussion
	Use -setOutputDevice:options:completionHandler: instead.
 */
- (BOOL)setOutputDevice:(nullable AVOutputDevice *)outputDevice forFeatures:(AVOutputDeviceFeatures)features API_DEPRECATED_WITH_REPLACEMENT("-setOutputDevice:options:completionHandler:", macos(10.11, API_TO_BE_DEPRECATED), ios(9.0, API_TO_BE_DEPRECATED), tvos(9.0, API_TO_BE_DEPRECATED), watchos(2.0, API_TO_BE_DEPRECATED));

/*!
 @method		setOutputDevice:options:
 @abstract		Sets the output device with options.
 @discussion
	Use -setOutputDevice:options:completionHandler: instead.
 */
- (void)setOutputDevice:(nullable AVOutputDevice *)outputDevice options:(nullable NSDictionary<AVOutputContextSetOutputDeviceOptionsKey, id> *)options API_DEPRECATED_WITH_REPLACEMENT("-setOutputDevice:options:completionHandler:", macos(10.13, API_TO_BE_DEPRECATED), ios(11.0, API_TO_BE_DEPRECATED), tvos(11.0, API_TO_BE_DEPRECATED), watchos(4.0, API_TO_BE_DEPRECATED));

/*!
 @method	addOutputDevice:
 @abstract	Add output device.
 @discussion
	Use -addOutputDevice:options:completionHandler: instead.
 */
- (void)addOutputDevice:(AVOutputDevice *)device API_DEPRECATED_WITH_REPLACEMENT("-addOutputDevice:options:completionHandler:", macos(10.13, API_TO_BE_DEPRECATED), ios(11.0, API_TO_BE_DEPRECATED), tvos(11.0, API_TO_BE_DEPRECATED), watchos(4.0, API_TO_BE_DEPRECATED));

@end

NS_ASSUME_NONNULL_END
