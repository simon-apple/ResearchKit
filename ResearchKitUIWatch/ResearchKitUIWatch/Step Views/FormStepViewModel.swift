//
//  FormStepViewModel.swift
//  ResearchKitUI(Watch)
//
//  Created by Jessi Aboukasm on 4/1/24.
//

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

    init(step: ORKFormStep, result: ORKStepResult) {
        self.step = step
        self.result = result

        // Convert our ORKFormItems to FormRows with associated values 
        guard let formItems = step.formItems else {
            fatalError("Attempting to create an empty ORKFormStep")
        }

        self.formRows = formItems.compactMap { formItem in
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
    }

    // TODO: Move this logic out to an adapter class 🛠️
    // rdar://127850219 (Create an RK Adapter class to handle translation layer)
    func createORKResult() {
        if result.results == nil {
            result.results = []
        }

        for row in formRows {
            switch row {
            case .multipleChoiceRow(let multipleChoiceRow):
                let result = ORKChoiceQuestionResult(identifier: multipleChoiceRow.id)
                result.choiceAnswers = multipleChoiceRow.result.map { $0.choiceText as NSString }
                self.result.results?.append(result)

            case .scale(let scaleRow):
                switch scaleRow.selectionType {
                case .textChoice(_):
                    let result = ORKTextQuestionResult(identifier: scaleRow.id)
                    result.textAnswer = scaleRow.result as? String
                    self.result.results?.append(result)

                case .integerRange(_), .doubleRange(_):
                    let result = ORKScaleQuestionResult(identifier: scaleRow.id)
                    result.scaleAnswer = scaleRow.result as? NSNumber
                    self.result.results?.append(result)
                }
            }
        }
    }
}
