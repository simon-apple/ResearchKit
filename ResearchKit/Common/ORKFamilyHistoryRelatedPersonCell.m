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

#import "ORKFamilyHistoryRelatedPersonCell.h"

#import "ORKHelpers_Internal.h"
#import "ORKAccessibilityFunctions.h"

static const CGFloat BackgroundViewBottomPadding = 18.0;
static const CGFloat CellLeftRightPadding = 12.0;
static const CGFloat CellTopBottomPadding = 12.0;
static const CGFloat CellBottomPadding = 8.0;
static const CGFloat CellLabelTopPadding = 8.0;
static const CGFloat CellBottomPaddingBeforeAddRelativeButton = 20.0;
static const CGFloat ContentLeftRightPadding = 16.0;
static const CGFloat DividerViewTopBottomPadding = 10.0;

typedef NS_ENUM(NSUInteger, ORKFamilyHistoryEditDeleteViewEvent) {
    ORKFamilyHistoryEditDeleteViewEventEdit = 0,
    ORKFamilyHistoryEditDeleteViewEventDelete,
};

typedef void (^ORKFamilyHistoryEditDeleteViewEventHandler)(ORKFamilyHistoryEditDeleteViewEvent);

@implementation ORKFamilyHistoryRelatedPersonCell {
    UIView *_backgroundView;
    UIView *_dividerView;
    UILabel *_titleLabel;
    UILabel *_conditionsLabel;
    UIButton *_optionsButton;
    
    NSArray<UILabel *> *_detailListLabels;
    NSArray<UILabel *> *_conditionListLabels;
    
    NSMutableArray<NSLayoutConstraint *> *_viewConstraints;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setBackgroundColor:[UIColor clearColor]];
        [self.contentView setBackgroundColor:[UIColor clearColor]];
        
        [self setupSubViews];
        [self setupConstraints];
    }
    
    return self;
}

- (void)setFrame:(CGRect)frame {
    frame.origin.x += ContentLeftRightPadding;
    frame.size.width -= 2 * ContentLeftRightPadding;
    
    [super setFrame:frame];
}

- (UIMenu *)optionsMenu  API_AVAILABLE(ios(13.0)) {
    ORKWeakTypeOf(self) weakSelf = self;
    // Edit Button
    UIImage *editImage = [UIImage systemImageNamed:@"pencil"];
    UIAction *editMenuItem = [UIAction actionWithTitle:ORKLocalizedString(@"FAMILY_HISTORY_EDIT_ENTRY", "")
                                                 image:editImage
                                            identifier:nil
                                               handler:^(__kindof UIAction * _Nonnull action) {
        ORKStrongTypeOf(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            [strongSelf handleContentViewEvent:ORKFamilyHistoryEditDeleteViewEventEdit];
        }
    }];
    
    // Delete Button
    UIImage *deleteImage = [UIImage systemImageNamed:@"trash.fill"];
    UIAction *deleteMenuItem = [UIAction actionWithTitle:ORKLocalizedString(@"FAMILY_HISTORY_DELETE_ENTRY", "")
                                                 image:deleteImage
                                            identifier:nil
                                               handler:^(__kindof UIAction * _Nonnull action) {
        ORKStrongTypeOf(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            [strongSelf handleContentViewEvent:ORKFamilyHistoryEditDeleteViewEventDelete];
        }
    }];
    [deleteMenuItem setAttributes:UIMenuElementAttributesDestructive];
    
    NSArray<UIAction *> *menuChildren = @[
        editMenuItem,
        deleteMenuItem
    ];
    UIMenu *menu = [UIMenu menuWithTitle:@"" children:menuChildren];
    return menu;
}

- (UIAlertController *)alertForOptionsMenu {
    ORKWeakTypeOf(self) weakSelf = self;
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *editAction = [UIAlertAction actionWithTitle:ORKLocalizedString(@"FAMILY_HISTORY_EDIT_ENTRY", "")
                                                         style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction * _Nonnull action) {
        ORKStrongTypeOf(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            [strongSelf handleContentViewEvent:ORKFamilyHistoryEditDeleteViewEventEdit];
        }
    }];
    
    UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:ORKLocalizedString(@"FAMILY_HISTORY_DELETE_ENTRY", "")
                                                         style:UIAlertActionStyleDestructive
                                                       handler:^(UIAlertAction * _Nonnull action) {
        ORKStrongTypeOf(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            [strongSelf handleContentViewEvent:ORKFamilyHistoryEditDeleteViewEventDelete];
        }
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:ORKLocalizedString(@"BUTTON_CANCEL", "") 
                                                           style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction * _Nonnull action) {
    }];
    
    [alert addAction:editAction];
    [alert addAction:deleteAction];
    [alert addAction:cancelAction];
    return alert;
}

