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


#import "ORKFaceDetectionStepContentView.h"
#import "ORKUnitLabel.h"
#import "ORKHelpers_Internal.h"
#import "ORKSkin.h"
#import "ORKBorderedButton.h"
#import "ORKDetectionOverlayView.h"
#import "ORKTitleLabel.h"
#import "ORKBodyLabel.h"
#import "ORKIconButton.h"
#import "ORKStepHeaderView_Internal.h"
#import <CoreImage/CoreImage.h>
#import <SceneKit/SceneKit.h>
#import <ARKit/ARKit.h>
#import <AVFoundation/AVFoundation.h>

static const CGFloat FaceDetectionDetailLabelTopPadding = 12.0;
static const CGFloat ContentLeftRightPadding = 16.0;
static const CGFloat FaceDetectionTimeLimit = 60.0;
static const CGFloat FaceDetectionRecalibrationTimeLimit = 30.0;

@interface ORKFaceDetectionStepContentView ()
@property (nonatomic, copy, nullable) ORKFaceDetectionStepContentViewEventHandler viewEventhandler;
@end

@implementation ORKFaceDetectionStepContentView {
    ORKStepHeaderView *_headerView;
    
    UIView *_cameraView;
    UIView *_bottomContentView;
    AVCaptureVideoPreviewLayer *_previewLayer;
    
    UIImageView *_facePositionImageView;
    UIImageView *_calibrationBoxImageView;
    UIImageView *_checkmarkImageView;
    
    UILabel *_faceDetectionTitleLabel;
    UILabel *_faceDetectionDetailLabel;
    
    NSTimer *_timer;
    NSTimeInterval _maxRecordingTime;
    CGFloat _recordingTime;
    NSDateComponentsFormatter *_dateComponentsFormatter;
    
    NSTimer *_animateFaceOutTimer;
    
    CGFloat _facePositionImageHeightWidth;
    CGFloat _facePositionImageSmallerHeightWidth;
    
    BOOL _faceDetected;
    BOOL _noFaceDetectedYet;
    BOOL _faceIconIsShowing;
    BOOL _showingForRecalibration;
}

- (instancetype)initForRecalibration:(BOOL)forRecalibration {
    self = [super initWithFrame:CGRectZero];
    self.layoutMargins = ORKStandardFullScreenLayoutMarginsForView(self);
    
    if (self) {
        self.translatesAutoresizingMaskIntoConstraints = NO;
        
        _faceDetected = NO;
        _noFaceDetectedYet = YES;
        _faceIconIsShowing = NO;
        _showingForRecalibration = forRecalibration;
        
        [self setUpSubviews];
        [self setUpConstraints];
        [self startTimerWithMaximumRecordingLimit: _showingForRecalibration ? FaceDetectionRecalibrationTimeLimit : FaceDetectionTimeLimit];
    }
    
    return self;
}

