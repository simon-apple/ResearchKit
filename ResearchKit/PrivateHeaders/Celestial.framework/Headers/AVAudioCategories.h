/*
        File:  AVAudioCategories.h

        Framework:  Celestial

	Copyright 2006-2013 Apple Inc. All rights reserved.

*/

#ifndef __AVAUDIOCATEGORIES__
#define __AVAUDIOCATEGORIES__

// Audio categories

#define kAVAudioCategory_AudioVideo						CFSTR("Audio/Video")
#define kAVAudioCategory_AmbientSound					CFSTR("AmbientSound")
#define kAVAudioCategory_SoloAmbientSound				CFSTR("SoloAmbientSound")
#define kAVAudioCategory_MediaPlayback					CFSTR("MediaPlayback")
#define kAVAudioCategory_MediaPlaybackNoSpeaker			CFSTR("MediaPlaybackNoSpeaker")
#define kAVAudioCategory_UserInterfaceSoundEffects		CFSTR("UserInterfaceSoundEffects")
#define kAVAudioCategory_Music							kAVAudioCategory_AudioVideo
#define kAVAudioCategory_Video							kAVAudioCategory_AudioVideo
#define kAVAudioCategory_LiveAudio						CFSTR("LiveAudio")
#define kAVAudioCategory_AudioProcessing				CFSTR("AudioProcessing")
#define kAVAudioCategory_Record_NoBluetooth				CFSTR("Record")
#define kAVAudioCategory_Ringtone						CFSTR("Ringtone")
#define kAVAudioCategory_PhoneCall						CFSTR("PhoneCall")
#define kAVAudioCategory_TTYCall						CFSTR("TTYCall")
#define kAVAudioCategory_Voicemail						CFSTR("Voicemail")
#define kAVAudioCategory_VoicemailGreeting				CFSTR("VoicemailGreeting")
#define kAVAudioCategory_RingtonePreview				CFSTR("RingtonePreview")
#define kAVAudioCategory_Alarm							CFSTR("Alarm")
#define kAVAudioCategory_Record							CFSTR("Record")
#define kAVAudioCategory_PlayAndRecord					CFSTR("PlayAndRecord")
#define kAVAudioCategory_Alert							CFSTR("Alert")
#define kAVAudioCategory_FindMyPhone					CFSTR("FindMyPhone")
#define kAVAudioCategory_FindMyAudioDevice				CFSTR("FindMyAudioDevice")
#define kAVAudioCategory_EmergencyAlert					CFSTR("EmergencyAlert")
#define kAVAudioCategory_EmergencyAlert_Muteable		CFSTR("EmergencyAlert_Muteable")

// kCMSessionProperty_AudioMode values
#define kAVAudioMode_Default 				CFSTR("Default");
#define kAVAudioMode_VoiceChat 				CFSTR("VoiceChat");
#define kAVAudioMode_VideoChat 				CFSTR("VideoChat");
#define kAVAudioMode_VideoRecording	 		CFSTR("VideoRecording");
#define kAVAudioMode_SpeechRecognition 		CFSTR("SpeechRecognition");
#define kAVAudioMode_Measurement 			CFSTR("Measurement");
#define kAVAudioMode_Raw 					CFSTR("Raw");
#define kAVAudioMode_GameChat 				CFSTR("GameChat");
#define kAVAudioMode_MoviePlayback 			CFSTR("MoviePlayback");
#define kAVAudioMode_SpokenAudio 			CFSTR("SpokenAudio");
#define kAVAudioMode_VoicePrompt 			CFSTR("VoicePrompt");
#define kAVAudioMode_RemoteVoiceChat		CFSTR("RemoteVoiceChat");
#define kAVAudioMode_VoiceMessages			CFSTR("VoiceMessages");
#define kAVAudioMode_FindMyPhone			CFSTR("FindMyPhone"); // To be used only with the PhoneCall category
#define kAVAudioMode_LivePhoto				CFSTR("LivePhoto");
#define kAVAudioMode_HearingAccessibility	CFSTR("HearingAccessibility");
#define kAVAudioMode_SOSNotification		CFSTR("SOSNotification");
#define kAVAudioMode_SpatialRecording		CFSTR("SpatialRecording");
#define kAVAudioMode_VideoChatForMedia		CFSTR("VideoChatForMedia");
#define kAVAudioMode_MultiCam				CFSTR("MultiCam");

