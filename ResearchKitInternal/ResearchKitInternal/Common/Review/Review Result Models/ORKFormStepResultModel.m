/*
 Copyright (c) 2024, Apple Inc. All rights reserved.
 
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

#import "ORKFormStepResultModel.h"

#import "ORKReviewCard.h"
#import "ORKReviewCardItem.h"
#import "ORKReviewCardSection.h"

#import <ResearchKit/ORKAnswerFormat_Internal.h>
#import <ResearchKit/ORKChoiceAnswerFormatHelper.h>
#import <ResearchKit/ORKCollectionResult.h>
#import <ResearchKit/ORKFormStep.h>
#import <ResearchKit/ORKHelpers_Internal.h>
#import <ResearchKit/ORKQuestionStep.h>
#import <ResearchKit/ORKQuestionResult_Private.h>


@implementation ORKFormStepResultModel {
    NSArray<ORKFormStep *> *_formSteps;
    NSArray<ORKStep *> *_surveySteps;
    
    ORKTaskResult *_taskResult;
}

- (instancetype)initWithFormSteps:(NSArray<ORKFormStep *> *)formSteps
                       taskResult:(ORKTaskResult *)taskResult {
    self = [super init];
    
    if (self) {
        _formSteps = [formSteps copy];
        _taskResult = [taskResult copy];
    }
    
    return self;
}

- (instancetype)initWithSurveySteps:(NSArray<ORKStep *> *)surveySteps
                         taskResult:(ORKTaskResult *)taskResult {
    self = [super init];
    
    if (self) {
        _surveySteps = [surveySteps copy];
        _taskResult = [taskResult copy];
        
        [self _validateSurveySteps];
    }
    
    return self;
}

- (NSArray<ORKReviewCardSection *> *)getReviewCards {
    NSArray<ORKReviewCardSection *> *reviewCardSections = [NSArray new];
    
    reviewCardSections = [reviewCardSections arrayByAddingObjectsFromArray:[self _getReviewCardSectionsFromFormSteps]];
    
    return reviewCardSections;
}

- (void)_validateSurveySteps {
    if (_surveySteps != nil) {
        NSString *formStepClassString = NSStringFromClass([ORKFormStep class]);
        NSString *questionStepClassString = NSStringFromClass([ORKQuestionStep class]);
        
        for (ORKStep *step in _surveySteps) {
            NSString *currentStepClassString = NSStringFromClass([step class]);
            if (![currentStepClassString isEqualToString:formStepClassString] && ![currentStepClassString isEqualToString:questionStepClassString]) {
                @throw [NSException exceptionWithName:NSGenericException reason:@"The surveySteps array provided can only contain instances of ORKFormSteps and ORKQuestionSteps." userInfo:nil];
            }
        }
    }
}

- (NSArray<ORKReviewCardSection *> *)_getReviewCardSectionsFromFormSteps {
    NSMutableArray<ORKReviewCardSection *> *reviewCardSections = [NSMutableArray new];
    
    for (ORKFormStep *formStep in _formSteps) {
        [reviewCardSections addObjectsFromArray:[self _getReviewCardSectionsForFormStep:formStep]];
    }
    
    return reviewCardSections;
}

- (NSMutableArray<ORKReviewCardSection *> *)_getReviewCardSectionsForFormStep:(ORKFormStep *)formStep {
    NSMutableArray<ORKReviewCardSection *> *reviewCardSections = [NSMutableArray new];
    NSMutableArray<ORKReviewCard *> *reviewCards = [NSMutableArray new];
    ORKStepResult *stepResult = (ORKStepResult *)[_taskResult resultForIdentifier:formStep.identifier];
    
    if (stepResult) {
        
        // Create an ORKReviewCardItem for each result
        for (ORKQuestionResult *questionResult in stepResult.results) {
            ORKAnswerFormat *answerFormat = [self _answerFormatWithIdentifier:questionResult.identifier formStep:formStep];
            NSString *question = [self _questionWithIdentifier:questionResult.identifier formStep:formStep];
            
            if (answerFormat != nil) {
                ORKReviewCardItem *reviewCardItem = [self _constructReviewCardItemsWithAnswerFormat:answerFormat
                                                                                             result:questionResult
                                                                                           question:question];
                
                // Each ORKReviewCard will only have one ORKReviewCardItem for now
                ORKReviewCard *reviewCard = [[ORKReviewCard alloc] initWithReviewCardItems:@[reviewCardItem]];
                [reviewCards addObject:reviewCard];
            }
        }
    }
    
    // Each formStep will have only one ORKReviewCardSection for now
    ORKReviewCardSection *reviewCardSection = [[ORKReviewCardSection alloc] initWithTitle:nil reviewCards:reviewCards];
    [reviewCardSections addObject:reviewCardSection];
    
    return reviewCardSections;
}

- (ORKAnswerFormat *)_answerFormatWithIdentifier:(NSString *)identifier formStep:(ORKFormStep *)formStep {
    for (ORKFormItem *formItem in formStep.formItems) {
        if ([formItem.identifier isEqualToString:identifier] && formItem.answerFormat != nil) {
            return formItem.answerFormat;
        }
    }
    
    // TODO: Throw here
    return nil;
}

- (NSString *)_questionWithIdentifier:(NSString *)identifier formStep:(ORKFormStep *)formStep {
    for (ORKFormItem *formItem in formStep.formItems) {
        if ([formItem.identifier isEqualToString:identifier] && formItem.answerFormat != nil) {
            return formItem.text;
        }
    }
    
    // TODO: Throw here
    return nil;
}

- (ORKReviewCardItem *)_constructReviewCardItemsWithAnswerFormat:(ORKAnswerFormat *)answerFormat
                                                          result:(ORKQuestionResult *)result
                                                        question:(NSString *)question {
    NSMutableArray<NSString *> *reviewCardItemValues = [NSMutableArray new];
    
    if ([self _isTextChoiceQuestionAnswerFormat:answerFormat result:result]) {
        ORKTextChoiceAnswerFormat *textChoiceAnswerFormat = ORKDynamicCast(answerFormat, ORKTextChoiceAnswerFormat);
        ORKChoiceQuestionResult *choiceQuestionResult = ORKDynamicCast(result, ORKChoiceQuestionResult);
        ORKChoiceAnswerFormatHelper *choiceAnswerHelper = [[ORKChoiceAnswerFormatHelper alloc] initWithAnswerFormat:textChoiceAnswerFormat];
        
        for (NSObject<NSCopying, NSSecureCoding> *answer in choiceQuestionResult.choiceAnswers) {
            NSString *stringAnswerForChoice = [choiceAnswerHelper stringForChoiceAnswer:answer] ?: @"No answer";
            [reviewCardItemValues addObject:stringAnswerForChoice];
        }
    } else {
        NSString *resultString = [answerFormat stringForAnswer: result.answer] ?: @"No answer";
        [reviewCardItemValues addObject:resultString];
    }
    
    ORKReviewCardItem *reviewCardItem = [[ORKReviewCardItem alloc] initWithTitle:question resultValues:reviewCardItemValues];
    return reviewCardItem;
}

- (BOOL)_isTextChoiceQuestionAnswerFormat:(ORKAnswerFormat *)answerFormat result:(ORKQuestionResult *)result {
    NSString *answerFormatClassString = NSStringFromClass([answerFormat class]);
    NSString *resultClassString = NSStringFromClass([result class]);
    BOOL answerFormatIsTextChoice = [answerFormatClassString isEqualToString:NSStringFromClass([ORKTextChoiceAnswerFormat class])];
    BOOL resultIsChoiceQuestion = [resultClassString isEqualToString:NSStringFromClass([ORKChoiceQuestionResult class])];
    
    return answerFormatIsTextChoice && resultIsChoiceQuestion;
}

@end
