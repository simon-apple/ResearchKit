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

import Combine
import SwiftUI

enum AnswerFormat {
    case text(String?)
    case numeric(Double?)
    case date(Date?)
    case weight(Double?)
    case height(Double?)
    case multipleChoice([ResultValue]?)
    case image([ResultValue]?)
    case scale(Double?)
}

extension AnswerFormat: Codable {}

public final class ResearchTaskResult: ObservableObject {

    @Published
    var stepResults: [String: AnswerFormat] = [:]
    
    // This initializer is to remain internal so that 3rd party developers can't insert into the environment.
    init() {}
    
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        stepResults = try container.decode([String: AnswerFormat].self, forKey: .stepResults)
    }

    func resultForStep<Result>(key: StepResultKey<Result>) -> Result? {
        let answerFormat = stepResults[key.id]
        switch answerFormat {
        case let .text(answer):
            return answer as? Result
        case .numeric(let decimal):
            return decimal as? Result
        case .date(let date):
            return date as? Result
        case .height(let height):
            return height as? Result
        case .weight(let weight):
            return weight as? Result
        case .image(let image):
            return image as? Result
        case .multipleChoice(let multipleChoice):
            return multipleChoice as? Result
        case .scale(let double):
            return double as? Result
        default:
            return nil
        }
    }

    func setResultForStep<Result>(_ format: AnswerFormat, key: StepResultKey<Result>) {
        stepResults[key.id] = format
    }
}

extension ResearchTaskResult: Codable {
    
    enum CodingKeys: CodingKey {
        
        case stepResults
        
    }
    
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(stepResults, forKey: .stepResults)
    }
    
}
