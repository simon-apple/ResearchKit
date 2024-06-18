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
#import "ORKReviewCardTableViewCell.h"
#import "ORKReviewResultModel.h"

#import <ResearchKit/ORKCollectionResult.h>
#import <ResearchKit/ORKFormStep.h>
#import <ResearchKit/ORKQuestionStep.h>
#import <ResearchKit/ORKOrderedTask.h>
#import <ResearchKit/ORKSkin.h>
#import <ResearchKit/ORKStep.h>


NSString * const ORKReviewCardTableViewCellIdentifier = @"ORKReviewCardTableViewCellIdentifier";

double const TableViewSectionHeaderHeight = 30.0;


@interface ORKReadOnlyReviewViewController () <UITableViewDelegate, UITableViewDataSource>

@end


@implementation ORKReadOnlyReviewViewController {
    NSArray<NSLayoutConstraint *> *_constraints;
    
    UITableView *_tableView;
    
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
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self _setupTableView];
    [self _setupConstraints];
    [self _updateViewColors];
    
    [_tableView reloadData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [_tableView reloadData];
}

- (void)_setupTableView {
    if (!_tableView) {
        _tableView = [UITableView new];
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
        
        [self.view addSubview:_tableView];
    }
}

- (void)_setupConstraints {
    if (_constraints) {
        [NSLayoutConstraint deactivateConstraints:_constraints];
        _constraints = nil;
    }

    _constraints = @[
        [_tableView.topAnchor constraintEqualToAnchor:self.view.topAnchor],
        [_tableView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [_tableView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [_tableView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor]
    ];
    
    [NSLayoutConstraint activateConstraints:_constraints];
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    [super traitCollectionDidChange:previousTraitCollection];
    [self _updateViewColors];
}

- (void)_updateViewColors {
    UIColor *updateColor =  self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark ? [UIColor systemGray6Color] : [UIColor secondarySystemGroupedBackgroundColor];
    self.view.backgroundColor = updateColor;
    _tableView.backgroundColor = updateColor;
    [self _updateNavBarBackgroundColor: updateColor];
}

- (void)_updateNavBarBackgroundColor:(UIColor *)color {
    UINavigationBarAppearance *appearance = [UINavigationBarAppearance new];
    [appearance configureWithOpaqueBackground];
    appearance.backgroundColor = color;
    //[LC:NOTE] this is needed to hide the divider line per fXH UI Spec
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

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    ORKReviewCardSection *reviewCardSection = [_reviewCardSections objectAtIndex:section];
    return reviewCardSection.title ? UITableViewAutomaticDimension : 0.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

@end
