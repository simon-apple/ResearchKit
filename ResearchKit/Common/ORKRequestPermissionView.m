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

#import "ORKRequestPermissionView.h"
#import "ORKStepContainerView_Private.h"
#import "ORKHelpers_Internal.h"
#import "ORKSkin.h"

ORKRequestPermissionsNotification const ORKRequestPermissionsNotificationCardViewStatusChanged = @"ORKRequestPermissionsNotificationCardViewStatusChanged";

static const CGFloat StandardPadding = 15.0;
static const CGFloat IconImageViewWidthHeight = 48.0;
static const CGFloat IconImageViewBottomPadding = 10.0;
static const CGFloat TitleTextLabelBottomPadding = 4.0;
static const CGFloat DetailTextLabelBottomPadding = 10.0;
static const CGFloat CornerRadius = 10.0;

/// A label whose intrinsic size matches the intrinsiz size of its `titleLabel`.
@interface ORKLabelFittingButton : UIButton

@end

@implementation ORKLabelFittingButton

-(CGSize)intrinsicContentSize {
    CGSize titleLabelIntrinsicSize = [self.titleLabel intrinsicContentSize];
    return CGSizeMake(titleLabelIntrinsicSize.width + self.titleEdgeInsets.left + self.titleEdgeInsets.right,
                      titleLabelIntrinsicSize.height + self.titleEdgeInsets.top + self.titleEdgeInsets.bottom);
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.titleLabel.preferredMaxLayoutWidth = self.titleLabel.frame.size.width;
}

@end

@implementation ORKRequestPermissionView {
    NSMutableArray *_constraints;
    
    UIImage *_iconImage;
    UIImageView *_iconImageView;
    
    NSString *_title;
    NSString *_detailText;
    
    UILabel *_titleLabel;
    UILabel *_detailTextLabel;
}

- (instancetype)initWithIconImage:(nullable UIImage *)iconImage title:(NSString *)title detailText:(NSString *)detailText {
    self = [self initWithFrame:CGRectZero];
    
    if (self) {
        _iconImage = iconImage;
        _title = title;
        _detailText = detailText;
        _enableContinueButton = YES;
        [self commonInit];
    }
    
    return self;
}

- (void)commonInit {
    if (@available(iOS 13.0, *)) {
        self.layer.borderColor = [[UIColor separatorColor] CGColor];
        [self setBackgroundColor:[UIColor systemBackgroundColor]];
    } else {
        self.layer.borderColor = [[UIColor ork_midGrayTintColor] CGColor];
        [self setBackgroundColor:[UIColor whiteColor]];
    }

    self.clipsToBounds = false;
    self.layer.cornerRadius = CornerRadius;

    [self setupSubviews];
    [self setUpConstraints];
}

- (void)setupSubviews {
    [self setupIconImageView];
    [self setUpTitleLabel];
    [self setUpDetailTextLabel];
    [self setupRequestDataButton];

    [self updateFonts];
}

- (void)setupIconImageView {
    if (_iconImage) {
        _iconImageView = [[UIImageView alloc] initWithImage:_iconImage];
        _iconImageView.contentMode = UIViewContentModeScaleAspectFit;
        _iconImageView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_iconImageView];
    }
}

- (void)setUpTitleLabel {
    if (_title) {
        _titleLabel = [self makeMultilineLabel];
        _titleLabel.text = _title;
        _titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_titleLabel];
    }
}

- (void)setUpDetailTextLabel {
    if (_detailText) {
        _detailTextLabel = [self makeMultilineLabel];
        _detailTextLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _detailTextLabel.text = _detailText;

        [_detailTextLabel setFont:[UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline]];
        _detailTextLabel.adjustsFontForContentSizeCategory = true;

        [self addSubview:_detailTextLabel];
    }
}

- (void)setupRequestDataButton {
    if (!_requestPermissionButton) {
        _requestPermissionButton = [ORKLabelFittingButton new];
        _requestPermissionButton.translatesAutoresizingMaskIntoConstraints = NO;
        [_requestPermissionButton setTitleEdgeInsets:UIEdgeInsetsMake(5, 16, 5, 16)];

        // The button's corner radius should match the corner radius of the parent.
        // Equation: r_inner = r_inner - d
        // r_inner = corner radius of the inner view
        // r_outer = corner radius of the outer view
        // d = Distance between the inner and outer view in pixels
        _requestPermissionButton.clipsToBounds = false;
        _requestPermissionButton.layer.cornerRadius =
            CornerRadius -
            (StandardPadding / [[UIScreen mainScreen] scale]);

        [self addSubview:_requestPermissionButton];
    }
}

