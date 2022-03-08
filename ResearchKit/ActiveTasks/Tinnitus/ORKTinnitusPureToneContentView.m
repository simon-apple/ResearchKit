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

#if RK_APPLE_INTERNAL

#import "ORKTinnitusPureToneContentView.h"
#import "ORKHelpers_Internal.h"
#import "ORKSkin.h"
#import "ORKTinnitusButtonView.h"

static const CGFloat ORKTinnitusStandardSpacing = 12.0;

@interface ORKTinnitusPureToneContentView () <ORKTinnitusButtonViewDelegate> {
    NSLayoutConstraint *_firstALeadingConstraint;
    NSLayoutConstraint *_firstBLeadingConstraint;
    NSLayoutConstraint *_secondALeadingConstraint;
    NSLayoutConstraint *_secondBLeadingConstraint;
    NSLayoutConstraint *_thirdALeadingConstraint;
    NSLayoutConstraint *_thirdBLeadingConstraint;
    NSLayoutConstraint *_cLeadingConstraint;
    NSLayoutConstraint *_cBottomConstraint;

    BOOL _constraintsDefined;
    
    NSArray *_buttonViewsArray;
    
    PureToneButtonsStage _buttonsStage;
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
    
    [self addSubview:_firstAButtonView];
    [self addSubview:_firstBButtonView];
    [self addSubview:_cButtonView];
    
