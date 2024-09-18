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

import Foundation
import ResearchKit
import SwiftUI

enum MultipleChoiceAnswerFormat: Int {
    case multiple = 0
    case image
}

public class RKAdapter {

    static var multipleChoiceAnswerFormatKey = "multipleChoiceAnswerFormatKey"

    public static func createFormRow(from item: ORKFormItem) -> FormRow? {
        guard let answerFormat = item.answerFormat else {
            return nil
        }

        return Self.createFormRow(from: item.identifier, with: item.text ?? "", detail: item.detailText, placeholder: item.placeholder, answer: answerFormat)
    }

    public static func createFormRow(from identifier: String, with title: String, detail: String?, placeholder: String? = nil, answer: ORKAnswerFormat) -> FormRow? {

        switch answer {
        case let textChoiceAnswerFormat as ORKTextChoiceAnswerFormat:
            var answerOptions : [MultipleChoiceOption] = []
            textChoiceAnswerFormat.textChoices.forEach { textChoice in
                let value: ResultValue? = RKAdapter.value(from: textChoice.value)
                answerOptions.append(
                    MultipleChoiceOption(
                        id: UUID().uuidString,
                        choiceText: textChoice.text,
                        value: value ?? .string("Unknown")
                    )
                )
            }
            return FormRow.multipleChoiceRow(
                MultipleChoiceQuestion(
                    id: identifier,
                    title: title,
                    choices: answerOptions,
                    selectionType: textChoiceAnswerFormat.style == .singleChoice ? .single : .multiple
                )
            )
        case let scaleAnswerFormat as ORKScaleAnswerFormat:
            return FormRow.intSliderRow(
                ScaleSliderQuestion(
                    id: identifier,
                    title: title,
                    step: scaleAnswerFormat.step,
                    range: scaleAnswerFormat.minimum...scaleAnswerFormat.maximum,
                    value: scaleAnswerFormat.defaultValue
                )
            )
        case let continuousScaleAnswerFormat as ORKContinuousScaleAnswerFormat:

            // Current ORKContinuousScaleAnswerFormat does not allow user to specify step size so we can create an approximation,
            // falling back on 0.01 as our step size if required.
            var stepSize = 0.01
            let numberOfValues = continuousScaleAnswerFormat.maximum - continuousScaleAnswerFormat.minimum
            if numberOfValues > 0 {
                stepSize = 1.0 / numberOfValues
            }
            return FormRow.doubleSliderRow(
                ScaleSliderQuestion(
                    id: identifier,
                    title: title,
                    step: stepSize,
                    range: continuousScaleAnswerFormat.minimum...continuousScaleAnswerFormat.maximum,
                    value: continuousScaleAnswerFormat.defaultValue
                )
            )
            
#if !os(watchOS)
        case let textChoiceScaleAnswerFormat as ORKTextScaleAnswerFormat:


            let answerOptions = textChoiceScaleAnswerFormat.textChoices.map { textChoice in
                let value: ResultValue? = RKAdapter.value(from: textChoice.value)
                return MultipleChoiceOption(
                    id: UUID().uuidString,
                    choiceText: textChoice.text,
                    value: value ?? .string("Unknown")
                )
            }
            guard var defaultOption = answerOptions.first else {
                fatalError("Invalid Choice Array for ORKTextScaleAnswerFormat")
            }
            if answerOptions.indices.contains(textChoiceScaleAnswerFormat.defaultIndex) {
                defaultOption = answerOptions[textChoiceScaleAnswerFormat.defaultIndex]
            }
            
            return FormRow.textSliderStep(
                ScaleSliderQuestion(
                    id: identifier,
                    title: title,
                    options: answerOptions,
                    selectedMultipleChoiceOption: defaultOption
                )
            )
#endif
        case let textAnswerFormat as ORKTextAnswerFormat:
            return FormRow.textRow(
                TextQuestion(
                    title: title,
                    id: identifier,
                    prompt: placeholder ?? "",
                    textFieldType: textAnswerFormat.multipleLines ? .multiline : .singleLine,
                    characterLimit: textAnswerFormat.maximumLength,
                    hideCharacterCountLabel: textAnswerFormat.hideCharacterCountLabel,
                    hideClearButton: textAnswerFormat.hideClearButton
                )
            )
        case let dateTimeAnswerFormat as ORKDateAnswerFormat:
            let prompt: String = {
                if let placeholder {
                    return placeholder
                }

                if dateTimeAnswerFormat.style == .dateAndTime {
                    return "Select Date and Time"
                } else {
                    return "Select Date"
                }
            }()

            let startDate: Date = {
                if let date = dateTimeAnswerFormat.minimumDate {
                    return date
                }
                return Date.distantPast
            }()

            let endDate: Date = {
                if let date = dateTimeAnswerFormat.maximumDate {
                    return date
                }
                return Date.distantFuture
            }()

            let components: DatePicker.Components = {
                switch dateTimeAnswerFormat.style {
                case .date:
                    return [.date]
                case .dateAndTime:
                    return [.date, .hourAndMinute]
                default:
                    return [.date]
                }
            }()

            return FormRow.dateRow(
                DateQuestion(
                    id: identifier,
                    title: title,
                    selection: Date(),
                    pickerPrompt: prompt,
                    displayedComponents: components,
                    range: startDate...endDate
                )
            )
            
#if !os(watchOS)
        case let numericAnswerFormat as ORKNumericAnswerFormat:
            return FormRow.numericRow(
                NumericQuestion(
                    id: identifier,
                    title: title,
                    detail: detail,
                    prompt: numericAnswerFormat.placeholder ?? "Tap to answer",
                    number: numericAnswerFormat.defaultNumericAnswer
                )
            )
#endif
        case let heightAnswerFormat as ORKHeightAnswerFormat:
            let measurementSystem: MeasurementSystem = {
                switch heightAnswerFormat.measurementSystem {
                case .USC:
                    return .USC
                case .local:
                    return .local
                case .metric:
                    return .metric
                @unknown default:
                    return .metric
                }
            }()

            return FormRow.heightRow(
                HeightQuestion(
                    id: identifier,
                    title: title,
                    detail: detail,
                    measurementSystem: measurementSystem,
                    selection: 162 // Denotes 5 feet 4 inches (162 cm)
                )
            )
        case let weightAnswerFormat as ORKWeightAnswerFormat:
            let measurementSystem: MeasurementSystem = {
                switch weightAnswerFormat.measurementSystem {
                case .USC:
                    return .USC
                case .local:
                    return .local
                case .metric:
                    return .metric
                @unknown default:
                    return .metric
                }
            }()

            let precision: NumericPrecision = {
                switch weightAnswerFormat.numericPrecision {
                case .default:
                    return .default
                case .high:
                    return .high
                case .low:
                    return .low
                @unknown default:
                    return .default
                }
            }()

            // At the moment the RK API for weight answer format defaults these values
            // to the `greatestFiniteMagnitude` if you don't explicitly pass them in.
            // We want to check for that here and pass in a valid value.
            let defaultValue: Double? = {
                if weightAnswerFormat.defaultValue == Double.greatestFiniteMagnitude {
                    if measurementSystem == .USC {
                        return 133
                    } else {
                        return 60
                    }
                }

                return weightAnswerFormat.defaultValue
            }()

            let minimumValue: Double? = {
                if weightAnswerFormat.minimumValue == Double.greatestFiniteMagnitude {
                    return nil
                }

                return weightAnswerFormat.minimumValue
            }()

            let maximumValue: Double? = {
                if weightAnswerFormat.maximumValue == Double.greatestFiniteMagnitude {
                    return nil
                }

                return weightAnswerFormat.maximumValue
            }()

            return FormRow.weightRow(
                WeightQuestion(
                    id: identifier,
                    title: title,
                    detail: detail,
                    measurementSystem: measurementSystem,
                    precision: precision,
                    defaultValue: defaultValue,
                    minimumValue: minimumValue,
                    maximumValue: maximumValue,
                    selection: defaultValue
                )
            )
        case let imageChoiceAnswerFormat as ORKImageChoiceAnswerFormat:
            let choices = imageChoiceAnswerFormat.imageChoices.map { choice in
                let value: ResultValue? = RKAdapter.value(from: choice.value)
                return ImageChoice(
                    normalImage: choice.normalStateImage,
                    selectedImage: choice.selectedStateImage,
                    text: choice.text!,
                    value: value ?? .string("Unknown")
                )
            }

            let style: ImageChoiceQuestion.ChoiceSelectionType = {
                switch imageChoiceAnswerFormat.style {
                    case .singleChoice:
                    return .single
                case .multipleChoice:
                    return .multiple
                default: return .single
                }
            }()

            return FormRow.imageRow(
                ImageChoiceQuestion(
                    title: title,
                    detail: detail,
                    id: identifier,
                    choices: choices,
                    style: style,
                    vertical: imageChoiceAnswerFormat.isVertical,
                    selections: []
                )
            )
        default:
            return nil
        }
    }

