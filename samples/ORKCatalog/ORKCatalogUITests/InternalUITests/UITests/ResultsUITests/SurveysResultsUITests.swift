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

import Foundation
import XCTest

final class SurveysResultsUITests: BaseUITest {
    
    let tasksList = TasksTab()
    let tabBar = TabBar()
    
    let shouldUseUIPickerWorkaround = true /// This issue required extra button tap to dismiss picker to continue: rdar://111132091 ([Modularization] [ORKCatalog] Date Picker won't display on the question card)
    
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
    
    // MARK: - Form Survey Results
    
    func testFormSurveyResults() {
        tasksList
            .selectTaskByName(Task.form.description)
        SurveysUITests().answerFormSurvey(performVerifications: false)
        FormStepScreen().tap(.continueButton)
        let resultsTab = tabBar.navigateToResults()
        
        // Navigate to formStep results
        resultsTab
            .selectResultsCell(withId: "formStep")
        
        // Results for verification
        let expectedResults = [
            ("appleFormItemIdentifier", [UserResponseValues(resultType: .choices, expectedValue: "[5]")]),
            ("formItem03", [UserResponseValues(resultType: .scaleAnswer,expectedValue: "10")]),
            ("formItem04", [UserResponseValues(resultType: .choices, expectedValue: "[choice 7]")]),
            ("formItem01", [
                UserResponseValues(resultType: .numericAnswer, expectedValue: "578"),
                UserResponseValues(resultType: .unit, expectedValue: "nil"),
                UserResponseValues(resultType: .displayUnit, expectedValue: "nil")
            ]
            ),
            ("formItem02", [UserResponseValues(resultType: .intervalAnswer, expectedValue: "34680")]),
            ("textChoiceFormItem", [UserResponseValues(resultType: .choices, expectedValue: "[6]")]),
            ("imageChoiceItem", [UserResponseValues(resultType: .choices, expectedValue: "[Round Shape]")]),
            ("freeTextItemIdentifier", [UserResponseValues(resultType: .textAnswer, expectedValue: Answers.loremIpsumShortText)])
        ]
        
        validateFormStepResults(expectedResults)
        
        // Verify completionStep result
        resultsTab
            .navigateToResultsStepBack()
            .selectResultsCell(withId: "completionStep")
            .verifyNoChildResults()
            .navigateToResultsStepBack()
        
    }
    
    // MARK: Survey With Multiple Options Results
    
    func testSurveyWithMultipleOptionsResults() {
        tasksList
            .selectTaskByName(Task.surveyWithMultipleOptions.description)
        
        // Task Steps: FormStep, FormStep
        test("Add user responses for Multiple Choice Text Question") {
            let formStep1 = FormStepScreen(itemIds: ["formItem01", "formItem02"])
            let stepOneItemOneIndices = [0, 1]
            let stepOneItemTwoIndex = 2
            let stepTwoItemOneIndex = 3
            formStep1
                .answerMultipleChoiceTextQuestion(withId: formStep1.itemIds[0], indices: stepOneItemOneIndices)
                .scrollToQuestionTitle(atIndex: 1)
                .answerSingleChoiceTextQuestion(withId: formStep1.itemIds[1], atIndex: stepOneItemTwoIndex)
                .tap(.continueButton)
            
            let formStep2 = FormStepScreen(itemIds: ["formItem01"])
            formStep2
                .verifySingleQuestionTitleExists()
                .answerSingleChoiceTextQuestion(withId: formStep2.itemIds[0], atIndex: stepTwoItemOneIndex)
                .tap(.continueButton)
        }
        
        // Results Validation
        test("Verify Results tab for Multiple Choice Text Question") {
            
            let expectedPageOneResults = [
                ("formItem01", [UserResponseValues(resultType: .choices, expectedValue: "[1, 2]")]),
                ("formItem02", [UserResponseValues(resultType: .choices,expectedValue: "[3]")])
            ]
            let expectedPageTwoResults = [
                ("formItem01", [UserResponseValues(resultType: .choices, expectedValue: "[4]")])
            ]
            let resultsTab = tabBar.navigateToResults()
            
            resultsTab
                .selectResultsCell(withId: "formStepWithMultipleSelection")
            validateFormStepResults(expectedPageOneResults)
            
            resultsTab
                .navigateToResultsStepBack()
                .selectResultsCell(withId: "formStepWithSingleSelection")
            validateFormStepResults(expectedPageTwoResults)
        }
    }
    
    // MARK: Helpers
    
    struct UserResponseValues {
        var resultType: AccessibilityIdentifiers.ResultRow
        var expectedValue: String
    }

    func validateFormStepResults(_ expectedResults: [(String, [UserResponseValues])]) {
        let resultsTab = ResultsTab()
        for result in expectedResults {
            resultsTab.selectResultsCell(withId: result.0)
            let responses: [UserResponseValues] = result.1 as [UserResponseValues]
            for response in responses {
                resultsTab.verifyResultsCellValue(resultType: response.resultType, expectedValue: response.expectedValue)
            }
            resultsTab.navigateToResultsStepBack()
        }
    }
}
