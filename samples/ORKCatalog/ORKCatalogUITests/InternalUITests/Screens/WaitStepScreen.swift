//  WaitStepScreen.swift
//  ORKCatalogUITests
//
//  Created by Albina Kashapova on 2/6/24.
//  Copyright © 2024 researchkit.org. All rights reserved.
//

import Foundation
import XCTest

final class WaitStepScreen: Step {
    
    static var stepView: XCUIElement {
        app.otherElements[AccessibilityIdentifiers.WaitStep.view].firstMatch
    }
    
    /// Verifies that step type did not change
    @discardableResult
    func verifyStepView(_ exists: Bool = true) -> Self {
        wait(for: Self.stepView, toExists: exists)
        return self
    }
    
    @discardableResult
    func verifyActivityIndicator(exists: Bool = true) -> Self {
        let activityIndicator = Self.stepView.activityIndicators.firstMatch
        wait(for: activityIndicator, toExists: exists)
        return self
    }
    
     /// - parameter expectedValue:: for  'In progress' value should be "1"
    @discardableResult
    func verifyActivityIndicatorValue(expectedValue: String) -> Self {
        let activityIndicator = Self.stepView.activityIndicators.firstMatch
        activityIndicator.verifyElementValue(expectedValue: expectedValue)
        return self
    }
    
    @discardableResult
    func verifyProgressIndicator(exists: Bool = true) -> Self {
        let activityIndicator = Self.stepView.progressIndicators.firstMatch
        wait(for: activityIndicator, toExists: exists)
        return self
    }
}
