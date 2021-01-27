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
#import "ORKTinnitusPredefinedTaskConstants.h"
#import "ORKHelpers_Internal.h"
#import "ORKTinnitusTypes.h"
#import "ORKSkin.h"

#import "ORKCheckmarkView.h"

static const CGFloat ORKTinnitusGlowAdjustment = 16.0;

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

@property (nonatomic, weak)id<ORKTinnitusMaskingSoundButtonViewDelegate> delegate;

- (instancetype)initWithTitle:(NSString *)title value:(NSString *)value;
- (void)setChecked:(NSNumber *)checked;

@end

@implementation ORKTinnitusMaskingSoundButtonView

- (instancetype)initWithTitle:(NSString *)title value:(NSString *)value {
    self = [super init];
    if (self) {
        self.title = title;
        self.value = value;
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
    _titleLabel.font = [UIFont systemFontOfSize:17.0 weight:UIFontWeightRegular];
    if (@available(iOS 13.0, *)) {
        _titleLabel.textColor = [UIColor labelColor];
    } else {
        _titleLabel.textColor = [UIColor blackColor];
    }
    [self addSubview:_titleLabel];
    
    _separatorView = [[UIView alloc] initWithFrame:CGRectZero];
    _separatorView.backgroundColor = [[UIColor systemGrayColor] colorWithAlphaComponent:0.5];
    _separatorView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:_separatorView];
    
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
    
    [_separatorView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:20.0].active = YES;
    [_separatorView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:0.0].active = YES;
    [_separatorView.heightAnchor constraintEqualToConstant:1.0].active = YES;
    [_separatorView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor].active = YES;
    
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
@property (nonatomic, strong) UILabel *questionLabel;
@property (nonatomic, strong) UIView *separatorView;

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
    [self setupScrollView];
    _playButtonView = [[ORKTinnitusButtonView alloc]
                         initWithTitle:self.buttonTitle
                         detail:nil];
    _playButtonView.translatesAutoresizingMaskIntoConstraints = NO;
    self.translatesAutoresizingMaskIntoConstraints = NO;
    [_scrollView addSubview:_playButtonView];
    [_playButtonView.leadingAnchor constraintEqualToAnchor:_scrollView.leadingAnchor constant:ORKTinnitusGlowAdjustment].active = YES;
    [_playButtonView.trailingAnchor constraintEqualToAnchor:_scrollView.trailingAnchor constant:-ORKTinnitusGlowAdjustment].active = YES;
    [_playButtonView.widthAnchor constraintEqualToAnchor:_scrollView.widthAnchor constant:-2*ORKTinnitusGlowAdjustment].active = YES;
    [_playButtonView.topAnchor constraintEqualToAnchor:_scrollView.topAnchor].active = YES;
    
    _questionLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _questionLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _questionLabel.numberOfLines = 0;
    _questionLabel.text = ORKLocalizedString(@"TINNITUS_MASKING_QUESTION", nil);
    _questionLabel.textAlignment = NSTextAlignmentLeft;
    _questionLabel.font = [UIFont systemFontOfSize:17.0 weight:UIFontWeightSemibold];
    if (@available(iOS 13.0, *)) {
        _questionLabel.textColor = [UIColor labelColor];
    } else {
        _questionLabel.textColor = [UIColor blackColor];
    }
    [_scrollView addSubview:_questionLabel];
    [_questionLabel.leadingAnchor constraintEqualToAnchor:_scrollView.leadingAnchor constant:36.0].active = YES;
    [_questionLabel.trailingAnchor constraintEqualToAnchor:_scrollView.trailingAnchor constant:-36.0].active = YES;
    [_questionLabel.topAnchor constraintEqualToAnchor:_playButtonView.bottomAnchor constant:ORKTinnitusGlowAdjustment].active = YES;
    
    _separatorView = [[UIView alloc] initWithFrame:CGRectZero];
    _separatorView.backgroundColor = [[UIColor systemGrayColor] colorWithAlphaComponent:0.5];
    _separatorView.translatesAutoresizingMaskIntoConstraints = NO;
    [_scrollView addSubview:_separatorView];
    [_separatorView.leadingAnchor constraintEqualToAnchor:_scrollView.leadingAnchor constant:ORKTinnitusGlowAdjustment].active = YES;
    [_separatorView.trailingAnchor constraintEqualToAnchor:_scrollView.trailingAnchor constant:-ORKTinnitusGlowAdjustment].active = YES;
    [_separatorView.heightAnchor constraintEqualToConstant:1.0].active = YES;
    [_separatorView.topAnchor constraintEqualToAnchor:_questionLabel.bottomAnchor constant:ORKTinnitusGlowAdjustment].active = YES;
    
    _buttons = [[NSMutableArray alloc] init];
    
    ORKTinnitusMaskingSoundButtonView *btn = [self addButtonForTitle:ORKLocalizedString(@"TINNITUS_MASKING_ANSWER_DEFINITELY", nil)
                                                               value:ORKTinnitusMaskingAnswerDefinitely
                                                             topView:_separatorView];
    
    btn = [self addButtonForTitle:ORKLocalizedString(@"TINNITUS_MASKING_ANSWER_PROBABLY", nil)
                            value:ORKTinnitusMaskingAnswerProbably
                          topView:btn];
    btn = [self addButtonForTitle:ORKLocalizedString(@"TINNITUS_MASKING_ANSWER_POSSIBLY", nil)
                            value:ORKTinnitusMaskingAnswerPossibly
                          topView:btn];
    btn = [self addButtonForTitle:ORKLocalizedString(@"TINNITUS_MASKING_ANSWER_PROBABLYNOT", nil)
                            value:ORKTinnitusMaskingAnswerProbablyNot
                          topView:btn];
    btn = [self addButtonForTitle:ORKLocalizedString(@"TINNITUS_MASKING_ANSWER_DEFINITELYNOT", nil)
                            value:ORKTinnitusMaskingAnswerDefinitelyNot
                          topView:btn];
    
    btn = [self addButtonForTitle:ORKLocalizedString(@"TINNITUS_MASKING_ANSWER_NOTA", nil)
                      value:ORKTinnitusMaskingAnswerNoneOfTheAbove
                    topView:btn];
    [btn.bottomAnchor constraintEqualToAnchor:_scrollView.bottomAnchor].active = YES;
}

