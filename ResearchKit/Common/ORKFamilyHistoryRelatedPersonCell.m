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

static const CGFloat BackgroundViewBottomPadding = 18.0;
static const CGFloat CellLeftRightPadding = 12.0;
static const CGFloat CellTopBottomPadding = 12.0;
static const CGFloat CellBottomPadding = 8.0;
static const CGFloat CellLabelTopPadding = 8.0;
static const CGFloat CellBottomPaddingBeforeAddRelativeButton = 20.0;
static const CGFloat ContentLeftRightPadding = 16.0;
static const CGFloat DividerViewTopBottomPadding = 10.0;
static const CGFloat OptionsButtonHeightWidth = 22.0;

static const CGFloat EditViewCornerRadius = 12.0;
static const CGFloat EditViewMinWidth = 250.0;
static const CGFloat EditViewRightPadding = 8.0;
static const CGFloat EditViewRowBottomPadding = 12.0;
static const CGFloat EditViewRowLeftRightPadding = 16.0;
static const CGFloat EditViewRowTopPadding = 11.0;

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
    
    UIVisualEffectView *_blurViewLight;
    UIVisualEffectView *_blurViewDark;
    
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

- (void)layoutSubviews {
    [self updateLayer];
}

- (void)styleView {
    self.clipsToBounds = YES;
    self.layer.cornerRadius = EditViewCornerRadius;
    self.translatesAutoresizingMaskIntoConstraints = NO;
}

- (void)updateLayer {
    self.layer.borderWidth = 0.0;
    self.layer.shadowRadius = 5.0f;
    self.layer.shadowOpacity = 0.2;
    self.layer.shadowOffset = CGSizeZero;
    self.layer.masksToBounds = NO;
}

- (void)setupSubviews {
    _blurViewLight = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight]];
    _blurViewLight.clipsToBounds = YES;
    _blurViewLight.layer.cornerRadius = EditViewCornerRadius;
    _blurViewLight.frame = self.bounds;
    _blurViewLight.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
    _blurViewLight.layer.opacity = 0.0;
    [self addSubview:_blurViewLight];
    
    _blurViewDark = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
    _blurViewDark.clipsToBounds = YES;
    _blurViewDark.layer.cornerRadius = EditViewCornerRadius;
    _blurViewDark.frame = self.bounds;
    _blurViewDark.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
    _blurViewDark.layer.opacity = 0.0;
    [self addSubview:_blurViewDark];
    
    _editButton = [UIButton new];
    _editButton.translatesAutoresizingMaskIntoConstraints = NO;
    [_editButton addTarget:self action:@selector(editButtonWasPressed) forControlEvents:UIControlEventTouchUpInside];
    
    _editLabel = [UILabel new];
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
    
    [self addSubview:_dividerView];
    
    _deleteButton = [UIButton new];
    _deleteButton.translatesAutoresizingMaskIntoConstraints = NO;
    [_deleteButton addTarget:self action:@selector(deleteButtonWasPressed) forControlEvents:UIControlEventTouchUpInside];
    _deleteLabel = [UILabel new];
    _deleteLabel.textAlignment = NSTextAlignmentLeft;
    _deleteLabel.text = ORKLocalizedString(@"FAMILY_HISTORY_DELETE_ENTRY", "");
    _deleteLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [_deleteButton addSubview:_deleteLabel];
    
    if (@available(iOS 13.0, *)) {
        UIImage *deleteImage = [UIImage systemImageNamed:@"trash.fill"];
        _deleteImageView = [[UIImageView alloc] initWithImage:deleteImage];
        _deleteImageView.tintColor =  [UIColor redColor];
        _deleteImageView.backgroundColor =  [UIColor clearColor];
        _deleteImageView.translatesAutoresizingMaskIntoConstraints = NO;
        [_deleteButton addSubview:_deleteImageView];
    }
    
    [self addSubview:_deleteButton];
    [self updateViewColors];
}

