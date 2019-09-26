/*
 Copyright (c) 2015, Apple Inc. All rights reserved.
 
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


#import "ORKCompletionStepViewController.h"

#import "ORKCustomStepView_Internal.h"
#import "ORKInstructionStepContainerView.h"
#import "ORKInstructionStepView.h"
#import "ORKNavigationContainerView.h"
#import "ORKStepHeaderView_Internal.h"
#import "ORKStepView_Private.h"
#import "ORKStepContainerView_Private.h"
#import "ORKStepContentView_Private.h"

#import "ORKInstructionStepViewController_Internal.h"
#import "ORKStepViewController_Internal.h"

#import "ORKSkin.h"
#import "ORKHelpers_Internal.h"


@implementation ORKCompletionCheckmarkView {
    CAShapeLayer *_shapeLayer;
    CGFloat tickViewSize;

}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        tickViewSize = ORKStepContentIconImageViewDimension;
        self.layer.cornerRadius = tickViewSize / 2;
        [self tintColorDidChange];
        
        UIBezierPath *path = [UIBezierPath new];
        [path moveToPoint:(CGPoint){0.25*tickViewSize, 0.5*tickViewSize}];
        [path addLineToPoint:(CGPoint){0.43*tickViewSize, 0.7*tickViewSize}];
        [path addLineToPoint:(CGPoint){0.77*tickViewSize, 0.27*tickViewSize}];
        path.lineCapStyle = kCGLineCapRound;
    
        CAShapeLayer *shapeLayer = [CAShapeLayer new];
        shapeLayer.path = path.CGPath;
        shapeLayer.lineWidth = 0.08*tickViewSize;
        shapeLayer.lineCap = kCALineCapRound;
        shapeLayer.lineJoin = kCALineJoinRound;
        shapeLayer.frame = self.layer.bounds;
        shapeLayer.strokeColor = [UIColor whiteColor].CGColor;
        shapeLayer.backgroundColor = [UIColor clearColor].CGColor;
        shapeLayer.fillColor = nil;
        [self.layer addSublayer:shapeLayer];
        _shapeLayer = shapeLayer;
        
        self.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _shapeLayer.frame = self.layer.bounds;
}

- (CGSize)intrinsicContentSize {
    return (CGSize){tickViewSize, tickViewSize};
}

- (CGSize)sizeThatFits:(CGSize)size {
    return [self intrinsicContentSize];
}

- (void)tintColorDidChange {
    self.backgroundColor = [self tintColor];
}

- (void)setAnimationPoint:(CGFloat)animationPoint {
    _shapeLayer.strokeEnd = animationPoint;
    _animationPoint = animationPoint;
}

- (void)setAnimationPoint:(CGFloat)animationPoint animated:(BOOL)animated {
    CAMediaTimingFunction *timing = [[CAMediaTimingFunction alloc] initWithControlPoints:0.180739998817444 :0 :0.577960014343262 :0.918200016021729];
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    [animation setTimingFunction:timing];
    [animation setFillMode:kCAFillModeBoth];
    animation.fromValue = @([(CAShapeLayer *)[_shapeLayer presentationLayer] strokeEnd]);
    animation.toValue = @(animationPoint);
    
    animation.duration = 0.3;
    _animationPoint = animationPoint;
    
    _shapeLayer.strokeEnd = animationPoint;
    [_shapeLayer addAnimation:animation forKey:@"strokeEnd"];
    
}

- (BOOL)isAccessibilityElement {
    return YES;
}

- (UIAccessibilityTraits)accessibilityTraits {
    return [super accessibilityTraits] | UIAccessibilityTraitImage;
}

- (NSString *)accessibilityLabel {
    return ORKLocalizedString(@"AX_COMPLETION_ILLUSTRATION", nil);
}

@end

@implementation ORKCompletionStepViewController {
    ORKCompletionCheckmarkView *_completionCheckmarkView;
}

- (void)stepDidChange {
    [super stepDidChange];
    
    self.cancelButtonItem = nil;
    _completionCheckmarkView = [self.stepView.stepContentView completionCheckmarkView];
    [_completionCheckmarkView setNeedsLayout];
    if (self.checkmarkColor) {
        _completionCheckmarkView.tintColor = self.checkmarkColor;
    }
    self.stepView.customContentFillsAvailableSpace = YES;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    _completionCheckmarkView.animationPoint = animated ? 0 : 1;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (animated) {
        [_completionCheckmarkView setAnimationPoint:1 animated:YES];
    }
}

- (void)setCheckmarkColor:(UIColor *)checkmarkColor {
    _checkmarkColor = [checkmarkColor copy];
    _completionCheckmarkView.tintColor = checkmarkColor;
}

@end
