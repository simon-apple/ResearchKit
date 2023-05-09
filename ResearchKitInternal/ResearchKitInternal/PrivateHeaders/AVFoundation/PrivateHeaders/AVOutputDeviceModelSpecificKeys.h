/*
	File:  AVOutputDeviceModelSpecificKeys.h
 
	Framework:  AVFoundation
 
	Copyright 2016-2019 Apple Inc. All rights reserved.
 
 */

typedef NSString * AVOutputDeviceModelSpecificKey NS_STRING_ENUM;

AVF_EXPORT AVOutputDeviceModelSpecificKey const AVOutputDeviceBatteryLevelCaseKey SPI_AVAILABLE(macos(10.12), ios(11.0), tvos(11.0), watchos(4.0)); /* NSNumber float 0.0-1.0 */
AVF_EXPORT AVOutputDeviceModelSpecificKey const AVOutputDeviceBatteryLevelLeftKey SPI_AVAILABLE(macos(10.12), ios(11.0), tvos(11.0), watchos(4.0)); /* NSNumber float 0.0-1.0 */
AVF_EXPORT AVOutputDeviceModelSpecificKey const AVOutputDeviceBatteryLevelRightKey SPI_AVAILABLE(macos(10.12), ios(11.0), tvos(11.0), watchos(4.0)); /* NSNumber float 0.0-1.0 */

/*!
  @constant	AVOutputDeviceSupportsDataOverACLProtocolKey
          A key whose value indicates whether the output device supports the Data over ACL Protocol. This setting applies only to devices supporting Advanced Audio Distribution Profile (A2DP) ports.
  @constant	AVOutputDeviceIsInEarKey
           A key whose value indicates whether the output device is in ear.
*/
#if !RC_HIDE_B288
AVF_EXPORT AVOutputDeviceModelSpecificKey const AVOutputDeviceSupportsDataOverACLProtocolKey SPI_AVAILABLE(macos(10.15), ios(13.0), tvos(13.0), watchos(6.0)); /* NSNumber bool */
#endif // RC_HIDE_B288
AVF_EXPORT AVOutputDeviceModelSpecificKey const AVOutputDeviceIsInEarKey SPI_AVAILABLE(macos(10.15), ios(13.0), tvos(13.0), watchos(6.0)); /* NSNumber bool */
