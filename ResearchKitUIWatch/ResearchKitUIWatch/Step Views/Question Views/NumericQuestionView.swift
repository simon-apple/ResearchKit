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
    
    enum FocusTarget {
        
        case numericQuestion
        
    }
    
    private let stateManagementType: StateManagementType<Decimal?>
    
    @State
    private var managedResult: Decimal?
    
    private var resolvedManagedResult: Binding<Decimal?> {
        Binding(
            get: { managedResult },
            set: { managedResult = $0 }
        )
    }
    
    private var selection: Binding<Decimal?> {
        let selection: Binding<Decimal?>
        switch stateManagementType {
        case .automatic:
            selection = resolvedManagedResult
        case .manual(let binding):
            selection = binding
        }
        return selection
    }
    
    private let id: String
    private let header: Header
    private let prompt: String?
    @FocusState private var focusTarget: FocusTarget?
    
    public var body: some View {
        FormItemCardView(
            header: {
                header
            },
            content: {
                TextField("", value: selection, format: .number, prompt: placeholder)
                    .keyboardType(.decimalPad)
                    .focused($focusTarget, equals: .numericQuestion)
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
    }
    
    private var placeholder: Text? {
        if let prompt {
            return Text(prompt)
        }

        return nil
    }
    
}

public extension NumericQuestionView where Header == _SimpleFormItemViewHeader {
    
    init(
        id: String,
        text: Binding<Decimal?>,
        title: String,
        detail: String? = nil,
        prompt: String?
    ) {
        self.id = id
        header = _SimpleFormItemViewHeader(title: title, detail: detail)
        self.prompt = prompt
        self.stateManagementType = .manual(text)
    }
    
    init(
        id: String,
        text: Decimal? = nil,
        title: String,
        detail: String? = nil,
        prompt: String?
    ) {
        self.id = id
        header = _SimpleFormItemViewHeader(title: title, detail: detail)
        self.prompt = prompt
        self.managedResult = text
        self.stateManagementType = .automatic
    }
    
}

struct NumericQuestionView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color(uiColor: .secondarySystemBackground)
                .ignoresSafeArea()

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
