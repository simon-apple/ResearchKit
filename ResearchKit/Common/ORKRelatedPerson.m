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

#import "ORKRelatedPerson.h"

#import "ORKCollectionResult.h"
#import "ORKCollectionResult_Private.h"
#import "ORKResult_Private.h"
#import "ORKStep_Private.h"
#import "ORKQuestionResult.h"
#import "ORKQuestionResult_Private.h"

#import "ORKHelpers_Internal.h"

#if RK_APPLE_INTERNAL
#import "ORKFormStep.h"
#endif

@implementation ORKRelatedPerson

- (instancetype)initWithIdentifier:(NSString *)identifier
                   groupIdentifier:(NSString *)groupIdentifier
                        taskResult:(ORKTaskResult *)result {
    self = [super init];
    
    if (self) {
        _identifier = [identifier copy];
        _groupIdentifier = [groupIdentifier copy];
        _taskResult = [result copy];
    }
    return self;
}

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    ORK_ENCODE_OBJ(aCoder, identifier);
    ORK_ENCODE_OBJ(aCoder, groupIdentifier);
    ORK_ENCODE_OBJ(aCoder, taskResult);
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-designated-initializers"
- (instancetype)initWithCoder:(NSCoder *)aDecoder { 
    self = [super init];
    if (self) {
        ORK_DECODE_OBJ_CLASS(aDecoder, identifier, NSString);
        ORK_DECODE_OBJ_CLASS(aDecoder, groupIdentifier, NSString);
        ORK_DECODE_OBJ_CLASS(aDecoder, taskResult, ORKTaskResult);
    }
    return self;
}

- (instancetype)copyWithZone:(nullable NSZone *)zone { 
    ORKRelatedPerson *relatedPerson = [[[self class] allocWithZone:zone] initWithIdentifier:[_identifier copy]
                                                                            groupIdentifier:[_groupIdentifier copy]
                                                                                 taskResult:[_taskResult copy]];
    return relatedPerson;
}

- (BOOL)isEqual:(id)object {
    if ([self class] != [object class]) {
        return NO;
    }
    
    __typeof(self) castObject = object;
    return (ORKEqualObjects(self.identifier, castObject.identifier)
            && ORKEqualObjects(self.groupIdentifier, castObject.groupIdentifier)
            && ORKEqualObjects(self.taskResult, castObject.taskResult));
}

- (nullable NSString *)getTitleValueWithIdentifier:(NSString *)identifier {
    return [self getResultValueWithIdentifier:identifier];
}

- (NSArray<NSString *> *)getDetailListValuesWithIdentifiers:(NSArray<NSString *> *)identifiers
                                    displayInfoKeyAndValues:(nonnull NSDictionary<NSString *,NSDictionary<NSString *,NSString *> *> *)displayInfoKeyAndValues {
    NSMutableArray<NSString *> *detailListValues = [NSMutableArray new];
    
    for (NSString *identifier in identifiers) {
        NSString *value = [self getResultValueWithIdentifier:identifier];
        
        if (value) {
            NSString *displayText = displayInfoKeyAndValues[identifier][value];
            [detailListValues addObject: displayText != nil ? displayText : value];
        }
    }
    
    return [detailListValues copy];
}

- (NSArray<NSString *> *)getConditionsListWithStepIdentifier:(NSString *)stepIdentifier
                                          formItemIdentifier:(NSString *)formItemIdentifier
                                         conditionsKeyValues:(nonnull NSDictionary<NSString *,NSString *> *)conditionsKeyValues {
    ORKStepResult *stepResult = (ORKStepResult *)[self.taskResult resultForIdentifier:stepIdentifier];
    
    ORKChoiceQuestionResult *choiceQuestionResult = (ORKChoiceQuestionResult *)[stepResult resultForIdentifier:formItemIdentifier];
    NSArray<NSString *> *conditionsList = (NSArray<NSString *> *)choiceQuestionResult.choiceAnswers;
    
    NSMutableArray<NSString *> *conditionListDisplayValues = [NSMutableArray new];
    
    for (NSString *condition in conditionsList) {
        [conditionListDisplayValues addObject:[conditionsKeyValues valueForKey:condition]];
    }
    
    return [conditionListDisplayValues copy];
}

- (nullable NSString *)getResultValueWithIdentifier:(NSString *)identifier {
    for (ORKStepResult *result in _taskResult.results) {
        ORKQuestionResult *questionResult = (ORKQuestionResult *)[result resultForIdentifier:identifier];
        
        if (questionResult) {
            if ([questionResult isKindOfClass:[ORKChoiceQuestionResult class]]) {
                ORKChoiceQuestionResult *choiceQuestionResult = (ORKChoiceQuestionResult *)questionResult;
                return (NSString *)choiceQuestionResult.choiceAnswers.firstObject;
            } else {
                return (NSString *)questionResult.answer;
            }
        } else {
            break;
        }
    }
    
    return nil;
}

#if RK_APPLE_INTERNAL
- (int)getAgeFromFormSteps:(NSArray<ORKFormStep *> *)formSteps {
    for (ORKFormStep *formStep in formSteps) {
        int index = 0;
        for (ORKFormItem *formItem in formStep.formItems) {
            if ([formItem.text containsString:@"age?"]) {
                // If answerFormat is nil that means that the formItem is used as a section header and we should fetch the next formItem in the array
                NSString *identifier = formItem.answerFormat != nil ? formItem.identifier : formStep.formItems[index + 1].identifier;
                NSString *value = [self getResultValueWithIdentifier:identifier];
                if (value) {
                    return [value integerValue];
                }
                break;
            }
            
            index += 1;
        }
    }
    
    return 0;
}
#endif

@end
