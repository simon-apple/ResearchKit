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

enum ScaleSelectionConfiguration {
    case textChoice([MultipleChoiceOption])
    case integerRange(ClosedRange<Int>)
    case doubleRange(ClosedRange<Double>)
}

struct ScaleSliderQuestion<ResultType>: Identifiable {

    public let id: String
    public let title: String
    public let detail: String?
    public let step: Double
    public let value: Double
    public let range: ClosedRange<Double>
    public let configuration: ScaleSelectionConfiguration

    init(
        id: String,
        title: String,
        detail: String? = nil,
        step: Double = 1.0,
        range: ClosedRange<Double>,
        value: Double
    ) {
        self.id = id
        self.title = title
        self.detail = detail
        self.step = step
        self.range = range
        self.configuration = .doubleRange(range)
        self.value = value
    }

}

extension ScaleSliderQuestion where ResultType == Int {

    var result: Int {
        return Int(value)
    }

    var range: ClosedRange<Int> {
        return Int(range.lowerBound)...Int(range.upperBound)
    }

    init(
        id: String,
        title: String,
        detail: String? = nil,
        step: Int = 1,
        range: ClosedRange<Int>,
        value: Int
    ) {
        self.id = id
        self.title = title
        self.detail = detail
        self.step = Double(step)
        self.range = Double(range.lowerBound) ... Double(range.upperBound)
        self.configuration = .integerRange(range)
        self.value = Double(value)
    }
}

extension ScaleSliderQuestion where ResultType == Double {

    var result: Double {
        return value
    }

}

extension ScaleSliderQuestion where ResultType == MultipleChoiceOption {

    var result: MultipleChoiceOption {
        switch configuration {
        case .textChoice(let choices):
            return choices[Int(value)]
        default:
            fatalError("Unsupported configuration detected for MultipleChoiceOption when querying result")
        }
    }
    
    var multipleChoiceOptions: [MultipleChoiceOption] {
        switch configuration {
        case .textChoice(let options):
            return options
        default:
            fatalError("Unsupported configuration detected for MultipleChoiceOption when querying multiple-choice options")
        }
    }

    init(
        id: String,
        title: String,
        detail: String? = nil,
        options: [MultipleChoiceOption],
        selectedMultipleChoiceOption: MultipleChoiceOption
    ) {
        self.id = id
        self.title = title
        self.detail = detail
        self.step = 1.0
        self.configuration = .textChoice(options)
        let index = options.firstIndex(where: { $0.id == selectedMultipleChoiceOption.id }) ?? 0
        self.range = Double(0) ... Double(options.count - 1)
        self.value = Double(index)
    }

}

// TODO(rdar://129033515): Update name of this module to reflect just the slider without the header.
struct ScaleSliderQuestionView: View {

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

    init(
        title: String,
        detail: String? = nil,
        range: ClosedRange<Double>,
        step: Double = 1.0,
        selection: Binding<Double>
    ) {
        self.title = title
        self.detail = detail
        self.scaleSelectionConfiguration = .doubleRange(range)
        self.step = step
        self.selection = .double(selection)
        self._sliderUIValue = State(wrappedValue: selection.wrappedValue)
    }

    // The int version
    init(
        title: String,
        detail: String? = nil,
        range: ClosedRange<Int>,
        step: Double = 1.0,
        selection: Binding<Int>
    ) {
        self.title = title
        self.detail = detail
        self.scaleSelectionConfiguration = .integerRange(range)
        self.step = step
        self.selection = .int(selection)
        self._sliderUIValue = State(wrappedValue: Double(selection.wrappedValue))
    }

    // The multi choice version
    init(
        title: String,
        detail: String? = nil,
        multipleChoiceOptions: [MultipleChoiceOption],
        selection: Binding<MultipleChoiceOption>
    ) {
        self.title = title
        self.detail = detail
        self.scaleSelectionConfiguration = .textChoice(multipleChoiceOptions)
        self.step = 1.0
        self.selection = .textChoice(selection)
        self._sliderUIValue = State(wrappedValue: Double(multipleChoiceOptions.firstIndex(where: { selection.id == $0.id }) ?? Array<MultipleChoiceOption>.Index(0.0)))
    }

    public var body: some View {
        VStack(alignment: .leading) {
            if let detail {
                Text(detail)
            }
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
                Text("Replace This Text")
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
            value = sliderUIValue
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
