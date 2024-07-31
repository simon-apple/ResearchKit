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
    
    let detail: String?
    @Binding var formRow: FormRow
    
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
                        multipleChoiceValue.result
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
                selection: .init(
                    get: {
                        doubleSliderQuestion.result
                    },
                    set: { newValue in
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
                )
            )
            
        case .intSliderRow(let intSliderQuestion):
            ScaleSliderQuestionView(
                title: intSliderQuestion.title,
                detail: detail,
                range: intSliderQuestion.range,
                selection: .init(
                    get: {
                        intSliderQuestion.intResult
                    },
                    set: { newValue in
                        formRow = .intSliderRow(
                            ScaleSliderQuestion(
                                id: intSliderQuestion.id,
                                title: intSliderQuestion.title,
                                range: intSliderQuestion.range,
                                value: newValue
                            )
                        )
                    }
                )
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
                }
                                )
            )
        case .textRow(let textQuestion):
            TextQuestionView(
                text: .init(
                    get: {
                        textQuestion.text
                    },
                    set: { newValue in
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
                    }
                ),
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
                selection: .init(
                    get: {
                        dateQuestion.selection
                    },
                    set: { newValue in
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
                    }
                ),
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
                detail: detail,
                measurementSystem: heightQuestion.measurementSystem,
                selection: .init(
                    get: {
                        let firstValue = heightQuestion.selection.0 ?? 0
                        let secondValue = heightQuestion.selection.1 ?? 0
                        return (firstValue, secondValue)
                    },
                    set: { newValue in
                        formRow = .heightRow(
                            HeightQuestion(
                                id: heightQuestion.id,
                                title: heightQuestion.title,
                                detail: heightQuestion.detail,
                                measurementSystem: heightQuestion.measurementSystem,
                                selection: newValue
                            )
                        )
                    }
                )
            )
        case .weightRow(let weightQuestion):
            WeightQuestionView(
                title: weightQuestion.title,
                detail: detail,
                measurementSystem: weightQuestion.measurementSystem,
                precision: weightQuestion.precision,
                defaultValue: weightQuestion.defaultValue,
                minimumValue: weightQuestion.minimumValue,
                maximumValue: weightQuestion.maximumValue,
                selection: .init(
                    get: {
                        let firstValue = weightQuestion.selection.0 ?? 0
                        let secondValue = weightQuestion.selection.1 ?? 0
                        return (firstValue, secondValue)
                    },
                    set: { newValue in
                        formRow = .weightRow(
                            WeightQuestion(
                                id: weightQuestion.id,
                                title: weightQuestion.title,
                                detail: detail,
                                measurementSystem: weightQuestion.measurementSystem,
                                precision: weightQuestion.precision,
                                defaultValue: weightQuestion.defaultValue,
                                minimumValue: weightQuestion.minimumValue,
                                maximumValue: weightQuestion.maximumValue,
                                selection: newValue
                            )
                        )
                    }
                )
            )
        case .imageRow(let imageQuestion):
            ImageChoiceView(
                title: imageQuestion.title,
                detail: detail,
                choices: imageQuestion.choices,
                style: imageQuestion.style,
                vertical: imageQuestion.vertical,
                selection: .init(get: {
                    return imageQuestion.selections
                }, set: { newValue in
                    $formRow.wrappedValue = .imageRow(
                        ImageChoiceQuestion(
                            title: imageQuestion.title,
                            detail: detail,
                            id: imageQuestion.id,
                            choices: imageQuestion.choices,
                            style: imageQuestion.style,
                            vertical: imageQuestion.vertical,
                            selections: newValue
                        )
                    )
                })
            )
        }
    }
}

public struct ResearchForm<Content: View>: View {
    
    private let title: Text
    private let subtitle: Text
    private let content: Content
    
    public init(title: Text, subtitle: Text, @ViewBuilder content: () -> Content) {
        self.title = title
        self.subtitle = subtitle
        self.content = content()
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HeaderView(title: title, subtitle: subtitle)
            
            content
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
}

public struct InputManagedDateTimeQuestion: View {
    
    private let title: String
    private let detail: String
    private let pickerPrompt: String
    private let displayedComponents: DatePicker.Components
    private let range: ClosedRange<Date>
    @State private var date: Date
    
    public init(
        title: String,
        detail: String,
        pickerPrompt: String,
        displayedComponents: DatePicker.Components,
        range: ClosedRange<Date>,
        date: Date = Date()
    ) {
        self.title = title
        self.detail = detail
        self.pickerPrompt = pickerPrompt
        self.displayedComponents = displayedComponents
        self.range = range
        self.date = date
    }
    
    public var body: some View {
        DateTimeView(
            title: title,
            detail: detail,
            selection: $date,
            pickerPrompt: pickerPrompt,
            displayedComponents: .date,
            range: Date.distantPast...Date.distantFuture
        )
    }
    
}

public struct InputManagedTextQuestion<Header: View>: View {
    
