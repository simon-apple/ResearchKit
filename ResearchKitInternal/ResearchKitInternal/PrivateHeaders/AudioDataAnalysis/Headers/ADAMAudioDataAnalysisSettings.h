//
//  ADAMAudioDataAnalysisSettings.h
//  AudioDataAnalysis
//
//  Created by Eric Zhang on 1/31/20.
//

#pragma once
#import "ADAMAudioDataAnalysisDefines.h"
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
// 
// // if any of the settings are updated, the darwin notification is sent by the framework
// // instead of calling "getPreferenceFor" everytime, register a darwin notification with this key and query only when notified
// ADAM_EXTERN NSString* const ADAFDarwinNotificationKey; // NSString
// ADAM_EXTERN NSString* const ADAFDarwinNotificationKeyNano;
// ADAM_EXTERN NSString* const ADAFDarwinNotificationKeyUnknownWiredDeviceStatusChanged;
// ADAM_EXTERN NSString* const ADAFDarwinNotificationKeyClearAllAdapters;
// ADAM_EXTERN NSString* const ADAFDarwinNotificationKeyVolumeLimitStatusDidChange;
// ADAM_EXTERN NSString* const ADAFDarwinNotificationKeyDeviceDataDispositionDidChange;
// ADAM_EXTERN NSString* const ADAFDarwinNotificationKeyRLSStatusDidChange;
// ADAM_EXTERN NSString* const ADAFDarwinNotificationKeyHAENKnownAccessoriesDidChange;
// 
// 
// #pragma mark *** AudioDataAnalysis Framework Settings Keys ***
// 
// ADAM_EXTERN NSString* const ADAFPreferenceDomain; // com.apple.coreaudio
// ADAM_EXTERN NSString* const ADAFDeviceSpecificPreferenceDomain;
// 
// #pragma mark *** Volume Limit Settings ***
ADAM_EXTERN ADAFPreferenceKey const ADAFPreferenceKeyVolumeLimitEnabled; // NSNumber

