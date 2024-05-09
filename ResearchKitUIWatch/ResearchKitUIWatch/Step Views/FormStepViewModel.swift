//
//  FormStepViewModel.swift
//  ResearchKitUI(Watch)
//
//  Created by Jessi Aboukasm on 4/1/24.
//

import ResearchKitCore
import SwiftUI

public class FormStepViewModel: ObservableObject {

    @ObservedObject
    private(set) var step: ORKFormStep

    @ObservedObject
    private(set) var result: ORKStepResult

    @Published
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

        // Convert our ORKFormItems to FormRows with associated types
        let formItems = step.formItems ?? []
        let rows : [FormRow?] = formItems.map { formItem in
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
                return FormRow.multipleChoiceRow(
                    MultipleChoiceQuestion(
                        id: UUID(),
                        title: questionText,
                        choices: answerOptions
                    )
                )
            }
            return nil
        }

        self.formRows = rows.compactMap { $0 }

    }

    func createORKResult() {
        for row in formRows {
            guard let id = row.id as? UUID else {
                return
            }
            switch row {
            case .textRow(let textRow):
                let result = ORKTextQuestionResult(identifier: id.uuidString)
                result.textAnswer = textRow.text
                self.result.results?.append(result)

            case .multipleChoiceRow(let multipleChoiceRow):
                let result = ORKChoiceQuestionResult(identifier: id.uuidString)

                let selectedIndex = multipleChoiceRow.selectedIndex
                guard multipleChoiceRow.choices.count > selectedIndex && selectedIndex > 0 else {
                    return
                }
                let choiceAnswer = multipleChoiceRow.choices[selectedIndex].choiceText
                result.choiceAnswers = [choiceAnswer as NSString]
                self.result.results?.append(result)
            }

        }
    }
}