    private let header: Header
    private let multilineTextFieldPadding: Double = 54
    private let prompt: String?
    private let textFieldType: TextFieldType
    private let characterLimit: Int
    private let hideCharacterCountLabel: Bool
    private let hideClearButton: Bool
    @State private var text: String

    public init(
        @ViewBuilder header: () -> Header,
        prompt: String?,
        textFieldType: TextFieldType,
        characterLimit: Int,
        hideCharacterCountLabel: Bool = false,
        hideClearButton: Bool = false,
        text: String = ""
    ) {
        self.header = header()
        self.prompt = prompt
        self.textFieldType = textFieldType
        self.characterLimit = characterLimit
        self.hideCharacterCountLabel = hideCharacterCountLabel
        self.hideClearButton = hideClearButton
        self.text = text
    }
    
    public var body: some View {
        TextQuestionView(
            header: {
                header
            },
            text: $text,
            prompt: prompt,
            textFieldType: textFieldType,
            characterLimit: characterLimit,
            hideCharacterCountLabel: hideCharacterCountLabel,
            hideClearButton: hideClearButton
        )
    }
    
}

public extension InputManagedTextQuestion where Header == _SimpleFormItemViewHeader {
    
    init(
        text: String,
        title: String,
        detail: String?,
        prompt: String?,
        textFieldType: TextFieldType,
        characterLimit: Int,
        hideCharacterCountLabel: Bool = false,
        hideClearButton: Bool = false
    ) {
        self.header = _SimpleFormItemViewHeader(title: title, detail: detail)
        self.text = text
        self.prompt = prompt
        self.textFieldType = textFieldType
        self.characterLimit = characterLimit
        self.hideCharacterCountLabel = hideCharacterCountLabel
        self.hideClearButton = hideClearButton
    }
    
}

public struct InputManagedScaleSliderQuestion: View {
    
    private let title: String

    private let detail: String?

    private let scaleSelectionConfiguration: ScaleSelectionConfiguration

    private let step: Double
    
    @State private var selection: ScaleSelectionValue
    
    private enum ScaleSelectionValue: Equatable {
        static func == (
            lhs: ScaleSelectionValue,
            rhs: ScaleSelectionValue
        ) -> Bool {
            switch lhs {
            case .textChoice(let lhsMultipleChoiceOption):
                guard case .textChoice(let rhsMultipleChoiceOption) = rhs else {
                    return false
                }
                return rhsMultipleChoiceOption.id == lhsMultipleChoiceOption.id
            case .int(let lhsInteger):
                guard case .int(let rhsInteger) = rhs else {
                    return false
                }
                return lhsInteger == rhsInteger
            case .double(let lhsDouble):
                guard case .double(let rhsDouble) = rhs else {
                    return false
                }
                return rhsDouble == lhsDouble
            }
            
        }

        case textChoice(MultipleChoiceOption)
        case int(Int)
        case double(Double)
    }
    
    public init(
        title: String,
        detail: String? = nil,
        range: ClosedRange<Double>,
        step: Double = 1.0,
        selection: Double = 5
    ) {
        self.title = title
        self.detail = detail
        self.scaleSelectionConfiguration = .doubleRange(range)
        self.step = step
        self.selection = .double(selection)
    }

    // The int version
    public init(
        title: String,
        detail: String? = nil,
        range: ClosedRange<Int>,
        step: Double = 1.0,
        selection: Int
    ) {
        self.title = title
        self.detail = detail
        self.scaleSelectionConfiguration = .integerRange(range)
        self.step = step
        self.selection = .int(selection)
    }

    // The multi choice version
    public init(
        title: String,
        detail: String? = nil,
        multipleChoiceOptions: [MultipleChoiceOption],
        selection: MultipleChoiceOption
    ) {
        self.title = title
        self.detail = detail
        self.scaleSelectionConfiguration = .textChoice(multipleChoiceOptions)
        self.step = 1.0
        self.selection = .textChoice(selection)
    }
    
    public var body: some View {
        switch (scaleSelectionConfiguration, selection) {
        case let (.textChoice(multipleChoiceOptions), .textChoice(textSelection)):
            ScaleSliderQuestionView(
                title: title,
                detail: detail,
                multipleChoiceOptions: multipleChoiceOptions,
                selection: .init(
                    get: {
                        textSelection
                    },
                    set: { newValue in
                        selection = .textChoice(newValue)
                    }
                )
            )
        case let (.integerRange(closedRange), .int(integerSelection)):
            ScaleSliderQuestionView(
                title: title,
                detail: detail,
                range: closedRange,
                selection: .init(
                    get: {
                        integerSelection
                    },
                    set: { newValue in
                        selection = .int(newValue)
                    }
                )
            )
        case let (.doubleRange(closedRange), .double(doubleSelection)):
            ScaleSliderQuestionView(
                title: title,
                detail: detail,
                range: closedRange,
                selection: .init(
                    get: {
                        doubleSelection
                    },
                    set: { newValue in
                        selection = .double(newValue)
                    }
                )
            )
        default:
            EmptyView()
        }
    }
    
}

