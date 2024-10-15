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
        
        // This is required for results validation
        let answerIndices: [String: Int] = [booleanQuestionId: 0, textChoiceOtherQuestionId: 6] // formItemId: index
        
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
                    .answerBooleanQuestion(withId: booleanQuestionId, atIndex: answerIndices[booleanQuestionId]!)
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
                    .answerSingleChoiceTextQuestion(withId: textChoiceOtherQuestionId, atIndex: answerIndices[textChoiceOtherQuestionId]!)
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
            .tap(.backButton)
            .tap(.backButton)
            .tap(.backButton)
        
        test("After returning back verify survey results are saved") {
            let formStep = FormStepScreen()
            formStep
                .verifyOnlyOneCellSelected(withId: booleanQuestionId, atIndex: answerIndices[booleanQuestionId]!)
                .tap(.continueButton)
            
            // TODO: rdar://124182363 ([Blocked] Numeric / Date Questions - Verify entered value). Currently I'm unable to verify entered value in date question due to rdar://120826508 ([Accessibility][iOS][ORKCatalog] Unable to access cell value after entering it)
                .tap(.continueButton)
            
            formStep
                .verifyOnlyOneCellSelected(withId: textChoiceOtherQuestionId, atIndex: answerIndices[textChoiceOtherQuestionId]!)
                .tap(.continueButton)
        }
        completionStep
            .verifyStepView()
            .tap(.continueButton)
    }
    
    /// rdar://tsc/21847943 ([Surveys] Form Survey Example)
    func testFormSurveyExample() {
        tasksList
            .selectTaskByName(Task.form.description)
        
        let formStep = FormStepScreen(itemIds: ["appleFormItemIdentifier", "formItem03", "formItem04", "formItem01", "formItem02", "textChoiceFormItem", "imageChoiceItem", "freeTextItemIdentifier"])
        
        // This is required for results validation
        let answerIndices: [String: Int] = [formStep.itemIds[0]: 4, formStep.itemIds[5]: 5, formStep.itemIds[6]: 1] // questionFormItemId: index
        
        formStep
            .verifyQuestionTitleExists(atIndex: 0)
            .verifyQuestionProgressLabelExists(atIndex: 0)
            .answerSingleChoiceTextQuestion(withId: formStep.itemIds[0], atIndex: 2)
            .answerSingleChoiceTextQuestion(withId: formStep.itemIds[0], atIndex: 1)
            .answerSingleChoiceTextQuestion(withId: formStep.itemIds[0], atIndex: answerIndices[formStep.itemIds[0]]!)
        
        formStep
            .verifyQuestionTitleExists(atIndex: 1)
            .verifyQuestionProgressLabelExists(atIndex: 1)
            .adjustQuestionSlider(withId: formStep.itemIds[1], withNormalizedPosition: 0.5)
            .adjustQuestionSlider(withId: formStep.itemIds[1], withNormalizedPosition: 1)
        
        // Section that consist of 3 questions:
        formStep
            .verifyQuestionTitleExists(atIndex: 2)
            .adjustQuestionSlider(withId: formStep.itemIds[2], withNormalizedPosition: 0.5)
            .adjustQuestionSlider(withId: formStep.itemIds[2], withNormalizedPosition: 1)
            .selectFormItemCell(withID: formStep.itemIds[3], atIndex: 1)
            .answerIntegerQuestion(number: 578)
            .selectFormItemCell(withID: formStep.itemIds[4], atIndex: 2)
            .answerTimeIntervalQuestion(hours: 9, minutes: 38, dismissPicker: true)
        
        formStep
            .verifyQuestionTitleExists(atIndex: 3)
            .answerSingleChoiceTextQuestion(withId: formStep.itemIds[5], atIndex: 1)
            .answerSingleChoiceTextQuestion(withId: formStep.itemIds[5], atIndex: 6)
            .answerTextChoiceOtherQuestion(withId: formStep.itemIds[5], atIndex: 6, text: Answers.loremIpsumShortText)
            .answerSingleChoiceTextQuestion(withId: formStep.itemIds[5], atIndex: answerIndices[formStep.itemIds[5]]!)
       //     app.swipeUp()
        formStep
            .verifyQuestionTitleExists(atIndex: 4)
        //   .scrollToQuestionTitle(atIndex: 4)
            .answerImageChoiceQuestion(withId: formStep.itemIds[6], imageIndex: answerIndices[formStep.itemIds[6]]!)
        
        formStep
            .verifyQuestionTitleExists(atIndex: 5)
            .answerTextQuestionTextView(withId: formStep.itemIds[7], text: Answers.loremIpsumShortText, dismissKeyboard: true)
        
        formStep
            .tap(.continueButton)
        
        let instructionStep = InstructionStepScreen()
        instructionStep
            .verify(.title)
            .tap(.backButton)
        
        test("After returning back verify survey results are saved") {
            formStep
                .verifyOnlyOneCellSelected(withId: formStep.itemIds[0], atIndex: 4)
                .verifySliderValue(withId: formStep.itemIds[1], atIndex: 0, expectedValue: "10")
                .verifySliderValue(withId: formStep.itemIds[2], atIndex: 0, expectedValue: "choice 7")
            
            // TODO: rdar://124182363 ([Blocked] Numeric / Date Questions - Verify entered value). Currently I'm unable to verify entered values in formStep.itemIds[3], formStep.itemIds[4] due to rdar://120826508 ([Accessibility][iOS][ORKCatalog] Unable to access cell value after entering it)
            
            formStep
                .scrollToQuestionTitle(atIndex: 3)
                .verifyOnlyOneCellSelected(withId: formStep.itemIds[5], atIndex: 5)
            
            let roundShape = FormStepScreen.ImageButtonLabel.roundShape.rawValue
            formStep
                .scrollToQuestionTitle(atIndex: 4)
                .verifyImageChoiceQuestion(withId: formStep.itemIds[6], imageIndex: 1, expectedLabel: roundShape)
                .verifyTextViewValue(withId: formStep.itemIds[7], expectedText: Answers.loremIpsumShortText)
                .tap(.continueButton)
        }
        
        instructionStep
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
    
    func testSimpleSurveySkipFlow() {
        tasksList
            .selectTaskByName(Task.survey.description)
        
        let instructionStep = InstructionStepScreen()
        instructionStep
            .tap(.continueButton)
        
        let formStep = FormStepScreen()
        let numOfFormSteps = 3
        for _ in 0..<numOfFormSteps {
            formStep
                .verifyStepView()
                .tap(.skipButton)
        }
        
        let completionStep = InstructionStepScreen()
        completionStep
            .tap(.continueButton)
    }
    
    func testGroupedSurveySkipFlow() {
        tasksList
            .selectTaskByName(Task.groupedForm.description)
        
        let formStep = FormStepScreen()
        let numOfFormSteps = 4
        for _ in 0..<numOfFormSteps {
            formStep
                .verifyStepView()
                .tap(.skipButton)
        }
    }
    
    /// rdar://119563338 ([Modularization] [ORK Catalog] [Surveys] App crashing when scroll up after entering text into Choice 7 text area in Simple Survey Example task)
    func testSimpleSurveyTextChoiceOther() {
        tasksList
            .selectTaskByName(Task.survey.description)
        
        let instructionStep = InstructionStepScreen()
        instructionStep
            .tap(.continueButton)
        
        let formStep = FormStepScreen()
        formStep
            .tap(.skipButton)
            .tap(.skipButton)
                
        let formItemTextChoiceId = "textChoiceFormItem"
        let otherTextChoiceIndex = 6
        formStep
            .answerSingleChoiceTextQuestion(withId: formItemTextChoiceId, atIndex: otherTextChoiceIndex)
            .answerTextChoiceOtherQuestion(withId: formItemTextChoiceId, atIndex: otherTextChoiceIndex, text: Answers.loremIpsumOneLineText)
            .verifyTextBoxIsHidden(false, withId: formItemTextChoiceId, atIndex: otherTextChoiceIndex)
            .verifyTextBoxValue(withId: formItemTextChoiceId, atIndex: otherTextChoiceIndex, expectedValue: Answers.loremIpsumOneLineText)
        app.swipeUp()
        formStep
            .tap(.continueButton)
            .tap(.backButton)
            .verifyTextBoxValue(withId: formItemTextChoiceId, atIndex: otherTextChoiceIndex, expectedValue: Answers.loremIpsumOneLineText)
        if (!isRunningInXcodeCloud && !isRunningOnSimulator) {
            // Hypothesizing that this extra tap prior to text entry is causing flakiness in Skywagon simulators. Omitting this step for those scenarios. rdar://134442269
            formStep
                .answerSingleChoiceTextQuestion(withId: formItemTextChoiceId, atIndex: otherTextChoiceIndex)
        }
        formStep
            .answerTextChoiceOtherQuestion(withId: formItemTextChoiceId, atIndex: otherTextChoiceIndex, text: Answers.loremIpsumOneLineText, clearIfNeeded: true)
            .tap(.continueButton)
            .tap(.continueButton)
  
    }
    ///rdar://119521655 ([Modularization] [ORK Catalog] [Surveys] ORKTextChoiceOther not getting saved when tap Next and go Back)
    ///rdar://119524431 ([Modularization] [ORK Catalog] [CRASH] App crashing when deleting Choice 7 text entry and tap Done on keyboard in ORKTextChoiceOther)
    func testFormSurveyTextChoiceOther() {

        tasksList
            .selectTaskByName(Task.form.description)
        
        let formStep = FormStepScreen()
        let formItemTextChoiceId = "textChoiceFormItem"
        let otherTextChoiceIndex = 6
        
        formStep
            .scrollToQuestionTitle(atIndex: 4)
            .answerSingleChoiceTextQuestion(withId: formItemTextChoiceId , atIndex: 1)
            .answerSingleChoiceTextQuestion(withId: formItemTextChoiceId , atIndex: otherTextChoiceIndex)
            .answerTextChoiceOtherQuestion(withId: formItemTextChoiceId, atIndex: otherTextChoiceIndex, text: Answers.loremIpsumOneLineText)
            .verifyTextBoxIsHidden(false, withId: formItemTextChoiceId, atIndex: otherTextChoiceIndex)
            .verifyTextBoxValue(withId: formItemTextChoiceId, atIndex: otherTextChoiceIndex, expectedValue: Answers.loremIpsumOneLineText)
            .answerSingleChoiceTextQuestion(withId: formItemTextChoiceId , atIndex: otherTextChoiceIndex)
            .answerTextChoiceOtherQuestion(withId: formItemTextChoiceId, atIndex: otherTextChoiceIndex, text: Answers.loremIpsumOneLineText, clearIfNeeded: true)
        
            app.swipeUp()
            app.swipeUp()
        formStep
            .tap(.continueButton)
        
        let completionStep = InstructionStepScreen()
        completionStep
            .tap(.backButton)
        formStep
            .scrollToQuestionTitle(atIndex: 4)
            .verifyTextBoxValue(withId: formItemTextChoiceId, atIndex: otherTextChoiceIndex, expectedValue: Answers.loremIpsumOneLineText)
            .tap(.continueButton)

        completionStep
            .tap(.continueButton)
    }
    
    func testScaleQuestionInFormSurvey() {
        tasksList
            .selectTaskByName(Task.form.description)
        
        let formStep = FormStepScreen()
        
        let formItemIdSlider1 = "formItem03"
        let minValueSlider1 = 0
        let maxValueSlider1 = 10
        let formItemIdSlider2 = "formItem04"
        let minValueSlider2 = 1
        let maxValueSlider2 = 7
        
        // First slider
        formStep
            .scrollToQuestionTitle(atIndex: 1)
        
        for sliderValue in minValueSlider1...maxValueSlider1 {
            formStep.answerScaleQuestion(withId: formItemIdSlider1, sliderValue: Double(sliderValue), stepValue: 1, minValue: Double(minValueSlider1), maxValue: Double(maxValueSlider1))
        }
        
        // Second Text Slider
        // Scroll to second slider
        let secondSlider = formStep.getFormItemCell(withId: formItemIdSlider2).sliders.firstMatch
        secondSlider.scrollUntilVisible()
        
        for value in minValueSlider2...maxValueSlider2 {
            formStep
                .answerTextScaleQuestion(withId: formItemIdSlider2, sliderValue: Double(value), expectedSliderValue: "choice \(value)" , stepValue: 1, minValue: Double(minValueSlider2), maxValue: Double(maxValueSlider2))
        }
        
        // End Task
        formStep
            .cancelTask()
    }
    
    func testSelectAllThatApplyLabelExists() {
        tasksList
            .selectTaskByName(Task.surveyWithMultipleOptions.description)
        
        let formStep1 = FormStepScreen()
        formStep1
            .verifySelectAllThatApplyExists()
    }
    
    func testLearnMoreStepView() {
        tasksList
            .selectTaskByName(Task.groupedForm.description)
        
        let formStep = FormStepScreen()
        let learnMoreStep = formStep.tapLearnMoreButton(withIndex: 0, buttonsCount: 2)
        learnMoreStep
            .verifyLearnMoreStepView()
            .verify(.title)
            .verify(.text)
            .tapDoneButtonNavigationBar()
        
        formStep.verifyStepView()
    }
    
    func testLearnMoreButtonInSurvey() {
        tasksList
            .selectTaskByName(Task.survey.description)
        
        let instructionStep = InstructionStepScreen()
        instructionStep
            .tap(.nextButton)
        
        let questionStep = FormStepScreen()
        questionStep
            .tapLearnMoreButton(withIndex: 0, buttonsCount: 1)
            .tapDoneButtonNavigationBar()
        
        questionStep.verifyStepView()
            .cancelTask()
    }
}
