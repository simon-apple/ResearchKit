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

#import "ORKFamilyHistoryStepViewController.h"

#import "ORKConditionStepConfiguration.h"
#import "ORKCompletionStep.h"
#import "ORKFamilyHistoryResult.h"
#import "ORKFamilyHistoryStep.h"
#import "ORKFormStep.h"
#import "ORKHealthCondition.h"
#import "ORKRelatedPerson.h"
#import "ORKRelativeGroup.h"

#import "ORKAnswerFormat.h"
#import "ORKNavigableOrderedTask.h"

#import "ORKStepContentView.h"
#import "ORKStepHeaderView_Internal.h"
#import "ORKTableContainerView.h"

#import "ORKNavigationContainerView_Internal.h"
#import "ORKStepViewController_Internal.h"
#import "ORKTaskViewController_Internal.h"

#import "ORKAnswerFormat_Internal.h"
#import "ORKCollectionResult_Private.h"
#import "ORKResult_Private.h"
#import "ORKStep_Private.h"
#import "ORKQuestionResult.h"

#import "ORKSkin.h"
#import "ORKHelpers_Internal.h"

NSString * const RelatedPersonCompletionStepIdentifier = @"RelatedPersonCompletionStepIdentifier";
NSString * const TablViewCellIdentifier = @"cell";

@interface ORKFamilyHistoryStepViewController () <ORKTableContainerViewDelegate, ORKTaskViewControllerDelegate, UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) ORKTableContainerView *tableContainer;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) ORKStepContentView *headerView;

@end

@implementation ORKFamilyHistoryStepViewController {
    NSArray<NSLayoutConstraint *> *_constraints;
    
    NSArray<ORKRelativeGroup *> *_relativeGroups;
    NSArray<ORKNavigableOrderedTask *> *_relativeGroupOrderedTasks;
    
    NSMutableArray<ORKRelatedPerson *> *_relatedPersons;
    NSMutableArray<NSString *> *_displayedConditions;
    
    NSArray<NSString *> *_conditionsWithinCurrentTask;
}

- (instancetype)ORKFamilyHistoryStepViewController_initWithResult:(ORKResult *)result {
   // TODO: HANDLE RESULT: rdar://108142925 (family history step should restore state from ongoingResult)
    return self;
}

- (instancetype)initWithStep:(ORKStep *)step {
    self = [super initWithStep:step];
    return [self ORKFamilyHistoryStepViewController_initWithResult:nil];
}

- (instancetype)initWithStep:(ORKStep *)step result:(ORKResult *)result {
    self = [super initWithStep:step];
    return [self ORKFamilyHistoryStepViewController_initWithResult:result];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self stepDidChange];
    
    _relatedPersons = [NSMutableArray new];
    _displayedConditions = [NSMutableArray new];
    
    _relativeGroups = [[self familyHistoryStep].relativeGroups copy];
    
    [self configureOrderedTasks];
}

- (void)stepDidChange {
    [super stepDidChange];
    
    [_tableContainer removeFromSuperview];
    _tableContainer = nil;
    
    if (self.isViewLoaded && self.step) {
        _tableContainer = [[ORKTableContainerView alloc] initWithStyle:UITableViewStyleGrouped pinNavigationContainer:NO];
        _tableContainer.tableContainerDelegate = self;
        [self.view addSubview:_tableContainer];
        _tableContainer.tapOffView = self.view;
        
        _tableView = _tableContainer.tableView;
        [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:TablViewCellIdentifier];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.clipsToBounds = YES;
        _tableView.rowHeight = UITableViewAutomaticDimension;
        _tableView.sectionHeaderHeight = UITableViewAutomaticDimension;
        _tableView.estimatedRowHeight = ORKGetMetricForWindow(ORKScreenMetricTableCellDefaultHeight, self.view.window);
        _tableView.estimatedSectionHeaderHeight = 30.0;
        
        _headerView = _tableContainer.stepContentView;
        _headerView.stepTopContentImage = self.step.image;
        _headerView.titleIconImage = self.step.iconImage;
        _headerView.stepTitle = self.step.title;
        _headerView.stepText = self.step.text;
        _headerView.stepDetailText = self.step.detailText;
        _headerView.stepHeaderTextAlignment = self.step.headerTextAlignment;
        _headerView.bodyItems = self.step.bodyItems;
        _tableContainer.stepTopContentImageContentMode = self.step.imageContentMode;
        
        _navigationFooterView = _tableContainer.navigationFooterView;
        _navigationFooterView.skipButtonItem = self.skipButtonItem;
        _navigationFooterView.continueEnabled = YES;
        _navigationFooterView.continueButtonItem = self.continueButtonItem;
        _navigationFooterView.optional = self.step.optional;
        
        [_navigationFooterView removeStyling];
        
        [self setupConstraints];
        [_tableContainer setNeedsLayout];
    }
}

