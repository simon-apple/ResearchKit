/*
 Copyright (c) 2023, Apple Inc. All rights reserved.
 
 Redistribution and use in source and binary forms, with or without modification,
 are permitted provided that the following conditions are met:
 
 1.  Redistributions of source code must retain the above copyright notice, this
 list of conditions and the following disclaimer.
 
 2.  Redistributions in binary form must reproduce the above copyright notice,
 this list of conditions and the following disclaimer in the documentation and/or
 other materials provided with the distribution.
 
 3.  Neither the name of the copyright holder(s) nor the names of any contributors
 may be used to endorse or promote products derived from this software without
 specific prior written permission. No license is granted to the trademarks of
 the copyright holders even if such marks are included in this software.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
 FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

@import Foundation;
@import UIKit;

#if TARGET_OS_WATCH
#import <ResearchKitCore/ORKDefines.h>
#elif TARGET_OS_IOS
#import <ResearchKit/ORKDefines.h>
#endif

NS_ASSUME_NONNULL_BEGIN

/**
 Route Identifiers for supported headphones chipset types.
 */
typedef NSString * ORKHeadphoneChipsetIdentifier NS_STRING_ENUM;

ORK_EXTERN ORKHeadphoneChipsetIdentifier const ORKHeadphoneChipsetIdentifierAirPods;
ORK_EXTERN ORKHeadphoneChipsetIdentifier const ORKHeadphoneChipsetIdentifierLightningEarPods;
ORK_EXTERN ORKHeadphoneChipsetIdentifier const ORKHeadphoneChipsetIdentifierAudioJackEarPods;

/**
 Type Identifiers for supported headphones vendor and product id types.
 */
typedef NSString * ORKHeadphoneVendorAndProductIdIdentifier NS_STRING_ENUM;
ORK_EXTERN ORKHeadphoneVendorAndProductIdIdentifier const ORKHeadphoneVendorAndProductIdIdentifierAirPodsGen1;
ORK_EXTERN ORKHeadphoneVendorAndProductIdIdentifier const ORKHeadphoneVendorAndProductIdIdentifierAirPodsGen2;
ORK_EXTERN ORKHeadphoneVendorAndProductIdIdentifier const ORKHeadphoneVendorAndProductIdIdentifierAirPodsGen3;
ORK_EXTERN ORKHeadphoneVendorAndProductIdIdentifier const ORKHeadphoneVendorAndProductIdIdentifierAirPodsPro;
ORK_EXTERN ORKHeadphoneVendorAndProductIdIdentifier const ORKHeadphoneVendorAndProductIdIdentifierAirPodsProGen2;
ORK_EXTERN ORKHeadphoneVendorAndProductIdIdentifier const ORKHeadphoneVendorAndProductIdIdentifierAirPodsProGen2USBC;
ORK_EXTERN ORKHeadphoneVendorAndProductIdIdentifier const ORKHeadphoneVendorAndProductIdIdentifierAirPodsMax;

/**
 An enumeration of the types of available blutooth modes
 */
typedef NS_ENUM(NSInteger, ORKBluetoothMode) {
    ORKBluetoothModeNone,
    ORKBluetoothModeNormal,
    ORKBluetoothModeTransparency,
    ORKBluetoothModeNoiseCancellation
} ORK_ENUM_AVAILABLE;

NS_ASSUME_NONNULL_END
