/*
 Copyright (c) 2024, Apple Inc. All rights reserved.
 
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

#import "ORKReviewCardTableViewCell.h"

#import "ORKReviewCard.h"
#import "ORKReviewCardItem.h"

static const CGFloat BackgroundViewBottomPadding = 18.0;
static const CGFloat BackgroundViewCornerRadius = 12.0;
static const CGFloat CellBottomPadding = 8.0;
static const CGFloat CellLabelTopPadding = 8.0;
static const CGFloat CellLeftRightPadding = 12.0;
static const CGFloat CellTopBottomPadding = 12.0;
static const CGFloat ContentLeftRightPadding = 16.0;


@implementation ORKReviewCardTableViewCell {
    ORKReviewCard *_reviewCard;
    
    UIView *_backgroundView;
    
    NSMutableArray<NSLayoutConstraint *> *_viewConstraints;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        [self setBackgroundColor:[UIColor clearColor]];
        [self.contentView setBackgroundColor:[UIColor clearColor]];
    }
    
    return self;
}

- (void)configureWithReviewCard:(ORKReviewCard *)reviewCard {
    _reviewCard = reviewCard;
    [self _setupSubViews];
}

- (void)_setupSubViews {
    [self _setupBackgoundView];
    [self _setupReviewCardItemLabels];
}

- (void)_setupBackgoundView {
    _backgroundView = [UIView new];
    _backgroundView.backgroundColor = [UIColor secondarySystemGroupedBackgroundColor];
    _backgroundView.clipsToBounds = YES;
    _backgroundView.layer.cornerRadius = BackgroundViewCornerRadius;
    _backgroundView.translatesAutoresizingMaskIntoConstraints = NO;
    [_backgroundView setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
    [self.contentView addSubview:_backgroundView];
}

- (void)_setupReviewCardItemLabels {
    int index = 0;
    for (ORKReviewCardItem *reviewCardItem in _reviewCard.reviewCardItems) {
        UILabel *questionLabel = [self _getQuestionLabelWithTitle:reviewCardItem.title];
        NSArray<UILabel *> *resultValueLabels = [self _getResultLabelsWithResultValues:reviewCardItem.resultValues];
        
        [self _setupConstraintsWithQuestionLabel:questionLabel resultValueLabels:resultValueLabels index:index];
        index++;
    }
}

- (void)_setupConstraintsWithQuestionLabel:(UILabel *)questionLabel 
                         resultValueLabels:(NSArray<UILabel *> *)resultValueLabels
                                     index:(int)index {
    if (index == 0) {
        [self _resetConstraints];
    }
    
    [_viewConstraints addObjectsFromArray:[self _backgroundViewContraints]];
    [_viewConstraints addObjectsFromArray:[self _constraintsForQuestionLabel:questionLabel]];
    
    UIView *relativeTopView = questionLabel;
    for (UILabel *resultValueLabel in resultValueLabels) {
        [_viewConstraints addObjectsFromArray: [self _constraintsForResultLabel:resultValueLabel relativeTo:relativeTopView]];
        relativeTopView = resultValueLabel;
    }
    
    [_viewConstraints addObject:[self _backgroundViewBottomConstraintRelativeToView:relativeTopView]];
    
    [NSLayoutConstraint activateConstraints:_viewConstraints];
}

#pragma mark Constraint Helpers

- (void)_resetConstraints {
    if (_viewConstraints) {
        [NSLayoutConstraint deactivateConstraints:_viewConstraints];
    }
    _viewConstraints = [NSMutableArray new];
}

- (NSArray<NSLayoutConstraint *> *)_backgroundViewContraints {
    return @[
        [_backgroundView.topAnchor constraintEqualToAnchor:self.contentView.topAnchor],
        [_backgroundView.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:ContentLeftRightPadding],
        [_backgroundView.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-ContentLeftRightPadding],
        [_backgroundView.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor constant:-CellBottomPadding]
    ];
}

- (NSArray<NSLayoutConstraint *> *)_constraintsForQuestionLabel:(UILabel *)questionLabel {
    return @[
        [questionLabel.topAnchor constraintEqualToAnchor:_backgroundView.topAnchor constant:CellTopBottomPadding],
        [questionLabel.leadingAnchor constraintEqualToAnchor:_backgroundView.leadingAnchor constant:CellLeftRightPadding],
        [questionLabel.trailingAnchor constraintEqualToAnchor:_backgroundView.trailingAnchor constant:-CellLeftRightPadding]
    ];
}

- (NSArray<NSLayoutConstraint *> *)_constraintsForResultLabel:(UILabel *)resultLabel relativeTo:(UIView *)referenceView {
    return @[
        [resultLabel.leadingAnchor constraintEqualToAnchor:_backgroundView.leadingAnchor constant:CellLeftRightPadding],
        [resultLabel.trailingAnchor constraintEqualToAnchor:_backgroundView.trailingAnchor constant:-CellLeftRightPadding],
        [resultLabel.topAnchor constraintEqualToAnchor:referenceView.bottomAnchor constant:CellLabelTopPadding]
    ];
}

- (NSLayoutConstraint *)_backgroundViewBottomConstraintRelativeToView:(UIView *)view {
    // set backgroundView's bottom anchor to lower most UILabel
    NSLayoutConstraint *bottomConstraint = [view.lastBaselineAnchor constraintEqualToAnchor:_backgroundView.bottomAnchor
                                                                                    constant:-BackgroundViewBottomPadding];
    [bottomConstraint setPriority:UILayoutPriorityDefaultHigh];
    return bottomConstraint;
}

#pragma mark UILabel Helpers

- (UILabel *)_getQuestionLabelWithTitle:(NSString *)title {
    UILabel *questionLabel = [self _primaryLabel];
    questionLabel.text = title;
    questionLabel.textColor = [UIColor labelColor];
    [_backgroundView addSubview:questionLabel];
    
    return questionLabel;
}

- (NSArray<UILabel *> *)_getResultLabelsWithResultValues:(NSArray<NSString *> *)resultValues {
    NSMutableArray<UILabel *> *labels = [NSMutableArray new];
    
    for (NSString *resultValue in resultValues) {
        UILabel *label = [self _secondaryLabel];
        label.text = resultValue;
        label.textColor = [UIColor secondaryLabelColor];
        [labels addObject:label];
        [_backgroundView addSubview:label];
    }
    
    return [labels copy];
}

- (UILabel *)_baseLabel {
    UILabel *label = [UILabel new];
    label.translatesAutoresizingMaskIntoConstraints = NO;
    label.lineBreakMode = NSLineBreakByWordWrapping;
    label.textAlignment = NSTextAlignmentNatural;
    label.numberOfLines = 0;
    return label;
}

- (UILabel *)_primaryLabel {
    UILabel *label = [self _baseLabel];
    label.font = [self _titleLabelFont];
    return label;
}

- (UILabel *)_secondaryLabel {
    UILabel *label = [self _baseLabel];
    label.font = [self _resultLabelFont];
    label.textColor = self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark ? [UIColor whiteColor] : [UIColor lightGrayColor];
    return label;
}

- (UIFont *)_titleLabelFont {
    UIFontDescriptor *descriptor = [UIFontDescriptor preferredFontDescriptorWithTextStyle:UIFontTextStyleSubheadline];
    UIFontDescriptor *fontDescriptor = [descriptor fontDescriptorWithSymbolicTraits:(UIFontDescriptorTraitBold)];
    return [UIFont fontWithDescriptor:fontDescriptor size:[[fontDescriptor objectForKey: UIFontDescriptorSizeAttribute] doubleValue]];
}

- (UIFont *)_resultLabelFont {
    UIFontDescriptor *descriptor = [UIFontDescriptor preferredFontDescriptorWithTextStyle:UIFontTextStyleSubheadline];
    UIFontDescriptor *fontDescriptor = [descriptor fontDescriptorWithSymbolicTraits:(UIFontDescriptorTraitUIOptimized)];
    return [UIFont fontWithDescriptor:fontDescriptor size:[[fontDescriptor objectForKey: UIFontDescriptorSizeAttribute] doubleValue]];
}

@end
