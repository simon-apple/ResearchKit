//#if (defined(USE_UIKIT_PUBLIC_HEADERS) && USE_UIKIT_PUBLIC_HEADERS) || !__has_include(<UIKitCore/UIResponder_Private.h>)
/*
 *  UIResponder_Private.h
 *  UIKit
 *
 *  Created by Andrew Platzer on 10/15/07.
 *  Copyright (c) 2007-2019 Apple Inc. All rights reserved.
 *
 */

#import <UIKit/UIResponder.h>
#import <Foundation/Foundation.h>
//#import <GraphicsServices/GraphicsServices.h>
//#import <UIKit/UIKitDefines_Private.h>
//#import <UIKit/UIUndoGestureInteraction.h>
//#import <UIKit/NSItemProvider+UIKitAdditions_Private.h>
//#import <UIKit/UIKeyCommand_Private.h>
//#import <UIKit/UIResponder+UICopyConfiguration_Private.h>
//#import <UIKit/UITextInteraction.h>

@class UIImage;
@class _UIGameControllerEvent;
@class UIPromisedItem;
@protocol UIPredictiveViewController;

@interface UIResponder(Private)

//- (void)scrollWheel:(GSEventRef)event;
//
//- (void)gestureStarted:(GSEventRef)event;
//- (void)gestureEnded:(GSEventRef)event;
//- (void)gestureChanged:(GSEventRef)event;
//
//- (UIResponder *)firstResponder;
//
//- (BOOL)_containsResponder:(UIResponder *)responder;
//
//- (void)_clearBecomeFirstResponderWhenCapable;
//
//// Caution: _targetCanPerformBlock: does not skip over modal presentations. There is internal implementation that does.
//- (id)_targetCanPerformBlock:(BOOL (NS_NOESCAPE ^) (id self))block API_AVAILABLE(ios(11.0));
//
//// Override these to customize the key responder cycle.  Changing the root affects the scope of the cycle.
//- (UIResponder *)_nextKeyResponder;
//- (UIResponder *)_previousKeyResponder;
//- (BOOL)_isRootForKeyResponderCycle;
//- (void)_gatherKeyResponders:(NSMutableArray *)responders
//                 indexOfSelf:(NSUInteger *)indexOfSelf
//              visibilityTest:(BOOL (NS_NOESCAPE ^) (UIResponder *))visibleTest
//                 passingTest:(BOOL (NS_NOESCAPE ^) (UIResponder *))test
//                subviewsTest:(BOOL (NS_NOESCAPE ^) (UIResponder *))subviewsTest;
//
//- (void)_becomeFirstResponderAndMakeVisible;         // Called by tab key for scrolling first responder to visible position.
//
//@property (nonatomic, readonly) UIResponder *_responderForEditing; // Convenience which returns either self or a non-nil delegate.
//
//// Staged before API review
//- (void)pasteAndMatchStyle:(id)sender API_AVAILABLE(ios(12.0));
//- (void)makeTextWritingDirectionNatural:(id)sender API_AVAILABLE(ios(12.0));
//
//// Private edit actions, not implemented on UIResponder itself
//- (void)replace:(id)sender;
//- (void)_promptForReplace:(id)sender;
//- (void)_transliterateChinese:(id)sender;
//- (void)_insertDrawing:(id)sender;    // implemented in PencilKit
//- (void)_cancelOperation:(id)sender;
//- (void)_openInNewCanvas:(id)sender;
//
//#if UIKIT_MACCATALYST
//// Case changes
//- (void)uppercaseWord:(id)sender API_AVAILABLE(ios(12.0));
//- (void)lowercaseWord:(id)sender API_AVAILABLE(ios(12.0));
//- (void)capitalizeWord:(id)sender API_AVAILABLE(ios(12.0));
//#endif
//
//// Text services originating actions
//- (void)_addShortcut:(id)sender;
//- (void)_lookup:(id)sender;
//- (void)_translate:(id)sender;
//- (void)_share:(id)sender;
//- (void)_findSelected:(id)sender;
//
//// As long as any responder is pinning input views, they will not be animated off-screen.
//- (void)_beginPinningInputViews;
//- (void)_endPinningInputViews;
//- (BOOL)_isPinningInputViews;
//
//// Defaults to sending up the responder chain, where it is eventually handled by UIApplication.
//- (void)_handleKeyEvent:(GSEventRef)event;
//- (void)_handleKeyUIEvent:(UIEvent *)event;
//
//- (BOOL)_wantsPriorityOverFocusUpdates;
//
//// Defaults to sending up the responder chain, where it is eventually handled by UIApplication.
//- (void)_handleGameControllerEvent:(UIEvent *)event;
//
//// The nextFirstResponder is given an opportunity to becomeFirstResponder when this responder resigns
//// Defaults to the first item int he responder chain that canBecomeFirstResponder
//- (UIResponder *)nextFirstResponder;

