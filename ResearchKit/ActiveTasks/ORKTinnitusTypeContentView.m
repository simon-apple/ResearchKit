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

#import "ORKTinnitusTypeContentView.h"
#import "ORKHelpers_Internal.h"
#import "ORKAnswerTextField.h"
#import "ORKTinnitusTypes.h"
#import "ORKTinnitusPredefinedTask.h"
#import "ORKTinnitusButtonView.h"
#import "ORKTinnitusAudioSample.h"
#import "ORKSkin.h"

#import "ORKCheckmarkView.h"

static const CGFloat ORKTinnitusGlowAdjustment = 16.0;

@interface ORKTinnitusTypeContentView () {
    UIScrollView *_scrollView;
    ORKTinnitusButtonView *_selectedButtonView;
    ORKTinnitusPredefinedTaskContext *_context;
}

@end

@implementation ORKTinnitusTypeContentView

- (instancetype)initWithContext:(ORKTinnitusPredefinedTaskContext *)context {
    self = [super init];
    if (self) {
        _context = context;
        [self commonInit];
    }
    
    return self;
}

- (void)commonInit
{
    [self setupScrollView];
    _selectedButtonView = nil;
    
    NSMutableArray *buttons = [[NSMutableArray alloc] init];
    ORKTinnitusButtonView *latestButtonView = nil;
    ORKTinnitusButtonView *sampleButton = nil;
    for (ORKTinnitusAudioSample *noiseTypeSample in _context.audioManifest.noiseTypeSamples) {
        sampleButton = [[ORKTinnitusButtonView alloc]
                        initWithTitle:noiseTypeSample.name
                        detail:nil answer:noiseTypeSample.identifier];
        if (latestButtonView == nil) {
            sampleButton.translatesAutoresizingMaskIntoConstraints = NO;
            [_scrollView addSubview:sampleButton];
            [sampleButton.leadingAnchor constraintEqualToAnchor:_scrollView.leadingAnchor constant:ORKTinnitusGlowAdjustment].active = YES;
            [sampleButton.trailingAnchor constraintEqualToAnchor:_scrollView.trailingAnchor constant:-ORKTinnitusGlowAdjustment].active = YES;
            [sampleButton.widthAnchor constraintEqualToAnchor:_scrollView.widthAnchor constant:-2*ORKTinnitusGlowAdjustment].active = YES;
            [sampleButton.topAnchor constraintEqualToAnchor:_scrollView.topAnchor constant:5.0].active = YES;
        } else {
            sampleButton.translatesAutoresizingMaskIntoConstraints = NO;
            [_scrollView addSubview:sampleButton];
            [sampleButton.leadingAnchor constraintEqualToAnchor:_scrollView.leadingAnchor constant:ORKTinnitusGlowAdjustment].active = YES;
            [sampleButton.trailingAnchor constraintEqualToAnchor:_scrollView.trailingAnchor constant:-ORKTinnitusGlowAdjustment].active = YES;
            [sampleButton.topAnchor constraintEqualToAnchor:latestButtonView.bottomAnchor constant: 16.0].active = YES;
        }
        [buttons addObject:sampleButton];
        latestButtonView = sampleButton;
    }
    
    _buttonsViewArray = [buttons copy];
    
    self.translatesAutoresizingMaskIntoConstraints = NO;
    
    self.clipsToBounds = NO;
    
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    ORKTinnitusButtonView *lastButton = [_buttonsViewArray lastObject];
    if (lastButton != nil) {
        _scrollView.contentSize = CGSizeMake(_scrollView.frame.size.width, lastButton.frame.origin.y + lastButton.frame.size.height + 32.0);
    }
}

- (void)setupScrollView {
    if (!_scrollView) {
        _scrollView = [UIScrollView new];
    }
    [self addSubview:_scrollView];
    _scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    [[_scrollView.topAnchor constraintEqualToAnchor:self.topAnchor] setActive:YES];
    [[_scrollView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:-ORKTinnitusGlowAdjustment] setActive:YES];
    [[_scrollView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:ORKTinnitusGlowAdjustment] setActive:YES];
    [[_scrollView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor] setActive:YES];
    
    _scrollView.scrollEnabled = YES;
}

- (void)selectButton:(ORKTinnitusButtonView *)buttonView
{
    NSArray *unselectArray = [_buttonsViewArray
                              filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id object, NSDictionary *bindings) {
        return (object != buttonView);
    }]];
    [unselectArray makeObjectsPerformSelector:@selector(restoreButton)];
    _selectedButtonView = buttonView;
}

- (nullable NSString *)getAnswer {
    return _selectedButtonView.answer;
}

- (ORKTinnitusType)getType {
    return [_context.audioManifest noiseTypeSampleWithIdentifier:_selectedButtonView.answer error:nil].type;
}

@end
