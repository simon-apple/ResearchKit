//
//  AXSettings.h
//  Accessibility
//
//  Created by Chris Fleizach on 9/13/12.
//  Copyright (c) 2012 Apple Inc. All rights reserved.
//

// #import <CoreGraphics/CoreGraphics.h>
// 
// // FIXME: <rdar://problem/59974549> Master out System/Library/PrivateFrameworks/Accessibility.framework from SDKRoot
// // #import <Accessibility/Accessibility.h>
// #import <AccessibilityUtilities/AXSettingsTypes.h>
// #import <AccessibilityUtilities/AXVoiceOverActivity.h>
// #import <AccessibilityUtilities/AXAssistiveTouchSettings.h>
// #import <AccessibilityUtilities/AXUtilitiesCommon.h>
// #import <AccessibilityUtilities/AXForceTouchSettings.h>
// #import <AccessibilityUtilities/AXDevice.h>
// #import <AccessibilitySupport.h>
// #define __ACCESSIBILITY__
// #if HAS_MOTION_TRACKING_SUPPORT
// #import <AccessibilitySharedSupport/AXSSMotionTrackingConstants.h>
// #import <AccessibilitySharedSupport/AXSSMotionTrackingInput.h>
// #endif
// #undef __ACCESSIBILITY__
// 
// @class AXSwitch, AXSwitchRecipe, AVSpeechSynthesisVoice, AXNamedReplayableGesture, AXCustomizableMouse, GAXAppSet, AXSSKeyboardCommandMap, TTSSubstitution;
// 
#pragma mark -
#pragma mark Public interface

// // NOTE: If you use 'self' in the block, it will cause a retain cycle. Make a weakSelf instead
// #define AXSettingsRegisterForUpdates(retrieveSelector, listener, block) { [[AXSettings sharedInstance] registerUpdateBlock:block forRetrieveSelector:@selector(retrieveSelector) withListener:listener]; }
// 
#define AXSharedSettings AXSettings.sharedInstance

AX_EXTERN
@interface AXSettings : AXBaseSettings

@property(nonatomic, class, readonly) AXSettings *sharedInstance;

