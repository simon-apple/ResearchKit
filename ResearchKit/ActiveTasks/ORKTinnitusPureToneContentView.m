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
    NSLayoutConstraint *_firstALeadingConstraint;
    NSLayoutConstraint *_firstBLeadingConstraint;
    NSLayoutConstraint *_secondALeadingConstraint;
    NSLayoutConstraint *_secondBLeadingConstraint;
    NSLayoutConstraint *_thirdALeadingConstraint;
    NSLayoutConstraint *_thirdBLeadingConstraint;
    NSLayoutConstraint *_cLeadingConstraint;
    
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

- (void)enableButtons:(BOOL)enabled
{
    [_buttonViewsArray makeObjectsPerformSelector:@selector(setEnabled:) withObject:[NSNumber numberWithBool:enabled]];
}

- (void)enableButtonsAnnouncements:(BOOL)enable {
    [_secondAButtonView enableAccessibilityAnnouncements:enable];
    [_thirdAButtonView enableAccessibilityAnnouncements:enable];
}

- (void)animateButtons {
    [self enableButtonsAnnouncements:NO];
    if (_buttonsStage == PureToneButtonsStageOne) {
        CGFloat firstAWidth = _firstAButtonView.bounds.size.width;
        [_scrollView setNeedsUpdateConstraints];
        
        _secondAButtonView.hidden = NO;
        _secondBButtonView.hidden = NO;
        
        [UIView animateWithDuration:0.8
                              delay:0.0
             usingSpringWithDamping:50.0
              initialSpringVelocity:0.0
                            options:UIViewAnimationOptionCurveEaseIn|UIViewAnimationOptionAllowUserInteraction
                         animations:^{
            _firstALeadingConstraint.constant = -firstAWidth;
            _firstBLeadingConstraint.constant = -firstAWidth;
            _cLeadingConstraint.constant = -firstAWidth;
            _secondALeadingConstraint.constant = ORKTinnitusGlowAdjustment;
            _secondBLeadingConstraint.constant = ORKTinnitusGlowAdjustment;
            _secondAButtonView.alpha = 1.0;
            _secondBButtonView.alpha = 1.0;
            
            [_scrollView layoutIfNeeded];
        } completion:^(BOOL finished) {
            _cButtonView.hidden = YES;
            _firstAButtonView.hidden = YES;
            _firstBButtonView.hidden = YES;
            if (_delegate && [_delegate respondsToSelector:@selector(animationFinishedForStage:)]) {
                [_delegate animationFinishedForStage:_buttonsStage];
            }
            _buttonsStage = PureToneButtonsStageTwo;
            CGFloat newContentSizeHeight = _secondAButtonView.bounds.size.height + _secondBButtonView.bounds.size.height + 2 * ORKTinnitusStandardSpacing + ORKTinnitusStandardSpacing/2 + ORKTinnitusStandardSpacing;
            _scrollView.contentSize = CGSizeMake(self.frame.size.width, newContentSizeHeight);
            [_scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
        }];
    } else {
        BOOL isStageTwo = (_buttonsStage == PureToneButtonsStageTwo);
        NSLayoutConstraint *showedALeadingConstraint = isStageTwo ? _secondALeadingConstraint : _thirdALeadingConstraint;
        ORKTinnitusButtonView *showedAButtonView = isStageTwo ? _secondAButtonView    : _thirdAButtonView;
        NSLayoutConstraint *showedBLeadingConstraint = isStageTwo ? _secondBLeadingConstraint : _thirdBLeadingConstraint;
        ORKTinnitusButtonView *showedBButtonView = isStageTwo ? _secondBButtonView    : _thirdBButtonView;

        NSLayoutConstraint *hiddenALeadingConstraint = isStageTwo ? _thirdALeadingConstraint  : _secondALeadingConstraint;
        ORKTinnitusButtonView *hiddenAButtonView = isStageTwo ? _thirdAButtonView     : _secondAButtonView;
        NSLayoutConstraint *hiddenBLeadingConstraint = isStageTwo ? _thirdBLeadingConstraint  : _secondBLeadingConstraint;
        ORKTinnitusButtonView *hiddenBButtonView = isStageTwo ? _thirdBButtonView     : _secondBButtonView;

        CGFloat aButtonViewWidth = showedAButtonView.bounds.size.width;
        
        hiddenAButtonView.hidden = NO;
        hiddenBButtonView.hidden = NO;

        [_scrollView setNeedsUpdateConstraints];
        
        [UIView animateWithDuration:0.8
                              delay:0.0
             usingSpringWithDamping:50.0
              initialSpringVelocity:0.0
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
            showedALeadingConstraint.constant = -aButtonViewWidth;
            showedAButtonView.alpha = 0.0;
            showedBLeadingConstraint.constant = -aButtonViewWidth;
            showedBButtonView.alpha = 0.0;
            hiddenALeadingConstraint.constant = ORKTinnitusGlowAdjustment;
            hiddenBLeadingConstraint.constant = ORKTinnitusGlowAdjustment;
            hiddenAButtonView.alpha = 1.0;
            hiddenBButtonView.alpha = 1.0;
            
            [_scrollView layoutIfNeeded];
        } completion:^(BOOL finished) {
            showedAButtonView.hidden = YES;
            showedBButtonView.hidden = YES;
            if (_delegate && [_delegate respondsToSelector:@selector(animationFinishedForStage:)]) {
                [_delegate animationFinishedForStage:_buttonsStage];
            }
            _buttonsStage = (_buttonsStage == PureToneButtonsStageTwo) ? PureToneButtonsStageThree : PureToneButtonsStageTwo;
            // repositioning the buttons after animation
            showedALeadingConstraint.constant = aButtonViewWidth + 2 * ORKTinnitusGlowAdjustment;
            showedBLeadingConstraint.constant = aButtonViewWidth + 2 * ORKTinnitusGlowAdjustment;
        }];
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

- (BOOL)atLeastOneButtonIsSelected {
    switch (_buttonsStage) {
        case PureToneButtonsStageOne:
            return _firstAButtonView.isSelected || _firstBButtonView.isSelected || _cButtonView.isSelected;
            break;
        case PureToneButtonsStageTwo:
            return _secondAButtonView.isSelected || _secondBButtonView.isSelected;
            break;
        case PureToneButtonsStageThree:
            return _thirdAButtonView.isSelected || _thirdBButtonView.isSelected;
            break;
        default:
            break;
    }
    return NO;
}

- (BOOL)isPlayingLastButton {
    BOOL isPlayingLastButton = NO;
    switch (_buttonsStage) {
        case PureToneButtonsStageOne:
            isPlayingLastButton = _cButtonView.isSelected;
            break;
        case PureToneButtonsStageTwo:
            isPlayingLastButton = _secondBButtonView.isSelected;
            break;
        case PureToneButtonsStageThree:
            isPlayingLastButton = _thirdBButtonView.isSelected;
            break;
        default:
            break;
    }
    return isPlayingLastButton;
}

- (void)restoreButtons {
    [_firstAButtonView restoreButton];
    [_firstBButtonView restoreButton];
    [_cButtonView restoreButton];
    [_secondAButtonView restoreButton];
    [_secondBButtonView restoreButton];
    [_thirdAButtonView restoreButton];
    [_thirdBButtonView restoreButton];
}

- (void)resetButtons
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
        _secondALeadingConstraint.constant = _firstAButtonView.bounds.size.width + 2 * ORKTinnitusGlowAdjustment;
        _secondBLeadingConstraint.constant = _firstBButtonView.bounds.size.width + 2 * ORKTinnitusGlowAdjustment;
        _thirdALeadingConstraint.constant = _firstAButtonView.bounds.size.width + 2 * ORKTinnitusGlowAdjustment;
        _thirdBLeadingConstraint.constant = _firstBButtonView.bounds.size.width + 2 * ORKTinnitusGlowAdjustment;
        
        _scrollView.contentSize = CGSizeMake(self.frame.size.width,
                                             cPosition + _cButtonView.frame.size.height
                                             + 2 * ORKTinnitusStandardSpacing + ORKTinnitusButtonTopAdjustment);
    }
}

