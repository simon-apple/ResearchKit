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

/// Represents the number of lines a text question can contain.
public enum TextQuestionType {
    
    /// A single line text question.
    case singleLine
    
    /// A multiline text question.
    case multiline
}

/// A question that allows for text input.
public struct TextQuestion<Header: View>: View {
    
    @EnvironmentObject
    private var managedFormResult: ResearchFormResult

    @Environment(\.questionRequired)
    private var isRequired: Bool
        
    enum FocusTarget {
        case textQuestion
    }
    
    let id: String
    let header: Header
    let multilineTextFieldPadding: Double = 54
    @FocusState private var focusTarget: FocusTarget?
    let prompt: String?
    let textQuestionType: TextQuestionType
    let characterLimit: Int
    let hideCharacterCountLabel: Bool
    let hideClearButton: Bool
    let result: StateManagementType<String?>

    private var resolvedResult: Binding<String?> {
        switch result {
        case let .automatic(key: key):
            return Binding(
                get: { managedFormResult.resultForStep(key: key) ?? nil },
                set: { managedFormResult.setResultForStep(.text($0), key: key) }
            )
        case let .manual(value):
            return value
        }
    }
    
    /// Initializes an instance of ``TextQuestion`` with the provided configuration.
    /// - Parameters:
    ///   - id: The unique identifier for this question.
    ///   - header: The header for this question.
    ///   - prompt: The placeholder for this question.
    ///   - textQuestionType: Specifies whether this text question is single line or multiline.
    ///   - characterLimit: The number of characters that can be used for this question.
    ///   - hideCharacterCountLabel: Whether or not the character count is displayed.
    ///   - hideClearButton: Whether or not the clear button is displayed.
    ///   - result: The binding for the text result.
    public init(
        id: String,
        @ViewBuilder header: () -> Header,
        prompt: String?,
        textQuestionType: TextQuestionType,
        characterLimit: Int,
        hideCharacterCountLabel: Bool = false,
        hideClearButton: Bool = false,
        result: Binding<String?>
    ) {
        self.id = id
        self.header = header()
        self.prompt = prompt
        self.textQuestionType = textQuestionType
        self.characterLimit = characterLimit
        self.hideCharacterCountLabel = hideCharacterCountLabel
        self.hideClearButton = hideClearButton
        self.result = .manual(result)
    }

    /// Initializes an instance of ``TextQuestion`` with the provided configuration.
    /// - Parameters:
    ///   - id: The unique identifier for this question.
    ///   - header: The header for this question.
    ///   - prompt: The placeholder for this question.
    ///   - textQuestionType: Specifies whether this text question is single line or multiline.
    ///   - characterLimit: The number of characters that can be used for this text question.
    ///   - hideCharacterCountLabel: Whether or not the character count is displayed.
    ///   - hideClearButton: Whether or not the clear button is displayed.
    public init(
        id: String,
        @ViewBuilder header: () -> Header,
        prompt: String?,
        textQuestionType: TextQuestionType,
        characterLimit: Int,
        hideCharacterCountLabel: Bool = false,
        hideClearButton: Bool = false
    ) {
        self.id = id
        self.header = header()
        self.prompt = prompt
        self.textQuestionType = textQuestionType
        self.characterLimit = characterLimit > 0 ? characterLimit : .max
        self.hideCharacterCountLabel = hideCharacterCountLabel
        self.hideClearButton = hideClearButton
        self.result = .automatic(key: .text(id: id))
    }

    private var axis: Axis {
        switch textQuestionType {
        case .singleLine:
            return .horizontal
        case .multiline:
            return .vertical
        }
    }

    private var placeholder: Text? {
        if let prompt {
            return Text(prompt)
        }

        return nil
    }

