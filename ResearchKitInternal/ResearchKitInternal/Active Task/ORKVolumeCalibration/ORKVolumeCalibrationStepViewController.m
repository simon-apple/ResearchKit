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
// apple-internal

#import "ORKVolumeCalibrationStepViewController.h"

#import "AAPLUtils.h"
#import "AVAudioMixerNode+Fade.h"
#import "ORKVolumeCalibrationStep.h"
#import "ORKVolumeCalibrationContentView.h"
#import "ORKTinnitusAudioGenerator.h"
#import "ORKTinnitusVolumeResult.h"
#import "ORKTinnitusAudioSample.h"
#import "ORKTinnitusHeadphoneTable.h"
#import "AAPLTaskViewController.h"

#import <ResearchKit/ORKHelpers_Internal.h>
#import <ResearchKitActiveTask/ORKActiveStepView.h>
#import <ResearchKitActiveTask/ORKActiveStepViewController_Internal.h>
#import <ResearchKitUI/ORKNavigationContainerView_Internal.h>
#import <ResearchKitUI/ORKStepContainerView_Private.h>
#import <ResearchKitUI/ORKStepViewController_Internal.h>
#import <ResearchKitUI/ORKTaskViewController_Internal.h>

#import <MediaPlayer/MPVolumeView.h>

#import "ORKCelestialSoftLink.h"

ORK_EXTERN NSString *const ORKHeadphoneNotificationSuspendActivity;

const NSTimeInterval ORKVolumeCalibrationFadeDuration = 0.1;
const NSTimeInterval ORKVolumeCalibrationFadeStep = 0.01;

@interface ORKVolumeCalibrationStepViewController () <ORKVolumeCalibrationContentViewDelegate>
@property (nonatomic, strong) ORKVolumeCalibrationContentView *contentView;
@property (nonatomic, strong) ORKTinnitusAudioGenerator *audioGenerator;
@property (nonatomic, strong) AVAudioEngine *audioEngine;
@property (nonatomic, strong) AVAudioMixerNode *mixerNode;
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
#if TARGET_IPHONE_SIMULATOR
    return NO;
#else
    if (!self.audioEngine) {
        self.audioEngine = [[AVAudioEngine alloc] init];
    }
    if (!self.playerNode) {
        self.playerNode = [[AVAudioPlayerNode alloc] init];
        [self.audioEngine attachNode:self.playerNode];
    }
    if (!self.mixerNode) {
        self.mixerNode = self.audioEngine.mainMixerNode;
    }
    NSArray<AVAudioConnectionPoint *> *connections = [self.audioEngine outputConnectionPointsForNode:self.playerNode outputBus:0];
    if ([connections count] == 0) {
        [self.audioEngine connect:self.playerNode to:self.mixerNode format:self.audioBuffer.format];
    }
    [self.playerNode prepareWithFrameCount:1024];
    [self.playerNode scheduleBuffer:self.audioBuffer atTime:nil options:AVAudioPlayerNodeBufferLoops | AVAudioPlayerNodeBufferInterrupts completionHandler:^() {
    }];
    [self.audioEngine prepare];
    return [self.audioEngine startAndReturnError:outError];
#endif
}

- (BOOL)setupAudioEngineForFile:(NSString *)fileName withExtension:(NSString *)extension error:(NSError **)outError {
    NSURL *path = [[NSBundle bundleForClass:[self class]] URLForResource:fileName withExtension:extension];
    AVAudioFile *file = [[AVAudioFile alloc] initForReading:path error:nil];
    
    if (file) {
        if (!self.audioBuffer) {
            self.audioBuffer = [[AVAudioPCMBuffer alloc] initWithPCMFormat:file.processingFormat frameCapacity:(AVAudioFrameCount)file.length];
            [file readIntoBuffer:self.audioBuffer error:outError];
        }
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
            if (!self.audioBuffer) {
#if defined(DEBUG)
                ORK_Log_Debug("ORKVolumeCalibrationSVC setupAudioEngineForSound: getBuffer");
#endif
                self.audioBuffer = [audioSample getBuffer:outError];
            }
            
            if (self.audioBuffer) {
#if defined(DEBUG)
                ORK_Log_Debug("ORKVolumeCalibrationSVC setupAudioEngineForSound:");
#endif
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
            if (!self.audioBuffer) {
                self.audioBuffer = [audioSample getBuffer:outError];
            }
            
            if (self.audioBuffer) {
                return [self setupAudioEngineWithError:outError];
            }
        }
    }
    return NO;
}

