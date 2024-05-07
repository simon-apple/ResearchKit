//
//  MultipleChoiceQuestion.swift
//  ResearchKitUI(Watch)
//
//  Created by Jessi Aboukasm on 3/5/24.
//

import SwiftUI

@Observable
public class MultipleChoiceOption<ID: Hashable>: Identifiable {

    public var id: ID
    public var choiceText: String

    public init(id: ID, choiceText: String) {
        self.id = id
        self.choiceText = choiceText
    }
}

@Observable
public class MultipleChoiceQuestion<ID: Hashable>: Identifiable {

    public var title: String
    public var id: ID
    public var choices: [MultipleChoiceOption<ID>]
    public var result: MultipleChoiceOption<ID>

    public init(id: ID, title: String, choices: [MultipleChoiceOption<ID>], result: MultipleChoiceOption<ID>) {
        self.title = title
        self.id = id
        self.choices = choices
        _result = result
    }
}

extension MultipleChoiceQuestion where ID == UUID {
    convenience init(title: String, choices: [MultipleChoiceOption<UUID>], result: MultipleChoiceOption<UUID>) {
        let id = UUID()
        self.init(id: id, title: title, choices: choices, result: result)
    }
}

extension MultipleChoiceOption where ID == UUID {

    public convenience init(choiceText: String) {
        let id = UUID()
        self.init(id: id, choiceText: choiceText)
    }
}

public struct MultipleChoiceQuestionView: View {

    @Binding
    public var result: MultipleChoiceOption<UUID>

    public let identifier: UUID = UUID()

    private var multipleChoiceQuestion: MultipleChoiceQuestion<UUID>

    private var detail: Text?

    public init(
        title: String,
        detail: Text? = nil,
        options: [MultipleChoiceOption<UUID>],
        result: Binding<MultipleChoiceOption<UUID>>
    ) {
        self.multipleChoiceQuestion = MultipleChoiceQuestion(id: identifier, title: title, choices: options, result: result.wrappedValue)
        _result = result
    }

    public var body: some View {
        CardView {
            VStack(alignment: .leading) {
                Text(multipleChoiceQuestion.title)
                    .font(.title)
                detail
                ForEach(
                    multipleChoiceQuestion.choices
                ) { option in
                    TextChoiceCell(
                        title: Text(option.choiceText),
                        selected: result.id == option.id
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
