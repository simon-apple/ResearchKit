/*
 *    Copyright (c) 2006 Apple Computer, Inc.
 *    All rights reserved.
 *
 *    This document is the property of Apple Computer, Inc. It is
 *    considered confidential and proprietary information.
 *
 *    This document may not be reproduced or transmitted in any form,
 *    in whole or in part, without the express written permission of
 *    Apple Computer, Inc.
 *
 *    Description:
 *      Bluetooth device functions.
 *
 */

/**
 * @file BTDevice.h
 * This file contains APIs for Bluetooth device support.
 */
#ifndef BT_DEVICE_H_
#define BT_DEVICE_H_

/** \addtogroup BTDev Device APIs */
/**@{*/

#ifdef __cplusplus
extern "C" {
#endif /* __cplusplus */

#include "BTTypes.h"
#include "BTServiceKeys.h"

/**@}*/

/**
* Constant for no devices.
**/                 
#define BT_DEVICE_NONE							BT_DEVICE_CONSTANT(1)

/**
* Constant for all devices.
**/                 
#define BT_DEVICE_ALL							BT_DEVICE_CONSTANT(2)

/**
* The maximum length of the device name
*/
#define BT_DEVICE_NAME_LENGTH_MAX	248

/**
* Device attributes. Stored as bitwise OR'd flags.
*/
typedef BTOptionFlags BTDeviceAttributes;

/**
* Device sync settings. Stored as bitwise OR'd flags.
*/
typedef BTOptionFlags BTDeviceSyncSettings;

/**
 * @name Device Attributes
 * @{
 * Defines for device attribute flags.
 */

/** None */
#define BT_DEVICE_ATTRIBUTE_NONE				0

/** The device type */
#define BT_DEVICE_ATTRIBUTE_DEVICE_TYPE			BIT0

/** The default name */
#define BT_DEVICE_ATTRIBUTE_DEFAULT_NAME		BIT1

/** The device capabilites */
#define BT_DEVICE_ATTRIBUTE_CAPABILITIES		BIT2

/** The device name */
#define BT_DEVICE_ATTRIBUTE_NAME				BIT3

/** The device roles */
#define BT_DEVICE_ATTRIBUTE_ROLES				BIT4

/**@}*/

/**
 * @name Sync Settings
 * @{
 * Defines for sync settings
 */

/** None */
#define BT_DEVICE_SYNC_SETTINGS_CLEAR			0

/** The device supports contact sync */
#define BT_DEVICE_SYNC_SETTINGS_SUPPORTS_SYNC	BIT0

/** The device has contact sync enabled */
#define BT_DEVICE_SYNC_SETTINGS_SYNC_ENABLED	BIT1

/** The device will sync recent calls */
#define BT_DEVICE_SYNC_SETTINGS_SYNC_RECENTS	BIT2

/** The device will sync favorites */
#define BT_DEVICE_SYNC_SETTINGS_SYNC_FAVORITES	BIT3

/** User has granted permission to sync contacts */
#define BT_DEVICE_SYNC_SETTINGS_PERMISSION_GRANTED	BIT4

/** The device has MAP enabled */
#define BT_DEVICE_SYNC_MAP_ENABLED    BIT5

/**@}*/



// W1 product PID List
#define APPLE_W1_PID_START	0x2002
#define APPLE_W1_PID_END	0x2009
#define APPLE_VENDOR_ID		0x004C
#define APPLE_PID_B188		0x2002
#define APPLE_PID_B312      0x2003
#define APPLE_PID_B282      0x2005
#define APPLE_PID_B352      0x2006
#define APPLE_PID_B443		0x2009
    
#define IS_W1_ACCESSORY(PID) (PID >= APPLE_W1_PID_START && PID <= APPLE_W1_PID_END)

// H1 product PID list
#define APPLE_H1_PID_START  0x200A
#define APPLE_H1_PID_END    0x200F
#define APPLE_PID_B515      0x200A
#define APPLE_PID_B444      0x200B
#define APPLE_PID_B419      0x200C
#define APPLE_PID_B364      0x200D
#define APPLE_PID_B298      0x200E
#define APPLE_PID_B288      0x200F

#define IS_H1_ACCESSORY(PID) (PID >= APPLE_H1_PID_START && PID <= APPLE_H1_PID_END)

/**
 * @name Device Types
 * @{
 */
typedef enum {
	BT_DEVICE_TYPE_GENERIC = 0,			/**< unspecified bluetooth device */
	BT_DEVICE_TYPE_GENERIC_COMPUTER,	/**< some kind of computer */
	BT_DEVICE_TYPE_GENERIC_PHONE,		/**< some kind of phone */
	BT_DEVICE_TYPE_GENERIC_AUDIO_VIDEO,	/**< some kind of A/V device */
	BT_DEVICE_TYPE_GENERIC_PERIPHERAL,	/**< some kind of peripheral */
	BT_DEVICE_TYPE_GENERIC_IMAGING,		/**< some kind of imagine device */
	BT_DEVICE_TYPE_GENERIC_TOY,			/**< some kind of toy or game */
	BT_DEVICE_TYPE_DESKTOP_COMPUTER,	/**< desktop computer */
	BT_DEVICE_TYPE_LAPTOP_COMPUTER,		/**< laptop/notebook computer */
	BT_DEVICE_TYPE_WEARABLE_COMPUTER,	/**< wearable computer */
	BT_DEVICE_TYPE_SERVER,				/**< computer server */
	BT_DEVICE_TYPE_PDA,					/**< handheld/PDA */
	BT_DEVICE_TYPE_MOBILE_PHONE,		/**< mobile phone */
	BT_DEVICE_TYPE_CORDLESS_PHONE,		/**< cordless phone */
	BT_DEVICE_TYPE_MODEM,  				/**< wired modem/ISDN or voice gateway */
	BT_DEVICE_TYPE_ACCESS_POINT, 		/**< LAN/Network Access Point */
	BT_DEVICE_TYPE_HEADSET,				/**< headset */
	BT_DEVICE_TYPE_HANDSFREE,			/**< handsfree (in car) */
	BT_DEVICE_TYPE_MICROPHONE,			/**< microphone */
	BT_DEVICE_TYPE_SPEAKER,				/**< speaker */
	BT_DEVICE_TYPE_HEADPHONES,			/**< headphones */
	BT_DEVICE_TYPE_PORTABLE_AUDIO,		/**< portable audio device, eg mp3 player */
	BT_DEVICE_TYPE_CAR_STEREO,			/**< car stereo */
	BT_DEVICE_TYPE_HIFI_STEREO,			/**< home stereo system */
	BT_DEVICE_TYPE_KEYBOARD,			/**< keyboard */
	BT_DEVICE_TYPE_MOUSE,				/**< mouse */
	BT_DEVICE_TYPE_GAMEPAD,				/**< gamepad or joystick */
	BT_DEVICE_TYPE_REMOTE_CONTROL,		/**< remote control */
	BT_DEVICE_TYPE_SENSOR,				/**< some kind of sensor device */
	BT_DEVICE_TYPE_TABLET,				/**< graphics tablet */
	BT_DEVICE_TYPE_CARD_READER,			/**< card reader */
	BT_DEVICE_TYPE_PRINTER,				/**< printer */
	BT_DEVICE_TYPE_SCANNER,				/**< scanner */
	BT_DEVICE_TYPE_CAMERA,				/**< picture camera */
	BT_DEVICE_TYPE_VIDEO_CAMERA,		/**< video camera */
	BT_DEVICE_TYPE_DISPLAY,				/**< picture display */
	BT_DEVICE_TYPE_VIDEO_DISPLAY,		/**< video display */
	BT_DEVICE_TYPE_VIDEO_CONFERENCING,	/**< video conferencing */
	BT_DEVICE_TYPE_SET_TOP_BOX,			/**< set-top box */
	BT_DEVICE_TYPE_VCR,					/**< VCR (dvd player or pvr?) */
	BT_DEVICE_TYPE_GAMING_CONSOLE,		/**< video game console */
	BT_DEVICE_TYPE_TOY_CONTROLLER,		/**< controller for toy */
	BT_DEVICE_TYPE_WATCH,				/**< watch */
	BT_DEVICE_TYPE_PAGER,				/**< pager */
	BT_DEVICE_TYPE_JACKET,				/**< jacket */
	BT_DEVICE_TYPE_HELMET,				/**< helmet */
	BT_DEVICE_TYPE_GLASSES,				/**< glasses */
	BT_DEVICE_TYPE_A2DP,				/**< a2dp device */
	BT_DEVICE_TYPE_LE_PERIPHERAL,		/**< Bluetooth Low Energy peripheral */
} BTDeviceType;
/**@}*/

typedef BTOptionFlags BTTypesOfDevices;

/**
 * @name Device Types
 * @{
 */
#define DEVICE_TYPE_GENERIC                                0
#define DEVICE_TYPE_GENERIC_COMPUTER                       BIT0
#define DEVICE_TYPE_GENERIC_PHONE                          BIT1
#define DEVICE_TYPE_GENERIC_AUDIO_VIDEO                    BIT2
#define DEVICE_TYPE_GENERIC_PERIPHERAL                     BIT3
#define DEVICE_TYPE_GENERIC_IMAGING                        BIT4
#define DEVICE_TYPE_GENERIC_TOY                            BIT5
#define DEVICE_TYPE_DESKTOP_COMPUTER                       BIT6
#define DEVICE_TYPE_LAPTOP_COMPUTER                        BIT7
#define DEVICE_TYPE_WEARABLE_COMPUTER                      BIT8
#define DEVICE_TYPE_SERVER                                 BIT9
#define DEVICE_TYPE_PDA                                    BIT10
#define DEVICE_TYPE_MOBILE_PHONE                           BIT11
#define DEVICE_TYPE_CORDLESS_PHONE                         BIT12
#define DEVICE_TYPE_MODEM                                  BIT13
#define DEVICE_TYPE_ACCESS_POINT                           BIT14
#define DEVICE_TYPE_HEADSET                                BIT15
#define DEVICE_TYPE_HANDSFREE                              BIT16
#define DEVICE_TYPE_MICROPHONE                             BIT17
#define DEVICE_TYPE_SPEAKER                                BIT18
#define DEVICE_TYPE_HEADPHONES                             BIT19
#define DEVICE_TYPE_PORTABLE_AUDIO                         BIT20
#define DEVICE_TYPE_CAR_STEREO                             BIT21
#define DEVICE_TYPE_HIFI_STEREO                            BIT22
#define DEVICE_TYPE_KEYBOARD                               BIT23
#define DEVICE_TYPE_MOUSE                                  BIT24
#define DEVICE_TYPE_GAMEPAD                                BIT25
#define DEVICE_TYPE_REMOTE_CONTROL                         BIT26
#define DEVICE_TYPE_SENSOR                                 BIT27
#define DEVICE_TYPE_TABLET                                 BIT28
#define DEVICE_TYPE_CARD_READER                            BIT29
#define DEVICE_TYPE_PRINTER                                BIT30
#define DEVICE_TYPE_SCANNER                                BIT31
#define DEVICE_TYPE_CAMERA                                 BIT32
#define DEVICE_TYPE_VIDEO_CAMERA                           BIT33
#define DEVICE_TYPE_DISPLAY                                BIT34
#define DEVICE_TYPE_VIDEO_DISPLAY                          BIT35
#define DEVICE_TYPE_VIDEO_CONFERENCING                     BIT36
#define DEVICE_TYPE_SET_TOP_BOX                            BIT37
#define DEVICE_TYPE_VCR                                    BIT38
#define DEVICE_TYPE_GAMING_CONSOLE                         BIT39
#define DEVICE_TYPE_TOY_CONTROLLER                         BIT40
#define DEVICE_TYPE_WATCH                                  BIT41
#define DEVICE_TYPE_PAGER                                  BIT42
#define DEVICE_TYPE_JACKET                                 BIT43
#define DEVICE_TYPE_HELMET                                 BIT44
#define DEVICE_TYPE_GLASSES                                BIT45
#define DEVICE_TYPE_A2DP                                   BIT46
#define DEVICE_TYPE_LE_PERIPHERAL                          BIT47
#define DEVICE_TYPE_APPLE_TRACKPAD                         BIT48
/**@}*/

/**
 * @name Device Capability Levels
 * @{
 */
typedef enum {
	BT_DEVICE_CAPABILITY_UNKNOWN = 0,
	BT_DEVICE_CAPABILITY_UNSUPPORTED,			/**< role not supported */
	BT_DEVICE_CAPABILITY_UNLIKELY,				/**< role may be supported, though unlikely */
	BT_DEVICE_CAPABILITY_LIKELY,				/**< role is likely supported */
	BT_DEVICE_CAPABILITY_SUPPORTED,				/**< role is supported */
} BTDeviceCapability;
/**@}*/

/**
 * @name Device Virtual Type
 * @{
 */
typedef enum {
	BT_DEVICE_VIRTUAL_TYPE_NONE = 0,
	BT_DEVICE_VIRTUAL_TYPE_N2BT_SENSOR,
	BT_DEVICE_VIRTUAL_TYPE_N2BT_REMOTE,
	BT_DEVICE_VIRTUAL_TYPE_N2BT_HRM
} BTDeviceVirtualType;
/**@}*/

/**
 * @name Device Link Mode
 * @{
 */
typedef enum {
	BT_LINK_MODE_ACTIVE = 0,
	BT_LINK_MODE_HOLD,
	BT_LINK_MODE_SNIFF,
} BTDeviceLinkMode;
/**@}*/

/**
 * @name Device Low Security Status
 * @{
 */
typedef enum {
    LowSecurityStatusUnavailable,
    LowSecurityConnectionAllowed,
    LowSecurityConnectionDisallowed
} BTLowSecurityStatus;
/**@}*/

/**
 * @name HID Device Behavior
 * @{
 */
typedef enum {
    HIDDeviceKnownGoodBehavior,
    HIDDeviceKnownPoorBehavior,
    HIDDeviceUnknownBehavior
} BTHIDDeviceBehavior;
/**@}*/

/**
 * @brief Converts a device address to a UTF8 string of the form XX:XX:XX:XX:XX:XX.
 * 
 * @param address the device address
 * @param buffer pointer to buffer where address string will be stored
 * @param bufferSize size of buffer
 * @return <code>BT_SUCCESS</code> on success, or <code>BT_ERROR_*</code> otherwise
 */
BTResult BTDeviceAddressToString(const BTDeviceAddress* address, char* buffer, size_t bufferSize);

/**
 * @brief Converts a string of the form XX:XX:XX:XX:XX:XX to a device address.
 * 
 * @param str the address string
 * @param address pointer to store the device address
 * @return <code>BT_SUCCESS</code> on success, or <code>BT_ERROR_*</code> otherwise
 */
BTResult BTDeviceAddressFromString(const char* str, BTDeviceAddress* address);

/**
 * @brief Returns a device handle for the a device associated with the given address.
 *  
 * @param session the session handle
 * @param address the device address
 * @param device pointer to store the device handle
 * @return <code>BT_SUCCESS</code> on success, <code>BT_ERROR_*</code> otherwise.
 */
BTResult BTDeviceFromAddress(BTSession session, const BTDeviceAddress* address, BTDevice* device);

/**
 * @brief Returns a device handle for the a device associated with the given identifier.
 *
 * @param session the session handle
 * @param identifier the device identifier
 * @param device pointer to store the device handle
 * @return <code>BT_SUCCESS</code> on success, <code>BT_ERROR_*</code> otherwise.
 */
BTResult BTDeviceFromIdentifier(BTSession session, const uuid_t* identifier, BTDevice* device);

/**
 * @brief Gets the address of a device as a formatted string of the form XX:XX:XX:XX:XX:XX.
 *
 * @param device the remote device
 * @param buffer pointer to buffer where address will be stored
 * @param bufferSize size of buffer
 * @return <code>BT_SUCCESS</code> on success, <code>BT_ERROR_*</code> otherwise.
 */
BTResult BTDeviceGetAddressString(BTDevice device, char* buffer, size_t bufferSize);

/**
 * @brief Gets the device type. This is the cached attribute value from the last discovery scan.
 *
 * @param device the remote device
 * @param deviceType the device type
 * @return <code>BT_SUCCESS</code> on success, <code>BT_ERROR_*</code> otherwise.
 */
BTResult BTDeviceGetDeviceType(BTDevice device, BTDeviceType* deviceType);

/*
 * @brief Gets the device class. This is the standardized value advertised in the last discovery scan.
 *
 * @param device the remote device
 * @param deviceClass the device class
 * @return <code>BT_SUCCESS</code> on success, <code>BT_ERROR_*</code> otherwise.
 */
BTResult BTDeviceGetDeviceClass(BTDevice device, uint32_t* deviceClass);

/**
 * @brief Gets the default device name. This is the cached attribute value from the last
 * discovery scan.
 *
 * This name is derived from the device type and manufacturer information, and is intended to be used
 * only when the actual device name is not available. @see BTDeviceGetName
 *
 * The name is returned as a UTF8-formatted string, up to 248 bytes in length.
 *
 * @param device the remote device
 * @param buffer pointer to buffer where name will be stored
 * @param bufferSize size of buffer
 * @return <code>BT_SUCCESS</code> on success, <code>BT_ERROR_*</code> otherwise.
 */
BTResult BTDeviceGetDefaultName(BTDevice device, char* buffer, size_t bufferSize);

/**
 * @brief Gets the device name. This is the cached attribute value from the last discovery scan.
 *
 * The name is returned as a UTF8-formatted string, up to 248 bytes in length.
 *
 * @param device the remote device
 * @param buffer pointer to buffer where name will be stored
 * @param bufferSize size of buffer
 * @return <code>BT_SUCCESS</code> on success, <code>BT_ERROR_*</code> otherwise.
 */
BTResult BTDeviceGetName(BTDevice device, char* buffer, size_t bufferSize);

/**
 * @brief Sets the user-defined device name. This is the cached display name set by the user.
 *
 * The name is returned as a UTF8-formatted string, up to 248 bytes in length.
 *
 * @param device the remote device
 * @param name pointer to buffer where name is stored
 * @return <code>BT_SUCCESS</code> on success, <code>BT_ERROR_*</code> otherwise.
 */
BTResult BTDeviceSetUserName(BTDevice device, const char* name);

/**
 * @brief Gets the contact sync settings. 
 *
 * @param device the remote device
 * @param settings the device sync settings
 * @return <code>BT_SUCCESS</code> on success, <code>BT_ERROR_*</code> otherwise.
 */
BTResult BTDeviceGetSyncSettings(BTDevice device, BTDeviceSyncSettings *settings);

/**
 * @brief Gets the contact sync settings.
 *
 * @param device the remote device
 * @param settings the device sync settings
 * @return <code>BT_SUCCESS</code> on success, <code>BT_ERROR_*</code> otherwise.
 */
BTResult BTDeviceSetSyncSettings(BTDevice device, BTDeviceSyncSettings settings);

/**
 * @brief Gets the currently enabled groups
 *
 * @param device the remote device
 * @param groupArray pointer to array where the enabled groups are stored
 * @param groupArraySize pointer to where groupArray size is to be stored
 * @param groupArrayMaxSize capacity of the groupArray
 * @return <code>BT_SUCCESS</code> on success, <code>BT_ERROR_*</code> otherwise.
 */
BTResult BTDeviceGetGroups(BTDevice device, BTGroupId *groupArray, size_t *groupArraySize, size_t groupArrayMaxSize);

/**
 * @brief Gets the currently enabled groups
 *
 * @param device the remote device
 * @param groupId group to be set
 * @param enable boolean value to enable/disable syncing groupId
 * @return <code>BT_SUCCESS</code> on success, <code>BT_ERROR_*</code> otherwise.
 */
BTResult BTDeviceSetGroup(BTDevice device, BTGroupId groupId, BTBool enable);

/**
 * @brief Returns true if the given device has been previously paired.
 *
 * @param device the remote device
 * @param paired <code>BT_TRUE</code> if previously paired, or <code>BT_FALSE</code> otherwise
 * @return <code>BT_SUCCESS</code> on success, or <code>BT_ERROR_*</code> otherwise
 */
BTResult BTDeviceGetPairingStatus(BTDevice device, BTBool* paired);
    
/**
 * @brief Returns true if the given device was paired via iCloud
 *
 * @param device the remote device
 * @param paired <code>BT_TRUE</code> if paired via iCloud, and <code>BT_FALSE</code> otherwise
 * @return <code>BT_SUCCESS</code> on success, and <code>BT_ERROR_*</code> otherwise
 */
BTResult BTDeviceGetCloudPairingStatus(BTDevice device, BTBool* paired);

/**
 * @brief Returns true if the given device was Magic paired
 *
 * @param device the remote device
 * @param paired <code>BT_TRUE</code> if magic paired, and <code>BT_FALSE</code> otherwise
 * @return <code>BT_SUCCESS</code> on success, and <code>BT_ERROR_*</code> otherwise
 */
BTResult BTDeviceGetMagicPairingStatus(BTDevice device, BTBool* paired);

/**
 * @brief Returns true if the given device is currently connected.
 *
 * Deprecated. Please use BTDeviceGetConnectedServices.
 *
 * @param device the remote device
 * @param connected <code>BT_TRUE</code> if connected, or <code>BT_FALSE</code> otherwise
 * @return <code>BT_SUCCESS</code> on success, or <code>BT_ERROR_*</code> otherwise
 */
BTResult BTDeviceGetConnectionStatus(BTDevice device, BTBool* connected) BT_DEPRECATED;

/**
 * @brief Returns true if the given device is an Apple audio device (Wx)
 *
 * @param device the remote device
 * @param appleAudioDevice <code>BT_TRUE</code> if Wx, and <code>BT_FALSE</code> otherwise
 * @return <code>BT_SUCCESS</code> on success, and <code>BT_ERROR_*</code> otherwise
 */
BTResult BTDeviceIsAppleAudioDevice(BTDevice device, BTBool* appleAudioDevice);

/**
 * @brief Returns true if the given device supports Hey Siri over DoAP uplink
 *
 * @param device the remote device
 * @param supportsHS <code>BT_TRUE</code> if Hey Siri supported, and <code>BT_FALSE</code> otherwise
 * @return <code>BT_SUCCESS</code> on success, and <code>BT_ERROR_*</code> otherwise
 */
BTResult BTDeviceSupportsHS(BTDevice device, BTBool* supportsHS);

/**
 * @brief Returns true if the given device is a Pro Controller
 *
 * @param device the remote device
 * @param isProController <code>BT_TRUE</code> if device is a Pro Controller and <code>BT_FALSE</code> otherwise
 * @return <code>BT_SUCCESS</code> on success, and <code>BT_ERROR_*</code> otherwise
 */
BTResult BTDeviceIsProController(BTDevice device, BTBool* isProController);

/**
* Service specific Event
*/
typedef uint32_t BTServiceSpecificEvent;

#define BT_SERVICE_SDP						00		/**< Doing SDP to figure out if there is any supported service */
#define BT_SERVICE_CONNECTION_ATTEMPT		01
#define BT_SERVICE_DISCONNECTION_ATTEMPT	02
#define BT_SERVICE_CONNECTION_RESULT		11
#define BT_SERVICE_DISCONNECTION_RESULT		12

#define BT_SERVICE_HANDSFREE_AUDIO_CONNECTED			101				/**< audio stream connected */
#define BT_SERVICE_HANDSFREE_AUDIO_DISCONNECTED			102				/**< audio stream disconnected */
#define BT_SERVICE_HANDSFREE_START_VOICE_COMMAND		103				/**< remote side requested a voice command session */
#define BT_SERVICE_HANDSFREE_END_VOICE_COMMAND			104				/**< remote side ended voice command session */
#define BT_SERVICE_HANDSFREE_ENHANCED_SAFETY_ENABLED	105				/**< remote side enabled enhanced safety */
#define BT_SERVICE_HANDSFREE_ENHANCED_SAFETY_DISABLED	106				/**< remote side disabled enhanced safety */

#define BT_SERVICE_A2DP_AUDIO_CONNECTED				201				/**< A2DP audio stream connected */
#define BT_SERVICE_A2DP_AUDIO_DISCONNECTED			202				/**< A2DP audio stream disconnected */

#define BT_SERVICE_PHONE_BOOK_SEND_INITIATED		301				/**< phone book send initiated */
#define BT_SERVICE_PHONE_BOOK_SEND_COMPLETE			302				/**< phone book send complete */
#define BT_SERVICE_PHONE_BOOK_SYNC_SUPPORTED		303				/**< phone book sync supported */

#define BT_GENERIC_SOFTWARE_ERROR                   401
#define BT_GENERIC_HARDWARE_ERROR                   402
#define BT_PAIRING_COMPLETE                         403
#define BT_UNPAIRING_STARTED                        404
#define BT_FIRMWARE_ERROR                           405
#define BT_RESTART_ERROR                            406
#define BT_UNOPTIMAL_HID_BEHAVIOR_DETECTED          407

#define BT_SERVICE_REMOTE_PLAY						501				/**< AVRCP Play */
#define BT_SERVICE_REMOTE_PAUSE						502				/**< AVRCP Pause */
#define BT_SERVICE_REMOTE_STOP						503				/**< AVRCP Stop */
#define BT_SERVICE_REMOTE_PREVIOUS					504				/**< AVRCP Previous track */
#define BT_SERVICE_REMOTE_NEXT						505				/**< AVRCP Next Track */
#define BT_SERVICE_REMOTE_VOL_UP					506				/**< AVRCP Volume UP */
#define BT_SERVICE_REMOTE_VOL_DOWN					507				/**< AVRCP Volume DOWN */
#define BT_SERVICE_REMOTE_MUTE						508				/**< AVRCP Volume Mute */
#define BT_SERVICE_REMOTE_FASTFORWARD_START			509				/**< AVRCP Fast forward */
#define BT_SERVICE_REMOTE_FASTFORWARD_STOP			510				/**< AVRCP Fast forward */
#define BT_SERVICE_REMOTE_REWIND_START				511				/**< AVRCP Rewind */
#define BT_SERVICE_REMOTE_REWIND_STOP				512				/**< AVRCP Rewind */

#define BT_SERVICE_SENSOR_RSSI						601				/**< RSSI value */

#define BT_SERVICE_LMP_NAME_CHANGED					701				/**< Name Request finished */
#define BT_SERVICE_HIGH_POWER_ENABLED				702				/**< High Power Enabled */
#define	BT_SERVICE_HIGH_POWER_DISABLED				703				/**< High Power Disabled */

typedef enum {
	BT_SERVICE_CONNECT,						/**< service connection event */
	BT_SERVICE_DISCONNECT,					/**< service disconnection event */
	BT_SERVICE_DEPENDENT_EVENT				/**< service event */
} BTServiceEventType;


/**
 * @brief Callback invoked when a service event occured.
 *
 * @param device The device that is concerned by the event.
 * @param services Mask of service ids that are originating the event.
 * @param eventType The kind of event which occured
 * @param event The event.
 * @param result The error code if an error occured.
 * @param userData User data pointer.
 */
typedef void (*BTServiceEventCallback)(BTDevice device, BTServiceMask services, BTServiceEventType eventType, BTServiceSpecificEvent event, BTResult result, void* userData);

/**
 * @brief Adds callbacks to get events on the current Runloop.
 *
 * @param session The session used to communicate with bluetoothd
 * @param callback The function to be called to dispatch a notification
 * @param userData The user context which will be available in the callback
 * @return <code>BT_SUCCESS</code> on success, or <code>BT_ERROR_*</code> otherwise.
 */
BTResult BTServiceAddCallbacks(BTSession session, BTServiceEventCallback callback, void *userData);

/**
 * @brief Adds callbacks to get events on the current Runloop.
 *
 * @param session The session used to communicate with bluetoothd
 * @param callback The function to be called to dispatch a notification
 * @param userData The user context which will be available in the callback
 * @param filter The services you are interested in getting callbacks from
 * @return <code>BT_SUCCESS</code> on success, or <code>BT_ERROR_*</code> otherwise.
 */
BTResult BTServiceAddCallbacksWithFilter(BTSession session, BTServiceEventCallback callback, BTServiceMask filter, void *userData);

/**
 * @brief Removes callbacks.
 *
 * @param session The session used to communicate with bluetoothd
 * @param callback The functions to remove
 * @return <code>BT_SUCCESS</code> on success, or <code>BT_ERROR_*</code> otherwise.
 */
BTResult BTServiceRemoveCallbacks(BTSession session, BTServiceEventCallback callback);

/**
 * @brief Sets all services states.
 *
 * @discussion This sets the state of all services. Setting the service mask to BT_SERVICE_NONE
 * will disable all services, BT_SERVICE_ALL will enable all services. BT_SERVICE_ALL | ~BT_SERVICE_HANDSFREE
 * will enable everything besides handsfree.
 *
 * @param device the remote device
 * @param services The services to be set.
 * @return <code>BT_SUCCESS</code> on success, or <code>BT_ERROR_*</code> otherwise.
 */
BTResult BTDeviceSetAuthorizedServices(BTDevice device, BTServiceMask services);

/**
 * @brief Gets all services states.
 *
 * @discussion This gets the state of all services. To check if handsfree is enabled use the following
 * if ((BT_SERVICE_HANDSFREE & mask) == BT_SERVICE_HANDSFREE)
 *
 * @param device the remote device
 * @param services The enabled services. This is a pointer that will receive the data.
 * @return <code>BT_SUCCESS</code> on success, or <code>BT_ERROR_*</code> otherwise.
 */
BTResult BTDeviceGetAuthorizedServices(BTDevice device, BTServiceMask *services);

/**
 * @brief Connects a device to enabled services.
 *
 * @discussion This connects the device to the all services if those are enabled.
 *
 * @param device the remote device
 * @return <code>BT_SUCCESS</code> on success, or <code>BT_ERROR_*</code> otherwise.
 */
BTResult BTDeviceConnect(BTDevice device);

/**
 * @brief Connects a device to enabled services.
 *
 * @discussion This connects the device to the specified services if those are enabled.
 *
 * @param device the remote device
 * @return <code>BT_SUCCESS</code> on success, or <code>BT_ERROR_*</code> otherwise.
 */
BTResult BTDeviceConnectServices(BTDevice device, BTServiceMask services);

/**
 * @brief Connects a device to enabled services in guest mode.
 *
 * @discussion This connects the device to the specified services with specified parameters below
 *
 * @param device The remote device
 * @param services Services to connect
 * @param mode The mode to be used to connect to remote device: BTDeviceConnectNormalMode - Not implemented
                                                                 BTDeviceConnectGuestMode -  Temporary sharing device
                                                                 BTDeviceConnectGuestModeWithLinkey - Temporary sharing device with specified linkkey
 * @param key This specifies linkkey to be used with BTDeviceConnectGuestModeWithLinkey
 * @return <code>BT_SUCCESS</code> on success, or <code>BT_ERROR_*</code> otherwise.
*/
BTResult BTDeviceConnectServicesWithParameters(BTDevice device, BTServiceMask services, BTDeviceConnectMode mode, BTSecurityKey* key);

/**
 * @brief Disconnects a device from connected services.
 *
 * @discussion This disconnects the device from all the services.
 *
 * @param device the remote device
 * @return <code>BT_SUCCESS</code> on success, or <code>BT_ERROR_*</code> otherwise.
 */
BTResult BTDeviceDisconnect(BTDevice device);

/**
 * @brief Disconnects a device from connected services.
 *
 * @discussion This disconnects the device from the specified services if those are connected.
 *
 * @param device the remote device
 * @return <code>BT_SUCCESS</code> on success, or <code>BT_ERROR_*</code> otherwise.
 */
BTResult BTDeviceDisconnectServices(BTDevice device, BTServiceMask services);

/**
 * @brief Gets the services the device is connected to.
 *
 * @param device The remote device
 * @param services A pointer to store the bit mask of connected services.
 * @return <code>BT_SUCCESS</code> on success, or <code>BT_ERROR_*</code> otherwise.
 */
BTResult BTDeviceGetConnectedServices(BTDevice device, BTServiceMask *services);

/**
 * @brief Gets the advertised device services. This is the cached attribute value from the
 * last sdp query.
 *
 * @param device the remote device
 * @param services A pointer to store the bit mask of supported services.
 * @return <code>BT_SUCCESS</code> on success, <code>BT_ERROR_*</code> otherwise.
 */
BTResult BTDeviceGetSupportedServices(BTDevice device, BTServiceMask* services);


/**
 * @brief This allows the personalization of the profiles using predefined keys.
 *
 * @discussion The key and value must be null terminated strings with a max length of 256.
 *
 * @param device the remote device
 * @param services The services that will receive the settings
 * @param key The setting's key
 * @param value The value to apply
 * @return <code>BT_SUCCESS</code> on success, or <code>BT_ERROR_*</code> otherwise.
 */
BTResult BTDeviceSetServiceSettings(BTDevice device, BTServiceMask services, const char *key, const char *value);

/**
 * @brief This retrieves the personalization of the profiles using predefined keys.
 *
 * @param device the remote device
 * @param services The services that will retreive the settings
 * @param key The setting's key
 * @param value The value to store
 * @return <code>BT_SUCCESS</code> on success, or <code>BT_ERROR_*</code> otherwise.
 */
BTResult BTDeviceGetServiceSettings(BTDevice device, BTServiceID services, const char *key, char *value);


/**
 * @brief Sets all services states.
 *
 * @discussion This sets the state of all services. Setting the service mask to BT_SERVICE_NONE
 * will disable all services, BT_SERVICE_ALL will enable all services. BT_SERVICE_ALL | ~BT_SERVICE_HANDSFREE
 * will enable everything besides handsfree.
 *
 * @param device the remote device
 * @param type The virtual device type to set
 * @return <code>BT_SUCCESS</code> on success, or <code>BT_ERROR_*</code> otherwise.
 */
BTResult BTDeviceSetVirtualType(BTDevice device, BTDeviceVirtualType type);

/**
 * @brief Sets all services states.
 *
 * @discussion This sets the state of all services. Setting the service mask to BT_SERVICE_NONE
 * will disable all services, BT_SERVICE_ALL will enable all services. BT_SERVICE_ALL | ~BT_SERVICE_HANDSFREE
 * will enable everything besides handsfree.
 *
 * @param device the remote device
 * @param type The virtual device type to get
 * @return <code>BT_SUCCESS</code> on success, or <code>BT_ERROR_*</code> otherwise.
 */
BTResult BTDeviceGetVirtualType(BTDevice device, BTDeviceVirtualType* type);

/**
 * @brief See BTDeviceGetComPortForServiceWithSandboxExtension
 */
BTResult BTDeviceGetComPortForService(BTDevice device, BTServiceID service, char *buffer, size_t size) BT_DEPRECATED;

	
/**
 * @brief Gets the com port associated with the service, enabling direct communication with the BT device
 *
 * @discussion Once a device is connected and sends data that needs to be interpreted by another program
 * than bluetoothd, such as GPS, modem (DUN), .... bluetoothd will open a com port, and send and read data through it.
 *
 * @param device The connected device
 * @param service The service id from which to get the com port from
 * @param buffer A preallocated buffer large enough to store the full path to the port. If successfull the buffer will be filled. (eg: /dev/ttyp6)
 * @param size The size eof the buffer you are passing in.
 * @param extensionToken A token to use with sandbox_extension_consume(). Clients are responsible for freeing it using sandbox_extension_release()
 * @return <code>BT_SUCCESS</code> on success, or <code>BT_ERROR_*</code> otherwise.
 */
BTResult BTDeviceGetComPortForServiceWithSandboxExtension(BTDevice device, BTServiceID service, char *buffer, size_t size, char *extensionToken);

/**
 * @brief Checks if a device matches a key advertized by BTLocalDeviceAdvertiseData
 *
 * @discussion This function will check against the EIR Manufacturer data of the device for the hash
 *				of key provided by the other device
 *
 * @param device the remote device
 * @param key the key to match
 * @param keySize the size of the key
 * @param match <code>BT_FALSE </code> if the device has no matching service in the EIR, <code>BT_TRUE</code> if it matches
 * @return <code>BT_SUCCESS</code> on success, or <code>BT_ERROR_*</code> otherwise.
 */
BTResult BTDeviceMatchesAdvertisedKey(BTDevice device, const BTData key, const size_t keySize, BTBool *match);


/**
 * @brief Gets the data stored in SDP by BTLocalDeviceAdvertiseData for the specified key 
 *
 * @discussion This function will copy the SDP data advertized by the remote device to data.
 *
 * @param device the remote device
 * @param key the key to match
 * @param keySize the size of the key
 * @param value a pointer to a chunk of memory large enough to store the SDP data (1k is recommanded)
 * @param valueLen a pointer to store the data size returned.
 * @param maxValueSize the size of your value buffer
 * @return <code>BT_SUCCESS</code> on success, or <code>BT_ERROR_*</code> otherwise.
 */
BTResult BTDeviceGetAdvertisedValueForKey(BTDevice device, const BTData key, const size_t keySize, BTData value, size_t *valueLen, uint32_t maxValueSize);


/**
 * @brief Gets the data stored in SDP under the Device ID profile
 *
 * @param deviceHandle the remote device
 * @param vendorIdSource the source of the vid. 0x1 for SIG, 0x2 for USB.
 * @param vendorId the vendor Identification number
 * @param productId the products Identification number (defined by the vendor)
 * @param versionId the software revision of the product (defined by the vendor)
 * @return <code>BT_SUCCESS</code> on success, or <code>BT_ERROR_*</code> otherwise.
 */
BTResult BTDeviceGetDeviceId(BTDevice deviceHandle, uint32_t *vendorIdSource, uint32_t *vendorId, uint32_t *productId, uint32_t *versionId);

/**
 * @brief Set authentication status and type of accessory
 *
 * @discussion This API is called by IAP to tell us the type of accessory and its authentication status
 *
 * @param deviceHandle the remote device
 * @param authStatus the authentication status of the remote device
 * @param hidType the type of accessory
 * @return <code>BT_SUCCESS</code> on success, or <code>BT_ERROR_*</code> otherwise.
 */
BTResult BTDeviceSetHIDProperties(BTDevice deviceHandle, BTBool authStatus, uint8_t hidType);
    
/**
 * @brief Set authentication status and type of accessory
 *
 * @discussion This API is called by to disconnect a physical link
 *
 * @param device the remote device
 * @return <code>BT_SUCCESS</code> on success, or <code>BT_ERROR_*</code> otherwise.
 */

BTResult BTDevicePhysicalLinkDisconnect(BTDevice device);

/**
 * @brief Pass linkkey to connected headset for temporary sharing
 *
 * @discussion This API passes specified linkkey to connected headset
 *
 * @param device the remote device
 * @param address BT Address to pass onto ACC with linkkey
 * @param key This specifies linkkey to be used with BTBool linkKeyProvided.
 * @param linkKeyProvided True if linkkey is provided otherwise False.
 * @return <code>BT_SUCCESS</code> on success, or <code>BT_ERROR_*</code> otherwise.
*/
    
BTResult BTDeviceConfigureLinkKey(BTDevice device, const BTDeviceAddress* address, BTSecurityKey* key, BTBool linkKeyProvided);
    
/**
* @brief Gives information if device is temporary paired
*
* @discussion This API allows you to check if headset is temporary paired
*
* @param device the remote device
* @param isTemporaryDevice True if device is temporary paired otherwise False.
* @return <code>BT_SUCCESS</code> on success, or <code>BT_ERROR_*</code> otherwise.
*/
    
BTResult BTDeviceIsTemporaryPaired(BTDevice device, BTBool* isTemporaryDevice);

/**
* @brief Returns true if the given device supports Wireless Splitter
*
* @param device the remote device
* @param isWSSupported <code>BT_TRUE</code> if  Wireless Splitter is supported, and <code>BT_FALSE</code> otherwise
* @return <code>BT_SUCCESS</code> on success, and <code>BT_ERROR_*</code> otherwise
*/
BTResult BTDeviceIsWirelessSplitterSupported(BTDevice device, BTBool* isWSSupported);

/**
 * @brief Gives information if device is temporary paired as guest not in contacts
 *
 * @discussion This API allows you to check if headset is temporary paired as guest not in contacts
 *
 * @param device the remote device
 * @param isTemporaryDeviceNotInContacts True if device is temporary paired as guest not in contacts otherwise False.
 * @return <code>BT_SUCCESS</code> on success, or <code>BT_ERROR_*</code> otherwise.
 */
BTResult BTDeviceIsTemporaryPairedNotInContacts(BTDevice device, BTBool* isTemporaryDeviceNotInContacts);

/**
 * @brief Returns true if the given device is using low security
 *
 * @param device the remote device
 * @param lowSecurityStatus the low security status of the remote device
 * @return <code>BT_SUCCESS</code> on success, or <code>BT_ERROR_*</code> otherwise.
 */

BTResult BTDeviceGetLowSecurityStatus(BTDevice device, BTLowSecurityStatus *lowSecurityStatus);

/**
 * @brief Get link quality data.
 *
 * @param deviceHandle the BTDevice handle
 * @param data link quality data pointer
 * @return <code>BT_SUCCESS</code> on success, or <code>BT_ERROR_*</code> otherwise
 */
BTResult BTLinkQualityGetData(BTLinkQualityData *data);

/**
 * @brief Retrieve HID Device behavior based on internal tests
 *
 * @param device the remote device
 * @param hidDeviceBehavior the behavior of the remote device
 * @return <code>BT_SUCCESS</code> on success, or <code>BT_ERROR_*</code> otherwise.
 */

BTResult BTDeviceGetHIDDeviceBehavior(BTDevice device, BTHIDDeviceBehavior *hidDeviceBehavior);


#ifdef __cplusplus
} /* extern "C" */
#endif /* __cplusplus */

/**@}*/

#endif /* BT_DEVICE_H_ */

