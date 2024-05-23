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
    var result: [MultipleChoiceOption]
    var selectionType: ChoiceSelectionType

    init(
        id: ID,
        title: String,
        choices: [MultipleChoiceOption],
        result: [MultipleChoiceOption] = [],
        selectionType: ChoiceSelectionType
    ) {
        self.title = title
        self.id = id
        self.choices = choices
        self.result = result
        self.selectionType = selectionType
    }

    public enum ChoiceSelectionType {
        case single, multiple
    }
}

public struct MultipleChoiceQuestionView: View {

    let title: String
    let choices: [MultipleChoiceOption]
    let selectionType: MultipleChoiceQuestion.ChoiceSelectionType

    @Binding
    var result: [MultipleChoiceOption]

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
                        isSelected: result.contains(where: { choice in
                            choice.id == option.id
                        })
                    ) {
                        choiceSelected(option)
                    }
                }
            }
            .padding()
        }
    }

    private func choiceSelected(_ option: MultipleChoiceOption) {
        if result.contains(where: { $0.id == option.id }) {
            result.removeAll { choice in
                choice.id == option.id
            }
        } else {
            switch selectionType {
            case .single:
                result = [option]
            case .multiple:
                result.append(option)
            }
        }
       }
}
