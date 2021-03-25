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

#import "ORKTinnitusTypeStepViewController.h"
#import "ORKTinnitusTypeStep.h"
#import "ORKTinnitusTypeContentView.h"
#import "ORKTinnitusButtonView.h"
#import "ORKTinnitusTypeResult.h"
#import "ORKTinnitusAudioSample.h"

#import "ORKActiveStepView.h"
#import "ORKActiveStepViewController_Internal.h"
#import "ORKStepViewController_Internal.h"
#import "ORKStepContainerView_Private.h"
#import "ORKNavigationContainerView_Internal.h"
#import "ORKHelpers_Internal.h"
#import "ResearchKit_Private.h"

#import "ORKSkin.h"

static const NSTimeInterval PLAY_DELAY = 0.3;
static const NSTimeInterval PLAY_DURATION = 3.0;

@interface ORKTinnitusTypeStepViewController () <ORKTinnitusButtonViewDelegate> {
    ORKTinnitusTypeContentView *_tinnitusTypeContentView;
    int _sampleIndex;
    NSTimer *_timer;
    BOOL _noneAreSimilarFlag;
}

@property (nonatomic, strong) AVAudioEngine *audioEngine;
@property (nonatomic, strong) AVAudioPlayerNode *playerNode;
@property (nonatomic, strong) AVAudioPCMBuffer *audioBuffer;

@end

@implementation ORKTinnitusTypeStepViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _noneAreSimilarFlag = NO;
    
    [self setNavigationFooterView];
    
    ORKTinnitusPredefinedTaskContext *context = (ORKTinnitusPredefinedTaskContext *)self.step.context;
    
    _tinnitusTypeContentView = [[ORKTinnitusTypeContentView alloc] initWithContext:context];
    self.activeStepView.activeCustomView = _tinnitusTypeContentView;
    self.activeStepView.customContentFillsAvailableSpace = YES;
    _tinnitusTypeContentView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [_tinnitusTypeContentView.buttonsViewArray makeObjectsPerformSelector:@selector(setDelegate:) withObject:self];
    
    self.audioEngine = [[AVAudioEngine alloc] init];
    self.playerNode = [[AVAudioPlayerNode alloc] init];
    [self.audioEngine attachNode:self.playerNode];
    
    self.activeStepView.navigationFooterView.optional = YES;
    
    [self performSelector:@selector(startAutomaticPlay) withObject:nil afterDelay:PLAY_DELAY];
}

- (void)setSkipButtonItem:(UIBarButtonItem *)skipButtonItem {
    [skipButtonItem setTitle:ORKLocalizedString(@"TINNITUS_TYPE_SKIP_BUTTON_TITLE", nil)];
    skipButtonItem.target = self;
    skipButtonItem.action = @selector(skipTaskAction);
    
    self.activeStepView.navigationFooterView.skipButtonItem = skipButtonItem;
    self.activeStepView.navigationFooterView.skipEnabled = NO;
    
    [super setSkipButtonItem:skipButtonItem];
}

- (void)skipTaskAction {
    _noneAreSimilarFlag = YES;
    [self finish];
}

- (void)startAutomaticPlay {
    _sampleIndex = 0;
    _timer = [NSTimer scheduledTimerWithTimeInterval:PLAY_DURATION
                                              target:self
                                            selector:@selector(playNextSample)
                                            userInfo:nil
                                             repeats:YES];
}

- (void)playNextSample {
    if (_sampleIndex > _tinnitusTypeContentView.buttonsViewArray.count - 1) {
        [_tinnitusTypeContentView.buttonsViewArray[_sampleIndex - 1] simulateTap];
        [self stopAutomaticPlay];
    } else {
        [_tinnitusTypeContentView.buttonsViewArray[_sampleIndex] simulateTap];
    }
    _sampleIndex = _sampleIndex + 1;
    
}

- (void)stopAutomaticPlay {
    [NSObject cancelPreviousPerformRequestsWithTarget:self
                                             selector:@selector(startAutomaticPlay)
                                               object:nil];
    [_timer invalidate];
    _timer = nil;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self stopAutomaticPlay];
    [self tearDownAudioEngine];
}

- (void)tearDownAudioEngine {
    [self.playerNode stop];
    [self.audioEngine stop];
}

- (BOOL)playSound:(NSString *)identifier error:(NSError **)outError {
    [self tearDownAudioEngine];
    
    if (self.step.context && [self.step.context isKindOfClass:[ORKTinnitusPredefinedTaskContext class]]) {
        ORKTinnitusPredefinedTaskContext *context = (ORKTinnitusPredefinedTaskContext *)self.step.context;
        ORKTinnitusAudioSample *audioSample = [context.audioManifest noiseTypeSampleWithIdentifier:identifier error:outError];
        
        if (audioSample) {
            AVAudioPCMBuffer *buffer = [audioSample getBuffer:outError];
            
            if (buffer) {
                self.audioBuffer = buffer;
                [self.audioEngine connect:self.playerNode to:self.audioEngine.outputNode format:self.audioBuffer.format];
                [self.playerNode scheduleBuffer:self.audioBuffer atTime:nil options:AVAudioPlayerNodeBufferLoops completionHandler:nil];
                [self.audioEngine prepare];
                if ([self.audioEngine startAndReturnError:outError]) {
                    [self.playerNode play];
                    return YES;
                }
            }
        }
    }
    return NO;
}

- (void)setNavigationFooterView {
    self.activeStepView.navigationFooterView.continueButtonItem = self.internalContinueButtonItem;
    self.activeStepView.navigationFooterView.continueEnabled = NO;
    [self.activeStepView.navigationFooterView updateContinueAndSkipEnabled];
}

- (void)tinnitusButtonViewPressed:(ORKTinnitusButtonView * _Nonnull)tinnitusButtonView {
    if (!tinnitusButtonView.isSimulatedTap) {
        [self stopAutomaticPlay];
    }
    
    [self tearDownAudioEngine];
    
    if (tinnitusButtonView.isShowingPause) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSError *error;
            [self playSound:tinnitusButtonView.answer error:&error];
            [_tinnitusTypeContentView selectButton:tinnitusButtonView];
            if (error) {
                ORK_Log_Error("Error fetching audioSample: %@", error);
            }
        });
    }
    
    __block BOOL allPlayedAtLeastOnce = YES;
    [_tinnitusTypeContentView.buttonsViewArray indexOfObjectPassingTest:^BOOL(ORKTinnitusButtonView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (!obj.playedOnce) {
            allPlayedAtLeastOnce = NO;
            *stop = YES;
            return YES;
        }
        return NO;
    }];
    if (allPlayedAtLeastOnce) {
        self.activeStepView.navigationFooterView.continueEnabled = YES;
        self.activeStepView.navigationFooterView.skipEnabled = YES;
    }
}

- (ORKStepResult *)result {
    ORKStepResult *parentResult = [super result];
    
    NSMutableArray *results = [NSMutableArray arrayWithArray:parentResult.results];
    
    ORKTinnitusTypeResult *typeResult = [[ORKTinnitusTypeResult alloc] initWithIdentifier:self.step.identifier];
    
    typeResult.type = _noneAreSimilarFlag ? ORKTinnitusTypeUnknown : [_tinnitusTypeContentView getType];
    
    typeResult.tinnitusIdentifier = _noneAreSimilarFlag ? @"NONEARESIMILAR" : [_tinnitusTypeContentView getAnswer];
    
    [results addObject:typeResult];
    
    parentResult.results = results;
    
    return parentResult;
}

- (void)finish {
    [super finish];
    
    [self tearDownAudioEngine];
    [self goForward];
}

@end