- (void)setUpConstraints {
    _firstALeadingConstraint = [_firstAButtonView.leadingAnchor constraintEqualToAnchor:_scrollView.leadingAnchor constant:ORKTinnitusGlowAdjustment];
    _firstALeadingConstraint.active = YES;
    [_firstAButtonView.widthAnchor constraintEqualToAnchor:_scrollView.widthAnchor constant:-2*ORKTinnitusGlowAdjustment].active = YES;
    [_firstAButtonView.topAnchor constraintEqualToAnchor:_scrollView.topAnchor constant:ORKTinnitusGlowAdjustment/2].active = YES;
    
    _firstBLeadingConstraint = [_firstBButtonView.leadingAnchor constraintEqualToAnchor:_scrollView.leadingAnchor constant:ORKTinnitusGlowAdjustment];
    _firstBLeadingConstraint.active = YES;
    [_firstBButtonView.widthAnchor constraintEqualToAnchor:_scrollView.widthAnchor constant:-2*ORKTinnitusGlowAdjustment].active = YES;
    [_firstBButtonView.topAnchor constraintEqualToAnchor:_firstAButtonView.bottomAnchor constant:ORKTinnitusStandardSpacing].active = YES;
    
    _cLeadingConstraint = [_cButtonView.leadingAnchor constraintEqualToAnchor:_scrollView.leadingAnchor constant:ORKTinnitusGlowAdjustment];
    _cLeadingConstraint.active = YES;
    [_cButtonView.widthAnchor constraintEqualToAnchor:_scrollView.widthAnchor constant:-2*ORKTinnitusGlowAdjustment].active = YES;
    [_cButtonView.topAnchor constraintEqualToAnchor:_firstBButtonView.bottomAnchor constant:ORKTinnitusStandardSpacing].active = YES;

    _secondALeadingConstraint = [_secondAButtonView.leadingAnchor constraintEqualToAnchor:_scrollView.leadingAnchor constant:ORKTinnitusGlowAdjustment];
    _secondALeadingConstraint.active = YES;
    [_secondAButtonView.widthAnchor constraintEqualToAnchor:_scrollView.widthAnchor constant:-2*ORKTinnitusGlowAdjustment].active = YES;
    [_secondAButtonView.topAnchor constraintEqualToAnchor:_scrollView.topAnchor constant:ORKTinnitusGlowAdjustment/2].active = YES;
    
    _secondBLeadingConstraint = [_secondBButtonView.leadingAnchor constraintEqualToAnchor:_scrollView.leadingAnchor constant:ORKTinnitusGlowAdjustment];
    _secondBLeadingConstraint.active = YES;
    [_secondBButtonView.widthAnchor constraintEqualToAnchor:_scrollView.widthAnchor constant:-2*ORKTinnitusGlowAdjustment].active = YES;
    [_secondBButtonView.topAnchor constraintEqualToAnchor:_secondAButtonView.bottomAnchor constant:ORKTinnitusStandardSpacing].active = YES;
    
    _thirdALeadingConstraint = [_thirdAButtonView.leadingAnchor constraintEqualToAnchor:_scrollView.leadingAnchor constant:ORKTinnitusGlowAdjustment];
    _thirdALeadingConstraint.active = YES;
    [_thirdAButtonView.widthAnchor constraintEqualToAnchor:_scrollView.widthAnchor constant:-2*ORKTinnitusGlowAdjustment].active = YES;
    [_thirdAButtonView.topAnchor constraintEqualToAnchor:_scrollView.topAnchor constant:ORKTinnitusGlowAdjustment/2].active = YES;
    
    _thirdBLeadingConstraint = [_thirdBButtonView.leadingAnchor constraintEqualToAnchor:_scrollView.leadingAnchor constant:ORKTinnitusGlowAdjustment];
    _thirdBLeadingConstraint.active = YES;
    [_thirdBButtonView.widthAnchor constraintEqualToAnchor:_scrollView.widthAnchor constant:-2*ORKTinnitusGlowAdjustment].active = YES;
    [_thirdBButtonView.topAnchor constraintEqualToAnchor:_thirdAButtonView.bottomAnchor constant:ORKTinnitusStandardSpacing].active = YES;
    
}

