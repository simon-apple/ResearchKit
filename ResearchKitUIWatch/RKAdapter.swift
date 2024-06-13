//
//  RKAdapter.swift
//  ResearchKitUI(Watch)
//
//  Created by Johnny Hicks on 6/13/24.
//

import Foundation
import ResearchKit

public class RKAdapter {
    public static func createFormRow(from item: ORKFormItem) -> FormRow? {
        switch item.answerFormat {
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
                        id: item.identifier,
                        title: item.text,
                        choices: answerOptions,
                        selectionType: textChoiceAnswerFormat.style == .singleChoice ? .single : .multiple
                     )
                 )
            case let scaleAnswerFormat as ORKScaleAnswerFormat:
                return FormRow.intSliderRow(
                    ScaleSliderQuestion(
                        id: item.identifier,
                        title: item.text ?? "",
                        step: scaleAnswerFormat.step,
                        range: scaleAnswerFormat.minimum...scaleAnswerFormat.maximum,
                        value: scaleAnswerFormat.defaultValue
                    )
                )
            case let continuousScaleAnswerFormat as ORKContinuousScaleAnswerFormat:

                // Current ORKContinuousScaleAnswerFormat does not allow user to specify step size so we can create an approximation,
                // falling back on 0.01 as our step size if required.
                var stepSize = 0.01
                let numberOfValues = continuousScaleAnswerFormat.maximum - continuousScaleAnswerFormat.minimum
                if numberOfValues > 0 {
                    stepSize = 1.0 / numberOfValues
                }
                return FormRow.doubleSliderRow(
                    ScaleSliderQuestion(
                        id: item.identifier,
                        title: item.text ?? "",
                        step: stepSize,
                        range: continuousScaleAnswerFormat.minimum...continuousScaleAnswerFormat.maximum,
                        value: continuousScaleAnswerFormat.defaultValue
                    )
                )

            case let textChoiceScaleAnswerFormat as ORKTextScaleAnswerFormat:
                let answerOptions = textChoiceScaleAnswerFormat.textChoices.map { textChoice in
                    MultipleChoiceOption(
                        id: UUID().uuidString,
                        choiceText: textChoice.text
                    )
                }
                guard var defaultOption = answerOptions.first else {
                    fatalError("Invalid Choice Array for ORKTextScaleAnswerFormat")
                }
                if answerOptions.indices.contains(textChoiceScaleAnswerFormat.defaultIndex) {
                    defaultOption = answerOptions[textChoiceScaleAnswerFormat.defaultIndex]
                }

                return FormRow.textSliderStep(
                    ScaleSliderQuestion(
                        id: item.identifier,
                        title: item.text ?? "",
                        options: answerOptions,
                        selectedMultipleChoiceOption: defaultOption
                    )
                )
        default:
            return nil
        }
    }

    static func createFormRowsFromORKStep(_ step: ORKFormStep) -> [FormRow] {
        // Convert our ORKFormItems to FormRows with associated values
        guard let formItems = step.formItems else {
            assertionFailure("Attempting to create an empty ORKFormStep")
            return []
        }

        let formRows = formItems.compactMap { formItem in
            Self.createFormRow(from: formItem)
        }

        return formRows
    }
}
