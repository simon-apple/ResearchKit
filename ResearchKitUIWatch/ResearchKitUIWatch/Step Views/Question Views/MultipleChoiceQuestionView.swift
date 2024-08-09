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

// TODO(rdar://129033515): Update name of this module to reflect just the choice options without the header.
public struct MultipleChoiceQuestionView: View {

    let id: String
    let title: String
    let choices: [MultipleChoiceOption]
    let selectionType: MultipleChoiceQuestion.ChoiceSelectionType

    @Binding
    var result: [MultipleChoiceOption]

    let detail: String?

    // TODO(rdar://129033515): Remove title parameter from initializer since the body reflects just the options.
    public init(
        id: String,
        title: String,
        detail: String? = nil,
        choices: [MultipleChoiceOption],
        selectionType: MultipleChoiceQuestion.ChoiceSelectionType,
        result: Binding<[MultipleChoiceOption]>
    ) {
        self.id = id
        self.title = title
        self.detail = detail
        self.choices = choices
        self.selectionType = selectionType
        _result = result
    }

    public var body: some View {
        FormItemCardView(title: title, detail: detail) {
            ForEach(Array(choices.enumerated()), id: \.offset) { index, option in
                VStack(spacing: .zero) {
                    if index != 0 {
                        Divider()
                    }

                    TextChoiceCell(
                        title: Text(option.choiceText),
                        isSelected: result.contains(where: { choice in
                            choice.id == option.id
                        })
                    ) {
                        choiceSelected(option)
                    }
                    .padding(.horizontal, 8)
#if !os(watchOS)
                    .contentShape(.hoverEffect, RoundedRectangle(cornerRadius: 12))
                    .hoverEffect()
#endif
                    .padding(.horizontal, -8)
                }
            }
        }
    }

    private func choiceSelected(_ option: MultipleChoiceOption) {
        if result.contains(where: { $0.id == option.id }) {
            result.removeAll { choice in
                choice.id == option.id
            }
        } else {
            switch selectionType {
            case .single:
                result = [option]
            case .multiple:
                result.append(option)
            }
        }
    }
}

struct MultipleChoiceQuestionView_Previews: PreviewProvider {

    static var previews: some View {
        ZStack {
            Color.choice(for: .secondaryBackground)
                .ignoresSafeArea()

            MultipleChoiceQuestionView(
                id: UUID().uuidString,
                title: "Which do you prefer?",
                choices: [
                    MultipleChoiceOption(id: "a", choiceText: "Option A"),
                    MultipleChoiceOption(id: "b", choiceText: "Option B"),
                    MultipleChoiceOption(id: "c", choiceText: "Option C")
            ],
                selectionType: .multiple,
                result: .constant([MultipleChoiceOption(id: "a", choiceText: "Option A")])
            )
            .padding(.horizontal)
        }

    }
}

public struct InputManagedMultipleChoiceQuestion: View {
    
    private let id: String
    private let title: String
    private let detail: String?
    private let choices: [MultipleChoiceOption]
    @State private var selectedChoices: [MultipleChoiceOption] = []
    private let selectionType: MultipleChoiceQuestion.ChoiceSelectionType
    
    public init(
        id: String,
        title: String,
        detail: String? = nil,
        choices: [MultipleChoiceOption],
        selectedChoices: [MultipleChoiceOption],
        selectionType: MultipleChoiceQuestion.ChoiceSelectionType
    ) {
        self.id = id
        self.title = title
        self.detail = detail
        self.choices = choices
        self.selectedChoices = selectedChoices
        self.selectionType = selectionType
    }
    
    public var body: some View {
        MultipleChoiceQuestionView(
            id: id,
            title: title,
            detail: detail,
            choices: choices,
            selectionType: selectionType,
            result: $selectedChoices
        )
    }
    
}
