//
//  FormRowContent.swift
//  ResearchKitUI(Watch)
//
//  Created by Johnny Hicks on 7/2/24.
//
import SwiftUI

public struct FormRowContent {
    @ViewBuilder
    public static func content(
        detail: String?,
        for formRow: Binding<FormRow>
    ) -> some View {
        switch formRow.wrappedValue {
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
                title: doubleSliderQuestion.title,
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
                title: intSliderQuestion.title,
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
                title: textSliderQuestion.title,
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
