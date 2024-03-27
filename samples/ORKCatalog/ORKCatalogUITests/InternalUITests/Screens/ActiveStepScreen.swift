//  ActiveStepScreen.swift
//  ORKCatalogUITests
//
//  Created by Albina Kashapova on 2/7/24.
//  Copyright © 2024 researchkit.org. All rights reserved.
//

import Foundation
import XCTest

final class ActiveStepScreen: Step {
    
    static var stepView: XCUIElement {
        app.otherElements[AccessibilityIdentifiers.ActiveStep.view].firstMatch
    }
    
    static var stepImage: XCUIElement {
        app.images[AccessibilityIdentifiers.ActiveStep.view].firstMatch
    }
    
    @discardableResult
    func verifyStepView(exists: Bool = true, timeout: TimeInterval = 30) -> Self {
        wait(for: Self.stepView, toExists: exists, withTimeout: timeout)
        return self
    }
    
    func stepViewExists(timeout: TimeInterval = 60) -> Bool {
        return Self.stepView.waitForExistence(timeout: timeout)
    }
    
    @discardableResult
    func verifyStepImage(exists: Bool = true) -> Self {
        wait(for: Self.stepImage, toExists: exists)
        return self
    }
}
