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

#import "AAPLSpeechRecognitionStepViewController.h"

#import <ResearchKitActiveTask/ORKSpeechRecognitionStepViewController_Private.h>
#import <ResearchKitActiveTask/ORKSpeechRecognitionResult.h>

#import <ResearchKit/ORKQuestionStep.h>
#import <ResearchKit/ORKAnswerFormat.h>
#import <ResearchKit/ORKBodyItem.h>
#import <ResearchKit/ORKBodyItem_Internal.h>
#import <ResearchKit/ORKHelpers_Internal.h>

#import "AAPLUtils.h"
#import "ORKContext.h"

@interface AAPLSpeechRecognitionStepViewController ()

@end

@implementation AAPLSpeechRecognitionStepViewController

- (NSObject<ORKContext> * _Nullable)currentSpeechInNoisePredefinedTaskContext {
    Class ORKSpeechInNoisePredefinedTaskContext = NSClassFromString(@"ORKSpeechInNoisePredefinedTaskContext");
    if (self.step.context && [self.step.context isKindOfClass:ORKSpeechInNoisePredefinedTaskContext]) {
        return self.step.context;
    }
    
    return nil;
}

- (void)setAllowUserToRecordInsteadOnNextStep:(BOOL)allowUserToRecordInsteadOnNextStep {
    [super setAllowUserToRecordInsteadOnNextStep:allowUserToRecordInsteadOnNextStep];
    
    NSObject<ORKContext> *currentContext = [self currentSpeechInNoisePredefinedTaskContext];
    if (currentContext)
    {
        [currentContext setValue:@(allowUserToRecordInsteadOnNextStep) forKey:@"prefersKeyboard"];
    }
}

- (BOOL)isPracticeTest {
    NSObject<ORKContext> *currentContext = [self currentSpeechInNoisePredefinedTaskContext];
    if (((NSNumber *)[currentContext valueForKey:@"isPracticeTest"]).boolValue || ((NSNumber *)[currentContext valueForKey:@"prefersKeyboard"]).boolValue) {
        // If we are in the speech in noise predefined context and we are in a practice test or the user elected to use keyboard entry, do not save their result.
        return YES;
    }
    
    return [super isPracticeTest];
}

- (void)setupNextStepForAllowingUserToRecordInstead:(BOOL)allowUserToRecordInsteadOnNextStep {
    NSObject<ORKContext> *currentContext = [self currentSpeechInNoisePredefinedTaskContext];
    if (currentContext)
    {
        ORKQuestionStep *nextStep = [self nextStep];
        if (nextStep)
        {
            NSObject<ORKContext> *nextStepContext = nil;
            Class ORKSpeechInNoisePredefinedTaskContext = NSClassFromString(@"ORKSpeechInNoisePredefinedTaskContext");
            if ([nextStep.context isKindOfClass:ORKSpeechInNoisePredefinedTaskContext])
            {
                nextStepContext = nextStep.context;
            }

            NSString *substitutedTextAnswer = [self substitutedStringWithString:[self.localResult.transcription formattedString]];
            
            [((ORKTextAnswerFormat *)nextStep.answerFormat) setDefaultTextAnswer:substitutedTextAnswer];
            
            if (allowUserToRecordInsteadOnNextStep)
            {
                nextStep.title = AAPLLocalizedString(@"SPEECH_IN_NOISE_PREDEFINED_TYPE_TITLE", nil);
                nextStep.text = nil;
                
                if (nextStepContext)
                {
                    [nextStepContext setValue:@(YES) forKey:@"prefersKeyboard"];
                }
                
                ORKStrongTypeOf(self.taskViewController) strongTaskViewController = self.taskViewController;
                
                ORKBodyItem *buttonItem = [[ORKBodyItem alloc] initWithCustomButtonConfigurationHandler:^(UIButton * _Nonnull button) {
                    
                    ORKWeakTypeOf(self.taskViewController) weakTaskViewController = strongTaskViewController;
                    
                    [button setImage:[UIImage systemImageNamed:@"smallcircle.fill.circle"] forState:UIControlStateNormal];
                    [[button imageView] setTintColor:UIColor.systemRedColor];
                    button.adjustsImageWhenHighlighted = NO;
                    NSAttributedString *attributedTitle = [[NSAttributedString alloc] initWithString:AAPLLocalizedString(@"SPEECH_IN_NOISE_PREDEFINED_RECORD_INSTEAD", nil)
                                                                                          attributes:@{NSFontAttributeName:[self buttonTextFont],
                                                                                                       NSForegroundColorAttributeName:self.view.tintColor}];
                    [button setAttributedTitle:attributedTitle forState:UIControlStateNormal];
                    [button addTarget:weakTaskViewController.currentStepViewController action:@selector(goBackward) forControlEvents:UIControlEventTouchUpInside];
                    [button setTitleEdgeInsets:UIEdgeInsetsMake(0, 5, 0, -5)];
                    [button setContentEdgeInsets:UIEdgeInsetsMake(0, 0, 0, -5)];
                }];
                
                nextStep.bodyItems = @[buttonItem];
            }
            else
            {
                nextStep.title = AAPLLocalizedString(@"SPEECH_IN_NOISE_PREDEFINED_REVIEW_TITLE", nil);
                nextStep.text = AAPLLocalizedString(@"SPEECH_IN_NOISE_PREDEFINED_REVIEW_TEXT", nil);
                nextStep.bodyItems = nil;
                
                if (nextStepContext)
                {
                    [nextStepContext setValue:@(NO) forKey:@"prefersKeyboard"];
                }
            }
        }
    } else {
        [super setupNextStepForAllowingUserToRecordInstead:allowUserToRecordInsteadOnNextStep];
    }
}


@end
