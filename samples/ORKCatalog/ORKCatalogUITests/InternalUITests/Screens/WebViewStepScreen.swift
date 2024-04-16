//  WebViewStepScreen.swift
//  ORKCatalogUITests
//
//  Created by Albina Kashapova on 2/13/24.
//  Copyright © 2024 researchkit.org. All rights reserved.
//

import Foundation
import XCTest

final class WebViewStepScreen: Step {
    
    static var view: XCUIElement {
        Self.app.webViews.firstMatch
    }
    
    static var continueButton: XCUIElement {
        Self.app.buttons.beginning(with: AccessibilityIdentifiers.Step.continueButton).firstMatch
    }
    
    static var nextButton: XCUIElement {
        Self.app.buttons[AccessibilityIdentifiers.Step.nextButton].firstMatch
    }
    
    static var signatureView: XCUIElement {
        Self.app.otherElements[AccessibilityIdentifiers.WebView.signatureView].firstMatch
    }
    
    static var clearSignature: XCUIElement {
        Self.app.buttons[AccessibilityIdentifiers.WebView.signatureViewClearButton].firstMatch
    }
    
    @discardableResult
    func verifyView(exists: Bool = true) -> Self {
        let webView = Self.view
        wait(for: webView, toExists: exists, withTimeout: 40)
        return self
    }
    
    @discardableResult
    func verifySignatureView(exists: Bool = true) -> Self {
        let signatureView = Self.signatureView
        wait(for: signatureView)
        return self
    }
    
    func tapClearSignature() -> Self {
        let clearButton = Self.clearSignature
        wait(for: clearButton)
        clearButton.tap()
        return self
    }
    
    @discardableResult
    func scrollUpToSignatureView(maxSwipes: Int = 15) -> Self {
        let signatureView = Self.signatureView
        if !signatureView.visible {
            signatureView.scrollUntilVisible(direction: .up, maxSwipes: maxSwipes)
        }
        return self
    }
    
    @discardableResult
    func drawSignature() -> Self {
        let startCoordinate = Self.signatureView.coordinate(withNormalizedOffset: CGVector(dx: 0.3, dy: 0.3))
        let endCoordinate = Self.signatureView.coordinate(withNormalizedOffset: CGVector(dx: 0.6, dy: 0.6))
        startCoordinate.press(forDuration: 3, thenDragTo: endCoordinate)
        return self
    }
    
    @discardableResult
    func verifyNumOfImages(expectedCount: Int) -> Self {
        let images = Self.app.webViews.images
        XCTAssertEqual(images.count, 2, "Number of web view images is not equal to \(expectedCount)")
        return self
    }
    
    @discardableResult
    func verifyWebViewLabelsExist(expectedLabels: [String]) -> Self {
        let staticTexts = Self.app.webViews.staticTexts.allElementsBoundByIndex
        let actualLabels = staticTexts.map {$0.label}
        for expectedLabel in expectedLabels {
            let labelExists = actualLabels.contains(expectedLabel)
            XCTAssertTrue(labelExists, "The label \(expectedLabel) does not exist")
        }
        return self
    }
}
