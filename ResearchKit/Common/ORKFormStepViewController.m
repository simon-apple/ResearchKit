/*
 Copyright (c) 2015, Apple Inc. All rights reserved.
 
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


#import "ORKFormStepViewController.h"

#import "ORKCaption1Label.h"
#import "ORKChoiceViewCell_Internal.h"
#import "ORKFormItemCell.h"
#import "ORKFormSectionTitleLabel.h"
#import "ORKStepHeaderView_Internal.h"
#import "ORKTableContainerView.h"
#import "ORKStepContentView.h"
#import "ORKBodyItem.h"
#import "ORKLearnMoreView.h"

#import "ORKBodyItem.h"
#import "ORKColorChoiceCellGroup.h"
#import "ORKLearnMoreStepViewController.h"
#import "ORKSurveyCardHeaderView.h"
#import "ORKTextChoiceCellGroup.h"

#import "ORKNavigationContainerView_Internal.h"
#import "ORKStepViewController_Internal.h"
#import "ORKTaskViewController_Internal.h"

#import "ORKAnswerFormat_Internal.h"
#import "ORKAnswerFormat+FormStepViewControllerAdditions.h"
#import "ORKCollectionResult_Private.h"
#import "ORKQuestionResult_Private.h"
#import "ORKFormItem_Internal.h"
#import "ORKFormStep_Internal.h"
#import "ORKResult_Private.h"
#import "ORKStep_Private.h"

#import "ORKSESSelectionView.h"
#import "ORKHelpers_Internal.h"
#import "ORKSkin.h"

static const CGFloat TableViewYOffsetStandard = 30.0;
static const NSTimeInterval DelayBeforeAutoScroll = 0.25;

@interface ORKFormItem (FormStepViewControllerExtensions)

- (BOOL)requiresSingleSection;

@end

@interface ORKTableCellItemIdentifier : NSObject <NSCopying>

- (instancetype)initWithFormItemIdentifier:(NSString *)formItemIdentifier choiceIndex:(NSInteger)index;

@property (nonatomic, copy, readonly) NSString *formItemIdentifier;
@property (nonatomic, readonly) NSInteger choiceIndex;

@end

@implementation ORKTableCellItemIdentifier

- (instancetype)initWithFormItemIdentifier:(NSString *)formItemIdentifier choiceIndex:(NSInteger)index {
    self = [super init];
    if (self != nil) {
        _formItemIdentifier = [formItemIdentifier copy];
        _choiceIndex = index;
    }
    return self;
}

- (NSUInteger)hash {
    return _formItemIdentifier.hash ^ _choiceIndex;
}

- (BOOL)isEqual:(id)object {
    if ([self class] != [object class]) {
        return NO;
    }
    
    __typeof(self) castObject = object;
    return (ORKEqualObjects(_formItemIdentifier, castObject->_formItemIdentifier)
            && (_choiceIndex == castObject->_choiceIndex));
}

- (nonnull id)copyWithZone:(nullable NSZone *)zone {
    __typeof(self) copy = [[[self class] alloc] init];
    copy->_formItemIdentifier = [_formItemIdentifier copy];
    copy->_choiceIndex = _choiceIndex;
    return copy;
}

- (NSString *)description {
    NSString *indexString = (_choiceIndex == NSNotFound) ? @"NSNotFound" : @(_choiceIndex).stringValue;
    return [NSString stringWithFormat:@"[%@ '%@', index: %@]", [super description], _formItemIdentifier, indexString];
}

@end

@interface ORKTableCellItem : NSObject

- (instancetype)initWithFormItem:(ORKFormItem *)formItem;
- (instancetype)initWithFormItem:(ORKFormItem *)formItem choiceIndex:(NSUInteger)index;

@property (nonatomic, copy) ORKFormItem *formItem;

@property (nonatomic, copy) ORKAnswerFormat *answerFormat;

@property (nonatomic, readonly) CGFloat labelWidth;

// For choice types only
@property (nonatomic, copy, readonly) ORKTextChoice *choice;

@end


@implementation ORKTableCellItem

- (instancetype)initWithFormItem:(ORKFormItem *)formItem {
    self = [super init];
    if (self) {
        self.formItem = formItem;
         _answerFormat = [[formItem impliedAnswerFormat] copy];
    }
    return self;
}

- (instancetype)initWithFormItem:(ORKFormItem *)formItem choiceIndex:(NSUInteger)index {
    self = [super init];
    if (self) {
        self.formItem = formItem;
        _answerFormat = [[formItem impliedAnswerFormat] copy];
        
        if ([self textChoiceAnswerFormat] != nil) {
            _choice = [self.textChoiceAnswerFormat.textChoices[index] copy];
        }
    }
    return self;
}

- (ORKTextChoiceAnswerFormat *)textChoiceAnswerFormat {
    if ([self.answerFormat isKindOfClass:[ORKTextChoiceAnswerFormat class]]) {
        return (ORKTextChoiceAnswerFormat *)self.answerFormat;
    }
    return nil;
}

- (CGFloat)labelWidth {
    static ORKCaption1Label *sharedLabel;
    
    if (sharedLabel == nil) {
        sharedLabel = [ORKCaption1Label new];
    }
    
    sharedLabel.text = _formItem.text;
    
    return [sharedLabel textRectForBounds:CGRectInfinite limitedToNumberOfLines:1].size.width;
}

@end


@interface ORKTableSection : NSObject

- (instancetype)initWithSectionIndex:(NSUInteger)index;

@property (nonatomic, assign, readonly) NSUInteger index;

@property (nonatomic, copy) NSString *title;

@property (nonatomic, copy, nullable) NSString *detailText;

@property (nonatomic) BOOL showsProgress;

@property (nonatomic, nullable) ORKLearnMoreItem *learnMoreItem;

@property (nonatomic, copy, nullable) NSString *tagText;

// ORKTableCellItem
@property (nonatomic, copy, readonly) NSArray *items;

@property (nonatomic, readonly) BOOL hasChoiceRows;

@property (nonatomic, strong) ORKTextChoiceCellGroup *textChoiceCellGroup;

@property (nonatomic, strong) ORKColorChoiceCellGroup *colorChoiceCellGroup;

- (void)addFormItem:(ORKFormItem *)item;

- (BOOL)containsFormItem:(ORKFormItem *)formItem;

@property (nonatomic, readonly) CGFloat maxLabelWidth;

@end


@implementation ORKTableSection

- (instancetype)initWithSectionIndex:(NSUInteger)index {
    self = [super init];
    if (self) {
        _items = [NSMutableArray new];
        self.title = nil;
        _index = index;
    }
    return self;
}

- (void)setTitle:(NSString *)title {
    _title = title;
}

- (void)addFormItem:(ORKFormItem *)item {
    if ([[item impliedAnswerFormat] isKindOfClass:[ORKTextChoiceAnswerFormat class]]) {
        _hasChoiceRows = YES;
        ORKTextChoiceAnswerFormat *textChoiceAnswerFormat = (ORKTextChoiceAnswerFormat *)[item impliedAnswerFormat];
        
        _textChoiceCellGroup = [[ORKTextChoiceCellGroup alloc] initWithTextChoiceAnswerFormat:textChoiceAnswerFormat
                                                                                       answer:nil
                                                                           beginningIndexPath:[NSIndexPath indexPathForRow:0 inSection:_index]
                                                                          immediateNavigation:NO];
        
        [textChoiceAnswerFormat.textChoices enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            ORKTableCellItem *cellItem = [[ORKTableCellItem alloc] initWithFormItem:item choiceIndex:idx];
            [(NSMutableArray *)self.items addObject:cellItem];
        }];
        
    } else if ([[item impliedAnswerFormat] isKindOfClass:[ORKColorChoiceAnswerFormat class]]) {
        _hasChoiceRows = YES;
        ORKColorChoiceAnswerFormat *colorChoiceAnswerFormat = (ORKColorChoiceAnswerFormat *)[item impliedAnswerFormat];
        
        _colorChoiceCellGroup = [[ORKColorChoiceCellGroup alloc] initWithColorChoiceAnswerFormat:colorChoiceAnswerFormat
                                                                                          answer:nil
                                                                              beginningIndexPath:[NSIndexPath indexPathForRow:0 inSection:_index]
                                                                             immediateNavigation:NO];
        
        [colorChoiceAnswerFormat.colorChoices enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            ORKTableCellItem *cellItem = [[ORKTableCellItem alloc] initWithFormItem:item choiceIndex:idx];
            [(NSMutableArray *)self.items addObject:cellItem];
        }];
        
    } else {
        ORKTableCellItem *cellItem = [[ORKTableCellItem alloc] initWithFormItem:item];
        [(NSMutableArray *)self.items addObject:cellItem];
    }
}

- (BOOL)containsFormItem:(ORKFormItem *)formItem {
    for (ORKTableCellItem *cellItem in _items) {
        if (cellItem.formItem.identifier == formItem.identifier) {
            return YES;
        }
    }
    
    return NO;
}

- (CGFloat)maxLabelWidth {
    CGFloat max = 0;
    for (ORKTableCellItem *item in self.items) {
        if (item.labelWidth > max) {
            max = item.labelWidth;
        }
    }
    return max;
}

@end

@interface ORKFormSectionHeaderView : UIView

- (instancetype)initWithTitle:(NSString *)title tableView:(UITableView *)tableView firstSection:(BOOL)firstSection;

@property (nonatomic, strong) NSLayoutConstraint *leftMarginConstraint;

@property (nonatomic, weak) UITableView *tableView;

@end


@implementation ORKFormSectionHeaderView {
    ORKFormSectionTitleLabel *_label;
    BOOL _firstSection;
}

- (instancetype)initWithTitle:(NSString *)title tableView:(UITableView *)tableView firstSection:(BOOL)firstSection {
    self = [super init];
    if (self) {
        _tableView = tableView;
        _firstSection = firstSection;
        self.backgroundColor = [UIColor whiteColor];
        
        _label = [ORKFormSectionTitleLabel new];
        _label.text = title;
        _label.numberOfLines = 0;
        _label.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_label];
        [self setUpConstraints];
    }
    return self;
}

- (void)setUpConstraints {
    
    const CGFloat LabelFirstBaselineToTop = _firstSection ? 20.0 : 40.0;
    const CGFloat LabelLastBaselineToBottom = -10.0;
    const CGFloat LabelRightMargin = -4.0;
    
    NSMutableArray *constraints = [NSMutableArray new];
    [constraints addObject:[NSLayoutConstraint constraintWithItem:_label
                                                        attribute:NSLayoutAttributeFirstBaseline
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:self
                                                        attribute:NSLayoutAttributeTop
                                                       multiplier:1.0
                                                         constant:LabelFirstBaselineToTop]];
    
    self.leftMarginConstraint = [NSLayoutConstraint constraintWithItem:_label
                                                             attribute:NSLayoutAttributeLeft
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:self
                                                             attribute:NSLayoutAttributeLeft
                                                            multiplier:1.0
                                                              constant:0.0];
    
    [constraints addObject:self.leftMarginConstraint];
    
    [constraints addObject:[NSLayoutConstraint constraintWithItem:_label
                                                        attribute:NSLayoutAttributeLastBaseline
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:self
                                                        attribute:NSLayoutAttributeBottom
                                                       multiplier:1.0
                                                         constant:LabelLastBaselineToBottom]];
    
    [constraints addObject:[NSLayoutConstraint constraintWithItem:_label
                                                        attribute:NSLayoutAttributeRight
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:self
                                                        attribute:NSLayoutAttributeRight
                                                       multiplier:1.0
                                                         constant:LabelRightMargin]];
    
    [NSLayoutConstraint activateConstraints:constraints];
}

- (void)updateConstraints {
    [super updateConstraints];
    self.leftMarginConstraint.constant = _tableView.layoutMargins.left;
}

@end


@interface ORKFormStepViewController () <UITableViewDelegate, ORKFormItemCellDelegate, ORKTableContainerViewDelegate, ORKTextChoiceCellGroupDelegate, ORKChoiceOtherViewCellDelegate, ORKLearnMoreViewDelegate>

@property (nonatomic, strong) ORKTableContainerView *tableContainer;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UITableViewDiffableDataSource<NSString *, ORKTableCellItemIdentifier *> *diffableDataSource;
@property (nonatomic, strong) ORKStepContentView *headerView;

@property (nonatomic, strong) NSMutableDictionary *savedAnswers;
@property (nonatomic, strong) NSMutableDictionary *savedAnswerDates;
@property (nonatomic, strong) NSMutableDictionary *savedSystemCalendars;
@property (nonatomic, strong) NSMutableDictionary *savedSystemTimeZones;
@property (nonatomic, strong) NSDictionary *originalAnswers;

@property (nonatomic, strong) NSMutableDictionary *savedDefaults;

@end


@implementation ORKFormStepViewController {
    ORKAnswerDefaultSource *_defaultSource;
    NSMutableSet *_formItemCells;

    NSMutableSet<NSString *> *_identifiersOfAnsweredSections;
    BOOL _skipped;
    BOOL _autoScrollCancelled;
    UITableViewCell *_currentFirstResponderCell;
    NSArray<NSLayoutConstraint *> *_constraints;
}

- (instancetype)ORKFormStepViewController_initWithResult:(ORKResult *)result {
    _defaultSource = [ORKAnswerDefaultSource sourceWithHealthStore:[HKHealthStore new]];
    if (result) {
        NSAssert([result isKindOfClass:[ORKStepResult class]], @"Expect a ORKStepResult instance");
        
        NSArray *resultsArray = [(ORKStepResult *)result results];
        for (ORKQuestionResult *currentResult in resultsArray) {
            id answer = currentResult.answer ? : ORKNullAnswerValue();
            [self setAnswer:answer forIdentifier:currentResult.identifier];
        }
        self.originalAnswers = [[NSDictionary alloc] initWithDictionary:self.savedAnswers];
    }
    return self;
}

- (instancetype)initWithStep:(ORKStep *)step {
    self = [super initWithStep:step];
    return [self ORKFormStepViewController_initWithResult:nil];
}

- (instancetype)initWithStep:(ORKStep *)step result:(ORKResult *)result {
    
    self = [super initWithStep:step];
    return [self ORKFormStepViewController_initWithResult:result];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self stepDidChange];
    
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [_tableContainer sizeHeaderToFit];
    [_tableContainer resizeFooterToFit];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self updateAnsweredSections];
    NSMutableSet *types = [NSMutableSet set];
    for (ORKFormItem *item in [self answerableFormItems]) {
        ORKAnswerFormat *format = [item answerFormat];
        HKObjectType *objType = [format healthKitObjectTypeForAuthorization];
        if (objType) {
            [types addObject:objType];
        }
    }
    
    BOOL refreshDefaultsPending = NO;
    if (types.count) {
        NSSet<HKObjectType *> *alreadyRequested = [[self taskViewController] requestedHealthTypesForRead];
        if (![types isSubsetOfSet:alreadyRequested]) {
            refreshDefaultsPending = YES;
            [_defaultSource.healthStore requestAuthorizationToShareTypes:nil readTypes:types completion:^(BOOL success, NSError *error) {
                if (!success) {
                    ORK_Log_Debug("Authorization: %@",error);
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self refreshDefaults];
                });
            }];
        }
    }
    if (!refreshDefaultsPending) {
        [self refreshDefaults];
    }
    
    // Reset skipped flag - result can now be non-empty
    _skipped = NO;
    
    if (_tableView) {
        [_tableView reloadData];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, nil);
    _autoScrollCancelled = NO;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    _autoScrollCancelled = YES;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

// [RDLS:NOTE] Removed sections and tableCellItem
- (void)updateAnsweredSections {
    _identifiersOfAnsweredSections = [NSMutableSet new];
    
    NSDiffableDataSourceSnapshot<NSString *, ORKTableCellItemIdentifier *> *snapshot = [_diffableDataSource snapshot];
    for (NSString *eachSectionIdentifier in [snapshot sectionIdentifiers]) {
        
        for (ORKTableCellItemIdentifier *itemIdentifier in [snapshot itemIdentifiersInSectionWithIdentifier:eachSectionIdentifier]) {
            id answer = _savedAnswers[itemIdentifier.formItemIdentifier];
            if (ORKIsAnswerEmpty(answer) == NO) {
                
                // [RDLS:NOTE] avoiding putting the answer info into a section viewModel object
                [_identifiersOfAnsweredSections addObject:eachSectionIdentifier];
            }
        }

    }
}

- (void)updateDefaults:(NSMutableDictionary *)defaults {
    _savedDefaults = defaults;
    
    __auto_type snapshot = [_diffableDataSource snapshot];
    NSMutableArray<ORKTableCellItemIdentifier *> *itemIdentifiersToReload = [NSMutableArray array];

    // [RDLS:????] not sure how this ever worked since visibleCells may not represent all rows in the tableView
    for (ORKFormItemCell *cell in [_tableView visibleCells]) {
        NSIndexPath *indexPath = [_tableView indexPathForCell:cell];
        
        ORKFormItem *formItem = [self _formItemForIndexPath:indexPath];
        NSString *formItemIdentifier = formItem.identifier;
        if ([cell isKindOfClass:[ORKChoiceViewCell class]]) {

            // Answers need to be saved.
            id answer = _savedAnswers[formItemIdentifier];
            answer = answer ? : _savedDefaults[formItemIdentifier];
            [self setAnswer:answer forIdentifier:formItemIdentifier];
            
        } else {
            cell.defaultAnswer = _savedDefaults[formItemIdentifier];
        }
        [itemIdentifiersToReload addObject:[_diffableDataSource itemIdentifierForIndexPath:indexPath]];
    }
    
    _skipped = NO;
    
    [snapshot reloadItemsWithIdentifiers:itemIdentifiersToReload];
    [_diffableDataSource applySnapshot:snapshot animatingDifferences:NO];
    
    [self updateButtonStates];
    [self notifyDelegateOnResultChange];
}

- (void)refreshDefaults {
    NSArray *formItems = [self allFormItems];
    ORKAnswerDefaultSource *source = _defaultSource;
    ORKWeakTypeOf(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        __block NSMutableDictionary *defaults = [NSMutableDictionary dictionary];
        for (ORKFormItem *formItem in formItems) {
            [source fetchDefaultValueForAnswerFormat:formItem.answerFormat handler:^(id defaultValue, NSError *error) {
                if (defaultValue != nil) {
                    defaults[formItem.identifier] = defaultValue;
                } else if (error != nil) {
                    ORK_Log_Error("Error fetching default for %@: %@", formItem, error);
                }
                dispatch_semaphore_signal(semaphore);
            }];
        }
        for (__unused ORKFormItem *formItem in formItems) {
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        }
        
        // All fetches have completed.
        dispatch_async(dispatch_get_main_queue(), ^{
            ORKStrongTypeOf(weakSelf) strongSelf = weakSelf;
            [strongSelf updateDefaults:defaults];
        });
        
    });
    
}

- (void)removeAnswerForIdentifier:(NSString *)identifier {
    if (identifier == nil) {
        return;
    }
    [_savedAnswers removeObjectForKey:identifier];
    _savedAnswerDates[identifier] = [NSDate date];
}

- (void)setAnswer:(id)answer forIdentifier:(NSString *)identifier {
    if (answer == nil || identifier == nil) {
        return;
    }
    if (_savedAnswers == nil) {
        _savedAnswers = [NSMutableDictionary new];
    }
    if (_savedAnswerDates == nil) {
        _savedAnswerDates = [NSMutableDictionary new];
    }
    if (_savedSystemCalendars == nil) {
        _savedSystemCalendars = [NSMutableDictionary new];
    }
    if (_savedSystemTimeZones == nil) {
        _savedSystemTimeZones = [NSMutableDictionary new];
    }
    _savedAnswers[identifier] = answer;
    _savedAnswerDates[identifier] = [NSDate date];
    _savedSystemCalendars[identifier] = [NSCalendar currentCalendar];
    _savedSystemTimeZones[identifier] = [NSTimeZone systemTimeZone];
}

// Override to monitor button title change
- (void)setContinueButtonItem:(UIBarButtonItem *)continueButtonItem {
    [super setContinueButtonItem:continueButtonItem];
    _navigationFooterView.continueButtonItem = continueButtonItem;
    [self updateButtonStates];
}

- (void)setSkipButtonItem:(UIBarButtonItem *)skipButtonItem {
    [super setSkipButtonItem:skipButtonItem];
    
    _navigationFooterView.skipButtonItem = skipButtonItem;
    [self updateButtonStates];
}

- (void)stepDidChange {
    [super stepDidChange];
    
    [_tableContainer removeFromSuperview];
    _tableContainer = nil;
    
    _tableView.delegate = nil;
    _tableView.dataSource = nil;
    _tableView = nil;
    _formItemCells = nil;
    _headerView = nil;
    _navigationFooterView = nil;
    
    if (self.isViewLoaded && self.step) {
        _formItemCells = [NSMutableSet new];
        
        _tableContainer = [[ORKTableContainerView alloc] initWithStyle:UITableViewStyleGrouped pinNavigationContainer:NO];
        _tableContainer.tableContainerDelegate = self;
        [self.view addSubview:_tableContainer];
        _tableContainer.tapOffView = self.view;
        
        _tableView = _tableContainer.tableView;
        _tableView.delegate = self;
        
        [self _registerCellClassesInTableView:_tableView];
        
        // [RDLS:NOTE] swapping out existing impl for diffableDataSource
        ORKWeakTypeOf(self) weakSelf = self;
        _diffableDataSource = [[UITableViewDiffableDataSource alloc] initWithTableView:_tableView cellProvider:^UITableViewCell * _Nullable(UITableView * _Nonnull tableView, NSIndexPath * _Nonnull indexPath, id  _Nonnull itemIdentifier) {
            return [weakSelf _tableView:tableView cellForIndexPath:indexPath itemIdentifier:itemIdentifier];
        }];
        [self buildDataSource:_diffableDataSource];
        _tableView.dataSource = _diffableDataSource;
        
//        _tableView.dataSource = self;
        _tableView.clipsToBounds = YES;
        _tableView.rowHeight = UITableViewAutomaticDimension;
        _tableView.sectionHeaderHeight = UITableViewAutomaticDimension;
        _tableView.estimatedRowHeight = ORKGetMetricForWindow(ORKScreenMetricTableCellDefaultHeight, self.view.window);
        _tableView.estimatedSectionHeaderHeight = 30.0;
        
        if ([self formStep].useCardView) {
            _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
            
            if (ORKNeedWideScreenDesign(self.view)) {
                [_tableView setBackgroundColor:[UIColor clearColor]];
                [self.taskViewController setNavigationBarColor:ORKColor(ORKBackgroundColorKey)];
                [self.view setBackgroundColor:ORKColor(ORKBackgroundColorKey)];
            }
            else {
                if (@available(iOS 13.0, *)) {
                    [_tableView setBackgroundColor:[UIColor systemGroupedBackgroundColor]];
                } else {
                    [_tableView setBackgroundColor:ORKColor(ORKBackgroundColorKey)];
                }
                [self.taskViewController setNavigationBarColor:[_tableView backgroundColor]];
                [self.view setBackgroundColor:[_tableView backgroundColor]];
            }
        } else {
            [_tableView setBackgroundColor:[UIColor clearColor]];
        }
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
        _navigationFooterView.continueEnabled = [self continueButtonEnabled];
        _navigationFooterView.continueButtonItem = self.continueButtonItem;
        _navigationFooterView.optional = self.step.optional;
        _navigationFooterView.footnoteLabel.text = [self formStep].footnote;
        
        // Form steps should always force the navigation controller to be scrollable
        // therefore we should always remove the styling.
        [_navigationFooterView removeStyling];
        
        if (self.readOnlyMode) {
            _navigationFooterView.optional = YES;
            [_navigationFooterView setNeverHasContinueButton:YES];
            _navigationFooterView.skipEnabled = [self skipButtonEnabled];
            _navigationFooterView.skipButton.accessibilityTraits = UIAccessibilityTraitStaticText;
        }
        [self setupConstraints];
        [_tableContainer setNeedsLayout];
    }
}

- (void)_registerCellClassesInTableView:(UITableView *)tableView {
    
    for (ORKFormItem *eachItem in [self allFormItems]) {
        
        // our cell choices are based on answerFormat
        ORKAnswerFormat *answerFormat = eachItem.impliedAnswerFormat;
        NSString *reuseIdentifier = eachItem.identifier;
        Class class = answerFormat.formStepViewControllerCellClass;
        if ((class != nil) && (reuseIdentifier != nil)) {
            [tableView registerClass:class forCellReuseIdentifier:reuseIdentifier];
        } else if (answerFormat.choices.count > 0) {
            for (id eachChoice in answerFormat.choices) {
                if ([eachChoice isKindOfClass:[ORKTextChoiceOther class]]) {
                    [tableView registerClass:[ORKChoiceOtherViewCell class] forCellReuseIdentifier:NSStringFromClass([eachChoice class])];
                } else {
                    [tableView registerClass:[ORKChoiceViewCell class] forCellReuseIdentifier:NSStringFromClass([eachChoice class])];
                }
            }
        } else {
            ORK_Log_Debug("Not registering cell class '%@' for formItem with identifier '%@' answerFormat: %@", class, reuseIdentifier, answerFormat);
        }
        
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

- (void)buildDataSource:(UITableViewDiffableDataSource<NSString *, ORKTableCellItemIdentifier *> *)dataSource {
    
    NSDiffableDataSourceSnapshot *snapshot = dataSource.snapshot;
    NSArray<ORKFormItem *> *formItems = [[self visibleFormItems] copy];
    
    // TODO: rdar://110144795 ([ConditionalFormItems] ORKFormStepViewController buildDataSource method is way too big)
    
    // make a brand new snapshot that holds the section and item identifiers that result from analyzing the formItems
    NSDiffableDataSourceSnapshot<NSString *, ORKTableCellItemIdentifier *> *newSnapshot = [[NSDiffableDataSourceSnapshot alloc] init];
    for (ORKFormItem *eachItem in formItems) {
        
        NSString *formItemIdentifier = eachItem.identifier;
        ORKAnswerFormat *answerFormat = eachItem.impliedAnswerFormat;

        if (formItemIdentifier == nil) {
            ORK_Log_Info("%@ Refusing to deal with formItem missing identifier", self);
        } else if (answerFormat == nil) {
            // has no answerFormat
            // treat these as sections
            [newSnapshot appendSectionsWithIdentifiers:@[formItemIdentifier]];
        } else {
            NSAssert((answerFormat != nil), @"building tableView data source: assumed answerFormat was nonnull");
            NSAssert((formItemIdentifier != nil), @"building tableView data source: assumed formItemIdentifier was nonnull");
            // if we're here, we expect to add at least one new itemIdentifier
            
            // Step 1/2: Do we need to make a section for this item to land in?
            if ((eachItem.requiresSingleSection) || ([newSnapshot numberOfSections] == 0)) {
                [newSnapshot appendSectionsWithIdentifiers:@[formItemIdentifier]];
            }
            
            // Step 2/2: Are we adding a single identifier for this formItem or exploding the formItem into an identifier per choice?
            // [RDLS:NOTE] unfortunately, besides checking isKindOfClass, we can't tell when we need to convert choices into tableView items. Some answerFormats have choices but don't want to be converted to one row per choice
            if (ORKDynamicCast(answerFormat, ORKTextChoiceAnswerFormat) != nil || ORKDynamicCast(answerFormat, ORKColorChoiceAnswerFormat) != nil) {
                // Make one row per choice, we probably made a section already since formItems with choice answerFormats are requiresSingleSection==YES
                NSArray *choices = answerFormat.choices;
                [choices enumerateObjectsUsingBlock:^(id eachChoice, NSUInteger index, BOOL *stop) {
                    ORKTableCellItemIdentifier *itemIdentifier = [[ORKTableCellItemIdentifier alloc] initWithFormItemIdentifier:formItemIdentifier choiceIndex:index];
                    [newSnapshot appendItemsWithIdentifiers:@[itemIdentifier]];
                }];
            } else {
                // has answerFormat but no choices
                // Convert the formItem itself into a row
                ORKTableCellItemIdentifier *itemIdentifier = [[ORKTableCellItemIdentifier alloc] initWithFormItemIdentifier:formItemIdentifier choiceIndex:NSNotFound];
                [newSnapshot appendItemsWithIdentifiers:@[itemIdentifier]];
            }
        }
    }
        
    // remove stale sections
    {
        NSMutableSet<NSString *> *originalSectionIdentifiers = [NSMutableSet setWithArray:[snapshot sectionIdentifiers]];
        NSSet<NSString *> *newSectionIdentifiers = [NSSet setWithArray:[newSnapshot sectionIdentifiers]];
        [originalSectionIdentifiers minusSet:newSectionIdentifiers];
        [snapshot deleteSectionsWithIdentifiers:[originalSectionIdentifiers allObjects]];
    }

    // remove stale items
    {
        NSMutableSet<ORKTableCellItemIdentifier *> *originalItemIdentifiers = [NSMutableSet setWithArray:[snapshot itemIdentifiers]];
        NSSet<ORKTableCellItemIdentifier *> *newItemIdentifiers = [NSSet setWithArray:[newSnapshot itemIdentifiers]];
        [originalItemIdentifiers minusSet:newItemIdentifiers];
        [snapshot deleteItemsWithIdentifiers:[originalItemIdentifiers allObjects]];
    }

    // Now we can run through the original snapshot and update it based on our new snapshot
    for (NSString *eachSectionIdentifier in [newSnapshot sectionIdentifiers]) {
        
        // put the section in the right spot
        // yes, we could keep a counter outside the for loop. Computing index here so there's less state to manage
        NSInteger index = [newSnapshot indexOfSectionIdentifier:eachSectionIdentifier];
        
        NSUInteger originalCountOfSections = [snapshot numberOfSections];
        if (originalCountOfSections > index) {
            NSString *originalSectionIdentiferAtIndex = [[snapshot sectionIdentifiers] objectAtIndex:index];
            if ([originalSectionIdentiferAtIndex isEqual:eachSectionIdentifier]) {
                // the same section identifier lives at the same index, no-op
            } else if ([snapshot indexOfSectionIdentifier:eachSectionIdentifier] != NSNotFound) {
                // the same section identifier lives in both, but at different index in each: move
                [snapshot moveSectionWithIdentifier:eachSectionIdentifier beforeSectionWithIdentifier:originalSectionIdentiferAtIndex];
            } else {
                // the sectionIdentifer doesn't exist in the original snapshot, insert ahead of whatever's currently at this index
                [snapshot insertSectionsWithIdentifiers:@[eachSectionIdentifier] beforeSectionWithIdentifier:originalSectionIdentiferAtIndex];
            }
        } else {
            // More sections in the new snapshot than the old, just append
            [snapshot appendSectionsWithIdentifiers:@[eachSectionIdentifier]];
        }
        
        for (ORKTableCellItemIdentifier *eachItemIdentifier in [newSnapshot itemIdentifiersInSectionWithIdentifier:eachSectionIdentifier]) {
            
            // put the items in the right spot
            // yes, we could keep a counter outside this for loop. Computing this index so there's less state to manage
            NSInteger itemIndex = [newSnapshot indexOfItemIdentifier:eachItemIdentifier];

            NSUInteger originalCountOfItems = [snapshot numberOfItems];
            if (originalCountOfItems > itemIndex) {
                ORKTableCellItemIdentifier *originalItemIdentiferAtIndex = [[snapshot itemIdentifiers] objectAtIndex:itemIndex];
                if ([originalItemIdentiferAtIndex isEqual:eachItemIdentifier]) {
                    // the same itemIdentifier lives at the same index, no-op
                } else if ([snapshot indexOfItemIdentifier:eachItemIdentifier] != NSNotFound) {
                    // the same itemIdentifier lives in both, but at different index in each: move
                    [snapshot moveItemWithIdentifier:eachItemIdentifier beforeItemWithIdentifier:originalItemIdentiferAtIndex];
                } else if ([eachItemIdentifier.formItemIdentifier isEqual:originalItemIdentiferAtIndex.formItemIdentifier]) {
                    // the itemIdentifer doesn't exist in the original snapshot, insert ahead of whatever's currently at this index
                    [snapshot insertItemsWithIdentifiers:@[eachItemIdentifier] beforeItemWithIdentifier:originalItemIdentiferAtIndex];
                } else {
                    // the itemIdentifier doesn't exist in the original snapshot, append to current section
                    [snapshot appendItemsWithIdentifiers:@[eachItemIdentifier] intoSectionWithIdentifier:eachSectionIdentifier];
                }

                // There may be a case where we don't support items moving between sections, but that shouldn't happen since the only way formItems can move around like that is if you feed the stepViewController a new step. Resetting the step builds a brand new tableView and datasource, so you shouldn't hit that problem.
            } else {
                if ([snapshot indexOfItemIdentifier:eachItemIdentifier] != NSNotFound) {
                    // item was there in original snapshot, moved in new snapshot, beyond the range of old snapshot's last item
                    id lastItemIdentifier = [[snapshot itemIdentifiers] lastObject];
                    [snapshot moveItemWithIdentifier:eachItemIdentifier afterItemWithIdentifier:lastItemIdentifier];
                } else {
                    // the itemIdentifer doesn't exist in the original snapshot
                    [snapshot appendItemsWithIdentifiers:@[eachItemIdentifier] intoSectionWithIdentifier:eachSectionIdentifier];
                }
            }
        }

    }
    
    // TODO: rdar://110144953 ([ConditionalFormItems] ORKFormStepViewController - it's not always appropriate to animate snapshot changes)
    [dataSource applySnapshot:snapshot animatingDifferences:YES];
}

- (NSInteger)numberOfAnsweredFormItemsInDictionary:(NSDictionary *)dictionary {
    __block NSInteger nonNilCount = 0;
    [dictionary enumerateKeysAndObjectsUsingBlock:^(id key, id answer, BOOL *stop) {
        if (ORKIsAnswerEmpty(answer) == NO) {
            nonNilCount ++;
        }
    }];
    return nonNilCount;
}

- (NSInteger)numberOfAnsweredFormItems {
    return [self numberOfAnsweredFormItemsInDictionary:self.savedAnswers];
}

- (BOOL)allAnsweredFormItemsAreValid {
    for (ORKFormItem *item in [self answerableFormItems]) {
        id answer = _savedAnswers[item.identifier];
        if (ORKIsAnswerEmpty(answer) == NO && ![item.impliedAnswerFormat isAnswerValid:answer]) {
            return NO;
        }
    }
    return YES;
}

- (BOOL)allNonOptionalFormItemsHaveAnswers {
    for (ORKFormItem *item in [self answerableFormItems]) {
        if (!item.optional) {
            id answer = _savedAnswers[item.identifier];
            if (ORKIsAnswerEmpty(answer) || ![item.impliedAnswerFormat isAnswerValid:answer]) {
                return NO;
            }
        }
    }
    return YES;
}

- (nullable ORKFormItem *)fetchFirstUnansweredNonOptionalFormItem:(NSArray<ORKFormItem *> *)formItems {
    for (ORKFormItem *item in formItems) {
        if (!item.optional) {
            id answer = _savedAnswers[item.identifier];
            if (ORKIsAnswerEmpty(answer) || ![item.impliedAnswerFormat isAnswerValid:answer]) {
                return item;
            }
        }
    }

    return nil;
}

- (nullable NSString *)fetchSectionThatContainsFormItem:(ORKFormItem *)formItem {
    ORKTableCellItemIdentifier *identifier = [[ORKTableCellItemIdentifier alloc] initWithFormItemIdentifier:formItem.identifier choiceIndex:NSNotFound];
    __auto_type snapshot = [_diffableDataSource snapshot];
    NSString *result = [snapshot sectionIdentifierForSectionContainingItemIdentifier:identifier];
    
    // in case the formItem turned into a section with choices instead, try looking for the formItemIdentifier as a sectionIdentifier
    result = result ? : formItem.identifier;
    
    return result;
    
//    for (ORKTableSection *section in _sections) {
//        if ([section containsFormItem:formItem]) {
//            return section;
//        }
//    }
//
//    return nil;
}

- (BOOL)continueButtonEnabled {
    BOOL enabled = ([self numberOfAnsweredFormItems] > 0
                    && [self allAnsweredFormItemsAreValid]
                    && [self allNonOptionalFormItemsHaveAnswers]);
    if (self.isBeingReviewed) {
        enabled = enabled && ![self.savedAnswers isEqualToDictionary:self.originalAnswers];
    }
    return enabled;
}

- (BOOL)skipButtonEnabled {
    BOOL enabled = self.formStep.optional;
    if (self.isBeingReviewed) {
        enabled = self.readOnlyMode ? NO : enabled && [self numberOfAnsweredFormItemsInDictionary:self.originalAnswers] > 0;
    }
    return enabled;
}

- (void)updateButtonStates {
    _navigationFooterView.continueEnabled = [self continueButtonEnabled];
    _navigationFooterView.skipEnabled = [self skipButtonEnabled];
    
    if (self.shouldPresentInReview && self.navigationItem.rightBarButtonItem) {
        self.navigationItem.rightBarButtonItem.enabled = [self continueButtonEnabled];
    }
}

- (void)setShouldPresentInReview:(BOOL)shouldPresentInReview {
    [super setShouldPresentInReview:shouldPresentInReview];
    [_navigationFooterView setHidden:YES];
}

#pragma mark Helpers

- (ORKFormStep *)formStep {
    NSAssert(!self.step || [self.step isKindOfClass:[ORKFormStep class]], nil);
    return (ORKFormStep *)self.step;
}

- (NSArray<ORKFormItem *> *)allFormItems {
    return [[self formStep] formItems];
}

- (NSArray<ORKFormItem *> *)visibleFormItemsFromResult:(ORKTaskResult *)ongoingTaskResult {
    NSMutableArray<ORKFormItem *> *visibleItemsMutableArray = [NSMutableArray new];

    for (ORKFormItem *eachItem in [self allFormItems]) {
        ORKFormItemVisibilityRule *rule = eachItem.visibilityRule;
        BOOL shouldAllowVisibility = (rule == nil) || ([rule formItemVisibilityForTaskResult:ongoingTaskResult] == YES);
        if (shouldAllowVisibility == YES) {
            [visibleItemsMutableArray addObject:eachItem];
        }
    }
    
    return [visibleItemsMutableArray copy];
}

- (NSArray<ORKFormItem *> *)visibleFormItems {
    ORKTaskResult *taskResult = [self _ongoingTaskResult];
    NSArray<ORKFormItem *> *visibileFormItems = [self visibleFormItemsFromResult:taskResult];
    return visibileFormItems;
}

- (NSArray *)answerableFormItems {
    NSMutableArray *array = [NSMutableArray new];
    for (ORKFormItem *item in [self visibleFormItems]) {
        if (item.answerFormat != nil) {
            [array addObject:item];
        }
    }
    
    return [array copy];
}

- (nullable ORKFormItem *)_formItemForIndexPath:(NSIndexPath *)indexPath {
    ORKFormItem *result;
    
    ORKTableCellItemIdentifier *itemIdentifier = [_diffableDataSource itemIdentifierForIndexPath:indexPath];
    result = [self _formItemForFormItemIdentifier:itemIdentifier.formItemIdentifier];
    
    return result;
}

- (nullable ORKFormItem *)_formItemForFormItemIdentifier:(NSString *)formItemIdentifier {
    ORKFormItem *result;

    NSArray<ORKFormItem *> *allFormItems = [self allFormItems];
    
    // TODO: rdar://110150128 ([ConditionalFormItems] Likely performance hotspot _formItemForFormItemIdentifier)
    NSInteger formItemIndex = [allFormItems indexOfObjectPassingTest:^BOOL(ORKFormItem * testItem, NSUInteger testIndex, BOOL *stop) {
        BOOL foundIndex = [testItem.identifier isEqualToString:formItemIdentifier];
        return foundIndex;
    }];
    result = (formItemIndex != NSNotFound) ? [allFormItems objectAtIndex:formItemIndex] : nil;

    return result;
}

- (NSSet<NSString *> *)hiddenFormItemIdentifiersForTaskResult:(ORKTaskResult *)taskResult {
    // make a set of all the identifiers of formItems we want to hide
    NSMutableSet *mutableSet = [NSMutableSet new];
    
    // start with all the formItems
    [[self allFormItems] enumerateObjectsUsingBlock:^(ORKFormItem *eachItem, NSUInteger idx, BOOL *stop) {
        NSString *identifier = eachItem.identifier;
        if (identifier != nil) {
            [mutableSet addObject:identifier];
        }
    }];
    
    // Now remove the visible formItem identifiers. The remaining set are the hidden ones
    [[self visibleFormItemsFromResult:taskResult] enumerateObjectsUsingBlock:^(ORKFormItem *eachItem, NSUInteger idx, BOOL *stop) {
        NSString *identifier = eachItem.identifier;
        if (identifier != nil) {
            [mutableSet removeObject:identifier];
        }
    }];
    
    return [mutableSet copy];
}

- (BOOL)showValidityAlertWithMessage:(NSString *)text {
    // Ignore if our answer is null
    if (_skipped) {
        return NO;
    }
    
    return [super showValidityAlertWithMessage:text];
}

- (BOOL)hasAnswer {
    return (self.savedAnswers != nil);
}

/// Returns the combination of the delegate's stepViewControllerOngoingResult: ORKTaskResult and the full ORKStepResult for this stepViewController (regardless of formItem visibilityRules)
- (nonnull ORKTaskResult *)_ongoingTaskResult {
    ORKTaskResult *taskResult = nil;

    id <ORKStepViewControllerDelegate> delegate = [self delegate];
    if ([delegate respondsToSelector:@selector(stepViewControllerOngoingResult:)]) {
        // make a copy of the taskResult since we're going to change its results
        taskResult = [[delegate stepViewControllerOngoingResult:self] copy];
    }

    // in case no taskResult was returned, make one up
    if (taskResult == nil) {
        taskResult = [[ORKTaskResult alloc] initWithTaskIdentifier:@"" taskRunUUID:[NSUUID new] outputDirectory:nil];
    }
    
    // start with all the stepResults regardless of visibilityRules
    ORKStepResult *stepResult = [self _stepResultFromFormItems:[self allFormItems]];
    
    // merge the results with the current ongoing task result.
    taskResult.results = [taskResult.results arrayByAddingObject:stepResult];

    return taskResult;
}

// Not to use `ImmediateNavigation` when current step already has an answer.
// So user is able to review the answer when it is present.
- (BOOL)isStepImmediateNavigation {
    // FIXME: - add explicit property in FormStep to dictate this behavior
//    return [[self formStep] isFormatImmediateNavigation] && [self hasAnswer] == NO && !self.isBeingReviewed;
    return NO;
}

- (ORKStepResult *)result {
    ORKTaskResult *taskResult = [self _ongoingTaskResult];
    
    // get the stepResult, which should be the last result in the taskResult.results array
    // this stepResult contains everything regardless of visibility rules
    ORKStepResult *stepResult = ORKDynamicCast(taskResult.results.lastObject, ORKStepResult);

    // Make a mutable copy of the stepResult's results array. We're going to remove items from this array
    // rather than build a new array from an empty one. This way we preserve the results that may
    // have been added through ORKStepViewController's `addResult:` API
    NSMutableArray<ORKResult *> *mutableResults = [stepResult.results mutableCopy];

    // walk through the array in reverse so we can use cheap removeObjectAtIndex: to remove results that should be hidden
    NSSet<NSString *> *hiddenFormItemIdentifiers = [self hiddenFormItemIdentifiersForTaskResult:taskResult];
    [stepResult.results enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(ORKResult *eachResult, NSUInteger index, BOOL *stop) {
        NSString *identifier = eachResult.identifier;
        if ([hiddenFormItemIdentifiers containsObject:identifier]) {
            [mutableResults removeObjectAtIndex:index];
        }
    }];
    
    stepResult.results = [mutableResults copy];
    return stepResult;
}

- (ORKStepResult *)_stepResultFromFormItems:(NSArray<ORKFormItem *> *)formItems {
    ORKStepResult *parentResult = [super result];

    // "Now" is the end time of the result, which is either actually now,
    // or the last time we were in the responder chain.
    NSDate *now = parentResult.endDate;
    
    NSMutableArray *qResults = [NSMutableArray new];
    for (ORKFormItem *item in formItems) {

        // Only process formItems for which we would have an answerFormat
        if (item.answerFormat == nil) {
            continue;
        }
        
        // Skipped forms report a "null" value for every item -- by skipping, the user has explicitly said they don't want
        // to report any values from this form.
        
        id answer = ORKNullAnswerValue();
        NSDate *answerDate = now;
        NSCalendar *systemCalendar = [NSCalendar currentCalendar];
        NSTimeZone *systemTimeZone = [NSTimeZone systemTimeZone];
        if (!_skipped) {
            answer = _savedAnswers[item.identifier];
            answerDate = _savedAnswerDates[item.identifier] ? : now;
            systemCalendar = _savedSystemCalendars[item.identifier];
            NSAssert(answer == nil || answer == ORKNullAnswerValue() || systemCalendar != nil, @"systemCalendar NOT saved");
            systemTimeZone = _savedSystemTimeZones[item.identifier];
            NSAssert(answer == nil || answer == ORKNullAnswerValue() || systemTimeZone != nil, @"systemTimeZone NOT saved");
        }
   
        ORKQuestionResult *result = [item.answerFormat resultWithIdentifier:item.identifier answer:answer];
        ORKAnswerFormat *impliedAnswerFormat = [item impliedAnswerFormat];

        if ([impliedAnswerFormat isKindOfClass:[ORKDateAnswerFormat class]]) {
            ORKDateQuestionResult *dqr = (ORKDateQuestionResult *)result;
            if (dqr.dateAnswer) {
                NSCalendar *usedCalendar = [(ORKDateAnswerFormat *)impliedAnswerFormat calendar] ? : systemCalendar;
                dqr.calendar = [NSCalendar calendarWithIdentifier:usedCalendar.calendarIdentifier];
                dqr.timeZone = systemTimeZone;
            }
        } else if ([impliedAnswerFormat isKindOfClass:[ORKNumericAnswerFormat class]]) {
            ORKNumericQuestionResult *nqr = (ORKNumericQuestionResult *)result;
            if (nqr.unit == nil) {
                nqr.unit = [(ORKNumericAnswerFormat *)impliedAnswerFormat unit];
                nqr.displayUnit = [(ORKNumericAnswerFormat *)impliedAnswerFormat displayUnit];
            }
        }
        
        result.startDate = answerDate;
        result.endDate = answerDate;

        [qResults addObject:result];
    }
    
    parentResult.results = [parentResult.results arrayByAddingObjectsFromArray:qResults] ? : qResults;
    
    return parentResult;
}

- (void)skipForward {
    // This _skipped flag is a hack so that the -result method can return an empty
    // result after the skip action, without having to generate the result
    // in advance.
    _skipped = YES;
    [self notifyDelegateOnResultChange];
    
    [super skipForward];
}

- (void)goBackward {
    if (self.isBeingReviewed) {
        self.savedAnswers = [[NSMutableDictionary alloc] initWithDictionary:self.originalAnswers];
    }
    [super goBackward];
}

- (BOOL)didAutoScrollToNextItem:(ORKFormItemCell *)cell {
    NSIndexPath *currentIndexPath = [self.tableView indexPathForCell:cell];
    
    if (cell.isLastItem) {
        return NO;
    } else {
        NSIndexPath *nextIndexPath = [NSIndexPath indexPathForRow:currentIndexPath.row + 1 inSection:currentIndexPath.section];
        ORKFormItemCell *nextCell = [self.tableView cellForRowAtIndexPath:nextIndexPath];
        ORKQuestionType type = nextCell.formItem.impliedAnswerFormat.questionType;

        if ([self doesTableCellTypeUseKeyboard:type]) {
            [_tableView deselectRowAtIndexPath:currentIndexPath animated:NO];

            if ([nextCell isKindOfClass:[ORKFormItemCell class]]) {
                [nextCell becomeFirstResponder];
            }

        } else {
            return NO;
        }
    }

    return YES;
}

- (BOOL)shouldAutoScrollToNextSection:(NSIndexPath *)indexPath {
    NSIndexPath *nextIndexPath = [NSIndexPath indexPathForRow:0 inSection:(indexPath.section + 1)];
    ORKFormItemCell *nextCell = [self.tableView cellForRowAtIndexPath:nextIndexPath];
    
    if ([nextCell respondsToSelector:@selector(formItem)] && !_autoScrollCancelled) {
        ORKQuestionType type = nextCell.formItem.impliedAnswerFormat.questionType;
        
        if ([self doesTableCellTypeUseKeyboard:type] && [nextCell isKindOfClass:[ORKFormItemCell class]]) {
            return YES;
        }
    }
    return NO;
}

- (void)autoScrollToNextSection:(NSIndexPath *)indexPath {
    NSIndexPath *nextIndexPath = [NSIndexPath indexPathForRow:0 inSection:(indexPath.section + 1)];
    ORKFormItemCell *nextCell = [self.tableView cellForRowAtIndexPath:nextIndexPath];
    [nextCell becomeFirstResponder];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, DelayBeforeAutoScroll * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [_tableView scrollToRowAtIndexPath:nextIndexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
    });
}

- (void)handleAutoScrollForNonKeyboardCell:(UITableViewCell *)cell {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    NSArray<NSString *> *sectionIdentifiers = [[_diffableDataSource snapshot] sectionIdentifiers];
    NSString *sectionIdentifier = [sectionIdentifiers objectAtIndex:indexPath.section];
    
    ORKFormItemCell *formItemCell = ORKDynamicCast(cell, ORKFormItemCell);
    if ([formItemCell.answer class] != [ORKDontKnowAnswer class]) {
        if (formItemCell.formItem.answerFormat.impliedAnswerFormat.questionType != ORKQuestionTypeSES) {
            return;
        }
    } else if ((formItemCell == nil) && ([self textChoiceAnswerFormatForIndexPath:indexPath].style != ORKChoiceAnswerStyleSingleChoice) && ![self exclusiveChoiceSelectedForSectionIdentifier:sectionIdentifier withCell:cell] ) {
        return;
    }

    if ((indexPath.section < sectionIdentifiers.count - 1) && [self shouldAutoScrollToNextSection:indexPath] && ![_identifiersOfAnsweredSections containsObject:sectionIdentifier]) {
        [self autoScrollToNextSection:indexPath];
    } else if ((indexPath.section == (sectionIdentifiers.count - 1)) && ![_identifiersOfAnsweredSections containsObject:sectionIdentifier]) {
        if (![self allNonOptionalFormItemsHaveAnswers]) {
            [self scrollToFirstUnansweredSection];
        } else {
            [self.tableView scrollRectToVisible:[self.tableView convertRect:self.tableView.tableFooterView.bounds fromView:self.tableView.tableFooterView] animated:YES];
        }
        
    } else if (indexPath.section < (sectionIdentifiers.count - 1) && ![_identifiersOfAnsweredSections containsObject:sectionIdentifier]) {
        NSIndexPath *nextIndexPath = [NSIndexPath indexPathForRow:0 inSection:(indexPath.section + 1)];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, DelayBeforeAutoScroll * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [_tableView scrollToRowAtIndexPath:nextIndexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
        });
    }
}

- (void)scrollToFirstUnansweredSection {
    ORKFormItem *formItem = [self fetchFirstUnansweredNonOptionalFormItem:[self answerableFormItems]];
    NSString *sectionIdentifier = [self fetchSectionThatContainsFormItem:formItem];
        
    NSInteger section = [[_diffableDataSource snapshot] indexOfSectionIdentifier:sectionIdentifier];
    if (section != NSNotFound) {
        NSIndexPath *nextIndexPath = [NSIndexPath indexPathForRow:0 inSection:section];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, DelayBeforeAutoScroll * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [_tableView scrollToRowAtIndexPath:nextIndexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
        });
    }
}

- (nullable ORKTextChoiceAnswerFormat *)textChoiceAnswerFormatForIndexPath:(NSIndexPath *)indexPath {
    ORKTextChoiceAnswerFormat *result = nil;
    
    ORKTableCellItemIdentifier *itemIdentifier = [_diffableDataSource itemIdentifierForIndexPath:indexPath];
    ORKFormItem *formItem = [self _formItemForFormItemIdentifier:itemIdentifier.formItemIdentifier];
    result = ORKDynamicCast(formItem.impliedAnswerFormat, ORKTextChoiceAnswerFormat);
    
    return result;
    
}

- (BOOL)exclusiveChoiceSelectedForSectionIdentifier:(NSString *)sectionIdentifier withCell:(UITableViewCell *)cell {
    BOOL result = NO;
    
    ORKChoiceViewCell *choiceViewCell = ORKDynamicCast(cell, ORKChoiceViewCell);
    if (choiceViewCell != nil) {
        // section identifiers are formItem identifiers, and formItem identifiers are the keys into answers
        id answer = _savedAnswers[sectionIdentifier];
        result = (answer != nil && choiceViewCell.isExclusive);
    }
    
    return result;
}

- (BOOL)doesTableCellTypeUseKeyboard:(ORKQuestionType)questionType {
    switch (questionType) {
        case ORKQuestionTypeDecimal:
        case ORKQuestionTypeInteger:
        case ORKQuestionTypeText:
            return YES;
            
        default:
            return NO;
    }
}

- (void)saveAnswer:(id)answer forItemIdentifier:(ORKTableCellItemIdentifier *)itemIdentifier {
    NSString *formItemIdentifier = [itemIdentifier formItemIdentifier];
    if (formItemIdentifier != nil) {
        if (answer != nil) {
            [self setAnswer:answer forIdentifier:formItemIdentifier];
        } else {
            [self removeAnswerForIdentifier:formItemIdentifier];
        }
    }
    
    NSIndexPath *indexPath = [_diffableDataSource indexPathForItemIdentifier:itemIdentifier];
    [self answerChangedForIndexPath:indexPath];
}

#pragma mark NSNotification methods

- (void)keyboardWillShow:(NSNotification *)notification {
    
    if (_currentFirstResponderCell) {
        if ([_currentFirstResponderCell isKindOfClass:[ORKChoiceOtherViewCell class]]) {
            CGRect keyboardFrame = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
               CGRect convertedKeyboardFrame = [self.view convertRect:keyboardFrame fromView:nil];
               
               if (CGRectGetMaxY(_currentFirstResponderCell.frame) >= CGRectGetMinY(convertedKeyboardFrame)) {
                   
                   [self.tableView setContentInset:UIEdgeInsetsMake(0, 0, CGRectGetHeight(convertedKeyboardFrame), 0)];
                   
                   NSIndexPath *currentFirstResponderCellIndex = [self.tableView indexPathForCell:_currentFirstResponderCell];
                   
                   if (currentFirstResponderCellIndex) {
                       [self.tableView scrollToRowAtIndexPath:currentFirstResponderCellIndex atScrollPosition:UITableViewScrollPositionBottom animated:YES];
                   }
               }
        } else {
            CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
            
            if ((_currentFirstResponderCell.frame.origin.y + CGRectGetHeight(_currentFirstResponderCell.frame)) >= (CGRectGetHeight(self.view.frame) - keyboardSize.height)) {
                _tableView.contentInset = UIEdgeInsetsMake(0, 0, keyboardSize.height + TableViewYOffsetStandard, 0);
            }
        }
    }
}

- (void)keyboardWillHide:(NSNotification *)notification {
    _tableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
}

- (BOOL)isChoiceSelected:(id)value atIndex:(NSUInteger)index answer:(id)answer {
    BOOL isSelected = NO;
    if (answer != nil && answer != ORKNullAnswerValue()) {
        if ([answer isKindOfClass:[NSArray class]]) {
            if (value) {
                isSelected = [(NSArray *)answer containsObject:value];
            } else {
                isSelected = [(NSArray *)answer containsObject:@(index)];
            }
        } else {
            if (value) {
                isSelected = ([answer isEqual:value]);
            } else {
                isSelected = (((NSNumber *)answer).integerValue == index);
            }
        }
    }
    return isSelected;
}

- (UITableViewCell *)_tableView:(UITableView *)tableView cellForIndexPath:(NSIndexPath *)indexPath itemIdentifier:(ORKTableCellItemIdentifier *)itemIdentifier {
    NSString *formItemIdentifier = itemIdentifier.formItemIdentifier;
    
    ORKFormItem *formItem = [self _formItemForFormItemIdentifier:formItemIdentifier];
    
    NSString *reuseIdentifier = ^{
        NSString *result;
        if (itemIdentifier.choiceIndex == NSNotFound) {
            result = formItemIdentifier;
        } else {
            ORKAnswerFormat *answerFormat = formItem.impliedAnswerFormat;
            id choice = [answerFormat.choices objectAtIndex:itemIdentifier.choiceIndex];
            result = NSStringFromClass([choice class]);
        }
        return result;
    }();
    NSAssert((reuseIdentifier != nil), @"reuseIdentifier cannot be nil");

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
    cell.userInteractionEnabled = !self.readOnlyMode;
    
    ORKFormItemCell *formCell = ORKDynamicCast(cell, ORKFormItemCell);
    ORKChoiceViewCell *choiceViewCell = ORKDynamicCast(cell, ORKChoiceViewCell);
    __auto_type snapshot = [_diffableDataSource snapshot];
    if (formCell != nil) {
        // [RDLS:NOTE] we have to pass in formItem, answer, delegate, and maxLabelWidth. I still don't have a replacement for computing maxLabelWidth
        id answer = _savedAnswers[formItemIdentifier];
        
        // TODO: rdar://110150303 ([ConditionalFormItems] compute maxLabelWidth once after stepDidChange but before first call to cellForIndexPath:)
        CGFloat maxLabelWidth = ORKLabelWidth(@"one two three four");
        [formCell configureWithFormItem:formItem answer:answer maxLabelWidth:maxLabelWidth delegate:self];

        [formCell setExpectedLayoutWidth:tableView.bounds.size.width];
        formCell.selectionStyle = UITableViewCellSelectionStyleNone;
        formCell.defaultAnswer = _savedDefaults[formItemIdentifier];
        if (!_savedAnswers) {
            _savedAnswers = [NSMutableDictionary new];
        }
        formCell.savedAnswers = _savedAnswers;
        formCell.useCardView = [self formStep].useCardView;
        formCell.cardViewStyle = [self formStep].cardViewStyle;
        
        formCell.isLastItem = ^{
            NSInteger section = indexPath.section;
            NSInteger rowCountInSection = [_diffableDataSource tableView:tableView numberOfRowsInSection:section];
            BOOL isLastItem = rowCountInSection == indexPath.row + 1;
            return isLastItem;
        }();

        formCell.isFirstItemInSectionWithoutTitle = ^{
            NSString *sectionFormItemIdentifier = [snapshot sectionIdentifierForSectionContainingItemIdentifier:itemIdentifier];
            ORKFormItem *sectionFormItem = [self _formItemForFormItemIdentifier:sectionFormItemIdentifier];
            BOOL isFirstItemWithSectionWithoutTitle = (indexPath.row == 0) && (sectionFormItem.text == nil); // formItem.text is section.title
            return isFirstItemWithSectionWithoutTitle;
        }();
    } else if (choiceViewCell != nil) {
        
        // check whether this cell should be selected, based on answer
        ORKAnswerFormat *answerFormat = formItem.impliedAnswerFormat;
        NSInteger choiceIndex = itemIdentifier.choiceIndex;
        if (choiceIndex != NSNotFound) {
            // TODO: rdar://110145136 ([ConditionalFormItems] choiceViewCell handling only supports textChoices (ORKFormStepViewController))
            BOOL isExclusive = NO;
            NSString *primaryText;
            NSString *detailText;
            
            if ([answerFormat isKindOfClass:[ORKTextChoiceAnswerFormat class]]) {
                ORKTextChoice *textChoice = [answerFormat.choices objectAtIndex:choiceIndex];
                if (textChoice.primaryTextAttributedString) {
                    [choiceViewCell setPrimaryAttributedText:textChoice.primaryTextAttributedString];
                }
                if (textChoice.detailTextAttributedString) {
                    [choiceViewCell setDetailAttributedText:textChoice.detailTextAttributedString];
                }
                
                isExclusive = textChoice.exclusive;
                primaryText = textChoice.text;
                detailText = textChoice.detailText;
            } else {
                ORKColorChoice *colorChoice = [answerFormat.choices objectAtIndex:choiceIndex];
                
                [choiceViewCell setSwatchColor:colorChoice.color];
                choiceViewCell.shouldIgnoreDarkMode = YES;
                
                isExclusive = colorChoice.exclusive;
                primaryText = colorChoice.text;
                detailText = colorChoice.detailText;
            }
            
            id answer = _savedAnswers[formItemIdentifier];
            
            // [RDLS:NOTE] moved from ORKTextChoiceCellGroup cellAtIndex:reuseIdentifier:
            // TODO: rdar://110150497 ([ConditionalFormItems] add a configuration method for ORKChoiceViewCell that accepts a formItem)
            choiceViewCell.isExclusive = isExclusive;
            choiceViewCell.isLastItem = (choiceIndex + 1) == answerFormat.choices.count;
            choiceViewCell.immediateNavigation = NO;
            [choiceViewCell setPrimaryText:primaryText];
            [choiceViewCell setDetailText:detailText];
            
            
            ORKChoiceAnswerFormatHelper *helper = [[ORKChoiceAnswerFormatHelper alloc] initWithAnswerFormat:answerFormat];
            NSArray *selectedIndexes = [helper selectedIndexesForAnswer:answer];
            if ([selectedIndexes containsObject:@(choiceIndex)]) {
                [choiceViewCell setCellSelected:YES highlight:NO];
            } else {
                [choiceViewCell setCellSelected:NO highlight:NO];
            }

        } else {
            // [RDLS:????] Can this be NSNotFound if we're here?
            ORK_Log_Debug("[FORMSTEP] choiceIndex was NSNotFound");
        }

        ORKChoiceOtherViewCell *choiceOtherViewCell = ORKDynamicCast(choiceViewCell, ORKChoiceOtherViewCell);
        choiceOtherViewCell.delegate = self;
        
        choiceViewCell.tintColor = ORKViewTintColor(self.view);
        choiceViewCell.useCardView = [self formStep].useCardView;
        choiceViewCell.cardViewStyle = [self formStep].cardViewStyle;
        
        // TODO: rdar://110150724 ([ConditionalFormItems] choiceViewCells draw strangely because we're not setting isLastItem or isFirstItemInSectionWithoutTitle)
//        choiceViewCell.isLastItem = isLastItem;
//        choiceViewCell.isFirstItemInSectionWithoutTitle = isFirstItemWithSectionWithoutTitle;
        [choiceViewCell layoutSubviews];

    } else {
        NSString *sectionIdentifier = [[snapshot sectionIdentifiers] objectAtIndex:indexPath.section];
        ORK_Log_Debug("[FORMSTEP] _tableView:CellForIndexPath: at index: %@ for section: '%@' cell type is '%@'", @(indexPath.row), sectionIdentifier, NSStringFromClass([cell class]));

    }

    return cell;
}

static CGFloat ORKLabelWidth(NSString *text) {
    static ORKCaption1Label *sharedLabel;

    if (sharedLabel == nil) {
        sharedLabel = [ORKCaption1Label new];
    }

    sharedLabel.text = text;

    return [sharedLabel textRectForBounds:CGRectInfinite limitedToNumberOfLines:1].size.width;
}


#pragma mark UITableViewDelegate

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];

    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    ORKFormItemCell *formItemCell = ORKDynamicCast(cell, ORKFormItemCell);
    if (formItemCell != nil) {
        [cell becomeFirstResponder];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, DelayBeforeAutoScroll * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [_tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
        });
    }

    /*
     TODO: rdar://110151044 ([ConditionalFormItems] tableView:didSelectRowAtIndexPath: needs to do ORKTextChoiceCellGroup's work (ORKFormStepViewController))
     if ([textChoice isKindOfClass:[ORKTextChoiceOther class]] && [touchedCell isKindOfClass:[ORKChoiceOtherViewCell class]])
     updateTextViewForChoiceOtherCell -> conditionally calls
        1. [choiceCell hideTextView:!choiceCell.textViewHidden];
        2. tableViewCellHeightUpdated
     */
    
    ORKChoiceViewCell *choiceViewCell = ORKDynamicCast(cell, ORKChoiceViewCell);
    if (choiceViewCell != nil) {
        // Dismiss other textField's keyboard
        [tableView endEditing:NO];
                
        ORKTableCellItemIdentifier *itemIdentifier = [_diffableDataSource itemIdentifierForIndexPath:indexPath];
        ORKFormItem *formItem = [self _formItemForFormItemIdentifier:itemIdentifier.formItemIdentifier];
        ORKTextChoiceAnswerFormat *textChoiceAnswerFormat = ORKDynamicCast(formItem.impliedAnswerFormat, ORKTextChoiceAnswerFormat);
        ORKColorChoiceAnswerFormat *colorChoiceAnswerFormat = ORKDynamicCast(formItem.impliedAnswerFormat, ORKColorChoiceAnswerFormat);
        
        if (textChoiceAnswerFormat != nil || colorChoiceAnswerFormat != nil) {
            ORKChoiceAnswerFormatHelper *helper = [[ORKChoiceAnswerFormatHelper alloc] initWithAnswerFormat:textChoiceAnswerFormat ? : colorChoiceAnswerFormat];
            
            NSMutableArray *selectedIndexes = [NSMutableArray array];
            
            // find all the row/cell peers to this indexPath
            // the formItem
            BOOL shouldAllowMultiSelection = YES; // assume multiple selection by default
            
            // does the answerFormat want multiple selection?
            BOOL answerFormatAllowsMultiSelection = textChoiceAnswerFormat ? (textChoiceAnswerFormat.style == ORKChoiceAnswerStyleMultipleChoice) : (colorChoiceAnswerFormat.style == ORKChoiceAnswerStyleMultipleChoice);
            shouldAllowMultiSelection = shouldAllowMultiSelection && answerFormatAllowsMultiSelection;
            
            // does the selected cell allow multiple choice?
            shouldAllowMultiSelection = shouldAllowMultiSelection && (choiceViewCell.isExclusive == NO);
            
            // does the cell representing the current answer allow multiple choice?
            NSNumber *previousSingleSelectionValue = [helper selectedIndexForAnswer:_savedAnswers[itemIdentifier.formItemIdentifier]];
            NSInteger previousSingleSelection = previousSingleSelectionValue ? previousSingleSelectionValue.integerValue : NSNotFound;
            BOOL choiceIsExclusive = NO;
            if (textChoiceAnswerFormat) {
                ORKTextChoice *selectedChoice = (previousSingleSelection != NSNotFound) ? [helper textChoiceAtIndex:previousSingleSelection] : nil;
                choiceIsExclusive = selectedChoice.exclusive;
            } else {
                ORKColorChoice *selectedChoice = (previousSingleSelection != NSNotFound) ? [helper colorChoiceAtIndex:previousSingleSelection] : nil;
                choiceIsExclusive = selectedChoice.exclusive;
            }
            
            shouldAllowMultiSelection = shouldAllowMultiSelection && choiceIsExclusive;

            NSRange range = NSMakeRange(0, helper.choiceCount);
            NSIndexSet *relatedChoiceRows = [NSIndexSet indexSetWithIndexesInRange:range];
            NSInteger eachIndex = relatedChoiceRows.firstIndex;
            while (eachIndex != NSNotFound) {
                NSIndexPath *testIndexPath = [NSIndexPath indexPathForRow:eachIndex inSection:indexPath.section];
                ORKChoiceViewCell *testCell = [tableView cellForRowAtIndexPath:testIndexPath];

                if (shouldAllowMultiSelection) {
                    // allowing multi selection means allowing toggling cells on and off when tapped
                    if (testCell == choiceViewCell) {
                        BOOL newSelectedState = !choiceViewCell.isCellSelected;
                        [testCell setCellSelected:newSelectedState highlight:YES];
                    }
                    if (testCell.isCellSelected) {
                        ORK_Log_Debug("[SELECTION] adding index %@", @(eachIndex));
                        [selectedIndexes addObject:@(eachIndex)];
                    }
                } else if (testCell == choiceViewCell) {
                    // only allow a single cell to be selected at a time
                    ORK_Log_Debug("[SELECTION] setting cell selected");
                    [testCell setCellSelected:YES highlight:YES];
                    [selectedIndexes addObject:@(eachIndex)];
                } else {
                    // we're not allowing multi-selection, but this isn't the selected cell either, unhighlight
                    [testCell setCellSelected:NO highlight:NO];
                }
                eachIndex = [relatedChoiceRows indexGreaterThanIndex:eachIndex];
            }

            id answer = [helper answerForSelectedIndexes:selectedIndexes];
            [self saveAnswer:answer forItemIdentifier:itemIdentifier];
        } else {
            ORK_Log_Debug("[FORMSTEP] NOT textChoice: row for item %@ selected: answerFormat is '%@'", itemIdentifier, formItem.impliedAnswerFormat);
        }

    } else {
        ORK_Log_Debug("[FORMSTEP] NOT ORKChoiceViewCell: row for indexPath %@ selected. Cell: %@", indexPath, cell);
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    __auto_type snapshot = [_diffableDataSource snapshot];
    NSString *sectionIdentifier = [[snapshot sectionIdentifiers] objectAtIndex:section];
    ORKFormItem *sectionFormItem = [self _formItemForFormItemIdentifier:sectionIdentifier];
    NSString *title = sectionFormItem.text;

    // Make first section header view zero height when there is no title
    return [self formStep].useCardView ? UITableViewAutomaticDimension : (title.length > 0) ? UITableViewAutomaticDimension : ((section == 0) ? 0 : UITableViewAutomaticDimension);
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    __auto_type snapshot = [_diffableDataSource snapshot];
    NSArray<NSString *> *sectionIdentifiers = [snapshot sectionIdentifiers];
    NSString *sectionIdentifier = [sectionIdentifiers objectAtIndex:section];
    ORKFormItem *sectionFormItem = [self _formItemForFormItemIdentifier:sectionIdentifier];

    NSString *title = sectionFormItem.text;
    NSString *detailText = sectionFormItem.detailText;
    NSString *sectionProgressText = nil;
    ORKLearnMoreView *learnMoreView;
    NSString *tagText = sectionFormItem.tagText;
    BOOL hasMultipleChoiceFormItem = NO;
    BOOL shouldIgnoreDarkMode = NO;
    
    if (sectionFormItem.showsProgress) {
        if ([self.delegate respondsToSelector:@selector(stepViewControllerTotalProgressInfoForStep:currentStep:)]) {
            ORKTaskTotalProgress progressInfo = [self.delegate stepViewControllerTotalProgressInfoForStep:self currentStep:self.step];
            if (progressInfo.stepShouldShowTotalProgress) {
                sectionProgressText = [NSString localizedStringWithFormat:ORKLocalizedString(@"FORM_ITEM_PROGRESS", nil) ,ORKLocalizedStringFromNumber(@(section + progressInfo.currentStepStartingProgressPosition)), ORKLocalizedStringFromNumber(@(progressInfo.total))];
            }
        }
        
        if (!sectionProgressText) {
            // only display progress label if there are more than 1 sections in the form step
            if (snapshot.numberOfSections > 1) {
             sectionProgressText = [NSString localizedStringWithFormat:ORKLocalizedString(@"FORM_ITEM_PROGRESS", nil) ,ORKLocalizedStringFromNumber(@(section + 1)), ORKLocalizedStringFromNumber(@(snapshot.numberOfSections))];
            }
        }
    }
    
    if (sectionFormItem.learnMoreItem) {
        learnMoreView = [ORKLearnMoreView learnMoreViewWithItem:sectionFormItem.learnMoreItem];
        learnMoreView.delegate = self;
    }
    
    hasMultipleChoiceFormItem = (sectionFormItem.impliedAnswerFormat.questionType == ORKQuestionTypeMultipleChoice) ? YES : NO;
    shouldIgnoreDarkMode = [sectionFormItem.impliedAnswerFormat isKindOfClass:[ORKColorChoiceAnswerFormat class]];

    ORKSurveyCardHeaderView *cardHeaderView = (ORKSurveyCardHeaderView *)[tableView dequeueReusableHeaderFooterViewWithIdentifier:@(section).stringValue];
    
    if (cardHeaderView == nil && title) {
        cardHeaderView = [[ORKSurveyCardHeaderView alloc] initWithTitle:title
                                                             detailText:detailText
                                                          learnMoreView:learnMoreView
                                                           progressText:sectionProgressText
                                                                tagText:tagText
                                                             showBorder:([self formStep].cardViewStyle == ORKCardViewStyleBordered)
                                                  hasMultipleChoiceItem:hasMultipleChoiceFormItem
                                                   shouldIgnoreDarkMode:shouldIgnoreDarkMode];
    }
    
    return cardHeaderView;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    ORKFormStep *formStep = [self formStep];
    if (formStep.footerText != nil && (section == (tableView.numberOfSections - 1))) {
        return formStep.footerText;
    }

    return nil;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return section == tableView.numberOfSections - 1 ? UITableViewAutomaticDimension : 10;
}

