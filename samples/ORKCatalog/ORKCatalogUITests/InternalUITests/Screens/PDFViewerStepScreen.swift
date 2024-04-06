//  PDFViewerStepScreen.swift
//  ORKCatalogUITests
//
//  Created by Albina Kashapova on 2/24/24.
//  Copyright © 2024 researchkit.org. All rights reserved.
//

import Foundation
import XCTest

final class PDFViewerStepScreen: Step {
    
    static var stepView: XCUIElement {
        app.otherElements[AccessibilityIdentifiers.PDFViewerStep.view].firstMatch
    }
    
    /// Verifies that step type did not change
    @discardableResult
    func verifyStepView(_ exists: Bool = true) -> Self {
        wait(for: Self.stepView, toExists: exists)
        return self
    }
    
    enum PDFViewerButton {
        case showPDFThumbnailActionButton, hidePDFThumbnailActionButton, annotationActionButton, showSearchActionButton, hideSearchActionButton, shareActionButton, exitButton, applyButton, clearButton
        
        var identifier: String {
            switch self {
            case .showPDFThumbnailActionButton:
                AccessibilityIdentifiers.PDFViewerStep.showPDFThumbnailActionButton
            case .hidePDFThumbnailActionButton:
                AccessibilityIdentifiers.PDFViewerStep.hidePDFThumbnailActionButton
            case .annotationActionButton:
                AccessibilityIdentifiers.PDFViewerStep.annotationActionButton
            case .showSearchActionButton:
                AccessibilityIdentifiers.PDFViewerStep.showSearchActionButton
            case .hideSearchActionButton:
                AccessibilityIdentifiers.PDFViewerStep.hideSearchActionButton
            case .shareActionButton:
                AccessibilityIdentifiers.PDFViewerStep.shareActionButton
            case .exitButton:
                AccessibilityIdentifiers.PDFViewerStep.exitButton
            case .applyButton:
                AccessibilityIdentifiers.PDFViewerStep.applyButton
            case .clearButton:
                AccessibilityIdentifiers.PDFViewerStep.clearButton
            }
        }
        
        var element: XCUIElement {
            switch self {
            case .showPDFThumbnailActionButton, .hidePDFThumbnailActionButton, .annotationActionButton, .showSearchActionButton, .hideSearchActionButton, .shareActionButton:
                return stepView.buttons[self.identifier].firstMatch
            case .applyButton, .clearButton, .exitButton:
                return stepView.otherElements[self.identifier].firstMatch
            }
        }
    }
    
    @discardableResult
    func verify(_ button: PDFViewerButton, exists: Bool = true) -> Self {
        let additionalFailureMessage = "PDFViewerStep button: \(button), button identifier:  \(button.identifier)"
        wait(for: button.element, toExists: exists, failureMessage: additionalFailureMessage)
        return self
    }
    
    @discardableResult
    func tap(_ button: PDFViewerButton) -> Self {
        let buttonElement = button.element
        wait(for: buttonElement)
        buttonElement.tap()
        return self
    }
    
    // Draws a line in annotation mode
    @discardableResult
    func drawLine() -> Self {
        let startCoordinate = Self.stepView.coordinate(withNormalizedOffset: CGVector(dx: 0.3, dy: 0.3))
        let endCoordinate = Self.stepView.coordinate(withNormalizedOffset: CGVector(dx: 0.6, dy: 0.6))
        startCoordinate.press(forDuration: 3, thenDragTo: endCoordinate)
        return self
    }
    
    @discardableResult
    func verifySearchField(exists: Bool) -> Self {
        let searchField = Self.stepView.searchFields.firstMatch
        wait(for: searchField, toExists: exists)
        return self
    }
    
    @discardableResult
    func enterTextInSearchField(_ text: String) -> Self {
        let searchField = Self.stepView.searchFields.firstMatch
        wait(for: searchField)
        searchField.tap()
        Keyboards.enterText(text)
        return self
    }
    
    @discardableResult
    func verifyPopUpTitle(displayed: Bool) -> Self {
        let sendPDFTitle = Self.app.otherElements["sendPDF"] // 'sendPDF' text is hardcoded in ORKCatalog, so no localization support needed
        wait(for: sendPDFTitle, toExists: displayed)
        return self
    }
    
    @discardableResult
    func closePopUp() -> Self {
        let closeButton = Self.app.navigationBars["UIActivityContentView"].buttons.firstMatch
        wait(for: closeButton)
        closeButton.tap()
        return self
    }
    
    func verifyLabelExist(expectedText: String) {
        let elements = Self.stepView.otherElements.allElementsBoundByIndex
        let actualLabels = elements.map {$0.label}
        let textExists = actualLabels.contains(expectedText)
        XCTAssertTrue(textExists, "Text \(expectedText) does not exist")
    }
    
    func verifyValueExists(expectedValue: String) {
        let elements = Self.stepView.otherElements.allElementsBoundByIndex
        let actualValues = elements.compactMap {$0.value as? String}.filter { !$0.isEmpty }
        let valueExists = actualValues.contains(expectedValue)
        XCTAssertTrue(valueExists, "Value \(expectedValue) does not exist")
    }
}