#ifdef __OBJC__
#define AVAudioCategory_AudioVideo			(NSString *)kAVAudioCategory_AudioVideo
#define AVAudioCategory_Music				(NSString *)kAVAudioCategory_AudioVideo
#define AVAudioCategory_Video				(NSString *)kAVAudioCategory_AudioVideo
#define AVAudioCategory_Ringtone			(NSString *)kAVAudioCategory_Ringtone
#define AVAudioCategory_PhoneCall			(NSString *)kAVAudioCategory_PhoneCall
#define AVAudioCategory_TTYCall				(NSString *)kAVAudioCategory_TTYCall
#define AVAudioCategory_Voicemail			(NSString *)kAVAudioCategory_Voicemail
#define AVAudioCategory_VoicemailGreeting	(NSString *)kAVAudioCategory_VoicemailGreeting
#define AVAudioCategory_RingtonePreview		(NSString *)kAVAudioCategory_RingtonePreview
#define AVAudioCategory_Alarm				(NSString *)kAVAudioCategory_Alarm
#define AVAudioCategory_Record				(NSString *)kAVAudioCategory_Record
#define AVAudioCategory_PlayAndRecord		(NSString *)kAVAudioCategory_PlayAndRecord
#define AVAudioCategory_Alert				(NSString *)kAVAudioCategory_Alert
#define AVAudioCategory_FindMyPhone			(NSString *)kAVAudioCategory_FindMyPhone
#define AVAudioCategory_FindMyAudioDevice	(NSString *)kAVAudioCategory_FindMyAudioDevice
#define AVAudioCategory_EmergencyAlert      (NSString *)kAVAudioCategory_EmergencyAlert
#define AVAudioCategory_EmergencyAlert_Muteable      (NSString *)kAVAudioCategory_EmergencyAlert_Muteable

#define AVAudioMode_FindMyPhone				(NSString *)kAVAudioMode_FindMyPhone

#endif // __OBJC__

// categories for use with AudioServicesPlayInterfaceSound

#define kAVAudioCategory_MailReceived				CFSTR("MailReceived")
#define kAVAudioCategory_MailSent					CFSTR("MailSent")
#define kAVAudioCategory_VoicemailReceived			CFSTR("VoicemailReceived")
#define kAVAudioCategory_SMSReceived				CFSTR("SMSReceived")
#define kAVAudioCategory_SMSSent					CFSTR("SMSSent")
#define kAVAudioCategory_SMSReceived_Alert			CFSTR("SMSReceived_Alert")
#define kAVAudioCategory_SMSReceived_Vibrate		CFSTR("SMSReceived_Vibrate")
#define kAVAudioCategory_SMSReceived_Selection		CFSTR("SMSReceived_Selection")
#define kAVAudioCategory_ScreenLocked				CFSTR("ScreenLocked")
#define kAVAudioCategory_FailedUnlock				CFSTR("FailedUnlock")
#define kAVAudioCategory_CalendarAlert				CFSTR("CalendarAlert")
#define kAVAudioCategory_ReminderAlert				CFSTR("ReminderAlert")
#define kAVAudioCategory_USSDAlert					CFSTR("USSDAlert")
#define kAVAudioCategory_SIMToolkitTone				CFSTR("SIMToolkitTone")
#define kAVAudioCategory_TouchTone					CFSTR("TouchTone")
#define kAVAudioCategory_RadioPresetAdded			CFSTR("RadioPresetAdded")
#define kAVAudioCategory_PINKeyPressed				CFSTR("PINKeyPressed")
#define kAVAudioCategory_CameraShutter				CFSTR("CameraShutter")
#define kAVAudioCategory_KeyPressed					CFSTR("KeyPressed")
#define kAVAudioCategory_RingerSwitchIndication		CFSTR("RingerSwitchIndication")
#define kAVAudioCategory_ConnectedToPower			CFSTR("ConnectedToPower")
#define kAVAudioCategory_LowPower					CFSTR("LowPower")
#define kAVAudioCategory_SystemSoundPreview			CFSTR("SystemSoundPreview")
#define kAVAudioCategory_SystemSoundPreview_IgnoreRingerSwitch				CFSTR("SystemSoundPreview_IgnoreRingerSwitch")
#define kAVAudioCategory_SystemSoundPreview_IgnoreRingerSwitch_NoVibe		CFSTR("SystemSoundPreview_IgnoreRingerSwitch_NoVibe")
#define kAVAudioCategory_KeyPressClickPreview		CFSTR("KeyPressClickPreview")
#define kAVAudioCategory_RingerVibeChanged			CFSTR("RingerVibeChanged")
#define kAVAudioCategory_SilentVibeChanged			CFSTR("SilentVibeChanged")
#define kAVAudioCategory_Headset_StartCall			CFSTR("Headset_StartCall")
#define kAVAudioCategory_Headset_Redial				CFSTR("Headset_Redial")
#define kAVAudioCategory_Headset_AnswerCall			CFSTR("Headset_AnswerCall")
#define kAVAudioCategory_Headset_EndCall			CFSTR("Headset_EndCall")
#define kAVAudioCategory_Headset_CallWaitingActions	CFSTR("Headset_CallWaitingActions")
#define kAVAudioCategory_Headset_TransitionEnd		CFSTR("Headset_TransitionEnd")

