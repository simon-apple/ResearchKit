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
     
class ActiveTasksBaseUITest: BaseUITest {
    
    let tasksList = TasksTab()
    let instructionStep = InstructionStepScreen()
    
    override func setUpWithError() throws {
        continueAfterFailure = true
        // Uncomment if clean state is needed:
        // resetAuthorizationStatusForProtectedResources()
        try super.setUpWithError()
    }
    
    override func tearDownWithError() throws {
        // Verify that we end up on Tasks tab
        tasksList
            .assertTitle()
    }
 
    struct PermissionAlerts {
        var isHealthAccessScreenExpected: Bool = false
        var isSystemAlertExpected: Bool = false
    }
    
    /**
     Navigate to active task screen. We skip instruction steps so we can process to active task itself
     - parameter task: the label of the task
     - parameter alertsExpected: whether we need to handle health authorization screens or permission alerts to grant access to a protected resource (for example, microphone, camera, location etc)
     */
    func navigateToActiveTask(task: String, alertsExpected: PermissionAlerts = PermissionAlerts(), cancelTask: Bool = true) {
        tasksList
            .selectTaskByName(task)
        navigateThroughInstructionSteps(maxInstructionStepsCount: 10, alertsExpected: alertsExpected)
        let activeStep = ActiveStepScreen()
        activeStep.verifyStepView(timeout: 60)
        guard cancelTask else {
            return
        }
        activeStep.cancelTask()
    }
    
    func navigateThroughInstructionSteps(maxInstructionStepsCount: Int, alertsExpected: PermissionAlerts = PermissionAlerts()) {
        var instructionStepsCount = 0
        while instructionStep.stepViewExists(timeout: 3) && instructionStepsCount < maxInstructionStepsCount {
            instructionStep.tap(.continueButton)
            handlePermissionAlertsIfNeeded(alertsExpected)
            instructionStepsCount += 1
        }
    }
    
    func handlePermissionAlertsIfNeeded(_ alerts: PermissionAlerts) {
        let step = Step()
        // Handle health access auth screens and alert
        if alerts.isHealthAccessScreenExpected {
            if HealthAccess.healthAccessView.waitForExistence(timeout: 8) {
                HealthAccess()
                    .tapAllowAllCell()
                    .tapAllowButton()
                sleep(5) // Allow time for the permission alert to appear as system alerts are not part of the app's a11y hierarchy and may have a delay in presentation
                step.tapCenterCoordinateScreen() // Required for automatic detection and handling the alert: see Helpers().monitorAlerts() method
                sleep(3)
            }
        }
        // Handle system alerts to grant access to a protected resource (for example, microphone)
        if alerts.isSystemAlertExpected {
            sleep(5) // Allow time for the permission alert to appear as system alerts are not part of the app's a11y hierarchy and may have a delay in presentation
            step.tapCenterCoordinateScreen() // Required for automatic detection and handling the alert: see Helpers().monitorAlerts() method
            sleep(3)
        }
    }
}
