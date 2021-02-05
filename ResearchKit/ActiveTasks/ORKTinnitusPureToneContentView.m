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

#import "ORKTinnitusPureToneContentView.h"
#import "ORKHelpers_Internal.h"
#import "ORKSkin.h"
#import "ORKTinnitusButtonView.h"

static const CGFloat ORKTinnitusStandardSpacing = 12.0;
static const CGFloat ORKTinnitusGlowAdjustment = 16.0;
static const CGFloat ORKTinnitusButtonTopAdjustment = 8.0;

@interface ORKTinnitusPureToneContentView () <ORKTinnitusButtonViewDelegate> {
    NSLayoutConstraint *_firstATopConstraint;
    NSLayoutConstraint *_firstBTopConstraint;
    NSLayoutConstraint *_secondATopConstraint;
    NSLayoutConstraint *_secondBTopConstraint;
    NSLayoutConstraint *_thirdATopConstraint;
    NSLayoutConstraint *_thirdBTopConstraint;
    NSLayoutConstraint *_cTopConstraint;
    NSLayoutConstraint *_fineTuneTopConstraint;
    
    UILabel *_hintLabel;
    
    BOOL _constraintsDefined;
    
    NSArray *_buttonViewsArray;
    
    PureToneButtonsStage _buttonsStage;
    
    UIScrollView *_scrollView;
}

@property (nonatomic, strong, readonly) ORKTinnitusButtonView *firstAButtonView;
@property (nonatomic, strong, readonly) ORKTinnitusButtonView *firstBButtonView;
@property (nonatomic, strong, readonly) ORKTinnitusButtonView *cButtonView;
@property (nonatomic, strong, readonly) ORKTinnitusButtonView *secondAButtonView;
@property (nonatomic, strong, readonly) ORKTinnitusButtonView *secondBButtonView;
@property (nonatomic, strong, readonly) ORKTinnitusButtonView *thirdAButtonView;
@property (nonatomic, strong, readonly) ORKTinnitusButtonView *thirdBButtonView;
@property (nonatomic, strong, readonly) UIButton *fineTuneButton;

@end


@implementation ORKTinnitusPureToneContentView

- (instancetype)init {
    self = [super init];
    if (self) {
        [self commonInit];
    }
    
    return self;
}

