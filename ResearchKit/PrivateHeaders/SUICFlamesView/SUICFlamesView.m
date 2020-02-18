//
//  SUICFlamesView.m
//  SiriUICore
//
//  Created by Peter Bohac on 5/25/19.
//  Copyright © 2019 Apple Inc. All rights reserved.
//
#import "SUICFlamesView.h"
#import "SUICFlamesViewMetal.h"
#import "SUICFlamesViewLegacy.h"

@interface SUICFlamesView () <SUICFlamesViewProvidingDelegate>
@end
@implementation SUICFlamesView
{
    UIView<SUICFlamesViewProviding> *_flamesView;
};
+ (BOOL)_isMetalAvailable {
    // Always use Metal on real devices. On the simulator, perform a run-time check for Metal support.
#if !TARGET_OS_SIMULATOR
    return YES;
#else
    id<MTLDevice> device = MTLCreateSystemDefaultDevice();
    return (device != nil);
#endif
}
- (instancetype)initWithFrame:(CGRect)frame screen:(UIScreen *)screen fidelity:(SUICFlamesViewFidelity)fidelity {
    self = [super initWithFrame:frame];
    if (self)
    {
        if ([SUICFlamesView _isMetalAvailable])
        {
            if (@available(iOS 13.0, *))
            {
                _flamesView = [[SUICFlamesViewMetal alloc] initWithFrame:frame screen:screen fidelity:fidelity];
            }
            else
            {
                _flamesView = [[SUICFlamesViewLegacy alloc] initWithFrame:frame screen:screen fidelity:fidelity];
            }
        }
        else
        {
            _flamesView = [[SUICFlamesViewLegacy alloc] initWithFrame:frame screen:screen fidelity:fidelity];
        }
    }
    return self;
}
- (void)layoutSubviews {
    [super layoutSubviews];
    [_flamesView setFrame:[self bounds]];
}
- (void)setHidden:(BOOL)hidden {
    [super setHidden:hidden];
    [_flamesView setHidden:hidden];
}
- (void)didMoveToSuperview {
    [super didMoveToSuperview];
    if ([self superview] == nil) {
        [_flamesView removeFromSuperview];
    } else {
        [self addSubview:_flamesView];
    }
}
#pragma mark - SUICFlamesViewProviding
- (void)prewarmShadersForCurrentMode {
    [_flamesView prewarmShadersForCurrentMode];
}
- (void)setRenderingEnabled:(BOOL)enabled forReason:(NSString *)reason {
    [_flamesView setRenderingEnabled:enabled forReason:reason];
}
- (void)fadeOutCurrentAura {
    [_flamesView fadeOutCurrentAura];
}
- (void)resetAndReinitializeMetal:(BOOL)initialize {
    [self resetAndReinitialize:initialize];
}
- (void)resetAndReinitialize:(BOOL)initialize {
    [_flamesView resetAndReinitialize:initialize];
}
- (void)setDelegate:(id<SUICFlamesViewDelegate>)delegate {
    [self setFlamesDelegate:delegate];
}
- (void)setFlamesDelegate:(id<SUICFlamesViewDelegate>)flamesDelegate {
    _flamesDelegate = flamesDelegate;
    if (flamesDelegate) {
        [_flamesView setFlamesDelegate:self];
    } else {
        [_flamesView setFlamesDelegate:nil];
    }
}
- (BOOL)isRenderingEnabled {
    return [_flamesView isRenderingEnabled];
}
- (SUICFlamesViewMode)mode {
    return [_flamesView mode];
}
- (void)setMode:(SUICFlamesViewMode)mode {
    [_flamesView setMode:mode];
}
- (SUICFlamesViewState)state {
    return [_flamesView state];
}
- (void)setState:(SUICFlamesViewState)state {
    [_flamesView setState:state];
}
- (BOOL)showAura {
    return [_flamesView showAura];
}
- (void)setShowAura:(BOOL)showAura {
    [_flamesView setShowAura:showAura];
}
- (BOOL)freezesAura {
    return [_flamesView freezesAura];
}
- (void)setFreezesAura:(BOOL)freezesAura {
    [_flamesView setFreezesAura:freezesAura];
}
- (BOOL)reduceFrameRate {
    return [_flamesView reduceFrameRate];
}
- (void)setReduceFrameRate:(BOOL)reduceFrameRate {
    [_flamesView setReduceFrameRate:reduceFrameRate];
}
- (BOOL)reduceThinkingFramerate {
    return [_flamesView reduceThinkingFramerate];
}
- (void)setReduceThinkingFramerate:(BOOL)reduceThinkingFramerate {
    [_flamesView setReduceThinkingFramerate:reduceThinkingFramerate];
}
- (CGRect)activeFrame {
    return [_flamesView activeFrame];
}
- (void)setActiveFrame:(CGRect)activeFrame {
    [_flamesView setActiveFrame:activeFrame];
}
- (UIImage *)overlayImage {
    return [_flamesView overlayImage];
}
- (void)setOverlayImage:(UIImage *)overlayImage {
    [_flamesView setOverlayImage:overlayImage];
}
- (UIColor *)dictationColor {
    return [_flamesView dictationColor];
}
- (void)setDictationColor:(UIColor *)dictationColor {
    [_flamesView setDictationColor:dictationColor];
}
- (BOOL)renderInBackground {
    return [_flamesView renderInBackground];
}
- (void)setRenderInBackground:(BOOL)renderInBackground {
    [_flamesView setRenderInBackground:renderInBackground];
}
- (BOOL)paused {
    return [_flamesView flamesPaused];
}
- (void)setPaused:(BOOL)paused {
    [_flamesView setFlamesPaused:paused];
}
- (CGFloat)horizontalScaleFactor {
    return [_flamesView horizontalScaleFactor];
}
- (void)setHorizontalScaleFactor:(CGFloat)horizontalScaleFactor {
    [_flamesView setHorizontalScaleFactor:horizontalScaleFactor];
}
- (BOOL)accelerateTransitions {
    return [_flamesView accelerateTransitions];
}
- (void)setAccelerateTransitions:(BOOL)accelerateTransitions {
    [_flamesView setAccelerateTransitions:accelerateTransitions];
}
#pragma mark - SUICFlamesViewProvidingDelegate
- (float)audioLevelForFlamesView:(id<SUICFlamesViewProviding>)flamesView {
    return [[self flamesDelegate] audioLevelForFlamesView:self];
}
- (void)flamesViewAuraDidDisplay:(id<SUICFlamesViewProviding>)flamesView {
    if ([[self flamesDelegate] respondsToSelector:@selector(flamesViewAuraDidDisplay:)]) {
        [[self flamesDelegate] flamesViewAuraDidDisplay:self];
    }
}
@end
