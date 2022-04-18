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

#import "ORKTinnitusMaskingSoundStepViewController.h"

#import "ORKActiveStepView.h"
#import "ORKTinnitusPredefinedTask.h"
#import "ORKTinnitusTypes.h"

#import "ORKActiveStepViewController_Internal.h"
#import "ORKStepViewController_Internal.h"

#import "ORKTinnitusMaskingSoundResult.h"
#import "ORKTinnitusMaskingSoundStep.h"
#import "ORKTinnitusAssessmentContentView.h"
#import "ORKTinnitusAudioSample.h"
#import "ORKTinnitusHeadphoneTable.h"
#import "AVAudioMixerNode+Fade.h"

#import "ORKStepContainerView_Private.h"
#import "ORKNavigationContainerView_Internal.h"
#import "ORKHelpers_Internal.h"
#import <ResearchKit/ResearchKit_Private.h>

@import AVFoundation;

const NSTimeInterval ORKTinnitusMaskingSoundFadeDuration = 0.1;
const NSTimeInterval ORKTinnitusMaskingSoundFadeStep = 0.01;

@interface ORKTinnitusMaskingSoundStepViewController () <ORKTinnitusAssessmentContentViewDelegate> {
    AVAudioEngine *_audioEngine;
    AVAudioMixerNode *_mixerNode;
    AVAudioPlayerNode *_playerNode;
    AVAudioPCMBuffer *_audioBuffer;
    
    NSString *_selectedValue;
}

@property (nonatomic, strong) ORKTinnitusAssessmentContentView *assessmentContentView;

- (ORKTinnitusMaskingSoundStep *)tinnitusMaskingSoundStep;

@end

@implementation ORKTinnitusMaskingSoundStepViewController

- (ORKTinnitusMaskingSoundStep *)tinnitusMaskingSoundStep {
    return (ORKTinnitusMaskingSoundStep *)self.step;
}

- (ORKTinnitusPredefinedTaskContext *)tinnitusPredefinedTaskContext {
    if (self.step.context && [self.step.context isKindOfClass:[ORKTinnitusPredefinedTaskContext class]]) {
        return (ORKTinnitusPredefinedTaskContext *)self.step.context;
    }
    return nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _audioBuffer = [[AVAudioPCMBuffer alloc] init];
    _audioEngine = [[AVAudioEngine alloc] init];
    _playerNode = [[AVAudioPlayerNode alloc] init];
    [_audioEngine attachNode:_playerNode];
    
    NSError *error;
    if (![self setupAudioEngineForSound:self.tinnitusMaskingSoundStep.soundIdentifier error:&error]) {
        ORK_Log_Error("Error fetching audioSample: %@", error);
    }
        
    self.assessmentContentView = [[ORKTinnitusAssessmentContentView alloc] initForMaskingWithButtonTitle:self.tinnitusMaskingSoundStep.name];
    self.activeStepView.activeCustomView = self.assessmentContentView;
    self.assessmentContentView.delegate = self;
    
    self.continueButtonItem = self.internalContinueButtonItem;
    [self setNavigationFooterView];
    
#if !TARGET_IPHONE_SIMULATOR
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(headphoneChanged:) name:ORKHeadphoneNotificationSuspendActivity object:nil];
#endif
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:ORKHeadphoneNotificationSuspendActivity object:nil];
}

- (BOOL)setupAudioEngineForSound:(NSString *)identifier error:(NSError **)outError {
    if (self.tinnitusPredefinedTaskContext) {
        ORKTinnitusAudioManifest *audioManifest = self.tinnitusPredefinedTaskContext.audioManifest;
        ORKTinnitusAudioSample *audioSample = [audioManifest maskingSampleWithIdentifier:identifier error:outError];
        
        if (audioSample) {
            AVAudioPCMBuffer *buffer = [audioSample getBuffer:outError];
            
            if (buffer) {
                _mixerNode = _audioEngine.mainMixerNode;
                _audioBuffer = buffer;
                [_audioEngine connect:_playerNode to:_mixerNode format:buffer.format];
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

- (void)tearDownAudioEngine {
    if (_playerNode) {
        [_playerNode stop];
        [_mixerNode removeTapOnBus:0];
        [_audioEngine stop];
        _audioBuffer = nil;
        _audioEngine = nil;
        _playerNode = nil;
        _mixerNode = nil;
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self stopSample];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self tearDownAudioEngine];
}

- (void)headphoneChanged:(NSNotification *)note {
    if (self.tinnitusPredefinedTaskContext != nil) {
        [self stopSample];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.assessmentContentView setPlaybackButtonPlaying:NO];
            self.assessmentContentView.delegate = nil;
        });
    }
}

- (void)setNavigationFooterView {
    self.activeStepView.navigationFooterView.continueButtonItem = self.internalContinueButtonItem;
    [self.activeStepView.navigationFooterView updateContinueAndSkipEnabled];
}

- (ORKStepResult *)result {
    ORKStepResult *sResult = [super result];
    NSDate *now = sResult.endDate;
    
    NSMutableArray *results = [NSMutableArray arrayWithArray:sResult.results];
    
    ORKTinnitusMaskingSoundResult *matchingSoundResult = [[ORKTinnitusMaskingSoundResult alloc] initWithIdentifier:self.step.identifier];
    matchingSoundResult.startDate = sResult.startDate;
    matchingSoundResult.endDate = now;
    matchingSoundResult.answer = [_assessmentContentView getAnswer];
    
    [results addObject:matchingSoundResult];
    sResult.results = [results copy];
    
    return sResult;
}

- (void)playSample {
    _mixerNode.outputVolume = 0.0;
    [_playerNode play];
    [_mixerNode fadeInWithDuration:ORKTinnitusMaskingSoundFadeDuration stepInterval:ORKTinnitusMaskingSoundFadeStep completion:nil];
}

- (void)stopSample {
    [_mixerNode fadeOutWithDuration:ORKTinnitusMaskingSoundFadeDuration stepInterval:ORKTinnitusMaskingSoundFadeStep completion:^{
        [_playerNode pause];
    }];
}

#pragma mark - ORKTinnitusAssessmentContentViewDelegate

- (void)buttonCheckedWithValue:(nonnull NSString *)value {
    _selectedValue = value;
}

- (BOOL)pressedPlaybackButton:(nonnull UIButton *)playbackButton {
    if (_playerNode.isPlaying) {
        [self stopSample];
        return NO;
    } else {
        [self playSample];
        return YES;
    }
}

- (void)shouldEnableContinue:(BOOL)enable {
    self.activeStepView.navigationFooterView.continueEnabled = enable;
}

@end
