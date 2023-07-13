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

static const CGFloat CellLeftRightPadding = 12.0;
static const CGFloat CellTopBottomPadding = 12.0;
static const CGFloat CellBottomPadding = 8.0;
static const CGFloat CellLabelTopPadding = 8.0;
static const CGFloat CellBottomPaddingBeforeAddRelativeButton = 20.0;
static const CGFloat ContentLeftRightPadding = 16.0;
static const CGFloat DividerViewTopBottomPadding = 10.0;

static const CGFloat EditDeleteLabelTopBottomPadding = 8.0;
static const CGFloat EditDeleteLabelLeftRightPadding = 8.0;

typedef NS_ENUM(NSUInteger, ORKFamilyHistoryEditDeleteViewEvent) {
    ORKFamilyHistoryEditDeleteViewEventEdit = 0,
    ORKFamilyHistoryEditDeleteViewEventDelete,
};

typedef void (^ORKFamilyHistoryEditDeleteViewEventHandler)(ORKFamilyHistoryEditDeleteViewEvent);

@interface ORKFamilyHistoryEditDeleteView : UIView

- (instancetype)init NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_UNAVAILABLE;
- (instancetype)initWithFrame:(CGRect)frame NS_UNAVAILABLE;

- (void)setViewEventHandler:(ORKFamilyHistoryEditDeleteViewEventHandler)handler;

@property (nonatomic, copy, nullable) ORKFamilyHistoryEditDeleteViewEventHandler eventhandler;

@end


@implementation ORKFamilyHistoryEditDeleteView {
    UIButton *_editButton;
    UIButton *_deleteButton;
    
    UILabel *_editLabel;
    UILabel *_deleteLabel;
    
    UIImageView *_editImageView;
    UIImageView *_deleteImageView;
    
    UIView *_dividerView;

    NSMutableArray<NSLayoutConstraint *> *_viewConstraints;
}

- (instancetype)init {
    self = [super initWithFrame:CGRectZero];
    
    if (self) {
        [self styleView];
        [self setupSubviews];
        [self setupConstraints];
    }
    
    return self;
}

- (void)styleView {
    self.backgroundColor = [UIColor whiteColor];
    self.clipsToBounds = YES;
    self.layer.cornerRadius = 12.0;
    self.translatesAutoresizingMaskIntoConstraints = NO;
    
    self.layer.borderWidth = 1.0;
    self.layer.borderColor = UIColor.whiteColor.CGColor;
    self.layer.shadowRadius = 1.5;
    self.layer.shadowOpacity = 0.2;
    self.layer.shadowOffset = CGSizeZero;
    self.layer.masksToBounds = NO;
}

