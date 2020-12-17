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
#import "ORKdBHLToneAudiometryCompletionStep.h"

#import "ORKInstructionStepViewController_Internal.h"
#import "ORKStepViewController_Internal.h"
#import "ORKSkin.h"
#import "ORKHelpers_Internal.h"
#import "ORKContext.h"
#import "ORKTaskViewController_Internal.h"

static const CGFloat ORKHeadphoneImageViewDimension = 36.0;
static const CGFloat ORKHeadphoneDetectStepSpacing = 12.0;
static const CGFloat ORKHeadphoneDetectCellStepSize = 40;
static const CGFloat ORKHeadphoneDetectExtraLabelsSpacing = 10.0;
static const NSTimeInterval ORKHeadphoneCellAnimationDuration = 0.2;

@interface ORKHeadphoneDetectedView : UIStackView

@property (nonatomic) BOOL connected;
@property (nonatomic) BOOL selected;

- (instancetype)initWithAirpodsMax;
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
        if ([title isEqualToString:ORKLocalizedString(@"AIRPODSPRO", nil)] ||
            [title isEqualToString:ORKLocalizedString(@"AIRPODSMAX", nil)]) {
            [self setupOrangeLabel];
            [self setupExtraLabel];
            [self setExtraLabelsAlpha:0.0];
        }
        
        [self updateAccessibilityElements];
    }
    return self;
}

