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

internal class CompletionObject: ObservableObject {
    
    private var block: () -> Void
    
    init(_ block: @escaping () -> Void) {
        self.block = block
    }
    
    func run() {
        block()
    }
}

typealias Progress = (index: Int, count: Int)

struct ProgressKey: EnvironmentKey {
    static let defaultValue: Progress? = nil
}

// swiftlint:disable implicit_getter
extension EnvironmentValues {
    
    var progress: Progress? {
        get { self[ProgressKey] }
        set { self[ProgressKey] = newValue }
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
    
    init(index: Int, @ViewBuilder _ content: @escaping (ORKStep, ORKStepResult) -> Content) {
        self.index = index
        self.content = content
    }
    
    var body: some View {
        
        let currentStep = taskManager.task.steps[index]
        let currentResult = taskManager.getOrCreateResult(for: currentStep)
        let stepView = content(currentStep, currentResult)
        let nextStep = index >= taskManager.task.steps.count - 1 ?
            nil : TaskContentView(index: index + 1, content).environmentObject(taskManager)
        
        ScrollView {
            stepView.onAppear {
                currentResult.startDate = Date()
            }
            .environment(\.progress, taskManager.progressForQuestionStep(currentStep))
            .environmentObject(CompletionObject({
                if nextStep != nil {
                        goNext = true
                } else {
                    currentResult.endDate = Date()
                    taskManager.finishReason = .completed
                }
            }))
            if let nextStepView = nextStep {
                NavigationLink(destination: nextStepView, isActive: $goNext, label: { EmptyView() })
            }
        }
    }
}