- (void)setupSubviews {
    _editButton = [UIButton new];
    _editButton.backgroundColor = [UIColor clearColor];
    _editButton.translatesAutoresizingMaskIntoConstraints = NO;
    [_editButton addTarget:self action:@selector(editButtonWasPressed) forControlEvents:UIControlEventTouchUpInside];
    
    _editLabel = [UILabel new];
    _editLabel.textColor = [UIColor blackColor];
    _editLabel.textAlignment = NSTextAlignmentLeft;
    _editLabel.text = ORKLocalizedString(@"FAMILY_HISTORY_EDIT_ENTRY", "");
    _editLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [_editButton addSubview:_editLabel];
    
    if (@available(iOS 13.0, *)) {
        UIImage *editImage = [UIImage systemImageNamed:@"pencil"];
        _editImageView = [[UIImageView alloc] initWithImage:editImage];
        _editImageView.backgroundColor = [UIColor clearColor];
        _editImageView.tintColor = [UIColor blackColor];
        _editImageView.translatesAutoresizingMaskIntoConstraints = NO;
        [_editButton addSubview:_editImageView];
    }
    
    [self addSubview:_editButton];
    
    _dividerView = [UIView new];
    _dividerView.translatesAutoresizingMaskIntoConstraints = NO;
    
    if (@available(iOS 13.0, *)) {
        _dividerView.backgroundColor = [UIColor separatorColor];
    } else {
        _dividerView.backgroundColor = [UIColor lightGrayColor];
    }
    [self addSubview:_dividerView];
    
    
    _deleteButton = [UIButton new];
    _deleteButton.backgroundColor = [UIColor clearColor];
    _deleteButton.translatesAutoresizingMaskIntoConstraints = NO;
    [_deleteButton addTarget:self action:@selector(deleteButtonWasPressed) forControlEvents:UIControlEventTouchUpInside];
    
    _deleteLabel = [UILabel new];
    _deleteLabel.textColor = [UIColor redColor];
    _deleteLabel.textAlignment = NSTextAlignmentLeft;
    _deleteLabel.text = ORKLocalizedString(@"FAMILY_HISTORY_DELETE_ENTRY", "");
    _deleteLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [_deleteButton addSubview:_deleteLabel];
    
    if (@available(iOS 13.0, *)) {
        UIImage *deleteImage = [UIImage systemImageNamed:@"trash.fill"];
        _deleteImageView = [[UIImageView alloc] initWithImage:deleteImage];
        _deleteImageView.backgroundColor = [UIColor clearColor];
        _deleteImageView.tintColor = [UIColor redColor];
        _deleteImageView.translatesAutoresizingMaskIntoConstraints = NO;
        [_deleteButton addSubview:_deleteImageView];
    }
    
    [self addSubview:_deleteButton];
}

- (void)setupConstraints {
    if (_viewConstraints.count > 0) {
        [NSLayoutConstraint deactivateConstraints:_viewConstraints];
    }
    
    _viewConstraints = [NSMutableArray new];
    
    // edit button & label constraints
    [_viewConstraints addObject:[_editButton.topAnchor constraintEqualToAnchor:self.topAnchor]];
    [_viewConstraints addObject:[_editButton.leadingAnchor constraintEqualToAnchor:self.leadingAnchor]];
    [_viewConstraints addObject:[_editButton.trailingAnchor constraintEqualToAnchor:self.trailingAnchor]];
    
    [_viewConstraints addObject:[_editLabel.topAnchor constraintEqualToAnchor:_editButton.topAnchor constant:EditDeleteLabelTopBottomPadding]];
    [_viewConstraints addObject:[_editLabel.leadingAnchor constraintEqualToAnchor:_editButton.leadingAnchor constant:EditDeleteLabelLeftRightPadding]];
    [_viewConstraints addObject:[_editLabel.bottomAnchor constraintEqualToAnchor:_editButton.bottomAnchor constant:-EditDeleteLabelTopBottomPadding]];
    
    if (_editImageView != nil) {
        [_viewConstraints addObject:[_editImageView.centerYAnchor constraintEqualToAnchor:_editLabel.centerYAnchor]];
        [_viewConstraints addObject:[_editImageView.trailingAnchor constraintEqualToAnchor:_editButton.trailingAnchor constant:-EditDeleteLabelLeftRightPadding]];
    }
    
    // dividerView constraints
    CGFloat separatorHeight = 1.0 / [UIScreen mainScreen].scale;
    
    [_viewConstraints addObject:[_dividerView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor]];
    [_viewConstraints addObject:[_dividerView.heightAnchor constraintEqualToConstant:separatorHeight]];
    [_viewConstraints addObject:[_dividerView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor]];
    [_viewConstraints addObject:[_dividerView.topAnchor constraintEqualToAnchor:_editButton.bottomAnchor]];
    
    // delete button & label constraints
    [_viewConstraints addObject:[_deleteButton.topAnchor constraintEqualToAnchor:_dividerView.bottomAnchor]];
    [_viewConstraints addObject:[_deleteButton.leadingAnchor constraintEqualToAnchor:self.leadingAnchor]];
    [_viewConstraints addObject:[_deleteButton.trailingAnchor constraintEqualToAnchor:self.trailingAnchor]];
    
    [_viewConstraints addObject:[_deleteLabel.topAnchor constraintEqualToAnchor:_deleteButton.topAnchor constant:EditDeleteLabelTopBottomPadding]];
    [_viewConstraints addObject:[_deleteLabel.leadingAnchor constraintEqualToAnchor:_deleteButton.leadingAnchor constant:EditDeleteLabelLeftRightPadding]];
    [_viewConstraints addObject:[_deleteLabel.bottomAnchor constraintEqualToAnchor:_deleteButton.bottomAnchor constant:-EditDeleteLabelTopBottomPadding]];
    
    if (_deleteImageView != nil) {
        [_viewConstraints addObject:[_deleteImageView.centerYAnchor constraintEqualToAnchor:_deleteButton.centerYAnchor]];
        [_viewConstraints addObject:[_deleteImageView.trailingAnchor constraintEqualToAnchor:_deleteButton.trailingAnchor constant:-EditDeleteLabelLeftRightPadding]];
    }
    
    [_viewConstraints addObject:[self.bottomAnchor constraintEqualToAnchor:_deleteButton.bottomAnchor]];
    
    [NSLayoutConstraint activateConstraints:_viewConstraints];
}

