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

#import "ORKVolumeCalibrationStep.h"
#import "ORKVolumeCalibrationContentView.h"
#import "ORKTinnitusAudioGenerator.h"
#import "ORKTinnitusVolumeResult.h"
#import "ORKTinnitusAudioSample.h"
#import "ORKTinnitusHeadphoneTable.h"
#import "ORKActiveStepView.h"

#import "ORKStepContainerView_Private.h"
#import "ORKActiveStepViewController_Internal.h"
#import "ORKNavigationContainerView_Internal.h"
#import "ORKTaskViewController_Internal.h"
#import "ORKStepViewController_Internal.h"
#import "ORKHelpers_Internal.h"

#import <MediaPlayer/MPVolumeView.h>

#import "ORKCelestialSoftLink.h"

@interface ORKVolumeCalibrationStepViewController () <ORKVolumeCalibrationContentViewDelegate>
@property (nonatomic, strong) ORKVolumeCalibrationContentView *contentView;
@property (nonatomic, strong) ORKTinnitusAudioGenerator *audioGenerator;
@property (nonatomic, strong) AVAudioEngine *audioEngine;
@property (nonatomic, strong) AVAudioPlayerNode *playerNode;
@property (nonatomic, strong) AVAudioPCMBuffer *audioBuffer;
@end

@implementation ORKVolumeCalibrationStepViewController

#pragma mark - ORKActiveStepViewController

- (instancetype)initWithStep:(ORKStep *)step {
    self = [super initWithStep:step];
    if (self)
    {
        self.suspendIfInactive = YES;
    }
    return self;
}

- (BOOL)setupAudioEngineWithError:(NSError **)outError {
    self.audioEngine = [[AVAudioEngine alloc] init];
    self.playerNode = [[AVAudioPlayerNode alloc] init];
    [self.audioEngine attachNode:self.playerNode];
    [self.audioEngine connect:self.playerNode to:self.audioEngine.outputNode format:self.audioBuffer.format];
    [self.playerNode scheduleBuffer:self.audioBuffer atTime:nil options:AVAudioPlayerNodeBufferLoops completionHandler:nil];
    [self.audioEngine prepare];
    return [self.audioEngine startAndReturnError:outError];
}

- (BOOL)setupAudioEngineForFile:(NSString *)fileName withExtension:(NSString *)extension error:(NSError **)outError {
    NSURL *path = [[NSBundle bundleForClass:[self class]] URLForResource:fileName withExtension:extension];
    AVAudioFile *file = [[AVAudioFile alloc] initForReading:path error:nil];
    
    if (file) {
        self.audioBuffer = [[AVAudioPCMBuffer alloc] initWithPCMFormat:file.processingFormat frameCapacity:(AVAudioFrameCount)file.length];
        [file readIntoBuffer:self.audioBuffer error:outError];
        return [self setupAudioEngineWithError:outError];
    }
    return NO;
}

- (BOOL)setupAudioEngineForSound:(NSString *)identifier error:(NSError **)outError {
    if (self.tinnitusPredefinedTaskContext) {
        ORKTinnitusAudioSample *audioSample = [self.tinnitusPredefinedTaskContext.audioManifest
                                               noiseTypeSampleWithIdentifier:identifier
                                               error:outError];
        if (audioSample) {
            self.audioBuffer = [audioSample getBuffer:outError];
            
            if (self.audioBuffer) {
                return [self setupAudioEngineWithError:outError];
            }
        }
    }
    return NO;
}

- (BOOL)setupAudioEngineForMaskingSound:(NSString *)identifier error:(NSError **)outError {
    if (self.tinnitusPredefinedTaskContext) {
        ORKTinnitusAudioSample *audioSample = [self.tinnitusPredefinedTaskContext.audioManifest
                                               maskingSampleWithIdentifier:identifier
                                               error:outError];
        if (audioSample) {
            self.audioBuffer = [audioSample getBuffer:outError];
            
            if (self.audioBuffer) {
                return [self setupAudioEngineWithError:outError];
            }
        }
    }
    return NO;
}

