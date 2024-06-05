//
//  ScaleQuestion.swift
//  ResearchKitUI(Watch)
//
//  Created by Akshay Yadav on 4/16/24.
//

import Foundation
import ResearchKit
import SwiftUI

enum ScaleSelectionType {
    case textChoice([MultipleChoiceOption])
    case integerRange(ClosedRange<Int>)
    case doubleRange(ClosedRange<Double>)
}

struct ScaleSliderQuestion<ResultType>: Identifiable {
    public let id: String
    public let title: String
    public let selectionType: ScaleSelectionType
    public let step: Double
    public var result: ResultType?

    init(id: String, 
         title: String,
         selectionType: ScaleSelectionType,
         step: Double,
         result: ResultType? = nil
    ) {
        self.title = title
        self.id = id
        self.selectionType = selectionType
        self.step = step
        self.result = result
    }
}

struct ScaleSliderQuestionView<ResultType>: View {

    var title: String

    var detail: String?

    var scaleSelectionType: ScaleSelectionType

    let step: Double

    // Actual underlying value of the slider
    @State
    private var value = 0.0

    @Binding
    var result: ResultType

    public var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.title)
            if let detail {
                Text(detail)
            }
            scaleView(selectionType: scaleSelectionType)
                .onChange(of: value) { _, _ in
                    updateResult()
                }
        }
    }

    @ViewBuilder
    private func scaleView(selectionType: ScaleSelectionType) -> some View {

        switch selectionType {
            case .integerRange(let range):
                VStack {
                    Text("\(Int(value))")
                    Slider(
                        value: $value,
                        in: Double(range.lowerBound)...Double(range.upperBound),
                        step: step
                    ) {
                        Text("Replace This Text")
                    } minimumValueLabel: {
                        Text("\(range.lowerBound)")
                    } maximumValueLabel: {
                        Text("\(range.upperBound)")
                    }
                }
            case .doubleRange(let range):
                VStack {
                    Text("\(value)")
                    Slider(
                        value: $value,
                        in: range.lowerBound...range.upperBound,
                        step: step
                    ) {
                    } minimumValueLabel: {
                        Text("\(range.lowerBound)")
                    } maximumValueLabel: {
                        Text("\(range.lowerBound)")
                    }
                }
            case .textChoice(let choices):
                VStack {
                    Text("\(choices[Int(value)].choiceText)")
                    Slider(
                        value: $value,
                        in: 0...Double(choices.count - 1),
                        step: 1
                    ) {
                    } minimumValueLabel: {
                        if let minimumLabelText = choices.first?.choiceText {
                            Text(minimumLabelText)
                        }
                    } maximumValueLabel: {
                        if let maximumLabelText = choices.last?.choiceText {
                            Text(maximumLabelText)
                        }
                    }
                }
        }
    }

    // MARK: Helpers
    
    private func updateResult() {
        switch self.scaleSelectionType {
        case .textChoice(let array):
            let index = Int(self.value)
            if let newValue = array[index] as? ResultType {
                $result.wrappedValue = newValue
            }
        case .integerRange(_):
            // value is a double for the sake of the SwiftUI Slider, so cast to an Int
            if let newValue = Int(value) as? ResultType {
                $result.wrappedValue = newValue
            }
        case .doubleRange(_):
            if let newValue = value as? ResultType {
                $result.wrappedValue = newValue
            }
        }
    }
}