- (void)commonInit
{
    [self setupScrollView];
    _constraintsDefined = NO;
    _buttonsStage = PureToneButtonsStageOne;
    
    _fineTuneButton = [[UIButton alloc] init];
    [_fineTuneButton setTitle:ORKLocalizedString(@"TINNITUS_BUTTON_FINE_TUNING_TITLE", nil)
                     forState:UIControlStateNormal];
    _fineTuneButton.translatesAutoresizingMaskIntoConstraints = NO;
    [_fineTuneButton setTitleColor:[UIColor systemBlueColor] forState:UIControlStateNormal];
    _fineTuneButton.alpha = 0.5;
    _fineTuneButton.userInteractionEnabled = NO;
    _fineTuneButton.accessibilityTraits = UIAccessibilityTraitButton | UIAccessibilityTraitStartsMediaSession;
    _fineTuneButton.accessibilityHint = ORKLocalizedString(@"TINNITUS_BUTTON_FINE_TUNING_TITLE", nil);
    
    _hintLabel = [UILabel new];
    _hintLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _hintLabel.text = ORKLocalizedString(@"TINNITUS_FINETUNE_TEXT", nil);
    _hintLabel.textAlignment = NSTextAlignmentCenter;
    _hintLabel.textColor = UIColor.systemGrayColor;
    _hintLabel.numberOfLines = 0;
    _hintLabel.font = [self bodyTextFont];
    [_scrollView addSubview:_hintLabel];
    
    _firstAButtonView = [[ORKTinnitusButtonView alloc]
                         initWithTitle:ORKLocalizedString(@"TINNITUS_BUTTON_A_TITLE", nil)
                         detail:ORKLocalizedString(@"TINNITUS_BUTTON_A_DETAIL", nil)];
    _firstAButtonView.translatesAutoresizingMaskIntoConstraints = NO;
    [self setDidFinishLayoutBlockFor:_firstAButtonView];
    
    _secondAButtonView = [[ORKTinnitusButtonView alloc]
                          initWithTitle:ORKLocalizedString(@"TINNITUS_BUTTON_UPPERPITCH_TITLE", nil)
                          detail:nil];
    _secondAButtonView.translatesAutoresizingMaskIntoConstraints = NO;
    _secondAButtonView.alpha = 0.0;
    [self setDidFinishLayoutBlockFor:_secondAButtonView];
    
    _thirdAButtonView = [[ORKTinnitusButtonView alloc]
                         initWithTitle:ORKLocalizedString(@"TINNITUS_BUTTON_UPPERPITCH_TITLE", nil)
                         detail:nil];
    _thirdAButtonView.translatesAutoresizingMaskIntoConstraints = NO;
    _thirdAButtonView.alpha = 0.0;
    [self setDidFinishLayoutBlockFor:_thirdAButtonView];
    
    _firstBButtonView = [[ORKTinnitusButtonView alloc]
                         initWithTitle:ORKLocalizedString(@"TINNITUS_BUTTON_B_TITLE", nil)
                         detail:ORKLocalizedString(@"TINNITUS_BUTTON_B_DETAIL", nil)];
    _firstBButtonView.translatesAutoresizingMaskIntoConstraints = NO;
    [self setDidFinishLayoutBlockFor:_firstBButtonView];
    
    _secondBButtonView = [[ORKTinnitusButtonView alloc]
                          initWithTitle:ORKLocalizedString(@"TINNITUS_BUTTON_LOWERPITCH_TITLE", nil)
                          detail:nil];
    _secondBButtonView.translatesAutoresizingMaskIntoConstraints = NO;
    _secondBButtonView.alpha = 0.0;
    [self setDidFinishLayoutBlockFor:_secondBButtonView];
    
    _thirdBButtonView = [[ORKTinnitusButtonView alloc]
                         initWithTitle:ORKLocalizedString(@"TINNITUS_BUTTON_LOWERPITCH_TITLE", nil)
                         detail:nil];
    _thirdBButtonView.translatesAutoresizingMaskIntoConstraints = NO;
    _thirdBButtonView.alpha = 0.0;
    [self setDidFinishLayoutBlockFor:_thirdBButtonView];
    
    _cButtonView = [[ORKTinnitusButtonView alloc]
                    initWithTitle:ORKLocalizedString(@"TINNITUS_BUTTON_C_TITLE", nil)
                    detail:ORKLocalizedString(@"TINNITUS_BUTTON_C_DETAIL", nil)];
    _cButtonView.translatesAutoresizingMaskIntoConstraints = NO;
    [self setDidFinishLayoutBlockFor:_cButtonView];
    
    [_scrollView addSubview:_fineTuneButton];
    [_scrollView addSubview:_firstAButtonView];
    [_scrollView addSubview:_firstBButtonView];
    [_scrollView addSubview:_cButtonView];
    
    [_scrollView addSubview:_secondAButtonView];
    _secondAButtonView.alpha = 0.0;
    _secondAButtonView.hidden = YES;
    [_scrollView addSubview:_secondBButtonView];
    _secondBButtonView.alpha = 0.0;
    _secondBButtonView.hidden = YES;
    [_scrollView addSubview:_thirdAButtonView];
    _thirdAButtonView.alpha = 0.0;
    _thirdAButtonView.hidden = YES;
    [_scrollView addSubview:_thirdBButtonView];
    _thirdBButtonView.alpha = 0.0;
    _thirdBButtonView.hidden = YES;
    
    _buttonViewsArray = @[_firstAButtonView, _firstBButtonView, _cButtonView, _secondAButtonView, _secondBButtonView, _thirdAButtonView, _thirdBButtonView];
    
    self.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self setUpConstraints];
    
    _firstAButtonView.delegate = self;
    _firstBButtonView.delegate = self;
    _cButtonView.delegate = self;
    _secondAButtonView.delegate = self;
    _secondBButtonView.delegate = self;
    _thirdAButtonView.delegate = self;
    _thirdBButtonView.delegate = self;
    
    [_fineTuneButton addTarget:self action:@selector(fineTunePressed:forEvent:) forControlEvents:UIControlEventTouchDown];
}

- (UIFont *)bodyTextFont {
    UIFontDescriptor *descriptor = [UIFontDescriptor preferredFontDescriptorWithTextStyle:UIFontTextStyleBody];
    return [UIFont fontWithDescriptor:descriptor size:[[descriptor objectForKey: UIFontDescriptorSizeAttribute] doubleValue] ];
}