- (void)tearDownAudioEngine {
    [self.playerNode stop];
    [self.audioEngine stop];
}

- (ORKStepResult *)result {
    ORKStepResult *sResult = [super result];
    
   if (self.tinnitusPredefinedTaskContext) {
        ORKTinnitusPredefinedTaskContext *context = self.tinnitusPredefinedTaskContext;
        float systemVolume = [[AVAudioSession sharedInstance] outputVolume];
        
        NSMutableArray *results = [NSMutableArray arrayWithArray:sResult.results];
        
        ORKTinnitusVolumeResult *tinnitusCalibrationResult = [[ORKTinnitusVolumeResult alloc] initWithIdentifier:self.step.identifier];
        tinnitusCalibrationResult.startDate = sResult.startDate;
        tinnitusCalibrationResult.endDate = sResult.endDate;
        
        ORKTinnitusHeadphoneTable *table = [[ORKTinnitusHeadphoneTable alloc] initWithHeadphoneType:context.headphoneType];
        tinnitusCalibrationResult.volumeCurve = [table gainForSystemVolume:systemVolume interpolated:YES];

        if (self.audioGenerator && context.predominantFrequency > 0.0 && systemVolume > 0.0) {
#if TARGET_IPHONE_SIMULATOR
            tinnitusCalibrationResult.amplitude = 0.0;
#else
            tinnitusCalibrationResult.amplitude = [self.audioGenerator getPuretoneSystemVolumeIndBSPL];
#endif
        } else {
            tinnitusCalibrationResult.amplitude = systemVolume;
        }
        
        [results addObject:tinnitusCalibrationResult];
        sResult.results = [results copy];
    }
    
    return sResult;
}

- (void)finish {
    [super finish];
    [super goForward];
}

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupVolumeView];
    [self.taskViewController saveVolume];
    [[getAVSystemControllerClass() sharedAVSystemController] setActiveCategoryVolumeTo:0];
    
    NSString *sampleTitle = @"Sample";
    ORKTinnitusPredefinedTaskContext *context = self.tinnitusPredefinedTaskContext;
    
    if ([self isMaskingSound]) {
        sampleTitle = self.volumeCalibrationStep.maskingSoundName;
        
        NSError *error;
        if (![self setupAudioEngineForMaskingSound:self.volumeCalibrationStep.maskingSoundIdentifier error:&error]) {
            ORK_Log_Error("Error fetching audioSample: %@", error);
        }
        
    } else if ([self isTinnitusSoundCalibration]) {
        if (context.predominantFrequency > 0.0) {
            sampleTitle = ORKLocalizedString(@"TINNITUS_FINAL_CALIBRATION_BUTTON_TITLE", nil);
            
#if (TARGET_IPHONE_SIMULATOR)
            self.audioGenerator = [[ORKTinnitusAudioGenerator alloc] initWithHeadphoneType:ORKHeadphoneTypeIdentifierAirPodsMax];
#else
            self.audioGenerator = [[ORKTinnitusAudioGenerator alloc] initWithHeadphoneType:context.headphoneType];
#endif
        } else {
            NSError *error;
            NSString *noiseType = context.tinnitusIdentifier;
            if (![self setupAudioEngineForSound:noiseType error:&error]) {
                ORK_Log_Error("Error fetching audioSample: %@", error);
            }
        }
    } else {
        NSError *error;
        NSString *audioFile = @"VolumeCalibration";
        if (![self setupAudioEngineForFile:audioFile withExtension:@"wav" error:&error]) {
            ORK_Log_Error("Error fetching audio file %@: %@", audioFile, error);
        }
    }
    
    self.contentView = [[ORKVolumeCalibrationContentView alloc] initWithTitle:sampleTitle];
    self.contentView.delegate = self;
    
    [self setNavigationFooterView];
    [self setupButtons];
    
    self.activeStepView.activeCustomView = self.contentView;
    self.activeStepView.customContentFillsAvailableSpace = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.audioGenerator stop];
    [self tearDownAudioEngine];
}