ADAM_EXTERN ADAFPreferenceKey const ADAFPreferenceKeyVolumeLimitThreshold; // NSNumber, dBA level
// 
// ADAM_EXTERN ADAFPreferenceKey const ADAFPreferenceKeyLoudnessCompensationEnabled; // NSNumber
// 
// 
// 
// #pragma mark *** Headphone Audio Exposure Settings ***
// /**
// @constant ADAFPreferenceKeyHAEEnableHKWrite
// @discussion
//     if the key is set true, HAE measurement is turned on and results are saved in healthkit
// */
// ADAM_EXTERN ADAFPreferenceKey const ADAFPreferenceKeyHAEEnableHKWrite; // NSNumber
// 
ADAM_EXTERN ADAFPreferenceKey const ADAFPreferenceKeyHAEEnableOtherDevices; // NSNumber
// 
// #pragma mark *** HAE Notification Settings ***
// /**
// @constant ADAFPreferenceKeyHAENotificationIsMandatory
// @discussion
//     if the key is set true, HAE Notifcations feature is mandatory for this device
//     if the key is set to false or does not exists, HAE Notifcations feature is not mandatory for the region and is opt out by the user
// */
// ADAM_EXTERN ADAFPreferenceKey const ADAFPreferenceKeyHAENotificationIsMandatory; // NSNumber
// 
// /**
// @constant ADAFPreferenceKeyHAENotificationFeatureEnabled
// @discussion
//     if the key ADAFPreferenceKeyHAENotificationIsMandatory is true, this key is not relevant, the feature should always be enabled
//     if the key is set true, HAE Notifcations feature is enabled by opt-in
//     if the HAE measurement toggle is turned off, this key will automatically be set to false. 
// */
ADAM_EXTERN ADAFPreferenceKey const ADAFPreferenceKeyHAENotificationFeatureEnabled; // NSNumber
// ADAM_EXTERN ADAFPreferenceKey const ADAFPreferenceKeyHAENotificationVolumeReductionEnabled API_DEPRECATED_WITH_REPLACEMENT("ADAFPreferenceKeyHAENotificationFeatureEnabled", ios(14.0,14.0), watchos(7.0,7.0));
// 
// /**
// @constant ADAFPreferenceKeyHAESampleTransient
// @discussion
//     if the key is set true, the associated HAE sample should be pruned after 8 days
//     if false or does not exist, the sample should not be pruned
// */
// ADAM_EXTERN ADAFPreferenceKey const ADAFPreferenceKeyHAESampleTransient; // NSNumber
// 
// /**
//  @constant ADAFPreferenceKeyConnectedWiredDeviceIsHeadphone
//  @discussion
//     if the key is set true, the connected device is a wired unknown headphone
//     if false, the connected device is a wired speaker
//     if the key does not exists, it's a known device or wireless connection
//  */
// ADAM_EXTERN ADAFPreferenceKey const ADAFPreferenceKeyConnectedWiredDeviceIsHeadphone; // NSNumber
// 
// /**
// @constant ADAFPreferenceKeyVolumeReductionDelta
// @discussion
//         The volume reduction in single step for HAE notification, default value is 1 volume click 0.0625
// */
// ADAM_EXTERN ADAFPreferenceKey const ADAFPreferenceKeyVolumeReductionDelta; // NSNumber
// 
// /**
// @constant ADAFPreferenceKeyHAENKnownAccessories
// @discussion
//     If present, this key contains a dictionary that remembers user's selection of wired unknown accessory types.
// */
// ADAM_EXTERN ADAFPreferenceKey const ADAFPreferenceKeyHAENKnownAccessories; // NSDictionary
// 
// /**
// @constant ADAFPreferenceKeyHAENKnownAccessoryExpiryDays
// @discussion
//     number of days to re-surface to alert box for user to reset the types of unknown wired device, default is 7 days
// */
// ADAM_EXTERN ADAFPreferenceKey const ADAFPreferenceKeyHAENKnownAccessoryExpiryDays; // NSNumber
// 
// ADAM_EXTERN ADAFPreferenceKey const ADAFPreferenceKeyHAENotificationLiveThreshold; // do not use
// 
// ADAM_EXTERN ADAFPreferenceKey const ADAFPreferenceKeyHAENotificationLiveWindowInSeconds; // NSNumber
// 
// 
// #pragma mark *** HAE Notification Location Gating Settings ***
// /**
// @constant ADAFDeviceDispositionKeyErase
// @discussion
//         The current OS is a fresh install (either a newly purchased device or a device after 'erase all contents and settings')
//         Associated with domain ADAFDeviceSpecificPreferenceDomain
// */
// ADAM_EXTERN NSString* const ADAFDeviceDispositionKeyErase;
// /**
// @constant ADAFDeviceDispositionKeyUpdate
// @discussion
//         The current OS is updated from an older version
//         Associated with domain ADAFDeviceSpecificPreferenceDomain
// */
// ADAM_EXTERN NSString* const ADAFDeviceDispositionKeyUpdate;
// 
// /**
// @constant ADAFPreferenceKeyHAENDeviceDisposition
// @discussion
//         This key indicates if the device is a fresh install of the current OS or an update from a previous version of OS
//         It's one of the value in ADAFDeviceDispositionKeyErase or ADAFDeviceDispositionKeyUpdate
//         Associated with domain ADAFDeviceSpecificPreferenceDomain
// */
// ADAM_EXTERN ADAFPreferenceKey const ADAFPreferenceKeyHAENDeviceDisposition; // NSString
// 
// /**
// @constant ADAFPreferenceKeyHAENDeviceCountryCodeOverride
// @discussion
//         The two character Country Code that overrides the country code from GeoServices
// */
// ADAM_EXTERN ADAFPreferenceKey const ADAFPreferenceKeyHAENDeviceCountryCodeOverride; // NSString
// 
// /**
// @constant ADAFPreferenceKeyHAENDeviceProductTypeOverride
// @discussion
//         Override the product type returned from MobileGestalt, for QA testing use only
// */
// ADAM_EXTERN ADAFPreferenceKey const ADAFPreferenceKeyHAENDeviceProductTypeOverride; // NSString
// 
// /**
// @constant ADAFPreferenceKeyHAENVolumeLimitOn
// @discussion
//     If set to true, MX should turn on 100dB volume limit on wired connections
//     can register notification using key: ADAFDarwinNotificationKeyVolumeLimitStatusDidChange
// */
// ADAM_EXTERN ADAFPreferenceKey const ADAFPreferenceKeyMXVolumeLimitOn; // NSNumber
// 
// 
// 
// #pragma mark *** AudioDataAnalysis Framework Settings Error Code ***
// 
// ADAM_EXTERN ADAFErrorCode const ADAFErrorUnknownPreferenceKey;
// 
// ADAM_EXTERN ADAFErrorCode const ADAFErrorInvalidPreferenceValue;
// 
// ADAM_EXTERN ADAFErrorCode const ADAFErrorNanoSettingsUnavailable;
// 
// 
// 
//  
#pragma mark *** ADASManager Interface ***
ADAM_EXTERN
@interface ADASManager : NSObject
-(instancetype) init;
// 
// -(BOOL)nanoSettingsAvailable;
// 
// // update
// -(nullable NSError*)setPreferenceFor:(ADAFPreferenceKey)key value:(id)val; /// notify == YES
// 
// -(nullable NSError*)setPreferenceFor:(ADAFPreferenceKey)key value:(id)val notify:(BOOL)notify;
// 
// -(nullable NSError*)setNanoPreferenceFor:(ADAFPreferenceKey)key value:(id)val; /// notify == YES
// 
// -(nullable NSError*)setNanoPreferenceFor:(ADAFPreferenceKey)key value:(NSNumber*)val notify:(BOOL)notify;
// 
// // query
// -(nullable id)getPreferenceFor:(ADAFPreferenceKey)key;
// 
// -(nullable id)getNanoPreferenceFor:(ADAFPreferenceKey)key;
// 
-(nullable NSDictionary*)getPreferencesFor:(NSArray<ADAFPreferenceKey> *)keys;
// 
// -(nullable NSDictionary*)getNanoPreferencesFor:(NSArray<ADAFPreferenceKey> *)keys;
// 
// // remove
// -(void)removePreferenceFor:(ADAFPreferenceKey)key; /// notify == YES
// 
// -(void)removePreferenceFor:(ADAFPreferenceKey)key notify:(BOOL)notify;
// 
// -(void)removeNanoPreferenceFor:(ADAFPreferenceKey)key; /// notify == YES
// 
// -(void)removeNanoPreferenceFor:(ADAFPreferenceKey)key notify:(BOOL)notify;
// 
// // methods for hae notification migration alert
// -(void)migrateKeyEnableHAEHKMeasurement:(BOOL)isNano;
// -(BOOL)shouldSufaceHAENotificationMigrationAlert;
// -(void)didSurfaceMigrationAlert;
@end
NS_ASSUME_NONNULL_END
