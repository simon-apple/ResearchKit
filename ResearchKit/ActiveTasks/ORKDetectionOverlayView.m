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

#import "ORKDetectionOverlayView.h"

typedef NS_CLOSED_ENUM(NSInteger, ORKDetectionLayerCornerType) {
    ORKDetectionLayerCornerTypeTopRight = 0,
    ORKDetectionLayerCornerTypeTopLeft,
    ORKDetectionLayerCornerTypeBottomRight,
    ORKDetectionLayerCornerTypeBottomLeft,
} ORK_ENUM_AVAILABLE;

@implementation ORKDetectionOverlayView {
    CGFloat _centerX;
    CGFloat _centerY;
    CGFloat _widthOffset;
    CGFloat _heightOffset;
    
    CAShapeLayer *_topRightCornerLayer;
    CAShapeLayer *_topLeftCornerLayer;
    CAShapeLayer *_bottomLeftCornerLayer;
    CAShapeLayer *_bottomRightCornerLayer;
    CATextLayer *_timerTextLayer;
    
    BOOL *_faceDetected;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    return self;
}

- (void)createRectsAndLayersForFaceDetection {
    [self setBackgroundColor:[[UIColor whiteColor] colorWithAlphaComponent:0.95]];
    
    _centerX = self.frame.size.width / 2;
    _widthOffset = _centerX - 10;
    _centerY = self.frame.size.height / 2;
    _heightOffset = _centerY - 10;
    
    CGMutablePathRef path = CGPathCreateMutable();
    
    CGPathAddRect(path, nil, CGRectMake(0, 0, self.frame.size.width, self.frame.size.height));
    
    CAShapeLayer *maskLayer = [CAShapeLayer new];
    maskLayer.path = path;
    maskLayer.fillRule = kCAFillRuleEvenOdd;
    
    CFBridgingRelease(path);
    
    self.layer.mask = maskLayer;
    
    _topRightCornerLayer = [self createShapeLayerForCornerType:ORKDetectionLayerCornerTypeTopRight];
    _topLeftCornerLayer = [self createShapeLayerForCornerType:ORKDetectionLayerCornerTypeTopLeft];
    _bottomLeftCornerLayer = [self createShapeLayerForCornerType:ORKDetectionLayerCornerTypeBottomLeft];
    _bottomRightCornerLayer = [self createShapeLayerForCornerType:ORKDetectionLayerCornerTypeBottomRight];
    
    [self.layer addSublayer:_topRightCornerLayer];
    [self.layer addSublayer:_topLeftCornerLayer];
    [self.layer addSublayer:_bottomLeftCornerLayer];
    [self.layer addSublayer:_bottomRightCornerLayer];
    
    [self setClipsToBounds:YES];
}

- (void)createRectsAndLayersForJournalRecording {
    [self setBackgroundColor:[UIColor clearColor]];
    
    _centerX = self.frame.size.width / 2;
    _widthOffset = _centerX - 20;
    _centerY = self.frame.size.height / 2;
    _heightOffset = _centerY - 20;
    
    CGMutablePathRef path = CGPathCreateMutable();
    
    //create outside rect
    CGPathAddRect(path, nil, CGRectMake(0, 0, self.frame.size.width, self.frame.size.height));
    
    CAShapeLayer *maskLayer = [CAShapeLayer new];
    maskLayer.path = path;
    maskLayer.fillRule = kCAFillRuleEvenOdd;
    
    CFBridgingRelease(path);
    
    self.layer.mask = maskLayer;
    
    _topRightCornerLayer = [self createShapeLayerForCornerType:ORKDetectionLayerCornerTypeTopRight];
    _topLeftCornerLayer = [self createShapeLayerForCornerType:ORKDetectionLayerCornerTypeTopLeft];
    _bottomLeftCornerLayer = [self createShapeLayerForCornerType:ORKDetectionLayerCornerTypeBottomLeft];
    _bottomRightCornerLayer = [self createShapeLayerForCornerType:ORKDetectionLayerCornerTypeBottomRight];
    
    [_topRightCornerLayer setFillColor:[[UIColor blackColor] CGColor]];
    [_topLeftCornerLayer setFillColor:[[UIColor blackColor] CGColor]];
    [_bottomLeftCornerLayer setFillColor:[[UIColor blackColor] CGColor]];
    [_bottomRightCornerLayer setFillColor:[[UIColor blackColor] CGColor]];
    
    [self.layer addSublayer:_topRightCornerLayer];
    [self.layer addSublayer:_topLeftCornerLayer];
    [self.layer addSublayer:_bottomLeftCornerLayer];
    [self.layer addSublayer:_bottomRightCornerLayer];
    [self.layer addSublayer:[self createRedRecordingCircle]];
    [self.layer addSublayer:[self createRecordingTextLayer]];
    [self.layer addSublayer:[self createTimerTextLayer]];

    [self setClipsToBounds:YES];
}