- (instancetype)initWithAirpodsMax {
    return [self initWithTitle:ORKLocalizedString(@"AIRPODSMAX", nil) image:[[UIImage imageNamed:@"airpods_max" inBundle:ORKBundle() compatibleWithTraitCollection:nil] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
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
    if ([_title isEqualToString:ORKLocalizedString(@"AIRPODSPRO", nil)]) {
        _extraLabel.text = ORKLocalizedString(@"NOISE_CANCELLATION_EXPLANATION_AIRPODSPRO", nil);
    } else {
        _extraLabel.text = ORKLocalizedString(@"NOISE_CANCELLATION_EXPLANATION_AIRPODSMAX", nil);
    }
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

- (void)updateAccessibilityElements {
    
    BOOL isShowingExtraLabels = _extraLabelsContainerView.alpha > 0;
    
    // Default (_titleLabel)
    NSMutableArray *mutableAccessibilityElements = [[NSMutableArray alloc] initWithObjects:_titleLabel, nil];
    
    if (isShowingExtraLabels)
    {
        if (_orangeLabel) {
            [mutableAccessibilityElements addObject:_orangeLabel];
        }
        
        if (_extraLabel) {
            [mutableAccessibilityElements addObject:_extraLabel];
        }
    }
    
    
    NSString *titleAndTextAccessibilityLabel = [NSString stringWithFormat:@"%@ %@", _titleLabel.text, _textLabel.text];
    _titleLabel.accessibilityLabel = titleAndTextAccessibilityLabel;
    
    self.accessibilityElements = (NSArray *)[mutableAccessibilityElements copy];
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
    
    [self updateAccessibilityElements];
}

- (void)setSelected:(BOOL)selected {
    _selected = selected;
    [self updateCheckView];
}

- (void)setConnected:(BOOL)connected {
    _connected = connected;
    _textLabel.text = _connected ? ORKLocalizedString(@"CONNECTED", nil) : ORKLocalizedString(@"NOT_CONNECTED", nil);
    
    [self updateAccessibilityElements];
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
    
    [self updateAccessibilityElements];
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
    
    /** Airpods Generation 1 */
    ORKHeadphoneDetectedAirpodsGen1,
    
    /** Airpods Generation 2 */
    ORKHeadphoneDetectedAirpodsGen2,
    
    /** Airpods Pro */
    ORKHeadphoneDetectedAirpodsPro,
    
    /** Airpods Max */
    ORKHeadphoneDetectedAirpodsMax,
    
    /** Earpods */
    ORKHeadphoneDetectedEarpods,
    
    /** Unknown*/
    ORKHeadphoneDetectedUnknown
    
} ORK_ENUM_AVAILABLE;

@interface ORKHeadphoneDetectStepView : UIStackView

- (instancetype)initWithHeadphonesSupported;
- (instancetype)initWithHeadphonesAny;
- (void)hideBottomAlert:(BOOL)isHidden;
@property (nonatomic) ORKHeadphoneDetected headphoneDetected;

@end

@implementation ORKHeadphoneDetectStepView {
    ORKHeadphoneDetectedView *_airpodSupportView;
    ORKHeadphoneDetectedView *_airpodProSupportView;
    ORKHeadphoneDetectedView *_airpodMaxSupportView;
    ORKHeadphoneDetectedView *_earpodSupportView;
    ORKHeadphoneDetectedView *_anyHeadphoneView;
    
    ORKHeadphoneTypes _headphoneTypes;
    
    UILabel *_bottomAlertLabel;
    
    NSLayoutConstraint *_airpodsProCellHeightConstraint;
    NSLayoutConstraint *_airpodsMaxCellHeightConstraint;
}
- (instancetype)initWithHeadphoneTypes:(ORKHeadphoneTypes)headphoneTypes {
    self = [super init];
    if (self) {
        _headphoneTypes = headphoneTypes;
        [self setupView];
        if (headphoneTypes == ORKHeadphoneTypesSupported) {
            _airpodProSupportView.selected = NO;
            _airpodProSupportView.connected = NO;
            _airpodSupportView.selected = NO;
            _airpodSupportView.connected = NO;
            _airpodMaxSupportView.selected = NO;
            _airpodMaxSupportView.connected = NO;
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

- (void)setupView {
    self.axis = UILayoutConstraintAxisVertical;
    self.spacing = ORKHeadphoneDetectStepSpacing;
    self.distribution = UIStackViewDistributionFill;
    self.alignment = UIStackViewAlignmentTrailing;
    
    self.translatesAutoresizingMaskIntoConstraints = NO;
    
    if (_headphoneTypes == ORKHeadphoneTypesSupported) {
        [self addSupportedHeadphonesDetectedViews];
    }
    else {
        [self addAnyHeadphoneDetectedView];
    }
    
    [self setupBottomAlertLabel];
}

- (void)setupBottomAlertLabel {
    if (!_bottomAlertLabel) {
        _bottomAlertLabel = [UILabel new];
    }
    _bottomAlertLabel.attributedText = [self getSharedAudioMessage];
    _bottomAlertLabel.numberOfLines = 0;
    _bottomAlertLabel.textAlignment = NSTextAlignmentLeft;
    _bottomAlertLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self addArrangedSubview:_bottomAlertLabel];
    
    CGFloat margin = ORKStandardHorizontalMarginForView(self);
    
    [[_bottomAlertLabel.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:margin] setActive:YES];
    
    _bottomAlertLabel.hidden = YES;
}

- (void)addSupportedHeadphonesDetectedViews {
    UIView *hr1 = [self horizontalRuleView];
    [self addArrangedSubview:hr1];
    [[hr1.leadingAnchor constraintEqualToAnchor:self.leadingAnchor] setActive:YES];
    [self setupAirpodMaxView];
    
    UIView *hr2 = [self horizontalRuleView];
    [self addArrangedSubview:hr2];
    [[hr2.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:3*ORKHeadphoneDetectStepSpacing+ORKHeadphoneImageViewDimension] setActive:YES];
    [self setupAirpodProView];
    
    UIView *hr3 = [self horizontalRuleView];
    [self addArrangedSubview:hr3];
    [[hr3.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:3*ORKHeadphoneDetectStepSpacing+ORKHeadphoneImageViewDimension] setActive:YES];
    [self setupAirpodView];

    UIView *hr4 = [self horizontalRuleView];
    [self addArrangedSubview:hr4];
    [[hr4.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:3*ORKHeadphoneDetectStepSpacing+ORKHeadphoneImageViewDimension] setActive:YES];
    [self setupEarpodView];

    UIView *hr5 = [self horizontalRuleView];
    [self addArrangedSubview:hr5];
    [[hr5.leadingAnchor constraintEqualToAnchor:self.leadingAnchor] setActive:YES];
}

- (void)addAnyHeadphoneDetectedView {
    [self addArrangedSubview:[self horizontalRuleView]];
    [self setupAnyHeadphoneView];
    [self addArrangedSubview:[self horizontalRuleView]];
}

- (NSAttributedString *)getSharedAudioMessage {
    NSMutableAttributedString *sharedAudioString = [NSMutableAttributedString new];
    
    NSArray<NSString *> *stringElements = [ORKLocalizedString(@"SHARED_AUDIO_ALERT", nil) componentsSeparatedByString:@"%@"];

    if (stringElements.count == 4) {
        NSString *title = stringElements[0];
        NSString *text1 = stringElements[1];
        NSString *text2 = stringElements[2];
        NSString *text3 = stringElements[3];
        
        UIColor *orangeColor = UIColor.systemOrangeColor;
        NSDictionary *orangeAttrs = @{ NSForegroundColorAttributeName : orangeColor };
        UIColor *grayColor = UIColor.systemGrayColor;
        NSDictionary *grayAttrs = @{ NSForegroundColorAttributeName : grayColor };
        
        NSTextAttachment *exclamationAttachment = [NSTextAttachment new];
        NSTextAttachment *airplayAttachment = [NSTextAttachment new];
        NSTextAttachment *checkmarkAttachment = [NSTextAttachment new];
        
        if (@available(iOS 13.0, *)) {
            UIImageConfiguration *configuration = [UIImageSymbolConfiguration configurationWithFont:[UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline] scale:UIImageSymbolScaleDefault];
            
            UIImage *exclamationImg = [[UIImage systemImageNamed:@"exclamationmark.circle.fill"
                                               withConfiguration:configuration] imageWithTintColor:orangeColor];
            exclamationAttachment.image = exclamationImg;
            
            UIImage *airplayImg = [[UIImage systemImageNamed:@"airplayaudio"
                                           withConfiguration:configuration] imageWithTintColor:grayColor];
            airplayAttachment.image = airplayImg;
            
            UIImage *checkmarkImg = [[UIImage systemImageNamed:@"checkmark.circle.fill"
                                             withConfiguration:configuration] imageWithTintColor:grayColor];
            checkmarkAttachment.image = checkmarkImg;
        }
        
        [sharedAudioString appendAttributedString:[self attributedEmptyLineWithSize:10]];
        
        NSString *titleString = [NSString stringWithFormat:@" %@\n", title];
        
        [sharedAudioString appendAttributedString:[NSAttributedString attributedStringWithAttachment:exclamationAttachment]];
        [sharedAudioString appendAttributedString:[[NSAttributedString alloc] initWithString:titleString attributes:orangeAttrs]];
        
        [sharedAudioString appendAttributedString:[self attributedEmptyLineWithSize:5]];
        
        [sharedAudioString appendAttributedString:[[NSAttributedString alloc] initWithString:text1 attributes:grayAttrs]];
        
        [sharedAudioString appendAttributedString:[NSAttributedString attributedStringWithAttachment:airplayAttachment]];
        [sharedAudioString appendAttributedString:[[NSAttributedString alloc] initWithString:text2 attributes:grayAttrs]];
        
        [sharedAudioString appendAttributedString:[NSAttributedString attributedStringWithAttachment:checkmarkAttachment]];
        [sharedAudioString appendAttributedString:[[NSAttributedString alloc] initWithString:text3 attributes:grayAttrs]];
        
    }

    
    return sharedAudioString;
}

- (NSAttributedString *)attributedEmptyLineWithSize:(CGFloat)lineSize {
    UIFont *font = [UIFont systemFontOfSize:lineSize];
    NSDictionary *attrs = @{ NSFontAttributeName : font };
    return [[NSAttributedString alloc] initWithString:@" \n" attributes:attrs];
}

- (void)hideBottomAlert:(BOOL)isHidden {
    [UIView animateWithDuration: ORKHeadphoneCellAnimationDuration animations:^{
        [_bottomAlertLabel setHidden:isHidden];
        [self layoutIfNeeded];
    }];
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
    [self addArrangedSubview:_airpodProSupportView];
    [[_airpodProSupportView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor] setActive:YES];
    _airpodsProCellHeightConstraint = [_airpodProSupportView.heightAnchor constraintEqualToConstant: ORKHeadphoneDetectCellStepSize];
    [_airpodProSupportView addConstraint:_airpodsProCellHeightConstraint];
    _airpodsProCellHeightConstraint.active = YES;
}

- (void)setupAirpodMaxView {
    if (!_airpodMaxSupportView) {
        _airpodMaxSupportView = [[ORKHeadphoneDetectedView alloc] initWithAirpodsMax];
    }
    _airpodMaxSupportView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addArrangedSubview:_airpodMaxSupportView];
    [[_airpodMaxSupportView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor] setActive:YES];
    _airpodsMaxCellHeightConstraint = [_airpodMaxSupportView.heightAnchor constraintEqualToConstant: ORKHeadphoneDetectCellStepSize];
    [_airpodMaxSupportView addConstraint:_airpodsMaxCellHeightConstraint];
    _airpodsMaxCellHeightConstraint.active = YES;
}

- (void)setupAirpodView {
    if (!_airpodSupportView) {
        _airpodSupportView = [[ORKHeadphoneDetectedView alloc] initWithAirpods];
    }
    _airpodSupportView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addArrangedSubview:_airpodSupportView];
    [[_airpodSupportView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor] setActive:YES];
    [[_airpodSupportView.heightAnchor constraintEqualToConstant:ORKHeadphoneDetectCellStepSize] setActive:YES];
}

- (void)setupEarpodView {
    if (!_earpodSupportView) {
        _earpodSupportView = [[ORKHeadphoneDetectedView alloc] initWithEarpods];
    }
    _earpodSupportView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addArrangedSubview:_earpodSupportView];
    [[_earpodSupportView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor] setActive:YES];
    [[_earpodSupportView.heightAnchor constraintEqualToConstant:ORKHeadphoneDetectCellStepSize] setActive:YES];
}

- (void)setupAnyHeadphoneView {
    if (!_anyHeadphoneView) {
        _anyHeadphoneView = [[ORKHeadphoneDetectedView alloc] initWithAnyHeadphones];
    }
    _anyHeadphoneView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addArrangedSubview:_anyHeadphoneView];
    [[_anyHeadphoneView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor] setActive:YES];
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
                case ORKHeadphoneDetectedAirpodsGen1:
                case ORKHeadphoneDetectedAirpodsGen2:
                    _airpodSupportView.selected = YES;
                    _airpodSupportView.connected = YES;
                    _earpodSupportView.selected = NO;
                    _airpodProSupportView.selected = NO;
                    _airpodMaxSupportView.selected = NO;
                    [self setAirpodProCellExpanded: NO];
                    [self setAirpodMaxCellExpanded: NO];
                    break;
                case ORKHeadphoneDetectedAirpodsPro:
                    _airpodProSupportView.selected = YES;
                    _airpodProSupportView.connected = YES;
                    _earpodSupportView.selected = NO;
                    _airpodSupportView.selected = NO;
                    _airpodMaxSupportView.selected = NO;
                    [self setAirpodProCellExpanded: isExpanded];
                    [self setAirpodMaxCellExpanded: NO];
                    break;
                case ORKHeadphoneDetectedAirpodsMax:
                    _airpodMaxSupportView.selected = YES;
                    _airpodMaxSupportView.connected = YES;
                    _earpodSupportView.selected = NO;
                    _airpodSupportView.selected = NO;
                    _airpodProSupportView.selected = NO;
                    [self setAirpodProCellExpanded: NO];
                    [self setAirpodMaxCellExpanded: isExpanded];
                    break;
                case ORKHeadphoneDetectedEarpods:
                    _earpodSupportView.selected = YES;
                    _earpodSupportView.connected = YES;
                    _airpodProSupportView.selected = NO;
                    _airpodSupportView.selected = NO;
                    _airpodMaxSupportView.selected = NO;
                    [self setAirpodProCellExpanded: NO];
                    [self setAirpodMaxCellExpanded: NO];
                    break;
                default:
                    _airpodProSupportView.selected = NO;
                    _airpodProSupportView.connected = NO;
                    _airpodSupportView.selected = NO;
                    _airpodSupportView.connected = NO;
                    _earpodSupportView.selected = NO;
                    _earpodSupportView.connected = NO;
                    _airpodMaxSupportView.selected = NO;
                    _airpodMaxSupportView.connected = NO;
                    [self setAirpodProCellExpanded: NO];
                    [self setAirpodMaxCellExpanded: NO];
                    break;
            }
            break;
            
        case ORKHeadphoneTypesAny:
            switch (_headphoneDetected) {
                case ORKHeadphoneDetectedAirpodsGen1:
                case ORKHeadphoneDetectedAirpodsGen2:
                    _anyHeadphoneView.selected = YES;
                    [_anyHeadphoneView anyHeadphoneDetected:ORKLocalizedString(@"AIRPODS", nil)];
                    break;
                case ORKHeadphoneDetectedAirpodsPro:
                    _anyHeadphoneView.selected = YES;
                    [_anyHeadphoneView anyHeadphoneDetected:ORKLocalizedString(@"AIRPODSPRO", nil)];
                    break;
                case ORKHeadphoneDetectedAirpodsMax:
                    _anyHeadphoneView.selected = YES;
                    [_anyHeadphoneView anyHeadphoneDetected:ORKLocalizedString(@"AIRPODSMAX", nil)];
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
}

- (void)setAirpodProCellExpanded:(BOOL)expanded {
    [UIView animateWithDuration: ORKHeadphoneCellAnimationDuration animations:^{
        [_airpodProSupportView setExtraLabelsAlpha: expanded ? 1.0 : 0.0];
        _airpodsProCellHeightConstraint.constant = expanded ? [_airpodProSupportView extraLabelsContentSize] : ORKHeadphoneDetectCellStepSize;
        [self.superview layoutIfNeeded];
    }];
}

- (void)setAirpodMaxCellExpanded:(BOOL)expanded {
    [UIView animateWithDuration: ORKHeadphoneCellAnimationDuration animations:^{
        [_airpodMaxSupportView setExtraLabelsAlpha: expanded ? 1.0 : 0.0];
        _airpodsMaxCellHeightConstraint.constant = expanded ? [_airpodMaxSupportView extraLabelsContentSize] : ORKHeadphoneDetectCellStepSize;
        [self.superview layoutIfNeeded];
    }];
}

@end

@implementation ORKHeadphoneDetectStepViewController {
    ORKHeadphoneDetectStepView *_headphoneDetectStepView;
    ORKHeadphoneDetector * _headphoneDetector;
    ORKHeadphoneTypeIdentifier _lastDetectedHeadphoneType;
    NSString * _lastDetectedVendorID;
    NSString * _lastDetectedProductID;
    NSInteger _lastDetectedDeviceSubType;
    ORKBluetoothMode _lastDetectedBluetoothMode;
    NSUInteger _wirelessSplitterNumberOfDevices;
}

- (BOOL)isDetectingAppleHeadphones {
    return [[[self detectStep] supportedHeadphoneChipsetTypes] isEqualToSet:[ORKHeadphoneDetector appleHeadphoneSet]];
}

- (ORKHeadphoneDetectStep *)detectStep {
    return (ORKHeadphoneDetectStep *)[self step];
}

- (void)stepDidChange {
    [super stepDidChange];
    
    _headphoneDetectStepView = [self detectStep].headphoneTypes == ORKHeadphoneTypesSupported ? [[ORKHeadphoneDetectStepView alloc] initWithHeadphonesSupported] : [[ORKHeadphoneDetectStepView alloc] initWithHeadphonesAny];

    _wirelessSplitterNumberOfDevices = 0;
    self.stepView.customContentFillsAvailableSpace = NO;
    self.stepView.customContentView = _headphoneDetectStepView;
    [self.stepView pinNavigationContainerToBottom];
    [self.stepView removeCustomContentPadding];
}

- (void)noHeadphonesButtonPressed:(id)sender
{
    NSString *stepIdentifier = @"";
    if ([self.step.context isKindOfClass:[ORKSpeechInNoisePredefinedTaskContext class]])
    {
        [(ORKSpeechInNoisePredefinedTaskContext *)self.step.context didSkipHeadphoneDetectionStepForTask:self.step.task];
        stepIdentifier = @"ORKSpeechInNoiseStepIdentifierHeadphonesRequired";
    }
    else if ([self isDetectingAppleHeadphones]) {
        [(ORKdBHLTaskContext *)self.step.context didSkipHeadphoneDetectionStepForTask:self.taskViewController.task];
        stepIdentifier = [ORKdBHLTaskContext dBHLToneAudiometryCompletionStepIdentifier];
    }
    
    [[self taskViewController] flipToPageWithIdentifier:stepIdentifier forward:YES animated:NO];
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
    else if ([self isDetectingAppleHeadphones]) {
        if (!self.step.context){
            self.step.context = [[ORKdBHLTaskContext alloc] init];
        }
        [skipButtonItem setTitle:ORKLocalizedString(@"DBHL_HEADPHONES_DETECT_SKIP", nil)];
        skipButtonItem.target = self;
        skipButtonItem.action = @selector(noHeadphonesButtonPressed:);
    }
}

- (void)updateAppearanceForConnectedState:(BOOL)connected {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        self.stepView.navigationFooterView.continueEnabled = connected;
        
        if ([self.step.context isKindOfClass:[ORKSpeechInNoisePredefinedTaskContext class]])
        {
            self.stepView.navigationFooterView.skipEnabled = !connected;
        }
    });
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
    headphoneResult.vendorID = _lastDetectedVendorID;
    headphoneResult.productID = _lastDetectedProductID;
    headphoneResult.deviceSubType = _lastDetectedDeviceSubType;
    
    [results addObject:headphoneResult];
    
    sResult.results = [results copy];
    
    return sResult;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_headphoneDetector discard];
    _headphoneDetector = nil;
}

