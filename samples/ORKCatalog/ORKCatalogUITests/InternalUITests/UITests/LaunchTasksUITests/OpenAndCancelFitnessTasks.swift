//  OpenAndCancelFitnessTasks.swift
//  ORKCatalogUITests
//
//  Created by Albina Kashapova on 2/7/24.
//  Copyright © 2024 researchkit.org. All rights reserved.
//

import Foundation
import XCTest

// Note: in case of tests flakiness or unexpected failures it's good idea to use openThenCancel method that cancels task on first step just for sanity
final class OpenAndCancelFitnessTasks: OpenAndCancelBaseUITest {
    
    override func tearDownWithError() throws {
        // Overriding tear down here as we finish test as soon as we end up on Active Step Screen due to inconsistent behavior in fitness tasks
    }
    
    func testLaunchFitnessTask() {
        tasksList
            .selectTaskByName(Task.fitness.description)
        
        let instructionStep = InstructionStep()
        instructionStep
            .tap(.continueButton) // First Instruction Step
        
        instructionStep
            .verifyStepView()
            .tap(.continueButton) // Second Instruction Step
        
        if HealthAccess.healthAccessView.waitForExistence(timeout: 8) {
            HealthAccess()
                .tapAllowAllCell()
                .tapAllowButton()
            sleep(5) // Allow time for the permission alert to appear (Allow access to Motion & Fitness Activity) as system alerts are not part of the app's a11y hierarchy and may have a delay in presentation
            instructionStep.tapCenterCoordinateScreen()
            sleep(5) // Allow time for the permission alert to appear (Allow access to location )
            if instructionStep.isStepViewExists(timeout: 3) {
                instructionStep.tapCenterCoordinateScreen()
            }
        }
        
        if instructionStep.isStepViewExists(timeout: 3) {
            instructionStep.tapCenterCoordinateScreen()
        }

        /// Not cancelling task just verifying that we end up on Active Step View
        let activeStep = ActiveStep()
        activeStep
            .verifyStepView(timeout: 60)
    }
    
    func testLaunchShortWalkTask() {
        openAndCancelActiveTask(task: Task.shortWalk.description, isHealthAccessRequired: true, cancelTask: false)
    }
    
    func testLaunchSixMinuteWalkTask() {
        openAndCancelActiveTask(task: Task.sixMinuteWalk.description, isHealthAccessRequired: true, cancelTask: false)
    }
    
    func testLaunchTecumsehCubeTestTask() {
        openAndCancelActiveTask(task: Task.tecumsehCubeTest.description, isHealthAccessRequired: true, cancelTask: false)
    }
    
    func testLaunchWalkBackAndForthTask() {
        openAndCancelActiveTask(task: Task.walkBackAndForth.description, isHealthAccessRequired: true)
    }
    
    func testLaunchTimedWalkWithTurnAround() {
        tasksList
            .selectTaskByName(Task.timedWalkWithTurnAround.description)
        let instructionStep = InstructionStep()
        
        while instructionStep.isStepViewExists(timeout: 3) {
            instructionStep.tap(.continueButton)
        }

        let formStep = FormStep()
        formStep
            .verifyStepView()
            .answerSingleChoiceTextQuestion(withId: "timed.walk.form.afo", atIndex: 0)
            .answerPickerValueChoiceQuestion(value: "None", verifyResultValue: false, dismissPicker: true)
            .tap(.continueButton)
        
        if instructionStep.isStepViewExists(timeout: 3) {
            instructionStep.tap(.continueButton)
        }
        
        sleep(5) // "Starting activity in 5 sec" screen
        
        /// Not cancelling task just verifying that we end up on Active Step View
        let activeStep = ActiveStep()
        activeStep
            .verifyStepView(timeout: 60)
    }
}
