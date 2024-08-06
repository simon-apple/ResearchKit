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

// apple-internal

import ResearchKit
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
    public internal(set) var finishReason: FinishReason? {
        willSet {
            result.endDate = Date()
        }
    }

    @Published
    public private(set) var result: ORKTaskResult

    public private(set) var task: ORKOrderedTask

    @Published
    internal private(set) var answeredSteps: Set<ORKStep> = []
    
    var viewModels: [String: ViewModel] = [:]
    
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
    
    func progressForQuestionStep(_ step: ORKStep) -> Progress? {
        
        let questionSteps = task.steps.compactMap { $0 as? ORKFormStep }

        guard let questionStep = step as? ORKFormStep,
              let index = questionSteps.firstIndex(of: questionStep) else {
            
            return nil
        }
        
        return (index + 1, questionSteps.count)
    }
}

internal extension TaskManager {
    
    func mark(_ step: ORKStep, answered: Bool) {
        if answered {
            answeredSteps.insert(step)
        } else {
            answeredSteps.remove(step)
        }
    }
}

internal extension TaskManager {
    
    // swiftlint:disable line_length
    // Since we are supporting watchOS 6.0, we do not have access to use @StateObject (watchOS 7.0 +) to support views having thier own models.
    // Instead, we opt to use the TaskManager as the source of truth, and therefore supply the views with a view model.
    // swiftlint:enable line_length
    
    func viewModelForStep(_ step: ORKStep) -> ViewModel {
        
        if let viewModel = viewModels[step.identifier] {
            return viewModel
        } else if let questionStep = step as? ORKFormStep {

            let viewModel = FormStepViewModel(step: questionStep,
                                            result: getOrCreateResult(for: step))
            viewModel.progress = progressForQuestionStep(step)
            self.viewModels[step.identifier] = .formStep(viewModel)
            return .formStep(viewModel)
        }

        debugPrint("Attempted to create a ViewModel for an ORKStep type that is not supported yet: \(step.description)")
        return .none
    }
}
