/*
 Copyright (c) 2015-2017, Apple Inc. All rights reserved.
 
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

#import <Contacts/Contacts.h>
#import <ResearchKit/ORKResult.h>

#if ORK_FEATURE_CLLOCATIONMANAGER_AUTHORIZATION && TARGET_OS_IOS
#import <CoreLocation/CLLocation.h>
#endif

NS_ASSUME_NONNULL_BEGIN

@class CLCircularRegion;
@class ORKQuestionStep;
@class ORKFormItem;
@class ORKFormStep;
@class ORKQuestionResult;


/**
 A base class for leaf results from an item that uses an answer format.
 
 A question result is typically generated by the framework as the task proceeds. When the task
 completes, it may be appropriate to serialize it for transmission to a server,
 or to immediately perform analysis on it.
 
 See also: `ORKQuestionStep` and `ORKFormItem`.
 */
ORK_CLASS_AVAILABLE
@interface ORKQuestionResult : ORKResult

/**
 A value that indicates the type of question the result came from.
 
 The value of `questionType` generally correlates closely with the class, but it can be
 easier to use this value in a switch statement in Objective-C.
 */
@property (nonatomic) ORKQuestionType questionType;

/**
 The `noAnswerType` is a nullable property that can contain an instance of an `ORKNoAnswer` subclass.
 
 If the user used the `ORKDontKnowButton`, the value of this property is `ORKDontKnowAnswer`, and the questionType specific answer is `nil`.
 */
@property (nonatomic, copy, nullable) ORKNoAnswer *noAnswerType;

@end


/**
 A result object from a boolean answer format.
 
 A Boolean question result is produced by the task view controller when it presents a question or form
 item with a Boolean answer format (that is, `ORKBooleanAnswerFormat`).
 
 A Boolean question result is typically generated by the framework as the task proceeds. When the task
 completes, it may be appropriate to serialize it for transmission to a server,
 or to immediately perform analysis on it.
 */
ORK_CLASS_AVAILABLE
@interface ORKBooleanQuestionResult : ORKQuestionResult

/** The answer, or `nil` if the user skipped the question. */
@property (nonatomic, copy, nullable) NSNumber *booleanAnswer;

@end


/**
 A result object from a multiple or single choice-based answer format.
 
 For example, an `ORKTextChoiceAnswerFormat` or an `ORKImageChoiceAnswerFormat`
 format produces an `ORKChoiceQuestionResult` object.
 
 A choice question result is typically generated by the framework as the task proceeds. When the task
 completes, it may be appropriate to serialize it for transmission to a server,
 or to immediately perform analysis on it.
 */
ORK_CLASS_AVAILABLE
@interface ORKChoiceQuestionResult : ORKQuestionResult

/**
 An array of selected values, from the `value` property of an `ORKTextChoice` or `ORKImageChoice` object.
 In the case of a single choice, the array has exactly one entry.
 
 If the user skipped the question, the value of the corresponding array member is `nil`.
 */
@property (nonatomic, copy, nullable) NSArray<NSObject<NSCopying, NSSecureCoding> *> *choiceAnswers;

@end


/**
 A result object from a date answer format.
 
 The calendar and time zone are recorded in addition to the answer itself,
 to give the answer context. Usually, this data corresponds to the current calendar
 and time zone at the time of the activity, but it can be overridden by setting
 these properties explicitly in the `ORKDateAnswerFormat` object.
 */
ORK_CLASS_AVAILABLE
@interface ORKDateQuestionResult : ORKQuestionResult

/**
 The date that the user entered, or `nil` if the user skipped the question.
 */
@property (nonatomic, copy, nullable) NSDate *dateAnswer;

/**
 The calendar used when selecting date and time.
 
 If the calendar in the `ORKDateAnswerFormat` object is `nil`, this calendar is the system
 calendar at the time of data entry.
 */
@property (nonatomic, copy, nullable) NSCalendar *calendar;

/**
 The time zone that was current when selecting the date and time.
 */
@property (nonatomic, copy, nullable) NSTimeZone *timeZone;

@end


#if ORK_FEATURE_CLLOCATIONMANAGER_AUTHORIZATION && TARGET_OS_IOS
/**
 The `ORKLocation` class represents the location addess obtained from a location question.
 */
ORK_CLASS_AVAILABLE
@interface ORKLocation : NSObject <NSCopying, NSSecureCoding>

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

/**
 The geographical coordinate information.
 */
@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;

/**
 The region describes the size of the placemark of the location.
 */
@property (nonatomic, copy, readonly, nullable) CLCircularRegion *region;

/**
 The human readable address typed in by user.
 */
@property (nonatomic, copy, readonly, nullable) NSString *userInput;

/**
 The postal address for this coordinate
 */
@property (nonatomic, copy, readonly, nullable) CNPostalAddress *postalAddress;

@end
#endif