#pragma mark ORKFormItemCellDelegate

- (void)formItemCellDidBecomeFirstResponder:(ORKFormItemCell *)cell {
    if (_currentFirstResponderCell) {
        ORKFormItemTextFieldBasedCell *previousSelectedCell = (ORKFormItemTextFieldBasedCell*)_currentFirstResponderCell;
        if (previousSelectedCell != nil && [previousSelectedCell respondsToSelector:@selector(removeEditingHighlight)]) {
            [previousSelectedCell removeEditingHighlight];
        }
    }
    
    _currentFirstResponderCell = cell;
    NSIndexPath *path = [_tableView indexPathForCell:cell];
    if (path) {
        [_tableContainer scrollCellVisible:cell animated:YES];
    }
}

- (void)formItemCellDidResignFirstResponder:(ORKFormItemCell *)cell {
    if (_currentFirstResponderCell == cell) {
        _currentFirstResponderCell = nil;
    }
    
    //determines if the table should autoscroll to the next section
    __auto_type snapshot = [_diffableDataSource snapshot];
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    NSString *sectionIdentifier = [[snapshot sectionIdentifiers] objectAtIndex:indexPath.section];
    
    if (cell.isLastItem && [self shouldAutoScrollToNextSection:indexPath]) {
        [self autoScrollToNextSection:indexPath];
        return;
    } else if (cell.isLastItem && indexPath.section == (snapshot.numberOfSections - 1) && ![_identifiersOfAnsweredSections containsObject:sectionIdentifier]) {
        if (![self allNonOptionalFormItemsHaveAnswers]) {
            [self scrollToFirstUnansweredSection];
        } else {
            [self.tableView scrollRectToVisible:[self.tableView convertRect:self.tableView.tableFooterView.bounds fromView:self.tableView.tableFooterView] animated:YES];
        }
    }
        
    if (indexPath) {
        NSInteger numberOfItemsInSection = [snapshot numberOfItemsInSection:sectionIdentifier];
        if (indexPath.row < numberOfItemsInSection - 1) {
            NSIndexPath *nextPath = [NSIndexPath indexPathForRow:(indexPath.row + 1) inSection:indexPath.section];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, DelayBeforeAutoScroll * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                if (_currentFirstResponderCell == nil) {
                    [_tableView scrollToRowAtIndexPath:nextPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
                }
            });
        }
    }
}

