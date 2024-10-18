//  ORKCoreSerializationEntryProvider.m
//  ORKCatalog
//
//  Created by Pariece Mckinney on 6/23/24.
//  Copyright © 2024 researchkit.org. All rights reserved.
//

#import "ORKCoreSerializationEntryProvider.h"

#import "ORKESerialization+Helpers.h"

#import <ResearchKit/ResearchKit.h>
#import <ResearchKit/ResearchKit_Private.h>


@implementation ORKCoreSerializationEntryProvider

- (NSMutableDictionary<NSString *,ORKESerializableTableEntry *> *)serializationEncodingTable {
    static NSMutableDictionary<NSString *, ORKESerializableTableEntry *> *internalEncodingTable = nil;
    
    internalEncodingTable =
        [@{
           ENTRY(ORKResultSelector,
                 ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
                     ORKResultSelector *selector = [[ORKResultSelector alloc] initWithTaskIdentifier:GETPROP(dict, taskIdentifier)
                                                                                      stepIdentifier:GETPROP(dict, stepIdentifier)
                                                                                    resultIdentifier:GETPROP(dict, resultIdentifier)];
                     return selector;
                 },
                 (@{
                      PROPERTY(taskIdentifier, NSString, NSObject, YES, nil, nil),
                      PROPERTY(stepIdentifier, NSString, NSObject, YES, nil, nil),
                      PROPERTY(resultIdentifier, NSString, NSObject, YES, nil, nil),
                      })),
           ENTRY(ORKOrderedTask,
                 ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
                     ORKOrderedTask *task = [[ORKOrderedTask alloc] initWithIdentifier:GETPROP(dict, identifier)
                                                                                 steps:GETPROP(dict, steps)];
                     return task;
                 },
                 (@{
                      PROPERTY(identifier, NSString, NSObject, NO, nil, nil),
                      PROPERTY(steps, ORKStep, NSArray, NO, nil, nil),
                      })),
           ENTRY(ORKNavigableOrderedTask,
                 ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
                     ORKNavigableOrderedTask *task = [[ORKNavigableOrderedTask alloc] initWithIdentifier:GETPROP(dict, identifier)
                                                                                                   steps:GETPROP(dict, steps)];
                     return task;
                 },
                 (@{
                      PROPERTY(stepNavigationRules, ORKStepNavigationRule, NSMutableDictionary, YES, nil, nil),
                      PROPERTY(skipStepNavigationRules, ORKSkipStepNavigationRule, NSMutableDictionary, YES, nil, nil),
                      PROPERTY(stepModifiers, ORKStepModifier, NSMutableDictionary, YES, nil, nil),
                      PROPERTY(shouldReportProgress, NSNumber, NSObject, YES, nil, nil),
                      })),
           ENTRY(ORKStep,
                 ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
                     ORKStep *step = [[ORKStep alloc] initWithIdentifier:GETPROP(dict, identifier)];
                     return step;
                 },
                 (@{
                    PROPERTY(identifier, NSString, NSObject, NO, nil, nil),
                    PROPERTY(optional, NSNumber, NSObject, YES, nil, nil),
                    PROPERTY(title, NSString, NSObject, YES, nil, nil),
                    PROPERTY(text, NSString, NSObject, YES, nil, nil),
                    PROPERTY(detailText, NSString, NSObject, YES, nil, nil),
                    PROPERTY(headerTextAlignment, NSNumber, NSObject, YES, nil, nil),
                    PROPERTY(footnote, NSString, NSObject, YES, nil, nil),
                    PROPERTY(shouldTintImages, NSNumber, NSObject, YES, nil, nil),
                    PROPERTY(useSurveyMode, NSNumber, NSObject, YES, nil, nil),
                    PROPERTY(bodyItems, ORKBodyItem, NSArray, YES, nil, nil),
                    PROPERTY(imageContentMode, NSNumber, NSObject, YES, nil, nil),
                    IMAGEPROPERTY(iconImage, NSObject, YES),
                    IMAGEPROPERTY(auxiliaryImage, NSObject, YES),
                    IMAGEPROPERTY(image, NSObject, YES),
                    PROPERTY(bodyItemTextAlignment, NSNumber, NSObject, YES, nil, nil),
                    PROPERTY(buildInBodyItems, NSNumber, NSObject, YES, nil, nil),
                    PROPERTY(useExtendedPadding, NSNumber, NSObject, YES, nil, nil),
                    PROPERTY(earlyTerminationConfiguration, ORKEarlyTerminationConfiguration, NSObject, YES, nil, nil),
                    PROPERTY(shouldAutomaticallyAdjustImageTintColor, NSNumber, NSObject, YES, nil, nil),
                    })),
           ENTRY(ORKQuestionStep,
                   ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
                       return [[ORKQuestionStep alloc] initWithIdentifier:GETPROP(dict, identifier)];
                   },
                   (@{
                      PROPERTY(answerFormat, ORKAnswerFormat, NSObject, YES, nil, nil),
                      PROPERTY(placeholder, NSString, NSObject, YES, nil, nil),
                      PROPERTY(question, NSString, NSObject, YES, nil, nil),
                      PROPERTY(useCardView, NSNumber, NSObject, YES, nil, nil),
                      PROPERTY(learnMoreItem, ORKLearnMoreItem, NSObject, YES, nil, nil),
                      PROPERTY(tagText, NSString, NSObject, YES, nil, nil),
                      PROPERTY(presentationStyle, NSString, NSObject, YES, nil, nil)
                      })),
           ENTRY(ORKInstructionStep,
                 ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
                     return [[ORKInstructionStep alloc] initWithIdentifier:GETPROP(dict, identifier)];
                 },
                 (@{
                    PROPERTY(detailText, NSString, NSObject, YES, nil, nil),
                    PROPERTY(footnote, NSString, NSObject, YES, nil, nil),
                    PROPERTY(centerImageVertically, NSNumber, NSObject, YES, nil, nil),
                    })),
           ENTRY(ORKFormStep,
                 ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
                     return [[ORKFormStep alloc] initWithIdentifier:GETPROP(dict, identifier)];
                 },
                 (@{
                    PROPERTY(formItems, ORKFormItem, NSArray, YES, nil, nil),
                    PROPERTY(footnote, NSString, NSObject, YES, nil, nil),
                    PROPERTY(useCardView, NSNumber, NSObject, YES, nil, nil),
                    PROPERTY(autoScrollEnabled, NSNumber, NSObject, YES, nil, nil),
                    PROPERTY(footerText, NSString, NSObject, YES, nil, nil),
                    PROPERTY(cardViewStyle, NSNumber, NSObject, YES, nil, nil),
                    })),
           ENTRY(ORKFormItem,
                 ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
                    ORKFormItem* formItem = [[ORKFormItem alloc] initWithIdentifier:GETPROP(dict, identifier) text:GETPROP(dict, text) answerFormat:GETPROP(dict, answerFormat)];
                    return formItem;
                 },
                 (@{
                    PROPERTY(identifier, NSString, NSObject, NO, nil, nil),
                    PROPERTY(optional, NSNumber, NSObject, YES, nil, nil),
                    PROPERTY(showsProgress, NSNumber, NSObject, YES, nil, nil),
                    PROPERTY(text, NSString, NSObject, NO, nil, nil),
                    PROPERTY(detailText, NSString, NSObject, YES, nil, nil),
                    PROPERTY(placeholder, NSString, NSObject, YES, nil, nil),
                    PROPERTY(answerFormat, ORKAnswerFormat, NSObject, NO, nil, nil),
                    PROPERTY(learnMoreItem, ORKLearnMoreItem, NSObject, YES, nil, nil),
                    PROPERTY(tagText, NSString, NSObject, YES, nil, nil),
                    })),
           ENTRY(ORKEarlyTerminationConfiguration,
                 ^id(__unused NSDictionary *dict, __unused ORKESerializationPropertyGetter getter) {
                     ORKEarlyTerminationConfiguration *configuration = [[ORKEarlyTerminationConfiguration alloc] initWithButtonText:GETPROP(dict, buttonText)
                                                                                                               earlyTerminationStep:GETPROP(dict, earlyTerminationStep)];
                     return configuration;
                 },
                 (@{
                    PROPERTY(buttonText, NSString, NSObject, NO, nil, nil),
                    PROPERTY(earlyTerminationStep, ORKStep, NSObject, NO, nil, nil),
                    })),
           ENTRY(ORKBodyItem,
                 ^id(__unused NSDictionary *dict, __unused ORKESerializationPropertyGetter getter) {
                     ORKBodyItem *bodyItem = [[ORKBodyItem alloc] initWithText:GETPROP(dict, text)
                                                                    detailText:GETPROP(dict, detailText)
                                                                         image:nil
                                                                 learnMoreItem:GETPROP(dict, learnMoreItem)
                                                                 bodyItemStyle:[GETPROP(dict, bodyItemStyle) intValue]
                                                                  useCardStyle:GETPROP(dict, useCardStyle)
                                                               alignImageToTop:GETPROP(dict, alignImageToTop)];
                     return bodyItem;
                 },
                 (@{
                    PROPERTY(text, NSString, NSObject, NO, nil, nil),
                    PROPERTY(detailText, NSString, NSObject, NO, nil, nil),
                    PROPERTY(bodyItemStyle, NSNumber, NSObject, NO, nil, nil),
                    IMAGEPROPERTY(image, NSObject, YES),
                    PROPERTY(learnMoreItem, ORKLearnMoreItem, NSObject, YES, nil, nil),
                    PROPERTY(useCardStyle, NSNumber, NSObject, YES, nil, nil),
                    PROPERTY(useSecondaryColor, NSNumber, NSObject, YES, nil, nil),
                    PROPERTY(alignImageToTop, NSNumber, NSObject, YES, nil, nil),
                    })),
           ENTRY(ORKLearnMoreItem,
                 ^id(__unused NSDictionary *dict, __unused ORKESerializationPropertyGetter getter) {
                     ORKLearnMoreItem *learnMoreItem = [[ORKLearnMoreItem alloc] initWithText:GETPROP(dict, text) learnMoreInstructionStep:GETPROP(dict, learnMoreInstructionStep)];
                     return learnMoreItem;
                 },
                 (@{
                    PROPERTY(text, NSString, NSObject, YES, nil, nil),
                    PROPERTY(learnMoreInstructionStep, ORKLearnMoreInstructionStep, NSObject, YES, nil, nil),
                    })),
           ENTRY(ORKLearnMoreInstructionStep,
                 ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
                     return [[ORKLearnMoreInstructionStep alloc] initWithIdentifier:GETPROP(dict, identifier)];
                 },
                 (@{
                    })),
           
           ENTRY(ORKAnswerFormat,
                 nil,
                 (@{
                     PROPERTY(showDontKnowButton, NSNumber, NSObject, YES, nil, nil),
                     PROPERTY(customDontKnowButtonText, NSString, NSObject, YES, nil, nil),
                     PROPERTY(dontKnowButtonStyle, NSNumber, NSObject, YES, nil, nil),
                    })),
           ENTRY(ORKDontKnowAnswer,
                 ^id(__unused NSDictionary *dict, __unused ORKESerializationPropertyGetter getter) {
                     return [ORKDontKnowAnswer answer];
                 },
                 (@{
                  })),
           ENTRY(ORKValuePickerAnswerFormat,
                 ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
                     return [[ORKValuePickerAnswerFormat alloc] initWithTextChoices:GETPROP(dict, textChoices)];
                 },
                 (@{
                    PROPERTY(textChoices, ORKTextChoice, NSArray, NO, nil, nil),
                    })),
           ENTRY(ORKMultipleValuePickerAnswerFormat,
                 ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
                     return [[ORKMultipleValuePickerAnswerFormat alloc] initWithValuePickers:GETPROP(dict, valuePickers) separator:GETPROP(dict, separator)];
                 },
                 (@{
                    PROPERTY(valuePickers, ORKValuePickerAnswerFormat, NSArray, NO, nil, nil),
                    PROPERTY(separator, NSString, NSObject, NO, nil, nil),
                    })),
           ENTRY(ORKTextChoiceAnswerFormat,
                 ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
                     return [[ORKTextChoiceAnswerFormat alloc] initWithStyle:((NSNumber *)GETPROP(dict, style)).integerValue textChoices:GETPROP(dict, textChoices)];
                 },
                 (@{
                    PROPERTY(style, NSNumber, NSObject, NO, NUMTOSTRINGBLOCK([ORKESerializerHelper ORKChoiceAnswerStyleTable]), STRINGTONUMBLOCK([ORKESerializerHelper ORKChoiceAnswerStyleTable])),
                    PROPERTY(textChoices, ORKTextChoice, NSArray, NO, nil, nil),
                    })),
           ENTRY(ORKTextChoice,
                 ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
                     return [[ORKTextChoice alloc] initWithText:GETPROP(dict, text) detailText:GETPROP(dict, detailText) value:GETPROP(dict, value) exclusive:((NSNumber *)GETPROP(dict, exclusive)).boolValue];
                 },
                 (@{
                    PROPERTY(text, NSString, NSObject, NO, nil, nil),
                    PROPERTY(value, NSObject, NSObject, NO, nil, nil),
                    PROPERTY(detailText, NSString, NSObject, NO, nil, nil),
                    PROPERTY(exclusive, NSNumber, NSObject, NO, nil, nil),
                    IMAGEPROPERTY(image, NSObject, YES)
                    })),
           ENTRY(ORKTextChoiceOther,
                 ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
                     return [[ORKTextChoiceOther alloc] initWithText:GETPROP(dict, text) primaryTextAttributedString:nil detailText:GETPROP(dict, detailText) detailTextAttributedString:nil value:GETPROP(dict, value) exclusive:((NSNumber *)GETPROP(dict, exclusive)).boolValue textViewPlaceholderText:GETPROP(dict, textViewPlaceholderText) textViewInputOptional:((NSNumber *)GETPROP(dict, textViewInputOptional)).boolValue textViewStartsHidden:((NSNumber *)GETPROP(dict, textViewStartsHidden)).boolValue];
                 },
                 (@{
                    PROPERTY(textViewPlaceholderText, NSString, NSObject, NO, nil, nil),
                    PROPERTY(textViewInputOptional, NSNumber, NSObject, NO, nil, nil),
                    PROPERTY(textViewStartsHidden, NSNumber, NSObject, NO, nil, nil),
                    })),
           ENTRY(ORKImageChoice,
                 ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
                     return [[ORKImageChoice alloc] initWithNormalImage:nil selectedImage:nil text:GETPROP(dict, text) value:GETPROP(dict, value)];
                 },
                 (@{
                    PROPERTY(text, NSString, NSObject, NO, nil, nil),
                    PROPERTY(value, NSObject, NSObject, NO, nil, nil),
                    IMAGEPROPERTY(normalStateImage, NSObject, YES),
                    IMAGEPROPERTY(selectedStateImage, NSObject, YES),
                    })),
           ENTRY(ORKTimeOfDayAnswerFormat,
                 ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
                     return [[ORKTimeOfDayAnswerFormat alloc] initWithDefaultComponents:GETPROP(dict, defaultComponents)];
                 },
                 (@{
                    PROPERTY(defaultComponents, NSDateComponents, NSObject, NO,
                             ^id(id components, __unused ORKESerializationContext *context) { return ORKTimeOfDayStringFromComponents(components);  },
                             ^id(id string, __unused ORKESerializationContext *context) { return ORKTimeOfDayComponentsFromString(string); }),
                    PROPERTY(minuteInterval, NSNumber, NSObject, YES, nil, nil)
                    })),
           ENTRY(ORKDateAnswerFormat,
                 ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
                     return [[ORKDateAnswerFormat alloc] initWithStyle:((NSNumber *)GETPROP(dict, style)).integerValue defaultDate:GETPROP(dict, defaultDate) minimumDate:GETPROP(dict, minimumDate) maximumDate:GETPROP(dict, maximumDate) calendar:GETPROP(dict, calendar)];
                 },
                 (@{
                    PROPERTY(style, NSNumber, NSObject, NO,
                             NUMTOSTRINGBLOCK([ORKESerializerHelper ORKDateAnswerStyleTable]),
                             STRINGTONUMBLOCK([ORKESerializerHelper ORKDateAnswerStyleTable])),
                    PROPERTY(calendar, NSCalendar, NSObject, NO,
                             ^id(id calendar, __unused ORKESerializationContext *context) { return [(NSCalendar *)calendar calendarIdentifier]; },
                             ^id(id string, __unused ORKESerializationContext *context) { return [NSCalendar calendarWithIdentifier:string]; }),
                    PROPERTY(minimumDate, NSDate, NSObject, NO,
                             ^id(id date, __unused ORKESerializationContext *context) { return [ORKResultDateTimeFormatter() stringFromDate:date]; },
                             ^id(id string, __unused ORKESerializationContext *context) { return [ORKResultDateTimeFormatter() dateFromString:string]; }),
                    PROPERTY(maximumDate, NSDate, NSObject, NO,
                             ^id(id date, __unused ORKESerializationContext *context) { return [ORKResultDateTimeFormatter() stringFromDate:date]; },
                             ^id(id string, __unused ORKESerializationContext *context) { return [ORKResultDateTimeFormatter() dateFromString:string]; }),
                    PROPERTY(defaultDate, NSDate, NSObject, NO,
                             ^id(id date, __unused ORKESerializationContext *context) { return [ORKResultDateTimeFormatter() stringFromDate:date]; },
                             ^id(id string, __unused ORKESerializationContext *context) { return [ORKResultDateTimeFormatter() dateFromString:string]; }),
                    PROPERTY(minuteInterval, NSNumber, NSObject, YES, nil, nil),
                    PROPERTY(daysBeforeCurrentDateToSetMinimumDate, NSNumber, NSObject, YES, nil, nil),
                    PROPERTY(daysAfterCurrentDateToSetMinimumDate, NSNumber, NSObject, YES, nil, nil),
                    PROPERTY(isMaxDateCurrentTime, NSNumber, NSObject, YES, nil, nil)
                 })),
           ENTRY(ORKNumericAnswerFormat,
                 ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
                     ORKNumericAnswerFormat *format = [[ORKNumericAnswerFormat alloc] initWithStyle:((NSNumber *)GETPROP(dict, style)).integerValue
                                                                                               unit:GETPROP(dict, unit)
                                                                                        displayUnit:GETPROP(dict, displayUnit)
                                                                                            minimum:GETPROP(dict, minimum)
                                                                                            maximum:GETPROP(dict, maximum)
                                                                              maximumFractionDigits:GETPROP(dict, maximumFractionDigits)];
                     format.defaultNumericAnswer = GETPROP(dict, defaultNumericAnswer);
                     return format;
                 },
                 (@{
                    PROPERTY(style, NSNumber, NSObject, NO,
                             ^id(id num, __unused ORKESerializationContext *context) {
                        ORKNumericAnswerStyle answerStyle = (ORKNumericAnswerStyle)((NSNumber *)num).integerValue;
                        return [ORKESerializerHelper ORKNumericAnswerStyleToStringWithStyle:answerStyle]; },
                             ^id(id string, __unused ORKESerializationContext *context) {
                        return @([ORKESerializerHelper ORKNumericAnswerStyleFromString:string]); }),
                    PROPERTY(unit, NSString, NSObject, NO, nil, nil),
                    PROPERTY(displayUnit, NSString, NSObject, NO, nil, nil),
                    PROPERTY(minimum, NSNumber, NSObject, NO, nil, nil),
                    PROPERTY(maximum, NSNumber, NSObject, NO, nil, nil),
                    PROPERTY(maximumFractionDigits, NSNumber, NSObject, NO, nil, nil),
                    PROPERTY(defaultNumericAnswer, NSNumber, NSObject, NO, nil, nil),
                    PROPERTY(hideUnitWhenAnswerIsEmpty, NSNumber, NSObject, YES, nil, nil),
                    PROPERTY(placeholder, NSString, NSObject, YES, nil, nil)
                    })),
           ENTRY(ORKScaleAnswerFormat,
                 ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
                     NSNumber *defaultValue = (NSNumber *)GETPROP(dict, defaultValue);
                     if (defaultValue == nil) {
                         defaultValue = [[NSNumber alloc] initWithInt:INT_MAX];
                     }
                     return [[ORKScaleAnswerFormat alloc] initWithMaximumValue:((NSNumber *)GETPROP(dict, maximum)).integerValue
                                                                  minimumValue:((NSNumber *)GETPROP(dict, minimum)).integerValue
                                                                  defaultValue:defaultValue.integerValue
                                                                          step:((NSNumber *)GETPROP(dict, step)).integerValue
                                                                      vertical:((NSNumber *)GETPROP(dict, vertical)).boolValue
                                                       maximumValueDescription:GETPROP(dict, maximumValueDescription)
                                                       minimumValueDescription:GETPROP(dict, minimumValueDescription)];
                 },
                 (@{
                    PROPERTY(minimum, NSNumber, NSObject, NO, nil, nil),
                    PROPERTY(maximum, NSNumber, NSObject, NO, nil, nil),
                    PROPERTY(defaultValue, NSNumber, NSObject, NO, nil, nil),
                    PROPERTY(step, NSNumber, NSObject, NO, nil, nil),
                    PROPERTY(vertical, NSNumber, NSObject, NO, nil, nil),
                    PROPERTY(maximumValueDescription, NSString, NSObject, NO, nil, nil),
                    PROPERTY(minimumValueDescription, NSString, NSObject, NO, nil, nil),
                    PROPERTY(gradientColors, UIColor, NSArray, YES, nil, nil),
                    PROPERTY(gradientLocations, NSNumber, NSArray, YES, nil, nil),
                    PROPERTY(hideSelectedValue, NSNumber, NSObject, YES, nil, nil),
                    PROPERTY(hideRanges, NSNumber, NSObject, YES, nil, nil),
                    PROPERTY(hideLabels, NSNumber, NSObject, YES, nil, nil),
                    PROPERTY(hideValueMarkers, NSNumber, NSObject, YES, nil, nil),
                    IMAGEPROPERTY(minimumImage, NSObject, YES),
                    IMAGEPROPERTY(maximumImage, NSObject, YES),
                    })),
           ENTRY(ORKContinuousScaleAnswerFormat,
                 ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
                     NSNumber *defaultValue = (NSNumber *)GETPROP(dict, defaultValue);
                     if (defaultValue == nil) {
                         defaultValue = [[NSNumber alloc] initWithDouble:DBL_MAX];
                     }
                     return [[ORKContinuousScaleAnswerFormat alloc] initWithMaximumValue:((NSNumber *)GETPROP(dict, maximum)).doubleValue
                                                                            minimumValue:((NSNumber *)GETPROP(dict, minimum)).doubleValue
                                                                            defaultValue:defaultValue.doubleValue
                                                                   maximumFractionDigits:((NSNumber *)GETPROP(dict, maximumFractionDigits)).integerValue
                                                                                vertical:((NSNumber *)GETPROP(dict, vertical)).boolValue
                                                                 maximumValueDescription:GETPROP(dict, maximumValueDescription)
                                                                 minimumValueDescription:GETPROP(dict, minimumValueDescription)];
                 },
                 (@{
                    PROPERTY(minimum, NSNumber, NSObject, NO, nil, nil),
                    PROPERTY(maximum, NSNumber, NSObject, NO, nil, nil),
                    PROPERTY(defaultValue, NSNumber, NSObject, NO, nil, nil),
                    PROPERTY(maximumFractionDigits, NSNumber, NSObject, NO, nil, nil),
                    PROPERTY(vertical, NSNumber, NSObject, NO, nil, nil),
                    PROPERTY(numberStyle, NSNumber, NSObject, YES,
                    ^id(id numeric, __unused ORKESerializationContext *context) {
                        return [ORKESerializerHelper tableMapForwardWithIndex:((NSNumber *)numeric).integerValue table:[ORKESerializerHelper numberFormattingStyleTable]];
                    },
                    ^id(id string, __unused ORKESerializationContext *context) {
                        return @([ORKESerializerHelper tableMapReverseWithValue:string table:[ORKESerializerHelper numberFormattingStyleTable]]);
                    }),
                    PROPERTY(maximumValueDescription, NSString, NSObject, NO, nil, nil),
                    PROPERTY(minimumValueDescription, NSString, NSObject, NO, nil, nil),
                    PROPERTY(gradientColors, UIColor, NSArray, YES, nil, nil),
                    PROPERTY(gradientLocations, NSNumber, NSArray, YES, nil, nil),
                    PROPERTY(hideSelectedValue, NSNumber, NSObject, YES, nil, nil),
                    PROPERTY(hideRanges, NSNumber, NSObject, YES, nil, nil),
                    PROPERTY(hideLabels, NSNumber, NSObject, YES, nil, nil),
                    IMAGEPROPERTY(minimumImage, NSObject, YES),
                    IMAGEPROPERTY(maximumImage, NSObject, YES),
                    })),
           ENTRY(ORKTextScaleAnswerFormat,
                 ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
                     return [[ORKTextScaleAnswerFormat alloc] initWithTextChoices:GETPROP(dict, textChoices) defaultIndex:(NSInteger)[GETPROP(dict, defaultIndex) doubleValue] vertical:[GETPROP(dict, vertical) boolValue]];
                 },
                 (@{
                    PROPERTY(textChoices, ORKTextChoice, NSArray<ORKTextChoice *>, NO, nil, nil),
                    PROPERTY(defaultIndex, NSNumber, NSObject, NO, nil, nil),
                    PROPERTY(vertical, NSNumber, NSObject, NO, nil, nil),
                    PROPERTY(gradientColors, UIColor, NSArray, YES, nil, nil),
                    PROPERTY(gradientLocations, NSNumber, NSArray, YES, nil, nil),
                    PROPERTY(hideSelectedValue, NSNumber, NSObject, YES, nil, nil),
                    PROPERTY(hideRanges, NSNumber, NSObject, YES, nil, nil),
                    PROPERTY(hideLabels, NSNumber, NSObject, YES, nil, nil),
                    PROPERTY(hideValueMarkers, NSNumber, NSObject, YES, nil, nil)
                    })),
           ENTRY(ORKTextAnswerFormat,
                 ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
                     return [[ORKTextAnswerFormat alloc] initWithMaximumLength:((NSNumber *)GETPROP(dict, maximumLength)).integerValue];
                 },
                 (@{
                    PROPERTY(maximumLength, NSNumber, NSObject, NO, nil, nil),
                    PROPERTY(validationRegularExpression, NSRegularExpression, NSObject, YES,
                             ^id(id value, __unused ORKESerializationContext *context) { return [ORKESerializerHelper dictionaryFromRegularExpression:(NSRegularExpression *)value]; },
                             ^id(id dict, __unused ORKESerializationContext *context) { return [ORKESerializerHelper regularExpressionsFromDictionary:dict]; } ),
                    PROPERTY(invalidMessage, NSString, NSObject, YES, nil, nil),
                    PROPERTY(defaultTextAnswer, NSString, NSObject, YES, nil, nil),
                    PROPERTY(autocapitalizationType, NSNumber, NSObject, YES, nil, nil),
                    PROPERTY(autocorrectionType, NSNumber, NSObject, YES, nil, nil),
                    PROPERTY(spellCheckingType, NSNumber, NSObject, YES, nil, nil),
                    PROPERTY(keyboardType, NSNumber, NSObject, YES, nil, nil),
                    PROPERTY(multipleLines, NSNumber, NSObject, YES, nil, nil),
                    PROPERTY(hideClearButton, NSNumber, NSObject, YES, nil, nil),
                    PROPERTY(hideCharacterCountLabel, NSNumber, NSObject, YES, nil, nil),
                    PROPERTY(secureTextEntry, NSNumber, NSObject, YES, nil, nil),
                    PROPERTY(textContentType, NSString, NSObject, YES, nil, nil),
                    PROPERTY(passwordRules, UITextInputPasswordRules, NSObject, YES,
                             ^id(id value, __unused ORKESerializationContext *context) { return [ORKESerializerHelper dictionaryFromPasswordRules:(UITextInputPasswordRules *)value]; },
                             ^id(id dict, __unused ORKESerializationContext *context) { return [ORKESerializerHelper passwordRulesFromDictionary:dict]; } ),
                    PROPERTY(placeholder, NSString, NSObject, YES, nil, nil),
                    })),
           ENTRY(ORKEmailAnswerFormat,
                 nil,
                 (@{
                    PROPERTY(usernameField, NSNumber, NSObject, YES, nil, nil),
                    })),
           ENTRY(ORKConfirmTextAnswerFormat,
                 ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
                     return [[ORKConfirmTextAnswerFormat alloc] initWithOriginalItemIdentifier:GETPROP(dict, originalItemIdentifier) errorMessage:GETPROP(dict, errorMessage)];
                 },
                 (@{
                    PROPERTY(originalItemIdentifier, NSString, NSObject, NO, nil, nil),
                    PROPERTY(errorMessage, NSString, NSObject, NO, nil, nil),
                    PROPERTY(maximumLength, NSNumber, NSObject, YES, nil, nil)
                    })),
           ENTRY(ORKTimeIntervalAnswerFormat,
                 ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
                     return [[ORKTimeIntervalAnswerFormat alloc] initWithDefaultInterval:((NSNumber *)GETPROP(dict, defaultInterval)).doubleValue step:((NSNumber *)GETPROP(dict, step)).integerValue];
                 },
                 (@{
                    PROPERTY(defaultInterval, NSNumber, NSObject, NO, nil, nil),
                    PROPERTY(step, NSNumber, NSObject, NO, nil, nil),
                    })),
           ENTRY(ORKBooleanAnswerFormat,
                 ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
                     return [[ORKBooleanAnswerFormat alloc] initWithYesString:((NSString *)GETPROP(dict, yes)) noString:((NSString *)GETPROP(dict, no))];
                 },
                 (@{
                    PROPERTY(yes, NSString, NSObject, NO, nil, nil),
                    PROPERTY(no, NSString, NSObject, NO, nil, nil)
                    })),
           ENTRY(ORKHeightAnswerFormat,
                 ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
                     return [[ORKHeightAnswerFormat alloc] initWithMeasurementSystem:((NSNumber *)GETPROP(dict, measurementSystem)).integerValue];
                 },
                 (@{
                    PROPERTY(measurementSystem, NSNumber, NSObject, NO,
                             ^id(id number, __unused ORKESerializationContext *context) { return [ORKESerializerHelper ORKMeasurementSystemToString:((NSNumber *)number).integerValue]; },
                             ^id(id string, __unused ORKESerializationContext *context) { return @([ORKESerializerHelper ORKMeasurementSystemFromString:string]); }),
                    })),
           ENTRY(ORKWeightAnswerFormat,
                 ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
                     return [[ORKWeightAnswerFormat alloc] initWithMeasurementSystem:((NSNumber *)GETPROP(dict, measurementSystem)).integerValue
                                                                    numericPrecision:((NSNumber *)GETPROP(dict, numericPrecision)).integerValue
                                                                        minimumValue:((NSNumber *)GETPROP(dict, minimumValue)).doubleValue
                                                                        maximumValue:((NSNumber *)GETPROP(dict, maximumValue)).doubleValue
                                                                        defaultValue:((NSNumber *)GETPROP(dict, defaultValue)).doubleValue];
                 },
                 (@{
                    PROPERTY(measurementSystem, NSNumber, NSObject, NO,
                             ^id(id number, __unused ORKESerializationContext *context) { return [ORKESerializerHelper ORKMeasurementSystemToString:((NSNumber *)number).integerValue]; },
                             ^id(id string, __unused ORKESerializationContext *context) { return @([ORKESerializerHelper ORKMeasurementSystemFromString:string]); }),
                    PROPERTY(numericPrecision, NSNumber, NSObject, NO, nil, nil),
                    PROPERTY(minimumValue, NSNumber, NSObject, NO, nil, nil),
                    PROPERTY(maximumValue, NSNumber, NSObject, NO, nil, nil),
                    PROPERTY(defaultValue, NSNumber, NSObject, NO, nil, nil),
                    })),
           ENTRY(ORKSESAnswerFormat,
                 ^id(__unused NSDictionary *dict, __unused ORKESerializationPropertyGetter getter) {
               return [[ORKSESAnswerFormat alloc] init];
           },
                 (@{
                     PROPERTY(topRungText, NSString, NSObject, YES, nil, nil),
                     PROPERTY(bottomRungText, NSString, NSObject, YES, nil, nil)
                 })),
           
        } mutableCopy];

    return internalEncodingTable;
}

@end
