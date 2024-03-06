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

// apple-internal

import ResearchKitCore
import SwiftUI

class QuestionStepViewModel: ObservableObject {
    
    @ObservedObject
    private(set) var step: ORKQuestionStep
    
    @ObservedObject
    private(set) var result: ORKStepResult
      
    @Published
    var selectedIndex: Int = -1
    
    var progress: Progress?
    
    var childResult: ORKResult? {
        get {
            return result.results?.first
        }
        set {
            if let value = newValue {
                value.startDate = result.startDate
                value.endDate = Date()
                result.results = [value]
            } else {
                result.results = nil
            }
        }
    }
    
    lazy var textChoiceAnswers: [(Int, ORKTextChoice)] = {
        
        if let textChoiceAnswerFormat = step.answerFormat as? ORKTextChoiceAnswerFormat {
            return Array(zip(textChoiceAnswerFormat.textChoices.indices,
                             textChoiceAnswerFormat.textChoices))
        } else {
            return []
        }
        
    }()
    
    init(step: ORKQuestionStep, result: ORKStepResult) {
        self.step = step
        self.result = result
    }
}

internal struct _QuestionStepView: View {
    
    enum Constants {
        static let topToProgressPadding: CGFloat = 4.0
        static let bottomToProgressPadding: CGFloat = 4.0
        static let questionToAnswerPadding: CGFloat = 12.0
    }
    
    @ObservedObject
    private var viewModel: QuestionStepViewModel
    
    @Environment(\.completion) var completion
    
    init(viewModel: QuestionStepViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        
        ORKScrollViewReader { value in
        
            VStack {
                
                Group {
                    
                    if let progress = viewModel.progress {
                        Text("\(progress.index) OF \(progress.count)".uppercased())
                            .foregroundColor(.gray)
                            .font(.subheadline)
                            .padding(.top, Constants.topToProgressPadding)
                            .padding(.bottom, Constants.bottomToProgressPadding)
                    }
                    
                    if let stepTitle = viewModel.step.title, !stepTitle.isEmpty {
                        Text(stepTitle)
                            .font(.body)
                            .fontWeight(.semibold)
                            .multilineTextAlignment(.leading)
                            .padding(.bottom, Constants.questionToAnswerPadding)
                    }
                    
                    if let stepQuestion = viewModel.step.question, !stepQuestion.isEmpty {
                        Text(stepQuestion)
                            .font(.body)
                            .fontWeight(.semibold)
                            .multilineTextAlignment(.leading)
                            .padding(.bottom, Constants.questionToAnswerPadding)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading)
                
            let textChoices = viewModel.textChoiceAnswers
                ForEach(textChoices, id: \.1) { index, textChoice in
                    
                    TextChoiceCell(title: Text(textChoice.text), selected: index == viewModel.selectedIndex) { selected in

                        if selected {
                            
                            viewModel.selectedIndex = index
                            
                            let choiceResult =
                                ORKChoiceQuestionResult(identifier: viewModel.step.identifier)
                            
                            choiceResult.choiceAnswers = [textChoice.value]
                            viewModel.childResult = choiceResult
                            
                            // 250 ms delay
                            DispatchQueue
                                .main
                                .asyncAfter(deadline: DispatchTime
                                                .now()
                                                .advanced(by: .milliseconds(250))) {

                                    completion(true)
                                }
                            
                        } else {
                            
                            viewModel.selectedIndex = -1
                            viewModel.childResult = nil

                            completion(false)
                        }
                    }
                }
            }
        }
    }
}

@available(watchOS 6.0, *)
public struct QuestionStepView: View {

    @EnvironmentObject
    private var taskManager: TaskManager
    
    @ObservedObject
    public private(set) var step: ORKQuestionStep

    @ObservedObject
    public private(set) var result: ORKStepResult
    
    @Environment(\.completion) var completion
    
    init(_ step: ORKQuestionStep, result: ORKStepResult) {
        self.step = step
        self.result = result
    }
    
    private var model: QuestionStepViewModel? {
        
        if case let ViewModel.questionStep(model) = taskManager.viewModelForStep(step) {
            return model
        } else {
            return nil
        }
    }
     
    public var body: some View {
        if let viewModel = model {
            _QuestionStepView(viewModel: viewModel)
                .environment(\.completion, completion)
        }
    }
}