- (void)formItemCell:(ORKFormItemCell *)cell invalidInputAlertWithMessage:(NSString *)input {
    [self showValidityAlertWithMessage:input];
}

- (void)formItemCell:(ORKFormItemCell *)cell invalidInputAlertWithTitle:(NSString *)title message:(NSString *)message {
    [self showValidityAlertWithTitle:title message:message];
}

- (void)formItemCell:(ORKFormItemCell *)cell answerDidChangeTo:(id)answer {
    if (answer && cell.formItem.identifier) {
        [self setAnswer:answer forIdentifier:cell.formItem.identifier];
    } else if (answer == nil && cell.formItem.identifier) {
        [self removeAnswerForIdentifier:cell.formItem.identifier];
    }
    
    _skipped = NO;
    [self updateButtonStates];
    [self notifyDelegateOnResultChange];
    [self handleAutoScrollForNonKeyboardCell:cell];
    [self updateAnsweredSections];
    [self buildDataSource:_diffableDataSource];
}

- (BOOL)formItemCellShouldDismissKeyboard:(ORKFormItemCell *)cell {
    if ([self didAutoScrollToNextItem:cell]) {
        return NO;
    }
    return YES;
}

#pragma mark ORKTableContainerViewDelegate

- (UITableViewCell *)currentFirstResponderCellForTableContainerView:(ORKTableContainerView *)tableContainerView {
    return _currentFirstResponderCell;
}

