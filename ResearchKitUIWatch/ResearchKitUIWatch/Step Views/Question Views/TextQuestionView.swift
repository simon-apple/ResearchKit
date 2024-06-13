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
import ResearchKit
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

    public init(
        title: String,
        id: String,
        text: String,
        prompt: String,
        textFieldType: TextFieldType,
        characterLimit: Int
    ) {
        self.title = title
        self.id = id
        self.text = text
        self.prompt = prompt
        self.textFieldType = textFieldType
        self.characterLimit = characterLimit
    }
}

public struct TextQuestionView: View {
    @FocusState var isInputActive: Bool
    @Binding var text: String
    let title: Text?
    let detail: Text?
    let prompt: String?
    let textFieldType: TextFieldType
    let characterLimit: Int

    public init(
        text: Binding<String>,
        title: Text?,
        detail: Text?,
        prompt: String?,
        textFieldType: TextFieldType,
        characterLimit: Int
    ) {
        self._text = text
        self.title = title
        self.detail = detail
        self.prompt = prompt
        self.textFieldType = textFieldType
        self.characterLimit = characterLimit
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
        TaskCardView(title: title, detail: detail) {
            VStack {
                TextField("", text: $text, prompt: placeholder, axis: axis)
                    .padding(.bottom, axis == .vertical ? 54 : .zero)
                    .contentShape(Rectangle())

                HStack {
                    Text("\(text.count)/\(characterLimit)")
                    Spacer()
                    Button {
                        text = ""
                    } label: {
                        Text("Clear")
                    }
                }
                .toolbar {
                    ToolbarItemGroup(placement: .keyboard) {
                        Spacer()
                        Button("Done") {
                            isInputActive = false
                        }
                    }
                }
                .onChange(of: text) { oldValue, newValue in
                    if text.count > characterLimit {
                        text = oldValue
                    }
                }
            }
        }
    }
}

struct TextQuestionView_Previews: PreviewProvider {
    static var previews: some View {
        TextQuestionView(
            text: .constant("Hello world!"),
            title: Text("What is your name?"),
            detail: nil,
            prompt: "Tap to write",
            textFieldType: .multiline,
            characterLimit: 10
        )
    }
}