# pragma mark OKHeadphoneDetectorDelegate

- (void)headphoneTypeDetected:(nonnull ORKHeadphoneTypeIdentifier)headphoneType vendorID:(nonnull NSString *)vendorID productID:(nonnull NSString *)productID deviceSubType:(NSInteger)deviceSubType isSupported:(BOOL)isSupported {
    if (isSupported) {
        _lastDetectedHeadphoneType = headphoneType;
        _lastDetectedVendorID = vendorID;
        _lastDetectedProductID = productID;
        _lastDetectedDeviceSubType = deviceSubType;
        if ([headphoneType isEqualToString:ORKHeadphoneTypeIdentifierAirPodsGen1]) {
            _headphoneDetectStepView.headphoneDetected = ORKHeadphoneDetectedAirpodsGen1;
        } else if ([headphoneType isEqualToString:ORKHeadphoneTypeIdentifierAirPodsGen2]) {
            _headphoneDetectStepView.headphoneDetected = ORKHeadphoneDetectedAirpodsGen2;
        } else if ([headphoneType isEqualToString:ORKHeadphoneTypeIdentifierAirPodsPro]) {
            _lastDetectedBluetoothMode = ORKBluetoothModeNone;
            _headphoneDetectStepView.headphoneDetected = ORKHeadphoneDetectedAirpodsPro;
        } else if ([headphoneType isEqualToString:ORKHeadphoneTypeIdentifierEarPods] ) {
            _headphoneDetectStepView.headphoneDetected = ORKHeadphoneDetectedEarpods;
        } else if ([headphoneType isEqualToString:ORKHeadphoneTypeIdentifierAirPodsMax] ) {
            _headphoneDetectStepView.headphoneDetected = ORKHeadphoneDetectedAirpodsMax;
        }  else {
            _headphoneDetectStepView.headphoneDetected = ORKHeadphoneDetectedUnknown;
        }
    } else {
        _lastDetectedHeadphoneType = nil;
        _headphoneDetectStepView.headphoneDetected = ORKHeadphoneDetectedNone;
    }
    
    BOOL isConnected = isSupported && (_lastDetectedHeadphoneType != ORKHeadphoneTypeIdentifierAirPodsPro);
    [self updateAppearanceForConnectedState:isConnected];
}