#pragma mark UIStateRestoration

static NSString *const _ORKSavedAnswersRestoreKey = @"savedAnswers";
static NSString *const _ORKSavedAnswerDatesRestoreKey = @"savedAnswerDates";
static NSString *const _ORKSavedSystemCalendarsRestoreKey = @"savedSystemCalendars";
static NSString *const _ORKSavedSystemTimeZonesRestoreKey = @"savedSystemTimeZones";
static NSString *const _ORKOriginalAnswersRestoreKey = @"originalAnswers";
static NSString *const _ORKAnsweredSectionIdentifiersRestoreKey = @"answeredSectionIdentifiers";

- (void)encodeRestorableStateWithCoder:(NSCoder *)coder {
    [super encodeRestorableStateWithCoder:coder];
    
    [coder encodeObject:_savedAnswers forKey:_ORKSavedAnswersRestoreKey];
    [coder encodeObject:_savedAnswerDates forKey:_ORKSavedAnswerDatesRestoreKey];
    [coder encodeObject:_savedSystemCalendars forKey:_ORKSavedSystemCalendarsRestoreKey];
    [coder encodeObject:_savedSystemTimeZones forKey:_ORKSavedSystemTimeZonesRestoreKey];
    [coder encodeObject:_originalAnswers forKey:_ORKOriginalAnswersRestoreKey];
    [coder encodeObject:_identifiersOfAnsweredSections forKey:_ORKAnsweredSectionIdentifiersRestoreKey];
}

