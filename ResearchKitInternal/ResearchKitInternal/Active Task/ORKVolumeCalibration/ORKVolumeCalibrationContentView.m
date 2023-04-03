/*
 Copyright (c) 2020, Apple Inc. All rights reserved.
 
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

#import "ORKVolumeCalibrationContentView.h"

#import "ORKCelestialSoftLink.h"
#import <ResearchKit/ORKHelpers_Internal.h>
#import <ResearchKitInternal/AAPLHelpers_Internal.h>
#import <ResearchKit/ORKSkin.h>
#import <ResearchKitActiveTask/UIColor+Custom.h>

static int const ORKVolumeCalibrationStepPadding = 8;
static int const ORKVolumeCalibrationStepInsetAdjustment = 4;
static int const ORKVolumeCalibrationStepMargin = 16;
static int const ORKVolumeCalibrationStepSliderMargin = 22;
static int const ORKVolumeCalibrationStepSliderSpacing = 30;
static int const ORKVolumeCalibrationStepPlaybackButtonSize = 36;

@interface ORKVolumeCalibrationContentView ()
@property (nonatomic, strong) UIButton *playbackButton;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIImageView *barLevelsView;
@property (nonatomic, strong) UISlider *volumeSlider;
@end

@implementation ORKVolumeCalibrationContentView

- (instancetype)initWithTitle:(NSString *)title
{
   self = [super init];
   if (self) {
       self.translatesAutoresizingMaskIntoConstraints = NO;
       [self commonInit];
       self.titleLabel.text = title;
   }
   
   return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit
{
    UIView *roundedView = [[UIView alloc] init];
    roundedView.layer.cornerRadius = 10;

    UIView *separatorView = [[UIView alloc] init];

    self.playbackButton = [UIButton buttonWithType:UIButtonTypeCustom];

    UIImage *playImage;
    UIImage *sliderFullImage;
    UIImage *sliderEmptyImage;
    if (@available(iOS 13.0, *)) {
        sliderFullImage = [UIImage systemImageNamed:@"speaker.wave.3.fill"];
        sliderEmptyImage = [UIImage systemImageNamed:@"speaker.fill"];
        UIImageSymbolConfiguration *imageConfig = [UIImageSymbolConfiguration configurationWithPointSize:ORKVolumeCalibrationStepPlaybackButtonSize weight:UIImageSymbolWeightRegular scale:UIImageSymbolScaleDefault];
        playImage = [[[UIImage systemImageNamed:@"play.circle.fill"] imageByApplyingSymbolConfiguration:imageConfig] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];

        separatorView.backgroundColor = UIColor.tinnitusBackgroundColor;
        _playbackButton.tintColor = UIColor.tinnitusPlayBackgroundColor;
        _playbackButton.backgroundColor = [UIColor systemBlueColor];
        roundedView.backgroundColor = UIColor.tinnitusButtonBackgroundColor;
        
        _playbackButton.layer.cornerRadius = ORKVolumeCalibrationStepPlaybackButtonSize/2.2;
    }

    [_playbackButton setImage:playImage forState:UIControlStateNormal];
    _playbackButton.imageEdgeInsets = UIEdgeInsetsMake(-2, -2, -2, -2);
    _playbackButton.imageView.contentMode = UIViewContentModeCenter;
    _playbackButton.clipsToBounds = YES;
    [roundedView addSubview:_playbackButton];

    self.titleLabel = [[UILabel alloc] init];
    _titleLabel.numberOfLines = 0;
    _titleLabel.font = [self headlineTextFont];
    [roundedView addSubview:_titleLabel];

    self.barLevelsView = [[UIImageView alloc] init];
    NSMutableArray *barImages = [[NSMutableArray alloc] init];
    for (int i = 0 ; i < 21 ; i ++) {
        

        // workaround to fix no tint color on animated images bug
        UIImage *blackImage = [UIImage imageNamed:[NSString stringWithFormat:@"tinnitus_bar_levels_%i", i] inBundle:ORKInternalBundle() compatibleWithTraitCollection:nil];
        UIImage *newImage = [blackImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        UIGraphicsBeginImageContextWithOptions(blackImage.size, NO, blackImage.scale);
        [UIColor.systemBlueColor set];
        [newImage drawInRect:CGRectMake(0, 0, blackImage.size.width, blackImage.size.height)];
        newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        [barImages addObject:newImage];
    }
    [_barLevelsView setAnimationImages:barImages];
    _barLevelsView.animationDuration = 1.33;
    _barLevelsView.animationRepeatCount = 0;
    _barLevelsView.backgroundColor = [UIColor clearColor];
    _barLevelsView.hidden = YES;
    [_barLevelsView startAnimating];

    [roundedView addSubview:_barLevelsView];
    [roundedView addSubview:separatorView];

    UIImageView *sliderFull = [[UIImageView alloc] initWithImage:sliderFullImage];
    UIImageView *sliderEmpty = [[UIImageView alloc] initWithImage:sliderEmptyImage];

    UIColor *tintColor = [UIColor grayColor];
    if (@available(iOS 13.0, *)) {
        tintColor = [UIColor secondaryLabelColor];
    }
    sliderFull.tintColor = tintColor;
    sliderEmpty.tintColor = tintColor;
    [roundedView addSubview:sliderEmpty];
    [roundedView addSubview:sliderFull];

    self.volumeSlider = [[UISlider alloc] init];
    [roundedView addSubview:_volumeSlider];

    [self addSubview:roundedView];

    [roundedView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [[roundedView.topAnchor constraintEqualToAnchor:self.topAnchor constant:ORKVolumeCalibrationStepPadding] setActive:YES];
    [[roundedView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor] setActive:YES];
    [[roundedView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor] setActive:YES];
    [[roundedView.bottomAnchor constraintLessThanOrEqualToAnchor:self.bottomAnchor constant:-ORKVolumeCalibrationStepPadding] setActive:YES];

    [_playbackButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    [[_playbackButton.centerYAnchor constraintEqualToAnchor:_titleLabel.centerYAnchor] setActive:YES];
    [[_playbackButton.heightAnchor constraintEqualToConstant:ORKVolumeCalibrationStepPlaybackButtonSize - ORKVolumeCalibrationStepInsetAdjustment] setActive:YES];
    [[_playbackButton.widthAnchor constraintEqualToConstant:ORKVolumeCalibrationStepPlaybackButtonSize - ORKVolumeCalibrationStepInsetAdjustment] setActive:YES];
    [[_playbackButton.leadingAnchor constraintEqualToAnchor:roundedView.leadingAnchor constant:ORKVolumeCalibrationStepMargin] setActive:YES];

    [_titleLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [[_titleLabel.topAnchor constraintEqualToAnchor:roundedView.topAnchor constant:ORKVolumeCalibrationStepMargin] setActive:YES];
    [[_titleLabel.centerYAnchor constraintEqualToAnchor:_playbackButton.centerYAnchor] setActive:YES];
    [[_titleLabel.leadingAnchor constraintEqualToAnchor:_playbackButton.trailingAnchor constant:ORKVolumeCalibrationStepMargin] setActive:YES];

    [_barLevelsView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [_barLevelsView.leadingAnchor constraintEqualToAnchor:_titleLabel.trailingAnchor constant:2.0].active = YES;
    [_barLevelsView.centerYAnchor constraintEqualToAnchor:_titleLabel.centerYAnchor constant:2.0].active = YES;
    [_barLevelsView.widthAnchor constraintEqualToConstant:30.0].active = YES;
    [_barLevelsView.heightAnchor constraintEqualToConstant:21.0].active = YES;
    [[_barLevelsView.trailingAnchor constraintLessThanOrEqualToAnchor:roundedView.trailingAnchor constant:-ORKVolumeCalibrationStepMargin] setActive:YES];

    [separatorView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [[separatorView.topAnchor constraintEqualToAnchor:_titleLabel.bottomAnchor constant:ORKVolumeCalibrationStepMargin] setActive:YES];
    [[separatorView.heightAnchor constraintEqualToConstant:1] setActive:YES];
    [[separatorView.widthAnchor constraintEqualToAnchor:roundedView.widthAnchor] setActive:YES];
    [[separatorView.centerXAnchor constraintEqualToAnchor:roundedView.centerXAnchor] setActive:YES];

    [_volumeSlider setTranslatesAutoresizingMaskIntoConstraints:NO];
    [[_volumeSlider.topAnchor constraintEqualToAnchor:separatorView.topAnchor constant:ORKVolumeCalibrationStepSliderSpacing] setActive:YES];
    [[_volumeSlider.heightAnchor constraintEqualToConstant:ORKVolumeCalibrationStepPlaybackButtonSize] setActive:YES];
    [[_volumeSlider.widthAnchor constraintEqualToAnchor:roundedView.widthAnchor multiplier:0.62] setActive:YES];
    [[_volumeSlider.centerXAnchor constraintEqualToAnchor:roundedView.centerXAnchor] setActive:YES];
    [[_volumeSlider.bottomAnchor constraintEqualToAnchor:roundedView.bottomAnchor constant:-ORKVolumeCalibrationStepSliderSpacing] setActive:YES];

    [sliderEmpty setTranslatesAutoresizingMaskIntoConstraints:NO];
    [[sliderEmpty.centerYAnchor constraintEqualToAnchor:_volumeSlider.centerYAnchor constant:1] setActive:YES];
    [[sliderEmpty.leadingAnchor constraintEqualToAnchor:roundedView.leadingAnchor constant:ORKVolumeCalibrationStepSliderMargin] setActive:YES];

    [sliderFull setTranslatesAutoresizingMaskIntoConstraints:NO];
    [[sliderFull.centerYAnchor constraintEqualToAnchor:_volumeSlider.centerYAnchor constant:1] setActive:YES];
    [[sliderFull.trailingAnchor constraintEqualToAnchor:roundedView.trailingAnchor constant:-ORKVolumeCalibrationStepSliderMargin] setActive:YES];

    [_volumeSlider addTarget:self action:@selector(volumeSliderChanged:) forControlEvents:UIControlEventValueChanged];
    [_playbackButton addTarget:self action:@selector(playbackButtonPressed:) forControlEvents:UIControlEventTouchUpInside];

    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(volumeDidChange:) name:getAVSystemController_SystemVolumeDidChangeNotification() object:nil];
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    [super traitCollectionDidChange:previousTraitCollection];
    _titleLabel.font = [self headlineTextFont];
}

- (UIFont *)headlineTextFont {
    UIFontDescriptor *descriptor = [UIFontDescriptor preferredFontDescriptorWithTextStyle:UIFontTextStyleHeadline];
    return[UIFont systemFontOfSize:[[descriptor objectForKey: UIFontDescriptorSizeAttribute] doubleValue] + 1.0 weight:UIFontWeightSemibold];
}

- (void)setPlaybackButtonPlaying:(BOOL)isPlaying {
    [self.barLevelsView setHidden:!isPlaying];
    
    if (@available(iOS 13.0, *)) {
        UIImageSymbolConfiguration *imageConfig = [UIImageSymbolConfiguration configurationWithPointSize:ORKVolumeCalibrationStepPlaybackButtonSize weight:UIImageSymbolWeightRegular scale:UIImageSymbolScaleDefault];
        NSString *imageName = isPlaying ? @"pause.circle.fill" : @"play.circle.fill";
        UIImage *image = [[[UIImage systemImageNamed:imageName] imageByApplyingSymbolConfiguration:imageConfig] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [self.playbackButton setImage:image forState:UIControlStateNormal];
    }
}

- (void)playbackButtonPressed:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(contentView:didPressPlaybackButton:)])
    {
        [self setPlaybackButtonPlaying:[self.delegate contentView:self didPressPlaybackButton:self.playbackButton]];
    }
}

- (void)volumeSliderChanged:(UISlider *)sender {
    float volume = sender.value;
    [self.volumeSlider setValue:volume];

    if ([self.delegate respondsToSelector:@selector(contentView:didRaisedVolume:)]) {
        [self.delegate contentView:self didRaisedVolume:volume];
    }

    if ([self.delegate respondsToSelector:@selector(contentView:shouldEnableContinue:)]) {
        [self.delegate contentView:self shouldEnableContinue:(volume > 0)];
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Volume notifications

- (void)volumeDidChange:(NSNotification *)note {
    NSDictionary *userInfo = note.userInfo;
    NSString *reason = userInfo[getAVSystemController_AudioVolumeChangeReasonNotificationParameter()];
    NSNumber *volume = userInfo[getAVSystemController_AudioVolumeNotificationParameter()];

    if ([reason isEqualToString:@"ExplicitVolumeChange"]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!_volumeSlider.isTracking) {
                [_volumeSlider setValue:volume.doubleValue];
            }
            
            if (volume.doubleValue > 0 && _barLevelsView.isHidden) {
                [self playbackButtonPressed:_playbackButton];
            }
            
            if ([self.delegate respondsToSelector:@selector(contentView:shouldEnableContinue:)]) {
                [self.delegate contentView:self shouldEnableContinue:(volume.doubleValue > 0)];
            }
        });
    }
}

@end
