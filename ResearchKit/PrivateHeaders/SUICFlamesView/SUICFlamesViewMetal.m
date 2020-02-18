//
//  SUICFlamesViewMetal.m
//
//  Created by Brandon Newendorp on 3/5/13.
//  Copyright (c) 2013-2014 Apple Inc. All rights reserved.
//
#import "SUICFlamesViewMetal.h"
#import "SUICFlameGroup.h"
#import "SUICFlamesShaderTypes.h"
//#import <AssistantServices/AFLogging.h>
//#import <AssistantServices/AFSignposts.h>
#import "SUICIndexCacheEntry.h"
#import "SUICAudioLevelSmoother.h"
//#import <MobileGestalt.h>
#import <QuartzCore/CAMetalLayer.h>
#import <QuartzCore/CADisplayLink.h>
#include <simd/simd.h>
#if !TARGET_OS_SIMULATOR
//#include <libproc_internal.h>
#endif
#define ENABLE_INDEX_CACHING 0

static const float kGlobalAlphaFadeSpeedIncrement = 0.03; // varies how fast the aura fades out when a new one is incoming.
static const CGFloat kMinimumPowerLevel = 0.05; // determines the lowest the flames can go
static const CGFloat kMaximumPowerLevel = 1.0; // determines the highest the flames can go
static const int kNumPowerLevels = 5;
static NSString * const kSUICFlamesViewUIApplicationNotificationReason = @"kSUICFlamesViewUIApplicationNotificationReason";
static NSUInteger sIndexCacheSize = 5;
#pragma mark - Implementation
@implementation SUICFlamesViewMetal
{
    CADisplayLink *_displayLink;
    NSInteger _currentContextCount;
    NSMutableSet *_renderingDisabledReasons;
    
    uint32_t _framebufferHandle;
    uint32_t _renderbufferHandle;
    int32_t  _flameProgramHandle, _auraProgramHandle, _vShadID, _fShadID;
    uint32_t _vertexArrayObjectHandle, _vertexBufferHandle, _elementArrayHandle;
    uint64_t _numIndices;
    uint64_t _numVertices;
    uint32_t _numAuraIndices;
    uint32_t _numAuraIndicesCulled;
    uint32_t _numWaveIndices;
    
    // the following contribute to the complete VBO. set from fidelity setting
    uint32_t _maxVertexCircles;
    uint32_t _auraVertexCircles;
    float _maxSubdivisionLevel;
    float _auraMinSubdivisionLevel;
    float _auraMaxSubdivisionLevel;
    
    NSMutableArray *_flameGroups;
    SUICFlameGroup *_currentFlameGroup;
    
    float _viewWidth;
    float _viewHeight;
    float _dictationUnitSize;
    UIScreen *_screen;
    
    UIImageView *_overlayImageView;
    
    CFTimeInterval _startTime;
    
    CGFloat _dictationRedColor, _dictationGreenColor, _dictationBlueColor;
    
    SUICAudioLevelSmoother *_levelSmoother;
    SUICFlamesViewFidelity _fidelity;
    
    CGFloat _frameRateScalingFactor;
    
    BOOL _transitionFinished;
    
    BOOL _isInitialized;
    BOOL _hasCustomActiveFrame;
    BOOL _shadersAreCompiled;
    
    BOOL _reduceMotionEnabled;
    
    // Our render pipeline composed of our vertex and fragment shaders in the .metal shader file
    id<MTLRenderPipelineState> _pipelineState[SUICFlamesViewModeNumModes];
    
    // The command Queue from which we'll obtain command buffers.  These have a large memory footprint and will be deallocated when not in use.
    id<MTLCommandQueue> _commandQueue;
    
    // GPU buffer which will contain our vertex array
    id<MTLBuffer> _vertexBuffer;
    id<MTLBuffer> _indexBuffer;
    
    // The current size of our view so we can use this in our render pipeline
    vector_uint2 _viewportSize;
};
@dynamic delegate;
@synthesize flamesDelegate = _flamesDelegate;
@synthesize accelerateTransitions = _accelerateTransitions;
@synthesize state = _state;
@synthesize showAura = _showAura;
@synthesize activeFrame = _activeFrame;
@synthesize dictationColor = _dictationColor;
@synthesize freezesAura = _freezesAura;
@synthesize horizontalScaleFactor = _horizontalScaleFactor;
@synthesize mode = _mode;
@synthesize overlayImage = _overlayImage;
@synthesize reduceFrameRate = _reduceFrameRate;
@synthesize reduceThinkingFramerate = _reduceThinkingFramerate;
@synthesize renderInBackground = _renderInBackground;
@synthesize flamesPaused = _flamesPaused;
- (void)_setValuesForFidelity:(SUICFlamesViewFidelity)fidelity {
    
    // forceably setting fidelity to needed fidelity for SUICWaveViewModeDictation
    if (_mode == SUICFlamesViewModeDictation) {
        _maxVertexCircles = 1;
        const CGFloat currentDisplayScale = [self _currentDisplayScale];
        float idealUnitSize = 6.0 * currentDisplayScale;
        
        // 3 * 2 ^ x. where x = (device-activeFrame-width * 2(upper and lower histogram vertex) / idealUnitSize).
        // value example for calulator: 3*2^((log(width * 2(screenscale) * 2(verts per histogram region) * 2(top and bottom) / 12 / 3))) / log(2))
        _maxSubdivisionLevel = logf(roundf(fmaxf(idealUnitSize, _activeFrame.size.width * currentDisplayScale * _horizontalScaleFactor) / idealUnitSize / 3.0f) * 4.0f) / logf(2);
        _dictationUnitSize = (_activeFrame.size.width * currentDisplayScale * _horizontalScaleFactor) / ((float)[self _numVerticesPerCircle] / 4.0);
        _auraVertexCircles = _maxVertexCircles;
        _auraMinSubdivisionLevel = 0;
        _auraMaxSubdivisionLevel = 0;
        return;
    }
    
    switch (fidelity) {
            // vertices in use for wave: 3*2^6 - 3*2^6 + 3*2^6
            // elements in use for wave: (3*2^6 - 3*2^6) * 3 + (3*2^6 - 2) (fill verts)
            // vertices in use for aura: 3*2^3 - 3*2^1 +         (6 - 3 - 1) *     3*2^3
            // elements in use for aura: (3*2^3 - 3*2^1) * 3 +   (6 - 1 - 3 - 1) * 3*2^3 * 2 + (3*2^1 - 2) (fill verts)
        case SUICFlamesViewFidelityLow:
            _maxVertexCircles = 6;
            _maxSubdivisionLevel = 6;
            _auraVertexCircles = _maxVertexCircles;
            _auraMinSubdivisionLevel = 1;
            _auraMaxSubdivisionLevel = 3;
            break;
            
            // vertices in use for wave: 3*2^7 - 3*2^7 + 3*2^7
            // elements in use for wave: (3*2^7 - 3*2^7) * 3 + (3*2^7 - 2) (fill verts)
            // vertices in use for aura: 3*2^3 - 3*2^1 +         (12 - 3 - 1) *     3*2^3
            // elements in use for aura: (3*2^3 - 3*2^1) * 3 +   (12 - 1 - 3 - 1) * 3*2^3 * 2 + (3*2^1 - 2) (fill verts)
        case SUICFlamesViewFidelityMedium:
            _maxVertexCircles = 12;
            _maxSubdivisionLevel = 7;
            _auraVertexCircles = _maxVertexCircles;
            _auraMinSubdivisionLevel = 1;
            _auraMaxSubdivisionLevel = 3;
            break;
            
            // vertices in use for wave: 3*2^8 - 3*2^8 + 3*2^8
            // elements in use for wave: (3*2^8 - 3*2^8) * 3 + (3*2^8 - 2) (fill verts)
            // vertices in use for aura: 3*2^4 - 3*2^1 +         (18 - 4 - 1) *     3*2^4
            // elements in use for aura: (3*2^4 - 3*2^1) * 3 +   (18 - 1 - 3 - 1) * 3*2^4 * 2 + (3*2^1 - 2) (fill verts)
        case SUICFlamesViewFidelityHigh:
            _maxVertexCircles = 18;
            _maxSubdivisionLevel = 8;
            _auraVertexCircles = _maxVertexCircles;
            _auraMinSubdivisionLevel = 1;
            _auraMaxSubdivisionLevel = 4;
            break;
    }
}
- (id)initWithFrame:(CGRect)frame screen:(UIScreen *)screen fidelity:(SUICFlamesViewFidelity)fidelity {
    self = [super initWithFrame:frame];
    if (self) {
        _reduceMotionEnabled = UIAccessibilityIsReduceMotionEnabled();
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_reduceMotionStatusChanged:) name:UIAccessibilityReduceMotionStatusDidChangeNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_applicationWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_applicationWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_applicationDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
        
        _levelSmoother = [[SUICAudioLevelSmoother alloc] initWithMinimumPower:-60.0 maximumPower:-10.0 historyLength:kNumPowerLevels attackSpeed:0.35 decaySpeed:0.9];
        _screen = screen;
        _showAura = YES;
        [self setMode:SUICFlamesViewModeDictation];
        _fidelity = fidelity;
        [self _setValuesForFidelity:fidelity];
        
        _activeFrame = [self bounds];
        _currentContextCount = 0;
        
        _horizontalScaleFactor = 1.0;
        _frameRateScalingFactor = 1.0;
        
        _state = SUICFlamesViewStateAboutToListen;
        
        _dictationRedColor = 1.0;
        _dictationGreenColor = 1.0;
        _dictationBlueColor = 1.0;
        
        _flameGroups = [[NSMutableArray alloc] init];
        _currentFlameGroup = [[SUICFlameGroup alloc] init];
        [_flameGroups addObject:_currentFlameGroup];
        
        _renderingDisabledReasons = [NSMutableSet set];
        [self setClearColor:MTLClearColorMake(0.0, 0.0, 0.0, 0.0)];
    }
    
    return self;
}
- (id)initWithFrame:(CGRect)frame screenScale:(CGFloat)screenScale fidelity:(SUICFlamesViewFidelity)fidelity {
    return [self initWithFrame:frame screen:[UIScreen mainScreen] fidelity:fidelity];
}
- (void)dealloc {
    [self _tearDownDisplayLink];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (void)didMoveToSuperview {
    // required to avoid memory leak due to circular dependency
    if ([self superview] == nil) {
        [self _tearDownDisplayLink];
    } else {
        [self _setupDisplayLink];
        // Set UIKit properties here to ensure that they only are called when the
        // view is to be displayed and not as part of prewarming in background.
        [self setBackgroundColor:[UIColor clearColor]];
        [self setUserInteractionEnabled:NO];
    }
}

+ (Class)layerClass API_AVAILABLE(ios(13)) {
    return [CAMetalLayer class];
}

- (void)setFlamesDelegate:(id<SUICFlamesViewProvidingDelegate>)delegate {
    if (delegate == nil && _displayLink) {
        [self _tearDownDisplayLink];
    }
    
    _flamesDelegate = delegate;
}
- (void)setState:(SUICFlamesViewState)state {
    if (_state != state) {
        _transitionFinished = NO;
        _state = state;
        _currentFlameGroup.transitionPhase = _accelerateTransitions ? 0.25f : 0.0f;
        _currentFlameGroup.stateTime = 0.0f;
        if (state == SUICFlamesViewStateSuccess) {
            if (_showAura) {
                // set current to aura state before creating a new wave system
                _currentFlameGroup.isAura = YES;
                
                // for all other flames, we know they must be Auras, so set them to die off since we have a new aura.
                for (SUICFlameGroup *flames in _flameGroups) {
                    if (flames != _currentFlameGroup) {
                        flames.isDyingOff = YES;
                    }
                }
                _state = SUICFlamesViewStateAboutToListen;
                _currentFlameGroup = [[SUICFlameGroup alloc] init];
                [_flameGroups addObject:_currentFlameGroup];
            } else {
                _state = SUICFlamesViewStateAboutToListen;
            }
        }
        
        [self _setPreferredFramesPerSecond];
        [self _updateDisplayLinkPausedState];
    }
}
- (void)fadeOutCurrentAura {
    for (SUICFlameGroup *flames in _flameGroups) {
        if ([flames isAura]) {
            [flames setIsDyingOff:YES];
        }
    }
}
#pragma mark - MG Querying
+ (BOOL)_supportsAdaptiveFramerate {
    static BOOL supportsAdaptiveFramerate = NO;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        supportsAdaptiveFramerate = NO;
    });
    
    return supportsAdaptiveFramerate;
}
- (void)_setPreferredFramesPerSecond {
    // Default value is zero, which means the display link will fire at the native cadence of the display hardware
    NSInteger preferredFramesPerSecond = 0;
    
    if (_flamesPaused)
    {
        preferredFramesPerSecond = 10;
    } else {
        // on Perseus-enabled devices, reduce frame rate during certain states to save power
        if ([[self class] _supportsAdaptiveFramerate]) {
            switch (_state) {
                case SUICFlamesViewStateAboutToListen:
                case SUICFlamesViewStateSuccess:
                case SUICFlamesViewStateDisabled:
                    preferredFramesPerSecond = 30;
                    break;
                    
                case SUICFlamesViewStateThinking:
                case SUICFlamesViewStateListening:
                    break;
            }
        }
        
        if (_mode == SUICFlamesViewModeSiri && _state == SUICFlamesViewStateThinking && _reduceThinkingFramerate) {
            preferredFramesPerSecond = 20;
            _frameRateScalingFactor = [_screen maximumFramesPerSecond] / preferredFramesPerSecond;
            
            // if it would actually speed up the framerate, keep it the same
            if (_frameRateScalingFactor < 1.0) {
                _frameRateScalingFactor = 1.0;
            }
            
        } else if (_reduceFrameRate) {
            switch (_mode) {
                case SUICFlamesViewModeSiri:
                case SUICFlamesViewModeHeySiriTraining:
                    if (_state != SUICFlamesViewStateThinking) {
                        preferredFramesPerSecond = 30;
                    }
                    break;
                    
                case SUICFlamesViewModeDictation:
                    preferredFramesPerSecond = 30;
                    break;
                    
                default:
                    preferredFramesPerSecond = 30;
                    break;
            }
        }
    }
    [_displayLink setPreferredFramesPerSecond:preferredFramesPerSecond];
}
- (NSInteger)_preferredFramesPerSecond {
    return [_displayLink preferredFramesPerSecond];
}
- (void)_updateDisplayLinkPausedState {
    if (_state == SUICFlamesViewStateThinking || _state == SUICFlamesViewStateListening) {
        // We don't really want to pause the display link in thinking or listening states
        [_displayLink setPaused:NO];
    } else if ((!_showAura || _freezesAura) && _state == SUICFlamesViewStateAboutToListen && _transitionFinished) {
        // if the aura is disabled or frozen, there's no need to have the display link continue to fire needlessly.
        [_displayLink setPaused:YES];
    } else {
        [_displayLink setPaused:_flamesPaused];
    }
}
#pragma mark - Setters
-(void)setMode:(SUICFlamesViewMode)mode {
    if (_mode == mode) {
        return;
    }
    _shadersAreCompiled = NO;
    _mode = mode;
    
    if (_mode == SUICFlamesViewModeDictation) {
        [self _setValuesForFidelity:0];
    }
    
    // Anytime a mode changes, it requires re-initialization of Metal data.
    if (_isInitialized) {
        [self _initMetalAndSetupDisplayLink:YES];
    }
}
- (void)setHidden:(BOOL)hidden {
    [super setHidden:hidden];
    
    if (hidden) {
        [self _tearDownDisplayLink];
    } else {
        if (_isInitialized) {
            [self _setupDisplayLink];
        }
    }
}
- (void)setDictationColor:(UIColor *)dictationColor {
    if (dictationColor != _dictationColor) {
        _dictationColor = dictationColor;
        
        [_dictationColor getRed:&_dictationRedColor green:&_dictationGreenColor blue:&_dictationBlueColor alpha:nil];
    }
}
- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    
    // when we're using dictation mode, we need to ensure that we're setting the fidelity according to the activeFrame's width. This requires re-initialization of Metal data.
    if (!_hasCustomActiveFrame) {
        _activeFrame = [self bounds];
    }
    if (_mode == SUICFlamesViewModeDictation) {
        [self _setValuesForFidelity:0]; // we need to reset the fidelity values since it relies on activeFrame width
        if (_isInitialized) {
            [self _initMetalAndSetupDisplayLink:YES];
        }
    }
    
    // keep the overlayImageView tied to the view's frame
    [_overlayImageView setFrame:[self frame]];
}
- (void)setBounds:(CGRect)bounds {
    [super setBounds:bounds];
    
    if (!_hasCustomActiveFrame) {
        _activeFrame = [self bounds];
    }
}
- (void)setActiveFrame:(CGRect)subFrame {
    // multiply by screen scale
    _activeFrame = CGRectMake(subFrame.origin.x, subFrame.origin.y, subFrame.size.width, subFrame.size.height);
    _hasCustomActiveFrame = YES;
    
    // when we're using dictation mode, we need to ensure that we're setting the fidelity according to the activeFrame's width. This requires re-initialization of Metal data.
    if (_mode == SUICFlamesViewModeDictation) {
        [self _setValuesForFidelity:0]; // we need to reset the fidelity values since it relies on activeFrame width.
        if (_isInitialized) {
            [self _initMetalAndSetupDisplayLink:YES];
        }
    }
}
- (void)setOverlayImage:(UIImage *)overlayImage {
    _overlayImage = overlayImage;
    
    if (_overlayImage) {
        _overlayImageView = [[UIImageView alloc] initWithImage:overlayImage];
        [_overlayImageView setFrame:[self frame]];
        [self addSubview:_overlayImageView];
        
    } else {
        [_overlayImageView removeFromSuperview];
        _overlayImageView = nil;
    }
}
- (void)setRenderInBackground:(BOOL)renderInBackground {
    _renderInBackground = renderInBackground;
}
- (BOOL)flamesPaused {
    return _flamesPaused;
}
- (void)setFlamesPaused:(BOOL)paused {
    _flamesPaused = paused;
    
    // We need to pause _displayLink only for states where the waveform is not visible.
    // Otherwise, we just reduce FPS to a minimum so the waveform is not "jumping" when you change the view's bounds.
    // This "jumping" is happening because the waveform is rendered relatively to the view's frame using display link.
    // Reducing FPS allows to render a few frames while rotation is happening, so the transition is much smoother than
    // just pausing the display link before rotation and resuming after.
    // Still it's preferable to pause rendering completely when possible, since it yields a better performance.
    [self _setPreferredFramesPerSecond];
    [self _updateDisplayLinkPausedState];
}
- (void)setHorizontalScaleFactor:(CGFloat)horizontalScaleFactor {
    _horizontalScaleFactor = horizontalScaleFactor;
    
    if (horizontalScaleFactor != 0.0) {
        [[self layer] setAffineTransform:CGAffineTransformMakeScale(1.0/_horizontalScaleFactor, 1.0)];
        [self _setValuesForFidelity:_fidelity];
    }
}
- (void)setRenderingEnabled:(BOOL)enabled forReason:(NSString *)reason {
    if (enabled) {
        [_renderingDisabledReasons removeObject:reason];
    } else {
        [_renderingDisabledReasons addObject:reason];
    }
    
    if ([self isRenderingEnabled]) {
        [self setNeedsLayout];
    }
}
#pragma mark - Prewarming
+ (void)prewarmShadersForScreen:(UIScreen *)screen size:(CGSize)size {
    [self prewarmShadersForScreen:screen size:size fidelity:SUICFlamesViewFidelityHigh];
}
+ (void)prewarmShadersForScreen:(UIScreen *)screen size:(CGSize)size fidelity:(SUICFlamesViewFidelity)fidelity {
    [self prewarmShadersForScreen:screen size:size fidelity:fidelity prewarmInBackground:NO];
}
+ (void)prewarmShadersForScreen:(UIScreen *)screen size:(CGSize)size fidelity:(SUICFlamesViewFidelity)fidelity prewarmInBackground:(BOOL)prewarmInBackground {
    CGRect frame = screen.bounds;
    frame.size.height = size.height;
    frame.size.width = size.width;
    
    [self prewarmShadersForScreen:screen initialFrame:frame activeFrame:frame fidelity:fidelity prewarmInBackground:prewarmInBackground];
}
+ (void)prewarmShadersForScreen:(UIScreen *)screen activeFrame:(CGRect)activeFrame fidelity:(SUICFlamesViewFidelity)fidelity {
    [self prewarmShadersForScreen:screen initialFrame:[screen bounds] activeFrame:activeFrame fidelity:fidelity prewarmInBackground:NO];
}
+ (void)prewarmShadersForScreen:(UIScreen *)screen initialFrame:(CGRect)initialFrame activeFrame:(CGRect)activeFrame fidelity:(SUICFlamesViewFidelity)fidelity prewarmInBackground:(BOOL)prewarmInBackground {
    
    // TODO: <rdar://problem/47131751> Better prewarming for Metal-based Flames
    SUICFlamesViewMetal *flamesView = [[SUICFlamesViewMetal alloc] initWithFrame:initialFrame screen:screen fidelity:fidelity];
    [flamesView setRenderInBackground:prewarmInBackground];
    [flamesView setActiveFrame:activeFrame];
    [flamesView _prewarmShaders];
}
- (void)prewarmShadersForCurrentMode {
    [self _prewarmShaders];
}
- (void)_prewarmShaders {
    // force a complete render pass as part of prewarm
    _isInitialized = [self _initMetalAndSetupDisplayLink:NO];
    [self _updateCurveLayer:_displayLink];
}
- (void)resetAndReinitialize:(BOOL)initialize {
    if (initialize) {
        [self _initMetalAndSetupDisplayLink:YES];
    }
    
    // always do this part
    NSMutableArray *discarded = [[NSMutableArray alloc] init];
    for (SUICFlameGroup *flames in _flameGroups) {
        if (flames != _currentFlameGroup) {
            [discarded addObject:flames];
        }
    }
    [_flameGroups removeObjectsInArray:discarded];
    
    // force one final draw, to flush any pending animations
    // this is needed for NanoSiri to reset the flames view and not show a frame of the aura animation
    [self _updateCurveLayer:_displayLink];
}
- (void)_reduceMotionStatusChanged:(NSNotification *)notification {
    _reduceMotionEnabled = UIAccessibilityIsReduceMotionEnabled();
    
    if (_mode == SUICFlamesViewModeSiri) {
        _shadersAreCompiled = NO;
        [self resetAndReinitialize:YES];
    }
}
- (void)_applicationWillResignActive:(NSNotification *)notification {
    [self setRenderingEnabled:NO forReason:kSUICFlamesViewUIApplicationNotificationReason];
}
- (void)_applicationWillEnterForeground:(NSNotification *)notification {
    [self setRenderingEnabled:YES forReason:kSUICFlamesViewUIApplicationNotificationReason];
}
- (void)_applicationDidBecomeActive:(NSNotification *)notification {
    [self setRenderingEnabled:YES forReason:kSUICFlamesViewUIApplicationNotificationReason];
}
- (void)_setupDisplayLink {
    if (!_displayLink && ([self superview] != nil) && ![self isHidden]) {
        _displayLink = [_screen displayLinkWithTarget:self selector:@selector(_updateCurveLayer:)];
        [_displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
        [self _setPreferredFramesPerSecond];
        [self _updateDisplayLinkPausedState];
    }
}
- (uint32_t)_numVerticesPerCircle {
    return (int)roundf(3 * powf(2, _maxSubdivisionLevel));
}
- (vector_float2)_predeterminedVertexPositionForAuraWithPolarVertex:(vector_float2)vertex {
    vector_float2 activeFrameOrigin = (vector_float2){_activeFrame.origin.x, _activeFrame.origin.y};
    vector_float2 activeFrameSize = (vector_float2){_activeFrame.size.width * _horizontalScaleFactor, _activeFrame.size.height};
    vector_float2 viewportSize = (vector_float2){_viewWidth, _viewHeight};
    //    vector_float2 scale =  activeFrameSize / viewportSize;
    vector_float2 center = (activeFrameOrigin + (activeFrameSize * 0.5)) / viewportSize * 2.0 - 1.0;
    center = -center;
    float r = vertex.x * vector_distance(center, 1.0);
    float q = vertex.y;
    return (vector_float2){cosf(q), sinf(q)} * r + center;
}
// ∑ of (3 * 2 ^ upperLimit - 3 * 2 ^ lowerLimit) * 3. Clamped by numCircles with continuation of linear upperLimit ∑ of 3 * 2 ^ upperLimit * (remainder of circles)
// example # 1: with upper limit of 8 and lower limit of 1 and a numCircles of 10:   ((3*2^8 - 3*2^1) + (3*2^8)*3)
// example # 2: with upper limit of 8 and lower limit of 7 and a numCircles of 10:   ((3*2^8 - 3*2^7) + (3*2^8)*9)
// example # 4: with upper limit of 4 and lower limit of 1 and a numCircles of 3:    ((3*2^4 - 3*2^1) + (3*2^4)*0)
// example # 5: with upper limit of 4 and lower limit of 3 and a numCircles of 7:    ((3*2^4 - 3*2^3) + (3*2^4)*6)
// example # 6: with upper limit of 8 and lower limit of 3 and a numCircles of 8:    ((3*2^9 - 3*2^3) + (3*2^8)*2)
- (int)_generateIndicesForNumCircleShapes:(int)numCircles withMaxSubdivisionLevel:(float)maxSubdivisionLevel startingWithNumSubdivisionLevel:(float)initialSubdivisionLevel forIndices:(uint32_t**)inOutIndices atStartIndex:(int)startIndex withFill:(BOOL)fillBool withCullingForAura:(BOOL)auraCullBool forVertices:(Vertex*)inVertices {
    const uint32_t numVertsPerCircle = [self _numVerticesPerCircle];
    int ii = startIndex;
    uint32_t * indices = *inOutIndices;
    Vertex * vertices = inVertices;
    
    // The vertex count for a hole should always be able to draw quads (to stay compatible with the histogram form of this geometry) so set initialSubDivisiionLevel at 1 or above.
    if (fillBool) {
        uint32_t numTriangleVerts = (uint)roundf(3 * powf(2, initialSubdivisionLevel));
        // our starting vertex should be the outer-most circle if we only have one circle.
        uint32_t begin = (numCircles == 1) ? numVertsPerCircle * (_maxVertexCircles - 1) : 0;
        uint32_t step = (int)((float)numVertsPerCircle / numTriangleVerts);
        for (int i = 0; i < numTriangleVerts / 2 - 1; ++i) {
            
            indices = (uint32_t*) realloc(indices, (ii + 6) * sizeof(uint32_t));
            
            indices[ii++] = begin + (i) * step;
            indices[ii++] = begin + (i+1) * step;
            indices[ii++] = begin + (numTriangleVerts - 1 - i - 1) * step;
            
            indices[ii++] = begin + (i) * step;
            indices[ii++] = begin + (numTriangleVerts - 1 - i - 1) * step;
            indices[ii++] = begin + (numTriangleVerts - 1 - i) * step;
        }
    }
    
    for (int i = 0; i < numCircles - 1; ++i) {
        const int32_t curr_step = (int)((float)i / numCircles * _maxVertexCircles);
        const int32_t next_step = (i == numCircles - 2) ? (_maxVertexCircles - 1) : (int)((float)(i+1) / numCircles * _maxVertexCircles);
        const int32_t n_inner = (int)roundf(3 * powf(2, MIN(initialSubdivisionLevel + i, maxSubdivisionLevel)));
        const int32_t n_outer = (int)roundf(3 * powf(2, MIN(initialSubdivisionLevel + i+1, maxSubdivisionLevel)));
        const float subdivision_ratio = (float)n_inner / n_outer;
        
        const int32_t ring_inner_index = curr_step * numVertsPerCircle;
        const int32_t ring_outer_index = next_step * numVertsPerCircle;
        
        for (int j = 0; j < n_inner; ++j) {
            const float ratio = ((float)j/n_inner);
            
            // outer vertex index plus one and minus one. using the ratio of j with n to determine offset. Since we are doubling from the inner circle, we want half the distance the next inner j step. modulo keeps us in range.
            const int32_t v_inner = ring_inner_index + (int)(numVertsPerCircle * ratio) % numVertsPerCircle;
            const int32_t v_inner_plus_one = ring_inner_index + (int)(numVertsPerCircle * (float)(j+1)/n_inner) % numVertsPerCircle;
            const int32_t v_outer = ring_outer_index + (int)(numVertsPerCircle * ratio) % numVertsPerCircle;
            
            // the following ratios must be positive for modulo to work the way we want it to.
            const float ratio_plus_one_outer_offset = ((float)j + (float)subdivision_ratio) / (float)n_inner;
            const float ratio_minus_one_outer_offset = ((float)j + (float)n_inner - (float)subdivision_ratio) / (float)n_inner;
            const int32_t v_outer_plus_one = ring_outer_index + (int)(ratio_plus_one_outer_offset * numVertsPerCircle) % numVertsPerCircle;
            const int32_t v_outer_minus_one = ring_outer_index + (int)(ratio_minus_one_outer_offset * numVertsPerCircle) % numVertsPerCircle;
            
            // culling setup
            vector_float2 inner_auraPosition = 0.0;
            vector_float2 inner_plus_one_auraPosition = 0.0;
            vector_float2 outer_auraPosition = 0.0;
            vector_float2 outer_plus_one_auraPosition = 0.0;
            vector_float2 outer_minus_one_auraPosition = 0.0;
            if (auraCullBool) {
                inner_auraPosition = vector_abs([self _predeterminedVertexPositionForAuraWithPolarVertex:vertices[v_inner].vertexLocation.xy]);
                inner_plus_one_auraPosition = vector_abs([self _predeterminedVertexPositionForAuraWithPolarVertex:vertices[v_inner_plus_one].vertexLocation.xy]);
                outer_auraPosition = vector_abs([self _predeterminedVertexPositionForAuraWithPolarVertex:vertices[v_outer].vertexLocation.xy]);
                outer_plus_one_auraPosition = vector_abs([self _predeterminedVertexPositionForAuraWithPolarVertex:vertices[v_outer_plus_one].vertexLocation.xy]);
                outer_minus_one_auraPosition = vector_abs([self _predeterminedVertexPositionForAuraWithPolarVertex:vertices[v_outer_minus_one].vertexLocation.xy]);
            }
            
            NSAssert(v_inner < _numVertices && v_inner >= 0, @"Failed to evaluate inner vertex (%i) within valid range: 0 <-> %lli", v_inner, _numVertices-1);
            NSAssert(v_outer < _numVertices && v_outer >= 0, @"Failed to evaluate outer vertex (%i) within valid range: %lli. ring_outer_index was %i. ring_outer_size was %i. And ratio was %f", v_outer, _numVertices-1, ring_outer_index, numVertsPerCircle, ratio);
            NSAssert(v_outer_plus_one < _numVertices && v_outer_plus_one >= 0, @"Failed to evaluate v_outer_plus_one (%i) within valid range: 0 <-> %lli", v_outer_plus_one, _numVertices-1);
            NSAssert(v_outer_minus_one < _numVertices && v_outer_minus_one >= 0, @"Failed to evaluate v_outer_minus_one (%i) within valid range: 0 <-> %lli", v_outer_minus_one, _numVertices-1);
            
            // this is where we need to apply our subdivided element if we are infact subdividing
            if (subdivision_ratio != 1.0)
            {
                // vector_length(vector_step(1.1, x)) calculations can result in 0 (x and y within screen), 1 (x or y within screen), 2 (x and y outside of screen).
                // using 1.1 as a fast hack to keep low fidelity vertices near the screen's corner.
                if (!auraCullBool ||
                    vector_length(vector_step(1.1, inner_auraPosition)) +
                    vector_length(vector_step(1.1, outer_minus_one_auraPosition)) +
                    vector_length(vector_step(1.1, outer_auraPosition)) < 3.0) {
                    
                    indices = (uint32_t*) realloc(indices, (ii + 3) * sizeof(uint32_t));
                    
                    // cw triangle.
                    indices[ii++] = v_inner;
                    indices[ii++] = v_outer_minus_one;
                    indices[ii++] = v_outer;
                }
            }
            
            if (!auraCullBool ||
                vector_length(vector_step(1.1, inner_auraPosition)) +
                vector_length(vector_step(1.1, outer_auraPosition)) +
                vector_length(vector_step(1.1, outer_plus_one_auraPosition)) < 3.0) {
                
                indices = (uint32_t*) realloc(indices, (ii + 3) * sizeof(uint32_t));
                
                // ccw triangle.
                indices[ii++] = v_inner;
                indices[ii++] = v_outer;
                indices[ii++] = v_outer_plus_one;
            }
            
            if (!auraCullBool ||
                vector_length(vector_step(1.1, inner_auraPosition)) +
                vector_length(vector_step(1.1, outer_plus_one_auraPosition)) +
                vector_length(vector_step(1.1, inner_plus_one_auraPosition)) < 3.0) {
                
                indices = (uint32_t*) realloc(indices, (ii + 3) * sizeof(uint32_t));
                
                // ccw triangle's adjacent triangle to create quad.
                indices[ii++] = v_inner;
                indices[ii++] = v_outer_plus_one;
                indices[ii++] = v_inner_plus_one;
            }
        }
    }
    
    *inOutIndices = indices;
    
    return ii;
}
- (BOOL)_setupVertexBuffer {
    NSAssert(_maxVertexCircles >= 1, @"Init size exepcted non-zero");
    const uint32_t numVertsPerCircle = [self _numVerticesPerCircle];
    _numVertices = _maxVertexCircles * numVertsPerCircle;
    
    // raw vertex data
    NSUInteger dataSize = sizeof(Vertex) * _numVertices;
    NSMutableData *vertexData = [[NSMutableData alloc] initWithLength:dataSize];
    Vertex *vertices = vertexData.mutableBytes;
    int32_t vi = 0;
    
    for(int i = 0; i < _maxVertexCircles; ++i) {
        
        // r: radius
        float r = (float)(i+1) / _maxVertexCircles;
        
        // square r for more inner circles.
        //        r *= r;
        
        const int32_t n = numVertsPerCircle;
        
        // subdivided vertex count. starts from a triangle.
        // const int32_t n = 3 * powf(2, MIN(i, kMaxSubdivisions));
        
        for (int j = 0; j < n; ++j) {
            // q: theta (radians)
            float q_geom;
            float q_noise;
            if (_mode == SUICFlamesViewModeDictation) {
                q_geom  = M_PI * 2.0 * ((float)((j+1) - (j % 2)) / n);
                q_noise = M_PI * 2.0 * vector_fract((float)((j+1) + ((j % 2) - 1.0)) / n);
            } else {
                q_geom = q_noise = M_PI * 2.0 * ((float)j / n);
            }
            
            // polar (r,q)
            vertices[vi].vertexLocation.xy = (vector_float2){r,q_geom};
            vertices[vi].vertexLocation.zw = (vector_float2){r,q_noise};
            vertices[vi].color = (vector_float4){_dictationRedColor, _dictationGreenColor, _dictationBlueColor, 1.0};
            ++vi;
        }
    }
    
    // raw index data
    uint32_t *indices = NULL;
#if ENABLE_INDEX_CACHING
    NSString *cacheKey = SUICGetIndexCacheEntryKey(_activeFrame, _fidelity, _horizontalScaleFactor, _mode, _viewWidth, _viewHeight);
    SUICIndexCacheEntry *cacheEntry = [[[self class] _indexCache] objectForKey:cacheKey];
    
    if (cacheEntry) {
        _numAuraIndices = [cacheEntry numAuraIndices];
        _numAuraIndicesCulled = [cacheEntry numAuraIndicesCulled];
        _numWaveIndices = [cacheEntry numWaveIndices];
        indices = [cacheEntry metal_indices];
    }
    else
#endif
    {
        _numAuraIndices = [self _generateIndicesForNumCircleShapes:_auraVertexCircles
                                           withMaxSubdivisionLevel:_auraMaxSubdivisionLevel
                                   startingWithNumSubdivisionLevel:_auraMinSubdivisionLevel
                                                        forIndices:&indices
                                                      atStartIndex:0
                                                          withFill:YES
                                                withCullingForAura:NO
                                                       forVertices:vertices];
        
        _numAuraIndicesCulled = [self _generateIndicesForNumCircleShapes:_auraVertexCircles
                                                 withMaxSubdivisionLevel:_auraMaxSubdivisionLevel
                                         startingWithNumSubdivisionLevel:_auraMinSubdivisionLevel
                                                              forIndices:&indices
                                                            atStartIndex:_numAuraIndices
                                                                withFill:YES
                                                      withCullingForAura:YES
                                                             forVertices:vertices];
        
        _numWaveIndices = [self _generateIndicesForNumCircleShapes:1
                                           withMaxSubdivisionLevel:_maxSubdivisionLevel
                                   startingWithNumSubdivisionLevel:_maxSubdivisionLevel
                                                        forIndices:&indices
                                                      atStartIndex:_numAuraIndicesCulled
                                                          withFill:YES
                                                withCullingForAura:NO
                                                       forVertices:vertices];
        
        _numWaveIndices -= _numAuraIndicesCulled;
        _numAuraIndicesCulled -= _numAuraIndices;
        
#if ENABLE_INDEX_CACHING
        // Create cache
        cacheEntry = [[SUICIndexCacheEntry alloc] init];
        [cacheEntry setNumAuraIndices:_numAuraIndices];
        [cacheEntry setNumAuraIndicesCulled:_numAuraIndicesCulled];
        [cacheEntry setNumWaveIndices:_numWaveIndices];
        [cacheEntry setMetal_indices:indices];
        [[[self class] _indexCache] setObject:cacheEntry forKey:cacheKey];
#endif
    }
    
    dataSize = sizeof(uint32_t) * (_numAuraIndices + _numAuraIndicesCulled + _numWaveIndices);
    NSData *indexData = [[NSData alloc] initWithBytesNoCopy:indices length:dataSize freeWhenDone:YES];
    // Create a vertex buffer that can be read by the GPU
    _vertexBuffer = [[self device] newBufferWithBytes:vertexData.bytes length:vertexData.length options:MTLResourceStorageModeShared];
    // Calculate the number of vertices by dividing the byte length by the size of each vertex
    _numVertices = vertexData.length / sizeof(Vertex);
    
    // Create an index buffer that can be read by the GPU
    _indexBuffer = [[self device] newBufferWithBytes:indexData.bytes length:indexData.length options:MTLResourceStorageModeShared];
    // Calculate the number of vertices by dividing the byte length by the size of each index
    _numIndices = indexData.length / sizeof(uint16_t);
    
    return YES;
}
- (BOOL)_initMetalAndSetupDisplayLink:(BOOL)setupDisplayLink
{
    self.layer.opaque = NO;
    self.layer.contentsScale = [self _currentDisplayScale];
    _viewWidth =  self.layer.contentsScale * self.layer.bounds.size.width;
    _viewHeight = self.layer.contentsScale * self.layer.bounds.size.height;
    
    [self setDrawableSize:CGSizeMake(_viewWidth, _viewHeight)];
    // Setup Metal
    self.device = MTLCreateSystemDefaultDevice();
        
    if (!self.device) {
        return NO;
    }
    [self _setupVertexBuffer];
    if ([self _loadPipelineLibraries] == NO) {
        return NO;
    }
    if (setupDisplayLink) {
        [self _setupDisplayLink];
    }
    
    return YES;
}
- (BOOL)_loadPipelineLibraries {
    // Load all the shader files with a .metal file extension in the project
    NSError *error = NULL;
    id<MTLLibrary> defaultLibrary = [self.device newDefaultLibraryWithBundle:[NSBundle bundleForClass:self.class] error:&error];
    if (defaultLibrary == nil) {
        defaultLibrary = [self.device newDefaultLibrary];
    }
    
    // Load shader and configure pipeline descriptors
    MTLRenderPipelineDescriptor *pipelineStateDescriptor = [[MTLRenderPipelineDescriptor alloc] init];
    pipelineStateDescriptor.colorAttachments[0].pixelFormat = [self colorPixelFormat];
    pipelineStateDescriptor.colorAttachments[0].blendingEnabled = YES;
    pipelineStateDescriptor.colorAttachments[0].rgbBlendOperation = MTLBlendOperationAdd;
    pipelineStateDescriptor.colorAttachments[0].sourceRGBBlendFactor = MTLBlendFactorSourceAlpha;
    pipelineStateDescriptor.colorAttachments[0].destinationRGBBlendFactor = MTLBlendFactorOneMinusSourceAlpha;
    pipelineStateDescriptor.label = @"Flame Pipeline";
    pipelineStateDescriptor.vertexFunction = _reduceMotionEnabled ? [defaultLibrary newFunctionWithName:@"siriFlameAccessibilityVertexShader"] : [defaultLibrary newFunctionWithName:@"siriFlameVertexShader"];
    pipelineStateDescriptor.fragmentFunction = [defaultLibrary newFunctionWithName:@"siriFlameFragmentShader"];
    _pipelineState[SUICFlamesViewModeSiri] = [self.device newRenderPipelineStateWithDescriptor:pipelineStateDescriptor error:&error];
    if (!_pipelineState[SUICFlamesViewModeSiri]) {
        return NO;
    }
    
    // Aura
    pipelineStateDescriptor.label = @"Aura Pipeline";
    pipelineStateDescriptor.fragmentFunction = [defaultLibrary newFunctionWithName:@"siriAuraFragmentShader"];
    _pipelineState[SUICFlamesViewModeAura] = [self.device newRenderPipelineStateWithDescriptor:pipelineStateDescriptor error:&error];
    if (!_pipelineState[SUICFlamesViewModeAura]) {
        return NO;
    }
    
    // Dictation
    pipelineStateDescriptor.label = @"Dictation Pipeline";
    pipelineStateDescriptor.vertexFunction = [defaultLibrary newFunctionWithName:@"siriDictationVertexShader"];
    pipelineStateDescriptor.fragmentFunction = [defaultLibrary newFunctionWithName:@"siriDictationFragmentShader"];
    _pipelineState[SUICFlamesViewModeDictation] = [self.device newRenderPipelineStateWithDescriptor:pipelineStateDescriptor error:&error];
    if (!_pipelineState[SUICFlamesViewModeDictation]) {
        return NO;
    }
    
    // Training
    pipelineStateDescriptor.label = @"Training Pipeline";
    pipelineStateDescriptor.vertexFunction = [defaultLibrary newFunctionWithName:@"siriTrainingVertexShader"];
    pipelineStateDescriptor.fragmentFunction = [defaultLibrary newFunctionWithName:@"siriTrainingFragmentShader"];
    _pipelineState[SUICFlamesViewModeHeySiriTraining] = [self.device newRenderPipelineStateWithDescriptor:pipelineStateDescriptor error:&error];
    if (!_pipelineState[SUICFlamesViewModeHeySiriTraining]) {
        return NO;
    }
    
    return YES;
}

- (BOOL)_resizeFromLayer:(CAMetalLayer *)layer API_AVAILABLE(ios(13.0)) {
    if (![self isRenderingEnabled]) {
        return NO;
    }
    
    _viewWidth =  layer.contentsScale * layer.bounds.size.width;
    _viewHeight = layer.contentsScale * layer.bounds.size.height;
    [self setDrawableSize:CGSizeMake(_viewWidth, _viewHeight)];
    return YES;
}

- (void)_updateOrthoProjection {
    if (![self isRenderingEnabled]) {
        return;
    }
}
- (void)layoutSubviews
{
    if (!_isInitialized)
    {
        _isInitialized = [self _initMetalAndSetupDisplayLink:YES];
    }
    else
    {
        if (@available(iOS 13.0, *))
        {
            [self _resizeFromLayer:[self _metalLayer]];
        }
    }
    
    [self _updateOrthoProjection];
}
- (CGFloat)_currentDisplayScale {
    // prefer the scale from the trait collection, but if it is not valid use the screen scale instead.
    CGFloat traitScale = [[self traitCollection] displayScale];
    CGFloat scale = (traitScale >= 1.0 ? traitScale : [_screen scale]);
    
    if ([self _deviceNeeds2xFlamesWithCurrentScale:scale]) {
        scale = 2.0;
    }
    
    return scale;
}
- (BOOL)_deviceNeeds2xFlamesWithCurrentScale:(CGFloat)scale {
    // <rdar://problem/41995955> Downscale flames view to display as 2x on N56
    static BOOL needsLowerQualityFlames = NO;
#ifdef MGPROD_N56
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        needsLowerQualityFlames = (MGGetProductType() == MGProductTypeN56);
    });
