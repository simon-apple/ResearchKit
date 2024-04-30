//
//  FormStepViewModel.swift
//  ResearchKitUI(Watch)
//
//  Created by Jessi Aboukasm on 4/1/24.
//

import ResearchKitCore
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

        let formRows: [FormRow?] = formItems.map { formItem in
            if let answerFormat = formItem.answerFormat as? ORKTextChoiceAnswerFormat,
               let questionText = formItem.text
            {
                var answerOptions : [MultipleChoiceOption<UUID>] = []
                answerFormat.textChoices.forEach { textChoice in
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
                        selectionType: answerFormat.style == .singleChoice ? .single : .multiple
                    )
                )
            }
            else if let answerFormat = formItem.answerFormat as? ORKScaleAnswerFormat,
                    let text = formItem.text {
                return FormRow.scale(ScaleSliderQuestion(
                    title: text,
                    id: UUID(),
                    selectionType: .numericRange(ScaleSliderNumericRange(minValue: answerFormat.minimum, maxValue: answerFormat.maximum)), result: 0))
            }
            return nil
        }
        let formRowsCompacted = formRows.compactMap { $0 }
        print(formRowsCompacted)
        return formRowsCompacted
    }

}
