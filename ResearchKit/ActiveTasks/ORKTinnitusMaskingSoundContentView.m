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

#import "ORKTinnitusMaskingSoundContentView.h"
#import "ORKHelpers_Internal.h"
#import "ORKTinnitusTypes.h"
#import "ORKSkin.h"

#import "ORKCheckmarkView.h"

static int const ORKTinnitusMaskingSoundStepPlaybackButtonSize = 36;
static int const ORKTinnitusMaskingSoundStepPadding = 8;
static int const ORKTinnitusMaskingSoundStepMargin = 16;
static int const ORKTinnitusMaskingSoundStepSliderMargin = 22;
static int const ORKTinnitusMaskingSoundStepSliderSpacing = 30;

@class ORKTinnitusMaskingSoundButtonView;

@protocol ORKTinnitusMaskingSoundButtonViewDelegate <NSObject>

@required
- (void)pressed:(ORKTinnitusMaskingSoundButtonView *)maskingButtonView;

@end

@interface ORKTinnitusMaskingSoundButtonView : UIView <UIGestureRecognizerDelegate>

@property (nonatomic) NSString *title;
@property (nonatomic) NSString *value;
@property (nonatomic) UILabel *titleLabel;
@property (nonatomic) UIView *separatorView;
@property (nonatomic) ORKCheckmarkView *checkmarkView;
@property (readonly) BOOL checked;
@property (readonly) BOOL includeSeparator;

@property (nonatomic, weak)id<ORKTinnitusMaskingSoundButtonViewDelegate> delegate;

- (instancetype)initWithTitle:(NSString *)title value:(NSString *)value includeSeparator:(BOOL)includeSeparator;
- (void)setChecked:(NSNumber *)checked;

@end

@implementation ORKTinnitusMaskingSoundButtonView

- (instancetype)initWithTitle:(NSString *)title value:(NSString *)value includeSeparator:(BOOL)includeSeparator {
    self = [super init];
    if (self) {
        self.title = title;
        self.value = value;
        _includeSeparator = includeSeparator;
        [self setupView];
        [self setUpConstraints];
    }
    return self;
}

- (void)setChecked:(NSNumber *)checked {
    _checkmarkView.checked = [checked boolValue];
}

- (BOOL)checked {
    return _checkmarkView.checked;
}

- (void)setAlphaWithNSNumber:(NSNumber *)alpha {
    self.alpha = [alpha floatValue];
}

- (void)setupView {
    self.backgroundColor = [UIColor clearColor];
    
    _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _titleLabel.numberOfLines = 1;
    _titleLabel.text = self.title;
    _titleLabel.textAlignment = NSTextAlignmentLeft;
    
    UIFontDescriptor *descriptor = [UIFontDescriptor preferredFontDescriptorWithTextStyle:UIFontTextStyleBody];
    _titleLabel.font = [UIFont systemFontOfSize:[[descriptor objectForKey: UIFontDescriptorSizeAttribute] doubleValue] weight:UIFontWeightRegular];
    [self addSubview:_titleLabel];
    
    if (_includeSeparator) {
        _separatorView = [[UIView alloc] initWithFrame:CGRectZero];
        _separatorView.backgroundColor = [[UIColor systemGrayColor] colorWithAlphaComponent:0.5];
        if (@available(iOS 13.0, *)) {
            _separatorView.backgroundColor = [UIColor systemGray5Color];
        }
        _separatorView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_separatorView];
    }
    
    _checkmarkView = [[ORKCheckmarkView alloc] initWithRadius:8.5 checkedImage:nil uncheckedImage:nil];
    [_checkmarkView setChecked:NO];
    [self addSubview:_checkmarkView];
    _checkmarkView.contentMode = UIViewContentModeScaleAspectFill;
    _checkmarkView.translatesAutoresizingMaskIntoConstraints = NO;
    
    UITapGestureRecognizer *singleFingerTap =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(handleSingleTap:)];
    [self addGestureRecognizer:singleFingerTap];
}

- (void)handleSingleTap:(UITapGestureRecognizer *)recognizer {
    if ([_delegate respondsToSelector:@selector(pressed:)]) {
        [_delegate pressed:self];
    }
}

