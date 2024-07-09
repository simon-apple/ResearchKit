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

import ResearchKit
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
        return NavigationStack(path: $viewModel.stepIdentifiers) {
            TaskStepContentView(
                image: viewModel.image(forIndex: 0),
                title: viewModel.title(forIndex: 0),
                subtitle: viewModel.subtitle(forIndex: 0),
                isLastStep: viewModel.isLastStep(forIndex: 0),
                onStepCompletion: { completion in
                    if completion == .discarded {
                        dismiss()
                    } else if completion == .saved {
                        viewModel.stepIdentifiers.append(viewModel.identifier(forIndex: 1))
                    } else {
                        onTaskCompletion?(completion)
                    }
                },
                content: {
                    viewModel.makeContent(forIndex: 0)
                }
            )
            .navigationTitle("1 of \(viewModel.numberOfSteps)")
            .navigationDestination(for: String.self) { path in
                TaskStepContentView(
                    image: viewModel.image(at: path),
                    title: viewModel.titleForStep(at: path),
                    subtitle: viewModel.subtitleForNextStep(for: path),
                    isLastStep: viewModel.isLastStep(for: path),
                    onStepCompletion: { completion in
                        if completion == .discarded {
                            dismiss()
                        } else if completion == .saved {
                            moveToStep(afterPath: path)
                        } else {
                            onTaskCompletion?(completion)
                        }
                    },
                    content: {
                        viewModel.makeContentForNextStep(for: path)
                    }
                )
                .navigationTitle(viewModel.navigationTitleForNextStep(for: path))
            }
        }
    }
    
    private func moveToStep(afterPath path: String) {
        if let nextIdentifier = viewModel.identifier(afterPath: path) {
            viewModel.stepIdentifiers.append(nextIdentifier)
        }
    }
    
}
