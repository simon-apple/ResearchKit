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
#import "AVAudioMixerNode+Fade.h"

#import "ORKActiveStepView.h"
#import "ORKActiveStepViewController_Internal.h"
#import "ORKStepViewController_Internal.h"
#import "ORKStepContainerView_Private.h"
#import "ORKNavigationContainerView_Internal.h"
#import "ORKHelpers_Internal.h"
#import "ResearchKit_Private.h"

#import "ORKSkin.h"

static const NSTimeInterval PLAY_DELAY = 0.5;
static const NSTimeInterval PLAY_DELAY_VOICEOVER = 1.3;
static const NSTimeInterval PLAY_DURATION = 3.0;
static const NSTimeInterval PLAY_DURATION_VOICEOVER = 5.0;

const NSTimeInterval ORKTinnitusTypeFadeDuration = 0.1;
const NSTimeInterval ORKTinnitusTypeFadeStep = 0.01;

@interface ORKTinnitusTypeStepViewController () <ORKTinnitusButtonViewDelegate> {
    ORKTinnitusTypeContentView *_tinnitusTypeContentView;
    int _sampleIndex;
    NSTimer *_timer;
    BOOL _noneAreSimilarFlag;
}

@property (nonatomic, strong) AVAudioEngine *audioEngine;
@property (nonatomic, strong) AVAudioMixerNode *mixerNode;
@property (nonatomic, strong) AVAudioPlayerNode *playerNode;
@property (nonatomic, strong) AVAudioPCMBuffer *audioBuffer;

@end

@implementation ORKTinnitusTypeStepViewController

- (ORKTinnitusTypeStep *)tinnitusTypeStep {
    return (ORKTinnitusTypeStep *)self.step;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _noneAreSimilarFlag = NO;
    
    ORKTinnitusPredefinedTaskContext *context = (ORKTinnitusPredefinedTaskContext *)self.step.context;
    
    _tinnitusTypeContentView = [[ORKTinnitusTypeContentView alloc] initWithContext:context];
    self.activeStepView.activeCustomView = _tinnitusTypeContentView;
    _tinnitusTypeContentView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [_tinnitusTypeContentView.buttonsViewArray makeObjectsPerformSelector:@selector(setDelegate:) withObject:self];
    
    [self setupAudioEngine];

    self.activeStepView.navigationFooterView.optional = YES;
    
    self.isAccessibilityElement = YES;
    
    if (UIAccessibilityIsVoiceOverRunning()) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(PLAY_DELAY_VOICEOVER * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self setupAutoPlay];
        });
    } else {
        [self setupAutoPlay];
    }
    
#if !TARGET_IPHONE_SIMULATOR
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(headphoneChanged:) name:ORKHeadphoneNotificationSuspendActivity object:nil];
#endif
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:ORKHeadphoneNotificationSuspendActivity object:nil];
}

- (void)setupAudioEngine {
    self.audioEngine = [[AVAudioEngine alloc] init];
    self.playerNode = [[AVAudioPlayerNode alloc] init];
    [self.audioEngine attachNode:self.playerNode];
    self.mixerNode = self.audioEngine.mainMixerNode;
}

- (void)setupAutoPlay {
    if (UIAccessibilityIsVoiceOverRunning()) {
        UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, _tinnitusTypeContentView);
        [_tinnitusTypeContentView.buttonsViewArray[0] enableAccessibilityAnnouncements:NO];
        UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, self.tinnitusTypeStep.title);
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(announcementFinished:) name:UIAccessibilityAnnouncementDidFinishNotification object:nil];
    } else {
        [self performSelector:@selector(startAutomaticPlay) withObject:nil afterDelay:PLAY_DELAY];
    }
}

- (void)announcementFinished:(NSNotification*)notification {
    BOOL success = [notification.userInfo[UIAccessibilityAnnouncementKeyWasSuccessful] boolValue];
    if (success) {
        if ([notification.userInfo[UIAccessibilityAnnouncementKeyStringValue] isEqualToString:self.tinnitusTypeStep.title]) {
            UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, ORKLocalizedString(@"TINNITUS_TYPE_ACCESSIBILITY_ANNOUNCEMENT", nil));
        } else {
            [[NSNotificationCenter defaultCenter] removeObserver:self name:UIAccessibilityAnnouncementDidFinishNotification object:nil];
            [self performSelector:@selector(startAutomaticPlay) withObject:nil afterDelay:PLAY_DELAY];
        }
    }
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
    _timer = [[NSTimer alloc] initWithFireDate:[NSDate date]
                                      interval:UIAccessibilityIsVoiceOverRunning() ? PLAY_DURATION_VOICEOVER : PLAY_DURATION
                                        target:self
                                      selector:@selector(playNextSample)
                                      userInfo:nil
                                       repeats:YES];
    NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
    [runLoop addTimer:_timer forMode:NSRunLoopCommonModes];
}

- (void)playNextSample {
    if (_sampleIndex > _tinnitusTypeContentView.buttonsViewArray.count - 1) {
        [_tinnitusTypeContentView.buttonsViewArray[_sampleIndex - 1] simulateTap];
        [_tinnitusTypeContentView.buttonsViewArray[0] enableAccessibilityAnnouncements:YES];
        [self stopAutomaticPlay];
    } else {
        [_tinnitusTypeContentView.buttonsViewArray[_sampleIndex] simulateTap];
    }
    _sampleIndex = _sampleIndex + 1;
}

