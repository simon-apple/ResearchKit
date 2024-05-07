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

public struct MultipleChoiceQuestion<ID: Hashable>: Identifiable, Hashable {
    
    public static func == (lhs: MultipleChoiceQuestion<ID>, rhs: MultipleChoiceQuestion<ID>) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(title)
        hasher.combine(id)
    }

    public var title: String
    public var id: ID
    public var choices: [MultipleChoiceOption<ID>]
    public var result: MultipleChoiceOption<ID>

    public init(id: ID, title: String, choices: [MultipleChoiceOption<ID>], result: MultipleChoiceOption<ID>) {
        self.title = title
        self.id = id
        self.choices = choices
        self.result = result
    }
}

extension MultipleChoiceQuestion where ID == UUID {
    init(title: String, choices: [MultipleChoiceOption<UUID>], result: MultipleChoiceOption<UUID>) {
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

    public var multipleChoiceQuestion: MultipleChoiceQuestion<UUID>

    public var detail: Text?

//    public init(
//        title: String,
//        detail: Text? = nil,
//        options: [MultipleChoiceOption<UUID>],
//        result: Binding<MultipleChoiceOption<UUID>>
//    ) {
//        self.multipleChoiceQuestion = MultipleChoiceQuestion(id: identifier, title: title, choices: options, result: result.wrappedValue)
//    }

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
