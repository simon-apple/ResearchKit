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

#import "ORKVolumeCalibrationContentView.h"
#import "ORKHelpers_Internal.h"
#import "ORKPlaybackButton_Internal.h"
#import "ORKSkin.h"

static float const ORKVolumeCalibrationStepPlaybackButtonPulseVariance = 0.05;  // percentage
static CFTimeInterval const ORKVolumeCalibrationStepPlaybackButtonPulseDuration = 0.75;   // ms

@interface ORKVolumeCalibrationContentView ()
@property (nonatomic, strong) ORKPlaybackButton *playbackButton;
@end

@implementation ORKVolumeCalibrationContentView

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self commonInit];
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

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit
{
    if (!_playbackButton)
    {
        UIImage *image;
        if (@available(iOS 13.0, *)) {
            image = [UIImage systemImageNamed:@"play.circle"];
        } else {
            image = [UIImage imageNamed:@"play" inBundle:ORKBundle() compatibleWithTraitCollection:nil];
        }
        self.playbackButton = [[ORKPlaybackButton alloc] initWithText:ORKLocalizedString(@"SPEECH_IN_NOISE_PREDEFINED_PLAY_AUDIO_SAMPLE", nil) image:image];
    
        [self addSubview:self.playbackButton];
    
        [self.playbackButton setTranslatesAutoresizingMaskIntoConstraints:NO];
        [[self.playbackButton.topAnchor constraintGreaterThanOrEqualToAnchor:self.topAnchor constant:ORKStepContainerTopPaddingForWindow(self.window)] setActive:YES];
        [[self.playbackButton.bottomAnchor constraintGreaterThanOrEqualToAnchor:self.bottomAnchor] setActive:YES];
        [[self.playbackButton.centerXAnchor constraintEqualToAnchor:self.centerXAnchor] setActive:YES];
        [[self.playbackButton.centerYAnchor constraintEqualToAnchor:self.centerYAnchor] setActive:YES];
        [self.playbackButton addTarget:self action:@selector(playbackButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    }
}

- (CAAnimation *)pulseAnimationWithDuration:(CFTimeInterval)duration variance:(float)variance
{
    CAKeyframeAnimation *pulse = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale.xy"];
    pulse.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    pulse.repeatCount = MAXFLOAT;
    pulse.duration = duration;
    pulse.beginTime = 0.15;
    pulse.values = @[
        @(1.0),
        @(1.0 * (1 - variance)),
        @(1.0),
        @(1.0 * (1 + variance)),
        @(1.0)
    ];
    
    return pulse;
}

- (void)playbackButtonPressed:(ORKPlaybackButton *)sender
{
    if ([self.delegate respondsToSelector:@selector(contentView:didPressPlaybackButton:)])
    {
        BOOL isPlaying = [self.delegate contentView:self didPressPlaybackButton:self.playbackButton];
        
        [self.playbackButton setText:isPlaying?
         ORKLocalizedString(@"SPEECH_IN_NOISE_PREDEFINED_STOP_AUDIO_SAMPLE", nil):
         ORKLocalizedString(@"SPEECH_IN_NOISE_PREDEFINED_PLAY_AUDIO_SAMPLE", nil)];
        
        [self.playbackButton setNormalTintColor:isPlaying? [UIColor ork_redColor] : self.tintColor];
        
        UIImage *image;
        if (@available(iOS 13.0, *)) {
            image = isPlaying?
            [UIImage systemImageNamed:@"stop.circle"]:
            [UIImage systemImageNamed:@"play.circle"];
            [self.playbackButton setImage:image];
        }
        
        if (isPlaying)
        {
            CAAnimation *animation = [self pulseAnimationWithDuration:ORKVolumeCalibrationStepPlaybackButtonPulseDuration
                                                             variance:ORKVolumeCalibrationStepPlaybackButtonPulseVariance];
            [self.playbackButton.iconImageView.layer addAnimation:animation forKey:@"pulse"];
        }
        else
        {
            [self.playbackButton.iconImageView.layer removeAnimationForKey:@"pulse"];
        }
    }
}

@end
