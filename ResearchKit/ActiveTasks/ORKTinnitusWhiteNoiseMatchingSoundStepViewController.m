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

#import "ORKTinnitusWhiteNoiseMatchingSoundStepViewController.h"
#import "ORKTinnitusWhiteNoiseMatchingSoundStep.h"
#import "ORKTinnitusWhiteNoiseMatchingSoundContentView.h"
#import "ORKTinnitusPredefinedTaskConstants.h"
#import "ORKTinnitusWhiteNoiseMatchingSoundResult.h"
#import "ORKTinnitusAudioSample.h"

#import "ORKActiveStepView.h"
#import "ORKActiveStepViewController_Internal.h"
#import "ORKStepViewController_Internal.h"
#import "ORKStepContainerView_Private.h"
#import "ORKNavigationContainerView_Internal.h"
#import "ORKHelpers_Internal.h"
#import <ResearchKit/ResearchKit_Private.h>

#import "ORKSkin.h"

@interface ORKTinnitusWhiteNoiseMatchingSoundStepViewController () <ORKTinnitusButtonViewDelegate> {
    ORKTinnitusWhiteNoiseMatchingSoundContentView *_maskingContentView;
}

@property (nonatomic, strong) AVAudioEngine *audioEngine;
@property (nonatomic, strong) AVAudioPlayerNode *playerNode;
@property (nonatomic, strong) AVAudioPCMBuffer *audioBuffer;

@end

@implementation ORKTinnitusWhiteNoiseMatchingSoundStepViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setNavigationFooterView];
    
    _maskingContentView = [[ORKTinnitusWhiteNoiseMatchingSoundContentView alloc] init];
    self.activeStepView.activeCustomView = _maskingContentView;
    self.activeStepView.customContentFillsAvailableSpace = YES;
    _maskingContentView.translatesAutoresizingMaskIntoConstraints = NO;

    _maskingContentView.whitenoiseButtonView.delegate = self;
    _maskingContentView.cicadasButtonView.delegate = self;
    _maskingContentView.cricketsButtonView.delegate = self;
    _maskingContentView.teakettleButtonView.delegate = self;
    
    self.audioEngine = [[AVAudioEngine alloc] init];
    self.playerNode = [[AVAudioPlayerNode alloc] init];
    [self.audioEngine attachNode:self.playerNode];
}

- (void)tearDownAudioEngine
{
    [self.playerNode stop];
    [self.audioEngine stop];
}

- (void)playSound:(NSString *)soundName {
    [self tearDownAudioEngine];
    
    ORKTinnitusPredefinedTaskContext *context = (ORKTinnitusPredefinedTaskContext *)[self.step context];
    NSArray *samples = context.audioManifest.samples;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name ==[c] %@", soundName];
    ORKTinnitusAudioSample *audioSample = [[samples filteredArrayUsingPredicate:predicate] firstObject];
    
    if (audioSample) {
        NSURL *path = [NSURL fileURLWithPath:audioSample.path];
        AVAudioFile *file = [[AVAudioFile alloc] initForReading:path error:nil];
        
        if (file)
        {
            self.audioBuffer = [[AVAudioPCMBuffer alloc] initWithPCMFormat:file.processingFormat frameCapacity:(AVAudioFrameCount)file.length];
            [file readIntoBuffer:self.audioBuffer error:nil];
        }
        
        [self.audioEngine connect:self.playerNode to:self.audioEngine.outputNode format:self.audioBuffer.format];
        [self.playerNode scheduleBuffer:self.audioBuffer atTime:nil options:AVAudioPlayerNodeBufferLoops completionHandler:nil];
        [self.audioEngine prepare];
        [self.audioEngine startAndReturnError:nil];
        
        [self.playerNode play];
    }
}

- (void)setNavigationFooterView
{
    self.activeStepView.navigationFooterView.continueButtonItem = self.internalContinueButtonItem;
    self.activeStepView.navigationFooterView.continueEnabled = NO;
    [self.activeStepView.navigationFooterView updateContinueAndSkipEnabled];
}

- (void)tinnitusButtonViewPressed:(ORKTinnitusButtonView * _Nonnull)tinnitusButtonView {
    [_maskingContentView unselectAllExcept:tinnitusButtonView];
    [self tearDownAudioEngine];
    
    if (tinnitusButtonView.isShowingPause) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (tinnitusButtonView == _maskingContentView.cicadasButtonView) {
                [self playSound:ORKTinnitusMaskingSoundCicadas];
            } else if (tinnitusButtonView == _maskingContentView.cricketsButtonView) {
                [self playSound:ORKTinnitusMaskingSoundCrickets];
            } else if (tinnitusButtonView == _maskingContentView.whitenoiseButtonView) {
                [self playSound:ORKTinnitusMaskingSoundWhiteNoise];
            } else if (tinnitusButtonView == _maskingContentView.teakettleButtonView) {
                [self playSound:ORKTinnitusMaskingSoundTeakettle];
            }
        });
    }
    if (_maskingContentView.cicadasButtonView.playedOnce && _maskingContentView.cricketsButtonView.playedOnce && _maskingContentView.whitenoiseButtonView.playedOnce && _maskingContentView.teakettleButtonView.playedOnce) {
        self.activeStepView.navigationFooterView.continueEnabled = YES;
    }
}

- (ORKStepResult *)result
{
    ORKStepResult *parentResult = [super result];
    
    NSMutableArray *results = [NSMutableArray arrayWithArray:parentResult.results];
    
    ORKTinnitusWhiteNoiseMatchingSoundResult *maskingResult = [[ORKTinnitusWhiteNoiseMatchingSoundResult alloc] initWithIdentifier:self.step.identifier];
    
    maskingResult.answer = [_maskingContentView getAnswer];
    
    [results addObject:maskingResult];
    
    parentResult.results = results;
    
    return parentResult;
}

- (void)goForward
{
    [self tearDownAudioEngine];
    [super goForward];
}

@end
