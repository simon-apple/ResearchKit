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
#import "ORKReviewCardTableHeaderView.h"
#import "ORKReviewCardTableViewCell.h"
#import "ORKReviewResultModel.h"

#import <ResearchKit/ORKCollectionResult.h>
#import <ResearchKit/ORKFormStep.h>
#import <ResearchKit/ORKHelpers_Internal.h>
#import <ResearchKit/ORKOrderedTask.h>
#import <ResearchKit/ORKQuestionStep.h>
#import <ResearchKit/ORKSkin.h>
#import <ResearchKit/ORKStep.h>

#import <ResearchKitUI/ORKStepContainerView_Private.h>
#import <ResearchKitUI/ORKStepContentView.h>
#import <ResearchKitUI/ORKTableContainerView.h>

NSString * const ORKReviewCardTableViewCellIdentifier = @"ORKReviewCardTableViewCellIdentifier";

double const TableViewSectionHeaderHeight = 30.0;


@interface ORKReadOnlyReviewViewController () <UITableViewDelegate, UITableViewDataSource>

@end


@implementation ORKReadOnlyReviewViewController {
    NSArray<NSLayoutConstraint *> *_constraints;
    
    NSString *_title;
    NSString *_detailText;
    NSString *_navTitle;
    
    ORKTableContainerView *_tableContainerView;
    UITableView *_tableView;
    
    ORKOrderedTask *_orderedTask;
    ORKTaskResult *_taskResult;
    ORKReadOnlyStepType _readOnlyStepType;
    
    NSArray<ORKStep *> *_stepsToParse;
    NSArray<ORKReviewCardSection *> *_reviewCardSections;
}


#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-designated-initializers"
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    ORKThrowMethodUnavailableException();
}
#pragma clang diagnostic pop

