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

#import "ORKReadOnlyReviewViewController.h"

#import "ORKFamilyHistoryStep.h"
#import "ORKReviewCardSection.h"
#import "ORKReviewResultModel.h"

#import <ResearchKit/ORKCollectionResult.h>
#import <ResearchKit/ORKFormStep.h>
#import <ResearchKit/ORKQuestionStep.h>
#import <ResearchKit/ORKOrderedTask.h>
#import <ResearchKit/ORKStep.h>


@implementation ORKReadOnlyReviewViewController {
    ORKOrderedTask *_orderedTask;
    ORKTaskResult *_taskResult;
    ORKReadOnlyStepType _readOnlyStepType;
    
    NSArray<ORKStep *> *_stepsToParse;
    NSArray<ORKReviewCardSection *> *_reviewCardSections;
}


- (nonnull instancetype)initWithTask:(nonnull ORKOrderedTask *)task 
                              result:(nonnull ORKTaskResult *)result
                    readOnlyStepType:(ORKReadOnlyStepType)readOnlyStepType {
    self = [super init];
    
    if (self) {
        _orderedTask = [task copy];
        _taskResult = [result copy];
        _readOnlyStepType = readOnlyStepType;
        _stepsToParse = [self _getStepsToParseForResults];
        _reviewCardSections = [self _getReviewCardSections];
        
        self.view.backgroundColor = [UIColor systemGrayColor];
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (NSArray<ORKStep *> *)_getStepsToParseForResults {
    switch (_readOnlyStepType) {
        case ORKReadOnlyStepTypeFormStep:
            return [self _getStepsOfClass:[ORKFormStep class]];
            break;
            
        case ORKReadOnlyStepTypeSurveyStep:
            return [self _getSurveyTypeSteps];
            break;
            
        case ORKReadOnlyStepTypeFamilyHistoryStep:
            return [self _getStepsOfClass:[ORKFamilyHistoryStep class]];
            break;
            
        default:
            break;
    }
}

- (NSArray<ORKStep *> *)_getSurveyTypeSteps {
    NSArray<ORKStep *> *formSteps = [self _getStepsOfClass:[ORKFormStep class]];
    NSArray<ORKStep *> *questionSteps = [self _getStepsOfClass:[ORKQuestionStep class]];
    
    return [formSteps arrayByAddingObjectsFromArray:questionSteps];
}

- (NSArray<ORKStep *> *)_getStepsOfClass:(Class)class {
    NSMutableArray<ORKStep *> *steps = [NSMutableArray new];
    NSString *classString = NSStringFromClass(class);
    
    for (ORKStep *step in _orderedTask.steps) {
        if ([NSStringFromClass([step class]) isEqualToString:classString]) {
            [steps addObject:step];
        }
    }
    
    return steps;
}

- (NSArray<ORKReviewCardSection *> *)_getReviewCardSections {
    switch (_readOnlyStepType) {
        case ORKReadOnlyStepTypeFormStep:
            return [ORKReviewResultModel getReviewCardSectionsWithFormSteps:[self _getCastedFormSteps] taskResult:_taskResult];
            break;
            
        case ORKReadOnlyStepTypeSurveyStep:
            return [NSArray new];
            break;
            
        case ORKReadOnlyStepTypeFamilyHistoryStep:
            // TODO: rdar://128870162 (Create model object for organizing ORKFamilyHistoryStep results)
            return [NSArray new];
            break;
            
        default:
            break;
    }
}

- (NSArray<ORKFormStep *> *)_getCastedFormSteps {
    NSArray<ORKFormStep *> *formSteps = (NSArray<ORKFormStep *> *)_stepsToParse;
    
    if (!formSteps) {
        @throw [NSException exceptionWithName:NSGenericException reason:@"Failed to cast collected steps to ORKFormSteps" userInfo:nil];
    }
    
    return formSteps;
}

@end
