/*
 Copyright (c) 2015, Shazino SAS. All rights reserved.
 Copyright (c) 2018, Apple Inc. All rights reserved.
 
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


#import "ORKdBHLToneAudiometryScreenerContentViewB.h"

#import "ORKRoundTappingButton.h"
#import "ORKHelpers_Internal.h"
#import "ORKSkin.h"

static const CGFloat TopToProgressViewMinPadding = 10.0;

@interface ScreenerTestingInProgressViewB : UIView

@property (nonatomic, assign, getter=isActive) BOOL active;

- (void)setProgress:(double)progress;

@end

@implementation ScreenerTestingInProgressViewB
{
    CAShapeLayer *_indicatorLayer;
    UILabel *_textLabel;
    NSNumberFormatter *percentageFormatter;
}

static const CGFloat TestingInProgressIndicatorRadius = 6.0;

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self _init];
    }
    return self;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self _init];
    }
    return self;
}

- (void)_init
{
    [self setupIndicatorLayer];
    [self setupTextLabel];
    
    percentageFormatter = [NSNumberFormatter new];
    percentageFormatter.numberStyle = NSNumberFormatterPercentStyle;
    percentageFormatter.roundingIncrement = @(5);
    percentageFormatter.roundingMode = NSNumberFormatterRoundFloor;
    percentageFormatter.maximum = @100;
    percentageFormatter.locale = [NSLocale currentLocale];
}

#define PULSE_OPACITY 1
#define PULSE_SCALE 0
- (void)setActive:(BOOL)active
{
    _active = active;
    if (active)
    {
        const CFTimeInterval duration = 2.5;
        
#if PULSE_OPACITY
        CAKeyframeAnimation *opacityAnimation = [CAKeyframeAnimation animationWithKeyPath:@"opacity"];
        opacityAnimation.keyTimes = @[@(0), @(0.50), @(1.0)];
        opacityAnimation.values =   @[@(1), @(0.2), @(1)];
        opacityAnimation.duration = duration;
        opacityAnimation.repeatCount = CGFLOAT_MAX;
        [_indicatorLayer addAnimation:opacityAnimation forKey:@"opacity"];
        
#endif
        
#if PULSE_SCALE
        CAKeyframeAnimation *scaleAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale.xy"];
        scaleAnimation.keyTimes = @[@(0), @(0.50), @(1.0)];
        scaleAnimation.values =   @[@(1), @(0.4), @(1)];
        scaleAnimation.duration = duration;
        scaleAnimation.repeatCount = CGFLOAT_MAX;
        [_indicatorLayer addAnimation:scaleAnimation forKey:@"scale"];
#endif
    }
    else
    {
        [_indicatorLayer removeAllAnimations];
    }
}

- (void)setProgress:(double)progress
{
    _textLabel.text = [NSString stringWithFormat:ORKLocalizedString(@"dBHL_TONE_AUDIOMETRY_TESTING_IN_PROGRESS_FMT", nil), [percentageFormatter stringFromNumber:@(progress)]];
}

- (void)setupTextLabel
{
    if (!_textLabel)
    {
        _textLabel = [[UILabel alloc] init];
        _textLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _textLabel.textColor = [UIColor systemGrayColor];
        UIFontDescriptor *descriptor = [UIFontDescriptor preferredFontDescriptorWithTextStyle:UIFontTextStyleHeadline
                                                                compatibleWithTraitCollection:self.traitCollection];
        _textLabel.font = [UIFont fontWithDescriptor:descriptor size:2 * TestingInProgressIndicatorRadius];
        _textLabel.text = ORKLocalizedString(@"dBHL_TONE_AUDIOMETRY_TESTING_IN_PROGRESS", nil);
        [self addSubview:_textLabel];
        
        [NSLayoutConstraint activateConstraints:@[
            [_textLabel.topAnchor constraintEqualToAnchor:self.topAnchor],
            [_textLabel.bottomAnchor constraintEqualToAnchor:self.bottomAnchor],
            [_textLabel.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:2 * TestingInProgressIndicatorRadius + 5.0],
            [_textLabel.trailingAnchor constraintEqualToAnchor:self.trailingAnchor]
        ]];
    }
}

- (void)drawRect:(CGRect)rect
{
    // Align the shape layer view to the edge of the
    if (_indicatorLayer)
    {
        // Set the anchor point to be the left most edge of the circle
        _indicatorLayer.position = CGPointMake(TestingInProgressIndicatorRadius, CGRectGetMidY(self.bounds));
    }
}

- (void)setupIndicatorLayer
{
    if (!_indicatorLayer)
    {
        _indicatorLayer = [self newCircleLayerWithRadius:TestingInProgressIndicatorRadius];
    }
    
    _indicatorLayer.fillColor = self.tintColor.CGColor;
    [self.layer addSublayer:_indicatorLayer];
}

// Make sure this method begins with create/new to avoid the compiler complaining about the potential leak.
- (CGPathRef)newCirclePathWithRadius:(CGFloat)radius
{
    CGPoint origin = CGPointZero;
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddArc(path, NULL, origin.x, origin.y, radius, 0, 2 * M_PI, YES);
    CGPathCloseSubpath(path);

    return path;
}

- (CAShapeLayer *)newCircleLayerWithRadius:(CGFloat)radius
{
    CAShapeLayer *circle = [CAShapeLayer layer];
    CGPathRef path = [self newCirclePathWithRadius:radius];
    circle.path = path;
    CGPathRelease(path);
    return circle;
}

@end

@interface UIPickerView (screener)

-(UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath;

@end

@protocol UIPickerViewCustomDelegate <NSObject>

- (void)pickerView:(UIPickerView *)pickerView didScrollByRow:(NSInteger)row inComponent:(NSInteger)component;

@end

@interface UIPickerViewCustom: UIPickerView

@end

@implementation UIPickerViewCustom {
    NSTimer *_timer;
    NSInteger _selectedRow;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    [self commomInit];
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    [self commomInit];
    return self;
}

- (void)commomInit {
    _timer = [[NSTimer alloc] initWithFireDate:[NSDate date]
                                      interval:1/30
                                        target:self
                                      selector:@selector(updateSelectedRow)
                                      userInfo:nil
                                       repeats:YES];
    NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
    [runLoop addTimer:_timer forMode:NSRunLoopCommonModes];
}

- (void)dealloc {
    [_timer invalidate];
    _timer = nil;
}

- (void)updateSelectedRow {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSUInteger row = [self selectedRowInComponent:0];
        if (row != _selectedRow) {
            _selectedRow = row;
            if ([self.delegate respondsToSelector:@selector(pickerView:didScrollByRow:inComponent:)]) {
                id<UIPickerViewCustomDelegate> customDelegate = (id<UIPickerViewCustomDelegate>)self.delegate;
                [customDelegate pickerView:self didScrollByRow:row inComponent:0];
            }
        }
    });
}

@end

#define kPICKERITEMS 10000

@interface ORKdBHLToneAudiometryScreenerContentViewB () <UIPickerViewCustomDelegate>

@end

@implementation ORKdBHLToneAudiometryScreenerContentViewB {
    NSLayoutConstraint *_topToProgressViewConstraint;
    UILabel *_progressLabel;
    ScreenerTestingInProgressViewB *_progressView;
    UIPickerViewCustom *_pickerView;
    NSInteger _minimumValue;
    NSInteger _maximumValue;
    
    UIImageView *_minimumIcon;
    UIImageView *_maximumIcon;
    
    float _initialValue;
    float _stepSize;
}

- (instancetype)initWithValue:(float)value minimum:(NSInteger)minimum maximum:(NSInteger)maximum stepSize:(float)stepSize {
    self = [super init];
    if (self) {
        _initialValue = value;
        _minimumValue = minimum;
        _maximumValue = maximum;
        _stepSize = stepSize;
    
        _progressView = [[ScreenerTestingInProgressViewB alloc] init];
        _progressView.active = NO;
        _progressView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_progressView];
        
        _pickerView = [[UIPickerViewCustom alloc] init];
        _pickerView.dataSource = self;
        _pickerView.delegate = self;
        [_pickerView selectRow:kPICKERITEMS inComponent:0 animated:NO];
        [_pickerView setValue:[[UISelectionFeedbackGenerator alloc] init] forKey:@"selectionFeedbackGenerator"];
        
#if TARGET_IPHONE_SIMULATOR
        if ([_pickerView respondsToSelector:@selector(setSoundsEnabled:)]) {
            [_pickerView performSelector:@selector(setSoundsEnabled:) withObject:NULL];
        }
#endif
        
        [self addSubview:_pickerView];
        
        UIImage *minimumImage = nil;
        UIImage *maximumImage = nil;
        if (@available(iOS 13.0, *)) {
            minimumImage = [UIImage systemImageNamed:@"speaker.wave.1"];
            maximumImage = [UIImage systemImageNamed:@"speaker.wave.2"];
        }
        _minimumIcon = [[UIImageView alloc] initWithImage:minimumImage];
        _maximumIcon = [[UIImageView alloc] initWithImage:maximumImage];
        _minimumIcon.translatesAutoresizingMaskIntoConstraints = NO;
        _maximumIcon.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_minimumIcon];
        [self addSubview:_maximumIcon];

        self.translatesAutoresizingMaskIntoConstraints = NO;

        [self setUpConstraints];
    }
    return self;
}

- (void)setProgress:(CGFloat)progress animated:(BOOL)animated
{
    if (![_progressView isActive])
    {
        [_progressView setActive:YES];
    }
    
    [_progressView setProgress:progress];
}

- (void)setValue:(float)value {
    _initialValue = value;
    [_pickerView selectRow:kPICKERITEMS inComponent:0 animated:NO];
}

- (void)finishStep:(ORKActiveStepViewController *)viewController {
    [super finishStep:viewController];
//    self.tapButton.enabled = NO;
}

- (void)setUpConstraints {
    NSArray<NSLayoutConstraint *> *constraints = @[
                                                   [NSLayoutConstraint constraintWithItem:_progressView
                                                                                attribute:NSLayoutAttributeTop
                                                                                relatedBy:NSLayoutRelationEqual
                                                                                   toItem:self
                                                                                attribute:NSLayoutAttributeTop
                                                                               multiplier:1.0
                                                                                 constant:TopToProgressViewMinPadding],
                                                   [NSLayoutConstraint constraintWithItem:_progressView
                                                                                attribute:NSLayoutAttributeLeft
                                                                                relatedBy:NSLayoutRelationEqual
                                                                                   toItem:self
                                                                                attribute:NSLayoutAttributeLeft
                                                                               multiplier:1.0
                                                                                 constant:0.0],
                                                   [NSLayoutConstraint constraintWithItem:_progressView
                                                                                attribute:NSLayoutAttributeRight
                                                                                relatedBy:NSLayoutRelationEqual
                                                                                   toItem:self
                                                                                attribute:NSLayoutAttributeRight
                                                                               multiplier:1.0
                                                                                 constant:0.0],
                                                   [NSLayoutConstraint constraintWithItem:_minimumIcon
                                                                                attribute:NSLayoutAttributeLeading
                                                                                relatedBy:NSLayoutRelationEqual
                                                                                   toItem:self
                                                                                attribute:NSLayoutAttributeLeading
                                                                               multiplier:1.0
                                                                                 constant:0.0],
                                                   [NSLayoutConstraint constraintWithItem:_minimumIcon
                                                                                attribute:NSLayoutAttributeTop
                                                                                relatedBy:NSLayoutRelationEqual
                                                                                   toItem:self
                                                                                attribute:NSLayoutAttributeTop
                                                                               multiplier:1.0
                                                                                 constant:78.0],
                                                   [NSLayoutConstraint constraintWithItem:_maximumIcon
                                                                                      attribute:NSLayoutAttributeTrailing
                                                                                      relatedBy:NSLayoutRelationEqual
                                                                                         toItem:self
                                                                                      attribute:NSLayoutAttributeTrailing
                                                                                     multiplier:1.0
                                                                                       constant:0.0],
                                                   [NSLayoutConstraint constraintWithItem:_maximumIcon
                                                                                attribute:NSLayoutAttributeTop
                                                                                relatedBy:NSLayoutRelationEqual
                                                                                   toItem:self
                                                                                attribute:NSLayoutAttributeTop
                                                                               multiplier:1.0
                                                                                 constant:78.0],
    ];
    
    [NSLayoutConstraint activateConstraints:constraints];
    
    _pickerView.transform = CGAffineTransformMakeRotation(-M_PI_2);
    _pickerView.frame = CGRectMake(-16, 44, [UIScreen mainScreen].bounds.size.width, 88);
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return 2 * kPICKERITEMS;
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    if (!view) {
        view = [[UIView alloc] init];
    }
    view.frame = CGRectMake(0, 0, 22, 2);
    view.backgroundColor = UIColor.grayColor;
    return view;
}

- (void)pickerView:(UIPickerView *)pickerView didScrollByRow:(NSInteger)row inComponent:(NSInteger)component {
    float currentValue = (((row - kPICKERITEMS) * _stepSize) + _initialValue);
    NSInteger newRow = row;
    
    if (currentValue < _minimumValue) {
        newRow = floor((_minimumValue - _initialValue) / _stepSize) + kPICKERITEMS;
    } else if (currentValue > _maximumValue) {
        newRow = ceil((_maximumValue - _initialValue) / _stepSize) + kPICKERITEMS;
    }
    
    [pickerView selectRow:newRow inComponent:0 animated:NO];
    [self didSelectedRow:newRow];
}

-(void)didSelectedRow:(NSInteger)row {
    if ([self.delegate conformsToProtocol:@protocol(ORKdBHLToneAudiometryScreenerContentViewDelegate)] && [self.delegate respondsToSelector:@selector(didSelected:)]) {
        float value = ((float)(row - kPICKERITEMS) * _stepSize) + _initialValue;
        float clampedValue = MIN(MAX(value, _minimumValue), _maximumValue);
        [self.delegate didSelected:clampedValue];
    }
}

@end
