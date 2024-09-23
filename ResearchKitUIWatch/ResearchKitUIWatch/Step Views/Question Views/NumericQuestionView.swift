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

import Foundation
import SwiftUI

@available(watchOS, unavailable)
public struct NumericQuestion: Identifiable {
    
    public let id: String
    public let title: String
    public let detail: String?
    public let prompt: String
    public let number: NSNumber?
    
    public init(
        id: String,
        title: String,
        detail: String?,
        prompt: String,
        number: NSNumber?
    ) {
        self.id = id
        self.title = title
        self.detail = detail
        self.prompt = prompt
        self.number = number
    }
    
}

@available(watchOS, unavailable)
public struct NumericQuestionView<Header: View>: View {

    @EnvironmentObject
    private var managedTaskResult: ResearchTaskResult

    enum FocusTarget {
        
        case numericQuestion
        
    }

    private let id: String
    private let header: Header
    private let prompt: String?
    @FocusState private var focusTarget: FocusTarget?
    private let result: StateManagementType<Double?>
    
    @Environment(\.questionRequired)
    private var isRequired: Bool

    private var resolvedResult: Binding<Double?> {
        switch result {
        case let .automatic(key: key):
            return Binding(
                get: { managedTaskResult.resultForStep(key: key) ?? nil },
                set: { managedTaskResult.setResultForStep(.numeric($0), key: key) }
            )
        case let .manual(value):
            return value
        }
    }

    public var body: some View {
        QuestionCard {
            Question(
                header: {
                    header
                },
                content: {
                    TextField("", value: resolvedResult, format: .number, prompt: placeholder)
#if !os(watchOS) && !os(macOS)
                        .keyboardType(.decimalPad)
                        .focused($focusTarget, equals: .numericQuestion)
#endif
                        .doneKeyboardToolbar(
                            condition: {
                                focusTarget == .numericQuestion
                            },
                            action: {
                                focusTarget = nil
                            }
                        )
                        .padding()
                }
            )
            .preference(key: QuestionRequiredPreferenceKey.self, value: isRequired)
            .preference(key: QuestionAnsweredPreferenceKey.self, value: isAnswered)
        }
    }
    
    private var placeholder: Text? {
        if let prompt {
            return Text(prompt)
        }

        return nil
    }
    
    private var isAnswered: Bool {
        resolvedResult.wrappedValue != nil
    }
}

@available(watchOS, unavailable)
public extension NumericQuestionView where Header == _SimpleFormItemViewHeader {
    
    init(
        id: String,
        text: Binding<Double?>,
        title: String,
        detail: String? = nil,
        prompt: String?
    ) {
        self.id = id
        header = _SimpleFormItemViewHeader(title: title)
        self.prompt = prompt
        self.result = .manual(text)
    }
    
    init(
        id: String,
        text: Decimal? = nil,
        title: String,
        detail: String? = nil,
        prompt: String?
    ) {
        self.id = id
        header = _SimpleFormItemViewHeader(title: title)
        self.prompt = prompt
        self.result = .automatic(key: .numeric(id: id))
    }
    
}

@available(watchOS, unavailable)
struct NumericQuestionView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.choice(for: .secondaryBackground)
                .ignoresSafeArea()

            ScrollView {
                NumericQuestionView(
                    id: UUID().uuidString,
                    text: .constant(22.0),
                    title: "How old are you?",
                    detail: nil,
                    prompt: "Tap to enter age"
                )
                .padding(.horizontal)
            }
        }

    }
}
