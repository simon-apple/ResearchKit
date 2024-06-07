/*
 Copyright (c) 2020, Apple Inc. All rights reserved.
 
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

// apple-internal

import ResearchKit
import SwiftUI

internal struct FormStepView: View {
    
    @ObservedObject
    private var viewModel: FormStepViewModel
    
    @Environment(\.completion) var completion
    
    init(viewModel: FormStepViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        List {
            ListHeaderView {
                StepHeaderView(viewModel: viewModel)
            }
            ForEach($viewModel.formRows) { $formRow in
                Section {
                    StepSectionHeaderView(viewModel: viewModel, formRow: formRow)
                    
                    content(for: $formRow)
                }
            }
            .listSectionSpacing(.compact)
        }
#if os(visionOS)
        .navigationTitle(
            Text(viewModel.step.title ?? "")
        )
#endif
    }
    
    @ViewBuilder
    private func content(for formRow: Binding<FormRow>) -> some View {
        switch formRow.wrappedValue {
        case .multipleChoiceRow(let multipleChoiceValue):
            MultipleChoiceQuestionView(
                title: multipleChoiceValue.title,
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
                range: intSliderQuestion.range,
                selection: .init(get: {
                    return intSliderQuestion.result
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
        }
    }
    
}
