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

#import "ORKSettingStatusStepViewController.h"

#import "ORKITaskViewController.h"
#import "ORKSettingStatusCollector.h"
#import "ORKSettingStatusResult.h"
#import "ORKSettingStatusSnapshot.h"
#import "ORKSettingStatusStep.h"
#import "ORKSettingStatusStepContainerView.h"
#import "ORKSettingStatusStepContentView.h"
#import "ORKSettingStatusStepViewController.h"

#import <ResearchKitUI/ORKStepContainerView_Private.h>

#define ORKSettingStatusReduceLoudSoundsSensitiveURLString "prefs:root=Sounds&path=HEADPHONE_LEVEL_LIMIT_SETTING"
#define ORKSettingStatusApplicationString "com.apple.Preferences"


@implementation ORKSettingStatusStepViewController {
    ORKSettingStatusCollector *_settingStatusCollector;
    ORKSettingStatusStepContentView *_settingsStatusStepContentView;
    ORKSettingStatusStepContainerView *_stepContainerView;
    NSArray<NSLayoutConstraint *> *_contentViewConstraints;
    
    BOOL _initialEnabledStatusCollected;
    BOOL _initialEnabledStatus;
}

- (instancetype)ORKSettingStatusStepViewController_initWithResult:(ORKResult *)result {
    ORKStepResult *stepResult = (ORKStepResult *)result;
    
    if (stepResult && stepResult.results.count > 0) {
        ORKSettingStatusResult *settingStatusResult = (ORKSettingStatusResult *)stepResult.firstResult;
        
        if (settingStatusResult) {
            _initialEnabledStatusCollected = YES;
            _initialEnabledStatus = settingStatusResult.isEnabledAtStart;
            return self;
        }
    }
    
    _initialEnabledStatusCollected = NO;
    _initialEnabledStatus = NO;
    return self;
}

- (instancetype)initWithStep:(ORKStep *)step {
    self = [super initWithStep:step];
    return [self ORKSettingStatusStepViewController_initWithResult:nil];
}

- (instancetype)initWithStep:(ORKStep *)step result:(ORKResult *)result {
    self = [super initWithStep:step];
    return [self ORKSettingStatusStepViewController_initWithResult:result];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self _setupContentView];
    [self _setupStepContainerView];
    [self _setupConstraints];
    [self _setupSettingStatusCollector];
    [self _checkSettingStatus];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(_checkSettingStatus)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.taskViewController setNavigationBarColor:self.view.backgroundColor];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (ORKStepResult *)result {
    ORKStepResult *stepResult = [super result];
    NSMutableArray *results = [NSMutableArray arrayWithArray:stepResult.results];
    
    ORKSettingStatusStep *settingStatusStep = [self _orkSettingStatusStep];
    
    ORKSettingStatusResult *settingStatusResult = [[ORKSettingStatusResult alloc] initWithIdentifier:settingStatusStep.identifier];
    settingStatusResult.isEnabledAtStart = _initialEnabledStatus;
    settingStatusResult.isEnabledAtEnd = _stepContainerView.isSettingEnabled;
    settingStatusResult.settingType = settingStatusStep.settingType;

    [results addObject:settingStatusResult];
    stepResult.results = [results copy];

    return stepResult;
}

- (void)_setupContentView {
    if (!_settingsStatusStepContentView) {
        ORKSettingStatusStep *settingStatusStep = [self _orkSettingStatusStep];
        _settingsStatusStepContentView = [[ORKSettingStatusStepContentView alloc] initWithTitle:settingStatusStep.title
                                                                                           text:settingStatusStep.text];
    }
    
    __weak typeof(self) weakSelf = self;
    [_settingsStatusStepContentView setViewEventHandler:^(ORKSettingStatusStepContentViewEvent event) {
        [weakSelf _handleContentViewEvent:event];
    }];
}

- (void)_setupStepContainerView {
    if (!_stepContainerView) {
        _stepContainerView = [[ORKSettingStatusStepContainerView alloc] initWithStatusStepContentView:_settingsStatusStepContentView];
        
        [self.view addSubview:_stepContainerView];
    }
}

