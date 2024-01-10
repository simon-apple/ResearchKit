/*
	File:  AVOutputContext.h
 
	Framework:  AVFoundation
 
	Copyright 2015-2019 Apple Inc. All rights reserved.
 
 */

#import <AVFoundation/AVMediaFormat.h>

@class AVOutputContextInternal;

NS_ASSUME_NONNULL_BEGIN

AVF_EXPORT NSNotificationName const AVOutputContextOutputDeviceDidChangeNotification SPI_AVAILABLE(macos(10.11), ios(9.0), tvos(9.0), watchos(2.0));
	AVF_EXPORT NSString *const AVOutputContextDestinationChangeInitiatorKey SPI_AVAILABLE(macos(10.14.5), ios(12.3), tvos(12.3), watchos(5.2.1));

/*!
 @class			AVOutputContext
 @abstract		An AVOutputContext represents a choice of output destination for a playback object such as AVPlayer.
 @discussion
	An instance of AVOutputContext can be shared between multiple playback objects, which means that any output destination picked on that output context will be applied to each associated playback object.  This sharing implies that all objects associated with a particular context vie for the same output device, and the last one to get the context is allowed access to the output device.
 */
SPI_AVAILABLE(macos(10.11), ios(9.0), tvos(9.0), watchos(2.0))
@interface AVOutputContext : NSObject <NSSecureCoding>
{
@private
	AVOutputContextInternal		*_outputContext;
}

/*!
 @method		outputContext
 @abstract		Creates an instance of an output context. An AVOutputContext defines AVFoundation's model for information associated with the currently selected output device.
 @discussion
	A context can be shared between multiple objects. In case of AirPlay video, this can be achieved by setting the same context on different AVPlayers using [AVPlayer setOutputContext:]. This sharing implies that all objects associated with a particular context vie for the same output device, and the last one to get the context is allowed access to the output device.
 */
+ (instancetype)outputContext;

/*!
 @property		deviceName
 @abstract		The name of the device to which objects associated with the context are currently routed.
 @discussion
	The device name is nil when there is no current output device associated with the context. This property is not key-value observable.
 */
@property (nonatomic, readonly, nullable) NSString *deviceName;

/*!
 @method		sharedAudioPresentationOutputContext
 @abstract		Returns a shared output context to be used for audio presentations.
 @discussion
	*** PLEASE contact Core Media Engineering before using this method. ***

	This is to be used only by clients who are interested in picking audio for the all long-form audio apps on the system.  On macOS, use of this method requires the following entitlement:

		"com.apple.avfoundation.allow-system-wide-context" = true (Boolean)
 

	Use this context if your content is an audio presentation, such as music or podcasts.  This context should not be used for system or ambient sounds.  This output context is shared between every "music" application on the system so that the user can route all music to a particular output device.

	 -setOutputDevices: should be used when changing the destination of this output context instead of -setOutputDevice:options:.  To examine the current destination of this output context, use the outputDevices property instead of the outputDevice property.
 */
+ (nullable AVOutputContext *)sharedAudioPresentationOutputContext SPI_AVAILABLE(macos(10.13), ios(11.0), tvos(11.0), watchos(4.0));

/*!
 @method		auxiliaryOutputContext
 @abstract		Creates an instance of an output context to be used for application-specific purposes.
 @discussion
	On macOS, an application can create multiple auxiliary output context instances, for example one per AVPlayer.  A single auxiliary context can also be shared between multiple playback objects.  Use +sharedOutputContext on iOS.
 */
+ (AVOutputContext *)auxiliaryOutputContext SPI_AVAILABLE(macos(10.13), ios(11.0), tvos(11.0), watchos(4.0));

@end

NS_ASSUME_NONNULL_END