- (void)setupConstraints {
    
    if (_constraints) {
        [NSLayoutConstraint deactivateConstraints:_constraints];
    }
    _tableContainer.translatesAutoresizingMaskIntoConstraints = NO;
    _constraints = nil;

    
    _constraints = @[
                     [NSLayoutConstraint constraintWithItem:_tableContainer
                                                  attribute:NSLayoutAttributeTop
                                                  relatedBy:NSLayoutRelationEqual
                                                     toItem:self.view
                                                  attribute:NSLayoutAttributeTop
                                                 multiplier:1.0
                                                   constant:0.0],
                     [NSLayoutConstraint constraintWithItem:_tableContainer
                                                  attribute:NSLayoutAttributeLeft
                                                  relatedBy:NSLayoutRelationEqual
                                                     toItem:self.view
                                                  attribute:NSLayoutAttributeLeft
                                                 multiplier:1.0
                                                   constant:0.0],
                     [NSLayoutConstraint constraintWithItem:_tableContainer
                                                  attribute:NSLayoutAttributeRight
                                                  relatedBy:NSLayoutRelationEqual
                                                     toItem:self.view
                                                  attribute:NSLayoutAttributeRight
                                                 multiplier:1.0
                                                   constant:0.0],
                     [NSLayoutConstraint constraintWithItem:_tableContainer
                                                  attribute:NSLayoutAttributeBottom
                                                  relatedBy:NSLayoutRelationEqual
                                                     toItem:self.view
                                                  attribute:NSLayoutAttributeBottom
                                                 multiplier:1.0
                                                   constant:0.0]
                     ];
    [NSLayoutConstraint activateConstraints:_constraints];
    
}

- (ORKFamilyHistoryStep *)familyHistoryStep {
    ORKFamilyHistoryStep *step = ORKDynamicCast(self.step, ORKFamilyHistoryStep);
    
    if (step == nil) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"the ORKFamilyHistoryStepViewController must be presented with a ORKFamilyHistoryStep"  userInfo:nil];
    }
    
    return step;
}

- (void)configureOrderedTasks {
    NSMutableArray<ORKNavigableOrderedTask *> *relativeGroupOrderedTasks = [NSMutableArray new];
    
    ORKFamilyHistoryStep *step = [self familyHistoryStep];
    
    for (ORKRelativeGroup *relativeGroup in step.relativeGroups) {
        NSMutableArray<ORKStep *> *steps = [NSMutableArray array];
        
        // add formSteps from ORKRelativeGroup to steps array
        
        for (ORKFormStep *formStep in relativeGroup.formSteps) {
            [steps addObject:[formStep copy]];
        }
        
        // configure and add health condition formStep to steps array
        
        NSMutableArray<ORKFormItem *> *formItems = [NSMutableArray new];
        
        ORKTextChoiceAnswerFormat *textChoiceAnswerFormat = [self makeConditionsTextChoiceAnswerFormat:[step.conditionStepConfiguration.conditions copy]];
        ORKFormItem *healthConditionsFormItem = [[ORKFormItem alloc] initWithIdentifier:step.conditionStepConfiguration.conditionsFormItemIdentifier
                                                                                   text:ORKLocalizedString(@"FAMILY_HISTORY_CONDITIONS_FORM_ITEM_TEXT", "")
                                                                           answerFormat:textChoiceAnswerFormat];
        
        [formItems addObject:healthConditionsFormItem];
        [formItems addObjectsFromArray:step.conditionStepConfiguration.formItems];
        
        ORKFormStep *conditionFormStep = [[ORKFormStep alloc] initWithIdentifier:step.conditionStepConfiguration.stepIdentifier];
        conditionFormStep.title = ORKLocalizedString(@"FAMILY_HISTORY_CONDITIONS_STEP_TITLE", "");
        conditionFormStep.detailText = ORKLocalizedString(@"FAMILY_HISTORY_CONDITIONS_STEP_DESCRIPTION", "");
        conditionFormStep.optional = NO;
        conditionFormStep.formItems = [formItems copy];
        
        [steps addObject:conditionFormStep];
        
        ORKCompletionStep *completionStep = [[ORKCompletionStep alloc] initWithIdentifier:RelatedPersonCompletionStepIdentifier];
        completionStep.title = ORKLocalizedString(@"FAMILY_HISTORY_COMPLETION_STEP_TITLE", "");
        
        [steps addObject:completionStep];
        
        ORKNavigableOrderedTask *orderedTask = [[ORKNavigableOrderedTask alloc] initWithIdentifier:relativeGroup.identifier steps:steps];
        [relativeGroupOrderedTasks addObject:orderedTask];
    }
    
    _relativeGroupOrderedTasks = [relativeGroupOrderedTasks copy];
}