// - (NSArray<NSString *> *)keysToIgnoreDuringBuddyTransfer;
// 
// #pragma mark -
// #pragma mark AssistiveTouch
// 
// // General
// @property (nonatomic) BOOL assistiveTouchAlwaysShowMenuEnabled;
// @property (nonatomic) BOOL assistiveTouchOpenMenuSwaggleEnabled;
// @property (nonatomic) double assistiveTouchSpeed;
// @property (nonatomic, strong, readonly) NSDictionary<NSString *, NSString *> *assistiveTouchMainScreenDefaultCustomization;
// @property (nonatomic, strong) NSDictionary<NSString *, NSString *> *assistiveTouchMainScreenCustomization;
// - (BOOL)assistiveTouchCustomizationEnabled;
// // Not using Orb on purpose for hiding reasons
// @property (nonatomic, strong) NSString *assistiveTouchOrbAction;
// @property (nonatomic, strong) NSString *assistiveTouchSingleTapAction;
// @property (nonatomic, strong) NSString *assistiveTouchDoubleTapAction;
// @property (nonatomic, strong) NSString *assistiveTouchLongPressAction;
// @property (nonatomic, assign) NSTimeInterval assistiveTouchLongPressActionDuration;
// @property (nonatomic, assign) NSTimeInterval assistiveTouchDoubleTapActionTimeout;
// 
// @property (nonatomic, strong) NSArray<AXNamedReplayableGesture *> *assistiveTouchCustomGestures; // for AssistiveTouch
// @property (nonatomic, strong) NSArray<AXNamedReplayableGesture *> *assistiveTouchRecentGestures; // for SCAT
// @property (nonatomic, strong) NSArray<AXNamedReplayableGesture *> *assistiveTouchSavedGestures; // for SCAT
// 
// #if AX_HAS_LASER
// @property (nonatomic, readonly) BOOL laserEnabled;
// @property (nonatomic) ZWPanningStyle laserZoomPanningStyle;
// #endif  // AX_HAS_LASER
// 
// // AST Mouse
// #if HAS_AST_MOUSE_SUPPORT
// #if AX_HAS_LASER
// @property (nonatomic) BOOL assistiveTouchMouseBehavesLikeFinger; // if YES, sends touch events for gestures
// #endif
// @property (nonatomic) BOOL assistiveTouchMouseKeysEnabled;
// @property (nonatomic) BOOL assistiveTouchMouseKeysOptionToggleEnabled;
// @property (nonatomic) BOOL assistiveTouchMouseKeysUseMainKeyboardKeys;
// @property (nonatomic) BOOL assistiveTouchMouseAlwaysShowSoftwareKeyboardEnabled;
// @property (nonatomic) BOOL assistiveTouchMouseAllowAppleBluetoothDevicesPairing;
// @property (nonatomic) NSInteger assistiveTouchMouseKeysDelay;
// @property (nonatomic) NSInteger assistiveTouchMouseKeysMaxSpeed;
// @property (nonatomic, readonly) NSArray<AXCustomizableMouse *> *assistiveTouchMouseCustomizedClickActions;
// - (void)updateCustomizableMouse:(AXCustomizableMouse *)mouse;
// #if HAS_EYE_TRACKING_SUPPORT
// @property (nonatomic, readonly) NSDictionary<NSString *, NSDictionary *> *assistiveTouchEyeTrackerCustomizedSettings;
// 
// // convenience functions to store/retreive user-facing smoothing values per eye tracker
// - (NSNumber *)smoothingBufferSizeForEyeTracker:(AXSSMotionTrackingHIDInput *)eyeTracker;
// - (void)updateSmoothingBufferSize:(NSNumber *)smoothingBufferSize forEyeTracker:(AXSSMotionTrackingHIDInput *)eyeTracker;
// #endif
// @property (nonatomic) AXAssistiveTouchCursorColor assistiveTouchMousePointerColor;
// @property (nonatomic) CGFloat assistiveTouchMousePointerSizeMultiplier;
// @property (nonatomic) BOOL assistiveTouchMousePointerTimeoutEnabled;
// @property (nonatomic) NSTimeInterval assistiveTouchMousePointerTimeout;
// @property (nonatomic) BOOL assistiveTouchMouseDwellControlEnabled;
// @property (nonatomic) BOOL assistiveTouchMouseDwellControlAutorevertEnabled;
// @property (nonatomic, strong) NSString *assistiveTouchMouseDwellControlAutorevertAction;
// @property (nonatomic) NSTimeInterval assistiveTouchMouseDwellControlActivationTimeout;
// @property (nonatomic) CGFloat assistiveTouchMouseDwellControlMovementToleranceRadius;   // measured in points
// @property (nonatomic, strong) NSDictionary<NSString *, NSString *> *assistiveTouchMouseDwellControlCornerCustomization;
// @property (nonatomic) BOOL assistiveTouchMouseDwellControlMutatedMenu;
// @property (nonatomic) BOOL assistiveTouchMouseDwellControlShowPrompt;
// @property (nonatomic) ZWPanningStyle assistiveTouchMouseZoomPanningStyle;
// #endif
// #if HAS_EYE_TRACKING_SUPPORT
// @property (nonatomic) BOOL assistiveTouchMotionTrackerConfigurable; // internal setting to expose smoothing settings for HID devices
// @property (nonatomic) BOOL assistiveTouchForceEyeTrackerExperience; // internal setting to enable eye-tracking specific code paths. Ex: draws bubble mode
// @property (nonatomic) NSUInteger assistiveTouchMotionTrackerSmoothingBufferSize; // Smoothed point is the average of n points
// @property (nonatomic) CGFloat assistiveTouchMotionTrackerSmoothingMaxDelta; // Buffer will clear points not within max delta
// @property (nonatomic) double assistiveTouchMotionTrackerXNormalizationOrder; // Degree at which x offset is applied
// @property (nonatomic) double assistiveTouchMotionTrackerYNormalizationOrder; // Degree at which y offset is applied
// @property (nonatomic) double assistiveTouchMotionTrackerXNormalizationOffset; // Magnitude which is normalized to offset x
// @property (nonatomic) double assistiveTouchMotionTrackerYNormalizationOffset; // Magnitude which is normalized to offset y
// @property (nonatomic) BOOL assistiveTouchMotionTrackerShouldOffsetBufferPoints; // When true, smoothed point is average of offset n points
// #endif
// #if HAS_BUBBLE_MODE_SUPPORT
// @property (nonatomic) BOOL assistiveTouchBubbleModeEnabled;
// #endif
// #if HAS_EYE_TRACKING_SUPPORT
// @property (nonatomic) BOOL assistiveTouchEyeTrackingAutoHideEnabled;
// @property (nonatomic) NSTimeInterval assistiveTouchEyeTrackingAutoHideTimeout;
// @property (nonatomic) CGFloat assistiveTouchEyeTrackingAutoHideOpacity;
// #endif
// // Scanner
// // TODO: Prefix these with switchControl instead
// @property (nonatomic) AXAssistiveTouchScanningMode assistiveTouchScanningMode;
// @property (nonatomic) AXAssistiveTouchPreferredPointPicker assistiveTouchPreferredPointPicker;
// @property (nonatomic) BOOL assistiveTouchGroupElementsEnabled;
// @property (nonatomic) BOOL assistiveTouchScannerCompactMenuEnabled;
// @property (nonatomic) BOOL assistiveTouchScannerMenuLabelsEnabled;
// // The time between stepping to the next item
// @property (nonatomic) NSTimeInterval assistiveTouchStepInterval;
// // The time allowed for multiple inputs to be counted as one input
// @property (nonatomic) NSTimeInterval assistiveTouchInputCoalescingDuration;
// @property (nonatomic) BOOL assistiveTouchInputCoalescingEnabled;
// // The time required for the input button to be down before it counts as one input.
// @property (nonatomic) NSTimeInterval assistiveTouchInputHoldDuration;
// @property (nonatomic) BOOL assistiveTouchInputHoldEnabled;
// // The time required for the input button to be down before the Long Press action is used instead of the regular action.
// @property (nonatomic) NSTimeInterval assistiveTouchLongPressDuration;
// @property (nonatomic) BOOL assistiveTouchLongPressEnabled;
// @property (nonatomic) BOOL assistiveTouchLongPressPauseScanningEnabled;
// // The time we wait after the user presses the button before we started moving again,
// @property (nonatomic) NSTimeInterval assistiveTouchDelayAfterInput;
// @property (nonatomic) BOOL assistiveTouchDelayAfterInputEnabled;
// // The speed (in points per second) that the xy sweeper moves
// @property (nonatomic) CGFloat assistiveTouchAxisSweepSpeed;
// 
// // The interval before an action is repeated while an input device remains pressed
// @property (nonatomic) NSTimeInterval assistiveTouchActionRepeatInterval;
// @property (nonatomic) BOOL assistiveTouchActionRepeatEnabled;
// @property (nonatomic) NSInteger assistiveTouchScanCycles;
// @property (nonatomic) NSTimeInterval assistiveTouchScanTimeout;
// @property (nonatomic) BOOL assistiveTouchScanTimeoutEnabled;
// @property (nonatomic) BOOL assistiveTouchScannerSoundEnabled;
// @property (nonatomic) BOOL assistiveTouchScannerCursorHighVisibilityEnabled;
// @property (nonatomic) BOOL assistiveTouchScannerSpeechIsInterruptedByScanning;
// @property (nonatomic) BOOL assistiveTouchScannerSpeechShouldSpeakTraits;
// @property (nonatomic) AXAssistiveTouchCursorColor assistiveTouchCursorColor;
// @property (nonatomic) AXAssistiveTouchHeadMovementSensitivity assistiveTouchHeadMovementSensitivity;
// @property (nonatomic) BOOL assistiveTouchSwitchUsageConfirmed;
// @property (nonatomic) BOOL assistiveTouchGameControllerEnabled;
// // NSSet of AXSwitches
// @property (nonatomic, strong) NSSet<AXSwitch *> *assistiveTouchSwitches;
// #if HAS_MOTION_TRACKING_SUPPORT
// @property (nonatomic, strong) NSSet<AXSwitch *> *assistiveTouchCameraPointPickerSwitches;
// #endif
// 
// @property (nonatomic) BOOL assistiveTouchScannerSpeechEnabled;
// @property (nonatomic) double assistiveTouchScannerSpeechRate;
// 
// @property (nonatomic) BOOL assistiveTouchScannerAddedTripleClickAutomatically;
// @property (nonatomic) CGFloat assistiveTouchIdleOpacity;
// 
// // NSArray of AXSwitchRecipe objects.  Guaranteed to be non-nil.
// // If you're trying to create/modify recipes, please use the methods in AXSwitchRecipeUtilities.h instead.
// @property (nonatomic, strong) NSArray<AXSwitchRecipe *> *switchControlRecipes;
// // The UUID of the recipe that Switch Control should apply at launch
// @property (nonatomic, strong) NSUUID *switchControlLaunchRecipeUUID;
// 
// // Menu customization
// // Each of these arrays contains NSDictionary objects with keys AXSSwitchControlMenuItemEnabledKey => NSNumber(BOOL), AXSSwitchControlMenuItemTypeKey => NSString
// @property (nonatomic, readonly) NSArray<AXSSwitchControlMenuItem> *gestureKeys;
// @property (nonatomic, readonly) NSArray<AXSSwitchControlMenuItem> *deviceKeys;
// @property (nonatomic, readonly) NSArray<AXSSwitchControlMenuItem> *settingsKeys;
// @property (nonatomic, readonly) NSArray<AXSSwitchControlMenuItem> *mediaControlsKeys;
// @property (nonatomic, strong) NSArray<NSDictionary *> *switchControlCombinedTopLevelMenuItems;
// @property (nonatomic, strong) NSArray<NSDictionary *> *switchControlTopLevelMenuItems;
// @property (nonatomic, strong) NSArray<NSDictionary *> *switchControlGesturesTopLevelMenuItems;
// @property (nonatomic, strong) NSArray<NSDictionary *> *switchControlDeviceTopLevelMenuItems;
// @property (nonatomic, strong) NSArray<NSDictionary *> *switchControlSettingsTopLevelMenuItems;
// @property (nonatomic, strong) NSArray<NSDictionary *> *switchControlMediaControlsTopLevelMenuItems;
// @property (nonatomic, readonly) BOOL switchControlHasEmptyTopLevelMenu;
// @property (nonatomic, assign) BOOL switchControlShouldUseShortFirstPage; // applies only when Auto Tap is off
// @property (nonatomic, strong) NSArray<NSDictionary *> *switchControlGesturesMenuItems;
// @property (nonatomic, strong) NSArray<NSDictionary *> *switchControlDeviceMenuItems;
// @property (nonatomic, strong) NSArray<NSDictionary *> *switchControlSettingsMenuItems;
// @property (nonatomic, strong) NSArray<NSDictionary *> *switchControlMediaControlsMenuItems;
// @property (nonatomic) BOOL switchControlShouldUseExtendedKeyboardPredictions;
// @property (nonatomic) BOOL switchControlRestartScanningAtCurrentKey;
// 
// // Tap Behavior
// @property (nonatomic) AXSSwitchControlTapBehavior switchControlTapBehavior;
// @property (nonatomic) NSTimeInterval switchControlAutoTapTimeout; // duration an element has to be focused before AutoTap kicks in
// @property (nonatomic) BOOL switchControlShouldAlwaysActivateKeyboardKeys;
// @property (nonatomic) AXSSwitchControlScanAfterTapLocation switchControlScanAfterTapLocation;
// 
// // Scanning Style
// @property (nonatomic) AXSSwitchControlScanningStyle switchControlScanningStyle;
// 
// // Always Start with... (always start SC in a specific scanning mode)
// @property (nonatomic) AXAssistiveTouchScanningMode switchControlFirstLaunchScanningMode;
// - (NSString *)switchControlLocStringForFirstLaunchScanningMode:(AXAssistiveTouchScanningMode)scanningMode;
// 
// @property (nonatomic, assign) NSTimeInterval switchControlDwellTime; // how long the user has to dwell on an item, before it can be selected
// @property (nonatomic) AXSSwitchControlPointPickerSelectionStyle switchControlPointPickerSelectionStyle;
// #if HAS_MOTION_TRACKING_SUPPORT
// @property (nonatomic) BOOL switchControlUseCameraForPointMode;
// // The sensitivity of the cursor for head tracking
// @property (nonatomic) double switchControlCameraPointPickerSensitivity;
// @property (nonatomic) double switchControlCameraPointPickerMovementToleranceInJoystickMode;
// @property (nonatomic) AXSSMotionTrackingMode switchControlCameraPointPickerMode;
// @property (nonatomic) NSTimeInterval switchControlCameraPointPickerDwellActivationTimeout;
// @property (nonatomic) CGFloat switchControlCameraPointPickerDwellMovementToleranceRadius;
// #endif
// 
// @property (nonatomic, assign) BOOL switchControlIsEnabledAsReceiver; // This means the user didn't explicitly enable Switch Control on this device, and it should get disabled when it stops receiving forwarded actions
// 
// #pragma mark -
// #pragma mark HoverText
// 
// @property (nonatomic, assign) AXSHoverTextScrollingSpeed hoverTextScrollingSpeed;
// @property (nonatomic, strong) NSString *hoverTextContentSize;
// @property (nonatomic, assign) BOOL hoverTextShowedBanner;
// 
// #pragma mark -
// #pragma mark Zoom
// 
// // Used to preserve the current zoom state
// @property (nonatomic) BOOL zoomPreferencesWereInitialized;
// @property (nonatomic) CGRect zoomWindowFrame;
// @property (nonatomic) CGFloat dockSize;
// @property (nonatomic) CGFloat zoomScale;
// @property (nonatomic) CGPoint zoomPanOffset;
// // Value in range of [0.0 1.0]. for x, 0.0 being all the way left and 1.0 being all the way right
// @property (nonatomic) CGPoint zoomSlugNormalizedPosition;
// @property (nonatomic, strong) NSString *zoomCurrentLensEffect;
// @property (nonatomic, strong) NSString *zoomCurrentLensMode;
// @property (nonatomic, assign) BOOL zoomInStandby;
// @property (nonatomic, assign) BOOL zoomShowedBanner;
// 
// // Used to back the things the user can change about zoom
// @property (nonatomic) BOOL zoomShouldFollowFocus;
// @property (nonatomic) BOOL zoomShouldShowSlug;
// @property (nonatomic) BOOL zoomPeekZoomEnabled;
// @property (nonatomic) BOOL zoomPeekZoomEverEnabled;
// @property (nonatomic) AXZoomSlugAction zoomSlugSingleTapAction;
// @property (nonatomic) AXZoomSlugAction zoomSlugDoubleTapAction;
// @property (nonatomic) AXZoomSlugAction zoomSlugTripleTapAction;
// @property (nonatomic) BOOL zoomSlugTapAndSlideToAdjustZoomLevelEnabled;
// 
// @property (nonatomic) BOOL zoomAlwaysUseWindowedZoomForTyping;
// @property (nonatomic, strong) NSString *zoomPreferredCurrentLensMode;
// @property (nonatomic, strong) NSString *zoomPreferredCurrentDockPosition;
// @property (nonatomic) CGFloat zoomPreferredMaximumZoomScale;
// @property (nonatomic, strong) NSOrderedSet *zoomPreferredLensModes;
// @property (nonatomic, strong) NSOrderedSet *zoomPreferredDockPositions;
// @property (nonatomic) CGFloat zoomIdleSlugOpacity;
// @property (nonatomic) AXZoomControllerColor zoomControllerColor;
// 
// // Keyboard Shortcuts
// @property (nonatomic) BOOL zoomKeyboardShortcutsEnabled;
// @property (nonatomic) BOOL zoomAdjustZoomLevelKbShortcutEnabled;
// @property (nonatomic) BOOL zoomToggleZoomKbShortcutEnabled;
// @property (nonatomic) BOOL zoomPanZoomKbShortcutEnabled;
// @property (nonatomic) BOOL zoomResizeZoomWindowKbShortcutEnabled;
// @property (nonatomic) BOOL zoomSwitchZoomModeKbShortcutEnabled;
// @property (nonatomic) BOOL zoomTempToggleZoomKbShortcutEnabled;
// @property (nonatomic) BOOL zoomScrollWheelKbShortcutEnabled;
// @property (nonatomic) BOOL zoomTrackpadGestureEnabled;
// 
// @property (nonatomic) BOOL zoomAutopannerShouldPanWithAcceleration;
// 
// @property (nonatomic) BOOL zoomShowWhileMirroring;
// 
// #if TARGET_OS_VISION
// @property (nonatomic, strong) NSArray<NSNumber *> *magnifyingGlassBorderColor;
// #endif
// 
// // Not currently public
// @property (nonatomic) BOOL zoomShouldAllowFullscreenAutopanning;
// 
// 
// - (void)zoomUserHadLegacyZoomEnabled:(BOOL *)legacyZoomWasEnabled wasZoomedIn:(BOOL *)legacyZoomWasZoomedIn withScale:(CGFloat *)legacyZoomScale;
// 
// @property (nonatomic) BOOL zoomDebugDisableZoomLensScaleTransform;
// @property (nonatomic) BOOL zoomDebugShowExternalFocusRect;
// 
// #pragma mark -
// #pragma mark Guided Access
// 
// @property (nonatomic) BOOL guidedAccessAXFeaturesEnabled;
// @property (nonatomic) BOOL guidedAccessAllowsUnlockWithTouchID;
// @property (nonatomic) BOOL guidedAccessShouldSpeakForTimeRestrictionEvents;
// @property (nonatomic, copy) NSString *guidedAccessToneIdentifierForTimeRestrictionEvents;
// @property (nonatomic, readonly) NSString *guidedAccessDefaultToneIdentifierForTimeRestrictionEvents;
// @property (nonatomic, readonly) BOOL guidedAccessOverrideIdleTime; // dead, but used by the migrator
// @property (nonatomic) NSInteger guidedAccessAutoLockTimeInSeconds; // either a number of seconds, or a constant like AXSGuidedAccessAutoLockTimeNever
// @property (nonatomic, readonly) BOOL guidedAccessAllowsMultipleWindows; // right now always returns YES
// @property (nonatomic) BOOL guidedAccessUserPrefersMirroringForExternalDisplays; // Chamois / Stage Manager
// 
// #if HAS_GAX_MULTI_APP
// @property (nonatomic, strong) NSArray<GAXAppSet *> *guidedAccessMultiAppSets;
// #endif
// 
// // GAX internal Persisted State
// @property (nonatomic, strong) NSDictionary *gaxInternalSettingsUserAppProfile;
// @property (nonatomic, strong) NSDictionary *gaxInternalSettingsUserGlobalProfile;
// @property (nonatomic, strong) NSDictionary *gaxInternalSettingsSavedAccessibilityFeatures;
// @property (nonatomic, strong) NSArray *gaxInternalSettingsSavedAccessibilityTripleClickOptions;
// @property (nonatomic, strong) NSArray *gaxInternalSettingsUserConfiguredAppIDs;
// @property (nonatomic, copy) NSNumber *gaxInternalSettingsActiveAppOrientation;
// @property (nonatomic, copy) NSString *gaxInternalSettingsActiveAppID;
// @property (nonatomic) BOOL gaxInternalSettingsTimeRestrictionHasExpired;
// @property (nonatomic) BOOL gaxInternalSettingsIsActiveAppSelfLocked;
// @property (nonatomic) BOOL gaxInternalSettingsSystemDidRestartDueToLowBattery;
// @property (nonatomic, copy) NSNumber *gaxInternalSettingsECID;
// @property (nonatomic, copy) NSString *gaxInternalSettingsProductBuildVersion;
// @property (nonatomic, strong) NSDate *gaxInternalSettingsLastActivationDate;
// @property (nonatomic, strong) NSDate *gaxInternalSettingsLastPasscodeSetDate;
// 
// #pragma mark -
// #pragma mark Hardware Keyboards
// @property (nonatomic, assign) BOOL stickyKeysEnabled;
// @property (nonatomic, assign) BOOL stickyKeysShiftToggleEnabled;
// @property (nonatomic, assign) BOOL stickyKeysBeepEnabled;
// 
// #pragma mark -
// #pragma mark Magnifier
// @property (nonatomic, assign) BOOL magnifierEnabled;
// // If Magnifier was activated from Back Tap menu, we don't need to add Magnifier option to Triple Click Menu
// - (void)setMagnifierEnabled:(BOOL)magnifierEnabled changeTripleClickMenu:(BOOL)changeTripleClickMenu;
// // Default is NO, if set to YES, brightness and contrast will be auto-adjusted when magnifier
// // becomes active, due to ambient light sampled by the camera
// @property (nonatomic, assign) BOOL magnifierShouldAdjustFiltersForAmbientLight;
// // Defaults is NO. When YES, magnifier will use video stabilization. The trade-off is we have to run
// // with a lower resolution
// @property (nonatomic, assign) BOOL magnifierShouldUseVideoStabilization;
// 
// @property (nonatomic, assign) CGFloat magnifierZoomLevel;
// @property (nonatomic, assign) AXMagnifierFilterSetIdentifier magnifierFilterSetIdentifier;
// @property (nonatomic, assign) BOOL magnifierFilterInverted;
// @property (nonatomic, assign) CGFloat magnifierContrast;
// @property (nonatomic, assign) CGFloat magnifierBrightness;
// #if APPLE_FEATURE_STACCATO
// @property (nonatomic, assign) BOOL didLaunchMagnifierFromStaccato;
// #endif
// 
// #pragma mark -
// #pragma mark Call Audio Routing
// 
// // The time we wait before auto answering a call,
// @property (nonatomic) NSTimeInterval callAudioRoutingAutoAnswerDelay;
// @property (nonatomic) BOOL callAudioRoutingAutoAnswerEnabled;
// 
// 
// #pragma mark -
// #pragma mark Internal
// 
// @property (nonatomic) BOOL assistiveTouchCameraSwitchPreviewEnabled;
// @property (nonatomic) BOOL assistiveTouchInternalOnlyHiddenNubbitModeEnabled;
// @property (nonatomic) BOOL assistiveTouchInternalOnlyPearlTrackingEnabled;
// @property (nonatomic) AXSInternalLoggingColorTheme internalLoggingColorTheme;
// @property (nonatomic) BOOL validateSecondPartyApps;
// @property (nonatomic) BOOL includeBacktraceInLogs;
// @property (nonatomic) BOOL writeAXLogsToFile;
// @property (nonatomic) BOOL ignoreAXAsserts;
// @property (nonatomic) BOOL ignoreAXServerEntitlements;
// @property (nonatomic) BOOL logAXNotificationPosting;
// @property (nonatomic) BOOL voiceOverHearingAidRoutingEnabled;
// @property (nonatomic) BOOL skipHearingAidMFiAuth;
// @property (nonatomic) BOOL enableHearingAidReporter;
// @property (nonatomic) BOOL guidedAccessDisallowDirectInactiveToActiveTransition;
// @property (nonatomic, strong) NSNumber *guidedAccessOverrideTimeRestrictionDuration; // In seconds
// @property (nonatomic) BOOL guidedAccessEnableExperimentalUI;
// @property (nonatomic) BOOL enableVoiceOverCaptions;
// @property (nonatomic) BOOL syncPronunciationsWithCloudKit;
// // <rdar://problem/32211885> For aggd logging. YES if the user triggered SOS today and had the accessibility shortcut enabled.
// @property (nonatomic) BOOL didTriggerSOSToday;
// - (BOOL)didTriggerSOSValueSet;
// @property (nonatomic, readonly) BOOL voiceOverShowBrailleWatchSettings;
// @property (nonatomic) BOOL voiceOverUseDigitalCrownNavigation;  // for watch
// @property (nonatomic) BOOL voiceOverUseTVToggleStyleNavigation;
// @property (nonatomic) BOOL shouldCaptureVisionEngineDiagnosticsToDisk;
// @property (nonatomic) NSInteger /*AXCustomContentDescriptionLevel*/ voiceOverContentDescriptionLevel;
// 
// #if AXM_HAS_IMAGE_CAPTION_SUPPORT
// @property (nonatomic) AXMCaptionGenderStrategy imageCaptionGenderStrategy;
// #endif
// @property (nonatomic, copy) NSArray<NSString *> *imageCaptioningDisabledApps; // List of apps where we turn off image captioning
// 
// @property (nonatomic, copy) NSDictionary<NSString *, NSNumber *> *voiceOverDirectTouchEnabledApps; // List of apps where direct touch is enabled
// 
// // on older devices we use scene descriptions. We can allow these to be controlled on older devices.
// @property (nonatomic) BOOL voiceOverSceneDescriptionsEnabled;
// 
// #if AX_IOS_VOICEOVER_CAN_INTERACT
// @property (nonatomic, assign) AXSVoiceOverNavigationStyle voiceOverNavigationStyle;
// #endif
// 
// @property (nonatomic, assign) BOOL voiceOverSoundCurtain;
// 
// #if HAS_ML_ELEMENT_SUPPORT
// @property (nonatomic) BOOL automaticAccessibilityEnabled;
// @property (nonatomic) BOOL automaticAccessibilityIgnoreAppAccessibilityPreferred;
// @property (nonatomic) BOOL automaticAccessibilityVisualizationsEnabled;
// - (NSDictionary<NSString *, NSNumber *> *)automaticAccessibilityModes;
// - (void)setAutomaticAccessibilityModes:(NSDictionary<NSString *, NSNumber *> *)modes;
// - (AXAutomaticAccessibilityMode)automaticAccessibilityModeForBundleIdentifier:(NSString *)bundleIdentifier;
// - (void)setAutomaticAccessibilityMode:(AXAutomaticAccessibilityMode)automaticAccessibilityModes forBundleIdentifier:(NSString *)bundleIdentifier;
// #endif
// 
// // Mark my words, this is temporary. Coming out once we transition over fully. Default is NO
// @property (nonatomic) BOOL useNewAXBundleLoader;
// 
// // Default is NO. Engineers wishing to see ax symbol validations at launch should set this to YES. This can
// // be done conveniently with 'axctl axvalidations enable'. See also [AXSettings appValidationTestingMode]
// @property (nonatomic) BOOL shouldPerformValidationsAtRuntime;
// 
// #pragma mark -
// #pragma mark Miscellaneous
// 
// @property (nonatomic, copy) NSArray *tripleClickOrderedOptions;
// @property (nonatomic) BOOL speakCorrectionsEnabled;
// @property (nonatomic, strong) NSURL *alexLocalAssetURL;
// @property (nonatomic, assign) BOOL classicInvertColors;
// @property (nonatomic) BOOL voiceOverSleepOnWristDownPreference;
// @property (nonatomic) BOOL assistiveTouchSleepOnWristDownPreference;
// 
// // currentVoices are all the voices present on the system currently
// @property (nonatomic, strong) NSArray<AVSpeechSynthesisVoice *> *currentVoices;
// // extantVoices are all the voices that are on the system and the servers.
// @property (nonatomic, strong) NSArray<AVSpeechSynthesisVoice *> *extantVoices;
// @property (nonatomic, readonly) BOOL extantVoicesExist;
// @property (nonatomic, readonly) BOOL currentVoicesExist;
// @property (nonatomic, assign) BOOL dataMigratorRequestedVoiceCacheRefresh;
// 
// @property (nonatomic, assign) BOOL securePayAssertionActive;
// 
// #pragma mark -
// #pragma mark Spoken Content
// 
// // Many of these values are shared by Speak This.
// 
// @property (nonatomic) BOOL showSpeechController;
// @property (nonatomic) CGFloat speechControllerIdleOpacity;
// @property (nonatomic) AXSpeechControllerAction speechControllerLongPressAction;
// @property (nonatomic) AXSpeechControllerAction speechControllerDoubleTapAction;
// // The rate at which content is spoken by the synthesizer. Values will
// // be capped between 0.5 and 4.0 (as per their documentation)
// @property (nonatomic) float quickSpeakSpeakingRate;
// @property (nonatomic) BOOL quickSpeakUnderlineSentence;
// @property (nonatomic) float quickSpeakVolume; // [0,1] - QS volume, not system volume.
// @property (nonatomic) AXSSentenceHighlightOption quickSpeakSentenceHighlightOption;
// @property (nonatomic) AXSHighlightOptions quickSpeakHighlightOption;
// @property (nonatomic) AXSHighlightColorOption quickSpeakWordHighlightColor;
// @property (nonatomic) AXSHighlightColorOption quickSpeakSentenceHighlightColor;
// 
// - (void)setQuickSpeakSpeakingRate:(float)rate forLanguage:(NSString *)language;
// - (float)quickSpeakSpeakingRateForLanguage:(NSString *)language;
// 
// //  deprecated in favor of string based source api
// // language should be general form, because we store a voice for a general language here
// - (NSString *)speechVoiceIdentifierForLanguage:(NSString *)generalLanguage source:(AXSpeechSource)source exists:(BOOL *)exists SPI_DEPRECATED_WITH_REPLACEMENT("Use speechVoiceIdentifierForLanguage:sourceKey:exists instead", macos(13.0, 14.0), ios(16.0, 17.0), watchos(9.0, 10.0), tvos(16.0, 17.0));
// 
// - (NSString *)speechVoiceIdentifierForLanguageWithoutFallback:(NSString *)language sourceKey:(NSString *)sourceKey;
// // language should be general form, because we store a voice for a general language here
// - (NSString *)speechVoiceIdentifierForLanguage:(NSString *)generalLanguage sourceKey:(NSString *)sourceKey exists:(BOOL *)exists;
// - (BOOL)userDidSelectVoiceForLanguage:(NSString *)language sourceKey:(NSString *)sourceKey;
// - (void)setSpeechVoiceIdentifier:(NSString *)voiceId forLanguage:(NSString *)generalLanguage sourceKey:(NSString *)sourceKey;
// 
// #if AX_HAS_LIVE_SPEECH
// // Live Speech is a bit different in that it binds a specific voice to a specific keyboardID. eg instead of zh-TW mapping to TingTing, it would be zh-Hant mapping to TingTing
// - (NSString *)liveSpeechVoiceIdentifierForKeyboardID:(NSString *)keyboardID;
// #endif
// 
// // custom per-voice settings, keyed by identifier and speech source
// - (NSDictionary *)customSettingsForVoice:(NSString *)voiceIdentifier sourceKey:(NSString *)sourceKey;
// - (void)setCustomSettingsForVoice:(NSString *)voiceIdentifier sourceKey:(NSString *)sourceKey settings:(NSDictionary *)settings;
// 
// - (void)setSpeechVoiceIdentifier:(NSString *)voiceId forLanguage:(NSString *)generalLanguage source:(AXSpeechSource)source SPI_DEPRECATED_WITH_REPLACEMENT("Use setSpeechVoiceIdentifier:forLanguage:sourceKey instead", macos(13.0, 14.0), ios(16.0, 17.0), watchos(9.0, 10.0), tvos(16.0, 17.0));
// 
// 
// - (void)setUserDidSelectVoiceForLanguage:(NSString *)language sourceKey:(NSString *)sourceKey;
// 
// // grab every selected speech voice identifier for every language + source pair where a preference exists
// - (NSArray<NSString *> *)selectedSpeechVoiceIdentifiers;
// - (NSArray<NSString *> *)selectedSpeechVoiceIdentifiersForSourceKey:(NSString *)sourceKey;
// // key: sourceKey -> { "language" -> "id" }
// - (NSDictionary<NSString *, NSDictionary<NSString *, NSString *> *> *)selectedSpeechVoiceIdentifiersWithLanguageSource;
// - (void)setSelectedSpeechVoiceIdentifiersWithLanguageSource:(NSDictionary<NSString *, NSDictionary<NSString *, NSString *> *> *)data;
// 
// @property (nonatomic, assign) BOOL siriAutoUpdateListInitialized;
// 
// // For the Speak This nubbit
// @property (nonatomic) CGPoint quickSpeakNubbitNormalizedPosition;
// 
// #if AX_HAS_SPATIALIZED_SPEECH_SUPPORT
// @property (nonatomic) BOOL spokenContentSpatializedSpeechEnabled;
// #endif
// 
// // True by default. Uses language tagging to switch voices. Before iOS 16 this was the only behavior available
// @property (nonatomic, assign) BOOL spokenContentShouldUseLanguageDetection;
// // If language-tagging fails or is disabled, spoken content normally falls back to a voice decided by the current locale. Users can
// // override this in iOS 16 by specifying a preferred language. Use case is a langauge for a new unified speech voice for which no
// // current locale will ever match (e.g. Basque, Bangla, etc)
// @property (nonatomic, strong /*nullable*/) NSString *spokenContentDefaultFallbackLanguage;
// 
// #pragma mark -
// #pragma mark VoiceOver
// 
// @property (nonatomic) BOOL voiceOverImageCaptionsEnabled;
// @property (nonatomic) BOOL voiceOverLargeCursorEnabled;
// @property (nonatomic) AXSVoiceOverTouchHelpMode voiceOverHelpMode;
// @property (nonatomic) AXSVoiceOverTouchNavigateImagesOption voiceOverNavigateImagesOption;
// @property (nonatomic) AXSVoiceOverTouchPhoneticsFeedback voiceOverPhoneticsFeedback;
// @property (nonatomic) AXSVoiceOverTouchTypingFeedback voiceOverHardwareTypingFeedback;
// @property (nonatomic) AXSVoiceOverTouchTypingFeedback voiceOverSoftwareTypingFeedback;
// @property (nonatomic) AXSVoiceOverTouchTypingFeedback voiceOverBrailleGesturesTypingFeedback;
// @property (nonatomic) AXSVoiceOverKeyboardModifierChoice voiceOverKeyboardModifierChoice;
// @property (nonatomic) CGFloat voiceOverContinuousPathKeyboardStartTimeout;
// @property (nonatomic) BOOL voiceOverBrailleAlertsEnabled;
// @property (nonatomic) NSTimeInterval voiceOverBrailleAlertDisplayDuration;
// @property (nonatomic) BOOL voiceOverBrailleAlertShowUntilDismissed;
// @property (nonatomic) NSTimeInterval voiceOverBrailleKeyDebounceTimeout;
// @property (nonatomic, readonly) BOOL voiceOverHandwritingEnabled;
// @property (nonatomic, readonly) BOOL voiceOverBrailleGesturesEnabled;
// @property (nonatomic) BOOL voiceOverBrailleWordWrapEnabled;
// @property (nonatomic) CGFloat voiceOverBrailleAutoAdvanceDuration;
// @property (nonatomic) BOOL voiceOverHintsEnabled;
// @property (nonatomic) BOOL voiceOverAudioDuckingEnabled;
// @property (nonatomic, strong) NSString *voiceOverSelectedLanguage;
// @property (nonatomic) BOOL voiceOverBrailleFormattingEnabled;
// @property (nonatomic) BOOL voiceOverUseRingerSwitchToControlNotificationOutput;
// @property (nonatomic) AXSVoiceOverFeedbackOption voiceOverBannerNotificationOutput;
// @property (nonatomic) AXSVoiceOverFeedbackOption voiceOverLockedScreenNotificationOutput;
// @property (copy, nonatomic) NSArray<NSDictionary *> *voiceOverBrailleDisplays;
// @property (copy, nonatomic) NSDictionary<NSString *, NSNumber *> *voiceOverBrailleDisconnectOnSleep;
// 
// // Default is NO. If YES, VoiceOver's audio should follow the system audio to an HDMI-connected audio destination. If NO, VoiceOver's
// // audio remains on device while system audio goes to the HDMI audio destination.
// @property (nonatomic) BOOL voiceOverAudioFollowsHDMIAudio;
// @property (nonatomic) BOOL voiceOverIgnoreTrackpad;
// @property (nonatomic) BOOL voiceOverPitchChangeEnabled;
// @property (nonatomic) double voiceOverPitch; // .5 default
// @property (nonatomic) BOOL voiceOverLanguageDetectionEnabled;
// @property (nonatomic) BOOL voiceOverSoundEffectsEnabled;
// @property (nonatomic) BOOL voiceOverAdjustSoundVolumeIndependently;
// @property (nonatomic) double voiceOverSoundVolume;
// @property (nonatomic) BOOL voiceOverHapticsEnabled;
// @property (nonatomic) BOOL voiceOverAlwaysTurnOnBluetooth;
// @property (nonatomic) double voiceOverHapticIntensity;
// @property (nonatomic) BOOL voiceOverVerbosityEmojiSuffixEnabled;
// @property (nonatomic) AXSVoiceOverFeedbackOption voiceOverVerbosityEmojiFeedback;
// @property (nonatomic) BOOL voiceOverVerbositySpeakCustomActionsHint;
// @property (nonatomic) BOOL voiceOverSpeakingRateInRotorEnabled;
// @property (nonatomic) BOOL voiceOverSpeakNotificationsEnabled;
// // NSArray of NSDictionaries containing the items (in order), each has enabled=BOOL and rotorItem=NSString
// @property (nonatomic, copy) NSArray<NSDictionary *> *voiceOverRotorItems;
// @property (nonatomic) BOOL voiceOverEditAppsActionEnabled;
// @property (nonatomic) BOOL voiceOverRotorUpdatesWithElement;
// @property (nonatomic) BOOL voiceOverSpeakActionConfirmation;
// @property (nonatomic, copy) NSString *voiceOverBrailleTableIdentifier;
// @property (nonatomic, copy) NSArray<NSDictionary *> *voiceOverBrailleLanguageRotorItems;
// @property (nonatomic) BOOL voiceOverAlwaysUseNemethCodeForMathEnabled;
// @property (nonatomic) BOOL voiceOverShowSoftwareKeyboardWithBraille;
// @property (nonatomic) AXSVoiceOverActivationWorkaround voiceOverActivationWorkaround;
// @property (nonatomic) BOOL voiceOverShouldOutputToHearingAid;
// // A nil return value implies we did not tinker with the real setting.
// @property (nonatomic, strong) NSNumber *voiceOverHandwritingWasNativeAutocorrectEnabled;
// // TODO: Rename, it's not a dictionary
// @property (nonatomic, strong) NSArray<TTSSubstitution *> *customPronunciationSubstitutions;
// @property (nonatomic) BOOL voiceOverTouchBraillePanningAutoTurnsReadingContent;
// @property (nonatomic) BOOL voiceOverTouchSingleLetterQuickNavEnabled;
// @property (nonatomic) AXSVoiceOverFeedbackOption voiceOverQuickNavAnnouncementFeedback;
// @property (nonatomic) AXSVoiceOverCapitalLetterFeedback voiceOverCapitalLetterFeedback;
// @property (nonatomic) BOOL voiceOverSpeakTableColumnRowInformation;
// @property (nonatomic) BOOL voiceOverSpeakTableHeaders;
// @property (nonatomic) AXSVoiceOverDeletionFeedback voiceOverDeletionFeedback;
// @property (nonatomic) AXSVoiceOverFeedbackOption voiceOverActionsFeedback;
// @property (nonatomic) BOOL voiceOverActionFeedbackFirstInListOnly;
// @property (nonatomic) AXSVoiceOverFeedbackOption voiceOverContainerOutputFeedback;
// @property (nonatomic) AXSVoiceOverFeedbackOption voiceOverMoreContentOutputFeedback;
// @property (nonatomic) AXSVoiceOverFeedbackOption voiceOverRotorSummaryFeedback;
// @property (nonatomic) AXSVoiceOverDiscoveredSensitiveContentFeedback voiceOverDiscoveredSensitiveContentFeedback;
// @property (nonatomic) AXSVoiceOverPunctuationLevel voiceOverPunctuationLevel API_DEPRECATED_WITH_REPLACEMENT("-voiceOverPunctuationGroup!", ios(3.0, 13.0), tvos(3.0, 13.0));
// @property (nonatomic, copy) NSUUID *voiceOverPunctuationGroup;
// @property (nonatomic, copy) NSUUID *voiceOverDefaultPunctuationGroup;
// 
// @property (nonatomic) AXSVoiceOverFeedbackOption voiceOverLinkFeedback;
// 
// @property (nonatomic) AXSVoiceOverFeedbackOption voiceOverInlineTextCompletionAppearanceFeedback;
// @property (nonatomic) AXSVoiceOverFeedbackOption voiceOverInlineTextCompletionInsertionFeedback;
// 
// @property (nonatomic) AXSVoiceOverBrailleMode voiceOverTouchBrailleDisplayInputMode;
// @property (nonatomic) AXSVoiceOverBrailleMode voiceOverTouchBrailleGesturesInputMode;
// @property (nonatomic) AXSVoiceOverBrailleMode voiceOverTouchBrailleDisplayOutputMode;
// 
// @property (nonatomic) BOOL voiceOverSpeaksOverTelephoneCalls;
// 
// @property (nonatomic) BOOL voiceOverTouchBrailleGesturesShouldUseLockedConfiguration;
// @property (nonatomic) AXDeviceOrientation voiceOverTouchBrailleGesturesLockedOrientation;
// @property (nonatomic) AXSVoiceOverTouchBrailleGesturesTypingMode voiceOverTouchBrailleGesturesLockedTypingMode;
// @property (nonatomic) BOOL voiceOverTouchBrailleGesturesDidPlayCalibrationHint;
// 
// @property (nonatomic) BOOL voiceOverTouchBrailleShouldReverseDots;
// 
// @property (nonatomic) BOOL voiceOverTouchBrailleShowGeneralStatus;
// @property (nonatomic) BOOL voiceOverTouchBrailleShowTextStyleStatus;
// 
// @property (nonatomic) BOOL voiceOverTouchUpdateBrailleWithoutConnectedDisplay;
// 
// - (NSString *)preferredBrailleTableIdentifierForKeyboardLanguage:(NSString *)keyboardLanguage keyboardLayout:(NSString *)keyboardLayout;
// - (void)setPreferredBrailleTableIdentifier:(NSString *)tableIdentifier forKeyboardLanguage:(NSString *)keyboardLanguage keyboardLayout:(NSString *)keyboardLayout;
// 
// #if AX_HAS_CAROUSEL_DETENTS_SUPPORT
// @property (nonatomic) BOOL voiceOverTouchDetentsEnabled;
// #endif
// 
// #if AX_IOS_VOICEOVER_FLASHLIGHT_NOTIFICATIONS
// @property (nonatomic) BOOL voiceOverFlashlightNotificationsEnabled;
// #endif
// 
// // Default is YES. The user can change this to NO in settings to have VO not perform fallback text detection
// // for inaccessible elements
// @property (nonatomic) BOOL voiceOverShouldSpeakDiscoveredText;
// @property (nonatomic) AXSVoiceOverDiscoveredMLContentFeedback voiceOverNeuralElementFeedback;
// 
// @property (nonatomic) AXSVoiceOverNumberFeedback voiceOverNumberFeedback;
// 
// @property (nonatomic) BOOL voiceOverAutomaticButtonLabels;
// 
// - (void)setVoiceOverSpeakingRate:(float)rate forLanguage:(NSString *)language;
// - (float)voiceOverSpeakingRateForLanguage:(NSString *)language;
// 
// - (void)addRotorOptionsForLoginSession;
// - (void)configureZoomForLoginSession;
// 
// @property (nonatomic) BOOL voiceOverBrailleGradeTwoAutoTranslateEnabled;
// @property (nonatomic) NSTimeInterval voiceOverDoubleTapInterval;
// 
// - (BOOL)anyUserPreferredLangaugeIsRTL;
// @property (nonatomic) AXSVoiceOverTouchNavigationDirectionMode voiceOverNavigationDirectionMode;
// 
// @property (nonatomic) BOOL tapToSpeakTimeEnabled;
// @property (nonatomic) AXSTapToSpeakTimeAvailability tapToSpeakTimeAvailability;
// 
// @property (nonatomic, readonly) BOOL tapticTimeIsAvailable;
// 
// @property (nonatomic) BOOL tapticTimeInternalFlashScreenEnabled;
// 
// @property (nonatomic) BOOL voiceOverTapticTimeMode;
// @property (nonatomic) AXSVoiceOverTapticTimeEncoding voiceOverTapticTimeEncoding;
// @property (nonatomic) float voiceOverTapticTimeSpeed;
// @property (nonatomic) BOOL voiceOverTapticChimesEnabled;
// @property (nonatomic) AXSVoiceOverTapticChimesAvailability voiceOverTapticChimesAvailability;
// @property (nonatomic) AXSVoiceOverTapticChimesFrequencyEncoding voiceOverTapticChimesFrequencyEncoding;
// @property (nonatomic) AXSVoiceOverTapticChimesSoundType voiceOverTapticChimesSoundType;
// 
// @property (nonatomic) BOOL letterFeedbackEnabled;
// @property (nonatomic) BOOL phoneticFeedbackEnabled;
// @property (nonatomic) NSTimeInterval characterFeedbackDelayDuration;
// @property (nonatomic) BOOL quickTypeWordFeedbackEnabled;
// @property (nonatomic) BOOL wordFeedbackEnabled;
// 
// @property (nonatomic) BOOL voiceOverSpeakNonfocusableElementsAfterDelay;
// @property (nonatomic) BOOL voiceOverSilenceAnnouncements;
// @property (nonatomic) AXSVoiceOverTVInteractionMode voiceOverPreferredTVInteractionMode;
// @property (nonatomic) BOOL voiceOverPrefersFollowFocusNavigationStyle;
// @property (nonatomic) BOOL voiceOverExploreFocusAffectsNativeFocus;
// @property (nonatomic) AXSVoiceOverDescribedMedia voiceOverDescribedMedia;
// @property (nonatomic, strong) NSData *voiceOverCustomCommandProfile;
// @property (nonatomic, strong) NSArray<AXVoiceOverActivity *> *voiceOverActivities;
// @property (nonatomic, strong) AXVoiceOverActivity *voiceOverSelectedActivity;
// 
// #if AX_HAS_MOSSDEEP
// @property (nonatomic) AXSVoiceOverInputFeedback voiceOverInputFeedback;
// @property (nonatomic) AXSVoiceOverInputFeedback voiceOverAppHoverFeedback;
// #endif
// 
// /**
//  Structure is:
//  {
//  "screenDidChange" :
//     {
//         "soundEnabled": 1,
//         "hapticEnabled": 1
//     }
//  "alertAppeared" :
//     {
//         "soundEnabled": 1,
//         "hapticEnabled": 1
//     }
//  }
//  */
// @property (nonatomic, strong) NSDictionary<NSString *, NSDictionary<NSString *, NSNumber *> *> *voiceOverSoundAndHapticPreferences;
// - (NSNumber *)voiceOverSoundEnabledForEvent:(NSString *)outputEvent;
// - (void)voiceOverSetSoundEnabled:(BOOL)soundEnabled forEvent:(NSString *)outputEvent;
// - (NSNumber *)voiceOverHapticEnabledForEvent:(NSString *)outputEvent;
// - (void)voiceOverSetHapticEnabled:(BOOL)hapticEnabled forEvent:(NSString *)outputEvent;
// - (void)voiceOverResetSoundAndHapticPreferences;
// 
// #if AX_HAS_VOICEOVER_SETTINGS_HUD
// // This is here for storage only. Do not access directly but instead use [VOSSettingsHelper userSettingsItems] API
// @property (nonatomic, copy) NSArray<NSDictionary *> *voiceOverQuickSettingsItems;
// #endif
// 
// // Hand gestures on watch
// @property (nonatomic) BOOL voiceOverHandGesturesEnabled;
// @property (nonatomic, strong) NSDictionary *voiceOverHandGesturesActionCustomizations;
// 
// @property (nonatomic) BOOL zoomHandGesturesEnabled;
// @property (nonatomic, strong) NSDictionary *zoomHandGesturesActionCustomizations;
// 
// #if AX_HAS_SPATIALIZED_SPEECH_SUPPORT
// @property (nonatomic) BOOL voiceOverSpatializedSpeechEnabled;
// #endif
// #if TARGET_OS_XR
// @property (nonatomic) BOOL voiceOverGestureHandednessFlipped;
// #endif
// 
// #pragma mark -
// #pragma mark - USB Restricted Mode
// 
// @property (nonatomic) BOOL voiceOverShouldDisallowUSBRestrictedMode; // dead, but here to access to migrate from previous seeds
// @property (nonatomic) BOOL voiceOverUserDidReadUSBRestrictedModeAlert;
// 
// // this will be set if a user ever connects an MFI switch
// @property (nonatomic) BOOL switchControlShouldDisallowUSBRestrictedMode; // dead, but here to access to migrate from previous seeds
// @property (nonatomic) BOOL switchControlUserDidReadUSBRestrictedModeAlert;
// 
// #pragma mark -
// #pragma mark Hearing Aids
// 
// @property(nonatomic) BOOL independentHearingAidSettings;
// @property(nonatomic) BOOL allowHearingAidControlOnLockScreen;
// @property(nonatomic) BOOL shouldStreamToLeftAid;
// @property(nonatomic) BOOL shouldStreamToRightAid;
// 
#pragma mark Hearing
// @property(nonatomic, assign) BOOL leftRightBalanceEnabled;
@property(nonatomic, assign) CGFloat leftRightBalanceValue;
// #if AX_HAS_ON_DEVICE_SPATIAL_AUDIO_SUPPORT
// @property (nonatomic) BOOL onDeviceSpatialAudioEnabled;
// #endif
// 
// #pragma mark -
// #pragma mark Touch Accommodations
// 
// // For touch accommodations to take effect, touchAccommodationsEnabled and touchAccommodationsAreConfigured must both return YES.
// @property (nonatomic) BOOL touchAccommodationsEnabled;
// @property (nonatomic, readonly) BOOL touchAccommodationsAreConfigured; // convenience to determine whether any of the individual settings are enabled
// 
// @property (nonatomic) BOOL touchAccommodationsUsageConfirmed;
// @property (nonatomic) BOOL touchAccommodationsTripleClickConfirmed;
// 
// @property (nonatomic) BOOL touchAccommodationsHoldDurationEnabled;
// @property (nonatomic) NSTimeInterval touchAccommodationsHoldDuration;
// @property (nonatomic) BOOL touchAccommodationsAllowsSwipeGesturesToBypass;
// @property (nonatomic) BOOL touchAccommodationsHoldDurationAllowsSwipeGesturesToBypass; // dead, but used by the migrator
// @property (nonatomic, readonly) AXSTouchAccommodationsHoldDurationSwipeGestureSensitivity touchAccommodationsHoldDurationSwipeGestureSensitivity; // dead, but used by the migrator
// @property (nonatomic) CGFloat touchAccommodationsSwipeGestureMinimumDistance; // distance in points
// @property (nonatomic) BOOL touchAccommodationsIgnoreRepeatEnabled;
// @property (nonatomic) NSTimeInterval touchAccommodationsIgnoreRepeatDuration;
// @property (nonatomic) AXSTouchAccommodationsTapActivationMethod touchAccommodationsTapActivationMethod;
// @property (nonatomic) NSTimeInterval touchAccommodationsTapActivationTimeout;
// 
// #pragma mark -
// #pragma mark Full Keyboard Access
// 
// @property (nonatomic, strong) NSData *fullKeyboardAccessCommandMapData; // clients should use FKAAvailableCommands instead of accessing this directly
// @property (nonatomic) NSTimeInterval fullKeyboardAccessFocusRingTimeout;
// @property (nonatomic) BOOL fullKeyboardAccessFocusRingTimeoutEnabled;
// @property (nonatomic) BOOL fullKeyboardAccessLargeFocusRingEnabled;
// @property (nonatomic) BOOL fullKeyboardAccessFocusRingHighContrastEnabled;
// @property (nonatomic) AXAssistiveTouchCursorColor fullKeyboardAccessFocusRingColor;
// @property (nonatomic) BOOL fullKeyboardAccessShouldShowTextEditingModeInstructions;
// @property (nonatomic) BOOL fullKeyboardAccessShouldShowDebugKeyCommandsView;
// 
// #pragma mark-
// #pragma mark Gizmo
// @property(nonatomic) BOOL gizmoApplicationAccessibilityEnabled;
// @property(nonatomic) AXSVoiceOverSpeakSecondsEncoding voiceOverSpeakSecondsEncoding;
// 
// // For auto speak settings on watch faces
// - (void)gizmoSetAutoSpeakEnabledForComplication:(NSString *)complication slot:(NSString *)slot face:(NSData *)faceIdentifier toggle:(BOOL)toggle;
// - (BOOL)gizmoGetAutoSpeakEnabledForComplication:(NSString *)complication slot:(NSString *)slot face:(NSData *)faceIdentifier;
// 
// @property (nonatomic, strong) NSDictionary<NSString *, NSString *> *remoteHandGestureCustomizedActions;
// 
// #pragma mark -
// #pragma mark Miscellaneous
// 
// @property(nonatomic) float reduceWhitePointLevel;
// @property(nonatomic) BOOL shouldFlashForAlertInSilentMode;
// @property(nonatomic) BOOL shouldFlashWhileUnlocked;
// @property(nonatomic) BOOL shouldLimitDisplayRefreshRate;
// @property(nonatomic) BOOL supportsAdvancedDisplayFilters; // this essentially mirrors blueLightSupports but allows others to access outside backboard
// 
// @property(nonatomic) BOOL shouldSpeakMedicalPreamble;
// @property(nonatomic) BOOL shouldTTYMedicalPreamble;
// @property(nonatomic, retain) NSString *medicalPreamble;
// 
// // This shows a caption on the bottom of the screen and shows where UI strings come from
// @property(nonatomic) BOOL localizationQACaptionMode;
// @property(nonatomic) BOOL localizationQACaptionShowFilePath;
// @property(nonatomic) BOOL localizationQACaptionShowUSString;
// @property(nonatomic) BOOL localizationQACaptionShowLocalizedString;
// 
// // Testing
// @property (nonatomic) BOOL appValidationTestingMode;
// 
// // Usage counts
// @property (nonatomic) NSInteger brokenHomeButtonCount;
// @property (nonatomic) NSInteger voiceOverBSIUsageCount;
// @property (nonatomic) NSInteger guidedAccessUsageCount;
// @property (nonatomic) NSInteger magnifierUsageCount;
// @property (nonatomic) NSInteger guidedAccessTimeLimitsUsageCount;
// @property (nonatomic, copy) NSDictionary<NSString *, NSNumber *> *assistiveTouchUsageCount;
// @property (nonatomic) NSInteger tapticTimeUsageCount;
// @property (nonatomic) NSInteger characterVoicesUsageCount;
// @property (nonatomic) NSInteger hearingAidControlPanelCount;
// @property (nonatomic) NSInteger hearingAidHandOffCount;
// @property (nonatomic) NSInteger switchControlPlatformSwitchedCount;
// @property (nonatomic) CFAbsoluteTime lastMagnifierResetCount;
// @property (nonatomic) CFAbsoluteTime lastAssistiveTouchTimeResetCount;
// @property (nonatomic) CFAbsoluteTime lastCharacterVoiceTimeResetCount;
// @property (nonatomic) CFAbsoluteTime lastPlatformSwitchTimeResetCount;
// @property (nonatomic) CFAbsoluteTime lastGuidedAccessTimeLimitResetCount;
// @property (nonatomic) CFAbsoluteTime lastGuidedAccessTimeResetCount;
// @property (nonatomic) CFAbsoluteTime lastTapticTimeResetCount;
// @property (nonatomic) CFAbsoluteTime lastBrailleScreenInputTimeResetCount;
// @property (nonatomic) CFAbsoluteTime lastHearingAidControlPanelTimeResetCount;
// @property (nonatomic) CFAbsoluteTime lastHearingAidHandoffTimeResetCount;
// @property (nonatomic) CFAbsoluteTime lastSmartInvertColorsEnablement;
// 
// @property (nonatomic) BOOL didResetD22Preferences;
// 
// @property (nonatomic) BOOL reachabilityEnabled;
// 
// #if HAS_GUEST_MODE
// // Guest Mode
// @property (nonatomic, strong) NSArray<NSString *> *guestModeModifiedPreferenceKeys;
// - (void)restorePreGuestModeSessionSettingsAndNukePrefs;
// #endif
// 
// // Back Tap
// #if HAS_BACK_TAP
// @property (nonatomic, assign) BOOL backTapEnabled;
// @property (nonatomic, strong) AXAssistiveTouchIconType backTapDoubleTapAction;
// @property (nonatomic, strong) AXAssistiveTouchIconType backTapTripleTapAction;
// @property (nonatomic, assign) BOOL backTapFalsePositiveAlertsEnabled;
// @property (nonatomic, assign) NSInteger backTapUsageCount;
// #endif
// 
// #if AX_HAS_SYSTEM_VOICE_TRIGGER
// @property (nonatomic, strong) NSDictionary<NSString *, AXAssistiveTouchIconType> *actionsBySoundAction;
// #endif
// 
// #if AX_HAS_PER_APP_SETTINGS
// @property (nonatomic, copy) NSArray<NSString *> *perAppSettingsCustomizedAppIDs; // Array of appIDs that use Per-App Settings Customization
// @property (nonatomic, copy) NSDictionary *perAppSettingsStats; // Aggregated statistics for how many apps use Per-App Settings
// - (void)aggregatePerAppSettingsStatistics;
// - (void)addCustomizedAppID:(NSString *)appID;
// - (void)removeCustomizedAppID:(NSString *)appID;
// #endif
// 
// #if AX_HAS_AUDIOGRAM_INGESTION
// @property (nonatomic, assign) CFAbsoluteTime audiogramIngestionLastModelAccess;
// #endif
// 
// #if AX_HAS_VOICE_TRIGGERS
// @property (nonatomic, assign) CFAbsoluteTime soundActionsLastModelAccess;
// #if AX_HAS_MOSSDEEP
// @property (nonatomic, assign, getter=isSoundActionsForMossdeepEnabled) BOOL soundActionsForMossdeepEnabled;
// #endif
// #endif
// 
// #if HAS_MACHINE_LISTEN_SUPPORT
// @property (nonatomic, assign) CFAbsoluteTime soundDetectionLastModelAccess;
// #endif
// 
// #if AX_SUPPORTS_BOOT_SOUND
// @property (nonatomic, assign) BOOL startupSoundEnabled;
// #endif
// 
// #if TARGET_OS_VISION
// @property (nonatomic, readonly) BOOL shouldUseMotionDataForUserPresence;
// #endif
// 
// @end
// 
// @interface AXSettings (NotificationListenerSelectorsOnly)
// - (NSDictionary *)_audioHardwareChannelLayout;
@end