- (CAShapeLayer *)createRectangleEdgeLayer {
    UIBezierPath *edgePath = [UIBezierPath new];
    
    [edgePath moveToPoint:CGPointMake(_centerX - _widthOffset - 1, _centerY - _heightOffset - 1)];
    [edgePath addLineToPoint:CGPointMake(_centerX + _widthOffset + 1, _centerY - _heightOffset - 1)];
    [edgePath addLineToPoint:CGPointMake(_centerX + _widthOffset + 1, _centerY + _heightOffset + 1)];
    [edgePath addLineToPoint:CGPointMake(_centerX - _widthOffset - 1, _centerY + _heightOffset + 1)];

    [edgePath closePath];
    
    CAShapeLayer *edgeShapeLayer = [self createStandardShapeLayer];
    edgeShapeLayer.path = edgePath.CGPath;
    
    return edgeShapeLayer;
}

- (CAShapeLayer *)createShapeLayerForCornerType:(ORKDetectionLayerCornerType)cornerType {
    CGFloat xStartingPosition;
    CGFloat yStartingPosition;
    
    UIBezierPath *edgePath = [UIBezierPath new];
    
    switch(cornerType){
        case    ORKDetectionLayerCornerTypeTopRight:
            
            xStartingPosition = _centerX + _widthOffset;
            yStartingPosition = _centerY - _heightOffset;
            
            [edgePath moveToPoint:CGPointMake(xStartingPosition - 20, yStartingPosition - 5)];
            [edgePath addLineToPoint:CGPointMake(xStartingPosition + 5, yStartingPosition - 5)];
            [edgePath addLineToPoint:CGPointMake(xStartingPosition + 5, yStartingPosition + 20)];
            [edgePath addLineToPoint:CGPointMake(xStartingPosition + 10, yStartingPosition + 20)];
            [edgePath addLineToPoint:CGPointMake(xStartingPosition + 10, yStartingPosition - 10)];
            [edgePath addLineToPoint:CGPointMake(xStartingPosition - 20, yStartingPosition - 10)];
            
            break;
        case    ORKDetectionLayerCornerTypeTopLeft:
            xStartingPosition = _centerX - _widthOffset;
            yStartingPosition = _centerY - _heightOffset;
            
            [edgePath moveToPoint:CGPointMake(xStartingPosition + 20, yStartingPosition - 5)];
            [edgePath addLineToPoint:CGPointMake(xStartingPosition - 5, yStartingPosition - 5)];
            [edgePath addLineToPoint:CGPointMake(xStartingPosition - 5, yStartingPosition + 20)];
            [edgePath addLineToPoint:CGPointMake(xStartingPosition - 10, yStartingPosition + 20)];
            [edgePath addLineToPoint:CGPointMake(xStartingPosition - 10, yStartingPosition - 10)];
            [edgePath addLineToPoint:CGPointMake(xStartingPosition + 20, yStartingPosition - 10)];
            break;
            
        case   ORKDetectionLayerCornerTypeBottomLeft:
            xStartingPosition = _centerX - _widthOffset;
            yStartingPosition = _centerY + _heightOffset;
            
            [edgePath moveToPoint:CGPointMake(xStartingPosition + 20, yStartingPosition + 5)];
            [edgePath addLineToPoint:CGPointMake(xStartingPosition - 5, yStartingPosition + 5)];
            [edgePath addLineToPoint:CGPointMake(xStartingPosition - 5, yStartingPosition - 20)];
            [edgePath addLineToPoint:CGPointMake(xStartingPosition - 10, yStartingPosition - 20)];
            [edgePath addLineToPoint:CGPointMake(xStartingPosition - 10, yStartingPosition + 10)];
            [edgePath addLineToPoint:CGPointMake(xStartingPosition + 20, yStartingPosition + 10)];
            
            break;
            
        case   ORKDetectionLayerCornerTypeBottomRight:
            xStartingPosition = _centerX + _widthOffset;
            yStartingPosition = _centerY + _heightOffset;
            
            [edgePath moveToPoint:CGPointMake(xStartingPosition - 20, yStartingPosition + 5)];
            [edgePath addLineToPoint:CGPointMake(xStartingPosition + 5, yStartingPosition + 5)];
            [edgePath addLineToPoint:CGPointMake(xStartingPosition + 5, yStartingPosition - 20)];
            [edgePath addLineToPoint:CGPointMake(xStartingPosition + 10, yStartingPosition - 20)];
            [edgePath addLineToPoint:CGPointMake(xStartingPosition + 10, yStartingPosition + 10)];
            [edgePath addLineToPoint:CGPointMake(xStartingPosition - 20, yStartingPosition + 10)];
            [edgePath closePath];

            break;
    }
    
    
    [edgePath closePath];
    
    CAShapeLayer *edgeShapeLayer = [self createStandardShapeLayer];
    edgeShapeLayer.path = edgePath.CGPath;
    
    return edgeShapeLayer;
}

