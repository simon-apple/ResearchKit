/*
 Copyright (c) 2020, Apple Inc. All rights reserved.
 
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

#import "ORKTinnitusButtonView.h"
#import "ORKHelpers_Internal.h"
#import "ResearchKit_Private.h"

static const CGFloat ORKTinnitusButtonViewButtonViewHeight = 90.0;
static const CGFloat ORKTinnitusButtonViewImageWidth = 40.0;
static const CGFloat ORKTinnitusButtonViewAdditionalHeightPadding = 40.0;
static const CGFloat ORKTinnitusButtonViewImageHeight = 42.0;
static const CGFloat ORKTinnitusButtonViewPadding = 16.0;

@interface UIColor (ORKTinnitusButtonView)

@property (class, nonatomic, readonly) UIColor *selectedBackgroundColor;
@property (class, nonatomic, readonly) UIColor *selectedLayerBorderColor;
@property (class, nonatomic, readonly) UIColor *unselectedBackgroundColor;
@property (class, nonatomic, readonly) UIColor *unselectedLayerBorderColor;

@end

@implementation UIColor (ORKTinnitusButtonView)

+ (UIColor *)selectedBackgroundColor {
    if (@available(iOS 13.0, *)) {
        return [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull traits) {
            return traits.userInterfaceStyle == UIUserInterfaceStyleDark ?
            [self colorWithRed:0.0/255.0 green:122.0/255.0 blue:1 alpha:0.05] :
            [self colorWithRed:242.0/255.0 green:248.0/255.0 blue:1 alpha:1];
        }];
    } else {
        return [self colorWithRed:242.0/255.0 green:248.0/255.0 blue:1 alpha:1];
    }
}

+ (UIColor *)selectedLayerBorderColor {
    if (@available(iOS 13.0, *)) {
        return [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull traits) {
            return traits.userInterfaceStyle == UIUserInterfaceStyleDark ?
            [self colorWithRed:9.0/255.0 green:107.0/255.0 blue:205.0/255.0 alpha:1] :
            [self systemBlueColor];
        }];
    } else {
        return [self colorWithRed:0.0/255.0 green:122.0/255.0 blue:255.0/255.0 alpha:1];
    }
}

+ (UIColor *)unselectedBackgroundColor {
    if (@available(iOS 13.0, *)) {
        return [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull traits) {
            return traits.userInterfaceStyle == UIUserInterfaceStyleDark ?
            [self systemGray6Color] :
            [self colorWithRed:251.0/255.0 green:251.0/255.0 blue:252.0/255.0 alpha:1];
        }];
    } else {
        return [self colorWithRed:251.0/255.0 green:251.0/255.0 blue:252.0/255.0 alpha:1];
    }
}

+ (UIColor *)unselectedLayerBorderColor {
    if (@available(iOS 13.0, *)) {
        return [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull traits) {
            return traits.userInterfaceStyle == UIUserInterfaceStyleDark ?
            [self systemGray5Color]:
            [self colorWithRed:229.0/255.0 green:229.0/255.0 blue: 234.0 / 255.0 alpha:1];
        }];
    } else {
        return [self colorWithRed:229.0/255.0 green:229.0/255.0 blue: 234.0 / 255.0 alpha:1];
    }
}

@end

@interface ORKTinnitusButtonView () <UIGestureRecognizerDelegate> {
    NSString *_titleText;
    NSString *_detailText;
    
    UIImageView *_imageView;
    UIImageView *_barLevelsView;
    UILabel * _titleLabel;
    UILabel * _detailLabel;
    UIView * _shadowView;
    UIView *_middleSeparatorView;
    
    NSLayoutConstraint *_middlePosition;
    NSLayoutConstraint *_heightConstraint;

    BOOL _subViewsAutoLayoutFinished;
    BOOL _firstLayoutTime;
    BOOL _selected;
    
    UITapGestureRecognizer *_tapOffGestureRecognizer;
    UIImpactFeedbackGenerator *_hapticFeedback;
}

@property (nonatomic, readwrite) BOOL isShowingPause;

@end

@implementation ORKTinnitusButtonView

- (instancetype _Nonnull )initWithTitle:(NSString *)title detail:(NSString *)detail answer:(id)answer {
    self = [super init];
    if (self) {
        [self commonInit];
        _titleText = title;
        _detailText = detail;
        _answer = answer;
        [self setupView];
        [self setUpConstraints];
    }
    return self;
}

- (instancetype)initWithTitle:(NSString *)title detail:(NSString *)detail {
    return [self initWithTitle:title detail:detail answer:nil];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self commonInit];
        [self setupView];
        [self setUpConstraints];
    }
    return self;
}

- (void)commonInit {
    _titleText = @"";
    _detailText = nil;
    _playedOnce = NO;
    _selected = NO;
    _subViewsAutoLayoutFinished = NO;
    _firstLayoutTime = YES;
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    [super traitCollectionDidChange:previousTraitCollection];

    [self setSelected:_selected];
}

- (void)setupView {
    self.opaque = YES;
    self.layer.masksToBounds = NO;
    
    self.layer.cornerRadius = 10.0;
    self.layer.borderWidth = 2.0;
    
    self.layer.shadowColor = [UIColor clearColor].CGColor;
    self.layer.shadowRadius = 5.0;
    self.layer.shadowOffset = CGSizeZero;
    self.layer.shadowOpacity = 0.35;
    
    self.contentMode = UIViewContentModeCenter;
    
    _middleSeparatorView = [UIView new];
    _middleSeparatorView.backgroundColor = [UIColor clearColor];
    [self addSubview:_middleSeparatorView];
    _middleSeparatorView.translatesAutoresizingMaskIntoConstraints = NO;
    
    _titleLabel = [[UILabel alloc] init];
    _titleLabel.font = [[self class] headlineFont];
    _titleLabel.numberOfLines = 1;
    _titleLabel.textAlignment = NSTextAlignmentNatural;
    [self addSubview:_titleLabel];
    _titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _titleLabel.text = _titleText;
    _titleLabel.minimumScaleFactor = 0.5;
    _titleLabel.adjustsFontSizeToFitWidth = YES;
    if (@available(iOS 13.0, *)) {
        _titleLabel.textColor = [UIColor labelColor];
    } else {
        _titleLabel.textColor = [UIColor blackColor];
    }
    
    _detailLabel = [[UILabel alloc] init];
    _detailLabel.font = [[self class] subheadlineFont];
    _detailLabel.numberOfLines = 0;
    _detailLabel.textAlignment = NSTextAlignmentNatural;
    _detailLabel.textColor = [UIColor systemGrayColor];
    [self addSubview:_detailLabel];
    _detailLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _detailLabel.text = _detailText;
    _detailLabel.adjustsFontSizeToFitWidth = YES;
    
    UIImage *playImage;
    UIImage *stopImage;
    
    if (@available(iOS 13.0, *)) {
        UIImageSymbolConfiguration *imageConfig = [UIImageSymbolConfiguration configurationWithPointSize:64 weight:UIImageSymbolWeightLight scale:UIImageSymbolScaleMedium];
        playImage = [[[UIImage systemImageNamed:@"play.circle"] imageByApplyingSymbolConfiguration:imageConfig] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        stopImage = [[[UIImage systemImageNamed:@"pause.circle"] imageByApplyingSymbolConfiguration:imageConfig] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    } else {
        // Fallback on earlier versions //
    }
    
    _imageView = [[UIImageView alloc] initWithImage:playImage highlightedImage:stopImage];
    _imageView.backgroundColor = [UIColor clearColor];
    [self addSubview:_imageView];
    _imageView.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSMutableArray *barImages = [[NSMutableArray alloc] initWithCapacity:15];
    UIImage *barLevelsImage;
    for (int i = 0 ; i < 15 ; i ++) {
        barLevelsImage = [UIImage imageNamed:[NSString stringWithFormat:@"tinnitus_bar_levels_%i", i] inBundle:ORKBundle() compatibleWithTraitCollection:nil];
        [barImages addObject:barLevelsImage];
    }
    _barLevelsView = [[UIImageView alloc] init];
    [_barLevelsView setAnimationImages:barImages] ;
    _barLevelsView.animationDuration = 0.5;
    _barLevelsView.animationRepeatCount = 0;
    
    _barLevelsView.backgroundColor = [UIColor clearColor];
    [self addSubview:_barLevelsView];
    _barLevelsView.translatesAutoresizingMaskIntoConstraints = NO;
    [_barLevelsView startAnimating];
    _barLevelsView.hidden = YES;

    _tapOffGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
    _tapOffGestureRecognizer.delegate = self;
    [self addGestureRecognizer:_tapOffGestureRecognizer];
    
    if (@available(iOS 13.0, *)) {
        self.backgroundColor = [UIColor secondarySystemBackgroundColor];
        self.layer.borderColor = [UIColor systemGray5Color].CGColor;
        _imageView.tintColor = [UIColor systemGray3Color];
    } else {
        self.backgroundColor = [UIColor colorWithRed:242.0/255.0 green:242.0/255.0 blue:247.0/255.0 alpha:1];
        self.layer.borderColor = [UIColor colorWithRed:229.0/255.0 green:229.0/255.0 blue: 234.0 / 255.0 alpha:1].CGColor;
        _imageView.tintColor = [UIColor colorWithRed:199.0/255.0 green:199.0/255.0 blue:204.0/255.0 alpha:1];
    }
    
    _hapticFeedback = [[UIImpactFeedbackGenerator alloc] initWithStyle: UIImpactFeedbackStyleMedium];
    
    [self setSelected:NO];
}

- (void)tapAction:(UITapGestureRecognizer *)recognizer {
    dispatch_async(dispatch_get_main_queue(), ^{
        [_hapticFeedback impactOccurred];
        if (!_selected) {
            [self setSelected:!_selected];
            _imageView.highlighted = YES;
            _barLevelsView.hidden = NO;
        } else {
            _imageView.highlighted = !_imageView.highlighted;
            _barLevelsView.hidden = !_barLevelsView.hidden;
        }
        _playedOnce = YES;
        if (_delegate && [_delegate respondsToSelector:@selector(tinnitusButtonViewPressed:)]) {
            [_delegate tinnitusButtonViewPressed:self];
        }
    });
}

+ (UIFont *)headlineFont {
    UIFontDescriptor *descriptor = [UIFontDescriptor preferredFontDescriptorWithTextStyle:UIFontTextStyleHeadline];
    return [UIFont systemFontOfSize:[[descriptor objectForKey: UIFontDescriptorSizeAttribute] doubleValue] + 1.0 weight:UIFontWeightSemibold];
}

+ (UIFont *)subheadlineFont {
    UIFontDescriptor *descriptor = [UIFontDescriptor preferredFontDescriptorWithTextStyle:UIFontTextStyleSubheadline];
    return [UIFont systemFontOfSize:((NSNumber *)[descriptor objectForKey:UIFontDescriptorSizeAttribute]).doubleValue + 1.0];
}

- (void)togglePlayButton {
    dispatch_async(dispatch_get_main_queue(), ^{
        _imageView.highlighted = !_imageView.highlighted;
        _barLevelsView.hidden = !_barLevelsView.hidden;
    });
}

- (BOOL)isShowingPause {
    return _imageView.highlighted;
}

- (void)restoreButton {
    _imageView.highlighted = NO;
    _barLevelsView.hidden = YES;
    [self setSelected:NO];
}

- (void)resetButton {
    [self restoreButton];
    _playedOnce = NO;
}

- (BOOL)isSelected {
    return _selected;
}

-(void)setSelected:(BOOL)isSelected {
    _selected = isSelected;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (isSelected) {
            UIColor *systemBlueColor;
            if (@available(iOS 13.0, *)) {
                systemBlueColor = [UIColor systemBlueColor];
            } else {
                systemBlueColor = [UIColor colorWithRed:0.0/255.0 green:122.0/255.0 blue:255.0/255.0 alpha:1];
            }
            self.layer.shadowColor = systemBlueColor.CGColor;
            self.backgroundColor = [UIColor selectedBackgroundColor];
            self.layer.borderColor = [UIColor selectedLayerBorderColor].CGColor;
            _imageView.tintColor = systemBlueColor;
            
        } else {
            self.layer.shadowColor = [UIColor clearColor].CGColor;
            self.backgroundColor = [UIColor unselectedBackgroundColor];
            self.layer.borderColor = [UIColor unselectedLayerBorderColor].CGColor;
            if (@available(iOS 13.0, *)) {
                _imageView.tintColor = [UIColor systemGray3Color];
            } else {
                _imageView.tintColor = [UIColor colorWithRed:199.0/255.0 green:199.0/255.0 blue:204.0/255.0 alpha:1];
            }
        }
    });
}

- (void)enableInteraction:(BOOL)enabled {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.userInteractionEnabled = enabled;
        self.alpha = enabled ? 1.0 : 0.5;
    });
}

- (BOOL)isEnabled {
    return self.userInteractionEnabled;
}

- (void)setEnabled:(BOOL)enabled {
    self.userInteractionEnabled = enabled;
    self.alpha = enabled ? 1.0 : 0.5;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (_firstLayoutTime) {
        _firstLayoutTime = NO;
        CGFloat buttonHeight = ORKExpectedLabelHeight(_titleLabel) + ORKExpectedLabelHeight(_detailLabel) + ORKTinnitusButtonViewAdditionalHeightPadding;
        
        CGFloat detailHeight = ORKExpectedLabelHeight(_detailLabel);
        CGFloat titleHeight = ORKExpectedLabelHeight(_titleLabel);
        
        _heightConstraint.constant = buttonHeight;
        _middlePosition.constant = (titleHeight - detailHeight)/2;
        
        [self setNeedsLayout];
    } else {
        _subViewsAutoLayoutFinished = YES;
        if (_didFinishLayoutBlock) {
            self.didFinishLayoutBlock();
        }
    }
}

- (BOOL)buttonFinishedAutoLayout {
    return _subViewsAutoLayoutFinished;
}

- (void)setUpConstraints {
    _heightConstraint = [self.heightAnchor constraintEqualToConstant:ORKTinnitusButtonViewButtonViewHeight];
    _heightConstraint.active = YES;

    _middlePosition = [_middleSeparatorView.centerYAnchor constraintEqualToAnchor:self.centerYAnchor];
    _middlePosition.active = YES;
    
    [_middleSeparatorView.heightAnchor constraintEqualToConstant:1.0].active = YES;
    [_middleSeparatorView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor].active = YES;
    [_middleSeparatorView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor].active = YES;
    
    [_titleLabel.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:ORKTinnitusButtonViewPadding].active = YES;
    [_titleLabel.bottomAnchor constraintEqualToAnchor:_middleSeparatorView.topAnchor].active = YES;
    
    [_barLevelsView.leadingAnchor constraintEqualToAnchor:_titleLabel.trailingAnchor constant:2.0].active = YES;
    [_barLevelsView.centerYAnchor constraintEqualToAnchor:_titleLabel.centerYAnchor constant:-4.0].active = YES;
    [_barLevelsView.widthAnchor constraintEqualToConstant:25.0].active = YES;
    [_barLevelsView.heightAnchor constraintEqualToConstant:21.0].active = YES;
    
    [_detailLabel.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:ORKTinnitusButtonViewPadding].active = YES;
    [_detailLabel.trailingAnchor constraintEqualToAnchor:_imageView.leadingAnchor].active = YES;
    [_detailLabel.topAnchor constraintEqualToAnchor:_middleSeparatorView.bottomAnchor].active = YES;
    
    [_imageView.heightAnchor constraintEqualToConstant:ORKTinnitusButtonViewImageHeight].active = YES;
    [_imageView.widthAnchor constraintEqualToConstant:ORKTinnitusButtonViewImageWidth].active = YES;
    [_imageView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-ORKTinnitusButtonViewPadding].active = YES;
    [_imageView.centerYAnchor constraintEqualToAnchor:self.centerYAnchor].active = YES;
}

@end

@implementation ORKTinnitusButtonView(NSArrayUtils)
- (void)setEnabledWithNSNumber:(NSNumber *)boolNum {
    [self setEnabled:[boolNum boolValue]];
}
@end