    [self addSubview:_secondAButtonView];
    _secondAButtonView.alpha = 0.0;
    _secondAButtonView.hidden = YES;
    [self addSubview:_secondBButtonView];
    _secondBButtonView.alpha = 0.0;
    _secondBButtonView.hidden = YES;
    [self addSubview:_thirdAButtonView];
    _thirdAButtonView.alpha = 0.0;
    _thirdAButtonView.hidden = YES;
    [self addSubview:_thirdBButtonView];
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

- (void)setDidFinishLayoutBlockFor:(ORKTinnitusButtonView *)button {
    ORKWeakTypeOf(self) weakSelf = self;
    button.didFinishLayoutBlock = ^{
        ORKStrongTypeOf(weakSelf) strongSelf = weakSelf;
        [strongSelf updateConstraintsConstants];
    };
}

- (PureToneButtonsStage)currentStage
{
    return _buttonsStage;
}

- (ORKTinnitusSelectedPureTonePosition)currentSelectedPosition {
    if (_firstAButtonView.isSelected) {
        return ORKTinnitusSelectedPureTonePositionA;
    } else if (_firstBButtonView.isSelected) {
        return ORKTinnitusSelectedPureTonePositionB;
    } else if (_cButtonView.isSelected) {
        return ORKTinnitusSelectedPureTonePositionC;
    } else if (_secondBButtonView.isSelected || _thirdBButtonView.isSelected) {
        return ORKTinnitusSelectedPureTonePositionB;
    } else if (_secondAButtonView.isSelected || _thirdAButtonView.isSelected) {
        return ORKTinnitusSelectedPureTonePositionA;
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
        [self removeConstraint:_cBottomConstraint];
        [self setNeedsUpdateConstraints];
        
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
            _firstAButtonView.alpha = 0;
            _firstBButtonView.alpha = 0;
            _cButtonView.alpha = 0;
            _secondALeadingConstraint.constant = 0;
            _secondBLeadingConstraint.constant = 0;
            _secondAButtonView.alpha = 1.0;
            _secondBButtonView.alpha = 1.0;

            [self layoutIfNeeded];
        } completion:^(BOOL finished) {
            _cButtonView.hidden = YES;
            _firstAButtonView.hidden = YES;
            _firstBButtonView.hidden = YES;
            if (_delegate && [_delegate respondsToSelector:@selector(animationFinishedForStage:)]) {
                [_delegate animationFinishedForStage:_buttonsStage];
            }
            _buttonsStage = PureToneButtonsStageTwo;
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

        [self setNeedsUpdateConstraints];
        
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
            hiddenALeadingConstraint.constant = 0;
            hiddenBLeadingConstraint.constant = 0;
            hiddenAButtonView.alpha = 1.0;
            hiddenBButtonView.alpha = 1.0;
            
            [self layoutIfNeeded];
        } completion:^(BOOL finished) {
            showedAButtonView.hidden = YES;
            showedBButtonView.hidden = YES;
            if (_delegate && [_delegate respondsToSelector:@selector(animationFinishedForStage:)]) {
                [_delegate animationFinishedForStage:_buttonsStage];
            }
            _buttonsStage = (_buttonsStage == PureToneButtonsStageTwo) ? PureToneButtonsStageThree : PureToneButtonsStageTwo;
            // repositioning the buttons after animation
            showedALeadingConstraint.constant = aButtonViewWidth;
            showedBLeadingConstraint.constant = aButtonViewWidth;
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
        _cButtonView.buttonFinishedAutoLayout &&
        !_constraintsDefined) {
        _constraintsDefined = YES;
        _secondALeadingConstraint.constant = _firstAButtonView.bounds.size.width;
        _secondBLeadingConstraint.constant = _firstBButtonView.bounds.size.width;
        _thirdALeadingConstraint.constant = _firstAButtonView.bounds.size.width;
        _thirdBLeadingConstraint.constant = _firstBButtonView.bounds.size.width;
    }
}

- (void)setUpConstraints {
    _firstALeadingConstraint = [_firstAButtonView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor];
    _firstALeadingConstraint.active = YES;
    [_firstAButtonView.widthAnchor constraintEqualToAnchor:self.widthAnchor].active = YES;
    [_firstAButtonView.topAnchor constraintEqualToAnchor:self.topAnchor constant:8].active = YES;
    
    _firstBLeadingConstraint = [_firstBButtonView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor];
    _firstBLeadingConstraint.active = YES;
    [_firstBButtonView.widthAnchor constraintEqualToAnchor:self.widthAnchor].active = YES;
    [_firstBButtonView.topAnchor constraintEqualToAnchor:_firstAButtonView.bottomAnchor constant:ORKTinnitusStandardSpacing].active = YES;
    
    _cLeadingConstraint = [_cButtonView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor];
    _cLeadingConstraint.active = YES;
    [_cButtonView.widthAnchor constraintEqualToAnchor:self.widthAnchor].active = YES;
    [_cButtonView.topAnchor constraintEqualToAnchor:_firstBButtonView.bottomAnchor constant:ORKTinnitusStandardSpacing].active = YES;
    _cBottomConstraint = [_cButtonView.bottomAnchor constraintLessThanOrEqualToAnchor:self.bottomAnchor constant:ORKTinnitusStandardSpacing];
    _cBottomConstraint.active = YES;

    _secondALeadingConstraint = [_secondAButtonView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor];
    _secondALeadingConstraint.active = YES;
    [_secondAButtonView.widthAnchor constraintEqualToAnchor:self.widthAnchor].active = YES;
    [_secondAButtonView.topAnchor constraintEqualToAnchor:self.topAnchor constant:8].active = YES;
    
    _secondBLeadingConstraint = [_secondBButtonView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor];
    _secondBLeadingConstraint.active = YES;
    [_secondBButtonView.widthAnchor constraintEqualToAnchor:self.widthAnchor].active = YES;
    [_secondBButtonView.topAnchor constraintEqualToAnchor:_secondAButtonView.bottomAnchor constant:ORKTinnitusStandardSpacing].active = YES;
    [_secondBButtonView.bottomAnchor constraintLessThanOrEqualToAnchor:self.bottomAnchor constant:ORKTinnitusStandardSpacing].active = YES;

    _thirdALeadingConstraint = [_thirdAButtonView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor];
    _thirdALeadingConstraint.active = YES;
    [_thirdAButtonView.widthAnchor constraintEqualToAnchor:self.widthAnchor].active = YES;
    [_thirdAButtonView.topAnchor constraintEqualToAnchor:self.topAnchor].active = YES;
    
    _thirdBLeadingConstraint = [_thirdBButtonView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor];
    _thirdBLeadingConstraint.active = YES;
    [_thirdBButtonView.widthAnchor constraintEqualToAnchor:self.widthAnchor].active = YES;
    [_thirdBButtonView.topAnchor constraintEqualToAnchor:_thirdAButtonView.bottomAnchor constant:ORKTinnitusStandardSpacing].active = YES;
    [_thirdBButtonView.bottomAnchor constraintLessThanOrEqualToAnchor:self.bottomAnchor constant:ORKTinnitusStandardSpacing].active = YES;
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
    
    if (tinnitusButtonView.isSimulatedTap) {
        UIScrollView *scrollView = [self getScrollSuperviewFor:self];
        CGRect buttonRect = [scrollView convertRect:tinnitusButtonView.bounds fromView:tinnitusButtonView];
        CGRect buttonCenterRect = CGRectMake(buttonRect.origin.x,
                                             buttonRect.origin.y - ((scrollView.bounds.size.height - buttonRect.size.height)/2),
                                             buttonRect.size.width,
                                             scrollView.bounds.size.height);
        
        [scrollView scrollRectToVisible:buttonCenterRect animated:YES];
    }
    
    if (_delegate && [_delegate respondsToSelector:@selector(playButtonPressedWithNewPosition:)]) {
        [_delegate playButtonPressedWithNewPosition:[self currentSelectedPosition]];
    }
}

-(UIScrollView *)getScrollSuperviewFor:(UIView *)view {
    UIView *superview = view.superview;
    if (superview) {
        if ([superview isKindOfClass:[UIScrollView class]]) {
            return (UIScrollView *)superview;
        }
        return [self getScrollSuperviewFor:superview];
    }
    return nil;
}

@end

#endif
