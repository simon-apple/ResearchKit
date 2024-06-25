//  VerificationStepScreen.swift
//  ORKCatalogUITests
//
//  Created by Albina Kashapova on 2/22/24.
//  Copyright © 2024 researchkit.org. All rights reserved.
//

import Foundation
import XCTest

final class VerificationStepScreen: Step {
    
    static var stepView: XCUIElement {
        app.descendants(matching: .any).matching(identifier: AccessibilityIdentifiers.VerificationStep.view).firstMatch
    }
    
    /// Verifies that step type did not change
    @discardableResult
    func verifyStepView(_ exists: Bool = true) -> Self {
        wait(for: Self.stepView, toExists: exists)
        return self
    }
    
    @discardableResult
    func tapResendEmailButton() -> Self {
        let firstButton = Self.stepView.buttons[AccessibilityIdentifiers.VerificationStep.resendEmailButton].firstMatch
        wait(for: firstButton)
        firstButton.tap()
        return self
    }
}
