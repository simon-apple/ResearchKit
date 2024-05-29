//
//  BooleanQuestion.swift
//  ORKVisionTestApp
//
//  Created by Jessi Aboukasm on 3/1/24.
//

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
        .padding()
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
