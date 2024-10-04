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
import ResearchKitSwiftUI
import SwiftUI

enum MultipleChoiceAnswerFormat: Int {
    case multiple = 0
    case image
}

public class RKAdapter {

    static var multipleChoiceAnswerFormatKey = "multipleChoiceAnswerFormatKey"
    
    public static func createORKResults(from taskResult: ResearchFormResult) -> [ORKResult] {
        taskResult.compactMap { result in
            let orkResult: ORKResult?
            
            switch result.answer {
            case let .text(answer):
                let result = ORKTextQuestionResult(identifier: result.identifier)
                result.questionType = .text
                result.textAnswer = answer
                orkResult = result
            case .numeric(let decimal):
                let result = ORKNumericQuestionResult(identifier: result.identifier)
                result.questionType = .decimal
                result.numericAnswer = NSNumber(floatLiteral: decimal ?? 0.0)
                orkResult = result
            case .date(let date):
                let result = ORKDateQuestionResult(identifier: result.identifier)
                result.questionType = .date
                result.dateAnswer = date
                orkResult = result
            case .height(let height):
                let result = ORKNumericQuestionResult(identifier: result.identifier)
                result.questionType = .height
                if let answer = height {
                    result.numericAnswer = NSNumber(floatLiteral: answer)
                }
                orkResult = result
            case .weight(let weight):
                let result = ORKNumericQuestionResult(identifier: result.identifier)
                result.questionType = .weight
                if let answer = weight {
                    result.numericAnswer = NSNumber(floatLiteral: answer)
                }
                orkResult = result
            case .image(let images):
                let result = ORKChoiceQuestionResult(identifier: result.identifier)
                let info = [
                    multipleChoiceAnswerFormatKey :
                        MultipleChoiceAnswerFormat.image.rawValue
                ]
                result.userInfo = info
                result.questionType = .multipleChoice
                if let results = images {
                    result.choiceAnswers = results.map { RKAdapter.rkValue(from: $0) }
                }
                orkResult = result
            case .multipleChoice(let multipleChoice):
                let result = ORKChoiceQuestionResult(identifier: result.identifier)
                let info = [
                    multipleChoiceAnswerFormatKey :
                        MultipleChoiceAnswerFormat.multiple.rawValue
                ]
                if let answers = multipleChoice {
                    let newResults = answers.map { RKAdapter.rkValue(from: $0) }
                    result.choiceAnswers = newResults
                }
                result.userInfo = info
                result.questionType = .multipleChoice
                orkResult = result
            case .scale(let value):
                let result = ORKScaleQuestionResult(identifier: result.identifier)
                if let value = value {
                    result.scaleAnswer = NSNumber(floatLiteral: value)
                }
                result.questionType = .scale
                orkResult = result
            @unknown default:
                orkResult = nil
            }
            
            return orkResult
        }
    }
    
    public static func data(for taskResult: ORKTaskResult) throws -> Data {
        try ORKIESerializer.swiftUI_JSONData(for: taskResult)
    }
    
    public static func createTaskResults(from data: Data) -> ResearchFormResult? {
        guard let taskResult = ORKIESerializer.swiftUI_object(fromJSONData: data, error: nil) as? ORKTaskResult else {
            return nil
        }
        
        let stepResults = taskResult.results as? [ORKStepResult] ?? []
        let results: [Result] = stepResults.flatMap { stepResult in
            let questionResults = stepResult.results ?? []
            
            return questionResults.compactMap { questionResult -> Result? in
                let identifier = questionResult.identifier
                
                let result: Result?
                
                if let textQuestionResult = questionResult as? ORKTextQuestionResult {
                    result = Result(identifier: identifier, answer: .text(textQuestionResult.textAnswer ?? "Unknown"))
                } else if let numericQuestionResult = questionResult as? ORKNumericQuestionResult {
                    if numericQuestionResult.questionType == .decimal {
                        result = Result(identifier: identifier, answer: .numeric(numericQuestionResult.numericAnswer?.doubleValue ?? 0))
                    } else if numericQuestionResult.questionType == .weight {
                        result = Result(identifier: identifier, answer: .weight(numericQuestionResult.numericAnswer?.doubleValue ?? 0))
                    } else if numericQuestionResult.questionType == .height {
                        result = Result(identifier: identifier, answer: .height(numericQuestionResult.numericAnswer?.doubleValue ?? 0))
                    } else {
                        result = nil
                    }
                } else if let dateQuestionResult = questionResult as? ORKDateQuestionResult {
                    result = Result(identifier: identifier, answer: .date(dateQuestionResult.dateAnswer ?? Date()))
                } else if let choiceQuestionResult = questionResult as? ORKChoiceQuestionResult {
                    if let userInfo = choiceQuestionResult.userInfo,
                       let formatValue = userInfo[multipleChoiceAnswerFormatKey] as? Int,
                       let format = MultipleChoiceAnswerFormat(rawValue: formatValue) {
                        if let selections = choiceQuestionResult.choiceAnswers {
                            let newSelections: [ResultValue] = selections.compactMap { RKAdapter.value(from: $0) }
                            switch format {
                            case .multiple:
                                result = Result(identifier: identifier, answer: .multipleChoice(newSelections))
                            case .image:
                                result = Result(identifier: identifier, answer: .image(newSelections))
                            }
                        } else {
                            result = nil
                        }
                    } else {
                        result = nil
                    }
                } else if let scaleQuestionResult = questionResult as? ORKScaleQuestionResult {
                    result = Result(identifier: identifier, answer: .scale(scaleQuestionResult.scaleAnswer?.doubleValue ?? 0))
                } else {
                    result = nil
                }
                
                return result
            }
        }
        return ResearchFormResult(results: results)
    }

    static func rkValue(from result: ResultValue) -> NSCopying & NSSecureCoding & NSObjectProtocol {
        switch result {
        case .int(let int):
            return NSNumber(integerLiteral: int)
        case .string(let string):
            return NSString(string: string)
        case .date(let date):
            return date as NSDate
        }
    }

    static func value(from rkValue: NSCopying & NSSecureCoding & NSObjectProtocol) -> ResultValue? {
        if let number = rkValue as? NSNumber {
            return .int(number.intValue)
        } else if let string = rkValue as? NSString {
            return .string(String(string))
        } else if let date = rkValue as? Date {
            return .date(date)
        }
        assertionFailure("Unexpected RKValue type passed in, this is a developer error")
        return nil
    }
    
}