- (void)setUpConstraints {
    [_titleLabel.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:20.0].active = YES;
    [_titleLabel.centerYAnchor constraintEqualToAnchor:self.centerYAnchor].active = YES;
    
    if (_includeSeparator) {
        [_separatorView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:20.0].active = YES;
        [_separatorView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:0.0].active = YES;
        [_separatorView.heightAnchor constraintEqualToConstant:1.0].active = YES;
        [_separatorView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor].active = YES;
    }
    
    [_checkmarkView.leadingAnchor constraintEqualToAnchor:_titleLabel.trailingAnchor constant:16.0].active = YES;
    [_checkmarkView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-16.0].active = YES;
    [_checkmarkView.centerYAnchor constraintEqualToAnchor:self.centerYAnchor].active = YES;
}

- (CGSize)intrinsicContentSize {
    CGSize intrinsic = [super intrinsicContentSize];
    return (CGSize){.width=intrinsic.width, self.frame.size.height == 0.0 ? ORKExpectedLabelHeight(_titleLabel) + 30.0 : self.frame.size.height};
}

@end

@interface ORKTinnitusMaskingSoundContentView () <ORKTinnitusMaskingSoundButtonViewDelegate> {
    NSMutableArray *_buttons;
    UIScrollView *_scrollView;
}
@property (nonatomic, strong) NSString *buttonTitle;
@property (nonatomic, strong) UIView *roundedView;
@property (nonatomic, strong) UIButton *playButtonView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIImageView *barLevelsView;
@property (nonatomic, strong) UIView *separatorView;
@property (nonatomic, strong) UISlider *volumeSlider;
@property (nonatomic, strong) UIImageView *sliderFull;
@property (nonatomic, strong) UIImageView *sliderEmpty;
@property (nonatomic, strong) UIView *choicesView;

@end

@implementation ORKTinnitusMaskingSoundContentView

- (instancetype)initWithButtonTitle:(NSString *)title {
    self = [super init];
    if (self) {
        self.buttonTitle = title;
        [self commonInit];
    }
    
    return self;
}

