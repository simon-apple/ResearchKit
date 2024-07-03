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

public struct TaskStepContentView: View {
    @ObservedObject
    var viewModel: TaskViewModel

    let path: Int
    var onStepCompletion: ((TaskCompletion) -> Void)?

    var isLastStep: Bool {
        path == (viewModel.steps.count - 1)
    }

    public var body: some View {
        StickyScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if let title = viewModel.steps[path].title {
                    Text(title)
                        .font(.title)
                        .fontWeight(.bold)
                }

                if let subtitle = viewModel.steps[path].subtitle {
                    Text(subtitle)
                }

                ForEach($viewModel.steps[path].items) { $row in
                    FormRowContent(detail: nil, formRow: $row)
                }
            }
            .padding()
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        onStepCompletion?(.discarded)
                    } label: {
                        Text("Cancel")
                    }
                }
            }
        } footerContent: {
            Button {
                if isLastStep {
                    onStepCompletion?(.completed)
                } else {
                    viewModel.stepCount.append(path + 1)
                }
            } label: {
                Text(isLastStep ? "Done" : "Next")
                    .fontWeight(.bold)
                    .frame(maxWidth: maxWidthForDoneButton)
                    .padding(.vertical, 8)
            }
            .buttonStyle(.borderedProminent)
        }
        .background(Color(uiColor: .secondarySystemBackground))
        .navigationTitle("\(path + 1) of \(viewModel.steps.count)")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var maxWidthForDoneButton: CGFloat {
#if os(iOS)
        .infinity
#elseif os(visionOS)
        300
#endif
    }
}