- (void)setUpSubviews {
    _cameraView = [UIView new];
    _cameraView.alpha = 1.0;
    [self addSubview:_cameraView];
    
    _bottomContentView = [UIView new];
    _bottomContentView.alpha = 1.0;
    _bottomContentView.layer.zPosition = 5.0;
    [self addSubview:_bottomContentView];
    
    if (@available(iOS 13.0, *)) {
        [_cameraView setBackgroundColor:[UIColor secondarySystemBackgroundColor]];
        [_bottomContentView setBackgroundColor:[UIColor secondarySystemBackgroundColor]];
     } else {
         [_cameraView setBackgroundColor:[UIColor whiteColor]];
         [_bottomContentView setBackgroundColor:[UIColor whiteColor]];
     }
    
    _faceDetectionTitleLabel = [UILabel new];
    _faceDetectionTitleLabel.font = [self titleLabelFont];
    _faceDetectionTitleLabel.textAlignment = NSTextAlignmentCenter;
    if (!_showingForRecalibration) {
        [_faceDetectionTitleLabel setText:ORKLocalizedString(@"AV_JOURNALING_FACE_DETECTION_STEP_NO_FACE_DETECTED_TITLE", "")];
    } else {
        [_faceDetectionTitleLabel setText:ORKLocalizedString(@"AV_JOURNALING_FACE_DETECTION_STEP_NO_FACE_DETECTED_TITLE_RECALIBRATION", "")];
    }
    
    [_bottomContentView addSubview:_faceDetectionTitleLabel];
    
    _faceDetectionDetailLabel = [UILabel new];
    _faceDetectionDetailLabel.font = [self detailTextLabelFont];
    _faceDetectionDetailLabel.textAlignment = NSTextAlignmentCenter;
    _faceDetectionDetailLabel.numberOfLines = 0;
    _faceDetectionDetailLabel.lineBreakMode = NSLineBreakByWordWrapping;

    if (!_showingForRecalibration) {
        [_faceDetectionDetailLabel setText:ORKLocalizedString(@"AV_JOURNALING_FACE_DETECTION_STEP_NO_FACE_DETECTED_TEXT", "")];
    } else {
        [_faceDetectionDetailLabel setText:ORKLocalizedString(@"AV_JOURNALING_FACE_DETECTION_STEP_NO_FACE_DETECTED_TEXT_RECALIBRATION", "")];
    }
    
    [_bottomContentView addSubview:_faceDetectionDetailLabel];
        
    UIImage *calibrationImage = [UIImage imageNamed:@"GuideCorners" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
    _calibrationBoxImageView = [UIImageView new];
    _calibrationBoxImageView.image = [calibrationImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [_calibrationBoxImageView setTintColor:[UIColor systemGrayColor]];
    
    _facePositionImageView = [UIImageView new];
    _facePositionImageView.image = [UIImage imageNamed:@"Face" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
    [_facePositionImageView.layer setOpacity:0.0];
}

- (void)layoutSubviews {
    if (_cameraView.frame.size.height != 0) {
        [self layoutFacePositionViews];
    }
}

- (void)setUpConstraints {
    _cameraView.translatesAutoresizingMaskIntoConstraints = NO;
    _bottomContentView.translatesAutoresizingMaskIntoConstraints = NO;
    _faceDetectionTitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _faceDetectionDetailLabel.translatesAutoresizingMaskIntoConstraints = NO;
    
    [[_cameraView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor] setActive:YES];
    [[_cameraView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor] setActive:YES];
    [[_cameraView.topAnchor constraintEqualToAnchor:self.topAnchor] setActive:YES];
    [[_cameraView.bottomAnchor constraintEqualToAnchor:self.centerYAnchor] setActive:YES];
    
    [[_bottomContentView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor] setActive:YES];
    [[_bottomContentView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor] setActive:YES];
    [[_bottomContentView.topAnchor constraintEqualToAnchor:self.centerYAnchor] setActive:YES];
    [[_bottomContentView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor] setActive:YES];
    
    [[_faceDetectionTitleLabel.topAnchor constraintEqualToAnchor:_bottomContentView.topAnchor] setActive:YES];
    [[_faceDetectionTitleLabel.centerXAnchor constraintEqualToAnchor:_bottomContentView.centerXAnchor] setActive:YES];
    
    [[_faceDetectionDetailLabel.leadingAnchor constraintEqualToAnchor:_bottomContentView.leadingAnchor constant:ContentLeftRightPadding] setActive:YES];
    [[_faceDetectionDetailLabel.trailingAnchor constraintEqualToAnchor:_bottomContentView.trailingAnchor constant:-ContentLeftRightPadding] setActive:YES];
    [[_faceDetectionDetailLabel.topAnchor constraintEqualToAnchor:_faceDetectionTitleLabel.bottomAnchor constant:FaceDetectionDetailLabelTopPadding] setActive:YES];
}

- (void)layoutFacePositionViews {
    if (_cameraView.frame.size.height != 0 && _calibrationBoxImageView.frame.size.height == 0) {
        _calibrationBoxImageView.translatesAutoresizingMaskIntoConstraints = NO;
        [_cameraView addSubview:_calibrationBoxImageView];
    
        _facePositionImageView.translatesAutoresizingMaskIntoConstraints = NO;
        [_cameraView addSubview:_facePositionImageView];
        
        CGFloat calibrationBoxWidth = _cameraView.frame.size.width * 0.70;
        CGFloat calibrationBoxHeight = _cameraView.frame.size.height * 0.70;
        _facePositionImageHeightWidth = calibrationBoxHeight * 0.45;
        _facePositionImageSmallerHeightWidth = _facePositionImageHeightWidth * 0.70;
        
        [[_calibrationBoxImageView.heightAnchor constraintEqualToConstant:calibrationBoxHeight] setActive:YES];
        [[_calibrationBoxImageView.widthAnchor constraintEqualToConstant:calibrationBoxWidth] setActive:YES];
        [[_calibrationBoxImageView.centerXAnchor constraintEqualToAnchor:_cameraView.centerXAnchor] setActive:YES];
        
        if (_showingForRecalibration) {
            [[_calibrationBoxImageView.topAnchor constraintEqualToAnchor:_cameraView.topAnchor] setActive:YES];
        } else {
            [[_calibrationBoxImageView.centerYAnchor constraintEqualToAnchor:_cameraView.centerYAnchor] setActive:YES];
        }
        
        [[_facePositionImageView.heightAnchor constraintEqualToConstant:_facePositionImageSmallerHeightWidth] setActive:YES];
        [[_facePositionImageView.widthAnchor constraintEqualToConstant:_facePositionImageSmallerHeightWidth] setActive:YES];
        [[_facePositionImageView.centerXAnchor constraintEqualToAnchor:_cameraView.centerXAnchor] setActive:YES];
        [[_facePositionImageView.centerYAnchor constraintEqualToAnchor:_cameraView.centerYAnchor] setActive:YES];
    }
}

- (void)setViewEventHandler:(ORKFaceDetectionStepContentViewEventHandler)handler {
    self.viewEventhandler = [handler copy];
}

- (void)invokeViewEventHandlerWithEvent:(ORKFaceDetectionStepContentViewEvent)event {
    if (self.viewEventhandler) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.viewEventhandler(event);
        });
    }
}