- (void)stopAutomaticPlay {
    [_tinnitusTypeContentView.buttonsViewArray[0] enableAccessibilityAnnouncements:YES];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIAccessibilityAnnouncementDidFinishNotification object:nil];
    [NSObject cancelPreviousPerformRequestsWithTarget:self
                                             selector:@selector(startAutomaticPlay)
                                               object:nil];
    [_timer invalidate];
    _timer = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (@available(iOS 13.0, *)) {
        self.view.backgroundColor = UIColor.systemGroupedBackgroundColor;
        self.taskViewController.navigationBar.barTintColor = UIColor.systemGroupedBackgroundColor;
        [self.taskViewController.navigationBar setTranslucent:NO];
    }
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self stopAutomaticPlay];
    [self stopSample:nil];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [self tearDownAudioEngine];
}

- (ORKTinnitusPredefinedTaskContext *)tinnitusPredefinedTaskContext {
    if (self.step.context && [self.step.context isKindOfClass:[ORKTinnitusPredefinedTaskContext class]]) {
        return (ORKTinnitusPredefinedTaskContext *)self.step.context;
    }
    return nil;
}

- (void)headphoneChanged:(NSNotification *)note {
    if (self.tinnitusPredefinedTaskContext != nil) {
        [self stopAutomaticPlay];
        [self stopSample:nil];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [_tinnitusTypeContentView.buttonsViewArray makeObjectsPerformSelector:@selector(restoreButton)];
        });
    }
}

- (void)tearDownAudioEngine {
    [self.playerNode stop];
    [self.audioEngine stop];
    [self.mixerNode removeTapOnBus:0];
}

- (BOOL)playSound:(NSString *)identifier error:(NSError **)outError {
    [self tearDownAudioEngine];
    [self setupAudioEngine];

    if (self.step.context && [self.step.context isKindOfClass:[ORKTinnitusPredefinedTaskContext class]]) {
        ORKTinnitusPredefinedTaskContext *context = (ORKTinnitusPredefinedTaskContext *)self.step.context;
        ORKTinnitusAudioSample *audioSample = [context.audioManifest noiseTypeSampleWithIdentifier:identifier error:outError];
        
        if (audioSample) {
            AVAudioPCMBuffer *buffer = [audioSample getBuffer:outError];
            
            if (buffer) {
                self.audioBuffer = buffer;
                [self.audioEngine connect:self.playerNode to:self.mixerNode format:self.audioBuffer.format];
                [self.playerNode scheduleBuffer:self.audioBuffer atTime:nil options:AVAudioPlayerNodeBufferLoops completionHandler:nil];
                [self.audioEngine prepare];
                if ([self.audioEngine startAndReturnError:outError]) {
                    [self playSample];
                    return YES;
                }
            }
        }
    }
    return NO;
}

- (void)playSample {
    _mixerNode.outputVolume = 0.0;
    [_playerNode play];

    [_mixerNode fadeInWithDuration:ORKTinnitusTypeFadeDuration stepInterval:ORKTinnitusTypeFadeStep completion:^{
        [_tinnitusTypeContentView enableButtons:YES];
    }];
}

- (void)stopSample:(void (^ __nullable)(void))completion {
    [_tinnitusTypeContentView enableButtons:NO];

    [_mixerNode fadeOutWithDuration:ORKTinnitusTypeFadeDuration stepInterval:ORKTinnitusTypeFadeStep completion:^{
        [_playerNode stop];
        if (completion) {
            completion();
        }
    }];
}

- (BOOL)atLeastOneButtonIsSelected {
    __block BOOL atLeastOneButtonIsSelected = NO;
    [_tinnitusTypeContentView.buttonsViewArray enumerateObjectsUsingBlock:^(ORKTinnitusButtonView*  _Nonnull buttonView, NSUInteger idx, BOOL * _Nonnull stop) {
        if (buttonView.isSelected) {
            atLeastOneButtonIsSelected = YES;
            *stop = YES;
        }
    }];
    return atLeastOneButtonIsSelected;
}

- (BOOL)allPlayedAtLeastOnce {
    __block BOOL allPlayedAtLeastOnce = YES;
    [_tinnitusTypeContentView.buttonsViewArray enumerateObjectsUsingBlock:^(ORKTinnitusButtonView*  _Nonnull buttonView, NSUInteger idx, BOOL * _Nonnull stop) {
        if (!buttonView.playedOnce) {
            allPlayedAtLeastOnce = NO;
            *stop = YES;
        }
    }];
    return allPlayedAtLeastOnce;
}

- (void)tinnitusButtonViewPressed:(ORKTinnitusButtonView * _Nonnull)tinnitusButtonView {
    if (!tinnitusButtonView.isSimulatedTap) {
        [self stopAutomaticPlay];
    }

    if (tinnitusButtonView.isShowingPause) {
        [_tinnitusTypeContentView selectButton:tinnitusButtonView];
        
        [self stopSample:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                NSError *error;
                [self playSound:tinnitusButtonView.answer error:&error];
                if (error) {
                    ORK_Log_Error("Error fetching audioSample: %@", error);
                }
            });
        }];
    } else {
        [self stopSample:^{
            [_tinnitusTypeContentView enableButtons:YES];
        }];
    }
    
    BOOL isPlayingLastButton = (tinnitusButtonView == _tinnitusTypeContentView.buttonsViewArray[_tinnitusTypeContentView.buttonsViewArray.count - 1]);
    
    if (isPlayingLastButton && _timer == nil && tinnitusButtonView.isSimulatedTap) {
        [tinnitusButtonView restoreButton];
    }
    
    if (self.allPlayedAtLeastOnce) {
        self.activeStepView.navigationFooterView.skipEnabled = YES;
    }
    
    self.activeStepView.navigationFooterView.continueEnabled = (_timer == nil && self.atLeastOneButtonIsSelected);
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
