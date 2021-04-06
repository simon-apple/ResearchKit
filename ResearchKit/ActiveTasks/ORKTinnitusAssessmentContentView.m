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

#import "ORKTinnitusAssessmentContentView.h"
#import "ORKHelpers_Internal.h"
#import "ORKTinnitusTypes.h"
#import "ORKSkin.h"
#import "UIColor+Custom.h"
#import "ORKCheckmarkView.h"

static int const ORKTinnitusAssessmentPlaybackButtonSize = 36;
static int const ORKTinnitusAssessmentPadding = 8;
static int const ORKTinnitusAssessmentMargin = 16;

@class ORKTinnitusAssessmentButtonView;

@protocol ORKTinnitusAssessmentButtonViewDelegate <NSObject>

@required
- (void)pressed:(ORKTinnitusAssessmentButtonView *)maskingButtonView;

@end

@interface ORKTinnitusAssessmentButtonView : UIView <UIGestureRecognizerDelegate>

@property (nonatomic) NSString *title;
@property (nonatomic) NSString *value;
@property (nonatomic) UILabel *titleLabel;
@property (nonatomic) UIView *separatorView;
@property (nonatomic) ORKCheckmarkView *checkmarkView;
@property (readonly) BOOL checked;
@property (readonly) BOOL includeSeparator;

@property (nonatomic, weak)id<ORKTinnitusAssessmentButtonViewDelegate> delegate;

- (instancetype)initWithTitle:(NSString *)title value:(NSString *)value includeSeparator:(BOOL)includeSeparator;
- (void)setChecked:(NSNumber *)checked;

@end

@implementation ORKTinnitusAssessmentButtonView

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

        if (@available(iOS 13.0, *)) {
            _separatorView.backgroundColor = [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull traits) {
                return traits.userInterfaceStyle == UIUserInterfaceStyleDark ? [UIColor systemGray3Color] : [UIColor systemGray5Color];
            }];
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
    
    self.accessibilityLabel = self.title;
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

- (UIAccessibilityTraits)accessibilityTraits {
     if (_checkmarkView.checked) {
         self.accessibilityHint = nil;
         return UIAccessibilityTraitSelected;
     } else {
         self.accessibilityHint = ORKLocalizedString(@"TINNITUS_BUTTON_ACCESSIBILITY_HINT", nil);
         return UIAccessibilityTraitNone;
     }
 }

- (BOOL)isAccessibilityElement {
     return YES;
 }

@end

@interface ORKTinnitusAssessmentContentView () <ORKTinnitusAssessmentButtonViewDelegate> {
    NSMutableArray *_buttons;
    BOOL _isTinnitusAssessment;
}
@property (nonatomic, strong) NSString *buttonTitle;
@property (nonatomic, strong) UIView *roundedView;
@property (nonatomic, strong) UIButton *playButtonView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIImageView *barLevelsView;
@property (nonatomic, strong) UIView *separatorView;
@property (nonatomic, strong) UIView *choicesView;
@property (nonatomic, strong) NSDictionary *buttonTitles;

@end

@implementation ORKTinnitusAssessmentContentView

- (instancetype)initForMaskingWithButtonTitle:(NSString *)title {
    self = [super init];
    if (self) {
        _isTinnitusAssessment = NO;
        self.buttonTitle = title;
        [self commonInit];
    }
    return self;
}

- (instancetype)initForTinnitusOverallAssesment {
    self = [super init];
    if (self) {
        _isTinnitusAssessment = YES;
        self.buttonTitle = ORKLocalizedString(@"TINNITUS_ASSESSMENT_SOUND_NAME", nil);
        [self commonInit];
    }
    return self;
}

- (void)commonInit
{
    self.roundedView = [[UIView alloc] init];
    _roundedView.layer.cornerRadius = 10;
    [self addSubview:_roundedView];

    self.playButtonView = [UIButton buttonWithType:UIButtonTypeCustom];
    if (@available(iOS 13.0, *)) {
        UIImage *playImage = [UIImage systemImageNamed:@"play.fill"];
        [_playButtonView setImage:playImage forState:UIControlStateNormal];

        _playButtonView.tintColor = [UIColor systemBlueColor];
        _playButtonView.layer.cornerRadius = ORKTinnitusAssessmentPlaybackButtonSize/2;
        
        _playButtonView.backgroundColor = UIColor.tinnitusPlayBackgroundColor;
        _roundedView.backgroundColor = UIColor.tinnitusButtonBackgroundColor;
    }

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
    _separatorView.backgroundColor = UIColor.tinnitusBackgroundColor;
    [_roundedView addSubview:_separatorView];

    self.choicesView = [[UIView alloc] init];
    [_roundedView addSubview:_choicesView];
        
    [self setupConstraints];
    [self setupChoices];
}

