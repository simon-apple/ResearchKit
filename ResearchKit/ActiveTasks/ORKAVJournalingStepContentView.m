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
#import "ORKFaceDetectionStepContentView.h"
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

static const CGFloat RecordingViewCornerRadius = 8.0;
static const CGFloat RecordingViewTopPadding = 24.0;
static const CGFloat RecordingViewInsidePadding = 9.0;
static const CGFloat RecordingImageViewRightPadding = 4.0;
static const CGFloat CountDownLabelTopPadding = 12.0;
static const CGFloat QuestionNumberLabelTopPadding = 36.0;
static const CGFloat QuestionLabelTopPadding = 6.0;
static const CGFloat ContentLeftRightPadding = 36.0;
static const CGFloat RecalibrationViewTopConstraint = 30.0;


@interface ORKAVJournalingStepContentView ()
@property (nonatomic, copy, nullable) ORKAVJournalingStepContentViewEventHandler viewEventhandler;
@end


@implementation ORKAVJournalingStepContentView {
    ORKStepHeaderView *_headerView;
    
    UIView *_recordingView;
    UILabel *_recordingLabel;
    UIImageView *_recordingIconImageView;
    
    UILabel *_countDownLabel;

    UILabel *_questionNumberLabel;
    UILabel *_questionLabel;
    
    ORKFaceDetectionStepContentView *_faceDetectionContentView;
    
    NSTimer *_faceCalibrationTimer;
    NSTimer *_timer;
    NSTimer *_badgeColorChangeTimer;
    NSTimeInterval _maxRecordingTime;
    CGFloat _recordingTime;
    NSDateComponentsFormatter *_dateComponentsFormatter;
    
    NSString *_titleText;
    NSString *_bodyText;
    
    NSMutableArray<NSLayoutConstraint *> *_constraints;
    NSLayoutConstraint *_questionNumberLabelTopConstraint;
    NSLayoutConstraint *_recalibrationViewTopConstraint;
    
    BOOL _badgeIsSystemRed;
    BOOL _countDownLabelShowing;
    BOOL _recalibrationViewPresented;
}

- (instancetype)initWithTitle:(nullable NSString *)title text:(NSString *)text {
    self = [super init];
    
    if (self) {
        self.layoutMargins = ORKStandardFullScreenLayoutMarginsForView(self);
        self.translatesAutoresizingMaskIntoConstraints = NO;
        _titleText = title;
        _bodyText = text;
        _countDownLabelShowing = NO;
        _recalibrationViewPresented = NO;
        
        [self setUpSubviews];
        [self setUpConstraints];
        [self startTimerForBadgeColorChange];
    }
    
    return self;
}

