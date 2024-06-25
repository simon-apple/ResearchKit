//  LearnMoreStepScreen.swift
//  ORKCatalogUITests
//
//  Created by Albina Kashapova on 1/17/24.
//  Copyright © 2024 researchkit.org. All rights reserved.
//

import Foundation
import XCTest

final class LearnMoreStepScreen: Step {
    
    static var stepView: XCUIElement {
        app.otherElements[AccessibilityIdentifiers.LearnMoreStep.view].firstMatch
    }
    
    /// Verifies that step type did not change
    @discardableResult
    func verifyLearnMoreStepView(_ exists: Bool = true) -> Self {
        wait(for: Self.stepView, toExists: exists)
        return self
    }
    
    func tapDoneButtonNavigationBar() {
        let doneButton = Self.app.navigationBars.buttons[AccessibilityIdentifiers.LearnMoreStep.doneButtonNavigationBar]
        wait(for: doneButton)
        doneButton.tap()
    }
}
