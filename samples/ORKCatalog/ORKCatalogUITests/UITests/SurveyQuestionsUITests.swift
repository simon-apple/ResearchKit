//  SurveyQuestionsUITests.swift
//  ORKCatalogUITests
//
//  Created by Albina Kashapova on 10/25/23.
//  Copyright © 2023 researchkit.org. All rights reserved.
//

import Foundation
import XCTest

final class SurveyQuestionsUITests: BaseUITest {
    
    let tasksList = TasksTab()
    
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
    
    /// <rdar://tsc/21847946> [Survey Questions] Boolean Question
    func testBooleanQuestion() {
        tasksList
            .selectTaskByName(Task.booleanQuestion.description)
        
        let questionStep = QuestionStep()
        let expectedNumberOfChoices = 2
        
        questionStep
            .verify(.title)
            .verify(.text)
            .verify(.skipButton, isEnabled: true)
            .verify(.continueButton, isEnabled: false)
        
            .verifyQuestionTitleExistsAndNotEmpty()
        
            .assertNumOfTextChoices(expectedNumberOfChoices)
            .verifyNoCellsSelected(expectedNumberOfChoices)
        
            .answerBooleanQuestion(atIndex: 0)
            .verifyOnlyOneCellSelected(atIndex: 0, expectedNumberOfTextChoices: expectedNumberOfChoices)
            .verify(.continueButton, isEnabled: true)
        
            .answerBooleanQuestion(atIndex: 1)
            .verifyOnlyOneCellSelected(atIndex: 1, expectedNumberOfTextChoices: expectedNumberOfChoices)
        
            .verifyContinueButtonLabel(expectedLabel: .done)
            .tap(.continueButton)
    }
    
    /// <rdar://tsc/21847947> [Survey Questions] Custom Boolean Question
    func testCustomBooleanQuestion() {
        tasksList
            .selectTaskByName(Task.customBooleanQuestion.description)
        
        let yesString = "Agree"
        let noString = "Disagree"
        let questionStep = QuestionStep()
        let expectedNumberOfChoices = 2
        
        questionStep
            .verify(.title)
            .verify(.text)
            .verify(.skipButton)
            .verify(.continueButton, isEnabled: false)
        
            .verifyQuestionTitleExistsAndNotEmpty()
            .verifyNoCellsSelected(expectedNumberOfChoices)
        
            .answerBooleanQuestion(atIndex: 0, yesString: yesString, noString: noString)
            .verifyOnlyOneCellSelected(atIndex: 0, expectedNumberOfTextChoices: expectedNumberOfChoices)
            .verify(.continueButton, isEnabled: true)
        
            .answerBooleanQuestion(atIndex: 1, yesString: yesString, noString: noString)
            .verifyOnlyOneCellSelected(atIndex: 1, expectedNumberOfTextChoices: expectedNumberOfChoices)
        
            .verifyContinueButtonLabel(expectedLabel: .done)
            .tap(.continueButton)
    }
    
    ///<rdar://tsc/21847948> [Survey Questions] Date Question
    func testDateQuestion() {
        tasksList
            .selectTaskByName(Task.dateQuestion.description)
        
        let questionStep = QuestionStep()
        questionStep
            .verify(.title)
            .verify(.text)
            .verify(.skipButton) // Optional Question
            .verify(.continueButton, isEnabled: true) // Picker value defaults to current date so continue button is enabled

            .verifyDatePickerDefaultsToCurrentDate()
            .answerDateQuestion(year: "1955", month: "February", day: "24")
            .verify(.continueButton,isEnabled: true)
    }
    
    ///<rdar://tsc/22567665> [Survey Questions] Time Interval Question
    func testTimeIntervalQuestion() {
        tasksList
            .selectTaskByName(Task.timeIntervalQuestion.description)
        let questionStep = QuestionStep()
        questionStep
            .verify(.title)
            .verify(.text)
            .verify(.skipButton) // Optional Question
            .verify(.skipButton, isEnabled: true) // Optional Question
            .verify(.continueButton,isEnabled: true)
        
        questionStep
            .answerTimeIntervalQuestion(hours: 07, minutes: 03)
            .verify(.continueButton,isEnabled: true)
            .answerTimeIntervalQuestion(hours: 23, minutes: 59)
            .verify(.continueButton,isEnabled: true)
            .tap(.continueButton)
    }
    
    ///<rdar://tsc/21847958> [Survey Questions] Text Choice Question
    func testSingleTextChoiceQuestion() {
        tasksList
            .selectTaskByName(Task.textChoiceQuestion.description)

        test("Step 1: Select an option") {
            let formStep1 = FormStep(items: ["formItem01"])
            formStep1
                .verify(.title)
                .verify(.text)
                .verify(.skipButton, exists: true)
                .verify(.skipButton, isEnabled: true)
                .verify(.continueButton, isEnabled: true)
            
                .answerSingleChoiceTextQuestion(withId: formStep1.items[0], atIndex: 2)
                .verifyOnlyOneCellSelected(withId: formStep1.items[0], atIndex: 2, cellsChoiceRange: (0,3))
                .verify(.continueButton, isEnabled: true)
                .tap(.continueButton)
        }
        
        test("Step 2: Select one or more options") {
            let formStep2 = FormStep(items: ["formItem02"])
            let indicesToSelect1 = [0, 2]
            let exclusiveChoiceIndex = [3]
            formStep2
                .verify(.title)
                .verify(.text)
                .verify(.skipButton, exists: true)
                .verify(.skipButton, isEnabled: true)
                .verify(.continueButton, isEnabled: true)
            
                .answerMultipleChoiceTextQuestion(withId: formStep2.items[0], indices: indicesToSelect1)
                .verifyMultipleCellsSelected(withId: formStep2.items[0], indices: indicesToSelect1, cellsChoiceRange: (0,3))
            
                .answerMultipleChoiceTextQuestion(withId: formStep2.items[0], indices: exclusiveChoiceIndex)
                .verifyOnlyOneCellSelected(withId: formStep2.items[0], atIndex: 3, cellsChoiceRange: (0,3))
                .tap(.continueButton)
        }
        
        let completionStep = InstructionStep()
        completionStep
            .verify(.title)
            .verifyContinueButtonLabel(expectedLabel: .done)
            .tap(.continueButton)
    }
}
