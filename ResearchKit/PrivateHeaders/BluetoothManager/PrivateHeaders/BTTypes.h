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
 *      Bluetooth type definitions.
 *
 */

/**
 * @file BTTypes.h
 * This file contains basic Bluetooth type definitions.
 */
#ifndef BT_TYPES_H_
#define BT_TYPES_H_

/** \addtogroup BTTypes Core Types */
/**@{*/

#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <stdint.h>

#ifndef BT_DEPRECATED
#define BT_DEPRECATED  __attribute__ (( deprecated))
#else
#undef BT_DEPRECATED
#define BT_DEPRECATED ;
#endif

#ifndef BT_WEAK_LINK
#define BT_WEAK_LINK __attribute__ (( weak ))
#endif /* BT_WEAK_LINK */


#ifdef __cplusplus
extern "C" {
#if 0
}
#endif
#endif /* __cplusplus */

/** 
 * @brief Function result type.
 */
typedef int BTResult;

/** 
 * @brief Boolean type.
 */
enum {
	BT_FALSE = 0,
	BT_TRUE = 0xFFFFFFFF
};
typedef unsigned int BTBool;

/** 
 * @brief Byte type.
 */
typedef uint8_t BTByte;

/**
 * @brief Float type.
 */
typedef float BTFloat;

/** 
 * @brief UTF8 character type.
 */
/* typedef uint8_t char; */
typedef char BTChar;

/** 
 * @brief bytes type.
 */
typedef uint8_t *BTData;

/**
 * @brief Device address.
 */
typedef struct {
	uint8_t bytes[6];
} BTDeviceAddress;

/**
 * @brief Bluetooth Group Id
 */
typedef int32_t BTGroupId;

#define BT_CONTACT_SYNC_ALL_GROUP -1
#define BT_CONTACT_SYNC_NONE_GROUP -2

/** 
 * @brief Option flags.
 */
typedef uint32_t BTOptionFlags;

/** 
 * @brief 128-bit UUID.
 */
typedef struct {
	uint8_t bytes[16];
} BTUUID128;

/**
 * @name Bit Flags
 * @{
 * Defines for bit flags.
 */
#define BIT0	0x00000001
#define BIT1	0x00000002
#define BIT2	0x00000004
#define BIT3	0x00000008
#define BIT4	0x00000010
#define BIT5	0x00000020
#define BIT6	0x00000040
#define BIT7	0x00000080
#define BIT8	0x00000100
#define BIT9	0x00000200
#define BIT10	0x00000400
#define BIT11	0x00000800
#define BIT12	0x00001000
#define BIT13	0x00002000
#define BIT14	0x00004000
#define BIT15	0x00008000
#define BIT16	0x00010000
#define BIT17	0x00020000
#define BIT18	0x00040000
#define BIT19	0x00080000
#define BIT20	0x00100000
#define BIT21	0x00200000
#define BIT22	0x00400000
#define BIT23	0x00800000
#define BIT24	0x01000000
#define BIT25	0x02000000
#define BIT26	0x04000000
#define BIT27	0x08000000
#define BIT28	0x10000000
#define BIT29	0x20000000
#define BIT30	0x40000000
#define BIT31	0x80000000
/**@}*/

#define BIT_IS_SET(num, bit)		(((num) & (bit)) == (bit))

#define BT_DEVICE_CONSTANT(h)		((BTDevice)(0xFFFF0000|(h)))

/* Get specific bytes from an 32-bit integer , index ranges from 3(MSB) to 0(LSB) for GET_UINT8; index ranges from 1(MSB) to 0(LSB) for GET_UINT16*/
#define BT_GET_UINT8_FROM_UINT32(num, index)	( ((0x000000FF<<(index*8)) & (num)) >> (index*8))
#define BT_GET_UINT16_FROM_UINT32(num, index)	( ((0x0000FFFF<<(index*16)) & (num)) >> (index*16))

/**
* Service ID
*/
typedef uint32_t BTServiceID;

/**
* Service mask. Stored as bitwise OR'd flags.
*/
typedef BTOptionFlags BTServiceMask;

/**
 * @name Service IDs
 * @{
 * Defines for service flags.
 */
/** None */
#define BT_SERVICE_NONE							0
/** handsfree service */
#define BT_SERVICE_HANDSFREE					BIT0
/** phonebook service */
#define BT_SERVICE_PHONEBOOK					BIT1
/** Remote service (AVRCP) */
#define BT_SERVICE_REMOTE						BIT3
/** A2DP service */
#define BT_SERVICE_A2DP	    					BIT4
/** HID service */
#define BT_SERVICE_HID	    					BIT5
/** Sensor service */
#define BT_SERVICE_SENSOR	    				BIT6
/** Wireless IAP service */
#define BT_SERVICE_WIRELESS_IAP					BIT7
/** DUN/PAN-NAP Service for internet sharing */
#define BT_SERVICE_NET_SHARING					BIT8
/* Message access profile. */
#define BT_SERVICE_MAP							BIT9
/** Passthrough service */
#define BT_SERVICE_PASSTHROUGH					BIT10
/** Gaming service */
#define BT_SERVICE_GAMING						BIT11
/* Client of network sharing */
#define BT_SERVICE_NETWORK_CONSUMER				BIT12
/* Braille service */
#define BT_SERVICE_BRAILLE						BIT13
/* Stream to multiple devices */
#define BT_SERVICE_PASSIVE_MULTI_STREAM			BIT14
/* Stream to multiple devices */
#define BT_SERVICE_LE_GATT_CLIENT				BIT15
/* LE Audio */
#define BT_SERVICE_LEA							BIT16
/** Wireless IAP sink service */
#define BT_SERVICE_WIRELESS_IAP_SINK            BIT17
/** Wireless car play */
#define BT_SERVICE_WIRELESS_CARPLAY             BIT18
/** Advanced Accessory Control */
#define BT_SERVICE_AACP							BIT19
/** GATT over Classic */
#define BT_SERVICE_GATT                         BIT20
/** all services */
#define BT_SERVICE_ALL							0xFFFFFFFF
/**@}*/

