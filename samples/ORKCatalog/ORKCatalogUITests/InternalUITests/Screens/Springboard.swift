//  Springboard.swift
//  ORKCatalogUITests
//
//  Created by Albina Kashapova on 12/18/23.
//  Copyright © 2023 researchkit.org. All rights reserved.
//

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
            }
        }
        
        wait(for: appIcon, toExists: false, failureMessage: "ORKCatalog app icon is still present on the SpringBoard")
    }
    
}
