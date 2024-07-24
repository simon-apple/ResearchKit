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