- (void)setNavigationFooterView {
    self.activeStepView.navigationFooterView.continueButtonItem = self.continueButtonItem;
    self.activeStepView.navigationFooterView.continueEnabled = NO;
    [self.activeStepView.navigationFooterView updateContinueAndSkipEnabled];
}

- (void)setupVolumeView {
    MPVolumeView *volumeView = [[MPVolumeView alloc] initWithFrame:CGRectNull];
    [volumeView setAlpha:0.001];
    [volumeView setIsAccessibilityElement:NO];
    [self.view addSubview:volumeView];
}

- (void)setupButtons {
    self.continueButtonItem  = self.internalContinueButtonItem;
}

#pragma mark - ORKVolumeCalibrationContentViewDelegate

- (BOOL)contentView:(ORKVolumeCalibrationContentView *)contentView didPressPlaybackButton:(UIButton *)playbackButton {
    ORKTinnitusPredefinedTaskContext *context = self.tinnitusPredefinedTaskContext;
    
    if ([self isMaskingSound]) {
        if (self.audioEngine.isRunning && !self.playerNode.isPlaying) {
            [self.playerNode play];
            return YES;
        } else {
            [self.playerNode pause];
        }
    } else if ([self isTinnitusSoundCalibration]) {
        ORKTinnitusType type = context.type;
        
        int64_t delay = (int64_t)((_audioGenerator.fadeDuration + 0.05) * NSEC_PER_SEC);
        if (type == ORKTinnitusTypePureTone && context.predominantFrequency > 0.0) {
            if (!self.audioGenerator.isPlaying) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, delay), dispatch_get_main_queue(), ^{
                    [self.audioGenerator playSoundAtFrequency:context.predominantFrequency];
                });
                return YES;
            }
        } else {
            if (self.audioEngine.isRunning && !self.playerNode.isPlaying) {
                [self.playerNode play];
                return YES;
            }
        }
        [self.audioGenerator stop];
        [self tearDownAudioEngine];
    } else {
        if (self.audioEngine.isRunning && !self.playerNode.isPlaying) {
            [self.playerNode play];
            return YES;
        } else {
            if (self.activeStepView.navigationFooterView.continueEnabled) {
                [self finish];
                [self tearDownAudioEngine];
            } else {
                [self.playerNode pause];
            }
        }
    }
    
    return NO;
}

- (void)contentView:(ORKVolumeCalibrationContentView *)contentView didRaisedVolume:(float)volume {
    [[getAVSystemControllerClass() sharedAVSystemController] setActiveCategoryVolumeTo:volume];
}

- (void)contentView:(ORKVolumeCalibrationContentView *)contentView shouldEnableContinue:(BOOL)enable {
    self.activeStepView.navigationFooterView.continueEnabled = enable;
}

#pragma mark - ORKTinnitusPredefinedTask

- (ORKVolumeCalibrationStep *)volumeCalibrationStep {
    if (self.step && [self.step isKindOfClass:[ORKVolumeCalibrationStep class]]) {
        return (ORKVolumeCalibrationStep *)self.step;
    }
    return nil;
}

- (ORKTinnitusPredefinedTaskContext *)tinnitusPredefinedTaskContext {
    if (self.step.context && [self.step.context isKindOfClass:[ORKTinnitusPredefinedTaskContext class]]) {
        return (ORKTinnitusPredefinedTaskContext *)self.step.context;
    }
    return nil;
}

- (BOOL)isMaskingSound {
    return (self.volumeCalibrationStep.maskingSoundName && self.volumeCalibrationStep.maskingSoundIdentifier);
}

- (BOOL)isTinnitusSoundCalibration {
    ORKTinnitusPredefinedTaskContext *context = self.tinnitusPredefinedTaskContext;
    return (context && context.type != ORKTinnitusTypeUnknown);
}

@end
