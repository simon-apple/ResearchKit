//  FormRow.swift
//  ResearchKitUI(Watch)
//
//  Created by Jessi Aboukasm on 4/26/24.
//

import Foundation

/// Enumeration to cover all the different question types for FormStep
/// Enumeration to cover all the different question types for FormStep
enum FormRow: Identifiable {
    case multipleChoiceRow(MultipleChoiceQuestion)
    case numericalSliderStep(ScaleSliderQuestion<Double>)
    case textSliderStep(ScaleSliderQuestion<MultipleChoiceOption>)

    var id: String {
        switch self {
        case .multipleChoiceRow(let multipleChoiceValue):
            multipleChoiceValue.id
        case .numericalSliderStep(let doubleSlider):
            doubleSlider.id
        case .textSliderStep(let textSlider):
            textSlider.id
        }
    }
}
