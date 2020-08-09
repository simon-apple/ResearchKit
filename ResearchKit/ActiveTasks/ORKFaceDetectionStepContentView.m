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


typedef NS_CLOSED_ENUM(NSInteger, ORKFaceDetectionButtonState) {
    ORKFaceDetectionButtonStateFaceDetected = 0,
    ORKFaceDetectionButtonStateNoFaceDetected,
} ORK_ENUM_AVAILABLE;

@interface ORKFaceDetectionBlurFooterView : UIVisualEffectView
- (instancetype)init;

@property (nonatomic) UIButton *startStopButton;
@property (nonatomic) UILabel *timerLabel;

- (void)setStartStopButtonState:(ORKFaceDetectionButtonState)buttonState;

@end


@implementation ORKFaceDetectionBlurFooterView {
    NSMutableArray<NSLayoutConstraint *> *_heightConstraints;
    NSLayoutConstraint *_blurViewTopConstraint;
    
    ORKTitleLabel *_titleLabel;
    ORKBodyLabel *_detailTextLabel;
}

- (instancetype)init {
    self = [super initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
    if (self) {
        [self setupSubviews];
        [self setupConstraints];
        [self setStartStopButtonState:ORKFaceDetectionButtonStateNoFaceDetected];
    }
    return self;
}

- (void)setupSubviews {
    _startStopButton = [UIButton new];
    _startStopButton.layer.cornerRadius = 14.0;
    _startStopButton.clipsToBounds = YES;
    _startStopButton.contentEdgeInsets = (UIEdgeInsets){.left = 6, .right = 6};
    UIFontDescriptor *descriptorOne = [UIFontDescriptor preferredFontDescriptorWithTextStyle:UIFontTextStyleHeadline];
    _startStopButton.titleLabel.font = [UIFont boldSystemFontOfSize:[[descriptorOne objectForKey: UIFontDescriptorSizeAttribute] doubleValue] + 1.0];
    [_startStopButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_startStopButton setTitle:ORKLocalizedString(@"AV_JOURNALING_FACE_DETECTION_STEP_NEXT_BUTTON_TEXT", nil) forState:UIControlStateNormal];
    [self.contentView addSubview:_startStopButton];
    
    _timerLabel = [UILabel new];
    _timerLabel.font = [UIFont systemFontOfSize:15.0];
    _timerLabel.adjustsFontSizeToFitWidth = YES;
    [_timerLabel setTextColor:[UIColor whiteColor]];
    [_timerLabel setText:ORKLocalizedString(@"AV_JOURNALING_FACE_DETECTION_START_TIME", nil)];
    [self.contentView addSubview:_timerLabel];
    
    _titleLabel = [ORKTitleLabel new];
    _titleLabel.textAlignment = NSTextAlignmentLeft;
    _titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    _titleLabel.numberOfLines = 0;
    [_titleLabel setTextColor:[UIColor whiteColor]];
    [self.contentView addSubview:_titleLabel];
    
    _detailTextLabel = [ORKBodyLabel new];
    _detailTextLabel.textAlignment = NSTextAlignmentLeft;
    _detailTextLabel.lineBreakMode = NSLineBreakByWordWrapping;
    _detailTextLabel.numberOfLines = 0;
    [_detailTextLabel setTextColor:[UIColor whiteColor]];
    [self.contentView addSubview:_detailTextLabel];
}

- (void)setupConstraints {
    _startStopButton.translatesAutoresizingMaskIntoConstraints = NO;
    _timerLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _detailTextLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    
    [[_startStopButton.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:20.0] setActive:YES];
    [[_startStopButton.trailingAnchor constraintEqualToAnchor:_timerLabel.leadingAnchor constant:-15.0] setActive:YES];
    [[_startStopButton.bottomAnchor constraintEqualToAnchor:self.contentView.safeAreaLayoutGuide.bottomAnchor constant:-20.0] setActive:YES];
    [[_startStopButton.heightAnchor constraintEqualToConstant:50.0] setActive:YES];
    
    [[_timerLabel.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-20.0] setActive:YES];
    [[_timerLabel.centerYAnchor constraintEqualToAnchor:_startStopButton.centerYAnchor] setActive:YES];
    [[_timerLabel.widthAnchor constraintEqualToConstant:40.0] setActive:YES];
    
    [[_detailTextLabel.leadingAnchor constraintEqualToAnchor:_startStopButton.leadingAnchor] setActive:YES];
    [[_detailTextLabel.trailingAnchor constraintEqualToAnchor:_timerLabel.trailingAnchor] setActive:YES];
    [[_detailTextLabel.bottomAnchor constraintEqualToAnchor:_startStopButton.topAnchor constant:-20.0] setActive:YES];
    
    [[_titleLabel.leadingAnchor constraintEqualToAnchor:_startStopButton.leadingAnchor] setActive:YES];
    [[_titleLabel.trailingAnchor constraintEqualToAnchor:_timerLabel.leadingAnchor constant: -10.0] setActive:YES];
    [[_titleLabel.bottomAnchor constraintEqualToAnchor:_detailTextLabel ? _detailTextLabel.topAnchor : _startStopButton.topAnchor constant: -15.0] setActive:YES];
    
    _blurViewTopConstraint = [self.contentView.topAnchor constraintEqualToAnchor:_titleLabel.topAnchor constant:-20.0];
    
    [_blurViewTopConstraint setActive:YES];
   
}

- (void)setStartStopButtonState:(ORKFaceDetectionButtonState)buttonState {
    if (buttonState == ORKFaceDetectionButtonStateFaceDetected) {
        [_startStopButton setBackgroundColor:[UIColor systemBlueColor]];
        [_startStopButton setEnabled:YES];
        _titleLabel.text = ORKLocalizedString(@"AV_JOURNALING_FACE_DETECTION_STEP_FACE_DETECTED_TITLE", nil);
        _detailTextLabel.text = ORKLocalizedString(@"AV_JOURNALING_FACE_DETECTION_STEP_FACE_DETECTED_TEXT", nil);
        [_titleLabel setTextColor:[UIColor whiteColor]];
        [_detailTextLabel setTextColor:[UIColor whiteColor]];
    } else {
        [_startStopButton setBackgroundColor:[UIColor systemGrayColor]];
        [_startStopButton setEnabled:NO];
        _titleLabel.text = ORKLocalizedString(@"AV_JOURNALING_FACE_DETECTION_STEP_NO_FACE_DETECTED_TITLE", nil);
        _detailTextLabel.text = ORKLocalizedString(@"AV_JOURNALING_FACE_DETECTION_STEP_NO_FACE_DETECTED_TEXT", nil);
        [_titleLabel setTextColor:[UIColor redColor]];
        [_detailTextLabel setTextColor:[UIColor redColor]];
    }
}

@end

@implementation ORKFaceDetectionStepContentView {
    ORKStepHeaderView *_headerView;
    UIView *_cameraView;
    UIView *_blurView;
    
    ORKFaceDetectionBlurFooterView *_blurFooterView;
    
    AVCaptureVideoPreviewLayer *_previewLayer;
    
    NSTimer *_timer;
    NSTimeInterval _maxRecordingTime;
    CGFloat _recordingTime;
    NSDateComponentsFormatter *_dateComponentsFormatter;
}

- (instancetype)init {
    self = [super initWithFrame:CGRectZero];
    self.layoutMargins = ORKStandardFullScreenLayoutMarginsForView(self);
    
    if (self) {
        self.translatesAutoresizingMaskIntoConstraints = NO;
        
        [self setUpSubviews];
        [self setUpConstraints];
    }
    
    return self;
}

- (void)setUpSubviews {
    _cameraView = [UIView new];
    _cameraView.alpha = 1.0;
     [self addSubview:_cameraView];
    
    _blurView = [UIView new];
    [_blurView setBackgroundColor:[UIColor whiteColor]];
    [_blurView setAlpha:0.95];
    [self addSubview:_blurView];
    
    _blurFooterView = [[ORKFaceDetectionBlurFooterView alloc] init];
    _blurFooterView.layer.cornerRadius = 10.0;
    _blurFooterView.layer.maskedCorners = kCALayerMinXMinYCorner | kCALayerMaxXMinYCorner;
    _blurFooterView.clipsToBounds = YES;
    [self addSubview:_blurFooterView];
}

- (void)layoutSubviews {
    if (_previewLayer && _previewLayer.frame.size.height == 0 && _cameraView.frame.size.height != 0) {
        _previewLayer.position = CGPointMake(_cameraView.frame.size.width / 2, _cameraView.frame.size.height / 2);
        _previewLayer.bounds = CGRectMake(0, 0, _cameraView.frame.size.width, _cameraView.frame.size.height);
    }
}

- (void)setUpConstraints {
    _cameraView.translatesAutoresizingMaskIntoConstraints = NO;
    _blurFooterView.translatesAutoresizingMaskIntoConstraints = NO;
    _blurView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [[_cameraView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor] setActive:YES];
    [[_cameraView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor] setActive:YES];
    [[_cameraView.topAnchor constraintEqualToAnchor:self.topAnchor] setActive:YES];
    [[_cameraView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor] setActive:YES];
    
    [[_blurView.leadingAnchor constraintEqualToAnchor:_cameraView.leadingAnchor] setActive:YES];
    [[_blurView.trailingAnchor constraintEqualToAnchor:_cameraView.trailingAnchor] setActive:YES];
    [[_blurView.topAnchor constraintEqualToAnchor:_cameraView.topAnchor] setActive:YES];
    [[_blurView.bottomAnchor constraintEqualToAnchor:_cameraView.bottomAnchor] setActive:YES];
    
    [[_blurFooterView.leadingAnchor constraintEqualToAnchor:_cameraView.leadingAnchor] setActive:YES];
    [[_blurFooterView.trailingAnchor constraintEqualToAnchor:_cameraView.trailingAnchor] setActive:YES];
    [[_blurFooterView.bottomAnchor constraintEqualToAnchor:_cameraView.bottomAnchor] setActive:YES];
}

- (void)setPreviewLayerWithSession:(AVCaptureSession *)session {
    _previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:session];
    _previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    _previewLayer.needsDisplayOnBoundsChange = YES;
    _previewLayer.connection.videoOrientation = AVCaptureVideoOrientationPortrait;
    
    [_cameraView.layer addSublayer:_previewLayer];
    [self startTimerWithMaximumRecordingLimit:60.0];
}

- (void)setFaceDetected:(BOOL)detected {
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        [_blurFooterView setStartStopButtonState: detected ? ORKFaceDetectionButtonStateFaceDetected : ORKFaceDetectionButtonStateNoFaceDetected] ;
    });
}

- (void)handleError:(NSError *)error {
    [_cameraView removeFromSuperview];
    [_blurFooterView removeFromSuperview];
    [_previewLayer removeFromSuperlayer];
    
    _cameraView = nil;
    _previewLayer = nil;
    
    if (_headerView)
    {
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

- (void)addTargetToContinueButton:(nullable id)target selector:(nonnull SEL)selector {
    [_blurFooterView.startStopButton addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
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
    _blurFooterView.timerLabel.text = [self formattedTimeFromSeconds:_recordingTime];
    
    if (_recordingTime >= _maxRecordingTime) {
        [_timer invalidate];
        //todo: deactivate button and stop task completely
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

@end



