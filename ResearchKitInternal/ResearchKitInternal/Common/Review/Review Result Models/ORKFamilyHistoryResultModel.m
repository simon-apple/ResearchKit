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

#import "ORKFamilyHistoryResultModel.h"

#import "ORKConditionStepConfiguration.h"
#import "ORKFamilyHistoryResult.h"
#import "ORKFamilyHistoryStep.h"
#import "ORKHealthCondition.h"
#import "ORKIUtils.h"
#import "ORKRelatedPerson.h"
#import "ORKRelativeGroup.h"
#import "ORKReviewCard.h"
#import "ORKReviewCardItem.h"
#import "ORKReviewCardSection.h"

#import <ResearchKit/ORKCollectionResult.h>
#import <ResearchKit/ORKQuestionResult_Private.h>
#import <ResearchKit/ORKTask.h>

NSString * const ORKHealthConditionIDontKnowChoice = @"do not know";
NSString * const ORKHealthConditionNoneOfTheAboveChoice = @"none of the above";
NSString * const ORKHealthConditionPreferNotToAnswerChoice = @"prefer not to answer";


@interface ORKRelativeGroupResultWrapper : NSObject

- (instancetype)initWithRelativeGroups:(NSArray<ORKRelativeGroup *> *)relativeGroups;

- (void)saveRelatedPerson:(ORKRelatedPerson *)relatedPerson;

@property (nonatomic) NSMutableDictionary<NSString *, NSMutableArray<ORKRelatedPerson *> *> *relatedPersons;
@property (nonatomic) NSArray<NSString *> *conditionIdentifiersFromLastSession;

@end

@implementation ORKRelativeGroupResultWrapper {
    NSArray<ORKRelativeGroup *> *_relativeGroups;
}

- (instancetype)initWithRelativeGroups:(NSArray<ORKRelativeGroup *> *)relativeGroups {
    self = [super init];
    if (self) {
        _relativeGroups = [relativeGroups copy];
        _relatedPersons = [NSMutableDictionary new];
        _conditionIdentifiersFromLastSession = [NSArray new];
    }
    return self;
}

- (void)saveRelatedPerson:(ORKRelatedPerson *)relatedPerson {
    if (!_relatedPersons[relatedPerson.groupIdentifier]) {
        _relatedPersons[relatedPerson.groupIdentifier] = [NSMutableArray new];
    }
    
    [_relatedPersons[relatedPerson.groupIdentifier] addObject:relatedPerson];
    [self _organizeRelatedPersonsByBirthYear];
}

- (void)_organizeRelatedPersonsByBirthYear {
    for (ORKRelativeGroup *relativeGroup in _relativeGroups) {
        if (_relatedPersons[relativeGroup.identifier].count > 1) {
            _relatedPersons[relativeGroup.identifier] = [self _bubbleSortRelativeGroup:relativeGroup];
        }
    }
}

- (NSMutableArray<ORKRelatedPerson *> *)_bubbleSortRelativeGroup:(ORKRelativeGroup *)relativeGroup {
    NSMutableArray<ORKRelatedPerson *> *relatedPersons = _relatedPersons[relativeGroup.identifier];
    NSMutableArray<ORKRelatedPerson *> *relatedPersonsNoAge = [NSMutableArray new];
    NSArray<ORKFormStep *> *formSteps = [relativeGroup.formSteps copy];
    
    NSInteger index = relatedPersons.count;
    
    while (index > 0) {
        for (int tempIndex = 0; tempIndex < index - 1; tempIndex++) {
            ORKRelatedPerson *relatedPersonLeft = relatedPersons[tempIndex];
            ORKRelatedPerson *relatedPersonRight = relatedPersons[tempIndex + 1];
            
            if ([relatedPersonLeft getAgeFromFormSteps:formSteps].doubleValue > [relatedPersonRight getAgeFromFormSteps:formSteps].doubleValue) {
                [relatedPersons exchangeObjectAtIndex:tempIndex withObjectAtIndex:tempIndex + 1];
            } else if ([relatedPersonLeft getAgeFromFormSteps:formSteps] == [relatedPersonRight getAgeFromFormSteps:formSteps]) {
                if ([relatedPersonLeft.taskResult.startDate compare:relatedPersonRight.taskResult.startDate] == NSOrderedAscending) {
                    [relatedPersons exchangeObjectAtIndex:tempIndex withObjectAtIndex:tempIndex + 1];
                }
            }
        }
        
        index -= 1;
    }
    
    // collect all relatives with no age provided
    for (int tempIndex = 0; tempIndex < relatedPersons.count; tempIndex++) {
        ORKRelatedPerson *relatedPerson = relatedPersons[tempIndex];

        if ([relatedPerson getAgeFromFormSteps:formSteps] == nil) {
            [relatedPersonsNoAge addObject:relatedPerson];
        }
    }
    
    // remove all related members with no age provided then append them to the end of the array
    [relatedPersons removeObjectsInArray:relatedPersonsNoAge];
    [relatedPersons addObjectsFromArray:relatedPersonsNoAge];

    return relatedPersons;
}

