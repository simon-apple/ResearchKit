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

#import "AAPLCompletionStepViewController.h"
#import "AAPLCompletionStep.h"

#import "ResearchKitUI/ORKInstructionStepViewController_Internal.h"
#import "ResearchKitUI/ORKTaskViewController_Internal.h"
#import "ResearchKitUI/ORKStepViewController_Internal.h"

#import "ResearchKit/ORKContext.h"

@implementation AAPLCompletionStepViewController

-(void)stepDidChange {
    [super stepDidChange];
    
    if ([self isSpeechInNoisePredefinedTaskPractice])
    {
        [self setContinueButtonTitle:ORKLocalizedString(@"BUTTON_START_TEST", nil)];
    }
}

// FIXME: rdar://98465050 (deal with internal code workaround)
- (NSObject<ORKContext> * _Nullable)speechInNoisePredefinedTaskContext
{
    Class speechInNoisePredefinedTaskContext = NSClassFromString(@"ORKSpeechInNoisePredefinedTaskContext");
    
    if (self.step.context && speechInNoisePredefinedTaskContext != nil && [self.step.context isKindOfClass:speechInNoisePredefinedTaskContext])
    {
        return self.step.context;
    }
    return nil;
}

- (BOOL)isSpeechInNoisePredefinedTaskPractice
{
    return [[self speechInNoisePredefinedTaskContext] performSelector:@selector(isPracticeTest)];
}

- (void)setSkipButtonItem:(UIBarButtonItem *)skipButtonItem
{
    [super setSkipButtonItem:skipButtonItem];
    
    if ([self isSpeechInNoisePredefinedTaskPractice])
    {
        [skipButtonItem setTitle:ORKLocalizedString(@"BUTTON_PRACTICE_AGAIN", nil)];
        skipButtonItem.target = self;
        skipButtonItem.action = @selector(practiceAgainPressed:);
    }
}

- (void)practiceAgainPressed:(id)sender
{
    if ([self isSpeechInNoisePredefinedTaskPractice])
    {
        [self.taskViewController flipToPageWithIdentifier:[[self speechInNoisePredefinedTaskContext] performSelector:@selector(practiceAgainStepIdentifier)] forward:NO animated:YES];
    }
}

- (BOOL)hasPreviousStep {
    if ([self.step.identifier isEqualToString:ORKEnvironmentSPLMeterTimeoutIdentifier]) {
        return YES;
    }
    return [super hasPreviousStep];
}

@end