- (void)decodeRestorableStateWithCoder:(NSCoder *)coder {
    [super decodeRestorableStateWithCoder:coder];
    
    _savedAnswers = [coder decodeObjectOfClass:[NSMutableDictionary class] forKey:_ORKSavedAnswersRestoreKey];
    _savedAnswerDates = [coder decodeObjectOfClass:[NSMutableDictionary class] forKey:_ORKSavedAnswerDatesRestoreKey];
    _savedSystemCalendars = [coder decodeObjectOfClass:[NSMutableDictionary class] forKey:_ORKSavedSystemCalendarsRestoreKey];
    _savedSystemTimeZones = [coder decodeObjectOfClass:[NSMutableDictionary class] forKey:_ORKSavedSystemTimeZonesRestoreKey];
    _originalAnswers = [coder decodeObjectOfClass:[NSMutableDictionary class] forKey:_ORKOriginalAnswersRestoreKey];
    _identifiersOfAnsweredSections = [coder decodeObjectOfClass:[NSMutableSet class] forKey:_ORKAnsweredSectionIdentifiersRestoreKey];
}

#pragma mark Rotate

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    for (ORKFormItemCell *cell in _formItemCells) {
        [cell setExpectedLayoutWidth:size.width];
    }
}

#pragma mark ORKTextChoiceCellGroupDelegate

