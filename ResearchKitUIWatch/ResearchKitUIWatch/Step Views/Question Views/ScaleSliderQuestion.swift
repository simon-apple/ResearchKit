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

