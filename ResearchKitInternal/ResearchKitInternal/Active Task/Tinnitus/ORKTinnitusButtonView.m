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
// apple-internal

#import "ORKTinnitusButtonView.h"

#import "AAPLUtils.h"

#import <QuartzCore/QuartzCore.h>
#import <ResearchKit/ORKHelpers_Internal.h>
#import <ResearchKit/ResearchKit_Private.h>
#import <ResearchKitActiveTask/UIColor+Custom.h>

static const CGFloat ORKTinnitusButtonViewHeight = 82.0;
static const CGFloat ORKTinnitusButtonViewImageSize = 36.0;
static const CGFloat ORKTinnitusButtonViewInsetAdjustment = 4.0;
static const CGFloat ORKTinnitusButtonViewPadding = 16.0;
static const CGFloat ORKTinnitusButtonViewBarLevelsHeight = 21.0;
static const CGFloat ORKTinnitusButtonViewBarLevelsWidth = 30.0;

@interface ORKTinnitusButtonView () <UIGestureRecognizerDelegate> {
    NSString *_titleText;
    NSString *_detailText;
    
    UIImageView *_playView;
    UIImageView *_barLevelsView;
    UILabel * _titleLabel;
    UILabel * _detailLabel;
    UIView *_middleSeparatorView;
    
    BOOL _subViewsAutoLayoutFinished;
    BOOL _selected;
    BOOL _announceEnabled;
    
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
    _announceEnabled = YES;
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    [super traitCollectionDidChange:previousTraitCollection];
    
    _titleLabel.font = [[self class] titleFont];
    _detailLabel.font = [[self class] detailFont];
    
    [self setSelected:_selected];
    [self layoutIfNeeded];
}

