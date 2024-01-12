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
// apple-internal

#import "ORKContext.h"
#import "ORKHeadphoneDetectStepViewController.h"
#import "ORKHeadphoneDetectResult.h"
#import "ORKHeadphoneDetectStep.h"
#import "ORKHeadphoneDetector.h"

#import "AAPLUtils.h"

#import <ResearchKit/ORKSkin.h>
#import <ResearchKit/ORKHelpers_Internal.h>
#import <ResearchKitUI/ORKCheckmarkView.h>
#import <ResearchKitUI/ORKCustomStepView_Internal.h>
#import <ResearchKitUI/ORKInstructionStepContainerView.h>
#import <ResearchKitUI/ORKInstructionStepViewController_Internal.h>
#import <ResearchKitUI/ORKNavigationContainerView.h>
#import <ResearchKitUI/ORKNavigationContainerView_Internal.h>
#import <ResearchKitUI/ORKStepHeaderView_Internal.h>
#import <ResearchKitUI/ORKStepViewController_Internal.h>
#import <ResearchKitUI/ORKStepContainerView_Private.h>
#import <ResearchKitUI/ORKTaskViewController_Internal.h>

#import <LocalAuthentication/LAContext.h>

#import <LocalAuthentication/LAContext.h>

#import <LocalAuthentication/LAContext.h>

#import <LocalAuthentication/LAContext.h>

static const CGFloat ORKHeadphoneImageViewDimension = 36.0;
static const CGFloat ORKHeadphoneDetectStepSpacing = 12.0;
static const CGFloat ORKHeadphoneDetectCellStepSize = 40;
static const CGFloat ORKHeadphoneDetectExtraLabelsSpacing = 10.0;
static const NSTimeInterval ORKHeadphoneCellAnimationDuration = 0.2;

static NSString *const ORKHeadphoneGlyphNameHeadphones = @"headphones";
static NSString *const ORKHeadphoneGlyphNameAirpods = @"airpods";
static NSString *const ORKHeadphoneGlyphNameAirpodsGen3 = @"airpods_gen3";
static NSString *const ORKHeadphoneGlyphNameAirpodsPro = @"airpods_pro";
static NSString *const ORKHeadphoneGlyphNameAirpodsMax = @"airpods_max";
static NSString *const ORKHeadphoneGlyphNameEarpods = @"earpods";

typedef NS_ENUM(NSInteger, ORKHeadphoneDetected) {
    
    /** Unknown*/
    ORKHeadphoneDetectedUnknown=0,
    
    /** None */
    ORKHeadphoneDetectedNone,
    
    /** Airpods Generation 1 */
    ORKHeadphoneDetectedAirpodsGen1,
    
    /** Airpods Generation 2 */
    ORKHeadphoneDetectedAirpodsGen2,
    
    /** Airpods Generation 3 */
    ORKHeadphoneDetectedAirpodsGen3,
    
    /** Airpods Pro */
    ORKHeadphoneDetectedAirpodsPro,
    
    /** Airpods Pro Generation 2*/
    ORKHeadphoneDetectedAirpodsProGen2,
    
    /** Airpods Max */
    ORKHeadphoneDetectedAirpodsMax,
    
    /** Earpods */
    ORKHeadphoneDetectedEarpods

    
} ORK_ENUM_AVAILABLE;

@interface UIDevice (HeadphoneDetectStepExtensions)
@property (nonatomic, readonly) BOOL supportsFaceID;
@end


@interface ORKHeadphoneDetectedView : UIStackView

@property (nonatomic) BOOL selected;
@property (nonatomic, assign) ORKHeadphoneDetected headphoneCellType;

- (instancetype)initWithHeadphoneType:(ORKHeadphoneDetected)detectedHeadphone;
- (void)setHeadphoneDetected:(ORKHeadphoneDetected * _Nullable)headphoneDetected;

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

