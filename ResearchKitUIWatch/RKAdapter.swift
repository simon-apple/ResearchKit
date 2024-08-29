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

public class RKAdapter {
    public static func createFormRow(from item: ORKFormItem) -> FormRow? {
        guard let answerFormat = item.answerFormat else {
            return nil
        }

        return Self.createFormRow(from: item.identifier, with: item.text ?? "", detail: item.detailText, placeholder: item.placeholder, answer: answerFormat)
    }

    public static func createFormRow(from step: ORKStep, for answer: ORKAnswerFormat) -> FormRow? {
        let itemText: String? = {
            if let questionStep = step as? ORKQuestionStep {
                return questionStep.question ?? step.text
            } else {
                return step.text
            }
        }()

        let placeholder: String? = {
            if let formStep = step as? ORKFormStep,
               let placeholder = formStep.formItems?.first?.placeholder {
                return placeholder
            }
            return nil
        }()

        return Self.createFormRow(from: step.identifier, with: itemText ?? "", detail: step.detailText, placeholder: placeholder, answer: answer)
    }

    public static func createFormRow(from identifier: String, with title: String, detail: String?, placeholder: String? = nil, answer: ORKAnswerFormat) -> FormRow? {

        switch answer {
        case let textChoiceAnswerFormat as ORKTextChoiceAnswerFormat:
            var answerOptions : [MultipleChoiceOption] = []
            textChoiceAnswerFormat.textChoices.forEach { textChoice in
                answerOptions.append(
                    MultipleChoiceOption(
                        id: UUID().uuidString,
                        choiceText: textChoice.text,
                        value: textChoice.value
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
                MultipleChoiceOption(
                    id: UUID().uuidString,
                    choiceText: textChoice.text,
                    value: textChoice.value
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
                    answer: .none(default: textAnswerFormat.defaultTextAnswer),
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
                return ImageChoice(
                    normalImage: choice.normalStateImage,
                    selectedImage: choice.selectedStateImage,
                    text: choice.text!,
                    value: choice.value
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
                result.textAnswer = answer.value
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
                result.numericAnswer = NSNumber(floatLiteral: height)
                resultsArray.append(result)
            case .weight(let weight):
                let result = ORKNumericQuestionResult(identifier: entry.key)
                result.questionType = .weight
                result.numericAnswer = NSNumber(floatLiteral: weight)
                resultsArray.append(result)
            case .image(let image):
                let result = ORKChoiceQuestionResult(identifier: entry.key)
                result.questionType = .multipleChoice
                let values = image.compactMap { $0.value }
                result.answer = values as any ResultValue
                resultsArray.append(result)
            case .multipleChoice(let multipleChoice):
                let result = ORKChoiceQuestionResult(identifier: entry.key)
                result.questionType = .multipleChoice
                let values = multipleChoice.compactMap { $0.value }
                result.answer = values as any ResultValue
                resultsArray.append(result)
            }
        }

        return resultsArray
    }
}

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