- (void)answerChangedForIndexPath:(NSIndexPath *)indexPath {
    
    _skipped = NO;
    [self updateButtonStates];
    [self notifyDelegateOnResultChange];
    
    UITableViewCell *cell = [_tableView cellForRowAtIndexPath:indexPath];
    if ([cell isKindOfClass:[ORKChoiceOtherViewCell class]] == NO) {
        [self handleAutoScrollForNonKeyboardCell:cell];
    }
    
    [self updateAnsweredSections];
    [self buildDataSource:_diffableDataSource];

    // [RDLS:NOTE] removed–immediateNavigation is hardcoded to NO right now
//    if (immediateNavigation) {
//        // Proceed as continueButton tapped
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, DelayBeforeAutoScroll * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
//            ORKSuppressPerformSelectorWarning(
//                                              [self.continueButtonItem.target performSelector:self.continueButtonItem.action withObject:self.continueButtonItem];);
//        });
//    }
}

- (void)tableViewCellHeightUpdated {
    [_tableView reloadData];
}

#pragma mark - ORKChoiceOtherViewCellDelegate

- (void)textChoiceOtherCellDidBecomeFirstResponder:(ORKChoiceOtherViewCell *)choiceOtherViewCell {
    _currentFirstResponderCell = choiceOtherViewCell;
    NSIndexPath *path = [_tableView indexPathForCell:choiceOtherViewCell];
    if (path) {
        [_tableContainer scrollCellVisible:choiceOtherViewCell animated:YES];
    }
}

