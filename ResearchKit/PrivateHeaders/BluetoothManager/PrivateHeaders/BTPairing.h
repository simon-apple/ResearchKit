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
 *      Bluetooth Pairing functions.
 *
 */

/**
 * @file BTPairing.h
 * This file contains APIs for Bluetooth device pairing.
 */
#ifndef BT_PAIRING_H_
#define BT_PAIRING_H_

/** \addtogroup BTPairing Pairing APIs */
/**@{*/

#ifdef __cplusplus
extern "C" {
#endif /* __cplusplus */

#include "BTDevice.h"
#include "BTTypes.h"

/**
* Constant to represent an empty pincode.
**/                 
#define BT_PINCODE_NONE		""

typedef enum {
	BT_PAIRING_AGENT_STARTED = 0,
	BT_PAIRING_AGENT_STOPPED,
	BT_PAIRING_ATTEMPT_STARTED,
	BT_PAIRING_ATTEMPT_COMPLETE
} BTPairingEvent;

/**
* v2.1+EDR, SSP IO Capabilities response/reply
**/
typedef enum {
	BT_PAIRING_IOCAP_DISPLAY_ONLY = 0x00,
	BT_PAIRING_IOCAP_DISPLAY_YES_NO,
	BT_PAIRING_IOCAP_KEYBOARD_ONLY,
	BT_PAIRING_IOCAP_NO_IN_NO_OUT
}BTPairingIOCapability;

/** @brief Callback invoked when a pairing status has changed.
 *
 * @param agent the pairing agent
 * @param event the pairing event
 * @param device the device associated with this event, or <code>BT_DEVICE_NONE</code>
 * @param result the result code
 * @param userData User data pointer
 */
typedef void (*BTPairingAgentStatusEventCallback)(BTPairingAgent agent, BTPairingEvent event, BTDevice device, BTResult result, void* userData);

/**
 * @brief Callback invoked whenever a pincode is required to pair a device.
 *
 * @param agent the pairing agent
 * @param device the remote device
 * @param minLength the minimum pincode length
 * @param userData User data pointer
 * @see BTPairingAgentSetPincode
 */
typedef void (*BTPairingAgentPincodeCallback)(BTPairingAgent agent, BTDevice device, uint8_t minLength, void* userData);

/**
 * @brief Callback invoked whenever authorization is required to connect a device to a given service.
 *
 * @param agent the pairing agent
 * @param device the remote device
 * @param services the services the device wishes to connect
 * @param userData User data pointer
 */
typedef void (*BTPairingAgentAuthorizationCallback)(BTPairingAgent agent, BTDevice device, BTServiceMask services, void* userData);

/**
 * @brief Callback invoked whenever the user needs to validate to pair a device.
 *
 * @param agent the pairing agent
 * @param device the remote device
 * @param value the value to be displayed if mitm is true
 * @param mitm if false we only need a "ACCEPT"/"DENY" pair of button otherwise we need to display the value
 * @param userData User data pointer
 */
typedef void (*BTPairingAgentUserConfirmationCallback)(BTPairingAgent agent, BTDevice device, uint32_t value, BTBool mitm, void* userData);

/**
 * @brief Callback invoked whenever a passkey needs to be displayed on the screen.
 *
 * @param agent the pairing agent
 * @param device the remote device
 * @param value the value to display.
 * @param userData User data pointer
 */
typedef void (*BTPairingAgentPassKeyDisplayCallback)(BTPairingAgent agent, BTDevice device, uint32_t value, void* userData); 

/**
 * @brief Callback invoked whenever local OOB data was generated.
 *
 * @param agent the pairing agent
 * @param c192 P192 confirm value
 * @param r192 P192 random value
 * @param c256 P192 confirm value
 * @param r256 P192 random value
 * @param userData User data pointer
 */
typedef void (*BTPairingAgentLocalOOBDataReadyCallback)(BTPairingAgent agent, BTData c192, BTData r192, BTData c256, BTData r256, void* userData);

typedef struct {
	BTPairingAgentStatusEventCallback statusEvent;
	BTPairingAgentPincodeCallback pincodeRequest;
	BTPairingAgentAuthorizationCallback authorizationRequest;
	BTPairingAgentUserConfirmationCallback userConfirmationRequest;
	BTPairingAgentPassKeyDisplayCallback passKeyRequest;
	BTPairingAgentLocalOOBDataReadyCallback localOOBDataReady;
} BTPairingAgentCallbacks;

typedef BTPairingAgentCallbacks* BTPairingAgentCallbackPointer;

/**
 * @brief Creates a pairing agent.
 *
 * Call @ref BTPairingAgentDestroy to release the object.
 *
 * @param session the bluetooth session handle
 * @param callbacks the callback structure
 * @param userData User data pointer
 * @param agent Place to store the handle on successful completion of function
 * @return <code>BT_SUCCESS</code> on success, or <code>BT_ERROR_*</code> otherwise
 */
BTResult BTPairingAgentCreate(BTSession session, const BTPairingAgentCallbacks* callbacks,
	void* userData, BTPairingAgent* agent);

/**
 * @brief Destroys a previously created pairing agent.
 *
 * When finished it will destroy the handle and set the passed handle to <code>NULL</code>.
 * If pairing is in progress it will be immediately cancelled.
 *
 * @param agent Pointer to the handle previously returned by @ref BTPairingAgentCreate
 * @return <code>BT_SUCCESS</code> on success, or <code>BT_ERROR_*</code> otherwise
 */
BTResult BTPairingAgentDestroy(BTPairingAgent* agent);

/**
 * @brief Enters pairing mode.
 *
 * The pairing agent will accept pairing requests when in this mode.
 *
 * @param agent the pairing agent
 * @return <code>BT_SUCCESS</code> on success, or <code>BT_ERROR_*</code> otherwise
 */
BTResult BTPairingAgentStart(BTPairingAgent agent);

/**
 * @brief Exits pairing mode.
 *
 * The pairing agent will no longer accept any pairing requests.
 *
 * @param agent the pairing agent
 * @return <code>BT_SUCCESS</code> on success, or <code>BT_ERROR_*</code> otherwise
 */
BTResult BTPairingAgentStop(BTPairingAgent agent);

/**
 * @brief Cancels a pairing request in progress.
 *
 * @param agent the pairing agent
 * @return <code>BT_SUCCESS</code> on success, or <code>BT_ERROR_*</code> otherwise
 */
BTResult BTPairingAgentCancelPairing(BTPairingAgent agent);

/**
 * @brief Sets the pincode for a device.
 *
 * This function may be called on its own or in response to the @ref BTPairingAgentCallbacks::pincodeRequest callback.
 * To cancel a pincode request callback, use @ref BTPairingAgentCancelPairing.
 *
 * @param agent the pairing agent
 * @param device the remote device
 * @param pincode the pincode to use, or <code>BT_PINCODE_NONE</code> if not required.
 * @return <code>BT_SUCCESS</code> on success, <code>BT_ERROR_*</code> otherwise
 */
BTResult BTPairingAgentSetPincode(BTPairingAgent agent, BTDevice device, const char* pincode);



BTResult BTPairingAgentAcceptSSP(BTPairingAgent agent, BTDevice device, BTResult error);

/**
 * @brief Deletes a previously paired device.
 *
 * This will remove all information stored for the device, including pincodes, link keys, and device settings.
 *
 * @param agent the pairing agent
 * @param device the device to delete
 * @return <code>BT_SUCCESS</code> on success, or <code>BT_ERROR_*</code> otherwise
 */
BTResult BTPairingAgentDeletePairedDevice(BTPairingAgent agent, BTDevice device);

/**
 * @brief Sets I/O Capability for next SSP pairing.
 *
 * This will set the I/O capability for next SSP pairing sessions
 *
 * @param agent the pairing agent
 * @param ioCapability desired I/O Capability
 * @return <code>BT_SUCCESS</code> on success, or <code>BT_ERROR_*</code> otherwise
 */
BTResult BTPairingAgentSetIOCapability(BTPairingAgent agent, BTPairingIOCapability ioCapability);

/**
 * @brief Clears the OOB data for a specified device
 *
 * This will clear the OOB data for a specified device
 *
 * @param agent the pairing agent
 * @param device specified device
 * @return <code>BT_SUCCESS</code> on success, or <code>BT_ERROR_*</code> otherwise
 */
BTResult BTPairingAgentClearOOBDataForDevice(BTPairingAgent agent, BTDevice device);
	
/**
 * @brief Sets the OOB data for a specified device
 *
 * This will set the OOB data for a specified device
 *
 * @param agent the pairing agent
 * @param device specified device
 * @param confirm192 the confirmation192 value received from the peer
 * @param random192 the random192 value received from the peer
 * @param confirm256 the confirmation256 value received from the peer
 * @param random256 the random256 value received from the peer
 * @return <code>BT_SUCCESS</code> on success, or <code>BT_ERROR_*</code> otherwise
 */
BTResult BTPairingAgentSetOOBDataForDevice(BTPairingAgent agent, BTDevice device, const BTData confirm192 , const BTData random192, const BTData confirm256 , const BTData random256);
	
/**
 * @brief Gets the local OOB data.
 *
 * This will initiate the generation of the local OOB data. When the local OOB data is ready,
 * @ref BTPairingAgentCallbacks::BTPairingAgentLocalOOBDataReadyCallback will be called with the local
 * confirm and random number.
 *
 * @param agent the pairing agent
 * @return <code>BT_SUCCESS</code> on success, or <code>BT_ERROR_*</code> otherwise
 */
BTResult BTPairingAgentGetLocalOOBData(BTPairingAgent agent);

#ifdef __cplusplus
} /* extern "C" */
#endif /* __cplusplus */

/**@}*/

#endif /* BT_PAIRING_H_ */