/* (it doesn't look like NSString * versions of these ones are needed -- let us know if they are.) */

// route overrides

// output only routes

#define kAVAudioRoute_Speaker				CFSTR("Speaker")
#define kAVAudioRoute_Headphone				CFSTR("Headphone")
#define kAVAudioRoute_Headset				CFSTR("Headset")
#define kAVAudioRoute_Receiver				CFSTR("Receiver")
#define kAVAudioRoute_BestSpeaker			CFSTR("BestSpeaker")	// back speaker, unless there is a better "audible to everyone" choice
#define kAVAudioRoute_LineOut				CFSTR("LineOut")
#define kAVAudioRoute_PersistentLineOut		CFSTR("PersistentLineOut")
#define kAVAudioRoute_USB					CFSTR("USB")
#define kAVAudioRoute_DisplayPort			CFSTR("HDMIOutput")
#define kAVAudioRoute_AirTunes				CFSTR("AirTunes")
#define kAVAudioRoute_HDMI					CFSTR("HDMI")
#define kAVAudioRoute_BluetoothLEOutput		CFSTR("BluetoothLEOutput")
#define kAVAudioRoute_SPDIF					CFSTR("S/PDIF")
#define kAVAudioRoute_CarAudioOutput		CFSTR("CarAudioOutput")
#define kAVAudioRoute_SystemCapture			CFSTR("SystemCapture")

#ifdef __OBJC__
#define AVAudioRoute_Speaker				(NSString *)kAVAudioRoute_Speaker
#define AVAudioRoute_Headphone				(NSString *)kAVAudioRoute_Headphone
#define AVAudioRoute_Headset				(NSString *)kAVAudioRoute_Headset
#define AVAudioRoute_Receiver				(NSString *)kAVAudioRoute_Receiver
#define AVAudioRoute_BestSpeaker			(NSString *)kAVAudioRoute_BestSpeaker	// back speaker, unless there is a better "audible to everyone" choice
#define AVAudioRoute_LineOut				(NSString *)kAVAudioRoute_LineOut
#define AVAudioRoute_PersistentLineOut		(NSString *)kAVAudioRoute_PersistentLineOut
#define AVAudioRoute_USB					(NSString *)kAVAudioRoute_USB
#define AVAudioRoute_DisplayPort			(NSString *)kAVAudioRoute_DisplayPort
#define AVAudioRoute_AirTunes				(NSString *)kAVAudioRoute_AirTunes
#define AVAudioRoute_HDMI					(NSString *)kAVAudioRoute_HDMI
#define AVAudioRoute_BluetoothLEOutput		(NSString *)kAVAudioRoute_BluetoothLEOutput
#define AVAudioRoute_SPDIF					(NSString *)kAVAudioRoute_SPDIF
#define AVAudioRoute_CarAudioOutput			(NSString *)kAVAudioRoute_CarAudioOutput
#define AVAudioRoute_SystemCapture			(NSString *)kAVAudioRoute_SystemCapture
#endif // __OBJC__

// input only routes

#define kAVAudioRoute_LineIn				CFSTR("LineIn")
#define kAVAudioRoute_MicrophoneBuiltIn		CFSTR("MicrophoneBuiltIn")
#define kAVAudioRoute_MicrophoneWired		CFSTR("MicrophoneWired")
#define kAVAudioRoute_MicrophoneBluetooth	CFSTR("MicrophoneBluetooth")
#define kAVAudioRoute_USBInput				CFSTR("USBInput")
#define kAVAudioRoute_CarAudioInput			CFSTR("CarAudioInput")

#ifdef __OBJC__
#define AVAudioRoute_LineIn					(NSString *)kAVAudioRoute_LineIn
#define AVAudioRoute_MicrophoneBuiltIn		(NSString *)kAVAudioRoute_MicrophoneBuiltIn
#define AVAudioRoute_MicrophoneWired		(NSString *)kAVAudioRoute_MicrophoneWired
#define AVAudioRoute_MicrophoneBluetooth	(NSString *)kAVAudioRoute_MicrophoneBluetooth
#define AVAudioRoute_USBInput				(NSString *)kAVAudioRoute_USBInput
#define AVAudioRoute_CarAudioInput			(NSString *)kAVAudioRoute_CarAudioInput
#endif // __OBJC__

// input+output routes

