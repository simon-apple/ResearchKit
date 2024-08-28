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

public struct ScaleSliderQuestionView: View {
    
    private enum ScaleSelectionBindingValue: Equatable {
        
        static func == (
            lhs: ScaleSliderQuestionView.ScaleSelectionBindingValue,
            rhs: ScaleSliderQuestionView.ScaleSelectionBindingValue
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

        case int(Binding<Int>)
        case double(Binding<Double>)
        
        @available(watchOS, unavailable)
        case textChoice(Binding<MultipleChoiceOption>)
        
    }
    
    private enum ScaleSelectionPrimitiveValue: Equatable {
        
        static func == (
            lhs: ScaleSliderQuestionView.ScaleSelectionPrimitiveValue,
            rhs: ScaleSliderQuestionView.ScaleSelectionPrimitiveValue
        ) -> Bool {
            switch lhs {
                case .textChoice(let lhsValue):
                    guard case .textChoice(let rhsValue) = rhs else {
                        return false
                    }
                    return lhsValue.id == rhsValue.id
                case .int(let lhsValue):
                    guard case .int(let rhsValue) = rhs else {
                        return false
                    }
                    return lhsValue == rhsValue
                case .double(let lhsValue):
                    guard case .double(let rhsValue) = rhs else {
                        return false
                    }
                    return lhsValue == rhsValue
            }
        }

        case int(Int)
        case double(Double)
        
        @available(watchOS, unavailable)
        case textChoice(MultipleChoiceOption)
        
    }
    
    private enum StateManagementType {
        
        case automatic, manual
        
    }
    
    private let stateManagementType: StateManagementType
    
    private var resolvedBinding: Binding<ScaleSelectionBindingValue> {
        let resolvedBinding: Binding<ScaleSelectionBindingValue>
        switch stateManagementType {
        case .automatic:
            resolvedBinding = resolvedManagedResult
        case .manual:
            resolvedBinding = .init(
                get: {
                    selection
                },
                // This binding isn't invoked with respect to `set` because another binding is returned in `get`.
                set: { _ in }
            )
        }
        return resolvedBinding
    }

    let id: String
    
    var title: String

    var detail: String?

    var scaleSelectionConfiguration: ScaleSelectionConfiguration

    let step: Double

    // Actual underlying value of the slider
    @State
    private var sliderUIValue: Double

    @State
    private var primitiveSelection: ScaleSelectionPrimitiveValue
    
    private var resolvedManagedResult: Binding<ScaleSelectionBindingValue> {
        .init(
            get: {
                switch primitiveSelection {
                case .textChoice(let multipleChoiceOption):
                        .textChoice(
                            .init(
                                get: {
                                    multipleChoiceOption
                                },
                                set: { primitiveSelection = .textChoice($0) }
                            )
                        )
                case .int(let int):
                        .int(
                            .init(
                                get: {
                                    int
                                },
                                set: { primitiveSelection = .int($0) }
                            )
                        )
                case .double(let double):
                        .double(
                            .init(
                                get: {
                                    print("Double: \(double)")
                                    return double
                                },
                                set: {
                                    print("New double: \($0)")
                                    primitiveSelection = .double($0)
                                }
                            )
                        )
                }
            },
            set: { newValue in
                switch newValue {
                case .textChoice(let binding):
                    primitiveSelection = .textChoice(binding.wrappedValue)
                case .int(let binding):
                    primitiveSelection = .int(binding.wrappedValue)
                case .double(let binding):
                    primitiveSelection = .double(binding.wrappedValue)
                }
            }
        )
    }
    
    private var selection: ScaleSelectionBindingValue
    
