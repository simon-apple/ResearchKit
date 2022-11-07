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
 *      Bluetooth service keys.
 *
 */

/**
 * @file BTServiceKeys.h
 * This file contains defines for Service Keys.
 */
#ifndef BT_SERVICE_KEYS_H_
#define BT_SERVICE_KEYS_H_	1

/** \addtogroup BTDev Device APIs */
/**@{*/

#ifdef __cplusplus
extern "C" {
#endif /* __cplusplus */

#include "BTTypes.h"

/**@}*/


/** Initiate a HID cable unplug */
#define BT_KEY_HID_VIRTUAL_CABLE_UNPLUG	"BT_KEY_HID_VIRTUAL_CABLE_UNPLUG"

#define BT_KEY_HFP_AG_ECNR_STATE		"BT_KEY_HFP_AG_ECNR_STATE"


/* MAP enabled keys. */
#define BT_KEY_MAP_ENABLED			"BT_KEY_MAP_ENABLED"
#define BT_VALUE_MAP_ENABLED		"BT_VALUE_MAP_ENABLED"
#define BT_VALUE_MAP_DISABLED		"BT_VALUE_MAP_DISABLED"

/* SIRI related keys */
#define BT_KEY_SIRI_EYESFREE_MODE	"BT_KEY_SIRI_EYESFREE_MODE"
#define BT_KEY_SIRI_AUDIO_STATE		"BT_KEY_SIRI_AUDIO_STATE"

/* Navigation related keys */
#define BT_KEY_ALLOW_SCO_FOR_TBT	"BT_KEY_ALLOW_SCO_FOR_TBT"

#ifdef __cplusplus
} /* extern "C" */
#endif /* __cplusplus */

/**@}*/

#endif /* BT_SERVICE_KEYS_H_ */

