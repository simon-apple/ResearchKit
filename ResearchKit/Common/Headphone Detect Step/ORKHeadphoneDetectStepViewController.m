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
#import "ORKStepHeaderView_Internal.h"
#import "ORKStepContainerView_Private.h"

#import "ORKInstructionStepViewController_Internal.h"
#import "ORKStepViewController_Internal.h"
#import "ORKSkin.h"
#import "ORKHelpers_Internal.h"

static const CGFloat ORKHeadphoneImageViewDimension = 60.0;
static const CGFloat ORKHeadphoneDetectStepViewTopPadding = 50.0;

@interface ORKHeadphoneDetectedView : UIStackView

@property (nonatomic) BOOL connected;
@property (nonatomic) BOOL selected;

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
    UIView *_labelContainerView;
    
    ORKCheckmarkView *_checkView;
}

- (instancetype)initWithTitle:(NSString *)title image:(UIImage *)image {
    self = [super init];
    if (self) {
        _title = title;
        _image = image;
        self.axis = UILayoutConstraintAxisHorizontal;
        self.distribution = UIStackViewDistributionFill;
        self.alignment = UIStackViewAlignmentCenter;
        self.spacing = 0.0;
        [self setupImageView];
        [self setupLabelStackView];
        [self setupTitleLabel];
        [self setupTextLabel];
        [self setupCheckView];
    }
    return self;
}

- (instancetype)initWithAirpods {
    return [self initWithTitle:ORKLocalizedString(@"AIRPODS", nil) image:[UIImage imageNamed:@"airpods" inBundle:ORKBundle() compatibleWithTraitCollection:nil]];
}

- (instancetype)initWithEarpods {
    return [self initWithTitle:ORKLocalizedString(@"EARPODS", nil) image:[UIImage imageNamed:@"earpods" inBundle:ORKBundle() compatibleWithTraitCollection:nil]];
}

- (instancetype)initWithAnyHeadphones {
    return [self initWithTitle:ORKLocalizedString(@"HEADPHONES", nil) image:nil];
}

