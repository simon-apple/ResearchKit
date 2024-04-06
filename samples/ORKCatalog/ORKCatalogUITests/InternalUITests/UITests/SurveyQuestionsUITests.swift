//  SurveyQuestionsUITests.swift
//  ORKCatalogUITests
//
//  Created by Albina Kashapova on 10/25/23.
//  Copyright © 2023 researchkit.org. All rights reserved.
//

import Foundation
import XCTest
import CoreLocation

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
        
        let questionStep = FormStepScreen()
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
        
        let questionStep = FormStepScreen()
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
        
        let formStep = FormStepScreen()
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
        let formStep = FormStepScreen()
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
            let formStep1 = FormStepScreen(itemIds: ["formItem01"])
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
            let formStep2 = FormStepScreen(itemIds: ["formItem02"])
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
        
        let completionStep = InstructionStepScreen()
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
        
        let inputText = Answers.loremIpsumShortText
        let formItemId = "formItem01"
        let otherTextChoiceIndex = 3
        
        let formStep1 = FormStepScreen()
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
        
        let formStep1 = FormStepScreen()
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
        
        let questionStep = FormStepScreen()
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
    
    /// <rdar://tsc/21847957> [Survey Questions] Text Question
    func testTextQuestion() {
        tasksList
            .selectTaskByName(Task.textQuestion.description)
        
        let questionStep = FormStepScreen()
        let itemId = "textQuestionFormItem"
        questionStep
            .verify(.title)
            .verify(.text)
            .verify(.skipButton, isEnabled: true)
            .verify(.continueButton, isEnabled: expectingNextButtonEnabledByDefault)
        
            .verifySingleQuestionTitleExists()
        
        questionStep
            .answerTextQuestionTextView(withId: itemId, text: Answers.loremIpsumMediumText)
            .verify(.continueButton, isEnabled: true)
        
        questionStep
            .tap(.continueButton)
    }
    
    /// <rdar://tsc/21847957> [Survey Questions] Text Question
    /// Additionally verifies  placeholder value and character count indicator
    func testTextQuestionPlaceholderValueAndCharacterIndicator()  {
        tasksList
            .selectTaskByName(Task.textQuestion.description)
        
        let questionStep = FormStepScreen()
        let itemId = "textQuestionFormItem"
   
        questionStep
            .answerTextQuestionTextView(withId: itemId, text: Answers.loremIpsumMediumText, maximumLength: 280, expectedPlaceholderValue: "Tap to write") // TODO: rdar://117821622 (Add localization support for UI Tests)
            .verify(.continueButton, isEnabled: true)
        
        questionStep
            .tap(.continueButton)
    }
    
    /// <rdar://tsc/21847957> [Survey Questions] Text Question
    /// Additionally verifies editing flow
    func testTextQuestionEditing() {
        tasksList
            .selectTaskByName(Task.textQuestion.description)
        
        let questionStep = FormStepScreen()
        let itemId = "textQuestionFormItem"
        questionStep
            .answerTextQuestionTextView(withId: itemId, text: Answers.loremIpsumShortText, dismissKeyboard: false) // We don't dismiss keyboard to be able to continue editing
            .answerTextQuestionTextView(withId: itemId, text: Answers.loremIpsumMediumText)
            .verify(.continueButton, isEnabled: true)
        
        questionStep
            .tap(.continueButton)
    }
    
    /// <rdar://tsc/21847957> [Survey Questions] Text Question
    /// Additionally verifies clear button
    func testTextQuestionClearButton() {
        tasksList
            .selectTaskByName(Task.textQuestion.description)
        
        let questionStep = FormStepScreen()
        let itemId = "textQuestionFormItem"

        questionStep
            .answerTextQuestionTextView(withId: itemId, text: Answers.loremIpsumShortText)
            .verify(.continueButton, isEnabled: true)
            .tapClearButton()
            .verify(.continueButton, isEnabled: expectingNextButtonEnabledByDefault)
            .answerTextQuestionTextView(withId: itemId, text: Answers.loremIpsumShortText)
            .verify(.continueButton, isEnabled: true)
        
        questionStep
            .tap(.continueButton)
    }
    
    /// <rdar://tsc/21847955> [Survey Questions] Numeric Question
    func testNumericQuestions() {
        tasksList
            .selectTaskByName(Task.numericQuestion.description)
        
        let questionStep = FormStepScreen()
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
        let questionStep = FormStepScreen()
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
        let formStep = FormStepScreen()
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
        
        let questionStep = FormStepScreen()
        let formId = "imageChoiceFormItem"
        questionStep
            .verify(.title)
            .verify(.text)
            .verify(.skipButton, isEnabled: true)
            .verify(.continueButton, isEnabled: expectingNextButtonEnabledByDefault)
        
        let roundShape = FormStepScreen.ImageButtonLabel.roundShape.rawValue
        let squareShape = FormStepScreen.ImageButtonLabel.squareShape.rawValue
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
    func testValidatedTextQuestion() {
        tasksList
            .selectTaskByName(Task.validatedTextQuestion.description)
        
        // Email validation
        let questionStep = FormStepScreen()
        let formItemId = "validatedTextFormItem"
        let username = "X"
        questionStep
            .verify(.title)
            .verify(.text)
            .verify(.skipButton, isEnabled: true)
            .verify(.continueButton, isEnabled: expectingNextButtonEnabledByDefault)
        
            .verifySingleQuestionTitleExists()
        
        questionStep
            .selectFormItemCell(withID:  formItemId)
            .answerTextQuestion(text: username, dismissKeyboard: true)
            .verify(.continueButton, isEnabled: false)
            .verifyErrorMessage(exists: true, withId: formItemId, expectedMessage: " Invalid Email") // Observed behavior: The error message label begins with a space. Also this error message is hardcoded in ORKCatalog app and does not require localization support
        
        questionStep
            .selectFormItemCell(withID:  formItemId)
        Keyboards.deleteValue(characterCount: username.count, keyboardType: .alphabetic)
        
        app.keyboards.keys[username].tap()
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
            .verifyErrorMessage(exists: false, withId: formItemId, expectedMessage: " Invalid Email")
            .tap(.continueButton)
        
        // URL validation
        let questionStep2 = FormStepScreen()
        let domainName = "apple.com"
        let secondLevelDomainName = String(domainName.split(separator: ".").first!)
        questionStep2
            .selectFormItemCell(withID:  formItemId)
            .answerTextQuestion(text: secondLevelDomainName, dismissKeyboard: true)
            .verify(.continueButton, isEnabled: false)
            .verifyErrorMessage(exists: true, withId: formItemId, expectedMessage: " Invalid URL") // Observed behavior: The error message label begins with a space. Also this error message is hardcoded in ORKCatalog app and does not require localization support
        
        questionStep2
            .selectFormItemCell(withID:  formItemId)
        Keyboards.deleteValue(characterCount: secondLevelDomainName.count, keyboardType: .alphabetic)
        // The period "." and ".com" are displayed along with the letters, so there is no need to switch to the numbers keyboard
        questionStep2.answerTextQuestion(text: domainName,  dismissKeyboard: true)
            .verify(.continueButton, isEnabled: true)
            .verifyErrorMessage(exists: false, withId: formItemId, expectedMessage: " Invalid URL")
            .tap(.continueButton)
    }
    
    /// <rdar://tsc/21847956> [Survey Questions] Scale Question
    func testScaleQuestion() {
        tasksList
            .selectTaskByName(Task.scaleQuestion.description)
        
        let questionStep = FormStepScreen()
        let formItemId = "scaleFormItem"
        
        // The first step is a scale control with 10 discrete ticks
        questionStep
            .verify(.title)
            .verify(.text)
            .verify(.skipButton, isEnabled: true)
            .verify(.continueButton, isEnabled: expectingNextButtonEnabledByDefault)
            .verifySingleQuestionTitleExists()
        
        for value in 1...10 {
            questionStep
                .answerScaleQuestion(withId: formItemId, sliderValue: Double(value), stepValue: 1, minValue: 1, maxValue: 10)
                .verify(.continueButton, isEnabled: true)
        }
        questionStep
            .tap(.continueButton)
        
        // The second step is a scale control that allows continuous movement with a percent formatter.
        questionStep
            .verify(.title)
            .verify(.text)
            .verify(.skipButton, isEnabled: true)
            .verify(.continueButton, isEnabled: expectingNextButtonEnabledByDefault)
            .verifySingleQuestionTitleExists()
        
        // It only barely works for specific values, such as 50% and 100% and required several retries, for other values it does not work due to the issue where slider won't reach the expected value. XCTest radar: rdar://122248912
        let sliderValues2 = [50, 100]
        for value in sliderValues2 {
            questionStep
                .answerScaleQuestionPercentStyle(withId: formItemId, sliderValue: value, stepValue: 1, minValue: 0, maxValue: 100)
                .verify(.continueButton, isEnabled: true)
        }
        questionStep
            .tap(.continueButton)
        
        // The third step is a vertical scale control with 10 discrete ticks.
        questionStep
            .verify(.title)
            .verify(.text)
            .verify(.skipButton, isEnabled: true)
            .verify(.continueButton, isEnabled: expectingNextButtonEnabledByDefault)
            .verifySingleQuestionTitleExists()
        
        // Can not verify slider value due to this radar XCTest radar: rdar://122248912
        questionStep
            .answerVerticalScaleQuestion(withId: formItemId, expectedSliderValue: 3, dx: 0.5, dy: 0.8)
            .answerVerticalScaleQuestion(withId: formItemId, expectedSliderValue: 4, dx: 0.5, dy: 0.7)
            .answerVerticalScaleQuestion(withId: formItemId, expectedSliderValue: 6, dx: 0.5, dy: 0.5)
            .answerVerticalScaleQuestion(withId: formItemId, expectedSliderValue: 8, dx: 0.5, dy: 0.3)
            .adjustVerticalSliderToEndPosition(withId: formItemId, expectedValue: 10)
            .tap(.continueButton)
        
        // The fourth step is a vertical scale control that allows continuous movement.
        questionStep
            .verify(.title)
            .verify(.text)
            .verify(.skipButton, isEnabled: true)
            .verify(.continueButton, isEnabled: expectingNextButtonEnabledByDefault)
            .verifySingleQuestionTitleExists()
        
            .adjustVerticalSlider(withId: formItemId, dx: 0.5, dy: 0.5)
            .adjustVerticalSlider(withId: formItemId, dx: 0.5, dy: 0.2)
            .adjustVerticalSliderToEndPosition(withId: formItemId, expectedValue: 5)
            .tap(.continueButton)
        
        // The fifth step is a scale control that allows text choices.
        let textChoices = ["Poor", "Fair", "Good", "Above Average", "Excellent"]
        questionStep
            .verify(.title)
            .verify(.text)
            .verify(.skipButton, isEnabled: true)
            .verify(.continueButton, isEnabled: expectingNextButtonEnabledByDefault)
            .verifySingleQuestionTitleExists()
        
        for value in 1...5 {
            questionStep
                .answerTextScaleQuestion(withId: formItemId, sliderValue: Double(value), expectedSliderValue: textChoices[value-1] , stepValue: 1, minValue: 1, maxValue: 5)
        }
        questionStep.tap(.continueButton)
        
        // The sixth step is a vertical scale control that allows text choices.
        questionStep
            .verify(.title)
            .verify(.text)
            .verify(.skipButton, isEnabled: true)
            .verify(.continueButton, isEnabled: expectingNextButtonEnabledByDefault)
            .verifySingleQuestionTitleExists()
        
            .adjustVerticalSlider(withId: formItemId, dx: 0.5, dy: 0.8)
            .verifySliderValue(withId: formItemId, expectedValue: textChoices[1])
        
            .adjustVerticalSlider(withId: formItemId, dx: 0.5, dy: 0.55)
            .verifySliderValue(withId: formItemId, expectedValue: textChoices[2])
        
            .adjustVerticalSlider(withId: formItemId, dx: 0.5, dy: 0.3)
            .verifySliderValue(withId: formItemId, expectedValue: textChoices[3])
        
            .adjustVerticalSliderToEndPosition(withId: formItemId, expectedValue: textChoices[4])
        
            .tap(.continueButton)
    }
    
    ///rdar://tsc/21847953 ([Survey Questions] Location Question) - Happy Path
    func testLocationQuestion() {
        /// https://developer.apple.com/documentation/xcode/simulating-location-in-tests
        if #available(iOS 16.4, *) {
            XCUIDevice.shared.location = XCUILocation(location: CLLocation(latitude: 37.787354, longitude: -122.408243))
        }
        
        tasksList
            .selectTaskByName(Task.locationQuestion.description)
        
        let questionStep = FormStepScreen()
        let formId = "locationQuestionFormItem"
        let simulatedLocation = "Geary St San Francisco CA 94102 United States" // This is simulated location configured in RegressionUITests test plan in "Simulated location" settings
        let validAddressExample = "One Apple Park Way"
        questionStep
            .verify(.title)
            .tap(.title) /// Required for automatic detection and handling the location alert: see Helpers().monitorAlerts() method
            .verify(.text)
            .verifySingleQuestionTitleExists()
            .verifyCellTextFieldValue(withId: formId, expectedValue: simulatedLocation)
            .verifyMapExists(withId: formId)
            .verifyLocationPinIconExists(withId: formId)
            .verify(.continueButton, isEnabled: true)
        
            .selectFormItemCell(withID: formId)
            .clearTextFieldWithXButton(withId: formId) // We need to use X button to clear text because we can not delete it normally due to cursor being in the beginning of string on selection
            .enterTextInTextField(withId: formId, text: validAddressExample, dismissKeyboard: true)
            .verify(.continueButton, isEnabled: true)
            .verifyAlert(exists: false)  /// Checking for "Could not Find Specified Address" alert
            .tap(.continueButton)
    }
    
    /// rdar://tsc/21847953 ([Survey Questions] Location Question) - Negative Path
    func testLocationQuestionInvalidAddress() {
        /// https://developer.apple.com/documentation/xcode/simulating-location-in-tests
        if #available(iOS 16.4, *) {
            XCUIDevice.shared.location = XCUILocation(location: CLLocation(latitude: 37.787354, longitude: -122.408243))
        }
        
        tasksList
            .selectTaskByName(Task.locationQuestion.description)
        
        let questionStep = FormStepScreen()
        let formId = "locationQuestionFormItem"
        let invalidAddress = "Hello"
        
        questionStep
            .verify(.title)
            .tap(.title) /// Required for automatic detection and handling the location alert: see Helpers().monitorAlerts() method
            .selectFormItemCell(withID: formId)
            .clearTextFieldWithXButton(withId: formId)
            .enterTextInTextField(withId: formId, text: invalidAddress, dismissKeyboard: true)
            .verify(.continueButton, isHittable: false)
            .verifyAlert(exists: true) /// Checking for "Could not Find Specified Address" alert
            .tapAlertFirstButton()
            .tap(.continueButton)
    }
    
    /// <rdar://tsc/25376929> [Survey Questions] Text Choice Image Question
    func testTextChoiceImage() {
        tasksList
            .selectTaskByName(Task.textChoiceQuestionWithImageTask.description)
        
        let questionStep = FormStepScreen()
        let formItemId = "textChoiceFormItem"
        let expectedNumberOfChoices = 3
        
        questionStep
            .verify(.title)
            .verify(.text)
            .verify(.skipButton, isEnabled: true)
            .verify(.continueButton, isEnabled: expectingNextButtonEnabledByDefault)
            .verifySingleQuestionTitleExists()
            .verifyNoCellsSelected(withId: formItemId, expectedNumberOfChoices)
        
        for i in 0..<expectedNumberOfChoices {
            questionStep
                .answerSingleChoiceTextQuestion(withId: formItemId, atIndex: i)
                .verifyOnlyOneCellSelected(withId: formItemId, atIndex: i)
                .verify(.continueButton, isEnabled: true)
        }
        
       // TODO: rdar://123531714 (Text Choice Image Question - verify images can be expanded). It's currently blocked by: rdar://120743593 ([ORKCatalog] [Modularization] Unable to expand images in Text Choice Image Question)
        
        questionStep
            .tap(.continueButton)
    }
    
    /// rdar://tsc/33942324 ([Survey Questions] Color Choice Question)
    func testColorChoiceQuestion() {
        tasksList
            .selectTaskByName(Task.colorChoiceQuestion.description)
        
        let questionStep = FormStepScreen()
        let formItemId = "colorChoiceQuestionFormItem"
        let expectedNumOfChoicesStep1 = 7
        
        questionStep
            .verify(.title)
            .verify(.text)
            .verify(.skipButton, isEnabled: true)
            .verify(.continueButton, isEnabled: expectingNextButtonEnabledByDefault)
            .verifySingleQuestionTitleExists()
            .verifyNoCellsSelected(withId: formItemId, expectedNumOfChoicesStep1)
        
        for i in 0..<expectedNumOfChoicesStep1 {
            questionStep
                .answerSingleChoiceTextQuestion(withId: formItemId, atIndex: i)
                .verifyOnlyOneCellSelected(withId: formItemId, atIndex: i)
                .verify(.continueButton, isEnabled: true)
        }
        
        questionStep
            .tap(.continueButton)
        
        let expectedNumOfChoicesStep2 = 6
        questionStep
            .verify(.title)
            .verify(.text)
            .verify(.skipButton, isEnabled: true)
            .verify(.continueButton, isEnabled: expectingNextButtonEnabledByDefault)
            .verifySingleQuestionTitleExists()
            .verifyNoCellsSelected(withId: formItemId, expectedNumOfChoicesStep2)
        
        for i in 0..<expectedNumOfChoicesStep2 {
            questionStep
                .answerSingleChoiceTextQuestion(withId: formItemId, atIndex: i)
                .verifyOnlyOneCellSelected(withId: formItemId, atIndex: i, cellShouldContainImage: true) // In this question cell contains image not text
                .verify(.continueButton, isEnabled: true)
        }
        
        questionStep
            .tap(.continueButton)
    }
}