- (void)updateViewColors {
    if (@available(iOS 13.0, *)) {
        self.backgroundColor = self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark ? [[UIColor systemGray6Color] colorWithAlphaComponent:0.41] : [[UIColor whiteColor] colorWithAlphaComponent:0.60];
        self.layer.borderColor = self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark ? [UIColor systemGray6Color].CGColor :  UIColor.whiteColor.CGColor;
        
        if (self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) {
            _blurViewDark.layer.opacity = 1.0;
            _blurViewLight.layer.opacity = 0.0;
        } else {
            _blurViewDark.layer.opacity = 0.0;
            _blurViewLight.layer.opacity = 1.0;
        }

        _editButton.backgroundColor = self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark ? [UIColor clearColor] : [UIColor clearColor];
        _editLabel.textColor = self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark ? [UIColor whiteColor] : [UIColor blackColor];
        _editImageView.tintColor = self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark ? [UIColor whiteColor] : [UIColor blackColor];
        _dividerView.backgroundColor = self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark ? [UIColor systemGray3Color] : [UIColor separatorColor];
        _deleteLabel.textColor = [UIColor redColor];
        _deleteImageView.image = self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark ? [UIImage systemImageNamed:@"trash"] : [UIImage systemImageNamed:@"trash.fill"];
    } else {
        _editButton.backgroundColor = [UIColor clearColor];
        _editLabel.textColor = [UIColor blackColor];
        _dividerView.backgroundColor = [UIColor lightGrayColor];
        _deleteImageView.tintColor = [UIColor redColor];
        _deleteButton.backgroundColor = [UIColor clearColor];
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
    
    // edit view width constraint
    [_viewConstraints addObject:[self.widthAnchor constraintGreaterThanOrEqualToConstant:EditViewMinWidth]];
    
    // edit button & label constraints
    [_viewConstraints addObject:[_editButton.topAnchor constraintEqualToAnchor:self.topAnchor]];
    [_viewConstraints addObject:[_editButton.leadingAnchor constraintEqualToAnchor:self.leadingAnchor]];
    [_viewConstraints addObject:[_editButton.trailingAnchor constraintEqualToAnchor:self.trailingAnchor]];
    
    [_viewConstraints addObject:[_editLabel.topAnchor constraintEqualToAnchor:_editButton.topAnchor constant:EditViewRowTopPadding]];
    [_viewConstraints addObject:[_editLabel.leadingAnchor constraintEqualToAnchor:_editButton.leadingAnchor constant:EditViewRowLeftRightPadding]];
    [_viewConstraints addObject:[_editLabel.bottomAnchor constraintEqualToAnchor:_editButton.bottomAnchor constant:-EditViewRowBottomPadding]];
    
    if (_editImageView != nil) {
        [_viewConstraints addObject:[_editImageView.centerYAnchor constraintEqualToAnchor:_editLabel.centerYAnchor]];
        [_viewConstraints addObject:[_editImageView.trailingAnchor constraintEqualToAnchor:_editButton.trailingAnchor constant:-EditViewRowLeftRightPadding]];
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
    
    [_viewConstraints addObject:[_deleteLabel.topAnchor constraintEqualToAnchor:_deleteButton.topAnchor constant:EditViewRowTopPadding]];
    [_viewConstraints addObject:[_deleteLabel.leadingAnchor constraintEqualToAnchor:_deleteButton.leadingAnchor constant:EditViewRowLeftRightPadding]];
    [_viewConstraints addObject:[_deleteLabel.bottomAnchor constraintEqualToAnchor:_deleteButton.bottomAnchor constant:-EditViewRowBottomPadding]];
    
    if (_deleteImageView != nil) {
        [_viewConstraints addObject:[_deleteImageView.centerYAnchor constraintEqualToAnchor:_deleteButton.centerYAnchor]];
        [_viewConstraints addObject:[_deleteImageView.trailingAnchor constraintEqualToAnchor:_deleteButton.trailingAnchor constant:-EditViewRowLeftRightPadding]];
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
    [_optionsButton addTarget:self action:@selector(optionsButtonWasPressed) forControlEvents:UIControlEventTouchUpInside];
    
    if (@available(iOS 13.0, *)) {
        [_optionsButton setImage:[UIImage systemImageNamed:@"ellipsis.circle"] forState:UIControlStateNormal];
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
    
    // optionsButton constraints
    [_viewConstraints addObject:[_optionsButton.topAnchor constraintEqualToAnchor:_titleLabel.topAnchor]];
    [_viewConstraints addObject:[_optionsButton.trailingAnchor constraintEqualToAnchor:_backgroundView.trailingAnchor constant:-CellLeftRightPadding]];
    [_viewConstraints addObject:[_optionsButton.widthAnchor constraintEqualToConstant:OptionsButtonHeightWidth]];
    [_viewConstraints addObject:[_optionsButton.heightAnchor constraintEqualToConstant:OptionsButtonHeightWidth]];
    
    // edit delete view constraints
    if (_editDeleteView != nil) {
        [_viewConstraints addObject:[_editDeleteView.topAnchor constraintEqualToAnchor:_optionsButton.bottomAnchor constant:5.0]];
        [_viewConstraints addObject:[_editDeleteView.trailingAnchor constraintEqualToAnchor:_backgroundView.trailingAnchor constant:-EditViewRightPadding]];
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