- (void)setDidFinishLayoutBlockFor:(ORKTinnitusButtonView *)button {
    ORKWeakTypeOf(self) weakSelf = self;
    button.didFinishLayoutBlock = ^{
        ORKStrongTypeOf(weakSelf) strongSelf = weakSelf;
        [strongSelf updateConstraintsConstants];
    };
}

- (void)setupScrollView {
    if (!_scrollView) {
        _scrollView = [UIScrollView new];
    }
    [self addSubview:_scrollView];
    _scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    [[_scrollView.topAnchor constraintEqualToAnchor:self.topAnchor constant:-ORKTinnitusGlowAdjustment/2] setActive:YES];
    [[_scrollView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:-ORKTinnitusGlowAdjustment] setActive:YES];
    [[_scrollView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:ORKTinnitusGlowAdjustment] setActive:YES];
    [[_scrollView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor] setActive:YES];
    
    _scrollView.scrollEnabled = YES;
}

- (PureToneButtonsStage)currentStage
{
    return _buttonsStage;
}

- (UIFont *)textFontBold {
    UIFontDescriptor *descriptor = [UIFontDescriptor preferredFontDescriptorWithTextStyle:UIFontTextStyleSubheadline];
    UIFontDescriptor *fontDescriptor = [descriptor fontDescriptorWithSymbolicTraits:(UIFontDescriptorTraitBold | UIFontDescriptorTraitLooseLeading)];
    return [UIFont fontWithDescriptor:fontDescriptor size:[[fontDescriptor objectForKey: UIFontDescriptorSizeAttribute] doubleValue]];
}

- (ORKTinnitusSelectedPureTonePosition)currentSelectedPosition
{
    if (_firstAButtonView.isSelected) {
        return ORKTinnitusSelectedPureTonePositionA;
    } else if (_firstBButtonView.isSelected) {
        return ORKTinnitusSelectedPureTonePositionB;
    } else if (_cButtonView.isSelected) {
        return ORKTinnitusSelectedPureTonePositionC;
    } else if (_secondBButtonView.isSelected || _thirdBButtonView.isSelected) {
        return ORKTinnitusSelectedPureTonePositionA;
    } else if (_secondAButtonView.isSelected || _thirdAButtonView.isSelected) {
        return ORKTinnitusSelectedPureTonePositionB;
    }
    return ORKTinnitusSelectedPureTonePositionNone;
}

- (nullable ORKTinnitusButtonView *)currentSelectedButtonView
{
    NSArray *selectedButtonsArray = [_buttonViewsArray
                                     filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id object, NSDictionary *bindings) {
        ORKTinnitusButtonView *buttonView = (ORKTinnitusButtonView *)object;
        return buttonView.isSelected;
    }]];
    
    return [selectedButtonsArray firstObject];
}

- (void)selectButton:(ORKTinnitusButtonView *)buttonView
{
    NSArray *unselectArray = [_buttonViewsArray
                              filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id object, NSDictionary *bindings) {
        return (object != buttonView);
    }]];
    [unselectArray makeObjectsPerformSelector:@selector(restoreButton)];
}

- (void)enablePlayButtons:(BOOL)enabled
{
    [_buttonViewsArray makeObjectsPerformSelector:@selector(setEnabled:) withObject:[NSNumber numberWithBool:enabled]];
}

- (void)enableFineTuneButton:(BOOL)enable
{
    _fineTuneButton.userInteractionEnabled = enable;
    _fineTuneButton.alpha = enable ? 1.0 : 0.5;
}