- (void)setPreviewLayerWithSession:(AVCaptureSession *)session {
    _previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:session];
    _previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    _previewLayer.needsDisplayOnBoundsChange = YES;
    _previewLayer.connection.videoOrientation = AVCaptureVideoOrientationPortrait;
    
    [_cameraView.layer addSublayer:_previewLayer];
}

- (void)setFaceDetected:(BOOL)detected faceRect:(CGRect)faceRect originalSize:(CGSize)originalSize {
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        if (detected && [self isFacePositionCircleWithinBox:faceRect originalSize:originalSize]) {
        
            [self updateDetectionTitleLabelAttributedText];
            [_faceDetectionDetailLabel setText:ORKLocalizedString(@"AV_JOURNALING_FACE_DETECTION_STEP_FACE_DETECTED_TEXT", "")];
            [_calibrationBoxImageView setTintColor:[UIColor greenColor]];
          
            _faceDetected = YES;
            _noFaceDetectedYet = NO;
            
            if (!_faceIconIsShowing) {
                [self animateInFaceIcon];
            }
            
            if (_animateFaceOutTimer) {
                [_animateFaceOutTimer invalidate];
                _animateFaceOutTimer = nil;
            }
        } else if (!_noFaceDetectedYet) {
            
            _faceDetectionTitleLabel.attributedText = nil;
            if (!_showingForRecalibration) {
                [_faceDetectionTitleLabel setText:ORKLocalizedString(@"AV_JOURNALING_FACE_DETECTION_STEP_NO_FACE_DETECTED_TITLE", "")];
                [_faceDetectionDetailLabel setText:ORKLocalizedString(@"AV_JOURNALING_FACE_DETECTION_STEP_NO_FACE_DETECTED_TEXT", "")];
            } else {
                [_faceDetectionTitleLabel setText:ORKLocalizedString(@"AV_JOURNALING_FACE_DETECTION_STEP_NO_FACE_DETECTED_TITLE_RECALIBRATION", "")];
                [_faceDetectionDetailLabel setText:ORKLocalizedString(@"AV_JOURNALING_FACE_DETECTION_STEP_NO_FACE_DETECTED_TEXT_RECALIBRATION", "")];
            }
            [_calibrationBoxImageView setTintColor:[UIColor systemGrayColor]];
            
            _faceDetected = NO;
            
            if (_faceIconIsShowing && !_animateFaceOutTimer) {
                _animateFaceOutTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                                        target:self
                                                                      selector:@selector(animateOutFaceIcon)
                                                                      userInfo:nil
                                                                       repeats:NO];

            }
        }
    });
}

