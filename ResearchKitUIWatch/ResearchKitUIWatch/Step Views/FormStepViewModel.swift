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

    @Published
    var selectedIndex: Int = -1

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

        if result.results == nil {
            result.results = []
        }

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
                            choiceText: textChoice.text
                        )
                    )
                }

                // TODO: need to figure out a bindable result object here!!
                let resultObject : MultipleChoiceOption<UUID> = MultipleChoiceOption(choiceText: "")
                return FormRow.multipleChoiceRow(
                    MultipleChoiceQuestion(
                        id: UUID(),
                        title: questionText,
                        choices: answerOptions,
                        result: resultObject
                    )
                )
            }
            return nil
        }
        let formRowsCompacted = formRows.compactMap { $0 }
        print(formRowsCompacted)
        return formRowsCompacted
    }

    func createORKResult() {
        for row in formRows {
            guard let id = row.id as? UUID else {
                return
            }
            switch row {
            case .multipleChoiceRow(let multipleChoiceRow):
                let result = ORKChoiceQuestionResult(identifier: id.uuidString)
                result.choiceAnswers = [multipleChoiceRow.result.choiceText as NSString]
                self.result.results?.append(result)

            case .textRow(let textRow):
                let result = ORKTextQuestionResult(identifier: id.uuidString)
                result.textAnswer = textRow.text
                self.result.results?.append(result)
            }

        }
    }
}