- (instancetype)initWithTask:(nonnull ORKOrderedTask *)task
                              result:(nonnull ORKTaskResult *)result
                    readOnlyStepType:(ORKReadOnlyStepType)readOnlyStepType
                               title:(nullable NSString *)title
                          detailText:(nullable NSString *)detailText
                            navTitle:(nullable NSString *)navTitle {
    self = [super initWithNibName:nil bundle:nil];
    
    if (self) {
        _orderedTask = [task copy];
        _taskResult = [result copy];
        _readOnlyStepType = readOnlyStepType;
        _title = [title copy];
        _detailText = [detailText copy];
        _navTitle = [navTitle copy];
        
        _stepsToParse = [self _getStepsToParseForResults];
        _reviewCardSections = [self _getReviewCardSections];
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeNever;
    self.navigationItem.title = _navTitle;
    
    [self _setupTableContainerView];
    [self _setupTableView];
    [self _setupConstraints];
    [self _updateViewColors];
    
    [_tableView reloadData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [_tableView reloadData];
}

- (void)_setupTableContainerView {
    if (!_tableContainerView) {
        _tableContainerView = [[ORKTableContainerView alloc] initWithStyle:UITableViewStyleGrouped pinNavigationContainer:NO];
        _tableContainerView.stepContentView.stepTitle = _title;
        _tableContainerView.stepContentView.stepText = _detailText;
        _tableContainerView.stepContentView.stepHeaderTextAlignment = NSTextAlignmentLeft;
        _tableContainerView.translatesAutoresizingMaskIntoConstraints = NO;
        [_tableContainerView removeFooterView];
        
        [self.view addSubview:_tableContainerView];
    }
    
}

- (void)_setupTableView {
    if (!_tableView) {
        _tableView = _tableContainerView.tableView;
        _tableView.translatesAutoresizingMaskIntoConstraints = NO;
        [_tableView registerClass:[ORKReviewCardTableViewCell class] forCellReuseIdentifier:ORKReviewCardTableViewCellIdentifier];
        _tableView.separatorColor = [UIColor clearColor];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.clipsToBounds = YES;
        _tableView.rowHeight = UITableViewAutomaticDimension;
        _tableView.sectionHeaderHeight = UITableViewAutomaticDimension;
        _tableView.estimatedRowHeight = ORKGetMetricForWindow(ORKScreenMetricTableCellDefaultHeight, self.view.window);
        _tableView.estimatedSectionHeaderHeight = TableViewSectionHeaderHeight;
    }
}

- (void)_setupConstraints {
    if (_constraints) {
        [NSLayoutConstraint deactivateConstraints:_constraints];
    }

    _constraints = @[
        [_tableContainerView.topAnchor constraintEqualToAnchor:self.view.topAnchor],
        [_tableContainerView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [_tableContainerView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [_tableContainerView.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor]
    ];
    
    [NSLayoutConstraint activateConstraints:_constraints];
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    [super traitCollectionDidChange:previousTraitCollection];
    [self _updateViewColors];
}

- (void)_updateViewColors {
    UIColor *updateColor = [UIColor systemBackgroundColor];
    self.view.backgroundColor = updateColor;
    _tableView.backgroundColor = updateColor;
    [self _updateNavBarBackgroundColor: updateColor];
}

- (void)_updateNavBarBackgroundColor:(UIColor *)color {
    UINavigationBarAppearance *appearance = [UINavigationBarAppearance new];
    [appearance configureWithOpaqueBackground];
    appearance.backgroundColor = color;
    appearance.shadowImage = [UIImage new];
    appearance.shadowColor = [UIColor clearColor];
    
    self.navigationController.navigationBar.scrollEdgeAppearance = appearance;
    self.navigationController.navigationBar.compactAppearance = appearance;
    self.navigationController.navigationBar.standardAppearance = appearance;
    
    if (@available(iOS 15.0, *)) {
        self.navigationController.navigationBar.compactScrollEdgeAppearance = appearance;
    }
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
    NSMutableArray *filteredSurveySteps = [NSMutableArray new];
    
    NSString *formStepClassString = NSStringFromClass([ORKFormStep class]);
    NSString *questionStepClassString = NSStringFromClass([ORKQuestionStep class]);
    
    for (ORKStep *step in _orderedTask.steps) {
        if ([NSStringFromClass([step class]) isEqualToString:formStepClassString] || [NSStringFromClass([step class]) isEqualToString:questionStepClassString]) {
            [filteredSurveySteps addObject:step];
        }
    }
    
    return filteredSurveySteps;
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
            return [ORKReviewResultModel getReviewCardSectionsWithSurveySteps:_stepsToParse taskResult:_taskResult];
            break;
            
        case ORKReadOnlyStepTypeFamilyHistoryStep:
            return [ORKReviewResultModel getReviewCardSectionsWithFamilyHistorySteps:[self _getCastedFamilyHistorySteps] taskResult:_taskResult];
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

- (NSArray<ORKFamilyHistoryStep *> *)_getCastedFamilyHistorySteps {
    NSArray<ORKFamilyHistoryStep *> *fxhSteps = (NSArray<ORKFamilyHistoryStep *> *)_stepsToParse;
    
    if (!fxhSteps) {
        @throw [NSException exceptionWithName:NSGenericException reason:@"Failed to cast collected steps to ORKFamilyHistorySteps" userInfo:nil];
    }
    
    return fxhSteps;
}

#pragma mark UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _reviewCardSections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    ORKReviewCardSection *reviewCardSection = [_reviewCardSections objectAtIndex:section];
    return reviewCardSection.reviewCards.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ORKReviewCardSection *reviewCardSection = [_reviewCardSections objectAtIndex:indexPath.section];
    ORKReviewCard *reviewCard = [reviewCardSection.reviewCards objectAtIndex:indexPath.row];
    
    ORKReviewCardTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ORKReviewCardTableViewCellIdentifier];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    [cell configureWithReviewCard:reviewCard];
    
    return cell;
}

#pragma mark UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    ORKReviewCardSection *reviewCardSection = [_reviewCardSections objectAtIndex:section];
    return reviewCardSection.title ? UITableViewAutomaticDimension : 0.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    ORKReviewCardSection *reviewCardSection = _reviewCardSections[section];
    
    if (reviewCardSection.title == nil) {
        return nil;
    }
    
    ORKReviewCardTableHeaderView *headerView = (ORKReviewCardTableHeaderView *)[tableView dequeueReusableHeaderFooterViewWithIdentifier:@(section).stringValue];
    
    if (headerView == nil) {
        headerView = [[ORKReviewCardTableHeaderView alloc] initWithTitle:reviewCardSection.title];
    }
    
    BOOL isExpanded = reviewCardSection.reviewCards.count > 0;
    [headerView setExpanded:isExpanded];
    
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

@end
