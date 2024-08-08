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

public struct ResearchTaskStepContentView<Content: View>: View {
    @State
    private var managedTaskResult: ResearchTaskResult = ResearchTaskResult()

    private let content: Content

    let isLastStep: Bool
    var onStepCompletion: ((ResearchTaskCompletion) -> Void)?

//    public init(
//        isLastStep: Bool,
//        onStepCompletion: ((ResearchTaskCompletion) -> Void)? = nil,
//        @ViewBuilder content: () -> Content
//    ) {
//        self.isLastStep = isLastStep
//        self.content = content()
//        self.onStepCompletion = onStepCompletion
//        self.onSubmit = nil
//    }

    public init(
        isLastStep: Bool,
        onStepCompletion: ((ResearchTaskCompletion) -> Void)? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.isLastStep = isLastStep
        self.onStepCompletion = onStepCompletion
        self.content = content()
    }

    public var body: some View {
        StickyScrollView {
            content
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
                .environment(managedTaskResult)
        } footerContent: {
            Button {
                if isLastStep {
                    onStepCompletion?(.completed(managedTaskResult))
                } else {
                    onStepCompletion?(.saved(managedTaskResult))
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
        .navigationBarTitleDisplayMode(.inline)
    }

    private var maxWidthForDoneButton: CGFloat {
#if os(iOS)
        .infinity
#elseif os(visionOS)
        300
#endif
    }

    // TODO: Is there a way to avoid exposing this if the dev isn't using managed results?
    public func onSurveyCompletion(_ perform: @escaping (ResearchTaskCompletion) -> Void) -> ResearchTaskStepContentView<Content> {
        return ResearchTaskStepContentView(
            isLastStep: self.isLastStep,
            onStepCompletion: perform,
            content: { content }
        )
    }

    // Alt version without the passing the managed result back to the dev
    public func onSurveyCompletion(_ perform: @escaping () -> Void) -> ResearchTaskStepContentView<Content> {
        return ResearchTaskStepContentView(
            isLastStep: self.isLastStep,
            onStepCompletion: { _ in perform() },
            content: { content }
        )
    }
}

public final class ResearchTaskResult: Observable {

    // You don't want this init to be public, b/c you son't want developers injecting it into your env
    init() {}

    // TODO: Is the "any" usage here inefficient when it comes to Observable diffing? Can we do better with an enum with cases for each result type?
    @Published
    private var stepResults: [String: Any] = [:]

    public func resultForStep<Result>(key: StepResultKey<Result>) -> Result {
        // TODO: Handle type mismatch and don't force cast
        return stepResults[key.id] as! Result
    }

    func setResultForStep<Result>(_ result: Result, key: StepResultKey<Result>) {
        stepResults[key.id] = result
    }
}

// TODO: If you'd like, skip this and just use Strings as keys. But this route eliminates the need for type casting.
// TODO: Explore using macros to type results automatically instead of relying on this
public struct StepResultKey<Result> {

    let id: String

    public static func text(id: String) -> StepResultKey<String> {
        return StepResultKey<String>(id: id)
    }
}