#endif
    // Only lower the quality if we're trying to render it at a 3x scale, to prevent cases where we might want to be rendering it at lower scales
    return (needsLowerQualityFlames && scale == 3.0);
}
- (void)_tearDownDisplayLink {
    _state = SUICFlamesViewStateDisabled;
    [_displayLink invalidate];
    _displayLink = nil;
    _commandQueue = nil;
}
- (BOOL)inSiriMode {
    return ([self mode] == SUICFlamesViewModeSiri);
}
- (BOOL)inDictationMode {
    return ([self mode] == SUICFlamesViewModeDictation);
}
- (BOOL)isRenderingEnabled {
#if TARGET_OS_TV
    return (![self _isOriginatingProcessInBackground] || _renderInBackground) && [_renderingDisabledReasons count] < 1;
#else
    return [_renderingDisabledReasons count] < 1;
#endif
}
- (BOOL)_isOriginatingProcessInBackground {
#if !TARGET_OS_SIMULATOR
//    uint32_t isBackground = 0;
//    proc_pidoriginatorinfo(0x2, &isBackground, sizeof(isBackground));
//    return (isBackground > 0);
    return NO;
#else
    return NO; // proc_pidoriginatorinfo SPI does not exist on Simulator
#endif
}

- (CAMetalLayer *)_metalLayer  API_AVAILABLE(ios(13.0)) {
    return (CAMetalLayer *)[self layer];
}

