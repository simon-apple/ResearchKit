//  SurveysUITests.swift
//  ORKCatalogUITests
//
//  Created by Albina Kashapova on 10/25/23.
//  Copyright © 2023 researchkit.org. All rights reserved.
//

import Foundation
import XCTest

final class SurveysUITests: BaseUITest {
    
    let tasksList = TasksTab()
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        // Verify that before we start our test we are on Tasks tab
        tasksList
            .assertTitle()
    }
    
    override func tearDownWithError() throws {
        if testRun?.hasSucceeded == false { return }
        // Verify that after test is completed, we end up on Tasks tab
        tasksList
            .assertTitle()
    }
    
    ///<rdar://tsc/21847945> [Surveys] Simple Survey Example
    func testSimpleSurvey() {
        tasksList
            .selectTaskByName(Task.survey.description)
        
        // Task Steps: QuestionStep, QuestionStep, QuestionStep, InstructionStep
        
        let instructionStep = InstructionStep()
        instructionStep
            .verify(.title)
            .verify(.text)
            .verify(.detailText)
            .tap(.continueButton)
        
        let firstQuestionId = "BooleanQuestion"
        let secondQuestionId = "DateQuestion"
        let thirdQuestionId = "SingleTextChoiceQuestion"
        
        let questionStep1 = QuestionStep(id: firstQuestionId)
        let questionStep2 = QuestionStep(id: secondQuestionId)
        let questionStep3 = QuestionStep(id: thirdQuestionId)
        let questionSteps = [questionStep1, questionStep2, questionStep3]
        let totalProgress = questionSteps.count
        
        // Iterate though question steps
        var counter = 0
        for (index, step) in questionSteps.enumerated() {
            let currentProgress = index + 1
            // Verify step order and step components
            step
                .verifyCurrentStepProgress(currentProgress: currentProgress, totalProgress: totalProgress)
                .verify(.title)
                .verify(.text)
                .verifyQuestionTitleExistsAndNotEmpty()
                .verify(.skipButton, exists: true)
                .verify(.skipButton, isEnabled: true) // All questions are optional in this survey
            
            switch step.id {
            case firstQuestionId:
                XCTAssert(currentProgress == 1, "Boolean Question not found at step 1")
                questionStep1
                    .verify(.continueButton, isEnabled: false)
                    .answerBooleanQuestion(atIndex: 0)
                    .verify(.continueButton, isEnabled: true)
            case secondQuestionId:
                XCTAssert(currentProgress == 2, "Date Question not found at step 2")
                questionStep2
                    .verify(.continueButton, isEnabled: true) // Continue button is enabled before user changes date picker values
                    .answerDateQuestion(year: "1955", month: "February", day: "24")
                    .verify(.continueButton, isEnabled: true)
            case thirdQuestionId:
                XCTAssert(currentProgress == 3, "Text Choice Question not found at step 3")
                questionStep3
                    .verify(.continueButton,isEnabled: false)
                    .answerSingleChoiceTextQuestion(atIndex: 6)
                    .verify(.continueButton,isEnabled: true)
            default:
                XCTFail("Unexpected step found with id: \(step.id)")
            }
            counter += 1
            step
                .tap(.continueButton)
        }
        
        XCTAssert(counter == totalProgress, "Unexpected number of steps. Expected count: \(totalProgress)")
        
        let completionStep = InstructionStep()
        completionStep
            .verify(.title)
            .verify(.text)
            .verifyContinueButtonLabel(expectedLabel: .done)
            .tap(.continueButton)
    }
    
    /// no tstt test case yet
    func testSurveyWithMultipleOptions() {
        self.executionTimeAllowance = 800 // Increase due to lengthly test
        
        tasksList
            .selectTaskByName(Task.surveyWithMultipleOptions.description)
        
        // Task Steps: FormStep, FormStep
        
        let formStep1 = FormStep(items: ["formItem01", "formItem02"])
        let totalQuestion = 2
        var indicesToSelect = [0, 1, 2, 5, 11, 46]
        let indexToSelect = 2
        formStep1
            .verify(.title)
            .verify(.text)
        
        test("Step 1 Form Item 1: Multiple Choice Text Question") {
            formStep1
                .verifyQuestionProgressAndTitleExists(questionIndex: 0, totalQuestions: totalQuestion)
                .answerMultipleChoiceTextQuestion(withId: formStep1.items[0], indices: indicesToSelect)
        }
        test("Step 1 Form Item 2: Single Choice Text Question") {
            formStep1
            //.verifyQuestionProgressAndTitleExists(questionIndex: 1, totalQuestions: totalQuestion) - Identifier for question title "ORKSurveyCardHeaderView_titleLabel" is missing here
                .answerSingleChoiceTextQuestion(withId: formStep1.items[1], atIndex: indexToSelect)
        }
        test("Step 1: Verify multiple cells selected") {
            indicesToSelect.append(indexToSelect)
            formStep1
                .scrollDownToStepTitle()
                .verifyMultipleCellsSelected(withId: formStep1.items[0], indices: indicesToSelect, cellsChoiceRange: (start: 0, end: 49))
                .verifyOnlyOneCellSelected(withId: formStep1.items[1], atIndex: indexToSelect, cellsChoiceRange: (start: 0, end: 49))
        }
        formStep1
            .tap(.continueButton)
        
        let formStep2 = FormStep(items: ["formItem01"])
        test("Step 2 Form Item 1: Single Choice Text Question") {
            formStep1
                .verifyQuestionTitleExists(questionIndex: 0)
                .answerSingleChoiceTextQuestion(withId: formStep2.items[0], atIndex: 7)
        }
        formStep2
            .tap(.continueButton)
    }
    
    /// <rdar://tsc/21847944> [Surveys] Grouped Formed Survey Example
    func testGroupedFormStep() {
        tasksList
            .selectTaskByName(Task.groupedForm.description)
        
       // Task Steps: FormStep, QuestionStep, QuestionStep, FormStep
        
        let formStep = FormStep(items: ["formItem01", "formItem02", "text-section-text-item-a", "text-section-text-item-b", "formItem03", "sesIdentifier"])
        let totalQuestions = 4
        formStep
            .verify(.title)
            .verify(.text)
        
        test("Form Items: Integer and Time Interval questions") {
            formStep
                .verifyQuestionProgressAndTitleExists(questionIndex: 0, totalQuestions: totalQuestions)
                .selectFormItemCell(withID: formStep.items[0])
                .answerIntegerQuestion(number: 123, dismissKeyboard: true)
                .answerTimeIntervalQuestion(hours: 15, minutes: 50, dismissPicker: true) // Autoscroll autofocus automatically selects form item so no need to use selectFormItemCell
        }
        test("Form Items: Text and Time Interval questions") {
            formStep
                .verifyQuestionProgressAndTitleExists(questionIndex: 1, totalQuestions: totalQuestions)
                .answerTextQuestion(text: "Abc", dismissKeyboard: true) // Autoscroll autofocus automatically selects form item so no need to use selectFormItemCell
                .answerTimeIntervalQuestion(hours: 1, minutes: 13, dismissPicker: true) // Autoscroll autofocus automatically selects form item so no need to use selectFormItemCell
            
        }
        test("Form Item: Scale question") {
            formStep
                .verifyQuestionProgressAndTitleExists(questionIndex: 2, totalQuestions: totalQuestions)
             //   .adjustFirstSlider(toNormalizedSliderPosition: 0.5)
                .answerScaleQuestion(withId: formStep.items[4], withNormalizedPosition: 0.5)
        }
        test("Form Item: SES question") {
            formStep
               // .verifyQuestionProgressAndTitleExists(questionIndex: 3, totalQuestions: totalQuestions) The following method works, for example, for  iPhone 14 Plus, Pro Max. But it does not work, for example, on iPhone 14
              //  .verifyQuestionTitleExistsAndNotEmpty(questionIndex: 3)
                .verifyQuestionProgressLabelExists(questionIndex: 3, totalQuestions: totalQuestions)
                .answerSESladder(withID: formStep.items[5], buttonIndexToSelect: 9)
        }
        formStep
            .tap(.continueButton)
        
        let questionStep1 = QuestionStep()
        questionStep1
            .verify(.continueButton, isEnabled: false)
            .verify(.skipButton,exists: true)
            .answerBooleanQuestion(atIndex: 0)  // "Yes" answer triggers additional question in last form step
            .tap(.continueButton)
        
        let questionStep2 = QuestionStep()
        questionStep2
            .verify(.continueButton, isEnabled: true)
            .verify(.skipButton,exists: true)
            .answerDateQuestion(year: "1960", month: "November", day: "1")
            .tap(.continueButton)
        
        let formStep2 = FormStep(items: ["appleFormItemIdentifier", "newletterFormItemIdentifier"])
        formStep2
            .verifyStepView()
            .verify(.continueButton, isEnabled: true)
            .verify(.skipButton)
        // First Question
            .answerSingleChoiceTextQuestion(withId: formStep2.items[0], atIndex: 4)
        // Second Question
            .answerSingleChoiceTextQuestion(withId: formStep2.items[1], atIndex: 0)
            .tap(.continueButton)
            .verify(.continueButton, exists: false)
    }
}
