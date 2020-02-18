//
//  SUICFlamesViewProviding.h
//  SiriUICore
//
//  Created by Peter Bohac on 5/28/19.
//  Copyright © 2019 Apple Inc. All rights reserved.
//
#ifndef SUICFlamesViewProviding_h
#define SUICFlamesViewProviding_h
#import <UIKit/UIKit.h>
#import "SUICFlamesViewTypes.h"
NS_ASSUME_NONNULL_BEGIN
@protocol SUICFlamesViewProviding;
@protocol SUICFlamesViewProvidingDelegate <NSObject>
@required
- (float)audioLevelForFlamesView:(id<SUICFlamesViewProviding>)flamesView;
@optional
- (void)flamesViewAuraDidDisplay:(id<SUICFlamesViewProviding>)flamesView;
@end
@protocol SUICFlamesViewProviding <NSObject>
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
/**
 Returns YES when OpenGL ES / Metal rendering is enabled.
 Always returns YES if `renderInBackground` is enabled.
 */
@property (nonatomic, assign, readonly) BOOL isRenderingEnabled;
/**
 Delegate for flames related events that need to be handled.
 */
@property (nullable, nonatomic, weak) id<SUICFlamesViewProvidingDelegate> flamesDelegate;
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
@property (nonatomic, assign) BOOL flamesPaused;
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
#endif /* SUICFlamesViewProviding_h */
