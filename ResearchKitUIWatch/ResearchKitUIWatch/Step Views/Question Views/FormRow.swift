//
//  FormRow.swift
//  ResearchKitUI(Watch)
//
//  Created by Jessi Aboukasm on 4/26/24.
//

import Foundation

// Enumeration to cover all the different question types for FormStep
enum FormRow: Identifiable {
    case multipleChoiceRow(MultipleChoiceQuestion)

    var id: AnyHashable {
        switch self {
            case .multipleChoiceRow(let multipleChoiceValue):
                multipleChoiceValue.id
        }
    }
}
