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
                        choiceText: textChoice.text
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

        case let textChoiceScaleAnswerFormat as ORKTextScaleAnswerFormat:
            let answerOptions = textChoiceScaleAnswerFormat.textChoices.map { textChoice in
                MultipleChoiceOption(
                    id: UUID().uuidString,
                    choiceText: textChoice.text
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
        case let textAnswerFormat as ORKTextAnswerFormat:
            return FormRow.textRow(
                TextQuestion(
                    title: title,
                    id: identifier,
                    text: textAnswerFormat.defaultTextAnswer ?? "",
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

            let initialPrimaryValue: Int = {
                // To set the picker at a nice middle of the road height
                // we will set it to 5 feet initially
                if measurementSystem == .USC {
                    return 5
                }

                // Similar to above, this equate to 5'4" which
                // is a good starting point for the picker.
                if measurementSystem == .metric {
                    return 162
                }

                return Locale.current.measurementSystem == .us ? 5 : 162
            }()

            return FormRow.heightRow(
                HeightQuestion(
                    id: identifier,
                    title: title,
                    detail: detail,
                    measurementSystem: measurementSystem,
                    selection: (initialPrimaryValue, 4) // Denotes 4 inches which is paired with a 5 foot selection (162 cm)
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
                    selection: (defaultValue, 0)
                )
            )
        case let imageChoiceAnswerFormat as ORKImageChoiceAnswerFormat:
            let choices = imageChoiceAnswerFormat.imageChoices.map { choice in
                let value = (choice.value as? NSNumber) as! Int
                return ImageChoice(
                    id: UUID(),
                    normalImage: choice.normalStateImage,
                    selectedImage: choice.selectedStateImage,
                    text: choice.text!, value: value
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
    
    @ResearchTaskBuilder
    static public func createSteps(for task: ORKOrderedTask) -> [ResearchTaskStep] {
        for step in task.steps {
            researchTaskStep(for: step)
        }
    }
    
    @ResearchTaskBuilder
    static private func researchTaskStep(for step: ORKStep) -> [ResearchTaskStep] {
        if let formStep = step as? ORKFormStep {
            ResearchTaskStep(title: formStep.title, subtitle: formStep.detailText) {
                if let formItems = formStep.formItems {
                    ForEach(groupItems(formItems), id: \.identifier) { formItem in
                        if let answerFormat = formItem.answerFormat {
                            switch answerFormat {
                            case let textChoiceAnswerFormat as ORKTextChoiceAnswerFormat:
                                MultipleChoiceQuestionView(
                                    id: formItem.identifier,
                                    title: formItem.text ?? "",
                                    choices: textChoiceAnswerFormat.textChoices.map { textChoice in
                                        MultipleChoiceOption(
                                            id: UUID().uuidString,
                                            choiceText: textChoice.text
                                        )
                                    },
                                    selectionType: textChoiceAnswerFormat.style == .singleChoice ? .single : .multiple
                                )
                            case let scaleAnswerFormat as ORKScaleAnswerFormat:
                                InputManagedScaleSliderQuestion(
                                    id: formItem.identifier,
                                    title: formItem.text ?? "",
                                    range: scaleAnswerFormat.minimum...scaleAnswerFormat.maximum,
                                    step: Double(scaleAnswerFormat.step),
                                    selection: scaleAnswerFormat.defaultValue
                                )
                            case let continuousScaleAnswerFormat as ORKContinuousScaleAnswerFormat:
                                let stepSize: Double = {
                                    // Current ORKContinuousScaleAnswerFormat does not allow user to specify step size so we can create an approximation,
                                    // falling back on 0.01 as our step size if required.
                                    var stepSize = 0.01
                                    let numberOfValues = continuousScaleAnswerFormat.maximum - continuousScaleAnswerFormat.minimum
                                    if numberOfValues > 0 {
                                        stepSize = 1.0 / numberOfValues
                                    }
                                    return stepSize
                                }()
                                
                                InputManagedScaleSliderQuestion(
                                    id: formItem.identifier,
                                    title: formItem.text ?? "",
                                    range: continuousScaleAnswerFormat.minimum...continuousScaleAnswerFormat.maximum,
                                    step: stepSize,
                                    selection: continuousScaleAnswerFormat.defaultValue
                                )
                            case let textChoiceScaleAnswerFormat as ORKTextScaleAnswerFormat:
                                let answerOptions = textChoiceScaleAnswerFormat.textChoices.map { textChoice in
                                    MultipleChoiceOption(
                                        id: UUID().uuidString,
                                        choiceText: textChoice.text
                                    )
                                }
                                
                                if answerOptions.indices.contains(textChoiceScaleAnswerFormat.defaultIndex) {
                                    InputManagedScaleSliderQuestion(
                                        id: formItem.identifier,
                                        title: formItem.text ?? "",
                                        multipleChoiceOptions: answerOptions,
                                        selection: answerOptions[textChoiceScaleAnswerFormat.defaultIndex]
                                    )
                                }
                            case let textAnswerFormat as ORKTextAnswerFormat:
                                TextQuestionView(
                                    id: formItem.identifier,
                                    title: formItem.text ?? "",
                                    detail: "",
                                    prompt: formItem.placeholder,
                                    textFieldType: textAnswerFormat.multipleLines ? .multiline : .singleLine,
                                    characterLimit: textAnswerFormat.maximumLength,
                                    hideCharacterCountLabel: textAnswerFormat.hideCharacterCountLabel,
                                    hideClearButton: textAnswerFormat.hideClearButton
                                )
                            case let dateTimeAnswerFormat as ORKDateAnswerFormat:
                                let prompt: String = {
                                    if let placeholder = formItem.placeholder {
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
                                
                                DateTimeView(
                                    id: formItem.identifier,
                                    title: formItem.text ?? "",
                                    pickerPrompt: prompt,
                                    displayedComponents: components,
                                    range: startDate...endDate
                                )
                            case let numericAnswerFormat as ORKNumericAnswerFormat:
                                NumericQuestionView(
                                    id: formItem.identifier,
                                    text: numericAnswerFormat.defaultNumericAnswer?.decimalValue,
                                    title: formItem.text ?? "",
                                    prompt: numericAnswerFormat.placeholder ?? "Tap to answer"
                                )
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

                                HeightQuestionView(
                                    id: formItem.identifier,
                                    title: formItem.text ?? "",
                                    measurementSystem: measurementSystem
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
                                let defaultValue: Double = {
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
                                
                                WeightQuestionView(
                                    id: formItem.identifier,
                                    title: formItem.text ?? "",
                                    measurementSystem: measurementSystem,
                                    precision: precision,
                                    defaultValue: defaultValue,
                                    minimumValue: minimumValue,
                                    maximumValue: maximumValue
                                )
                            case let imageChoiceAnswerFormat as ORKImageChoiceAnswerFormat:
                                let choices = imageChoiceAnswerFormat.imageChoices.map { choice in
                                    let value = (choice.value as? NSNumber) as! Int
                                    return ImageChoice(
                                        id: UUID(),
                                        normalImage: choice.normalStateImage,
                                        selectedImage: choice.selectedStateImage,
                                        text: choice.text!, value: value
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

                                ImageChoiceView(
                                    id: formItem.identifier,
                                    title: formItem.text ?? "",
                                    detail: formItem.detailText,
                                    choices: choices,
                                    style: style,
                                    vertical: imageChoiceAnswerFormat.isVertical
                                )
                            default:
                                EmptyView()
                            }
                        }
                    }
                }
            }
        } else if let questionStep = step as? ORKQuestionStep {
            ResearchTaskStep(title: questionStep.title, subtitle: questionStep.detailText) {
                InputManagedQuestionView(
                    id: questionStep.identifier,
                    question: questionStep.question ?? "",
                    answer: RKAdapter.createFormRow(from: questionStep, for: questionStep.answerFormat!)!
                )
            }
        } else if let instructionStep = step as? ORKInstructionStep {
            let image: Image? = {
                let image: Image?
                if let iconImage = instructionStep.iconImage {
                    image = Image(uiImage: iconImage)
                } else {
                    image = nil
                }
                return image
            }()
            
            ResearchTaskStep(
                image: image,
                title: instructionStep.title,
                subtitle: instructionStep.text
            ) {
                if let bodyItems = instructionStep.bodyItems {
                    ForEach(Array(bodyItems.enumerated()), id: \.offset) { _, bodyItem in
                        HStack {
                            if let image = bodyItem.image {
                                Image(uiImage: image)
                                    .frame(width: 40, height: 40)
                                    .foregroundStyle(.bodyItemIconForegroundStyle)
                            }
                            
                            Text(bodyItem.text ?? "")
                                .font(.subheadline)
                        }
                    }
                }
            }
        }
    }

    static public func createStepsFromORKTask(_ task: ORKOrderedTask) -> [Step] {
        let steps = task.steps
        var stepArray: [Step] = []
        for step in steps {
            if let formStep = step as? ORKFormStep {
                stepArray.append(.formStep(
                    FormStep(
                        id: UUID(uuidString: step.identifier) ?? UUID(),
                        title: step.title,
                        subtitle: step.detailText,
                        items: RKAdapter.createFormRowsFromORKStep(formStep)
                    )
                ))
            } else if let questionStep = step as? ORKQuestionStep {
                stepArray.append(.questionStep(
                    QuestionStep(
                        identifier: questionStep.identifier,
                        title: questionStep.title ?? "",
                        question: questionStep.question ?? "",
                        answer: RKAdapter.createFormRow(from: questionStep, for: questionStep.answerFormat!)!
                    )
                ))
            } else if let instructionStep = step as? ORKInstructionStep {
                stepArray.append(.instructionStep(
                    InstructionStep(
                        identifier: instructionStep.identifier,
                        title: instructionStep.title ?? "",
                        subtitle: instructionStep.text
                    )
                ))
            }
        }
        return stepArray
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
            switch value.format {
            case .text:
                let result = ORKTextQuestionResult(identifier: value.id)
                if let answer = value.answer as? String {
                    result.textAnswer = answer
                }
                resultsArray.append(result)
            default:
                resultsArray.append(ORKResult(identifier: entry.key))
            }
        }

        return resultsArray
    }

    public static func restoreData(_ data: Data, to steps: [ResearchTaskStep]) {

    }
}