- (ORKTextChoiceAnswerFormat *)makeConditionsTextChoiceAnswerFormat:(NSArray<ORKHealthCondition *> *)healthConditions {
    NSMutableArray<NSString *> *conditionsWithinCurrentTask = _conditionsWithinCurrentTask ? [_conditionsWithinCurrentTask mutableCopy] : [NSMutableArray new];
    
    NSMutableArray<ORKTextChoice *> *textChoices = [NSMutableArray new];
    for (ORKHealthCondition *healthCondition in healthConditions) {
        
        if (![conditionsWithinCurrentTask containsObject:healthCondition.identifier]) {
            [conditionsWithinCurrentTask addObject:healthCondition.identifier];
        }
        
        ORKTextChoice *textChoice = [[ORKTextChoice alloc] initWithText:healthCondition.displayName
                                                             detailText:nil
                                                                  value:healthCondition.value
                                                              exclusive:NO];
        
        [textChoices addObject:textChoice];
    }
    
    _conditionsWithinCurrentTask = [conditionsWithinCurrentTask copy];
    
    ORKTextChoice *noneOfTheAboveTextChoice = [[ORKTextChoice alloc] initWithText:ORKLocalizedString(@"FAMILY_HISTORY_NONE_OF_THE_ABOVE", "")
                                                         detailText:nil
                                                              value:[NSNumber numberWithLong:textChoices.count + 1]
                                                          exclusive:NO];
    
    ORKTextChoice *idkTextChoice = [[ORKTextChoice alloc] initWithText:ORKLocalizedString(@"SLIDER_I_DONT_KNOW", "")
                                                         detailText:nil
                                                              value:[NSNumber numberWithLong:textChoices.count + 2]
                                                          exclusive:NO];
    
    ORKTextChoice *preferNotToAnswerTextChoice = [[ORKTextChoice alloc] initWithText:ORKLocalizedString(@"FAMILY_HISTORY_PREFER_NOT_TO_ANSWER", "")
                                                         detailText:nil
                                                              value:[NSNumber numberWithLong:textChoices.count + 3]
                                                          exclusive:NO];
    
    [textChoices addObject:noneOfTheAboveTextChoice];
    [textChoices addObject:idkTextChoice];
    [textChoices addObject:preferNotToAnswerTextChoice];
    
    ORKTextChoiceAnswerFormat *textChoiceAnswerFormat = [[ORKTextChoiceAnswerFormat alloc] initWithStyle:ORKChoiceAnswerStyleMultipleChoice
                                                                                             textChoices:textChoices];
    
    return textChoiceAnswerFormat;
}

- (void)presentNewOrderedTaskForRelativeGroup:(ORKRelativeGroup *)relativeGroup {
    ORKNavigableOrderedTask *taskToPresent;
    
    for (ORKNavigableOrderedTask *orderedTask in _relativeGroupOrderedTasks) {
        if (orderedTask.identifier == relativeGroup.identifier) {
            taskToPresent = orderedTask;
            break;
        }
    }
    
    if (taskToPresent == nil) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:[NSString stringWithFormat:@"An orderedTask was not found for relative group `%@`", relativeGroup.name]  userInfo:nil];
    }
    
    ORKTaskViewController *taskViewController = [[ORKTaskViewController alloc] initWithTask:taskToPresent taskRunUUID:nil];
    taskViewController.delegate = self;
    
    [self presentViewController:taskViewController animated:YES completion:^{}];
}

- (void)handleRelatedPersonTaskResult:(ORKTaskResult *)taskResult taskIdentifier:(NSString *)identifier {
    ORKFamilyHistoryStep *familyHistoryStep = [self familyHistoryStep];
    
    for (ORKRelativeGroup *relativeGroup in familyHistoryStep.relativeGroups) {
        if (relativeGroup.identifier == identifier) {
            ORKRelatedPerson *relatedPerson = [[ORKRelatedPerson alloc] initWithIdentifier:[NSUUID new].UUIDString
                                                                           groupIdentifier:identifier
                                                                                taskResult:taskResult];
            
            [_relatedPersons addObject:relatedPerson];
            break;
        }
    }
}

