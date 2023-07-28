//#if (defined(USE_UIKIT_PUBLIC_HEADERS) && USE_UIKIT_PUBLIC_HEADERS) || !__has_include(<UIKitCore/UIWindowScene_Private.h>)
//
//  UIWindowScene_Private.h
//  UIKit
//
//  Copyright © 2019 Apple Inc. All rights reserved.
//

#import <UIKit/UIWindowScene.h>
//#import "UIScene_Private.h"
//#import <UIKit/UIScene_UIWindowEventRouting.h>
//#import <UIKit/UIKitDefines_Private.h>
//#import <UIKit/UIApplication_Private.h>
//#import <UIKit/_UIInvalidatable.h>
//
//NS_HEADER_AUDIT_BEGIN(nullability, sendability)
//
//@protocol _UIWindowSceneComponentProviding;
//
//UIKIT_EXTERN UISceneSessionRole const _UIWindowSceneSessionRoleCarPlay SPI_AVAILABLE(ios(13.0));
//UIKIT_EXTERN UISceneSessionRole const _UIWindowSceneSessionTypeCoverSheet SPI_AVAILABLE(ios(13.0));
//UIKIT_EXTERN UISceneSessionRole const _UICHWindowSceneSessionRoleAvocado SPI_AVAILABLE(ios(14.0));
//
//// ClarityUI is an accessibility feature that provides an alternate, simplified UI, optimized for people with cognitive disabilities.
//// The following role allows UIKit apps with the Info.plist key UISupportsClarityUI = YES to provide an appropriate interface when ClarityUI is enabled.
//UIKIT_EXTERN UISceneSessionRole const _UIWindowSceneSessionRoleSimplifiedApplication SPI_AVAILABLE(ios(16.0));
//
//@protocol UIActivityItemsConfigurationReading;
//@protocol UIActivityItemsConfigurationProviding_Private;
//
//#if UIKIT_MACCATALYST
//@protocol UINSWindow;
//#endif
//
@interface UIWindowScene ()/* <_UISceneUIWindowHosting, _UISceneUIWindowEventRouting>*/
//@property (nonatomic, assign) BOOL _isKeyWindowScene;
//// SPI and potential API to control whether the scene appears in UIWindowMenu.
//@property (nonatomic, assign, getter=isExcludedFromWindowsMenu) BOOL excludedFromWindowsMenu SPI_AVAILABLE(ios(14.0));
//@property (nonatomic, setter=_setBackgroundStyle:) UIBackgroundStyle _backgroundStyle SPI_AVAILABLE(ios(13.0));
//@property (nonatomic, assign, getter=_keepContextAssociationInBackground, setter=_setKeepContextAssociationInBackground:) BOOL keepContextAssociationInBackground SPI_AVAILABLE(ios(13.0));
//
//@property (nonatomic, readonly) BOOL _isPerformingSystemSnapshot;
//
//// SPI so apps can request progress is shown for handoff user activities if they take a while to fetch
//- (void)_showProgressWhenFetchingUserActivityForTypes:(NSSet<NSString *>*)activityTypes;

