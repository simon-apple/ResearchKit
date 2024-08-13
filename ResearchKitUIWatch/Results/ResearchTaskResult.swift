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

import SwiftUI

enum AnswerFormat: String, CaseIterable {
    case text
    case numeric
    case date
    case height
    case weight
    case image
    case multipleChoice
}

struct StepResult {
    let id: String
    let format: AnswerFormat
    let answer: Any
}

public final class ResearchTaskResult: Observable {

    // You don't want this init to be public, b/c you son't want developers injecting it into your env
    public init() {}

    // TODO: Is the "any" usage here inefficient when it comes to Observable diffing? Can we do better with an enum with cases for each result type?
    @Published
    var stepResults: [String: StepResult] = [:]

    func resultForStep<Result>(key: StepResultKey<Result>) -> Result? {
        if let value = stepResults[key.id] as? Result {
            return value
        } else {
            return nil
        }
    }

    func setResultForStep<Result>(_ result: Result, format: AnswerFormat, key: StepResultKey<Result>) {
        stepResults[key.id] = StepResult(
            id: key.id,
            format: format,
            answer: result
        )
    }
}

