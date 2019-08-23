/*
	AVSystemController.h
	Celestial
	
	Created by Jeremy on 12/5/06.
	Copyright 2006-2019 Apple Computer. All rights reserved.
	
*/

#import <Foundation/Foundation.h>

#ifndef AV_EXTERN
#ifdef __cplusplus
#define AV_EXTERN extern "C"
#else
#define AV_EXTERN extern
#endif
#endif

// notifications for sharedAVSystemController                                              description                 parameter           parameter types
AV_EXTERN NSString *AVSystemController_SystemHasAudioInputDeviceDidChangeNotification;	// SystemHasAudioInputDevice state changed (no payload)
AV_EXTERN NSString *AVSystemController_ActiveInputRouteForPlayAndRecordNoBluetoothDidChangeNotification;	// ActiveInputRouteForPlayAndRecordNoBluetooth state changed (no payload)
AV_EXTERN NSString *AVSystemController_SystemHasAudioInputDeviceExcludingBluetoothDidChangeNotification;	// SystemHasAudioInputDeviceExcludingBluetooth state changed (no payload)
AV_EXTERN NSString *AVSystemController_HeadphoneJackIsConnectedDidChangeNotification;	// HeadphoneJackIsConnected state changed (no payload)
AV_EXTERN NSString *AVSystemController_SystemVolumeDidChangeNotification;				// audioCategory & newVolume & reason -- volume changed
AV_EXTERN NSString *AVSystemController_EffectiveVolumeDidChangeNotification;				// audioCategory & newEffectiveVolume & reason -- volume changed

AV_EXTERN NSString *AVSystemController_ServerConnectionDiedNotification;     	 // NSNumber (BOOL)
AV_EXTERN NSString *AVSystemController_PostNotificationsFromMainThreadOnly;      // NSNumber (BOOL)
// NOTE: If you are checking for anything other than the receiver route for Audio Routes, talk with the Celeste team.
AV_EXTERN NSString *AVSystemController_ActiveAudioRouteAttribute;
AV_EXTERN NSString *AVSystemController_ActiveAudioRouteDidChangeNotification;			// no payload for now
AV_EXTERN NSString *AVSystemController_CurrentRouteHasVolumeControlDidChangeNotification;	// payload contains AVSystemController_CurrentRouteHasVolumeControlNotificationParameter (new value)
AV_EXTERN NSString *AVSystemController_SpeechDetectionDevicePresentDidChangeNotification;	// payload contains AVSystemController_SpeechDetectionDevicePresentNotificationParameter (new value)

AV_EXTERN NSString *AVSystemController_PickableRoutesDidChangeNotification;				// no payload

// Note: if you start listening to AVSystemController_MutedDidChangeNotification, please talk to us about it.
// We know that this doesn't always fire and need to know about any deadlines that demand it working completely.
AV_EXTERN NSString *AVSystemController_MutedDidChangeNotification;						// audioCategory & newMuted -- muted changed.  

AV_EXTERN NSString *AVSystemController_RecordingStateDidChangeNotification;						// new recording state and client PID
AV_EXTERN NSString *AVSystemController_ExternalScreenDidChangeNotification;						// mirroring (AirPlay or wired) status changed
AV_EXTERN NSString *AVSystemController_CarPlayIsConnectedDidChangeNotification;					// CarPlay is connected value changed
AV_EXTERN NSString *AVSystemController_CarPlayAuxStreamSupportDidChangeNotification;			// CarPlay support aux stream
AV_EXTERN NSString *AVSystemController_CarPlaySupportsMixableSiriDidChangeNotification;			// CarPlay HU siri session supports mixable audio
AV_EXTERN NSString *AVSystemController_UplinkMuteDidChangeNotification;							// new uplink mute
AV_EXTERN NSString *AVSystemController_SoftMuteDidChangeNotification;							// soft mute unmuted on volume change
AV_EXTERN NSString *AVSystemController_PortStatusDidChangeNotification;							// Port status changed notification with route description of the failed port with reason. All other keys are defined in AVController.h and they are the same as those in a route description dictionary. The additional key is mentioned below.

AV_EXTERN NSString *AVSystemController_FullMuteDidChangeNotification;						// audioCategory & newFullMute -- full mute changed.  

AV_EXTERN NSString *AVSystemController_NowPlayingAppPIDDidChangeNotification;				// payload contains now playing app PID
AV_EXTERN NSString *AVSystemController_NowPlayingAppIsPlayingDidChangeNotification;		// payload contains now playing app playing state
AV_EXTERN NSString *AVSystemController_NowPlayingAppDidChangeNotification;				// payload contains now playing app displayID

AV_EXTERN NSString *AVSystemController_SomeClientIsPlayingDidChangeNotification;		// payload contains whether some client is playing audio

AV_EXTERN NSString *AVSystemController_SomeClientIsActiveDidChangeNotification;			// no payload

AV_EXTERN NSString *AVSystemController_VibeIntensityDidChangeNotification;				// payload contains new vibe intensity

AV_EXTERN NSString *AVSystemController_EUVolumeLimitDidChangeNotification;				// payload contains EU volume limit
AV_EXTERN NSString *AVSystemController_EUVolumeLimitEnforcedDidChangeNotification;				// payload tells whether EU volume limit is enforced

