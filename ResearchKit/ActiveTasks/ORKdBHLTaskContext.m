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

#if RK_APPLE_INTERNAL

#import <ResearchKit/ORKContext.h>
#import "ORKdBHLToneAudiometryCompletionStep.h"
#import "ORKHelpers_Internal.h"


@implementation ORKdBHLTaskContext

- (NSString *)didSkipHeadphoneDetectionStepForTask:(id<ORKTask>)task {
    
    if ([task isKindOfClass:[ORKOrderedTask class]]) {
        
        static NSString * dBHLToneAudiometryCompletionStepIdentifier = @"ORKdBHLCompletionStepIdentifierHeadphonesRequired";
        
        ORKOrderedTask *currentTask = (ORKNavigableOrderedTask *)task;
        
        ORKdBHLToneAudiometryCompletionStep *step = [[ORKdBHLToneAudiometryCompletionStep alloc] initWithIdentifier:dBHLToneAudiometryCompletionStepIdentifier];
        step.title = ORKLocalizedString(@"dBHL_NO_COMPATIBLE_HEADPHONES_COMPLETION_TITLE", nil);
        step.text = ORKLocalizedString(@"dBHL_NO_COMPATIBLE_HEADPHONES_COMPLETION_TEXT", nil);
        
        [currentTask addStep:step];
        
        return dBHLToneAudiometryCompletionStepIdentifier;
    }
    
    return nil;
}

- (NSString *)didNotAllowRequiredHealthPermissionsForTask:(id<ORKTask>)task
{
    NSAssert([task isKindOfClass:[ORKNavigableOrderedTask class]], @"Unexpected task type.");
    if ([task isKindOfClass:[ORKNavigableOrderedTask class]])
    {
        // If the user opts out of health access, append a new step to the end of the task and skip to the end.
        // Add a navigation rule to end the current task.
        ORKNavigableOrderedTask *currentTask = (ORKNavigableOrderedTask *)task;
        
        NSString *healthPermissionsRequired = @"ORKdBHLStepIdentifierHealthPermissionsRequired";
        
        ORKCompletionStep *step = [[ORKCompletionStep alloc] initWithIdentifier:healthPermissionsRequired];
        step.title = ORKLocalizedString(@"CONTEXT_MICROPHONE_REQUIRED_TITLE", nil);
        step.text = ORKLocalizedString(@"CONTEXT_MICROPHONE_REQUIRED_TEXT", nil);
        step.optional = NO;
        step.reasonForCompletion = ORKTaskViewControllerFinishReasonDiscarded;
        
        if (@available(iOS 13.0, *)) {
            step.iconImage = [UIImage systemImageNamed:@"mic.slash"];
        }

        ORKLearnMoreInstructionStep *learnMoreInstructionStep = [[ORKLearnMoreInstructionStep alloc] initWithIdentifier:ORKCompletionStepIdentifierMicrophoneLearnMore];
        ORKLearnMoreItem *learnMoreItem = [[ORKLearnMoreItem alloc]
                                           initWithText:ORKLocalizedString(@"OPEN_MICROPHONE_SETTINGS", nil)
                                           learnMoreInstructionStep:learnMoreInstructionStep];
        
        ORKBodyItem *settingsLinkBodyItem = [[ORKBodyItem alloc] initWithText:nil
                                                                   detailText:nil
                                                                        image:nil
                                                                learnMoreItem:learnMoreItem
                                                                bodyItemStyle:ORKBodyItemStyleText];
        
        step.bodyItems = @[settingsLinkBodyItem];

        [currentTask addStep:step];
        
        ORKDirectStepNavigationRule *endNavigationRule = [[ORKDirectStepNavigationRule alloc] initWithDestinationStepIdentifier:ORKNullStepIdentifier];
        [currentTask setNavigationRule:endNavigationRule forTriggerStepIdentifier:healthPermissionsRequired];
        
        return healthPermissionsRequired;
    }
    
    return (NSString * _Nonnull)nil;
}

@end

#endif
