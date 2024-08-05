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

// MARK: - Active Tasks Not Related To Fitness

final class ActiveTasksOtherUITests: ActiveTasksBaseUITest {
    
    func testNavigateToHolePegTask() {
        navigateToActiveTask(task: Task.holePegTest.description)
    }
    
    func testNavigateToLaunchKneeRangeOfMotionTask() {
        navigateToActiveTask(task: Task.kneeRangeOfMotion.description)
    }
    
    func testNavigateToNormalizedReactionTimeTask() {
        navigateToActiveTask(task: Task.normalizedReactionTime.description)
    }
    
    func testNavigateToPsatTimeTask() {
        navigateToActiveTask(task: Task.psat.description)
    }
    
    func testNavigateToReactionTimeTask() {
        navigateToActiveTask(task: Task.reactionTime.description)
    }
    
    func testNavigateToShoulderRangeOfMotionTask() {
        navigateToActiveTask(task: Task.shoulderRangeOfMotion.description)
    }
    
    func testNavigateToSpatialSpanMemoryTask() {
        navigateToActiveTask(task: Task.spatialSpanMemory.description)
    }
    
    func testNavigateToStroopTask() {
        navigateToActiveTask(task: Task.stroop.description)
    }
    
    func testNavigateToTowerOfHanoiTask() {
        navigateToActiveTask(task: Task.towerOfHanoi.description)
    }
    
    func testNavigateToTwoFingerTappingIntervalTask() {
        navigateToActiveTask(task: Task.twoFingerTappingInterval.description)
    }
    
    func testNavigateToAmslerGrid() {
        tasksList
            .selectTaskByName(Task.amslerGrid.description)
        // Note: No system permission alerts here
        navigateThroughInstructionSteps(maxInstructionStepsCount: 5)
        
        let activeStep = ActiveStepScreen()
        activeStep
            .verifyStepImage() // we check for an image not for a view
            .cancelTask()
    }
    
    func testNavigateToTremorTest() {
        tasksList
            .selectTaskByName(Task.tremorTest.description)
        // Note: No system permission alerts here
        navigateThroughInstructionSteps(maxInstructionStepsCount: 10)
        
        if app.navigationBars["ORKQuestionStepView"].waitForExistence(timeout: 3) {
            Step().cancelTask()
            return
        } else {
            let formStep = FormStepScreen()
            formStep
                .verifyStepView()
                .answerSingleChoiceTextQuestion(withId: "skipHand", atIndex: 0)
                .tap(.continueButton)
            
            while instructionStep.stepViewExists(timeout: 3) {
                instructionStep.tap(.continueButton)
            }
            
            let activeStep = ActiveStepScreen()
            activeStep
                .verifyStepView()
                .cancelTask()
        }
    }
}

// MARK: - Audio Active Tasks

final class ActiveTasksAudioUITests: ActiveTasksBaseUITest {
    
    func testAudioTask() {
        tasksList
            .selectTaskByName(Task.audio.description)
        let alerts = PermissionAlerts(isSystemAlertExpected: true)
        navigateThroughInstructionSteps(maxInstructionStepsCount: 5, alertsExpected: alerts)
        
        sleep(5) // "Starting activity in 5 sec" screen
        sleep(20) // Wait for 20 sec to complete audio task
        
        // Completion step
        if InstructionStepScreen.stepView.waitForExistence(timeout: 20) {
            instructionStep
                .tap(.continueButton)
        }
    }
    
    // In this specific test we might end up in form step instead of active step due to speech recognition being disabled so handling both cases
    func testNavigateToSpeechRecognitionTask() {
        tasksList
            .selectTaskByName(Task.speechRecognition.description)
        let alerts = PermissionAlerts(isSystemAlertExpected: true)
        navigateThroughInstructionSteps(maxInstructionStepsCount: 5, alertsExpected: alerts)
        
        let activeStep = ActiveStepScreen()
        let formStep = FormStepScreen()
        if activeStep.stepViewExists(timeout: 7) {
            activeStep
                .cancelTask()
            // "Edit Transcript" Screen
        } else if formStep.stepViewExists(timeout: 30)  {
            let formStep = FormStepScreen()
            formStep
                .verifyStepView()
                .cancelTask()
        } else {
            // Handling ORKQuestionStep
            Step().cancelTask()
        }
    }
    
