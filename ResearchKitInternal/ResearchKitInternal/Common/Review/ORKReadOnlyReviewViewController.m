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

#import <ResearchKit/ORKCollectionResult.h>
#import <ResearchKit/ORKFormStep.h>
#import <ResearchKit/ORKOrderedTask.h>
#import <ResearchKit/ORKStep.h>


@implementation ORKReadOnlyReviewViewController {
    ORKOrderedTask *_orderedTask;
    ORKTaskResult *_taskResult;
    ORKReadOnlyStepType _readOnlyStepType;
    
    NSArray<ORKStep *> *_stepsToParse;
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
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor systemGrayColor];
}

- (NSArray<ORKStep *> *)_getStepsToParseForResults {
    switch (_readOnlyStepType) {
        case ORKReadOnlyStepTypeFormStep:
            return [self _getStepsOfClass:[ORKFormStep class]];
            break;
            
        case ORKReadOnlyStepTypeFamilyHistoryStep:
            return [self _getStepsOfClass:[ORKFamilyHistoryStep class]];
            break;
            
        default:
            break;
    }
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


@end
