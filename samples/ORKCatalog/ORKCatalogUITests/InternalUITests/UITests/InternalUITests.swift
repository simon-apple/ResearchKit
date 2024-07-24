//  InternalUITests.swift
//  ORKCatalogUITests
//
//  Created by Albina Kashapova on 3/6/24.
//  Copyright © 2024 researchkit.org. All rights reserved.
//

import Foundation
import XCTest

#if RK_APPLE_INTERNAL
final class InternalUITests: BaseUITest {
    
    let tasksList = TasksTab()
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
    
    /// rdar://116741746 (FxHist: after selecting Yes for a minor on the conditions page, a very large space is left at the bottom below conditions, before the Done button. It was hard to find the button.)
   func testPaddingBetweenContinueButtonAndLastCell() {
       tasksList
           .selectTaskByName(Task.booleanConditionalFormTask.description)
       let formStep = FormStepScreen()
       let formItemId1 = "childFormItem"
       let formItemId2 = "childConditions"
       formStep
           .answerSingleChoiceTextQuestion(withId: formItemId1, atIndex: 0) // Triggers next form item to appear
           .answerMultipleChoiceTextQuestion(withId: formItemId2, indices: [2, 4, 12])
       app.swipeUp() // Accelerate scrolling down, a preparatory step for next method
       formStep
           .scrollTo(.continueButton)
           .verifyPaddingBetweenContinueButtonAndCell(withId: formItemId2, maximumAllowedDistance: 200.0)
           .tap(.continueButton)
   }
    
    /// rdar://tsc/26623039 ([Survey Questions] Platter UI Question)
    /// Note: Platter question does not have question title. The step title itself is a question title
    func testPlatterUIQuestion() throws {
        try XCTSkipIf(true, "Skipping this test for now. It needs to be converted to Question Step")
        tasksList
            .selectTaskByName(Task.platterUIQuestion.description)
        
        let questionStep = FormStepScreen()
        let itemId = "platterQuestionStep"
        questionStep
            .verify(.title)
            .verify(.text)
            .verify(.skipButton, isEnabled: true)
          //  .verify(.continueButton, isEnabled: expectingNextButtonEnabledByDefault)
        
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
    
    /// rdar://tsc/26029135 ([Internal] Custom Step Task)
    func testCustomStepTask() {
        tasksList
            .selectTaskByName(Task.customStepTask.description)
        
        let customStep = CustomStepScreen()
        customStep
            .verifyStepView()
            .verify(.title)
            .verify(.text)
            .verify(.detailText)
            .verifyIconImage(exists: true)
            .verifyIconImageLabel(expectedAXLabel: "clock")
        // Verify UI Labels. These strings are hardcoded in ORKCatalog app and do not require localization support
            .verifyLabelExists("Sample Label 1")
            .verifyLabelExists("Sample Label 2")
            .tap(.continueButton)
    }
    
    /// rdar://tsc/26029137 ([Internal] Study Promo View Controller)
    func testStudyPromoTask() {
        tasksList
            .selectTaskByName(Task.studyPromoTask.description)
        
        let customStep = CustomStepScreen()
        customStep
            .verifyStepView()
            .tap(.continueButton)
        // TODO: rdar://124193315 ([Blocked] Verify Content View in Study Promo View Controller). Currently it's blocked: rdar://123654451 ([Accessibility][ORKCatalog] Internal StudyPromoView - Text is not reachable in Accessibility hierarchy)
    }
}
#endif