- (UILabel *)makeMultilineLabel {
    UILabel *label = [UILabel new];
    label.numberOfLines = 0;
    label.lineBreakMode = NSLineBreakByWordWrapping;
    label.textAlignment = NSTextAlignmentNatural;
    return label;
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    [super traitCollectionDidChange:previousTraitCollection];
    if (previousTraitCollection.preferredContentSizeCategory != self.traitCollection.preferredContentSizeCategory) {
        [self updateFonts];
    }
}

- (void)updateFonts {
    if (_requestPermissionButton) {
        [_requestPermissionButton.titleLabel setFont: [self fontWithTextStyle:UIFontTextStyleSubheadline weight:UIFontWeightMedium]];
    }

    if (_titleLabel) {
        _titleLabel.font = [self fontWithTextStyle:UIFontTextStyleBody weight:UIFontWeightBold];
    }
}

- (UIFont *)fontWithTextStyle:(UIFontTextStyle)textStyle weight:(UIFontWeight)weight {
    UIFontDescriptor *descriptor = [UIFontDescriptor preferredFontDescriptorWithTextStyle:textStyle];
    return [UIFont systemFontOfSize:descriptor.pointSize weight:weight];
}

- (void)setUpConstraints {
    if (_constraints) {
        [NSLayoutConstraint deactivateConstraints:_constraints];
    }
    
    _constraints = [NSMutableArray array];
        
    [_constraints addObject:[_iconImageView.topAnchor constraintEqualToAnchor:self.topAnchor constant:StandardPadding]];
    [_constraints addObject:[_iconImageView.leftAnchor constraintEqualToAnchor:self.leftAnchor constant:StandardPadding]];
    [_constraints addObject:[_iconImageView.widthAnchor constraintEqualToConstant:IconImageViewWidthHeight]];
    [_constraints addObject:[_iconImageView.heightAnchor constraintEqualToConstant:IconImageViewWidthHeight]];
    
    [_constraints addObject:[_titleLabel.topAnchor constraintEqualToAnchor:_iconImageView.bottomAnchor constant:IconImageViewBottomPadding]];
    [_constraints addObject:[_titleLabel.leftAnchor constraintEqualToAnchor:self.leftAnchor constant:StandardPadding]];
    [_constraints addObject:[_titleLabel.rightAnchor constraintEqualToAnchor:self.rightAnchor constant:-StandardPadding]];
    
    [_constraints addObject:[_detailTextLabel.topAnchor constraintEqualToAnchor:_titleLabel.bottomAnchor constant:TitleTextLabelBottomPadding]];
    [_constraints addObject:[_detailTextLabel.leftAnchor constraintEqualToAnchor:_titleLabel.leftAnchor]];
    [_constraints addObject:[_detailTextLabel.rightAnchor constraintEqualToAnchor:self.rightAnchor constant:-StandardPadding]];

    [_constraints addObject:[_requestPermissionButton.topAnchor constraintEqualToAnchor:_detailTextLabel.bottomAnchor constant:DetailTextLabelBottomPadding]];
    [_constraints addObject:[_requestPermissionButton.leftAnchor constraintEqualToAnchor:_titleLabel.leftAnchor]];
    [_constraints addObject:[_requestPermissionButton.rightAnchor constraintLessThanOrEqualToAnchor:self.rightAnchor constant: -StandardPadding]];
    [_constraints addObject:[_requestPermissionButton.bottomAnchor constraintEqualToAnchor:self.bottomAnchor constant:-StandardPadding]];
   
    [NSLayoutConstraint activateConstraints:_constraints];
}

- (void)updateIconTintColor:(UIColor *)iconTintColor {
    if (_iconImageView) {
        [_iconImageView setTintColor:iconTintColor];
    }
}

- (void)setEnableContinueButton:(BOOL)enableContinueButton {
    _enableContinueButton = enableContinueButton;
    [[NSNotificationCenter defaultCenter] postNotificationName:ORKRequestPermissionsNotificationCardViewStatusChanged object:self];
}

@end
