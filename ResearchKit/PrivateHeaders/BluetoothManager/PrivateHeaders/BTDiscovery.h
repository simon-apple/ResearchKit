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
 *      Bluetooth discovery functions.
 *
 */

/**
 * @file BTDiscovery.h
 * This file contains APIs for Bluetooth device discovery.
 */
#ifndef BT_DISCOVERY_H_
#define BT_DISCOVERY_H_

/** \addtogroup BTDisc Discovery APIs */
/**@{*/

#ifdef __cplusplus
extern "C" {
#endif /* __cplusplus */

#include "BTDevice.h"
#include "BTTypes.h"

/** Discovery Mode */
typedef enum
{
	/** One-time. The discovery agent will perform an initial scan and then stop. */
	BT_DISCOVERY_MODE_ONETIME,
	/** Continuous. The discovery agent will scan continuously until cancelled. */
	BT_DISCOVERY_MODE_CONTINUOUS,
	/** Periodic. The discovery agent will scan periodically until cancelled. */
	BT_DISCOVERY_MODE_PERIODIC,
	/** Periodic, while wifi is associated. The discovery agent will scan periodically until cancelled. */
	BT_DISCOVERY_MODE_PERIODIC_WIFI,
	/** Checks if the paired devices are in range. */
	BT_DISCOVERY_MODE_IN_RANGE
} BTDiscoveryMode;


/** Allows sensor scans only */
#define BT_SCAN_SHOE		BIT1
/** Allows remote scan only */
#define BT_SCAN_REMOTE		BIT2
/** Allows remote scan only */
#define BT_SCAN_HRM			BIT3
/** Will scan for shoe sensor then remotes */
#define BT_SCAN_ALL_SENSORS	0xFFFFFFFF


typedef enum {
	BT_DISCOVERY_SCAN_STARTED,
	BT_DISCOVERY_SCAN_STOPPED,
    BT_DISCOVERY_QUERY_STARTED,
    BT_DISCOVERY_QUERY_STOPPED,
} BTDiscoveryStatus;

typedef enum {
    BT_DISCOVERY_DEVICE_FOUND,
    BT_DISCOVERY_DEVICE_LOST,
    BT_DISCOVERY_DEVICE_CHANGED
} BTDiscoveryEvent;

/** @brief Callback invoked when a discovery scan has started or stopped, or a query has started or stopped.
 *
 * @param agent the discovery agent
 * @param status the discovery status
 * @param device the device associated with this status, or <code>BT_DEVICE_NONE</code>
 * @param result the result code
 * @param userData User data pointer
 */
typedef void (*BTDiscoveryAgentStatusEventCallback)(BTDiscoveryAgent agent, BTDiscoveryStatus status, BTDevice device, BTResult result, void* userData);

/** @brief Callback invoked when a device is found or lost, or device attributes have changed.
 *
 * @param agent the discovery agent
 * @param event the device event
 * @param device the device
 * @param attributes the device attributes
 * @param userData User data pointer
 */
typedef void (*BTDiscoveryAgentDiscoveryEventCallback)(BTDiscoveryAgent agent, BTDiscoveryEvent event, BTDevice device, BTDeviceAttributes attributes, void* userData);

typedef struct {
	BTDiscoveryAgentStatusEventCallback statusEvent;
	BTDiscoveryAgentDiscoveryEventCallback discoveryEvent;
} BTDiscoveryAgentCallbacks;

typedef BTDiscoveryAgentCallbacks*  BTDiscoveryAgentCallbackPointer;

/**
 * @brief Creates a discovery agent.
 *
 * Call @ref BTDiscoveryAgentDestroy to release the object.
 *
 * @param session the bluetooth session handle
 * @param callbacks the callback structure
 * @param userData User data pointer
 * @param agent Place to store the handle on successful completion of function
 * @return <code>BT_SUCCESS</code> on success, or <code>BT_ERROR_*</code> otherwise
 */
BTResult BTDiscoveryAgentCreate(BTSession session, const BTDiscoveryAgentCallbacks* callbacks,
	void* userData, BTDiscoveryAgent* agent);

/**
 * @brief Destroys a previously created discovery agent.
 *
 * When finished it will destroy the handle and set the passed handle to <code>NULL</code>.
 * If a discovery scan is in progress it will be immediately cancelled.
 *
 * @param agent Pointer to the handle previously returned by @ref BTDiscoveryAgentCreate
 * @return <code>BT_SUCCESS</code> on success, or <code>BT_ERROR_*</code> otherwise
 */
BTResult BTDiscoveryAgentDestroy(BTDiscoveryAgent* agent);

/**
 * @brief Starts a device inquiry scan.
 *
 * The discovery agent will schedule its scan frequency according to the discovery mode.
 * NOTE: Passing BT_SERVICE_ALL for the service filter is used for factory testing and can be very slow. Instead, mask the services
 *       together that you are interested in.
 *
 * @param agent the discovery agent
 * @param mode the discovery mode
 * @param serviceFilter the services to filter by
 * @return <code>BT_SUCCESS</code> on success, or <code>BT_ERROR_*</code> otherwise
 */
BTResult BTDiscoveryAgentStartScan(BTDiscoveryAgent agent, BTDiscoveryMode mode, BTServiceMask serviceFilter);


/**
 * @brief Starts a device inquiry scan.
 *
 * @discussion The discovery agent will schedule its scan frequency according to the discovery mode. The returned device's EIR
 *				will match at least one of the services wanted. Those services should be advertized by BTLocalDeviceAdvertiseService.
 *				!!! This will not work on non 2.1 devices !!!
 *
 * @param agent the discovery agent
 * @return <code>BT_SUCCESS</code> on success, or <code>BT_ERROR_*</code> otherwise
 */
BTResult BTDiscoveryAgentStartScanForAdvertizedData(BTDiscoveryAgent agent);


/**
 * @brief Stops an inquiry scan in progress.
 *
 * @param agent the discovery agent
 * @return <code>BT_SUCCESS</code> on success, or <code>BT_ERROR_*</code> otherwise
 */
BTResult BTDiscoveryAgentStopScan(BTDiscoveryAgent agent);

/**
 * @brief Gets list of the devices found during the most recent inquiry scan. Lost devices are not included.
 *
 * @param agent the discovery agent
 * @param deviceArray pointer to array where devices are to be stored
 * @param deviceArraySize pointer to where deviceArray size is to be stored
 * @param deviceArrayMaxSize capacity of the deviceArray
 * @return <code>BT_SUCCESS</code> on success, or <code>BT_ERROR_*</code> otherwise
 */
BTResult BTDiscoveryAgentGetDevices(BTDiscoveryAgent agent, BTDevice* deviceArray, size_t* deviceArraySize, size_t deviceArrayMaxSize);


/**
 * @brief Adds a service to the list of services to match. Only valid on agents that are running BTDiscoveryAgentStartScanForAdvertizedData
 *
 * @param agent the discovery agent
 * @param key The service to add
 * @return <code>BT_SUCCESS</code> on success, or <code>BT_ERROR_*</code> otherwise
 */
BTResult BTDiscoveryAgentAddKey(BTDiscoveryAgent agent, BTData key, size_t keySize);


/**
 * @brief Removes a user service to the list of services to match. Only valid on agents that are running BTDiscoveryAgentStartScanForAdvertizedData
 *
 * @param agent the discovery agent
 * @param key The service to remove
 * @return <code>BT_SUCCESS</code> on success, or <code>BT_ERROR_*</code> otherwise
 */
BTResult BTDiscoveryAgentRemoveKey(BTDiscoveryAgent agent, BTData key, size_t keySize);


#ifdef __cplusplus
} /* extern "C" */
#endif /* __cplusplus */

/**@}*/

#endif /* BT_DISCOVERY_H_ */