/**
 A result object from a location answer format.
 
 A Location question result is produced by the task view controller when it presents a question or form
 item with a Location answer format (that is, `ORKLocationAnswerFormat`).
 
 A Location question result is typically generated by the framework as the task proceeds. When the task
 completes, it may be appropriate to serialize it for transmission to a server,
 or to immediately perform analysis on it.
 */

#if ORK_FEATURE_CLLOCATIONMANAGER_AUTHORIZATION && TARGET_OS_IOS
ORK_CLASS_AVAILABLE
@interface ORKLocationQuestionResult : ORKQuestionResult

/**
 The answer representing the coordinate and the address of a specific location.
 */
@property (nonatomic, copy, nullable) ORKLocation *locationAnswer;

@end
#endif

/**
 A result object from a multiple-component picker-style choice-based answer format.
 
 For example, an `ORKMultipleValuePickerAnswerFormat` produces an `ORKMultipleComponentQuestionResult` object.
 
 A multiple component question result is typically generated by the framework as the task proceeds.
 When the task completes, it may be appropriate to serialize it for transmission to a server,
 or to immediately perform analysis on it.
 */
ORK_CLASS_AVAILABLE
@interface ORKMultipleComponentQuestionResult : ORKQuestionResult

/**
 An array of selected components, from the `value` property of an `ORKTextChoice` object.
 The array will have the same count as the number of components.
 
 If the user skipped the question, the value of the corresponding array member is `nil`.
 */
@property (nonatomic, copy, nullable) NSArray<NSObject<NSCopying, NSSecureCoding> *> *componentsAnswer;

/**
 The string separator used to join the components (if applicable)
 */
@property (nonatomic, copy, nullable) NSString *separator;

@end


/**
 A result object from a numeric answer format.
 
 Examples of this type of answer format include `ORKScaleAnswerFormat` and `ORKNumericAnswerFormat`.
 
 A numeric question result is typically generated by the framework as the task proceeds. When the task
 completes, it may be appropriate to serialize it for transmission to a server,
 or to immediately perform analysis on it.
 */
ORK_CLASS_AVAILABLE
@interface ORKNumericQuestionResult : ORKQuestionResult

/// The number collected, or `nil` if the user skipped the question.
@property (nonatomic, copy, nullable) NSNumber *numericAnswer;

/**
 The unit string saved to the result object when the value was entered, or `nil` if no unit string was displayed.
 */
@property (nonatomic, copy, nullable) NSString *unit;

/**
 The unit string displayed to the user when the value was entered, or `nil` if no unit string was displayed.
 */
@property (nonatomic, copy, nullable) NSString *displayUnit;


@end


/**
 A result object from a continuous or discrete-value scale answer format.
 
 A scale question result is typically generated by the framework as the task proceeds. When the task
 completes, it may be appropriate to serialize it for transmission to a server,
 or to immediately perform analysis on it.
 */
ORK_CLASS_AVAILABLE
@interface ORKScaleQuestionResult : ORKQuestionResult

/**
 The answer obtained from the scale question.
 
 The value of this property is `nil` when the user skipped the question or otherwise did not
 enter an answer.
 */
@property (nonatomic, copy, nullable) NSNumber *scaleAnswer;

@end

/**
 A result object from a question or form item that uses an text answer format.
 
 A text question result is typically generated by the framework as the task proceeds. When the task
 completes, it may be appropriate to serialize it for transmission to a server
 or to immediately perform analysis on it.
 */
ORK_CLASS_AVAILABLE
@interface ORKTextQuestionResult : ORKQuestionResult

/**
 The answer that the user entered.
 
 If the user skipped the question the value of this property is `nil`.
 */
@property (nonatomic, copy, nullable) NSString *textAnswer;

@end


/**
 A result object from a question that uses the time interval answer format.
 
 A time interval question result is typically generated by the framework as the task proceeds. When the task
 completes, it may be appropriate to serialize it for transmission to a server,
 or to immediately perform analysis on it.
 */
ORK_CLASS_AVAILABLE
@interface ORKTimeIntervalQuestionResult : ORKQuestionResult

/**
 The selected interval, in seconds.
 
 The value of this property is `nil` if the user skipped the question.
 */
@property (nonatomic, copy, nullable) NSNumber *intervalAnswer;

@end


/**
 A result object from a question that uses the time of day answer format.
 */
ORK_CLASS_AVAILABLE
@interface ORKTimeOfDayQuestionResult : ORKQuestionResult

/**
 The date components picked by the user.
 
 Typically only hour, minute, and AM/PM data are of interest.
 */
@property (nonatomic, copy, nullable) NSDateComponents *dateComponentsAnswer;

@end

/**
 A result object from the socio-economic ladder answer format.
 */
ORK_CLASS_AVAILABLE
@interface ORKSESQuestionResult : ORKQuestionResult

/**
 The socio-economic status picked by the user.
 */
@property (nonatomic, copy, nullable) NSNumber *rungPicked;

@end

NS_ASSUME_NONNULL_END
