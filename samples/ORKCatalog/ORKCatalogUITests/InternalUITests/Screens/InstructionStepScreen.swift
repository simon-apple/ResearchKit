//  InstructionStepScreen.swift
//  ORKCatalogUITests
//
//  Created by Albina Kashapova on 10/25/23.
//  Copyright © 2023 researchkit.org. All rights reserved.
//

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
}