- (void)setUpSubviews {
    _recordingView = [UIView new];
    _recordingView.clipsToBounds = YES;
    _recordingView.layer.cornerRadius = RecordingViewCornerRadius;
    [_recordingView setBackgroundColor:[UIColor systemRedColor]];
    _badgeIsSystemRed = YES;
    [self addSubview:_recordingView];
    
    _recordingLabel = [UILabel new];
    [_recordingLabel setFont:[self recordingLabelFont]];
    [_recordingLabel setTextColor:[UIColor whiteColor]];
    [_recordingLabel setText:ORKLocalizedString(@"AV_JOURNALING_STEP_RECORDING_LABEL_TEXT", "")];
    [_recordingView addSubview:_recordingLabel];
    
    if (@available(iOS 13.0, *)) {
        UIImage *videoImage = [UIImage systemImageNamed:@"video.fill"];
        _recordingIconImageView = [UIImageView new];
        _recordingIconImageView.image = [videoImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [_recordingIconImageView setTintColor:[UIColor whiteColor]];
        [_recordingView addSubview:_recordingIconImageView];
    }
    
    _countDownLabel = [UILabel new];
    _countDownLabel.layer.opacity = 0;
    [_countDownLabel setFont:[self countDownLabelFont]];
    [_countDownLabel setTextColor:[UIColor systemRedColor]];
    [_countDownLabel setText:[NSString stringWithFormat:ORKLocalizedString(@"AV_JOURNALING_STEP_NEXT_QUESTION_MESSAGE", nil), [self formattedTimeFromSeconds:30.0]]];
    [self addSubview:_countDownLabel];
    
    _questionNumberLabel = [UILabel new];
    [_questionNumberLabel setTextColor:[UIColor systemGrayColor]];
    [_questionNumberLabel setText:_titleText];
    [_questionNumberLabel setFont:[self questionNumberLabelFont]];
    [self addSubview:_questionNumberLabel];
    
    _questionLabel = [UILabel new];
    _questionLabel.numberOfLines = 0;
    _questionLabel.lineBreakMode = NSLineBreakByWordWrapping;
    [_questionLabel setText:_bodyText];
    [_questionLabel setFont:[self questionLabelFont]];
    [self addSubview:_questionLabel];
}

- (void)setUpConstraints {
    _recordingView.translatesAutoresizingMaskIntoConstraints = NO;
    _recordingIconImageView.translatesAutoresizingMaskIntoConstraints = NO;
    _recordingLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _countDownLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _questionNumberLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _questionLabel.translatesAutoresizingMaskIntoConstraints = NO;
    
    if (_constraints) {
        [NSLayoutConstraint deactivateConstraints:_constraints];
    }
    
    _constraints = [NSMutableArray new];
    _questionNumberLabelTopConstraint = nil;
    
    [_constraints addObject:[_recordingView.centerXAnchor constraintEqualToAnchor:self.centerXAnchor]];
    [_constraints addObject:[_recordingView.topAnchor constraintEqualToAnchor:self.topAnchor constant:RecordingViewTopPadding]];
    
    if (_recordingIconImageView) {
        [_constraints addObject:[_recordingIconImageView.topAnchor constraintEqualToAnchor:_recordingView.topAnchor constant:RecordingViewInsidePadding]];
        [_constraints addObject:[_recordingIconImageView.bottomAnchor constraintEqualToAnchor:_recordingView.bottomAnchor constant:-RecordingViewInsidePadding]];
        [_constraints addObject:[_recordingIconImageView.leftAnchor constraintEqualToAnchor:_recordingView.leftAnchor constant:RecordingViewInsidePadding]];
        
        [_constraints addObject:[_recordingLabel.centerYAnchor constraintEqualToAnchor:_recordingIconImageView.centerYAnchor]];
        [_constraints addObject:[_recordingLabel.leadingAnchor constraintEqualToAnchor:_recordingIconImageView.trailingAnchor constant:RecordingImageViewRightPadding]];
        [_constraints addObject:[_recordingLabel.trailingAnchor constraintEqualToAnchor:_recordingView.trailingAnchor constant:-RecordingViewInsidePadding]];
    } else {
        [_constraints addObject:[_recordingLabel.centerXAnchor constraintEqualToAnchor:_recordingView.centerXAnchor]];
        [_constraints addObject:[_recordingLabel.topAnchor constraintEqualToAnchor:_recordingView.topAnchor constant:RecordingViewInsidePadding]];
        [_constraints addObject:[_recordingLabel.bottomAnchor constraintEqualToAnchor:_recordingView.bottomAnchor constant:-RecordingViewInsidePadding]];
        [_constraints addObject:[_recordingLabel.leadingAnchor constraintEqualToAnchor:_recordingView.leadingAnchor constant:RecordingViewInsidePadding]];
        [_constraints addObject:[_recordingLabel.trailingAnchor constraintEqualToAnchor:_recordingView.trailingAnchor constant:RecordingViewInsidePadding]];
    }
    
    [_constraints addObject:[_countDownLabel.centerXAnchor constraintEqualToAnchor:self.centerXAnchor]];
    [_constraints addObject:[_countDownLabel.topAnchor constraintEqualToAnchor: _recordingView.bottomAnchor constant:CountDownLabelTopPadding]];
    
    _questionNumberLabelTopConstraint = [_questionNumberLabel.topAnchor constraintEqualToAnchor:_recordingView.bottomAnchor constant:QuestionNumberLabelTopPadding];
    [_constraints addObject:_questionNumberLabelTopConstraint];
    [_constraints addObject:[_questionNumberLabel.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:ContentLeftRightPadding]];
    [_constraints addObject:[_questionNumberLabel.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-ContentLeftRightPadding]];
    
    [_constraints addObject:[_questionLabel.topAnchor constraintEqualToAnchor:_questionNumberLabel.bottomAnchor constant:QuestionLabelTopPadding]];
    [_constraints addObject:[_questionLabel.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:ContentLeftRightPadding]];
    [_constraints addObject:[_questionLabel.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-ContentLeftRightPadding]];
    
    [NSLayoutConstraint activateConstraints:_constraints];
}

- (void)setViewEventHandler:(ORKAVJournalingStepContentViewEventHandler)handler {
    self.viewEventhandler = [handler copy];
}

- (void)startTimerWithMaximumRecordingLimit:(NSTimeInterval)maximumRecordingLimit {
    if (_timer) {
        [_timer invalidate];
    }
    
    _maxRecordingTime = maximumRecordingLimit;
    _recordingTime = _maxRecordingTime;
    _timer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                              target:self
                                            selector:@selector(updateRecordingTime)
                                            userInfo:nil
                                             repeats:YES];
}

