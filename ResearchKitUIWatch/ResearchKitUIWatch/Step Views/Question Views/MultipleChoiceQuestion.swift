//
//  MultipleChoiceQuestion.swift
//  ResearchKitUI(Watch)
//
//  Created by Jessi Aboukasm on 3/5/24.
//

import SwiftUI

public class MultipleChoiceOption<ID: Hashable>: Identifiable {

    public var id: ID
    public var choiceText: String

    public init(id: ID, choiceText: String) {
        self.id = id
        self.choiceText = choiceText
    }
}

@Observable
public class MultipleChoiceQuestion<ID: Hashable>: Identifiable, Hashable {

    public static func == (lhs: MultipleChoiceQuestion<ID>, rhs: MultipleChoiceQuestion<ID>) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(title)
        hasher.combine(id)
        hasher.combine(selectedIndex)
    }

    public var title: String
    public var id: ID
    public var choices: [MultipleChoiceOption<ID>]
    public var selectedIndex: Int = -1


    public init(id: ID, title: String, choices: [MultipleChoiceOption<ID>], selectedIndex: Int = -1) {
        self.title = title
        self.id = id
        self.choices = choices
        self.selectedIndex = selectedIndex
    }
}

extension MultipleChoiceQuestion where ID == UUID {
    convenience init(title: String, choices: [MultipleChoiceOption<UUID>]) {
        let id = UUID()
        self.init(id: id, title: title, choices: choices)
    }
}

extension MultipleChoiceOption where ID == UUID {

    public convenience init(choiceText: String) {
        let id = UUID()
        self.init(id: id, choiceText: choiceText)
    }
}

public struct MultipleChoiceQuestionView: View {

    let title: String

    let choices: [MultipleChoiceOption<UUID>]

    @Binding
    var selectedIndex: Int

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
                        selected: {
                            guard choices.indices.contains(selectedIndex) else {
                                return false
                            }
                            return choices[selectedIndex].id == option.id
                        }()
                    ) { choiceSelected in
                        if choiceSelected == true {
                            selectedIndex = choices.firstIndex(where: { $0.id == option.id })!
                        } else {
                            // This would allow un-selection, which RK doesn't really have??
                            selectedIndex = -1
                        }
                    }
                }
            }
            .padding()
        }
    }
}
