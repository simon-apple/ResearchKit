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