- (void)_setupConstraints {
    if (_contentViewConstraints) {
        [NSLayoutConstraint deactivateConstraints:_contentViewConstraints];
        _contentViewConstraints = nil;
    }
    
    _contentViewConstraints = @[
        [[_stepContainerView topAnchor] constraintEqualToAnchor:self.view.topAnchor],
        [[_stepContainerView bottomAnchor] constraintEqualToAnchor:self.view.bottomAnchor],
        [[_stepContainerView leadingAnchor] constraintEqualToAnchor:self.view.leadingAnchor],
        [[_stepContainerView trailingAnchor] constraintEqualToAnchor:self.view.trailingAnchor]
    ];
    
    [NSLayoutConstraint activateConstraints:_contentViewConstraints];
}

- (void)_setupSettingStatusCollector {
    ORKSettingStatusStep *settingsStatusStep = [self _orkSettingStatusStep];
    
    switch (settingsStatusStep.settingType) {
        case ORKSettingTypeReduceLoudSounds:
            _settingStatusCollector = [ORKAudioSettingStatusCollector new];
            break;
            
        default:
            break;
    }
}

- (void)_checkSettingStatus {
    if (_settingStatusCollector) {
        ORKSettingStatusStep *settingStatusStep = [self _orkSettingStatusStep];
        ORKSettingStatusSnapshot *settingStatusSnapshot = [_settingStatusCollector getSettingStatusForSettingType:settingStatusStep.settingType];
        [_stepContainerView setIsSettingEnabled:settingStatusSnapshot.isEnabled];
        
        if (!_initialEnabledStatusCollected) {
            _initialEnabledStatusCollected = YES;
            _initialEnabledStatus = settingStatusSnapshot.isEnabled;
        }
    }
}

- (void)_handleContentViewEvent:(ORKSettingStatusStepContentViewEvent)event {
    switch (event) {
        case ORKSettingStatusStepContentViewEventGoForwardPressed:
            [self goForward];
            break;
        case ORKSettingStatusStepContentViewEventSkipButtonPressed:
            [self skipForward];
            break;
        case ORKSettingStatusStepContentViewEventGoToSettingsPressed:
            [self _navigateToSetting];
            break;
        default:
            break;
    }
}

- (void)_navigateToSetting {
    ORKITaskViewController *taskVC = (ORKITaskViewController *)[self taskViewController];
    SEL sensitiveURLSelector = @selector(taskViewController:goToSettingsButtonPressedWithSettingStatusStep:sensitiveURLString:applicationString:);
    
    if (taskVC == nil || taskVC.internalDelegate == nil) {
        return;
    }
    
    if ([taskVC.internalDelegate respondsToSelector:sensitiveURLSelector]) {
        ORKSettingStatusStep *settingStatusStep = [self _orkSettingStatusStep];
        NSString *sensitiveURLString = [self _getSensitiveURLForSettingType:settingStatusStep.settingType];
        
        [taskVC.internalDelegate taskViewController:taskVC goToSettingsButtonPressedWithSettingStatusStep:settingStatusStep
                                 sensitiveURLString:sensitiveURLString
                                  applicationString:@ORKSettingStatusApplicationString];
    }
}

- (NSString *)_getSensitiveURLForSettingType:(ORKSettingType)settingType {
    switch (settingType) {
        case ORKSettingTypeReduceLoudSounds:
            return @ORKSettingStatusReduceLoudSoundsSensitiveURLString;
            break;
            
        default:
            @throw [NSException exceptionWithName:NSGenericException reason:@"There is no sensitive URL for the provided ORKSettingType." userInfo:nil];
            break;
    }
}

- (ORKSettingStatusStep *)_orkSettingStatusStep {
    ORKSettingStatusStep *settingStatusStep = (ORKSettingStatusStep *)self.step;
    
    if (![NSStringFromClass([settingStatusStep class]) isEqualToString:NSStringFromClass([ORKSettingStatusStep class])]) {
        @throw [NSException exceptionWithName:NSGenericException reason:@"A ORKSettingStatusStep must be used with the ORKSettingStatusStepViewController." userInfo:nil];
    }
    
    return settingStatusStep;
}

@end