- (void)animateButtonsSetting:(BOOL)isLastStep
{
    if (_buttonsStage == PureToneButtonsStageOne) {
        CGFloat firstAHeight = _firstAButtonView.bounds.size.height;
        CGFloat firstBHeight = _firstBButtonView.bounds.size.height;
        [_scrollView setNeedsUpdateConstraints];
        
        // hide animations
        _firstATopConstraint.constant = -firstAHeight;
        [UIView animateWithDuration:0.25 delay:0.0 options:(UIViewAnimationOptionCurveEaseIn | UIViewAnimationOptionAllowUserInteraction) animations:^{
            _firstAButtonView.alpha = 0.0;
            [_scrollView layoutIfNeeded];
        } completion:^(BOOL finished) {
            _firstAButtonView.hidden = YES;
        }];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.05 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            _firstBTopConstraint.constant = 0;
            [_scrollView setNeedsUpdateConstraints];
            [UIView animateWithDuration:0.20 delay:0.0 options:(UIViewAnimationOptionCurveEaseOut | UIViewAnimationOptionAllowUserInteraction) animations:^{
                _firstBButtonView.alpha = 0.0;
                _hintLabel.alpha = 0.0;
                [_scrollView layoutIfNeeded];
            } completion:^(BOOL finished) {
                _firstBButtonView.hidden = YES;
            }];
        });
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            _cTopConstraint.constant = firstBHeight + ORKTinnitusStandardSpacing;
            [_scrollView setNeedsUpdateConstraints];
            [UIView animateWithDuration:0.15 delay:0.0 options:(UIViewAnimationOptionCurveEaseOut | UIViewAnimationOptionAllowUserInteraction) animations:^{
                _cButtonView.alpha = 0.0;
                [_scrollView layoutIfNeeded];
            } completion:^(BOOL finished) {
                _cButtonView.hidden = finished;
            }];
        });
        
        // show animations
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            _secondATopConstraint.constant = ORKTinnitusStandardSpacing/2;
            _secondAButtonView.hidden = NO;
            NSLayoutConstraint *newFineTuneConstraint = [_fineTuneButton.topAnchor constraintEqualToAnchor:_secondBButtonView.bottomAnchor constant:ORKTinnitusStandardSpacing];
            [_scrollView setNeedsUpdateConstraints];
            [UIView animateWithDuration:0.2 delay:0.0 options:(UIViewAnimationOptionCurveEaseOut | UIViewAnimationOptionAllowUserInteraction) animations:^{
                _secondAButtonView.alpha = 1.0;
                [_scrollView removeConstraint:_fineTuneTopConstraint];
                [_scrollView addConstraint:newFineTuneConstraint];
                _fineTuneTopConstraint = newFineTuneConstraint;
                [_fineTuneButton setTitle:ORKLocalizedString(@"TINNITUS_BUTTON_CONTINUE_FINE_TUNING_TITLE", nil) forState:UIControlStateNormal];
                [_scrollView layoutIfNeeded];
            } completion:nil];
        });
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.15 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            _secondBTopConstraint.constant = _secondAButtonView.bounds.size.height + ORKTinnitusStandardSpacing + ORKTinnitusStandardSpacing/2;
            _secondBButtonView.hidden = NO;
            [_scrollView setNeedsUpdateConstraints];
            [UIView animateWithDuration:0.15 delay:0.0 options:(UIViewAnimationOptionCurveEaseOut | UIViewAnimationOptionAllowUserInteraction) animations:^{
                _secondBButtonView.alpha = 1.0;
                [_scrollView layoutIfNeeded];
            } completion:^(BOOL finished) {
                _buttonsStage = PureToneButtonsStageTwo;
                CGFloat newContentSizeHeight = _secondAButtonView.bounds.size.height + _secondBButtonView.bounds.size.height + 2 * ORKTinnitusStandardSpacing + ORKTinnitusStandardSpacing/2 + _fineTuneButton.frame.size.height + ORKTinnitusStandardSpacing;
                _scrollView.contentSize = CGSizeMake(self.frame.size.width, newContentSizeHeight);
                [_scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
            }];
        });
    } else {
        BOOL isStageTwo = (_buttonsStage == PureToneButtonsStageTwo);
        NSLayoutConstraint *showedATopConstraint = isStageTwo ? _secondATopConstraint : _thirdATopConstraint;
        ORKTinnitusButtonView *showedAButtonView = isStageTwo ? _secondAButtonView    : _thirdAButtonView;
        NSLayoutConstraint *showedBTopConstraint = isStageTwo ? _secondBTopConstraint : _thirdBTopConstraint;
        ORKTinnitusButtonView *showedBButtonView = isStageTwo ? _secondBButtonView    : _thirdBButtonView;
        
        NSLayoutConstraint *hiddenATopConstraint = isStageTwo ? _thirdATopConstraint  : _secondATopConstraint;
        ORKTinnitusButtonView *hiddenAButtonView = isStageTwo ? _thirdAButtonView     : _secondAButtonView;
        NSLayoutConstraint *hiddenBTopConstraint = isStageTwo ? _thirdBTopConstraint  : _secondBTopConstraint;
        ORKTinnitusButtonView *hiddenBButtonView = isStageTwo ? _thirdBButtonView     : _secondBButtonView;
        
        CGFloat aButtonViewHeight = showedAButtonView.bounds.size.height;
        
        [_scrollView setNeedsUpdateConstraints];
        
        // hide animations
        showedATopConstraint.constant = -aButtonViewHeight;
        [UIView animateWithDuration:0.25 delay:0.0 options:(UIViewAnimationOptionCurveEaseIn | UIViewAnimationOptionAllowUserInteraction) animations:^{
            showedAButtonView.alpha = 0.0;
            [_scrollView layoutIfNeeded];
        } completion:^(BOOL finished) {
            showedAButtonView.hidden = YES;
        }];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.05 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            showedBTopConstraint.constant = 0;
            [_scrollView setNeedsUpdateConstraints];
            [UIView animateWithDuration:0.20 delay:0.0 options:(UIViewAnimationOptionCurveEaseOut | UIViewAnimationOptionAllowUserInteraction) animations:^{
                showedBButtonView.alpha = 0.0;
                [_scrollView layoutIfNeeded];
            } completion:^(BOOL finished) {
                showedBButtonView.hidden = YES;
            }];
        });
        
        // show animations
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            hiddenATopConstraint.constant = ORKTinnitusStandardSpacing/2;
            hiddenAButtonView.hidden = NO;
            NSLayoutConstraint *newFineTuneConstraint = [_fineTuneButton.topAnchor constraintEqualToAnchor:hiddenBButtonView.bottomAnchor constant:ORKTinnitusStandardSpacing];
            [_scrollView setNeedsUpdateConstraints];
            [UIView animateWithDuration:0.2 delay:0.0 options:(UIViewAnimationOptionCurveEaseOut | UIViewAnimationOptionAllowUserInteraction) animations:^{
                [_scrollView removeConstraint:_fineTuneTopConstraint];
                [_scrollView addConstraint:newFineTuneConstraint];
                _fineTuneTopConstraint = newFineTuneConstraint;
                NSString *fineTunningTitle = isLastStep ? ORKLocalizedString(@"TINNITUS_BUTTON_FINISH_FINE_TUNING_TITLE", nil) : ORKLocalizedString(@"TINNITUS_BUTTON_CONTINUE_FINE_TUNING_TITLE", nil);
                [_fineTuneButton setTitle:fineTunningTitle forState:UIControlStateNormal];
                hiddenAButtonView.alpha = 1.0;
                [_scrollView layoutIfNeeded];
            } completion:nil];
        });
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.15 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            hiddenBTopConstraint.constant = hiddenBButtonView.bounds.size.height + ORKTinnitusStandardSpacing + ORKTinnitusStandardSpacing/2;
            hiddenBButtonView.hidden = NO;
            [_scrollView setNeedsUpdateConstraints];
            [UIView animateWithDuration:0.15 delay:0.0 options:(UIViewAnimationOptionCurveEaseOut | UIViewAnimationOptionAllowUserInteraction) animations:^{
                hiddenBButtonView.alpha = 1.0;
                [_scrollView layoutIfNeeded];
            } completion:^(BOOL finished) {
                _buttonsStage = (_buttonsStage == PureToneButtonsStageTwo) ? PureToneButtonsStageThree : PureToneButtonsStageTwo;
                // repositioning the buttons after animation
                showedATopConstraint.constant = showedBButtonView.bounds.size.height + ORKTinnitusStandardSpacing + ORKTinnitusStandardSpacing/2;
                showedBTopConstraint.constant = showedAButtonView.bounds.size.height + showedBButtonView.bounds.size.height + ORKTinnitusStandardSpacing/2 + 2 * ORKTinnitusStandardSpacing;
            }];
        });
    }
}