- (void)updateDetectionTitleLabelAttributedText {
    NSString *separatorString = @":";
    NSString *stringtoParse =  !_showingForRecalibration ? ORKLocalizedString(@"AV_JOURNALING_FACE_DETECTION_STEP_FACE_DETECTED_TITLE", "") : ORKLocalizedString(@"AV_JOURNALING_FACE_DETECTION_STEP_FACE_DETECTED_TITLE_RECALIBRATION", "");
    NSString *parsedString = [stringtoParse componentsSeparatedByString:separatorString].firstObject;
    
    if (@available(iOS 13.0, *)) {
        NSString *titleMesssage = [NSString stringWithFormat:@" %@", parsedString];
        NSMutableAttributedString *fullString = [[NSMutableAttributedString alloc] initWithString:titleMesssage];
        NSTextAttachment *imageAttachment = [NSTextAttachment new];
        
        UIImageSymbolConfiguration *imageConfig = [UIImageSymbolConfiguration configurationWithPointSize:25 weight:UIImageSymbolWeightBold];
        UIImage *exclamationMarkImage = [UIImage systemImageNamed:@"checkmark"];
        UIImage *configuredImage = [exclamationMarkImage imageByApplyingSymbolConfiguration:imageConfig];
        
        imageAttachment.image = [configuredImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        
        NSAttributedString *imageString = [NSAttributedString attributedStringWithAttachment:imageAttachment];
        
        [fullString appendAttributedString:imageString];
        
        _faceDetectionTitleLabel.attributedText = fullString;
    } else {
        [_faceDetectionTitleLabel setText:ORKLocalizedString(@"AV_JOURNALING_FACE_DETECTION_STEP_FACE_DETECTED_TITLE", "")];
    }
}

- (void)animateInFaceIcon {
    dispatch_async(dispatch_get_main_queue(), ^(void) {

        UISpringTimingParameters *springTimingParametersForOpacity = [[UISpringTimingParameters alloc] initWithMass:2.0 stiffness:300 damping:50 initialVelocity:CGVectorMake(0, 0)];
        UIViewPropertyAnimator *propertyAnimatorForOpacity = [[UIViewPropertyAnimator alloc] initWithDuration:0.8 timingParameters:springTimingParametersForOpacity];

        [propertyAnimatorForOpacity addAnimations:^{
            [_facePositionImageView.layer setOpacity:1.0];
        }];

        UISpringTimingParameters *springTimingParametersForSize = [[UISpringTimingParameters alloc] initWithMass:2.0 stiffness:300 damping:20 initialVelocity:CGVectorMake(0, 0)];
        UIViewPropertyAnimator *propertyAnimatorForSize = [[UIViewPropertyAnimator alloc] initWithDuration:1.2 timingParameters:springTimingParametersForSize];

        [propertyAnimatorForSize addAnimations:^{
            CGRect currentFrame = _facePositionImageView.layer.frame;
            currentFrame.size.height = _facePositionImageHeightWidth;
            currentFrame.size.width = _facePositionImageHeightWidth;

            [_facePositionImageView.layer setFrame:currentFrame];
        }];

        [propertyAnimatorForOpacity startAnimation];
        [propertyAnimatorForSize startAnimation];
        _faceIconIsShowing = YES;
    });
}

- (void)animateOutFaceIcon {
    dispatch_async(dispatch_get_main_queue(), ^(void) {

        UISpringTimingParameters *springTimingParametersForOpacity = [[UISpringTimingParameters alloc] initWithMass:2.0 stiffness:300 damping:50 initialVelocity:CGVectorMake(0, 0)];
        UIViewPropertyAnimator *propertyAnimatorForOpacity = [[UIViewPropertyAnimator alloc] initWithDuration:0.8 timingParameters:springTimingParametersForOpacity];

        [propertyAnimatorForOpacity addAnimations:^{
            [_facePositionImageView.layer setOpacity:0.0];
        }];

        UISpringTimingParameters *springTimingParametersForSize = [[UISpringTimingParameters alloc] initWithMass:2.0 stiffness:300 damping:50 initialVelocity:CGVectorMake(0, 0)];
        UIViewPropertyAnimator *propertyAnimatorForSize = [[UIViewPropertyAnimator alloc] initWithDuration:0.8 timingParameters:springTimingParametersForSize];

        [propertyAnimatorForSize addAnimations:^{
            CGRect currentFrame = _facePositionImageView.layer.frame;
            currentFrame.size.height = _facePositionImageSmallerHeightWidth;
            currentFrame.size.width = _facePositionImageSmallerHeightWidth;

            [_facePositionImageView.layer setFrame:currentFrame];
        }];

        [propertyAnimatorForOpacity startAnimation];
        [propertyAnimatorForSize startAnimation];
        _faceIconIsShowing = NO;
        _animateFaceOutTimer = nil;
    });
}

- (void)updateFacePositionCircleWithCGRect:(CGRect)rect originalSize:(CGSize)originalSize {
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        [self layoutIfNeeded];
        
        [UIView animateWithDuration:0.4
                         animations:^{
            [_facePositionImageView.layer setPosition:[self getFaceCirclePositionWithFaceRect:rect originalSize:originalSize]];
            [self setNeedsLayout];
        }];
    });
}

