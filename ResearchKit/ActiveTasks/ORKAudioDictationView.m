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

#import "ORKAudioDictationView.h"
#import "SUICFlamesView.h"

static float const ORKAudioDictationViewAveragePowerLevelMaximum = -10;
static float const ORKAudioDictationViewAveragePowerLevelMinimum = -60;
static float const ORKAudioDictationViewAveragePowerLevelSilence = -120;

#define TRANSFORM_RANGE_TO_POWER_LEVEL(x) TransformRange(x, 0, 1, ORKAudioDictationViewAveragePowerLevelMinimum, ORKAudioDictationViewAveragePowerLevelMaximum)
static float TransformRange(float x, float a, float b, float c, float d)
{
    return (x - a) * ((d - c) / (b - a)) + c;
}

@interface ORKAudioDictationView () <SUICFlamesViewDelegate>
@property (nonatomic, strong) SUICFlamesView *flamesView;

/// ORKAudioMetering
@property (nonatomic, copy, nullable) NSArray<NSNumber *> *samples;
@property (nonatomic, assign) float alertThreshold;

/// ORKAudioMeteringView
@property (nonatomic, strong) UIColor *meterColor;
@property (nonatomic, strong, nullable) UIColor *alertColor;
@end

@implementation ORKAudioDictationView

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self _commonInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self _commonInit];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self _commonInit];
    }
    return self;
}

- (void)_commonInit
{
    _meterColor = self.tintColor;
    _alertThreshold = CGFLOAT_MAX;
    
    self.flamesView = [[SUICFlamesView alloc] initWithFrame:CGRectZero screen:UIScreen.mainScreen fidelity:SUICFlamesViewFidelityHigh];
    self.flamesView.mode = SUICFlamesViewModeDictation;
    self.flamesView.state = SUICFlamesViewStateAboutToListen;
    self.flamesView.flamesDelegate = self;
    self.flamesView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.flamesView];
    
    [NSLayoutConstraint activateConstraints:@[
        [self.flamesView.topAnchor constraintEqualToAnchor:self.topAnchor],
        [self.flamesView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor],
        [self.flamesView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor],
        [self.flamesView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor]
    ]];
}

#pragma mark - ORKAudioMetering

- (void)setSamples:(NSArray<NSNumber *> *)samples
{
    _samples = [samples copy];
    
    if (!_samples || _samples.count == 0)
    {
        [self.flamesView setState:SUICFlamesViewStateAboutToListen];
    }
    else
    {
        [self.flamesView setState:SUICFlamesViewStateListening];
    }
}

- (void)setAlertThreshold:(float)alertThreshold
{
    _alertThreshold = alertThreshold;
}

#pragma mark - ORKAudioMeteringView

- (void)setMeterColor:(UIColor *)meterColor
{
    _meterColor = meterColor;
    [self.flamesView setDictationColor:_meterColor];
}

- (void)setAlertColor:(UIColor *)alertColor
{
    _alertColor = alertColor;
}

#pragma mark - SUICFlamesDelegate

- (float)audioLevelForFlamesView:(SUICFlamesView *)flamesView
{
    if (_samples.count > 0)
    {
        NSMutableArray *mutableSamples = [_samples mutableCopy];
        float currentSample = [[mutableSamples lastObject] floatValue];
        [mutableSamples removeLastObject];
        _samples = [mutableSamples copy];
        
        currentSample = TRANSFORM_RANGE_TO_POWER_LEVEL(currentSample);
        
        if (currentSample < ORKAudioDictationViewAveragePowerLevelMinimum)
        {
            currentSample = ORKAudioDictationViewAveragePowerLevelMinimum;
        }
        else if (currentSample > ORKAudioDictationViewAveragePowerLevelMaximum)
        {
            currentSample = ORKAudioDictationViewAveragePowerLevelMinimum;
        }
        
        if (currentSample > _alertThreshold && _alertColor)
        {
            [self.flamesView setDictationColor:_alertColor];
        }
        else
        {
            [self.flamesView setDictationColor:_meterColor];
        }
        
        return currentSample;
    }
    else
    {
        return ORKAudioDictationViewAveragePowerLevelSilence;
    }
}

@end
