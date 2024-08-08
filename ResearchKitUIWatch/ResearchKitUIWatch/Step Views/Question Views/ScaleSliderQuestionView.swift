/*
 Copyright (c) 2024, Apple Inc. All rights reserved.
 
 Redistribution and use in source and binary forms, with or without modification,
 are permitted provided that the following conditions are met:
 
 1.  Redistributions of source code must retain the above copyright notice, this
 list of conditions and the following disclaimer.
 
 2.  Redistributions in binary form must reproduce the above copyright notice,
 this list of conditions and the following disclaimer in the documentation and/or
 other materials provided with the distribution.
 
 3.  Neither the name of the copyright holder(s) nor the names of any contributors
 may be used to endorse or promote products derived from this software without
 specific prior written permission. No license is granted to the trademarks of
 the copyright holders even if such marks are included in this software.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
 FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

import Foundation
import ResearchKit
import SwiftUI

// TODO(rdar://129033515): Update name of this module to reflect just the slider without the header.
public struct ScaleSliderQuestionView: View {

    let id: String
    
    var title: String

    var detail: String?

    var scaleSelectionConfiguration: ScaleSelectionConfiguration

    let step: Double

    // Actual underlying value of the slider
    @State
    private var sliderUIValue: Double

    private var selection: ScaleSelectionValue

    private enum ScaleSelectionValue: Equatable {
        static func == (
            lhs: ScaleSliderQuestionView.ScaleSelectionValue,
            rhs: ScaleSliderQuestionView.ScaleSelectionValue
        ) -> Bool {

            switch lhs {
                case .textChoice(let binding):
                    guard case .textChoice(let rhsBinding) = rhs else {
                        return false
                    }
                    return rhsBinding.wrappedValue.id == binding.wrappedValue.id
                case .int(let binding):
                    guard case .int(let rhsBinding) = rhs else {
                        return false
                    }
                    return rhsBinding.wrappedValue == binding.wrappedValue
                case .double(let binding):
                    guard case .double(let rhsBinding) = rhs else {
                        return false
                    }
                    return rhsBinding.wrappedValue == binding.wrappedValue
            }

        }

        case textChoice(Binding<MultipleChoiceOption>)
        case int(Binding<Int>)
        case double(Binding<Double>)
    }

    public init(
        id: String,
        title: String,
        detail: String? = nil,
        range: ClosedRange<Double>,
        step: Double = 1.0,
        selection: Binding<Double>
    ) {
        self.id = id
        self.title = title
        self.detail = detail
        self.scaleSelectionConfiguration = .doubleRange(range)
        self.step = step
        self.selection = .double(selection)
        self._sliderUIValue = State(wrappedValue: selection.wrappedValue)
    }

    // The int version
    public init(
        id: String,
        title: String,
        detail: String? = nil,
        range: ClosedRange<Int>,
        step: Double = 1.0,
        selection: Binding<Int>
    ) {
        self.id = id
        self.title = title
        self.detail = detail
        self.scaleSelectionConfiguration = .integerRange(range)
        self.step = step
        self.selection = .int(selection)
        self._sliderUIValue = State(wrappedValue: Double(selection.wrappedValue))
    }

    // The multi choice version
    public init(
        id: String,
        title: String,
        detail: String? = nil,
        multipleChoiceOptions: [MultipleChoiceOption],
        selection: Binding<MultipleChoiceOption>
    ) {
        self.id = id
        self.title = title
        self.detail = detail
        self.scaleSelectionConfiguration = .textChoice(multipleChoiceOptions)
        self.step = 1.0
        self.selection = .textChoice(selection)
        self._sliderUIValue = State(wrappedValue: Double(multipleChoiceOptions.firstIndex(where: { selection.id == $0.id }) ?? Array<MultipleChoiceOption>.Index(0.0)))
    }

    public var body: some View {
        FormItemCardView(title: title, detail: detail) {
            scaleView(selectionConfiguration: scaleSelectionConfiguration)
                .onChange(of: sliderUIValue) { oldValue, newValue in
                    switch selection {
                        case .double(let doubleBinding):
                            doubleBinding.wrappedValue = newValue
                        case .int(let intBinding):
                            intBinding.wrappedValue = Int(newValue)
                        case .textChoice(let textChoiceBinding):
                            guard case let .textChoice(array) = scaleSelectionConfiguration else {
                                return
                            }
                            let index = Int(newValue)
                            textChoiceBinding.wrappedValue = array[index]
                    }
                }
                .onChange(of: selection) { oldValue, newValue in
                    switch newValue {
                        case .textChoice(let binding):
                            guard case let .textChoice(array) = scaleSelectionConfiguration else {
                                return
                            }
                            let selectedIndex = array.firstIndex(where: { $0.id == binding.wrappedValue.id }) ?? 0
                            sliderUIValue = Double(selectedIndex)
                        case .int(let binding):
                            sliderUIValue = Double(binding.wrappedValue)
                        case .double(let binding):
                            sliderUIValue = binding.wrappedValue
                    }
                }
                .padding()
        }
    }

    @ViewBuilder
    private func scaleView(selectionConfiguration: ScaleSelectionConfiguration) -> some View {
        VStack {
            Text("\(value(for: selectionConfiguration))")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(.sliderValueForegroundStyle)
            
            Slider(
                value: $sliderUIValue,
                in: sliderBounds(for: selectionConfiguration),
                step: sliderStep(for: selectionConfiguration)
            ) {
                Text("Slider for \(selectionConfiguration)")
            } minimumValueLabel: {
                Text("\(minimumValueDescription(for: selectionConfiguration))")
                    .fixedSize()
                    .foregroundStyle(Color(.label))
                    .font(.subheadline)
                    .fontWeight(.bold)
            } maximumValueLabel: {
                Text("\(maximumValueDescription(for: selectionConfiguration))")
                    .fixedSize()
                    .foregroundStyle(Color(.label))
                    .font(.subheadline)
                    .fontWeight(.bold)
            }
        }
    }
    
    private func value(for selectionConfiguration: ScaleSelectionConfiguration) -> any CustomStringConvertible {
        let value: any CustomStringConvertible
        switch selectionConfiguration {
        case .integerRange:
            value = Int(sliderUIValue)
        case .doubleRange:
            value = String(format: "%.1f", sliderUIValue)
        case .textChoice(let choices):
            value = choices[Int(sliderUIValue)].choiceText
        }
        return value
    }
    
    private func sliderBounds(for selectionConfiguration: ScaleSelectionConfiguration) -> ClosedRange<Double> {
        let sliderBounds: ClosedRange<Double>
        switch selectionConfiguration {
        case .textChoice(let choices):
            sliderBounds = 0...Double(choices.count - 1)
        case .integerRange(let range):
            sliderBounds = Double(range.lowerBound)...Double(range.upperBound)
        case .doubleRange(let range):
            sliderBounds = range.lowerBound...range.upperBound
        }
        return sliderBounds
    }
    
    private func sliderStep(for selectionConfiguration: ScaleSelectionConfiguration) -> Double.Stride {
        let sliderStep: Double.Stride
        switch selectionConfiguration {
        case .textChoice:
            sliderStep = 1
        case .integerRange, .doubleRange:
            sliderStep = step
        }
        return sliderStep
    }
    
    private func minimumValueDescription(for selectionConfiguration: ScaleSelectionConfiguration) -> any CustomStringConvertible {
        let minimumValueLabel: any CustomStringConvertible
        switch selectionConfiguration {
        case .textChoice(let choices):
            minimumValueLabel = choices.first?.choiceText ?? ""
        case .integerRange(let range):
            minimumValueLabel = range.lowerBound
        case .doubleRange(let range):
            minimumValueLabel = range.lowerBound
        }
        return minimumValueLabel
    }

    private func maximumValueDescription(for selectionConfiguration: ScaleSelectionConfiguration) -> any CustomStringConvertible {
        let maximumValueDescription: any CustomStringConvertible
        switch selectionConfiguration {
        case .textChoice(let choices):
            maximumValueDescription = choices.last?.choiceText ?? ""
        case .integerRange(let range):
            maximumValueDescription = range.upperBound
        case .doubleRange(let range):
            maximumValueDescription = range.upperBound
        }
        return maximumValueDescription
    }
}

struct ScaleSliderQuestionView_Previews: PreviewProvider {

    static var previews: some View {
        ZStack {
            Color(uiColor: .secondarySystemBackground)
                .ignoresSafeArea()

            ScaleSliderQuestionView(
                id: UUID().uuidString,
                title: "On a scale of 1-10, how would you rate today?",
                range: 1...10,
                selection: .constant(7)
            )
            .padding(.horizontal)
        }

    }
}

public struct InputManagedScaleSliderQuestion: View {
    
    private let id: String
    
    private let title: String

    private let detail: String?

    private let scaleSelectionConfiguration: ScaleSelectionConfiguration

    private let step: Double
    
    @State private var selection: ScaleSelectionValue
    
    private enum ScaleSelectionValue: Equatable {
        static func == (
            lhs: ScaleSelectionValue,
            rhs: ScaleSelectionValue
        ) -> Bool {
            switch lhs {
            case .textChoice(let lhsMultipleChoiceOption):
                guard case .textChoice(let rhsMultipleChoiceOption) = rhs else {
                    return false
                }
                return rhsMultipleChoiceOption.id == lhsMultipleChoiceOption.id
            case .int(let lhsInteger):
                guard case .int(let rhsInteger) = rhs else {
                    return false
                }
                return lhsInteger == rhsInteger
            case .double(let lhsDouble):
                guard case .double(let rhsDouble) = rhs else {
                    return false
                }
                return rhsDouble == lhsDouble
            }
            
        }

        case textChoice(MultipleChoiceOption)
        case int(Int)
        case double(Double)
    }
    
    public init(
        id: String,
        title: String,
        detail: String? = nil,
        range: ClosedRange<Double>,
        step: Double = 1.0,
        selection: Double = 5
    ) {
        self.id = id
        self.title = title
        self.detail = detail
        self.scaleSelectionConfiguration = .doubleRange(range)
        self.step = step
        self.selection = .double(selection)
    }

    // The int version
    public init(
        id: String,
        title: String,
        detail: String? = nil,
        range: ClosedRange<Int>,
        step: Double = 1.0,
        selection: Int
    ) {
        self.id = id
        self.title = title
        self.detail = detail
        self.scaleSelectionConfiguration = .integerRange(range)
        self.step = step
        self.selection = .int(selection)
    }

    // The multi choice version
    public init(
        id: String,
        title: String,
        detail: String? = nil,
        multipleChoiceOptions: [MultipleChoiceOption],
        selection: MultipleChoiceOption
    ) {
        self.id = id
        self.title = title
        self.detail = detail
        self.scaleSelectionConfiguration = .textChoice(multipleChoiceOptions)
        self.step = 1.0
        self.selection = .textChoice(selection)
    }
    
    public var body: some View {
        switch (scaleSelectionConfiguration, selection) {
        case let (.textChoice(multipleChoiceOptions), .textChoice(textSelection)):
            ScaleSliderQuestionView(
                id: id,
                title: title,
                detail: detail,
                multipleChoiceOptions: multipleChoiceOptions,
                selection: .init(
                    get: {
                        textSelection
                    },
                    set: { newValue in
                        selection = .textChoice(newValue)
                    }
                )
            )
        case let (.integerRange(closedRange), .int(integerSelection)):
            ScaleSliderQuestionView(
                id: id,
                title: title,
                detail: detail,
                range: closedRange,
                selection: .init(
                    get: {
                        integerSelection
                    },
                    set: { newValue in
                        selection = .int(newValue)
                    }
                )
            )
        case let (.doubleRange(closedRange), .double(doubleSelection)):
            ScaleSliderQuestionView(
                id: id,
                title: title,
                detail: detail,
                range: closedRange,
                selection: .init(
                    get: {
                        doubleSelection
                    },
                    set: { newValue in
                        selection = .double(newValue)
                    }
                )
            )
        default:
            EmptyView()
        }
    }
    
}
