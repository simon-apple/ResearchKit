//  OpenAndCancelBaseUITest.swift
//  ORKCatalogUITests
//
//  Created by Albina Kashapova on 2/7/24.
//  Copyright © 2024 researchkit.org. All rights reserved.
//

import Foundation
import XCTest
     
class OpenAndCancelBaseUITest: BaseUITest {
    
    let tasksList = TasksTab()
    override func setUpWithError() throws {
        continueAfterFailure = true
        // Uncomment if clean state is needed:
        //   app.resetAuthorizationStatus(for: .microphone)
        //   app.resetAuthorizationStatus(for: .location)
        //   app.resetAuthorizationStatus(for: .camera)
        //   if #available(iOS 14.0, *) {
        //       app.resetAuthorizationStatus(for: .health)
        //     }
        try super.setUpWithError()
    }
    
    override func tearDownWithError() throws {
        // Verify that we end up on Tasks tab
        tasksList
            .assertTitle()
    }
    
    // Open and then cancel on first step without moving to next step
    func openThenCancel(task: String) {
        tasksList.selectTaskByName(task)
        let step = Step()
        step.cancelTask()
    }
    
    /**
     Open and cancel task. We skip instruction steps so we can process to active task itself
     - parameter task: the label of the task
     - parameter isHealthAccessRequired: whether we need to handle health authorization screens and alert
     - parameter isAudioAccessRequired: whether we need to handle permission alert to grant access to microphone
     - parameter ifExpectFormStep: whether we need to expect form step instead of active step
     */
    func openAndCancelActiveTask(task: String, isHealthAccessRequired: Bool = false, isAudioAccessRequired: Bool = false, ifExpectFormStep: Bool = false, cancelTask: Bool = true) {
        tasksList
            .selectTaskByName(task)
        
        let instructionStep = InstructionStep()
        while instructionStep.isStepViewExists(timeout: 3) {
            instructionStep.tap(.continueButton)
            // Handle health access auth screens and alert
            if isHealthAccessRequired {
                if HealthAccess.healthAccessView.waitForExistence(timeout: 8) {
                    HealthAccess()
                        .tapAllowAllCell()
                        .tapAllowButton()
                    sleep(5) // Allow time for the permission alert to appear as system alerts are not part of the app's a11y hierarchy and may have a delay in presentation
                    instructionStep.tapCenterCoordinateScreen() // Required for automatic detection and handling the alert: see Helpers().monitorAlerts() method
                    sleep(3)
                }
            // Handle system alert to grant access to the microphone
            } else if isAudioAccessRequired {
                sleep(5) // Allow time for the permission alert to appear as system alerts are not part of the app's a11y hierarchy and may have a delay in presentation
                instructionStep.tapCenterCoordinateScreen() // Required for automatic detection and handling the alert: see Helpers().monitorAlerts() method
            }
        }
        
        if ifExpectFormStep {
            let formStep = FormStep()
            formStep
                .verifyStepView()
                .cancelTask()
        } else {
            let activeStep = ActiveStep()
            activeStep.verifyStepView(timeout: 60)
            guard cancelTask else {
                return
            }
            activeStep.cancelTask()
        }
    }
}