AV_EXTERN NSString *AVSystemController_CallIsActiveDidChangeNotification;				// payload contains a boolean that indicates if a call is active
AV_EXTERN NSString *AVSystemController_PreferredExternalRouteDidChangeNotification;     // preferred external route changed, no payload
AV_EXTERN NSString *AVSystemController_VideoStreamsDidChangeNotification;				// video app started/stopped playing on video capable route.
																								// payload contains app bundleID & video routes if app starts playing.
AV_EXTERN NSString *AVSystemController_VideoAppInForegroundDidChangeNotification;		// video app enters/exits foreground on video capable route.
																								// payload contains app bundleID & video routes if app enters foreground.

// notification parameters																	description                  parameter type
AV_EXTERN NSString *AVSystemController_AudioCategoryNotificationParameter;				// audio category				NSString
AV_EXTERN NSString *AVSystemController_EffectiveVolumeNotificationParameter_Category;	// audio category				NSString
AV_EXTERN NSString *AVSystemController_AudioVolumeNotificationParameter;				// audio volume					NSNumber (float)
AV_EXTERN NSString *AVSystemController_EffectiveVolumeNotificationParameter_Volume;		// effective volume					NSNumber (float)
AV_EXTERN NSString *AVSystemController_EffectiveVolumeNotificationParameter_VolumeChangeReason;		// effective volume	 change reason	NSString
AV_EXTERN NSString *AVSystemController_AudioVolumeChangeReasonNotificationParameter;	// why volume changed			NSString (see AVAudioCategories.h for values)
AV_EXTERN NSString *AVSystemController_UserVolumeAboveEUVolumeLimitNotificationParameter;	// whether volume is above the EU volume limit	NSNumber (BOOL)
AV_EXTERN NSString *AVSystemController_AudioMutedNotificationParameter;					// audio muted					NSNumber (BOOL)
AV_EXTERN NSString *AVSystemController_AudioFullMutedNotificationParameter;					// audio full muted			NSNumber (BOOL)
AV_EXTERN NSString *AVSystemController_UplinkMuteNotificationParameter;						// new uplink mute			NSNumber (BOOL)
AV_EXTERN NSString *AVSystemController_SoftMuteNotificationParameter;						// new soft mute			NSNumber (BOOL)
AV_EXTERN NSString *AVSystemController_RecordingStateNotificationParameter;					// new recording state		NSNumber (BOOL)
AV_EXTERN NSString *AVSystemController_RecordingClientPIDNotificationParameter SPI_DEPRECATED("Please use AVSystemController_RecordingClientPIDsNotificationParameter instead.", ios(4.0, 13.0), watchos(1.0, 6.0), tvos(9.0, 13.0)); // recording client PID 	NSNumber (int32_t)
AV_EXTERN NSString *AVSystemController_RecordingClientPIDsNotificationParameter;			// recording client PIDs 	NSArray of NSNumber (int32_t)
AV_EXTERN NSString *AVSystemController_CurrentRouteHasVolumeControlNotificationParameter; // has volume control			NSNumber (BOOL)
AV_EXTERN NSString *AVSystemController_SpeechDetectionDevicePresentNotificationParameter; // speech detection device present	NSNumber (BOOL)
AV_EXTERN NSString *AVSystemController_NowPlayingAppPIDNotificationParameter;				// now playing app PID 		NSNumber (int32_t)
AV_EXTERN NSString *AVSystemController_NowPlayingAppNotificationParameter;				// now playing app displayID	NSString
AV_EXTERN NSString *AVSystemController_NowPlayingAppIsPlayingNotificationParameter;		// now playing app is playing (yes/no) 	NSNumber (BOOL)
AV_EXTERN NSString *AVSystemController_SomeClientIsPlayingNotificationParameter;		// some client is playing (yes/no) 	NSNumber (BOOL)
AV_EXTERN NSString *AVSystemController_VibeIntensityNotificationParameter;				// new vibe intensity			NSNumber (float)
AV_EXTERN NSString *AVSystemController_EUVolumeLimitNotificationParameter;				// EU volume limit	 		NSNumber (float)
AV_EXTERN NSString *AVSystemController_EUVolumeLimitEnforcedNotificationParameter;		// EU volume limit enforced 	NSNumber (BOOL)
AV_EXTERN NSString *AVSystemController_CallIsActiveNotificationParameter;				// call (phone/FaceTime) is active (yes/no) 	NSNumber (BOOL)
AV_EXTERN NSString *AVSystemController_CarPlayIsConnectedNotificationParameter;			// CarPlay is connected (yes/no) NSNumber (BOOL)
AV_EXTERN NSString *AVSystemController_CarPlayAuxStreamSupportNotificationParameter;	// CarPlay supports aux stream (yes/no) NSNumber (BOOL)
AV_EXTERN NSString *AVSystemController_CarPlaySupportsMixableSiriNotificationParameter;	// CarPlay HU Siri session supports mixable audio (yes/no) NSNumber (BOOL)
AV_EXTERN NSString *AVSystemController_ActiveAudioRouteDidChangeNotificationParameter_ShouldPause;	// indicates whether route change should lead to pausing playback NSNUMBER (BOOL)
AV_EXTERN NSString *AVSystemController_VideoStreamsDidChangeNotificationParameter_BundleID;	// indicates bundleID of video app.
AV_EXTERN NSString *AVSystemController_VideoStreamsDidChangeNotificationParameter_RouteNames;// indicates video routes.
AV_EXTERN NSString *AVSystemController_VideoAppInForegroundDidChangeNotificationParameter_BundleID;	// indicates bundleID of video app.
AV_EXTERN NSString *AVSystemController_VideoAppInForegroundDidChangeNotificationParameter_RouteNames;// indicates video routes.

