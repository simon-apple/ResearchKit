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

/// This class corresponds to a single screen that enables sharing the health data types to the study (`ORKRequestPermissionsStep`)
final class RequestPermissionsStepScreen: Step {
    
    static var stepView: XCUIElement {
        app.otherElements[AccessibilityIdentifiers.RequestPermissionsStep.view].firstMatch
    }
    
    /// Verifies that step type did not change
    @discardableResult
    func verifyStepView(_ exists: Bool = true) -> Self {
        wait(for: Self.stepView, toExists: exists)
        return self
    }
    
    @discardableResult
    func getStepViewStaticTexts() -> XCUIElementQuery {
        return Self.stepView.staticTexts
    }
    
    @discardableResult
    func getStepViewImages() -> XCUIElementQuery {
        return Self.stepView.images
    }
    
    @discardableResult
    func getPermissionButtons() -> XCUIElementQuery {
        return Self.stepView.otherElements.matching(identifier: AccessibilityIdentifiers.RequestPermissionsStep.permissionButton)
    }
        
    /// Verifies the number of data types by counting the buttons
    func verifyNumOfDataTypes(expectedCount: Int) {
        let permissionButtons = getPermissionButtons().count
        XCTAssertEqual(expectedCount, permissionButtons, "Failed to find this many permission buttons: \(expectedCount)")
    }
    
    enum PermissionButtonLabel: String {
        case labelDefault = "Review"
        case labelConnected = "Reviewed"
    }
    
    @discardableResult
    func verifyPermissionButton(atIndex index: Int, isEnabled: Bool) -> Self {
        let reviewPermissionButton = getPermissionButtons().element(boundBy: index)
        if !reviewPermissionButton.visible {
            reviewPermissionButton.scrollUntilVisible()
        }
        wait(for: reviewPermissionButton, withTimeout: 30)
        wait(for: reviewPermissionButton, toBeEnabled: isEnabled, failureMessage: "Permission button at index \(index) is not enabled")
        return self
    }
    
    @discardableResult
    func tapPermissionButton(atIndex index: Int) -> Self {
        let reviewPermissionButton = getPermissionButtons().element(boundBy: index)
        wait(for: reviewPermissionButton, withTimeout: 30)
        reviewPermissionButton.tap()
        return self
    }
    
    /// Verifies that permission button at specified index has expected label id (Default: Review or Connected: Reviewed )
    @discardableResult
    func verifyPermissionButtonLabelExists(atIndex index: Int, label: PermissionButtonLabel) -> Self {
        var reviewPermissionButtonLabel: XCUIElement
        let reviewPermissionButton = Self().getPermissionButtons().element(boundBy: index)
        wait(for: reviewPermissionButton, withTimeout: 30)
        switch label {
        case .labelDefault:
            reviewPermissionButtonLabel = reviewPermissionButton.staticTexts.matching(identifier: AccessibilityIdentifiers.RequestPermissionsStep.permissionButtonLabelDefault).firstMatch
        case .labelConnected:
            reviewPermissionButtonLabel = reviewPermissionButton.staticTexts.matching(identifier: AccessibilityIdentifiers.RequestPermissionsStep.permissionButtonLabelConnected).firstMatch
        }
        wait(for: reviewPermissionButtonLabel, withTimeout: 30, failureMessage: "Permission button label \(label.rawValue)")
        return self
    }
    
    @discardableResult
    func verifyDataTypeTitle(_ title: String) -> Self {
        let dataTypeTitle = Self().getStepViewStaticTexts()[title].firstMatch
        if !dataTypeTitle.visible {
            dataTypeTitle.scrollUntilVisible()
        }
        wait(for: dataTypeTitle)
        return self
    }
    
    @discardableResult
    func verifyDataTypeImage(_ image: String) -> Self {
        let dataTypeImage = Self().getStepViewImages()[image].firstMatch
        if !dataTypeImage.visible {
            dataTypeImage.scrollUntilVisible()
        }
        wait(for: dataTypeImage)
        return self
    }
}