    static func createFormRowsFromORKStep(_ step: ORKFormStep) -> [FormRow] {
        // Convert our ORKFormItems to FormRows with associated values
        guard let formItems = step.formItems else {
            assertionFailure("Attempting to create an empty ORKFormStep")
            return []
        }

        let groupedItems = groupItems(formItems)

        let formRows = groupedItems.compactMap { formItem in
            Self.createFormRow(from: formItem)
        }

        return formRows
    }

    private static func groupItems(_ items: [ORKFormItem]) -> [ORKFormItem] {
        var groupedItems: [ORKFormItem] = []
        var builder: ORKFormItem?

        for item in items {
            if builder == nil {
                builder = item
                continue
            }

            if hasMatchingIdentifiers(firstIdentifier: item.identifier, secondIdentifier: builder?.identifier ?? "") {
                let newFormItem = ORKFormItem(
                    identifier: item.identifier,
                    text: builder?.text,
                    answerFormat: item.answerFormat
                )
                newFormItem.placeholder = item.placeholder

                groupedItems.append(
                    newFormItem
                )
                builder = nil
            } else {
                if let safeBuilder = builder {
                    groupedItems.append(safeBuilder)
                    builder = item
                }
            }
        }
        if let builder {
            groupedItems.append(builder)
        }
        return groupedItems
    }