- (BOOL)hasPlayingButton
{
    NSArray *playingButtonsArray = [_buttonViewsArray
                                    filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id object, NSDictionary *bindings) {
        ORKTinnitusButtonView *buttonView = (ORKTinnitusButtonView *)object;
        return buttonView.isShowingPause;
    }]];
    return playingButtonsArray.count > 0;
}

- (BOOL)allCurrentVisibleButtonsPlayed
{
    if (_cButtonView.isHidden) {
        return (_secondAButtonView.playedOnce && _secondBButtonView.playedOnce) || (_thirdAButtonView.playedOnce && _thirdBButtonView.playedOnce);
    } else {
        return _firstAButtonView.playedOnce && _firstBButtonView.playedOnce && _cButtonView.playedOnce;
    }
}

- (void)resetPlayButtons
{
    [_firstAButtonView resetButton];
    [_firstBButtonView resetButton];
    [_cButtonView resetButton];
    [_secondAButtonView resetButton];
    [_secondBButtonView resetButton];
    [_thirdAButtonView resetButton];
    [_thirdBButtonView resetButton];
}

- (void)finishStep:(ORKActiveStepViewController *)viewController {
    [super finishStep:viewController];
}

- (void)updateConstraintsConstants {
    if (_firstAButtonView.buttonFinishedAutoLayout &&
        _firstBButtonView.buttonFinishedAutoLayout &&
        _secondAButtonView.buttonFinishedAutoLayout &&
        _secondBButtonView.buttonFinishedAutoLayout &&
        _thirdAButtonView.buttonFinishedAutoLayout &&
        _thirdBButtonView.buttonFinishedAutoLayout &&
        _cButtonView.buttonFinishedAutoLayout) {
        CGFloat bPosition = _firstAButtonView.bounds.size.height + ORKTinnitusStandardSpacing + ORKTinnitusStandardSpacing/2;
        CGFloat cPosition = bPosition + _firstBButtonView.bounds.size.height + ORKTinnitusStandardSpacing;
        _firstBTopConstraint.constant = bPosition;
        _cTopConstraint.constant = cPosition;
        
        _secondATopConstraint.constant = bPosition;
        _secondBTopConstraint.constant = cPosition;
        
        _thirdATopConstraint.constant = bPosition;
        _thirdBTopConstraint.constant = cPosition;
        
        _scrollView.contentSize = CGSizeMake(self.frame.size.width,
                                             cPosition + _cButtonView.frame.size.height
                                             + _fineTuneButton.frame.size.height + 2 * ORKTinnitusStandardSpacing + _hintLabel.frame.size.height + ORKTinnitusButtonTopAdjustment);
    }
}

