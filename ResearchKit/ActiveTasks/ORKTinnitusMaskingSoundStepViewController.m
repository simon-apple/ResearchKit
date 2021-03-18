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
#import "ORKTinnitusMaskingSoundContentView.h"
#import "ORKTinnitusAudioSample.h"

#import "ORKStepContainerView_Private.h"
#import "ORKNavigationContainerView_Internal.h"
#import "ORKHelpers_Internal.h"
#import <ResearchKit/ResearchKit_Private.h>

#import <AVFoundation/AVFoundation.h>

NSString *const ORKTinnitusPuretoneMaskSoundNameExtension = @"wav";

@interface ORKTinnitusMaskingSoundStepViewController () <ORKTinnitusButtonViewDelegate, ORKTinnitusMaskingSoundContentViewDelegate> {
    AVAudioEngine *_audioEngine;
    AVAudioPlayerNode *_playerNode;
    AVAudioMixerNode *_mixerNode;
    AVAudioPCMBuffer *_audioBuffer;
    
    NSString *_selectedValue;
}

@property (nonatomic, strong) ORKTinnitusMaskingSoundContentView *matchingSoundContentView;

- (ORKTinnitusMaskingSoundStep *)tinnitusMaskingSoundStep;

@end

@implementation ORKTinnitusMaskingSoundStepViewController

- (ORKTinnitusMaskingSoundStep *)tinnitusMaskingSoundStep {
    return (ORKTinnitusMaskingSoundStep *)self.step;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString *buttonTitle = [[self tinnitusMaskingSoundStep] name];
    NSString *soundIdentifier = [[self tinnitusMaskingSoundStep] soundIdentifier];
    
    self.matchingSoundContentView = [[ORKTinnitusMaskingSoundContentView alloc] initWithButtonTitle:buttonTitle];
    self.matchingSoundContentView.playButtonView.delegate = self;
    self.activeStepView.activeCustomView = self.matchingSoundContentView;
    self.matchingSoundContentView.delegate = self;
    
    self.activeStepView.customContentFillsAvailableSpace = YES;
    
    _audioBuffer = [[AVAudioPCMBuffer alloc] init];
    _audioEngine = [[AVAudioEngine alloc] init];
    _playerNode = [[AVAudioPlayerNode alloc] init];
    
    [_audioEngine attachNode:_playerNode];
    
    NSError *error;
    if (![self setupAudioEngineForSound:soundIdentifier error:&error]) {
        ORK_Log_Error("Error fetching audioSample: %@", error);
    }
    
    [self setNavigationFooterView];
}

- (BOOL)setupAudioEngineForSound:(NSString *)identifier error:(NSError **)outError {
    if (self.step.context && [self.step.context isKindOfClass:[ORKTinnitusPredefinedTaskContext class]]) {
        ORKTinnitusPredefinedTaskContext *context = (ORKTinnitusPredefinedTaskContext *)self.step.context;
        ORKTinnitusAudioSample *audioSample = [context.audioManifest maskingSampleWithIdentifier:identifier error:outError];
        
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


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (_playerNode) {
        [_playerNode stop];
        [_playerNode removeTapOnBus:0];
        [_audioEngine stop];
        _audioBuffer = nil;
        _audioEngine = nil;
        _playerNode = nil;
        _mixerNode = nil;
    }
}

- (void)setNavigationFooterView {
    self.activeStepView.navigationFooterView.continueButtonItem = self.internalContinueButtonItem;
    self.activeStepView.navigationFooterView.continueEnabled = NO;
    [self.activeStepView.navigationFooterView updateContinueAndSkipEnabled];
}

- (void)start {
    [super start];
}

- (ORKStepResult *)result {
    ORKStepResult *sResult = [super result];
    NSDate *now = sResult.endDate;
    
    NSMutableArray *results = [NSMutableArray arrayWithArray:sResult.results];
    
    ORKTinnitusMaskingSoundResult *matchingSoundResult = [[ORKTinnitusMaskingSoundResult alloc] initWithIdentifier:self.step.identifier];
    matchingSoundResult.startDate = sResult.startDate;
    matchingSoundResult.endDate = now;
    matchingSoundResult.answer = [_matchingSoundContentView getAnswer];

    [results addObject:matchingSoundResult];
    sResult.results = [results copy];
    
    return sResult;
}

- (void)tinnitusButtonViewPressed:(ORKTinnitusButtonView * _Nonnull)tinnitusButtonView {
    [self.matchingSoundContentView enableButtons];
    if (_playerNode.isPlaying) {
        [_playerNode pause];
    } else {
        [_playerNode play];
    }
}

- (void)buttonCheckedWithValue:(nonnull NSString *)value {
    _selectedValue = value;
    self.activeStepView.navigationFooterView.continueEnabled = YES;
}

@end
