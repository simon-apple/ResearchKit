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


#import "ORKSurveyAnswerCellForNumber.h"

#import "ORKTextFieldView.h"

#import "ORKAnswerFormat_Internal.h"
#import "ORKQuestionStep_Internal.h"

#import "ORKHelpers_Internal.h"
#import "ORKSkin.h"

static const CGFloat ErrorLabelTopPadding = 4.0;
static const CGFloat ErrorLabelBottomPadding = 10.0;

@interface ORKSurveyAnswerCellForNumber ()

@property (nonatomic, strong) ORKTextFieldView *textFieldView;
@property (nonatomic, strong) UILabel *errorLabel;

@end


@implementation ORKSurveyAnswerCellForNumber {
    NSNumberFormatter *_numberFormatter;
    NSNumber *_defaultNumericAnswer;
    NSMutableArray *constraints;
}

- (ORKUnitTextField *)textField {
    return _textFieldView.textField;
}

- (void)numberCell_initialize {
    ORKQuestionType questionType = self.step.questionType;
    _numberFormatter = ORKDecimalNumberFormatter();
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(localeDidChange:) name:NSCurrentLocaleDidChangeNotification object:nil];
    
    _textFieldView = [[ORKTextFieldView alloc] init];
    ORKUnitTextField *textField =  _textFieldView.textField;
    
    textField.delegate = self;
    textField.allowsSelection = YES;
    
    if (questionType == ORKQuestionTypeDecimal) {
        textField.keyboardType = UIKeyboardTypeDecimalPad;
    } else if (questionType == ORKQuestionTypeInteger) {
        textField.keyboardType = UIKeyboardTypeNumberPad;
    }
    
    [textField addTarget:self action:@selector(valueFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [self addSubview:_textFieldView];
    
    _errorLabel = [UILabel new];
    [_errorLabel setTextColor: [UIColor redColor]];
    [self.errorLabel setFont:[UIFont preferredFontForTextStyle:UIFontTextStyleFootnote]];
    _errorLabel.numberOfLines = 0;
    _errorLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:_errorLabel];
   
    self.layoutMargins = ORKStandardLayoutMarginsForTableViewCell(self);
    ORKEnableAutoLayoutForViews(@[_textFieldView]);
    [self setUpConstraints];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)localeDidChange:(NSNotification *)note {
    // On a locale change, re-format the value with the current locale
    _numberFormatter.locale = [NSLocale currentLocale];
    [self answerDidChange];
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    self.layoutMargins = ORKStandardLayoutMarginsForTableViewCell(self);
}

- (void)setUpConstraints {
    if (constraints != nil) {
        [NSLayoutConstraint deactivateConstraints:constraints];
    }
    
    constraints = [NSMutableArray new];
    NSDictionary *metrics = @{@"errorLabelTopPadding":@(ErrorLabelTopPadding), @"errorLabelBottomPadding":@(ErrorLabelBottomPadding)};
    NSDictionary *views = NSDictionaryOfVariableBindings(_textFieldView, _errorLabel);
    
    if (self.errorLabel.attributedText == nil) {
            [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[_textFieldView]-|"
                                                                                     options:NSLayoutFormatDirectionLeadingToTrailing | NSLayoutFormatAlignAllLeading
                                                                                     metrics:nil
                                                                                       views:views]];
            
            [constraints addObjectsFromArray:
             [NSLayoutConstraint constraintsWithVisualFormat:@"V:[_errorLabel(==0)]"
                                                     options:0
                                                     metrics:nil
                                                       views:views]];
        } else {
            [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[_textFieldView]-errorLabelTopPadding-[_errorLabel]-|"
                                                                                     options:NSLayoutFormatDirectionLeadingToTrailing | NSLayoutFormatAlignAllLeading
                                                                                     metrics:metrics
                                                                                       views:views]];
        }
    
   
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[_textFieldView]-|"
                                                                             options:(NSLayoutFormatOptions)0
                                                                             metrics:nil
                                                                               views:views]];
    
    [constraints addObject:[NSLayoutConstraint constraintWithItem:_errorLabel
                                                            attribute:NSLayoutAttributeRight
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:_textFieldView
                                                            attribute:NSLayoutAttributeRight
                                                           multiplier:1.0
                                                             constant:0.0]];
    
    [NSLayoutConstraint activateConstraints:constraints];
}

- (BOOL)becomeFirstResponder {
    return [[self textField] becomeFirstResponder];
}

- (void)prepareView {
    if (self.textField == nil ) {
        [self numberCell_initialize];
    }
    
    [self answerDidChange];
    
    [super prepareView];
}

- (BOOL)isAnswerValid {
    id answer = self.answer;
    
    if (answer == ORKNullAnswerValue()) {
        return YES;
    }
    
    ORKAnswerFormat *answerFormat = [self.step impliedAnswerFormat];
    ORKNumericAnswerFormat *numericFormat = (ORKNumericAnswerFormat *)answerFormat;
    return [numericFormat isAnswerValidWithString:self.textField.text];
}

