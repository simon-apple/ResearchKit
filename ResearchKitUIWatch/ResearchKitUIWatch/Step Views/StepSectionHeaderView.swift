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
            if let progress = viewModel.progress {
                Text("Question \(progress.index) of \(progress.count)")
                    .foregroundColor(.gray)
                    .font(.subheadline)
            }
            
            if case .multipleChoiceRow(let multipleChoiceValue) = formRow {
                Text(multipleChoiceValue.title)
            }
        }
        .listRowSeparatorSectionInsetStyle()
    }
    
}