- (void)setViewEventHandler:(ORKFamilyHistoryEditDeleteViewEventHandler)handler {
    _eventhandler = [handler copy];
}

- (void)invokeViewEventHandlerWithEvent:(ORKFamilyHistoryEditDeleteViewEvent)event {
    if (_eventhandler) {
        dispatch_async(dispatch_get_main_queue(), ^{
            _eventhandler(event);
        });
    }
}

- (void)editButtonWasPressed {
    [self invokeViewEventHandlerWithEvent:ORKFamilyHistoryEditDeleteViewEventEdit];
}

- (void)deleteButtonWasPressed {
    [self invokeViewEventHandlerWithEvent:ORKFamilyHistoryEditDeleteViewEventDelete];
}

@end


@implementation ORKFamilyHistoryRelatedPersonCell {
    UIView *_backgroundView;
    UIView *_dividerView;
    UILabel *_titleLabel;
    UILabel *_conditionsLabel;
    UIButton *_optionsButton;
    
    NSArray<UILabel *> *_detailListLabels;
    NSArray<UILabel *> *_conditionListLabels;
    
    ORKFamilyHistoryEditDeleteView *_editDeleteView;
    
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

- (void)setupSubViews {
    _backgroundView = [UIView new];
    _backgroundView.clipsToBounds = YES;
    _backgroundView.layer.cornerRadius = 12.0;
    _backgroundView.translatesAutoresizingMaskIntoConstraints = NO;
    _backgroundView.backgroundColor = [UIColor whiteColor];
    [self.contentView addSubview:_backgroundView];
    
    _titleLabel = [UILabel new];
    _titleLabel.numberOfLines = 0;
    _titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    _titleLabel.font = [self titleLabelFont];
    _titleLabel.textColor = [UIColor blackColor];
    _titleLabel.textAlignment = NSTextAlignmentLeft;
    [_backgroundView addSubview:_titleLabel];
    
    _optionsButton = [UIButton new];
    _optionsButton.translatesAutoresizingMaskIntoConstraints = NO;
    _optionsButton.backgroundColor = [UIColor clearColor];
    _optionsButton.tintColor = [UIColor systemGrayColor];
    [_optionsButton addTarget:self action:@selector(optionsButtonWasPressed) forControlEvents:UIControlEventTouchUpInside];
    
    if (@available(iOS 13.0, *)) {
        [_optionsButton setImage:[UIImage systemImageNamed:@"ellipsis.circle.fill"] forState:UIControlStateNormal];
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
    _conditionsLabel.font = [self conditionsLabelFont];
    _conditionsLabel.textColor = [UIColor blackColor];
    _conditionsLabel.textAlignment = NSTextAlignmentLeft;
    [_backgroundView addSubview:_conditionsLabel];
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
    
    // optionsButton constraints
    [_viewConstraints addObject:[_optionsButton.topAnchor constraintEqualToAnchor:_titleLabel.topAnchor]];
    [_viewConstraints addObject:[_optionsButton.trailingAnchor constraintEqualToAnchor:_backgroundView.trailingAnchor constant:-CellLeftRightPadding]];
    
    // edit delete view constraints
    if (_editDeleteView != nil) {
        [_viewConstraints addObject:[_editDeleteView.topAnchor constraintEqualToAnchor:_optionsButton.bottomAnchor constant:5.0]];
        [_viewConstraints addObject:[_editDeleteView.trailingAnchor constraintEqualToAnchor:_backgroundView.trailingAnchor]];
        [_viewConstraints addObject:[_editDeleteView.widthAnchor constraintEqualToConstant:_backgroundView.frame.size.width * 0.40]];
    }
    
    // find lower most view to constrain the dividerView to
    UIView *detailsLowerMostView = _titleLabel;
    
    _detailListLabels = [self getDetailLabels];
    
    for (UILabel *label in _detailListLabels) {
        [_backgroundView addSubview:label];
        
        [_viewConstraints addObject:[label.leadingAnchor constraintEqualToAnchor:_backgroundView.leadingAnchor constant:CellLeftRightPadding]];
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
        [_viewConstraints addObject:[label.topAnchor constraintEqualToAnchor:conditionsLowerMostView.bottomAnchor constant:CellLabelTopPadding]];

        conditionsLowerMostView = label;
    }
    
    // set backgroundView's bottom anchor to lower most UILabel
    [_viewConstraints addObject:[_backgroundView.bottomAnchor constraintEqualToAnchor:conditionsLowerMostView.bottomAnchor constant:CellTopBottomPadding]];
    
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
        label.textColor = [UIColor lightGrayColor];
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
        noneSelectedLabel.text = ORKLocalizedString(@"FAMILY_HISTORY_NONE_SELECTED", "");
        noneSelectedLabel.numberOfLines = 0;
        noneSelectedLabel.translatesAutoresizingMaskIntoConstraints = NO;
        noneSelectedLabel.lineBreakMode = NSLineBreakByWordWrapping;
        noneSelectedLabel.font = [self conditionsLabelFont];
        noneSelectedLabel.textColor = [UIColor lightGrayColor];
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
            label.textColor = [UIColor lightGrayColor];
            label.textAlignment = NSTextAlignmentLeft;
            
            [labels addObject:label];
        }
        
    }
    
    return [labels copy];
}