- (BOOL)shouldContinue {
    BOOL isValid = [self isAnswerValid];

    if (!isValid) {
        [self updateErrorLabelWithMessage:ORKLocalizedString(@"RANGE_ALERT_TITLE", nil)];
    }
    
    return isValid;
}

- (void)assignDefaultAnswer {
    if (_defaultNumericAnswer) {
        [self ork_setAnswer:_defaultNumericAnswer];
        if (self.textField) {
            self.textField.text = [_numberFormatter stringFromNumber:_defaultNumericAnswer];
        }
    }
}

- (void)answerDidChange {
    id answer = self.answer;
    ORKAnswerFormat *answerFormat = [self.step impliedAnswerFormat];
    ORKNumericAnswerFormat *numericFormat = (ORKNumericAnswerFormat *)answerFormat;
    
    _defaultNumericAnswer = numericFormat.defaultNumericAnswer;
    NSString *placeholder = self.step.placeholder ? : ORKLocalizedString(@"PLACEHOLDER_TEXT_OR_NUMBER", nil);

    self.textField.manageUnitAndPlaceholder = YES;
    self.textField.unit = numericFormat.unit;
    self.textField.placeholder = placeholder;
    if (answer != ORKNullAnswerValue()) {
        if (!answer) {
            [self assignDefaultAnswer];
        }
        else {
            NSString *displayValue = answer;
            if ([answer isKindOfClass:[NSNumber class]]) {
                displayValue = [_numberFormatter stringFromNumber:answer];
            }
            
            self.textField.text = displayValue;
        }
    }
}

- (void)updateErrorLabelWithMessage:(NSString *)message {
    NSString *separatorString = @":";
    NSString *stringtoParse = message ? : ORKLocalizedString(@"RANGE_ALERT_TITLE", @"");
    NSString *parsedString = [stringtoParse componentsSeparatedByString:separatorString].firstObject;
    
    if (@available(iOS 13.0, *)) {
        
        NSString *errorMessage = [NSString stringWithFormat:@" %@", parsedString];
        NSMutableAttributedString *fullString = [[NSMutableAttributedString alloc] initWithString:errorMessage];
        NSTextAttachment *imageAttachment = [NSTextAttachment new];
        
        UIImageSymbolConfiguration *imageConfig = [UIImageSymbolConfiguration configurationWithPointSize:12 weight:UIImageSymbolWeightRegular scale:UIImageSymbolScaleMedium];
        UIImage *exclamationMarkImage = [UIImage systemImageNamed:@"exclamationmark.circle"];
        UIImage *configuredImage = [exclamationMarkImage imageByApplyingSymbolConfiguration:imageConfig];
        
        imageAttachment.image = [configuredImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        
        NSAttributedString *imageString = [NSAttributedString attributedStringWithAttachment:imageAttachment];
        
        [fullString insertAttributedString:imageString atIndex:0];
        
        self.errorLabel.attributedText = fullString;
    } else {
        NSMutableAttributedString *fullString = [[NSMutableAttributedString alloc] initWithString:parsedString];
        self.errorLabel.attributedText = fullString;
    }
    
    [self setUpConstraints];
}

#pragma mark - UITextFieldDelegate

- (void)valueFieldDidChange:(UITextField *)textField {
    ORKNumericAnswerFormat *answerFormat = (ORKNumericAnswerFormat *)[self.step impliedAnswerFormat];
    NSString *sanitizedText = [answerFormat sanitizedTextFieldText:[textField text] decimalSeparator:[_numberFormatter decimalSeparator]];
    textField.text = sanitizedText;
    [self setAnswerWithText:textField.text];
    
    BOOL isValid = [self isAnswerValid];
        
    if (isValid && _errorLabel.attributedText != nil) {
        _errorLabel.attributedText = nil;
        [self setUpConstraints];
    }
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
    [self ork_setAnswer:ORKNullAnswerValue()];
    return YES;
}

- (void)setAnswerWithText:(NSString *)text {
    BOOL updateInput = NO;
    id answer = ORKNullAnswerValue();
    if (text.length) {
        answer = [[NSDecimalNumber alloc] initWithString:text locale:[NSLocale currentLocale]];
        if (!answer) {
            answer = ORKNullAnswerValue();
            updateInput = YES;
        }
    }
    
    [self ork_setAnswer:answer];
    if (updateInput) {
        [self answerDidChange];
    }
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    BOOL isValid = [self isAnswerValid];
    if (!isValid) {
        
    }
    
    return YES;
}

+ (BOOL)shouldDisplayWithSeparators {
    return NO;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    BOOL isValid = [self isAnswerValid];
    
    if (!isValid) {
       [self updateErrorLabelWithMessage:ORKLocalizedString(@"RANGE_ALERT_TITLE", nil)];
        return NO;
    }
    
    [self.textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    NSString *text = self.textField.text;
    [self setAnswerWithText:text];
}

@end
