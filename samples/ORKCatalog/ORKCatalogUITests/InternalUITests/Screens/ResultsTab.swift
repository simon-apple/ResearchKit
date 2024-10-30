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
        cellToSelect.scrollToVisible()
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
    
    @discardableResult
    func verifyResultsCellContainsValue(resultType: AccessibilityIdentifiers.ResultRow, expectedValue: String) -> Self {
        let cellToSelect = Self.app.cells.staticTexts[resultType.detailTextLabelIdentifier]
        wait(for: cellToSelect)
        XCTAssertTrue(cellToSelect.label.contains(expectedValue), "The cell label \(cellToSelect.label) does not contain \(expectedValue)")
        return self
    }
    
    @discardableResult
    func verifyNoChildResults() -> Self {
        XCTAssertTrue(Self.app.cells.staticTexts[AccessibilityIdentifiers.ResultsTab.noChildResults].visible, "'No child results.' expected but not found.")
        return self
    }
}
