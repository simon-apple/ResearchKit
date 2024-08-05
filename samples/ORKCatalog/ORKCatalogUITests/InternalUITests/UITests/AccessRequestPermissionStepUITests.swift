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

final class AccessRequestPermissionStepUITests: BaseUITest {
    
    let tasksList = TasksTab()
    
    override func setUpWithError() throws {
        
        if isRunningInXcodeCloud && !isRunningOnSimulator {
            try XCTSkipIf(true, "Skipping this test when running in Xcode Cloud environment on device compute devices due to this issue: rdar://130824888 (Health Authorization Error and Health Access screen won't trigger in XCUITests - Occurs only on skywagon device compute devices)")
        }
        
        if !isRunningInXcodeCloud {
            // Deleting the app from springboard is a workaround for the XCTest issues where you can't reset authorization status for device motion and notifications:
            // rdar://111541621(SEED: XCTest: Missing ability to reset device fitness and motion permission)
            // rdar://59388255(XCUIProtectedResource misses user notifications to reset authorization status)
            // In Xcode Cloud we run this test first to verify all permission alerts so no need to delete the app to reset state
             let springBoard = Springboard()
             springBoard.deleteORKCatalogAppFromSpringboard()
        }
 
        // Reset authorization for resources
        app.resetAuthorizationStatus(for: .location)
        if #available(iOS 14.0, *) {
            app.resetAuthorizationStatus(for: .health)
        }
        
        try super.setUpWithError()
        // Verify that before we start our test we are on Tasks tab
        tasksList
            .assertTitle()
    }
    
    override func tearDownWithError() throws {
        if testRun?.hasSucceeded == false {
            return
        }
        // Verify that after test is completed, we end up on Tasks tab
        tasksList
            .assertTitle()
    }
    
    func testRequestPermissionStep() {
        tasksList
            .selectTaskByName(Task.requestPermissions.description)
    
        // Data Types for which to request permission:
        let notifications = (title: "Notifications", image: "notifications")
        let deviceMotion = (title: "Device Motion", image: "arrow.right.arrow.left.circle")
        let healthData = (title: "Health Data", image: "love")
        let locationData = (title:"Location Data", image: "orient to phone")
        let dataTypes = [notifications, deviceMotion, healthData, locationData]
        
        let permissionsStep = RequestPermissionsStepScreen()
        permissionsStep
            .verifyStepView()
            .verify(.title)
            .verify(.text)
            .verify(.skipButton, exists: false) // Non-Optional Step
            .verify(.continueButton, isEnabled: false)
        
            .verifyNumOfDataTypes(expectedCount: dataTypes.count)
        
        for (i, dataType) in dataTypes.enumerated() {
            permissionsStep
                .verifyDataTypeTitle(dataType.title)
                .verifyDataTypeImage(dataType.image)
                .verifyPermissionButtonLabelExists(atIndex: i, label: .labelDefault)
                .verifyPermissionButton(atIndex: i, isEnabled: true)
                .tapPermissionButton(atIndex: i) // Triggers alert for granting access
            if dataType.title == "Health Data" {
                let healthAccessScreen = HealthAccess()
                healthAccessScreen
                    .verifyAllowButton(isEnabled: false)
                    .tapAllowAllCell()
                    .verifyAllowButton(isEnabled: true)
                    .tapAllowButton()

            } else {
                sleep(5) /// Allow time for the permission alert to appear as system alerts are not part of the app's a11y hierarchy and may have a delay in presentation
                permissionsStep.tapPermissionButton(atIndex: i) /// Required for automatic detection and handling the alert: see Helpers().monitorAlerts() method
            }
            permissionsStep
                .verifyPermissionButtonLabelExists(atIndex: i, label: .labelConnected)
                .verifyPermissionButton(atIndex: i, isEnabled: false)
                .verifyPermissionButton(atIndex: i, isEnabled: false)
        }
        
        permissionsStep
            .tap(.continueButton)
    }
}
