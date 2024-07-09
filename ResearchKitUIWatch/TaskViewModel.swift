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

import ResearchKit // TODO: Remove
import SwiftUI

public class TaskViewModel: ObservableObject {
    @Published var stepIdentifiers: [String] = []
    @Published var steps: [TaskStep] = []
    @Published var instructionSteps: [ORKInstructionStep]?

    public init(
        stepIdentifiers: [String],
        steps: [TaskStep],
        instructionSteps: [ORKInstructionStep]? = nil
    ) {
        self.stepIdentifiers = stepIdentifiers
        self.steps = steps
        self.instructionSteps = instructionSteps
    }
    
    var numberOfSteps: Int {
        let numberOfSteps: Int
        if let instructionSteps {
            numberOfSteps = instructionSteps.count
        } else {
            numberOfSteps = steps.count
        }
        return numberOfSteps
    }

    func isLastStep(_ step: TaskStep) -> Bool {
        step.id == steps.last?.id
    }

    func index(for identifier: String) -> Int {
        steps.firstIndex(where: { $0.id.uuidString == identifier }) ?? 0
    }
    
    private func index(for path: String, in instructionSteps: [ORKInstructionStep]) -> Int? {
        instructionSteps.firstIndex { instructionStep in
            instructionStep.identifier == path
        }
    }

    func step(for identifier: String) -> TaskStep? {
        steps.first { $0.id.uuidString == identifier }
    }
    
    func image(forIndex index: Int) -> Image? {
        let image: Image?
        if let instructionSteps {
            if let iconImage = instructionSteps[index].iconImage {
                image = Image(uiImage: iconImage)
            } else {
                image = nil
            }
        } else {
            image = nil
        }
        return image
    }
    
    func image(at path: String) -> Image? {
        let image: Image?
        if let instructionSteps {
            if let iconImage = step(for: path, in: instructionSteps)?.iconImage {
                image = Image(uiImage: iconImage)
            } else {
                image = nil
            }
        } else {
            image = nil
        }
        return image
    }
    
    func title(forIndex index: Int) -> String? {
        let title: String?
        if let instructionSteps {
            title = instructionSteps[index].title
        } else {
            title = steps[index].title
        }
        return title
    }
    
    func titleForStep(at path: String) -> String? {
        let title: String?
        if let instructionSteps {
            title = step(for: path, in: instructionSteps)?.title
        } else if let step = step(for: path) {
            title = step.title
        } else {
            title = nil
        }
        return title
    }
    
    func subtitle(forIndex index: Int) -> String? {
        let subtitle: String?
        if let instructionSteps {
            subtitle = instructionSteps[index].detailText
        } else {
            subtitle = steps[index].subtitle
        }
        return subtitle
    }
    
    func subtitleForNextStep(for path: String) -> String? {
        let subtitle: String?
        if let instructionSteps {
            subtitle = step(for: path, in: instructionSteps)?.detailText
        } else if let step = step(for: path) {
            subtitle = step.subtitle
        } else {
            subtitle = nil
        }
        return subtitle
    }
    
    func isLastStep(forIndex index: Int) -> Bool {
        let isLastStepForInitialStep: Bool
        if let instructionSteps {
            isLastStepForInitialStep = index == (instructionSteps.count - 1)
        } else {
            isLastStepForInitialStep = index == (steps.count - 1)
        }
        return isLastStepForInitialStep
    }
    
    func isLastStep(for path: String) -> Bool {
        let isLastStep: Bool
        if let instructionSteps {
            isLastStep = self.isLastStep(for: path, in: instructionSteps)
        } else if let step = step(for: path) {
            isLastStep = self.isLastStep(step)
        } else {
            isLastStep = true
        }
        return isLastStep
    }
    
    private func isLastStep(for path: String, in instructionSteps: [ORKInstructionStep]) -> Bool {
        guard let lastInstructionStep = instructionSteps.last else {
            return false
        }
        return lastInstructionStep.identifier == path
    }
    