- (NSString *)sampleTitleForCalibrationStep {
    NSString *result = @"Sample";
    
    if ([self isMaskingSound]) {
        result = self.volumeCalibrationStep.maskingSoundName;
    } else if ([self isTinnitusSoundCalibration]) {
        ORKTinnitusPredefinedTaskContext *context = self.tinnitusPredefinedTaskContext;
        if (context.predominantFrequency > 0.0) {
            result = ORKLocalizedString(@"TINNITUS_FINAL_CALIBRATION_BUTTON_TITLE", nil);
        }
    }
    return result;
}

- (NSString *)soundNameForCalibrationStep {
    NSString *result = @"VolumeCalibration";
    if ([self isMaskingSound]) {
        result = self.volumeCalibrationStep.maskingSoundIdentifier;
    } else if ([self isTinnitusSoundCalibration]) {
        ORKTinnitusPredefinedTaskContext *context = self.tinnitusPredefinedTaskContext;
        result = context.tinnitusIdentifier;
    }
    return result;
}


- (void)setupAudioEngine {

    NSString *soundName = [self soundNameForCalibrationStep];
    
    if ([self isMaskingSound]) {
        NSError *error;
        if (![self setupAudioEngineForMaskingSound:soundName error:&error]) {
            ORK_Log_Error("Error fetching audioSample: %@", error);
        }
        
    } else if ([self isTinnitusSoundCalibration]) {
        ORKTinnitusPredefinedTaskContext *context = self.tinnitusPredefinedTaskContext;
        
        if (context.predominantFrequency > 0.0) {
#if (TARGET_IPHONE_SIMULATOR)
            self.audioGenerator = [[ORKTinnitusAudioGenerator alloc] initWithHeadphoneType:ORKHeadphoneTypeIdentifierAirPodsMax];
#else
            self.audioGenerator = [[ORKTinnitusAudioGenerator alloc] initWithHeadphoneType:context.headphoneType];
#endif
        } else {
            NSError *error;
            if (![self setupAudioEngineForSound:soundName error:&error]) {
                ORK_Log_Error("Error fetching audioSample: %@", error);
            }
        }
    } else {
        NSError *error;
        if (![self setupAudioEngineForFile:soundName withExtension:@"wav" error:&error]) {
            ORK_Log_Error("Error fetching audio file %@: %@", soundName, error);
        }
    }
}

- (void)stopAudioEngine {
    void (^stopEverything)(void) = ^void() {
        [self.playerNode stop];
        [self.audioEngine stop];
        // What is remove Tap doing?
        //[self.mixerNode removeTapOnBus:0];
        [self.contentView enablePlaybackButton:YES];
    };
    
    [self.contentView enablePlaybackButton:NO];
    [self.contentView setPlaybackButtonPlaying:NO];
    
    if ([self isTinnitusSoundCalibration]) {
        ORKTinnitusPredefinedTaskContext *context = self.tinnitusPredefinedTaskContext;
        
        if (context.type == ORKTinnitusTypePureTone && context.predominantFrequency > 0.0) {
            if (self.audioGenerator.isPlaying) {
                [self.audioGenerator stop:^{
                    stopEverything();
                }];
            } else {
                stopEverything();
            }
        } else {
            stopEverything();
        }
        return;
    }

    if (self.audioEngine.isRunning && self.playerNode.isPlaying) {
        [self stopSample:^{
            stopEverything();
        }];
    } else {
        stopEverything();
    }
}

- (ORKStepResult *)result {
    ORKStepResult *sResult = [super result];
    
   if (self.tinnitusPredefinedTaskContext) {
        ORKTinnitusPredefinedTaskContext *context = self.tinnitusPredefinedTaskContext;
        float systemVolume = [[AVAudioSession sharedInstance] outputVolume];
        context.userVolume = systemVolume;
       
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
            tinnitusCalibrationResult.amplitude = [self.audioGenerator getPuretone_dBSPL];
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
            sampleTitle = AAPLLocalizedString(@"TINNITUS_FINAL_CALIBRATION_BUTTON_TITLE", nil);
            
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

    self.contentView = [[ORKVolumeCalibrationContentView alloc] initWithTitle:[self sampleTitleForCalibrationStep]];
    self.contentView.delegate = self;
    
    [self setNavigationFooterView];
    [self setupButtons];
    
    self.activeStepView.activeCustomView = self.contentView;
    
#if !TARGET_IPHONE_SIMULATOR
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(headphoneChanged:) name:ORKHeadphoneNotificationSuspendActivity object:nil];
#endif
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:ORKHeadphoneNotificationSuspendActivity object:nil];
}

