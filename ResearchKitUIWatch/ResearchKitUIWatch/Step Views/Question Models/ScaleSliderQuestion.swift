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

public enum ScaleSelectionConfiguration {
    
    @available(watchOS, unavailable)
    case textChoice([MultipleChoiceOption])
    
    case integerRange(ClosedRange<Int>)
    case doubleRange(ClosedRange<Double>)
}

public struct ScaleSliderQuestion<ResultType>: Identifiable {

    public let id: String
    public let title: String
    public let detail: String?
    public let step: Double
    public let value: Double
    public let range: ClosedRange<Double>
    public let configuration: ScaleSelectionConfiguration

    public init(
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

    public var intResult: Int {
        return Int(value)
    }

    var range: ClosedRange<Int> {
        return Int(range.lowerBound)...Int(range.upperBound)
    }

    public init(
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

    public var result: Double {
        return value
    }

}

extension ScaleSliderQuestion where ResultType == MultipleChoiceOption {

    public var result: MultipleChoiceOption {
        switch configuration {
        case .textChoice(let choices):
            return choices[Int(value)]
        default:
            fatalError("Unsupported configuration detected for MultipleChoiceOption when querying result")
        }
    }

    public var multipleChoiceOptions: [MultipleChoiceOption] {
        switch configuration {
        case .textChoice(let options):
            return options
        default:
            fatalError("Unsupported configuration detected for MultipleChoiceOption when querying multiple choice options")
        }
    }

    @available(watchOS, unavailable)
    public init(
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
