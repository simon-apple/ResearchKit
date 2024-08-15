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

public enum TextFieldType {
    case singleLine, multiline
}

public struct TextQuestion: Identifiable {
    public var title: String
    public var id: String
    public var text: String
    public var prompt: String
    public var textFieldType: TextFieldType
    public var characterLimit: Int
    public var hideCharacterCountLabel: Bool
    public var hideClearButton: Bool

    public init(
        title: String,
        id: String,
        text: String,
        prompt: String,
        textFieldType: TextFieldType,
        characterLimit: Int,
        hideCharacterCountLabel: Bool,
        hideClearButton: Bool
    ) {
        self.title = title
        self.id = id
        self.text = text
        self.prompt = prompt
        self.textFieldType = textFieldType
        self.characterLimit = characterLimit
        self.hideCharacterCountLabel = hideCharacterCountLabel
        self.hideClearButton = hideClearButton
    }
}

public struct TextQuestionView<Header: View>: View {
    @EnvironmentObject
    private var managedTaskResult: ResearchTaskResult

    enum FocusTarget {
        
        case textQuestion
        
    }
    
    let id: String
    let header: Header
    let multilineTextFieldPadding: Double = 54
    @FocusState private var focusTarget: FocusTarget?
    let prompt: String?
    let textFieldType: TextFieldType
    let characterLimit: Int
    let hideCharacterCountLabel: Bool
    let hideClearButton: Bool
    let result: StateManagementType<String>

    private var resolvedResult: Binding<String> {
        switch result {
        case let .automatic(key: key):
            return Binding(
                get: { managedTaskResult.resultForStep(key: key) ?? ""},
                set: { managedTaskResult.setResultForStep(.text($0), key: key) }
            )
        case let .manual(value):
            return value
        }
    }

    public init(
        id: String,
        @ViewBuilder header: () -> Header,
        prompt: String?,
        textFieldType: TextFieldType,
        characterLimit: Int,
        hideCharacterCountLabel: Bool = false,
        hideClearButton: Bool = false,
        result: Binding<String>
    ) {
        self.id = id
        self.header = header()
        self.prompt = prompt
        self.textFieldType = textFieldType
        self.characterLimit = characterLimit
        self.hideCharacterCountLabel = hideCharacterCountLabel
        self.hideClearButton = hideClearButton
        self.result = .manual(result)
    }

    public init(
        id: String,
        @ViewBuilder header: () -> Header,
        prompt: String?,
        textFieldType: TextFieldType,
        characterLimit: Int,
        hideCharacterCountLabel: Bool = false,
        hideClearButton: Bool = false
    ) {
        self.id = id
        self.header = header()
        self.prompt = prompt
        self.textFieldType = textFieldType
        self.characterLimit = characterLimit > 0 ? characterLimit : .max
        self.hideCharacterCountLabel = hideCharacterCountLabel
        self.hideClearButton = hideClearButton
        self.result = .automatic(key: .text(id: id))
    }

    private var axis: Axis {
        switch textFieldType {
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
        FormItemCardView {
            header
        } content: {
            VStack {
                TextField("", text: resolvedResult, prompt: placeholder, axis: axis)
                    .textFieldStyle(.plain) // Text binding's `didSet` called twice if this is not set.
                    .focused($focusTarget, equals: .textQuestion)
                    .padding(.bottom, axis == .vertical ? multilineTextFieldPadding : .zero)
                    .contentShape(Rectangle())
                    .onAppear(perform: {
                        if textFieldType == .singleLine {
                            UITextField.appearance().clearButtonMode = .whileEditing
                        }
                    })

                if textFieldType == .multiline {
                    HStack {
                        if hideCharacterCountLabel == false {
                            Text("\(resolvedResult.wrappedValue.count)/\(characterLimit)")
                        }
                        Spacer()

                        if !hideClearButton {
                            Button {
                                resolvedResult.wrappedValue = ""
                            } label: {
                                Text("Clear")
                            }
                        }
                    }
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
                    .onChange(of: resolvedResult.wrappedValue) { oldValue, newValue in
                        if resolvedResult.wrappedValue.count > characterLimit {
                            resolvedResult.wrappedValue = oldValue
                        }
                    }
                }
            }
            .padding()
        }
    }
}

public extension TextQuestionView where Header == _SimpleFormItemViewHeader {
    init(
        id: String,
        title: String,
        detail: String?,
        prompt: String?,
        textFieldType: TextFieldType,
        characterLimit: Int,
        hideCharacterCountLabel: Bool = false,
        hideClearButton: Bool = false,
        result: Binding<String>
    ) {
        self.id = id
        self.header = _SimpleFormItemViewHeader(title: title, detail: detail)
        self.prompt = prompt
        self.textFieldType = textFieldType
        self.characterLimit = characterLimit
        self.hideCharacterCountLabel = hideCharacterCountLabel
        self.hideClearButton = hideClearButton
        self.result = .manual(result)
    }

    init(
        id: String,
        title: String,
        detail: String? = nil,
        prompt: String?,
        textFieldType: TextFieldType,
        characterLimit: Int,
        hideCharacterCountLabel: Bool = false,
        hideClearButton: Bool = false,
        defaultTextAnswer: String? = nil
    ) {
        self.id = id
        self.header = _SimpleFormItemViewHeader(title: title, detail: detail)
        self.prompt = prompt
        self.textFieldType = textFieldType
        self.characterLimit = characterLimit
        self.hideCharacterCountLabel = hideCharacterCountLabel
        self.hideClearButton = hideClearButton
        self.result = .automatic(key: .text(id: id))

        if let defaultTextAnswer {
            self.resolvedResult.wrappedValue = defaultTextAnswer
        }
    }
    
}

struct TextQuestionView_Previews: PreviewProvider {
    static var previews: some View {
        TextQuestionView(
            id: UUID().uuidString,
            title: "What is your name?",
            detail: nil,
            prompt: "Tap to write",
            textFieldType: .multiline,
            characterLimit: 10,
            hideCharacterCountLabel: true,
            result: .constant("Tom Riddle")
        )
    }
}