// attributes for sharedAVSystemController                                                 type 
AV_EXTERN NSString *AVSystemController_AudioIsPlayingSomewhereAttribute;				// NSNumber (BOOL) YES == audio is playing; NO == audio is not playing (get only)
AV_EXTERN NSString *AVSystemController_SpeechDetectionDevicePresentAttribute;			// NSNumber (BOOL) YES == speech detection device is present; NO == speech detection device is NOT present (get only)
AV_EXTERN NSString *AVSystemController_ActiveClientPIDsThatHideTheSpeechDetectionDeviceAttribute; // NSArray NULL if no such client is active; NSArray of NSNumber(int32_t) client PIDs if there are active clients which hide the speech detection VAD.
AV_EXTERN NSString *AVSystemController_SomeClientIsPlayingLongFormAudioAttribute;		// NSNumber (BOOL) YES == long form audio is playing; NO == long form audio is not playing (get only) (valid only for watchOS currently)
AV_EXTERN NSString *AVSystemController_SystemHasAudioInputDeviceAttribute;				// NSNumber (BOOL) YES == has input device; NO == no input device
AV_EXTERN NSString *AVSystemController_SystemHasAudioInputDeviceExcludingBluetoothAttribute; // NSNumber (BOOL) YES == has input device; NO == no input device
AV_EXTERN NSString *AVSystemController_HeadphoneJackIsConnectedAttribute;				// NSNumber (BOOL) YES == connected; NO == no connection detected
AV_EXTERN NSString *AVSystemController_HeadphoneJackHasInputAttribute;					// NSNumber (BOOL) YES == has input (headset); NO == no input (headphones)
AV_EXTERN NSString *AVSystemController_HeadphoneVolumeLimitAttribute;					// NSNumber (float) range 0.0 .. 1.0 (default is 1.0 == full range)
AV_EXTERN NSString *AVSystemController_ParentalVolumeCappedToEUVolumeLimitAttribute;	// NSNumber (BOOL) YES = parental volume capped to EU volume limit, NO == not capped) (get/set)
AV_EXTERN NSString *AVSystemController_EUVolumeLimitAttribute;							// NSNumber (float) range 0.0 .. 1.0 (greater than 1.0 is capped to 1.0) (get only)
AV_EXTERN NSString *AVSystemController_EUVolumeLimitEnforcedAttribute;					// NSNumber (BOOL) YES == Acknowlegdement needed to go past the volume limit NO == User can go past the volume limit. (get only)
AV_EXTERN NSString *AVSystemController_DeviceManufacturedForEURegion;					// NSNumber (BOOL) returns whether the device is manufactured for EU region (get only)
AV_EXTERN NSString *AVSystemController_ActiveAudioRouteAttribute;						// NSString -- returns current route

AV_EXTERN NSString *AVSystemController_CurrentlyActiveCategoryAttribute;				// NSString (returns NULL if nothing active)
AV_EXTERN NSString *AVSystemController_CurrentlyActiveModeAttribute;					// NSString (returns NULL if nothing active)
AV_EXTERN NSString *AVSystemController_FullMuteAttribute;								// NSNumber (BOOL) YES == muted, NO == not muted 
AV_EXTERN NSString *AVSystemController_IsSomeoneRecordingAttribute SPI_DEPRECATED("Please use AVSystemController_RecordingClientPIDsAttribute instead.", ios(4.0, 13.0), watchos(1.0, 6.0), tvos(9.0, 13.0)); // NSNumber (int32_t) 0 if no one is recording; client PID if someone is.
AV_EXTERN NSString *AVSystemController_RecordingClientPIDsAttribute;					// NSArray NULL if no one is recording; NSArray of NSNumber(int32_t) client PIDs if there are recording clients.
AV_EXTERN NSString *AVSystemController_UplinkMuteAttribute;								// NSNumber (BOOL) YES == uplink muted, NO == uplink not mute (presently valid only for a phone call) 
AV_EXTERN NSString *AVSystemController_DownlinkMuteAttribute;							// NSNumber (BOOL) YES == downlink muted, NO == downlink not muted (presently valid only for a phone call) 
AV_EXTERN NSString *AVSystemController_ThermalControlInfoAttribute;						// NSDictionary This dictionary contains the ThermalControlInfo. Only valid for the Puffin output device on B238a for now.
AV_EXTERN NSString *AVSystemController_AppToInterruptCurrentNowPlayingSessionAttribute; // NSString bundle ID of a playing app that wants to interrupt the current now playing session
AV_EXTERN NSString *AVSystemController_MeasuredHDMILatencyAttribute;					// NSDictionary This dictionary contains the audio & video latency information for 24 and 60 hz refresh rates.
	AV_EXTERN NSString *AVSystemController_MeasuredHDMILatency_MeasuredAudioHDMILatency24Hz; // NSNumber (NSTimeInterval) value for audio latency, 24hz refresh rate with an unknown value of 0.
	AV_EXTERN NSString *AVSystemController_MeasuredHDMILatency_MeasuredAudioHDMILatency60Hz; // NSNumber (NSTimeInterval) value for audio latency, 60hz refresh rate with an unknown value of 0.
	AV_EXTERN NSString *AVSystemController_MeasuredHDMILatency_MeasuredVideoHDMILatency24Hz; // NSNumber (NSTimeInterval) value for video latency, 24hz refresh rate with an unknown value of 0.
	AV_EXTERN NSString *AVSystemController_MeasuredHDMILatency_MeasuredVideoHDMILatency60Hz; // NSNumber (NSTimeInterval) value for video latency, 60hz refresh rate with an unknown value of 0.
