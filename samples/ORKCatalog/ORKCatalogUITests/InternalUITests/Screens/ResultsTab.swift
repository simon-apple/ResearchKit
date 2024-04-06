//  ResultsTab.swift
//  ORKCatalogUITests
//
//  Created by Albina Kashapova on 2/27/24.
//  Copyright © 2024 researchkit.org. All rights reserved.
//

import Foundation
import XCTest

// Settings tab on the bottom tab bar
final class ResultsTab {
    static let app = XCUIApplication()
    static var title: XCUIElement {
        app.navigationBars[AccessibilityIdentifiers.TabBar.ResultsTab.resultsTabButton].firstMatch
    }
    
    @discardableResult
    func navigateBackwardsToResults() -> Self {
        let resultsButton = Self.app.navigationBars.buttons["Results"] // Left button on navigation bar
        wait(for: resultsButton)
        resultsButton.tap()
        return self
    }
}
