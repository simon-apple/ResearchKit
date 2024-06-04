// //
// //  ADAMAudioDataAnalysisDefines.h
// //  AudioDSP-Aspen
// //
// //  Created by Eric Zhang on 10/31/18.
// //
#pragma once
#import <Foundation/Foundation.h>
// #import <AudioDataAnalysis/ADAMAudioDataAnalysisTypes.h>
// 
#if !defined(__cplusplus)
#define ADAM_EXTERN extern __attribute__((visibility("default")))
#else
#define ADAM_EXTERN extern "C" __attribute__((visibility("default")))
#endif
// 
// #define kAudioDataAnalysisManagerServiceName @"com.apple.audio.adam.xpc"
// 
// typedef enum ADAMXPCErrorCode : uint32_t
// {
//     kADAMXPCError_NoError = 0,
//     kADAMXPCError_MissingEntitlements = '!ent',
//     kADAMXPCError_ConnectionInvalid   = '!cni',
//     kADAMXPCError_UnknownClientName   = 'uknn',
//     kADAMXPCError_DataTypeDoesNotSupportONOFF = '!onf',
// } ADAMXPCErrorCode;
// 
// ADAM_EXTERN const ADAMEnvironmentalDosageConfigType ADAMEnvConfigKeys[];
// 
// #pragma mark -- AudioDataAnalysis Framework Metadata Keys
// typedef NSString * ADAFMetadataKey NS_STRING_ENUM;
// 
// ADAM_EXTERN ADAFMetadataKey const ADAFMetadataKeyIsLoud; // BOOL
// 
// ADAM_EXTERN ADAFMetadataKey const ADAFMetadataKeyDeviceID; // NSString
// 
// ADAM_EXTERN ADAFMetadataKey const ADAFMetadataKeyHAEDataForGauge; // NSString
// 
typedef NSString * ADAFPreferenceKey NS_STRING_ENUM;
// 
// #pragma mark -- AudioDataAnalysis Error Code
// ADAM_EXTERN NSErrorDomain const ADAFErrorDomain;
// 
// typedef NSInteger ADAFErrorCode;
// 