AV_EXTERN NSString *AVSystemController_NowPlayingAppShouldPlayOnCarPlayConnectAttribute;// NSNumber (BOOL) YES == NowPlayingApp should resume playback, NO == NowPlayingApp shouldn't resume playback because car is likely playing media initiated by the user
AV_EXTERN NSString *AVSystemController_CarPlayIsConnectedAttribute;						// NSNumber (BOOL) YES == CarPlay is connected, NO == CarPlay is not connected
AV_EXTERN NSString *AVSystemController_CarPlayAuxStreamSupportAttribute;				// NSNumber (BOOL) YES == CarPlay supports Aux Stream, NO == CarPlay does not support Aux Stream
AV_EXTERN NSString *AVSystemController_CarPlaySupportsMixableSiriAttribute;				// NSNumber (BOOL) YES == CarPlay Siri session supports mixable audio, NO == CarPlay siri session does not support mixable audio
AV_EXTERN NSString *AVSystemController_IAmTheiPodAppAttribute;							// NSNumber (BOOL) YES == I am the iPod app( duh! ) (only set) 
AV_EXTERN NSString *AVSystemController_LongFormVideoAppsAttribute;						// NSArray 	This is an array of NSStrings consisting of bundleID's of longform video apps. (get only)
AV_EXTERN NSString *AVSystemController_PIDToInheritApplicationStateFrom;                // NSNumber (int32_t) PID of the app that the process wants to bind to, especially for using the target process' application state
AV_EXTERN NSString *AVSystemController_PIDNowPlayingAppIsInheritingApplicationStateFrom; // NSNumber (int32_t) PID of the app that the now playing app (if any) is inheriting its app state from 
AV_EXTERN NSString *AVSystemController_CanBeNowPlayingAppAttribute;						// NSNumber (BOOL) YES == this app can be the "now playing" app, NO == this app cannot be the "now playing" app (default) 
AV_EXTERN NSString *AVSystemController_AllowAppToInitiatePlaybackTemporarilyAttribute;	// NSString The displayID of a (future) NowPlayingApp that can temporarily initiate playback after being launched in the background
AV_EXTERN NSString *AVSystemController_AppWantsVolumeChangesAttribute;					// NSNumber (BOOL) YES == this app wants volume changes, NO == this app does not want volume changes (default) 
AV_EXTERN NSString *AVSystemController_NowPlayingAppPIDAttribute;						// NSNumber (int32_t) pid of the current "now playing" app.  pid == 0 means there isn't a "now playing" app. (get only)
AV_EXTERN NSString *AVSystemController_NowPlayingAppDisplayIDAttribute;					// NSString Display ID of the current "now playing" app. A NULL means there isn't a "now playing" app. (get only)
AV_EXTERN NSString *AVSystemController_CallIsActive;									// NSNumber (BOOL) returns whether a call is active (phone/Facetime/TTY). (get only)
AV_EXTERN NSString *AVSystemController_ShouldIgnorePlayCommandsFromAccessoryAttribute;	// NSNumber (BOOL) returns whether a call, Siri, VVM, etc. are active and we need to ignore play commands originating from the accessory. (get only)
AV_EXTERN NSString *AVSystemController_ActiveInputRouteForPlayAndRecordNoBluetoothAttribute;		// NSString ( returns NULL is no active input port ) (get only)
AV_EXTERN NSString *AVSystemController_NowPlayingAppIsPlayingAttribute;					// NSNumber (BOOL) playing state of the current "now playing" app. state == 0 means not playing, 1 means it is playing. (get only)
AV_EXTERN NSString *AVSystemController_NowPlayingAppIsInterruptedAttribute;				// NSNumber (BOOL) returns if the now playing app is currently interrupted. 0 means not interrupted, 1 means it is interrupted. (get only)
AV_EXTERN NSString *AVSystemController_AirPlayScreenSuspended;							// NSNumber (BOOL) YES == Suspends AirPlay Screen, NO == resumes AirPlay Screen (set only).
AV_EXTERN NSString *AVSystemController_DiscoveryModeAttribute;							// NSString (returns/sets the discovery mode; values below)
	AV_EXTERN NSString *AVSystemController_DiscoveryMode_PresenceScan;					// To check if any devices are available
	AV_EXTERN NSString *AVSystemController_DiscoveryMode_DetailedDiscovery;				// To get detailed information and capabilities of the available devices
	AV_EXTERN NSString *AVSystemController_DiscoveryMode_None;							// To switch off discovery
