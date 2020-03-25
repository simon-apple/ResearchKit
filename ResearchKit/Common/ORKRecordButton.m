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

#import "ORKRecordButton.h"
#import "ORKHelpers_Internal.h"

@implementation ORKRecordButton
{
    ORKRecordButtonType _currentType;
    CAShapeLayer *_ringLayer;
    CAShapeLayer *_shapeLayer;
    CGPathRef _ringPath;
    CGPathRef _recordPath;
    CGPathRef _playPath;
    CGPathRef _stopPath;
    UILabel *_textLabel;
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        [NSLayoutConstraint activateConstraints:@[
            [self.heightAnchor constraintEqualToConstant:67.0],
            [self.widthAnchor constraintEqualToConstant:57.0]
        ]];
        
        [self setupRingLayer];
        [self setupShapeLayer];
        [self setupTextLabel];
        
        [self addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

- (void)buttonPressed:(id)sender
{
    if ([self.delegate conformsToProtocol:@protocol(ORKRecordButtonDelegate)] && [self.delegate respondsToSelector:@selector(buttonPressed:)])
    {
        [self.delegate buttonPressed:self];
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat minY = CGRectGetMinY(self.frame);
    CGFloat midX = CGRectGetMidX(self.frame);
    CGPoint anchorPoint = CGPointMake(midX, minY);
    
    _ringLayer.anchorPoint = CGPointMake(0.5, 0.0);
    _ringLayer.position = [self.superview convertPoint:anchorPoint toView:self];

    _shapeLayer.anchorPoint = CGPointMake(0.5, 0.0);
    _shapeLayer.position = [self.superview convertPoint:anchorPoint toView:self];
}

- (void)setupRingLayer
{
    _ringLayer = [CAShapeLayer layer];
    _ringLayer.path = [self ringPath];
    _ringLayer.fillColor = [[UIColor clearColor] CGColor];
    _ringLayer.strokeColor = [[UIColor systemRedColor] CGColor];
    _ringLayer.lineWidth = 2.0;
    [self.layer addSublayer:_ringLayer];
}

- (void)setupShapeLayer
{
    _shapeLayer = [CAShapeLayer layer];
    [self setButtonType:ORKRecordButtonTypeRecord];
    _shapeLayer.fillColor = [[UIColor systemRedColor] CGColor];
    [self.layer addSublayer:_shapeLayer];
}

- (void)setupTextLabel
{
    _textLabel = [[UILabel alloc] init];
    _textLabel.text = [self localizedTitleForType:_buttonType];
    _textLabel.textAlignment = NSTextAlignmentCenter;
    _textLabel.font = [self bodyTextFont];
    _textLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:_textLabel];
    
    [NSLayoutConstraint activateConstraints:@[
        [_textLabel.leadingAnchor constraintEqualToAnchor:self.leadingAnchor],
        [_textLabel.trailingAnchor constraintEqualToAnchor:self.trailingAnchor],
        [_textLabel.bottomAnchor constraintEqualToAnchor:self.bottomAnchor]
    ]];
}

- (UIFont *)bodyTextFont
{
    UIFontDescriptor *descriptor = [UIFontDescriptor preferredFontDescriptorWithTextStyle:UIFontTextStyleBody];
    return [UIFont fontWithDescriptor:descriptor size:[[descriptor objectForKey: UIFontDescriptorSizeAttribute] doubleValue]];
}

- (CGPathRef)ringPath
{
    if (!_ringPath)
    {
        _ringPath = [self newCirclePathWithRadius:28.5];
    }
    return _ringPath;
}

- (CGPathRef)recordPath
{
    if (!_recordPath)
    {
        _recordPath = [self newCirclePathWithRadius:25];
    }
    return _recordPath;
}

- (CGPathRef)playPath
{
    if (!_playPath)
    {
        _playPath = [self newTrianglePathWithSize:22 radius:1];
    }
    return _playPath;
}

- (CGPathRef)stopPath
{
    if (!_stopPath)
    {
        _stopPath = [self newSquirclePathWithLength:22 cornerRadius:3];
    }
    return _stopPath;
}

- (CGPathRef)pathForType:(ORKRecordButtonType)type
{
    switch (type)
    {
        case ORKRecordButtonTypePlay:
            return [self playPath];
            
        case ORKRecordButtonTypeStop:
            return [self stopPath];
            
        case ORKRecordButtonTypeRecord:
            return [self recordPath];
    }
}

- (NSString *)localizedTitleForType:(ORKRecordButtonType)type
{
    switch (type)
    {
        case ORKRecordButtonTypePlay:
            return ORKLocalizedString(@"PLAY", nil);
            
        case ORKRecordButtonTypeStop:
            return ORKLocalizedString(@"STOP", nil);
            
        case ORKRecordButtonTypeRecord:
            return ORKLocalizedString(@"RECORD", nil);
    }
}

- (void)setButtonType:(ORKRecordButtonType)type
{
    [self setButtonType:type animated:NO];
}

- (void)setButtonType:(ORKRecordButtonType)type animated:(BOOL)animated
{
    CGPathRef path = [self pathForType:type];
    
    if (animated)
    {
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"path"];
        animation.fromValue = (__bridge id _Nullable)(_shapeLayer.path);
        animation.toValue = (__bridge id _Nullable)(path);
        animation.duration = 0.2;
        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        [_shapeLayer addAnimation:animation forKey:@"animatePath"];
    }
    
    _shapeLayer.path = path;
    _buttonType = type;
    _textLabel.text = [self localizedTitleForType:type];
}

- (CGPathRef)newCirclePathWithRadius:(CGFloat)radius
{
    CGPoint A = CGPointMake(-radius, 0);
    CGPoint B = CGPointMake(-radius, -radius);
    CGPoint C = CGPointMake(radius, -radius);
    CGPoint D = CGPointMake(radius, radius);
    CGPoint E = CGPointMake(-radius, radius);
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, A.x, A.y);
    CGPathAddArcToPoint(path, NULL, A.x, A.y, B.x,B.y, radius);
    CGPathAddArcToPoint(path, NULL, B.x, B.y, C.x, C.y, radius);
    CGPathAddArcToPoint(path, NULL, C.x, C.y, D.x, D.y, radius);
    CGPathAddArcToPoint(path, NULL, D.x, D.y, E.x, E.y, radius);
    CGPathAddArcToPoint(path, NULL, E.x, E.y, A.x, A.y, radius);
    CGPathCloseSubpath(path);
    
    return path;
}