    public init(
        id: String,
        title: String,
        detail: String? = nil,
        range: ClosedRange<Double>,
        step: Double = 1.0,
        selection: Double
    ) {
        self.id = id
        self.title = title
        self.detail = detail
        self.scaleSelectionConfiguration = .doubleRange(range)
        self.step = step
        self.primitiveSelection = .double(selection)
        self.selection = .double(.init(get: { selection }, set: { _ in }))
        self.stateManagementType = .automatic
        self._sliderUIValue = State(wrappedValue: selection)
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
        self.primitiveSelection = .double(selection.wrappedValue)
        self.selection = .double(selection)
        self.stateManagementType = .manual
        self._sliderUIValue = State(wrappedValue: selection.wrappedValue)
    }
    
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
        self.primitiveSelection = .int(selection)
        self.selection = .int(.init(get: { selection }, set: { _ in }))
        self.stateManagementType = .automatic
        self._sliderUIValue = State(wrappedValue: Double(selection))
    }

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
        self.primitiveSelection = .int(selection.wrappedValue)
        self.stateManagementType = .manual
        self._sliderUIValue = State(wrappedValue: Double(selection.wrappedValue))
    }
    
    @available(watchOS, unavailable)
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
        self.primitiveSelection = .textChoice(selection)
        self.selection = .textChoice(.init(get: { selection }, set: { _ in }))
        self.stateManagementType = .automatic
        
        let index = multipleChoiceOptions.firstIndex(where: { selection.id == $0.id })
        let sliderValue = index ?? Array<MultipleChoiceOption>.Index(0.0)
        self._sliderUIValue = State(wrappedValue: Double(sliderValue))
    }

    @available(watchOS, unavailable)
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
        self.primitiveSelection = .textChoice(selection.wrappedValue)
        self.selection = .textChoice(selection)
        self.stateManagementType = .manual
        
        let index = multipleChoiceOptions.firstIndex(where: { selection.id == $0.id })
        let sliderValue = index ?? Array<MultipleChoiceOption>.Index(0.0)
        self._sliderUIValue = State(wrappedValue: Double(sliderValue))
    }

    public var body: some View {
        FormItemCardView(title: title, detail: detail) {
            scaleView(selectionConfiguration: scaleSelectionConfiguration)
                .onChange(of: sliderUIValue) { oldValue, newValue in
                    switch resolvedBinding.wrappedValue {
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
            
            slider(selectionConfiguration: selectionConfiguration)
        }
    }
    
    @ViewBuilder
    private func sliderLabel(_ value: String) -> some View {
        Text(value)
            .fixedSize()
            .foregroundStyle(Color.choice(for: .label))
            .font(.subheadline)
            .fontWeight(.bold)
    }
    
    @ViewBuilder
    private func slider(selectionConfiguration: ScaleSelectionConfiguration) -> some View {
#if os(watchOS)
        Slider(
            value: $sliderUIValue,
            in: sliderBounds(for: selectionConfiguration)
        ) {
            Text("Slider for \(selectionConfiguration)")
        } minimumValueLabel: {
            sliderLabel("\(minimumValueDescription(for: selectionConfiguration))")
        } maximumValueLabel: {
            sliderLabel("\(maximumValueDescription(for: selectionConfiguration))")
        }
#else
        Slider(
            value: $sliderUIValue,
            in: sliderBounds(for: selectionConfiguration),
            step: sliderStep(for: selectionConfiguration)
        ) {
            Text("Slider for \(selectionConfiguration)")
        } minimumValueLabel: {
            sliderLabel("\(minimumValueDescription(for: selectionConfiguration))")
        } maximumValueLabel: {
            sliderLabel("\(maximumValueDescription(for: selectionConfiguration))")
        }
#endif
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
            (Color.choice(for: .secondaryBackground))
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

#Preview("Int") {
    ScrollView {
        ScaleSliderQuestionView(
            id: UUID().uuidString,
            title: "On a scale of 1-10, how would you rate today?",
            range: 1...10,
            selection: .constant(7)
        )
    }
}

#Preview("Double") {
    @Previewable @State var selection: Double = 0.0
    
    ScrollView {
        ScaleSliderQuestionView(
            id: UUID().uuidString,
            title: "Double Slider Question Example",
            range: 0.0 ... 10.0,
            step: 0.1,
            selection: $selection
        )
    }
}

#if !os(watchOS)
#Preview("Text") {
    ScrollView {
        ScaleSliderQuestionView(
            id: UUID().uuidString,
            title: "On a scale of Pun - Poem, how would you rate today?",
            multipleChoiceOptions: [
                .init(id: "1", choiceText: "Pun", value: 1 as NSNumber),
                .init(id: "2", choiceText: "Dad Joke", value: 2 as NSNumber),
                .init(id: "3", choiceText: "Knock-Knock Joke", value: 3 as NSNumber),
                .init(id: "4", choiceText: "One-Liner", value: 4 as NSNumber),
                .init(id: "5", choiceText: "Parody", value: 5 as NSNumber),
                .init(id: "5", choiceText: "Poem", value: 6 as NSNumber),
            ],
            selection: .constant(.init(id: "2", choiceText: "Dad Joke", value: 2 as NSNumber))
        )
    }
}
#endif
