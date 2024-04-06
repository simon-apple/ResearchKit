//  SettingsTab.swift
//  ORKCatalogUITests
//
//  Created by Albina Kashapova on 2/25/24.
//  Copyright © 2024 researchkit.org. All rights reserved.
//

import Foundation
import XCTest

// Settings tab on the bottom tab bar
final class SettingsTab {
    static let app = XCUIApplication()
    static var title: XCUIElement {
        app.navigationBars[AccessibilityIdentifiers.TabBar.SettingsTab.settingsTabButton].firstMatch
    }
    
    @discardableResult
    func assertTitle(exists: Bool = true) -> Self {
        wait(for: Self.title, toExists: exists, failureMessage: "Please ensure that the app is navigated to Settings Tab")
        return self
    }
    
    @discardableResult
    func toggleSwitch(toState: Bool) -> Self {
        let swiftUISwitch = Self.app.switches.firstMatch.switches.firstMatch
        wait(for: swiftUISwitch)
        let currentStateIsOn = swiftUISwitch.value as? String == "1"
        if currentStateIsOn != toState {
            swiftUISwitch.tap()
            let predicate = NSPredicate(format: "value == %@", toState ? "1": "0")
            let expectation = XCTNSPredicateExpectation(predicate: predicate, object: swiftUISwitch)
            let result = XCTWaiter.wait(for: [expectation], timeout: 5)
            if result != .completed {
                XCTFail("Failed to toggle Swift UI switch to \(toState ? "on" : "off") state")
            }
        }
        return self
    }
}
