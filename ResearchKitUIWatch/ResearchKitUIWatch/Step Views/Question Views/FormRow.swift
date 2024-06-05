//  FormRow.swift
//  ResearchKitUI(Watch)
//
//  Created by Jessi Aboukasm on 4/26/24.
//

import Foundation

/// Enumeration to cover all the different question types for FormStep
enum FormRow: Identifiable {
    case multipleChoiceRow(MultipleChoiceQuestion)
    case doubleSliderRow(ScaleSliderQuestion<Double>)
    case intSliderRow(ScaleSliderQuestion<Int>)
    case textSliderStep(ScaleSliderQuestion<MultipleChoiceOption>)

    var id: String {
        switch self {
        case .multipleChoiceRow(let multipleChoiceValue):
            multipleChoiceValue.id
        case .doubleSliderRow(let doubleSlider):
            doubleSlider.id
        case .intSliderRow(let intSlider):
            intSlider.id
        case .textSliderStep(let textSlider):
            textSlider.id
        }
    }
}
