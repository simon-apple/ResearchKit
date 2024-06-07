/*
 Copyright (c) 2024, Apple Inc. All rights reserved.
 
 Redistribution and use in source and binary forms, with or without modification,
 are permitted provided that the following conditions are met:
 
 1.  Redistributions of source code must retain the above copyright notice, this
 list of conditions and the following disclaimer.
 
 2.  Redistributions in binary form must reproduce the above copyright notice,
 this list of conditions and the following disclaimer in the documentation and/or
 other materials provided with the distribution.
 
 3.  Neither the name of the copyright holder(s) nor the names of any contributors
 may be used to endorse or promote products derived from this software without
 specific prior written permission. No license is granted to the trademarks of
 the copyright holders even if such marks are included in this software.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
 FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

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
        case .doubleSliderRow(let scaleSliderQuestion):
            title = scaleSliderQuestion.title
        case .intSliderRow(let scaleSliderQuestion):
            title = scaleSliderQuestion.title
        case .textSliderStep(let scaleSliderQuestion):
            title = scaleSliderQuestion.title
        }
        return title
    }
    
}
