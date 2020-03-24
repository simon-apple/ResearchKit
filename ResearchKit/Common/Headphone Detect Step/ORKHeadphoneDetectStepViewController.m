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


#import "ORKHeadphoneDetectStepViewController.h"
#import "ORKHeadphoneDetectResult.h"
#import "ORKHeadphoneDetectStep.h"
#import "ORKHeadphoneDetector.h"
#import "ORKCheckmarkView.h"
#import "ORKCustomStepView_Internal.h"
#import "ORKInstructionStepContainerView.h"
#import "ORKInstructionStepView.h"
#import "ORKNavigationContainerView.h"
#import "ORKNavigationContainerView_Internal.h"
#import "ORKStepHeaderView_Internal.h"
#import "ORKStepContainerView_Private.h"

#import "ORKInstructionStepViewController_Internal.h"
#import "ORKStepViewController_Internal.h"
#import "ORKSkin.h"
#import "ORKHelpers_Internal.h"
#import "ORKContext.h"

static const CGFloat ORKHeadphoneImageViewDimension = 36.0;
static const CGFloat ORKHeadphoneDetectStepViewTopPadding = 37.0;
static const CGFloat ORKHeadphoneDetectStepSpacing = 12.0;
static const CGFloat ORKHeadphoneDetectCellStepSize = 40;
static const CGFloat ORKHeadphoneDetectExtraLabelsSpacing = 10.0;
static const NSTimeInterval ORKHeadphoneCellAnimationDuration = 0.2;

@interface ORKHeadphoneDetectedView : UIStackView

@property (nonatomic) BOOL connected;
@property (nonatomic) BOOL selected;

- (instancetype)initWithAirpodsPro;
- (instancetype)initWithAirpods;
- (instancetype)initWithEarpods;
- (instancetype)initWithAnyHeadphones;

- (void)anyHeadphoneDetected:(NSString *)headphoneName;

@end

@implementation ORKHeadphoneDetectedView {
    NSString *_title;
    UIImage *_image;
    
    UIImageView *_imageView;
    
    UILabel *_titleLabel;
    UILabel *_textLabel;
    
    UIView *_extraLabelsContainerView;
    UILabel *_orangeLabel;
    UIImageView *_orangeLabelImage;
    UILabel *_extraLabel;
    
    UIView *_labelContainerView;
    
    ORKCheckmarkView *_checkView;
    UIView *_checkContainerView;
}

- (instancetype)initWithTitle:(NSString *)title image:(UIImage *)image {
    self = [super init];
    if (self) {
        _title = title;
        _image = image;
        self.axis = UILayoutConstraintAxisHorizontal;
        self.distribution = UIStackViewDistributionFill;
        self.alignment = UIStackViewAlignmentTop;
        self.spacing = ORKHeadphoneDetectStepSpacing;
        self.layoutMargins = UIEdgeInsetsMake(0.0, ORKStepContainerLeftRightPaddingForWindow(self.window), 0.0, ORKStepContainerLeftRightPaddingForWindow(self.window));
        self.layoutMarginsRelativeArrangement = YES;
        [self setupImageView];
        [self setupLabelStackView];
        [self setupTitleLabel];
        [self setupTextLabel];
        [self setupCheckView];
        if ([title isEqualToString:ORKLocalizedString(@"AIRPODSPRO", nil)]) {
            [self setupOrangeLabel];
            [self setupExtraLabel];
            [self setExtraLabelsAlpha:0.0];
        }
    }
    return self;
}

