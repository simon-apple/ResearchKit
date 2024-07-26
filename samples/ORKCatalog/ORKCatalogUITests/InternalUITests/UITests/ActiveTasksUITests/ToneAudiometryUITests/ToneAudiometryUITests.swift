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

class ToneAudiometryUITests: BaseUITest {
    
    let tasksList = TasksTab()
    
    override func setUpWithError() throws {
        app.resetAuthorizationStatus(for: .microphone)
        try super.setUpWithError()
        // Verify that before we start our test, we are on Tasks tab
        tasksList
            .assertTitle()
    }
    
    override func tearDownWithError() throws {
        if testRun?.hasSucceeded == false { return }
        // Verify that after test is completed, we end up on Tasks tab
        tasksList
            .assertTitle()
    }
    
    /// rdar://tsc/21847990 ([Active Tasks] dBHL Tone Audiometry)
    /// Verifies that no unexpected alert interrupts the test before 10% progress : rdar://118144128 (IQVIA: Pacha - Participants unable to complete Tone Exercise: Task interrupted)
    func testDBHLToneAudiometry10Percent() {
        verifyDBHLToneAudiometryTask(testProgressLevelNeeded: "10%", blueButtonTapsLimit: 12) // Usually, 8-10 taps correspond to 10% of test progress
    }
    
    /// rdar://tsc/21847990 ([Active Tasks] dBHL Tone Audiometry)
    func testDBHLToneAudiometryFullFlow() {
        verifyDBHLToneAudiometryTask(testProgressLevelNeeded: nil, blueButtonTapsLimit: 60) // Usually, 47-56 taps required to complete the test
    }
    
    // MARK: - Helpers methods
    
    // If we need full flow testProgressLevelNeeded should be nil
    func verifyDBHLToneAudiometryTask(testProgressLevelNeeded: String? = nil, blueButtonTapsLimit: Int) {
        tasksList.selectTaskByName(Task.dBHLToneAudiometry.description)
        
        // "Tone & Volume" step
        let instructionStepScreen = InstructionStepScreen()
        instructionStepScreen
            .verify(.title)
            .tap(.continueButton)
        
        // "Tone Audiometry" step
        instructionStepScreen
            .verify(.title)
            .tap(.continueButton)
        
        // "Find a Quiet Place" step
        let splMeterStepScreen = EnvironmentSPLMeterStepScreen()
        if !splMeterStepScreen.isStepViewDisplayed() {
            instructionStepScreen.tapCenterCoordinateScreen() // Required for automatic detection and handling the alert: see Helpers().monitorAlerts() method
        }
        splMeterStepScreen
            .verifyStepView(exists: true)
            .verify(.title)
            .verify(.continueButton, isEnabled: false)
            .verifyOptimumNoiseLevelLabel(exists: true, withTimeout: 40)
            .verify(.continueButton, isEnabled: true)
            .tap(.continueButton)
        
        // "Tones will play in your right ear" step
        instructionStepScreen
            .verify(.title)
            .tap(.continueButton)
        
        // "Tap the button when you hear a tone" step. Tone Audiometry test for right ear
        let dBHLToneAudiometryStepScreen = DBHLToneAudiometryStepScreen()
        dBHLToneAudiometryStepScreen
            .verifyTestProgressLabel(exists: true)
        if testProgressLevelNeeded != nil {
            dBHLToneAudiometryStepScreen
                .tapBlueButton(maxNumberOfTaps: blueButtonTapsLimit, waitForTestProgressLevel: testProgressLevelNeeded!)
            return
        }
        dBHLToneAudiometryStepScreen
            .tapBlueButton(maxNumberOfTaps: blueButtonTapsLimit)
        
        // "Tones will play in your left ear" step
        instructionStepScreen
            .tap(.continueButton)
        
        // "Tap the button when you hear a tone" step. Tone Audiometry test for left ear
        dBHLToneAudiometryStepScreen
            .verifyTestProgressLabel(exists: true)
            .tapBlueButton(maxNumberOfTaps: blueButtonTapsLimit)
        
        // Completion step
        instructionStepScreen
            .verifyContinueButtonLabel(expectedLabel: .done)
            .tap(.continueButton)
    }
}