- (void)cleanUpView {
    [_timer invalidate];
    _timer = nil;
    [_animateFaceOutTimer invalidate];
    _animateFaceOutTimer = nil;
}

- (void)handleError:(NSError *)error {
    [_cameraView removeFromSuperview];
    [_previewLayer removeFromSuperlayer];
    
    _cameraView = nil;
    _previewLayer = nil;
    
    if (_headerView) {
        [_headerView removeFromSuperview];
        _headerView = nil;
    }
    
    _headerView = [[ORKStepHeaderView alloc] init];
    _headerView.instructionLabel.text = error.localizedDescription;
    [_headerView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self addSubview:_headerView];
    [NSLayoutConstraint activateConstraints:@[
        [_headerView.topAnchor constraintEqualToAnchor:self.safeAreaLayoutGuide.topAnchor],
        [_headerView.leftAnchor constraintEqualToAnchor:self.safeAreaLayoutGuide.leftAnchor],
        [_headerView.rightAnchor constraintEqualToAnchor:self.safeAreaLayoutGuide.rightAnchor],
    ]];
}

- (void)startTimerWithMaximumRecordingLimit:(NSTimeInterval)maximumRecordingLimit {
    if (_timer) {
        [_timer invalidate];
    }
    
    _maxRecordingTime = maximumRecordingLimit;
    _recordingTime = 0.0;
    _timer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                              target:self
                                            selector:@selector(updateRecordingTime)
                                            userInfo:nil
                                             repeats:YES];
}

- (void)updateRecordingTime {
    _recordingTime += _timer.timeInterval;
    
    if (_recordingTime >= _maxRecordingTime) {
        [_timer invalidate];
        [self invokeViewEventHandlerWithEvent:ORKFaceDetectionStepContentViewEventTimeLimitHit];
    }
}