AV_EXTERN NSString *AVSystemController_CurrentExternalScreenAttribute;					// NSString (returns current external screen type; values below)
	AV_EXTERN NSString *AVSystemController_ExternalScreenType_None;						// External screen (mirroring) is NOT active
	AV_EXTERN NSString *AVSystemController_ExternalScreenType_AirPlay;					// AirPlay Mirroring is active
	AV_EXTERN NSString *AVSystemController_ExternalScreenType_TVOut;					// Wired Mirroring is active

AV_EXTERN NSString *AVSystemController_RouteAwayFromAirPlayAttribute;					// NSNumber (BOOL) (YES == unpick all airplay routes; NO == no-op)
AV_EXTERN NSString *AVSystemController_CurrentVideoStreamsAttribute;					// NSArray This is an array of dictionaries with each dictionary containing a key for the bundle ID of currently playing video app and a key for the video route name.
	AV_EXTERN NSString *AVSystemController_CurrentVideoStreams_BundleID;				// BundleID of actively playing video apps.
	AV_EXTERN NSString *AVSystemController_CurrentVideoStreams_VideoRoutes;				// Route names of video route.

AV_EXTERN NSString *AVSystemController_PickableRoutesAttribute;							// NSArray of NSDictionaries (RouteDescriptions): RouteName (NSString), RouteCurrentlyPicked (NSInteger(boolean)).
																						// This list of pickable routes for the current category contains "iPhone" + any wireless routes + any alternate
																						// built-in routes. The currently picked route has RouteCurrentlyPicked set to true.
																						// read-only.
AV_EXTERN NSString *AVSystemController_PickedRouteAttribute;							// NSDictionary (RouteDescription)
																						// read/write.  When setting this property, pass in an entire element of the array you got from PickableRoutes

// keys for RouteDescription NSDictionary (used in AVSystemController_{Pickable,Picked}RoutesAttribute)				
//																																description					type
AV_EXTERN NSString *AVSystemController_PickableRoutesAttribute;
		
AV_EXTERN NSString *AVSystemController_RouteDescriptionKey_RouteName;								// display name of route		NSString (often localized)
AV_EXTERN NSString *AVSystemController_RouteDescriptionKey_RouteSubtype;							// subtype of route				NSString (many routes don't have a subtype; Headphones can be differentiated here)
AV_EXTERN NSString *AVSystemController_RouteDescriptionKey_PortStatusChangeReason;					// reason for port status change	NSNumber( int32_t) The reason code for status change. Reason codes are in VirtualAudio.h.
AV_EXTERN NSString *AVSystemController_RouteDescriptionKey_RouteUID;								// UID of route					NSString (many routes don't have a UID; BT routes do)
AV_EXTERN NSString *AVSystemController_RouteDescriptionKey_AlternateUIDs;							// alternate UIDs of route		NSArray of NSString (some BT devices have multiple UIDs)
AV_EXTERN NSString *AVSystemController_RouteDescriptionKey_RouteCurrentlyPicked;					// currently picked?			NSInteger (BOOL)
AV_EXTERN NSString *AVSystemController_RouteDescriptionKey_RouteType;								// route type					NSString
	// RouteType values
	AV_EXTERN NSString *AVSystemController_PickableRouteType_Override;								// a built-in route (eg. back speaker, receiver) that is only currently available as an override
	AV_EXTERN NSString *AVSystemController_PickableRouteType_Wireless;								// a wireless route (eg. BT headset)
	AV_EXTERN NSString *AVSystemController_PickableRouteType_Default;								// aka. "iPhone", it routes to last plugged in wired route, falling back to built-in default
	// Note that wired routes and the current default built-in route will not show up in the pickable routes array.  These are all represented by the "Default" entry in the array.
AV_EXTERN NSString *AVSystemController_RouteDescriptionKey_AVAudioRouteName;						// route name 					NSString (from AVAudioCategories.h)
AV_EXTERN NSString *AVSystemController_RouteDescriptionKey_PortHasPassword;							// if port requires password			NSNumber(BOOL)
AV_EXTERN NSString *AVSystemController_RouteDescriptionKey_RouteSupportsAirPlayAudio;				// if route supports AirPlay audio 	NSNumber(BOOL)
AV_EXTERN NSString *AVSystemController_RouteDescriptionKey_RouteSupportsAirPlayVideo;				// if route supports AirPlay video 	NSNumber(BOOL)
AV_EXTERN NSString *AVSystemController_RouteDescriptionKey_RouteSupportsAirPlayScreen;				// if route supports AirPlay Screen NSNumber(BOOL)
AV_EXTERN NSString *AVSystemController_RouteDescriptionKey_RouteSupportsAirPlayPhoto;				// if route supports AirPlay Photo 	NSNumber(BOOL)
AV_EXTERN NSString *AVSystemController_RouteDescriptionKey_RouteSupportsAirPlaySlideshow;			// if route supports AirPlay Slideshow 	NSNumber(BOOL)
AV_EXTERN NSString *AVSystemController_RouteDescriptionKey_RouteRequiresAirPlayPIN;					// if route requires AirPlay PIN, called "Onscreen Code" on Apple TV UI 	NSNumber(BOOL)
AV_EXTERN NSString *AVSystemController_RouteDescriptionKey_RouteSupportsAirPlayFromCloud;			// if route supports AirPlay video playback from "the Cloud" 	NSNumber(BOOL)
AV_EXTERN NSString *AVSystemController_RouteDescriptionKey_AirPlayRouteHasCloudConnectivity;		// True if RouteSupportsAirPlayFromCloud is true and AirPlay device reports connectivity to "the Cloud" 	NSNumber(BOOL)
AV_EXTERN NSString *AVSystemController_RouteDescriptionKey_IsBTRoute; 								// If route is a Bluetooth route	NSNumber(BOOL)
	AV_EXTERN NSString *AVSystemController_RouteDescriptionKey_BTDetails_IsHFPRoute; 						// If route is a Bluetooth HFP route	NSNumber(BOOL)
		AV_EXTERN NSString *AVSystemController_RouteDescriptionKey_BTDetails_IsAvailableForVoicePrompts; 		// If Bluetooth HFP route is available for voice prompts NSNumber(BOOL)
