//
//  Helpers.swift
//  ORKCatalogUITests
//
//  Created by Jason on 8/19/20.
//  Copyright © 2020 researchkit.org. All rights reserved.
//

import Foundation
import XCTest

class Helpers: XCTestCase {
    let app = XCUIApplication()
    let commonElements = CommonElements()
    let taskScreen = TaskScreen()
    
    func verifyElement(_ element: XCUIElement) -> Bool{
        if element.exists {
            return true
        }
        XCTFail("Unable to confrim \(element) exists")
        return false
    }
    
    func launchAndLeave(_ task: String) -> Bool {
        XCTAssert(verifyElement(taskScreen.mainTaskScreen))
        XCTAssert(app.tables.staticTexts[task].exists, "Unable to find \(task) element")
        let currentTask = app.tables.staticTexts[task]
        currentTask.tap()
        
        sleep(1)
        guard let cancelButton = commonElements.cancelButton else {
            XCTFail("Unable to locate Cancel Button")
            return false
        }
        cancelButton.tap()
        
        sleep(1)
        guard let exitButton = commonElements.getExitButton() else {
            XCTFail("Unable to locate End Task or Discard Results button")
            return false
        }
        exitButton.tap()
        
        return verifyElement(taskScreen.mainTaskScreen)
    }
    
    func deleteORKCatalog() {
        app.terminate()
        let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")
        let icon = springboard.icons["ORKCatalog"]
                if icon.exists {
                    icon.press(forDuration: 1.3)
                    springboard.buttons["Delete App"].tap()
                    sleep(2)
                    springboard.buttons["Delete"].tap()
                }
    }
    
    func monitorAlerts() {
        addUIInterruptionMonitor(withDescription: "Alert") {
          element in
          do {
            // Push Notification
            let button = element.buttons["Allow"]
            let title = element.staticTexts["“ORKCatalog” Would Like to Send You Notifications"]
            if title.exists && button.exists {
              button.tap()
            }
          }

          do {
            // Location
            let button = element.buttons["Allow While Using App"]
            if button.exists {
              button.tap()
            }
          }
          
          do {
            // Microphone
            let button = element.buttons["OK"]
            if button.exists {
              button.tap()
            }
          }
          return true
        }
    }
}
