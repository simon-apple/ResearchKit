//
//  ScaleQuestion.swift
//  ResearchKitUI(Watch)
//
//  Created by Akshay Yadav on 4/16/24.
//

import Foundation
import ResearchKit
import SwiftUI

public enum ScaleAxis {
    case horizontal, verticle
}

public enum ScaleSelectionType {
    case textChoice([MultipleChoiceOption<String>])
    case integerRange(ClosedRange<Int>)
    case doubleRange(ClosedRange<Double>)
}

@Observable
public class ScaleSliderQuestion<ResultType>: Identifiable {

    public var title: String
    public var id: UUID
    public let selectionType: ScaleSelectionType
    public var result: ResultType


    init(title: String, id: UUID, selectionType: ScaleSelectionType, result: ResultType) {
        self.title = title
        self.id = id
        self.selectionType = selectionType
        _result = result
    }

}

public struct ScaleSliderQuestionView<ResultType>: View {

    public let identifier: UUID = UUID()

    private var title: String

    private var detail: String?

    private var scaleSelectionType: ScaleSelectionType

    @State
    var value = 0.0

    @Binding
    public var result: ResultType

    public init(
        title: String,
        detail: String? = nil,
        result: Binding<ResultType>,
        scaleSelectionType: ScaleSelectionType
    ) {
        self.title = title
        self.detail = detail
        _result = result
        self.scaleSelectionType = scaleSelectionType
    }

    public var body: some View {
        CardView {
            VStack(alignment: .leading) {
                Text(title)
                    .font(.title)
                if let detail {
                    Text(detail)
                }

                scaleView(selectionType: scaleSelectionType)

            }
            .padding()
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