    private static func extractUUID(_ string: String) -> String? {
        let uuidRegex = "[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}"
        guard let range = string.range(of: uuidRegex, options: .regularExpression, range: nil, locale: nil) else {
            return nil
        }
        let uuidString = String(string[range])
        return uuidString
    }

    private static func hasMatchingIdentifiers(firstIdentifier: String, secondIdentifier: String) -> Bool {
        guard let firstUUID = Self.extractUUID(firstIdentifier),
              let secondUUID = Self.extractUUID(secondIdentifier) else { return false }

        return firstUUID == secondUUID
    }

    public static func createORKResults(from taskResult: ResearchTaskResult) -> [ORKResult] {
        let resultsDictionary = taskResult.stepResults

        var resultsArray: [ORKResult] = []
        resultsDictionary.forEach { entry in
            let value = entry.value
            switch value {
            case let .text(answer):
                let result = ORKTextQuestionResult(identifier: entry.key)
                result.questionType = .text
                result.textAnswer = answer
                resultsArray.append(result)
            case .numeric(let decimal):
                let result = ORKNumericQuestionResult(identifier: entry.key)
                result.questionType = .decimal
                result.numericAnswer = NSNumber(floatLiteral: decimal ?? 0.0)
                resultsArray.append(result)
            case .date(let date):
                let result = ORKDateQuestionResult(identifier: entry.key)
                result.questionType = .date
                result.dateAnswer = date
                resultsArray.append(result)
            case .height(let height):
                let result = ORKNumericQuestionResult(identifier: entry.key)
                result.questionType = .height
                if let answer = height {
                    result.numericAnswer = NSNumber(floatLiteral: answer)
                }
                resultsArray.append(result)
            case .weight(let weight):
                let result = ORKNumericQuestionResult(identifier: entry.key)
                result.questionType = .weight
                if let answer = weight {
                    result.numericAnswer = NSNumber(floatLiteral: answer)
                }
                resultsArray.append(result)
            case .image(let images):
                let result = ORKChoiceQuestionResult(identifier: entry.key)
                let info = [
                    multipleChoiceAnswerFormatKey :
                        MultipleChoiceAnswerFormat.image.rawValue
                ]
                result.userInfo = info
                result.questionType = .multipleChoice
                if let results = images {
                    result.choiceAnswers = results.map { RKAdapter.rkValue(from: $0) }
                }
                resultsArray.append(result)
            case .multipleChoice(let multipleChoice):
                let result = ORKChoiceQuestionResult(identifier: entry.key)
                let info = [
                    multipleChoiceAnswerFormatKey :
                        MultipleChoiceAnswerFormat.multiple.rawValue
                ]
                if let answers = multipleChoice {
                    let newResults: [NSCopying & NSSecureCoding & NSObjectProtocol] = answers.map { RKAdapter.rkValue(from: $0) }
                    result.choiceAnswers = newResults
                }
                result.userInfo = info
                result.questionType = .multipleChoice
                resultsArray.append(result)
            case .scale(let value):
                let result = ORKScaleQuestionResult(identifier: entry.key)
                if let value = value {
                    result.scaleAnswer = NSNumber(floatLiteral: value)
                }
                result.questionType = .scale
                resultsArray.append(result)
            }
        }

        return resultsArray
    }

