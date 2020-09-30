/*
 Copyright (c) 2020, Apple Inc. All rights reserved.
 
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

import ResearchKitCore
import SwiftUI

@available(watchOS 6.0, *)
public struct QuestionStepView: View {

    @ObservedObject
    public private(set) var step: ORKQuestionStep

    @ObservedObject
    public private(set) var result: ORKStepResult

    init(_ step: ORKQuestionStep, result: ORKStepResult) {
        self.step = step
        self.result = result
    }

    public var body: some View {
        VStack {
            if let stepTitle = step.title {
                Text(stepTitle)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .font(Font.system(.headline))
            }
            if let stepQuestion = step.question {
                Text(stepQuestion)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            if let textChoiceAnswerFormat = step.answerFormat as? ORKTextChoiceAnswerFormat {
                ForEach(textChoiceAnswerFormat.textChoices, id: \.self) { textChoice in
                    Button(action: {
                        let choiceResult = ORKChoiceQuestionResult(identifier: step.identifier)
                        choiceResult.choiceAnswers = [textChoice]
                        choiceResult.startDate = result.startDate
                        choiceResult.endDate = Date()
                        result.results = [choiceResult]
                    }) {
                        Text(textChoice.text)
                    }
                }
            }
        }
    }
}