- (void)setUpConstraints {
    [_firstAButtonView.leadingAnchor constraintEqualToAnchor:_scrollView.leadingAnchor constant:ORKTinnitusGlowAdjustment].active = YES;
    [_firstAButtonView.widthAnchor constraintEqualToAnchor:_scrollView.widthAnchor constant:-2*ORKTinnitusGlowAdjustment].active = YES;
    _firstATopConstraint = [_firstAButtonView.topAnchor constraintEqualToAnchor:_scrollView.topAnchor constant:ORKTinnitusGlowAdjustment/2];
    _firstATopConstraint.active = YES;
    
    [_firstBButtonView.leadingAnchor constraintEqualToAnchor:_scrollView.leadingAnchor constant:ORKTinnitusGlowAdjustment].active = YES;
    [_firstBButtonView.widthAnchor constraintEqualToAnchor:_scrollView.widthAnchor constant:-2*ORKTinnitusGlowAdjustment].active = YES;
    _firstBTopConstraint = [_firstBButtonView.topAnchor constraintEqualToAnchor:_scrollView.topAnchor];
    _firstBTopConstraint.active = YES;
    
    [_cButtonView.leadingAnchor constraintEqualToAnchor:_scrollView.leadingAnchor constant:ORKTinnitusGlowAdjustment].active = YES;
    [_cButtonView.widthAnchor constraintEqualToAnchor:_scrollView.widthAnchor constant:-2*ORKTinnitusGlowAdjustment].active = YES;
    _cTopConstraint = [_cButtonView.topAnchor constraintEqualToAnchor:_scrollView.topAnchor];
    _cTopConstraint.active = YES;
    
    [_fineTuneButton.centerXAnchor constraintEqualToAnchor:_scrollView.centerXAnchor].active = YES;
    _fineTuneTopConstraint = [_fineTuneButton.topAnchor constraintEqualToAnchor:_cButtonView.bottomAnchor constant:ORKTinnitusStandardSpacing + ORKTinnitusButtonTopAdjustment];
    _fineTuneTopConstraint.active = YES;
    
    [_hintLabel.centerXAnchor constraintEqualToAnchor:_scrollView.centerXAnchor].active = YES;
    [_hintLabel.topAnchor constraintEqualToAnchor:_fineTuneButton.bottomAnchor constant:ORKTinnitusStandardSpacing].active = YES;
    [_hintLabel.widthAnchor constraintEqualToAnchor:_scrollView.widthAnchor constant:-3*ORKTinnitusGlowAdjustment].active = YES;

    [_secondAButtonView.leadingAnchor constraintEqualToAnchor:_scrollView.leadingAnchor constant:ORKTinnitusGlowAdjustment].active = YES;
    [_secondAButtonView.widthAnchor constraintEqualToAnchor:_scrollView.widthAnchor constant:-2*ORKTinnitusGlowAdjustment].active = YES;

    _secondATopConstraint = [_secondAButtonView.topAnchor constraintEqualToAnchor:_scrollView.topAnchor];
    _secondATopConstraint.active = YES;
    
    [_secondBButtonView.leadingAnchor constraintEqualToAnchor:_scrollView.leadingAnchor constant:ORKTinnitusGlowAdjustment].active = YES;
    [_secondBButtonView.widthAnchor constraintEqualToAnchor:_scrollView.widthAnchor constant:-2*ORKTinnitusGlowAdjustment].active = YES;

    _secondBTopConstraint = [_secondBButtonView.topAnchor constraintEqualToAnchor:_scrollView.topAnchor];
    _secondBTopConstraint.active = YES;
    
    [_thirdAButtonView.leadingAnchor constraintEqualToAnchor:_scrollView.leadingAnchor constant:ORKTinnitusGlowAdjustment].active = YES;
    [_thirdAButtonView.widthAnchor constraintEqualToAnchor:_scrollView.widthAnchor constant:-2*ORKTinnitusGlowAdjustment].active = YES;

    _thirdATopConstraint = [_thirdAButtonView.topAnchor constraintEqualToAnchor:_scrollView.topAnchor];
    _thirdATopConstraint.active = YES;
    
    [_thirdBButtonView.leadingAnchor constraintEqualToAnchor:_scrollView.leadingAnchor constant:ORKTinnitusGlowAdjustment].active = YES;
    [_thirdBButtonView.widthAnchor constraintEqualToAnchor:_scrollView.widthAnchor constant:-2*ORKTinnitusGlowAdjustment].active = YES;

    _thirdBTopConstraint = [_thirdBButtonView.topAnchor constraintEqualToAnchor:_scrollView.topAnchor];
    _thirdBTopConstraint.active = YES;
    
}

