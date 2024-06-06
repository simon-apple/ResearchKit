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

import ResearchKit
import SwiftUI

class FormStepViewModel: ObservableObject {

    @ObservedObject
    private(set) var step: ORKFormStep

    @ObservedObject
    private(set) var result: ORKStepResult

    @Published
    var formRows: [FormRow]

    var progress: Progress?

    var childResult: ORKResult? {
        get {
            return result.results?.first
        }
        set {
            if let value = newValue {
                value.startDate = result.startDate
                value.endDate = Date()
                result.results = [value]
            } else {
                result.results = nil
            }
        }
    }
    
    var numberOfQuestions: Int {
        step.formItems?.count ?? 0
    }

    init(step: ORKFormStep, result: ORKStepResult) {
        self.step = step
        self.result = result
        self.formRows = Self.createFormRowsFromORKStep(step)
    }

    static func createFormRowsFromORKStep(_ step: ORKFormStep) -> [FormRow] {
        // Convert our ORKFormItems to FormRows with associated values
        guard let formItems = step.formItems else {
            assertionFailure("Attempting to create an empty ORKFormStep")
            return []
        }

        let formRows = formItems.compactMap { formItem in
            #warning("[AY] Handle optional string")
            let questionText = formItem.text ?? ""
            switch formItem.answerFormat {
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
                            id: formItem.identifier,
                            title: questionText,
                            choices: answerOptions,
                            selectionType: textChoiceAnswerFormat.style == .singleChoice ? .single : .multiple
                         )
                     )
                case let scaleAnswerFormat as ORKScaleAnswerFormat:
                    return FormRow.scale(
                        ScaleSliderQuestion(
                            title: questionText,
                            id: formItem.identifier,
                            selectionType: .integerRange(scaleAnswerFormat.minimum...scaleAnswerFormat.maximum),
                            result: 1
                        )
                    )
                case let continuousScaleAnswerFormat as ORKContinuousScaleAnswerFormat:
                    return FormRow.scale(
                        ScaleSliderQuestion(
                            title: questionText,
                            id: formItem.identifier,
                            selectionType: .doubleRange(continuousScaleAnswerFormat.minimum...continuousScaleAnswerFormat.maximum),
                            result: 1
                        )
                    )

                case let textChoiceScaleAnswerFormat as ORKTextScaleAnswerFormat:
                    #warning("[AY] remove uuid string as identifier")
                    let answerOptions = textChoiceScaleAnswerFormat.textChoices.map { textChoice in
                        MultipleChoiceOption(
                            id: UUID().uuidString,
                            choiceText: textChoice.text
                        )
                    }
                    return FormRow.scale(
                        ScaleSliderQuestion(
                            title: questionText,
                            id: formItem.identifier,
                            selectionType: .textChoice(answerOptions),
                            result: MultipleChoiceOption(id: UUID().uuidString, choiceText: "")
                        )
                    )
            default:
                return nil
            }
        }
        
        return formRows
    }

    // TODO: Move this logic out to an adapter class 🛠️
    // rdar://127850219 (Create an RK Adapter class to handle translation layer)
    func createORKResult() {

        var resultArray: [ORKResult] = []

        for row in formRows {
            switch row {
            case .multipleChoiceRow(let multipleChoiceRow):
                let result = ORKChoiceQuestionResult(identifier: multipleChoiceRow.id)
                result.choiceAnswers = multipleChoiceRow.result.map { $0.choiceText as NSString }
                resultArray.append(result)

            case .scale(let scaleRow):
                switch scaleRow.selectionType {
                case .textChoice(_):
                    let result = ORKTextQuestionResult(identifier: scaleRow.id)
                    result.textAnswer = scaleRow.result as? String
                    resultArray.append(result)

                case .integerRange(_), .doubleRange(_):
                    let result = ORKScaleQuestionResult(identifier: scaleRow.id)
                    result.scaleAnswer = scaleRow.result as? NSNumber
                    resultArray.append(result)
                }
            }
        }

        // Step result may be nil if the user skipped a step
        if resultArray.isEmpty == false {
            self.result.results = resultArray
        }
    }
    
    func questionNumber(for formRow: FormRow) -> Int? {
        let answerOptionNumber: Int?
        if let index = step.formItems?.firstIndex(where: { formItem in
            formItem.identifier == formRow.id
        }) {
            answerOptionNumber = index + 1
        } else {
            answerOptionNumber = nil
        }
        return answerOptionNumber
    }
    
}
