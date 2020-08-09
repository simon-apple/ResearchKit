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

#import "ORKAVJournalingStepContentView.h"
#import "ORKUnitLabel.h"
#import "ORKHelpers_Internal.h"
#import "ORKSkin.h"
#import "ORKBorderedButton.h"
#import "ORKStepHeaderView_Internal.h"
#import "ORKTitleLabel.h"
#import "ORKBodyLabel.h"
#import "ORKIconButton.h"
#import <AVFoundation/AVFoundation.h>
#import <ARKit/ARKit.h>


@interface ORKAVJournalingStepOptionsView : UIVisualEffectView

@property (nonatomic, strong) ORKIconButton *reviewVideoButton;
@property (nonatomic, strong) ORKIconButton *deleteAndRetryVideoButton;
@property (nonatomic, strong) UIButton *submitVideoButton;

@end

@implementation ORKAVJournalingStepOptionsView {
    NSMutableArray *_constraints;
    ORKTitleLabel *_titleLabel;
}

- (instancetype)initWithEffect:(UIVisualEffect *)effect {
    self = [super initWithEffect:effect];
    
    if (self) {
        [self setupSubviews];
        [self setUpConstraints];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    self.layer.cornerRadius = 10.0;
    self.layer.maskedCorners = kCALayerMinXMinYCorner | kCALayerMaxXMinYCorner;
    self.clipsToBounds = YES;
}

- (void)setupSubviews {
    _titleLabel = [ORKTitleLabel new];
    _titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _titleLabel.textAlignment = NSTextAlignmentLeft;
    _titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    [_titleLabel setTextColor:[UIColor whiteColor]];
    _titleLabel.text = ORKLocalizedString(@"FRONT_FACING_CAMERA_REVIEW_OPTIONS_TITLE", nil);
    [self.contentView addSubview:_titleLabel];

    UIImage *reviewButtonIcon = nil;
    
    if (@available(iOS 13.0, *)) {
        reviewButtonIcon = [UIImage systemImageNamed:@"video.fill"];
    }
    
    _reviewVideoButton = [[ORKIconButton alloc] initWithButtonText:ORKLocalizedString(@"FRONT_FACING_CAMERA_REVIEW_VIDEO", nil) buttonIcon: reviewButtonIcon];
    _reviewVideoButton.tag = 0;
    _reviewVideoButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:_reviewVideoButton];
    
    UIImage *deleteAndRetryButtonIcon = nil;
    
    if (@available(iOS 13.0, *)) {
        deleteAndRetryButtonIcon = [UIImage systemImageNamed:@"trash.fill"];
    }
    
    _deleteAndRetryVideoButton = [[ORKIconButton alloc] initWithButtonText:ORKLocalizedString(@"FRONT_FACING_CAMERA_RETRY_VIDEO", nil) buttonIcon: deleteAndRetryButtonIcon];
    _deleteAndRetryVideoButton.tag = 1;
    _deleteAndRetryVideoButton.translatesAutoresizingMaskIntoConstraints = NO;
    [_deleteAndRetryVideoButton updateTextAndImageColor:[UIColor redColor]];
    [self.contentView addSubview:_deleteAndRetryVideoButton];
    
    _submitVideoButton = [UIButton new];
    _submitVideoButton.tag = 2;
    _submitVideoButton.translatesAutoresizingMaskIntoConstraints = NO;
    _submitVideoButton.layer.cornerRadius = 10.0;
    _submitVideoButton.clipsToBounds = YES;
    _submitVideoButton.titleLabel.font = [UIFont systemFontOfSize:20.0];
    [_submitVideoButton setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [_submitVideoButton setBackgroundColor:[UIColor systemBlueColor]];
    [_submitVideoButton setTitleEdgeInsets:UIEdgeInsetsMake(5.0, 8.0, 5.0, 8.0)];
    [_submitVideoButton setTitle:ORKLocalizedString(@"FRONT_FACING_CAMERA_SUBMIT_VIDEO", nil) forState:UIControlStateNormal];
    [self.contentView addSubview:_submitVideoButton];
}

- (void)setUpConstraints {
    if (_constraints) {
        [NSLayoutConstraint deactivateConstraints:_constraints];
    }
    
    _constraints = [NSMutableArray array];
    
    [_constraints addObject: [_titleLabel.topAnchor constraintEqualToAnchor:self.contentView.topAnchor constant:25.0]];
    [_constraints addObject: [_titleLabel.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:20.0]];
    [_constraints addObject: [_titleLabel.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-20.0]];
    
    //reviewVideoButton constraints
    [_constraints addObject:[_reviewVideoButton.topAnchor constraintEqualToAnchor:_titleLabel.bottomAnchor constant:40.0]];
    [_constraints addObject:[_reviewVideoButton.leadingAnchor constraintEqualToAnchor:_titleLabel.leadingAnchor]];
    [_constraints addObject:[_reviewVideoButton.trailingAnchor constraintEqualToAnchor:_titleLabel.trailingAnchor]];
    [_constraints addObject:[_reviewVideoButton.heightAnchor constraintEqualToConstant:50.0]];
    
    //deleteAndRetryButton constraints
    [_constraints addObject:[_deleteAndRetryVideoButton.topAnchor constraintEqualToAnchor:_reviewVideoButton.bottomAnchor constant:15.0]];
    [_constraints addObject:[_deleteAndRetryVideoButton.leadingAnchor constraintEqualToAnchor:_titleLabel.leadingAnchor]];
    [_constraints addObject:[_deleteAndRetryVideoButton.trailingAnchor constraintEqualToAnchor:_titleLabel.trailingAnchor]];
    [_constraints addObject:[_deleteAndRetryVideoButton.heightAnchor constraintEqualToConstant:50.0]];
    
    //submitVideoButton constraints
    [_constraints addObject:[_submitVideoButton.leadingAnchor constraintEqualToAnchor:_titleLabel.leadingAnchor]];
    [_constraints addObject:[_submitVideoButton.trailingAnchor constraintEqualToAnchor:_titleLabel.trailingAnchor]];
    [_constraints addObject:[_submitVideoButton.bottomAnchor constraintEqualToAnchor:self.contentView.safeAreaLayoutGuide.bottomAnchor constant:-20.0]];
    [_constraints addObject:[_submitVideoButton.heightAnchor constraintEqualToConstant:50.0]];
    
    [NSLayoutConstraint activateConstraints:_constraints];
}

@end

typedef NS_CLOSED_ENUM(NSInteger, ORKStartStopButtonState) {
    ORKStartStopButtonStateStartRecording = 0,
    ORKStartStopButtonStateStopRecording,
} ORK_ENUM_AVAILABLE;


@interface ORKAVJournalingBlurFooterView : UIVisualEffectView
- (instancetype)initWithTitleText:(nullable NSString *)titleText detailText:(nullable NSString *)detailText;

@property (nonatomic) UIButton *startStopButton;
@property (nonatomic) ORKStartStopButtonState startStopButtonState;
@property (nonatomic) UILabel *timerLabel;

- (void)faceDetected:(BOOL)faceDetected;

@end

@implementation ORKAVJournalingBlurFooterView {
    NSMutableArray<NSLayoutConstraint *> *_heightConstraints;
    NSLayoutConstraint *_blurViewTopConstraint;
    
    NSString *_titleText;
    NSString *_detailText;
    
    ORKTitleLabel *_titleLabel;
    ORKBodyLabel *_detailTextLabel;
    
    UIButton *_collapseButton;
    
    BOOL _isTextCollapsed;
}

- (instancetype)initWithTitleText:(nullable NSString *)titleText detailText:(nullable NSString *)detailText {
    self = [super initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
    if (self) {
        _titleText = titleText;
        _detailText = detailText;
        _isTextCollapsed = NO;
        _startStopButtonState = ORKStartStopButtonStateStartRecording;
        [self setupSubviews];
        [self setupConstraints];
        [self setStartStopButtonState:ORKStartStopButtonStateStartRecording];
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
    [self.contentView addSubview:_startStopButton];
    
    _timerLabel = [UILabel new];
    _timerLabel.font = [UIFont systemFontOfSize:15.0];
    _timerLabel.adjustsFontSizeToFitWidth = YES;
    [_timerLabel setTextColor:[UIColor whiteColor]];
    [self.contentView addSubview:_timerLabel];
    
    UIImage *collapseButtonImage;
    
    if (@available(iOS 13.0, *)) {
        collapseButtonImage = [UIImage systemImageNamed:@"chevron.down"];
    }
    
    if (_titleText) {
        _titleLabel = [ORKTitleLabel new];
        _titleLabel.textAlignment = NSTextAlignmentLeft;
        _titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        _titleLabel.numberOfLines = 0;
        [_titleLabel setTextColor:[UIColor whiteColor]];
        _titleLabel.text = _titleText;
        [self.contentView addSubview:_titleLabel];
    }
    
    if (_detailText) {
        _detailTextLabel = [ORKBodyLabel new];
        _detailTextLabel.textAlignment = NSTextAlignmentLeft;
        _detailTextLabel.lineBreakMode = NSLineBreakByWordWrapping;
        _detailTextLabel.numberOfLines = 0;
        [_detailTextLabel setTextColor:[UIColor whiteColor]];
        _detailTextLabel.text = _detailText ? : @"";
        [self.contentView addSubview:_detailTextLabel];
    }
    
    if (_titleText || _detailText) {
        _collapseButton = [UIButton new];
        _collapseButton.translatesAutoresizingMaskIntoConstraints = NO;
        [_collapseButton setTintColor:[UIColor whiteColor]];
        [_collapseButton setBackgroundImage:collapseButtonImage forState:UIControlStateNormal];
        [_collapseButton addTarget:self
                            action:@selector(collapseButtonPressed)
                  forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_collapseButton];
    }
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
    
    if (_titleLabel || _detailTextLabel) {
        
        if (_detailTextLabel) {
            [[_detailTextLabel.leadingAnchor constraintEqualToAnchor:_startStopButton.leadingAnchor] setActive:YES];
            [[_detailTextLabel.trailingAnchor constraintEqualToAnchor:_timerLabel.trailingAnchor] setActive:YES];
            [[_detailTextLabel.bottomAnchor constraintEqualToAnchor:_startStopButton.topAnchor constant:-20.0] setActive:YES];
        }
        
        if (_titleLabel) {
            [[_titleLabel.leadingAnchor constraintEqualToAnchor:_startStopButton.leadingAnchor] setActive:YES];
            [[_titleLabel.trailingAnchor constraintEqualToAnchor:_collapseButton.leadingAnchor constant: -10.0] setActive:YES];
            [[_titleLabel.bottomAnchor constraintEqualToAnchor:_detailTextLabel ? _detailTextLabel.topAnchor : _startStopButton.topAnchor constant: -15.0] setActive:YES];
            
            [[_collapseButton.topAnchor constraintEqualToAnchor:_titleLabel.topAnchor] setActive:YES];
            
            _blurViewTopConstraint = [self.contentView.topAnchor constraintEqualToAnchor:_titleLabel.topAnchor constant:-20.0];
        } else {
            [[_collapseButton.bottomAnchor constraintEqualToAnchor:_detailTextLabel.topAnchor constant:-15.0] setActive:YES];
            _blurViewTopConstraint = [self.contentView.topAnchor constraintEqualToAnchor:_collapseButton.topAnchor constant:-20.0];
        }
        
        [[_collapseButton.trailingAnchor constraintEqualToAnchor:_timerLabel.trailingAnchor] setActive:YES];
        [[_collapseButton.heightAnchor constraintEqualToConstant:25.0] setActive:YES];
        [[_collapseButton.widthAnchor constraintEqualToConstant:25.0] setActive:YES];
        
        [_blurViewTopConstraint setActive:YES];
    } else {
        [[self.contentView.topAnchor constraintEqualToAnchor:_startStopButton.topAnchor constant:-20.0] setActive:YES];
    }
    
}

- (void)setStartStopButtonState:(ORKStartStopButtonState)startStopButtonState {
    _startStopButtonState = startStopButtonState;
    
    if (startStopButtonState == ORKStartStopButtonStateStartRecording) {
        [_startStopButton setTitle:ORKLocalizedString(@"FRONT_FACING_CAMERA_START_TITLE", nil) forState:UIControlStateNormal];
        [_startStopButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_startStopButton setBackgroundColor:[UIColor systemBlueColor]];
        
        [_timerLabel setText:ORKLocalizedString(@"AV_JOURNALING_STEP_START_TIME", nil)];
    } else {
        [_startStopButton setTitle:ORKLocalizedString(@"FRONT_FACING_CAMERA_STOP_TITLE", nil) forState:UIControlStateNormal];
        [_startStopButton setTitleColor:[UIColor systemBlueColor] forState:UIControlStateNormal];
        [_startStopButton setBackgroundColor:[UIColor systemGrayColor]];
    }
}

- (void)faceDetected:(BOOL)faceDetected {
    if (faceDetected) {
        _titleLabel.text = _titleText;
        _detailTextLabel.text = _detailText;
        [_titleLabel setTextColor:[UIColor whiteColor]];
        [_detailTextLabel setTextColor:[UIColor whiteColor]];
    } else {
        _titleLabel.text = ORKLocalizedString(@"AV_JOURNALING_STEP_NO_FACE_DETECTED_TITLE", nil);
        _detailTextLabel.text = ORKLocalizedString(@"AV_JOURNALING_STEP_NO_FACE_DETECTED_TEXT", nil);
        [_titleLabel setTextColor:[UIColor redColor]];
        [_detailTextLabel setTextColor:[UIColor redColor]];
        
        if (_isTextCollapsed) {
            [self collapseButtonPressed];
        }
    }
}

- (void)collapseButtonPressed {
    UIImage *collapseButtonImage;
    
    if (_isTextCollapsed) {
        [_blurViewTopConstraint setActive:NO];
        _blurViewTopConstraint = [self.contentView.topAnchor constraintEqualToAnchor:_titleLabel.topAnchor constant:-20.0];
        [_blurViewTopConstraint setActive:YES];
        
        [NSLayoutConstraint deactivateConstraints:_heightConstraints];
        _heightConstraints = nil;
    } else {
        [_blurViewTopConstraint setActive:NO];
        _blurViewTopConstraint = [self.contentView.topAnchor constraintEqualToAnchor:_collapseButton.topAnchor constant:-20.0];
        [_blurViewTopConstraint setActive:YES];
        
        _heightConstraints = [NSMutableArray new];
        [_heightConstraints addObject:[_titleLabel.heightAnchor constraintEqualToConstant:0.0]];
        [_heightConstraints addObject:[_detailTextLabel.heightAnchor constraintEqualToConstant:0.0]];
        
        [NSLayoutConstraint activateConstraints:_heightConstraints];
    }
    
    if (@available(iOS 13.0, *)) {
        collapseButtonImage =  _isTextCollapsed ? [UIImage systemImageNamed:@"chevron.down"] : [UIImage systemImageNamed:@"chevron.up"];
    }
    
    [_collapseButton setBackgroundImage:collapseButtonImage forState:UIControlStateNormal];
    _isTextCollapsed = !_isTextCollapsed;
}

@end

@interface ORKAVJournalingStepContentView ()
@property (nonatomic, copy, nullable) ORKAVJournalingStepContentViewEventHandler viewEventhandler;
@end


@implementation ORKAVJournalingStepContentView {
    ORKStepHeaderView *_headerView;
    UIView *_cameraView;
    UIView *_blurView;
    
    AVCaptureVideoPreviewLayer *_previewLayer;
    ORKAVJournalingBlurFooterView *_blurFooterView;
    
    NSTimer *_timer;
    NSTimeInterval _maxRecordingTime;
    CGFloat _recordingTime;
    NSDateComponentsFormatter *_dateComponentsFormatter;
    
    ORKAVJournalingStepOptionsView *_optionsView;
    
    NSString *_titleText;
    NSString *_bodyText;
    
    ARSCNView *_arSceneView;
}

- (instancetype)initWithTitle:(nullable NSString *)title text:(NSString *)text {
    self = [super initWithFrame:CGRectZero];
    self.layoutMargins = ORKStandardFullScreenLayoutMarginsForView(self);
    
    if (self) {
        self.translatesAutoresizingMaskIntoConstraints = NO;
        _titleText = title;
        _bodyText = text;
        
        [self setUpSubviews];
        [self setUpConstraints];
    }
    
    return self;
}

- (void)setUpSubviews {
    
    if ([ARFaceTrackingConfiguration isSupported]) {
        _arSceneView = [[ARSCNView alloc] initWithFrame:_previewLayer.frame];
        [self addSubview:_arSceneView];
    } else {
        _cameraView = [UIView new];
        _cameraView.alpha = 1.0;
        [self addSubview:_cameraView];
    }
    
    _blurView = [UIView new];
    [_blurView setBackgroundColor:[UIColor whiteColor]];
    [_blurView setAlpha:0.95];
    [self addSubview:_blurView];
    
    _blurFooterView = [[ORKAVJournalingBlurFooterView alloc] initWithTitleText:_titleText detailText:_bodyText];
    _blurFooterView.layer.cornerRadius = 10.0;
    _blurFooterView.layer.maskedCorners = kCALayerMinXMinYCorner | kCALayerMaxXMinYCorner;
    _blurFooterView.clipsToBounds = YES;
    
    [_blurFooterView.startStopButton addTarget:self
                                action:@selector(startStopButtonPressed)
                      forControlEvents:UIControlEventTouchUpInside];

    [self addSubview:_blurFooterView];
}

- (void)layoutSubviews {
    if (_previewLayer && _previewLayer.frame.size.height == 0 && _cameraView.frame.size.height != 0 && ![ARFaceTrackingConfiguration isSupported]) {
        _previewLayer.position = CGPointMake(_cameraView.frame.size.width / 2, _cameraView.frame.size.height / 2);
        _previewLayer.bounds = CGRectMake(0, 0, _cameraView.frame.size.width, _cameraView.frame.size.height);
    }
}

- (void)setUpConstraints {
    _blurView.translatesAutoresizingMaskIntoConstraints = NO;
    _blurFooterView.translatesAutoresizingMaskIntoConstraints = NO;
    
    UIView *videoPreviewView;
    if ([ARFaceTrackingConfiguration isSupported]) {
        _arSceneView.translatesAutoresizingMaskIntoConstraints = NO;
        videoPreviewView = _arSceneView;
    } else {
        _cameraView.translatesAutoresizingMaskIntoConstraints = NO;
        videoPreviewView = _cameraView;
    }
    
    [[videoPreviewView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor] setActive:YES];
    [[videoPreviewView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor] setActive:YES];
    [[videoPreviewView.topAnchor constraintEqualToAnchor:self.topAnchor] setActive:YES];
    [[videoPreviewView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor] setActive:YES];
    
    [[_blurView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor] setActive:YES];
    [[_blurView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor] setActive:YES];
    [[_blurView.topAnchor constraintEqualToAnchor:self.topAnchor] setActive:YES];
    [[_blurView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor] setActive:YES];
    
    [[_blurFooterView.leadingAnchor constraintEqualToAnchor:videoPreviewView.leadingAnchor] setActive:YES];
    [[_blurFooterView.trailingAnchor constraintEqualToAnchor:videoPreviewView.trailingAnchor] setActive:YES];
    [[_blurFooterView.bottomAnchor constraintEqualToAnchor:videoPreviewView.bottomAnchor] setActive:YES];
}

- (void)setViewEventHandler:(ORKAVJournalingStepContentViewEventHandler)handler {
    self.viewEventhandler = [handler copy];
}

- (void)invokeViewEventHandlerWithEvent:(ORKAVJournalingStepContentViewEvent)event {
    if (self.viewEventhandler)
    {
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

- (ARSCNView *)ARSceneView {
    return _arSceneView;
}

- (void)setFaceDetected:(BOOL)detected {
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        [_blurFooterView faceDetected:detected] ;
    });
}

- (void)handleError:(NSError *)error {
    [_optionsView removeFromSuperview];
    [_cameraView removeFromSuperview];
    [_blurFooterView removeFromSuperview];
    [_previewLayer removeFromSuperlayer];
    
    _optionsView = nil;
    _cameraView = nil;
    _blurFooterView = nil;
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
    
    [self invokeViewEventHandlerWithEvent:ORKAVJournalingStepContentViewEventError];
}

- (void)startStopButtonPressed {
    if (_blurFooterView.startStopButtonState == ORKStartStopButtonStateStartRecording)
    {
        [_blurFooterView setStartStopButtonState:ORKStartStopButtonStateStopRecording];
        [self invokeViewEventHandlerWithEvent:ORKAVJournalingStepContentViewEventStartRecording];
    }
    else
    {
        [_blurFooterView setStartStopButtonState:ORKStartStopButtonStateStartRecording];
        [self invokeViewEventHandlerWithEvent:ORKAVJournalingStepContentViewEventStopRecording];
        [_timer invalidate];
        _timer = nil;
    }
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
        [_blurFooterView setStartStopButtonState:ORKStartStopButtonStateStartRecording];
        [self invokeViewEventHandlerWithEvent:ORKAVJournalingStepContentViewEventStopRecording];
    } else {
        _blurFooterView.timerLabel.text = [self formattedTimeFromSeconds:_recordingTime];
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

- (void)presentReviewOptionsAllowingReview:(BOOL)allowReview allowRetry:(BOOL)allowRetry {
    if (allowRetry || allowReview)
    {
        [self presentOptionsView];
        [_optionsView.reviewVideoButton setHidden:!allowReview];
        [_optionsView.deleteAndRetryVideoButton setHidden:!allowRetry];
    }
}

- (void)presentOptionsView {
    if (_optionsView)
    {
        [_optionsView removeFromSuperview];
        _optionsView = nil;
    }

    _optionsView = [[ORKAVJournalingStepOptionsView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
    _optionsView.translatesAutoresizingMaskIntoConstraints = NO;

    [_optionsView.reviewVideoButton addTarget:self
                                       action:@selector(optionsViewButtonPressed:)
                             forControlEvents:UIControlEventTouchUpInside];
    [_optionsView.deleteAndRetryVideoButton addTarget:self
                                               action:@selector(optionsViewButtonPressed:)
                                     forControlEvents:UIControlEventTouchUpInside];
    [_optionsView.submitVideoButton addTarget:self
                                       action:@selector(optionsViewButtonPressed:)
                             forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:_optionsView];
    [self setupOptionsViewConstraints];
}

- (void)setupOptionsViewConstraints {
        [[_optionsView.topAnchor constraintEqualToAnchor:self.topAnchor] setActive:YES];
        [[_optionsView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor] setActive:YES];
        [[_optionsView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor] setActive:YES];
        [[_optionsView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor] setActive:YES];
}

- (void)optionsViewButtonPressed:(UIButton *)button {
    if (button) {
        if (button.tag == 0) {
            //review video
            [self invokeViewEventHandlerWithEvent:ORKAVJournalingStepContentViewEventReviewRecording];
        } else if (button.tag == 1) {
            //delete and redo recording
            [self invokeViewEventHandlerWithEvent:ORKAVJournalingStepContentViewEventRetryRecording];
            [_optionsView removeFromSuperview];
            _optionsView = nil;
        } else if (button.tag == 2) {
            //submit video
            [self invokeViewEventHandlerWithEvent:ORKAVJournalingStepContentViewEventSubmitRecording];
        }
    }
}

@end