@end


@implementation ORKFamilyHistoryResultModel {
    NSArray<ORKFamilyHistoryStep *> *_familyHistorySteps;
    ORKTaskResult *_taskResult;
}

- (instancetype)initWithFamilyHistorySteps:(NSArray<ORKFamilyHistoryStep *> *)familyHistorySteps
                                taskResult:(ORKTaskResult *)taskResult {
    self = [super init];
    
    if (self) {
        _familyHistorySteps = [familyHistorySteps copy];
        _taskResult = [taskResult copy];
    }
    
    return self;
}


- (NSArray<ORKReviewCardSection *> *)getReviewCards {
    NSMutableArray<ORKReviewCardSection *> *reviewCardSections = [NSMutableArray new];
    
    for (ORKFamilyHistoryStep *familyHistoryStep in _familyHistorySteps) {
        ORKRelativeGroupResultWrapper *relativeGroupResultWrapper = [[ORKRelativeGroupResultWrapper alloc] initWithRelativeGroups:[familyHistoryStep.relativeGroups copy]];
        ORKStepResult *stepResult = (ORKStepResult *)[_taskResult resultForIdentifier:familyHistoryStep.identifier];
        
        // TODO: split this out into its own method (to create a nullable ORKRelativeGroupResultWrapper)
        if (stepResult) {
            ORKFamilyHistoryResult *familyHistoryResult = (ORKFamilyHistoryResult *)stepResult.firstResult;
            
            if (familyHistoryResult) {
                for (ORKRelatedPerson *relatedPerson in familyHistoryResult.relatedPersons) {
                    [relativeGroupResultWrapper saveRelatedPerson:[relatedPerson copy]];
                }
                relativeGroupResultWrapper.conditionIdentifiersFromLastSession = [familyHistoryResult.displayedConditions copy];
            }
        }
        
        // TODO: split this out into its own method (to collect an array of ReviewCardSections)
        for (ORKRelativeGroup *relativeGroup in familyHistoryStep.relativeGroups) {
            NSMutableArray<ORKReviewCard *> *reviewCards = [NSMutableArray new];
            NSArray<ORKRelatedPerson *> *relatedPersons = [relativeGroupResultWrapper.relatedPersons valueForKey:relativeGroup.identifier];
            
            if (relatedPersons) {
                int index = 1;
                for (ORKRelatedPerson *relatedPerson in relatedPersons) {
                    [self _populateAgeQuestionValuesForRelatedPerson:relatedPerson relativeGroup:relativeGroup];
                    
                    NSString *title = [relatedPerson getTitleValueWithIdentifier:relativeGroup.identifierForCellTitle] ?: [NSString stringWithFormat:@"%@ %d", relativeGroup.name, index];;
                    NSArray<NSString *> *detailValues = [relatedPerson getDetailListValuesWithIdentifiers:relativeGroup.detailTextIdentifiers displayInfoKeyAndValues:[self _getDetailInfoTextAndValuesForRelativeGroup:relativeGroup]];
                    ORKReviewCardItem *detailListReviewCardItem = [[ORKReviewCardItem alloc] initWithTitle:title resultValues:detailValues];

                    NSArray<NSString *> *conditionValues = [relatedPerson getConditionsListWithStepIdentifier:familyHistoryStep.conditionStepConfiguration.stepIdentifier
                                                                                           formItemIdentifier:familyHistoryStep.conditionStepConfiguration.conditionsFormItemIdentifier
                                                                                          conditionsKeyValues:[self _getConditionsListTextAndValuesWithFxHStep:familyHistoryStep]];
                    if (conditionValues.count == 0) {
                        conditionValues = @[ORKILocalizedString(@"READ_ONLY_VIEW_NO_ANSWER", @"")];
                    }
                    
                    ORKReviewCardItem *conditionListReviewCardItem = [[ORKReviewCardItem alloc] initWithTitle:ORKILocalizedString(@"FAMILY_HISTORY_CONDITIONS", @"") resultValues:conditionValues];
                    
                    ORKReviewCard *reviewCard = [[ORKReviewCard alloc] initWithReviewCardItems:@[detailListReviewCardItem, conditionListReviewCardItem]];
                    [reviewCards addObject:reviewCard];
                }
            }
            
            ORKReviewCardSection *reviewCardSection = [[ORKReviewCardSection alloc] initWithTitle:relativeGroup.sectionTitle reviewCards:reviewCards];
            [reviewCardSections addObject:reviewCardSection];
        }
        
    }
    
    return reviewCardSections;
}

