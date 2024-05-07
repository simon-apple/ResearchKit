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

import ResearchKitCore
import SwiftUI

struct TextRowValue: Identifiable, Hashable {
    let id = UUID()
    var text: String = ""
}

enum FormRow: Identifiable, Hashable {
    
    static func == (lhs: FormRow, rhs: FormRow) -> Bool {
       return lhs.hashValue == rhs.hashValue
    }
    
    case textRow(TextRowValue)
    case multipleChoiceRow(MultipleChoiceQuestion<UUID>)

    var id: AnyHashable {
        switch self {
            case .textRow(let textRowValue):
                textRowValue.id
            case .multipleChoiceRow(let multipleChoiceValue):
                multipleChoiceValue.id
        }
    }

//    var result: Any {
//        switch self {
//        case .textRow(let value):
//            value.text
//        case .multipleChoiceRow(let value):
//            value.result
//        }
//    }
}

internal struct FormStepView: View {

    enum Constants {
        static let topToProgressPadding: CGFloat = 4.0
        static let bottomToProgressPadding: CGFloat = 4.0
        static let questionToAnswerPadding: CGFloat = 12.0
    }

    @State
    private var viewModel: FormStepViewModel

    @Environment(\.completion) var completion
    
    init(viewModel: FormStepViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {

        ScrollView {
            VStack {
                Group {
                    if let progress = viewModel.progress {
                        Text("\(progress.index) OF \(progress.count)".uppercased())
                            .foregroundColor(.gray)
                            .font(.subheadline)
                            .padding(.top, Constants.topToProgressPadding)
                            .padding(.bottom, Constants.bottomToProgressPadding)
                    }
                    
                    if let stepTitle = viewModel.step.title {
                        Text(stepTitle)
                            .font(.body)
                            .fontWeight(.semibold)
                            .multilineTextAlignment(.leading)
                            .padding(.bottom, Constants.questionToAnswerPadding)
                    }

                    ForEach($viewModel.formRows) { $formRow in
                        switch formRow {
                        case .textRow(let value):
                            Text("hi")
                        case .multipleChoiceRow(let value):
                            Text("")

                            MultipleChoiceQuestionView(
                                result: .init(get: {
                                    value.result
                                }, set: { newValue in
                                    print("newValue \(newValue)")


                                    viewModel.formRows[0] = .multipleChoiceRow(MultipleChoiceQuestion(title: "", choices: [], result: newValue))
//
//                                    print("newValue \(newValue)")
                                    print("formRow \(self.viewModel.formRows)")


                                }),
                                multipleChoiceQuestion: value
                            )
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading)
            }
        }
    }

//    @ViewBuilder
//    func viewFor(formRow: Binding<FormRow>) -> some View {
//
//    }
}

/*
 .init(
                                 get: {
                                     info.textField
                                 },
                                 set: { newValue in
                                     component = .textfield(
                                         TextFieldComponentInfo(
                                             id: info.id,
                                             contextLabel: info.contextLabel,
                                             placeholder: info.placeholder,
                                             textField: newValue
                                         )
                                     )
                                 }
 */
