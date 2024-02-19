/*
 Copyright (c) 2022, Apple Inc. All rights reserved.
 
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

// apple-internal
#import "ORKTypingStepViewController.h"
#import "ORKTypingStep.h"
#import "ORKTypingResult.h"

#import "ORKIUtils.h"

#import <ResearchKit/ORKCollectionResult.h>
#import <ResearchKit/ORKHelpers_Internal.h>
#import <ResearchKitUI/ORKStepViewController_Internal.h>

@interface ORKTypingStepViewController () <UITextFieldDelegate>

@property (nonatomic, strong) UILabel *textLabel;
@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, strong) NSString *prevText;
@property (nonatomic, strong) NSMutableArray <NSArray *> *errors;
@property (nonatomic) NSInteger numDeletes;
@property (nonatomic) NSArray<NSLayoutConstraint *> *constraints;

@end

@implementation ORKTypingStepViewController

- (ORKTypingStep *)typingStep {
    return (ORKTypingStep *)self.step;
}

- (void)stepDidChange {
    [super stepDidChange];
    
    if (self.step && [self isViewLoaded]) {
        [self setupTextLabel];
        [self setupTextField];
        [self setupConstraints];
        [self setupErrorTracking];
    }
}

- (void)setupTextLabel {
    [self.textLabel removeFromSuperview];
    self.textLabel = nil;
    
    self.textLabel = UILabel.new;
    self.textLabel.text = self.typingStep.textToType;
    self.textLabel.textColor = UIColor.systemGrayColor;
    
    self.textLabel.font = [UIFont systemFontOfSize:20.0 weight:UIFontWeightMedium];
    self.textLabel.numberOfLines = 0;
    self.textLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.textLabel];
}

- (void)setupTextField {
    [self.textField removeFromSuperview];
    self.textField = nil;
    
    self.textField = UITextField.new;
    self.textField.font = [UIFont systemFontOfSize:18.0 weight:UIFontWeightRegular];
    self.textField.placeholder = ORKILocalizedString(@"Type the above text here", nil);
    self.textField.returnKeyType = UIReturnKeyDone;
    self.textField.borderStyle = UITextBorderStyleRoundedRect;
    self.textField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.textField.delegate = self;
    [self.textField addTarget:self
                       action:@selector(textFieldDidChange:)
             forControlEvents:UIControlEventEditingChanged];
    [self.view addSubview:self.textField];
}

- (void)setupErrorTracking {
    [self.errors removeAllObjects];
    self.errors = nil;
    self.errors = [[NSMutableArray alloc] init];
    
    self.prevText = @"";
}

- (void)setupConstraints {
    if (self.constraints) {
        [NSLayoutConstraint deactivateConstraints:self.constraints];
    }
    self.textLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.textField.translatesAutoresizingMaskIntoConstraints = NO;
    self.constraints = nil;
    self.constraints = @[
        [NSLayoutConstraint constraintWithItem:self.textLabel
                                     attribute:NSLayoutAttributeTop
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:self.view
                                     attribute:NSLayoutAttributeTop
                                    multiplier:1.0
                                      constant:10.0],
        [NSLayoutConstraint constraintWithItem:self.textLabel
                                     attribute:NSLayoutAttributeLeading
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:self.view
                                     attribute:NSLayoutAttributeLeading
                                    multiplier:1.0
                                      constant:20],
        [NSLayoutConstraint constraintWithItem:self.textLabel
                                     attribute:NSLayoutAttributeTrailing
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:self.view
                                     attribute:NSLayoutAttributeTrailing
                                    multiplier:1.0
                                      constant:-20],
        [NSLayoutConstraint constraintWithItem:self.textField
                                     attribute:NSLayoutAttributeTop
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:self.textLabel
                                     attribute:NSLayoutAttributeBottom
                                    multiplier:1.0
                                      constant:50.0],
        [NSLayoutConstraint constraintWithItem:self.textField
                                     attribute:NSLayoutAttributeLeading
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:self.view
                                     attribute:NSLayoutAttributeLeading
                                    multiplier:1.0
                                      constant:20],
        [NSLayoutConstraint constraintWithItem:self.textField
                                     attribute:NSLayoutAttributeTrailing
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:self.view
                                     attribute:NSLayoutAttributeTrailing
                                    multiplier:1.0
                                      constant:-20],
        [NSLayoutConstraint constraintWithItem:self.textField
                                     attribute:NSLayoutAttributeHeight
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:nil
                                     attribute:NSLayoutAttributeNotAnAttribute
                                    multiplier:1.0
                                      constant:35.0]
    ];
    [NSLayoutConstraint activateConstraints:self.constraints];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    [super goForward];
    return YES;
}

- (void)textFieldDidChange:(UITextField *)textField {
    NSString *currString = textField.text;
    NSUInteger currLength = currString.length;
    
    // Ignore characters outside of range
    if (currLength == 0 || currLength > self.typingStep.textToType.length) {
        self.prevText = currString;
        return;
    }
    
    // If previous text is longer, user deleted
    if (self.prevText.length >= currLength) {
        self.numDeletes += 1;
        self.prevText = currString;
        return;
    }
    
    NSInteger currIndex = currLength - 1;
    NSString *currChar = [currString substringWithRange:NSMakeRange(currIndex, 1)];
    NSString *expectedChar = [self.typingStep.textToType substringWithRange:NSMakeRange(currIndex, 1)];
    
    // User typed wrong character
    if (![currChar isEqualToString:expectedChar]) {
        NSArray *error = [NSArray arrayWithObjects:currChar, expectedChar, nil];
        [self.errors addObject:error];
    }
    
    self.prevText = currString;
    NSLog(@"Expected: %@, Received: %@", expectedChar, currChar);
}

- (BOOL)hasPreviousStep {
    return NO;
}

- (ORKStepResult *)result {
    ORKStepResult *stepResult = [super result];
    
    ORKTypingResult *result = [[ORKTypingResult alloc] initWithIdentifier:self.typingStep.identifier];
    result.errors = self.errors;
    result.startDate = stepResult.startDate;
    result.endDate = stepResult.endDate;
    result.timeTakenToType = [result.endDate timeIntervalSinceDate:result.startDate];
    result.numDeletes = self.numDeletes;
    result.totalCharacterCount = self.typingStep.textToType.length;
    
    NSInteger finalErrorCount = 0;
    for (int i = 0; i < self.typingStep.textToType.length; i++) {
        // Any extra characters count as an error
        if (i >= self.textField.text.length) {
            finalErrorCount += 1;
            continue;
        }
        NSString *typedChar = [self.textField.text substringWithRange:NSMakeRange(i, 1)];
        NSString *expectedChar = [self.typingStep.textToType substringWithRange:NSMakeRange(i, 1)];
        
        // Characters at the same index don't match
        if (typedChar != expectedChar) {
            finalErrorCount += 1;
        }
    }
    result.finalErrorCount = finalErrorCount;

    NSMutableArray *results = [[NSMutableArray alloc] init];
    if (stepResult.results) {
        results = [stepResult.results mutableCopy];
    }
    
    [results addObject:result];
    
    stepResult.results = [results copy];
    return stepResult;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self stepDidChange];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // Show keyboard right away
    [self.textField becomeFirstResponder];
}

@end