- (void)commonInit
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(volumeDidChange:) name:@"AVSystemController_SystemVolumeDidChangeNotification" object:nil];

    [self setupScrollView];

    self.roundedView = [[UIView alloc] init];
    _roundedView.layer.cornerRadius = 10;
    [_scrollView addSubview:_roundedView];

    self.playButtonView = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *playImage;
    if (@available(iOS 13.0, *)) {
        playImage = [UIImage systemImageNamed:@"play.fill"];
        _playButtonView.tintColor = [UIColor systemBlueColor];
        _playButtonView.backgroundColor = [UIColor systemGray6Color];
        _playButtonView.layer.cornerRadius = ORKTinnitusMaskingSoundStepPlaybackButtonSize/2;
        _roundedView.backgroundColor = [UIColor tertiarySystemBackgroundColor];
    } else {
        playImage = [UIImage imageNamed:@"play" inBundle:ORKBundle() compatibleWithTraitCollection:nil];
        _roundedView.backgroundColor = [UIColor whiteColor];
    }

    [_playButtonView setImage:playImage forState:UIControlStateNormal];
    [_playButtonView addTarget:self action:@selector(playButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [_roundedView addSubview:_playButtonView];
    
    self.titleLabel = [[UILabel alloc] init];
    _titleLabel.text = self.buttonTitle;
    UIFontDescriptor *descriptor = [UIFontDescriptor preferredFontDescriptorWithTextStyle:UIFontTextStyleHeadline];
    _titleLabel.font = [UIFont systemFontOfSize:[[descriptor objectForKey: UIFontDescriptorSizeAttribute] doubleValue] + 1.0 weight:UIFontWeightSemibold];
    [_roundedView addSubview:_titleLabel];
    
    self.barLevelsView = [[UIImageView alloc] init];
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
    [_barLevelsView setAnimationImages:barImages];
    _barLevelsView.animationDuration = 1.33;
    _barLevelsView.animationRepeatCount = 0;
    _barLevelsView.backgroundColor = [UIColor clearColor];
    _barLevelsView.hidden = YES;
    [_barLevelsView startAnimating];
    [_roundedView addSubview:_barLevelsView];

    _separatorView = [[UIView alloc] initWithFrame:CGRectZero];
    _separatorView.backgroundColor = [[UIColor systemGrayColor] colorWithAlphaComponent:0.5];
    if (@available(iOS 13.0, *)) {
        _separatorView.backgroundColor = [UIColor systemGray5Color];
    }
    [_roundedView addSubview:_separatorView];

    self.choicesView = [[UIView alloc] init];
    [_roundedView addSubview:_choicesView];
    
    UIImage *sliderFullImage;
    UIImage *sliderEmptyImage;
    UIColor *tintColor = [UIColor grayColor];
    if (@available(iOS 13.0, *)) {
        sliderFullImage = [UIImage systemImageNamed:@"speaker.wave.3.fill"];
        sliderEmptyImage = [UIImage systemImageNamed:@"speaker.fill"];
        tintColor = [UIColor secondaryLabelColor];
    }
    
    self.sliderFull = [[UIImageView alloc] initWithImage:sliderFullImage];
    self.sliderEmpty = [[UIImageView alloc] initWithImage:sliderEmptyImage];
    _sliderFull.tintColor = tintColor;
    _sliderEmpty.tintColor = tintColor;
    [_roundedView addSubview:_sliderEmpty];
    [_roundedView addSubview:_sliderFull];
    
    self.volumeSlider = [[UISlider alloc] init];
    [_volumeSlider addTarget:self action:@selector(volumeSliderChanged:) forControlEvents:UIControlEventValueChanged];
    [_roundedView addSubview:_volumeSlider];
    
    _buttons = [[NSMutableArray alloc] init];
    
    [self setupConstraints];
}

- (void)setupConstraints {
    self.translatesAutoresizingMaskIntoConstraints = NO;

    [_roundedView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [[_roundedView.topAnchor constraintGreaterThanOrEqualToAnchor:self.topAnchor constant:ORKTinnitusMaskingSoundStepPadding] setActive:YES];
    [[_roundedView.widthAnchor constraintEqualToAnchor:_scrollView.widthAnchor constant:-2*ORKTinnitusMaskingSoundStepPadding] setActive:YES];
    [[_roundedView.centerXAnchor constraintEqualToAnchor:_scrollView.centerXAnchor] setActive:YES];

    [_playButtonView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [[_playButtonView.topAnchor constraintEqualToAnchor:_roundedView.topAnchor constant:ORKTinnitusMaskingSoundStepMargin] setActive:YES];
    [[_playButtonView.heightAnchor constraintEqualToConstant:ORKTinnitusMaskingSoundStepPlaybackButtonSize] setActive:YES];
    [[_playButtonView.widthAnchor constraintEqualToConstant:ORKTinnitusMaskingSoundStepPlaybackButtonSize] setActive:YES];
    [[_playButtonView.leadingAnchor constraintEqualToAnchor:_roundedView.leadingAnchor constant:ORKTinnitusMaskingSoundStepMargin] setActive:YES];
    
    [_titleLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [[_titleLabel.centerYAnchor constraintEqualToAnchor:_playButtonView.centerYAnchor] setActive:YES];
    [[_titleLabel.leadingAnchor constraintEqualToAnchor:_playButtonView.trailingAnchor constant:ORKTinnitusMaskingSoundStepMargin] setActive:YES];

    [_barLevelsView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [_barLevelsView.leadingAnchor constraintEqualToAnchor:_titleLabel.trailingAnchor constant:2.0].active = YES;
    [_barLevelsView.centerYAnchor constraintEqualToAnchor:_titleLabel.centerYAnchor constant:3.0].active = YES;
    [_barLevelsView.widthAnchor constraintEqualToConstant:30.0].active = YES;
    [_barLevelsView.heightAnchor constraintEqualToConstant:21.0].active = YES;
    
    _separatorView.translatesAutoresizingMaskIntoConstraints = NO;
    [_separatorView.leadingAnchor constraintEqualToAnchor:_roundedView.leadingAnchor constant:ORKTinnitusMaskingSoundStepMargin].active = YES;
    [_separatorView.trailingAnchor constraintEqualToAnchor:_roundedView.trailingAnchor].active = YES;
    [_separatorView.heightAnchor constraintEqualToConstant:1.0].active = YES;
    [_separatorView.topAnchor constraintEqualToAnchor:_playButtonView.bottomAnchor constant:ORKTinnitusMaskingSoundStepMargin].active = YES;
    
    [_choicesView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [_choicesView.leadingAnchor constraintEqualToAnchor:_roundedView.leadingAnchor constant:ORKTinnitusMaskingSoundStepMargin].active = YES;
    [_choicesView.trailingAnchor constraintEqualToAnchor:_roundedView.trailingAnchor].active = YES;
    [_choicesView.topAnchor constraintEqualToAnchor:_separatorView.bottomAnchor constant:ORKTinnitusMaskingSoundStepMargin].active = YES;
    [_choicesView.bottomAnchor constraintEqualToAnchor:_roundedView.bottomAnchor].active = YES;

    [_volumeSlider setTranslatesAutoresizingMaskIntoConstraints:NO];
    [[_volumeSlider.topAnchor constraintEqualToAnchor:_separatorView.topAnchor constant:ORKTinnitusMaskingSoundStepSliderSpacing] setActive:YES];
    [[_volumeSlider.heightAnchor constraintEqualToConstant:ORKTinnitusMaskingSoundStepPlaybackButtonSize] setActive:YES];
    [[_volumeSlider.widthAnchor constraintEqualToAnchor:_roundedView.widthAnchor multiplier:0.62] setActive:YES];
    [[_volumeSlider.centerXAnchor constraintEqualToAnchor:_roundedView.centerXAnchor] setActive:YES];
    [[_volumeSlider.bottomAnchor constraintEqualToAnchor:_roundedView.bottomAnchor constant:-ORKTinnitusMaskingSoundStepSliderSpacing] setActive:YES];

    [_sliderEmpty setTranslatesAutoresizingMaskIntoConstraints:NO];
    [[_sliderEmpty.centerYAnchor constraintEqualToAnchor:_volumeSlider.centerYAnchor constant:1] setActive:YES];
    [[_sliderEmpty.leadingAnchor constraintEqualToAnchor:_roundedView.leadingAnchor constant:ORKTinnitusMaskingSoundStepSliderMargin] setActive:YES];
    
    [_sliderFull setTranslatesAutoresizingMaskIntoConstraints:NO];
    [[_sliderFull.centerYAnchor constraintEqualToAnchor:_volumeSlider.centerYAnchor constant:1] setActive:YES];
    [[_sliderFull.trailingAnchor constraintEqualToAnchor:_roundedView.trailingAnchor constant:-ORKTinnitusMaskingSoundStepSliderMargin] setActive:YES];
}

- (ORKTinnitusMaskingSoundButtonView *)addButtonForTitle:(NSString *)title value:(NSString *)value topView:(UIView *)topView isLastButton:(BOOL)isLast {
    ORKTinnitusMaskingSoundButtonView *button = [[ORKTinnitusMaskingSoundButtonView alloc] initWithTitle:title value:value includeSeparator:!isLast];
    button.translatesAutoresizingMaskIntoConstraints = NO;
    [_buttons addObject:button];
    [_choicesView addSubview:button];
    button.delegate = self;
    [button.leadingAnchor constraintEqualToAnchor:_roundedView.leadingAnchor].active = YES;
    [button.trailingAnchor constraintEqualToAnchor:_roundedView.trailingAnchor].active = YES;
    [button.topAnchor constraintEqualToAnchor:topView.bottomAnchor].active = YES;
    [button setAlpha:0.0];
    
    return button;
}

- (void)setupScrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectZero];
    }
    [self addSubview:_scrollView];
    _scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    [[_scrollView.topAnchor constraintEqualToAnchor:self.topAnchor] setActive:YES];
    [[_scrollView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor] setActive:YES];
    [[_scrollView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor] setActive:YES];
    [[_scrollView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor] setActive:YES];
    
    _scrollView.scrollEnabled = YES;
}

- (nullable NSString *)getAnswer {
    NSArray <ORKTinnitusMaskingSoundButtonView *>*checkedButton = [_buttons filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        ORKTinnitusMaskingSoundButtonView *buttonView = (ORKTinnitusMaskingSoundButtonView *)evaluatedObject;
        return buttonView.checked;
    }]];
    if (checkedButton.count == 1) {
        return checkedButton[0].value;
    }
    return nil;
}

- (void)displayChoices {
    [self layoutIfNeeded];

    [_volumeSlider removeFromSuperview];
    [_sliderEmpty removeFromSuperview];
    [_sliderFull removeFromSuperview];
        
    ORKTinnitusMaskingSoundButtonView *btn = [self addButtonForTitle:ORKLocalizedString(@"TINNITUS_MASKING_ANSWER_VERY_EFFECTIVE", nil)
                                                               value:ORKTinnitusMaskingAnswerVeryEffective
                                                             topView:_separatorView
                                                        isLastButton:NO];
    
    btn = [self addButtonForTitle:ORKLocalizedString(@"TINNITUS_MASKING_ANSWER_SOMEWHAT_EFFECTIVE", nil)
                            value:ORKTinnitusMaskingAnswerSomewhatEffective
                          topView:btn
                     isLastButton:NO];
    btn = [self addButtonForTitle:ORKLocalizedString(@"TINNITUS_MASKING_ANSWER_NOT_EFFECTIVE", nil)
                            value:ORKTinnitusMaskingAnswerNotEffective
                          topView:btn
                     isLastButton:NO];
    btn = [self addButtonForTitle:ORKLocalizedString(@"TINNITUS_MASKING_ANSWER_NOTA", nil)
                            value:ORKTinnitusMaskingAnswerNoneOfTheAbove
                          topView:btn
                     isLastButton:YES];
    
    [btn.bottomAnchor constraintEqualToAnchor:_choicesView.bottomAnchor].active = YES;
    
    [UIView animateWithDuration:0.1 animations:^{
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.2 animations:^{
            for (UIView *button in _buttons) {
                [button setAlpha:1];
            }
        }];
    }];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Actions

- (void)playButtonTapped:(UIButton *)sender {
    if (_delegate && [_delegate respondsToSelector:@selector(pressedPlaybackButton:)]) {
        BOOL isPlaying = [_delegate pressedPlaybackButton:sender];
        [self.barLevelsView setHidden:!isPlaying];
        
        UIImage *image;
        if (@available(iOS 13.0, *)) {
            image = isPlaying?
            [UIImage systemImageNamed:@"pause.fill"]:
            [UIImage systemImageNamed:@"play.fill"];
            [_playButtonView setImage:image forState:UIControlStateNormal];
        }
    }
}

- (void)volumeSliderChanged:(UISlider *)sender {
    float volume = sender.value;
    [self.volumeSlider setValue:volume];

    if ([self.delegate respondsToSelector:@selector(raisedVolume:)]) {
        [self.delegate raisedVolume:volume];
    }
}

#pragma mark - ORKTinnitusMaskingSoundButtonViewDelegate

- (void)pressed:(ORKTinnitusMaskingSoundButtonView *)matchingButtonView {
    [_buttons makeObjectsPerformSelector:@selector(setChecked:) withObject:@NO];
    [matchingButtonView setChecked:@YES];
    if (_delegate && [_delegate respondsToSelector:@selector(buttonCheckedWithValue:)]) {
        [_delegate buttonCheckedWithValue:matchingButtonView.value];
    }
}

#pragma mark - Volume notifications

- (void)volumeDidChange:(NSNotification *)note {
    NSDictionary *userInfo = note.userInfo;
    NSNumber *volume = userInfo[@"AVSystemController_AudioVolumeNotificationParameter"];

    if (!_volumeSlider.isTracking) {
        [_volumeSlider setValue:volume.doubleValue];
    }

    if (volume.doubleValue > 0 && _barLevelsView.isHidden) {
        [self playButtonTapped:_playButtonView];
    }
}


@end