    @ViewBuilder
    func makeContent(forIndex index: Int) -> some View {
        if let instructionSteps {
            if let bodyItems = instructionSteps[index].bodyItems {
                ForEach(bodyItems, id: \.text) { bodyItem in
                    Text(bodyItem.text ?? "")
                }
            }
        } else {
            ForEach(Array(steps[index].items.enumerated()), id: \.offset) { itemIndex, formRow in
                FormRowContent(
                    detail: nil,
                    formRow: Binding<FormRow>(
                        get: {
                            formRow
                        },
                        set: { formRow in
                            self.steps[index].items[itemIndex] = formRow
                        }
                    )
                )
            }
        }
    }
    
    @ViewBuilder
    func makeContentForNextStep(for path: String) -> some View {
        // This is where the biggest difference will be. TaskViewModel currently assumes
        // TaskSteps, and by association, TaskViewModel also assumes FormRows.
        //
        // The body is different for the kind of step. Instruction step, for instance,
        // does not care about form rows.
        //
        if let instructionSteps {
            if let bodyItems = step(for: path, in: instructionSteps)?.bodyItems {
                ForEach(bodyItems, id: \.text) { bodyItem in
                    Text(bodyItem.text ?? "")
                }
            }
        } else if let step = step(for: path) {
            let index = index(for: step.id.uuidString)
            ForEach(Array(steps[index].items.enumerated()), id: \.offset) { itemIndex, formRow in
                FormRowContent(
                    detail: nil,
                    formRow: Binding<FormRow>(
                        get: {
                            formRow
                        },
                        set: { formRow in
                            self.steps[index].items[itemIndex] = formRow
                        }
                    )
                )
            }
        }
    }
    
    func identifier(forIndex index: Int) -> String {
        let id: String
        if let instructionSteps {
            let nextStep = instructionSteps[index]
            id = nextStep.identifier
        } else {
            let nextStep = steps[index]
            id = nextStep.id.uuidString
        }
        return id
    }
    
    func identifier(afterPath path: String) -> String? {
        func step(after path: String, in instructionSteps: [ORKInstructionStep]) -> ORKInstructionStep? {
            guard let index = index(for: path, in: instructionSteps) else {
                return nil
            }
            
            let nextIndex = index + 1
            
            let instructionStep: ORKInstructionStep?
            if nextIndex == instructionSteps.count {
                instructionStep = nil
            } else {
                instructionStep = instructionSteps[nextIndex]
            }
            return instructionStep
        }
        
        let identifier: String?
        if let instructionSteps {
            if let nextInstructionStep = step(after: path, in: instructionSteps) {
                identifier = nextInstructionStep.identifier
            } else {
                identifier = nil
            }
        } else if let step = self.step(for: path) {
            let index = index(for: step.id.uuidString)
            let nextStep = steps[index + 1]
            identifier = nextStep.id.uuidString
        } else {
            identifier = nil
        }
        return identifier
    }
    
    func navigationTitleForNextStep(for path: String) -> String {
        let navigationTitle: String
        if let instructionSteps {
            if let index = index(for: path, in: instructionSteps) {
                navigationTitle = "\(index + 1) of \(instructionSteps.count)"
            } else {
                navigationTitle = ""
            }
        } else if let step = step(for: path) {
            let index = index(for: step.id.uuidString)
            navigationTitle = "\(index + 1) of \(steps.count)"
        } else {
            navigationTitle = ""
        }
        return navigationTitle
    }
    
    private func step(for path: String, in instructionSteps: [ORKInstructionStep]) -> ORKInstructionStep? {
        instructionSteps.first { instructionStep in
            instructionStep.identifier == path
        }
    }
    
}

public struct TaskStep: Identifiable {
    public let id: UUID = UUID()
    let title: String?
    let subtitle: String?
    var items: [FormRow]

    public init(
        title: String?,
        subtitle: String?,
        items: [FormRow]
    ) {
        self.title = title
        self.subtitle = subtitle
        self.items = items
    }
}
