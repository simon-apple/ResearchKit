//  PasscodeStepScreen.swift
//  ORKCatalogUITests
//
//  Created by Albina Kashapova on 2/12/24.
//  Copyright © 2024 researchkit.org. All rights reserved.
//

import Foundation
import XCTest

final class PasscodeStepScreen: Step {
    
    static var stepView: XCUIElement {
        app.otherElements[AccessibilityIdentifiers.PasscodeStep.view].firstMatch
    }
    
    /// Verifies that step type did not change
    @discardableResult
    func verifyStepView(_ exists: Bool = true) -> Self {
        wait(for: Self.stepView, toExists: exists)
        return self
    }
    
    @discardableResult
    func verifyImage(exists: Bool = true) -> Self {
        let imageElement = Self.stepView.images.firstMatch
        wait(for: imageElement, toExists: exists)
        return self
    }
}
