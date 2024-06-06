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

