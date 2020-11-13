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

extension ORKStep: ObservableObject {}
extension ORKOrderedTask: ObservableObject {}
extension ORKResult: ObservableObject {}

@available(watchOS 6.0, *)
open class TaskManager: ObservableObject {

    public enum FinishReason {
        case saved
        case discarded
        case completed
        case failed
        case terminated
    }

    @Published
    public internal(set) var finishReason: FinishReason?

    @Published
    public private(set) var result: ORKTaskResult

    private(set) var task: ORKOrderedTask

    public init(task: ORKOrderedTask) {
        self.task = task
        self.result = ORKTaskResult(taskIdentifier: self.task.identifier,
                                    taskRun: UUID(),
                                    outputDirectory: nil)
    }

    func getOrCreateResult(for step: ORKStep) -> ORKStepResult {

        if let currentStepResult = self.result.results?
            .first(where: { $0.identifier == step.identifier }) as? ORKStepResult {
            return currentStepResult
        } else {
            let result = ORKStepResult(identifier: step.identifier)
            self.result.results?.append(result)
            return result
        }
    }
}

extension TaskManager {
    
    var questionSteps: [ORKQuestionStep]? {
        
        return task.steps.filter { $0 is ORKQuestionStep } as? [ORKQuestionStep]
    }
    
    func progressForQuestionStep(_ step: ORKStep) -> Progress {
        
        guard let questionStep = step as? ORKQuestionStep,
              let index = questionSteps?.firstIndex(of: questionStep),
              let count = questionSteps?.count else {
            
            return Progress(value: nil)
        }
        
        return Progress(value: (index + 1, count))
    }
}