    public var body: some View {
        QuestionCard {
            Question {
                header
            } content: {
                VStack {
                    TextField(id, text: resolvedResult.unwrapped(defaultValue: ""), prompt: placeholder, axis: axis)
                        .textFieldStyle(.plain) // Text binding's `didSet` called twice if this is not set.
                        .focused($focusTarget, equals: .textQuestion)
                        .padding(.bottom, axis == .vertical ? multilineTextFieldPadding : .zero)
                        .contentShape(Rectangle())
                        .onAppear(perform: {
#if !os(watchOS)
                            if textQuestionType == .singleLine {
                                UITextField.appearance().clearButtonMode = .whileEditing
                            }
#endif
                        })
                    
                    if textQuestionType == .multiline {
                        HStack {
                            if hideCharacterCountLabel == false {
                                Text("\(resolvedResult.wrappedValue?.count ?? 0)/\(characterLimit)")
                            }
                            Spacer()
                            
                            if !hideClearButton {
                                Button {
                                    resolvedResult.wrappedValue = .none
                                } label: {
                                    Text("Clear")
                                }
                            }
                        }
                        .onChange(of: resolvedResult.wrappedValue) { oldValue, newValue in
                            if resolvedResult.wrappedValue?.count ?? 0 > characterLimit {
                                resolvedResult.wrappedValue = oldValue
                            }
                        }
                    }
                }
                .padding()
    #if os(iOS)
                .doneKeyboardToolbar(
                    condition: {
                        focusTarget == .textQuestion
                    },
                    action: {
                        focusTarget = nil
                    }
                )
    #endif
            }
            .preference(key: QuestionRequiredPreferenceKey.self, value: isRequired)
            .preference(key: QuestionAnsweredPreferenceKey.self, value: isAnswered)
        }
    }
    
    private var isAnswered: Bool {
        if let result = resolvedResult.wrappedValue {
            return !result.isEmpty
        }
        return false
    }
}

public extension TextQuestion where Header == _SimpleFormItemViewHeader {
    
    /// Initializes an instance of ``TextQuestion`` with the provided configuration.
    /// - Parameters:
    ///   - id: The unique identifier for this question.
    ///   - title: The title for this question.
    ///   - detail: The details for this question.
    ///   - prompt: The placeholder for this question.
    ///   - textQuestionType: Specifies whether this text question is single line or multiline.
    ///   - characterLimit: The number of characters that can be used for this text question.
    ///   - hideCharacterCountLabel: Whether or not the character count is displayed.
    ///   - hideClearButton: Whether or not the clear button is displayed.
    ///   - result: The binding for the text result.
    init(
        id: String,
        title: String,
        detail: String?,
        prompt: String?,
        textQuestionType: TextQuestionType,
        characterLimit: Int,
        hideCharacterCountLabel: Bool = false,
        hideClearButton: Bool = false,
        result: Binding<String?>
    ) {
        self.id = id
        self.header = _SimpleFormItemViewHeader(title: title)
        self.prompt = prompt
        self.textQuestionType = textQuestionType
        self.characterLimit = characterLimit
        self.hideCharacterCountLabel = hideCharacterCountLabel
        self.hideClearButton = hideClearButton
        self.result = .manual(result)
    }

    /// Initializes an instance of ``TextQuestion`` with the provided configuration.
    /// - Parameters:
    ///   - id: The unique identifier for this text question.
    ///   - title: The title for this text question.
    ///   - detail: The details for this text question.
    ///   - prompt: The placeholder for this text question.
    ///   - textQuestionType: Specifies whether this text question is single line or multiline.
    ///   - characterLimit: The number of characters that can be used for this text question.
    ///   - hideCharacterCountLabel: Whether or not the character count is displayed.
    ///   - hideClearButton: Whether or not the clear button is displayed.
    ///   - defaultTextAnswer: The initial text to display.
    init(
        id: String,
        title: String,
        detail: String? = nil,
        prompt: String?,
        textQuestionType: TextQuestionType,
        characterLimit: Int,
        hideCharacterCountLabel: Bool = false,
        hideClearButton: Bool = false,
        defaultTextAnswer: String? = nil
    ) {
        self.id = id
        self.header = _SimpleFormItemViewHeader(title: title)
        self.prompt = prompt
        self.textQuestionType = textQuestionType
        self.characterLimit = characterLimit
        self.hideCharacterCountLabel = hideCharacterCountLabel
        self.hideClearButton = hideClearButton
        self.result = .automatic(key: StepResultKey(id: id))

        if let defaultTextAnswer {
            self.resolvedResult.wrappedValue = defaultTextAnswer
        }
    }
}

#Preview {
    @Previewable @State var value: String? = "Tom Riddle"
    ScrollView {
        TextQuestion(
            id: UUID().uuidString,
            title: "What is your name?",
            detail: nil,
            prompt: "Tap to write",
            textQuestionType: .singleLine,
            characterLimit: 10,
            hideCharacterCountLabel: true,
            result: $value
        )
    }
}

