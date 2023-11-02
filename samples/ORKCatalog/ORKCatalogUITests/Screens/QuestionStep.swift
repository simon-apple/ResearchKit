//  QuestionStep.swift
//  ORKCatalogUITests
//
//  Created by Albina Kashapova on 10/25/23.
//  Copyright © 2023 researchkit.org. All rights reserved.
//

import Foundation
import XCTest

///  This class corresponds to a single screen that displays a single question (`ORKQuestionStep`)
///  https://github.com/ResearchKit/ResearchKit/blob/main/docs/Survey/CreatingSurveys-template.markdown#question-step
final class QuestionStep: AnswerableStep {
    
    static var stepView: XCUIElement {
        app.otherElements[AccessibilityIdentifiers.QuestionStep.view].firstMatch
    }
    
    static var cellQuery: XCUIElementQuery {
        return Self.stepView.cells
    }
    
    func getCell(atIndex index: Int) -> XCUIElement {
        return Self.cellQuery.element(boundBy: index).firstMatch
    }
    
    /// Verifies that step type did not change
    @discardableResult
    func verifyStepView(_ exists: Bool = true) -> Self {
        wait(for: Self.stepView, toExists: exists)
        return self
    }
    
    // MARK: - Text Choice Answer Format
    
    /**
     Verifies that we only have one cell selected across several choices/cells
     - parameter index: index that should be selected
     - parameter choices: number of choices/cells that will be verified
     */
    @discardableResult
    func verifyOnlyOneCellSelected(atIndex index: Int, expectedNumberOfTextChoices choices: Int) -> Self {
        var currentCell: XCUIElement
        for i in 0..<choices {
            currentCell = getCell(atIndex: i)
            if !currentCell.visible {
                currentCell.scrollUntilVisible()
            }
            if i == index {
                XCTAssert(currentCell.isSelected, "Cell at index \(i) should be selected")
                XCTAssert(!currentCell.label.isEmpty, "Text choice cell found to be empty")
            } else {
                XCTAssert(!currentCell.isSelected, "Cell at index \(i) should not be selected")
            }
        }
        return self
    }
    
    /// Count cells and compare with the expected count
    @discardableResult
    func assertNumOfTextChoices(_ expectedCount: Int) -> Self {
        let firstCell = getCell(atIndex: 0)
        wait(for: firstCell, toExists: true)
        let actualCount = Self.cellQuery.count
        XCTAssertEqual(actualCount, expectedCount, "Number of cell choices is not equal to expected count \(expectedCount)")
        return self
    }
}