#define kAVAudioRoute_TTY						CFSTR("TTY")
#define kAVAudioRoute_HeadsetBT					CFSTR("HeadsetBT")		// Bluetooth low-quality voice only
#define kAVAudioRoute_HeadphonesBT				CFSTR("HeadphonesBT")	// Bluetooth A2DP hi-quality audio capable

// the following 6 strings should be removed for <rdar://problem/15291726>
#define kAVAudioRoute_LineInOut					CFSTR("LineInOut")
#define kAVAudioRoute_HeadsetInOut				CFSTR("HeadsetInOut")
#define kAVAudioRoute_SpeakerAndMicrophone		CFSTR("SpeakerAndMicrophone")
#define kAVAudioRoute_HeadphonesAndMicrophone	CFSTR("HeadphonesAndMicrophone")
#define kAVAudioRoute_BestSpeakerAndMicrophone	CFSTR("BestSpeakerAndMicrophone")
#define kAVAudioRoute_ReceiverAndMicrophone		CFSTR("ReceiverAndMicrophone")

#ifdef __OBJC__
#define AVAudioRoute_TTY						(NSString *)kAVAudioRoute_TTY
#define AVAudioRoute_HeadsetBT					(NSString *)kAVAudioRoute_HeadsetBT		// Bluetooth low-quality voice only
#define AVAudioRoute_HeadphonesBT				(NSString *)kAVAudioRoute_HeadphonesBT	// Bluetooth A2DP hi-quality audio capable
// the following 6 strings should be removed for <rdar://problem/15291726>
#define AVAudioRoute_LineInOut					(NSString *)kAVAudioRoute_LineInOut
#define AVAudioRoute_HeadsetInOut				(NSString *)kAVAudioRoute_HeadsetInOut
#define AVAudioRoute_SpeakerAndMicrophone		(NSString *)kAVAudioRoute_SpeakerAndMicrophone
#define AVAudioRoute_HeadphonesAndMicrophone	(NSString *)kAVAudioRoute_HeadphonesAndMicrophone
#define AVAudioRoute_BestSpeakerAndMicrophone	(NSString *)kAVAudioRoute_BestSpeakerAndMicrophone
#define AVAudioRoute_ReceiverAndMicrophone		(NSString *)kAVAudioRoute_ReceiverAndMicrophone
#endif // __OBJC__

// special route

#define kAVAudioRoute_None						CFSTR("None")
#define kAVAudioRoute_AllRoutes					CFSTR("AllRoutes")
#define kAVAudioRoute_Broadcast					CFSTR("broadcast")

#ifdef __OBJC__
#define AVAudioRoute_None						(NSString *)kAVAudioRoute_None
#define AVAudioRoute_AllRoutes					(NSString *)kAVAudioRoute_AllRoutes
#define AVAudioRoute_Broadcast					(NSString *)kAVAudioRoute_Broadcast
#endif // __OBJC__

// volume change reasons
#define kAVAudioVolumeChangeReason_RouteChange				CFSTR("RouteChange")
#define kAVAudioVolumeChangeReason_CategoryChange			CFSTR("CategoryChange")
#define kAVAudioVolumeChangeReason_VolumeLimitChange		CFSTR("VolumeLimitChange")
#define kAVAudioVolumeChangeReason_ExplicitVolumeChange		CFSTR("ExplicitVolumeChange")
#define kAVAudioVolumeChangeReason_FullMuteChange			CFSTR("FullMuteChange")
#define kAVAudioVolumeChangeReason_EUVolumeLimitReached		CFSTR("EUVolumeLimitReached")
#define kAVAudioVolumeChangeReason_CannotExceedEUVolumeLimit		CFSTR("CannotExceedEUVolumeLimit")

#ifdef __OBJC__
#define AVAudioVolumeChangeReason_RouteChange				(NSString *)kAVAudioVolumeChangeReason_RouteChange
#define AVAudioVolumeChangeReason_CategoryChange			(NSString *)kAVAudioVolumeChangeReason_CategoryChange
#define AVAudioVolumeChangeReason_VolumeLimitChange			(NSString *)kAVAudioVolumeChangeReason_VolumeLimitChange
#define AVAudioVolumeChangeReason_ExplicitVolumeChange		(NSString *)kAVAudioVolumeChangeReason_ExplicitVolumeChange
#define AVAudioVolumeChangeReason_FullMuteChange			(NSString *)kAVAudioVolumeChangeReason_FullMuteChange
#define AVAudioVolumeChangeReason_EUVolumeLimitReached		(NSString *)kAVAudioVolumeChangeReason_EUVolumeLimitReached
#define AVAudioVolumeChangeReason_CannotExceedEUVolumeLimit		(NSString *)kAVAudioVolumeChangeReason_CannotExceedEUVolumeLimit
#endif // __OBJC__


#endif // __AVAUDIOCATEGORIES__
