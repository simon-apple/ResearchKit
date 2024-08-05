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

/// This class corresponds to a single screen that introduces the survey or provide instructions (`ORKInstructionStep`). Same methods used for Completion Step
///  https://github.com/ResearchKit/ResearchKit/blob/main/docs/Survey/CreatingSurveys-template.markdown#instruction-step
final class InstructionStepScreen: Step {

    static var stepView: XCUIElement {
        app.otherElements[AccessibilityIdentifiers.InstructionStep.view].firstMatch
    }
    
    /// Verifies that step type did not change
    @discardableResult
    func verifyStepView(_ exists: Bool = true) -> Self {
        wait(for: Self.stepView, toExists: exists)
        return self
    }
    
    func stepViewExists(timeout: TimeInterval) -> Bool {
        return Self.stepView.waitForExistence(timeout: timeout)
    }
    
    func verifyImage(exists: Bool = true) -> Self {
        let imageElement = Self.stepView.images.firstMatch
        wait(for: imageElement, toExists: exists)
        return self
    }
    
    func verifyImageLabel(expectedAXLabel: String) -> Self {
        let imageElement = Self.stepView.images.firstMatch
        wait(for: imageElement)
        XCTAssertEqual(imageElement.label, expectedAXLabel)
        return self
    }
    
    func verifyImageBodyItems(expectedCount: Int) -> Self {
        let firstBodyItem = Self.stepView.otherElements[AccessibilityIdentifiers.InstructionStep.bodyView].images.element(boundBy: 0)
        wait(for: firstBodyItem)
        let bodyItems = Self.stepView.otherElements[AccessibilityIdentifiers.InstructionStep.bodyView].images.count
        XCTAssertEqual(bodyItems, expectedCount, "Expected to find \(expectedCount) body items but found \(bodyItems)")
        return self
    }
    
    func getBodyItemsLabels() -> [String] {
        let staticTexts = Self.stepView.otherElements[AccessibilityIdentifiers.InstructionStep.bodyView].staticTexts.allElementsBoundByIndex
        let actualLabels = staticTexts.map {$0.label}
        return actualLabels
    }
}
