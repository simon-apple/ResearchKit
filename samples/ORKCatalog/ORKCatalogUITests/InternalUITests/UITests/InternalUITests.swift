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