- (void)setupImageView {
    if (_image) {
        if (!_imageView) {
            _imageView = [UIImageView new];
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
    if (!_checkView) {
        _checkView = [[ORKCheckmarkView alloc] initWithDefaults];
    }
    [_checkView setChecked:NO];
    [self addArrangedSubview:_checkView];
}

- (void)updateCheckView {
    if (_checkView) {
        [_checkView setChecked:_selected];
    }
}

- (void)setSelected:(BOOL)selected {
    _selected = selected;
    [self updateCheckView];
}

- (void)setConnected:(BOOL)connected {
    _connected = connected;
    _textLabel.text = _connected ? ORKLocalizedString(@"CONNECTED", nil) : ORKLocalizedString(@"NOT_CONNECTED", nil);
}

- (void)anyHeadphoneDetected:(NSString *)headphoneName {
    if (_textLabel && headphoneName) {
        [_textLabel setText:[NSString localizedStringWithFormat:ORKLocalizedString(@"HEADPHONE_CONNECTED_%@", nil),headphoneName]];
    }
}

@end

typedef NS_ENUM(NSInteger, ORKHeadphoneDetected) {
    
    /** None */
    ORKHeadphoneDetectedNone=0,
    
    /** Airpods */
    ORKHeadphoneDetectedAirpods,
    
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
    ORKHeadphoneDetectedView *_earpodSupportView;
    ORKHeadphoneDetectedView *_anyHeadphoneView;
    
    ORKHeadphoneTypes _headphoneTypes;
}
- (instancetype)initWithHeadphoneTypes:(ORKHeadphoneTypes)headphoneTypes {
    self = [super init];
    if (self) {
        _headphoneTypes = headphoneTypes;
        [self setupStackView];
        [self updateAppearance];
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
    _stackView.spacing = 5.0;
    _stackView.distribution = UIStackViewDistributionFillProportionally;
    _stackView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:_stackView];
    [[_stackView.topAnchor constraintEqualToAnchor:self.topAnchor constant:ORKHeadphoneDetectStepViewTopPadding] setActive:YES];
    [[_stackView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor] setActive:YES];
    [[_stackView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor] setActive:YES];
    [[_stackView.heightAnchor constraintGreaterThanOrEqualToConstant:ORKHeadphoneImageViewDimension] setActive:YES];
    if (_headphoneTypes == ORKHeadphoneTypesSupported) {
        [self addSupportedHeadphonesDetectedViews];
    }
    else {
        [self addAnyHeadphoneDetectedView];
    }
}

- (void)addSupportedHeadphonesDetectedViews {
    [_stackView addArrangedSubview:[self horizontalRuleView]];
    [self setupAirpodView];
    [_stackView addArrangedSubview:[self horizontalRuleView]];
    [self setupEarpodView];
    [_stackView addArrangedSubview:[self horizontalRuleView]];
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
    [separator.heightAnchor constraintEqualToConstant:ORKHorizontalRuleHeight].active = YES;
    return separator;
}

- (void)setupAirpodView {
    if (!_airpodSupportView) {
        _airpodSupportView = [[ORKHeadphoneDetectedView alloc] initWithAirpods];
    }
    _airpodSupportView.translatesAutoresizingMaskIntoConstraints = NO;
    [_stackView addArrangedSubview:_airpodSupportView];
}

- (void)setupEarpodView {
    if (!_earpodSupportView) {
        _earpodSupportView = [[ORKHeadphoneDetectedView alloc] initWithEarpods];
    }
    _earpodSupportView.translatesAutoresizingMaskIntoConstraints = NO;
    [_stackView addArrangedSubview:_earpodSupportView];
}

- (void)setupAnyHeadphoneView {
    if (!_anyHeadphoneView) {
        _anyHeadphoneView = [[ORKHeadphoneDetectedView alloc] initWithAnyHeadphones];
    }
    _anyHeadphoneView.translatesAutoresizingMaskIntoConstraints = NO;
    [_stackView addArrangedSubview:_anyHeadphoneView];
}

- (void)setHeadphoneDetected:(ORKHeadphoneDetected)headphoneDetected {
    _headphoneDetected = headphoneDetected;
    [self updateAppearance];
}

- (void)updateAppearance {
    switch (_headphoneTypes) {
        case ORKHeadphoneTypesSupported:
            switch (_headphoneDetected) {
                case ORKHeadphoneDetectedAirpods:
                    _airpodSupportView.selected = YES;
                    _airpodSupportView.connected = YES;
                    _earpodSupportView.selected = NO;
                    break;
                case ORKHeadphoneDetectedEarpods:
                    _airpodSupportView.selected = NO;
                    _earpodSupportView.selected = YES;
                    _earpodSupportView.connected = YES;
                    break;
                default:
                    _airpodSupportView.selected = NO;
                    _earpodSupportView.selected = NO;
                    break;
            }
            break;
            
        case ORKHeadphoneTypesAny:
            switch (_headphoneDetected) {
                case ORKHeadphoneDetectedAirpods:
                    _anyHeadphoneView.selected = YES;
                    [_anyHeadphoneView anyHeadphoneDetected:ORKLocalizedString(@"AIRPODS", nil)];
                    break;
                case ORKHeadphoneDetectedEarpods:
                    _anyHeadphoneView.selected = YES;
                    [_anyHeadphoneView anyHeadphoneDetected:ORKLocalizedString(@"EARPODS", nil)];
                    break;
                case ORKHeadphoneDetectedUnknown:
                    _anyHeadphoneView.selected = YES;
                    [_anyHeadphoneView anyHeadphoneDetected:ORKLocalizedString(@"HEADPHONES_UNKNOWN", nil)];
                    break;
                case ORKHeadphoneDetectedNone:
                    _anyHeadphoneView.selected = NO;
                    [_anyHeadphoneView anyHeadphoneDetected:ORKLocalizedString(@"HEADPHONES_NONE", nil)];
                    break;
            }
            break;
    }
}


@end

@implementation ORKHeadphoneDetectStepViewController {
    ORKHeadphoneDetectStepView *_headphoneDetectStepView;
    ORKHeadphoneDetector * _headphoneDetector;
    NSString * _lastDetectedRoute;
}

- (ORKHeadphoneDetectStep *)detectStep {
    return (ORKHeadphoneDetectStep *)[self step];
}

- (void)stepDidChange {
    [super stepDidChange];
    
    _headphoneDetectStepView = [self detectStep].headphoneTypes == ORKHeadphoneTypesSupported ? [[ORKHeadphoneDetectStepView alloc] initWithHeadphonesSupported] : [[ORKHeadphoneDetectStepView alloc] initWithHeadphonesAny];

    self.stepView.customContentFillsAvailableSpace = YES;
    self.stepView.customContentView = _headphoneDetectStepView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.stepView.navigationFooterView.continueEnabled = NO;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    _headphoneDetector = [[ORKHeadphoneDetector alloc] initWithDelegate:self supportedHeadphoneTypes:[[self detectStep] supportedHeadphoneTypes]];
}

- (ORKStepResult *)result {
    ORKStepResult *sResult = [super result];
    
    NSMutableArray *results = [NSMutableArray arrayWithArray:sResult.results];
    
    ORKHeadphoneDetectResult *headphoneResult = [[ORKHeadphoneDetectResult alloc] initWithIdentifier:self.step.identifier];
    
    headphoneResult.headphoneType = _lastDetectedRoute;
    
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
- (void)headphoneTypeDetected:(NSString *)headphoneType isSupported:(BOOL)isSupported {
    if (headphoneType == nil) {
        _lastDetectedRoute = nil;
        _headphoneDetectStepView.headphoneDetected = ORKHeadphoneDetectedNone;
    } else if ([headphoneType containsString:ORKHeadphoneTypeIdentifierAirpods]) {
        _lastDetectedRoute = @"AIRPODS";
        _headphoneDetectStepView.headphoneDetected = ORKHeadphoneDetectedAirpods;
    } else if ([headphoneType containsString:ORKHeadphoneTypeIdentifierAudiojackEarpods] || [headphoneType containsString:ORKHeadphoneTypeIdentifierLightningEarpods]) {
        _lastDetectedRoute = @"EARPODS";
        _headphoneDetectStepView.headphoneDetected = ORKHeadphoneDetectedEarpods;
    } else {
        _lastDetectedRoute = @"UNKNOWN";
        _headphoneDetectStepView.headphoneDetected = ORKHeadphoneDetectedUnknown;
    }
    self.stepView.navigationFooterView.continueEnabled = isSupported;
}

@end

