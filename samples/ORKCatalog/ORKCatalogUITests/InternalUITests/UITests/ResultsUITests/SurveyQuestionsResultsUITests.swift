/*
 Copyright (c) 20202415, Apple Inc. All rights reserved.
 
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

import Foundation
import XCTest
import ORKCatalog

final class SurveyQuestionsResultsUITests: BaseUITest {
    
    let tasksList = TasksTab()
    let tabBar = TabBar()
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        // Verify that before we start our test we are on Tasks tab
        tasksList
            .assertTitle()
    }
    
    override func tearDownWithError() throws {
        if testRun?.hasSucceeded == false {
            return
        }
        // Verify that after test is completed, we end up on Tasks tab
        tasksList
            .assertTitle()
    }
    
    // MARK: - Boolean Question
    
    func answerAndVerifyBoolQuestion(answerCellIndex: Int?, expectedValue: String) {
        tasksList
            .selectTaskByName(Task.booleanQuestion.description)
        
        let questionStep = FormStepScreen(id: String(describing: Identifier.booleanFormStep), itemIds: [String(describing: Identifier.booleanFormItem)], answer: answerCellIndex)
        
        if answerCellIndex == nil {
            questionStep
                .tap(.skipButton)
        } else {
            questionStep
                .answerBooleanQuestion(withId: questionStep.itemIds[0], atIndex: questionStep.answer as! Int)
                .tap(.continueButton)
        }
        
        let resultsTab = tabBar.navigateToResults()
        resultsTab
            .selectResultsCell(withId: questionStep.id)
            .selectResultsCell(withId: questionStep.itemIds[0])
            .verifyResultsCellValue(resultType: .bool, expectedValue: expectedValue)
    }
    
    func testBooleanQuestionTrueResult() {
        answerAndVerifyBoolQuestion(answerCellIndex: 0, expectedValue: "true")
    }
    
    func testBooleanQuestionFalseResult() {
        answerAndVerifyBoolQuestion(answerCellIndex: 1, expectedValue: "false")
    }
    
    func testBooleanQuestionSkipResult() {
        answerAndVerifyBoolQuestion(answerCellIndex: nil, expectedValue: "nil")
    }
    
    // MARK: - Custom Boolean Question
    
    func answerAndVerifyCustomBoolQuestion(answerCellIndex: Int?, expectedValue: String) {
        tasksList
            .selectTaskByName(Task.customBooleanQuestion.description)
        
        let formStep = FormStepScreen(id: String(describing: Identifier.booleanFormStep), itemIds: [String(describing: Identifier.booleanFormItem)], answer: answerCellIndex)
        
        if answerCellIndex != nil {
            formStep
                .answerSingleChoiceTextQuestion(withId: formStep.itemIds[0], atIndex: formStep.answer as! Int)
                .tap(.continueButton)
        } else {
            formStep
                .tap(.skipButton)
        }
        
        let resultsTab = tabBar.navigateToResults()
        resultsTab
            .selectResultsCell(withId: formStep.id)
            .selectResultsCell(withId: formStep.itemIds[0])
            .verifyResultsCellValue(resultType: .bool, expectedValue: expectedValue)
    }
    
    func testCustomBooleanQuestionTrueResult() {
        answerAndVerifyCustomBoolQuestion(answerCellIndex: 0, expectedValue: "true")
    }
    
    func testCustomBooleanQuestionFalseResult() {
        answerAndVerifyCustomBoolQuestion(answerCellIndex: 1, expectedValue: "false")
    }
    
    func testCustomBooleanQuestionSkipResult() {
        answerAndVerifyCustomBoolQuestion(answerCellIndex: nil, expectedValue: "nil")
    }
    
    // MARK: - Text Choice Question
    
    /**
     Verifies results of task that consists of two form steps: form step with single choice style and form step with multiple choice style
     - parameter singleChoiceExpectedValue/multiChoiceExpectedValue: Expected value in results tab
     - parameter inputText:text that is entered in other choice when selected
     */
    func answerAndVerifyTextChoiceQuestionTask(singleChoiceAnswerIndex: Int?, multiChoiceAnswerIndex: [Int]?, singleChoiceExpectedValue: String, multiChoiceExpectedValue: String, inputText: String?) {
        
        tasksList.selectTaskByName(Task.textChoiceQuestion.description)
        
        let formStep1 = FormStepScreen(id: String(describing: Identifier.formStep), itemIds: [String(describing: Identifier.formItem01)], answer: singleChoiceAnswerIndex)
        
        let formStep2 = FormStepScreen(id: String(describing: Identifier.formStep02), itemIds: [String(describing: Identifier.formItem02)], answer: multiChoiceAnswerIndex)
        
        // Answer question in form step 1
        if singleChoiceAnswerIndex != nil {
            let formStep1Answer = formStep1.answer as! Int
            formStep1
                .answerSingleChoiceTextQuestion(withId: formStep1.itemIds[0], atIndex: 0) /// Adding extra check for single choice question: selecting first index before next one
                .answerSingleChoiceTextQuestion(withId: formStep1.itemIds[0], atIndex: formStep1Answer)
            if inputText != nil {
                formStep1.answerTextChoiceOtherQuestion(withId: formStep1.itemIds[0], atIndex: formStep1Answer, text: inputText!)
            }
            formStep1.tap(.continueButton)
        } else {
            formStep1.tap(.skipButton)
        }
        
        // Answer question in form step 2
        if multiChoiceAnswerIndex != nil {
            let formStep2Answer = formStep2.answer as! [Int]
            formStep2
                .answerMultipleChoiceTextQuestion(withId: formStep2.itemIds[0], indices: formStep2Answer)
            if inputText != nil {
                formStep2.answerTextChoiceOtherQuestion(withId: formStep2.itemIds[0], atIndex: formStep2Answer[0], text: inputText!)
            }
            formStep2.tap(.continueButton)
        } else {
            formStep2.tap(.skipButton)
        }
        
        let completionStep = InstructionStepScreen()
        completionStep
            .verifyStepView()
            .tap(.continueButton)
        
        let resultsTab = tabBar.navigateToResults()
        resultsTab
            .selectResultsCell(withId: formStep1.id)
            .selectResultsCell(withId: formStep1.itemIds[0])
            .verifyResultsCellValue(resultType: .choices, expectedValue: singleChoiceExpectedValue)
            .navigateToResultsStepBack()
            .navigateToResultsStepBack()
        
        resultsTab
            .selectResultsCell(withId: formStep2.id)
            .selectResultsCell(withId: formStep2.itemIds[0])
            .verifyResultsCellValue(resultType: .choices, expectedValue: multiChoiceExpectedValue)
    }
    
    /// Verifies non-exclusive choices
    func testTextChoiceQuestionResult() {
        answerAndVerifyTextChoiceQuestionTask(singleChoiceAnswerIndex: 2, multiChoiceAnswerIndex: [0, 2], singleChoiceExpectedValue: "[choice_3]", multiChoiceExpectedValue: "[choice_1, choice_3]", inputText: nil)
    }
    
    /// Verifies exclusive choices without text. Adding extra check for multi choice question: selecting not just exclusive index but some other indices as well
    func testTextChoiceOtherQuestionResult() {
        answerAndVerifyTextChoiceQuestionTask(singleChoiceAnswerIndex: 3, multiChoiceAnswerIndex: [0, 2, 3], singleChoiceExpectedValue: "[Other]", multiChoiceExpectedValue: "[Other]", inputText: nil)
    }
    
    /// Verifies exclusive choices with input text
    func testTextChoiceOtherInputTextQuestionResult() {
        answerAndVerifyTextChoiceQuestionTask(singleChoiceAnswerIndex: 3, multiChoiceAnswerIndex: [3], singleChoiceExpectedValue: "[\(Answers.loremIpsumShortText)]", multiChoiceExpectedValue: "[\(Answers.loremIpsumShortText)]", inputText: Answers.loremIpsumShortText)
    }
    
    func testTextChoiceQuestionSkipResult() {
        answerAndVerifyTextChoiceQuestionTask(singleChoiceAnswerIndex: nil, multiChoiceAnswerIndex: nil, singleChoiceExpectedValue: "nil", multiChoiceExpectedValue: "nil", inputText: nil)
    }
    
    // MARK: - Text Choice Image Question
    
    func answerAndVerifyImageQuestion(answerCellIndex: Int?, expectedValue: String) {
        tasksList.selectTaskByName(Task.textChoiceQuestionWithImageTask.description)
        
        let formStep = FormStepScreen(id: String(describing: Identifier.textChoiceFormStep), itemIds: [String(describing: Identifier.textChoiceFormItem)], answer: answerCellIndex)
        
        if answerCellIndex != nil {
            formStep
                .verifyStepView()
                .answerSingleChoiceTextQuestion(withId: formStep.itemIds[0], atIndex: formStep.answer as! Int)
                .tap(.continueButton)
        } else {
            formStep.tap(.skipButton)
        }
        
        let resultsTab = tabBar.navigateToResults()
        resultsTab
            .selectResultsCell(withId: formStep.id)
            .selectResultsCell(withId: formStep.itemIds[0])
            .verifyResultsCellValue(resultType: .choices, expectedValue: expectedValue)
    }
    
    func testTextChoiceImageQuestionResult() {
        answerAndVerifyImageQuestion(answerCellIndex: 1, expectedValue: "[tap 2]")
    }
    
    func testTextChoiceImageQuestionSkipResult() {
        answerAndVerifyImageQuestion(answerCellIndex: nil, expectedValue: "nil")
    }
}
