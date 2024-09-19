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

public struct ResearchForm<Content: View>: View {
    @State
    private var managedTaskResult: ResearchTaskResult

    private let taskKey: StepResultKey<String?>
    private let steps: Content
    
    var onResearchFormCompletion: ((ResearchTaskCompletion) -> Void)?
    
    public init(
        taskIdentifier: String,
        restorationResult: ResearchTaskResult? = nil,
        @ViewBuilder steps: () -> Content,
        onResearchFormCompletion: ((ResearchTaskCompletion) -> Void)? = nil
    ) {
        self.taskKey = .text(id: taskIdentifier)
        self.steps = steps()
        self.onResearchFormCompletion = onResearchFormCompletion
        self.managedTaskResult = restorationResult ?? ResearchTaskResult()
    }
    
    public var body: some View {
        Group(subviews: steps) { steps in
            NavigationalLayout(steps, onResearchFormCompletion: onResearchFormCompletion)
        }
        .environmentObject(managedTaskResult)
    }
    
}

public struct ResearchFormStep<Header: View, Content: View>: View {
    
    private let header: Header
    private let content: Content
    
    public init(
        @ViewBuilder header: () -> Header,
        @ViewBuilder content: () -> Content
    ) {
        self.header = header()
        self.content = content()
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            header
            
            Group(subviews: content) { questions in
                ForEach(subviews: questions) { question in
                    if let questionIndex = questions.firstIndex(where: { $0.id == question.id }) {
                        let questionNumber = questionIndex + 1
                        QuestionCardView {
                            VStack(alignment: .leading, spacing: 0) {
                                Text("Question \(questionNumber) of \(questions.count)")
                                    .foregroundColor(.secondary)
                                    .font(.footnote)
#if os(watchOS)
                                    .padding([.horizontal])
                                    .padding(.top, 4)
#else
                                    .fontWeight(.bold)
                                    .padding([.horizontal, .top])
#endif
                                
                                question
                            }
                        }
                    } else {
                        question
                    }
                }
            }
        }
#if os(iOS)
        .frame(maxWidth: .infinity, alignment: .leading)
#endif
    }
    
}

public extension ResearchFormStep where Header == EmptyView {
    
    init(@ViewBuilder content: () -> Content) {
        self.init(
            header: {
                EmptyView()
            },
            content: content
        )
    }
    
}

public extension ResearchFormStep where Header == StepHeaderView, Content == EmptyView {
    
    init(
        image: Image? = nil,
        title: String? = nil,
        subtitle: String? = nil
    ) {
        self.init(
            image: image,
            title: title,
            subtitle: subtitle,
            content: {
                EmptyView()
            }
        )
    }
    
}

public extension ResearchFormStep where Header == StepHeaderView {
    
    init(
        image: Image? = nil,
        title: String? = nil,
        subtitle: String? = nil,
        @ViewBuilder content: () -> Content
    ) {
        let titleText: Text?
        if let title, !title.isEmpty {
            titleText = Text(title)
        } else {
            titleText = nil
        }
        
        let subtitleText: Text?
        if let subtitle, !subtitle.isEmpty {
            subtitleText = Text(subtitle)
        } else {
            subtitleText = nil
        }
        
        self.init(
            header: {
                StepHeaderView(
                    image: image,
                    title: titleText,
                    subtitle: subtitleText
                )
            },
            content: content
        )
    }
    
}

struct ResearchFormStepContent<Content: View>: View {
    
    private let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
    }
    
}
