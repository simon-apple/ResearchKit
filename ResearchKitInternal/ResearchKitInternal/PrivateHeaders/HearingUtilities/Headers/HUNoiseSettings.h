//
//  HUNoiseSettings.h
//  HearingUtilities
//
//  Created by Ian Fisch on 1/11/19.
//  Copyright © 2019 Apple Inc. All rights reserved.
//

// #import "HearingUtilities.h"

#if HAS_ENVIRONMENTAL_DOSIMETRY_SUPPORT

NS_ASSUME_NONNULL_BEGIN

#define HUNoiseCurrentThresholdVersion  1

@interface HUNoiseSettings : NSObject

+ (HUNoiseSettings *)sharedInstance;

// - (void)registerUpdateBlock:(__nullable AXBasicBlock)block forRetrieveSelector:(SEL)selector withListener:(id)listener;
// 
// - (BOOL)preferenceIsSetForRetrieveSelector:(SEL)selector;
// - (NSString *)notificationForPreferenceKey:(NSString *)preferenceKey;
// - (NSString *)notificationForNoiseEnabled;

@property(nonatomic, assign) BOOL noiseEnabled;
// @property(nonatomic, assign) BOOL onboardingCompleted;
// 
@property(nonatomic, assign) BOOL notificationsEnabled;
@property(nonatomic, assign) NSUInteger notificationThreshold;
// @property(nonatomic, strong, nullable) NSDate *notificationMuteDate; // the point in the future when notifications should work again
// 
// @property(nonatomic, assign) CGFloat currentLeq;
// @property(nonatomic, strong) NSDate *leqTimestamp;
// @property(nonatomic, assign) NSTimeInterval leqDuration;
// 
// // Internal
// @property(nonatomic, assign) BOOL migratedThreshold;
// @property(nonatomic, assign) NSUInteger thresholdVersion;
// 
// @property(nonatomic, assign) BOOL internalLoggingEnabled;
// 
// @property (nonatomic, readonly) NSString *launchNoiseOnboardingTitle;
// @property (nonatomic, readonly) NSString *environmentalMeasurementsTitleDescription;
// @property (nonatomic, readonly) NSString *environmentalMeasurementsFooterDescription;
// @property (nonatomic, readonly) NSString *noiseThresholdSectionTitle;
// @property (nonatomic, readonly) NSString *noiseThresholdTitleDescription;
// 
// // Will include NSLinkAttributeName that points to the URL
// @property (nonatomic, readonly) NSAttributedString *noiseThresholdFooterDescriptionWithLink;
// 
// // The link title will part of the description. You can scan the string and annotate with the URL when needed.
// @property (nonatomic, readonly) NSString *noiseThresholdFooterDescription;
// @property (nonatomic, readonly) NSString *noiseThresholdFooterLinkTitle;
// @property (nonatomic, readonly) NSURL *noiseThresholdFooterLinkURL;
// 
// @property (nonatomic, readonly) NSString *noiseThresholdValueFooterDescription;
// 
// @property (nonatomic, readonly) NSInteger noiseThresholdMinutesThreshold;
// @property (nonatomic, readonly) NSInteger noiseThresholdCurrentValue;
// @property (nonatomic, readonly) NSArray<NSNumber *> *noiseThresholdOptions;
// 
// - (NSString *)localizedNoiseThresholdValue:(NSInteger)value;
// - (NSString *)localizedNoiseThresholdDetailValue:(NSInteger)value;
// 
// // Testing
// @property(nonatomic, strong, null_resettable) NSNumber *notificationsEnabledOverride;
// @property(nonatomic, strong, null_resettable) NSNumber *notificationsThreshholdOverride;


@end

NS_ASSUME_NONNULL_END


#endif
