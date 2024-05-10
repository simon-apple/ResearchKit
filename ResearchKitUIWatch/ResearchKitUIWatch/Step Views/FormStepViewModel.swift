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

        self.formRows = Self.convertFormItemsToFormRows(formItems: step.formItems ?? []) ?? []
    }

    static func convertFormItemsToFormRows(formItems: [ORKFormItem]) -> [FormRow]? {

        let formRows: [FormRow] = formItems.compactMap { formItem in
            #warning("[AY] Handle optional string")
            let questionText = formItem.text ?? ""
            switch formItem.answerFormat {
                case let textChoiceAnswerFormat as ORKTextChoiceAnswerFormat:

                    var answerOptions : [MultipleChoiceOption<UUID>] = []
                    textChoiceAnswerFormat.textChoices.forEach { textChoice in
                         answerOptions.append(
                             MultipleChoiceOption(
                                 id: UUID(),
                                 choiceText: Text(
                                     textChoice.text
                                 )
                             )
                         )
                     }

                     // TODO: where should this be owned
                     let resultObject : [MultipleChoiceOption<UUID>] = [MultipleChoiceOption(choiceText: Text(""))]
                     return FormRow.multipleChoiceRow(
                         MultipleChoiceQuestion(
                             id: UUID(),
                             title: Text(questionText),
                             choices: answerOptions,
                             result: resultObject,
                             selectionType: textChoiceAnswerFormat.style == .singleChoice ? .single : .multiple
                         )
                     )
                case let scaleAnswerFormat as ORKScaleAnswerFormat:
                    return FormRow.scale(
                        ScaleSliderQuestion(
                        title: questionText,
                        id: UUID(),
                        selectionType: .integerRange(scaleAnswerFormat.minimum...scaleAnswerFormat.maximum),
                        result: 1
                        )
                    )
                case let continuousScaleAnswerFormat as ORKContinuousScaleAnswerFormat:
                    return FormRow.scale(
                        ScaleSliderQuestion(
                        title: questionText,
                        id: UUID(),
                        selectionType: .doubleRange(continuousScaleAnswerFormat.minimum...continuousScaleAnswerFormat.maximum),
                        result: 1
                        )
                    )

                case let textChoiceScaleAnswerFormat as ORKTextScaleAnswerFormat:
                    #warning("[AY] remove uuid string as identifier")
                    let answerOptions = textChoiceScaleAnswerFormat.textChoices.map { textChoice in
                        MultipleChoiceOption(
                            id: UUID().uuidString,
                            choiceText: Text(
                                textChoice.text
                            )
                        )
                    }
                    return FormRow.scale(
                        ScaleSliderQuestion(
                        title: questionText,
                        id: UUID(),
                        selectionType: .textChoice(answerOptions),
                        result: MultipleChoiceOption(choiceText: Text(""))
                        )
                    )
                default:
                    return nil
            }

        }
        let formRowsCompacted = formRows.compactMap { $0 }
        print(formRowsCompacted)
        return formRowsCompacted
    }

}
