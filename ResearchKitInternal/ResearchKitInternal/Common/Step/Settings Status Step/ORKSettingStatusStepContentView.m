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

#import "ORKSettingStatusStepContentView.h"

#import "ORKIUtils.h"

#import <ResearchKit/ORKHelpers_Internal.h>
#import <ResearchKit/ORKSkin.h>

#import <ResearchKitUI/ORKNavigationContainerView_Internal.h>
#import <ResearchKitUI/ORKStepViewController_Internal.h>


double const ContentViewLabelBottomPadding = 15.0;
double const ContentViewLeftRightPadding = 10.0;
double const ContentViewTopPadding = 10.0;
double const NavigationFooterViewTopMargin = 5.0;
double const NavigationFooterViewBottomMargin = 15.0;
double const SettingStatusIconRightPadding = 8.0;


@interface ORKSettingStatusStepContentView ()

@property (nonatomic, copy, nullable) ORKSettingStatusStepContentViewEventHandler viewEventHandler;

@end

@implementation ORKSettingStatusStepContentView {
    NSString *_title;
    NSString *_detailText;
    
    UILabel *_titleLabel;
    UILabel *_detailTextLabel;
    
    UIImageView *_settingStatusImageView;
    UILabel *_settingStatusTextLabel;
    
    UIButton *_editSettingsButton;
    
    ORKNavigationContainerView *_navigationFooterView;
    
    NSMutableArray<NSLayoutConstraint *> *_layoutConstraints;
}

- (instancetype)initWithTitle:(NSString *)title detailText:(NSString *)detailText {
    self = [super initWithFrame:CGRectZero];
    self.layoutMargins = ORKStandardFullScreenLayoutMarginsForView(self);
    
    if (self) {
        self.translatesAutoresizingMaskIntoConstraints = NO;
        _isSettingEnabled = NO;
        _title = title;
        _detailText = detailText;
        
        [self _setupSubviews];
        [self _setupConstraints];
        [self _updateAppearance];
    }
    
    return self;
}

- (void)setIsSettingEnabled:(BOOL)isSettingEnabled {
    _isSettingEnabled = isSettingEnabled;
    [self _updateAppearance];
}

- (void)setViewEventHandler:(ORKSettingStatusStepContentViewEventHandler)handler {
    _viewEventHandler = [handler copy];
}

- (void)invokeViewEventHandlerWithEvent:(ORKSettingStatusStepContentViewEvent)event {
    if (self.viewEventHandler){
        dispatch_async(dispatch_get_main_queue(), ^{
            self.viewEventHandler(event);
        });
    }
}

- (void)_setupSubviews {
    [self _setupTitleLabel];
    [self _setupStatusIconLabel];
    [self _setupDetailTextLabel];
    [self _setupEditSettingsButton];
    [self _setupNavigationFooterView];
}

- (void)_setupTitleLabel {
    if (!_titleLabel) {
        _titleLabel = [UILabel new];
        _titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _titleLabel.text = _title;
        _titleLabel.textAlignment = NSTextAlignmentLeft;
        _titleLabel.numberOfLines = 0;
        _titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        
        [self addSubview:_titleLabel];
    }
}

- (void)_setupStatusIconLabel {
    if (!_settingStatusImageView) {
        _settingStatusImageView = [UIImageView new];
        _settingStatusImageView.translatesAutoresizingMaskIntoConstraints = NO;
        
        [self addSubview:_settingStatusImageView];
    }
    
    if (!_settingStatusTextLabel) {
        _settingStatusTextLabel = [UILabel new];
        _settingStatusTextLabel.translatesAutoresizingMaskIntoConstraints = NO;
        
        [self addSubview:_settingStatusTextLabel];
    }
}

- (void)_setupDetailTextLabel {
    if (!_detailTextLabel) {
        _detailTextLabel = [UILabel new];
        _detailTextLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _detailTextLabel.text = _detailText;
        _detailTextLabel.textAlignment = NSTextAlignmentLeft;
        _detailTextLabel.numberOfLines = 0;
        _detailTextLabel.lineBreakMode = NSLineBreakByWordWrapping;
        
        [self addSubview:_detailTextLabel];
    }
}

- (void)_setupEditSettingsButton {
    if (!_editSettingsButton) {
        _editSettingsButton = [UIButton new];
        _editSettingsButton.translatesAutoresizingMaskIntoConstraints = NO;
        [_editSettingsButton setTitle:ORKILocalizedString(@"SETTING_STATUS_STEP_EDIT_SETTINGS", @"")
                             forState:UIControlStateNormal];
        [_editSettingsButton setTitleColor:self.tintColor forState:UIControlStateNormal];
        _editSettingsButton.backgroundColor = [UIColor clearColor];
        [_editSettingsButton addTarget:self
                                action:@selector(_goToSettingsButtonPressed)
                      forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview:_editSettingsButton];
    }
}

- (void)_setupNavigationFooterView {
    if (!_navigationFooterView) {
        _navigationFooterView = [ORKNavigationContainerView new];
        _navigationFooterView.translatesAutoresizingMaskIntoConstraints = NO;
        _navigationFooterView.continueEnabled = YES;
        _navigationFooterView.topMargin = NavigationFooterViewTopMargin;
        _navigationFooterView.bottomMargin = NavigationFooterViewBottomMargin;
        _navigationFooterView.backgroundColor = ORKColor(ORKNavigationContainerColorKey);
        
        [self addSubview:_navigationFooterView];
    }
}