- (void)updateDisplayedConditionsFromTaskResult:(ORKTaskResult *)taskResult {
    ORKFamilyHistoryStep *step = [self familyHistoryStep];
    
    ORKStepResult *stepResult = (ORKStepResult *)[taskResult resultForIdentifier:step.conditionStepConfiguration.stepIdentifier];
    
    // if stepResult is nil, then choiceQuestionResult will also be nil here
    ORKChoiceQuestionResult *choiceQuestionResult = (ORKChoiceQuestionResult *)[stepResult resultForIdentifier:step.conditionStepConfiguration.conditionsFormItemIdentifier];

    // if choiceQuestionResult is nil, then choiceQuestionResult.choiceAnswers is nil
    NSArray<NSString *> *conditionsIdentifiers = choiceQuestionResult.choiceAnswers != nil ? _conditionsWithinCurrentTask : nil;
    
     for (NSString *conditionIdentifier in conditionsIdentifiers) {
          if (![_displayedConditions containsObject:conditionIdentifier]) {
            [_displayedConditions addObject:conditionIdentifier];
        }
    }
        
}

- (BOOL)didReachMaxForRelativeGroup:(ORKRelativeGroup *)relativeGroup {
    int numberOfSavedRelatives = 0;
    
    for (ORKRelatedPerson *relatedPerson in _relatedPersons) {
        if (relatedPerson.groupIdentifier == relativeGroup.identifier) {
            numberOfSavedRelatives += 1;
        }
    }
    
    return numberOfSavedRelatives >= relativeGroup.maxAllowed;
}

- (ORKStepResult *)result {
    ORKStepResult *stepResult = [super result];
    
    NSMutableArray *results = [NSMutableArray arrayWithArray:stepResult.results];
    ORKFamilyHistoryResult *familyHistoryResult = [[ORKFamilyHistoryResult alloc] initWithIdentifier:[self step].identifier];
    familyHistoryResult.startDate = stepResult.startDate;
    familyHistoryResult.endDate = stepResult.endDate;
    familyHistoryResult.relatedPersons = _relatedPersons;
    familyHistoryResult.displayedConditions = _displayedConditions;
    [results addObject:familyHistoryResult];

    stepResult.results = [results copy];
    
    return stepResult;
}

- (nonnull UITableViewCell *)currentFirstResponderCellForTableContainerView:(nonnull ORKTableContainerView *)tableContainerView {
    return [UITableViewCell new];
}

- (void)taskViewController:(ORKTaskViewController *)taskViewController didFinishWithReason:(ORKTaskViewControllerFinishReason)reason error:(NSError *)error {
    [self dismissViewControllerAnimated:YES completion:^{
        switch (reason) {
            case ORKTaskViewControllerFinishReasonFailed:
            case ORKTaskViewControllerFinishReasonDiscarded:
                break;
            case ORKTaskViewControllerFinishReasonSaved:
            case ORKTaskViewControllerFinishReasonCompleted:
            case ORKTaskViewControllerFinishReasonEarlyTermination:
                [self handleRelatedPersonTaskResult:taskViewController.result taskIdentifier:taskViewController.task.identifier];
                [self updateDisplayedConditionsFromTaskResult:taskViewController.result];
                break;
        }
    }];
}

#pragma mark UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self familyHistoryStep].relativeGroups.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *identifier = TablViewCellIdentifier;
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    ORKRelativeGroup *relativeGroup = _relativeGroups[indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"Tap to add new %@", relativeGroup.name];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    return cell;
}

#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    ORKRelativeGroup *selectedRelativeGroup = _relativeGroups[indexPath.row];
    
    if (![self didReachMaxForRelativeGroup:selectedRelativeGroup]) {
        [self presentNewOrderedTaskForRelativeGroup:selectedRelativeGroup];
    } else {
        NSString *msg = [NSString stringWithFormat:@"The %@ relative group can only save %ld related persons", selectedRelativeGroup.name, (long)selectedRelativeGroup.maxAllowed];
        UIAlertController *alertvc = [UIAlertController alertControllerWithTitle:@"Max Reached" message:msg preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction * action = [UIAlertAction actionWithTitle: @"Dismiss" style: UIAlertActionStyleDefault handler:nil];
        [alertvc addAction: action];
        
        [self presentViewController: alertvc animated: true completion: nil];
    }
}

@end