- (void)textChoiceOtherCellDidResignFirstResponder:(ORKChoiceOtherViewCell *)choiceOtherViewCell {
    if (_currentFirstResponderCell == choiceOtherViewCell) {
        _currentFirstResponderCell = nil;
    }
    NSIndexPath *indexPath = [_tableView indexPathForCell:choiceOtherViewCell];
        
//    ORKChoiceOtherViewCell *touchedCell = choiceOtherViewCell;
    
    ORKTableCellItemIdentifier *itemIdentifier = [_diffableDataSource itemIdentifierForIndexPath:indexPath];
    ORKFormItem *formItem = [self _formItemForFormItemIdentifier:itemIdentifier.formItemIdentifier];
    ORKTextChoiceOther *textChoice = [[[formItem answerFormat] choices] objectAtIndex:itemIdentifier.choiceIndex];
    
    ORK_Log_Debug("[FORMSTEP] textChoiceOtherCellDidResignFirstResponder found textChoice %@", textChoice);
        
    // TODO: rdar://110151218 ([ConditionalFormItems] textChoiceOtherCellDidResignFirstResponder doesn't do anything (ORKFormStepViewController))
    //    Was calling [textChoiceCellGroup textViewDidResignResponderForCellAtIndexPath:indexPath];
    // where that implementation was:
    /*
     NSUInteger index = indexPath.row - _beginningIndexPath.row;
     ORKChoiceOtherViewCell *touchedCell = (ORKChoiceOtherViewCell *) [self cellAtIndex:index withReuseIdentifier:nil];
     ORKTextChoiceOther *textChoice = (ORKTextChoiceOther *) [_helper textChoiceAtIndex:index];
     
     if (touchedCell.textView.text.length > 0) {
         textChoice.textViewText = touchedCell.textView.text;
         [self didSelectCellAtIndexPath:indexPath];
     } else {
         textChoice.textViewText = nil;
         if (!textChoice.textViewInputOptional) {
             [touchedCell setCellSelected:NO highlight:NO];
         }
         _answer = [_helper answerForSelectedIndexes:[self selectedIndexes]];
         [self.delegate answerChangedForIndexPath:indexPath];
     }
     */
}

#pragma mark - ORKlearnMoreStepViewControllerDelegate

- (void)learnMoreButtonPressedWithStep:(ORKLearnMoreInstructionStep *)learnMoreStep {
    [self.taskViewController learnMoreButtonPressedWithStep:learnMoreStep fromStepViewController:self];
}

@end

@implementation ORKFormItem (FormStepViewControllerExtensions)

- (BOOL)requiresSingleSection {
    ORKAnswerFormat *answerFormat = [self impliedAnswerFormat];

    ORKQuestionType questionType = answerFormat.questionType;
    NSArray *singleSectionTypes = @[@(ORKQuestionTypeBoolean),
                                    @(ORKQuestionTypeSingleChoice),
                                    @(ORKQuestionTypeMultipleChoice),
                                    @(ORKQuestionTypeLocation),
                                    @(ORKQuestionTypeSES)];
    
    BOOL multiCellChoices = ([singleSectionTypes containsObject:@(questionType)] &&
                             NO == [answerFormat isKindOfClass:[ORKValuePickerAnswerFormat class]]);

    BOOL scale = (questionType == ORKQuestionTypeScale);
    
    // Items require individual section
    if (multiCellChoices || scale) {
        return YES;
    }
    
    return NO;
}

@end
