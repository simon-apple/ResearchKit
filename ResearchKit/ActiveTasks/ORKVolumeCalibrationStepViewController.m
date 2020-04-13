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

#import "ORKVolumeCalibrationStepViewController.h"
#import "ORKActiveStepViewController_Internal.h"
#import "ORKActiveStepView.h"
#import "ORKVolumeCalibrationContentView.h"
#import "ORKStepContainerView_Private.h"

#import <AVFoundation/AVFoundation.h>

@interface ORKVolumeCalibrationStepViewController () <ORKVolumeCalibrationContentViewDelegate>
@property (nonatomic, strong) ORKVolumeCalibrationContentView *volumeCalibrationContentView;
@property (nonatomic, strong) AVAudioEngine *audioEngine;
@property (nonatomic, strong) AVAudioPlayerNode *playerNode;
@property (nonatomic, strong) AVAudioPCMBuffer *audioBuffer;
@end

@implementation ORKVolumeCalibrationStepViewController

#pragma mark - ORKActiveStepViewController

- (instancetype)initWithStep:(ORKStep *)step
{
    self = [super initWithStep:step];
    if (self)
    {
        [self setupAudioEngine];
    }
    return self;
}

- (void)setupAudioEngine
{
    NSURL *path = [[NSBundle bundleForClass:[self class]] URLForResource:@"VolumeCalibration" withExtension:@"wav"];
    AVAudioFile *file = [[AVAudioFile alloc] initForReading:path error:nil];
    if (file)
    {
        self.audioBuffer = [[AVAudioPCMBuffer alloc] initWithPCMFormat:file.processingFormat frameCapacity:(AVAudioFrameCount)file.length];
        [file readIntoBuffer:self.audioBuffer error:nil];
    }
    
    self.audioEngine = [[AVAudioEngine alloc] init];
    self.playerNode = [[AVAudioPlayerNode alloc] init];
    [self.audioEngine attachNode:self.playerNode];
    [self.audioEngine connect:self.playerNode to:self.audioEngine.outputNode format:self.audioBuffer.format];
    [self.playerNode scheduleBuffer:self.audioBuffer atTime:nil options:AVAudioPlayerNodeBufferLoops completionHandler:nil];
    [self.audioEngine prepare];
    [self.audioEngine startAndReturnError:nil];
}

- (void)tearDownAudioEngine
{
    [self.playerNode stop];
    [self.audioEngine stop];
}

- (void)start
{
    [super start];
}

- (ORKStepResult *)result
{
    return [super result];
}

- (void)goForward
{
    [self tearDownAudioEngine];
    [super goForward];
}

- (void)finish
{
    [super finish];
    [super goForward];
}
#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.volumeCalibrationContentView = [[ORKVolumeCalibrationContentView alloc] init];
    self.volumeCalibrationContentView.delegate = self;
    self.activeStepView.activeCustomView = _volumeCalibrationContentView;
}

#pragma mark - ORKVolumeCalibrationContentViewDelegate

- (BOOL)contentView:(ORKVolumeCalibrationContentView *)contentView didPressPlaybackButton:(ORKPlaybackButton *)playbackButton
{
    if (self.audioEngine.isRunning && !self.playerNode.isPlaying)
    {
        [self.playerNode play];
        return YES;
    }
    else
    {
        [self tearDownAudioEngine];
        [self finish];
        return NO;
    }
}

@end