- (void)setupConstraints {
    self.translatesAutoresizingMaskIntoConstraints = NO;

    [_roundedView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [[_roundedView.topAnchor constraintGreaterThanOrEqualToAnchor:self.topAnchor constant:ORKTinnitusAssessmentPadding] setActive:YES];
    [[_roundedView.widthAnchor constraintEqualToAnchor:self.widthAnchor] setActive:YES];
    [[_roundedView.centerXAnchor constraintEqualToAnchor:self.centerXAnchor] setActive:YES];
    [_roundedView.bottomAnchor constraintLessThanOrEqualToAnchor:self.bottomAnchor].active = YES;

    [_playButtonView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [[_playButtonView.topAnchor constraintEqualToAnchor:_roundedView.topAnchor constant:ORKTinnitusAssessmentMargin] setActive:YES];
    [[_playButtonView.heightAnchor constraintEqualToConstant:ORKTinnitusAssessmentPlaybackButtonSize] setActive:YES];
    [[_playButtonView.widthAnchor constraintEqualToConstant:ORKTinnitusAssessmentPlaybackButtonSize] setActive:YES];
    [[_playButtonView.leadingAnchor constraintEqualToAnchor:_roundedView.leadingAnchor constant:ORKTinnitusAssessmentMargin] setActive:YES];
    
    [_titleLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [[_titleLabel.centerYAnchor constraintEqualToAnchor:_playButtonView.centerYAnchor] setActive:YES];
    [[_titleLabel.leadingAnchor constraintEqualToAnchor:_playButtonView.trailingAnchor constant:ORKTinnitusAssessmentMargin] setActive:YES];

    [_barLevelsView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [_barLevelsView.leadingAnchor constraintEqualToAnchor:_titleLabel.trailingAnchor constant:2.0].active = YES;
    [_barLevelsView.centerYAnchor constraintEqualToAnchor:_titleLabel.centerYAnchor constant:2.0].active = YES;
    [_barLevelsView.widthAnchor constraintEqualToConstant:30.0].active = YES;
    [_barLevelsView.heightAnchor constraintEqualToConstant:21.0].active = YES;
    
    _separatorView.translatesAutoresizingMaskIntoConstraints = NO;
    [_separatorView.leadingAnchor constraintEqualToAnchor:_roundedView.leadingAnchor constant:ORKTinnitusAssessmentMargin].active = YES;
    [_separatorView.trailingAnchor constraintEqualToAnchor:_roundedView.trailingAnchor].active = YES;
    [_separatorView.heightAnchor constraintEqualToConstant:1.0].active = YES;
    [_separatorView.topAnchor constraintEqualToAnchor:_playButtonView.bottomAnchor constant:ORKTinnitusAssessmentMargin].active = YES;
    
    [_choicesView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [_choicesView.leadingAnchor constraintEqualToAnchor:_roundedView.leadingAnchor constant:ORKTinnitusAssessmentMargin].active = YES;
    [_choicesView.trailingAnchor constraintEqualToAnchor:_roundedView.trailingAnchor].active = YES;
    [_choicesView.topAnchor constraintEqualToAnchor:_separatorView.bottomAnchor constant:ORKTinnitusAssessmentMargin].active = YES;
    [_choicesView.bottomAnchor constraintEqualToAnchor:_roundedView.bottomAnchor].active = YES;
}

- (NSString *)titleForValue:(NSString *)value {
    if (!self.buttonTitles) {
        self.buttonTitles = @{
            ORKTinnitusMaskingAnswerVeryEffective: @"TINNITUS_MASKING_ANSWER_VERY_EFFECTIVE",
            ORKTinnitusMaskingAnswerSomewhatEffective: @"TINNITUS_MASKING_ANSWER_SOMEWHAT_EFFECTIVE",
            ORKTinnitusMaskingAnswerNotEffective: @"TINNITUS_MASKING_ANSWER_NOT_EFFECTIVE",
            ORKTinnitusMaskingAnswerNoneOfTheAbove: @"TINNITUS_ASSESSMENT_ANSWER_NOTA",
            ORKTinnitusAssessmentAnswerVerySimilar: @"TINNITUS_ASSESSMENT_ANSWER_VERY_SIMILAR",
            ORKTinnitusAssessmentAnswerSomewhatSimilar: @"TINNITUS_ASSESSMENT_ANSWER_SOMEWHAT_SIMILAR",
            ORKTinnitusAssessmentAnswerNotSimilar: @"TINNITUS_ASSESSMENT_ANSWER_NOT_SIMILAR",
            ORKTinnitusAssessmentAnswerNoneOfTheAbove: @"TINNITUS_ASSESSMENT_ANSWER_NOTA"
        };
    }
    return ORKLocalizedString(_buttonTitles[value], nil);
}

- (ORKTinnitusAssessmentButtonView *)addButtonForValue:(NSString *)value topView:(UIView *)topView isLastButton:(BOOL)isLast {
    NSString *title = [self titleForValue:value];
    ORKTinnitusAssessmentButtonView *button = [[ORKTinnitusAssessmentButtonView alloc] initWithTitle:title value:value includeSeparator:!isLast];
    button.translatesAutoresizingMaskIntoConstraints = NO;
    [_buttons addObject:button];
    [_choicesView addSubview:button];
    button.delegate = self;
    [button.leadingAnchor constraintEqualToAnchor:_roundedView.leadingAnchor].active = YES;
    [button.trailingAnchor constraintEqualToAnchor:_roundedView.trailingAnchor].active = YES;
    [button.topAnchor constraintEqualToAnchor:topView.bottomAnchor].active = YES;
    
    return button;
}

- (void)setupChoices {
    _buttons = [[NSMutableArray alloc] init];

    NSString *value = _isTinnitusAssessment ? ORKTinnitusAssessmentAnswerVerySimilar : ORKTinnitusMaskingAnswerVeryEffective;
    ORKTinnitusAssessmentButtonView *btn = [self addButtonForValue:value topView:_separatorView isLastButton:NO];
    
    value = _isTinnitusAssessment ? ORKTinnitusAssessmentAnswerSomewhatSimilar : ORKTinnitusMaskingAnswerSomewhatEffective;
    btn = [self addButtonForValue:value topView:btn isLastButton:NO];
    
    value = _isTinnitusAssessment ? ORKTinnitusAssessmentAnswerNotSimilar : ORKTinnitusMaskingAnswerNotEffective;
    btn = [self addButtonForValue:value topView:btn isLastButton:NO];
    
    value = _isTinnitusAssessment ? ORKTinnitusAssessmentAnswerNoneOfTheAbove : ORKTinnitusMaskingAnswerNoneOfTheAbove;
    btn = [self addButtonForValue:value topView:btn isLastButton:YES];
    
    [btn.bottomAnchor constraintEqualToAnchor:_choicesView.bottomAnchor].active = YES;
}


- (nullable NSString *)getAnswer {
    NSArray <ORKTinnitusAssessmentButtonView *>*checkedButton = [_buttons filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        ORKTinnitusAssessmentButtonView *buttonView = (ORKTinnitusAssessmentButtonView *)evaluatedObject;
        return buttonView.checked;
    }]];
    if (checkedButton.count == 1) {
        return checkedButton[0].value;
    }
    return nil;
}

- (void)setDelegate:(id<ORKTinnitusAssessmentContentViewDelegate>)delegate {
    _delegate = delegate;
    
    if (_delegate) {
        [self playButtonTapped:_playButtonView];
    }
}

- (void)setPlaybackButtonPlaying:(BOOL)isPlaying {
    [self.barLevelsView setHidden:!isPlaying];
    
    UIImage *image;
    if (@available(iOS 13.0, *)) {
        image = isPlaying?
        [UIImage systemImageNamed:@"pause.fill"]:
        [UIImage systemImageNamed:@"play.fill"];
        [_playButtonView setImage:image forState:UIControlStateNormal];
    }
}

#pragma mark - Actions

- (void)playButtonTapped:(UIButton *)sender {
    if (_delegate && [_delegate respondsToSelector:@selector(pressedPlaybackButton:)]) {
        [self setPlaybackButtonPlaying:[_delegate pressedPlaybackButton:sender]];
    }
}

#pragma mark - ORKTinnitusMaskingSoundButtonViewDelegate

- (void)pressed:(ORKTinnitusAssessmentButtonView *)matchingButtonView {
    [_buttons makeObjectsPerformSelector:@selector(setChecked:) withObject:@NO];
    [matchingButtonView setChecked:@YES];
    
    if (_delegate && [_delegate respondsToSelector:@selector(buttonCheckedWithValue:)]) {
        [_delegate buttonCheckedWithValue:matchingButtonView.value];
    }
    
    if ([self.delegate respondsToSelector:@selector(shouldEnableContinue:)]) {
        [self.delegate shouldEnableContinue:YES];
    }
}

@end