- (CGPathRef)newSquirclePathWithLength:(CGFloat)length cornerRadius:(CGFloat)cornerRadius
{
    CGFloat minX = -0.5 * length;
    CGFloat maxX =  0.5 * length;
    CGFloat minY = -0.5 * length;
    CGFloat midY =  0.0;
    CGFloat maxY =  0.5 * length;
    
    CGPoint A = CGPointMake(minX, midY);
    CGPoint B = CGPointMake(minX, minY);
    CGPoint C = CGPointMake(maxX, minY);
    CGPoint D = CGPointMake(maxX, maxY);
    CGPoint E = CGPointMake(minX, maxY);
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, A.x, A.y);
    CGPathAddArcToPoint(path, NULL, A.x, A.y, B.x,B.y, cornerRadius);
    CGPathAddArcToPoint(path, NULL, B.x, B.y, C.x, C.y, cornerRadius);
    CGPathAddArcToPoint(path, NULL, C.x, C.y, D.x, D.y, cornerRadius);
    CGPathAddArcToPoint(path, NULL, D.x, D.y, E.x, E.y, cornerRadius);
    CGPathAddArcToPoint(path, NULL, E.x, E.y, A.x, A.y, cornerRadius);
    CGPathCloseSubpath(path);
    
    return path;
}


- (CGPathRef)newTrianglePathWithSize:(CGFloat)size radius:(CGFloat)radius
{
    CGFloat translation = 0.1 * size;
    CGFloat minX = -(size / 2) + translation;
    CGFloat maxX =  (size / 2) + translation;
    CGFloat minY = -(size / 2);
    CGFloat midY =  0.0;
    CGFloat maxY =  (size / 2);
    
    CGPoint A = CGPointMake(minX, midY);
    CGPoint B = CGPointMake(minX, minY);
    CGPoint C = CGPointMake(maxX, midY);
    CGPoint D = CGPointMake(minX, maxY);
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, A.x, A.y);
    CGPathAddArcToPoint(path, NULL, A.x, A.y, B.x, B.y, radius);
    CGPathAddArcToPoint(path, NULL, B.x, B.y, C.x, C.y, radius);
    CGPathAddArcToPoint(path, NULL, C.x, C.y, D.x, D.y, radius);
    CGPathAddArcToPoint(path, NULL, D.x, D.y, A.x, A.y, radius);
    CGPathCloseSubpath(path);

    return path;
}

@end
