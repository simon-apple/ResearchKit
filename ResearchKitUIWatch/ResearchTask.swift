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

public struct ResearchTask: View {
    
    @Environment(\.dismiss) var dismiss
    private let steps: [ResearchTaskStep]
    @State private var stepIdentifiers: [String] = []
    
    var onResearchTaskCompletion: ((ResearchTaskCompletion) -> Void)?

    public init(
        @ResearchTaskBuilder steps: () -> [ResearchTaskStep],
        onResearchTaskCompletion: ((ResearchTaskCompletion) -> Void)? = nil
    ) {
        self.steps = steps()
        self.onResearchTaskCompletion = onResearchTaskCompletion
    }

    public var body: some View {
        NavigationStack(path: $stepIdentifiers) {
            if let firstStep = steps.first {
                ResearchTaskStepContentView(
                    isLastStep: isLastStep(for: firstStep),
                    onStepCompletion: { completion in
                        if completion == .discarded {
                            dismiss()
                        } else if completion == .saved {
                            moveToStep(after: firstStep)
                        } else {
                            onResearchTaskCompletion?(completion)
                        }
                    },
                    content: {
                        firstStep
                    }
                )
                .navigationTitle("1 of \(steps.count)")
                .navigationDestination(for: String.self) { path in
                    ResearchTaskStepContentView(
                        isLastStep: isLastStep(atPath: path),
                        onStepCompletion: { completion in
                            if completion == .discarded {
                                dismiss()
                            } else if completion == .saved {
                                moveToStep(afterPath: path)
                            } else {
                                onResearchTaskCompletion?(completion)
                            }
                        },
                        content: {
                            step(atPath: path)
                        }
                    )
                    .navigationTitle(navigationTitle(atPath: path))
                }
            }
        }
    }
    
    private func isLastStep(for step: ResearchTaskStep) -> Bool {
        guard let stepIndex = index(for: step) else {
            return false
        }
        return isLastStep(forIndex: stepIndex)
    }
    
    private func isLastStep(forIndex index: Int) -> Bool {
        steps.count - 1 == index
    }
    
    private func isLastStep(atPath path: String) -> Bool {
        guard let index = index(forPath: path) else {
            return false
        }
        return isLastStep(forIndex: index)
    }
    
    private func index(forPath path: String) -> Int? {
        steps.firstIndex { step in
            step.identifier == path
        }
    }
    
    private func moveToStep(after step: ResearchTaskStep) {
        guard let nextStep = self.step(after: step) else {
            return
        }
        stepIdentifiers.append(nextStep.identifier)
    }
    
    private func step(after step: ResearchTaskStep) -> ResearchTaskStep? {
        guard let stepIndex = index(for: step) else {
            return nil
        }
        
        let nextStepIndex = stepIndex + 1
        
        guard nextStepIndex < steps.count else {
            return nil
        }
        
        return steps[nextStepIndex]
    }
    
    private func moveToStep(atIndex index: Int) {
        if index < steps.count {
            stepIdentifiers.append(steps[index].identifier)
        }
    }
    
    private func moveToStep(afterPath path: String) {
        if let nextIdentifier = identifier(afterPath: path) {
            stepIdentifiers.append(nextIdentifier)
        }
    }
    
    private func identifier(afterPath path: String) -> String? {
        func step(afterPath path: String) -> ResearchTaskStep? {
            guard let index = index(forPath: path) else {
                return nil
            }
            
            let nextIndex = index + 1
            
            let instructionStep: ResearchTaskStep?
            if nextIndex == steps.count {
                instructionStep = nil
            } else {
                instructionStep = steps[nextIndex]
            }
            return instructionStep
        }
        
        return step(afterPath: path)?.identifier
    }
    
    private func indexForStep(atPath path: String) -> Int? {
        steps.firstIndex(where: { $0.identifier == path })
    }
    
    private func index(for step: ResearchTaskStep) -> Int? {
        steps.firstIndex(where: { $0.identifier == step.identifier })
    }
    
    private func step(atPath path: String) -> ResearchTaskStep? {
        steps.first(where: { $0.identifier == path })
    }
    
    private func navigationTitle(atPath path: String) -> String {
        let navigationTitle: String
        if let index = index(forPath: path) {
            navigationTitle = "\(index + 1) of \(steps.count)"
        } else {
            navigationTitle = ""
        }
        return navigationTitle
    }
    
}

public struct ResearchTaskStep: View {
    
    private let id = UUID()
    private let content: AnyView
    
    public init<Content: View>(@ViewBuilder content: () -> Content) {
        self.content = AnyView(content())
    }
    
    public var body: some View {
        content
    }
    
    var identifier: String {
        id.uuidString
    }
    
}

@resultBuilder
public struct ResearchTaskBuilder {
    
    public static func buildBlock(_ components: ResearchTaskStep...) -> [ResearchTaskStep] {
        components
    }
    
    public static func buildBlock(_ components: [ResearchTaskStep]...) -> [ResearchTaskStep] {
        components.flatMap { $0 }
    }
    
    public static func buildEither(first component: [ResearchTaskStep]) -> [ResearchTaskStep] {
        component
    }
    
    public static func buildEither(second component: [ResearchTaskStep]) -> [ResearchTaskStep] {
        component
    }
    
}
