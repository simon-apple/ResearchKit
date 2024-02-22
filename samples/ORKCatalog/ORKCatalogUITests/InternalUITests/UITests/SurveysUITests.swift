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
    
    /// rdar://119572486 ([ORKCatalog] [Modularization] Survey Questions - Next button is enabled by default before user provides answers)
    let expectingNextButtonEnabledByDefault = true
    
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
        
        let instructionStep = InstructionStepScreen()
        instructionStep
            .verify(.title)
            .verify(.text)
            .verify(.detailText)
            .tap(.continueButton)
        
        let booleanQuestionId = "booleanFormItem"
        let dateQuestionId = "birthdayQuestionFormItem"
        let textChoiceOtherQuestionId = "textChoiceFormItem"
        
        let questionSteps = [FormStepScreen(id: booleanQuestionId), FormStepScreen(id: dateQuestionId), FormStepScreen(id: textChoiceOtherQuestionId)]
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
                .verifySingleQuestionTitleExists()
                .verify(.skipButton, exists: true)
                .verify(.skipButton, isEnabled: true) // All questions are optional in this survey
            
            switch step.id {
            case booleanQuestionId:
                XCTAssert(currentProgress == 1, "Boolean Question not found at step 1")
                step
                    .verify(.continueButton, isEnabled: expectingNextButtonEnabledByDefault)
                    .answerBooleanQuestion(withId: booleanQuestionId, atIndex: 0)
                    .verify(.continueButton, isEnabled: true)
            case dateQuestionId:
                XCTAssert(currentProgress == 2, "Date Question not found at step 2")
                step
                    .verify(.continueButton, isEnabled: true) // Continue button is enabled before user changes date picker values
                    .selectFormItemCell(withID: dateQuestionId)
                    .answerDateQuestion(year: "1955", month: "February", day: "24", dismissPicker: true)
                    .verify(.continueButton, isEnabled: true)
            case textChoiceOtherQuestionId:
                XCTAssert(currentProgress == 3, "Text Choice Question not found at step 3")
                step
                    .verify(.continueButton,isEnabled: expectingNextButtonEnabledByDefault)
                    .answerSingleChoiceTextQuestion(withId: "textChoiceFormItem", atIndex: 6)
                    .verify(.continueButton,isEnabled: true)
            default:
                XCTFail("Unexpected step found with id: \(step.id)")
            }
            counter += 1
            step
                .tap(.continueButton)
        }
        
        XCTAssert(counter == totalProgress, "Unexpected number of steps. Expected count: \(totalProgress)")
        
        let completionStep = InstructionStepScreen()
        completionStep
            .verify(.title)
            .verify(.text)
            .verifyContinueButtonLabel(expectedLabel: .done)
            .tap(.continueButton)
    }
    
    /// rdar://tsc/21847943 ([Surveys] Form Survey Example)
    func testFormSurveyExample() {
        tasksList
            .selectTaskByName(Task.form.description)
        
        let formStep = FormStepScreen(itemIds: ["appleFormItemIdentifier", "formItem03", "formItem04", "formItem01", "formItem02", "textChoiceFormItem", "imageChoiceItem", "freeTextItemIdentifier"])
        
        formStep
            .verifyQuestionTitleExists(atIndex: 0)
            .verifyQuestionProgressLabelExists(atIndex: 0)
            .answerSingleChoiceTextQuestion(withId: formStep.itemIds[0], atIndex: 2)
            .answerSingleChoiceTextQuestion(withId: formStep.itemIds[0], atIndex: 1)
            .answerSingleChoiceTextQuestion(withId: formStep.itemIds[0], atIndex: 4)
        
        formStep
            .verifyQuestionTitleExists(atIndex: 1)
            .verifyQuestionProgressLabelExists(atIndex: 1)
            .adjustQuestionSlider(withId: formStep.itemIds[1], withNormalizedPosition: 0.5)
            .adjustQuestionSlider(withId: formStep.itemIds[1], withNormalizedPosition: 1)
        
        // Section that consist of 3 questions:
        formStep
            .verifyQuestionTitleExists(atIndex: 2)
            .adjustQuestionSlider(withId: formStep.itemIds[2], atIndex: 0, withNormalizedPosition: 1)
            .selectFormItemCell(withID: formStep.itemIds[3], atIndex: 1)
            .answerIntegerQuestion(number: 578)
            .selectFormItemCell(withID: formStep.itemIds[4], atIndex: 2)
            .answerTimeIntervalQuestion(hours: 9, minutes: 38, dismissPicker: true)
        
        formStep
            .verifyQuestionTitleExists(atIndex: 3)
            .answerSingleChoiceTextQuestion(withId: formStep.itemIds[5], atIndex: 1)
            .answerSingleChoiceTextQuestion(withId: formStep.itemIds[5], atIndex: 6)
            .answerTextChoiceOtherQuestion(withId: formStep.itemIds[5], atIndex: 6, text: TextAnswers.loremIpsumShortText)
            .answerSingleChoiceTextQuestion(withId: formStep.itemIds[5], atIndex: 5)
       //     app.swipeUp()
        formStep
            .verifyQuestionTitleExists(atIndex: 4)
         //   .scrollToQuestionTitle(atIndex: 4)
            .answerImageChoiceQuestion(withId: formStep.itemIds[6], imageIndex: 1)
        
        formStep
            .verifyQuestionTitleExists(atIndex: 5)
            .answerTextQuestionTextView(withId: formStep.itemIds[7], text: TextAnswers.loremIpsumShortText, dismissKeyboard: true)
        
        formStep
            .tap(.continueButton)
        
        let instructionStep = InstructionStepScreen()
        instructionStep
            .verify(.title)
            .tap(.continueButton)
    }
    
    /// no tstt test case yet
    func testSurveyWithMultipleOptions() {
        self.executionTimeAllowance = 1020 // Increase due to lengthly test
        
        tasksList
            .selectTaskByName(Task.surveyWithMultipleOptions.description)
        
        // Task Steps: FormStep, FormStep
        
        let formStep1 = FormStepScreen(itemIds: ["formItem01", "formItem02"])
        var indicesToSelect = [0, 1, 2, 5, 11, 46]
        let indexToSelect = 2
        formStep1
            .verify(.title)
            .verify(.text)
        
        test("Step 1 Form Item 1: Multiple Choice Text Question") {
            formStep1
                .verifyQuestionTitleExists(atIndex: 0)
                .verifyQuestionProgressLabelExists(atIndex: 0)
                .answerMultipleChoiceTextQuestion(withId: formStep1.itemIds[0], indices: indicesToSelect)
        }
        test("Step 1 Form Item 2: Single Choice Text Question") {
            formStep1
                .scrollToQuestionTitle(atIndex: 1)
                .verifyQuestionTitleExists(atIndex: 1)
                .verifyQuestionProgressLabelExists(atIndex: 1)
                .answerSingleChoiceTextQuestion(withId: formStep1.itemIds[1], atIndex: indexToSelect)
        }
        test("Step 1 Form Item 1 and Form Item 2: Verify multiple cells selected") {
            indicesToSelect.append(indexToSelect)
            app.swipeDown()
            app.swipeDown() // to accelerate scrolling down, a preparatory step for next method
            formStep1.scrollDownToStepTitle()
                .verifyMultipleCellsSelected(withId: formStep1.itemIds[0], indices: indicesToSelect, cellsChoiceRange: (start: 0, end: 49))
                .verifyOnlyOneCellSelected(withId: formStep1.itemIds[1], atIndex: indexToSelect, cellsChoiceRange: (start: 0, end: 49))
        }
        formStep1
            .tap(.continueButton)
        
        let formStep2 = FormStepScreen(itemIds: ["formItem01"])
        test("Step 2 Form Item 1: Single Choice Text Question") {
            formStep1
                .verifySingleQuestionTitleExists()
                .answerSingleChoiceTextQuestion(withId: formStep2.itemIds[0], atIndex: 7)
        }
        formStep2
            .tap(.continueButton)
    }
    
    /// <rdar://tsc/21847944> [Surveys] Grouped Formed Survey Example
    func testGroupedFormStep() {
        tasksList
            .selectTaskByName(Task.groupedForm.description)
        
       // Task Steps: FormStep, QuestionStep, QuestionStep, FormStep
        
        let formStep = FormStepScreen(itemIds: ["formItem01", "formItem02", "text-section-text-item-a", "text-section-text-item-b", "formItem03", "sesIdentifier"])
        formStep
            .verify(.title)
            .verify(.text)
        
        test("Form Items: Integer and Time Interval questions") {
            formStep
                .verifyQuestionTitleExists(atIndex: 0)
                .verifyQuestionProgressLabelExists(atIndex: 0)
                .selectFormItemCell(withID: formStep.itemIds[0])
                .answerIntegerQuestion(number: 123, dismissKeyboard: true)
                .answerTimeIntervalQuestion(hours: 15, minutes: 50, dismissPicker: true) // Autoscroll autofocus automatically selects form item so no need to use selectFormItemCell
        }
        test("Form Items: Text and Time Interval questions") {
            formStep
                .verifyQuestionTitleExists(atIndex: 1)
                .verifyQuestionProgressLabelExists(atIndex: 1)
                .answerTextQuestion(text: "Abc", dismissKeyboard: true) // Autoscroll autofocus automatically selects form item so no need to use selectFormItemCell
                .answerTimeIntervalQuestion(hours: 1, minutes: 13, dismissPicker: true) // Autoscroll autofocus automatically selects form item so no need to use selectFormItemCell
            
        }
        test("Form Item: Scale question") {
            formStep
                .verifyQuestionTitleExists(atIndex: 2)
                .verifyQuestionProgressLabelExists(atIndex: 2)
                .adjustQuestionSlider(withId: formStep.itemIds[4], withNormalizedPosition: 0.5)
        }
        test("Form Item: SES question") {
            formStep
                .verifyQuestionTitleExists(atIndex: 3)
                .verifyQuestionProgressLabelExists(atIndex: 3)
                .answerSESladder(withID: formStep.itemIds[5], buttonIndexToSelect: 9)
        }
        formStep
            .tap(.continueButton)
        
        let formStep1 = FormStepScreen(itemIds: ["booleanFormItem"])
        formStep1
            .verify(.continueButton, isEnabled: expectingNextButtonEnabledByDefault)
            .verify(.skipButton,exists: true)
            .verifySingleQuestionTitleExists()
            .answerBooleanQuestion(withId: formStep1.itemIds[0], atIndex: 0)  // "Yes" answer triggers additional question in last form step
            .tap(.continueButton)
          
        let formStep2 = FormStepScreen(itemIds: ["birthdayQuestionFormItem"])
        formStep2
            .verify(.continueButton, isEnabled: true)
            .verify(.skipButton,exists: true)
            .verifySingleQuestionTitleExists()
            .selectFormItemCell(withID: formStep2.itemIds[0])
            .answerDateQuestion(year: "1960", month: "November", day: "1", dismissPicker: true)
            .tap(.continueButton)
        
        let formStep3 = FormStepScreen(itemIds: ["appleFormItemIdentifier", "newletterFormItemIdentifier"])
        formStep3
            .verifyStepView()
            .verify(.continueButton, isEnabled: true)
            .verify(.skipButton)
        // First Question
            .answerSingleChoiceTextQuestion(withId: formStep3.itemIds[0], atIndex: 4)
        // Second Question
            .answerSingleChoiceTextQuestion(withId: formStep3.itemIds[1], atIndex: 0)
            .tap(.continueButton)
            .verify(.continueButton, exists: false)
    }
    
        //rdar://116741746 (FxHist: after selecting Yes for a minor on the conditions page, a very large space is left at the bottom below conditions, before the Done button. It was hard to find the button.)
       func testPaddingBetweenContinueButtonAndLastCell() {
           tasksList
               .selectTaskByName(Task.booleanConditionalFormTask.description)
           let formStep = FormStepScreen()
           let formItemId1 = "childFormItem"
           let formItemId2 = "childConditions"
           formStep
               .answerSingleChoiceTextQuestion(withId: formItemId1, atIndex: 0) // Triggers next form item to appear
               .answerMultipleChoiceTextQuestion(withId: formItemId2, indices: [2, 4, 12])
           app.swipeUp() // just to streamline next method
           formStep
               .scrollTo(.continueButton)
               .verifyPaddingBetweenContinueButtonAndCell(withId: formItemId2, maximumAllowedDistance: 200.0)
       }
    
    /// rdar://tsc/21847968 ([Onboarding] Eligibility Task Example)
    /// Navigable Ordered Task
    func testEligibilitySurvey() {
        tasksList
            .selectTaskByName(Task.eligibilityTask.description)
        
        let instructionStep = InstructionStepScreen()
        instructionStep
            .verify(.title)
            .verify(.text)
            .verify(.detailText)
            .tap(.continueButton)
        
        let formStep = FormStepScreen(itemIds: ["eligibilityFormItem01", "eligibilityFormItem02", "eligibilityFormItem03"])
        
        formStep
            .verify(.continueButton, isEnabled: false)
            .answerSingleChoiceTextQuestion(withId: formStep.itemIds[0], atIndex: 0)
            .answerSingleChoiceTextQuestion(withId: formStep.itemIds[1], atIndex: 0)
            .answerSingleChoiceTextQuestion(withId: formStep.itemIds[2], atIndex: 1)
            .verify(.continueButton, isEnabled: true)
            .tap(.continueButton)
        
        let completionStep = InstructionStepScreen()
        // Eligible step
        completionStep
            .verify(.title)
            .verify(.detailText)
            .verifyImage(exists: true) // blue check mark success
            .verify(.continueButton, isEnabled: true)
            .tap(.backButton)
        
        formStep
            .answerSingleChoiceTextQuestion(withId: formStep.itemIds[2], atIndex: 0)
            .tap(.continueButton)
        // Ineligible step
        completionStep
            .verify(.title)
            .verify(.detailText)
            .verifyImage(exists: false)
            .tap(.continueButton)
    }
    
    ///rdar://tsc/21847968 ([Onboarding] Eligibility Task Example)
    /// Navigable Ordered Task
    /// TODO: rdar://117821622 (Add localization support for UI Tests)
    func testEligibilitySurveyResultLabels() {
        tasksList
            .selectTaskByName(Task.eligibilityTask.description)
        
        let instructionStep = InstructionStepScreen()
        instructionStep
            .tap(.continueButton)
        
        let formStep = FormStepScreen(itemIds: ["eligibilityFormItem01", "eligibilityFormItem02", "eligibilityFormItem03"])
        
        formStep
            .answerSingleChoiceTextQuestion(withId: formStep.itemIds[0], atIndex: 0)
            .answerSingleChoiceTextQuestion(withId: formStep.itemIds[1], atIndex: 0)
            .answerSingleChoiceTextQuestion(withId: formStep.itemIds[2], atIndex: 1)
            .tap(.continueButton)
        
        let completionStep = InstructionStepScreen()
        // Eligible step
            .verifyImageLabel(expectedAXLabel: "Illustration of a check mark in a blue circle conveying success")
            .verifyLabel(.detailText, expectedLabel: "You are eligible to join the study")
            .verifyContinueButtonLabel(expectedLabel: .done)
            .tap(.backButton)
        
        formStep
            .answerSingleChoiceTextQuestion(withId: formStep.itemIds[2], atIndex: 0)
            .tap(.continueButton)
        completionStep
        // Ineligible step
            .verifyLabel(.detailText, expectedLabel: "You are ineligible to join the study")
            .tap(.continueButton)
    }
}
