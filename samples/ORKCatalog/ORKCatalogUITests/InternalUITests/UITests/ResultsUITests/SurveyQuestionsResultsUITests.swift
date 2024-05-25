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
import CoreLocation

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
        
        let questionStep = FormStepScreen(id: String(describing: Identifier.booleanFormStep), itemIds: [String(describing: Identifier.booleanFormItem)])
        
        if let answerCellIndex = answerCellIndex {
            questionStep
                .answerBooleanQuestion(withId: questionStep.itemIds[0], atIndex: answerCellIndex)
                .tap(.continueButton)
        } else {
            questionStep
                .tap(.skipButton)
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
        
        let formStep = FormStepScreen(id: String(describing: Identifier.booleanFormStep), itemIds: [String(describing: Identifier.booleanFormItem)])
        
        if let answerCellIndex = answerCellIndex {
            formStep
                .answerSingleChoiceTextQuestion(withId: formStep.itemIds[0], atIndex: answerCellIndex)
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
     - parameter singleChoiceExpectedValue/multiChoiceExpectedValue: expected value in results tab
     - parameter inputText: text that is entered in other choice textfield when selected
     */
    func answerAndVerifyTextChoiceQuestionTask(singleChoiceAnswerIndex: Int?, multiChoiceAnswerIndex: [Int]?, singleChoiceExpectedValue: String, multiChoiceExpectedValue: String, inputText: String?) {
        
        tasksList.selectTaskByName(Task.textChoiceQuestion.description)
        
        let formStep1 = FormStepScreen(id: String(describing: Identifier.formStep), itemIds: [String(describing: Identifier.formItem01)])
        let formStep2 = FormStepScreen(id: String(describing: Identifier.formStep02), itemIds: [String(describing: Identifier.formItem02)])
        
        // Answer question in form step 1
        if let singleChoiceAnswerIndex = singleChoiceAnswerIndex {
            formStep1
                .answerSingleChoiceTextQuestion(withId: formStep1.itemIds[0], atIndex: 0) /// Adding extra check for single choice question: selecting first index before next one
                .answerSingleChoiceTextQuestion(withId: formStep1.itemIds[0], atIndex: singleChoiceAnswerIndex)
            if let inputText = inputText {
                formStep1.answerTextChoiceOtherQuestion(withId: formStep1.itemIds[0], atIndex: singleChoiceAnswerIndex, text: inputText)
            }
            formStep1.tap(.continueButton)
        } else {
            formStep1.tap(.skipButton)
        }
        
        // Answer question in form step 2
        if let multiChoiceAnswerIndex = multiChoiceAnswerIndex {
            formStep2
                .answerMultipleChoiceTextQuestion(withId: formStep2.itemIds[0], indices: multiChoiceAnswerIndex)
            if let inputText = inputText {
                formStep2.answerTextChoiceOtherQuestion(withId: formStep2.itemIds[0], atIndex: multiChoiceAnswerIndex[0], text: inputText)
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
        
        let formStep = FormStepScreen(id: String(describing: Identifier.textChoiceFormStep), itemIds: [String(describing: Identifier.textChoiceFormItem)])
        
        if let answerCellIndex = answerCellIndex {
            formStep
                .verifyStepView()
                .answerSingleChoiceTextQuestion(withId: formStep.itemIds[0], atIndex: answerCellIndex)
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
    
    // MARK: - Image Choice Question
    
    func answerAndVerifyImageChoiceQuestionTask(singleChoiceAnswerIndex: Int?, multiChoiceAnswerIndex: [Int]?, singleChoiceExpectedValue: String, multiChoiceExpectedValue: String) {
        tasksList.selectTaskByName(Task.imageChoiceQuestion.description)
        
        let formStep1 = FormStepScreen(id: String(describing: Identifier.imageChoiceFormStep1), itemIds: [String(describing: Identifier.imageChoiceFormItem)])
        let formStep2 = FormStepScreen(id: String(describing: Identifier.imageChoiceFormStep2), itemIds: [String(describing: Identifier.imageChoiceFormItem)])
        
        if let singleChoiceAnswerIndex = singleChoiceAnswerIndex {
            formStep1
                .verifyStepView()
                .answerImageChoiceQuestion(withId: formStep1.itemIds[0], imageIndex: 0)
                .answerImageChoiceQuestion(withId: formStep1.itemIds[0], imageIndex: singleChoiceAnswerIndex)
                .tap(.continueButton)
        } else {
            formStep1.tap(.skipButton)
        }
        
        if let multiChoiceAnswerIndex = multiChoiceAnswerIndex {
            formStep2.verifyStepView()
            for index in multiChoiceAnswerIndex {
                formStep2.answerImageChoiceQuestion(withId: formStep2.itemIds[0], imageIndex: index)
            }
            formStep2.tap(.continueButton)
        } else {
            formStep2.tap(.skipButton)
        }
        
        let resultsTab = tabBar.navigateToResults()
        resultsTab
            .selectResultsCell(withId: formStep1.id)
            .selectResultsCell(withId: formStep1.itemIds[0])
            .verifyResultsCellValue(resultType: .choices, expectedValue: singleChoiceExpectedValue)
            .navigateToResultsStepBack()
            .navigateToResultsStepBack()
        
            .selectResultsCell(withId: formStep2.id)
            .selectResultsCell(withId: formStep2.itemIds[0])
            .verifyResultsCellValue(resultType: .choices, expectedValue: multiChoiceExpectedValue)
    }
    
    func testImageChoiceQuestionResult() {
        let roundShape = FormStepScreen.ImageButtonLabel.roundShape.rawValue
        let squareShape = FormStepScreen.ImageButtonLabel.squareShape.rawValue
        
        answerAndVerifyImageChoiceQuestionTask(singleChoiceAnswerIndex: 1, multiChoiceAnswerIndex: [0, 1], singleChoiceExpectedValue: "[\(roundShape)]", multiChoiceExpectedValue: "[\(roundShape), \(squareShape)]")
    }
    
    func testImageChoiceQuestionSkipResult() {
        answerAndVerifyImageChoiceQuestionTask(singleChoiceAnswerIndex: nil, multiChoiceAnswerIndex: nil, singleChoiceExpectedValue: "nil", multiChoiceExpectedValue: "nil")
    }
    
    // MARK: - Text Question
    
    func answerAndVerifyTextQuestionTask(textAnswer: String?, expectedValue: String) {
        tasksList.selectTaskByName(Task.textQuestion.description)
        
        let formStep = FormStepScreen(id: String(describing: Identifier.textQuestionFormStep), itemIds: [String(describing: Identifier.textQuestionFormItem)])
        
        if let textAnswer = textAnswer {
            formStep
                .answerTextQuestionTextView(withId: formStep.itemIds[0], text: textAnswer)
                .tap(.continueButton)
        } else {
            formStep.tap(.skipButton)
        }
        
        let resultsTab = tabBar.navigateToResults()
        resultsTab
            .selectResultsCell(withId: formStep.id)
            .selectResultsCell(withId: formStep.itemIds[0])
            .verifyResultsCellValue(resultType: .textAnswer, expectedValue: expectedValue)
    }
    
    func testTextQuestionResult() {
        let inputText = Answers.loremIpsumMediumText
        answerAndVerifyTextQuestionTask(textAnswer: inputText, expectedValue: inputText)
    }
    
    func testTextQuestionSkipResult() {
        answerAndVerifyTextQuestionTask(textAnswer: nil, expectedValue: "nil")
    }
    
    // MARK: - Numeric Question
    
    func answerAndVerifyNumericQuestionTask(answer: Double?, expectedValue: String) {
        tasksList.selectTaskByName(Task.numericQuestion.description)
        
        let formItemId = String(describing: Identifier.numericFormItem)
        let formStep1 = FormStepScreen(id: String(describing: Identifier.numericQuestionFormStep), itemIds: [formItemId])
        let formStep2 = FormStepScreen(id: String(describing: Identifier.numericNoUnitQuestionFormStep), itemIds: [formItemId])
        let formStep3 = FormStepScreen(id:  String(describing: Identifier.numericDisplayUnitQuestionFormStep), itemIds: [formItemId])
        
        if let answer = answer {
            formStep1
                .selectFormItemCell(withID: formItemId)
                .answerNumericQuestion(number: answer, dismissKeyboard: true)
                .tap(.continueButton)
            
            formStep2
                .selectFormItemCell(withID: formItemId)
                .answerNumericQuestion(number: answer, dismissKeyboard: true)
                .tap(.continueButton)
            
            formStep3
                .selectFormItemCell(withID: formItemId)
                .answerNumericQuestion(number: answer, dismissKeyboard: true)
                .tap(.continueButton)
            
        } else {
            formStep1
                .selectFormItemCell(withID: formItemId) /// Adding extra check:  verify that the answer is not saved after it is entered and then skipped it
                .answerNumericQuestion(number: Double(1), dismissKeyboard: true)
                .tap(.skipButton)
            formStep2.tap(.skipButton)
            formStep3.tap(.skipButton)
        }
        
        let resultsTab = tabBar.navigateToResults()
        resultsTab
            .selectResultsCell(withId: formStep1.id)
            .selectResultsCell(withId: formStep1.itemIds[0])
            .verifyResultsCellValue(resultType: .numericAnswer, expectedValue: expectedValue)
            .verifyResultsCellValue(resultType: .unit, expectedValue: "Your unit")
            .verifyResultsCellValue(resultType: .displayUnit, expectedValue: "Your unit")
            .navigateToResultsStepBack()
            .navigateToResultsStepBack()
        
            .selectResultsCell(withId: formStep2.id)
            .selectResultsCell(withId: formStep2.itemIds[0])
            .verifyResultsCellValue(resultType: .numericAnswer, expectedValue: expectedValue)
            .verifyResultsCellValue(resultType: .unit, expectedValue: "nil")
            .verifyResultsCellValue(resultType: .displayUnit, expectedValue: "nil")
            .navigateToResultsStepBack()
            .navigateToResultsStepBack()
        
            .selectResultsCell(withId: formStep3.id)
            .selectResultsCell(withId: formStep3.itemIds[0])
            .verifyResultsCellValue(resultType: .numericAnswer, expectedValue: expectedValue)
            .verifyResultsCellValue(resultType: .unit, expectedValue: "weeks")
            .verifyResultsCellValue(resultType: .displayUnit, expectedValue: "semanas")
    }
    
    func testNumericQuestionResults() {
        let numericAnswer = 123.1
        answerAndVerifyNumericQuestionTask(answer: numericAnswer, expectedValue: String(numericAnswer))
    }
    
    func testNumericQuestionSkipResults() {
        answerAndVerifyNumericQuestionTask(answer: nil, expectedValue: "nil")
    }
    
    // MARK: - Value Picker Question
    
    func answerAndVerifyValuePickerQuestion(answer: String?, expectedValue: String) {
        tasksList.selectTaskByName(Task.valuePickerChoiceQuestion.description)
        
        let formStep = FormStepScreen(id: String(describing: Identifier.valuePickerChoiceFormStep), itemIds: [String(describing: Identifier.valuePickerChoiceFormItem)])
        
        /// This issue required extra button tap to dismiss picker to continue rdar://111132091 ([Modularization] [ORKCatalog] Date Picker won't display on the question card)
        let shouldUseUIPickerWorkaround = true
        
        if let answer = answer {
            var dismissPicker = false
            if shouldUseUIPickerWorkaround {
                formStep.selectFormItemCell(withID: formStep.itemIds[0])
                dismissPicker = true
            }
            formStep
                .answerPickerValueChoiceQuestion(value: answer, dismissPicker: dismissPicker)
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
    
    func testValuePickerChoiceQuestionMinResult() {
        let choiceIndex = 0
        answerAndVerifyValuePickerQuestion(answer: textChoices[choiceIndex].text, expectedValue: textChoices[choiceIndex].value)
    }
    
    func testValuePickerChoiceQuestionMaxResult() {
        let choiceIndex = 4
        answerAndVerifyValuePickerQuestion(answer: textChoices[choiceIndex].text, expectedValue: textChoices[choiceIndex].value)
    }
    
    func testValuePickerChoiceQuestionSkipResult() {
        answerAndVerifyValuePickerQuestion(answer: nil, expectedValue: "nil")
    }
    
    // MARK: - Location Question
    
    func answerAndVerifyLocationQuestionTask(locationAnswer: (locationString: String, latitude: Double, longitude: Double)?, expectedValue: (locationString: String, latitude: String, longitude: String)) {
        
        tasksList.selectTaskByName(Task.locationQuestion.description)
        
        let formStep = FormStepScreen(id: String(describing: Identifier.locationQuestionFormStep))
        let formItemId = String(describing: Identifier.locationQuestionFormItem)
        
        if let location = locationAnswer {
            formStep
                .tap(.title) /// Required for automatic detection and handling the location alert: see Helpers().monitorAlerts() method
                .verifyCellTextFieldValue(withId: formItemId, expectedValue: location.locationString)
                .tap(.continueButton)
        } else {
            formStep
                .tap(.skipButton)
        }
        
        let resultsTab = tabBar.navigateToResults()
        resultsTab
            .selectResultsCell(withId: formStep.id)
            .selectResultsCell(withId: formItemId)
            .verifyResultsCellValue(resultType: .latitude, expectedValue: expectedValue.latitude)
            .verifyResultsCellValue(resultType: .longitude, expectedValue: expectedValue.longitude)
            .verifyResultsCellValue(resultType: .address, expectedValue: expectedValue.locationString)
    }
    
    func testLocationQuestionResult() {
        let simulatedLocation = (locationString: "Geary St San Francisco CA 94102 United States", latitude: 37.787354, longitude: -122.408243)
        let simulatedLocationResultString = "Geary St\nSan Francisco CA 94102\nUnited States"
        
        /// https://developer.apple.com/documentation/xcode/simulating-location-in-tests
        if #available(iOS 16.4, *) {
            XCUIDevice.shared.location = XCUILocation(location: CLLocation(latitude: simulatedLocation.latitude, longitude: simulatedLocation.longitude))
        }
        
        answerAndVerifyLocationQuestionTask(locationAnswer: (locationString: simulatedLocation.locationString, latitude: simulatedLocation.latitude, longitude: simulatedLocation.longitude), expectedValue: (locationString: simulatedLocationResultString, latitude: "\(simulatedLocation.latitude)", longitude: "\(simulatedLocation.longitude)"))
    }
    
    func testLocationQuestionSkipResult() throws {
        try XCTSkipIf(true, "Skipping this test for now due to crash after skipping question (126589758)") /// rdar://126589758 ([ORKCatalog] App crash when viewing location question result in Results tab after skipping question)
        
        answerAndVerifyLocationQuestionTask(locationAnswer: nil, expectedValue: (locationString: "nil", latitude: "nil", longitude: "nil"))
    }
    
    // MARK: - Validated Text Question
    
    func answerAndVerifyValidatedTextQuestionTask(emailAnswer: String?, domainAnswer: String?, expectedEmail: String, expectedDomain: String) {
        tasksList.selectTaskByName(Task.validatedTextQuestion.description)
        
        let formItemId = String(describing: Identifier.validatedTextFormItem)
        // Email Step
        let formStep1 = FormStepScreen(id: String(describing: Identifier.validatedTextFormStepEmail), itemIds: [formItemId])
        // URL Step
        let formStep2 = FormStepScreen(id: String(describing: Identifier.validatedTextFormStepDomain), itemIds: [formItemId])
        
        if let email = emailAnswer, let domain = domainAnswer {
            formStep1
                .selectFormItemCell(withID: formStep1.itemIds[0])
                .typeEmail(email: email)
                .tap(.continueButton)
            
            formStep2
                .selectFormItemCell(withID: formStep2.itemIds[0])
                .answerTextQuestion(text: domain, dismissKeyboard: true)
                .tap(.continueButton)
        } else {
            formStep1
                .tap(.skipButton)
                .tap(.skipButton)
        }
        
        let resultsTab = tabBar.navigateToResults()
        resultsTab
            .selectResultsCell(withId: formStep1.id)
            .selectResultsCell(withId: formStep1.itemIds[0])
            .verifyResultsCellValue(resultType: .textAnswer, expectedValue: expectedEmail)
            .navigateToResultsStepBack()
            .navigateToResultsStepBack()
        
            .selectResultsCell(withId: formStep2.id)
            .selectResultsCell(withId: formStep2.itemIds[0])
            .verifyResultsCellValue(resultType: .textAnswer, expectedValue: expectedDomain)
    }
    
    func testValidatedTextQuestionResult() {
        let email = Answers.exampleEmailCapitalized
        let url = Answers.exampleDomainName
        answerAndVerifyValidatedTextQuestionTask(emailAnswer: email, domainAnswer: url, expectedEmail: email, expectedDomain: url)
    }
    
    func testValidatedTextQuestionSkipResult() {
        answerAndVerifyValidatedTextQuestionTask(emailAnswer: nil, domainAnswer: nil, expectedEmail: "nil", expectedDomain: "nil")
    }
    
    // MARK: - Scale Question
    
    enum ScaleValue {
        case maxValue, minValue, middleValue
        
        var getSliderValues: [Double] {
            switch self {
            case .maxValue:
                return formStepsSliderValues.map {$0.maxValue}
            case .minValue:
                return formStepsSliderValues.map {$0.minValue}
            case .middleValue:
                return formStepsSliderValues.map {$0.midValue}
            }
        }
    }
    
    // Scale control with 10 discrete ticks
    func answerDiscreteScaleFormStep(answer: ScaleValue, stepIndex: Int, formStep: FormStepScreen = FormStepScreen(), formItemId: String) {
        let currentSliderMinValue = formStepsSliderValues[stepIndex].minValue
        let currentSliderMaxValue = formStepsSliderValues[stepIndex].maxValue
        let currentSliderMidValue = formStepsSliderValues[stepIndex].midValue
        
        switch answer {
        case .maxValue:
            formStep.answerScaleQuestion(withId: formItemId, sliderValue: currentSliderMaxValue, stepValue: defaultStep, minValue: currentSliderMinValue, maxValue: currentSliderMaxValue)
        case .middleValue:
            formStep.answerScaleQuestion(withId: formItemId, sliderValue: currentSliderMidValue, stepValue: defaultStep, minValue: currentSliderMinValue, maxValue: currentSliderMaxValue)
        case .minValue:
            // In order to adjust slider to min value, we need to move it first
            formStep
                .answerScaleQuestion(withId: formItemId, sliderValue: currentSliderMidValue, stepValue: defaultStep, minValue: currentSliderMinValue, maxValue: currentSliderMaxValue)
                .answerScaleQuestion(withId: formItemId, sliderValue: currentSliderMinValue, stepValue: defaultStep, minValue: currentSliderMinValue, maxValue: currentSliderMaxValue)
        }
    }
    
    // Scale control that allows continuous movement with a percent formatter
    func answerContinuousScaleFormStep(answer: ScaleValue, stepIndex: Int, formStep: FormStepScreen = FormStepScreen(), formItemId: String) {
        let currentSliderMinValue = formStepsSliderValues[stepIndex].minValue
        let currentSliderMaxValue = formStepsSliderValues[stepIndex].maxValue
        let currentSliderMidValue = formStepsSliderValues[stepIndex].midValue
        
        switch answer {
        case .maxValue:
            formStep.answerScaleQuestionPercentStyle(withId: formItemId, sliderValue: Int(currentSliderMaxValue), stepValue: defaultStep, minValue: currentSliderMinValue, maxValue: currentSliderMaxValue)
        case .middleValue:
            formStep.answerScaleQuestionPercentStyle(withId: formItemId, sliderValue: Int(currentSliderMidValue), stepValue: defaultStep, minValue: currentSliderMinValue, maxValue: currentSliderMaxValue)
        case .minValue:
            // In order to adjust slider to min value, we need to move it first
            formStep.answerScaleQuestionPercentStyle(withId: formItemId, sliderValue: Int(currentSliderMidValue), stepValue: defaultStep, minValue: currentSliderMinValue, maxValue: currentSliderMaxValue)
            formStep.answerScaleQuestionPercentStyle(withId: formItemId, sliderValue: Int(currentSliderMinValue), stepValue: defaultStep, minValue: currentSliderMinValue, maxValue: currentSliderMaxValue)
        }
    }
    
    // Vertical scale control with 10 discrete ticks
    func answerDiscreteVerticalScaleFormStep(answer: ScaleValue, stepIndex: Int, formStep: FormStepScreen = FormStepScreen(), formItemId: String) {
        let currentSliderMinValue = formStepsSliderValues[stepIndex].minValue
        let currentSliderMaxValue = formStepsSliderValues[stepIndex].maxValue
        
        switch answer {
        case .maxValue:
            formStep.adjustVerticalSliderToEndPosition(withId: formItemId, expectedValue: currentSliderMaxValue)
        case .minValue:
            // In order to adjust slider to min value, we need to move it first
            formStep
                .adjustVerticalSlider(withId: formItemId, dx: 0.5, dy: 0.5)
                .adjustVerticalSliderToStartPosition(withId: formItemId, expectedValue: currentSliderMinValue)
        case .middleValue:
            formStep
                .adjustVerticalSlider(withId: formItemId, dx: 0.5, dy: 0.5)
        }
    }
    
    // Vertical scale control that allows continuous movement
    func answerContinuousVerticalScaleFormStep(answer: ScaleValue, stepIndex: Int, formStep: FormStepScreen = FormStepScreen(), formItemId: String) {
        let currentSliderMinValue = formStepsSliderValues[stepIndex].minValue
        let currentSliderMaxValue = formStepsSliderValues[stepIndex].maxValue
        
        switch answer {
        case .maxValue:
            formStep.adjustVerticalSliderToEndPosition(withId: formItemId, expectedValue: currentSliderMaxValue)
        case .minValue:
            // In order to adjust slider to min value, we need to move it first
            formStep
                .adjustVerticalSlider(withId: formItemId, dx: 0.5, dy: 0.5)
                .adjustVerticalSliderToStartPosition(withId: formItemId, expectedValue: currentSliderMinValue)
        case .middleValue:
            formStep
                .adjustVerticalSlider(withId: formItemId, dx: 0.5, dy: 0.5)
        }
    }
    
    // Scale control that allows text choices
    func answerTextScaleFormStep(answer: ScaleValue, stepIndex: Int, formStep: FormStepScreen = FormStepScreen(), formItemId: String) {
        let currentSliderMinValue = formStepsSliderValues[stepIndex].minValue
        let currentSliderMaxValue = formStepsSliderValues[stepIndex].maxValue
        let currentSliderMidValue = formStepsSliderValues[stepIndex].midValue
        
        switch answer {
        case .maxValue:
            formStep
                .answerTextScaleQuestion(withId: formItemId, sliderValue: currentSliderMaxValue, expectedSliderValue: textValues[4], stepValue: defaultStep, minValue: currentSliderMinValue, maxValue: currentSliderMaxValue)
        case .minValue:
            // In order to adjust slider to min value, we need to move it first
            formStep
                .answerTextScaleQuestion(withId: formItemId, sliderValue: currentSliderMidValue, expectedSliderValue: textValues[2], stepValue: defaultStep, minValue: currentSliderMinValue, maxValue: currentSliderMaxValue)
                .answerTextScaleQuestion(withId: formItemId, sliderValue: currentSliderMinValue, expectedSliderValue: textValues[0], stepValue: defaultStep, minValue: currentSliderMinValue, maxValue: currentSliderMaxValue)
        case .middleValue:
            formStep
                .answerTextScaleQuestion(withId: formItemId, sliderValue: currentSliderMidValue, expectedSliderValue: textValues[2], stepValue: defaultStep, minValue: currentSliderMinValue, maxValue: currentSliderMaxValue)
        }
    }
    
    // Vertical scale control that allows text choices
    func answerVerticalTextScaleFormStep(answer: ScaleValue, stepIndex: Int, formStep: FormStepScreen = FormStepScreen(), formItemId: String) {
        switch answer {
        case .maxValue:
            formStep
                .adjustVerticalSliderToEndPosition(withId: formItemId, expectedValue: textValues[4])
        case .minValue:
            // In order to adjust slider to min value, we need to move it first
            formStep
                .adjustVerticalSlider(withId: formItemId, dx: 0.5, dy: 0.5)
                .adjustVerticalSliderToStartPosition(withId: formItemId, expectedValue: textValues[0])
        case .middleValue:
            formStep
                .adjustVerticalSlider(withId: formItemId, dx: 0.5, dy: 0.5)
        }
    }
    
    func navigateAndAnswerScaleTask(answer: ScaleValue?, expectedValues: [String]) {
        tasksList.selectTaskByName(Task.scaleQuestion.description)
        
        let formItemId = String(describing: Identifier.scaleFormItem)
        let discreteScale = String(describing: Identifier.discreteScaleFormStep)
        let continuousScale = String(describing: Identifier.continuousScaleFormStep)
        let discreteVerticalScale = String(describing: Identifier.discreteVerticalScaleFormStep)
        let continuousVerticalScale = String(describing: Identifier.continuousVerticalScaleFormStep)
        let textScale = String(describing: Identifier.textScaleFormStep)
        let textVerticalScale = String(describing: Identifier.textVerticalScaleFormStep)
        let formStep0 = FormStepScreen(id: discreteScale)
        let formStep1 = FormStepScreen(id: continuousScale)
        let formStep2 = FormStepScreen(id: discreteVerticalScale)
        let formStep3 = FormStepScreen(id: continuousVerticalScale)
        let formStep4 = FormStepScreen(id: textScale)
        let formStep5 = FormStepScreen(id: textVerticalScale)
        
        let task = [formStep0, formStep1, formStep2, formStep3, formStep4, formStep5]
        
        if let answer = answer {
            for formStep in task {
                switch formStep.id {
                case discreteScale:
                    answerDiscreteScaleFormStep(answer: answer, stepIndex: 0, formItemId: formItemId)
                case continuousScale:
                    answerContinuousScaleFormStep(answer: answer, stepIndex: 1, formItemId: formItemId)
                case discreteVerticalScale:
                    answerDiscreteVerticalScaleFormStep(answer: answer, stepIndex: 2, formItemId: formItemId)
                case continuousVerticalScale:
                    answerContinuousVerticalScaleFormStep(answer: answer, stepIndex: 3, formItemId: formItemId)
                case textScale:
                    answerTextScaleFormStep(answer: answer, stepIndex: 4, formItemId: formItemId)
                case textVerticalScale:
                    answerVerticalTextScaleFormStep(answer:answer, stepIndex: 5, formItemId: formItemId)
                default:
                    XCTFail("Unknown step id")
                }
                formStep.tap(.continueButton)
            }
        } else {
            for formStep in task {
                formStep
                    .verifyStepView()
                    .tap(.skipButton)
            }
        }
        
        let resultsTab = tabBar.navigateToResults()
            .selectResultsCell(withId: formStep0.id)
            .selectResultsCell(withId: formItemId)
            .verifyResultsCellValue(resultType: .scaleAnswer, expectedValue: expectedValues[0])
            .navigateToResultsStepBack()
            .navigateToResultsStepBack()
        
            .selectResultsCell(withId: formStep1.id)
            .selectResultsCell(withId: formItemId)
            .verifyResultsCellValue(resultType: .scaleAnswer, expectedValue: expectedValues[1])
            .navigateToResultsStepBack()
            .navigateToResultsStepBack()
        
            .selectResultsCell(withId: formStep2.id)
            .selectResultsCell(withId: formItemId)
            .verifyResultsCellValue(resultType: .scaleAnswer, expectedValue: expectedValues[2])
            .navigateToResultsStepBack()
            .navigateToResultsStepBack()
        
            .selectResultsCell(withId: formStep3.id)
            .selectResultsCell(withId: formItemId)
        if answer == .middleValue {
            // Currently there is no way to get consistent results for vertical slider due to screen sizes affecting result. Workaround is used
            resultsTab.verifyResultsCellStartsWithValue(resultType: .scaleAnswer, expectedValue: expectedValues[3])
        } else {
            resultsTab.verifyResultsCellValue(resultType: .scaleAnswer, expectedValue: expectedValues[3])
        }
        resultsTab
            .navigateToResultsStepBack()
            .navigateToResultsStepBack()
        
            .selectResultsCell(withId: formStep4.id)
            .selectResultsCell(withId: formItemId)
            .verifyResultsCellValue(resultType: .choices, expectedValue: expectedValues[4])
            .navigateToResultsStepBack()
            .navigateToResultsStepBack()
        
            .selectResultsCell(withId: formStep5.id)
            .selectResultsCell(withId: formItemId)
            .verifyResultsCellValue(resultType: .choices, expectedValue:  expectedValues[5])
            .navigateToResultsStepBack()
            .navigateToResultsStepBack()
    }
    
    func testScaleQuestionMaxValueResults() {
        let expectedValues = formStepsSliderResultValues.map { $0.maxValue }
        navigateAndAnswerScaleTask(answer: .maxValue, expectedValues: expectedValues)
    }
    
    func testScaleQuestionMinValueResults() {
        let expectedValues = formStepsSliderResultValues.map { $0.minValue }
        navigateAndAnswerScaleTask(answer: .minValue, expectedValues: expectedValues)
    }
    
    func testScaleQuestionMidValueResults() {
        let expectedValues = formStepsSliderResultValues.map { $0.midValue }
        navigateAndAnswerScaleTask(answer: .middleValue, expectedValues: expectedValues)
    }
    
    func testScaleQuestionSkipResults() {
        let expectedValues = Array(repeating: "nil", count: formStepsSliderResultValues.count)
        navigateAndAnswerScaleTask(answer: nil, expectedValues: expectedValues)
    }
}
