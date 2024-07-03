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

//
import SwiftUI

public struct TaskNavigationView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: TaskViewModel
    var onTaskCompletion: ((TaskCompletion) -> Void)?

    public init(
        viewModel: TaskViewModel,
        onTaskCompletion: ((TaskCompletion) -> Void)? = nil
    ) {
        self.viewModel = viewModel
        self.onTaskCompletion = onTaskCompletion
    }

    public var body: some View {
        NavigationStack(path: $viewModel.stepIdentifiers) {
            TaskStepContentView(
                title: viewModel.steps[0].title,
                subtitle: viewModel.steps[0].subtitle,
                path: viewModel.steps[0].id.uuidString,
                isLastStep: 0 == (viewModel.steps.count - 1),
                onStepCompletion: { completion in
                    if completion == .discarded {
                        dismiss()
                    } else if completion == .saved {
                        let nextStep = viewModel.steps[1]
                        viewModel.stepIdentifiers.append(nextStep.id.uuidString)
                    } else {
                        onTaskCompletion?(completion)
                    }
                },
                content: {
                    ForEach($viewModel.steps[0].items) { $row in
                        FormRowContent(detail: nil, formRow: $row)
                    }
                }
            )
            .navigationTitle("1 of \(viewModel.steps.count)")
            .navigationDestination(for: String.self) { path in
                if let step = viewModel.step(for: path) {
                    let index = viewModel.index(for: step.id.uuidString)
                    TaskStepContentView(
                        title: step.title,
                        subtitle: step.subtitle,
                        path: path,
                        isLastStep: viewModel.isLastStep(step),
                        onStepCompletion: { completion in
                            if completion == .discarded {
                                dismiss()
                            } else if completion == .saved {
                                let nextStep = viewModel.steps[index + 1]
                                viewModel.stepIdentifiers.append(nextStep.id.uuidString)
                            } else {
                                onTaskCompletion?(completion)
                            }
                        },
                        content: {
                            ForEach($viewModel.steps[index].items) { $row in
                                FormRowContent(detail: nil, formRow: $row)
                            }
                        }
                    )
                    .navigationTitle("\(index + 1) of \(viewModel.steps.count)")
                }
            }
        }
    }
}

