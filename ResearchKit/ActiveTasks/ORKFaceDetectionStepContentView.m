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

@implementation ORKFaceDetectionStepContentView {
    UILabel *_centerFaceInstructionLabel;
    UILabel *_alignmentTimerLabel;
    
    UIView *_cameraView;
    ORKDetectionOverlayView *_detectionOverlayView;
    
    ARSCNView *_arSceneView;
    
    AVCaptureVideoPreviewLayer *_previewLayer;
    AVCaptureDevice *_frontCameraCaptureDevice;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    self.layoutMargins = ORKStandardFullScreenLayoutMarginsForView(self);
    
    if (self) {
        self.translatesAutoresizingMaskIntoConstraints = NO;
        
        [self setUpSubviews];
        [self setUpConstraints];
    }
    
    return self;
}

- (void)setUpSubviews {
    _nextButton = [UIButton new];
    [_nextButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [_nextButton setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
    [_nextButton setBackgroundColor:[UIColor whiteColor]];
    [_nextButton.layer setBorderColor:[[UIColor grayColor] CGColor]];
    [_nextButton setEnabled:NO];
    [_nextButton.layer setBorderWidth:1.0];
    _nextButton.translatesAutoresizingMaskIntoConstraints = NO;
    [_nextButton setTitle:ORKLocalizedString(@"AV_JOURNALING_FACE_DETECTION_STEP_NEXT_BUTTON_TEXT", nil) forState:UIControlStateNormal];
    
    _centerFaceInstructionLabel = [UILabel new];
    _centerFaceInstructionLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    _centerFaceInstructionLabel.adjustsFontForContentSizeCategory = YES;
    _centerFaceInstructionLabel.textAlignment = NSTextAlignmentCenter;
    _centerFaceInstructionLabel.numberOfLines = 0;
    [_centerFaceInstructionLabel setText:ORKLocalizedString(@"AV_JOURNALING_FACE_DETECTION_STEP_CENTER_FACE_TEXT", nil)];
    
    _alignmentTimerLabel = [UILabel new];
    _alignmentTimerLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    _alignmentTimerLabel.adjustsFontForContentSizeCategory = YES;
    _alignmentTimerLabel.textAlignment = NSTextAlignmentLeft;
    [_alignmentTimerLabel setText:@"0:00"];
        
    _cameraView = [UIView new];
    _cameraView.alpha = 1.0;
    
    _arSceneView = [[ARSCNView alloc] initWithFrame:_previewLayer.frame];
}

- (void)layoutSubviews {
    if (_previewLayer && _previewLayer.frame.size.height == 0 && _cameraView.frame.size.height != 0 && ![ARFaceTrackingConfiguration isSupported]) {
        _previewLayer.position = CGPointMake(_cameraView.frame.size.width / 2, _cameraView.frame.size.height / 2);
        _previewLayer.bounds = CGRectMake(0, 0, _cameraView.frame.size.width, _cameraView.frame.size.height);
        
        if (_detectionOverlayView) {
            [_detectionOverlayView removeFromSuperview];
            _detectionOverlayView = nil;
        }
        
        _detectionOverlayView = [[ORKDetectionOverlayView alloc] initWithFrame:_cameraView.frame];
        [_detectionOverlayView createRectsAndLayersForFaceDetection];
        [self addSubview:_detectionOverlayView];
    } else if ([ARFaceTrackingConfiguration isSupported] && (!_detectionOverlayView || _detectionOverlayView.frame.size.height == 0)) {
        _detectionOverlayView = [[ORKDetectionOverlayView alloc] initWithFrame:_arSceneView.frame];
        [_detectionOverlayView createRectsAndLayersForFaceDetection];
        [self addSubview:_detectionOverlayView];
    }
}

- (void)setUpConstraints {
    _alignmentTimerLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _nextButton.translatesAutoresizingMaskIntoConstraints = NO;
    _centerFaceInstructionLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _cameraView.translatesAutoresizingMaskIntoConstraints = NO;
    _arSceneView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self addSubview:_alignmentTimerLabel];
    [self addSubview:_nextButton];
    [self addSubview:_centerFaceInstructionLabel];
    
    [[_centerFaceInstructionLabel.centerXAnchor constraintEqualToAnchor:self.centerXAnchor] setActive:YES];
    [[_centerFaceInstructionLabel.topAnchor constraintEqualToAnchor:self.topAnchor constant:25.0] setActive:YES];
    [[_centerFaceInstructionLabel.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:15.0] setActive:YES];
    [[_centerFaceInstructionLabel.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-15.0] setActive:YES];
    
    if ([ARFaceTrackingConfiguration isSupported]) {
        [self addSubview:_arSceneView];
        [[_arSceneView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant: 15.0] setActive:YES];
        [[_arSceneView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant: -15.0] setActive:YES];
        [[_arSceneView.topAnchor constraintEqualToAnchor:_centerFaceInstructionLabel.bottomAnchor constant:15.0] setActive:YES];
        [[_arSceneView.bottomAnchor constraintEqualToAnchor:_nextButton.topAnchor constant:-15.0] setActive:YES];
        [[_arSceneView.heightAnchor constraintGreaterThanOrEqualToConstant:400.0] setActive:YES];
    } else {
        [self addSubview:_cameraView];
        [[_cameraView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant: 15.0] setActive:YES];
        [[_cameraView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant: -15.0] setActive:YES];
        [[_cameraView.topAnchor constraintEqualToAnchor:_centerFaceInstructionLabel.bottomAnchor constant:15.0] setActive:YES];
        [[_cameraView.bottomAnchor constraintEqualToAnchor:_nextButton.topAnchor constant:-15.0] setActive:YES];
        [[_cameraView.heightAnchor constraintGreaterThanOrEqualToConstant:400.0] setActive:YES];
    }
    
    [[_nextButton.centerXAnchor constraintEqualToAnchor:self.centerXAnchor] setActive:YES];
    [[_nextButton.bottomAnchor constraintEqualToAnchor:_alignmentTimerLabel.topAnchor constant:-15.0] setActive:YES];
    [[_nextButton.widthAnchor constraintEqualToConstant:100.0] setActive:YES];
    
    [[_alignmentTimerLabel.centerXAnchor constraintEqualToAnchor:self.centerXAnchor] setActive:YES];
    [[_alignmentTimerLabel.bottomAnchor constraintGreaterThanOrEqualToAnchor:self.bottomAnchor constant:-8.0] setActive:YES];
    
}

- (void)setPreviewLayerWithSession:(AVCaptureSession *)session {
    _previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:session];
    _previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    _previewLayer.connection.videoOrientation = AVCaptureVideoOrientationPortrait;
    
    [_cameraView.layer addSublayer:_previewLayer];
}

- (void)updateTimerLabelWithSeconds:(int)seconds {
    if (_detectionOverlayView) {
        if (seconds < 10) {
            [_alignmentTimerLabel setText:[NSString stringWithFormat:@"0:0%i", seconds]];
        } else if (seconds >= 10 && seconds < 60) {
            [_alignmentTimerLabel setText:[NSString stringWithFormat:@"0:%i", seconds]];
        } else if (seconds == 60) {
            [_alignmentTimerLabel setText:@"1:00"];
        }
    }
}

- (ARSCNView *)arSceneView {
    return _arSceneView;
}

- (void)setFaceDetected:(BOOL)detected {
    if (_detectionOverlayView) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
            dispatch_async(dispatch_get_main_queue(), ^(void){
                [_detectionOverlayView wasFaceDetected:detected];
                [self toggleNextButtonEnabled:detected];
            });
        });
    }
}

- (void)toggleNextButtonEnabled:(BOOL)detected {
    if (_nextButton) {
        [_nextButton setEnabled:detected];
        [_nextButton.layer setBorderColor:detected ? [UIColor blueColor].CGColor : [UIColor grayColor].CGColor];
    }
}

@end