- (void)_didSkipFrameUpdateWithReason:(NSString *)reason andCount:(NSUInteger)count {

}
- (id<MTLCommandQueue>)_lazy_commandQueue {
    if (!_commandQueue) {
        _commandQueue = [self.device newCommandQueue];
    }
    
    return _commandQueue;
}
- (void)_updateCurveLayer:(CADisplayLink*)sender {
    if (!_currentFlameGroup) {
        [self _didSkipFrameUpdateWithReason:@"No current flame group" andCount:0];
        return;
    }
    
    if (!_isInitialized) {
        [self _didSkipFrameUpdateWithReason:@"not initialized" andCount:0];
        return;
    }
    
    if (![self isRenderingEnabled]) {
        [self _didSkipFrameUpdateWithReason:@"rendering disabled" andCount:0];
        return;
    }
   
// Commenting this out due to SPI `isDrawableAvailable`.
//    CAMetalLayer *layer = [self _metalLayer];
//    if (![layer isDrawableAvailable]) {
//        // <rdar://problem/52006442> is tracking the investigation into why this happens so frequently
//        // For now, reduce the frequency of this logging.
//        static NSUInteger skipCount = 0;
//        if ((skipCount++ % 1000) == 0) {
//            [self _didSkipFrameUpdateWithReason:@"no drawable available" andCount:skipCount];
//        }
//        return;
//    }
    
    BOOL flamesTransitionFinished = NO;
    BOOL auraTransitionFinished = NO;
    {
        float *phase = _currentFlameGroup.transitionPhasePtr;
        vector_float4 *states = _currentFlameGroup.stateModifiersPtr;
        
        if (*phase < 1.0) {
            switch (_state) {
                case SUICFlamesViewStateAboutToListen:
                    *phase += (0.03 * _frameRateScalingFactor);
                    *phase = MIN(*phase, 1.0);
                    *states = vector_mix(*states, (vector_float4){1.0, 0.0, 0.0, 0.0}, (vector_float4){*phase, *phase, *phase, *phase});
                    [_levelSmoother setDecaySpeed:0.95];
                    break;
                case SUICFlamesViewStateListening:
                    *phase += (0.03 * _frameRateScalingFactor);
                    *phase = MIN(*phase, 1.0);
                    *states = vector_mix(*states, (vector_float4){0.0, 1.0, 0.0, 0.0}, (vector_float4){*phase, *phase, *phase, *phase});
                    [_levelSmoother setDecaySpeed:0.9];
                    break;
                case SUICFlamesViewStateThinking:
                    *phase += (0.02 * _frameRateScalingFactor);
                    *phase = MIN(*phase, 1.0);
                    *states = vector_mix(*states, (vector_float4){0.0, 0.0, 1.0, 0.0}, (vector_float4){*phase, *phase, *phase, *phase});
                    break;
                case SUICFlamesViewStateSuccess:
                    // Since a new _currentFlameGroup is immediately allocated when this state is hit, and _currentFlameGroup becomes of state SUICFlamesViewStateAboutToListen, this switch case will never execute for any duration.
                    break;
                case SUICFlamesViewStateDisabled:
                    *phase += (0.03 * _frameRateScalingFactor);
                    *phase = MIN(*phase, 1.0);
                    *states = vector_mix(*states, (vector_float4){0.0, 0.0, 0.0, 0.0}, (vector_float4){*phase, *phase, *phase, *phase});
                    if (*phase == 1.0) {
                        [self setHidden:YES];
                    }
                    break;
            }
        }
        else
        {
            flamesTransitionFinished = YES;
        }
    }
    
    // <rdar://problem/20979777> SpringBoard is checking power levels even when not recording
    float powerLevel = 0.0;
    if (_state == SUICFlamesViewStateListening) {
        powerLevel = [self _currentMicPowerLevel];
    }
    // Obtain a renderPassDescriptor generated from the view's drawable textures
    MTLRenderPassDescriptor *renderPassDescriptor = [self currentRenderPassDescriptor];
    if (renderPassDescriptor != nil) {
        // Create a new command buffer for each render pass to the current drawable
        id<MTLCommandBuffer> commandBuffer = [[self _lazy_commandQueue] commandBuffer];
        [commandBuffer setLabel:@"SUICFlamesViewMetalBuffer"];
        // Create a render command encoder so we can render into something
        id<MTLRenderCommandEncoder> renderEncoder = [commandBuffer renderCommandEncoderWithDescriptor:renderPassDescriptor];
        [renderEncoder setLabel:@"SUICFlamesViewMetalEncoder"];
        float timeInterval = [_displayLink duration];
        
        NSMutableArray *discarded = [[NSMutableArray alloc] init];
        for (SUICFlameGroup *flames in _flameGroups) {
            vector_float4 *states = flames.stateModifiersPtr;
            // Don't animate the aura group if frozen.
            if (!(_freezesAura && flames.isAura)) {
                if (_reduceMotionEnabled) {
                    flames.stateTime    += timeInterval * 0.5 * _frameRateScalingFactor;
                    flames.zTime        += timeInterval * ((0.1 + powerLevel * 0.5) * ((*states).x + (*states).y) + (*states).z * 0.1 + (*states).w * 0.05); // manipulates that speed of zTime with irregular increments depending on the state
                } else {
                    flames.stateTime    += timeInterval * _frameRateScalingFactor;
                    flames.zTime        += timeInterval * ((0.25 + powerLevel * 2.0) * ((*states).x + (*states).y) + (*states).z * 0.25 + (*states).w * 0.05); // manipulates that speed of zTime with irregular increments depending on the state
                }
            }
        
            uint32_t indicesLength = 0;
            uint32_t indicesPosition = 0;
            
            if (flames.isDyingOff) {
                flames.globalAlpha = MAX(flames.globalAlpha - kGlobalAlphaFadeSpeedIncrement, 0.0);
            }
            
            if (flames.isAura && _mode == SUICFlamesViewModeSiri) {
                float *phase = flames.transitionPhasePtr;
                indicesLength = _numAuraIndicesCulled;
                indicesPosition = _numAuraIndices;
                if (*phase < 1.0) {
                    *phase += (_reduceMotionEnabled ? 0.001 : 0.005) * _frameRateScalingFactor;
                    *phase = MIN(*phase, 1.0);
                    // since this transtion is longer than the standard speed, all states except aura should be pushed to zero quickly.
                    *states = vector_mix(*states, (vector_float4){0.0, 0.0, 0.0, 1.0}, (vector_float4){*phase, *phase, *phase, *phase});
                    indicesLength = _numAuraIndices;
                    indicesPosition = 0;
                    
                    // check if the aura reached full size. states = {0, 0, 0, 1} is full aura
                    if ((*states).x <= DBL_EPSILON &&
                        (*states).y <= DBL_EPSILON &&
                        (*states).z <= DBL_EPSILON &&
                        (*states).w + DBL_EPSILON >= 1.0) {
                        if ([_flamesDelegate respondsToSelector:@selector(flamesViewAuraDidDisplay:)])
                        {
                            [_flamesDelegate flamesViewAuraDidDisplay:self];
                        }
                    }
                } else {
                    auraTransitionFinished = YES;
                }
            }
            
            // Set the region of the drawable to which we'll draw.
            vector_float4 viewportSize;
            viewportSize.x = [self drawableSize].width;
            viewportSize.y = [self drawableSize].height;
            [renderEncoder setViewport:(MTLViewport){0.0, 0.0, viewportSize.x, viewportSize.y, -1.0, 1.0}];
            
            [renderEncoder setVertexBuffer:_vertexBuffer offset:0 atIndex:SiriFlames_VertexInput_Polar];
            
            viewportSize.z = (float)[self _currentDisplayScale];
            viewportSize.w = (float)_dictationUnitSize;
            [renderEncoder setVertexBytes:&viewportSize length:sizeof(viewportSize) atIndex:SiriFlames_VertexInput_Viewport];
            
            [renderEncoder setVertexBytes:states length:sizeof(*states) atIndex:SiriFlames_VertexInput_States];
            
            vector_float4 boundsData = {(float)_activeFrame.origin.x, (float)_activeFrame.origin.y, (float)_activeFrame.size.width, (float)_activeFrame.size.height};
            [renderEncoder setVertexBytes:&boundsData length:sizeof(boundsData) atIndex:SiriFlames_VertexInput_Bounds];
            
            vector_float4 flamesData = {flames.stateTime, flames.zTime, powerLevel, flames.globalAlpha};
            [renderEncoder setVertexBytes:&flamesData length:sizeof(flamesData) atIndex:SiriFlames_VertexInput_Time_Ztime_Height_Alpha];
            
            // simd_float2 center = (boundsData.xy + (boundsData.zw * 0.5)) / (viewportSize.xy / viewportSize.z) * 2.0 - 1.0;
            if (states->w > 0.0) {
                [renderEncoder setRenderPipelineState:_pipelineState[SUICFlamesViewModeAura]];
            } else {
                indicesLength = _numWaveIndices;
                indicesPosition = _numAuraIndices + _numAuraIndicesCulled;
                
                [renderEncoder setRenderPipelineState:_pipelineState[_mode]];
            }
            
            [renderEncoder drawIndexedPrimitives:MTLPrimitiveTypeTriangle indexCount:indicesLength indexType:MTLIndexTypeUInt32 indexBuffer:_indexBuffer indexBufferOffset:indicesPosition * sizeof(uint32_t)];
            
            if (flames.globalAlpha == 0.0)
            {
                [discarded addObject:flames];
            }
        }
        
        [renderEncoder endEncoding];
        
        // Schedule a present once the framebuffer is complete using the current drawable
        [commandBuffer presentDrawable:[self currentDrawable]];
        // If freezing the aura, only consider a transition finished if both the flames and aura are finished.
        _transitionFinished = _freezesAura ? (flamesTransitionFinished && auraTransitionFinished) : flamesTransitionFinished;
        __weak typeof(self) weakSelf = self;
        void (^postCompletionBlock)(void) = ^void() {
            __strong typeof(self) strongSelf = weakSelf;
            if (!strongSelf) { return; }
            if (discarded.count)
            {
                [strongSelf->_flameGroups removeObjectsInArray:discarded];
            }
            if (strongSelf->_transitionFinished)
            {
                [strongSelf _didFinishTransition];
            }
        };
        
        [commandBuffer addCompletedHandler:^(id<MTLCommandBuffer> _Nonnull buffer) {
            if ([NSThread isMainThread]) {
                postCompletionBlock();
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    postCompletionBlock();
                });
            }
        }];
        
        // Finalize rendering here & push the command buffer to the GPU
        [commandBuffer commit];
    }
    
    if (!sender) {
        // The commandQueue has a large memory footprint.  If this is a one time call - not linked to a DisplayLink - deallocate it.
        _commandQueue = nil;
    }
}
- (void)_didFinishTransition {
    [self _updateDisplayLinkPausedState];
}
#pragma mark - Index Cache
+ (NSCache<NSString *, SUICIndexCacheEntry *> *)_indexCache {
    static NSCache<NSString *, SUICIndexCacheEntry *> *sIndexCache;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sIndexCache = [[NSCache alloc] init];
        [sIndexCache setCountLimit:sIndexCacheSize];
    });
    return sIndexCache;
}
+ (void)setIndexCacheSize:(NSUInteger)size {
    sIndexCacheSize = size;
    [[self _indexCache] setCountLimit:sIndexCacheSize];
}
#pragma mark - Power level calculations
- (float)_currentMicPowerLevel {
    float power = [_flamesDelegate audioLevelForFlamesView:self];
    // map the 0.0–1.0 level we get from the smoother to the minimum/maximum with which we want to actually drive the animation
    return ([_levelSmoother smoothedLevelForMicPower:power] * (kMaximumPowerLevel - kMinimumPowerLevel)) + kMinimumPowerLevel;
}
#pragma mark - UITraitEnvironment
- (void)traitCollectionDidChange:(nullable UITraitCollection *)previousTraitCollection {
    [super traitCollectionDidChange:previousTraitCollection];
    
    if (previousTraitCollection) {
        UITraitCollection *currentTraitCollection = [self traitCollection];
        if ([currentTraitCollection displayScale] != [previousTraitCollection displayScale]) {
            // currently we only expect scale to change on J105a
            [self resetAndReinitialize:YES];
            [self _setValuesForFidelity:_fidelity];
            [self setNeedsLayout];
        }
    }
}
@end
