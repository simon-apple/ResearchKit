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
            
            Slider(
                value: $value,
                in: sliderBounds(for: selectionType),
                step: sliderStep(for: selectionType)
            ) {
                Text(labelDescription(for: selectionType))
            } minimumValueLabel: {
                Text(minimumValueDescription(for: selectionType))
                    .foregroundStyle(Color(.label))
                    .font(.subheadline)
                    .fontWeight(.bold)
            } maximumValueLabel: {
                Text(maximumValueDescription(for: selectionType))
                    .foregroundStyle(Color(.label))
                    .font(.subheadline)
                    .fontWeight(.bold)
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
    
    private func sliderBounds(for selectionType: ScaleSelectionType) -> ClosedRange<Double> {
        let sliderBounds: ClosedRange<Double>
        switch selectionType {
        case .textChoice(let choices):
            sliderBounds = 0...Double(choices.count - 1)
        case .integerRange(let closedRange):
            sliderBounds = 0...100
        case .doubleRange(let closedRange):
            sliderBounds = 0...5
        }
        return sliderBounds
    }
    
    private func sliderStep(for selectionType: ScaleSelectionType) -> Double.Stride {
        let sliderStep: Double.Stride
        switch selectionType {
        case .textChoice(_):
            fallthrough
        case .integerRange(_):
            sliderStep = 1
        case .doubleRange(_):
            sliderStep = 0.01
        }
        return sliderStep
    }
    
    private func labelDescription(for selectionType: ScaleSelectionType) -> String {
        let labelDescription: String
        switch selectionType {
        case .textChoice(let array):
            labelDescription = "Choices"
        case .integerRange(_):
            fallthrough
        case .doubleRange(_):
            labelDescription = "Replace This Text"
        }
        return labelDescription
    }
    
    private func minimumValueDescription(for selectionType: ScaleSelectionType) -> String {
        let minimumValueLabel: String
        switch selectionType {
        case .textChoice(let array):
            minimumValueLabel = "Min"
        case .integerRange(_):
            fallthrough
        case .doubleRange(_):
            minimumValueLabel = "min"
        }
        return minimumValueLabel
    }

    private func maximumValueDescription(for selectionType: ScaleSelectionType) -> String {
        let maximumValueDescription: String
        switch selectionType {
        case .textChoice(let array):
            maximumValueDescription = "Max"
        case .integerRange(_):
            fallthrough
        case .doubleRange(_):
            maximumValueDescription = "max"
        }
        return maximumValueDescription
    }
    
}
