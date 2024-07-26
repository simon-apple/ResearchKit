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

final class HeadphoneDetectStepScreen: Step {
    
    lazy var settingsApp = SettingsAppScreens()
    
    static var stepView: XCUIElement {
        app.otherElements[AccessibilityIdentifiers.HeadphoneDetectStep.view].firstMatch
    }
    
    static var headphoneTypeLabelQuery: XCUIElementQuery {
        app.staticTexts.matching(identifier: AccessibilityIdentifiers.HeadphoneDetectStep.headphoneTypeLabel)
    }
    
    static var noiseCancellationRequiredLabel: XCUIElement {
        Self.stepView.staticTexts[AccessibilityIdentifiers.HeadphoneDetectStep.noiseCancellationRequiredLabel].firstMatch
    }
    
    @discardableResult
    func verifyStepView(exists: Bool = true) -> Self {
        wait(for: Self.stepView, toExists: exists)
        return self
    }
    
    @discardableResult
    func verifyNoiseCancellationRequiredLabel(exists: Bool = true) -> Self {
        wait(for: Self.noiseCancellationRequiredLabel, toExists: exists)
        return self
    }
    
    @discardableResult
    func isNoiseCancellationRequiredLabelExists() -> Bool {
        if Self.noiseCancellationRequiredLabel.waitForExistence(timeout: 20) {
            return true
        }
        return false
    }
    
    func ensureNoiseCancellationModeIsOn() {
        if isNoiseCancellationRequiredLabelExists() {
            settingsApp.turnOnAirPodsModeFromSettingsScreen(mode: .noiseCancellation)
            Self.app.activate()
        }
    }
    
    enum HeadphoneType: String {
        case airPodsMax = "AirPods Max"
        case airPodsPro = "AirPods Pro"
        case airPods = "AirPods"
        case earPods = "EarPods"
    }
    
    /// Verifies whether the headphone is connected by finding the corresponding text label
    func verifyHeadphoneConnectedLabel(headphoneType: HeadphoneType) -> Bool {
        let firstHeadphoneTypeLabel = Self.headphoneTypeLabelQuery.element(boundBy: 0)
        wait(for: firstHeadphoneTypeLabel)
        let headphoneTypeLabels = Self.app.staticTexts.matching(identifier: AccessibilityIdentifiers.HeadphoneDetectStep.headphoneTypeLabel).allElementsBoundByIndex
        for headphoneTypeLabel in headphoneTypeLabels {
            if headphoneTypeLabel.label == "\(headphoneType.rawValue) Connected" {
                return true
            }
        }
        return false
    }
    
    /// Verifies whether the headphone is connected by finding the corresponding text label. If failed verifies whether automatic ear detection is disabled
    func verifyHeadphoneIsConnected(headphoneType: HeadphoneType, enableNoiseCancellation: Bool = true) -> Self {
        guard verifyHeadphoneConnectedLabel(headphoneType: headphoneType) else {
            // If headphones are not connected we need to go to setting screen and apply required settings
            settingsApp.applyHeadphonesSettings(disableAutomaticEarDetection: true, enableNoiseCancellation: true, headphoneType: headphoneType)
            // Try to launch app again and check whether device is connected now
            Self.app.activate()
            guard verifyHeadphoneConnectedLabel(headphoneType: headphoneType) else {
                XCTFail("Headphones are not connected. Headphones should be connected to run the test")
                return self
            }
            return self
        }
        return self
    }
}
