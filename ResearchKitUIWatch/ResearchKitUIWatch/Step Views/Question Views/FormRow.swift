//
//  FormRow.swift
//  ResearchKitUI(Watch)
//
//  Created by Jessi Aboukasm on 4/26/24.
//

import Foundation

typealias AnyResultProviding = ResultProviding & Any

// Define a protocol for the result
public protocol ResultProviding {
    // Define associated type for the result
    associatedtype ResultType
    // Define a property to access the result
    var value: ResultType { get set }
}


enum FormRow: Identifiable {
    case textRow(TextRowValue)
    case multipleChoiceRow(MultipleChoiceQuestion)

    var id: AnyHashable {
        switch self {
            case .textRow(let textRowValue):
                textRowValue.id
            case .multipleChoiceRow(let multipleChoiceValue):
                multipleChoiceValue.id
        }
    }
}
