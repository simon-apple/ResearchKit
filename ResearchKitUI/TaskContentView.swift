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

typealias Progress = (index: Int, count: Int)

struct ProgressKey: EnvironmentKey {
    static let defaultValue: Progress? = nil
}

struct CompletionKey: EnvironmentKey {
    static let defaultValue: (() -> Void)? = nil
}

// swiftlint:disable implicit_getter
extension EnvironmentValues {
    
    var progress: Progress? {
        get { self[ProgressKey] }
        set { self[ProgressKey] = newValue }
    }
    
    var completion: (() -> Void)? {
        get { self[CompletionKey] }
        set { self[CompletionKey] = newValue }
    }
}
// swiftlint:enable implicit_getter

internal struct TaskContentView<Content>: View where Content: View {
    
    @EnvironmentObject
    private var taskManager: TaskManager
    
    @State
    private var goNext: Bool = false
    
    private let index: Int
    
    private let content: (ORKStep, ORKStepResult) -> Content
    
    private var currentStep: ORKStep {
        return taskManager.task.steps[index]
    }
    
    private var currentResult: ORKStepResult {
        return taskManager.getOrCreateResult(for: currentStep)
    }
    
    private var hasNextStep: Bool {
        return index < taskManager.task.steps.count - 1
    }
    
    private var hasPreviousResult: Bool {
        guard let count = currentResult.results?.count, count >= 1 else {
            return false
        }
        
        return true
    }
    
    private var shouldAutoAdvance: Bool {
        return !taskManager.completedSteps.contains(currentStep)
    }
    
    func completion() -> () -> Void {
        
        return { [self] in

            // Date the end of this result
            currentResult.endDate = Date()
            
            if hasNextStep {
                goNext = shouldAutoAdvance
            } else {
                taskManager.finishReason = .completed
            }
            
            // 100ms buffer to not show the "Next" button until the transition is close to finishing
            DispatchQueue
                .main
                .asyncAfter(deadline: DispatchTime
                                .now()
                                .advanced(by: .milliseconds(100))) {
                    taskManager.markStepComplete(currentStep)
                }
        }
    }
    
    init(index: Int, @ViewBuilder _ content: @escaping (ORKStep, ORKStepResult) -> Content) {
        self.index = index
        self.content = content
    }
    
    var body: some View {
        
        let nextStep = hasNextStep ?
            TaskContentView(index: index + 1, content).environmentObject(taskManager) : nil
        
        ScrollView {
            
            content(currentStep, currentResult)
                .onAppear {
                    currentResult.startDate = Date()
                }
                .environment(\.progress, taskManager.progressForQuestionStep(currentStep))
                .environment((\.completion), completion())
            
            if let nextStepView = nextStep {
                NavigationLink(destination: nextStepView, isActive: $goNext) { EmptyView() }
                    .frame(height: .zero)
                
                if !shouldAutoAdvance {
                    Button("Next") { goNext = true }
                }
            }
        }
    }
}
