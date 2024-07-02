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
static const CGFloat DividerViewTopBottomPadding = 10.0;


@implementation ORKReviewCardTableViewCell {
    ORKReviewCard *_reviewCard;
    UIView *_backgroundView;
    NSMutableArray<UILabel *> *_questionLabels;
    NSMutableArray<UIView *> *_horizontalRowViews;
    NSMutableArray<NSMutableArray<UILabel *> *> *_resultLabelGroups;
    
    NSMutableArray<NSLayoutConstraint *> *_viewConstraints;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        [self setBackgroundColor:[UIColor clearColor]];
        [self.contentView setBackgroundColor:[UIColor clearColor]];
        
        _questionLabels = [NSMutableArray new];
        _horizontalRowViews = [NSMutableArray new];
        _resultLabelGroups = [NSMutableArray new];
    }
    
    return self;
}

- (void)configureWithReviewCard:(ORKReviewCard *)reviewCard {
    _reviewCard = reviewCard;
    [self _setupSubViews];
    [self _setupConstraints];
}

- (void)_setupSubViews {
    [self _setupBackgoundView];
    [self _setupReviewCardItemLabels];
}

- (void)_setupBackgoundView {
    if (!_backgroundView) {
        _backgroundView = [UIView new];
        _backgroundView.backgroundColor = [UIColor systemGroupedBackgroundColor];
        _backgroundView.clipsToBounds = YES;
        _backgroundView.layer.cornerRadius = BackgroundViewCornerRadius;
        _backgroundView.translatesAutoresizingMaskIntoConstraints = NO;
        [_backgroundView setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
        [self.contentView addSubview:_backgroundView];
    }
}

- (void)_setupReviewCardItemLabels {
    [self _clearOutSubViews];
    
    int index = 0;
    for (ORKReviewCardItem *reviewCardItem in _reviewCard.reviewCardItems) {
        [self _addQuestionLabelWithTitle:reviewCardItem.title];
        
        if (_reviewCard.reviewCardItems.count > 1 && index != _reviewCard.reviewCardItems.count - 1) {
            [self _addHorizontalRowView];
        }
        
        [self _addResultLabelsWithResultValues:reviewCardItem.resultValues];
        index++;
    }
}

- (void)_clearOutSubViews {
    for (UILabel *questionLabel in _questionLabels) {
        [questionLabel removeFromSuperview];
    }
    
    for (UIView *horizontalRowView in _horizontalRowViews) {
        [horizontalRowView removeFromSuperview];
    }
    
    for (NSMutableArray<UILabel *> *resultLabels in _resultLabelGroups) {
        for (UILabel *resultLabel in resultLabels) {
            [resultLabel removeFromSuperview];
        }
    }
    
    _questionLabels = [NSMutableArray new];
    _horizontalRowViews = [NSMutableArray new];
    _resultLabelGroups = [NSMutableArray new];
}

- (void)_setupConstraints {
    [self _resetConstraints];
    
    [_viewConstraints addObjectsFromArray:[self _backgroundViewContraints]];
    NSLayoutAnchor *questionLabelTopRelatedAnchor = _backgroundView.topAnchor;
    UIView *backgroundViewBottomRelatedView;
    
    int index = 0;
    for (UILabel *questionLabel in _questionLabels) {
        [_viewConstraints addObjectsFromArray:[self _constraintsForQuestionLabel:questionLabel
                                                                topRelatedAnchor:questionLabelTopRelatedAnchor]];
       
        NSLayoutAnchor *resultLabelRelatedAnchor = questionLabel.bottomAnchor;
        NSMutableArray<UILabel *> *resultLabels = [_resultLabelGroups objectAtIndex:index];
        for (UILabel *resultLabel in resultLabels) {
            [_viewConstraints addObjectsFromArray:[self _constraintsForResultLabel:resultLabel topRelatedAnchor:resultLabelRelatedAnchor]];
            
            resultLabelRelatedAnchor = resultLabel.bottomAnchor;
            backgroundViewBottomRelatedView = resultLabel;
        }
        
        if (index < _horizontalRowViews.count) {
            UIView *horizontalRowView = [_horizontalRowViews objectAtIndex:index];
            [_viewConstraints addObjectsFromArray:[self _constraintsForHorizontalRowView:horizontalRowView topRelatedAnchor:resultLabelRelatedAnchor]];
            
            questionLabelTopRelatedAnchor = horizontalRowView.bottomAnchor;
        }
        
        index++;
    }
    
    [_viewConstraints addObject:[self _backgroundViewBottomConstraintRelativeToView:backgroundViewBottomRelatedView]];
    
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

- (NSArray<NSLayoutConstraint *> *)_constraintsForQuestionLabel:(UILabel *)questionLabel topRelatedAnchor:(NSLayoutAnchor *)topRelatedAnchor {
    return @[
        [questionLabel.topAnchor constraintEqualToAnchor:topRelatedAnchor constant:CellTopBottomPadding],
        [questionLabel.leadingAnchor constraintEqualToAnchor:_backgroundView.leadingAnchor constant:CellLeftRightPadding],
        [questionLabel.trailingAnchor constraintEqualToAnchor:_backgroundView.trailingAnchor constant:-CellLeftRightPadding]
    ];
}

- (NSArray<NSLayoutConstraint *> *)_constraintsForResultLabel:(UILabel *)resultLabel topRelatedAnchor:(NSLayoutAnchor *)topRelatedAnchor {
    return @[
        [resultLabel.leadingAnchor constraintEqualToAnchor:_backgroundView.leadingAnchor constant:CellLeftRightPadding],
        [resultLabel.trailingAnchor constraintEqualToAnchor:_backgroundView.trailingAnchor constant:-CellLeftRightPadding],
        [resultLabel.topAnchor constraintEqualToAnchor:topRelatedAnchor constant:CellLabelTopPadding]
    ];
}

- (NSArray<NSLayoutConstraint *> *)_constraintsForHorizontalRowView:(UIView *)horizontalRowView topRelatedAnchor:(NSLayoutAnchor *)topRelatedAnchor {
    CGFloat separatorHeight = 1.0 / [UIScreen mainScreen].scale;
    NSLayoutConstraint *heightConstraint = [horizontalRowView.heightAnchor constraintEqualToConstant:separatorHeight];
    [heightConstraint setPriority:UILayoutPriorityDefaultLow];
    return @[
        [horizontalRowView.leadingAnchor constraintEqualToAnchor:_backgroundView.leadingAnchor],
        [horizontalRowView.trailingAnchor constraintEqualToAnchor:_backgroundView.trailingAnchor],
        heightConstraint,
        [horizontalRowView.topAnchor constraintEqualToAnchor:topRelatedAnchor constant:DividerViewTopBottomPadding]
        //[horizontalRowView.bottomAnchor constraintEqualToAnchor:_conditionsLabel.topAnchor constant:-DividerViewTopBottomPadding]
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

- (void)_addQuestionLabelWithTitle:(NSString *)title {
    UILabel *questionLabel = [self _primaryLabel];
    questionLabel.text = title;
    questionLabel.textColor = [UIColor labelColor];
    [_backgroundView addSubview:questionLabel];
    
    [_questionLabels addObject:questionLabel];
}

- (void)_addHorizontalRowView {
    UIView *dividerView = [UIView new];
    dividerView.translatesAutoresizingMaskIntoConstraints = NO;
    dividerView.backgroundColor = [UIColor separatorColor];
    [_backgroundView addSubview:dividerView];
    
    [_horizontalRowViews addObject:dividerView];
}

- (void)_addResultLabelsWithResultValues:(NSArray<NSString *> *)resultValues {
    NSMutableArray<UILabel *> *labels = [NSMutableArray new];
    
    for (NSString *resultValue in resultValues) {
        UILabel *label = [self _secondaryLabel];
        label.text = resultValue;
        label.textColor = [UIColor secondaryLabelColor];
        [labels addObject:label];
        [_backgroundView addSubview:label];
    }
    
    [_resultLabelGroups addObject:labels];
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
