//  ResultsTab.swift
//  ORKCatalogUITests
//
//  Created by Albina Kashapova on 2/27/24.
//  Copyright © 2024 researchkit.org. All rights reserved.
//

import Foundation
import XCTest

// Results tab on the bottom tab bar
final class ResultsTab {
    static let app = XCUIApplication()
    static var title: XCUIElement {
        app.navigationBars[AccessibilityIdentifiers.TabBar.ResultsTab.resultsTabButton].firstMatch
    }
    
    @discardableResult
    func navigateToResultsStepBack() -> Self {
        let resultsButton = Self.app.navigationBars.buttons[AccessibilityIdentifiers.TabBar.ResultsTab.resultsTabButton]
        wait(for: resultsButton)
        resultsButton.tap()
        return self
    }
    
    /**
     Selects cell based on id
     - parameter id: The string that identifies step identifier or form item identifier
     */
    @discardableResult
    func selectResultsCell(withId id: String) -> Self {
        let cellToSelect = Self.app.cells.staticTexts[id]
        wait(for: cellToSelect)
        cellToSelect.tap()
        return self
    }
    
    /// Verifies result data for different question types
    @discardableResult
    func verifyResultsCellValue(resultType: AccessibilityIdentifiers.ResultRow, expectedValue: String) -> Self {
        let cellToSelect = Self.app.cells.staticTexts[resultType.detailTextLabelIdentifier]
        wait(for: cellToSelect)
        XCTAssertEqual(cellToSelect.label, expectedValue)
        return self
    }
    
    @discardableResult
    func verifyResultsCellStartsWithValue(resultType: AccessibilityIdentifiers.ResultRow, expectedValue: String) -> Self {
        let cellToSelect = Self.app.cells.staticTexts[resultType.detailTextLabelIdentifier]
        wait(for: cellToSelect)
        XCTAssertTrue(cellToSelect.label.starts(with: expectedValue))
        return self
    }
}
