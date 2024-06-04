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

                    return FormRow.numericalSliderStep(
                        ScaleSliderQuestion(
                            id: formItem.identifier,
                            title: questionText,
                            selectionType: .integerRange(scaleAnswerFormat.minimum...scaleAnswerFormat.maximum)
                        )
                    )
                case let continuousScaleAnswerFormat as ORKContinuousScaleAnswerFormat:
                    return FormRow.numericalSliderStep(
                        ScaleSliderQuestion(
                            id: formItem.identifier,
                            title: questionText,
                            selectionType: .doubleRange(continuousScaleAnswerFormat.minimum...continuousScaleAnswerFormat.maximum)
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
                    return FormRow.textSliderStep(
                        ScaleSliderQuestion(
                            id: formItem.identifier,
                            title: questionText,
                            selectionType: .textChoice(answerOptions)
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

            case .numericalSliderStep(let numericalScaleRow):
                let result = ORKScaleQuestionResult(identifier: numericalScaleRow.id)
                result.scaleAnswer = numericalScaleRow.result as? NSNumber
                resultArray.append(result)

            case .textSliderStep(let textSliderRow):
                let result = ORKTextQuestionResult(identifier: textSliderRow.id)
                result.textAnswer = textSliderRow.result?.choiceText as? String
                resultArray.append(result)
            }
        }

        // Step result may be nil if the user skipped a step
        if resultArray.isEmpty == false {
            self.result.results = resultArray
        }
    }
}
