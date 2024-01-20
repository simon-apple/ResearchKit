//  HealthAccess.swift
//  ORKCatalogUITests
//
//  Created by Albina Kashapova on 1/10/24.
//  Copyright © 2024 researchkit.org. All rights reserved.
//

import Foundation
import XCTest

/// Health Authorization Screen
final class HealthAccess: Step {
    
    static var healthAccessView: XCUIElement {
        app.navigationBars["Health Access"].firstMatch
    }
    
    /// Don't Allow button that is located on navigation bar
    static var cancelButton: XCUIElement  {
        if #available(iOS 17, *) {
            return healthAccessView.buttons["UIA.Health.AuthSheet.CancelButton"]
        } else {
            return healthAccessView.buttons.element(boundBy: 0) /// "Don't Allow" Button is the first button ("Allow" Button is positioned as the second button)
        }
    }
    
    /// Allow button that is located on navigation bar
    static var allowButton: XCUIElement  {
        if #available(iOS 17, *) {
            return healthAccessView.buttons["UIA.Health.AuthSheet.DoneButton"]
        } else {
            return healthAccessView.buttons.element(boundBy: 1) /// "Allow" button is the second button ("Don't Allow" Button is positioned as the first button)
        }
    }
    
    static var allowAllCell: XCUIElement  {
        if #available(iOS 17, *) {
            return app.cells["UIA.Health.AuthSheet.AllCategoryButton"]
        } else {
            return app.cells.staticTexts["Turn On All"].firstMatch
        }
    }
    
    func verifyHealthAuthorizationView(exists: Bool) -> Self {
        wait(for: Self.healthAccessView, toExists: exists, withTimeout: 40)
        return self
    }
    
    func verifyAllowButton(isEnabled: Bool) -> Self {
        wait(for: Self.allowButton, toBeEnabled: isEnabled, failureMessage: "Allow button is not enabled")
        return self
    }
    
    func tapAllowButton() {
        Self.allowButton.tap()
    }
    
    func tapAllowAllCell() -> Self {
        wait(for: Self.allowAllCell)
        Self.allowAllCell.tap()
        return self
    }
    
    enum HealthKitDataType {
        case weight
        case height
        
        var switchCell: XCUIElement {
            switch self {
            case .weight:
                if #available(iOS 17, *) {
                    return app.cells["UIA.Health.Read.Weight.SwitchCell"].firstMatch
                }
                else {
                    return app.cells["Weight"].firstMatch
                }
            case .height:
                if #available(iOS 17, *) {
                    return app.cells["UIA.Health.Read.Height.SwitchCell"].firstMatch
                } else {
                    return app.cells["Height"].firstMatch
                }
            }
        }
    }
    
    func tapAllowToRead(for healthDataType: HealthKitDataType) -> Self {
        let cell = healthDataType.switchCell
        wait(for: cell)
        cell.tap()
        wait(for: cell)
        cell.verifyElementValue(expectedValue: "1", failureMessage: "The cell switch that allows access to read health data is not enabled")
        return self
    }
}