- (NSString *)formattedTimeFromSeconds:(CGFloat)seconds {
    if (!_dateComponentsFormatter) {
        _dateComponentsFormatter = [NSDateComponentsFormatter new];
        _dateComponentsFormatter.zeroFormattingBehavior = NSDateComponentsFormatterZeroFormattingBehaviorPad;
        _dateComponentsFormatter.allowedUnits =  NSCalendarUnitMinute | NSCalendarUnitSecond | NSCalendarUnitNanosecond;
    }
    return [_dateComponentsFormatter stringFromTimeInterval:seconds];
}

- (CGPoint)getFaceCirclePositionWithFaceRect:(CGRect)faceRect originalSize:(CGSize)originalSize {
    CGFloat newWidth = _cameraView.bounds.size.width;
    CGFloat widthAdjustment = originalSize.width / newWidth;
    
    CGFloat newHeight = _cameraView.bounds.size.height;
    CGFloat heightAdjustment = originalSize.height / newHeight;
    
    CGFloat faceOriginX = faceRect.origin.x / widthAdjustment;
    CGFloat faceOriginY = faceRect.origin.y / heightAdjustment;
    
    CGFloat faceRectWidth = faceRect.size.width / widthAdjustment;
    CGFloat faceRectHeight = faceRect.size.height / heightAdjustment;
    
    CGFloat faceCenterX = faceOriginX + (faceRectWidth / 2);
    CGFloat faceCenterY = faceOriginY + (faceRectHeight / 2);
    
    if (_showingForRecalibration) {
        faceCenterY -= ((newHeight - _calibrationBoxImageView.frame.size.height) / 2);
    }
       
    return CGPointMake(faceCenterX, faceCenterY);
}

- (BOOL)isFacePositionCircleWithinBox:(CGRect)rect originalSize:(CGSize)originalSize {
    CGPoint circlePosition = [self getFaceCirclePositionWithFaceRect:rect originalSize:originalSize];
    CGFloat circleRadius = _facePositionImageView.frame.size.width / 2;
    CGFloat viewCenterX = _calibrationBoxImageView.center.x;
    CGFloat viewCenterY = _calibrationBoxImageView.center.y;
    
    BOOL circleIsHorizontallyWithinBox = (circlePosition.x - circleRadius) > viewCenterX - ((_calibrationBoxImageView.frame.size.width) / 2) && (circlePosition.x + circleRadius) < viewCenterX + ((_calibrationBoxImageView.frame.size.width) / 2);
    BOOL circleIsVerticallyWithinBox = (circlePosition.y - circleRadius) >  viewCenterY - ((_calibrationBoxImageView.frame.size.height) / 2) && (circlePosition.y + circleRadius) < viewCenterY + ((_calibrationBoxImageView.frame.size.height) / 2);
    
    return (circleIsHorizontallyWithinBox && circleIsVerticallyWithinBox);
}

- (CGRect)updateFaceRectToPortrait:(CGRect)faceRect originalSize:(CGSize)originalSize {
    CGRect updatedFaceRect = CGRectMake(faceRect.origin.y * originalSize.height,
                                        faceRect.origin.x * originalSize.width,
                                        faceRect.size.height * originalSize.height,
                                        faceRect.size.width * originalSize.width);
    return updatedFaceRect;
}

- (UIFont *)titleLabelFont {
    UIFontDescriptor *descriptor = [UIFontDescriptor preferredFontDescriptorWithTextStyle:UIFontTextStyleTitle1];
    UIFontDescriptor *fontDescriptor = [descriptor fontDescriptorWithSymbolicTraits:(UIFontDescriptorTraitBold)];
    return [UIFont fontWithDescriptor:fontDescriptor size:[[fontDescriptor objectForKey: UIFontDescriptorSizeAttribute] doubleValue]];
}

- (UIFont *)detailTextLabelFont {
    UIFontDescriptor *descriptor = [UIFontDescriptor preferredFontDescriptorWithTextStyle:UIFontTextStyleBody];
    return [UIFont fontWithDescriptor:descriptor size:[[descriptor objectForKey: UIFontDescriptorSizeAttribute] doubleValue]];
}

@end
