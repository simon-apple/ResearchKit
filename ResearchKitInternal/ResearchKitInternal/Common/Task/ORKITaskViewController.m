/*
 Copyright (c) 2023, Apple Inc. All rights reserved.
 
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

#import "ORKITaskViewController.h"

#import "ORKInternalClassMapper.h"
#import "ORKIUtils.h"
#import "ORKSensitiveURLLearnMoreInstructionStep.h"
#import "ORKContext.h"
#import "ORKSensitiveURLLearnMoreInstructionStep.h"
#import "ORKSpeechInNoisePredefinedTask.h"
#import "ORKTinnitusPredefinedTask.h"
#import "ORKCelestialSoftLink.h"

#import <ResearchKitUI/ORKTaskViewController_Internal.h>
#import <ResearchKitUI/ORKTaskViewController_Private.h>

#import <ResearchKit/ORKActiveStep_Internal.h>
#import <ResearchKit/ORKOrderedTask_Private.h>

#import <ResearchKit/ORKActiveStep_Internal.h>
#import <ResearchKit/ORKOrderedTask_Private.h>


ORKCompletionStepIdentifier const ORKCompletionStepIdentifierMicrophoneLearnMore = @"ORKCompletionStepIdentifierMicrophoneLearnMore";
ORKCompletionStepIdentifier const ORKEnvironmentSPLMeterTimeoutIdentifier = @"ORKEnvironmentSPLMeterTimeoutIdentifier";


@interface ORKITaskViewController () {
    BOOL _hasMicrophoneAccess;
    BOOL _hasLockedVolume;
    float _savedVolume;
    float _lockedVolume;
}

@end

@implementation ORKITaskViewController

- (void)viewDidDisappear:(BOOL)animated {
    // restore saved volume
    if (_hasLockedVolume || (!_hasLockedVolume && _savedVolume > 0)) {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        [[getAVSystemControllerClass() sharedAVSystemController] setActiveCategoryVolumeTo:_savedVolume];
    }
    
    [super viewDidDisappear:animated];
}

- (instancetype)commonInitWithTask:(nullable id<ORKTask>)task taskRunUUID:(nullable NSUUID *)taskRunUUID {
    _hasLockedVolume = NO;
    return [super commonInitWithTask:task taskRunUUID:taskRunUUID];
}

- (void)setTask:(id<ORKTask>)task {
    [super setTask: task];
    _hasMicrophoneAccess = NO;
}

- (void)lockDeviceVolume:(float)volume {
    if (!_hasLockedVolume) {
        _hasLockedVolume = YES;
        _lockedVolume = volume;
        _savedVolume = [[AVAudioSession sharedInstance] outputVolume];
        
        [self registerNotifications];
        
        [[getAVSystemControllerClass() sharedAVSystemController] setActiveCategoryVolumeTo:_lockedVolume];
    }
}

- (void)saveVolume {
    _savedVolume = [[AVAudioSession sharedInstance] outputVolume];
}

- (void)registerNotifications {
    if (@available(iOS 15.0, *)) {
        [[getAVSystemControllerClass() sharedAVSystemController] setAttribute:@[AVSystemController_SystemVolumeDidChangeNotification]
                                                                       forKey:AVSystemController_SubscribeToNotificationsAttribute
                                                                        error:nil];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(volumeDidChange:) name:AVSystemController_SystemVolumeDidChangeNotification object:nil];
}


- (void)removeIdentifiersAndResultsAfterIdentifier:(NSString *)identifier {
    NSUInteger index = [self.managedStepIdentifiers indexOfObject:identifier];
    
    if (index != NSNotFound) {
        NSRange rangeToKeep = NSMakeRange(0, index + 1);
        NSArray *updatedStepIdentifiers = [self.managedStepIdentifiers subarrayWithRange:rangeToKeep];
        NSMutableDictionary *updatedResults = [self.managedResults mutableCopy];
        for (NSString *key in self.managedResults) {
            if (![updatedStepIdentifiers containsObject:key]) {
                [updatedResults removeObjectForKey:key];
            }
        }
        self.managedStepIdentifiers = [updatedStepIdentifiers mutableCopy];
        self.managedResults = updatedResults;
    }
}

- (void)flipToPageWithIdentifier:(NSString *)identifier forward:(BOOL)forward animated:(BOOL)animated eraseForwardResults:(BOOL)eraseForwardResults {
    ORKStep *step = [self.task stepWithIdentifier:identifier];
    if (step) {
        if (eraseForwardResults) {
            [self removeIdentifiersAndResultsAfterIdentifier:identifier];
        }
        [self showStepViewController:[self viewControllerForStep:step] goForward:forward animated:animated];
    }
}

- (BOOL)didHandlePermissionDenial {
    ORKNavigableOrderedTask *task = (ORKNavigableOrderedTask *)self.task;
    
    if (task) {
        BOOL isTaskThatRequiresMicrophoneAccess = [task isKindOfClass:[ORKSpeechInNoisePredefinedTask class]] || [task isKindOfClass:[ORKTinnitusPredefinedTask class]];
        BOOL taskContainsStepThatRequiresMicrophoneAccess = [self _foundStepThatReqiresMicrophoneAccessInTask:task];
        
        if ((isTaskThatRequiresMicrophoneAccess || taskContainsStepThatRequiresMicrophoneAccess) && !_hasMicrophoneAccess) {
            return [self showSensitiveURLLearnMoreStepViewController];
        }
    }
    
    return NO;
}

- (BOOL)_foundStepThatReqiresMicrophoneAccessInTask:(ORKNavigableOrderedTask *)task {
    for (ORKStep *step in task.steps) {
        if ([step isKindOfClass:[ORKActiveStep class]]) {
            ORKActiveStep *activeStep = (ORKActiveStep *)step;
            return [activeStep hasAudioRecording];
        }
    }
    
    return NO;
}

- (BOOL)showSensitiveURLLearnMoreStepViewController {
    // If they select to not allow required permissions, we need to show them to the door.
    if ([self.task isKindOfClass:[ORKNavigableOrderedTask class]]) {
        ORKNavigableOrderedTask *navigableOrderedTask = (ORKNavigableOrderedTask *)self.task;
        
        ORKCompletionStep *completionStep = [[ORKCompletionStep alloc] initWithIdentifier:ORKCompletionStepIdentifierMicrophoneLearnMore];
        completionStep.title = ORKILocalizedString(@"CONTEXT_MICROPHONE_REQUIRED_TITLE", nil);
        completionStep.text = ORKILocalizedString(@"CONTEXT_MICROPHONE_REQUIRED_TEXT", nil);
        completionStep.optional = NO;
        completionStep.reasonForCompletion = ORKTaskFinishReasonDiscarded;
        
        completionStep.iconImage = [UIImage systemImageNamed:@"mic.slash"];
        
        ORKSensitiveURLLearnMoreInstructionStep *learnMoreInstructionStep = [[ORKSensitiveURLLearnMoreInstructionStep alloc]
                                                                             initWithIdentifier:ORKCompletionStepIdentifierMicrophoneLearnMore
                                                                             sensitiveURLString:@ORKSensitiveMicrophoneURLString
                                                                             applicationString:@ORKSensitiveMicrophoneApplicationString];
        
        
        ORKLearnMoreItem *learnMoreItem = [[ORKLearnMoreItem alloc]
                                           initWithText:ORKILocalizedString(@"OPEN_MICROPHONE_SETTINGS", nil)
                                           learnMoreInstructionStep:learnMoreInstructionStep];
        
        ORKBodyItem *settingsLinkBodyItem = [[ORKBodyItem alloc] initWithText:nil
                                                                   detailText:nil
                                                                        image:nil
                                                                learnMoreItem:learnMoreItem
                                                                bodyItemStyle:ORKBodyItemStyleText];
        
        completionStep.bodyItems = @[settingsLinkBodyItem];
        
        [navigableOrderedTask addStep:completionStep];
        
        ORKDirectStepNavigationRule *endNavigationRule = [[ORKDirectStepNavigationRule alloc] initWithDestinationStepIdentifier:ORKNullStepIdentifier];
        [navigableOrderedTask setNavigationRule:endNavigationRule forTriggerStepIdentifier:ORKCompletionStepIdentifierMicrophoneLearnMore];
        
        [self flipToPageWithIdentifier:ORKCompletionStepIdentifierMicrophoneLearnMore forward:YES animated:NO];
        return YES;
    }
    return NO;
}

#pragma mark Volume notifications
- (void)volumeDidChange:(NSNotification *)note {
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive) {
            NSDictionary *userInfo = note.userInfo;
            NSNumber *volume = userInfo[getAVSystemController_AudioVolumeNotificationParameter()];
            
            if (volume.floatValue != self->_lockedVolume) {
                NSString *reason = userInfo[getAVSystemController_AudioVolumeChangeReasonNotificationParameter()];
                if ([reason isEqualToString:@"ExplicitVolumeChange"]) {
                    [[getAVSystemControllerClass() sharedAVSystemController] setActiveCategoryVolumeTo:self->_lockedVolume];
                };
            }
        }
    });
}

- (void)didFinishWithReason:(ORKTaskFinishReason)reason error:(nullable NSError *)error {
    ORKNavigableOrderedTask *navigableOrderedTask = ORKDynamicCast(self.task, ORKNavigableOrderedTask);
    
    id<ORKContext> context = nil;
    for (ORKStep *step in navigableOrderedTask.steps) {
        if (step.context != nil) {
            context = step.context;
            break;
        }
    }
    
    if ([context respondsToSelector:@selector(resetVariables)]) {
        [context performSelector:@selector(resetVariables)];
    }
    
}

- (BOOL)canPerformAnimatedNavigationFromStep:(ORKStep *)step {
    return YES;
}

- (BOOL)handlePermissionRequestsDeniedForStep:(ORKStep *)step error:(NSError **)outError {
    BOOL shouldBail = YES; // start out assuming that being denied permissions is a total deal breaker
    
    // gotta bail if the step requires recording but we weren't granted any permissions
    ORKActiveStep *activeStep = ORKDynamicCast(step, ORKActiveStep);
    shouldBail = shouldBail && ([activeStep hasAudioRecording] == YES);

    // if we need audio recording but don't have microphone access, that's a deal breaker
    shouldBail = shouldBail && (_hasMicrophoneAccess == NO);

    // For some reason, ResearchApp has this as a condition:
    // if we need audio recording and have mic access, that's not enough. We also need to be running in ORKNavigableOrderedTask. w/e
    shouldBail = shouldBail && (ORKDynamicCast(self.task, ORKNavigableOrderedTask) != nil);
    
    if (shouldBail == YES) {
        [self showSensitiveURLLearnMoreStepViewController];
        
        if (outError != nil) {
            *outError = [NSError errorWithDomain:NSCocoaErrorDomain
                                            code:NSUserCancelledError
                                        userInfo:@{@"reason": @"Required permissions not granted."}];
        }
    }
    
    BOOL handled = shouldBail ? NO : YES;
    return handled;
}

- (void)handleResponseFromAudioRequest:(BOOL)success {
    _hasMicrophoneAccess = success;
    [super handleResponseFromAudioRequest:success];
}

@end
