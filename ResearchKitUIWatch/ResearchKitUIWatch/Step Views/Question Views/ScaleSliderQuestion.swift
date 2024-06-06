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
                .sliderValueForegroundStyle()
            
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
