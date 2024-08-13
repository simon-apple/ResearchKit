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

#import "ORKFamilyHistoryReviewController.h"

#import <ResearchKit/ORKCollectionResult_Private.h>
#import <ResearchKit/ORKFamilyHistoryResult.h>
#import <ResearchKit/ORKFamilyHistoryStep.h>
#import <ResearchKit/ORKHelpers_Internal.h>
#import <ResearchKit/ORKNavigableOrderedTask.h>
#import <ResearchKit/ORKRelatedPerson.h>
#import <ResearchKit/ORKSkin.h>

#import <ResearchKitUI/ORKFamilyHistoryRelatedPersonCell.h>
#import <ResearchKitUI/ORKFamilyHistoryTableFooterView.h>
#import <ResearchKitUI/ORKStepViewController_Internal.h>
#import <ResearchKitUI/ORKReviewIncompleteCell.h>
#import <ResearchkitUI/ORKTableContainerView.h>
#import <ResearchKitUI/ORKTaskViewController_Internal.h>

#import <ResearchKitInternal/ResearchKitInternal.h>


@interface ORKFamilyHistoryReviewController (ORKFamilyHistoryReviewSupport)

@property (nonatomic, strong) ORKTableContainerView *tableContainer;

@end

@implementation ORKFamilyHistoryReviewController {
    BOOL _isCompleted;
    NSString *_incompleteText;
    id<ORKTaskResultSource> _previousTaskResult;
}

- (instancetype)initWithTask:(ORKOrderedTask *)task
                      result:(ORKTaskResult *)result
                    delegate:(id<ORKFamilyHistoryReviewControllerDelegate>)delegate {
    
    for (ORKStep *step in task.steps) {
        if ([step isKindOfClass:[ORKFamilyHistoryStep class]]) {
            
            ORKStepResult *stepResult = (ORKStepResult *)[result resultForIdentifier:step.identifier];

            if (stepResult) {
                self = [self initWithStep:step result:stepResult];
                
                if (self) {
                    _isCompleted = YES;
                    _reviewDelegate = delegate;
                    _previousTaskResult = result;
                }
                
                return self;
            } else {
                @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"No ORKStepResult was found for the ORKFamilyHistoryStep provided"  userInfo:nil];
            }
        }
    }
    
    @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"The ORKOrderedTask provided must contain a ORKFamilyHistoryStep"  userInfo:nil];
}

- (instancetype)initWithTask:(ORKNavigableOrderedTask *)task
                    delegate:(id<ORKFamilyHistoryReviewControllerDelegate>)delegate
                 isCompleted:(BOOL)isCompleted
              incompleteText:(NSString *)incompleteText {
    
    for (ORKStep *step in task.steps) {
        if ([step isKindOfClass:[ORKFamilyHistoryStep class]]) {
            self = [self initWithStep:step];
            
            if (self) {
                _isCompleted = isCompleted;
                _incompleteText = [incompleteText copy];
                _reviewDelegate = delegate;
            }
            
            return self;
        }
    }
    
    @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"The task provided must contain a ORKFamilyHistoryStep"  userInfo:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
  
    // tab bars will cover up the last cell of the tableview, need to update the edgesForExtendedLayout
    // and the contentInset to use the height of the tabBar
    if (self.tabBarController) {
        self.edgesForExtendedLayout = UIRectEdgeAll;
        self.tableContainer.tableView.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, CGRectGetHeight(self.tabBarController.tabBar.frame), 0.0f);
    }
}

- (void)setText:(NSString *)text {
    self.step.text = text;
    [self.tableContainer sizeHeaderToFit];
    [self stepDidChange];
}

- (nullable NSString *)reviewTitle {
    return self.step.title;
}

- (void)setReviewTitle:(nullable NSString *)reviewTitle {
    self.step.title = reviewTitle;
}