- (void)toggleCurrentSelectPlayButton
{
    [[self currentSelectedButtonView] togglePlayButton];
}

- (BOOL)thirdButtonIsHidden
{
    return _cButtonView.isHidden;
}

- (ORKTinnitusSelectedPureTonePosition)positionForButton:(ORKTinnitusButtonView *)buttonView
{
    if (buttonView == _firstAButtonView || buttonView == _secondAButtonView || buttonView == _thirdAButtonView) {
        return ORKTinnitusSelectedPureTonePositionA;
    } else if (buttonView == _firstBButtonView || buttonView == _secondBButtonView || buttonView == _thirdBButtonView) {
        return ORKTinnitusSelectedPureTonePositionB;
    } else if (buttonView == _cButtonView) {
        return ORKTinnitusSelectedPureTonePositionC;
    }
    return ORKTinnitusSelectedPureTonePositionNone;
}

- (void)fineTunePressed:(id)button forEvent:(UIEvent *)event
{
    if (_delegate && [_delegate respondsToSelector:@selector(fineTunePressed)]) {
        [_delegate fineTunePressed];
    }
}

- (void)tinnitusButtonViewPressed:(nonnull ORKTinnitusButtonView *)tinnitusButtonView {
    [self selectButton:tinnitusButtonView];
    if (_delegate && [_delegate respondsToSelector:@selector(playButtonPressedWithNewPosition:)]) {
        [_delegate playButtonPressedWithNewPosition:[self currentSelectedPosition]];
    }
}

@end
