//
//  MultipleChoiceQuestion.swift
//  ResearchKitUI(Watch)
//
//  Created by Jessi Aboukasm on 3/5/24.
//

import SwiftUI

public struct MultipleChoiceOption: Identifiable {
    public var id: String
    public var choiceText: String
}

public struct MultipleChoiceQuestion: Identifiable {

    public var title: String
    public var id: String
    public var choices: [MultipleChoiceOption]
    public var result: MultipleChoiceOption?

    // TODO: Get rid of all my public things
    public init(id: ID, title: String, choices: [MultipleChoiceOption], result: MultipleChoiceOption? = nil) {
        self.title = title
        self.id = id
        self.choices = choices
        self.result = result
    }
}

public struct MultipleChoiceQuestionView: View {

    let title: String
    let choices: [MultipleChoiceOption]

    @Binding
    var result: MultipleChoiceOption?

    public let detail: Text? = nil

    public var body: some View {
        CardView {
            VStack(alignment: .leading) {
                Text(title)
                    .font(.title)
                detail
                ForEach(
                    choices
                ) { option in
                    TextChoiceCell(
                        title: Text(option.choiceText),
                       selected: result?.id == option.id
                   ) { choiceSelected in
                       if choiceSelected == true {
                           result = option
                       }
                   }
                }
            }
            .padding()
        }
    }
}
