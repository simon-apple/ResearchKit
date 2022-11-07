/*
 *      Copyright (c) 2006 Apple Computer, Inc.
 *      All rights reserved.
 *
 *      This document is the property of Apple Computer, Inc. It is
 *      considered confidential and proprietary information.
 *
 *      This document may not be reproduced or transmitted in any form,
 *      in whole or in part, without the express written permission of
 *      Apple Computer, Inc.
 *
 *      Description:
 *        Device management API for bluetooth accessories.
 */

/**
 * @file BTAccessory.h
 * This file contains APIs for Bluetooth accessory management.
 */
#ifndef BT_ACCESSORY_MANAGER_H
#define BT_ACCESSORY_MANAGER_H

/** \addtogroup BTAM Accessory Manager APIs*/
/**@{*/

#ifdef __cplusplus
extern "C" {
#endif /* __cplusplus */

#include "BTTypes.h"
#include "BTFeatures.h"
#include "BTSession.h"
#include "BTDevice.h"

/**
 * @name Accessory States
 * @{
 */
typedef enum {
    BT_ACCESSORY_STATE_UNKNOWN = 0,        /**< unknown */
    BT_ACCESSORY_STATE_PLUGGED_IN,        /**< device is plugged in */
    BT_ACCESSORY_STATE_UNPLUGGED        /**< device is unplugged */
} BTAccessoryState;
/**@}*/

/**
 * @name Accessory Events
 * @{
 */
typedef enum {
    BT_ACCESSORY_STATE_CHANGED,        /**< the accessory state has changed */
    BT_ACCESSORY_BATTERY_LEVEL_CHANGED,    /**< the accessory battery level has changed */
    BT_ACCESSORY_DEVICE_FOUND,        /**< a new accessory device is available */
    BT_ACCESSORY_DEVICE_LOST,        /**< a previous accessory device is no longer available */
    BT_ACCESSORY_NAME_CHANGED,        /**< the accessory name has changed */
    BT_ACCESSORY_SETTINGS_CHANGED,  /**< the accessory settings have changed */
    BT_ACCESSORY_IN_EAR_STATUS_CHANGED, /**< the accessory in ear status has changed */
    BT_ACCESSORY_TIMESYNC_AVAILABLE, /**< the accessory Timesync status has changed to available */
    BT_ACCESSORY_TIMESYNC_NOT_AVAILABLE, /**< the accessory Timesync status has changed to non-available */
    BT_ACCESSORY_REMOTE_STREAM_STATE_IDLE, /**< the accessory stream state upate - idle */
    BT_ACCESSORY_REMOTE_STREAM_STATE_A2DP, /**< the accessory stream state upate - A2DP  */
    BT_ACCESSORY_REMOTE_STREAM_STATE_SCO, /**< the accessory stream state upate - SCO  */
    BT_ACCESSORY_IN_EAR_ENABLE_CHANGED, /**< the accessory in ear enable has changed  */
    BT_ACCESSORY_LIVE_LISTEN_VERSION_CHANGED, /**< the accessory has sent the live listen version it is using */
    BT_ACCESSORY_ACCESSIBILITY_HEADTRACKING_CHANGED, /**< the accessory headtracking setting from accessiblity has changed */
    BT_ACCESSORY_HEADTRACKING_AVAILABILITY_CHANGED, /**< the accessory headtracking availability changed */
    BT_ACCESSORY_DOUBLE_CLICK_INTERVAL_CHANGED, /**< Accessibility setting: double click interval has changed */
    BT_ACCESSORY_CHIME_VOLUME_CHANGED, /**< Accessibility setting: accessory chime volume has changed */
    BT_ACCESSORY_CLICK_HOLD_INTERVAL_CHANGED, /**< Accessibility setting: accessory stem click interval has changed */
    BT_ACCESSORY_VOLUME_SWIPE_MODE_CHANGED, /**< Accessibility setting: accessory volume swipe on/off state has changed */
    BT_ACCESSORY_VOLUME_SWIPE_INTERVAL_CHANGED, /**< Accessibility setting: accessory volume swipe interval has changed */
    BT_ACCESSORY_ONE_BUD_ANC_MODE_CHANGED, /**< Accessibility setting: accessory one bud ANC on/off has changed */
    BT_ACCESSORY_AACP_CAPABILITIES_RECEIVED /**< AACP capabilities have been received and processed */
} BTAccessoryEvent;
/**@}*/

/**
 * @name Accessory Time Sync Mode
 * @{
 */
typedef enum {
    BT_ACCESSORY_TIMESYNC_MODE_SPATIAL,
    BT_ACCESSORY_TIMESYNC_MODE_SENSOR
} BTAccessoryTimeSyncMode;

/**
 * @name Accessory Mic Mode
 * @{
 */
typedef enum {
    BT_ACCESSORY_MIC_MODE_AUTO = 0,        /**< Active Mic selected based upon in ear detection */
    BT_ACCESSORY_MIC_MODE_FIXED_RIGHT,    /**< Active Mic is on the right bud */
    BT_ACCESSORY_MIC_MODE_FIXED_LEFT    /**< Active Mic is on the left bud  */
} BTAccessoryMicMode;
/**@}*/

/**
 * @name Accessory DoubleTap Behavior
 * @{
 */
typedef enum {
    BT_ACCESSORY_DOUBLETAP_OFF = 0,               /**< OFF */
    BT_ACCESSORY_DOUBLETAP_SIRI,                  /**< Double tap will invoke Siri */
    BT_ACCESSORY_DOUBLETAP_MEDIA,                 /**< Double tap will invoke Play/Pause  */
    BT_ACCESSORY_DOUBLETAP_FORWARD,               /**< Double tap will invoke next track  */
    BT_ACCESSORY_DOUBLETAP_BACKWARD,              /**< Double tap will invoke previous track  */
    BT_ACCESSORY_DOUBLETAP_UNKNOWN_CLOUD = 0x0F,  /**< Double tap action unknown (from CloudKit, stored as 4 bits) */
    BT_ACCESSORY_DOUBLETAP_UNKNOWN       = 0xFFFF /**< Double tap action Unknown  */
    
} BTAccessoryDoubleTapAction;
/**@}*/

/**
 * @name Accessory DoubleTap capability
 * @{
 */
typedef enum {
    BT_ACCESSORY_DOUBLETAP_BASIC  = 0,                 /**< both buds either Siri or Media control */
    BT_ACCESSORY_DOUBLETAP_ADVANCED = 1,        /**< seperate tap action for individual buds */
    BT_ACCESSORY_DOUBLETAP_RAW_MODE = 2,        /**< Buds send raw tap, source interprets it*/
} BTAccessoryDoubleTapCapability;
/**@}*/
 
/**
 * @name Accessory Inear Mode
 * @{
 */
typedef enum
{
    BT_ACCESSORY_INEAR_MODE_UNKNOWN,
    BT_ACCESSORY_INEAR_MODE_DISABLED,
    BT_ACCESSORY_INEAR_MODE_ENABLED
} BTAccessoryInearMode;

/**
 * @name Accessory Inear Status
 * @{
 */
typedef enum
{
    BT_ACCESSORY_IN_EAR_STATUS_IN_EAR,
    BT_ACCESSORY_IN_EAR_STATUS_OUT_OF_EAR,
    BT_ACCESSORY_IN_EAR_STATUS_IN_CASE,
    BT_ACCESSORY_IN_EAR_STATUS_UNKNOWN,

    BT_ACCESSORY_ON_HEAD_STATUS_ON_EAR = 10,
    BT_ACCESSORY_ON_HEAD_STATUS_OFF_EAR = 11,
    BT_ACCESSORY_ON_HEAD_STATUS_ON_NECK = 12,
    BT_ACCESSORY_ON_HEAD_STATUS_UNKNOWN = 13
} BTAccessoryInEarStatus;

/**
 * @name Accessory Bud Role
 * @{
 */
typedef enum
{
    BT_ACCESSORY_BUD_ROLE_LEFT = 0x01,
    BT_ACCESSORY_BUD_ROLE_RIGHT,
    BT_ACCESSORY_BUD_ROLE_UNKNOWN
} BTAccessoryBudRole;

/**
 * @name Accessory Listening Mode
 * @{
 */
typedef enum
{
    BT_ACCESSORY_LISTENING_MODE_UNKNOWN,
    BT_ACCESSORY_LISTENING_MODE_NORMAL,
    BT_ACCESSORY_LISTENING_MODE_ANC,
    BT_ACCESSORY_LISTENING_MODE_TRANSPARENCY
} BTAccessoryListeningMode;

/**
 * @name Accessory Digital Crown Rotation Direction
 * @{
 */
typedef enum
{
    BT_ACCESSORY_CROWN_UNKNOWN,
    BT_ACCESSORY_CROWN_BACK_TO_FRONT,
    BT_ACCESSORY_CROWN_FRONT_TO_BACK
} BTAccessoryCrownRotationDirection;

#ifdef ENABLE_LIVE_LISTEN_VERSIONING
/**
 * @name Accessory Live Listen Version
 * @{
 */
typedef enum
{
    BT_ACCESSORY_LIVE_LISTEN_VERSION_UNKNOWN,
    BT_ACCESSORY_LIVE_LISTEN_VERSION_V1,
    BT_ACCESSORY_LIVE_LISTEN_VERSION_V2
} BTAccessoryLiveListenVersion;
#endif // ENABLE_LIVE_LISTEN_VERSIONING

/**
 * @name Accessory Chime Volume
 * @{
 */
typedef uint32_t BTAccessoryChimeVolume;

/**
* @name Accessory Listening Mode Configs Bitmask
* @{
*/
typedef enum
{
    BT_ACCESSORY_LISTENING_MODE_CONFIGS_BITMASK_NONE            = 0x00000000,
    BT_ACCESSORY_LISTENING_MODE_CONFIGS_BITMASK_NORMAL          = 0x00000001,
    BT_ACCESSORY_LISTENING_MODE_CONFIGS_BITMASK_ANC             = 0x00000002,
    BT_ACCESSORY_LISTENING_MODE_CONFIGS_BITMASK_TRANSPARENCY    = 0x00000004,
} BTAccessoryListeningModeCofigsBitMask;

/**
 * @name Accessory Setting Feature Bitmask
 * @{
 */
typedef enum
{
    BT_ACCESSORY_SETTING_FEATURE_BITMASK_NONE                     = 0x00000000,
    BT_ACCESSORY_SETTING_FEATURE_BITMASK_RENAME                 = 0x00000001,
    BT_ACCESSORY_SETTING_FEATURE_BITMASK_DOUBLE_TAP                = 0x00000002,
    BT_ACCESSORY_SETTING_FEATURE_BITMASK_DOUBLE_TAP_ENHANCED    = 0x00000004,
    BT_ACCESSORY_SETTING_FEATURE_BITMASK_INEAR_DETECTION        = 0x00000008,
    BT_ACCESSORY_SETTING_FEATURE_BITMASK_MIC                    = 0x00000010,
    BT_ACCESSORY_SETTING_FEATURE_BITMASK_HEAD_DETECTION            = 0x00000020,
//  BT_ACCESSORY_SETTING_FEATURE_BITMASK_EQ                        = 0x00000040, // B415 only, not currently used
//  BT_ACCESSORY_SETTING_FEATURE_BITMASK_LR_DETECTION            = 0x00000080, // B415 only, not currently used
    BT_ACCESSORY_SETTING_FEATURE_BITMASK_TRANSPARENCY           = 0x00000100,
    BT_ACCESSORY_SETTING_FEATURE_BITMASK_ANC                    = 0x00000200,
    BT_ACCESSORY_SETTING_FEATURE_BITMASK_UNTETHERED                = 0x00000400,
} BTAccessorySettingFeatureBitMask;

/**
 * @name Listen Mode support, bitmask
 * @{
 */
typedef enum
{
    BT_ACCESSORY_LISTEN_MODE_UNSUPPORTED                 = 0x00,
    BT_ACCESSORY_LISTEN_MODE_ANC_SUPPORTED               = 0x01,
    BT_ACCESSORY_LISTEN_MODE_TRANSPARENCY_SUPPORTED      = 0x02,
} BTAccessoryListenModeSupport;

/**
 * @name Session Type
 * @{
 */
typedef enum {
    BT_ACCESSORY_SESSION_TYPE_UNKNOWN           = 0x00,
    BT_ACCESSORY_SESSION_TYPE_WIRELESS_SPLITTER = 0x01,
    BT_ACCESSORY_SESSION_TYPE_SOFTWARE_VOLUME   = 0x02,
    BT_ACCESSORY_SESSION_TYPE_TEMP_PAIRING      = 0x03
} BTAccessorySessionType;

/**
 * @name Wireless Splitter Session State
 * @{
 */
typedef enum {
    BT_ACCESSORY_WS_SESSION_UNKNOWN        = 0x00,
    BT_ACCESSORY_WS_SESSION_START           = 0x01,
    BT_ACCESSORY_WS_SESSION_STOP            = 0x02,
} BTAccessoryWSSessionState;

/**
 * @name Software Volume Session State
 * @{
 */
typedef enum {
    BT_ACCESSORY_SW_VOL_SESSION_UNKNOWN     = 0x00,
    BT_ACCESSORY_SW_VOL_SESSION_START       = 0x01,
    BT_ACCESSORY_SW_VOL_SESSION_STOP        = 0x02,
}BTAccessorySwVolSessionState;

/**
 * @name Temporary Piairng Session State
 * @{
 */
typedef enum {
    BT_ACCESSORY_TEMP_PAIRING_SESSION_UNKNOWN     = 0x00,
    BT_ACCESSORY_TEMP_PAIRING_SESSION_ON          = 0x01,
    BT_ACCESSORY_TEMP_PAIRING_SESSION_OFF         = 0x02,
}BTAccessoryTempPairingSessionState;


/**
 * @name Accessory Setup Type
 * @{
 */
typedef enum {
    BT_ACCESSORY_SETUP_TYPE_UNKNOWN = 0x00,
    BT_ACCESSORY_SETUP_TYPE_SEAL    = 0x01,
}BTAccessorySetupType;

/**
 * @name Accessory Seal Setup Operation Type
 * @{
 */
typedef enum {
    BT_ACCESSORY_SETUP_SEAL_OP_UNKNOWN           = 0x00,
    BT_ACCESSORY_SETUP_SEAL_OP_START             = 0x01,
    BT_ACCESSORY_SETUP_SEAL_OP_START_RSP         = 0x02,
    BT_ACCESSORY_SETUP_SEAL_OP_STOP              = 0x03,
    BT_ACCESSORY_SETUP_SEAL_OP_STOP_RSP          = 0x04,
}BTAccessorySetupSealOpType;

/**
 * @name Accessory Generic Config Mode enable/disable
 * @{
 */
typedef enum {
    BT_ACCESSORY_GENERIC_CONFIG_MODE_UNKNOWN      = 0x00,
    BT_ACCESSORY_GENERIC_CONFIG_MODE_ENABLED      = 0x01,
    BT_ACCESSORY_GENERIC_CONFIG_MODE_DISABLED     = 0x02,
}BTAccessoryGenericConfigMode;

/**
 * @name Stereo HFP support
 * @{
 */
typedef enum {
    BT_ACCESSORY_STEREO_HFP_NOT_SUPPORTED               = 0x00,
    BT_ACCESSORY_STEREO_HFP_SUPPORTED                   = 0x01,
    BT_ACCESSORY_STEREO_HFP_AND_HEADTRACKING_SUPPORTED  = 0x02,
} BTAccessoryStereoHFPStatus;

/**
 * @name Accessory Setup Status
 * @{
 */
typedef enum {
    BT_ACCESSORY_SETUP_STATUS_SUCCESS           = 0x00,
    BT_ACCESSORY_SETUP_STATUS_NOT_READY         = 0x01,
    BT_ACCESSORY_SETUP_STATUS_TIMEOUT           = 0x02,
    BT_ACCESSORY_SETUP_STATUS_ABORT             = 0x03,
} BTAccessorySetupStatus;

typedef enum
{
    BT_ACCESSORY_CONFIG_TYPE_LISTENING_MODE             = 0x0D,
//  BT_ACCESSORY_CONFIG_TYPE_SENSOR_DETECTION           = 0x0E, // B415 only, not currently used
//  BT_ACCESSORY_CONFIG_TYPE_EQ                         = 0x0F, // B415 only, not currently used
    SWITCH_CONTROL_CONFIG_TYPE                          = 0x11, // TODO : Update naming after accordination with AssistiveTouch
    BT_ACCESSORY_CONFIG_TYPE_SINGLE_CLICK_MODE          = 0x14,
    BT_ACCESSORY_CONFIG_TYPE_DOUBLE_CLICK_MODE          = 0x15,
    BT_ACCESSORY_CONFIG_TYPE_CLICK_HOLD_MODE            = 0x16,
    BT_ACCESSORY_CONFIG_TYPE_DOUBLE_CLICK_INTERVAL      = 0x17,
    BT_ACCESSORY_CONFIG_TYPE_CLICK_HOLD_INTERVAL        = 0x18,
// 0x19 was the original opcode for BT_ACCESSORY_CONFIG_TYPE_VOLUME_SWIPE_MODE. Changed to 0x25 in SydneyB/MarimbaB
    BT_ACCESSORY_CONFIG_TYPE_LISTENING_MODE_CONFIGS     = 0x1A,
    BT_ACCESSORY_CONFIG_TYPE_ONE_BUD_ANC_MODE           = 0x1B,
    BT_ACCESSORY_CONFIG_TYPE_CROWN_ROTATION_DIR         = 0x1C,
#ifdef ENABLE_LIVE_LISTEN_VERSIONING
    BT_ACCESSORY_CONFIG_TYPE_LIVE_LISTEN_VERSION        = 0x1D,
#endif // ENABLE_LIVE_LISTEN_VERSIONING
    BT_ACCESSORY_CONFIG_TYPE_AUTO_ANSWER_MODE           = 0x1E,
    BT_ACCESSORY_CONFIG_TYPE_CHIME_VOLUME               = 0x1F,
#ifndef RC_HIDE_B698
    BT_ACCESSORY_CONFIG_TYPE_VOLUME_SWIPE_INTERVAL      = 0x23,
#endif
    BT_ACCESSORY_CONFIG_TYPE_CALL_CONFIGURATION         = 0x24,
#ifndef RC_HIDE_B698
    BT_ACCESSORY_CONFIG_TYPE_VOLUME_SWIPE_MODE          = 0x25,
#endif
}BTAccessoryConfigType;

/**
 * @name User Selected Call management status
 * @{
 */
typedef enum : uint8_t {
    BT_ACCESSORY_CALL_MANAGEMENT_STATUS_UNKNOWN         = 0x00,
    BT_ACCESSORY_CALL_MANAGEMENT_STATUS_DISABLED        = 0x01,
    BT_ACCESSORY_CALL_MANAGEMENT_STATUS_END_CALL_SET    = 0x02,
    BT_ACCESSORY_CALL_MANAGEMENT_STATUS_COUNT           // Invalid
} BTAccessoryCallManagementStatus;
/**@}*/

/**
 * @name User Selected EndCall configuration
 * @{
 */
typedef enum : uint8_t {
    BT_ACCESSORY_END_CALL_MANAGEMENT_CONFIG_UNKNOWN         = 0x00,
    BT_ACCESSORY_END_CALL_MANAGEMENT_CONFIG_DISABLED        = 0x01,
    BT_ACCESSORY_END_CALL_MANAGEMENT_CONFIG_SINGLE_TAP      = 0x02,
    BT_ACCESSORY_END_CALL_MANAGEMENT_CONFIG_DOUBLE_TAP      = 0x03,
    BT_ACCESSORY_END_CALL_MANAGEMENT_CONFIG_COUNT           // Invalid
} BTAccessoryEndCallConfig;
/**@}*/
    
/**
 * @name Call management struct
 * @{
 */

typedef enum {
    // End call only
    BT_ACCESSORY_CALL_MANAGEMENT_VERSION_0              = 0x00,
    BT_ACCESSORY_CALL_MANAGEMENT_VERSION_COUNT          // Invalid
} BTAccessoryCallManagementVersion;

typedef struct {
    uint8_t                         version;
    BTAccessoryCallManagementStatus status;
    BTAccessoryEndCallConfig        endCall;
    // below structure elements can be modified in future as needed
    BTAccessoryEndCallConfig        unusedNibble3;
    BTAccessoryEndCallConfig        unusedNibble4;
    BTAccessoryEndCallConfig        unusedNibble5;
    BTAccessoryEndCallConfig        unusedNibble6;
    BTAccessoryEndCallConfig        unusedNibble7;
} __attribute__((packed)) BTAccessoryCallManagementMessage;
/**@}*/
/**
* @name Accessory UI Gesture modes
* @{
*/
typedef enum
{
    BT_ACCESSORY_UI_GESTURE_MODE_UNKNOWN     = 0x00, /**< UI gesture action Unknown */
    BT_ACCESSORY_UI_GESTURE_MODE_SIRI        = 0x01, /**< UI gesture will invoke Siri */
    BT_ACCESSORY_UI_GESTURE_MODE_MEDIA       = 0x02, /**< UI gesture will invoke Play/Pause  */
    BT_ACCESSORY_UI_GESTURE_MODE_FORWARD     = 0x03, /**< UI gesture will invoke Next Track  */
    BT_ACCESSORY_UI_GESTURE_MODE_BACKWARD    = 0x04, /**< UI gesture will invoke Previous Track  */
    BT_ACCESSORY_UI_GESTURE_MODE_NOISE_MGMT  = 0x05, /**< UI gesture will invoke Noise Managment  */
    BT_ACCESSORY_UI_GESTURE_MODE_VOLUME_UP   = 0x06, /**< UI gesture will invoke Volume Up */
    BT_ACCESSORY_UI_GESTURE_MODE_VOLUME_DOWN = 0x07  /**< UI gesture will invoke Volume Down */
} BTAccessoryUIGestureMode;

/**
@name Accessory UI Gesture modes
@{
@Note: Each element in this struct represents a different byte in the 4-byte integer used to configure click hold modes. They are populated as follows:
    uint32_t value
    rightMode = (value) & 0xFF
    leftMode = (value >> 8) & 0xFF
    prevRightMode = (value >> 16) & 0xFF
    prevLeftMode = (value >> 24) & 0xFF
 
    prevRightMode and prevLeftMode are only supported by some Beats products, and should otherwise be ignored on products that do not support those fields.
*/
typedef struct {
    BTAccessoryUIGestureMode rightMode;
    BTAccessoryUIGestureMode leftMode;
    BTAccessoryUIGestureMode prevRightMode; // Currently only supported by some Beats products
    BTAccessoryUIGestureMode prevLeftMode;  // Currently only supported by some Beats products
} BTAccessoryUIGestureModeInformation;
/**
 @}
 */
    
/**
 * @name Accessory Relay Message Type
 * @{
 */
typedef enum
{
    BT_ACCESSORY_RELAY_MSG_TYPE_UNKNOWN                 = 0x00,        /**< Relay message type - Unknown */
    BT_ACCESSORY_RELAY_MSG_TYPE_AUDIO_ARBITRATION       = 0x01,        /**< Relay message type - Audio Arbitration for TiPi */
} BTAccessoryRelayMsgType;

/**
 * @name Accessory Connection Priority List Update Request Type
 * @{
 */
typedef enum
{
    BT_ACCESSORY_CONN_PRI_LIST_REQ_TYPE_UNKNOWN         = 0x00,        /**< Connection priority list update - Unknown */
    BT_ACCESSORY_CONN_PRI_LIST_REQ_TYPE_TIPI            = 0x01,        /**< Connection priority list update request type - TiPi */
    BT_ACCESSORY_CONN_PRI_LIST_REQ_TYPE_LEGACY_TRIANGLE = 0x02,        /**< Connection priority list update request type - Legacy Tringle */
} BTAccessoryConnPriListReqType;

/**
 * @name Accessory Command Request Type for Command Status
 * @{
 */
typedef enum
{
    BT_ACCESSORY_CMD_REQ_TYPE_UNKNOWN                       = 0x00,        /**< Command Request Type for Command Status - Unknown */
    BT_ACCESSORY_CMD_REQ_TYPE_CONN_PRI_LIST_UPDATE_TIPI     = 0x01,        /**< Command Request Type for Command Status - TiPi connection priority list update */
} BTAccessoryCmdReqType;

/**
 * @name Accessory Device State
 * @{
 */
typedef enum
{
    BT_ACCESSORY_DEVICE_STATE_UNKNOWN                       = 0x00,        /**< Unknown */
    BT_ACCESSORY_DEVICE_STATE_CONNECTED                     = 0x01,        /**< Accessory Connected on Peer Source */
    BT_ACCESSORY_DEVICE_STATE_DISCONNECTED                  = 0x02,        /**< Accessory Disconnected on Peer Source */
    BT_ACCESSORY_DEVICE_STATE_NOT_NEARBY                    = 0x03,        /**< AAccessory Not Nearby on Peer Source (TiPi user case) */
} BTAccessoryDeviceState;

/**
 * @name Accessory AACP Version String Message Version Number
 * As new strings are added to Version Info Strings, message versions are incremented accordingly
 * @{
 */
typedef enum {
    BT_ACCESSORY_VERSION_INFO_MSG_VERSION_UNKNOWN       = 0x00,
    BT_ACCESSORY_VERSION_INFO_MSG_VERSION_1             = 0x01,
    BT_ACCESSORY_VERSION_INFO_MSG_VERSION_2             = 0x02,
    BT_ACCESSORY_VERSION_INFO_MSG_VERSION_LIMIT
} BTAccessoryAACPVersionInfoMsgVersion;
/**@}*/

/**
 * @name  Accessory AACP Version String Indices
 * More AACP Version Info Strings can be added in the future. Each version bump includes all strings in previous versions.
 * Please see BTAccessoryAACPVersionInfoMsgVersion for valid version numbers.
 *
 * Many of these (protocol won't be) are going to be identical for every EA session; consider consolidating.
 * @{
*/
typedef enum {
    // BT_ACCESSORY_VERSION_INFO_MSG_VERSION_1+
    BT_ACCESSORY_AACP_VERSION_NAME                              = 0x00,
    BT_ACCESSORY_AACP_VERSION_MODEL_IDENTIFIER                  = 0x01,
    BT_ACCESSORY_AACP_VERSION_MANUFACTURER                      = 0x02,
    BT_ACCESSORY_AACP_VERSION_SERIAL_NUMBER_SYSTEM              = 0x03, // originally designed to be right bud serial
    BT_ACCESSORY_AACP_VERSION_FIRMWARE_VERSION_ACTIVE           = 0x04,
    BT_ACCESSORY_AACP_VERSION_FIRMWARE_VERSION_PENDING          = 0x05,
    BT_ACCESSORY_AACP_VERSION_HARDWARE_VERSION                  = 0x06,
    BT_ACCESSORY_AACP_VERSION_EA_PROTOCOL_NAME                  = 0x07,
    BT_ACCESSORY_AACP_VERSION_SERIAL_NUMBER_LEFT                = 0x08,
    BT_ACCESSORY_AACP_VERSION_SERIAL_NUMBER_RIGHT               = 0x09, // originally designed to be case serial
    BT_ACCESSORY_AACP_VERSION_MARKETING_VERSION                 = 0x0A,
    
    // BT_ACCESSORY_VERSION_INFO_MSG_VERSION_2+
    BT_ACCESSORY_AACP_VERSION_UUID_LEFT                         = 0x0B,
    BT_ACCESSORY_AACP_VERSION_UUID_RIGHT                        = 0x0C,
    BT_ACCESSORY_AACP_VERSION_FIRST_PAIRING_TIMESTAMP_LEFT      = 0x0D,
    BT_ACCESSORY_AACP_VERSION_FIRST_PAIRING_TIMESTAMP_RIGHT     = 0x0E
} BTAccessoryAACPVersionString;
/**@}*/

/**
 * @name Accessory AACP Capability Bits (by index)
 * Dates to the days when this was the other kind of bitmask; feel free to backfill lower values that are not powers of 2
 * Different variables shouldn't have the same index as for BTAccessoryAACPCapabilityInteger (this may one day be separate)
 */
typedef enum
{
    BT_ACCESSORY_AACP_CAP_AUTHENTICATION                = 0x08,
    BT_ACCESSORY_AACP_CAP_CERTIFICATES                  = 0x09,
    BT_ACCESSORY_AACP_CAP_SWITCH_VOLUME                 = 0x0A,
    BT_ACCESSORY_AACP_CAP_EXTENDED_HFP_VOLUME_LIMIT     = 0x0B,
    BT_ACCESSORY_AACP_CAP_VOLUME_CONTROL_BUTTON_CONFIG  = 0x0C,
    BT_ACCESSORY_AACP_CAP_PADDED_PACKETS                = 0x0D,
#ifndef RC_HIDE_B698
    BT_ACCESSORY_AACP_CAP_VOLUME_SWIPE                  = 0x0F,
#endif
    BT_ACCESSORY_AACP_CAP_CASE_INFO_RELAY               = 0x10,
    BT_ACCESSORY_AACP_CAP_CROWN_VOLUME                  = 0x20,
    BT_ACCESSORY_AACP_CAP_SPATIAL_AUDIO                 = 0x40,
    BT_ACCESSORY_AACP_CAP_CALL_MANAGEMENT_CONFIG        = 0x50,
    BT_ACCESSORY_AACP_CAP_INTERVAL_SETTING              = 0x80,
} BTAccessoryAACPCapabilityBit;

/**
* @name Accessory AACP Capability Integer (by 8-bit index)
* This is an index to either a bit or an integer (there's more than one SPI, we didn't anticipate the demand for integers)
* Different variables shouldn't have the same index as for BTAccessoryAACPCapabilityBit
*/
typedef enum
{
#ifdef ENABLE_LIVE_LISTEN_VERSIONING
   BT_ACCESSORY_AACP_CAP_LIVE_LISTEN_VERSION               = 0x03, // integer
#endif // ENABLE_LIVE_LISTEN_VERSIONING
   BT_ACCESSORY_AACP_CAP_SWITCH_CONTROL_VERSION            = 0x05, // integer
   BT_ACCESSORY_AACP_CAP_ENHANCED_TRANSPARENCY_VERSION     = 0x06, // integer
   BT_ACCESSORY_AACP_CAP_CHIME_VOLUME                      = 0x07, // integer
#ifndef RC_HIDE_B698
   BT_ACCESSORY_AACP_CAP_HP_VERSION                        = 0x30, // integer
#endif
   BT_ACCESSORY_AACP_CAP_MAXIMUM                           = 0xFF  // neither
} BTAccessoryAACPCapabilityInteger;

/**
* @name Accessory Spatial Mode Type
* @{
*/
typedef enum
{
    BT_ACCESSORY_SPATIAL_MODE_OFF                = 0x00,        /**< Spatial Mode - Disabled */
    BT_ACCESSORY_SPATIAL_MODE_CONTENTDRIVEN      = 0x01,        /**< Spatial Mode - Based on Content*/
    BT_ACCESSORY_SPATIAL_MODE_ALWAYS             = 0x02,        /**< Spatial Mode - Always */
    BT_ACCESSORY_SPATIAL_MODE_NO_STEREO_UPSAMPLE = 0x03,        /**< Spatial Mode - Disable Stereo Up Sampling */
    BT_ACCESSORY_SPATIAL_MODE_UNKNOWN            = 0xFF,        /**< Spatial Mode - Unknown */
} BTAccessorySpatialModeType;

/**
* @name Accessory Gyro Info Version
* @{
*/
typedef enum : uint8_t
{
    BT_ACCESSORY_GYRO_INFO_VERSION_UNKNOWN      = 0x00,         /**< Gyro Version - Unknown */
    BT_ACCESSORY_GYRO_INFO_VERSION_1,                           /**< Gyro Version - Version 1*/
    BT_ACCESSORY_GYRO_INFO_VERSION_LIMIT
} BTAccessoryGyroInfoVersion;
/**@}*/

/**
 * @name GAPA Version
 * @{
 */
typedef enum : uint8_t
{
    BT_ACCESSORY_GAPA_VERSION_UNKNOWN      = 0x00,         /**< GAPA Version - Unknown */
    BT_ACCESSORY_GAPA_VERSION_1,                           /**< GAPA Version - Version 1*/
    BT_ACCESSORY_GAPA_VERSION_LIMIT
} BTAccessoryGAPAVersion;
/**@}*/

/**
 * @name GAPA Timing Point
 * @{
 */
typedef enum : uint8_t
{
    GAPA_TIMING_NON_AUTH_COMPLETE          = 0x00,        /**< GAPA Timing Point - Non-Auth Complete */
    GAPA_TIMING_AUTH_SUPPORTED,                           /**< GAPA Timing Point - Auth Supported */
    GAPA_TIMING_AUTH_GET_ACRT_OTA,                        /**< GAPA Timing Point - Get ACRT OTA */
    GAPA_TIMING_AUTH_ACRT_RECEIVED,                       /**< GAPA Timing Point - ACRT Received */
    GAPA_TIMING_AUTH_CHALLENGE_OTA,                       /**< GAPA Timing Point - Challenge OTA */
    GAPA_TIMING_AUTH_RESPONSE_RECEIVED,                   /**< GAPA Timing Point - Auth Response Received */
    GAPA_TIMING_AUTH_RESULT,                              /**< GAPA Timing Point - Auth Result */
    GAPA_TIMING_COUNT                                     /**< GAPA Timing Point - Count */
} BTAccessoryGAPATimingPoint;
/**@}*/

 /**
 * @brief Callback invoked when a bluetooth accessory device is plugged in or unplugged.
 *
 * @param manager The accessory manager handle
 * @param event the accessory event
 * @param device the accessory device
 * @param state the accessory state
 * @param userData user data pointer
 */
typedef void (*BTAccessoryEventCallback)(BTAccessoryManager manager, BTAccessoryEvent event, BTDevice device, BTAccessoryState state, void* userData);

/**
 * @brief Callback invoked when a bluetooth accessory device receives setup command message.
 *
 * @param manager The accessory manager handle
 * @param device the accessory device
 * @param setupType the accessory setup command type
 * @param opType the accessory setup command operation type
 * @param pldLen the accessory setup command payload length
 * @param pldData the accessory setup command payload data
 * @param userData user data pointer
 */
typedef void (*BTAccessorySetupCommandCallback)(BTAccessoryManager manager, BTDevice device, BTAccessorySetupType setupType, uint8_t opType, BTData pldData, uint16_t pldLen, void* userData);

/**
 * @brief Callback invoked when a bluetooth accessory device is receives relay message.
 *
 * @param manager The accessory manager handle
 * @param device the accessory device
 * @param srcAddr the source address for this received relay message
 * @param msgType the accessory relay message type
 * @param pldLen the accessory relay message payload length
 * @param pldData the accessory relay message payload data
 * @param userData user data pointer
 */
typedef void (*BTAccessoryRelayMsgRecvCallback)(BTAccessoryManager manager, BTDevice device, BTDeviceAddress srcAddr, BTAccessoryRelayMsgType msgType, BTData pldData, uint16_t pldLen, void* userData);

/**
 * @brief Callback invoked when a bluetooth accessory device receives command status message for certain request type.
 *
 * @param manager The accessory manager handle
 * @param device the accessory device
 * @param reqType the type of the request which generates the command status
 * @param result the command request result from the accessory
 * @param reason the command request reason from the accessory
 * @param userData user data pointer
 */
typedef void (*BTAccessoryCommandStatusCallback)(BTAccessoryManager manager, BTDevice device, BTAccessoryCmdReqType reqType, uint16_t result, uint16_t reason, void* userData);

typedef struct {
    BTAccessoryEventCallback            accessoryEvent;
    BTAccessorySetupCommandCallback     accessorySetupCommand;
    BTAccessoryRelayMsgRecvCallback     accessoryRelayMsgRecv;
    BTAccessoryCommandStatusCallback    accessoryCommandStatus;
} BTAccessoryCallbacks;

typedef BTAccessoryCallbacks* BTAccessoryCallbackPointer;

// #define BTAccessoryManagerSetLinkKey(a, b,c,d,e,f) BTAccessoryManagerSetLinkKeyEx(a, b,c,d,0,e,f)

/*** @brief Set ANC/Transparency listening mode for a supported accessory.
 *
 * @param manager the accessory manager handle
 * @param deviceHandle the accessory device
 * @param listeningMode BTAccessoryListeningMode, listening mode
 * @return <code>BT_SUCCESS</code> on success, or <code>BT_ERROR_*</code> otherwise
 */
#define BTAccessoryManagerSetListeningMode(manager, deviceHandle, listeningMode) \
            BTAccessoryManagerSendControlCommand(manager, deviceHandle, BT_ACCESSORY_CONFIG_TYPE_LISTENING_MODE, listeningMode)

/*** @brief Set listening mode configurations (ANC/Transparency/Bypass) for a supported accessory.
*
* @param manager the accessory manager handle
* @param deviceHandle the accessory device
* @param listeningModeConfigs BTAccessoryListeningModeCofigsBitMask, listening modeConfigs
* @return <code>BT_SUCCESS</code> on success, or <code>BT_ERROR_*</code> otherwise
*/
#define BTAccessoryManagerSetListeningModeConfigs(manager, deviceHandle, listeningModeConfigs) \
            BTAccessoryManagerSendControlCommand(manager, deviceHandle, BT_ACCESSORY_CONFIG_TYPE_LISTENING_MODE_CONFIGS, listeningModeConfigs)

/*** @brief Get ANC/Transparency listening mode for a supported accessory
 *
 * @param manager the accessory manager handle
 * @param deviceHandle the accessory device
 * @param audioMode BTAccessoryListeningMode *, listening Mode
 * @return <code>BT_SUCCESS</code> on success, or <code>BT_ERROR_*</code> otherwise
 */
#define BTAccessoryManagerGetListeningMode(manager, deviceHandle, listeningMode) \
            BTAccessoryManagerGetControlCommand(manager, deviceHandle, BT_ACCESSORY_CONFIG_TYPE_LISTENING_MODE, 0x00, listeningMode)

/*** @brief Get ANC/Transparency listening mode for a supported accessory
*
* @param manager the accessory manager handle
* @param deviceHandle the accessory device
* @param listeningModeConfigs BTAccessoryListeningModeCofigsBitMask *, listening Mode configs
* @return <code>BT_SUCCESS</code> on success, or <code>BT_ERROR_*</code> otherwise
*/
#define BTAccessoryManagerGetListeningModeConfigs(manager, deviceHandle, listeningModeConfigs) \
            BTAccessoryManagerGetControlCommand(manager, deviceHandle, BT_ACCESSORY_CONFIG_TYPE_LISTENING_MODE_CONFIGS, 0x00, listeningModeConfigs)

/*** @brief Get Single Click mode for a supported accessory
*
* @param manager the accessory manager handle
* @param deviceHandle the accessory device
* @param singleClickMode single click Mode
* @return <code>BT_SUCCESS</code> on success, or <code>BT_ERROR_*</code> otherwise
*/
#define BTAccessoryManagerGetSingleClickMode(manager, deviceHandle, singleClickMode) \
            BTAccessoryManagerGetControlCommand(manager, deviceHandle, BT_ACCESSORY_CONFIG_TYPE_SINGLE_CLICK_MODE, 0x00, singleClickMode)

/*** @brief Get Double Click mode for a supported accessory
*
* @param manager the accessory manager handle
* @param deviceHandle the accessory device
* @param doubleClickMode double click Mode
* @return <code>BT_SUCCESS</code> on success, or <code>BT_ERROR_*</code> otherwise
*/
#define BTAccessoryManagerGetDoubleClickMode(manager, deviceHandle, doubleClickMode) \
            BTAccessoryManagerGetControlCommand(manager, deviceHandle, BT_ACCESSORY_CONFIG_TYPE_DOUBLE_CLICK_MODE, 0x00, doubleClickMode)

/*** @brief Get Click And Hold mode for a supported accessory
*
* @param manager the accessory manager handle
* @param deviceHandle the accessory device
* @param clickHoldMode click and hold mode from both sides
* @return <code>BT_SUCCESS</code> on success, or <code>BT_ERROR_*</code> otherwise
*/
#define BTAccessoryManagerGetClickHoldMode(manager, deviceHandle, clickHoldMode) \
            BTAccessoryManagerGetControlCommand(manager, deviceHandle, BT_ACCESSORY_CONFIG_TYPE_CLICK_HOLD_MODE, 0x00, clickHoldMode)

/*** @brief Get Double Click interval for a supported accessory
*
* @param manager the accessory manager handle
* @param deviceHandle the accessory device
* @param doubleClickIntervalMode double click interval mode
* @return <code>BT_SUCCESS</code> on success, or <code>BT_ERROR_*</code> otherwise
*/
#define BTAccessoryManagerGetDoubleClickInterval(manager, deviceHandle, doubleClickIntervalMode) \
            BTAccessoryManagerGetControlCommand(manager, deviceHandle, BT_ACCESSORY_CONFIG_TYPE_DOUBLE_CLICK_INTERVAL, 0x00, doubleClickIntervalMode)

/*** @brief Get Click And Hold interval mode for a supported accessory.
*
* @param manager the accessory manager handle
* @param deviceHandle the accessory device
* @param clickHoldIntervalMode click and hold interval mode
* @return <code>BT_SUCCESS</code> on success, or <code>BT_ERROR_*</code> otherwise
*/
#define BTAccessoryManagerGetClickHoldInterval(manager, deviceHandle, clickHoldIntervalMode) \
            BTAccessoryManagerGetControlCommand(manager, deviceHandle, BT_ACCESSORY_CONFIG_TYPE_CLICK_HOLD_INTERVAL, 0x00, clickHoldIntervalMode)

/*** @brief Get One Bud ANC mode for a supported accessory.
 *
 * @param manager the accessory manager handle
 * @param deviceHandle the accessory device
 * @param oneBudANCMode one bud ANC mode
 * @return <code>BT_SUCCESS</code> on success, or <code>BT_ERROR_*</code> otherwise
 */
#define BTAccessoryManagerGetOneBudANCMode(manager, deviceHandle, oneBudANCMode) \
        BTAccessoryManagerGetControlCommand(manager, deviceHandle, BT_ACCESSORY_CONFIG_TYPE_ONE_BUD_ANC_MODE, 0x00, oneBudANCMode)

/*** @brief Get Digital Crown Rotation Direction for a supported accessory.
 *
 * @param manager the accessory manager handle
 * @param deviceHandle the accessory device
 * @param crownRotationDir crown rotation direction (always BT_ACCESSORY_CROWN_UNKNOWN for anything without a digital crown)
 * @return <code>BT_SUCCESS</code> on success, or <code>BT_ERROR_*</code> otherwise
 */
#define BTAccessoryManagerGetCrownRotationDirection(manager, deviceHandle, crownRotationDir) \
        BTAccessoryManagerGetControlCommand(manager, deviceHandle, BT_ACCESSORY_CONFIG_TYPE_CROWN_ROTATION_DIR, 0x00, crownRotationDir)

/*** @brief Get Auto Answer Mode for a supported accessory.
 *
 * @param manager the accessory manager handle
 * @param autoAnswerMode auto answer setting (values as in BTAccessoryGenericConfigMode)
 * @return <code>BT_SUCCESS</code> on success, or <code>BT_ERROR_*</code> otherwise
 */
#define BTAccessoryManagerGetAutoAnswerMode(manager, deviceHandle, autoAnswerMode) \
        BTAccessoryManagerGetControlCommand(manager, deviceHandle, BT_ACCESSORY_CONFIG_TYPE_AUTO_ANSWER_MODE, 0x00, autoAnswerMode)

/*** @brief Get Chime Volume for a supported accessory.
 *
 * @param manager the accessory manager handle
 * @param deviceHandle the accessory device
 * @param chinmeVolumne chime volume
 * @return <code>BT_SUCCESS</code> on success, or <code>BT_ERROR_*</code> otherwise
 */
#define BTAccessoryManagerGetChimeVolume(manager, deviceHandle, chimeVolume) \
        BTAccessoryManagerGetControlCommand(manager, deviceHandle, BT_ACCESSORY_CONFIG_TYPE_CHIME_VOLUME, 0x00, chimeVolume)

#ifndef RC_HIDE_B698
/*** @brief Get Volume Swipe mode for a supported accessory
*
* @param manager the accessory manager handle
* @param deviceHandle the accessory device
* @param volumeSwipeMode volume swipe mode
* @return <code>BT_SUCCESS</code> on success, or <code>BT_ERROR_*</code> otherwise
*/
#define BTAccessoryManagerGetVolumeSwipeMode(manager, deviceHandle, volumeSwipeMode) \
            BTAccessoryManagerGetControlCommand(manager, deviceHandle, BT_ACCESSORY_CONFIG_TYPE_VOLUME_SWIPE_MODE, 0x00, volumeSwipeMode)

/*** @brief Get Volume Swipe Speed for a supported accessory.
*
* @param manager the accessory manager handle
* @param deviceHandle the accessory device
* @param volumeSwipeIntervalMode volume swipe interval
* @return <code>BT_SUCCESS</code> on success, or <code>BT_ERROR_*</code> otherwise
*/
#define BTAccessoryManagerGetVolumeSwipeInterval(manager, deviceHandle, volumeSwipeIntervalMode) \
            BTAccessoryManagerGetControlCommand(manager, deviceHandle, BT_ACCESSORY_CONFIG_TYPE_VOLUME_SWIPE_INTERVAL, 0x00, volumeSwipeIntervalMode)
#endif

/*** @brief Get Call Configuration for a supported accessory.
*
* @param manager the accessory manager handle
* @param deviceHandle the accessory device
* @param callConfiguration - configuration for different features of phone calls
* @return <code>BT_SUCCESS</code> on success, or <code>BT_ERROR_*</code> otherwise
*/
#define BTAccessoryManagerGetCallConfiguration(manager, deviceHandle, callConfiguration) \
            BTAccessoryManagerGetControlCommand(manager, deviceHandle, BT_ACCESSORY_CONFIG_TYPE_CALL_CONFIGURATION, 0x00, callConfiguration)

/*** @brief Set Switch Control mode for a supported accessory.
 *
 * @param manager the accessory manager handle
 * @param deviceHandle the accessory device
 * @param switchControlMode switch control mode
 * @return <code>BT_SUCCESS</code> on success, or <code>BT_ERROR_*</code> otherwise
 */
#define BTAccessoryManagerSetSwitchControlMode(manager, deviceHandle, switchControlMode) \
BTAccessoryManagerSendControlCommand(manager, deviceHandle, SWITCH_CONTROL_CONFIG_TYPE, switchControlMode)

/*** @brief Set Single Click mode for a supported accessory.
*
* @param manager the accessory manager handle
* @param deviceHandle the accessory device
* @param singleClickMode single click mode
* @return <code>BT_SUCCESS</code> on success, or <code>BT_ERROR_*</code> otherwise
*/
#define BTAccessoryManagerSetSingleClickMode(manager, deviceHandle, singleClickMode) \
            BTAccessoryManagerSendControlCommand(manager, deviceHandle, BT_ACCESSORY_CONFIG_TYPE_SINGLE_CLICK_MODE, singleClickMode)

/*** @brief Set Double Click mode for a supported accessory.
*
* @param manager the accessory manager handle
* @param deviceHandle the accessory device
* @param doubleClickMode double click mode
* @return <code>BT_SUCCESS</code> on success, or <code>BT_ERROR_*</code> otherwise
*/
#define BTAccessoryManagerSetDoubleClickMode(manager, deviceHandle, doubleClickMode) \
            BTAccessoryManagerSendControlCommand(manager, deviceHandle, BT_ACCESSORY_CONFIG_TYPE_DOUBLE_CLICK_MODE, doubleClickMode)

/*** @brief Set Click And Hold mode for a supported accessory.
*
* @param manager the accessory manager handle
* @param deviceHandle the accessory device
* @param leftClickHoldMode click and hold mode on left side
* @param rightClickHoldMode click and hold mode on right side
* @return <code>BT_SUCCESS</code> on success, or <code>BT_ERROR_*</code> otherwise
*/
#define BTAccessoryManagerSetClickHoldMode(manager, deviceHandle, leftClickHoldMode, rightClickHoldMode) \
            BTAccessoryManagerSendControlCommand(manager, deviceHandle, BT_ACCESSORY_CONFIG_TYPE_CLICK_HOLD_MODE, ((leftClickHoldMode << 8) | rightClickHoldMode) )

/*** @brief Set Click And Hold mode for a supported accessory.
*
* @param manager the accessory manager handle
* @param deviceHandle the accessory device
* @param gestureModeInfo is previous and current configuration on the left and right buds
* @return <code>BT_SUCCESS</code> on success, or <code>BT_ERROR_*</code> otherwise
*/
#define BTAccessoryManagerSetClickHoldModes(manager, deviceHandle, gestureModeInfo) \
            BTAccessoryManagerSendControlCommand(manager, deviceHandle, BT_ACCESSORY_CONFIG_TYPE_CLICK_HOLD_MODE, gestureModeInfo)

/*** @brief Set Double Click interval for a supported accessory.
*
* @param manager the accessory manager handle
* @param deviceHandle the accessory device
* @param doubleClickIntervalMode double click interval mode
* @return <code>BT_SUCCESS</code> on success, or <code>BT_ERROR_*</code> otherwise
*/
#define BTAccessoryManagerSetDoubleClickInterval(manager, deviceHandle, doubleClickIntervalMode) \
            BTAccessoryManagerSendControlCommand(manager, deviceHandle, BT_ACCESSORY_CONFIG_TYPE_DOUBLE_CLICK_INTERVAL, doubleClickIntervalMode)
    
/*** @brief Set Click And Hold interval for a supported accessory.
*
* @param manager the accessory manager handle
* @param deviceHandle the accessory device
* @param clickHoldIntervalMode click and hold interval mode
* @return <code>BT_SUCCESS</code> on success, or <code>BT_ERROR_*</code> otherwise
*/
#define BTAccessoryManagerSetClickHoldInterval(manager, deviceHandle, clickHoldIntervalMode) \
            BTAccessoryManagerSendControlCommand(manager, deviceHandle, BT_ACCESSORY_CONFIG_TYPE_CLICK_HOLD_INTERVAL, clickHoldIntervalMode)

/*** @brief Set One Bud ANC Mode for a supported accessory.
 *
 * @param manager the accessory manager handle
 * @param deviceHandle the accessory device
 * @param oneBudANCMode one bud ANC mode
 * @return <code>BT_SUCCESS</code> on success, or <code>BT_ERROR_*</code> otherwise
 */
#define BTAccessoryManagerSetOneBudANCMode(manager, deviceHandle, oneBudANCMode) \
        BTAccessoryManagerSendControlCommand(manager, deviceHandle, BT_ACCESSORY_CONFIG_TYPE_ONE_BUD_ANC_MODE, oneBudANCMode)

/*** @brief Set Digital Crown Rotation Direction for a supported accessory.
 *
 * @param manager the accessory manager handle
 * @param deviceHandle the accessory device
 * @param crownRotationDir crown rotation direction
 * @return <code>BT_SUCCESS</code> on success, or <code>BT_ERROR_*</code> otherwise
 */
#define BTAccessoryManagerSetCrownRotationDirection(manager, deviceHandle, crownRotationDir) \
        BTAccessoryManagerSendControlCommand(manager, deviceHandle, BT_ACCESSORY_CONFIG_TYPE_CROWN_ROTATION_DIR, crownRotationDir)

#ifdef ENABLE_LIVE_LISTEN_VERSIONING
/*** @brief Set Live Listen Version for a supported accessory.
 *
 * @param manager the accessory manager handle
 * @param deviceHandle the accessory device
 * @param liveListenVersion live listen version
 * @return <code>BT_SUCCESS</code> on success, or <code>BT_ERROR_*</code> otherwise
 */
#define BTAccessoryManagerSetLiveListenVersion(manager, deviceHandle, liveListenVersion) \
        BTAccessoryManagerSendControlCommand(manager, deviceHandle, BT_ACCESSORY_CONFIG_TYPE_LIVE_LISTEN_VERSION, liveListenVersion)
#endif // ENABLE_LIVE_LISTEN_VERSIONING

/*** @brief Set Auto Answer Mode for a supported accessory.
 *
 * @param manager the accessory manager handle
 * @param deviceHandle the accessory device
 * @param autoAnswerMode auto answer setting (values as in BTAccessoryGenericConfigMode)
 * @return <code>BT_SUCCESS</code> on success, or <code>BT_ERROR_*</code> otherwise
 */
#define BTAccessoryManagerSetAutoAnswerMode(manager, deviceHandle, autoAnswerMode) \
        BTAccessoryManagerSendControlCommand(manager, deviceHandle, BT_ACCESSORY_CONFIG_TYPE_AUTO_ANSWER_MODE, autoAnswerMode)

/*** @brief Set Chime Volume for a supported accessory.
 *
 * @param manager the accessory manager handle
 * @param deviceHandle the accessory device
 * @param chimeVolume Chime Volume
 * @return <code>BT_SUCCESS</code> on success, or <code>BT_ERROR_*</code> otherwise
 */
#define BTAccessoryManagerSetChimeVolume(manager, deviceHandle, chimeVolume) \
        BTAccessoryManagerSendControlCommand(manager, deviceHandle, BT_ACCESSORY_CONFIG_TYPE_CHIME_VOLUME, chimeVolume)

#ifndef RC_HIDE_B698
/*** @brief Set Volume Swipe mode for a supported accessory
*
* @param manager the accessory manager handle
* @param deviceHandle the accessory device
* @param volumeSwipeMode volume swipe mode from both sides
* @return <code>BT_SUCCESS</code> on success, or <code>BT_ERROR_*</code> otherwise
*/
#define BTAccessoryManagerSetVolumeSwipeMode(manager, deviceHandle, volumeSwipeMode) \
            BTAccessoryManagerSendControlCommand(manager, deviceHandle, BT_ACCESSORY_CONFIG_TYPE_VOLUME_SWIPE_MODE, volumeSwipeMode)

/*** @brief Set Volume Swipe interval for a supported accessory.
*
* @param manager the accessory manager handle
* @param deviceHandle the accessory device
* @param volumeSwipeIntervalMode volume swipe interval
* @return <code>BT_SUCCESS</code> on success, or <code>BT_ERROR_*</code> otherwise
*/
#define BTAccessoryManagerSetVolumeSwipeInterval(manager, deviceHandle, volumeSwipeIntervalMode) \
            BTAccessoryManagerSendControlCommand(manager, deviceHandle, BT_ACCESSORY_CONFIG_TYPE_VOLUME_SWIPE_INTERVAL, volumeSwipeIntervalMode)
#endif

/*** @brief Set Call Configuration for a supported accessory.
*
* @param manager the accessory manager handle
* @param deviceHandle the accessory device
* @param callConfiguration - configuration for different features of phone calls
* @return <code>BT_SUCCESS</code> on success, or <code>BT_ERROR_*</code> otherwise
*/
#define BTAccessoryManagerSetCallManagementConfig(manager, deviceHandle, callConfiguration) \
            BTAccessoryManagerSendControlCommand(manager, deviceHandle, BT_ACCESSORY_CONFIG_TYPE_CALL_CONFIGURATION, callConfiguration)

/**
 * @brief Gets the accessory manager handle.
 *
 * @param session the session handle
 * @param manager Place to store the accessory manager handle on successful completion of function
 * @return <code>BT_SUCCESS</code> on success, or <code>BT_ERROR_*</code> otherwise
 */
BTResult BTAccessoryManagerGetDefault(BTSession session, BTAccessoryManager* manager);

/**
 * @brief Adds accessory callbacks.
 *
 * Callbacks are invoked whenever the accessory state is changed.
 *
 * @param manager the accessory manager handle
 * @param callbacks the callback structure
 * @param userData User data pointer
 * @return <code>BT_SUCCESS</code> on success, or <code>BT_ERROR_*</code> otherwise
 */
BTResult BTAccessoryManagerAddCallbacks(BTAccessoryManager manager, const BTAccessoryCallbacks* callbacks, void* userData);

/**
 * @brief Removes accessory callbacks.
 *
 * @param manager the accessory manager handle
 * @param callbacks the callback structure
 * @return <code>BT_SUCCESS</code> on success, or <code>BT_ERROR_*</code> otherwise
 */
BTResult BTAccessoryManagerRemoveCallbacks(BTAccessoryManager manager, const BTAccessoryCallbacks* callbacks);

/**
 * @brief Registers a new accessory device.
 *
 * If the device already exists, it will be updated with the new parameters.
 *
 * @param manager the accessory manager handle
 * @param address the device address
 * @param name the device name
 * @param classOfDevice the class of device
 * @param pincode the pincode
 * @param device location to store the device handle
 * @return <code>BT_SUCCESS</code> on success, or <code>BT_ERROR_*</code> otherwise
 */
BTResult BTAccessoryManagerRegisterDevice(BTAccessoryManager manager, const BTDeviceAddress* address,
    const char* name, uint32_t classOfDevice, const char* pincode, BTDevice* device);

/**
 * @brief Plugs in the accessory device. Notify all listeners of the state change.
 *
 * @param manager the accessory manager handle
 * @param device the accessory device
 * @return <code>BT_SUCCESS</code> on success, or <code>BT_ERROR_*</code> otherwise
 */
BTResult BTAccessoryManagerPlugInDevice(BTAccessoryManager manager, BTDevice device);

/**
 * @brief Unplugs the accessory device. Notify all listeners of the state change.
 *
 * @param manager the accessory manager handle
 * @param device the accessory device
 * @return <code>BT_SUCCESS</code> on success, or <code>BT_ERROR_*</code> otherwise
 */
BTResult BTAccessoryManagerUnplugDevice(BTAccessoryManager manager, BTDevice device);

/**
 * @brief Gets the current state of the accessory device.
 *
 * @param manager the accessory manager handle
 * @param device the accessory device
 * @param state location to store the current state
 * @return <code>BT_SUCCESS</code> on success, or <code>BT_ERROR_*</code> otherwise
 */
BTResult BTAccessoryManagerGetDeviceState(BTAccessoryManager manager, BTDevice device, BTAccessoryState *state);

/**
 * @brief Gets a list of the accessory devices.
 *
 * @param manager the accessory manager handle
 * @param deviceArray pointer to array where devices are to be stored
 * @param deviceArraySize pointer to where deviceArray size is to be stored
 * @param deviceArrayMaxSize capacity of the deviceArray
 * @return <code>BT_SUCCESS</code> on success, or <code>BT_ERROR_*</code> otherwise
 */
BTResult BTAccessoryManagerGetDevices(BTAccessoryManager manager, BTDevice *deviceArray, size_t *deviceArraySize, size_t deviceArrayMaxSize);

/**
 * @brief Gets the battery level for an accessory device.
 *
 * @param manager the accessory manager handle
 * @param deviceHandle the accessory device
 * @param level a pointer to store the battery level
 * @return <code>BT_SUCCESS</code> on success, or <code>BT_ERROR_*</code> otherwise.
 */
BTResult BTAccessoryManagerGetDeviceBatteryLevel(BTAccessoryManager manager, BTDevice deviceHandle, uint8_t *level);

/**
 * @brief Gets the battery status for an accessory device.
 *
 * @param manager the accessory manager handle
 * @param deviceHandle the accessory device
 * @param status a pointer to store the battery status
 * @return <code>BT_SUCCESS</code> on success, or <code>BT_ERROR_*</code> otherwise.
 */
//BTResult BTAccessoryManagerGetDeviceBatteryStatus(BTAccessoryManager manager, BTDevice deviceHandle, BTDeviceBatteryStatus *status);

/**
 * @brief Asks the manager if the device is an accessory
 *
 * @param manager the accessory manager handle
 * @param deviceHandle the device to query for accessory status
 * @param isAccessory pointer to store the return value
 * @return <code>BT_SUCCESS</code> on success, or <code>BT_ERROR_*</code> otherwise.
 */
BTResult BTAccessoryManagerIsAccessory(BTAccessoryManager manager, BTDevice deviceHandle, BTBool *isAccessory);

/**
 * @brief Asks the manager to generate a link key for a device that can be used for BR/EDR connection with the device
 *
 * @param manager the accessory manager handle
 * @param address the device address
 * @param key location to store the generated link key
 * @return <code>BT_SUCCESS</code> on success, or <code>BT_ERROR_*</code> otherwise
 */
BTResult BTAccessoryManagerGenerateLinkKey(BTAccessoryManager manager, const BTDeviceAddress* address,BTSecurityKey *key);


/**
 * @brief Sets the BR/EDR link key for a remote Bluetooth device.
 *
 * @param manager the accessory manager handle
 * @param address the device address
 * @param name the device name
 * @param classOfDevice Class of Device
 * @param supportedServices  bit mask of Supported services. (Service defintion bit mask in BTTypes.h)
 * @param key link key for the device
 * @param deviceHandle location to store the device handle
 * @return <code>BT_SUCCESS</code> on success, or <code>BT_ERROR_*</code> otherwise
 * @
 */
BTResult BTAccessoryManagerSetLinkKeyEx(BTAccessoryManager manager, const BTDeviceAddress* address,
                                      const char* name, uint32_t classOfDevice, BTServiceMask supportedServices, BTSecurityKey* key,BTDevice* deviceHandle);

/*** @brief Sets double tap behavior for a supported accessory.
 *
 * @param manager the accessory manager handle
 * @param deviceHandle the accessory device
 * @param doubleTapAction the behavior on double-tap
 * @return <code>BT_SUCCESS</code> on success, or <code>BT_ERROR_*</code> otherwise
 */
BTResult BTAccessoryManagerSetDoubleTapAction(BTAccessoryManager manager, BTDevice deviceHandle, BTAccessoryDoubleTapAction doubleTapAction);

/*** @@brief Sets double tap behavior for individual buds for a supported accessory.
 *
 * @param manager the accessory manager handle
 * @param deviceHandle the accessory device
 * @param doubleTapActionLeft the behavior on double-tap for left bud
 * @param doubleTapActionRight the behavior on double-tap for right bud
 * @return <code>BT_SUCCESS</code> on success, or <code>BT_ERROR_*</code> otherwise
 */
BTResult BTAccessoryManagerSetDoubleTapActionEx(BTAccessoryManager manager, BTDevice deviceHandle, BTAccessoryDoubleTapAction doubleTapActionLeft, BTAccessoryDoubleTapAction doubleTapActionRight);

/*** @@brief gets current double tap capability of supported accessory
 *
 * @param manager the accessory manager handle
 * @param deviceHandle the accessory device
 * @param doubleTapCap DoubleTap capability of accessory
 * @return <code>BT_SUCCESS</code> on success, or <code>BT_ERROR_*</code> otherwise
 */
BTResult BTAccessoryManagerGetDoubleTapCapability(BTAccessoryManager manager, BTDevice deviceHandle, BTAccessoryDoubleTapCapability *doubleTapCap);
    
/*** @@brief gets feature capability of supported accessory
 *
 * @param manager the accessory manager handle
 * @param deviceHandle the accessory device
 * @param feature the feature
 * @param capable feature capability of accessory
 * @return <code>BT_SUCCESS</code> on success, or <code>BT_ERROR_*</code> otherwise
 */
BTResult BTAccessoryManagerGetFeatureCapability(BTAccessoryManager manager, BTDevice deviceHandle, FeatureDBEntry_t feature, BTBool *capable);

/*** @@Get if Announce Messages is supported
 *
 * @param manager the accessory manager handle
 * @param deviceHandle the accessory device
 * @param support BT_TRUE if Announce Messages is supported, BT_FALSE if not
 * @return <code>BT_SUCCESS</code> on success, or <code>BT_ERROR_*</code> otherwise
 */
BTResult BTAccessoryManagerGetAnnounceMessagesSupport(BTAccessoryManager manager, BTDevice deviceHandle, BTBool *support);

/**
 * @brief Sets active Mic mode for a supported accessory.
 *
 * @param manager the accessory manager handle
 * @param deviceHandle the accessory device
 * @param micMode Mic mode
 * @return <code>BT_SUCCESS</code> on success, or <code>BT_ERROR_*</code> otherwise
 * @
 */
BTResult BTAccessoryManagerSetMicMode(BTAccessoryManager manager, BTDevice deviceHandle,
                                      BTAccessoryMicMode micMode);
/**
 * @brief enable/disable In ear detection for a supported accessory.
 *
 * @param manager the accessory manager handle
 * @param deviceHandle the accessory device
 * @param enable TRUE if in ear detection to be enabled else FALSE
 * @return <code>BT_SUCCESS</code> on success, or <code>BT_ERROR_*</code> otherwise
 * @
 */
BTResult BTAccessoryManagerSetInEarDetectionEnable(BTAccessoryManager manager, BTDevice deviceHandle, BTBool enable);

/**
 * @brief enable/disable Time Sync for Spatial Audio.
 *
 * @param manager the accessory manager handle
 * @param deviceHandle the accessory device
 * @param enable TRUE if Timesync need to be enabled else FALSE
 * @return <code>BT_SUCCESS</code> on success, or <code>BT_ERROR_*</code> otherwise
 * @
 */
BTResult BTAccessoryManagerRemoteTimeSyncEnable(BTAccessoryManager manager, BTDevice deviceHandle, BTBool enable);

/**
 * @brief enable/disable Time Sync for Sensor Stream.
 *
 * @param manager the accessory manager handle
 * @param deviceHandle the accessory device
 * @param enable TRUE if Timesync need to be enabled else FALSE
 * @return <code>BT_SUCCESS</code> on success, or <code>BT_ERROR_*</code> otherwise
 * @
 */
BTResult BTAccessoryManagerSensorStreamTimeSyncEnable(BTAccessoryManager manager, BTDevice deviceHandle, BTBool enable);

/**
 * @brief Gets the Timesync handle for an accessory device.
 *
 * @param manager the accessory manager handle
 * @param deviceHandle the accessory device
 * @param timesyncID a pointer to store the timesync ID. This ID can be used by the APIs exposed by Timesync Framework to do time translation.
 *        Refer the API defintion of TimeSync module to find out how it can be used.
 * @return <code>BT_SUCCESS</code> on success, or <code>BT_ERROR_*</code> otherwise.
 */
BTResult BTAccessoryManagerGetTimeSyncId(BTAccessoryManager manager, BTDevice deviceHandle, uint64_t *timesyncID);

/**
 * @brief Returns active double-tap control for a supported accessory.
 *
 * @param manager the accessory manager handle
 * @param deviceHandle the accessory device
 * @param doubleTapAction pointer to store the return value
 * @return <code>BT_SUCCESS</code> on success, or <code>BT_ERROR_*</code> otherwise
 */
BTResult BTAccessoryManagerGetDoubleTapAction(BTAccessoryManager manager, BTDevice deviceHandle,
                                               BTAccessoryDoubleTapAction *doubleTapAction);

/**
 * @brief Returns active double-tap control for individual buds of supported accessory.
 *
 * @param manager the accessory manager handle
 * @param deviceHandle the accessory device
 * @param doubleTapActionLeft pointer to store the current double tap setting for left bud
 * @param doubleTapActionRight pointer to store the current double tap setting for right bud
 * @return <code>BT_SUCCESS</code> on success, or <code>BT_ERROR_*</code> otherwise
 */
BTResult BTAccessoryManagerGetDoubleTapActionEx(BTAccessoryManager manager, BTDevice deviceHandle,
                                              BTAccessoryDoubleTapAction *doubleTapActionLeft, BTAccessoryDoubleTapAction *doubleTapActionRight);

/**
 * @brief Returns active Mic mode for a supported accessory.
 *
 * @param manager the accessory manager handle
 * @param deviceHandle the accessory device
 * @param micMode pointer to store the return value
 * @return <code>BT_SUCCESS</code> on success, or <code>BT_ERROR_*</code> otherwise
 * @
 */
BTResult BTAccessoryManagerGetMicMode(BTAccessoryManager manager, BTDevice deviceHandle,
                                      BTAccessoryMicMode *micMode);
/**
 * @brief Returns current state (enable/disable) of in-ear detection for a supported accessory.
 *
 * @param manager the accessory manager handle
 * @param deviceHandle the accessory device
 * @param enable pointer to store the return value
 * @return <code>BT_SUCCESS</code> on success, or <code>BT_ERROR_*</code> otherwise
 * @
 */
BTResult BTAccessoryManagerGetInEarDetectionEnable(BTAccessoryManager manager, BTDevice deviceHandle,
                                                   BTBool *enable);

/**
 * @brief Returns if setting isHidden property on accessory succesful or not.
 *
 * @param manager the accessory manager handle
 * @param deviceHandle the accessory device
 * @param isHidden TRUE if isHidden property is set on accessory or FALSE if not. (FALSE is default).
 * @return <code>BT_SUCCESS</code> on success, or <code>BT_ERROR_*</code> otherwise
 * @
 */
BTResult BTAccessoryManagerSetIsHidden(BTAccessoryManager manager, BTDevice deviceHandle,
                                                    BTBool isHidden);

/**
 * @brief Returns current in-ear status for a supported accessory.
 *
 * @param manager the accessory manager handle
 * @param deviceHandle the accessory device
 * @param primary pointer to store the primary in ear status return value
 * @param secondary pointer to store the secondary in ear status return value
 * @return <code>BT_SUCCESS</code> on success, or <code>BT_ERROR_*</code> otherwise
 * @
 */
BTResult BTAccessoryManagerGetInEarStatus(BTAccessoryManager manager, BTDevice deviceHandle, BTAccessoryInEarStatus *primary, BTAccessoryInEarStatus *secondary);

/**
 * @brief Accessory Setup Command for a supported accessory.
 *
 * @param manager the accessory manager handle
 * @param deviceHandle the accessory device
 * @param setupType the accessory setup command type
 * @param opType the accessory setup command operation type
 * @param pldLen the accessory setup command payload length
 * @param pldData the accessory setup command payload data
 * @return <code>BT_SUCCESS</code> on success, or <code>BT_ERROR_*</code> otherwise
 * @
 */
BTResult BTAccessoryManagerSetupCommand(BTAccessoryManager manager, BTDevice deviceHandle, BTAccessorySetupType setupType, uint8_t opType, BTData pldData, uint16_t pldLen);

/**
 * @brief Accessory Relay Message (Conduit mode) for a supported accessory.
 *
 * @param manager the accessory manager handle
 * @param deviceHandle the accessory device
 * @param destAddr the accessory destination address for relay message type
 * @param msgType the accessory relay message type
 * @param pldLen the accessory relay message payload length
 * @param pldData the accessory relay messag payload data
 * @return <code>BT_SUCCESS</code> on success, or <code>BT_ERROR_*</code> otherwise
 * @
 */
BTResult BTAccessoryManagerSendRelayMsg(BTAccessoryManager manager, BTDevice deviceHandle, const BTDeviceAddress* destAddr, BTAccessoryRelayMsgType msgType, BTData pldData, uint16_t pldLen);

/**
 * @brief Accessory Update Connection Priority List request for a supported accessory.
 *        Each request would get an acknowledgement by "TODO CALLBACK NAME". If there is an on-going request for same device, the request would be rejected.
 *
 * @param manager the accessory manager handle
 * @param deviceHandle the accessory device
 * @param reqType the request type for connection priority list
 * @param connPriList the accessory connection list by the order of priority
 * @param numOfConn number of connections in the list
 * @return <code>BT_SUCCESS</code> on success, or <code>BT_ERROR_*</code> otherwise
 * @
 */
BTResult BTAccessoryManagerUpdateConnPriorityList(BTAccessoryManager manager, BTDevice deviceHandle, BTAccessoryConnPriListReqType reqType, const BTDeviceAddress* connPriList, uint8_t numOfConn);

// BT Accessory Test Interfaces specific to communicate with AACP devices.
/**
 * @name Accessory test clients
 * @{
 */
typedef enum {
    AACP_CUSTOM_MESSAGE_TYPE_ACOUSTIC                = 0x00000001,        /**< Acoustic */
    AACP_CUSTOM_MESSAGE_TYPE_SCP                    = 0x00000002,        /**< Sensor Co-processor */
    AACP_CUSTOM_MESSAGE_TYPE_BUDDY                    = 0x00000004,        /**< buddy interface */
    AACP_CUSTOM_MESSAGE_TYPE_VIRTUAL_CLI_PRIMARY    = 0x00000008,        /**<  virtual Cli interface for Primary */
    AACP_CUSTOM_MESSAGE_TYPE_VIRTUAL_CLI_SECONDARY    = 0x00000010,        /**<  virtual Cli interface for Primary */
    AACP_CUSTOM_MESSAGE_TYPE_APP_DIAGNOSTICS        = 0x00000020,        /**<  App Diagnostics */
    AACP_CUSTOM_MESSAGE_TYPE_LOGGING_TRIGGER        = 0x00000040,        /**<  Trigger Trace Log Collection */
    AACP_CUSTOM_MESSAGE_TYPE_DEBUG_DATA                = 0x00000080,        /**<  Magic Key Table/Prox Data/Link Key */
    AACP_CUSTOM_MESSAGE_TYPE_TOUCH                    = 0x00000100,        /**<  Touch Data */
    AACP_CUSTOM_MESSAGE_TYPE_LOG_CONFIG             = 0x00000200,       /**<  Configure logging on client */
    AACP_CUSTOM_MESSAGE_TYPE_LOG_MSG                = 0x00000400,       /**<  Log message or message fragment from client  */
    AACP_CUSTOM_MESSAGE_TYPE_SENSOR                 = 0x00000800,       /**<  Generic Sensor Data v1 */
    AACP_CUSTOM_MESSAGE_TYPE_SWITCH_CONTROL         = 0x00001000,       /**<  Switch Control Message */
    AACP_CUSTOM_MESSAGE_TYPE_MISMATCHED_BUDS        = 0x00002000,       /**<  Mismatched Buds Message */
    // 0x00004000 was AACP_CUSTOM_MESSAGE_TYPE_BUILD_VERSION, not used anywhere except in old internal versions
    AACP_CUSTOM_MESSAGE_TYPE_B2P                    = 0x00008000,       /**<  Beats Protocol */
    AACP_CUSTOM_MESSAGE_TYPE_CONTINUITY             = 0x00010000,       /**<  Continuity messages */
    AACP_CUSTOM_MESSAGE_TYPE_BATTERY_HEALTH         = 0x00020000,       /**<  Battery Health */
    AACP_CUSTOM_MESSAGE_TYPE_SENSOR_V2              = 0x00040000,       /**<  Generic Sensor Data v2 (internal binary format changed from v1) */
    AACP_CUSTOM_MESSAGE_TYPE_OBCv2                  = 0x00080000,       /**<  OBCv2 requirements*/
    AACP_CUSTOM_MESSAGE_TYPE_SENSOR_WX              = 0x00100000,       /**<  Modern sensor data - all sensor data going forward will go through this */
#if APPLE_FEATURE_ULLA
    AACP_CUSTOM_MESSAGE_TYPE_ULLA_STATS_MSG         = 0x00200000,       /**<  ULLA statistics from sink */
    AACP_CUSTOM_MESSAGE_TYPE_ULLA_METRICS_MSG       = 0x00400000,       /**<  ULLA metrics from sink */
#endif
#if APPLE_FEATURE_DIGITAL_ENGRAVING
    AACP_CUSTOM_MESSAGE_TYPE_DIGITAL_ENGRAVING_INFO = 0x00800000,
#endif // #if APPLE_FEATURE_DIGITAL_ENGRAVING
} BTAccessoryCustomMessageType;

/**
 * @brief Callback invoked when an AACP capable bluetooth accessory device sends custom messages.
 *
 * @param manager The accessory manager handle
 * @param device the accessory device
 * @param type   the message type
 * @param data   data byte stream
 * @param dataSize length of data byte stream in bytes
 * @param userData user data pointer
 */
typedef void (*BTAccessoryCustomMessageCallback)(BTAccessoryManager manager, BTDevice device, BTAccessoryCustomMessageType type, BTData data, size_t dataSize, void* userData);

typedef struct {
    BTAccessoryCustomMessageCallback customMessageCallback;
}BTAccessoryCustomMessageCallbacks;

typedef BTAccessoryCustomMessageCallbacks*  BTAccessoryCustomMessageCallbackPointer;

/* WARNING: BTAccessoryLoggingCallbackData is for INTERNAL USE ONLY - TO BE REMOVED  with <rdar://problem/71941502> [MBFXPC] Implement Accessory Logging Callbacks*/
typedef struct {
    void *userData;
    void *productID;
    BTBool isAccessoryLoggingRequired;
    BTBool isUserDataFromClientNULL;
}BTAccessoryLoggingCallbackData;
/**
 * @brief Register a client for receiving AACP custom messages.
 
 * Callbacks are invoked whenever the custom message is received that matches client type.
 *
 * @param manager the accessory manager handle
 * @param callback the callback structure
 * @param clientType custom message type
 * @param userData user data pointer
 * @return <code>BT_SUCCESS</code> on success, or <code>BT_ERROR_*</code> otherwise
 */
BTResult BTAccessoryManagerRegisterCustomMessageClient(BTAccessoryManager manager,
                                                       const BTAccessoryCustomMessageCallbacks *callback, BTAccessoryCustomMessageType clientType, void *userData);

/**
 * @brief Removes accessory custom message callbacks.
 *
 * @param manager the accessory manager handle
 * @param callback the callback structure
 * @return <code>BT_SUCCESS</code> on success, or <code>BT_ERROR_*</code> otherwise
 */
BTResult BTAccessoryManagerDeregisterCustomMessageClient(BTAccessoryManager manager,const BTAccessoryCustomMessageCallbacks *callback);

/**
 * @brief Sends AACP custom message to an AACP capable bluetooth accessory device
 *
 * @param manager The accessory manager handle
 * @param clientType   the message type
 * @param deviceHandle the accessory device
 * @param data   data byte stream
 * @param dataSize length of data byte stream in bytes
 */
BTResult BTAccessoryManagerSendCustomMessage (BTAccessoryManager manager, BTAccessoryCustomMessageType clientType, BTDevice deviceHandle, BTData data, size_t dataSize);
    
/**
 * @brief Gets the diagnostics info of an accessory device.
 *
 * @param manager the accessory manager handle
 * @param deviceHandle the accessory device
 * @param data a pointer to store the diagnostics info
 * @param dataLen returned data length
 * @param bufferLen maximum size for buffer
 * @return <code>BT_SUCCESS</code> on success, or <code>BT_ERROR_*</code> otherwise.
 */
BTResult BTAccessoryManagerGetDeviceDiagnostics(BTAccessoryManager manager, BTDevice deviceHandle, BTData data, size_t* dataLen, size_t bufferLen);

/**
 * @brief Send Request Periodically to an accessory device.
 *
 * @param manager the accessory manager handle
 * @param deviceHandle the accessory device
 * @param type request type, TimeStamp or Diagnostics
 * @param interval periodical interval
 * @return <code>BT_SUCCESS</code> on success, or <code>BT_ERROR_*</code> otherwise.
 */
BTResult BTAccessoryManagerSendRequestPeriodically(BTAccessoryManager manager, BTDevice deviceHandle, size_t type, size_t interval);
    
/**
 * @brief Cancel Request Periodically to an accessory device.
 *
 * @param manager the accessory manager handle
 * @param deviceHandle the accessory device
 * @param type request type, TimeStamp or Diagnostics
 * @return <code>BT_SUCCESS</code> on success, or <code>BT_ERROR_*</code> otherwise.
 */
BTResult BTAccessoryManagerCancelRequestPeriodically(BTAccessoryManager manager, BTDevice deviceHandle, size_t type);

/**
 * @brief Send Control Command to an accessory device.
 *
 * @param manager the accessory manager handle
 * @param deviceHandle the accessory device
 * @param controlType control command type
 * @param controlValue control command value
 * @return <code>BT_SUCCESS</code> on success, or <code>BT_ERROR_*</code> otherwise.
 */
BTResult BTAccessoryManagerSendControlCommand(BTAccessoryManager manager,  BTDevice deviceHandle, uint8_t controlType, uint32_t controlValue);

/**
 * @brief Get Control Command from an accessory device.
 *
 * @param manager the accessory manager handle
 * @param deviceHandle the accessory device
 * @param controlType control command type
 * @param subControlType control command subtype
 * @param controlValue control command value
 * @return <code>BT_SUCCESS</code> on success, or <code>BT_ERROR_*</code> otherwise.
 */
BTResult BTAccessoryManagerGetControlCommand(BTAccessoryManager manager,  BTDevice deviceHandle, uint8_t controlType, uint16_t subControlType, uint32_t *controlValue);


/**
 * @brief Get Setting Feature BitMask from an accessory device.
 *
 * @param manager the accessory manager handle
 * @param deviceHandle the accessory device
 * @param settingFeatureBitMask settingFeatureBitMask
 * @return <code>BT_SUCCESS</code> on success, or <code>BT_ERROR_*</code> otherwise.
 */
BTResult BTAccessoryManagerGetSettingFeatureBitMask(BTAccessoryManager manager,  BTDevice deviceHandle, uint32_t *settingFeatureBitMask);

/**
 * @brief Get Apple accessory information (includes but is not limited to version information)
 *
 * @param manager the accessory manager handle
 * @param deviceHandle the accessory device
 * @param accessoryData JSON-encoded dictionary
 * @param dataLen returned data length
 * @param bufferLen maximum size for buffer
 * @return <code>BT_SUCCESS</code> on success, or <code>BT_ERROR_*</code> otherwise.
 */
BTResult BTAccessoryManagerGetAccessoryInfo(BTAccessoryManager manager, BTDevice deviceHandle, BTData accessoryData, size_t* dataLen, size_t bufferLen);

/**
 * @brief Get AACP capability bits
 * @discussion This is not currently pushed to/from the cloud
 *
 * @param manager the accessory manager handle
 * @param deviceHandle the accessory device
 * @param capabilityBits AACP capability bits
 * @param dataLen returned data length
 * @param bufferLen maximum size for buffer
 * @return <code>BT_SUCCESS</code> on success, or <code>BT_ERROR_*</code> otherwise.
 */
BTResult BTAccessoryManagerGetAACPCapabilityBits(BTAccessoryManager manager, BTDevice deviceHandle, BTData capabilityBits, size_t* dataLen, size_t bufferLen);

/**
 * @brief Get AACP capability integer
 * @discussion This is not currently pushed to/from the cloud
 * @discussion This is a separate API from BTAccessoryManagerGetAACPCapabilityBits because its need was not anticipated
 * @discussion This will return 0 if nothing was ever received
 *
 * @param manager the accessory manager handle
 * @param deviceHandle the accessory device
 * @param index AACP capability index (the type has "bit" in the name since BTAccessoryManagerGetAACPCapabilityBits was all we thought necessary)
 * @param value AACP capability value
 * @return <code>BT_SUCCESS</code> on success, or <code>BT_ERROR_*</code> otherwise.
 */
BTResult BTAccessoryManagerGetAACPCapabilityInteger(BTAccessoryManager manager, BTDevice deviceHandle, BTAccessoryAACPCapabilityInteger index, uint32_t* value);

static inline BTResult BTAccessoryManagerConvertSetCallManagementConfiguration(uint32_t configMessage, BTAccessoryCallManagementMessage *message) {
    if (!message) {
        return BT_ERROR;
    }
    
    message->version = configMessage & 0x0F;
    message->status = (BTAccessoryCallManagementStatus)((configMessage >> 4) & 0x0F);
    message->endCall = (BTAccessoryEndCallConfig)((configMessage >> 8) & 0x0F);
    message->unusedNibble3 = (BTAccessoryEndCallConfig)((configMessage >> 12) & 0x0F);
    message->unusedNibble4 = (BTAccessoryEndCallConfig)((configMessage >> 16) & 0x0F);
    message->unusedNibble5 = (BTAccessoryEndCallConfig)((configMessage >> 20) & 0x0F);
    message->unusedNibble6 = (BTAccessoryEndCallConfig)((configMessage >> 24) & 0x0F);
    message->unusedNibble7 = (BTAccessoryEndCallConfig)((configMessage >> 28) & 0x0F);
    
    return BT_SUCCESS;
}

static inline BTResult BTAccessoryManagerConvertGetCallManagementConfiguration(BTAccessoryCallManagementMessage message, uint32_t *configMessage) {
    if (!configMessage) {
        return BT_ERROR;
    }
    
    uint32_t tempConfig = 0;
    tempConfig |= message.version & 0x0F;
    tempConfig |= (message.status & 0x0F) << 4;
    tempConfig |= (message.endCall & 0x0F) << 8;
    tempConfig |= (message.unusedNibble3 & 0x0F) << 12;
    tempConfig |= (message.unusedNibble4 & 0x0F) << 16;
    tempConfig |= (message.unusedNibble5 & 0x0F) << 20;
    tempConfig |= (message.unusedNibble6 & 0x0F) << 24;
    tempConfig |= (message.unusedNibble7 & 0x0F) << 28;
    
    *configMessage = tempConfig;
    
    return BT_SUCCESS;
}

/**
 * @brief returns version information of an accessory device.
 *
 * @param deviceId the device identifier
 * @param accAddress  out buffer to store accessory address
 * @param accAddressSize size of out buffer to store accessory address
 * @param accName  out buffer to store accessory name
 * @param accNameSize size of out buffer to store accessory name
 * @param accManufacturer  out buffer to store accessory manufacturer info
 * @param accManufacturerSize size of out buffer to store manufacturer info
 * @param accModelNumber  out buffer to store accessory model number
 * @param accModelNumberSize size of out buffer to store accessory model number
 * @param accSerialNumber  out buffer to store accessory serial number
 * @param accSerialNumberSize size of out buffer to store accessory serial number
 * @param accFWVersion  out buffer to store accessory firmware version
 * @param accFWVersionSize size of out buffer to store accessory firmware version
 * @param accHWVersion  out buffer to store accessory hardware version
 * @param accHWVersionSize size of out buffer to store accessory hardware version
 * @return <code>BT_SUCCESS</code> on success, or <code>BT_ERROR_*</code> otherwise.
 * @ Note: currently valid only for Airpods
 */
BTResult BTAccessoryManagerReadDeviceVersionInfo(uint64_t deviceId,
                                         char* accAddress, size_t accAddressSize,
                                         char* accName, size_t accNameSize,
                                         char* accManufacturer, size_t accManufacturerSize,
                                         char* accModelNumber, size_t accModelNumberSize,
                                         char* accSerialNumber, size_t accSerialNumberSize,
                                         char* accFWVersion, size_t accFWVersionSize,
                                         char* accHWVersion, size_t accHWVersionSize);

/**
 * @brief Get device color.
 *
 * @param manager the accessory manager handle
 * @param deviceHandle the accessory device
 * @param color out buffer to store color value
 * @return <code>BT_SUCCESS</code> on success, or <code>BT_ERROR_*</code> otherwise.
 */
BTResult BTAccessoryManagerGetDeviceColor(BTAccessoryManager manager,  BTDevice deviceHandle, uint32_t *color);
/**
 * @Struct to represent the response data for App Diagnostics
 */
typedef struct {
    uint32_t coordinated_count;
    uint32_t uncoordinated_count;
    uint32_t a2dp_uptime_primary_ms;
    uint32_t a2dp_uptime_secondary_ms;
    uint32_t hfp_uptime_primary_ms;
    uint32_t hfp_uptime_secondary_ms;
    uint32_t hfp_aaceld_uptime_primary_ms;
    uint32_t hfp_aaceld_uptime_secondary_ms;
    uint32_t total_uptime_ms;
    uint8_t bud_fw_ver_active[3];
    uint8_t bud_fw_ver_pending[3];
    uint8_t bud_fw_ver_previous[3];
    uint8_t bud_hw_ver[3];
    uint8_t case_fw_ver[3];
    uint8_t case_fw_ver_fwup[3];
    uint8_t case_hw_ver[3];
    uint8_t scp_fw_ver[6];
} BT_UTP_DIAG_RSP_PARMS;

    
/**
* @brief Gets a list of the 3rd party HAE supporting paired devices.
*
* @param manager the accessory manager handle
* @param deviceArray pointer to array where devices are to be stored
* @param deviceArraySize pointer to where deviceArray size is to be stored
* @param deviceArrayMaxSize capacity of the deviceArray
* @return <code>BT_SUCCESS</code> on success, or <code>BT_ERROR_*</code> otherwise
*/
BTResult BTAccessoryManagerGetNonAppleHAEPairedDevices(BTAccessoryManager manager, BTDevice* deviceArray, size_t* deviceArraySize, size_t deviceArrayMaxSize);

/**
 * @brief Sets smart Route mode for a supported accessory.
 *
 * @param manager the accessory manager handle
 * @param deviceHandle the accessory device
 * @param mode Smart Routing mode
 * @return <code>BT_SUCCESS</code> on success, or <code>BT_ERROR_*</code> otherwise
 * @
 */
BTResult BTAccessoryManagerSmartRouteMode(BTAccessoryManager manager, BTDevice deviceHandle, BTAccessoryGenericConfigMode mode);

/**
* @brief Returns current state of smart routing for a supported accessory.
*
* @param manager the accessory manager handle
* @param deviceHandle the accessory device
* @param mode receives mode
* @return <code>BT_SUCCESS</code> on success, or <code>BT_ERROR_*</code> otherwise
* @
*/
BTResult BTAccessoryManagerGetSmartRouteMode(BTAccessoryManager manager, BTDevice deviceHandle, BTAccessoryGenericConfigMode *mode);

/**
* @brief Returns current support state of smart routing for a supported accessory.
*
* @param manager the accessory manager handle
* @param deviceHandle the accessory device
* @param support receives support
* @return <code>BT_SUCCESS</code> on success, or <code>BT_ERROR_*</code> otherwise
* @
*/
BTResult BTAccessoryManagerGetSmartRouteSupport(BTAccessoryManager manager, BTDevice deviceHandle, BTAccessoryGenericConfigMode *support);

/**
* @brief Sets Spatial Audio Allowed for supported catagories.
*
* @param manager the accessory manager handle
* @param deviceHandle the accessory device
* @param mode User selection
* @return <code>BT_SUCCESS</code> on success, or <code>BT_ERROR_*</code> otherwise
* @
*/
BTResult BTAccessoryManagerSpatialAudioAllowed(BTAccessoryManager manager, BTDevice deviceHandle, BTAccessoryGenericConfigMode mode);

/**
* @brief Returns current User selection of Spatial Audio for a supported accessory.
*
* @param manager the accessory manager handle
* @param deviceHandle the accessory device
* @param mode receives mode
* @return <code>BT_SUCCESS</code> on success, or <code>BT_ERROR_*</code> otherwise
* @
*/

BTResult BTAccessoryManagerGetSpatialAudioAllowed(BTAccessoryManager manager, BTDevice deviceHandle, BTAccessoryGenericConfigMode *mode);

/**
 * @brief Sets Spatial Audio mode for a supported accessory.
 *
 * @param manager the accessory manager handle
 * @param deviceHandle the accessory device
 * @param bundleID  the bundleID of the app
 * @param mode Spatial Audio Mode
 * @param headTracking HeadTracking status
 * @return <code>BT_SUCCESS</code> on success, or <code>BT_ERROR_*</code> otherwise
 * @
 */
BTResult BTAccessoryManagerSpatialAudioConfig(BTAccessoryManager manager, BTDevice deviceHandle, const char* bundleID, BTAccessorySpatialModeType mode, BTBool headTracking);

/**
* @brief Returns current state of Spatial Audio for a supported accessory.
*
* @param manager the accessory manager handle
* @param deviceHandle the accessory device
* @param bundleID  the bundleID of the app to get the mode
* @param mode receives mode
* @param headTracking receives head tracking selection
* @return <code>BT_SUCCESS</code> on success, or <code>BT_ERROR_*</code> otherwise
* @
*/
BTResult BTAccessoryManagerGetSpatialAudioConfig(BTAccessoryManager manager, BTDevice deviceHandle, const char* bundleID, BTAccessorySpatialModeType *mode, BTBool *headTracking);

/**
* @brief Returns current state of Spatial Audio activity  a supported accessory.
*
* @param manager the accessory manager handle
* @param deviceHandle the accessory device
* @param active receives active
* @return <code>BT_SUCCESS</code> on success, or <code>BT_ERROR_*</code> otherwise
* @
*/
BTResult BTAccessoryManagerGetSpatialAudioActive(BTAccessoryManager manager, BTDevice deviceHandle, BTBool *active);
/**
 * @brief Accessory Set device state on peer source for a supported accessory.
 *
 * @param manager the accessory manager handle
 * @param deviceHandle the accessory device
 * @param peerSrcAddr the peer source address in TiPi connection
 * @param state the accessory state on peer source
 * @return <code>BT_SUCCESS</code> on success, or <code>BT_ERROR_*</code> otherwise
 * @
 */
BTResult BTAccessoryManagerSetDeviceStateOnPeerSrc(BTAccessoryManager manager, BTDevice deviceHandle, const BTDeviceAddress* peerSrcAddr, BTAccessoryDeviceState state);

/**
* @brief Get Spatial Audio Platform Support.
*
* @param manager the accessory manager handle
* @param deviceHandle the accessory device
* @param mode pointer to store the return value
* @return <code>BT_SUCCESS</code> on success, or <code>BT_ERROR_*</code> otherwise
* @
*/
BTResult BTAccessoryManagerGetSpatialAudioPlatformSupport(BTAccessoryManager manager, BTDevice deviceHandle, BTAccessoryGenericConfigMode *mode);

/**
* @brief Get if Device support Head tracked FaceTime.
*
* @param manager the accessory manager handle
* @param deviceHandle the accessory device
* @param support pointer to store the return value
* @return <code>BT_SUCCESS</code> on success, or <code>BT_ERROR_*</code> otherwise
* @
*/
BTResult BTAccessoryManagerGetStereoHFPSupport(BTAccessoryManager manager, BTDevice deviceHandle, BTAccessoryStereoHFPStatus *support);

/**
* @brief Get call configuration
*
* @param manager the accessory manager handle
* @param deviceHandle the accessory device
* @param config pointer to store the return value
* @return <code>BT_SUCCESS</code> on success, or <code>BT_ERROR_*</code> otherwise
* @
*/
BTResult BTAccessoryManagerGetCallManagementConfig(BTAccessoryManager manager, BTDevice deviceHandle, BTAccessoryCallManagementMessage *config);

/**
* @brief Get if Device support Spatial Profile:.
*
* @param manager the accessory manager handle
* @param deviceHandle the accessory device
* @param support pointer to store the return value
* @return <code>BT_SUCCESS</code> on success, or <code>BT_ERROR_*</code> otherwise
* @
*/
BTResult BTAccessoryManagerGetDeviceSoundProfileSupport(BTAccessoryManager manager, BTDevice deviceHandle, BTBool *support);

/**
* @brief Get if Device support Allows Profile.
*
* @param manager the accessory manager handle
* @param deviceHandle the accessory device
* @param allowed pointer to store the return value
* @return <code>BT_SUCCESS</code> on success, or <code>BT_ERROR_*</code> otherwise
* @
*/
BTResult BTAccessoryManagerGetDeviceSoundProfileAllowed(BTAccessoryManager manager, BTDevice deviceHandle, BTBool *allowed);

/**
* @brief Set if Device support Allows Profile.
*
* @param manager the accessory manager handle
* @param deviceHandle the accessory device
* @param allowed pointer to store the return value
* @return <code>BT_SUCCESS</code> on success, or <code>BT_ERROR_*</code> otherwise
* @
*/
BTResult BTAccessoryManagerSetDeviceSoundProfileAllowed(BTAccessoryManager manager, BTDevice deviceHandle, BTBool allowed);

/*** @@Get if Announce Calls is supported
 *
 * @param manager the accessory manager handle
 * @param deviceHandle the accessory device
 * @param support BT_TRUE if Announce Calls is supported, BT_FALSE if not
 * @return <code>BT_SUCCESS</code> on success, or <code>BT_ERROR_*</code> otherwise
 */
BTResult BTAccessoryManagerGetAnnounceCallsSupport(BTAccessoryManager manager, BTDevice deviceHandle, BTBool *support);

/*** @@Get JitterBufferLevel and device handle that is currently streaming, if in spatial music mode.
 *
 * @param manager the accessory manager handle
 * @param deviceHandle the accessory device handle should be set to none. If no active device found that is streaming it will return none.
 * @param jitterBufferLevel set to jitterBufferLevel or 0. 0 indicates no active streaming devices were found.
 * @return <code>BT_SUCCESS</code> on success, or <code>BT_ERROR_*</code> otherwise
 */
BTResult BTAccessoryManagerGetAdaptiveLatencyJitterBufferLevel(BTAccessoryManager manager, BTDevice *deviceHandle, uint16_t *jitterBufferLevel);

/**
 * @brief Get gyro information about accessory
 *
 * @param manager the accessory manager handle
 * @param deviceHandle the accessory device
 * @param gyroData address of unitialized buffer of gyro information data. if gyro information exists, this will be initialized to the appropriate size. otherwise, this will remain uninitialized. Caller is responsible for freeing this buffer.
 * @param dataLen length of initialized gyroData buffer if gyro information exists. 0 otherwise
 * @return <code>BT_SUCCESS</code> on success, or <code>BT_ERROR_*</code> otherwise.
 */
BTResult BTAccessoryManagerGetGyroInformation(BTAccessoryManager manager, BTDevice deviceHandle, uint8_t **gyroData, uint16_t *dataLen);

#if APPLE_FEATURE_COUNTERFEIT_DETECTION
/**
 * @brief Get flag indicating the device shall be treated as genuine AirPods
 *
 * @param manager the accessory manager handle
 * @param deviceHandle the accessory device
 * @param genuine BT_TRUE if genuine, BT_FALSE if not
 * @return <code>BT_SUCCESS</code> on success, or <code>BT_ERROR_*</code> otherwise.
 */
BTResult BTAccessoryManagerIsGenuineAirPods(BTAccessoryManager manager, BTDevice deviceHandle, BTBool *genuine);
#endif // APPLE_FEATURE_COUNTERFEIT_DETECTION

/**
 * @brief Get case serial numbers corresponding to an accessory productId (no connection and no deviceHandle required)
 *
 * @param manager the accessory manager handle
 * @param productId accesssory productId (of buds, not case)
 * @param serialData JSON-encoded array of serial numbers
 * @param dataLen returned data length
 * @param bufferLen maximum size for buffer
 * @return <code>BT_SUCCESS</code> on success, or <code>BT_ERROR_*</code> otherwise.
 */
BTResult BTAccessoryManagerGetCaseSerialNumbersForAppleProductId(BTAccessoryManager manager, uint16_t productId, BTData serialData, size_t* dataLen, size_t bufferLen);

/**
 * @brief Get the side (left or right) of the primary bud
 *
 * @param manager the accessory manager handle
 * @param deviceHandle the accessory device
 * @param primarySide side of primary bud, 1 = left, 2 = right, 3 = unknown
 * @return <code>BT_SUCCESS</code> on success, or <code>BT_ERROR_*</code> otherwise.
 */

BTResult BTAccessoryManagerGetPrimaryBudSide(BTAccessoryManager manager, BTDevice deviceHandle, BTAccessoryBudRole *primarySide);

#ifdef __cplusplus
} /* extern "C" */
#endif /* __cplusplus */

/**@}*/

#endif /* BT_ACCESSORY_MANAGER_H */
