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
        switch item.answerFormat {
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
                    id: item.identifier,
                    title: item.text,
                    choices: answerOptions,
                    selectionType: textChoiceAnswerFormat.style == .singleChoice ? .single : .multiple
                )
            )
        case let scaleAnswerFormat as ORKScaleAnswerFormat:
            return FormRow.intSliderRow(
                ScaleSliderQuestion(
                    id: item.identifier,
                    title: item.text ?? "",
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
                    id: item.identifier,
                    title: item.text ?? "",
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
                    id: item.identifier,
                    title: item.text ?? "",
                    options: answerOptions,
                    selectedMultipleChoiceOption: defaultOption
                )
            )
        case let textAnswerFormat as ORKTextAnswerFormat:
            return FormRow.textRow(
                TextQuestion(
                    title: item.text ?? "",
                    id: item.identifier,
                    text: textAnswerFormat.defaultTextAnswer ?? "",
                    prompt: textAnswerFormat.placeholder ?? "",
                    textFieldType: textAnswerFormat.multipleLines ? .multiline : .singleLine,
                    characterLimit: textAnswerFormat.maximumLength,
                    hideCharacterCountLabel: textAnswerFormat.hideCharacterCountLabel,
                    hideClearButton: textAnswerFormat.hideClearButton
                )
            )
        case let dateTimeAnswerFormat as ORKDateAnswerFormat:
            let prompt: String = {
                if let placeholder = item.placeholder {
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
                    id: item.identifier,
                    title: item.text ?? "",
                    selection: Date(),
                    pickerPrompt: prompt,
                    displayedComponents: components,
                    range: startDate...endDate
                )
            )
        case let numericAnswerFormat as ORKNumericAnswerFormat:
            return FormRow.numericRow(
                NumericQuestion(
                    id: item.identifier,
                    title: item.text ?? "",
                    detail: item.detailText,
                    prompt: numericAnswerFormat.placeholder ?? "Tap to answer",
                    number: numericAnswerFormat.defaultNumericAnswer
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

        let formRows = formItems.compactMap { formItem in
            Self.createFormRow(from: formItem)
        }

        return formRows
    }

    @ViewBuilder
    static func content(
        title: String,
        detail: String?,
        for formRow: Binding<FormRow>
    ) -> some View {
        switch formRow.wrappedValue {
        case .multipleChoiceRow(let multipleChoiceValue):
            MultipleChoiceQuestionView(
                title: title,
                detail: detail,
                choices: multipleChoiceValue.choices,
                selectionType: multipleChoiceValue.selectionType,
                result: .init(
                    get: {
                        return multipleChoiceValue.result
                    },
                    set: { newValue in
                        formRow.wrappedValue = .multipleChoiceRow(
                            MultipleChoiceQuestion(
                                id: multipleChoiceValue.id,
                                title: multipleChoiceValue.title,
                                choices: multipleChoiceValue.choices,
                                result: newValue,
                                selectionType: multipleChoiceValue.selectionType
                            )
                        )
                    }
                )
            )
        case .doubleSliderRow(let doubleSliderQuestion):
            ScaleSliderQuestionView(
                title: title,
                detail: detail,
                range: doubleSliderQuestion.range,
                step: doubleSliderQuestion.step,
                selection: .init(get: {
                    return doubleSliderQuestion.result
                }, set: { newValue in
                    formRow.wrappedValue = .doubleSliderRow(
                        ScaleSliderQuestion(
                            id: doubleSliderQuestion.id,
                            title: doubleSliderQuestion.title,
                            range: doubleSliderQuestion.range,
                            value: newValue
                        )
                    )
                }
            ))

        case .intSliderRow(let intSliderQuestion):
            ScaleSliderQuestionView(
                title: title,
                detail: detail,
                range: intSliderQuestion.range,
                selection: .init(get: {
                    return intSliderQuestion.intResult
                }, set: { newValue in
                    formRow.wrappedValue = .intSliderRow(
                        ScaleSliderQuestion(
                            id: intSliderQuestion.id,
                            title: intSliderQuestion.title,
                            range: intSliderQuestion.range,
                            value: newValue
                        )
                    )
                })
            )

        case .textSliderStep(let textSliderQuestion):
            ScaleSliderQuestionView(
                title: title,
                detail: detail,
                multipleChoiceOptions: textSliderQuestion.multipleChoiceOptions,
                selection: .init(get: {
                    return textSliderQuestion.result
                }, set: { newValue in
                    formRow.wrappedValue = .textSliderStep(
                        ScaleSliderQuestion(
                            id: textSliderQuestion.id,
                            title: textSliderQuestion.title,
                            options: textSliderQuestion.multipleChoiceOptions,
                            selectedMultipleChoiceOption: newValue
                        )
                    )
                })
            )
        case .textRow(let textQuestion):
            TextQuestionView(
                text: .init(get: {
                    return textQuestion.text
                }, set: { newValue in
                    formRow.wrappedValue = .textRow(
                        TextQuestion(
                            title: textQuestion.title,
                            id: textQuestion.id,
                            text: newValue,
                            prompt: textQuestion.prompt,
                            textFieldType: textQuestion.textFieldType,
                            characterLimit: textQuestion.characterLimit,
                            hideCharacterCountLabel: textQuestion.hideCharacterCountLabel,
                            hideClearButton: textQuestion.hideClearButton
                        )
                    )
                }),
                title: title,
                detail: detail,
                prompt: textQuestion.prompt,
                textFieldType: textQuestion.textFieldType,
                characterLimit: textQuestion.characterLimit
            )
        case .dateRow(let dateQuestion):
            DateTimeView(
                title: title,
                detail: detail,
                selection: .init(get: {
                    return dateQuestion.selection
                }, set: { newValue in
                    formRow.wrappedValue = .dateRow(
                        DateQuestion(
                            id: dateQuestion.id,
                            title: dateQuestion.title,
                            selection: newValue,
                            pickerPrompt: dateQuestion.pickerPrompt,
                            displayedComponents: dateQuestion.displayedComponents,
                            range: dateQuestion.range
                        )
                    )
                }),
                pickerPrompt: dateQuestion.pickerPrompt,
                displayedComponents: dateQuestion.displayedComponents,
                range: dateQuestion.range
            )
        case .numericRow(let numericQuestion):
            NumericQuestionView(
                text: .init(
                    get: {
                        let decimal: Decimal?
                        if let doubleValue = numericQuestion.number?.doubleValue {
                            decimal = Decimal(doubleValue)
                        } else {
                            decimal = nil
                        }
                        return decimal
                    },
                    set: { newValue in
                        formRow.wrappedValue = .numericRow(
                            NumericQuestion(
                                id: numericQuestion.id,
                                title: numericQuestion.title,
                                detail: numericQuestion.detail,
                                prompt: numericQuestion.prompt,
                                number: newValue as? NSDecimalNumber
                            )
                        )
                    }
                ),
                title: numericQuestion.title,
                detail: detail,
                prompt: numericQuestion.prompt
            )
        }
    }
}
