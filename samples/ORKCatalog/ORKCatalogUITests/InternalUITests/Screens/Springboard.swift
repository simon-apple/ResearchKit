//  Springboard.swift
//  ORKCatalogUITests
//
//  Created by Albina Kashapova on 12/18/23.
//  Copyright © 2023 researchkit.org. All rights reserved.
//

import Foundation
import XCTest

final class Springboard {
    
    static let ORKCatalogApp = XCUIApplication()
    static let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")
    static var appIcon: XCUIElement {
        return springboard.icons["ORKCatalog"].firstMatch
    }
    
    /// Deletes the ORKCatalog app from SpringBoard
    func deleteORKCatalogAppFromSpringboard() {
        Self.ORKCatalogApp.terminate()
        Self.springboard.activate()
        
        if Self.appIcon.waitForExistence(timeout: 5) {
            /// This is workaround for the issue where ORKCatalog app icon is not visible on the current springboard screen, requiring swiping in different directions to locate it
            let maxAttempts = 5
            if !swipeUntilAppIconIsHittable(direction: .left, maxAttempts: maxAttempts) {
                swipeUntilAppIconIsHittable(direction: .right, maxAttempts: maxAttempts)
            }
            
            Self.appIcon.press(forDuration: 1.5)
            
            let deleteButton = Self.springboard.buttons["com.apple.springboardhome.application-shortcut-item.remove-app"]
            if deleteButton.waitForExistence(timeout: 5) {
                deleteButton.tap()
                sleep(1)
                var firstAlertDeleteButton = Self.springboard.alerts.buttons["Delete App"].firstMatch
                if firstAlertDeleteButton.waitForExistence(timeout: 5) {
                    firstAlertDeleteButton.tap()
                } else {
                    firstAlertDeleteButton = Self.springboard.alerts.buttons.element(boundBy: 0) /// First alert: first button on alert
                    firstAlertDeleteButton.tap()
                }
                var secondAlertDeleteButton = Self.springboard.alerts.buttons["Delete"].firstMatch
                if secondAlertDeleteButton.waitForExistence(timeout: 5) {
                    secondAlertDeleteButton.tap()
                } else {
                    secondAlertDeleteButton = Self.springboard.alerts.buttons.element(boundBy: 1)  /// Second alert: second button on alert
                }
                let thirdAlertDeleteButton = Self.springboard.alerts.buttons["OK"].firstMatch /// Third alert is regarding keeping collected health data on device
                if thirdAlertDeleteButton.waitForExistence(timeout: 5) {
                    thirdAlertDeleteButton.tap()
                }
            }
        }
        
        wait(for: Self.appIcon, toExists: false, failureMessage: "ORKCatalog app icon is still present on the SpringBoard")
    }
    
    @discardableResult
    fileprivate func swipeUntilAppIconIsHittable(direction: SwipeDirection, maxAttempts: Int) -> Bool {
        var attempts = 0
        while !Self.appIcon.isHittable && attempts < maxAttempts {
            switch direction {
            case .left:
                Self.springboard.swipeLeft()
            case .right:
                Self.springboard.swipeRight()
            default:
                XCTFail("Swiping in \(direction) is not supported in this method")
            }
            attempts += 1
        }
        return Self.appIcon.isHittable
    }
}
