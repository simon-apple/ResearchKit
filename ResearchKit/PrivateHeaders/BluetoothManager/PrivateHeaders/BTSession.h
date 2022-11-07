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
 *      Bluetooth session functions.
 *
 */

/**
 * @file BTSession.h
 * This file contains Bluetooth session APIs.
 */
#ifndef BT_SESSION_H_
#define BT_SESSION_H_

/** \addtogroup BTTypes Core Types */
/**@{*/

#ifdef __cplusplus
extern "C" {
#endif /* __cplusplus */

#include "BTTypes.h"
#include "BTResult.h"
#ifdef __APPLE__
#include <dispatch/dispatch.h>
#include <CoreFoundation/CFRunLoop.h>
#endif

typedef enum {
	BT_SESSION_ATTACHED,
	BT_SESSION_DETACHED,
	BT_SESSION_TERMINATED,
	BT_SESSION_FAILED
} BTSessionEvent;

 /**
 * @brief Callback invoked when the session state has changed.
 *
 * Here are the possible event/result pairs and their meaning:
 * - BT_SESSION_ATTACHED / BT_SUCCESS:
 *		A session has been successfully created as a result of calling BTSessionAttachWithQueue().
 *		The BTSession handle is passed in the callback and all MobileBluetooth APIs are now usable.
 * - BT_SESSION_ATTACHED / BT_ERROR_*:
 *		A session has failed to be created as a result of calling BTSessionAttachWithQueue().
 *		The client may try to re-attach by calling BTSessionAttachWithQueue() again.
 * - BT_SESSION_DETACHED / *:
 *		The session has been completely detached as a result of calling BTSessionDetachWithQueue().
 *		The client can use that event as a finalizer and release any corresponding resources.
 *		The BTSession handle is passed in the callback for comparison purposes, but is invalid and must not be accessed.
 * - BT_SESSION_TERMINATED / *:
 *		The session has been severed, usually due a crash of the Bluetooth daemon.
 *		The BTSession handle is passed in the callback for comparison purposes, but is invalid and must not be accessed.
 *
 * @param session the session handle
 * @param event the session event
 * @param result the result code
 * @param userData User data pointer
 * @see BTSessionAttach
 */
typedef void (*BTSessionEventCallback)(BTSession session, BTSessionEvent event, BTResult result, void* userData);

typedef struct {
	BTSessionEventCallback sessionEvent;
} BTSessionCallbacks;

#ifdef __APPLE__

BTResult BTSessionAttachWithRunLoopAsync(CFRunLoopRef runloop, const char *name, const BTSessionCallbacks *callbacks, void *userData) CF_DEPRECATED_IOS(2_0, 8_1, "Use BTSessionAttachWithQueue() instead");

BTResult BTSessionDetachWithRunLoopAsync(CFRunLoopRef runloop, BTSession* session) CF_DEPRECATED_IOS(2_0, 8_1, "Deprecated") CF_DEPRECATED_IOS(2_0, 8_1, "Use BTSessionDetachWithQueue() instead");

/**
 * @brief Attaches a Bluetooth session.
 *
 * This function performs any system specific service discovery to find
 * the bluetooth server and sets up any system specific resources for
 * communicating with the server. The handle returned is used in many
 * other API calls to uniquely identify the live session.
 * This function is asynchronous (non blocking); If it is called when
 * the server is not running, it will wait for it to start before
 * attaching. The session is returned in the callback with the event
 * BT_SESSION_ATTACHED.
 *
 * @param name A unique identifier for the session (eg "com.example.foo.app"), must not be <code>NULL</code>
 * @param callbacks The callback structure
 * @param userData User data pointer
 * @param queue Dispatch queue to use for callbacks
 * @return <code>BT_SUCCESS</code> on success, or <code>BT_ERROR_*</code> otherwise
 */
BTResult BTSessionAttachWithQueue(const char *name, const BTSessionCallbacks *callbacks, void *userData, dispatch_queue_t queue);

/**
 * @brief Detaches a Bluetooth session.
 *
 * This function tears down a session (and its associated ressources)
 * with the bluetooth server. When finished it destroys the handle and
 * sets it to <code>NULL</code>.
 *
 * @param session Pointer to the handle previously returned by the @ref BTSessionCallbacks that were passed to @ref BTSessionAttachWithQueue()
 * @return <code>BT_SUCCESS</code> on success, or <code>BT_ERROR_*</code> otherwise
 */
BTResult BTSessionDetachWithQueue(BTSession *session);

#endif

#ifdef __cplusplus
} /* extern "C" */
#endif /* __cplusplus */

/**@}*/

#endif /* BT_SESSION_H_ */