#if !RC_HIDE_B288
	AV_EXTERN NSString *AVSystemController_RouteDescriptionKey_BTDetails_SupportsDoAP;				// If the BT route supports DoAP NSNumber(BOOL)
#endif // RC_HIDE_B288
	AV_EXTERN NSString *AVSystemController_RouteDescriptionKey_BTDetails_SupportsLiveListen;		// If the BT route supports LiveListen NSNumber(BOOL)
	AV_EXTERN NSString *AVSystemController_RouteDescriptionKey_BTDetails_EndpointType;
		AV_EXTERN NSString *AVSystemController_RouteDescriptionKey_BTDetails_EndpointType_Unspecified;
		AV_EXTERN NSString *AVSystemController_RouteDescriptionKey_BTDetails_EndpointType_Headphones;
		AV_EXTERN NSString *AVSystemController_RouteDescriptionKey_BTDetails_EndpointType_Vehicle;
		AV_EXTERN NSString *AVSystemController_RouteDescriptionKey_BTDetails_EndpointType_Speakers;
		AV_EXTERN NSString *AVSystemController_RouteDescriptionKey_BTDetails_EndpointType_TTY;

	AV_EXTERN NSString *AVSystemController_RouteDescriptionKey_IsPreferredExternalRoute;				// If route is car or BT headset that supports in ear detection NSNumber(BOOL)
	AV_EXTERN NSString *AVSystemController_RouteDescriptionKey_PreferredExternalRouteDetails_IsActive; // If route is car or state of BT headset is in ear
	AV_EXTERN NSString *AVSystemController_RouteDescriptionKey_PreferredExternalRouteDetails_InEarDetectSupported; // If BT headset supports in-ear detection

AV_EXTERN NSString *AVSystemController_RouteDescriptionKey_OtherDevicesConnected;					// Provides info about the other devices that this route is connected to currently. NSArray( NSDictionary )
AV_EXTERN NSString *AVSystemController_RouteDescriptionKey_OtherDevicesConnected_UniqueID;			// CFStringRef (ID provided by IDS to uniquely identify the device)
AV_EXTERN NSString *AVSystemController_RouteDescriptionKey_OtherDevicesConnected_Name;				// CFStringRef (name of the device connected to this route)
AV_EXTERN NSString *AVSystemController_RouteDescriptionKey_OtherDevicesConnected_ModelIdentifier;	// CFStringRef (model identifier of the device connected to this route)
AV_EXTERN NSString *AVSystemController_RouteDescriptionKey_OtherDevicesConnected_ProductName;		// CFStringRef (product name of the device connected to this route)
AV_EXTERN NSString *AVSystemController_RouteDescriptionKey_OtherDevicesConnected_Playing;			// CFBooleanRef (True - if device is playing something to this route)
AV_EXTERN NSString *AVSystemController_RouteDescriptionKey_OtherDevicesConnected_RouteUID;			// CFStringRef (RouteUID of the route on which the device is playing to)
AV_EXTERN NSString *AVSystemController_RouteDescriptionKey_IsCurrentlyPickedOnPairedDevice;		// CFBooleanRef (True - if this route is a shared audio route and is picked on a paired device)

#define AVSystemController_RouteDescriptionKey_RouteSupportsPhoto AVSystemController_RouteDescriptionKey_RouteSupportsAirPlayPhoto				// backward compatibility for name change
#define AVSystemController_RouteDescriptionKey_RouteSupportsSlideshow AVSystemController_RouteDescriptionKey_RouteSupportsAirPlaySlideshow		// backward compatibility for name change

