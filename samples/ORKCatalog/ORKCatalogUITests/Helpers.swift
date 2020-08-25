/*
Copyright (c) 2015, Apple Inc. All rights reserved.

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

class Helpers: XCTestCase {
    let app = XCUIApplication()
    let commonElements = CommonElements()
    let taskScreen = TaskScreen()
    
    func verifyElement(_ element: XCUIElement) -> Bool {
        if element.exists {
            return true
        }
        XCTFail("Unable to confirm \(element) exists")
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
                    return true
                }
            }

            do {
            // Location
                let button = element.buttons["Allow While Using App"]
                if button.exists {
                    button.tap()
                    return true
                }
            }
              
            do {
                // Microphone
                let button = element.buttons["OK"]
                let title = element.staticTexts["“ORKCatalog” Would Like to Access the Microphone"]
                if title.exists && button.exists {
                    button.tap()
                    return true
                }
              }
          return false
        }
    }
}