- (void)bluetoothModeChanged:(ORKBluetoothMode)bluetoothMode {
    if (_lastDetectedBluetoothMode != bluetoothMode &&
        ([_lastDetectedHeadphoneType isEqualToString:ORKHeadphoneTypeIdentifierAirPodsPro] ||
         [_lastDetectedHeadphoneType isEqualToString:ORKHeadphoneTypeIdentifierAirPodsMax])) {
        _lastDetectedBluetoothMode = bluetoothMode;
        // FIXME:- temporary workaround for <rdar://problem/62519889>
        BOOL isNoiseCancellingEnabled = (bluetoothMode == ORKBluetoothModeNoiseCancellation) || ([self detectStep].headphoneTypes == ORKHeadphoneTypesAny);
        [_headphoneDetectStepView updateAppearanceWithExpandedCell: !isNoiseCancellingEnabled];
        self.stepView.navigationFooterView.continueEnabled = isNoiseCancellingEnabled;
    }
}

- (void)podLowBatteryLevelDetected {
    _headphoneDetector.delegate = nil;
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertController *alertController = [UIAlertController
                                              alertControllerWithTitle:ORKLocalizedString(@"HEADPHONES_LOW_BATTERY_TITLE", nil)
                                              message:ORKLocalizedString(@"HEADPHONES_LOW_BATTERY_TEXT", nil)
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

- (void)wirelessSplitterMoreThanOneDeviceDetected:(BOOL)moreThanOne {
    dispatch_async(dispatch_get_main_queue(), ^{
        [_headphoneDetectStepView hideBottomAlert:!moreThanOne];
    });
}

@end