AV_EXTERN NSString *AVSystemController_RouteDescriptionKey_BTDetails_BatteryLevelLeft;			// CFNumberRef (battery level for left bud - float ranging between [0,1])
AV_EXTERN NSString *AVSystemController_RouteDescriptionKey_BTDetails_BatteryLevelRight;			// CFNumberRef (battery level for right bud - float ranging between
AV_EXTERN NSString *AVSystemController_RouteDescriptionKey_BTDetails_BatteryLevelCase;			// CFNumberRef (battery level for case - float ranging between [0,1])
AV_EXTERN NSString *AVSystemController_RouteDescriptionKey_BTDetails_BatteryLevelSingle;		// CFNumberRef (overall battery level - float ranging between [0,1])
AV_EXTERN NSString *AVSystemController_RouteDescriptionKey_BTDetails_ProductID;					// CFStringRef (vendor and product ID of the bluetooth device)

//		... add more route info here.


// for compatibility only -- clients, please switch to the AVSystemController_ prefixed versions to help us decommission AVController.  rdar://
AV_EXTERN NSString *AVController_ServerConnectionDiedNotification;
AV_EXTERN NSString *AVController_PostNotificationsFromMainThreadOnly;
AV_EXTERN NSString *AVController_ActiveAudioRouteAttribute;
AV_EXTERN NSString *AVController_PickableRoutesDidChangeNotification;
AV_EXTERN NSString *AVController_ActiveAudioRouteAttribute;
AV_EXTERN NSString *AVController_PickableRoutesAttribute;
AV_EXTERN NSString *AVController_PickedRouteAttribute;
AV_EXTERN NSString *AVController_PickableRoutesAttribute;
AV_EXTERN NSString *AVController_RouteDescriptionKey_RouteName;
AV_EXTERN NSString *AVController_RouteDescriptionKey_RouteSubtype;
AV_EXTERN NSString *AVController_RouteDescriptionKey_PortStatusChangeReason;
AV_EXTERN NSString *AVController_RouteDescriptionKey_RouteUID;
AV_EXTERN NSString *AVController_RouteDescriptionKey_AlternateUIDs;
AV_EXTERN NSString *AVController_RouteDescriptionKey_RouteCurrentlyPicked;
AV_EXTERN NSString *AVController_RouteDescriptionKey_RouteType;
AV_EXTERN NSString *AVController_PickableRouteType_Override;
AV_EXTERN NSString *AVController_PickableRouteType_Wireless;
AV_EXTERN NSString *AVController_PickableRouteType_Default;
AV_EXTERN NSString *AVController_RouteDescriptionKey_AVAudioRouteName;
AV_EXTERN NSString *AVController_RouteDescriptionKey_PortHasPassword;
AV_EXTERN NSString *AVController_RouteDescriptionKey_RouteSupportsAirPlayAudio;
AV_EXTERN NSString *AVController_RouteDescriptionKey_RouteSupportsAirPlayVideo;
AV_EXTERN NSString *AVController_RouteDescriptionKey_RouteSupportsAirPlayScreen;
AV_EXTERN NSString *AVController_RouteDescriptionKey_RouteSupportsAirPlayPhoto;
AV_EXTERN NSString *AVController_RouteDescriptionKey_RouteSupportsAirPlaySlideshow;
AV_EXTERN NSString *AVController_RouteDescriptionKey_RouteRequiresAirPlayPIN;
AV_EXTERN NSString *AVController_RouteDescriptionKey_RouteSupportsAirPlayFromCloud;
AV_EXTERN NSString *AVController_RouteDescriptionKey_AirPlayRouteHasCloudConnectivity;

@interface AVSystemController : NSObject
{
	struct AVSystemControllerPrivate *_priv;
}

// Listen for notifications on [AVSystemController sharedAVSystemController].  
// (If that method is never called, the notification wiring won't get made.)
// If AVSystemController_ServerConnectionDiedNotification fires, sharedAVSystemController will need to be rebuilt and you'll need to register again.
+(AVSystemController*)sharedAVSystemController;

// pass NULL for the fallbackCategory to get the default (Ringtone).  
// *** Note: We want to deprecate these 3 calls: ***
- (BOOL)changeActiveCategoryVolumeBy:(float)delta fallbackCategory:(NSString*)fallbackCategory resultVolume:(float*)outNewVolume affectedCategory:(NSString **)outAffectedCategory;
- (BOOL)setActiveCategoryVolumeTo:(float)volume fallbackCategory:(NSString*)fallbackCategory resultVolume:(float*)outNewVolume affectedCategory:(NSString **)outAffectedCategory;
- (BOOL)getActiveCategoryVolume:(float*)outVolume andName:(NSString**)outActiveCategory fallbackCategory:(NSString*)fallbackCategory;

// Simpler versions of the above 3.  Use these instead of the fallbackCategory: calls.  
- (BOOL)changeActiveCategoryVolumeBy:(float)delta;
- (BOOL)setActiveCategoryVolumeTo:(float)volume;
- (BOOL)getActiveCategoryVolume:(float*)outVolume andName:(NSString**)outActiveCategory;

// category-specific versions of the above 3.  Use these for Springboard iPod assist HUD and iAP remotes.
- (BOOL)changeVolumeBy:(float)delta forCategory:(NSString*)category;
- (BOOL)setVolumeTo:(float)volume forCategory:(NSString*)category;
- (BOOL)getVolume:(float*)outVolume forCategory:(NSString*)category;

- (BOOL)toggleActiveCategoryMuted; // like other APIs here, return value reports success communicating with server.
- (BOOL)getActiveCategoryMuted:(BOOL*)outMuted;