- (void)setupView {
    self.opaque = YES;
    self.layer.masksToBounds = NO;
    
    self.layer.cornerRadius = 10.0;
    self.layer.borderWidth = 3.0;
    
    self.contentMode = UIViewContentModeCenter;
    
    _middleSeparatorView = [UIView new];
    _middleSeparatorView.backgroundColor = [UIColor clearColor];
    [self addSubview:_middleSeparatorView];
    _middleSeparatorView.translatesAutoresizingMaskIntoConstraints = NO;
    
    _titleLabel = [[UILabel alloc] init];
    _titleLabel.font = [[self class] titleFont];
    _titleLabel.numberOfLines = 0;
    _titleLabel.textAlignment = NSTextAlignmentNatural;
    [self addSubview:_titleLabel];
    _titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _titleLabel.text = _titleText;
    if (@available(iOS 13.0, *)) {
        _titleLabel.textColor = [UIColor labelColor];
    }
    _detailLabel = [[UILabel alloc] init];
    _detailLabel.font = [[self class] detailFont];
    _detailLabel.numberOfLines = 0;
    _detailLabel.textAlignment = NSTextAlignmentNatural;
    if (@available(iOS 13.0, *)) {
        _detailLabel.textColor = [UIColor secondaryLabelColor];
    }
    [self addSubview:_detailLabel];
    _detailLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _detailLabel.text = _detailText;
    _detailLabel.adjustsFontSizeToFitWidth = YES;
    
    UIImage *playImage;
    UIImage *stopImage;
    
    if (@available(iOS 13.0, *)) {
        UIImageSymbolConfiguration *imageConfig = [UIImageSymbolConfiguration configurationWithPointSize:ORKTinnitusButtonViewImageSize weight:UIImageSymbolWeightRegular scale:UIImageSymbolScaleDefault];
        playImage = [[[UIImage systemImageNamed:@"play.circle.fill"] imageByApplyingSymbolConfiguration:imageConfig] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        stopImage = [[[UIImage systemImageNamed:@"pause.circle.fill"] imageByApplyingSymbolConfiguration:imageConfig] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    }
    
    _playView = [[UIImageView alloc] initWithImage:playImage highlightedImage:stopImage];
    _playView.contentMode = UIViewContentModeCenter;
    _playView.layer.cornerRadius = ORKTinnitusButtonViewImageSize/2;
    _playView.clipsToBounds = NO;
    _playView.tintColor = UIColor.tinnitusPlayBackgroundColor;
    _playView.backgroundColor = UIColor.systemBlueColor;
    [self addSubview:_playView];
    _playView.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSMutableArray *barImages = [[NSMutableArray alloc] init];
    for (int i = 0 ; i < 21 ; i ++) {
        // workaround to fix no tint color on animated images bug
        UIImage *blackImage = [UIImage imageNamed:[NSString stringWithFormat:@"tinnitus_bar_levels_%i", i] inBundle:ORKBundle() compatibleWithTraitCollection:nil];
        UIImage *newImage = [blackImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        UIGraphicsBeginImageContextWithOptions(blackImage.size, NO, blackImage.scale);
        [UIColor.systemBlueColor set];
        [newImage drawInRect:CGRectMake(0, 0, blackImage.size.width, blackImage.size.height)];
        newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        [barImages addObject:newImage];
    }
    _barLevelsView = [[UIImageView alloc] init];
    [_barLevelsView setAnimationImages:barImages];
    _barLevelsView.animationDuration = 1.5;
    _barLevelsView.animationRepeatCount = 0;
    
    [self addSubview:_barLevelsView];
    _barLevelsView.translatesAutoresizingMaskIntoConstraints = NO;
    [_barLevelsView startAnimating];
    _barLevelsView.hidden = YES;
    
    _tapOffGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
    _tapOffGestureRecognizer.delegate = self;
    [self addGestureRecognizer:_tapOffGestureRecognizer];
    
    self.backgroundColor = UIColor.tinnitusButtonBackgroundColor;
    
    _hapticFeedback = [[UIImpactFeedbackGenerator alloc] initWithStyle: UIImpactFeedbackStyleMedium];
    
    [self setSelected:NO];
    
    self.accessibilityLabel = _titleText;
    self.accessibilityHint = AAPLLocalizedString(@"TINNITUS_BUTTON_ACCESSIBILITY_HINT", nil);
}


- (void)enableAccessibilityAnnouncements:(BOOL)shouldAnnouce {
    if (shouldAnnouce) {
        self.accessibilityLabel = _titleText;
        self.accessibilityHint = !_selected ? AAPLLocalizedString(@"TINNITUS_BUTTON_ACCESSIBILITY_HINT", nil) : nil;
    } else {
        self.accessibilityLabel = nil;
        self.accessibilityHint = nil;
    }
    _announceEnabled = shouldAnnouce;
}

- (void)simulateTap {
    [self tapAction:nil];
}

#pragma mark - Accessibility

- (UIAccessibilityTraits)accessibilityTraits {
    if (_selected) {
        self.accessibilityHint = nil;
        return UIAccessibilityTraitSelected;
    } else {
        if (_announceEnabled) {
            self.accessibilityHint = AAPLLocalizedString(@"TINNITUS_BUTTON_ACCESSIBILITY_HINT", nil);
        }
        return UIAccessibilityTraitNone;
    }
}

- (BOOL)isAccessibilityElement {
    return YES;
}

- (void)tapAction:(UITapGestureRecognizer *)recognizer {
    dispatch_async(dispatch_get_main_queue(), ^{
        [_hapticFeedback impactOccurred];
        _simulatedTap = (recognizer == nil);
        if (!_selected) {
            [self setSelected:!_selected];
            _playView.highlighted = YES;
            _barLevelsView.hidden = NO;
            if (_simulatedTap) {
                UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, [NSString stringWithFormat:AAPLLocalizedString(@"TINNITUS_BUTTON_ACCESSIBILITY_ANNOUNCEMENT", nil), _titleText]);
            }
        } else {
            _playView.highlighted = !_playView.highlighted;
            _barLevelsView.hidden = !_barLevelsView.hidden;
            
        }
        _playedOnce = YES;
        if (_delegate && [_delegate respondsToSelector:@selector(tinnitusButtonViewPressed:)]) {
            [_delegate tinnitusButtonViewPressed:self];
        }
    });
}

+ (UIFont *)titleFont {
    UIFontDescriptor *descriptor = [UIFontDescriptor preferredFontDescriptorWithTextStyle:UIFontTextStyleTitle3];
    return [UIFont systemFontOfSize:[[descriptor objectForKey: UIFontDescriptorSizeAttribute] doubleValue] + 1.0 weight:UIFontWeightBold];
}

+ (UIFont *)detailFont {
    UIFontDescriptor *descriptor = [UIFontDescriptor preferredFontDescriptorWithTextStyle:UIFontTextStyleBody];
    return [UIFont systemFontOfSize:((NSNumber *)[descriptor objectForKey:UIFontDescriptorSizeAttribute]).doubleValue + 1.0];
}

- (void)togglePlayButton {
    dispatch_async(dispatch_get_main_queue(), ^{
        _playView.highlighted = !_playView.highlighted;
        _barLevelsView.hidden = !_barLevelsView.hidden;
    });
}

- (BOOL)isShowingPause {
    return _playView.highlighted;
}

- (void)restoreButton {
    _playView.highlighted = NO;
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
        self.layer.borderColor = isSelected ? [UIColor systemBlueColor].CGColor : [UIColor clearColor].CGColor;
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
    
    _subViewsAutoLayoutFinished = YES;
    if (_didFinishLayoutBlock) {
        self.didFinishLayoutBlock();
    }
}

- (BOOL)buttonFinishedAutoLayout {
    return _subViewsAutoLayoutFinished;
}

- (void)setUpConstraints {
    [self.heightAnchor constraintGreaterThanOrEqualToConstant:ORKTinnitusButtonViewHeight].active = YES;
    
    [_middleSeparatorView.heightAnchor constraintEqualToConstant:2.0].active = YES;
    [_middleSeparatorView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor].active = YES;
    [_middleSeparatorView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor].active = YES;
    
    [_playView.heightAnchor constraintEqualToConstant:ORKTinnitusButtonViewImageSize - ORKTinnitusButtonViewInsetAdjustment].active = YES;
    [_playView.widthAnchor constraintEqualToConstant:ORKTinnitusButtonViewImageSize - ORKTinnitusButtonViewInsetAdjustment].active = YES;
    [_playView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:ORKTinnitusButtonViewPadding + ORKTinnitusButtonViewInsetAdjustment / 2].active = YES;
    [_playView.centerYAnchor constraintEqualToAnchor:self.centerYAnchor].active = YES;
    
    [_titleLabel.topAnchor constraintEqualToAnchor:self.topAnchor constant:ORKTinnitusButtonViewPadding].active = YES;
    [_titleLabel.leadingAnchor constraintEqualToAnchor:_playView.trailingAnchor constant:ORKTinnitusButtonViewPadding + ORKTinnitusButtonViewInsetAdjustment / 2].active = YES;
    [_titleLabel.trailingAnchor constraintLessThanOrEqualToAnchor:self.trailingAnchor constant:-(ORKTinnitusButtonViewBarLevelsWidth+ORKTinnitusButtonViewPadding)].active = YES;
    if (_detailText) {
        [_titleLabel.bottomAnchor constraintEqualToAnchor:_middleSeparatorView.topAnchor].active = YES;
    } else {
        [_titleLabel.bottomAnchor constraintEqualToAnchor:self.bottomAnchor constant:-ORKTinnitusButtonViewPadding].active = YES;
    }
    
    [_barLevelsView.leadingAnchor constraintEqualToAnchor:_titleLabel.trailingAnchor constant:2.0].active = YES;
    [_barLevelsView.centerYAnchor constraintEqualToAnchor:_titleLabel.centerYAnchor constant:2.0].active = YES;
    [_barLevelsView.widthAnchor constraintEqualToConstant:ORKTinnitusButtonViewBarLevelsWidth].active = YES;
    [_barLevelsView.heightAnchor constraintEqualToConstant:ORKTinnitusButtonViewBarLevelsHeight].active = YES;
    
    [_detailLabel.leadingAnchor constraintEqualToAnchor:_playView.trailingAnchor constant:ORKTinnitusButtonViewPadding + ORKTinnitusButtonViewInsetAdjustment / 2].active = YES;
    [_detailLabel.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-ORKTinnitusButtonViewPadding].active = YES;
    [_detailLabel.topAnchor constraintEqualToAnchor:_middleSeparatorView.bottomAnchor].active = YES;
    [_detailLabel.bottomAnchor constraintEqualToAnchor:self.bottomAnchor constant:-ORKTinnitusButtonViewPadding].active = YES;
}

@end

@implementation ORKTinnitusButtonView(NSArrayUtils)
- (void)setEnabledWithNSNumber:(NSNumber *)boolNum {
    [self setEnabled:[boolNum boolValue]];
}
@end
