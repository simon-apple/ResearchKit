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

public struct NumericQuestionView<Header: View>: View {
    
    @Binding var text: String
    private let header: Header
    private let prompt: String?
    @FocusState private var isInputActive: Bool
    
    public var body: some View {
        TaskCardView(
            header: {
                header
            },
            content: {
                TextField("", text: $text, prompt: placeholder)
                    .keyboardType(.decimalPad)
                    .focused($isInputActive)
#if os(iOS)
                    .toolbar {
                        ToolbarItemGroup(placement: .keyboard) {
                            Spacer()
                            
                            Button("Done") {
                                isInputActive = false
                            }
                        }
                    }
#endif
            }
        )
    }
    
    private var placeholder: Text? {
        if let prompt {
            return Text(prompt)
        }

        return nil
    }
    
}

public extension NumericQuestionView where Header == _SimpleTaskViewHeader {
    
    init(
        text: Binding<String>,
        title: String,
        detail: String?,
        prompt: String?
    ) {
        self._text = text
        header = _SimpleTaskViewHeader(title: title, detail: detail)
        self.prompt = prompt
    }
    
}