// @interface AXSettings (Testing)
// @property (nonatomic, copy) NSArray<AVSpeechSynthesisVoice *> *testingExtantVoices;
// @property (nonatomic, copy) NSArray<AVSpeechSynthesisVoice *> *testingProviderVoices;
// @end
// 
// #pragma mark - Support Funtions
// 
// AX_EXTERN BOOL AXShouldHideVoiceOverRotorItemFromSettings(NSDictionary *item);
// #if HAS_MOTION_TRACKING_SUPPORT
// AX_EXTERN BOOL AXShouldShowSwitchControlHeadTrackingModeFromSettings(void);
// #endif
// 
// // Returns the true speed for the scanner xy sweeper (in points per second), given the userPreference value which
// // has a normalized range of 1 to 120
// AX_EXTERN CGFloat assistiveTouchXYScannerSpeedForNormalizedUserPreference(NSInteger userPreference);
// // Returns the normalized user preference for speed (1 to 120), given the true speed preference for the sweeper (in points per second)
// AX_EXTERN NSInteger assistiveTouchXYScannerNormalizedUserPreferenceForSpeed(CGFloat xySweeperSpeed);
// #if HAS_MOTION_TRACKING_SUPPORT
// AX_EXTERN double switchControlNormalizedHeadTrackingSensitivityForUserPreference(NSInteger userPreference);
// AX_EXTERN NSInteger switchControlUserPreferenceForNormalizedHeadTrackingSensitivity(double sensitivity);
// AX_EXTERN double switchControlNormalizedHeadTrackingMovementToleranceInJoystickModeForUserPreference(NSInteger userPreference);
// AX_EXTERN NSInteger switchControlUserPreferenceForNormalizedHeadTrackingMovementToleranceInJoystickMode(double tolerance);
// AX_EXTERN double assistiveTouchNormalizedMotionTrackerSmoothingBufferSizeForUserPreference(NSUInteger userPreference);
// AX_EXTERN NSUInteger assistiveTouchUserPreferenceForNormalizedMotionTrackerSmoothingBufferSize(double bufferSize);
// #endif
// 
// AX_EXTERN BOOL AXShouldAskBeforeDisablingTransportMethods(void);
// 
// AX_EXTERN CGFloat const kAXSTouchAccommodationsHoldDurationSwipeGestureMinimumDistanceDefault;
// 
// #if HAS_GUEST_MODE
// #pragma mark - Guest Mode Keys
// 
// AX_EXTERN NSString *const AXGMKeyZoomSettings;
// AX_EXTERN NSString *const AXGMKeyZoomFilter;
// AX_EXTERN NSString *const AXGMKeyZoomLensMode;
// AX_EXTERN NSString *const AXGMKeyZoomControllerVisible;
// AX_EXTERN NSString *const AXGMKeyVoiceOverSettings;
// #endif