    func testNavigateToSpeechInNoiseTask() {
        let alerts = PermissionAlerts(isSystemAlertExpected: true)
        navigateToActiveTask(task: Task.speechInNoise.description, alertsExpected: alerts)
    }
    
    func testNavigateToSplMeterTask() {
        let alerts = PermissionAlerts(isSystemAlertExpected: true)
        navigateToActiveTask(task: Task.splMeter.description, alertsExpected: alerts)
    }
    
    func testNavigateToToneAudiometryTask() {
        let alerts = PermissionAlerts(isSystemAlertExpected: true)
        navigateToActiveTask(task: Task.toneAudiometry.description, alertsExpected: alerts)
    }
}

// MARK: - Active Tasks Related To Fitness

final class ActiveTasksFitnessUITests: ActiveTasksBaseUITest {
    
    override func tearDownWithError() throws {
        // Overriding tear down here as we finish test as soon as we end up on Active Step Screen due to inconsistent behavior in fitness tasks
    }
    
    func testNavigateToFitnessTask() {
        tasksList
            .selectTaskByName(Task.fitness.description)
        
        let instructionStep = InstructionStepScreen()
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
            if instructionStep.stepViewExists(timeout: 3) {
                instructionStep.tapCenterCoordinateScreen()
            }
        }
        
        if instructionStep.stepViewExists(timeout: 3) {
            instructionStep.tapCenterCoordinateScreen()
        }
        
        /// Not cancelling task just verifying that we end up on Active Step View
        let activeStep = ActiveStepScreen()
        activeStep
            .verifyStepView(timeout: 60)
    }
    
    func testNavigateToShortWalkTask() {
        let alerts = PermissionAlerts(isHealthAccessScreenExpected: true)
        navigateToActiveTask(task: Task.shortWalk.description, alertsExpected: alerts, cancelTask: false)
    }
    
    func testNavigateToSixMinuteWalkTask() {
        let alerts = PermissionAlerts(isHealthAccessScreenExpected: true)
        navigateToActiveTask(task: Task.sixMinuteWalk.description, alertsExpected: alerts, cancelTask: false)
    }
    
    func testNavigateToTecumsehCubeTestTask() {
        let alerts = PermissionAlerts(isHealthAccessScreenExpected: true)
        navigateToActiveTask(task: Task.tecumsehCubeTest.description, alertsExpected: alerts, cancelTask: false)
    }
    
    func testNavigateToWalkBackAndForthTask() {
        let alerts = PermissionAlerts(isHealthAccessScreenExpected: true)
        navigateToActiveTask(task: Task.walkBackAndForth.description, alertsExpected: alerts)
    }
    
    func testNavigateToTimedWalkWithTurnAround() {
        tasksList
            .selectTaskByName(Task.timedWalkWithTurnAround.description)
        navigateThroughInstructionSteps(maxInstructionStepsCount: 5)
        
        let formStep = FormStepScreen()
        formStep
            .verifyStepView()
            .answerSingleChoiceTextQuestion(withId: "timed.walk.form.afo", atIndex: 0)
            .answerPickerValueChoiceQuestion(value: "None", verifyResultValue: false, dismissPicker: true)
            .tap(.continueButton)
        
        if instructionStep.stepViewExists(timeout: 3) {
            instructionStep.tap(.continueButton)
        }
        
        sleep(5) // "Starting activity in 5 sec" screen
        
        /// Not cancelling task just verifying that we end up on Active Step View
        let activeStep = ActiveStepScreen()
        activeStep
            .verifyStepView(timeout: 60)
    }
}
