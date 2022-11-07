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
 *      Bluetooth result codes.
 *
 */

/**
 * @file BTResult.h
 * This file contains Bluetooth function result codes.
 */
#ifndef BT_RESULT_H_
#define BT_RESULT_H_

/** \addtogroup BTTypes Core Types */
/**@{*/

#ifdef __cplusplus
extern "C" {
#endif /* __cplusplus */

/**
 * @name Result Codes
 * @{
 * Return values from BT functions.
 */
/** Success */
#define BT_SUCCESS									0
/** Generic Error */
#define BT_ERROR									1
/** Function not implemented */
#define BT_ERROR_NOT_IMPLEMENTED					2
/** Invalid argument was passed to function */
#define BT_ERROR_INVALID_ARGUMENT					3
/** Out of memory */
#define BT_ERROR_NO_MEMORY							4
/** Buffer is not big enough to hold the returned data. */
#define BT_ERROR_BUFFER_TOO_SMALL					5
/** Operation cancelled */
#define BT_ERROR_OPERATION_CANCELLED				6
/** Handle is not valid */
#define BT_ERROR_INVALID_HANDLE						7
/** The device address is invalid */
#define BT_ERROR_INVALID_ADDRESS					8
/** The IPC based server was not found */
#define BT_ERROR_NO_SERVER_FOUND                    9
/** The response to the operation is pending */
#define BT_ERROR_RESPONSE_PENDING                   10
/** The operation is not supported */
#define BT_ERROR_OPERATION_NOT_SUPPORTED			11
/** The current state is invalid */
#define BT_ERROR_INVALID_STATE						12
/** Insufficient entitlements */
#define BT_ERROR_INSUFFICIENT_ENTITLEMENTS			13
/** Failed to register */
#define BT_ERROR_REGISTRATION_FAILED				14
/** Already registered */
#define BT_ERROR_ALREADY_REGISTERED					15
/** not registered */
#define BT_ERROR_NOT_REGISTERED						16
/** Not allowed */
#define BT_ERROR_NOT_ALLOWED						17
/** Buffer is empty */
#define BT_ERROR_EMPTY_BUFFER						18

	
/** Session could not be attached */
#define BT_ERROR_SESSION_ATTACH_FAILED				100
/** Callbacks already registered */
#define BT_ERROR_CALLBACKS_ALREADY_REGISTERED		101
/** Service already registered */
#define BT_ERROR_SERVICE_ALREADY_REGISTERED			103
/** Service already started */
#define BT_ERROR_SERVICE_ALREADY_STARTED			104
/** Service not started */
#define BT_ERROR_SERVICE_NOT_STARTED				105
/** No callbacks were registered to handle an event */
#define BT_ERROR_NO_CALLBACKS_REGISTERED			106
/** The Service is not authorized */
#define BT_ERROR_SERVICE_NOT_AUTHORIZED				107
/** Service not supported */
#define BT_ERROR_SERVICE_NOT_SUPPORTED				108
/** No service would accept that device */
#define BT_ERROR_NO_SERVICE_FOR_DEVICE				109
/** Error during stack initialization */
#define BT_ERROR_STACK_INIT_FAILED					110
/** Stack is not ready */
#define BT_ERROR_STACK_NOT_READY					111
/** Error while executing an HCI command */
#define BT_ERROR_HCI_COMMAND_FAILED					112
/** Service is stopping but needs more time */
#define BT_ERROR_SERVICE_PENDING_STOP				113 
/** The service is not available */
#define BT_ERROR_SERVICE_NOT_AVAILABLE				114
/** No service would accept that device */
#define BT_ERROR_NO_AVAILABLE_SERVICE_FOR_DEVICE	115
/** Local address refresh in progress */
#define BT_ERROR_LOCAL_ADDRESS_REFRESH				116
/** Peer device GATT disabled */
#define BT_ERROR_LE_GATT_DISABLED					117
/** RFCOMM Session Shutdown */
#define BT_ERROR_RFCOMM_SESSION_SHUTDOWN            118

/** Local device was already connectable */
#define BT_ERROR_ALREADY_CONNECTABLE				120
/** Local device was already not connectable */
#define BT_ERROR_ALREADY_NOT_CONNECTABLE			121

/** Local device was already discoverable */
#define BT_ERROR_ALREADY_DISCOVERABLE				122
/** Local device was already not discoverable */
#define BT_ERROR_ALREADY_NOT_DISCOVERABLE			123

/** No link key found for device */
#define BT_ERROR_LINK_KEY_NOT_FOUND					150
/** Invalid link key */
#define BT_ERROR_INVALID_LINK_KEY					151
/** Link key could not be stored */
#define BT_ERROR_LINK_KEY_NOT_STORED				152
/** Link key could not be deleted */
#define BT_ERROR_LINK_KEY_NOT_DELETED				153
/** Pincode request failed */
#define BT_ERROR_PINCODE_REQUEST_DENIED				154
/** Pincode lookup failed */
#define BT_ERROR_PINCODE_NOT_FOUND					155
/** Invalid pincode */
#define BT_ERROR_INVALID_PINCODE					156

/** Incoming device authorization was denined */
#define BT_ERROR_AUTHORIZATION_REQUEST_DENIED		157
/** Device connection had an authentication failure due to an invalid pincode or link key */
#define BT_ERROR_AUTHENTICATION_FAILURE				158
/* The pin code provided is too small */
#define BT_ERROR_PINCODE_SIZE						159

/** Pairing agent was already started */
#define BT_ERROR_PAIRING_AGENT_ALREADY_STARTED		160
/** Pairing was cancelled */
#define BT_ERROR_PAIRING_CANCELLED					161
/** Pairing not allowed */
#define BT_ERROR_PAIRING_NOT_ALLOWED				162
/** Pairing already exists */
#define BT_ERROR_PAIRING_AGENT_ALREADY_EXISTS		163
/** Pairing in progress */
#define BT_ERROR_PAIRING_IN_PROGRESS				164
/** Pairing request failed */
#define BT_ERROR_PAIRING_REQUEST_FAILED				165
/** Pairing failed. Too many retries **/
#define BT_ERROR_PAIRING_TOO_MANY_ATTEMPTS			166
/** LE pairing failed because the confirm value didn't match (wrong passcode) **/
#define BT_ERROR_PAIRING_PASSCODE_INCORRECT         167
/** LE Pairing attempt failed because we're already paired to a device with the same address (public or static) **/
#define BT_ERROR_PAIRING_ALREADY_PAIRED				168
/** LE Pairing attempt failed because we're already in progress of another pairing attempt **/
#define BT_ERROR_PAIRING_ALREADY_IN_PROGRESS		169
/** LE Pairing failed due to Confirm value comparison failue **/
#define BT_ERROR_PAIRING_CONFIRM_VALUE_FAILED		170
/** LE Pairing failed due to timeout **/
#define BT_ERROR_PAIRING_TIMEOUT					171
/** LE Pairing failed due to timeout waiting for a user response **/
#define BT_ERROR_PAIRING_TIMEOUT_USER_RESPONSE		172
/** LE Pairing failed due to DHKEY check failure **/
#define BT_ERROR_PAIRING_DHKEY_CHECK_FAILED			173
/** LE Pairing failed due to Numeric Comparison failure **/
#define BT_ERROR_PAIRING_NUM_COMPARISON_FAILED		174
/** LE Pairing failed because there were no callbacks registered **/
#define BT_ERROR_PAIRING_NO_CALLBACK				175
/** LE Pairing failed due to Crypto library failure **/
#define BT_ERROR_PAIRING_CRYPTO_FAILED				176
/** Classic OOB data already exist **/
#define BT_ERROR_PAIRING_OOB_DATA_ALREADY_EXIST		177
/** LE Pairing failed due to bad link key **/
#define BT_ERROR_PAIRING_BAD_LINK_KEY				178
/** LE Pairing removed on peer device **/
#define BT_ERROR_PEER_REMOVED_PAIRING				179

/** Local device power could not be powered on or off */
#define BT_ERROR_LOCAL_DEVICE_POWER_FAILED			200
/** Local device is currently powered on */
#define BT_ERROR_LOCAL_DEVICE_POWER_IS_ON			201
/** Local device is currently powered off */
#define BT_ERROR_LOCAL_DEVICE_POWER_IS_OFF			202
/** Local device version information could not be retrieved */
#define BT_ERROR_LOCAL_DEVICE_VERSION_FAILED		203
/** Local device name could not be retrieved */
#define BT_ERROR_LOCAL_DEVICE_NAME_FAILED			204
/** Local device could not process a command */
#define BT_ERROR_LOCAL_DEVICE_NOT_READY				205
/** Local device name could not be changed */
#define BT_ERROR_LOCAL_DEVICE_NAME_CHANGE_FAILED	206
/** Local device is currently powering on or off */
#define BT_ERROR_LOCAL_DEVICE_POWER_BUSY			207
/** Local device is in airplane mode, you need to unset airplane mode before changing power state */
#define BT_ERROR_LOCAL_DEVICE_POWER_AIRPLANEMODE	208
/** Local device module has been set ON, no need to wait for a callback */
#define BT_RESULT_MODULE_POWER_SET_ON				209
/** Local device module has been set OFF, no need to wait for a callback */
#define BT_RESULT_MODULE_POWER_SET_OFF				210
/** Device is in DUT mode. Operation forbidden */
#define BT_ERROR_DUT_MODE							211
/** Local device has not been first unlocked yet */
#define BT_ERROR_LOCAL_DEVICE_NOT_FIRST_UNLOCKED    212


/** Incoming connection was rejected */
//#define BT_ERROR_CONNECTION_REJECTED				300
/** Connection was rejected due to profile in use */
//#define BT_ERROR_PROFILE_IN_USE					301
/** Connection was rejected due to duplicate connection request */
#define BT_ERROR_DUPLICATE_CONNECTION_REQUEST		302
/** Outoing connection was queued */
#define BT_ERROR_CONNECTION_PENDING				303
/** Disconnection was queued */
//#define BT_ERROR_DISCONNECTION_PENDING			304

/** Connection request failed */
#define BT_ERROR_CONNECTION_REQUEST_FAILED			305
/** Disconnection request failed */
#define BT_ERROR_DISCONNECTION_REQUEST_FAILED		306
/** Connection timed out */
#define BT_ERROR_CONNECTION_TIMEOUT					307
/** Connection was stopped due to another connection request */
#define BT_ERROR_CONNECTION_REQUEST_STOPPED			308
/** We are already connected and have no more resources to make an extra connection. */
#define BT_ERROR_MAX_CONNECTION_REACHED				309
/** incoming and outgoing connections at the same time and we lost */
#define BT_ERROR_CONNECTION_OVERLAP					310
/** We were already connected */
#define BT_ERROR_ALREADY_CONNECTED					311
/** We weren't connected */
#define BT_ERROR_NOT_CONNECTED						312
/** The peripheral disconnected */
#define BT_ERROR_PERIPHERAL_DISCONNECTED			313
/** The peripheral disconnected */
#define BT_ERROR_CONNECTION_ALREADY_EXISTS			314
/** Encryption timed out */
#define BT_ERROR_ENCRYPTION_TIMEOUT					315
/** Generic BT Timeout */
#define BT_ERROR_TIMEOUT                            316
/** AVRCP Timeout */
#define BT_ERROR_AVRCP_TIMEOUT                      317
/** BNEP Timeout */
#define BT_ERROR_BNEP_TIMEOUT                       318
/** Handsfree AG Timeout */
#define BT_ERROR_HANDSFREE_AG_TIMEOUT                319
/** Transport Switch Timeout */
#define BT_ERROR_TS_TIMEOUT                         320
/** L2CAP ERTM Timeout */
#define BT_ERROR_L2CAP_ERTM_TIMEOUT                 321
/** Stack Wrapper Timeout */
#define BT_ERROR_STACKWRAPPER_TIMEOUT               322
/** HCI Transport H4BC Timeout */
#define BT_ERROR_HCITRANS_H4BC_TIMEOUT              323
/** Conditional Timeout */
#define BT_ERROR_CONDITIONAL_TIMEOUT                324
/** L2CAP Signal Manager Timeout */
#define BT_ERROR_L2CAP_SIGNALMAN_TIMEOUT            325
/** HID Timeout */
#define BT_ERROR_HID_TIMEOUT                        326
/** HCI LMP Response Timeout */
#define BT_ERROR_HCI_LMP_RESPONSE_TIMEOUT           327
/** HCI Connection Timeout */
#define BT_ERROR_HCI_CONNECTION_TIMEOUT             328
/** HCI Page Timeout */
#define BT_ERROR_HCI_PAGE_TIMEOUT                   329
/** HCI Host Timeout */
#define BT_ERROR_HCI_HOST_TIMEOUT                   330
/** L2CAP Connection Timeout */
#define BT_ERROR_L2CAP_CONNECT_TIMEOUT              331
/** SDP Request Timeout */
#define BT_ERROR_SDP_REQUEST_TIMEOUT                332
/** SDP Connection Timeout */
#define BT_ERROR_SDP_CONNECTION_TIMEOUT             333
/** DevMgr Busy Timeout */
#define BT_ERROR_DEVMGR_BUSY_TIMEOUT                334
/** HID interface is busy*/
#define BT_HID_BUSY                                 335

/** Discovery already running */
#define BT_ERROR_DISCOVERY_IN_PROGRESS				400
/** Discovery already running */
#define BT_ERROR_DISCOVERY_NOT_IN_PROGRESS			401
/** Error during device discovery */
#define BT_ERROR_DISCOVERY_FAILED					402
/** Device discovery was cancelled */
#define BT_ERROR_DISCOVERY_CANCELLED				403
/** A discovery scan is required in order to retrieve the information  */
#define BT_ERROR_DISCOVERY_REQUIRED					404
/** Device query already running */
#define BT_ERROR_DEVICE_QUERY_IN_PROGRESS			405
/** Device query was cancelled */
#define BT_ERROR_DEVICE_QUERY_CANCELLED				406
/** Device query timed out */
#define BT_ERROR_DEVICE_QUERY_TIMEOUT				407
/** Device attribute is not present */
#define BT_ERROR_DEVICE_ATTRIBUTE_NOT_FOUND			408
/** Device role is not supported */
#define BT_ROLE_NOT_SUPPORTED						409
/** Device role may be supported, but a query is required */
#define BT_ROLE_QUERY_REQUIRED						410
/** No room to queue more discoveries. */
#define BT_ERROR_DISCOVERY_QUEUE_FULL				411
/** Unknown scan type. */
#define BT_ERROR_UNKNOWN_DISCOVERY_SCAN				412


/** The contact UID is invalid */
#define BT_ERROR_INVALID_UID						500

/** The device in not an accessory */
#define BT_ERROR_UNKNOWN_ACCESSORY					600
/** The device in not an accessory */
#define BT_ERROR_ACCESSORY_ALREADY_REGISTERED		601
/** No battery information has been received */
#define BT_ERROR_ACCESSORY_NO_BATTERY_INFO			602
/** Accessory already plugged in */
#define BT_ERROR_ACCESSORY_ALREADY_PLUGGED_IN		603
/** Accessory already not plugged in */
#define BT_ERROR_ACCESSORY_NOT_PLUGGED_IN			604


/** No device plugged in */
#define BT_ERROR_AUDIO_JACK_NO_DEVICE				700
/** Already plugged in */
#define BT_ERROR_AUDIO_JACK_ALREADY_PLUGGED_IN		701


/** Communication port is not available for this service **/
#define BT_ERROR_NO_COM_PORT						800


/* Operation cannot be completed on this attribute */
#define BT_ERROR_RESTRICTED_ATTRIBUTE				902
/* Failed to update connection interval */
#define BT_ERROR_CONNECTION_INTERVAL_UPDATE_FAILED	903
/* Invalid included service being referenced */
#define BT_ERROR_INVALID_INCLUDED_SERVICE			904
/* Attribute UUID is not allowed for this operation */
#define BT_ERROR_UUID_NOT_ALLOWED					905
/* Duplicate characteristic descriptor found */
#define BT_ERROR_DUPLICATE_CHAR_DESCRIPTOR			906
/* Characteristic properties require an extended property descriptor */
#define BT_ERROR_MISSING_EXT_PROP_DESCRIPTOR		907
/* Characteristic properties require a server config descriptor */
#define BT_ERROR_MISSING_SERVER_CONFIG_DESCRIPTOR	908
/* Characteristic properties require a client config descriptor */
#define BT_ERROR_MISSING_CLIENT_CONFIG_DESCRIPTOR	909
/* Invalid characteristic properties */
#define BT_ERROR_INVALID_CHAR_PROPERTIES			910
/* Invalid characteristic value permissions */
#define BT_ERROR_INVALID_CHAR_VALUE_PERMISSIONS		911
/* Duplicate primary service */
#define BT_ERROR_DUPLICATE_PRIMARY_SERVICE			912
/* Not sending GATT command as the subscription state is already correct */
#define BT_ERROR_SUBSCRIPTION_STATE_CORRECT			913

/* LE ATT errors */
#define BT_ERROR_ATT_SUCCESS								1000
#define BT_ERROR_ATT_INVALID_HANDLE					  		1001
#define BT_ERROR_ATT_READ_NOT_PERMITTED		  			  	1002
#define BT_ERROR_ATT_WRITE_NOT_PERMITTED				 	1003
#define BT_ERROR_ATT_INVALID_PDU					  		1004
#define BT_ERROR_ATT_INSUFFICIENT_AUTHENTICATION  			1005
#define BT_ERROR_ATT_REQUEST_NOT_SUPPORTED					1006
#define BT_ERROR_ATT_INVALID_OFFSET					  		1007
#define BT_ERROR_ATT_INSUFFICIENT_AUTHORIZATION				1008
#define BT_ERROR_ATT_PREPARE_QUEUE_FULL					  	1009
#define BT_ERROR_ATT_ATTRIBUTE_NOT_FOUND					1010
#define BT_ERROR_ATT_ATTRIBUTE_NOT_LONG						1011
#define BT_ERROR_ATT_INSUFFICIENT_ENCRYPTION_KEY_SIZE		1012
#define BT_ERROR_ATT_INVALID_ATTRIBUTE_VALUE_LENGTH			1013
#define BT_ERROR_ATT_UNLIKELY_ERROR							1014
#define BT_ERROR_ATT_INSUFFICIENT_ENCRYPTION				1015
#define BT_ERROR_ATT_UNSUPPORTED_GROUP_TYPE					1016
#define BT_ERROR_ATT_INSUFFICIENT_RESOURCES					1017
/* ATT errors go ]0;255] */
	
/* LE L2CAP Errors */
#define BT_ERROR_L2CAP_INVALID_PSM							1100
#define BT_ERROR_L2CAP_PSM_ALREADY_REGISTERED				1101
#define BT_ERROR_L2CAP_NO_RESOURCES							1102
#define BT_ERROR_L2CAP_PSM_ALREADY_CONNECTED				1103
#define BT_ERROR_L2CAP_NO_SUCH_CONNECTION					1104
#define BT_ERROR_L2CAP_FAILED_TO_REGISTER_SOCKET_PIPE		1105

	
#define BT_ERROR_ATT_RESERVED_MAX							1255

/**@}*/

#define BT_RESULT_SUCCESS(result)		((result) == BT_SUCCESS)

#define BT_RESULT_CONNECTION_TIMEOUT(result)    ((result) == BT_ERROR_CONNECTION_TIMEOUT || ((result) >= BT_ERROR_TIMEOUT && (result) <= BT_ERROR_DEVMGR_BUSY_TIMEOUT))

#ifdef __cplusplus
} /*  extern "C" */
#endif /* __cplusplus */

/**@}*/

#endif /* BT_RESULT_H_ */
