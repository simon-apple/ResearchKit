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
                id: multipleChoiceValue.id,
                title: multipleChoiceValue.title ?? "",
                detail: detail,
                choices: multipleChoiceValue.choices,
                selectionType: multipleChoiceValue.selectionType
            )
        case .doubleSliderRow(let doubleSliderQuestion):
            ScaleSliderQuestionView(
                id: doubleSliderQuestion.id,
                title: doubleSliderQuestion.title,
                detail: detail,
                range: doubleSliderQuestion.range,
                step: doubleSliderQuestion.step,
                selection: doubleSliderQuestion.result
            )
        case .intSliderRow(let intSliderQuestion):
            ScaleSliderQuestionView(
                id: intSliderQuestion.id,
                title: intSliderQuestion.title,
                detail: detail,
                range: intSliderQuestion.range,
                selection: intSliderQuestion.intResult
            )
#if !os(watchOS)
        case .textSliderStep(let textSliderQuestion):
            ScaleSliderQuestionView(
                id: textSliderQuestion.id,
                title: textSliderQuestion.title,
                detail: detail,
                multipleChoiceOptions: textSliderQuestion.multipleChoiceOptions,
                selection: textSliderQuestion.result
            )
#endif
            
        case .textRow(let textQuestion):
            TextQuestionView(
                id: textQuestion.id,
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
                id: dateQuestion.id,
                title: dateQuestion.title,
                detail: detail,
                pickerPrompt: dateQuestion.pickerPrompt,
                displayedComponents: dateQuestion.displayedComponents,
                range: dateQuestion.range
            )
#if !os(watchOS)
        case .numericRow(let numericQuestion):
            NumericQuestionView(
                id: numericQuestion.id,
                title: numericQuestion.title,
                detail: detail,
                prompt: numericQuestion.prompt
            )
#endif
        case .heightRow(let heightQuestion):
            HeightQuestionView(
                id: heightQuestion.id,
                title: heightQuestion.title,
                detail: detail,
                measurementSystem: heightQuestion.measurementSystem
            )
        case .weightRow(let weightQuestion):
            WeightQuestionView(
                id: weightQuestion.id,
                title: weightQuestion.title,
                detail: detail,
                measurementSystem: weightQuestion.measurementSystem,
                precision: weightQuestion.precision,
                defaultValue: weightQuestion.defaultValue,
                minimumValue: weightQuestion.minimumValue,
                maximumValue: weightQuestion.maximumValue
            )
        case .imageRow(let imageQuestion):
            ImageChoiceView(
                id: imageQuestion.id,
                title: imageQuestion.title,
                detail: detail,
                choices: imageQuestion.choices,
                style: imageQuestion.style,
                vertical: imageQuestion.vertical
            )
        }
    }
}