- (void)_setupConstraints {
    if (_layoutConstraints) {
        [NSLayoutConstraint deactivateConstraints:_layoutConstraints];
        _layoutConstraints = nil;
    }
    
    _layoutConstraints = [NSMutableArray new];
    
    [_layoutConstraints addObjectsFromArray:[self _titleLabelConstraints]];
    [_layoutConstraints addObjectsFromArray:[self _statusIconLabelConstraints]];
    [_layoutConstraints addObjectsFromArray:[self _detailTextLabelConstraints]];
    [_layoutConstraints addObjectsFromArray:[self _editSettingsButtonConstraints]];
    [_layoutConstraints addObjectsFromArray:[self _navigationFooterViewConstraints]];
    
    [NSLayoutConstraint activateConstraints:_layoutConstraints];
}

- (NSArray<NSLayoutConstraint *> *)_titleLabelConstraints {
    return @[
        [_titleLabel.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:ContentViewLeftRightPadding],
        [_titleLabel.topAnchor constraintEqualToAnchor:self.topAnchor constant:ContentViewTopPadding],
        [_titleLabel.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-ContentViewLeftRightPadding]
    ];
}

- (NSArray<NSLayoutConstraint *> *)_statusIconLabelConstraints {
    return @[
        [_settingStatusImageView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:ContentViewLeftRightPadding],
        [_settingStatusImageView.topAnchor constraintEqualToAnchor:_titleLabel.bottomAnchor constant:ContentViewLabelBottomPadding],
        [_settingStatusTextLabel.leadingAnchor constraintEqualToAnchor:_settingStatusImageView.trailingAnchor constant:SettingStatusIconRightPadding],
        [_settingStatusTextLabel.centerYAnchor constraintEqualToAnchor:_settingStatusImageView.centerYAnchor]
    ];
}

- (NSArray<NSLayoutConstraint *> *)_detailTextLabelConstraints {
    return @[
        [_detailTextLabel.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:ContentViewLeftRightPadding],
        [_detailTextLabel.topAnchor constraintEqualToAnchor:_settingStatusImageView.bottomAnchor constant:ContentViewLabelBottomPadding],
        [_detailTextLabel.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-ContentViewLeftRightPadding]
    ];
}

- (NSArray<NSLayoutConstraint *> *)_editSettingsButtonConstraints {
    return @[
        [_editSettingsButton.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:ContentViewLeftRightPadding],
        [_editSettingsButton.topAnchor constraintEqualToAnchor:_detailTextLabel.bottomAnchor constant:ContentViewLabelBottomPadding]
    ];
}

- (NSArray<NSLayoutConstraint *> *)_navigationFooterViewConstraints {
    return @[
        [_navigationFooterView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor],
        [_navigationFooterView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor],
        [_navigationFooterView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor]
    ];
}

- (void)_goToSettingsButtonPressed {
    [self invokeViewEventHandlerWithEvent:ORKSettingStatusStepContentViewEventGoToSettingsPressed];
}

- (UIBarButtonItem *)_goToSettingsBarButtonItem {
    return [[UIBarButtonItem alloc] initWithTitle:ORKILocalizedString(@"SETTING_STATUS_STEP_GO_TO_SETTINGS", @"")
                                            style:UIBarButtonItemStyleDone
                                           target:self
                                           action:@selector(_goToSettingsButtonPressed)];
}

- (void)_goForwardButtonPressed {
    [self invokeViewEventHandlerWithEvent:ORKSettingStatusStepContentViewEventGoForwardPressed];
}

- (UIBarButtonItem *)_goForwardButtonItem {
    return [[UIBarButtonItem alloc] initWithTitle:ORKLocalizedString(@"BUTTON_NEXT", nil) style:UIBarButtonItemStylePlain target:self action:@selector(_goForwardButtonPressed)];
}

- (void)_skipButtonPressed {
    [self invokeViewEventHandlerWithEvent:ORKSettingStatusStepContentViewEventSkipButtonPressed];
}

- (UIBarButtonItem *)_skipButtonItem {
    return [[UIBarButtonItem alloc] initWithTitle:ORKLocalizedString(@"BUTTON_SKIP", nil) style:UIBarButtonItemStylePlain target:self action:@selector(_skipButtonPressed)];
}

- (void)_updateAppearance {
    if (!_isSettingEnabled) {
        _settingStatusImageView.image = [UIImage systemImageNamed:@"x.circle.fill"];
        _settingStatusImageView.tintColor = [UIColor lightGrayColor];
        _settingStatusTextLabel.text = ORKILocalizedString(@"SETTING_STATUS_STEP_TURNED_OFF", @"");
        
        _editSettingsButton.hidden = YES;
        
        _navigationFooterView.continueButtonItem = [self _goToSettingsBarButtonItem];
        _navigationFooterView.skipButtonItem = [self _skipButtonItem];
        _navigationFooterView.optional = YES;
    } else {
        _settingStatusImageView.image = [UIImage systemImageNamed:@"checkmark.circle.fill"];
        _settingStatusImageView.tintColor = [UIColor greenColor];
        
        _editSettingsButton.hidden = NO;
        
        _settingStatusTextLabel.text = ORKILocalizedString(@"SETTING_STATUS_STEP_TURNED_ON", @"");
        _navigationFooterView.continueButtonItem = [self _goForwardButtonItem];
        _navigationFooterView.skipButtonItem = nil;
    }
}

@end
