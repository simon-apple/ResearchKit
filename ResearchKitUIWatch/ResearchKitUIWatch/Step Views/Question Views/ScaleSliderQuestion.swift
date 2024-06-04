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

struct ScaleSliderQuestionView<ResultType>: View {

    let identifier: String

    var title: String

    var detail: String?

    var scaleSelectionType: ScaleSelectionType

    @State
    var value = 0.0

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

        }
    }


    @ViewBuilder
    func scaleView(selectionType: ScaleSelectionType) -> some View {

        switch selectionType {
            case .integerRange(let range):
                VStack {
                    Text("\(Int(value))")
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
                    Text("\(value)")
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
                    Text("\(choices[Int(value)].choiceText)")
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