// Allow volume HUD to appear in this scene. If category is nil, will apply to all categories.
- (void)_setSystemVolumeHUDEnabled:(BOOL)enabled forAudioCategory:(nullable NSString *)category;
// calls setSystemVolumeHUDEnabled:forAudioCategory: with a nil category
- (void)_setSystemVolumeHUDEnabled:(BOOL)enabled;
//
//// Allow reachability to be activated in this scene
//- (void)_setReachabilitySupported:(BOOL)supported forReason:(NSString *)reason;
//
//- (void)_componentDidUpdateTraitOverrides:(id<_UIWindowSceneComponentProviding>)component;
//
//#pragma mark - Activity Items Configuration
//
///// An optional object used as a source of scene-level activity items configuration
/////
///// If this property is @nil, the @c activityItemsConfiguration property of the most-presented view controller
///// of the scene's key window will be used for scene-level sharing and activities.
//@property (nonatomic, nullable, setter=_setActivityItemsConfigurationSource:, weak) id<UIActivityItemsConfigurationProviding> _activityItemsConfigurationSource API_DEPRECATED_WITH_REPLACEMENT("activityItemsConfigurationSource", ios(15.0, 15.0)) SPI_AVAILABLE(watchos(8.0)) API_UNAVAILABLE(tvos);
//
///// The effective activity items configuration for this window scene
//@property (nonatomic, readonly, nullable, strong) id<UIActivityItemsConfigurationReading> _activityItemsConfiguration API_AVAILABLE(ios(15.0), watchos(8.0)) API_UNAVAILABLE(tvos);
//
//#pragma mark - Live Resize
//// Future API
//
//#if UIKIT_MACCATALYST || UIKIT_SUPPORTS_IOS_ENHANCED_WINDOWING
//@property (nonatomic, readonly, getter=_isInLiveResize) BOOL _inLiveResize;
//#endif
//
//#if UIKIT_MACCATALYST
//@property (nonatomic, nullable, weak, setter=_setUINSWindowProxy:) id<UINSWindow> _UINSWindowProxy;
//#endif
//
//// Call this method to hold the live resize snapshot while performing an asynchronous task
//// The snapshot will be held until the object returned by this method is invalidated
//// The object must be invalidated on the main thread
//- (id<_UIInvalidatable>)_holdLiveResizeSnapshotForReason:(NSString *)reason;
//
///// Returns `YES` if the scene will consult view controllers for supported orientations when orienting the scene.
///// @warning This is not intended to be overridden.
//@property (nonatomic, readonly) BOOL _canDynamicallySpecifySupportedInterfaceOrientations;
//
//// Returns a string useful in debugging orientation issues.
//- (NSString *)_orientationDebugDescription;
//
//// Access the windowingBehaviors object for internal use, without lazy-instantiating it as the public accessor does.
//- (nullable UISceneWindowingBehaviors *)_windowingBehaviorsNotInstantiating;

@end
//
//#if UIKIT_MACCATALYST
//@interface UISceneSizeRestrictions () // note: this interface is mirrored in UINSSceneSizeRestrictions
//- (void)_updateCompatibleSizeRestrictions;
//- (void)_setMinimumSizeForScreen:(CGSize)minimumSizeForScreen;
//
//@property (nonatomic, assign, setter=_setContentSize:) CGSize  _contentSize API_AVAILABLE(macCatalyst(16.0));
//@property (nonatomic, assign, setter=_setWindowOrigin:) CGPoint _windowOrigin API_AVAILABLE(macCatalyst(16.0));
//
//@end
//#endif
//
//// TODO: rdar://73679734 (Consider ordering of _UIWindowSceneComponentProviding trait overrides)
//// We need to find a way to order this properly and disambiguate if multiple components want to override the same trait.
//// This might change the behavior of your component implementing this method.
//@protocol _UIWindowSceneComponentProviding <_UIWindowHostingSceneComponentProviding>
//
//@optional
//@property (nullable, nonatomic, readonly) UITraitCollection *_traitOverrides;
//
//@end
//
//#if UIKIT_MACCATALYST || UIKIT_SUPPORTS_IOS_ENHANCED_WINDOWING
//UIKIT_EXTERN NSNotificationName const _UIWindowSceneDidBeginLiveResizeNotification API_AVAILABLE(ios(15.0)) API_UNAVAILABLE(tvos, watchos);
//UIKIT_EXTERN NSNotificationName const _UIWindowSceneDidEndLiveResizeNotification API_AVAILABLE(ios(15.0)) API_UNAVAILABLE(tvos, watchos);
//#endif
//
//NS_HEADER_AUDIT_END(nullability, sendability)
//
//#else
//#import <UIKitCore/UIWindowScene_Private.h>
//#endif