    public static func createTaskResults(from data: Data) -> ResearchTaskResult? {
        if let taskResult = ORKIESerializer.swiftUI_object(fromJSONData: data, error: nil) as? ORKTaskResult {
            let researchTaskResult = ResearchTaskResult()
            if let stepResults = taskResult.results as? [ORKStepResult] {
                for stepResult in stepResults {
                    guard let results = stepResult.results else { continue }

                    for result in results {
                        let identifier = result.identifier
                        if let result = result as? ORKTextQuestionResult {
                            researchTaskResult.stepResults[identifier] = .text(result.textAnswer ?? "Unknown")
                        } else if let result = result as? ORKNumericQuestionResult {
                            if result.questionType == .decimal {
                                researchTaskResult.stepResults[identifier] = .numeric(result.numericAnswer?.doubleValue ?? 0)
                            } else if result.questionType == .weight {
                                researchTaskResult.stepResults[identifier] = .weight(result.numericAnswer?.doubleValue ?? 0)
                            } else if result.questionType == .height {
                                researchTaskResult.stepResults[identifier] = .height(result.numericAnswer?.doubleValue ?? 0)
                            }
                        } else if let result = result as? ORKDateQuestionResult {
                            researchTaskResult.stepResults[identifier] = .date(result.dateAnswer ?? Date())
                        } else if let result = result as? ORKChoiceQuestionResult {
                            if let userInfo = result.userInfo,
                               let formatValue = userInfo[multipleChoiceAnswerFormatKey] as? Int,
                               let format = MultipleChoiceAnswerFormat(rawValue: formatValue) {
                                if let selections = result.choiceAnswers {
                                    let newSelections: [ResultValue] = selections.compactMap { RKAdapter.value(from: $0) }
                                    switch format {
                                    case .multiple:
                                        researchTaskResult.stepResults[identifier] = .multipleChoice(newSelections)
                                    case .image:
                                        researchTaskResult.stepResults[identifier] = .image(newSelections)
                                    }
                                }
                            }
                        } else if let result = result as? ORKScaleQuestionResult {
                            researchTaskResult.stepResults[identifier] = .scale(result.scaleAnswer?.doubleValue ?? 0)
                        }
                    }
                }
            }

            return researchTaskResult
        }
        return nil
    }

    public static func rkValue(from result: ResultValue) -> NSCopying & NSSecureCoding & NSObjectProtocol {
        switch result {
        case .int(let int):
            return NSNumber(integerLiteral: int)
        case .string(let string):
            return NSString(string: string)
        case .date(let date):
            return date as NSDate
        }
    }

    public static func value(from rkValue: NSCopying & NSSecureCoding & NSObjectProtocol) -> ResultValue? {
        if let number = rkValue as? NSNumber {
            return .int(number.intValue)
        } else if let string = rkValue as? NSString {
            return .string(String(string))
        } else if let date = rkValue as? Date {
            return .date(date)
        }
        assertionFailure("Unexpected RKValue type passed in, this is a developer error")
        return nil
    }}

#if DEBUG
extension RKAdapter {
    public static func test_extractUUID(_ string: String) -> String? {
        Self.extractUUID(string)
    }

    public static func test_hasMatchingIdentifiers(firstIdentifier: String, secondIdentifier: String) -> Bool {
        Self.hasMatchingIdentifiers(firstIdentifier: firstIdentifier, secondIdentifier: secondIdentifier)
    }

    public static func test_groupItems(_ items: [ORKFormItem]) -> [ORKFormItem] {
        Self.groupItems(items)
    }
}
#endif
