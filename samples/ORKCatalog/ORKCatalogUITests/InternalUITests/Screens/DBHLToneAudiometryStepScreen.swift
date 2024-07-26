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

final class DBHLToneAudiometryStepScreen: Step {
    
    static var stepView: XCUIElement {
        app.otherElements[AccessibilityIdentifiers.DBHLToneAudiometryStep.view].firstMatch
    }
    
    static var testProgressLabel: XCUIElement {
        app.staticTexts[AccessibilityIdentifiers.DBHLToneAudiometryStep.progressLabel]
    }
    
    static var blueCircularButton: XCUIElement {
        Self.stepView.buttons.element.firstMatch /// There is only one button on the screen view
    }
    
    @discardableResult
    func verifyStepView(exists: Bool = true) -> Self {
        wait(for: Self.stepView, toExists: exists)
        return self
    }
    
    /// Label displaying testing progress in percentage (format: "TEST IN PROGRESS • 0%")
    @discardableResult
    func verifyTestProgressLabel(exists: Bool) -> Self {
        wait(for: Self.testProgressLabel, toExists: exists)
        return self
    }
    
    /**
     - parameter progressPercentString: expected progress of test in percents ("10%")
     */
    func verifyTestProgressLabelContains(_ progressPercentString: String) -> Bool {
        let testProgressLabelValue = Self.testProgressLabel.label
        return testProgressLabelValue.contains(progressPercentString)
    }
    
    /// We tap blue button until we reach the required progress of the test ("10%")
    func tapBlueButton(maxNumberOfTaps: Int, waitForTestProgressLevel: String) {
        let blueButton =  Self.blueCircularButton
        var currentNumberOfTaps = 0
        while currentNumberOfTaps < maxNumberOfTaps {
            if verifyTestProgressLabelContains(waitForTestProgressLevel) {
                return
            }
            blueButton.doubleTap()
            sleep(3) /// Add wait here in order to progress test. As per engineers: All taps between 0-1.0 secs are invalid (can be considered as a “nervous finger” the user can be cheating) and all taps after 2.0 secs are valid and will increase the progress level of test
            currentNumberOfTaps += 1
        }
        XCTFail("After tapping the blue circular button \(maxNumberOfTaps) times, \(waitForTestProgressLevel) of test progress level not detected")
    }
    
    func tapBlueButton(maxNumberOfTaps: Int) {
        let blueButton =  Self.blueCircularButton
        var currentNumberOfTaps = 0
        while currentNumberOfTaps < maxNumberOfTaps {
            if StepComponent.nextButton.element.exists {
                return
            }
            blueButton.doubleTap()
            sleep(3) /// Add wait here in order to progress test. As per engineers: All taps between 0-1.0 secs are invalid (can be considered as a “nervous finger” the user can be cheating) and all taps after 2.0 secs are valid and will increase the progress level of test
            currentNumberOfTaps += 1
        }
        XCTFail("After tapping the blue circular button \(maxNumberOfTaps) times, next button not detected")
    }
}