/**
 * LocalDeviceEvents mask. Stored as bitwise OR'd flags.
 */
typedef BTOptionFlags BTLocalDeviceEventMask;

/**
* @name Local device events
* @{
* Defines for local device events
*/
/** None */
#define BT_MASKED_EVENTS_NONE								0
#define BT_LOCAL_DEVICE_EVENT_POWER_STATE_CHANGED			BIT0
#define BT_LOCAL_DEVICE_EVENT_NAME_CHANGED					BIT1
#define BT_LOCAL_DEVICE_EVENT_DISCOVERABILITY_CHANGED		BIT2
#define BT_LOCAL_DEVICE_EVENT_CONNECTABILITY_CHANGED		BIT3
#define BT_LOCAL_DEVICE_EVENT_PAIRING_STATUS_CHANGED		BIT4
#define BT_LOCAL_DEVICE_EVENT_CONNECTION_STATUS_CHANGED		BIT5
#define BT_LOCAL_DEVICE_EVENT_DISCOVERY_STARTED				BIT6
#define BT_LOCAL_DEVICE_EVENT_DISCOVERY_STOPPED				BIT7
#define BT_LOCAL_DEVICE_EVENT_ADVERTISING_STATUS_CHANGED	BIT8
#define BT_LOCAL_DEVICE_EVENT_AIRPLANE_MODE_STATUS_CHANGED	BIT9
#define BT_LOCAL_DEVICE_EVENT_BLACKLIST_MODE_CHANGED		BIT10
#define BT_LOCAL_DEVICE_EVENT_FIRST_UNLOCK_COMPLETED        BIT11
/**@}*/

/**
 * ServiceEvents mask. Stored as bitwise OR'd flags.
 */
typedef BTOptionFlags BTServiceEventMask;

/**
 * @name Service events
 * @{
 * Defines for service events
 */
/** None */
#define BT_SERVICE_EVENT_CONNECT			BIT0
#define BT_SERVICE_EVENT_DISCONNECT			BIT1
#define BT_SERVICE_EVENT_DEPENDENT_EVENT	BIT2
/**@}*/

/**
* the session opaque type
*/
struct BTSessionImpl;
typedef struct BTSessionImpl* BTSession;

/**
* the local device opaque type
*/
struct BTLocalDeviceImpl;
typedef struct BTLocalDeviceImpl* BTLocalDevice;

/**
* the device opaque type
*/
struct BTDeviceImpl;
typedef struct BTDeviceImpl* BTDevice;

/**
* the discovery agent opaque type
*/
struct BTDiscoveryAgentImpl;
typedef struct BTDiscoveryAgentImpl* BTDiscoveryAgent;

/**
 * the pairing agent opaque type
 */
struct BTPairingAgentImpl;
typedef struct BTPairingAgentImpl* BTPairingAgent;

/**
* the accssory manager opaque type
*/
struct BTAccessoryManagerImpl;
typedef struct BTAccessoryManagerImpl* BTAccessoryManager;

typedef struct {
	uint8_t 	retx;
	int8_t 		rssi;
	int8_t 		noise;
	uint8_t 	snr;
	uint16_t 	data_rate;
	uint16_t 	jitter_buffer;
	uint16_t 	codec_type;
	char 		device_name[256];
} BTLinkQualityDeviceData;

typedef struct {
	uint16_t count;
	BTLinkQualityDeviceData deviceData[2];
} BTLinkQualityData;

typedef uint8_t	BTLocalDeviceAfhMap[10];

typedef struct {
	uint8_t channelMap[10];
} BTAfhMapStruct;

/**
 * @brief Security Key.
 */
typedef struct {
	uint8_t key[16];
}BTSecurityKey;

/*
 * @brief bluetooth device names
 */
typedef struct {
	char name[248];
} BTDeviceName;

#define BTDeviceConnectNormalMode                       0          // Connect in normal mode.
#define BTDeviceConnectGuestMode                    ( 1U << 0 )     //  Connect in guest mode.
#define BTDeviceConnectGuestModeWithLinkey          ( 1U << 1 )     //  Connect in guest mode with specified linkkey.
#define BTDeviceConnectGuestModeNotInContactsWithLinkkey ( 1U << 2 ) // Connect in guest mode that is not in contacts with specified linkkey.
typedef uint32_t BTDeviceConnectMode;


#ifdef __cplusplus
#if 0
{
#endif
} /* extern "C" */
#endif /* __cplusplus */

/**@}*/

#endif /* BT_TYPES_H_ */