- (ORKTinnitusMaskingSoundButtonView *)addButtonForTitle:(NSString *)title value:(NSString *)value topView:(UIView *)topView {
    ORKTinnitusMaskingSoundButtonView *button = [[ORKTinnitusMaskingSoundButtonView alloc] initWithTitle:title value:value];
    button.translatesAutoresizingMaskIntoConstraints = NO;
    [_buttons addObject:button];
    [_scrollView addSubview:button];
    button.delegate = self;
    [button.leadingAnchor constraintEqualToAnchor:_scrollView.leadingAnchor constant:ORKTinnitusGlowAdjustment].active = YES;
    [button.trailingAnchor constraintEqualToAnchor:_scrollView.trailingAnchor constant:-ORKTinnitusGlowAdjustment].active = YES;
    [button.topAnchor constraintEqualToAnchor:topView.bottomAnchor].active = YES;
    
    button.alpha = 0.5;
    
    return button;
}

- (void)setupScrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectZero];
    }
    [self addSubview:_scrollView];
    _scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    [[_scrollView.topAnchor constraintEqualToAnchor:self.topAnchor] setActive:YES];
    [[_scrollView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:-ORKTinnitusGlowAdjustment] setActive:YES];
    [[_scrollView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:ORKTinnitusGlowAdjustment] setActive:YES];
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

- (void)enableButtons {
    [_buttons makeObjectsPerformSelector:@selector(setAlphaWithNSNumber:) withObject:@1.0];
}

- (void)pressed:(ORKTinnitusMaskingSoundButtonView *)matchingButtonView {
    if (_playButtonView.playedOnce) {
        [_buttons makeObjectsPerformSelector:@selector(setChecked:) withObject:@NO];
        [matchingButtonView setChecked:@YES];
        if (_delegate && [_delegate respondsToSelector:@selector(buttonCheckedWithValue:)]) {
            [_delegate buttonCheckedWithValue:matchingButtonView.value];
        }
    }
}

@end

