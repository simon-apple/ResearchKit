//  CustomStepScreen.swift
//  ORKCatalogUITests
//
//  Created by Albina Kashapova on 2/26/24.
//  Copyright © 2024 researchkit.org. All rights reserved.
//

import Foundation
import XCTest

final class CustomStepScreen: Step {
    
    static var stepView: XCUIElement {
        return app.otherElements[AccessibilityIdentifiers.CustomStep.view]
    }
    
    /// Verifies that step type did not change
    func verifyStepView(_ exists: Bool = true) -> Self {
        wait(for: Self.stepView, toExists: exists)
        return self
    }
    
    func verifyIconImage(exists: Bool = true) -> Self {
        let imageElement = Self.stepView.images.firstMatch
        wait(for: imageElement, toExists: exists)
        return self
    }
    
    func verifyIconImageLabel(expectedAXLabel: String) -> Self {
        let imageElement = Self.stepView.images.firstMatch
        wait(for: imageElement)
        XCTAssertEqual(imageElement.label, expectedAXLabel)
        return self
    }
    
    @discardableResult
    func verifyLabelExists(_ label: String) -> Self {
        let label = Self.stepView.staticTexts[label]
        wait(for: label)
        return self
    }
}
