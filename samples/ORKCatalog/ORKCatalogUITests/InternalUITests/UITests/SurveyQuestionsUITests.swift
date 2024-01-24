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
    
    var dismissPicker = false
    /// rdar://119572486 ([ORKCatalog] [Modularization] Survey Questions - Next button is enabled by default before user provides answers)
    let expectingNextButtonEnabledByDefault = true
    /// rdar://111132091 ([Modularization] [ORKCatalog] Date Picker won't display on the question card)
    /// This issue required extra button tap to dismiss picker to continue
    let shouldUseUIPickerWorkaround = true
    
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
        
        let questionStep = FormStep()
        let itemId = "booleanFormItem"
        let expectedNumberOfChoices = 2
        
        questionStep
            .verify(.title)
            .verify(.text)
            .verify(.skipButton, isEnabled: true)
            .verify(.continueButton, isEnabled: expectingNextButtonEnabledByDefault)
        
            .verifySingleQuestionTitleExists()
        
            .assertNumOfTextChoiceCells(withId: itemId, expectedCount: expectedNumberOfChoices)
            .verifyNoCellsSelected(withId: itemId, expectedNumberOfChoices)
        
            .answerBooleanQuestion(withId: itemId, atIndex: 0)
            .verifyOnlyOneCellSelected(withId: itemId, atIndex: 0)
            .verify(.continueButton, isEnabled: true)
        
            .answerBooleanQuestion(withId: itemId, atIndex: 1)
            .verifyOnlyOneCellSelected(withId: itemId, atIndex: 1)
        
            .verifyContinueButtonLabel(expectedLabel: .done)
            .tap(.continueButton)
    }
    
    /// <rdar://tsc/21847947> [Survey Questions] Custom Boolean Question
    func testCustomBooleanQuestion() {
        tasksList
            .selectTaskByName(Task.customBooleanQuestion.description)
        
        let questionStep = FormStep()
        let itemId = "booleanFormItem"
        let yesString = "Agree"
        let noString = "Disagree"
        let expectedNumberOfChoices = 2
        
        questionStep
            .verify(.title)
            .verify(.text)
            .verify(.skipButton)
            .verify(.continueButton, isEnabled: expectingNextButtonEnabledByDefault)
        
            .verifySingleQuestionTitleExists()
            .verifyNoCellsSelected(withId: itemId, expectedNumberOfChoices)
        
            .answerBooleanQuestion(withId: itemId, atIndex: 0, yesString: yesString, noString: noString)
            .verifyOnlyOneCellSelected(withId: itemId, atIndex: 0)
            .verify(.continueButton, isEnabled: true)
            .answerBooleanQuestion(withId: itemId, atIndex: 1, yesString: yesString, noString: noString)
            .verifyOnlyOneCellSelected(withId: itemId, atIndex: 1)

        questionStep
            .tap(.continueButton)
    }
    
    ///<rdar://tsc/21847948> [Survey Questions] Date Question
    func testDateQuestion() {
        tasksList
            .selectTaskByName(Task.dateQuestion.description)
        
        let formStep = FormStep()
        let itemId = "dateQuestionFormItem"
        formStep
            .verify(.title)
            .verify(.text)
            .verify(.skipButton) // Optional Question
            .verify(.continueButton, isEnabled: true) // Picker value defaults to current date so continue button is enabled
            .verifySingleQuestionTitleExists()
        
        if shouldUseUIPickerWorkaround {
            formStep.selectFormItemCell(withID: itemId)
            dismissPicker = true
        } else {
            formStep.verifyDatePickerDefaultsToCurrentDate()
        }
        formStep
            .answerDateQuestion(year: "1955", month: "February", day: "24", dismissPicker: dismissPicker)
            .verify(.continueButton,isEnabled: true)
            .tap(.continueButton)
    }
    
    ///<rdar://tsc/22567665> [Survey Questions] Time Interval Question
    func testTimeIntervalQuestion() {
        tasksList
            .selectTaskByName(Task.timeIntervalQuestion.description)
        let formStep = FormStep()
        let itemId = "timeIntervalFormItem"
        formStep
            .verify(.title)
            .verify(.text)
            .verify(.skipButton) // Optional Question
            .verify(.skipButton, isEnabled: true) // Optional Question
            .verify(.continueButton, isEnabled: expectingNextButtonEnabledByDefault)
            .verifySingleQuestionTitleExists()
        
        if shouldUseUIPickerWorkaround {
            formStep.selectFormItemCell(withID: itemId)
            dismissPicker = true
        }
        formStep
            .answerTimeIntervalQuestion(hours: 07, minutes: 03, dismissPicker: dismissPicker)
            .verify(.continueButton,isEnabled: true)
        sleep(5) // Allow the UI to settle for subsequent
        formStep.selectFormItemCell(withID: itemId)
            .answerTimeIntervalQuestion(hours: 23, minutes: 59, dismissPicker: dismissPicker)
            .verify(.continueButton,isEnabled: true)
            .tap(.continueButton)
    }
    
    ///<rdar://tsc/21847958> [Survey Questions] Text Choice Question
    func testSingleTextChoiceQuestion() {
        tasksList
            .selectTaskByName(Task.textChoiceQuestion.description)

        test("Step 1: Select an option") {
            let formStep1 = FormStep(itemIds: ["formItem01"])
            formStep1
                .verify(.title)
                .verify(.text)
                .verify(.skipButton, exists: true)
                .verify(.skipButton, isEnabled: true)
                .verify(.continueButton, isEnabled: expectingNextButtonEnabledByDefault)
                .verifySingleQuestionTitleExists()
            
                .answerSingleChoiceTextQuestion(withId: formStep1.itemIds[0], atIndex: 2)
                .verifyOnlyOneCellSelected(withId: formStep1.itemIds[0], atIndex: 2, cellsChoiceRange: (0,3))
                .verify(.continueButton, isEnabled: true)
                .tap(.continueButton)
        }
        
        test("Step 2: Select one or more options") {
            let formStep2 = FormStep(itemIds: ["formItem02"])
            let indicesToSelect1 = [0, 2]
            let exclusiveChoiceIndex = [3]
            formStep2
                .verify(.title)
                .verify(.text)
                .verify(.skipButton, exists: true)
                .verify(.skipButton, isEnabled: true)
                .verify(.continueButton, isEnabled: expectingNextButtonEnabledByDefault)
                .verifySingleQuestionTitleExists()
            
                .answerMultipleChoiceTextQuestion(withId: formStep2.itemIds[0], indices: indicesToSelect1)
                .verifyMultipleCellsSelected(withId: formStep2.itemIds[0], indices: indicesToSelect1, cellsChoiceRange: (0,3))
            
                .answerMultipleChoiceTextQuestion(withId: formStep2.itemIds[0], indices: exclusiveChoiceIndex)
                .verifyOnlyOneCellSelected(withId: formStep2.itemIds[0], atIndex: 3, cellsChoiceRange: (0,3))
                .tap(.continueButton)
        }
        
        let completionStep = InstructionStep()
        completionStep
            .verify(.title)
            .verifyContinueButtonLabel(expectedLabel: .done)
            .tap(.continueButton)
    }
    
    /// rdar://119274038 ([Surveys] ORKCatalog - Text Choice Question - No text box appears when selecting Other option)
    /// rdar://118204460 (ORKTextChoiceOther Improvements for Public [UI])
    /// rdar://115800919 ([Surveys] ORKCatalog - Inconsistent button/option behavior for choice with additional information text box)
    func testTextChoiceOtherQuestion() {
        tasksList
            .selectTaskByName(Task.textChoiceQuestion.description)
        
        let inputText = TextAnswers.loremIpsumShortText
        let formItemId = "formItem01"
        let otherTextChoiceIndex = 3
        
        let formStep1 = FormStep()
        formStep1
            .answerSingleChoiceTextQuestion(withId: formItemId, atIndex: 0)
            .verifyTextBoxIsHidden(true, withId: formItemId, atIndex: otherTextChoiceIndex)
            .answerSingleChoiceTextQuestion(withId: formItemId, atIndex: otherTextChoiceIndex)
            .answerTextChoiceOtherQuestion(withId: formItemId, atIndex: otherTextChoiceIndex, text: inputText)
            .verifyTextBoxIsHidden(false, withId: formItemId, atIndex: otherTextChoiceIndex)
            .verifyTextBoxValue(withId: formItemId, atIndex: otherTextChoiceIndex, expectedValue: inputText)
            .tap(.continueButton)
            .tap(.backButton)
            .verifyTextBoxIsHidden(false, withId: formItemId, atIndex: otherTextChoiceIndex)
            .verifyTextBoxValue(withId: formItemId, atIndex: otherTextChoiceIndex, expectedValue: inputText)
            .answerSingleChoiceTextQuestion(withId: formItemId, atIndex: 0)
            .tap(.continueButton)
            .tap(.backButton)
            .verifyTextBoxIsHidden(false, withId: formItemId, atIndex: otherTextChoiceIndex)
            .tap(.continueButton)
            .tap(.continueButton)
    }
    
    /// <rdar://tsc/21847958> [Survey Questions] Text Choice Question
    /// Additionally verifies placeholder value in other choice option
    func testTextChoiceOtherQuestionPlaceholderValue() {
        tasksList
            .selectTaskByName(Task.textChoiceQuestion.description)
        
        let formItemId = "formItem01"
        let otherTextChoiceIndex = 3
        
        let formStep1 = FormStep()
        formStep1
            .answerSingleChoiceTextQuestion(withId: formItemId, atIndex: 0)
            .verifyTextBoxIsHidden(true, withId: formItemId, atIndex: otherTextChoiceIndex)
            .answerSingleChoiceTextQuestion(withId: formItemId, atIndex: otherTextChoiceIndex)
            .verifyTextBoxValue(withId: formItemId, atIndex: otherTextChoiceIndex, expectedValue: "enter additional information", isPlaceholderExpected: true)
            .tap(.continueButton)
            .tap(.continueButton)
    }
    
    /// <rdar://tsc/21847961> [Survey Questions] Value Picker Choice
    func testValuePickerChoiceQuestion() {
        tasksList
            .selectTaskByName(Task.valuePickerChoiceQuestion.description)
        
       // let textChoices = ["Choice 1", "Choice 2", "Choice 3"]
        let textChoices = ["Poor", "Fair", "Good", "Above Average", "Excellent"]
        /// rdar://117821622 (Add localization support for UI Tests)
        
        let questionStep = FormStep()
        let id = "valuePickerChoiceFormItem"
        questionStep
            .verify(.title)
            .verify(.text)
            .verify(.skipButton, isEnabled: true)
            .verify(.continueButton, isEnabled: expectingNextButtonEnabledByDefault)
            .verifySingleQuestionTitleExists()
        
        for textChoice in textChoices {
            if shouldUseUIPickerWorkaround {
                questionStep
                    .selectFormItemCell(withID: id)
                dismissPicker = true
            }
            questionStep
                .answerPickerValueChoiceQuestion(value: textChoice, verifyResultValue: true, dismissPicker: dismissPicker)
                .verify(.continueButton, isEnabled: true)
            sleep(5) // Allow the UI to settle for subsequent interactions
        }
        
        questionStep
            .tap(.continueButton)
    }
    
    /// rdar://tsc/26623039 ([Survey Questions] Platter UI Question)
    /// Note: Platter question does not have question title. The step title itself is a question title
    func testPlatterUIQuestion() {
        tasksList
            .selectTaskByName(Task.platterUIQuestion.description)
        
        let questionStep = FormStep()
        let itemId = "platterQuestionStep"
        questionStep
            .verify(.title)
            .verify(.text)
            .verify(.skipButton, isEnabled: true)
            .verify(.continueButton, isEnabled: expectingNextButtonEnabledByDefault)
        
        for choiceIndex in 0..<3 {
            let uiIndex = choiceIndex + 1
            questionStep
                .answerSingleChoiceTextQuestion(withId: itemId, atIndex: choiceIndex)
                .verifyCellLabel(withId: itemId, atIndex: choiceIndex, expectedLabel: "Choice \(uiIndex), Detail")
                .verify(.continueButton, isEnabled: true)
        }
        questionStep
            .tap(.continueButton)
    }
    
    /// <rdar://tsc/21847957> [Survey Questions] Text Question
    func testTextQuestion() {
        tasksList
            .selectTaskByName(Task.textQuestion.description)
        
        let questionStep = FormStep()
        let itemId = "textQuestionFormItem"
        questionStep
            .verify(.title)
            .verify(.text)
            .verify(.skipButton, isEnabled: true)
            .verify(.continueButton, isEnabled: expectingNextButtonEnabledByDefault)
        
            .verifySingleQuestionTitleExists()
        
        questionStep
            .answerTextQuestionTextView(withId: itemId, text: TextAnswers.loremIpsumMediumText)
            .verify(.continueButton, isEnabled: true)
        
        questionStep
            .tap(.continueButton)
    }
    
    /// <rdar://tsc/21847957> [Survey Questions] Text Question
    /// Additionally verifies  placeholder value and character count indicator
    func testTextQuestionPlaceholderValueAndCharacterIndicator()  {
        tasksList
            .selectTaskByName(Task.textQuestion.description)
        
        let questionStep = FormStep()
        let itemId = "textQuestionFormItem"
   
        questionStep
            .answerTextQuestionTextView(withId: itemId, text: TextAnswers.loremIpsumMediumText, maximumLength: 280, expectedPlaceholderValue: "Tap to write") // TODO: rdar://117821622 (Add localization support for UI Tests)
            .verify(.continueButton, isEnabled: true)
        
        questionStep
            .tap(.continueButton)
    }
    
    /// <rdar://tsc/21847957> [Survey Questions] Text Question
    /// Additionally verifies editing flow
    func testTextQuestionEditing() {
        tasksList
            .selectTaskByName(Task.textQuestion.description)
        
        let questionStep = FormStep()
        let itemId = "textQuestionFormItem"
        questionStep
            .answerTextQuestionTextView(withId: itemId, text: TextAnswers.loremIpsumShortText, dismissKeyboard: false) // We don't dismiss keyboard to be able to continue editing
            .answerTextQuestionTextView(withId: itemId, text: TextAnswers.loremIpsumMediumText)
            .verify(.continueButton, isEnabled: true)
        
        questionStep
            .tap(.continueButton)
    }
    
    /// <rdar://tsc/21847957> [Survey Questions] Text Question
    /// Additionally verifies clear button
    func testTextQuestionClearButton() {
        tasksList
            .selectTaskByName(Task.textQuestion.description)
        
        let questionStep = FormStep()
        let itemId = "textQuestionFormItem"

        questionStep
            .answerTextQuestionTextView(withId: itemId, text: TextAnswers.loremIpsumShortText)
            .verify(.continueButton, isEnabled: true)
            .tapClearButton()
            .verify(.continueButton, isEnabled: expectingNextButtonEnabledByDefault)
            .answerTextQuestionTextView(withId: itemId, text: TextAnswers.loremIpsumShortText)
            .verify(.continueButton, isEnabled: true)
        
        questionStep
            .tap(.continueButton)
    }
    
    /// <rdar://tsc/21847955> [Survey Questions] Numeric Question
    func testNumericQuestions() {
        tasksList
            .selectTaskByName(Task.numericQuestion.description)
        
        let questionStep = FormStep()
        questionStep
            .verify(.title)
            .verify(.text)
            .verifySingleQuestionTitleExists()
        
        let formItemId = "numericFormItem"
        
        var randomValue = randomDecimal(withDecimalPlaces: 3)
        questionStep
            .verify(.continueButton, isEnabled: expectingNextButtonEnabledByDefault)
            .selectFormItemCell(withID: formItemId)
            .answerNumericQuestion(number: randomValue, dismissKeyboard: true)
            .verify(.continueButton, isEnabled: true)
            .tap(.continueButton)
        
        randomValue = randomDecimal(withDecimalPlaces: 3)
        questionStep
            .verify(.continueButton, isEnabled: expectingNextButtonEnabledByDefault)
            .selectFormItemCell(withID: formItemId)
            .answerNumericQuestion(number: randomValue, dismissKeyboard: true)
            .verify(.continueButton, isEnabled: true)
            .tap(.continueButton)
    
        let valueWithOneFractionalDigit = randomDecimal(withDecimalPlaces: 1)
        questionStep
            .verify(.continueButton, isEnabled: expectingNextButtonEnabledByDefault)
            .selectFormItemCell(withID: formItemId)
            .answerNumericQuestion(number: valueWithOneFractionalDigit, dismissKeyboard: true)
            .verify(.continueButton, isEnabled: true)
            .tap(.continueButton)
    }
    
    func randomDecimal(withDecimalPlaces places: Int) -> Double {
        let range: ClosedRange<Double> = 0.0 ... 500.0
        let randomDouble = Double.random(in: range)
        let multiplier = pow(10, Double(places))
        let roundedValue = (randomDouble * multiplier).rounded() / multiplier
        return roundedValue
    }
    
    /// <rdar://tsc/21847955> [Survey Questions] Numeric Question
    /// Additionally verifies editing flow
    func testNumericQuestionsEditing() {
        tasksList
            .selectTaskByName(Task.numericQuestion.description)
        let questionStep = FormStep()
        let formItemId = "numericFormItem"
        
        var randomValue = randomDecimal(withDecimalPlaces: 2)
        questionStep
            .selectFormItemCell(withID: formItemId)
            .answerNumericQuestion(number: randomValue, dismissKeyboard: true)
            .selectFormItemCell(withID: formItemId)
        randomValue = randomDecimal(withDecimalPlaces: 2)
        questionStep
            .answerNumericQuestion(number: randomValue, dismissKeyboard: true, clearIfNeeded: true)
            .tap(.continueButton)
        
        randomValue = randomDecimal(withDecimalPlaces: 1)
        questionStep
            .selectFormItemCell(withID: formItemId)
            .answerNumericQuestion(number: randomValue, dismissKeyboard: true)
            .selectFormItemCell(withID: formItemId)
        randomValue = randomDecimal(withDecimalPlaces: 1)
        questionStep
            .answerNumericQuestion(number: randomValue, dismissKeyboard: true, clearIfNeeded: true)
            .tap(.continueButton)
        
        randomValue = randomDecimal(withDecimalPlaces: 1)
        questionStep
            .selectFormItemCell(withID: formItemId)
            .answerNumericQuestion(number: randomValue, dismissKeyboard: true)
            .selectFormItemCell(withID: formItemId)
        randomValue = randomDecimal(withDecimalPlaces: 1)
        questionStep
            .answerNumericQuestion(number: randomValue, dismissKeyboard: true, clearIfNeeded: true)
            .tap(.continueButton)
    }
    
    /// rdar://115861020 ([Surveys] ORKCatalog - tapping selection with text box pushed Next and Skip buttons off screen)
    func testPaddingBetweenContinueButtonAndLastCell() {
        tasksList
            .selectTaskByName(Task.textChoiceQuestion.description)
        let formStep = FormStep()
        let formItemId = "formItem01"
        formStep
            .answerSingleChoiceTextQuestion(withId: formItemId, atIndex: 3)
        app.swipeUp() // to accelerate scrolling down, a preparatory step for next method
        formStep
            .scrollTo(.continueButton)
            .verifyPaddingBetweenContinueButtonAndCell(withId: formItemId, maximumAllowedDistance: 200.0)
    }
    
    /// rdar://tsc/21847952 ([Survey Questions] Image Choice Question)
    func testImageChoiceQuestion() {
        tasksList
            .selectTaskByName(Task.imageChoiceQuestion.description)
        
        let questionStep = FormStep()
        let formId = "imageChoiceFormItem"
        questionStep
            .verify(.title)
            .verify(.text)
            .verify(.skipButton, isEnabled: true)
            .verify(.continueButton, isEnabled: expectingNextButtonEnabledByDefault)
        
        let roundShape = FormStep.ImageButtonLabel.roundShape.rawValue
        let squareShape = FormStep.ImageButtonLabel.squareShape.rawValue
        questionStep
            .answerImageChoiceQuestion(withId: formId, imageIndex: 1, expectedLabel: roundShape)
            .answerImageChoiceQuestion(withId: formId, imageIndex: 0, expectedLabel: squareShape)
        
        questionStep
            .tap(.continueButton)
        
        questionStep
            .verify(.title)
            .verify(.text)
            .verify(.skipButton, isEnabled: true)
            .verify(.continueButton, isEnabled: expectingNextButtonEnabledByDefault)
        
        questionStep
            .answerImageChoiceQuestion(withId: formId, imageIndex: 0, expectedLabel: squareShape)
            .answerImageChoiceQuestion(withId: formId, imageIndex: 1, expectedLabel: roundShape)
    }
    
    ///rdar://tsc/21847962 ([Survey Questions] Validated Text Question)
    func testValidatedText() {
        tasksList
            .selectTaskByName(Task.validatedTextQuestion.description)
        
        let questionStep = FormStep()
        // Email validation
        let formItemId = "validatedTextFormItem"
        let name = "User"
        questionStep
            .verify(.title)
            .verify(.text)
            .verify(.skipButton, isEnabled: true)
            .verify(.continueButton, isEnabled: expectingNextButtonEnabledByDefault)
        
            .verifySingleQuestionTitleExists()
        
        questionStep
            .selectFormItemCell(withID:  formItemId)
            .answerTextQuestion(text: name, dismissKeyboard: true)
            .verify(.continueButton, isEnabled: false)
        // TODO: rdar://121345903 (Check for an error message when invalid values are entered)
        
        questionStep
            .selectFormItemCell(withID:  formItemId)
        Keyboards.deleteValueCaseSensitive(characterCount: name.count)
        
        let xKey =  app.keyboards.keys["X"]
        xKey.tap()
        // The letters keyboard is displayed, so we need to switch to the numbers keyboard in order to type "@"
        let moreKey =  app.keyboards.keys["more"]
        if moreKey.waitForExistence(timeout: 20)  {
            moreKey.tap() // switch to numbers
        }
        app.keyboards.keys["@"].tap()
        moreKey.tap() // switch to letters
        questionStep.answerTextQuestion(text: "example")
        moreKey.tap()  // switch to numbers
        app.keyboards.keys["."].tap()
        moreKey.tap()  // switch to letters
        questionStep
            .answerTextQuestion(text: "com", dismissKeyboard: true)
            .verify(.continueButton, isEnabled: true)
            .tap(.continueButton)
        
        let questionStep2 = FormStep()
        // URL validation
        let domainName = "apple.com"
        let secondLevelDomainName = String(domainName.split(separator: ".").first!)
        questionStep2
            .selectFormItemCell(withID:  formItemId)
            .answerTextQuestion(text: secondLevelDomainName, dismissKeyboard: true)
            .verify(.continueButton, isEnabled: false)
        // TODO: rdar://121345903 (Check for an error message when invalid values are entered)
        
        questionStep2
            .selectFormItemCell(withID:  formItemId)
        Keyboards.deleteValueCaseSensitive(characterCount: secondLevelDomainName.count)
        // The period "." and ".com" are displayed along with the letters, so there is no need to switch to the numbers keyboard
        questionStep2.answerTextQuestion(text: domainName,  dismissKeyboard: true)
            .verify(.continueButton, isEnabled: true)
            .tap(.continueButton)
    }
}
