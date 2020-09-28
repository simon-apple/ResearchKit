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

#import "ORKAudioFitnessStep.h"
#import "ORKAudioFitnessStepViewController.h"
#import "ORKHelpers_Internal.h"

#import <AVFoundation/AVFoundation.h>

@interface ORKAVAudioPlayer : AVAudioPlayer <ORKAudioPlayer>
@end

@implementation ORKAVAudioPlayer
@end

@interface ORKAudioFitnessStepViewController ()
@property (nonatomic) BOOL appHasAudioBackgroundMode;
@end

@implementation ORKAudioFitnessStepViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.audioPlayer prepareToPlay];
}

- (void)start {
    [super start];

    if (self.appHasAudioBackgroundMode) {
        [self enableBackgroundAudioSession:YES];
    }

    [self.audioPlayer play];
}

- (void)suspend {
    [super suspend];
    [self.audioPlayer pause];
}

- (void)resume {
    [super resume];
    [self.audioPlayer play];
}

- (void)finish {
    [super finish];
    [self.audioPlayer stop];

    if (self.appHasAudioBackgroundMode) {
        [self enableBackgroundAudioSession:NO];
    }
}

- (BOOL)appHasAudioBackgroundMode {
    NSArray<NSString*> *backgroundModes = (NSArray<NSString*> *)[[NSBundle mainBundle] objectForInfoDictionaryKey:@"UIBackgroundModes"];
    BOOL hasBackgroundAudioMode = [backgroundModes containsObject:@"audio"];
    return hasBackgroundAudioMode;
}

- (void)enableBackgroundAudioSession:(BOOL)enabled {
    NSError *error;
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback
                                            mode:AVAudioSessionModeDefault
                              routeSharingPolicy:AVAudioSessionRouteSharingPolicyLongForm
                                         options:0
                                           error:&error];
    if (error) {
        ORK_Log_Error("ORKAudioFitnessStepViewController failed to setup audio session: %@", error);
        return;
    }

    [[AVAudioSession sharedInstance] setActive:enabled error:&error];
    if (error) {
        ORK_Log_Error("ORKAudioFitnessViewController failed to start audio session: %@", error);
        return;
    }
}

- (id<ORKAudioPlayer>)audioPlayer {
    if (!_audioPlayer) {
        ORKAudioFitnessStep *step = (ORKAudioFitnessStep *)self.step;
        NSBundle *bundle = [NSBundle bundleWithIdentifier: step.audioBundleIdentifier];
        NSURL *url = [bundle URLForResource:step.audioResourceName withExtension:step.audioFileExtension];
        NSError *error;
        _audioPlayer = [[ORKAVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
        if (error) {
            ORK_Log_Error("ORKAudioFitnessStepViewController Failed to load audio file: %@", error.localizedFailureReason);
        }
    }
    return _audioPlayer;
}

@end