- (void)removeOptionsViewIfPresented {
    if (_editDeleteView != nil) {
        [_editDeleteView removeFromSuperview];
        _editDeleteView = nil;
        [self setupConstraints];
    }
}

- (void)optionsButtonWasPressed {
    if (!_editDeleteView) {
        _editDeleteView = [[ORKFamilyHistoryEditDeleteView alloc] init];
        _editDeleteView.layer.zPosition = 100;
        
        __weak typeof(self) weakSelf = self;
        [_editDeleteView setViewEventHandler:^(ORKFamilyHistoryEditDeleteViewEvent event) {
            [weakSelf handleContentViewEvent:event];
        }];
        
        [_backgroundView addSubview:_editDeleteView];
        
        [self setupConstraints];
    } else {
        [self removeOptionsViewIfPresented];
    }
    

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

- (UIFont *)conditionsLabelFont {
    UIFontDescriptor *descriptor = [UIFontDescriptor preferredFontDescriptorWithTextStyle:UIFontTextStyleSubheadline];
    UIFontDescriptor *fontDescriptor = [descriptor fontDescriptorWithSymbolicTraits:(UIFontDescriptorTraitUIOptimized)];
    return [UIFont fontWithDescriptor:fontDescriptor size:[[fontDescriptor objectForKey: UIFontDescriptorSizeAttribute] doubleValue]];
}

@end
