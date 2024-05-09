//
//  MultipleChoiceQuestion.swift
//  ResearchKitUI(Watch)
//
//  Created by Jessi Aboukasm on 3/5/24.
//

import SwiftUI

struct MultipleChoiceOption: Identifiable {
    var id: String
    var choiceText: String
}

struct MultipleChoiceQuestion: Identifiable {

    var title: String
    var id: String
    var choices: [MultipleChoiceOption]
    var result: MultipleChoiceOption?

    init(id: ID, title: String, choices: [MultipleChoiceOption], result: MultipleChoiceOption? = nil) {
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

    let detail: Text? = nil

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
