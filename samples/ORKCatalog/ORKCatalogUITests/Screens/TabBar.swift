//
//  TabBar.swift
//  ORKCatalogUITests
//
//  Created by Albina Kashapova on 10/25/23.
//  Copyright © 2023 researchkit.org. All rights reserved.
//

import Foundation
import XCTest

/// Bottom tab bar
class TabBar {
    static let app = XCUIApplication()
    enum Tab {
        case tasksTab, resultsTab, settingsTab
        var identifier: String {
            switch self {
            case .tasksTab:
                return AccessibilityIdentifiers.TabBar.TasksTab.tasksTabButton
            case .resultsTab:
                return AccessibilityIdentifiers.TabBar.ResultsTab.resultsTabButton
            case .settingsTab:
                return AccessibilityIdentifiers.TabBar.SettingsTab.settingsTabButton
            }
        }
        /// Query for tab buttons
        var button: XCUIElement {
            return app.tabBars.buttons[self.identifier].firstMatch
        }
    }
    
    static func navigateTo(tab: Tab) {
        let tabToSelect = tab.button
        wait(for: tabToSelect)
        tabToSelect.tap()
        wait(for: tabToSelect, toBeSelected: true)
    }
}