- (void)_populateAgeQuestionValuesForRelatedPerson:(ORKRelatedPerson *)relatedPerson relativeGroup:(ORKRelativeGroup *)relativeGroup {
    for (ORKFormStep *formStep in relativeGroup.formSteps) {
        for (ORKFormItem *formItem in formStep.formItems) {
            if ([formItem.answerFormat isKindOfClass:[ORKAgeAnswerFormat class]]) {
                ORKAgeAnswerFormat *ageAnswerFormat = (ORKAgeAnswerFormat *)formItem.answerFormat;
                // if this condition passes we should be confident that we're dealing with the correct ageAnswerFormat
                if (ageAnswerFormat.minimumAgeCustomText != nil && ageAnswerFormat.maximumAgeCustomText != nil && ageAnswerFormat.treatMinAgeAsRange) {
                    [relatedPerson setAgeAnswerFormat:[ageAnswerFormat copy] ageFormItemIdentifier:[formItem.identifier copy]];
                }
            }
        }
    }
}

- (NSDictionary<NSString *, NSDictionary<NSString *, NSString *> *> *)_getDetailInfoTextAndValuesForRelativeGroup:(ORKRelativeGroup *)relativeGroup {
    NSMutableDictionary<NSString *, NSMutableDictionary<NSString *, NSString *> *> *detailInfoTextAndValues = [NSMutableDictionary new];
    
    // parse all formSteps of the relativeGroup and check if any of its formItems are a choice type. If yes, we'll need to grab the text values from the textChoices for presentation in the tableView as opposed to presenting the value of the formItem
    for (ORKFormStep *formStep in relativeGroup.formSteps) {
        for (ORKFormItem *formItem in formStep.formItems) {
            for (NSString *identifier in relativeGroup.detailTextIdentifiers) {
                if ([identifier isEqual:formItem.identifier]) {
                    detailInfoTextAndValues[identifier] = [NSMutableDictionary new];
                    
                    // check if formItem.answerFormat is of type ORKTextChoiceAnswerFormat, ORKTextScaleAnswerFormat, or ORKValuePickerAnswerFormat
                    NSArray<ORKTextChoice *> *textChoices = [NSArray new];
                    
                    if ([formItem.answerFormat isKindOfClass:[ORKTextChoiceAnswerFormat class]]) {
                        ORKTextChoiceAnswerFormat *textChoiceAnswerFormat = (ORKTextChoiceAnswerFormat *)formItem.answerFormat;
                        textChoices = textChoiceAnswerFormat.textChoices;
                    } else if ([formItem.answerFormat isKindOfClass:[ORKTextScaleAnswerFormat class]]) {
                        ORKTextScaleAnswerFormat *textScaleAnswerFormat = (ORKTextScaleAnswerFormat *)formItem.answerFormat;
                        textChoices = textScaleAnswerFormat.textChoices;
                    } else if ([formItem.answerFormat isKindOfClass:[ORKValuePickerAnswerFormat class]]) {
                        ORKValuePickerAnswerFormat *valuePickerAnswerFormat = (ORKValuePickerAnswerFormat *)formItem.answerFormat;
                        textChoices = valuePickerAnswerFormat.textChoices;
                    }
                    
                    for (ORKTextChoice *textChoice in textChoices) {
                        if ([textChoice.value isKindOfClass:[NSString class]]) {
                            NSString *stringValue = (NSString *)textChoice.value;
                            detailInfoTextAndValues[identifier][stringValue] = textChoice.text;
                        }
                    }
                }
            }
        }
    }
    
    return [detailInfoTextAndValues copy];
}

- (NSMutableDictionary<NSString *, NSString *> *)_getConditionsListTextAndValuesWithFxHStep:(ORKFamilyHistoryStep *)familyHistoryStep {
    NSMutableDictionary<NSString *, NSString *> *conditionsTextAndValues = [NSMutableDictionary new];
    
    for (ORKHealthCondition *healthCondition in familyHistoryStep.conditionStepConfiguration.conditions) {
        conditionsTextAndValues[(NSString *)healthCondition.value] = healthCondition.displayName;
    }
    
    conditionsTextAndValues[ORKHealthConditionNoneOfTheAboveChoice] = ORKILocalizedString(@"FAMILY_HISTORY_NONE_OF_THE_ABOVE", @"");
    conditionsTextAndValues[ORKHealthConditionIDontKnowChoice] = ORKILocalizedString(@"FAMILY_HISTORY_I_DONT_KNOW", @"");
    conditionsTextAndValues[ORKHealthConditionPreferNotToAnswerChoice] = ORKILocalizedString(@"FAMILY_HISTORY_PREFER_NOT_TO_ANSWER", @"");
    
    return conditionsTextAndValues;
}

@end
