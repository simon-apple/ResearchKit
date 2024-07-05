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

public class TaskViewModel: ObservableObject {
    @Published var stepIdentifiers: [String] = []
    @Published var steps: [TaskStep] = []

    public init(
        stepIdentifiers: [String],
        steps: [TaskStep]
    ) {
        self.stepIdentifiers = stepIdentifiers
        self.steps = steps
    }

    func isLastStep(_ step: TaskStep) -> Bool {
        step.id == steps.last?.id
    }

    func index(for identifier: String) -> Int {
        steps.firstIndex(where: { $0.id.uuidString == identifier }) ?? 0
    }

    func step(for identifier: String) -> TaskStep? {
        steps.first { $0.id.uuidString == identifier }
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