- (void)toggleCurrentSelectPlayButton
{
    [[self currentSelectedButtonView] togglePlayButton];
}

- (BOOL)thirdButtonIsHidden
{
    return _cButtonView.isHidden;
}

- (void)simulateTapForPosition:(ORKTinnitusSelectedPureTonePosition)position {
    switch (_buttonsStage) {
        case PureToneButtonsStageOne:
            switch (position) {
                case ORKTinnitusSelectedPureTonePositionA:
                    [_firstAButtonView simulateTap];
                    break;
                case ORKTinnitusSelectedPureTonePositionB:
                    [_firstBButtonView simulateTap];
                    break;
                case ORKTinnitusSelectedPureTonePositionC:
                    [_cButtonView simulateTap];
                    break;
                default:
                    break;
            }
            break;
        case PureToneButtonsStageTwo:
            switch (position) {
                case ORKTinnitusSelectedPureTonePositionA:
                    [_secondAButtonView simulateTap];
                    break;
                case ORKTinnitusSelectedPureTonePositionB:
                    [_secondBButtonView simulateTap];
                    break;
                default:
                    break;
            }
            break;
        case PureToneButtonsStageThree:
            switch (position) {
                case ORKTinnitusSelectedPureTonePositionA:
                    [_thirdAButtonView simulateTap];
                    break;
                case ORKTinnitusSelectedPureTonePositionB:
                    [_thirdBButtonView simulateTap];
                    break;
                default:
                    break;
            }
            break;
        default:
            break;
    }
    if (_buttonsStage == PureToneButtonsStageOne) {
        
    }
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

- (void)tinnitusButtonViewPressed:(nonnull ORKTinnitusButtonView *)tinnitusButtonView {
    [self selectButton:tinnitusButtonView];
    [_scrollView scrollRectToVisible:[_scrollView convertRect:tinnitusButtonView.bounds fromView:tinnitusButtonView] animated:YES];
    if (_delegate && [_delegate respondsToSelector:@selector(playButtonPressedWithNewPosition:)]) {
        [_delegate playButtonPressedWithNewPosition:[self currentSelectedPosition]];
    }
}

@end
