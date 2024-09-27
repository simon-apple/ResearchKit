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

enum MultipleChoiceAnswerFormat: Int {
    case multiple = 0
    case image
}

public class RKAdapter {
    
    static var multipleChoiceAnswerFormatKey = "multipleChoiceAnswerFormatKey"
    
    public static func createORKResults(from taskResult: ResearchFormResult) -> [ORKResult] {
        let resultsDictionary = taskResult.stepResults
        
        var resultsArray: [ORKResult] = []
        resultsDictionary.forEach { entry in
            let value = entry.value
            switch value {
            case let .text(answer):
                let result = ORKTextQuestionResult(identifier: entry.key)
                result.questionType = .text
                result.textAnswer = answer
                resultsArray.append(result)
            case .numeric(let decimal):
                let result = ORKNumericQuestionResult(identifier: entry.key)
                result.questionType = .decimal
                result.numericAnswer = NSNumber(floatLiteral: decimal ?? 0.0)
                resultsArray.append(result)
            case .date(let date):
                let result = ORKDateQuestionResult(identifier: entry.key)
                result.questionType = .date
                result.dateAnswer = date
                resultsArray.append(result)
            case .height(let height):
                let result = ORKNumericQuestionResult(identifier: entry.key)
                result.questionType = .height
                if let answer = height {
                    result.numericAnswer = NSNumber(floatLiteral: answer)
                }
                resultsArray.append(result)
            case .weight(let weight):
                let result = ORKNumericQuestionResult(identifier: entry.key)
                result.questionType = .weight
                if let answer = weight {
                    result.numericAnswer = NSNumber(floatLiteral: answer)
                }
                resultsArray.append(result)
            case .image(let images):
                let result = ORKChoiceQuestionResult(identifier: entry.key)
                let info = [
                    multipleChoiceAnswerFormatKey :
                        MultipleChoiceAnswerFormat.image.rawValue
                ]
                result.userInfo = info
                result.questionType = .multipleChoice
                if let results = images {
                    result.choiceAnswers = results.map { RKAdapter.rkValue(from: $0) }
                }
                resultsArray.append(result)
            case .multipleChoice(let multipleChoice):
                let result = ORKChoiceQuestionResult(identifier: entry.key)
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
                resultsArray.append(result)
            case .scale(let value):
                let result = ORKScaleQuestionResult(identifier: entry.key)
                if let value = value {
                    result.scaleAnswer = NSNumber(floatLiteral: value)
                }
                result.questionType = .scale
                resultsArray.append(result)
            }
        }
        
        return resultsArray
    }
    
    public static func createTaskResults(from data: Data) -> ResearchFormResult? {
        if let taskResult = ORKIESerializer.swiftUI_object(fromJSONData: data, error: nil) as? ORKTaskResult {
            let researchTaskResult = ResearchFormResult()
            if let stepResults = taskResult.results as? [ORKStepResult] {
                for stepResult in stepResults {
                    guard let results = stepResult.results else { continue }
                    
                    for result in results {
                        let identifier = result.identifier
                        if let result = result as? ORKTextQuestionResult {
                            researchTaskResult.stepResults[identifier] = .text(result.textAnswer ?? "Unknown")
                        } else if let result = result as? ORKNumericQuestionResult {
                            if result.questionType == .decimal {
                                researchTaskResult.stepResults[identifier] = .numeric(result.numericAnswer?.doubleValue ?? 0)
                            } else if result.questionType == .weight {
                                researchTaskResult.stepResults[identifier] = .weight(result.numericAnswer?.doubleValue ?? 0)
                            } else if result.questionType == .height {
                                researchTaskResult.stepResults[identifier] = .height(result.numericAnswer?.doubleValue ?? 0)
                            }
                        } else if let result = result as? ORKDateQuestionResult {
                            researchTaskResult.stepResults[identifier] = .date(result.dateAnswer ?? Date())
                        } else if let result = result as? ORKChoiceQuestionResult {
                            if let userInfo = result.userInfo,
                               let formatValue = userInfo[multipleChoiceAnswerFormatKey] as? Int,
                               let format = MultipleChoiceAnswerFormat(rawValue: formatValue) {
                                if let selections = result.choiceAnswers {
                                    let newSelections: [ResultValue] = selections.compactMap { RKAdapter.value(from: $0) }
                                    switch format {
                                    case .multiple:
                                        researchTaskResult.stepResults[identifier] = .multipleChoice(newSelections)
                                    case .image:
                                        researchTaskResult.stepResults[identifier] = .image(newSelections)
                                    }
                                }
                            }
                        } else if let result = result as? ORKScaleQuestionResult {
                            researchTaskResult.stepResults[identifier] = .scale(result.scaleAnswer?.doubleValue ?? 0)
                        }
                    }
                }
            }
            
            return researchTaskResult
        }
        return nil
    }
    
    public static func rkValue(from result: ResultValue) -> NSCopying & NSSecureCoding & NSObjectProtocol {
        switch result {
        case .int(let int):
            return NSNumber(integerLiteral: int)
        case .string(let string):
            return NSString(string: string)
        case .date(let date):
            return date as NSDate
        }
    }
    
    public static func value(from rkValue: NSCopying & NSSecureCoding & NSObjectProtocol) -> ResultValue? {
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