- (void)headphoneChanged:(NSNotification *)note {
    if (self.tinnitusPredefinedTaskContext != nil) {
        [self.contentView enablePlaybackButton:NO];
        [self.contentView setPlaybackButtonPlaying:NO];
        [self stopSample:^{
            [self.contentView enablePlaybackButton:YES];
        }];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (@available(iOS 13.0, *)) {
        self.view.backgroundColor = UIColor.systemGroupedBackgroundColor;
        self.taskViewController.navigationBar.barTintColor = UIColor.systemGroupedBackgroundColor;
        [self.taskViewController.navigationBar setTranslucent:NO];
    }
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self setupAudioEngine];
    
    AAPLTaskViewController *aaplTaskViewController = (AAPLTaskViewController *)self.taskViewController;
    if (aaplTaskViewController != nil && [aaplTaskViewController isKindOfClass:[AAPLTaskViewController class]]) {
        [aaplTaskViewController saveVolume];
    } else {
        // rdar://107531448 (all internal classes should throw error if parent is AAPLTaskViewController)
        // TODO: THROW IF PARENT VIEW CONTROLLER ISN'T OF TYPE AAPLTaskViewController
    }
    
    [[getAVSystemControllerClass() sharedAVSystemController] setActiveCategoryVolumeTo:UIAccessibilityIsVoiceOverRunning() ? 0.2 : 0];
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [self stopAudioEngine];

    [super viewWillDisappear:animated];
}

-(void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    self.contentView.delegate = nil;
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

- (void)playSample:(void (^ _Nonnull)(void))didStartPlaying {
    self.mixerNode.outputVolume = 0.0;
    [self.playerNode play];
    [self.contentView enablePlaybackButton:NO];
    [self.contentView setPlaybackButtonPlaying:YES];
    [self.mixerNode fadeInWithDuration:ORKVolumeCalibrationFadeDuration stepInterval:ORKVolumeCalibrationFadeStep completion:^{
        didStartPlaying();
        [self.contentView enablePlaybackButton:YES];
    }];
}

- (void)stopSample:(void (^ _Nonnull)(void))didStopPlaying {
    [self.contentView enablePlaybackButton:NO];
    [self.contentView setPlaybackButtonPlaying:NO];
    [self.mixerNode fadeOutWithDuration:ORKVolumeCalibrationFadeDuration stepInterval:ORKVolumeCalibrationFadeStep completion:^{
        [self.playerNode pause];
        didStopPlaying();
        [self.contentView enablePlaybackButton:YES];
    }];
}

#pragma mark - ORKVolumeCalibrationContentViewDelegate

- (BOOL)contentView:(ORKVolumeCalibrationContentView *)contentView didPressPlaybackButton:(UIButton *)playbackButton {
    if ([self isTinnitusSoundCalibration]) {
        ORKTinnitusPredefinedTaskContext *context = self.tinnitusPredefinedTaskContext;
        
        if (context.type == ORKTinnitusTypePureTone && context.predominantFrequency > 0.0) {
            if (!self.audioGenerator.isPlaying) {
                int64_t delay = (int64_t)((_audioGenerator.fadeDuration + 0.05) * NSEC_PER_SEC);
                [playbackButton setEnabled:FALSE];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, delay), dispatch_get_main_queue(), ^{
                    [self.audioGenerator playSoundAtFrequency:context.predominantFrequency];
                    [playbackButton setEnabled:TRUE];
                });
                return YES;
            } else {
                [playbackButton setEnabled:FALSE];
                [self.audioGenerator stop:^{
                    [playbackButton setEnabled:TRUE];
                }];
                return NO;
            }
        }
    }
    
    if (self.audioEngine.isRunning) {
        if (!self.playerNode.isPlaying) {
            [playbackButton setEnabled:FALSE];
            [self playSample:^{
                [playbackButton setEnabled:TRUE];
            }];
            return YES;
        } else if (self.playerNode.isPlaying) {
            [playbackButton setEnabled:FALSE];
            [self stopSample:^{
                [playbackButton setEnabled:TRUE];
            }];
            return NO;
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
    BOOL hasType = (context && context.type != ORKTinnitusTypeUnknown);
    return hasType && ![self isMaskingSound];
}

@end
