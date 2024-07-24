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

final class Springboard {
    
    static let app = XCUIApplication()
    
    /// Deletes the ORKCatalog app from SpringBoard
    func deleteORKCatalogAppFromSpringboard() {
        Self.app.terminate()
        let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")
        springboard.activate()
        
        let appIcon = springboard.icons["ORKCatalog"]
        if appIcon.waitForExistence(timeout: 5) {
            appIcon.press(forDuration: 1.5)
            
            let deleteButton = springboard.buttons["com.apple.springboardhome.application-shortcut-item.remove-app"]
            if deleteButton.waitForExistence(timeout: 5) {
                deleteButton.tap()
                sleep(1)
                var firstAlertDeleteButton = springboard.alerts.buttons["Delete App"].firstMatch
                if firstAlertDeleteButton.waitForExistence(timeout: 5) {
                    firstAlertDeleteButton.tap()
                } else {
                    firstAlertDeleteButton = springboard.alerts.buttons.element(boundBy: 0) /// First alert: first button on alert
                    firstAlertDeleteButton.tap()
                }
                var secondAlertDeleteButton = springboard.alerts.buttons["Delete"].firstMatch
                if secondAlertDeleteButton.waitForExistence(timeout: 5) {
                    secondAlertDeleteButton.tap()
                } else {
                    secondAlertDeleteButton = springboard.alerts.buttons.element(boundBy: 1)  /// Second alert: second button on alert
                }
                let thirdAlertDeleteButton = springboard.alerts.buttons["OK"].firstMatch /// Third alert is regarding keeping collected health data on device
                if thirdAlertDeleteButton.waitForExistence(timeout: 5) {
                    thirdAlertDeleteButton.tap()
                }
            }
        }
        
        wait(for: appIcon, toExists: false, failureMessage: "ORKCatalog app icon is still present on the SpringBoard")
    }
    
}