- (CAShapeLayer *)createStandardShapeLayer {
    CAShapeLayer *shapeLayer = [CAShapeLayer new];
    [shapeLayer setFillColor:[[UIColor grayColor] CGColor]];
    [shapeLayer setBorderColor:[[UIColor grayColor] CGColor]];
    
    return shapeLayer;
}

- (CALayer *)createRedRecordingCircle {
    CAShapeLayer *circleLayer = [CAShapeLayer layer];
    [circleLayer setPath:[[UIBezierPath bezierPathWithOvalInRect:CGRectMake(_centerX - _widthOffset + 15, _centerY - _heightOffset + 15, 20, 20)] CGPath]];
    [circleLayer setFillColor:[UIColor redColor].CGColor];
    
    return circleLayer;
}

- (CATextLayer *)createRecordingTextLayer {
    CATextLayer *textLayer = [CATextLayer new];
    [textLayer setString:@"REC"];
    [textLayer setForegroundColor:[UIColor whiteColor].CGColor];
    [textLayer setFontSize:12.0];
    textLayer.alignmentMode = kCAAlignmentCenter;
    [textLayer setFrame:CGRectMake(_centerX - _widthOffset + 35, _centerY - _heightOffset + 18, 40.0, 12.0)];
    [textLayer setContentsScale:UIScreen.mainScreen.scale];
    
    return textLayer;
}

- (CATextLayer *)createTimerTextLayer {
    _timerTextLayer = [CATextLayer new];
    [_timerTextLayer setString:@"0:00"];
    [_timerTextLayer setForegroundColor:[UIColor whiteColor].CGColor];
    [_timerTextLayer setFontSize:15.0];
    _timerTextLayer.alignmentMode = kCAAlignmentCenter;
    [_timerTextLayer setFrame:CGRectMake(_centerX + _widthOffset - 50, _centerY - _heightOffset + 18, 40.0, 15.0)];
    [_timerTextLayer setContentsScale:UIScreen.mainScreen.scale];
    
    return _timerTextLayer;
}

- (void)updateTimerLabelWithText:(NSString *)text {
    if (_timerTextLayer) {
        [_timerTextLayer setString:text];
    }
}

- (void)wasFaceDetected:(BOOL)faceDetected {
    
    [_topRightCornerLayer setFillColor:faceDetected ? [[UIColor greenColor] CGColor] : [[UIColor redColor] CGColor]];
    [_topLeftCornerLayer setFillColor:faceDetected ? [[UIColor greenColor] CGColor] : [[UIColor redColor] CGColor]];
    [_bottomLeftCornerLayer setFillColor:faceDetected ? [[UIColor greenColor] CGColor] : [[UIColor redColor] CGColor]];
    [_bottomRightCornerLayer setFillColor:faceDetected ? [[UIColor greenColor] CGColor] : [[UIColor redColor] CGColor]];
}

@end