- (UIWindow *)_responderWindow;// returns the window that anchors the responder chain that this is a member of
//
//// These are only sent to the first responders.
//- (void)_windowBecameKey;
//- (void)_windowResignedKey;
//- (BOOL)_isTransitioningFromView:(UIView *)fromView;
//
//// A reload of input views that never sets the delegate to nil
//- (void)reloadInputViewsWithoutReset;
//
//// returns YES if this UIResponder either overrides -inputAccessoryView, or has non-nil storage of it.
//- (BOOL)_ownsInputAccessoryView;
//
//@property (nonatomic, readonly, strong) __kindof UIView *recentsAccessoryView; // A custom view to be displayed above the Recents view
//
//@property (nonatomic, readonly, strong) UIViewController<UIPredictiveViewController> *inputDashboardViewController SPI_AVAILABLE(ios(16.0));
//
//- (void)_moveWithEvent:(UIEvent *)event API_AVAILABLE(ios(7.0));
//
//- (BOOL)_canChangeFirstResponder:(UIResponder *)firstResponder toResponder:(UIResponder *)responder;
//- (void)_willChangeToFirstResponder:(UIResponder *)firstResponder;
//- (void)_didChangeToFirstResponder:(UIResponder *)firstResponder;
//
//- (UIView *)_responderSelectionContainerViewForResponder:(UIResponder *)firstResponder;
//
//// Only used when responder selection is enabled
//- (UIImage *)_responderSelectionImage;
//
//- (void)_wheelChangedWithEvent:(UIEvent *)event;
//
//- (void)touchesEstimatedPropertiesUpdated:(NSSet *)touches API_AVAILABLE(ios(9.0));
//
//- (void)_showCustomInputView;
//
//// Called only on account-based apps
//// Both properties default to _UIDataOwnerUndefined, which will cause UIKit to walk up the responder chain for answers.
//@property (nonatomic, setter=_setDragDataOwner:) _UIDataOwner _dragDataOwner;
//@property (nonatomic, setter=_setDropDataOwner:) _UIDataOwner _dropDataOwner;
//
//@property (nonatomic, setter=_setDataOwnerForCopy:) _UIDataOwner _dataOwnerForCopy;
//@property (nonatomic, setter=_setDataOwnerForPaste:) _UIDataOwner _dataOwnerForPaste;
//
//// Suppress SW keyboard
//@property (nonatomic, setter=_setSuppressSoftwareKeyboard:) BOOL _suppressSoftwareKeyboard;
//
//- (UITextInteraction *)_textInteraction;
//
//// For Translation app only. The app will provide the additional languages to be included in the keyboard. Do not call this setter when handling text field change events.
//// The app can supply either language or language with region.
//// We only match language when comparing existing keyboards. e.g. when fr_FR is enabled but the app is adding fr_CA, we won't add fr_CA. But if none of French keyboards are enabled, we'll add fr_CA, that's when the region is used.
//@property (nonatomic, strong, readonly) NSArray<NSLocale *> *_additionalTextInputLocales;

@end

//@class UIViewController;
//
//UIKIT_EXTERN NSString *const UITextInputContextIdentifierDataDidUpdateNotification API_AVAILABLE(ios(8.2));
//UIKIT_EXTERN NSString *const UITextInputContextIdentifierPreferencesDomainKey API_AVAILABLE(ios(8.2));
//UIKIT_EXTERN NSString *const UITextInputContextIdentifierPreferencesIdentifierKey API_AVAILABLE(ios(8.2));
//UIKIT_EXTERN NSString *const UITextInputContextIdentifierPreferencesIdentifierSetTimeKey API_AVAILABLE(ios(16.0));
//UIKIT_EXTERN NSString *const UITextInputContextIdentifierPreferencesDomain API_AVAILABLE(ios(8.2));
//UIKIT_EXTERN NSString *const UITextInputContextIdentifierPreferencesPrefix API_AVAILABLE(ios(8.2));
//UIKIT_EXTERN NSString *const UITextInputContextIdentifierPreferencesSetTimeSuffix API_AVAILABLE(ios(16.0));
//
//
//UIKIT_EXTERN NSString *const UIKeyInputEmpty          API_AVAILABLE(ios(8.3));    // for matching lone modifier keys
//
//#else
//#import <UIKitCore/UIResponder_Private.h>
//#endif
