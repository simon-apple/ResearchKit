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

#if RK_APPLE_INTERNAL

#import "ORKTinnitusTypeContentView.h"
#import "ORKHelpers_Internal.h"
#import "ORKAnswerTextField.h"
#import "ORKTinnitusTypes.h"
#import "ORKTinnitusPredefinedTask.h"
#import "ORKTinnitusButtonView.h"
#import "ORKTinnitusAudioSample.h"
#import "ORKSkin.h"

#import "ORKCheckmarkView.h"

#import "ORKContext+ActiveTask.h"

@interface ORKTinnitusTypeContentView () {
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
            [self addSubview:sampleButton];
            [sampleButton.leadingAnchor constraintEqualToAnchor:self.leadingAnchor].active = YES;
            [sampleButton.trailingAnchor constraintEqualToAnchor:self.trailingAnchor].active = YES;
            [sampleButton.topAnchor constraintEqualToAnchor:self.topAnchor constant:5.0].active = YES;
        } else {
            sampleButton.translatesAutoresizingMaskIntoConstraints = NO;
            [self addSubview:sampleButton];
            [sampleButton.leadingAnchor constraintEqualToAnchor:self.leadingAnchor].active = YES;
            [sampleButton.trailingAnchor constraintEqualToAnchor:self.trailingAnchor].active = YES;
            [sampleButton.topAnchor constraintEqualToAnchor:latestButtonView.bottomAnchor constant: 16.0].active = YES;
        }
        [buttons addObject:sampleButton];
        latestButtonView = sampleButton;
    }
    [latestButtonView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor].active = YES;
    
    _buttonsViewArray = [buttons copy];
    
    self.translatesAutoresizingMaskIntoConstraints = NO;
    
    self.clipsToBounds = NO;
    
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

- (void)selectButton:(ORKTinnitusButtonView *)buttonView
{
    NSArray *unselectArray = [_buttonsViewArray
                              filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id object, NSDictionary *bindings) {
        return (object != buttonView);
    }]];
    [unselectArray makeObjectsPerformSelector:@selector(restoreButton)];
    _selectedButtonView = buttonView;
    
    UIScrollView *scrollView = [self getScrollSuperviewFor:self];

    if (_selectedButtonView.isSimulatedTap) {
        CGRect buttonRect = [scrollView convertRect:_selectedButtonView.bounds fromView:_selectedButtonView];
        CGRect buttonCenterRect = CGRectMake(buttonRect.origin.x,
                                             buttonRect.origin.y - ((scrollView.bounds.size.height - buttonRect.size.height)/2),
                                             buttonRect.size.width,
                                             scrollView.bounds.size.height);
        
        [scrollView scrollRectToVisible:buttonCenterRect animated:YES];
    }
}

- (void)enableButtons:(BOOL)enable {
    for (ORKTinnitusButtonView *button in _buttonsViewArray) {
        [button setUserInteractionEnabled:enable];
    }
}

- (nullable NSString *)getAnswer {
    return _selectedButtonView.answer;
}

- (ORKTinnitusType)getType {
    return [_context.audioManifest noiseTypeSampleWithIdentifier:_selectedButtonView.answer error:nil].type;
}

-(UIScrollView *)getScrollSuperviewFor:(UIView *)view {
    UIView *superview = view.superview;
    if (superview) {
        if ([superview isKindOfClass:[UIScrollView class]]) {
            return (UIScrollView *)superview;
        }
        return [self getScrollSuperviewFor:superview];
    }
    return nil;
}

@end

#endif
