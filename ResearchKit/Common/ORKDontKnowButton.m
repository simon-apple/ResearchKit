/*
 Copyright (c) 2019, Apple Inc. All rights reserved.
 
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

#import "ORKDontKnowButton.h"
#import "ORKHelpers_Internal.h"
#import "ORKBorderedButton.h"
#import "ORKCheckmarkView.h"
#import "ORKSkin.h"
#import "ORKLabel.h"

static const CGFloat DontKnowButtonCornerRadius = 10.0;
static const CGFloat DontKnowButtonEdgeInsetHorizontalSpacing = 10.0;
static const CGFloat DontKnowButtonEdgeInsetVerticalSpacing = 4.0;
static const CGFloat CheckMarkImageHeightOffset = 2.0;
static const CGFloat CheckMarkImageTrailingPadding = 2.0;

@implementation ORKDontKnowButton {
    UIView *_dontKnowButtonCustomView;
    ORKLabel *_dontKnowButtonTextLabel;
    ORKCheckmarkView *_checkmarkView;
    NSMutableArray<NSLayoutConstraint *> *_constraints;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self init_ORKDontKnowButton];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self init_ORKDontKnowButton];
    }
    return self;
}

- (void)init_ORKDontKnowButton {
    _isDontKnowButtonActive = NO;
    _dontKnowButtonStyle = ORKDontKnowButtonStyleStandard;
    
    [self setButtonInactive];
    [self tintColorDidChange];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (_dontKnowButtonCustomView && _dontKnowButtonCustomView.frame.size.width > 0 && _dontKnowButtonStyle == ORKDontKnowButtonStyleStandard) {
        _dontKnowButtonCustomView.layer.cornerRadius = _dontKnowButtonCustomView.frame.size.height / 2;
        [_dontKnowButtonCustomView.layer setCornerCurveContinuous];
    }
}

- (void)updateAppearance {
    self.layer.cornerRadius = DontKnowButtonCornerRadius;
    [self.layer setCornerCurveContinuous];
    
    self.clipsToBounds = YES;
    
    if (_dontKnowButtonCustomView) {
        [_dontKnowButtonCustomView removeFromSuperview];
    }
    
    _dontKnowButtonCustomView = [UIView new];
    [_dontKnowButtonCustomView setUserInteractionEnabled:NO];
    _dontKnowButtonCustomView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:_dontKnowButtonCustomView];
    
    if (!_dontKnowButtonTextLabel) {
        _dontKnowButtonTextLabel = [ORKLabel new];
        _dontKnowButtonTextLabel.text = ORKLocalizedString(@"SLIDER_I_DONT_KNOW", nil);
        _dontKnowButtonTextLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _dontKnowButtonTextLabel.numberOfLines = 0;
        _dontKnowButtonTextLabel.lineBreakMode = NSLineBreakByWordWrapping;
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setButtonInactive {
    switch (_dontKnowButtonStyle) {
        case ORKDontKnowButtonStyleStandard:
            [self setButtonInactiveStandard];
            break;
            
        case ORKDontKnowButtonStyleCircleChoice:
            [self setButtonInactiveCircleChoice];
            break;
    }
}

- (void)setButtonActive {
    switch (_dontKnowButtonStyle) {
        case ORKDontKnowButtonStyleStandard:
            [self setButtonActiveStandard];
            break;
            
        case ORKDontKnowButtonStyleCircleChoice:
            [self setButtonActiveCircleChoice];
            break;
    }
}

- (void)setCustomDontKnowButtonText:(NSString *)customDontKnowButtonText {
    _customDontKnowButtonText = customDontKnowButtonText;
    
    if (_customDontKnowButtonText) {
        _dontKnowButtonTextLabel.text = _customDontKnowButtonText;
    }
    
    if (_isDontKnowButtonActive) {
        [self setButtonActive];
    } else {
        [self setButtonInactive];
    }
}

- (void)setDontKnowButtonStyle:(ORKDontKnowButtonStyle)dontKnowButtonStyle {
    _dontKnowButtonStyle = dontKnowButtonStyle;
    
    if (_isDontKnowButtonActive) {
        [self setButtonActive];
    } else {
        [self setButtonInactive];
    }
}

- (void)setButtonInactiveStandard {
    if (_constraints) {
        [NSLayoutConstraint deactivateConstraints:_constraints];
    }
    
    _constraints = [NSMutableArray new];
    
    _isDontKnowButtonActive = NO;
    [self updateAppearance];
    
    UIFontDescriptor *dontKnowButtonDescriptor = [UIFontDescriptor preferredFontDescriptorWithTextStyle:UIFontTextStyleFootnote];
    UIFontDescriptor *dontKnowButtonFontDescriptor = [dontKnowButtonDescriptor fontDescriptorWithSymbolicTraits:(UIFontDescriptorTraitBold)];
    [_dontKnowButtonTextLabel setFont:[UIFont fontWithDescriptor:dontKnowButtonFontDescriptor size:[[dontKnowButtonDescriptor objectForKey: UIFontDescriptorSizeAttribute] doubleValue]]];
    [_dontKnowButtonTextLabel setTextAlignment:NSTextAlignmentCenter];
    
    [_dontKnowButtonCustomView addSubview:_dontKnowButtonTextLabel];
    
    if (@available(iOS 13.0, *)) {
        [_dontKnowButtonCustomView setBackgroundColor:[UIColor systemFillColor]];
        [_dontKnowButtonTextLabel setTextColor:[UIColor secondaryLabelColor]];
    } else {
        [_dontKnowButtonCustomView setBackgroundColor:[UIColor grayColor]];
        [_dontKnowButtonTextLabel setTextColor:[UIColor grayColor]];
    }

    CGSize neededSize = [_dontKnowButtonTextLabel sizeThatFits:CGSizeMake( _dontKnowButtonTextLabel.frame.size.width, CGFLOAT_MAX)];
    
    //label constraints
    [_constraints addObject:[_dontKnowButtonTextLabel.heightAnchor constraintGreaterThanOrEqualToConstant:neededSize.height]];
    [_constraints addObject:[_dontKnowButtonTextLabel.centerYAnchor constraintEqualToAnchor:_dontKnowButtonCustomView.centerYAnchor]];
    [_constraints addObject:[_dontKnowButtonTextLabel.centerXAnchor constraintEqualToAnchor:_dontKnowButtonCustomView.centerXAnchor]];
    
    //custom view constraints
    [_constraints addObject:[_dontKnowButtonCustomView.topAnchor constraintEqualToAnchor:_dontKnowButtonTextLabel.topAnchor constant:-DontKnowButtonEdgeInsetVerticalSpacing]];
    [_constraints addObject:[_dontKnowButtonCustomView.bottomAnchor constraintEqualToAnchor:_dontKnowButtonTextLabel.bottomAnchor constant:DontKnowButtonEdgeInsetVerticalSpacing]];
    [_constraints addObject:[_dontKnowButtonCustomView.centerXAnchor constraintEqualToAnchor:self.centerXAnchor]];
    [_constraints addObject:[_dontKnowButtonCustomView.leadingAnchor constraintEqualToAnchor:_dontKnowButtonTextLabel.leadingAnchor constant:-DontKnowButtonEdgeInsetHorizontalSpacing]];
    [_constraints addObject:[_dontKnowButtonCustomView.trailingAnchor constraintEqualToAnchor:_dontKnowButtonTextLabel.trailingAnchor constant:DontKnowButtonEdgeInsetHorizontalSpacing]];
        
    //button constraints
    [_constraints addObject:[self.topAnchor constraintEqualToAnchor:_dontKnowButtonCustomView.topAnchor constant:0.0]];
    [_constraints addObject:[self.bottomAnchor constraintEqualToAnchor:_dontKnowButtonCustomView.bottomAnchor constant:0.0]];
    [_constraints addObject:[self.widthAnchor constraintGreaterThanOrEqualToAnchor:_dontKnowButtonCustomView.widthAnchor]];
    
    [NSLayoutConstraint activateConstraints:_constraints];
}

- (void)setButtonActiveStandard {
    if (_constraints) {
        [NSLayoutConstraint deactivateConstraints:_constraints];
    }
    
    _constraints = [NSMutableArray new];
    
    _isDontKnowButtonActive = YES;
    [self updateAppearance];
    
    UIFontDescriptor *dontKnowButtonDescriptor = [UIFontDescriptor preferredFontDescriptorWithTextStyle:UIFontTextStyleFootnote];
    UIFontDescriptor *dontKnowButtonFontDescriptor = [dontKnowButtonDescriptor fontDescriptorWithSymbolicTraits:(UIFontDescriptorTraitBold)];
    [_dontKnowButtonTextLabel setFont:[UIFont fontWithDescriptor:dontKnowButtonFontDescriptor size:[[dontKnowButtonDescriptor objectForKey: UIFontDescriptorSizeAttribute] doubleValue]]];
    
    [_dontKnowButtonCustomView addSubview:_dontKnowButtonTextLabel];
    
    if (@available(iOS 13.0, *)) {
        [_dontKnowButtonTextLabel setTextColor:[UIColor systemBackgroundColor]];
        
        //image, image view and add to custom view
        UIImageSymbolConfiguration *imageConfig = [UIImageSymbolConfiguration configurationWithScale:UIImageSymbolScaleSmall];
        UIImage *checkMarkImage = [UIImage systemImageNamed:@"checkmark.circle.fill" withConfiguration:imageConfig];
        UIImage *tintedCheckMarkImage = [checkMarkImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:tintedCheckMarkImage];
        imageView.translatesAutoresizingMaskIntoConstraints = NO;
        [imageView setTintColor:_dontKnowButtonTextLabel.textColor];
        
        [_dontKnowButtonCustomView addSubview:imageView];
        
        CGSize neededSize = [_dontKnowButtonTextLabel sizeThatFits:CGSizeMake( _dontKnowButtonTextLabel.frame.size.width, CGFLOAT_MAX)];
        
        //image view constraints
        [_constraints addObject:[imageView.heightAnchor constraintEqualToConstant:neededSize.height + CheckMarkImageHeightOffset]];
        [_constraints addObject:[imageView.widthAnchor constraintEqualToConstant:neededSize.height]];
        [_constraints addObject:[imageView.trailingAnchor constraintEqualToAnchor:_dontKnowButtonTextLabel.leadingAnchor constant:-CheckMarkImageTrailingPadding]];
        [_constraints addObject:[imageView.centerYAnchor constraintEqualToAnchor:_dontKnowButtonCustomView.centerYAnchor]];
        
        //label constraints
        [_constraints addObject:[_dontKnowButtonTextLabel.centerYAnchor constraintEqualToAnchor:imageView.centerYAnchor]];
                
        //custom view constraints
        [_constraints addObject:[_dontKnowButtonCustomView.topAnchor constraintEqualToAnchor:_dontKnowButtonTextLabel.topAnchor constant:-DontKnowButtonEdgeInsetVerticalSpacing]];
        [_constraints addObject:[_dontKnowButtonCustomView.bottomAnchor constraintEqualToAnchor:_dontKnowButtonTextLabel.bottomAnchor constant:DontKnowButtonEdgeInsetVerticalSpacing]];
        [_constraints addObject:[_dontKnowButtonCustomView.centerXAnchor constraintEqualToAnchor:self.centerXAnchor]];
        [_constraints addObject:[_dontKnowButtonCustomView.leadingAnchor constraintEqualToAnchor:imageView.leadingAnchor constant:-DontKnowButtonEdgeInsetHorizontalSpacing]];
        [_constraints addObject:[_dontKnowButtonCustomView.trailingAnchor constraintEqualToAnchor:_dontKnowButtonTextLabel.trailingAnchor constant:DontKnowButtonEdgeInsetHorizontalSpacing]];
        
        //button constraints
        [_constraints addObject:[self.topAnchor constraintEqualToAnchor:_dontKnowButtonCustomView.topAnchor constant:0.0]];
        [_constraints addObject:[self.bottomAnchor constraintEqualToAnchor:_dontKnowButtonCustomView.bottomAnchor constant:0.0]];
        [_constraints addObject:[self.widthAnchor constraintGreaterThanOrEqualToAnchor:_dontKnowButtonCustomView.widthAnchor]];
        
        [NSLayoutConstraint activateConstraints:_constraints];
    } else {
        [_dontKnowButtonTextLabel setTextColor:[UIColor whiteColor]];
    }
    
    [_dontKnowButtonCustomView setBackgroundColor:ORKWindowTintcolor(self.window) ? : [UIColor systemBlueColor]];
}

- (void)setButtonInactiveCircleChoice {
    [self setupCircleChoiceView];
    
    [_checkmarkView setChecked:NO];
    _isDontKnowButtonActive = NO;
}

- (void)setButtonActiveCircleChoice {
    [self setupCircleChoiceView];
    
    [_checkmarkView setChecked:YES];
    _isDontKnowButtonActive = YES;
}

- (void)setupCircleChoiceView {
    if (!_checkmarkView) {
        [self setupCheckMarkView];
    } else {
        return;
    }
    
    if (_constraints) {
        [NSLayoutConstraint deactivateConstraints:_constraints];
    }
    
    _constraints = [NSMutableArray new];
    
    [self updateAppearance];
    
    //setup and add text label
    [self setupCircleChoiceViewLabel];
    [_dontKnowButtonCustomView addSubview:_dontKnowButtonTextLabel];
    
    //add checkmark view here
    [_dontKnowButtonCustomView addSubview:_checkmarkView];
    
    if (@available(iOS 13.0, *)) {
        [_dontKnowButtonCustomView setBackgroundColor:[UIColor secondarySystemGroupedBackgroundColor]];
    } else {
        [_dontKnowButtonCustomView setBackgroundColor:[UIColor whiteColor]];
    }

    CGSize neededSize = [_dontKnowButtonTextLabel sizeThatFits:CGSizeMake(_dontKnowButtonTextLabel.frame.size.width, CGFLOAT_MAX)];
    
    //label constraints
    [_constraints addObject:[_dontKnowButtonTextLabel.heightAnchor constraintGreaterThanOrEqualToConstant:neededSize.height]];
    [_constraints addObject:[_dontKnowButtonTextLabel.centerYAnchor constraintEqualToAnchor:_dontKnowButtonCustomView.centerYAnchor]];
    [_constraints addObject:[_dontKnowButtonTextLabel.leadingAnchor constraintEqualToAnchor:_dontKnowButtonCustomView.leadingAnchor constant:8.0]];
    [_constraints addObject:[_dontKnowButtonTextLabel.trailingAnchor constraintEqualToAnchor:_checkmarkView.leadingAnchor constant:-8.0]];
    
    //image view constraints
    [_constraints addObject:[_checkmarkView.trailingAnchor constraintEqualToAnchor:_dontKnowButtonCustomView.trailingAnchor constant:-ORKSurveyItemMargin]];
    [_constraints addObject:[_checkmarkView.centerYAnchor constraintEqualToAnchor:_dontKnowButtonCustomView.centerYAnchor]];
    
    //custom view constraints
    [_constraints addObject:[_dontKnowButtonCustomView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor]];
    [_constraints addObject:[_dontKnowButtonCustomView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor]];
    [_constraints addObject:[_dontKnowButtonCustomView.topAnchor constraintEqualToAnchor:self.topAnchor]];
    [_constraints addObject:[_dontKnowButtonCustomView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor]];
    
    [_constraints addObject:[self.widthAnchor constraintGreaterThanOrEqualToAnchor:_dontKnowButtonCustomView.widthAnchor]];
    
    [NSLayoutConstraint activateConstraints:_constraints];
}

- (void)setupCircleChoiceViewLabel {
    [_dontKnowButtonTextLabel setTextAlignment:NSTextAlignmentLeft];
    
    if (@available(iOS 13.0, *)) {
        _dontKnowButtonTextLabel.textColor = [UIColor labelColor];
    } else {
        _dontKnowButtonTextLabel.textColor = [UIColor blackColor];
    }

    [self setChoiceViewLabelFont];
}

- (void)setChoiceViewLabelFont {
    UIFontDescriptor *descriptor = [UIFontDescriptor preferredFontDescriptorWithTextStyle:UIFontTextStyleSubheadline];
    [_dontKnowButtonTextLabel setFont:[UIFont fontWithDescriptor:descriptor size:[[descriptor objectForKey: UIFontDescriptorSizeAttribute] doubleValue]]];
}

- (void)setupCheckMarkView {
    _checkmarkView = [[ORKCheckmarkView alloc] initWithDefaults];
    _checkmarkView.contentMode = UIViewContentModeScaleAspectFill;
    _checkmarkView.translatesAutoresizingMaskIntoConstraints = NO;
}

#pragma mark - Accessibility

- (BOOL)isAccessibilityElement {
    return YES;
}

- (NSString *)accessibilityLabel {
    NSString *accessibilityLabelText = [NSString stringWithFormat:@"%@ %@", [self isDontKnowButtonActive] ? ORKLocalizedString(@"AX_SELECTED", nil) : ORKLocalizedString(@"AX_UNSELECTED", nil), _customDontKnowButtonText != nil ? _customDontKnowButtonText : ORKLocalizedString(@"SLIDER_I_DONT_KNOW", nil)];
    
    if ([self isDontKnowButtonActive]) {
        accessibilityLabelText = [accessibilityLabelText stringByAppendingFormat:@", %@", ORKLocalizedString(@"AX_BUTTON", nil)];
    }
    
    return accessibilityLabelText;
}

@end


