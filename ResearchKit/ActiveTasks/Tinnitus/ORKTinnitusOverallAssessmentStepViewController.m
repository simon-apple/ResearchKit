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

#import "ORKTinnitusOverallAssessmentStepViewController.h"

#import "ORKActiveStepView.h"
#import "ORKTinnitusPredefinedTask.h"

#import "ORKActiveStepViewController_Internal.h"
#import "ORKStepViewController_Internal.h"

#import "ORKTinnitusOverallAssessmentResult.h"
#import "ORKTinnitusOverallAssessmentStep.h"
#import "ORKTinnitusAssessmentContentView.h"
#import "ORKTinnitusAudioSample.h"
#import "ORKTinnitusAudioGenerator.h"

#import "ORKStepContainerView_Private.h"
#import "ORKNavigationContainerView_Internal.h"
#import "ORKHelpers_Internal.h"
#import "ResearchKit_Private.h"

@import AVFoundation;

@interface ORKTinnitusOverallAssessmentStepViewController () <ORKTinnitusAssessmentContentViewDelegate> {
    AVAudioEngine *_audioEngine;
    AVAudioPlayerNode *_playerNode;
    AVAudioPCMBuffer *_audioBuffer;
}

@property (nonatomic, strong) ORKTinnitusAssessmentContentView *assessmentContentView;
@property (nonatomic, strong) ORKTinnitusAudioGenerator *audioGenerator;

@end

@implementation ORKTinnitusOverallAssessmentStepViewController

- (ORKTinnitusOverallAssessmentStep *)tinnitusMaskingSoundStep {
    return (ORKTinnitusOverallAssessmentStep *)self.step;
}

- (ORKTinnitusPredefinedTaskContext *)tinnitusPredefinedTaskContext {
    if (self.step.context && [self.step.context isKindOfClass:[ORKTinnitusPredefinedTaskContext class]]) {
        return (ORKTinnitusPredefinedTaskContext *)self.step.context;
    }
    return nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (self.tinnitusPredefinedTaskContext) {
        ORKTinnitusPredefinedTaskContext *context = self.tinnitusPredefinedTaskContext;
        
        if (context.predominantFrequency > 0.0) {
            self.audioGenerator = [[ORKTinnitusAudioGenerator alloc] initWithHeadphoneType:context.headphoneType];
        } else if (context.tinnitusIdentifier && ![context.tinnitusIdentifier isEqualToString:@""]) {
            _audioBuffer = [[AVAudioPCMBuffer alloc] init];
            _audioEngine = [[AVAudioEngine alloc] init];
            _playerNode = [[AVAudioPlayerNode alloc] init];
            [_audioEngine attachNode:_playerNode];

            NSError *error;
            if (![self setupAudioEngineForWhiteNoiseSound:context.tinnitusIdentifier error:&error]) {
                ORK_Log_Error("Error fetching audioSample: %@", error);
            }
        }
    }
    
    self.assessmentContentView = [[ORKTinnitusAssessmentContentView alloc] initForTinnitusOverallAssesment];
    self.activeStepView.activeCustomView = self.assessmentContentView;
    self.assessmentContentView.delegate = self;
            
    [self setNavigationFooterView];
    
#if !TARGET_IPHONE_SIMULATOR
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(headphoneChanged:) name:ORKHeadphoneNotificationSuspendActivity object:nil];
#endif
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:ORKHeadphoneNotificationSuspendActivity object:nil];
}

- (BOOL)setupAudioEngineForWhiteNoiseSound:(NSString *)identifier error:(NSError **)outError {
    if (self.tinnitusPredefinedTaskContext) {
        ORKTinnitusAudioManifest *audioManifest = self.tinnitusPredefinedTaskContext.audioManifest;
        ORKTinnitusAudioSample *audioSample = [audioManifest noiseTypeSampleWithIdentifier:identifier error:outError];
        
        if (audioSample) {
            AVAudioPCMBuffer *buffer = [audioSample getBuffer:outError];
            
            if (buffer) {
                _audioBuffer = buffer;
                [_audioEngine connect:_playerNode to:_audioEngine.outputNode format:_audioBuffer.format];
                [_playerNode scheduleBuffer:_audioBuffer atTime:nil options:AVAudioPlayerNodeBufferLoops completionHandler:nil];
                [_audioEngine prepare];
                return [_audioEngine startAndReturnError:outError];
            }            
        }
    }
    return NO;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (@available(iOS 13.0, *)) {
        self.view.backgroundColor = UIColor.systemGroupedBackgroundColor;
        self.taskViewController.navigationBar.barTintColor = UIColor.systemGroupedBackgroundColor;
        [self.taskViewController.navigationBar setTranslucent:NO];
    }
}

- (void)headphoneChanged:(NSNotification *)note {
    if (self.tinnitusPredefinedTaskContext != nil) {
        [self stopAudio];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.assessmentContentView setPlaybackButtonPlaying:NO];
            self.assessmentContentView.delegate = nil;
        });
    }
}

- (void)stopAudio {
    if (_playerNode) {
        [_playerNode stop];
        [_audioEngine stop];
        _audioBuffer = nil;
        _audioEngine = nil;
        _playerNode = nil;
    }
    if (_audioGenerator) {
        [_audioGenerator stop];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self stopAudio];
}

- (void)setNavigationFooterView {
    self.activeStepView.navigationFooterView.continueButtonItem = self.internalContinueButtonItem;
    [self.activeStepView.navigationFooterView updateContinueAndSkipEnabled];
    self.activeStepView.navigationFooterView.continueEnabled = NO;
}

- (ORKStepResult *)result {
    ORKStepResult *sResult = [super result];
    NSDate *now = sResult.endDate;
    
    NSMutableArray *results = [NSMutableArray arrayWithArray:sResult.results];
    
    ORKTinnitusOverallAssessmentResult *tinnitusAssessmentResult = [[ORKTinnitusOverallAssessmentResult alloc] initWithIdentifier:self.step.identifier];
    tinnitusAssessmentResult.startDate = sResult.startDate;
    tinnitusAssessmentResult.endDate = now;
    tinnitusAssessmentResult.answer = [_assessmentContentView getAnswer];

    [results addObject:tinnitusAssessmentResult];
    sResult.results = [results copy];
    
    return sResult;
}

- (void)buttonCheckedWithValue:(nonnull NSString *)value {
    self.activeStepView.navigationFooterView.continueEnabled = YES;
}

- (BOOL)pressedPlaybackButton:(nonnull UIButton *)playbackButton {
    if (self.tinnitusPredefinedTaskContext) {
        ORKTinnitusPredefinedTaskContext *context = self.tinnitusPredefinedTaskContext;
        
        if (context.predominantFrequency > 0.0) {
            if (self.audioGenerator.isPlaying) {
                [self.audioGenerator stop];
                return NO;
            } else {
                [self.audioGenerator playSoundAtFrequency:context.predominantFrequency];
                return YES;
            }
        } else if (_playerNode) {
            if (_playerNode.isPlaying) {
                [_playerNode pause];
                return NO;
            } else {
                [_playerNode play];
                return YES;
            }
        }
    }
    return NO;
}

@end
