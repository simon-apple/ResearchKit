//
//  SUICFlamesView.h
//  SiriUICore
//
//  Created by Peter Bohac on 5/25/19.
//  Copyright © 2019 Apple Inc. All rights reserved.
//

#ifndef SUICFlamesView_h
#define SUICFlamesView_h

#import <UIKit/UIKit.h>
#import "SUICFlamesViewTypes.h"

NS_ASSUME_NONNULL_BEGIN

@class SUICFlamesView;

@protocol SUICFlamesViewDelegate <NSObject>

@required

- (float)audioLevelForFlamesView:(SUICFlamesView *)flamesView;

@optional

- (void)flamesViewAuraDidDisplay:(SUICFlamesView *)flamesView;

@end

/**
 This is a container class that determines (at run-time) whether to host a GL-based or Metal-based implementation of the flames view.
 */
@interface SUICFlamesView : UIView
/**
 Initialise a new `SUICFlamesView`.
 @param frame The provided frame is the space to render the aura.
 @param screen The `UIScreen` that the flames view will be displayed on.
 @param fidelity The quality of the renderer. This value is ignored when setting mode to SUICFlamesViewModeDictation because this mode generates a fidelity based on the activeFrame's width. Low fidelity is intended to be used by Apple Watch.
 */
- (instancetype)initWithFrame:(CGRect)frame screen:(UIScreen *)screen fidelity:(SUICFlamesViewFidelity)fidelity;
/**
 Prewarm shaders for flames view that has already been intialized but won't be displayed right away. If mode hasn't been set, it was compile the shaders for the default mode (Siri).
 Calls into Metal intialization code (when Metal support is detected), which is responsible for loading shaders and preparing pipelines. When shaders are loaded the first time on boot, the system will take additional time to run a full compile of these shaders. Calling prewarmShaders on boot will ensure the device has these shaders built and ready in the cache.
 @warning The call should be from a utility thread thread only, as this will spin up other processes based on this priority. Setting too low of a priority will cause this shared resource to get stuck scheduling our compile. Setting too high of a priority will slow down other parts of the system.
 */
- (void)prewarmShadersForCurrentMode;
/**
 Enables or disables OpenGL ES / Metal rendering for a specific reason.
 This setting is ignored if `renderInBackground` is enabled.
 */
- (void)setRenderingEnabled:(BOOL)enabled forReason:(NSString *)reason;
- (void)fadeOutCurrentAura;
/**
 This will remove all non-current flames (including the aura) from the view.
 @param initialize Will re-initialize frame and vertex buffers as well as removing non-current flames from the view.
 */
- (void)resetAndReinitialize:(BOOL)initialize;
- (void)resetAndReinitializeMetal:(BOOL)initialize NS_DEPRECATED_IOS(13_0, 13_0, "Please use resetAndReinitialize: instead");
/**
 Returns YES when OpenGL ES / Metal rendering is enabled.
 Always returns YES if `renderInBackground` is enabled.
 */
@property (nonatomic, assign, readonly) BOOL isRenderingEnabled;
/**
 Delegate for flames related events that need to be handled.
 */
@property (nullable, nonatomic, weak) id<SUICFlamesViewDelegate> flamesDelegate;
//TODO: Remove this method once clients have adopted flamesDelegate. <rdar://problem/47130299> Remove setDelegate from SUICFlamesView
- (void)setDelegate:(nullable id<SUICFlamesViewDelegate>)delegate;
/**
 Changes the overall appearance of the view.
 If layoutSubviews has already happened, GL / Metal data will re-initialize.
 */
@property (nonatomic, assign) SUICFlamesViewMode mode;
/**
 Changes view behavior of the view.
 */
@property (nonatomic, assign) SUICFlamesViewState state;
/**
 Hides / shows the aura. Default is YES.
 */
@property (nonatomic, assign) BOOL showAura;
/**
 Freezes the aura after the flash and doesn't continue animating.
 Default is NO.
 */
@property (nonatomic, assign) BOOL freezesAura;
/**
 This will lower the frame rate of the renderer in certain modes.
 Default is NO.
 @warning Ask before using this.
 */
@property (nonatomic, assign) BOOL reduceFrameRate;
/**
 When YES, the thinking state framerate will be reduced to 20fps.
 Default is NO.
 @warning Use with extreme caution, please ask first.
 */
@property (nonatomic, assign) BOOL reduceThinkingFramerate;
/**
 The bounds of the wave form in all states except SUICFlamesViewStateSuccess.
 In dictation mode, if layoutSubviews has already happened, GL / Metal data will re-initialize.
 */
@property (nonatomic, assign) CGRect activeFrame;
/**
 When assigned, the image is overlaid above the GL / Metal rendering at all times.
 The image will be stretched to fill the view's frame.
 Defaults to nil, or no overlay image.
 */
@property (nullable, nonatomic, strong) UIImage *overlayImage;
/**
 When set, specifies the color used to render the dictation UI. This has no effect on non-dictation modes. Ignores alpha values.
 Defaults to white.
 */
@property (nonatomic, strong) UIColor *dictationColor;
/**
 When YES, the EAGL / Metal context will allow rendering while the hosting app is backgrounded.
 Defaults to NO.
 @warning Use with extreme caution, please ask first.
 */
@property (nonatomic, assign) BOOL renderInBackground;
/**
 Defaullts to NO.
 */
@property (nonatomic, assign) BOOL paused;
/**
 This will scale the GL / Metal context horizontally, and scale the layer correspondingly to fill the frame.
 For example, a scale of 0.1 will substantially reduce the GL overhead, which is useful for when the GPU is software emulated.
 Default is 1.0.
 */
@property (nonatomic, assign) CGFloat horizontalScaleFactor;
/**
 Default is NO.
 */
@property (nonatomic, assign) BOOL accelerateTransitions;
@end
NS_ASSUME_NONNULL_END

#endif /* SUICFlamesView_h */
