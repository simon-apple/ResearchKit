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

import SwiftUI

public struct FormRowContent: View {

    @Binding var formRow: FormRow
    let detail: String?

    public init(
        detail: String?,
        formRow: Binding<FormRow>
    ) {
        self.detail = detail
        _formRow = formRow
    }

    public var body: some View {
        switch formRow {
        case .multipleChoiceRow(let multipleChoiceValue):
            MultipleChoiceQuestionView(
                title: multipleChoiceValue.title ?? "",
                detail: detail,
                choices: multipleChoiceValue.choices,
                selectionType: multipleChoiceValue.selectionType,
                result: .init(
                    get: {
                        return multipleChoiceValue.result
                    },
                    set: { newValue in
                        formRow = .multipleChoiceRow(
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
                title: doubleSliderQuestion.title,
                detail: detail,
                range: doubleSliderQuestion.range,
                step: doubleSliderQuestion.step,
                selection: .init(get: {
                    return doubleSliderQuestion.result
                }, set: { newValue in
                    formRow = .doubleSliderRow(
                        ScaleSliderQuestion(
                            id: doubleSliderQuestion.id,
                            title: doubleSliderQuestion.title,
                            step: doubleSliderQuestion.step,
                            range: doubleSliderQuestion.range,
                            value: newValue
                        )
                    )
                }
            ))

        case .intSliderRow(let intSliderQuestion):
            ScaleSliderQuestionView(
                title: intSliderQuestion.title,
                detail: detail,
                range: intSliderQuestion.range,
                selection: .init(get: {
                    return intSliderQuestion.intResult
                }, set: { newValue in
                    formRow = .intSliderRow(
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
                title: textSliderQuestion.title,
                detail: detail,
                multipleChoiceOptions: textSliderQuestion.multipleChoiceOptions,
                selection: .init(get: {
                    return textSliderQuestion.result
                }, set: { newValue in
                    formRow = .textSliderStep(
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
                    textQuestion.text
                }, set: { newValue in
                    formRow = .textRow(
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
                title: textQuestion.title,
                detail: detail,
                prompt: textQuestion.prompt,
                textFieldType: textQuestion.textFieldType,
                characterLimit: textQuestion.characterLimit,
                hideCharacterCountLabel: textQuestion.hideCharacterCountLabel,
                hideClearButton: textQuestion.hideClearButton
            )
        case .dateRow(let dateQuestion):
            DateTimeView(
                title: dateQuestion.title,
                detail: detail,
                selection: .init(get: {
                    return dateQuestion.selection
                }, set: { newValue in
                    formRow = .dateRow(
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
                        formRow = .numericRow(
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
        case .heightRow(let heightQuestion):
            HeightQuestionView(
                title: heightQuestion.title,
                detail: heightQuestion.detail,
                measurementSystem: heightQuestion.measurementSystem,
                selection: .init(get: {
                    let firstValue = heightQuestion.selection.0 ?? 0
                    let secondValue = heightQuestion.selection.1 ?? 0
                    return (firstValue, secondValue)
                }, set: { newValue in
                    formRow = .heightRow(
                        HeightQuestion(
                            id: heightQuestion.id,
                            title: heightQuestion.title,
                            detail: heightQuestion.detail,
                            measurementSystem: heightQuestion.measurementSystem,
                            selection: newValue
                        )
                    )
                })
            )
        case .weightRow(let weightQuestion):
            WeightQuestionView(
                title: weightQuestion.title,
                detail: weightQuestion.detail,
                measurementSystem: weightQuestion.measurementSystem,
                precision: weightQuestion.precision,
                defaultValue: weightQuestion.defaultValue,
                minimumValue: weightQuestion.minimumValue,
                maximumValue: weightQuestion.maximumValue,
                selection: .init(get: {
                    let firstValue = weightQuestion.selection.0 ?? 0
                    let secondValue = weightQuestion.selection.1 ?? 0
                    return (firstValue, secondValue)
                }, set: { newValue in
                    formRow = .weightRow(
                        WeightQuestion(
                            id: weightQuestion.id,
                            title: weightQuestion.title,
                            detail: weightQuestion.detail,
                            measurementSystem: weightQuestion.measurementSystem,
                            precision: weightQuestion.precision,
                            defaultValue: weightQuestion.defaultValue,
                            minimumValue: weightQuestion.minimumValue,
                            maximumValue: weightQuestion.maximumValue,
                            selection: newValue
                        )
                    )
                })
            )
        }
    }
}
