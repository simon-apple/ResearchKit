//
//  ScaleQuestion.swift
//  ResearchKitUI(Watch)
//
//  Created by Akshay Yadav on 4/16/24.
//

import Foundation
import ResearchKit
import SwiftUI

enum ScaleAxis {
    case horizontal, verticle
}

enum ScaleSelectionType {
    case textChoice([MultipleChoiceOption])
    case integerRange(ClosedRange<Int>)
    case doubleRange(ClosedRange<Double>)
}

@Observable
class ScaleSliderQuestion<ResultType>: Identifiable {

    public var title: String
    public var id: String
    public let selectionType: ScaleSelectionType
    public var result: ResultType


    init(title: String, id: String, selectionType: ScaleSelectionType, result: ResultType) {
        self.title = title
        self.id = id
        self.selectionType = selectionType
        _result = result
    }

}

// TODO(rdar://129033515): Update name of this module to reflect just the slider without the header.
struct ScaleSliderQuestionView<ResultType>: View {

    let identifier: String

    var detail: String?

    var scaleSelectionType: ScaleSelectionType

    @State
    var value = 0.0

    @Binding
    var result: ResultType

    public var body: some View {
        VStack(alignment: .leading) {
            if let detail {
                Text(detail)
            }

            scaleView(selectionType: scaleSelectionType)
        }
    }

    @ViewBuilder
    func scaleView(selectionType: ScaleSelectionType) -> some View {
        VStack {
            Text("\(value(for: selectionType))")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(.blue)
            
            switch selectionType {
            case .integerRange(let range):
                VStack {
                    Slider(
                        value: $value,
                        in: 0...100,
                        step: 1
                    ) {
                        Text("Replace This Text")
                    } minimumValueLabel: {
                        Text("min")
                    } maximumValueLabel: {
                        Text("max")
                    }
                }
            case .doubleRange(let range):
                VStack {
                    Slider(
                        value: $value,
                        in: 0...5,
                        step: 0.01
                    ) {
                        Text("Replace This Text")
                    } minimumValueLabel: {
                        Text("min")
                    } maximumValueLabel: {
                        Text("max")
                    }
                }
            case .textChoice(let choices):
                VStack {
                    Slider(
                        value: $value,
                        in: 0...Double(choices.count - 1),
                        step: 1
                    ) {
                        Text("Choices")
                    } minimumValueLabel: {
                        Text("Min")
                    } maximumValueLabel: {
                        Text("Max")
                    }
                }
            }
        }
    }
    
    private func value(for selectionType: ScaleSelectionType) -> any CustomStringConvertible {
        let value: any CustomStringConvertible
        switch selectionType {
        case .integerRange(_):
            value = Int(self.value)
        case .doubleRange(_):
            value = self.value
        case .textChoice(let choices):
            value = choices[Int(self.value)].choiceText
        }
        return value
    }

}
