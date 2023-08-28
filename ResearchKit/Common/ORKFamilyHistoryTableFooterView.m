//
/*
 Copyright (c) 2023, Apple Inc. All rights reserved.
 
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

#import "ORKFamilyHistoryTableFooterView.h"

static const CGFloat CellLeftRightPadding = 12.0;
static const CGFloat CellTopBottomPadding = 12.0;
static const CGFloat ViewButtonTopBottomPadding = 12.0;
static const CGFloat ViewLeftRightPadding = 16.0;

@implementation ORKFamilyHistoryTableFooterView {
    NSString *_relativeGroupIdentifier;
    NSString *_title;
    
    UILabel *_titleLabel;
    UIImageView *_iconImageview;
    
    UIButton *_viewButton;
    
    NSMutableArray<NSLayoutConstraint *> *_viewConstraints;
    id<ORKFamilyHistoryTableFooterViewDelegate> _delegate;
}

- (instancetype)initWithTitle:(NSString *)title relativeGroupIdentifier:(NSString *)relativeGroupIdentifier delegate:(id<ORKFamilyHistoryTableFooterViewDelegate>)delegate {
    self = [super init];
    
    if (self) {
        _title = [title copy];
        _relativeGroupIdentifier = [relativeGroupIdentifier copy];
        _delegate = delegate;
        
        self.backgroundColor = [UIColor clearColor];
        
        [self setupSubviews];
        [self setupConstraints];
    }
    return self;
}

- (void)setFrame:(CGRect)frame {
    frame.origin.x += ViewLeftRightPadding;
    frame.size.width -= 2 * ViewLeftRightPadding;
    [super setFrame:frame];
}

- (void)setupSubviews {
    _viewButton = [UIButton new];
    _viewButton.translatesAutoresizingMaskIntoConstraints = NO;
    _viewButton.clipsToBounds = YES;
    _viewButton.layer.cornerRadius = 12.0;
    [_viewButton addTarget:self action:@selector(buttonWasPressed) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_viewButton];
    
    _titleLabel = [UILabel new];
    _titleLabel.text = [_title copy];
    _titleLabel.numberOfLines = 0;
    _titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    _titleLabel.font = [self titleLabelFont];
    
    _titleLabel.textAlignment = NSTextAlignmentLeft;
    [_viewButton addSubview:_titleLabel];
    
    // TODO: REMOVE THIS CHECK AFTER MODULARIZATION ADDITIONS. Min version will be 13 and RA's min verions is already 13
    if (@available(iOS 13.0, *)) {
        _iconImageview = [UIImageView new];
        _iconImageview.image = [UIImage systemImageNamed:@"plus.circle.fill"];
        _iconImageview.translatesAutoresizingMaskIntoConstraints = NO;
        _iconImageview.backgroundColor = [UIColor clearColor];
        _iconImageview.tintColor = [UIColor systemBlueColor];
        [_viewButton addSubview:_iconImageview];
    }
    
    [self updateViewColors];
}

- (void)updateViewColors {
    if (@available(iOS 13.0, *)) {
        _titleLabel.textColor = self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark ? [UIColor whiteColor] : [UIColor systemBlueColor];
        _viewButton.backgroundColor = self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark ?  [UIColor systemGray4Color] : [UIColor whiteColor];
    } else {
        _viewButton.backgroundColor = [UIColor whiteColor];
        _titleLabel.textColor = [UIColor systemBlueColor];
    }
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    [super traitCollectionDidChange:previousTraitCollection];
    [self updateViewColors];
}

- (void)setupConstraints {
    if (_viewConstraints.count > 0) {
        [NSLayoutConstraint deactivateConstraints:_viewConstraints];
    }
    
    _viewConstraints = [NSMutableArray new];
    
    [_viewConstraints addObject:[_viewButton.leadingAnchor constraintEqualToAnchor:self.leadingAnchor]];
    [_viewConstraints addObject:[_viewButton.trailingAnchor constraintEqualToAnchor:self.trailingAnchor]];
    [_viewConstraints addObject:[_viewButton.centerYAnchor constraintEqualToAnchor:self.centerYAnchor]];
    
    [_viewConstraints addObject:[_titleLabel.centerYAnchor constraintEqualToAnchor:_viewButton.centerYAnchor]];
    [_viewConstraints addObject:[_titleLabel.leadingAnchor constraintEqualToAnchor:_viewButton.leadingAnchor constant:CellLeftRightPadding]];
    
    // TODO: REMOVE THIS CHECK AFTER MODULARIZATION ADDITIONS. Min version will be 13 and RA's min verions is already 13
    if (_iconImageview != nil) {
        [_viewConstraints addObject:[_iconImageview.centerYAnchor constraintEqualToAnchor:_viewButton.centerYAnchor]];
        [_viewConstraints addObject:[_iconImageview.trailingAnchor constraintEqualToAnchor:_viewButton.trailingAnchor constant:-CellLeftRightPadding]];
    }
    
    [_viewConstraints addObject:[_viewButton.topAnchor constraintEqualToAnchor:_titleLabel.topAnchor constant:-ViewButtonTopBottomPadding]];
    [_viewConstraints addObject:[_viewButton.bottomAnchor constraintEqualToAnchor:_titleLabel.bottomAnchor constant:ViewButtonTopBottomPadding]];
    
    [_viewConstraints addObject:[self.topAnchor constraintEqualToAnchor:_viewButton.topAnchor constant:-CellTopBottomPadding]];
    [_viewConstraints addObject:[self.bottomAnchor constraintEqualToAnchor:_viewButton.bottomAnchor constant:CellTopBottomPadding]];
    
    [NSLayoutConstraint activateConstraints:_viewConstraints];
}

- (UIFont *)titleLabelFont {
    UIFontDescriptor *descriptor = [UIFontDescriptor preferredFontDescriptorWithTextStyle:UIFontTextStyleBody];
    UIFontDescriptor *fontDescriptor = [descriptor fontDescriptorWithSymbolicTraits:(UIFontDescriptorTraitUIOptimized)];
    return [UIFont fontWithDescriptor:fontDescriptor size:[[fontDescriptor objectForKey: UIFontDescriptorSizeAttribute] doubleValue]];
}

- (void)buttonWasPressed {
    [_delegate ORKFamilyHistoryTableFooterView:self didSelectFooterForRelativeGroup:_relativeGroupIdentifier];
}

@end