- (void)presentOptionsMenuAlert {
    UIAlertController *alert = [self alertForOptionsMenu];
    [UIApplication.sharedApplication.keyWindow.rootViewController presentViewController:alert animated:true completion:nil];
}

- (void)setupSubViews {
    _backgroundView = [UIView new];
    _backgroundView.clipsToBounds = YES;
    _backgroundView.layer.cornerRadius = 12.0;
    _backgroundView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:_backgroundView];
    
    _titleLabel = [UILabel new];
    _titleLabel.numberOfLines = 0;
    _titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    _titleLabel.font = [self titleLabelFont];
    _titleLabel.textAlignment = NSTextAlignmentLeft;
    [_backgroundView addSubview:_titleLabel];
    
    _optionsButton = [UIButton new];
    _optionsButton.translatesAutoresizingMaskIntoConstraints = NO;
    _optionsButton.backgroundColor = [UIColor clearColor];
    _optionsButton.tintColor = [UIColor systemGrayColor];
    if (@available(iOS 14.0, *)) {
        _optionsButton.menu = [self optionsMenu];
        _optionsButton.showsMenuAsPrimaryAction = YES;
    } else {
        [_optionsButton addTarget:self action:@selector(presentOptionsMenuAlert) forControlEvents:UIControlEventTouchUpInside];
    }
    
    if (@available(iOS 13.0, *)) {
        UIImageConfiguration *configuration = [UIImageSymbolConfiguration configurationWithFont:[UIFont preferredFontForTextStyle:UIFontTextStyleBody] scale:ORKImageScaleToUse()];
        [_optionsButton setImage:[UIImage systemImageNamed:@"ellipsis.circle" withConfiguration:configuration] forState:UIControlStateNormal];
    }
    
    [_backgroundView addSubview:_optionsButton];
    
    _dividerView = [UIView new];
    _dividerView.translatesAutoresizingMaskIntoConstraints = NO;
    
    if (@available(iOS 13.0, *)) {
        _dividerView.backgroundColor = [UIColor separatorColor];
    } else {
        _dividerView.backgroundColor = [UIColor lightGrayColor];
    }
    [_backgroundView addSubview:_dividerView];
    
    _conditionsLabel = [UILabel new];
    _conditionsLabel.text = ORKLocalizedString(@"FAMILY_HISTORY_CONDITIONS", "");
    _conditionsLabel.numberOfLines = 0;
    _conditionsLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _conditionsLabel.lineBreakMode = NSLineBreakByWordWrapping;
    _conditionsLabel.font = [self conditionsTitleLabelFont];
    _conditionsLabel.textAlignment = NSTextAlignmentLeft;
    [_backgroundView addSubview:_conditionsLabel];
    
    [self updateViewColors];
}

- (void)updateViewColors {
    if (@available(iOS 13.0, *)) {
        _backgroundView.backgroundColor = self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark ? [UIColor systemGray4Color] : [UIColor whiteColor];
        _dividerView.backgroundColor = self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark ? [UIColor systemGray6Color] : [UIColor separatorColor];
        _titleLabel.textColor = self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark ? [UIColor whiteColor] : [UIColor blackColor];
        _conditionsLabel.textColor = self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark ? [UIColor whiteColor] : [UIColor blackColor];
        _optionsButton.tintColor = self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark ?  [UIColor whiteColor] :  [UIColor systemGrayColor];;

        [self updateViewLabelsTextColor:self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark ? [UIColor whiteColor] : [UIColor systemGrayColor]];
    } else {
        _backgroundView.backgroundColor = [UIColor whiteColor];
        _dividerView.backgroundColor = [UIColor lightGrayColor];
        _titleLabel.textColor = [UIColor blackColor];
        _conditionsLabel.textColor = [UIColor blackColor];
        _optionsButton.tintColor = [UIColor systemGrayColor];
        [self updateViewLabelsTextColor:[UIColor systemGrayColor]];
    }
}

