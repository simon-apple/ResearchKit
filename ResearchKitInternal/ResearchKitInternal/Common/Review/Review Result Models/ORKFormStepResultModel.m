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

#import "ORKReviewCardSection.h"

#import <ResearchKit/ORKCollectionResult.h>
#import <ResearchKit/ORKFormStep.h>
#import <ResearchKit/ORKQuestionStep.h>


@implementation ORKFormStepResultModel

+ (NSArray<ORKReviewCardSection *> *)getReviewCardSectionsWithFormSteps:(NSArray<ORKFormStep *> *)formSteps
                                                             taskResult:(ORKTaskResult *)taskResult {
    // iterate through form steps
    // find result for each step
    // iterate through results of each result
    // cast the result to a string (depending on the specific type)
    
    NSMutableArray<ORKReviewCardSection *> *reviewCardSections = [NSMutableArray new];
    
    for (ORKFormStep *formStep in formSteps) {
        ORKStepResult *stepResult = (ORKStepResult *)[taskResult resultForIdentifier:formStep.identifier];
        
        if (stepResult) {
            ORKReviewCardSection *reviewCardSection = [ORKFormStepResultModel _getReviewSectionCardWithFormStep:formStep stepResult:stepResult];
            if (reviewCardSection != nil) {
                [reviewCardSections addObject:reviewCardSection];
            }
        }
        
    }
    
    return reviewCardSections;
}

+ (NSArray<ORKReviewCardSection *> *)getReviewCardSectionsWithSurveySteps:(NSArray<ORKStep *> *)surveySteps
                                                               taskResult:(ORKTaskResult *)taskResult {
    [ORKFormStepResultModel _validateSurveySteps:surveySteps];
    
    
    
    
    return [NSArray new];
}

+ (void)_validateSurveySteps:(NSArray<ORKStep *> *)surveySteps {
    NSString *formStepClassString = NSStringFromClass([ORKFormStep class]);
    NSString *questionStepClassString = NSStringFromClass([ORKQuestionStep class]);
    
    for (ORKStep *step in surveySteps) {
        NSString *currentStepClassString = NSStringFromClass([step class]);
        if (![currentStepClassString isEqualToString:formStepClassString] && ![currentStepClassString isEqualToString:questionStepClassString]) {
            @throw [NSException exceptionWithName:NSGenericException reason:@"The surveySteps array provided can only contain instances of ORKFormSteps and ORKQuestionSteps." userInfo:nil];
        }
    }
}

+ (nullable ORKReviewCardSection *)_getReviewSectionCardWithFormStep:(ORKFormStep *)formStep stepResult:(ORKStepResult *)stepResult {
    
    
    return nil;
}

+ (nullable ORKReviewCardSection *)_getReviewSectionCardWithQuestionStep:(ORKQuestionStep *)questionStep stepResult:(ORKStepResult *)stepResult {
    

    return nil;
}

@end