- (void)updateViewColors {
    UIColor *updateColor = [UIColor systemGroupedBackgroundColor];
    self.view.backgroundColor = updateColor;
    self.tableContainer.tableView.backgroundColor = updateColor;
}

- (void)setupFooterViewIfNeeded {
    // We don't need the footer button for the review view
    [self.tableContainer removeFooterView];
}

- (void)resultUpdated {
    ORKStepResult *stepResult = [self result];
    
    ORKTaskResult *resultToUpdate = [ORKDynamicCast(_previousTaskResult, ORKTaskResult) copy];
    
    NSMutableArray<ORKResult *> *results = [NSMutableArray new];
    
    for (ORKResult *result in resultToUpdate.results) {
        [results addObject:result];
    }
    
    NSUInteger index = 0;
    for (ORKResult *result in resultToUpdate.results) {
        if ([result.identifier isEqual:stepResult.identifier]) {
            [results replaceObjectAtIndex:index withObject:stepResult];
            resultToUpdate.results = (NSArray<ORKResult *> *)results;
            break;
        }
        index += 1;
    }
    
    if (_reviewDelegate && [_reviewDelegate respondsToSelector:@selector(familyHistoryReviewController:didUpdateResult:source:)]) {
        ORKTaskResult *taskResult = ORKDynamicCast(_previousTaskResult, ORKTaskResult);
        [_reviewDelegate familyHistoryReviewController:self didUpdateResult:resultToUpdate source:taskResult];
    }
}

- (void)updateResultSource:(ORKTaskResult *)taskResult {
    _isCompleted = YES;
    _previousTaskResult = taskResult;
    
    ORKFamilyHistoryResult* familyHistoryResult;
    
    for (ORKStepResult *result in taskResult.results) {
        familyHistoryResult = (ORKFamilyHistoryResult *)result.firstResult;
        if (familyHistoryResult) {
            break;
        }
    }
    
    if (familyHistoryResult == nil) {
        ORK_Log_Debug("Result must include a ORKFamilyHistoryResult.");
        return;
    }
    
    for (ORKRelatedPerson* person in familyHistoryResult.relatedPersons) {
        ORKTaskResult* result = [person taskResult];
        [self handleRelatedPersonTaskResult:result taskIdentifier:[result identifier]];
        [self updateDisplayedConditionsFromTaskResult:result];
    }
}

- (nonnull UITableViewCell *)currentFirstResponderCellForTableContainerView:(nonnull ORKTableContainerView *)tableContainerView {
    return [UITableViewCell new];
}


#pragma mark UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return !_isCompleted ? 1 : [super numberOfSectionsInTableView: tableView];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return !_isCompleted ? 1 : [super numberOfRowsForRelativeGroupInSection:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (!_isCompleted) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
        
        if (cell == nil || ![cell isKindOfClass:ORKReviewIncompleteCell.class]) {
            ORKReviewIncompleteCell *reviewIncompleteCell = [[ORKReviewIncompleteCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"incompleteCell"];
            reviewIncompleteCell.text = _incompleteText;
            reviewIncompleteCell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell = reviewIncompleteCell;
            return cell;
        }
    }
    
    return [super tableView:tableView cellForRowAtIndexPath:indexPath];
}


#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (!_isCompleted) {
        if (_reviewDelegate && [_reviewDelegate respondsToSelector:@selector(familyHistoryReviewControllerDidSelectIncompleteCell:)]) {
            [_reviewDelegate familyHistoryReviewControllerDidSelectIncompleteCell:self];
        }
        return;
    }
    
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return !_isCompleted ? 0 : UITableViewAutomaticDimension;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (!_isCompleted) {
        return nil;
    }
    
    return [super tableView:tableView viewForHeaderInSection:section];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (!_isCompleted) {
        return 0;
    }
    
    return [super tableView:tableView heightForFooterInSection:section];
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    return !_isCompleted;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    if (!_isCompleted) {
        return nil;
    }
    
    return [super tableView:tableView viewForFooterInSection:section];
}

@end
