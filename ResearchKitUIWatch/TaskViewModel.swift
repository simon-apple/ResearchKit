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
import ResearchKit // TODO: Remove
import SwiftUI

public protocol Step {
    
    associatedtype Content: View
    
    var identifier: String { get }
    
    var iconImage: Image? { get }
    
    var title: String? { get }
    
    var subtitle: String? { get }
    
    func makeContent() -> Content
    
}

public class TaskViewModel: ObservableObject {
    @Published var stepIdentifiers: [String] = []
    @Published var steps: [any Step]
    
    private var anyCancellable: AnyCancellable?

    public init(
        stepIdentifiers: [String],
        steps: [any Step]
    ) {
        self.stepIdentifiers = stepIdentifiers
        self.steps = steps
        
        anyCancellable = $steps.sink(receiveValue: { steps in
            print("Steps changed to: \(steps)")
        })
    }
    
    var numberOfSteps: Int {
        steps.count
    }

    func isLastStep(_ step: TaskStep) -> Bool {
        steps.last?.identifier == step.id.uuidString
    }

    func index(for identifier: String) -> Int {
        steps.firstIndex(where: { $0.identifier == identifier }) ?? 0
    }
    
    private func index(for path: String) -> Int? {
        steps.firstIndex { step in
            step.identifier == path
        }
    }
    
    func step(for identifier: String) -> (any Step)? {
        steps.first { $0.identifier == identifier }
    }
    
    func image(forIndex index: Int) -> Image? {
        steps[index].iconImage
    }
    
    func image(at path: String) -> Image? {
        step(for: path)?.iconImage
    }
    
    func title(forIndex index: Int) -> String? {
        steps[index].title
    }
    
    func titleForStep(at path: String) -> String? {
        step(for: path)?.title
    }
    
    func subtitle(forIndex index: Int) -> String? {
        steps[index].subtitle
    }
    
    func subtitleForNextStep(for path: String) -> String? {
        step(for: path)?.subtitle
    }
    
    func isLastStep(forIndex index: Int) -> Bool {
        steps.count - 1 == index
    }
    
    func isLastStep(for path: String) -> Bool {
        guard let index = index(for: path) else {
            return false
        }
        return isLastStep(forIndex: index)
    }
    
    private func isLastStep(for path: String, in instructionSteps: [ORKInstructionStep]) -> Bool {
        steps.last?.identifier == path
    }
    
    func makeContent(forIndex index: Int) -> any View {
        steps[index].makeContent()
    }
    
    func makeContentForNextStep(for path: String) -> any View {
        step(for: path)?.makeContent() ?? EmptyView()
    }
    
    func identifier(forIndex index: Int) -> String {
        steps[index].identifier
    }
    
    func identifier(afterPath path: String) -> String? {
        func step(after path: String) -> (any Step)? {
            guard let index = index(for: path) else {
                return nil
            }
            
            let nextIndex = index + 1
            
            let instructionStep: (any Step)?
            if nextIndex == steps.count {
                instructionStep = nil
            } else {
                instructionStep = steps[nextIndex]
            }
            return instructionStep
        }
        
        return step(after: path)?.identifier
    }
    
    func navigationTitleForNextStep(for path: String) -> String {
        let navigationTitle: String
        if let index = index(for: path) {
            navigationTitle = "\(index + 1) of \(steps.count)"
        } else {
            navigationTitle = ""
        }
        return navigationTitle
    }
    
}

public class TaskStep: Identifiable {
    public let id: UUID = UUID()
    public let title: String?
    public let subtitle: String?
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

extension TaskStep: Step {
    
    public typealias Content = ForEach
    
    public var identifier: String {
        id.uuidString
    }
    
    public var iconImage: Image? {
        nil
    }
    
    @ViewBuilder
    public func makeContent() -> some View {
        ForEach(Array(items.enumerated()), id: \.offset) { itemIndex, formRow in
            FormRowContent(
                detail: nil,
                formRow: Binding<FormRow>(
                    get: { [weak self] in
                        self?.items[itemIndex] ?? formRow
                    },
                    set: { [weak self] formRow in
                        print("Form row set to: \(formRow)")
                        self?.items[itemIndex] = formRow
                    }
                )
            )
        }
    }
    
}