// These are for device-specific volume changes.  Pass nil for deviceIdentifier if n/a.  Volume limits still apply.  
- (BOOL)changeActiveCategoryVolumeBy:(float)delta forRoute:(NSString*)route andDeviceIdentifier:(NSString*)deviceIdentifier;
- (BOOL)setActiveCategoryVolumeTo:(float)volume forRoute:(NSString*)route andDeviceIdentifier:(NSString*)deviceIdentifier;
- (BOOL)getActiveCategoryVolume:(float*)outVolume andName:(NSString**)outActiveCategory forRoute:(NSString*)route andDeviceIdentifier:(NSString*)deviceIdentifier;

// DEPRECATED. PLEASE USE THE VERSIONS THAT ARE NOT SPECIFIC TO ACCESSORIES BELOW.
// These are for category-specific volume changes for accessories only.  Pass nil for deviceIdentifier if n/a.  Volume limits still apply.
// The accessory audio routes for which these will work: LineOut, PersistentLineOut, USB, DisplayPort and HDMI.
- (BOOL)changeVolumeForAccessoryBy:(float)delta forCategory:(NSString*)category accessoryRoute:(NSString*)accessoryRoute andAccessoryDeviceIdentifier:(NSString*)accessoryDeviceIdentifier;
- (BOOL)setVolumeForAccessoryTo:(float)volume forCategory:(NSString*)category accessoryRoute:(NSString*)accessoryRoute andAccessoryDeviceIdentifier:(NSString*)accessoryDeviceIdentifier;
- (BOOL)getVolumeForAccessory:(float*)outVolume forCategory:(NSString*)category accessoryRoute:(NSString*)accessoryRoute andAccessoryDeviceIdentifier:(NSString*)accessoryDeviceIdentifier;

// These are for category-specific volume changes for any generic route.  Pass nil for deviceIdentifier if n/a.  Volume limits still apply.
- (BOOL)changeVolumeForRouteBy:(float)delta forCategory:(NSString*)category mode:(NSString*)mode route:(NSString*)route deviceIdentifier:(NSString*)deviceIdentifier andRouteSubtype:(NSString*)routeSubtype;
- (BOOL)setVolumeForRouteTo:(float)volume forCategory:(NSString*)category mode:(NSString*)mode route:(NSString*)route deviceIdentifier:(NSString*)deviceIdentifier andRouteSubtype:(NSString*)routeSubtype;
- (BOOL)getVolumeForRoute:(float*)outVolume forCategory:(NSString*)category mode:(NSString*)mode route:(NSString*)route deviceIdentifier:(NSString*)deviceIdentifier andRouteSubtype:(NSString*)routeSubtype;

- (BOOL)toggleActiveCategoryMutedForRoute:(NSString*)route andDeviceIdentifier:(NSString*)deviceIdentifier; // like other APIs here, return value reports success communicating with server.
- (BOOL)getActiveCategoryMuted:(BOOL*)outMuted forRoute:(NSString*)route andDeviceIdentifier:(NSString*)deviceIdentifier;

- (id)attributeForKey:(NSString *)attributeKey;
- (BOOL)setAttribute:(id)value forKey:(NSString *)attributeKey error:(NSError **)errorPtr;

// The following returns the route for the category.  If the category is in use by the currently active controller, its current route is returned (honoring overrides, etc).
// Otherwise, the route that would be used for the category is returned.  (note: a hardware configuration change may change the answer)
- (NSString *)routeForCategory:(NSString*)category;

// The following returns the volume category for an audio category.  Used by clients listening to volume notifications for a particular audio category.  
- (NSString *)volumeCategoryForAudioCategory:(NSString*)category;

// This behaves just like the AVSystemController_PickableRoutesAttribute, but for a particular category, not the currently active category.
- (NSArray *)pickableRoutesForCategory:(NSString*)category;
// This behaves just like the AVSystemController_PickableRoutesAttribute, but for a particular category and mode, not the currently active category and mode.
- (NSArray *)pickableRoutesForCategory:(NSString*)category andMode:(NSString*)mode;

// if there is no current active client, assumes Audio/Video category
- (BOOL)currentRouteHasVolumeControl;

- (BOOL)allowUserToExceedEUVolumeLimit;

// This call is to change the vibe intensity on platforms that support it.
- (BOOL)setVibeIntensityTo:(float)intensity;
- (BOOL)getVibeIntensity:(float *)intensity;

- (BOOL)didCancelRoutePicking:(NSDictionary *)routeInfo;
- (BOOL)setPickedRouteWithPassword:(NSDictionary *)routeInfo withPassword:(NSString *)password;
- (BOOL)setBTHFPRoute:(NSDictionary *)routeInfo availableForVoicePrompts:(BOOL)isAvailable;

// Returns true if the bundleID is for a whitelisted video app OR if route sharing policy is long form video. Used by clients to determine if an app represents long form video content.
- (BOOL)hasRouteSharingPolicyLongFormVideo:(NSString*)bundleID;

@end

@interface NSArray(PickableRoutes)
	- (NSDictionary *)pickableRouteWithUID:(NSString *)uid;
@end

@interface NSDictionary(PickableRoute)
	- (BOOL)matchesUID:(NSString *)uid;
@end

