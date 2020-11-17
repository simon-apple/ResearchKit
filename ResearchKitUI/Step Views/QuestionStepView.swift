/*
 Copyright (c) 2020, Apple Inc. All rights reserved.
 
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

import ResearchKitCore
import SwiftUI

struct TextChoiceCell: View {
    
    private var selected: Bool = false
    
    var title: String
    
    var selection: (Bool) -> Void
    
    init(title: String, selected: Bool = false, selection: @escaping (Bool) -> Void) {
        self.title = title
        self.selection = selection
        self.selected = selected
    }
    
    @ViewBuilder
    var body: some View {
        Button(action: {
            selection(!selected)
        }) {
            HStack {
                Text(title)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Image(systemName: selected ? "checkmark.circle.fill" : "circle")
                    .frame(alignment: .trailing)
                    .imageScale(.large)
                    .foregroundColor(selected ? .blue : .white)
            }
        }
    }
}

@available(watchOS 6.0, *)
public struct QuestionStepView: View {

    enum Constants {
        static let questionToAnswerPadding: CGFloat = 12.0
    }
    
    @State
    private var selectedIndex: Int = -1
    
    @ObservedObject
    public private(set) var step: ORKQuestionStep

    @ObservedObject
    public private(set) var result: ORKStepResult
    
    @EnvironmentObject
    private var completion: CompletionObject
    
    @Environment(\.progress) var progress
    
    init(_ step: ORKQuestionStep, result: ORKStepResult) {
        self.step = step
        self.result = result
    }
     
    public var body: some View {
        
        VStack {
            
            if let progress = progress {
                Text("\(progress.index) OF \(progress.count)".uppercased())
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            if let stepTitle = step.title, !stepTitle.isEmpty {
                Text(stepTitle)
                    .font(.body)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            if let stepQuestion = step.question, !stepQuestion.isEmpty {
                Text(stepQuestion)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            Spacer()
                .frame(height: Constants.questionToAnswerPadding)
            
            if let textChoiceAnswerFormat = step.answerFormat as? ORKTextChoiceAnswerFormat {
                
                let textChoices = Array(zip(textChoiceAnswerFormat.textChoices.indices,
                                            textChoiceAnswerFormat.textChoices))
                
                // Find the current result
                // Match the current result to the existing options
                // If found, set the selected index for UI
                let currentChoice = (result.results?.first as? ORKChoiceQuestionResult)?
                    .choiceAnswers?
                    .first as? String
                let someIndex = selectedIndex == -1 ?
                    textChoices.first(where: { ($1.value as? String) == currentChoice })?.0 :
                    selectedIndex
                
                ForEach(textChoices, id: \.1) { index, textChoice in
                    
                    TextChoiceCell(title: textChoice.text,
                                   selected: index == someIndex) { selected in
                        
                        if selected {
                            
                            selectedIndex = index
                            
                            let choiceResult = ORKChoiceQuestionResult(identifier: step.identifier)
                            choiceResult.choiceAnswers = [textChoice.value]
                            choiceResult.startDate = result.startDate
                            choiceResult.endDate = Date()
                            result.results = [choiceResult]
                            
                            // 250 ms delay
                            DispatchQueue
                                .main
                                .asyncAfter(deadline: DispatchTime
                                                .now()
                                                .advanced(by: .milliseconds(250))) {
                                    
                                    completion.run()
                                }
                        }
                    }
                }
            }
        }
    }
}
