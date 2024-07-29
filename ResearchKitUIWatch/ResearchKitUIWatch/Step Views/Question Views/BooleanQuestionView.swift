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

public struct BooleanQuestion: View { // TODO: Do we even need a Boolean type? is Multiple Choice good enough? Nice convenience for clients? 
    
    public var title: Text
    public var detail: Text

    public var yesAnswerText: Text
    public var noAnswerText: Text

    public init(
        title: Text,
        detail: Text,
        yesAnswerText: Text, // TODO: Look at ORKBooleanQuestionAnswerFormat to see naming convention for yes/no params
        noAnswerText: Text,
        resultBinding: Binding<Bool?> // TODO: Discuss whether to name result parameters "resultBinding" in initializers?
    ) {
        self.title = title
        self.detail = detail
        self.yesAnswerText = yesAnswerText
        self.noAnswerText = noAnswerText
        _result = resultBinding
    }

    @Binding
    private var result: Bool?

    public var body: some View {
        VStack(alignment: .leading) {
            title
                .font(.title)
            detail
            TextChoiceCell(title: yesAnswerText, isSelected: isSelected(for: true)) { }
            TextChoiceCell(title: noAnswerText, isSelected: isSelected(for: false)) { }
        }
    }

    func isSelected(for choice: Bool) -> Bool {
        guard let result = result else {
            return false
        }
        if result == choice {
            return true
        }
        return false
    }
}
