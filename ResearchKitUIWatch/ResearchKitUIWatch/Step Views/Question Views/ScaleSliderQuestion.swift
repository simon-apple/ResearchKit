//
//  ScaleQuestion.swift
//  ResearchKitUI(Watch)
//
//  Created by Akshay Yadav on 4/16/24.
//

import Foundation
import SwiftUI

@Observable
public class ScaleSliderNumericRange {
    public var minValue: Int
    public var maxValue: Int

    init(minValue: Int, maxValue: Int) {
        self.minValue = minValue
        self.maxValue = maxValue
    }
}

public enum ScaleAxis {
    case horizontal, verticle
}

public enum ScaleSelectionType {
    case textChoice([MultipleChoiceOption<String>])
    case numericRange(ScaleSliderNumericRange)
}

@Observable
public class ScaleSliderQuestion<ResultType>: Identifiable {

    public var title: String
    public var id: UUID
    public var selectionType: ScaleSelectionType
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

    @State var value: Double = 2.0

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
            case .textChoice(let array):
                Text("Coming Soon")
            case .numericRange(let scaleSliderNumericRange):
                VStack {
                    HStack {
                        Text("\(scaleSliderNumericRange.minValue)")
                            .frame(alignment: .leading)
                        Text("\(scaleSliderNumericRange.maxValue)")
                            .frame(alignment: .trailing)
                    }
                    Slider(
                        value: $value,
                        in: 0...10
                    ) {
                        Text("Hello")
                    } minimumValueLabel: {
                        Text("\(scaleSliderNumericRange.minValue)")
                    } maximumValueLabel: {
                        Text("\(scaleSliderNumericRange.maxValue)")
                    }
                }
        }
    }

}

