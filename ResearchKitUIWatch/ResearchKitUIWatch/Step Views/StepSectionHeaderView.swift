//
//  StepSectionHeaderView.swift
//  ResearchKitUI(Watch)
//
//  Created by Simon Tsai on 5/29/24.
//

import SwiftUI

struct StepSectionHeaderView: View {
    
    @ObservedObject
    private var viewModel: FormStepViewModel
    
    private let formRow: FormRow
    
    init(viewModel: FormStepViewModel, formRow: FormRow) {
        self.viewModel = viewModel
        self.formRow = formRow
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            if let questionNumber = viewModel.questionNumber(for: formRow) {
                Text("Question \(questionNumber) of \(viewModel.numberOfQuestions)")
                    .foregroundColor(.secondary)
                    .font(.footnote)
                    .fontWeight(.bold)
            }
            
            Text(title(for: formRow))
        }
        .listRowSeparatorSectionInsetStyle()
    }
    
    private func title(for formRow: FormRow) -> String {
        let title: String
        switch formRow {
        case .multipleChoiceRow(let multipleChoiceValue):
            title = multipleChoiceValue.title
        case .scale(let scaleSliderQuestion):
            title = scaleSliderQuestion.title
        }
        return title
    }
    
}
