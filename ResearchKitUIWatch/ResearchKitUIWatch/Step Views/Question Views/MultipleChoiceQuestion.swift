//
//  MultipleChoiceQuestion.swift
//  ResearchKitUI(Watch)
//
//  Created by Jessi Aboukasm on 3/5/24.
//

import SwiftUI

public struct MultipleChoiceOption<ID: Hashable>: Identifiable {
    public var id: ID
    public var title: Text // TODO: Does this count as a codable model object?

    public init(id: ID, title: Text) {
        self.id = id
        self.title = title
    }
}

public struct MultipleChoiceQuestion<OptionID: Hashable>: View {

    public var title: Text
    public var detail: Text
    public var options: [MultipleChoiceOption<OptionID>]

    @Binding
    public var result: MultipleChoiceOption<OptionID>

    public init(
        title: Text, // what does customizing this look like
        detail: Text,
        options: [MultipleChoiceOption<OptionID>],
        result: Binding<MultipleChoiceOption<OptionID>>
    ) {
        self.title = title
        self.detail = detail
        self.options = options
        _result = result
    }

    public init(
        title: String, // TODO: Think about the various initializers we could offer?
        detail: String,
        options: [MultipleChoiceOption<OptionID>],
        result: Binding<MultipleChoiceOption<OptionID>>
    ) {
        self.title = Text(title)
        self.detail = Text(detail)
        self.options = options
        _result = result
    }

    /*
     QuestionCard(Title, Detail):
     - Header(Title Detail)

     */

    public var body: some View {

//        QuestionCard {
//
//        }
//        Header(title, detail)
        title
            .font(.title)
        detail

        VStack {
            ForEach(options) { option in
                TextChoiceCell(title: option.title, selected: result.id == option.id) { choiceSelected in
                    if choiceSelected == true {
                        result = option
                    }
                }
            }
        }
    }
}