- (void)updateViewLabelsTextColor:(UIColor *)color {
    for (UILabel* detailLabel in _detailListLabels) {
        detailLabel.textColor = color;
    }
    for (UILabel* conditionLabel in _conditionListLabels) {
        conditionLabel.textColor = color;
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
    
    // backgroundView constraints
    [_viewConstraints addObject:[_backgroundView.topAnchor constraintEqualToAnchor:_titleLabel.topAnchor constant:-CellTopBottomPadding]];
    [_viewConstraints addObject:[_backgroundView.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor]];
    [_viewConstraints addObject:[_backgroundView.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor]];
    
    // titleLabel constraints
    [_viewConstraints addObject:[_titleLabel.leadingAnchor constraintEqualToAnchor:_backgroundView.leadingAnchor constant:CellLeftRightPadding]];
    [_viewConstraints addObject:[_titleLabel.trailingAnchor constraintEqualToAnchor:_optionsButton.leadingAnchor constant:-CellLeftRightPadding]];
    
    // optionsButton constraints
    [_viewConstraints addObject:[_optionsButton.topAnchor constraintEqualToAnchor:_titleLabel.topAnchor]];
    [_viewConstraints addObject:[_optionsButton.trailingAnchor constraintEqualToAnchor:_backgroundView.trailingAnchor constant:-CellLeftRightPadding]];
    
    // find lower most view to constrain the dividerView to
    UIView *detailsLowerMostView = _titleLabel;
    
    _detailListLabels = [self getDetailLabels];
    
    for (UILabel *label in _detailListLabels) {
        [_backgroundView addSubview:label];
        
        [_viewConstraints addObject:[label.leadingAnchor constraintEqualToAnchor:_backgroundView.leadingAnchor constant:CellLeftRightPadding]];
        [_viewConstraints addObject:[label.trailingAnchor constraintEqualToAnchor:_optionsButton.leadingAnchor constant:-CellLeftRightPadding]];
        [_viewConstraints addObject:[label.topAnchor constraintEqualToAnchor:detailsLowerMostView.bottomAnchor constant:CellLabelTopPadding]];

        detailsLowerMostView = label;
    }
    
    // dividerView constraints
    CGFloat separatorHeight = 1.0 / [UIScreen mainScreen].scale;
    
    [_viewConstraints addObject:[_dividerView.leftAnchor constraintEqualToAnchor:_backgroundView.leftAnchor]];
    [_viewConstraints addObject:[_dividerView.rightAnchor constraintEqualToAnchor:_backgroundView.rightAnchor]];
    [_viewConstraints addObject:[_dividerView.heightAnchor constraintEqualToConstant:separatorHeight]];
    [_viewConstraints addObject:[_dividerView.topAnchor constraintGreaterThanOrEqualToAnchor: detailsLowerMostView.bottomAnchor constant:DividerViewTopBottomPadding]];
    
    // conditionsLabel constraints
    [_viewConstraints addObject:[_conditionsLabel.topAnchor constraintEqualToAnchor:_dividerView.bottomAnchor constant:DividerViewTopBottomPadding]];
    [_viewConstraints addObject:[_conditionsLabel.leadingAnchor constraintEqualToAnchor:_backgroundView.leadingAnchor constant:CellLeftRightPadding]];
    
    // find lower most view to constrain the backgroundView to
    UIView *conditionsLowerMostView = _conditionsLabel;
    
    _conditionListLabels = [self getConditionLabels];
    
    for (UILabel *label in _conditionListLabels) {
        [_backgroundView addSubview:label];
        
        [_viewConstraints addObject:[label.leadingAnchor constraintEqualToAnchor:_backgroundView.leadingAnchor constant:CellLeftRightPadding]];
        [_viewConstraints addObject:[label.trailingAnchor constraintEqualToAnchor:_backgroundView.trailingAnchor constant:-CellLeftRightPadding]];
        [_viewConstraints addObject:[label.topAnchor constraintEqualToAnchor:conditionsLowerMostView.bottomAnchor constant:CellLabelTopPadding]];

        conditionsLowerMostView = label;
    }
    
    // set backgroundView's bottom anchor to lower most UILabel
    [_viewConstraints addObject:[_backgroundView.bottomAnchor constraintEqualToAnchor:conditionsLowerMostView.bottomAnchor constant:BackgroundViewBottomPadding]];
    
    // set contentView constraints
    [_viewConstraints addObject:[self.contentView.topAnchor constraintEqualToAnchor:_backgroundView.topAnchor]];
    [_viewConstraints addObject:[self.contentView.bottomAnchor
                                 constraintEqualToAnchor:_backgroundView.bottomAnchor
                                 constant:_isLastItemBeforeAddRelativeButton ? CellBottomPaddingBeforeAddRelativeButton : CellBottomPadding]];
    
    [NSLayoutConstraint activateConstraints:_viewConstraints];
}

- (NSArray<UILabel *> *)getDetailLabels {
    for (UILabel *label in _detailListLabels) {
        [label removeFromSuperview];
    }
    
    NSMutableArray<UILabel *> *labels = [NSMutableArray new];
    
    for (NSString *detailValue in _detailValues) {
        UILabel *label = [UILabel new];
        label.text = detailValue;
        label.numberOfLines = 0;
        label.translatesAutoresizingMaskIntoConstraints = NO;
        label.lineBreakMode = NSLineBreakByWordWrapping;
        label.font = [self conditionsLabelFont];
        if (@available(iOS 13.0, *)) {
            label.textColor = self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark ? [UIColor whiteColor] : [UIColor lightGrayColor];
        } else {
            label.textColor = [UIColor lightGrayColor];
        }
        label.textAlignment = NSTextAlignmentLeft;
        
        [labels addObject:label];
    }
    
    return labels;
}

- (NSArray<UILabel *> *)getConditionLabels {
    for (UILabel *label in _conditionListLabels) {
        [label removeFromSuperview];
    }
    
    NSMutableArray<UILabel *> *labels = [NSMutableArray new];
    
    if (!_conditionValues || _conditionValues.count == 0) {
        UILabel *noneSelectedLabel = [UILabel new];
        noneSelectedLabel.text = @"";
        noneSelectedLabel.numberOfLines = 0;
        noneSelectedLabel.translatesAutoresizingMaskIntoConstraints = NO;
        noneSelectedLabel.lineBreakMode = NSLineBreakByWordWrapping;
        noneSelectedLabel.font = [self conditionsLabelFont];
        if (@available(iOS 13.0, *)) {
            noneSelectedLabel.textColor = self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark ? [UIColor whiteColor] : [UIColor lightGrayColor];
        } else {
            noneSelectedLabel.textColor = [UIColor lightGrayColor];
        }
        noneSelectedLabel.textAlignment = NSTextAlignmentLeft;
        
        [labels addObject:noneSelectedLabel];
    } else {
        
        for (NSString *conditionValue in _conditionValues) {
            UILabel *label = [UILabel new];
            label.text = conditionValue;
            label.numberOfLines = 0;
            label.translatesAutoresizingMaskIntoConstraints = NO;
            label.lineBreakMode = NSLineBreakByWordWrapping;
            label.font = [self conditionsLabelFont];
            if (@available(iOS 13.0, *)) {
                label.textColor = self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark ? [UIColor whiteColor] : [UIColor lightGrayColor];
            } else {
                label.textColor = [UIColor lightGrayColor];
            }
            
            label.textAlignment = NSTextAlignmentLeft;
            
            [labels addObject:label];
        }
        
    }
    
    return [labels copy];
}

- (void)handleContentViewEvent:(ORKFamilyHistoryEditDeleteViewEvent)event {
    switch (event) {
        case ORKFamilyHistoryEditDeleteViewEventEdit:
            [_delegate familyHistoryRelatedPersonCell:self tappedOption:ORKFamilyHistoryTooltipOptionEdit];
            break;
            
        case ORKFamilyHistoryEditDeleteViewEventDelete:
            [_delegate familyHistoryRelatedPersonCell:self tappedOption:ORKFamilyHistoryTooltipOptionDelete];
            break;
    }
}

- (void)setTitle:(NSString *)title {
    if (_titleLabel) {
        [_titleLabel setText:title];
    }
    
    _title = title;
}

- (void)setIsLastItemBeforeAddRelativeButton:(BOOL)isLastItemBeforeAddRelativeButton {
    _isLastItemBeforeAddRelativeButton = isLastItemBeforeAddRelativeButton;
    [self setupConstraints];
}

// TODO: investigate makign this its own type
- (void)setDetailValues:(NSArray<NSString *> *)detailValues {
    _detailValues = detailValues;
    [self setupConstraints];
}

- (void)setConditionValues:(NSArray<NSString *> *)conditionValues {
    _conditionValues = conditionValues;
    [self setupConstraints];
}

- (UIFont *)titleLabelFont {
    UIFontDescriptor *descriptor = [UIFontDescriptor preferredFontDescriptorWithTextStyle:UIFontTextStyleSubheadline];
    UIFontDescriptor *fontDescriptor = [descriptor fontDescriptorWithSymbolicTraits:(UIFontDescriptorTraitBold)];
    return [UIFont fontWithDescriptor:fontDescriptor size:[[fontDescriptor objectForKey: UIFontDescriptorSizeAttribute] doubleValue]];
}

- (UIFont *)conditionsTitleLabelFont {
    UIFontDescriptor *descriptor = [UIFontDescriptor preferredFontDescriptorWithTextStyle:UIFontTextStyleSubheadline];
    UIFontDescriptor *fontDescriptor = [descriptor fontDescriptorWithSymbolicTraits:(UIFontDescriptorTraitBold)];
    return [UIFont fontWithDescriptor:fontDescriptor size:[[fontDescriptor objectForKey: UIFontDescriptorSizeAttribute] doubleValue]];
}

- (UIFont *)conditionsLabelFont {
    UIFontDescriptor *descriptor = [UIFontDescriptor preferredFontDescriptorWithTextStyle:UIFontTextStyleSubheadline];
    UIFontDescriptor *fontDescriptor = [descriptor fontDescriptorWithSymbolicTraits:(UIFontDescriptorTraitUIOptimized)];
    return [UIFont fontWithDescriptor:fontDescriptor size:[[fontDescriptor objectForKey: UIFontDescriptorSizeAttribute] doubleValue]];
}

@end
