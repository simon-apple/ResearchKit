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
    
    enum FocusTarget {
        
        case textQuestion
        
    }
    
    private let stateManagementType: StateManagementType<String>
    
    @State
    private var managedResult: String?
    
    private var resolvedManagedResult: Binding<String> {
        Binding(
            get: { managedResult ?? "" },
            set: { managedResult = $0 }
        )
    }
    
    private var selection: Binding<String> {
        let selection: Binding<String>
        switch stateManagementType {
        case .automatic:
            selection = resolvedManagedResult
        case .manual(let binding):
            selection = binding
        }
        return selection
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

    init(
        id: String,
        @ViewBuilder header: () -> Header,
        text: String? = nil,
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
        self.managedResult = text
        self.stateManagementType = .automatic
    }
    
    init(
        id: String,
        @ViewBuilder header: () -> Header,
        text: Binding<String>,
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
        self.stateManagementType = .manual(text)
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
                TextField("", text: selection, prompt: placeholder, axis: axis)
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
                            Text("\(selection.wrappedValue.count)/\(characterLimit)")
                        }
                        Spacer()

                        if !hideClearButton {
                            Button {
                                selection.wrappedValue = ""
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
                    .onChange(of: selection.wrappedValue) { oldValue, newValue in
                        if selection.wrappedValue.count > characterLimit {
                            selection.wrappedValue = oldValue
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
        text: String? = nil,
        title: String,
        detail: String? = nil,
        prompt: String?,
        textFieldType: TextFieldType,
        characterLimit: Int,
        hideCharacterCountLabel: Bool = false,
        hideClearButton: Bool = false
    ) {
        self.id = id
        self.header = _SimpleFormItemViewHeader(title: title, detail: detail)
        self.prompt = prompt
        self.textFieldType = textFieldType
        self.characterLimit = characterLimit
        self.hideCharacterCountLabel = hideCharacterCountLabel
        self.hideClearButton = hideClearButton
        self.managedResult = text
        self.stateManagementType = .automatic
    }
    
    init(
        id: String,
        text: Binding<String>,
        title: String,
        detail: String? = nil,
        prompt: String?,
        textFieldType: TextFieldType,
        characterLimit: Int,
        hideCharacterCountLabel: Bool = false,
        hideClearButton: Bool = false
    ) {
        self.id = id
        self.header = _SimpleFormItemViewHeader(title: title, detail: detail)
        self.prompt = prompt
        self.textFieldType = textFieldType
        self.characterLimit = characterLimit
        self.hideCharacterCountLabel = hideCharacterCountLabel
        self.hideClearButton = hideClearButton
        self.stateManagementType = .manual(text)
    }
    
}

struct TextQuestionView_Previews: PreviewProvider {
    static var previews: some View {
        TextQuestionView(
            id: UUID().uuidString,
            text: .constant("Hello world!"),
            title: "What is your name?",
            detail: nil,
            prompt: "Tap to write",
            textFieldType: .multiline,
            characterLimit: 10,
            hideCharacterCountLabel: true
        )
    }
}
