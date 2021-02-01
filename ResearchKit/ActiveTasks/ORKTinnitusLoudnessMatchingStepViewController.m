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

#import "ORKTinnitusLoudnessMatchingStepViewController.h"
#import "ORKTinnitusCalibrationContentView.h"
#import "ORKTinnitusLoudnessMatchingStep.h"
#import "ORKTinnitusTypeResult.h"
#import "ORKTinnitusAudioGenerator.h"
#import "ORKTinnitusLoudnessMatchingResult.h"
#import "ORKTinnitusPredefinedTaskConstants.h"
#import "ORKTinnitusAudioSample.h"

#import "ORKActiveStepView.h"
#import "ORKActiveStepViewController_Internal.h"
#import "ORKStepViewController_Internal.h"
#import "ORKStepContainerView_Private.h"
#import "ORKNavigationContainerView_Internal.h"
#import "ORKTinnitusButtonView.h"
#import "ORKTinnitusTypes.h"

#import "ORKHelpers_Internal.h"

@interface ORKTinnitusLoudnessMatchingStepViewController () <ORKTinnitusButtonViewDelegate>

@property (nonatomic, strong) ORKTinnitusCalibrationContentView *contentView;
@property (nonatomic, strong) ORKTinnitusAudioGenerator *audioGenerator;
@property (nonatomic, copy) ORKTinnitusType type;
@property (nonatomic, assign) double frequency;
@property (nonatomic, strong) AVAudioEngine *audioEngine;
@property (nonatomic, strong) AVAudioPlayerNode *playerNode;
@property (nonatomic, strong) AVAudioPCMBuffer *audioBuffer;

- (ORKTinnitusLoudnessMatchingStep *)loudnessStep;

@end

@implementation ORKTinnitusLoudnessMatchingStepViewController


- (ORKTinnitusLoudnessMatchingStep *)loudnessStep {
    return (ORKTinnitusLoudnessMatchingStep *)self.step;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    ORKTaskResult *taskResults = [[self taskViewController] result];
    
    // defining a default value here because headphone detect step is bypassed when testing on simulator
    ORKHeadphoneTypeIdentifier headphoneType = ORKHeadphoneTypeIdentifierAirPodsPro;
    
    for (ORKStepResult *result in taskResults.results) {
        if (result.results > 0) {
            ORKStepResult *firstResult = (ORKStepResult *)[result.results firstObject];
            if ([firstResult isKindOfClass:[ORKTinnitusTypeResult class]]) {
                ORKTinnitusTypeResult *tinnitusTypeResult = (ORKTinnitusTypeResult *)firstResult;
                self.type = tinnitusTypeResult.type;
            }
            if ([firstResult isKindOfClass:[ORKHeadphoneDetectResult class]]) {
                ORKHeadphoneDetectResult *hedphoneResult = (ORKHeadphoneDetectResult *)firstResult;
                headphoneType = hedphoneResult.headphoneType;
            }
        }
    }
    
    [self setNavigationFooterView];
    [self setupButtons];
    
    self.contentView = [[ORKTinnitusCalibrationContentView alloc] initWithType:self.type isLoudnessMatching:YES];
    
    self.frequency = [[self loudnessStep] frequency];
    
    self.activeStepView.activeCustomView = self.contentView;
    self.activeStepView.customContentFillsAvailableSpace = YES;
    
    self.contentView.playButtonView.delegate = self;
    
    ORKTinnitusNoiseType noiseType = self.loudnessStep.noiseType;
    self.audioGenerator = [[ORKTinnitusAudioGenerator alloc] initWithType:self.type headphoneType:headphoneType];
    
    NSError *error;
    NSString *fileName = ORKTinnitusMaskingSoundForNoiseType(noiseType);
    
    if (![self setupAudioEngineForFilename:fileName error:nil]) {
        ORK_Log_Error("Error fetching audioSample: %@", error);
    }
}

- (BOOL)setupAudioEngineForFilename:(NSString *)filename error:(NSError **)outError {
    if (self.step.context && [self.step.context isKindOfClass:[ORKTinnitusPredefinedTaskContext class]]) {
        ORKTinnitusPredefinedTaskContext *context = (ORKTinnitusPredefinedTaskContext *)self.step.context;
        ORKTinnitusAudioSample *audioSample = [context.audioManifest noiseTypeSampleNamed:filename error:outError];
        
        if (audioSample) {
            AVAudioPCMBuffer *buffer = [audioSample getBuffer:outError];
            
            if (buffer) {
                self.audioBuffer = buffer;
                self.audioEngine = [[AVAudioEngine alloc] init];
                self.playerNode = [[AVAudioPlayerNode alloc] init];
                [self.audioEngine attachNode:self.playerNode];
                [self.audioEngine connect:self.playerNode to:self.audioEngine.outputNode format:self.audioBuffer.format];
                [self.playerNode scheduleBuffer:self.audioBuffer atTime:nil options:AVAudioPlayerNodeBufferLoops completionHandler:nil];
                [self.audioEngine prepare];
                
                return [self.audioEngine startAndReturnError:outError];
            }
        }
    }
    return NO;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.audioGenerator stop];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear: animated];
    
    self.audioGenerator = nil;
}

- (void)setNavigationFooterView {
    self.activeStepView.navigationFooterView.continueButtonItem = self.continueButtonItem;
    self.activeStepView.navigationFooterView.continueEnabled = NO;
    [self.activeStepView.navigationFooterView updateContinueAndSkipEnabled];
}

- (void)setupButtons
{
    self.continueButtonItem  = self.internalContinueButtonItem;
}

- (ORKStepResult *)result
{
    ORKStepResult *sResult = [super result];
    NSDate *now = sResult.endDate;

    NSMutableArray *results = [NSMutableArray arrayWithArray:sResult.results];

    ORKTinnitusLoudnessMatchingResult *result = [[ORKTinnitusLoudnessMatchingResult alloc] initWithIdentifier:self.step.identifier];
    result.startDate = sResult.startDate;
    result.endDate = now;
    result.type = self.type;
    result.noiseType = self.loudnessStep.noiseType;

    if ([self.type isEqualToString: ORKTinnitusTypePureTone]) {
        result.amplitude = [self.audioGenerator getPuretoneSystemVolumeIndBSPL];
        result.frequency = _frequency;
    } else {
        result.amplitude = [self.audioGenerator getWhiteNoiseSystemVolumeIndBSPL:self.loudnessStep.noiseType];
        result.frequency = 0.0;
    }

    [results addObject:result];
    sResult.results = [results copy];
    
    return sResult;
}

- (void)tearDownAudioEngine
{
    [self.playerNode stop];
    [self.audioEngine stop];
}

- (void)tinnitusButtonViewPressed:(nonnull ORKTinnitusButtonView *)tinnitusButtonView
{
    if (self.audioEngine.isRunning) {
        if (tinnitusButtonView.isShowingPause) {
            [self.playerNode play];
        } else {
            [self.playerNode pause];
        }
    } else {
        if (tinnitusButtonView.isShowingPause) {
            int64_t delay = (int64_t)((_audioGenerator.fadeDuration + 0.05) * NSEC_PER_SEC);
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, delay), dispatch_get_main_queue(), ^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    if ([self.type isEqualToString:ORKTinnitusTypePureTone]) {
                        [self.audioGenerator playSoundAtFrequency:_frequency];
                    } else {
                        [self.audioGenerator playWhiteNoise];
                    }
                });
            });
        } else {
            [self.audioGenerator stop];
        }
    }

    self.activeStepView.navigationFooterView.continueEnabled = YES;
}

@end
