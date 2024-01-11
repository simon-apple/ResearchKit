//  RequestPermissionsStep.swift
//  ORKCatalogUITests
//
//  Created by Albina Kashapova on 12/18/23.
//  Copyright © 2023 researchkit.org. All rights reserved.
//

import Foundation
import XCTest

/// This class corresponds to a single screen that enables sharing the health data types to the study (`ORKRequestPermissionsStep`)
final class RequestPermissionsStep: Step {
    
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
    
    enum PermissionButtonLabel {
        case labelDefault, labelConnected
    }
    
    @discardableResult
    func verifyPermissionButton(atIndex index: Int, isEnabled: Bool) -> Self {
        let reviewPermissionButton = getPermissionButtons().element(boundBy: index)
        if !reviewPermissionButton.visible {
            reviewPermissionButton.scrollUntilVisible()
        }
        wait(for: reviewPermissionButton)
        wait(for: reviewPermissionButton, toBeEnabled: isEnabled, failureMessage: "Permission button at index \(index) is not enabled")
        return self
    }
    
    @discardableResult
    func tapPermissionButton(atIndex index: Int) -> Self {
        let reviewPermissionButton = getPermissionButtons().element(boundBy: index)
        wait(for: reviewPermissionButton)
        reviewPermissionButton.tap()
        return self
    }
    
    /// Verifies that permission button at specified index has expected label id (Default: Review or Connected: Reviewed )
    @discardableResult
    func verifyPermissionButtonLabelExists(atIndex index: Int, label: PermissionButtonLabel) -> Self {
        var reviewPermissionButtonLabel: XCUIElement
        let reviewPermissionButton = Self().getPermissionButtons().element(boundBy: index)
        switch label {
        case .labelDefault:
            reviewPermissionButtonLabel = reviewPermissionButton.staticTexts.matching(identifier: AccessibilityIdentifiers.RequestPermissionsStep.permissionButtonLabelDefault).firstMatch
        case .labelConnected:
            reviewPermissionButtonLabel = reviewPermissionButton.staticTexts.matching(identifier: AccessibilityIdentifiers.RequestPermissionsStep.permissionButtonLabelConnected).firstMatch
        }
        wait(for: reviewPermissionButtonLabel, failureMessage: "Permission button label \(PermissionButtonLabel.self)")
        return self
    }
    
    @discardableResult
    func verifyDataTypeTitle(_ title: String) -> Self {
        let dataTypeTitle = Self().getStepViewStaticTexts()[title].firstMatch
        if !dataTypeTitle.visible {
            dataTypeTitle.scrollUntilVisible()
        }
        XCTAssert(dataTypeTitle.exists)
        return self
    }
    
    @discardableResult
    func verifyDataTypeImage(_ image: String) -> Self {
        let dataTypeImage = Self().getStepViewImages()[image].firstMatch
        if !dataTypeImage.visible {
            dataTypeImage.scrollUntilVisible()
        }
        XCTAssert(dataTypeImage.exists)
        return self
    }
}
