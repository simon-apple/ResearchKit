/*
 Copyright (c) 2022, Apple Inc. All rights reserved.
 
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

#import "ORKdBHLToneAudiometryMethodOfAdjustmentContentView.h"
#import "ORKIUtils.h"
#import <ResearchKit/ResearchKit-Swift.h>
#import <ResearchKitInternal/ResearchKitInternal-Swift.h>
#import <ResearchKit/ORKHelpers_Internal.h>

static const NSInteger ORKdBHLToneAudiometryMethodOfAdjustmentContentViewDBStepsNum = 28;
static const double ORKdBHLToneAudiometryMethodOfAdjustmentContentViewSliderMargin = 16.0;

@interface ORKdBHLToneAudiometryMethodOfAdjustmentContentView ()

@end

@implementation ORKdBHLToneAudiometryMethodOfAdjustmentContentView {
    NSLayoutConstraint *_topToProgressViewConstraint;
    NSInteger _minimumValue;
    NSInteger _maximumValue;
    
    NSInteger _currentMinimumValue;
    NSInteger _currentMaximumValue;
    
    NSInteger _numDBSteps;
    
    float _selectedValue;
        
    float _initialValue;
    float _stepSize;
    
    ORKAudiometryTimestampProvider _getTimestamp;

    UIView *_sliderView;
    ORKIdBHLToneAudiometryMethodOfAdjustmentSwiftUIFactory *_swiftUIFactory;
    int _currentSliderValue;
}

@synthesize timestampProvider;

- (instancetype)initWithValue:(float)value minimum:(NSInteger)minimum maximum:(NSInteger)maximum stepSize:(float)stepSize numFrequencies:(NSInteger)numFrequencies audioChannel:(ORKAudioChannel)audioChannel {
    self = [super init];
    if (self) {
        _initialValue = value;
        _minimumValue = minimum;
        _maximumValue = maximum;
        _currentMinimumValue = minimum;
        _currentMaximumValue = maximum;
        
        _numDBSteps = ORKdBHLToneAudiometryMethodOfAdjustmentContentViewDBStepsNum;
        
        _stepSize = stepSize;
        
        _getTimestamp = ^NSTimeInterval{
            return 0;
        };
    
        [self setupSliderViewWithNumFrequencies:numFrequencies audioChannel:audioChannel];

        [[NSNotificationCenter defaultCenter] addObserver:self
             selector:@selector(receiveSliderNotification:)
             name:@"sliderValueChanged"
             object:nil];
                
        _currentSliderValue = value;
        _sliderView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_sliderView];
        
        self.userInteractions = [[NSMutableArray alloc] init];
        
        self.backgroundColor = UIColor.clearColor;

        self.translatesAutoresizingMaskIntoConstraints = NO;
        
        [self setUpConstraints];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)receiveSliderNotification:(NSNotification *)notification {
    if ([[notification name] isEqualToString:@"sliderValueChanged"]) {
        NSDictionary *userInfo = notification.userInfo;
        int value = [userInfo[@"sliderValue"] intValue];
        ORKdBHLToneAudiometryMethodOfAdjustmentSourceOfInteraction sourceOfInteraction = [userInfo[@"sourceOfInteraction"] intValue];

        if (value != _currentSliderValue) {
            _currentSliderValue = value;
            if (sourceOfInteraction != ORKdBHLToneAudiometryMethodOfAdjustmentSourceOfInteractionReset) {
                ORKdBHLToneAudiometryMethodOfAdjustmentInteraction *interaction = [[ORKdBHLToneAudiometryMethodOfAdjustmentInteraction alloc] init];
                interaction.sourceOfInteraction = sourceOfInteraction;
                interaction.dBHLValue = [self indexToDBHL:value];
                interaction.timeStamp = _getTimestamp();
                [_userInteractions addObject:interaction];
                if ([self.delegate conformsToProtocol:@protocol(ORKdBHLToneAudiometryMethodOfAdjustmentContentViewDelegate)]
                    && [self.delegate respondsToSelector:@selector(didSelected:)]) {
                    float floatValue = [self indexToDBHL:value];
                    ORK_Log_Info("selectedValue %f", floatValue);
                    _selectedValue = floatValue;
                    [self.delegate didSelected:floatValue];
                }
            }
        }
    }
}

- (void)setupSliderViewWithNumFrequencies:(NSInteger)numFrequencies audioChannel:(ORKAudioChannel)audioChannel {
    _swiftUIFactory = [[ORKIdBHLToneAudiometryMethodOfAdjustmentSwiftUIFactory alloc] init];
    _sliderView = [[_swiftUIFactory makeMethodOfAdjustmentsViewWithNumSteps:_numDBSteps
                                                             numFrequencies:numFrequencies
                                                               audioChannel:audioChannel] view];
    _sliderView.backgroundColor = UIColor.clearColor;
}

- (void)setTimestampProvider:(ORKAudiometryTimestampProvider)provider {
    _getTimestamp = provider;
}

- (float)indexToDBHL:(int)index {
    float abs = ABS(_currentMaximumValue - _currentMinimumValue);
    float stride = abs / ((float)_numDBSteps - 1);
    return (stride * index) + _currentMinimumValue;
}

- (void)resetView {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"resetView" object:nil];
    [_userInteractions removeAllObjects];
}

- (void)setValue:(float)value {
    _initialValue = value;
}

- (void)finishStep:(ORKActiveStepViewController *)viewController {
    [super finishStep:viewController];
}

- (void)setUpConstraints {
    NSArray<NSLayoutConstraint *> *constraints = @[
                                                   [NSLayoutConstraint constraintWithItem:_sliderView
                                                                                attribute:NSLayoutAttributeLeft
                                                                                relatedBy:NSLayoutRelationEqual
                                                                                   toItem:self
                                                                                attribute:NSLayoutAttributeLeft
                                                                               multiplier:1.0
                                                                                 constant:ORKdBHLToneAudiometryMethodOfAdjustmentContentViewSliderMargin],
                                                   [NSLayoutConstraint constraintWithItem:_sliderView
                                                                                attribute:NSLayoutAttributeRight
                                                                                relatedBy:NSLayoutRelationEqual
                                                                                   toItem:self
                                                                                attribute:NSLayoutAttributeRight
                                                                               multiplier:1.0
                                                                                 constant:-ORKdBHLToneAudiometryMethodOfAdjustmentContentViewSliderMargin],
    ];
    
    [NSLayoutConstraint activateConstraints:constraints];
}

@end