- (void)setFaceDetected:(BOOL)detected faceBound:(CGRect)faceBounds originalSize:(CGSize)originalSize {
    if (detected) {
        if (_recalibrationViewPresented) {
            [_faceDetectionContentView updateFacePositionCircleWithCGRect:faceBounds originalSize:originalSize];
            
            //if face icon is within the calibration box, start timer to remove recalibration view
            if ([_faceDetectionContentView isFacePositionCircleWithinBox:faceBounds originalSize:originalSize]) {
                [self startFaceCalibrationTimer];
            }
        }
    } else {
        //present recalibration view if no face is detected
        if (!_recalibrationViewPresented) {
            [self presentRecalibrationView];
        }
    }

    if (_recalibrationViewPresented) {
        [_faceDetectionContentView setFaceDetected:detected faceRect:faceBounds originalSize:originalSize];
        
        //stop recalibration timer if no face detected or the face isn't within the calibration box
        if (!detected || ![_faceDetectionContentView isFacePositionCircleWithinBox:faceBounds originalSize:originalSize]) {
            [_faceCalibrationTimer invalidate];
            _faceCalibrationTimer = nil;
        }
    }
}

- (void)handleError:(NSError *)error {
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
    
    [self invokeViewEventHandlerWithEvent:ORKAVJournalingStepContentViewEventError];
}

#pragma mark - Helper Methods (Private)

- (void)startTimerForBadgeColorChange {
    _badgeColorChangeTimer = [NSTimer scheduledTimerWithTimeInterval:0.3
                                                              target:self
                                                            selector:@selector(changeBadgeColor)
                                                            userInfo:nil
                                                             repeats:NO];
}

- (void)changeBadgeColor {
     dispatch_async(dispatch_get_main_queue(), ^(void) {
         [self layoutIfNeeded];
         
         [UIView animateWithDuration:1.0
                          animations:^{
             if (_badgeIsSystemRed) {
                 [_recordingView setBackgroundColor:[UIColor colorWithRed:188/255.0 green:59/255.0 blue:52/255.0 alpha:1.0]];
                 
             } else {
                 [_recordingView setBackgroundColor:[UIColor systemRedColor]];
             }
             
             _badgeIsSystemRed = !_badgeIsSystemRed;
             
             [self setNeedsLayout];
         } completion:^(BOOL finished) {
             [self startTimerForBadgeColorChange];
         }];
     });
}

