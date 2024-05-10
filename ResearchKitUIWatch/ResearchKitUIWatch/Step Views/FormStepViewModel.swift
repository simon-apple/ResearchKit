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

        // Convert our ORKFormItems to FormRows with associated values 
        guard let formItems = step.formItems else {
            fatalError("Attempting to create an empty ORKFormStep")
        }

        let rows : [FormRow?] = formItems.map { formItem in
            if let answerFormat = formItem.answerFormat as? ORKTextChoiceAnswerFormat,
               let questionText = formItem.text
            {
                var answerOptions : [MultipleChoiceOption] = []
                answerFormat.textChoices.forEach { textChoice in
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
            switch row {
            case .multipleChoiceRow(let multipleChoiceRow):
                let result = ORKChoiceQuestionResult(identifier: multipleChoiceRow.id)
                guard let choiceAnswer = multipleChoiceRow.result?.choiceText else {
                    return
                }
                result.choiceAnswers = [choiceAnswer as NSString]
                self.result.results?.append(result)
            }
        }
    }
}