- (instancetype)initWithAirpodsPro {
    return [self initWithTitle:ORKLocalizedString(@"AIRPODSPRO", nil) image:[[UIImage imageNamed:@"airpods_pro" inBundle:ORKBundle() compatibleWithTraitCollection:nil] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
}

- (instancetype)initWithAirpods {
    return [self initWithTitle:ORKLocalizedString(@"AIRPODS", nil) image:[[UIImage imageNamed:@"airpods" inBundle:ORKBundle() compatibleWithTraitCollection:nil] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
}

- (instancetype)initWithEarpods {
    return [self initWithTitle:ORKLocalizedString(@"EARPODS", nil) image:[[UIImage imageNamed:@"earpods" inBundle:ORKBundle() compatibleWithTraitCollection:nil] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
}

- (instancetype)initWithAnyHeadphones {
    return [self initWithTitle:ORKLocalizedString(@"HEADPHONES", nil) image:[[UIImage imageNamed:@"headphones" inBundle:ORKBundle() compatibleWithTraitCollection:nil] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
}

- (void)setupImageView {
    if (_image) {
        if (!_imageView) {
            _imageView = [UIImageView new];
        }
        if (@available(iOS 13.0, *)) {
            _imageView.tintColor = UIColor.labelColor;
        }
        _imageView.image = _image;
        _imageView.translatesAutoresizingMaskIntoConstraints = NO;
        [[_imageView.widthAnchor constraintEqualToConstant:ORKHeadphoneImageViewDimension] setActive:YES];
        [[_imageView.heightAnchor constraintEqualToConstant:ORKHeadphoneImageViewDimension] setActive:YES];
        [self addArrangedSubview:_imageView];
    }
}

- (void)setupLabelStackView {
    if (!_labelContainerView) {
        _labelContainerView = [UIView new];
    }
    _labelContainerView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addArrangedSubview:_labelContainerView];
    [[_labelContainerView.heightAnchor constraintEqualToConstant:ORKHeadphoneDetectCellStepSize] setActive:YES];
}

- (void)setupTitleLabel {
    if (!_titleLabel) {
        _titleLabel = [UILabel new];
    }
    _titleLabel.text = _title;
    _titleLabel.numberOfLines = 0;
    _titleLabel.font = [self bodyTitleFontBold];
    _titleLabel.textAlignment = NSTextAlignmentLeft;
    _titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [_labelContainerView addSubview:_titleLabel];
    
    [[_titleLabel.leadingAnchor constraintEqualToAnchor:_labelContainerView.leadingAnchor] setActive:YES];
    [[_titleLabel.bottomAnchor constraintEqualToAnchor:_labelContainerView.centerYAnchor] setActive:YES];

}

- (void)setupTextLabel {
    if (!_textLabel) {
        _textLabel = [UILabel new];
    }
    _textLabel.text = _connected ? ORKLocalizedString(@"CONNECTED", nil) : ORKLocalizedString(@"NOT_CONNECTED", nil);
    _textLabel.textColor = UIColor.systemGrayColor;
    _textLabel.font = [self bodyTextFont];
    _textLabel.textAlignment = NSTextAlignmentLeft;
    _textLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [_labelContainerView addSubview:_textLabel];
    
    [[_textLabel.leadingAnchor constraintEqualToAnchor:_labelContainerView.leadingAnchor] setActive:YES];
    [[_textLabel.topAnchor constraintEqualToAnchor:_labelContainerView.centerYAnchor] setActive:YES];
}

- (void)setupOrangeLabel {
    if (!_extraLabelsContainerView) {
        _extraLabelsContainerView =  [UIView new];
    }
    if (!_orangeLabel) {
        _orangeLabel = [UILabel new];
    }
    if (@available(iOS 13.0, *)) {
        UIImageConfiguration *configuration = [UIImageSymbolConfiguration configurationWithFont:[UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline] scale:UIImageSymbolScaleDefault];
        UIImage *exclamation = [[UIImage systemImageNamed:@"exclamationmark.circle.fill" withConfiguration:configuration] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        _orangeLabelImage = [[UIImageView alloc] initWithImage: exclamation];
        _orangeLabelImage.tintColor = UIColor.systemOrangeColor;
    }
    [_orangeLabelImage sizeToFit];
    _orangeLabelImage.translatesAutoresizingMaskIntoConstraints = NO;
    _orangeLabel.text = ORKLocalizedString(@"NOISE_CANCELLATION_REQUIRED", nil);
    _orangeLabel.numberOfLines = 0;
    _orangeLabel.textColor = UIColor.systemOrangeColor;
    _orangeLabel.font = [self subheadlineFontBold];
    _orangeLabel.textAlignment = NSTextAlignmentLeft;
    _orangeLabel.translatesAutoresizingMaskIntoConstraints = NO;
    
    _extraLabelsContainerView.translatesAutoresizingMaskIntoConstraints = NO;
    [_extraLabelsContainerView addSubview:_orangeLabelImage];
    [_extraLabelsContainerView addSubview:_orangeLabel];
    
    [[_orangeLabelImage.topAnchor constraintEqualToAnchor:_extraLabelsContainerView.topAnchor] setActive:YES];
    [[_orangeLabelImage.leadingAnchor constraintEqualToAnchor:_extraLabelsContainerView.leadingAnchor] setActive:YES];
    
    [[_orangeLabel.topAnchor constraintEqualToAnchor:_extraLabelsContainerView.topAnchor] setActive:YES];
    [[_orangeLabel.leadingAnchor constraintEqualToAnchor:_orangeLabelImage.trailingAnchor constant:ORKHeadphoneDetectExtraLabelsSpacing * 0.5] setActive:YES];
    [[_orangeLabel.trailingAnchor constraintEqualToAnchor:_extraLabelsContainerView.trailingAnchor constant: -ORKHeadphoneDetectStepSpacing] setActive:YES];
    
    [_labelContainerView addSubview:_extraLabelsContainerView];
    
    [[_extraLabelsContainerView.leadingAnchor constraintEqualToAnchor:_labelContainerView.leadingAnchor] setActive:YES];
    [[_extraLabelsContainerView.topAnchor constraintEqualToAnchor:_textLabel.bottomAnchor constant:ORKHeadphoneDetectExtraLabelsSpacing] setActive:YES];
    [[_extraLabelsContainerView.trailingAnchor constraintEqualToAnchor:_checkContainerView.leadingAnchor constant:ORKHeadphoneDetectStepSpacing] setActive:YES];

}

- (void)setupExtraLabel {
    if (!_extraLabel) {
        _extraLabel = [UILabel new];
    }
    _extraLabel.text = ORKLocalizedString(@"NOISE_CANCELLATION_EXPLANATION", nil);
    _extraLabel.numberOfLines = 0;
    _extraLabel.textColor = UIColor.systemGrayColor;
    _extraLabel.font = [self footnoteFont];
    _extraLabel.textAlignment = NSTextAlignmentLeft;
    _extraLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [_extraLabelsContainerView addSubview:_extraLabel];
    
    [[_extraLabel.leadingAnchor constraintEqualToAnchor:_extraLabelsContainerView.leadingAnchor] setActive:YES];
    [[_extraLabel.trailingAnchor constraintEqualToAnchor:_extraLabelsContainerView.trailingAnchor constant: -ORKHeadphoneDetectStepSpacing] setActive:YES];
    [[_extraLabel.topAnchor constraintEqualToAnchor:_orangeLabel.bottomAnchor constant:ORKHeadphoneDetectExtraLabelsSpacing] setActive:YES];
    [[_extraLabel.bottomAnchor constraintEqualToAnchor:_extraLabelsContainerView.bottomAnchor] setActive:YES];
}

- (UIFont *)footnoteFont {
    UIFontDescriptor *descriptor = [UIFontDescriptor preferredFontDescriptorWithTextStyle:UIFontTextStyleCallout];
    return [UIFont fontWithDescriptor:descriptor size:[[descriptor objectForKey: UIFontDescriptorSizeAttribute] doubleValue]];
}

- (UIFont *)subheadlineFontBold {
    UIFontDescriptor *descriptor = [UIFontDescriptor preferredFontDescriptorWithTextStyle:UIFontTextStyleSubheadline];
    UIFontDescriptor *fontDescriptor = [descriptor fontDescriptorWithSymbolicTraits:(UIFontDescriptorTraitBold)];
    return [UIFont fontWithDescriptor:fontDescriptor size:[[fontDescriptor objectForKey: UIFontDescriptorSizeAttribute] doubleValue]];
}

- (UIFont *)bodyTitleFontBold {
    UIFontDescriptor *descriptor = [UIFontDescriptor preferredFontDescriptorWithTextStyle:UIFontTextStyleBody];
    UIFontDescriptor *fontDescriptor = [descriptor fontDescriptorWithSymbolicTraits:(UIFontDescriptorTraitBold)];
    return [UIFont fontWithDescriptor:fontDescriptor size:[[fontDescriptor objectForKey: UIFontDescriptorSizeAttribute] doubleValue]];
}

- (UIFont *)bodyTextFont {
    UIFontDescriptor *descriptor = [UIFontDescriptor preferredFontDescriptorWithTextStyle:UIFontTextStyleBody];
    return [UIFont fontWithDescriptor:descriptor size:[[descriptor objectForKey: UIFontDescriptorSizeAttribute] doubleValue]];
}

- (void)setupCheckView {
    if (!_checkContainerView) {
        _checkContainerView = [UIView new];
    }
    if (!_checkView) {
        _checkView = [[ORKCheckmarkView alloc] initWithDefaultsWithoutCircle];
    }
    [_checkView setChecked:NO];
    _checkView.translatesAutoresizingMaskIntoConstraints = NO;
    [_checkContainerView addSubview:_checkView];
    [[_checkView.centerYAnchor constraintEqualToAnchor:_checkContainerView.centerYAnchor] setActive:YES];
    _checkContainerView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addArrangedSubview:_checkContainerView];
    [[_checkContainerView.widthAnchor constraintEqualToConstant:CheckmarkViewDimension] setActive:YES];
    [[_checkContainerView.heightAnchor constraintEqualToConstant:ORKHeadphoneDetectCellStepSize] setActive:YES];
}

- (void)updateCheckView {
    if (_checkView) {
        [_checkView setChecked:_selected];
    }
}

- (void)setExtraLabelsAlpha:(CGFloat) alpha {
    _extraLabelsContainerView.alpha = alpha;
}

- (void)setSelected:(BOOL)selected {
    _selected = selected;
    [self updateCheckView];
}

- (void)setConnected:(BOOL)connected {
    _connected = connected;
    _textLabel.text = _connected ? ORKLocalizedString(@"CONNECTED", nil) : ORKLocalizedString(@"NOT_CONNECTED", nil);
}

- (void)anyHeadphoneDetected:(NSString * _Nullable)headphoneName
{
    if (!_textLabel) { return; }
    
    if (headphoneName)
    {
        [_textLabel setText:[NSString localizedStringWithFormat:ORKLocalizedString(@"HEADPHONE_CONNECTED_%@", nil),headphoneName]];
    }
    else
    {
        [_textLabel setText:ORKLocalizedString(@"CONNECTED", nil)];
    }
}

- (CGFloat)extraLabelsContentSize {
    CGFloat containerHeight = ORKHeadphoneDetectCellStepSize;
    if (_orangeLabel != nil && _extraLabel != nil) {
        containerHeight = containerHeight + ORKExpectedLabelHeight(_orangeLabel) + 2 * ORKHeadphoneDetectStepSpacing + ORKExpectedLabelHeight(_extraLabel);
    }
    
    return containerHeight;
}

@end

typedef NS_ENUM(NSInteger, ORKHeadphoneDetected) {
    
    /** None */
    ORKHeadphoneDetectedNone=0,
    
    /** Airpods */
    ORKHeadphoneDetectedAirpods,
    
    /** Airpods Pro */
    ORKHeadphoneDetectedAirpodsPro,
    
    /** Earpods */
    ORKHeadphoneDetectedEarpods,
    
    /** Unknown*/
    ORKHeadphoneDetectedUnknown
    
} ORK_ENUM_AVAILABLE;

@interface ORKHeadphoneDetectStepView : ORKActiveStepCustomView

- (instancetype)initWithHeadphonesSupported;
- (instancetype)initWithHeadphonesAny;
@property (nonatomic) ORKHeadphoneDetected headphoneDetected;

@end

@implementation ORKHeadphoneDetectStepView {
    UIStackView *_stackView;
    ORKHeadphoneDetectedView *_airpodSupportView;
    ORKHeadphoneDetectedView *_airpodProSupportView;
    ORKHeadphoneDetectedView *_earpodSupportView;
    ORKHeadphoneDetectedView *_anyHeadphoneView;
    
    ORKHeadphoneTypes _headphoneTypes;
    
    NSLayoutConstraint *_airpodsProCellHeightConstraint;
}
- (instancetype)initWithHeadphoneTypes:(ORKHeadphoneTypes)headphoneTypes {
    self = [super init];
    if (self) {
        _headphoneTypes = headphoneTypes;
        [self setupStackView];
        if (headphoneTypes == ORKHeadphoneTypesSupported) {
            _airpodProSupportView.selected = NO;
            _airpodProSupportView.connected = NO;
            _airpodSupportView.selected = NO;
            _airpodSupportView.connected = NO;
            _earpodSupportView.selected = NO;
            _earpodSupportView.connected = NO;
        } else if (headphoneTypes == ORKHeadphoneTypesAny) {
            _anyHeadphoneView.selected = NO;
            [_anyHeadphoneView anyHeadphoneDetected:ORKLocalizedString(@"HEADPHONES_NONE", nil)];
        }
    }
    return self;
}

- (instancetype)initWithHeadphonesSupported {
    return [self initWithHeadphoneTypes:ORKHeadphoneTypesSupported];
}

- (instancetype)initWithHeadphonesAny {
    return [self initWithHeadphoneTypes:ORKHeadphoneTypesAny];
}

- (void)setupStackView {
    if (!_stackView) {
        _stackView = [UIStackView new];
    }
    _stackView.axis = UILayoutConstraintAxisVertical;
    _stackView.spacing = ORKHeadphoneDetectStepSpacing;
    _stackView.distribution = UIStackViewDistributionFill;
    _stackView.alignment = UIStackViewAlignmentTrailing;
    
    _stackView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:_stackView];
    [[_stackView.topAnchor constraintEqualToAnchor:self.topAnchor constant:ORKHeadphoneDetectStepViewTopPadding] setActive:YES];
    [[_stackView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor] setActive:YES];
    [[_stackView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor] setActive:YES];
    [[_stackView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor] setActive:YES];
    if (_headphoneTypes == ORKHeadphoneTypesSupported) {
        [self addSupportedHeadphonesDetectedViews];
    }
    else {
        [self addAnyHeadphoneDetectedView];
    }
}

- (void)addSupportedHeadphonesDetectedViews {
    UIView *hr1 = [self horizontalRuleView];
    [_stackView addArrangedSubview:hr1];
    [[hr1.leadingAnchor constraintEqualToAnchor:_stackView.leadingAnchor] setActive:YES];
    [self setupAirpodProView];
    
    UIView *hr2 = [self horizontalRuleView];
    [_stackView addArrangedSubview:hr2];
    [[hr2.leadingAnchor constraintEqualToAnchor:_stackView.leadingAnchor constant:3*ORKHeadphoneDetectStepSpacing+ORKHeadphoneImageViewDimension] setActive:YES];
    [self setupAirpodView];
    
    UIView *hr3 = [self horizontalRuleView];
    [_stackView addArrangedSubview:hr3];
    [[hr3.leadingAnchor constraintEqualToAnchor:_stackView.leadingAnchor constant:3*ORKHeadphoneDetectStepSpacing+ORKHeadphoneImageViewDimension] setActive:YES];
    [self setupEarpodView];
    
    UIView *hr4 = [self horizontalRuleView];
    [_stackView addArrangedSubview:hr4];
    [[hr4.leadingAnchor constraintEqualToAnchor:_stackView.leadingAnchor] setActive:YES];
}

- (void)addAnyHeadphoneDetectedView {
    [_stackView addArrangedSubview:[self horizontalRuleView]];
    [self setupAnyHeadphoneView];
    [_stackView addArrangedSubview:[self horizontalRuleView]];
}

- (UIView *)horizontalRuleView {
    UIView *separator = [UIView new];
    separator.translatesAutoresizingMaskIntoConstraints = NO;
    if (@available(iOS 13.0, *)) {
        separator.backgroundColor = UIColor.separatorColor;
    } else {
        separator.backgroundColor = UIColor.lightGrayColor;
    }
    [separator.heightAnchor constraintEqualToConstant:1.0 / [UIScreen mainScreen].scale].active = YES;
    return separator;
}

- (void)setupAirpodProView {
    if (!_airpodProSupportView) {
        _airpodProSupportView = [[ORKHeadphoneDetectedView alloc] initWithAirpodsPro];
    }
    _airpodProSupportView.translatesAutoresizingMaskIntoConstraints = NO;
    [_stackView addArrangedSubview:_airpodProSupportView];
    [[_airpodProSupportView.leadingAnchor constraintEqualToAnchor:_stackView.leadingAnchor] setActive:YES];
    _airpodsProCellHeightConstraint = [_airpodProSupportView.heightAnchor constraintEqualToConstant: ORKHeadphoneDetectCellStepSize];
    [_airpodProSupportView addConstraint:_airpodsProCellHeightConstraint];
    _airpodsProCellHeightConstraint.active = YES;
}

- (void)setupAirpodView {
    if (!_airpodSupportView) {
        _airpodSupportView = [[ORKHeadphoneDetectedView alloc] initWithAirpods];
    }
    _airpodSupportView.translatesAutoresizingMaskIntoConstraints = NO;
    [_stackView addArrangedSubview:_airpodSupportView];
    [[_airpodSupportView.leadingAnchor constraintEqualToAnchor:_stackView.leadingAnchor] setActive:YES];
    [[_airpodSupportView.heightAnchor constraintEqualToConstant:ORKHeadphoneDetectCellStepSize] setActive:YES];
}

- (void)setupEarpodView {
    if (!_earpodSupportView) {
        _earpodSupportView = [[ORKHeadphoneDetectedView alloc] initWithEarpods];
    }
    _earpodSupportView.translatesAutoresizingMaskIntoConstraints = NO;
    [_stackView addArrangedSubview:_earpodSupportView];
    [[_earpodSupportView.leadingAnchor constraintEqualToAnchor:_stackView.leadingAnchor] setActive:YES];
    [[_earpodSupportView.heightAnchor constraintEqualToConstant:ORKHeadphoneDetectCellStepSize] setActive:YES];
}

- (void)setupAnyHeadphoneView {
    if (!_anyHeadphoneView) {
        _anyHeadphoneView = [[ORKHeadphoneDetectedView alloc] initWithAnyHeadphones];
    }
    _anyHeadphoneView.translatesAutoresizingMaskIntoConstraints = NO;
    [_stackView addArrangedSubview:_anyHeadphoneView];
    [[_anyHeadphoneView.leadingAnchor constraintEqualToAnchor:_stackView.leadingAnchor] setActive:YES];
    [[_anyHeadphoneView.heightAnchor constraintEqualToConstant:ORKHeadphoneDetectCellStepSize] setActive:YES];
}

- (void)setHeadphoneDetected:(ORKHeadphoneDetected)headphoneDetected {
    _headphoneDetected = headphoneDetected;
    [self updateAppearanceWithExpandedCell:NO];
}

- (void)updateAppearanceWithExpandedCell:(BOOL)isExpanded {
    switch (_headphoneTypes) {
        case ORKHeadphoneTypesSupported:
            switch (_headphoneDetected) {
                case ORKHeadphoneDetectedAirpods:
                    _airpodSupportView.selected = YES;
                    _airpodSupportView.connected = YES;
                    _earpodSupportView.selected = NO;
                    _airpodProSupportView.selected = NO;
                    break;
                case ORKHeadphoneDetectedAirpodsPro:
                    _airpodProSupportView.selected = YES;
                    _airpodProSupportView.connected = YES;
                    _earpodSupportView.selected = NO;
                    _airpodSupportView.selected = NO;
                    break;
                case ORKHeadphoneDetectedEarpods:
                    _earpodSupportView.selected = YES;
                    _earpodSupportView.connected = YES;
                    _airpodProSupportView.selected = NO;
                    _airpodSupportView.selected = NO;
                    break;
                default:
                    _airpodProSupportView.selected = NO;
                    _airpodProSupportView.connected = NO;
                    _airpodSupportView.selected = NO;
                    _airpodSupportView.connected = NO;
                    _earpodSupportView.selected = NO;
                    _earpodSupportView.connected = NO;
                    break;
            }
            break;
            
        case ORKHeadphoneTypesAny:
            switch (_headphoneDetected) {
                case ORKHeadphoneDetectedAirpods:
                    _anyHeadphoneView.selected = YES;
                    [_anyHeadphoneView anyHeadphoneDetected:ORKLocalizedString(@"AIRPODS", nil)];
                    break;
                case ORKHeadphoneDetectedAirpodsPro:
                    _anyHeadphoneView.selected = YES;
                    [_anyHeadphoneView anyHeadphoneDetected:ORKLocalizedString(@"AIRPODSPRO", nil)];
                    break;
                case ORKHeadphoneDetectedEarpods:
                    _anyHeadphoneView.selected = YES;
                    [_anyHeadphoneView anyHeadphoneDetected:ORKLocalizedString(@"EARPODS", nil)];
                    break;
                case ORKHeadphoneDetectedUnknown:
                    _anyHeadphoneView.selected = YES;
                    [_anyHeadphoneView anyHeadphoneDetected:nil];
                    break;
                case ORKHeadphoneDetectedNone:
                    _anyHeadphoneView.selected = NO;
                    [_anyHeadphoneView anyHeadphoneDetected:ORKLocalizedString(@"HEADPHONES_NONE", nil)];
                    break;
            }
            break;
    }
    [self setAirpodProCellExpanded: isExpanded];
}

- (void)setAirpodProCellExpanded:(BOOL)expanded {
    [UIView animateWithDuration: ORKHeadphoneCellAnimationDuration animations:^{
        [_airpodProSupportView setExtraLabelsAlpha: expanded ? 1.0 : 0.0];
        _airpodsProCellHeightConstraint.constant = expanded ? [_airpodProSupportView extraLabelsContentSize] : ORKHeadphoneDetectCellStepSize;
        [self layoutIfNeeded];
    }];
}

@end

@implementation ORKHeadphoneDetectStepViewController {
    ORKHeadphoneDetectStepView *_headphoneDetectStepView;
    ORKHeadphoneDetector * _headphoneDetector;
    ORKHeadphoneTypeIdentifier _lastDetectedHeadphoneType;
    ORKBluetoothMode _lastDetectedBluetoothMode;
}

- (ORKHeadphoneDetectStep *)detectStep {
    return (ORKHeadphoneDetectStep *)[self step];
}

- (void)stepDidChange {
    [super stepDidChange];
    
    _headphoneDetectStepView = [self detectStep].headphoneTypes == ORKHeadphoneTypesSupported ? [[ORKHeadphoneDetectStepView alloc] initWithHeadphonesSupported] : [[ORKHeadphoneDetectStepView alloc] initWithHeadphonesAny];

    self.stepView.customContentFillsAvailableSpace = NO;
    self.stepView.customContentView = _headphoneDetectStepView;
    [self.stepView removeCustomContentPadding];
}

- (void)noHeadphonesButtonPressed:(id)sender
{
    if ([self.step.context isKindOfClass:[ORKSpeechInNoisePredefinedTaskContext class]])
    {
        [(ORKSpeechInNoisePredefinedTaskContext *)self.step.context didSkipHeadphoneDetectionStepForTask:self.step.task];
    }
    
    [self goToEnd:sender];
}

- (void)goToEnd:(id)sender {
    [[self taskViewController] flipToLastPage];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.stepView.navigationFooterView.optional = YES;
    self.stepView.navigationFooterView.continueEnabled = NO;
}

- (void)setContinueButtonItem:(UIBarButtonItem *)continueButtonItem
{
    [super setContinueButtonItem:continueButtonItem];
    
    if ([self.step.context isKindOfClass:[ORKSpeechInNoisePredefinedTaskContext class]])
    {
        continueButtonItem.title = ORKLocalizedString(@"SPEECH_IN_NOISE_PREDEFINED_HEADPHONES_DETECT_CONTINUE", nil);
    }
}

- (void)setSkipButtonItem:(UIBarButtonItem *)skipButtonItem
{
    [super setSkipButtonItem:skipButtonItem];
    
    if ([self.step.context isKindOfClass:[ORKSpeechInNoisePredefinedTaskContext class]])
    {
        [skipButtonItem setTitle:ORKLocalizedString(@"SPEECH_IN_NOISE_PREDEFINED_HEADPHONES_DETECT_SKIP", nil)];
        skipButtonItem.target = self;
        skipButtonItem.action = @selector(noHeadphonesButtonPressed:);
    }
    else
    {
        [skipButtonItem setTitle:ORKLocalizedString(@"SKIP_TO_END_TEXT", nil)];
        skipButtonItem.target = self;
        skipButtonItem.action = @selector(goToEnd:);
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    _headphoneDetector = [[ORKHeadphoneDetector alloc] initWithDelegate:self supportedHeadphoneChipsetTypes:[[self detectStep] supportedHeadphoneChipsetTypes]];
}

- (ORKStepResult *)result {
    ORKStepResult *sResult = [super result];
    
    NSMutableArray *results = [NSMutableArray arrayWithArray:sResult.results];
    
    ORKHeadphoneDetectResult *headphoneResult = [[ORKHeadphoneDetectResult alloc] initWithIdentifier:self.step.identifier];
    
    headphoneResult.headphoneType = _lastDetectedHeadphoneType;
    
    [results addObject:headphoneResult];
    
    sResult.results = [results copy];
    
    return sResult;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    _headphoneDetector.delegate = nil;
    _headphoneDetector = nil;
}

# pragma mark OKHeadphoneDetectorDelegate

- (void)headphoneTypeDetected:(ORKHeadphoneTypeIdentifier)headphoneType isSupported:(BOOL)isSupported {
    if (isSupported) {
        _lastDetectedHeadphoneType = headphoneType;
        if ([headphoneType isEqualToString:ORKHeadphoneTypeIdentifierAirPods]) {
            _headphoneDetectStepView.headphoneDetected = ORKHeadphoneDetectedAirpods;
        } else if ([headphoneType isEqualToString:ORKHeadphoneTypeIdentifierAirPodsPro]) {
            _lastDetectedBluetoothMode = ORKBluetoothModeNone;
            _headphoneDetectStepView.headphoneDetected = ORKHeadphoneDetectedAirpodsPro;
        } else if ([headphoneType isEqualToString:ORKHeadphoneTypeIdentifierEarPods] ) {
            _headphoneDetectStepView.headphoneDetected = ORKHeadphoneDetectedEarpods;
        } else {
            _headphoneDetectStepView.headphoneDetected = ORKHeadphoneDetectedUnknown;
        }
    } else {
        _lastDetectedHeadphoneType = nil;
        _headphoneDetectStepView.headphoneDetected = ORKHeadphoneDetectedNone;
    }
    self.stepView.navigationFooterView.continueEnabled = isSupported && (_lastDetectedHeadphoneType != ORKHeadphoneTypeIdentifierAirPodsPro);
}

- (void)bluetoothModeChanged:(ORKBluetoothMode)bluetoothMode {
    if (_lastDetectedBluetoothMode != bluetoothMode && [_lastDetectedHeadphoneType isEqualToString:ORKHeadphoneTypeIdentifierAirPodsPro]) {
        _lastDetectedBluetoothMode = bluetoothMode;
        BOOL isNoiseCancellingEnabled = (bluetoothMode == ORKBluetoothModeNoiseCancellation);
        [_headphoneDetectStepView updateAppearanceWithExpandedCell: !isNoiseCancellingEnabled];
        self.stepView.navigationFooterView.continueEnabled = isNoiseCancellingEnabled;
    }
}

- (void)podLowBatteryLevelDetected {
    _headphoneDetector.delegate = nil;
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertController *alertController = [UIAlertController
                                              alertControllerWithTitle:ORKLocalizedString(@"dBHL_ALERT_TITLE2_TEST_INTERRUPTED", nil)
                                              message:ORKLocalizedString(@"dBHL_POD_LOW_LEVEL_ALERT_TEXT", nil)
                                              preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *startOver = [UIAlertAction
                                    actionWithTitle:ORKLocalizedString(@"dBHL_ALERT_TITLE_START_OVER", nil)
                                    style:UIAlertActionStyleDefault
                                    handler:^(UIAlertAction *action) {
            [[self taskViewController] flipToFirstPage];
        }];
        [alertController addAction:startOver];
        [alertController addAction:[UIAlertAction
                                    actionWithTitle:ORKLocalizedString(@"dBHL_ALERT_TITLE_CANCEL_TEST", nil)
                                    style:UIAlertActionStyleDefault
                                    handler:^(UIAlertAction *action) {
            ORKStrongTypeOf(self.taskViewController.delegate) strongDelegate = self.taskViewController.delegate;
            if ([strongDelegate respondsToSelector:@selector(taskViewController:didFinishWithReason:error:)]) {
                [strongDelegate taskViewController:self.taskViewController didFinishWithReason:ORKTaskViewControllerFinishReasonDiscarded error:nil];
            }
        }]];
        alertController.preferredAction = startOver;
        [self presentViewController:alertController animated:YES completion:nil];
    });
}

@end