- (void)invokeViewEventHandlerWithEvent:(ORKAVJournalingStepContentViewEvent)event {
    if (self.viewEventhandler)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            self.viewEventhandler(event);
        });
    }
}

- (void)updateRecordingTime {
    _recordingTime -= _timer.timeInterval;
    
    if (_recordingTime <= 0) {
        [self stopAndSubmitVideo];
    } else if (_recordingTime <= 30) {
        if (!_countDownLabelShowing) {
            [self showCountDownLabel];
        } else {
            [self updateCountDownLabelWithTime:[self formattedTimeFromSeconds:_recordingTime]];
        }
    }
}

- (void)showCountDownLabel {
    _countDownLabelShowing = YES;
    
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        [UIView animateWithDuration:0.8
                         animations:^{
            _countDownLabel.layer.opacity = 1.0;
            
            [_questionNumberLabelTopConstraint setActive:NO];
            _questionNumberLabelTopConstraint = [_questionNumberLabel.topAnchor constraintEqualToAnchor:_countDownLabel.bottomAnchor constant:QuestionNumberLabelTopPadding];
            [_questionNumberLabelTopConstraint setActive:YES];
            
            if (_recalibrationViewPresented) {
                [_recalibrationViewTopConstraint setActive:NO];
                _recalibrationViewTopConstraint = [_faceDetectionContentView.topAnchor constraintEqualToAnchor:_countDownLabel.bottomAnchor constant:RecalibrationViewTopConstraint];
                [_recalibrationViewTopConstraint setActive:YES];
            }
            
            [self layoutIfNeeded];
        }];
     });
}

- (void)updateCountDownLabelWithTime:(NSString *)time {
    [_countDownLabel setText:[NSString stringWithFormat:ORKLocalizedString(@"AV_JOURNALING_STEP_NEXT_QUESTION_MESSAGE", nil), time]];
}

- (void)stopAndSubmitVideo {
    [self invokeViewEventHandlerWithEvent:ORKAVJournalingStepContentViewEventStopAndSubmitRecording];
    [_timer invalidate];
    _timer = nil;
}

- (NSString *)formattedTimeFromSeconds:(CGFloat)seconds {
    if (!_dateComponentsFormatter) {
        _dateComponentsFormatter = [NSDateComponentsFormatter new];
        _dateComponentsFormatter.zeroFormattingBehavior = NSDateComponentsFormatterZeroFormattingBehaviorPad;
        _dateComponentsFormatter.allowedUnits =  NSCalendarUnitMinute | NSCalendarUnitSecond | NSCalendarUnitNanosecond;
    }
    return [_dateComponentsFormatter stringFromTimeInterval:seconds];
}

- (UIFont *)recordingLabelFont {
    UIFontDescriptor *descriptor = [UIFontDescriptor preferredFontDescriptorWithTextStyle:UIFontTextStyleFootnote];
    UIFontDescriptor *fontDescriptor = [descriptor fontDescriptorWithSymbolicTraits:(UIFontDescriptorTraitBold)];
    return [UIFont fontWithDescriptor:fontDescriptor size:[[fontDescriptor objectForKey: UIFontDescriptorSizeAttribute] doubleValue]];
}

- (UIFont *)countDownLabelFont {
    UIFontDescriptor *descriptor = [UIFontDescriptor preferredFontDescriptorWithTextStyle:UIFontTextStyleFootnote];
    UIFontDescriptor *fontDescriptor = [descriptor fontDescriptorWithSymbolicTraits:(UIFontDescriptorTraitBold)];
    return [UIFont fontWithDescriptor:fontDescriptor size:[[fontDescriptor objectForKey: UIFontDescriptorSizeAttribute] doubleValue]];
}