- (instancetype)initWithTitle:(NSString *)title image:(UIImage *)image headphoneType:(ORKHeadphoneDetected)headphoneType {
    self = [super init];
    if (self) {
        _title = title;
        _image = image;
        _headphoneCellType = headphoneType;
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
        
        NSString *explanation = [self getNoiseCancellationExplanationForHeadphoneType:headphoneType];
        if (explanation != nil) {
            [self setupOrangeLabel];
            [self setupExtraLabelWithText:explanation];
            [self setExtraLabelsAlpha:0.0];
        }
        
        [self updateAccessibilityElements];
    }
    return self;
}

- (instancetype)initWithHeadphoneType:(ORKHeadphoneDetected)detectedHeadphone {
    return [self initWithTitle:[self getTitleLabelForHeadphoneType:detectedHeadphone] image:[self headphoneImage:detectedHeadphone] headphoneType:detectedHeadphone];
}

- (void)setupImageView {
    if (_image) {
        if (!_imageView) {
            _imageView = [UIImageView new];
        }

        _imageView.tintColor = UIColor.labelColor;
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
    _textLabel.text = [self getTextLabelForHeadphoneType:_headphoneCellType];
    _textLabel.textColor = UIColor.systemGrayColor;
    _textLabel.font = [self bodyTextFont];
    _textLabel.textAlignment = NSTextAlignmentLeft;
    _textLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [_labelContainerView addSubview:_textLabel];
    
    [[_textLabel.leadingAnchor constraintEqualToAnchor:_labelContainerView.leadingAnchor] setActive:YES];
    [[_textLabel.topAnchor constraintEqualToAnchor:_labelContainerView.centerYAnchor] setActive:YES];
}

- (NSString *)getTitleLabelForHeadphoneType:(ORKHeadphoneDetected)headphoneType {
    switch (headphoneType) {
        case ORKHeadphoneDetectedAirpodsGen1:
        case ORKHeadphoneDetectedAirpodsGen2:
        case ORKHeadphoneDetectedAirpodsGen3:
            return AAPLLocalizedString(@"AIRPODS", nil);
        case ORKHeadphoneDetectedAirpodsPro:
        case ORKHeadphoneDetectedAirpodsProGen2:
            return AAPLLocalizedString(@"AIRPODSPRO", nil);
        case ORKHeadphoneDetectedAirpodsMax:
            return AAPLLocalizedString(@"AIRPODSMAX", nil);
        case ORKHeadphoneDetectedEarpods:
            return AAPLLocalizedString(@"EARPODS", nil);
        default:
            return AAPLLocalizedString(@"HEADPHONES", nil);
    }
}

- (NSString *)getTextLabelForHeadphoneType:(ORKHeadphoneDetected)headphoneType {
    switch (headphoneType) {
        case ORKHeadphoneDetectedAirpodsGen1:
        case ORKHeadphoneDetectedAirpodsGen2:
        case ORKHeadphoneDetectedAirpodsGen3:
            if (_headphoneCellType == ORKHeadphoneDetectedUnknown) {
                return _selected ? AAPLLocalizedString(@"HEADPHONE_CONNECTED_AIRPODS", nil) : AAPLLocalizedString(@"HEADPHONES_NONE", nil);
            }
            return _selected ? AAPLLocalizedString(@"AIRPODS_CONNECTED", nil) :  AAPLLocalizedString(@"AIRPODS_NOT_CONNECTED", nil);
        case ORKHeadphoneDetectedAirpodsPro:
        case ORKHeadphoneDetectedAirpodsProGen2:
            if (_headphoneCellType == ORKHeadphoneDetectedUnknown) {
                return _selected ? AAPLLocalizedString(@"HEADPHONE_CONNECTED_AIRPODSPRO", nil) : AAPLLocalizedString(@"HEADPHONES_NONE", nil);
            }
            return _selected ? AAPLLocalizedString(@"AIRPODSPRO_CONNECTED", nil) :  AAPLLocalizedString(@"AIRPODSPRO_NOT_CONNECTED", nil);
        case ORKHeadphoneDetectedAirpodsMax:
            if (_headphoneCellType == ORKHeadphoneDetectedUnknown) {
                return _selected ? AAPLLocalizedString(@"HEADPHONE_CONNECTED_AIRPODSMAX", nil) : AAPLLocalizedString(@"HEADPHONES_NONE", nil);
            }
            return _selected ? AAPLLocalizedString(@"AIRPODSMAX_CONNECTED", nil) :  AAPLLocalizedString(@"AIRPODSMAX_NOT_CONNECTED", nil);
        case ORKHeadphoneDetectedEarpods:
            if (_headphoneCellType == ORKHeadphoneDetectedUnknown) {
                return _selected ? AAPLLocalizedString(@"HEADPHONE_CONNECTED_EARPODS", nil) : AAPLLocalizedString(@"HEADPHONES_NONE", nil);
            }
            return _selected ? AAPLLocalizedString(@"EARPODS_CONNECTED", nil) :  AAPLLocalizedString(@"EARPODS_NOT_CONNECTED", nil);
        case ORKHeadphoneDetectedNone:
            return AAPLLocalizedString(@"HEADPHONES_NONE", nil);
        case ORKHeadphoneDetectedUnknown:
            return AAPLLocalizedString(@"HEADPHONES", nil);
    }
}

- (NSString *)getNoiseCancellationExplanationForHeadphoneType:(ORKHeadphoneDetected)headphoneType {
    NSString *result = nil;
        
    switch (headphoneType) {
        case ORKHeadphoneDetectedAirpodsGen1:
        case ORKHeadphoneDetectedAirpodsGen2:
        case ORKHeadphoneDetectedAirpodsGen3:
            result = nil;
            break;

        case ORKHeadphoneDetectedAirpodsPro:
        case ORKHeadphoneDetectedAirpodsProGen2:
            result = [[UIDevice currentDevice] supportsFaceID]
            ? ORKLocalizedString(@"NOISE_CANCELLATION_EXPLANATION_CONTROLCENTER_ATOP_AIRPODSPRO", nil)
            : ORKLocalizedString(@"NOISE_CANCELLATION_EXPLANATION_CONTROLCENTER_BELOW_AIRPODSPRO", nil);
            break;

        case ORKHeadphoneDetectedAirpodsMax:
            result = [[UIDevice currentDevice] supportsFaceID]
            ? ORKLocalizedString(@"NOISE_CANCELLATION_EXPLANATION_CONTROLCENTER_ATOP_AIRPODSMAX", nil)
            : ORKLocalizedString(@"NOISE_CANCELLATION_EXPLANATION_CONTROLCENTER_BELOW_AIRPODSMAX", nil);
            break;

        case ORKHeadphoneDetectedEarpods:
        case ORKHeadphoneDetectedNone:
        case ORKHeadphoneDetectedUnknown:
            result = nil;
            break;            
    }
    
    return result;
}


- (void)setupOrangeLabel {
    if (!_extraLabelsContainerView) {
        _extraLabelsContainerView =  [UIView new];
    }
    if (!_orangeLabel) {
        _orangeLabel = [UILabel new];
    }

    UIImageConfiguration *configuration = [UIImageSymbolConfiguration configurationWithFont:[UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline] scale:UIImageSymbolScaleDefault];
    UIImage *exclamation = [[UIImage systemImageNamed:@"exclamationmark.circle.fill" withConfiguration:configuration] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    
    _orangeLabelImage = [[UIImageView alloc] initWithImage: exclamation];
    _orangeLabelImage.tintColor = UIColor.systemOrangeColor;
    [_orangeLabelImage sizeToFit];
    _orangeLabelImage.translatesAutoresizingMaskIntoConstraints = NO;
    _orangeLabel.text = AAPLLocalizedString(@"NOISE_CANCELLATION_REQUIRED", nil);
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

- (void)setupExtraLabelWithText:(NSString *)text {
    if (!_extraLabel) {
        _extraLabel = [UILabel new];
    }
    _extraLabel.text = text;
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

- (void)reset {
    [self setSelected:NO];
    _textLabel.text = [self getTextLabelForHeadphoneType:_headphoneCellType];
}

- (void)setSelected:(BOOL)selected {
    _selected = selected;
    [self updateCheckView];
    [self updateAccessibilityElements];
}

- (void)setHeadphoneDetected:(ORKHeadphoneDetected * _Nullable)headphone {
    if (!_textLabel) { return; }
    if (headphone) {
        UIImage *headphoneglyph = [self headphoneImage:headphone];
        NSString *headphoneName = [self getTextLabelForHeadphoneType:headphone];
        [_textLabel setText:headphoneName];
        _imageView.image = headphoneglyph;
    } else {
        [_textLabel setText:ORKLocalizedString(@"THIRD_PARTY_HEADPHONES_CONNECTED", nil)];
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

- (UIImage *)headphoneImage:(ORKHeadphoneDetected)detectedHeadphone {
    NSString *glyphName;
    switch (detectedHeadphone) {
        case ORKHeadphoneDetectedAirpodsGen1:
        case ORKHeadphoneDetectedAirpodsGen2:
            glyphName = ORKHeadphoneGlyphNameAirpods;
            break;
        case ORKHeadphoneDetectedAirpodsGen3:
            glyphName = ORKHeadphoneGlyphNameAirpodsGen3;
            break;
        case ORKHeadphoneDetectedAirpodsPro:
        case ORKHeadphoneDetectedAirpodsProGen2:
            glyphName = ORKHeadphoneGlyphNameAirpodsPro;
            break;
        case ORKHeadphoneDetectedAirpodsMax:
            glyphName = ORKHeadphoneGlyphNameAirpodsMax;
            break;
        case ORKHeadphoneDetectedEarpods:
            glyphName = ORKHeadphoneGlyphNameEarpods;
            break;
        default:
            glyphName = ORKHeadphoneGlyphNameHeadphones;
    }
    return [[UIImage imageNamed:glyphName inBundle:ORKBundle() compatibleWithTraitCollection:nil] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
}

@end

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
    NSArray <ORKHeadphoneDetectedView*> *_supportViews;
    
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
            [_supportViews makeObjectsPerformSelector:@selector(reset)];
        } else if (headphoneTypes == ORKHeadphoneTypesAny) {
            _anyHeadphoneView.selected = NO;
            [_anyHeadphoneView setHeadphoneDetected:ORKHeadphoneDetectedNone];
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
    
    _supportViews = @[_airpodMaxSupportView,_airpodProSupportView,_airpodSupportView,_earpodSupportView];
}

- (void)addAnyHeadphoneDetectedView {
    [self addArrangedSubview:[self horizontalRuleView]];
    [self setupAnyHeadphoneView];
    [self addArrangedSubview:[self horizontalRuleView]];
}

- (NSAttributedString *)getSharedAudioMessage {
    NSMutableAttributedString *sharedAudioString = [NSMutableAttributedString new];
    
    NSArray<NSString *> *stringElements = [AAPLLocalizedString(@"SHARED_AUDIO_ALERT", nil) componentsSeparatedByString:@"%@"];

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
    separator.backgroundColor = UIColor.separatorColor;
    [separator.heightAnchor constraintEqualToConstant:1.0 / [UIScreen mainScreen].scale].active = YES;
    return separator;
}

- (void)setupAirpodProView {
    if (!_airpodProSupportView) {
        _airpodProSupportView = [[ORKHeadphoneDetectedView alloc] initWithHeadphoneType:ORKHeadphoneDetectedAirpodsPro];
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
        _airpodMaxSupportView = [[ORKHeadphoneDetectedView alloc] initWithHeadphoneType:ORKHeadphoneDetectedAirpodsMax];
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
        _airpodSupportView = [[ORKHeadphoneDetectedView alloc] initWithHeadphoneType:ORKHeadphoneDetectedAirpodsGen3];
    }
    _airpodSupportView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addArrangedSubview:_airpodSupportView];
    [[_airpodSupportView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor] setActive:YES];
    [[_airpodSupportView.heightAnchor constraintEqualToConstant:ORKHeadphoneDetectCellStepSize] setActive:YES];
}

- (void)setupEarpodView {
    if (!_earpodSupportView) {
        _earpodSupportView = [[ORKHeadphoneDetectedView alloc] initWithHeadphoneType:ORKHeadphoneDetectedEarpods];
    }
    _earpodSupportView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addArrangedSubview:_earpodSupportView];
    [[_earpodSupportView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor] setActive:YES];
    [[_earpodSupportView.heightAnchor constraintEqualToConstant:ORKHeadphoneDetectCellStepSize] setActive:YES];
}

- (void)setupAnyHeadphoneView {
    if (!_anyHeadphoneView) {
        _anyHeadphoneView = [[ORKHeadphoneDetectedView alloc] initWithHeadphoneType:ORKHeadphoneDetectedUnknown];
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
            [_supportViews makeObjectsPerformSelector:@selector(reset)];
            switch (_headphoneDetected) {
                case ORKHeadphoneDetectedAirpodsGen1:
                case ORKHeadphoneDetectedAirpodsGen2:
                case ORKHeadphoneDetectedAirpodsGen3:
                    _airpodSupportView.selected = YES;
                    [_airpodSupportView setHeadphoneDetected:_headphoneDetected];
                    [self setAirpodProCellExpanded: NO];
                    [self setAirpodMaxCellExpanded: NO];
                    break;
                case ORKHeadphoneDetectedAirpodsPro:
                case ORKHeadphoneDetectedAirpodsProGen2:
                    _airpodProSupportView.selected = YES;
                    [_airpodProSupportView setHeadphoneDetected:_headphoneDetected];
                    [self setAirpodProCellExpanded: isExpanded];
                    [self setAirpodMaxCellExpanded: NO];
                    break;
                case ORKHeadphoneDetectedAirpodsMax:
                    _airpodMaxSupportView.selected = YES;
                    [_airpodMaxSupportView setHeadphoneDetected:_headphoneDetected];
                    [self setAirpodProCellExpanded: NO];
                    [self setAirpodMaxCellExpanded: isExpanded];
                    break;
                case ORKHeadphoneDetectedEarpods:
                    _earpodSupportView.selected = YES;
                    [_earpodSupportView setHeadphoneDetected:_headphoneDetected];
                    [self setAirpodProCellExpanded: NO];
                    [self setAirpodMaxCellExpanded: NO];
                    break;
                default:
                    [self setAirpodProCellExpanded: NO];
                    [self setAirpodMaxCellExpanded: NO];
                    break;
            }
            break;
            
        case ORKHeadphoneTypesAny:
            switch (_headphoneDetected) {
                case ORKHeadphoneDetectedUnknown:
                    _anyHeadphoneView.selected = YES;
                    [_anyHeadphoneView setHeadphoneDetected:nil];
                    break;
                case ORKHeadphoneDetectedNone:
                    _anyHeadphoneView.selected = NO;
                    [_anyHeadphoneView setHeadphoneDetected:ORKHeadphoneDetectedNone];
                    break;
                default:
                    _anyHeadphoneView.selected = YES;
                    [_anyHeadphoneView setHeadphoneDetected:_headphoneDetected];
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

- (void)noHeadphonesButtonPressed:(id)sender {
    NSString *stepIdentifier = [(id<ORKHeadphoneRequiredTaskContext>)self.step.context didSkipHeadphoneDetectionStep:self.step forTask:self.taskViewController.task];
    NSAssert(stepIdentifier != nil, @"Cannot flip to page with no identifier");
    [[self taskViewController] flipToPageWithIdentifier:stepIdentifier forward:YES animated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.stepView.navigationFooterView.optional = YES;
    self.stepView.navigationFooterView.continueEnabled = NO;
}

- (void)setContinueButtonItem:(UIBarButtonItem *)continueButtonItem {
    if ([self.step.context isKindOfClass:[ORKSpeechInNoisePredefinedTaskContext class]]) {
        continueButtonItem.title = AAPLLocalizedString(@"SPEECH_IN_NOISE_PREDEFINED_HEADPHONES_DETECT_CONTINUE", nil);
    }
    
    continueButtonItem.target = self;
    continueButtonItem.action = @selector(continueButtonTapped:);
    [super setContinueButtonItem:continueButtonItem];
}

- (void)continueButtonTapped:(id)sender {
    if ([self.step.context conformsToProtocol:@protocol(ORKHeadphoneRequiredTaskContext)]) {
        NSString *completionStepIdentifierHeadphonesRequired = ((id<ORKHeadphoneRequiredTaskContext>)self.step.context).headphoneRequiredIdentifier;
        ORKPredicateSkipStepNavigationRule *skipNavigationRule = [[ORKPredicateSkipStepNavigationRule alloc] initWithResultPredicate:[NSPredicate predicateWithValue:YES]];
        [(ORKNavigableOrderedTask *)[[self taskViewController] task] setSkipNavigationRule:skipNavigationRule forStepIdentifier:completionStepIdentifierHeadphonesRequired];
    }
    
    [self goForward];
}

- (void)setSkipButtonItem:(UIBarButtonItem *)skipButtonItem
{
    [super setSkipButtonItem:skipButtonItem];
    
    if ([self.step.context isKindOfClass:[ORKSpeechInNoisePredefinedTaskContext class]])
    {
        [skipButtonItem setTitle:AAPLLocalizedString(@"SPEECH_IN_NOISE_PREDEFINED_HEADPHONES_DETECT_SKIP", nil)];
        skipButtonItem.target = self;
        skipButtonItem.action = @selector(noHeadphonesButtonPressed:);
    } else if ([self isDetectingAppleHeadphones]) {
        if (!self.step.context) {
            self.step.context = [[ORKdBHLTaskContext alloc] init];
        }
        [skipButtonItem setTitle:AAPLLocalizedString(@"DBHL_HEADPHONES_DETECT_SKIP", nil)];
        skipButtonItem.target = self;
        skipButtonItem.action = @selector(noHeadphonesButtonPressed:);
    }
}

- (void)updateAppearanceForConnectedState:(BOOL)connected {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.stepView.navigationFooterView.continueEnabled = connected;
        self.stepView.navigationFooterView.skipEnabled = !connected;
    });
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (self.step.context && [self.step.context isKindOfClass:[ORKTinnitusPredefinedTaskContext class]]) {
        [(ORKTinnitusPredefinedTaskContext *)self.step.context insertTaskViewController:[self taskViewController]];
    }
    
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
    headphoneResult.isMonoAudioEnabled = UIAccessibilityIsMonoAudioEnabled();
    
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
        } else if ([headphoneType isEqualToString:ORKHeadphoneTypeIdentifierAirPodsGen3]) {
            _headphoneDetectStepView.headphoneDetected = ORKHeadphoneDetectedAirpodsGen3;
        } else if ([headphoneType isEqualToString:ORKHeadphoneTypeIdentifierAirPodsPro]) {
            _lastDetectedBluetoothMode = ORKBluetoothModeNone;
            _headphoneDetectStepView.headphoneDetected = ORKHeadphoneDetectedAirpodsPro;
        } else if ([headphoneType isEqualToString:ORKHeadphoneTypeIdentifierAirPodsProGen2]) {
            _lastDetectedBluetoothMode = ORKBluetoothModeNone;
            _headphoneDetectStepView.headphoneDetected = ORKHeadphoneDetectedAirpodsProGen2;
        } else if ([headphoneType isEqualToString:ORKHeadphoneTypeIdentifierEarPods] ) {
            _headphoneDetectStepView.headphoneDetected = ORKHeadphoneDetectedEarpods;
        } else if ([headphoneType isEqualToString:ORKHeadphoneTypeIdentifierAirPodsMax] ) {
            _headphoneDetectStepView.headphoneDetected = ORKHeadphoneDetectedAirpodsMax;
        }  else {
            _headphoneDetectStepView.headphoneDetected = ORKHeadphoneDetectedUnknown;
        }
        
        if (self.step.context && [self.step.context isKindOfClass:[ORKTinnitusPredefinedTaskContext class]]) {
            [(ORKTinnitusPredefinedTaskContext *)self.step.context setHeadphoneType:headphoneType];
        }
    } else {
        _lastDetectedHeadphoneType = nil;
        _headphoneDetectStepView.headphoneDetected = ORKHeadphoneDetectedNone;
    }
    
    [self updateAppearanceForConnectedState:isSupported];
}

- (void)bluetoothModeChanged:(ORKBluetoothMode)bluetoothMode {
    if (_lastDetectedBluetoothMode != bluetoothMode &&
        ([_lastDetectedHeadphoneType isEqualToString:ORKHeadphoneTypeIdentifierAirPodsPro] ||
         [_lastDetectedHeadphoneType isEqualToString:ORKHeadphoneTypeIdentifierAirPodsProGen2] ||
         [_lastDetectedHeadphoneType isEqualToString:ORKHeadphoneTypeIdentifierAirPodsMax])) {
        _lastDetectedBluetoothMode = bluetoothMode;
        // FIXME:- temporary workaround for <rdar://problem/62519889>
        BOOL isNoiseCancellingEnabled = (bluetoothMode == ORKBluetoothModeNoiseCancellation) || ([self detectStep].headphoneTypes == ORKHeadphoneTypesAny);
        [_headphoneDetectStepView updateAppearanceWithExpandedCell: !isNoiseCancellingEnabled];
        self.stepView.navigationFooterView.continueEnabled = isNoiseCancellingEnabled;
        self.stepView.navigationFooterView.skipEnabled = !isNoiseCancellingEnabled;
    }
}

- (void)podLowBatteryLevelDetected {
    _headphoneDetector.delegate = nil;
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertController *alertController = [UIAlertController
                                              alertControllerWithTitle:AAPLLocalizedString(@"HEADPHONES_LOW_BATTERY_TITLE", nil)
                                              message:AAPLLocalizedString(@"HEADPHONES_LOW_BATTERY_TEXT", nil)
                                              preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *startOver = [UIAlertAction
                                    actionWithTitle:AAPLLocalizedString(@"dBHL_ALERT_TITLE_START_OVER", nil)
                                    style:UIAlertActionStyleDefault
                                    handler:^(UIAlertAction *action) {
            [[self taskViewController] restartTask];
        }];
        [alertController addAction:startOver];
        [alertController addAction:[UIAlertAction
                                    actionWithTitle:AAPLLocalizedString(@"dBHL_ALERT_TITLE_CANCEL_TEST", nil)
                                    style:UIAlertActionStyleDefault
                                    handler:^(UIAlertAction *action) {
            ORKStrongTypeOf(self.taskViewController.delegate) strongDelegate = self.taskViewController.delegate;
            if ([strongDelegate respondsToSelector:@selector(taskViewController:didFinishWithReason:error:)]) {
                [strongDelegate taskViewController:self.taskViewController didFinishWithReason:ORKTaskFinishReasonDiscarded error:nil];
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

@implementation UIDevice (HeadphoneDetectStepExtensions)

- (BOOL)supportsFaceID {
    BOOL result = NO;
    
    if (@available(iOS 11.2, *)) {
        LAContext *context = [[LAContext alloc] init];
        NSError *error = nil;
        result = [context canEvaluatePolicy:kLAPolicyDeviceOwnerAuthentication error:&error];
        result = result && context.biometryType == LABiometryTypeFaceID;
    }
    
    return  result;
}

@end
