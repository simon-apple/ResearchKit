//
//  StepSectionHeaderView.swift
//  ResearchKitUI(Watch)
//
//  Created by Simon Tsai on 5/29/24.
//

import SwiftUI

struct StepSectionHeaderView: View {
    
    private let topPadding: CGFloat = 16
    private let bottomPadding: CGFloat = 24
    
    private let questionPadding: CGFloat = 4
    
    private let defaultHorizontalSpacing: CGFloat = 20
    
    @ObservedObject
    private var viewModel: FormStepViewModel
    
    private let formRow: FormRow
    
    init(viewModel: FormStepViewModel, formRow: FormRow) {
        self.viewModel = viewModel
        self.formRow = formRow
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Spacer()
                .frame(height: topPadding)
            
            if let questionNumber = viewModel.questionNumber(for: formRow) {
                Text("Question \(questionNumber) of \(viewModel.numberOfQuestions)")
                    .foregroundColor(.secondary)
                    .font(.footnote)
                    .fontWeight(.bold)
                
                Spacer()
                    .frame(height: questionPadding)
            }
            
            Text(title(for: formRow))
                .foregroundStyle(Color(.label))
                .font(.body)
                .fontWeight(.bold)
            
            Spacer()
                .frame(height: bottomPadding)
        }
        .listRowSeparatorSectionInsetStyle()
        .listRowInsets(
            EdgeInsets(
                top: 0,
                leading: defaultHorizontalSpacing,
                bottom: 0,
                trailing: defaultHorizontalSpacing
            )
        )
        
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