- (UIFont *)questionNumberLabelFont {
    UIFontDescriptor *descriptor = [UIFontDescriptor preferredFontDescriptorWithTextStyle:UIFontTextStyleFootnote];
    UIFontDescriptor *fontDescriptor = [descriptor fontDescriptorWithSymbolicTraits:(UIFontDescriptorTraitBold)];
    return [UIFont fontWithDescriptor:fontDescriptor size:[[fontDescriptor objectForKey: UIFontDescriptorSizeAttribute] doubleValue]];
}

- (UIFont *)questionLabelFont {
    UIFontDescriptor *descriptor = [UIFontDescriptor preferredFontDescriptorWithTextStyle:UIFontTextStyleTitle1];
    UIFontDescriptor *fontDescriptor = [descriptor fontDescriptorWithSymbolicTraits:(UIFontDescriptorTraitBold)];
    return [UIFont fontWithDescriptor:fontDescriptor size:[[fontDescriptor objectForKey: UIFontDescriptorSizeAttribute] doubleValue]];
}

#pragma mark - Recalibration View Methods (Private)

- (void)presentRecalibrationView {
    _recalibrationViewPresented = YES;
    
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        [self layoutIfNeeded];
        [self setupFaceDetectionContentView];
        
        [UIView animateWithDuration:0.5
                         animations:^{
            
            _questionNumberLabel.layer.opacity = 0;
            _questionLabel.layer.opacity = 0;
            _faceDetectionContentView.layer.opacity = 1.0;
            
            [self setNeedsLayout];
        } completion:^(BOOL finished) {
            [_faceDetectionContentView layoutSubviews];
            
            //next button should say disabled while recalibration view is presented
            [self invokeViewEventHandlerWithEvent:ORKAVJournalingStepContentViewEventDisableContinueButton];
        }];
    });
    
}

- (void)removeRecalibrationView {
    if (_recalibrationViewPresented) {
        _recalibrationViewPresented = NO;

        dispatch_async(dispatch_get_main_queue(), ^(void) {
            [self layoutIfNeeded];

            [UIView animateWithDuration:0.5
                             animations:^{

                _questionNumberLabel.layer.opacity = 1;
                _questionLabel.layer.opacity = 1;
                _faceDetectionContentView.layer.opacity = 0;

                [self setNeedsLayout];
            } completion:^(BOOL finished) {
                [_faceDetectionContentView removeFromSuperview];
                _faceDetectionContentView = nil;
                
                //next button should say disabled while recalibration view is presented
                [self invokeViewEventHandlerWithEvent:ORKAVJournalingStepContentViewEventEnableContinueButton];
            }];
        });
    }
}

- (void)setupFaceDetectionContentView {
    _faceDetectionContentView = [[ORKFaceDetectionStepContentView alloc] initForRecalibration:YES];
    _faceDetectionContentView.layer.opacity = 0;
    [self addSubview:_faceDetectionContentView];
    
    [[_faceDetectionContentView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor] setActive:YES];
    [[_faceDetectionContentView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor] setActive:YES];
    [[_faceDetectionContentView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor] setActive:YES];
    
    if (_countDownLabelShowing) {
        _recalibrationViewTopConstraint = [_faceDetectionContentView.topAnchor constraintEqualToAnchor:_countDownLabel.bottomAnchor constant:RecalibrationViewTopConstraint];
    } else {
        _recalibrationViewTopConstraint = [_faceDetectionContentView.topAnchor constraintEqualToAnchor:_recordingView.bottomAnchor constant:RecalibrationViewTopConstraint];
    }
    
    [_recalibrationViewTopConstraint setActive:YES];
}

- (void)startFaceCalibrationTimer {
    if (_faceCalibrationTimer) {
        return;
    }
    
    _faceCalibrationTimer = [NSTimer scheduledTimerWithTimeInterval:2.0
                                                             target:self
                                                           selector:@selector(removeRecalibrationView)
                                                           userInfo:nil
                                                            repeats:NO];
}

@end




