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

final class SurveyQuestionsHealthKitIntegrationUITests: BaseUITest {
    
    let tasksList = TasksTab()
    let tabBar = TabBar()
    let sampleHeartRate = 86

    override func setUpWithError() throws {
        /// Enable writing heart rate to simulator/device via HealthKit api
        app.launchEnvironment = ["WriteHealthKitUITestData": "\(sampleHeartRate)"]
        
        /// Start with clean state. Reset authorization status for health and location
        if #available(iOS 14.0, *) { app.resetAuthorizationStatus(for: .health) }
        try super.setUpWithError()
    }
    
    // Verify answers are prefilled with HealthKit value (rdar://109472204)
    // Warning ⚠️ This test will write data to the iOS Health app
    func testHealthQuantityQuestionHearRate() {
        // Grant access to read/write Heart Rate health data
        let healthAccessScreen = HealthAccess()
        healthAccessScreen
            .verifyHealthAuthorizationView(exists: true)
            .verifyAllowButton(isEnabled: false)
            .tapAllowAllCell()
            .verifyAllowButton(isEnabled: true)
            .tapAllowButton()
        
        tasksList
            .selectTaskByName(Task.healthQuantity.description)
        
        // Grant access to read Blood Type health data
        healthAccessScreen
            .verifyHealthAuthorizationView(exists: true)
            .verifyAllowButton(isEnabled: false)
            .tapAllowAllCell()
            .verifyAllowButton(isEnabled: true)
            .tapAllowButton()
        
        let formItemId = String(describing: Identifier.healthQuantityFormItem)
        let formStep = FormStepScreen(id: String(describing: Identifier.healthQuantityFormStep1))
        
        formStep
            .verify(.title)
            .verify(.text)
            .verifySingleQuestionTitleExists()
            .verify(.continueButton, isEnabled: true) // This question is non-optional and should be prefilled with HealthKit value automatically so continue button should be enabled
        
        // TODO: rdar://124182363 [Numeric Question] Verify entered value. Currently I'm unable to verify entered value due to this issue: rdar://120826508 ([Accessibility][ORKCatalog] Unable to access cell value after entering it)
            .tap(.continueButton)
        
        // Skip 'Blood Type' Question to complete task
        formStep
            .verifyStepView()
            .tap(.skipButton)
        
        // Verify result in Results tab
        let resultsTab = tabBar.navigateToResults()
        resultsTab
            .selectResultsCell(withId: formStep.id)
            .selectResultsCell(withId: formItemId)
            .verifyResultsCellValue(resultType: .numericAnswer, expectedValue: "\(sampleHeartRate)")
    }
}
