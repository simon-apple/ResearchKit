//  OpenAndCancelActiveTasksUITests.swift
//  ORKCatalogUITests
//
//  Created by Albina Kashapova on 2/7/24.
//  Copyright © 2024 researchkit.org. All rights reserved.
//

import Foundation
import XCTest

// Note: in case of tests flakiness or unexpected failures it's good idea to use openThenCancel method that cancels task on first instruction step just for sanity

// MARK: - Active Tasks Not Related To Fitness

final class OpenAndCancelActiveTaskOtherUITests: OpenAndCancelBaseUITest {
    
    func testLaunchHolePegTask() {
        openThenCancelActiveTask(task: Task.holePegTest.description)
    }
    
    func testLaunchKneeRangeOfMotionTask() {
        openThenCancelActiveTask(task: Task.holePegTest.description)
    }
    
    func testLaunchNormalizedReactionTimeTask() {
        openThenCancelActiveTask(task: Task.normalizedReactionTime.description)
    }
    
    func testLaunchPsatTimeTask() {
        openThenCancelActiveTask(task: Task.psat.description)
    }
    
    func testLaunchReactionTimeTask() {
        openThenCancelActiveTask(task: Task.reactionTime.description)
    }
    
    func testLaunchShoulderRangeOfMotionTask() {
        openThenCancelActiveTask(task: Task.shoulderRangeOfMotion.description)
    }
    
    func testLaunchSpatialSpanMemoryTask() {
        openThenCancelActiveTask(task: Task.spatialSpanMemory.description)
    }
    
    func testLaunchStroopTask() {
        openThenCancelActiveTask(task: Task.stroop.description)
    }
    
    func testLaunchTowerOfHanoiTask() {
        openThenCancelActiveTask(task: Task.towerOfHanoi.description)
    }
    
    func testLaunchTwoFingerTappingIntervalTask() {
        openThenCancelActiveTask(task: Task.twoFingerTappingInterval.description)
    }
    
    func testLaunchAmslerGrid() {
        tasksList
            .selectTaskByName(Task.amslerGrid.description)
        
        // Skip Instruction Steps
        // Note: No system permission alerts here
        let instructionStep = InstructionStepScreen()
        while instructionStep.stepViewExists(timeout: 3) {
            instructionStep.tap(.continueButton)
        }
        
        let activeStep = ActiveStepScreen()
        activeStep
            .verifyStepImage() // we check for an image not for a view
            .cancelTask()
    }
    
    func testLaunchTremorTest() {
        tasksList
            .selectTaskByName(Task.tremorTest.description)
        
        // Skip Instruction Steps
        // Note: No system permission alerts here
        let instructionStep = InstructionStepScreen()
        while instructionStep.stepViewExists(timeout: 3) {
            instructionStep.tap(.continueButton)
        }
        
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

// MARK: - Active Tasks In Miscellaneous Section

final class OpenAndCancelMiscellaneousTasksUITests: OpenAndCancelBaseUITest {
    
    func testLaunchImageCaptureTask() {
        openThenCancel(task: Task.imageCapture.description)
    }
    
    func testLaunchFrontFacingCameraTask() {
        openThenCancel(task: Task.frontFacingCamera.description)
    }
    
    func testLaunchVideoCaptureTask() {
        openThenCancel(task: Task.videoCapture.description)
    }
    
    func testLaunchVideoInstructionTask() {
        openThenCancel(task: Task.videoInstruction.description)
    }
}

// MARK: - Audio Active Tasks

final class OpenAndCancelAudioTasksUITests: OpenAndCancelBaseUITest {
    
    func testLaunchAudioTask() {
        tasksList
            .selectTaskByName(Task.audio.description)
        let instructionStep = InstructionStepScreen()
        
        while instructionStep.stepViewExists(timeout: 3) {
            instructionStep.tap(.continueButton)
            // Handle system alert to grant access to the microphone
            sleep(5) // Allow time for the permission alert to appear as system alerts are not part of the app's a11y hierarchy and may have a delay in presentation
            instructionStep.tapCenterCoordinateScreen() // Required for automatic detection and handling the alert: see Helpers().monitorAlerts() method
        }
        
        sleep(5) // "Starting activity in 5 sec" screen
        sleep(20) // Wait for 20 sec to complete audio task
        
        // Completion step
        if InstructionStepScreen.stepView.waitForExistence(timeout: 20) {
            instructionStep
                .tap(.continueButton)
        }
    }
    
    // In this specific test we might end up in form step instead of active step due to speech recognition being disabled so handling both cases
    func testLaunchSpeechRecognitionTask() {
        tasksList
            .selectTaskByName(Task.speechRecognition.description)
        let instructionStep = InstructionStepScreen()
        while instructionStep.stepViewExists(timeout: 3) {
            instructionStep.tap(.continueButton)
            // Handle system alert to grant access to the microphone
            sleep(5) // Allow time for the permission alert to appear as system alerts are not part of the app's a11y hierarchy and may have a delay in presentation
            instructionStep.tapCenterCoordinateScreen() // Required for automatic detection and handling the alert: see Helpers().monitorAlerts() method
        }
        
        let activeStep = ActiveStepScreen()
        let formStep = FormStepScreen()
        if activeStep.stepViewExists(timeout: 7) {
            activeStep
                .cancelTask()
            // "Edit Transcript" Screen
        } else if formStep.stepViewExists(timeout: 30) {
            let formStep = FormStepScreen()
            formStep
                .verifyStepView()
                .cancelTask()
        } else {
            // Handling ORKQuestionStep
            Step().cancelTask()
        }
    }
    
    func testLaunchSpeechInNoiseTask() {
        openThenCancelActiveTask(task: Task.speechInNoise.description, isAudioAccessRequired: true)
    }
    
    func testLaunchSplMeterTask() {
        openThenCancelActiveTask(task: Task.splMeter.description, isAudioAccessRequired: true)
    }
    
    func testLaunchToneAudiometryTask() {
        openThenCancelActiveTask(task: Task.toneAudiometry.description, isAudioAccessRequired: true)
    }
    
    // TODO: rdar://122515996 (Update Launch and Cancel Audio Tasks)
    func testLaunchDBHLToneAudiometryTask() {
        openThenCancel(task: Task.dBHLToneAudiometry.description)
    }
    // TODO: rdar://122515996 (Update Launch and Cancel Audio Tasks)
    func testLaunchNewdBHLToneAudiometryTask() {
        openThenCancel(task: Task.newdBHLToneAudiometryTask.description)
    }
    // TODO: rdar://122515996 (Update Launch and Cancel Audio Tasks)
    func testLaunchPredefinedSpeechInNoiseTask() {
        openThenCancel(task: Task.predefinedSpeechInNoiseTask.description)
    }
    // TODO: rdar://122515996 (Update Launch and Cancel Audio Tasks)
    func testLaunchPredefinedTinnitusTask() {
        openThenCancel(task: Task.predefinedTinnitusTask.description)
    }
}

// MARK: - Active Tasks Related To Fitness

final class OpenAndCancelFitnessTasksUITests: OpenAndCancelBaseUITest {
    
    override func tearDownWithError() throws {
        // Overriding tear down here as we finish test as soon as we end up on Active Step Screen due to inconsistent behavior in fitness tasks
    }
    
    func testLaunchFitnessTask() {
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
    
    func testLaunchShortWalkTask() {
        openThenCancelActiveTask(task: Task.shortWalk.description, isHealthAccessRequired: true, cancelTask: false)
    }
    
    func testLaunchSixMinuteWalkTask() {
        openThenCancelActiveTask(task: Task.sixMinuteWalk.description, isHealthAccessRequired: true, cancelTask: false)
    }
    
    func testLaunchTecumsehCubeTestTask() {
        openThenCancelActiveTask(task: Task.tecumsehCubeTest.description, isHealthAccessRequired: true, cancelTask: false)
    }
    
    func testLaunchWalkBackAndForthTask() {
        openThenCancelActiveTask(task: Task.walkBackAndForth.description, isHealthAccessRequired: true)
    }
    
    func testLaunchTimedWalkWithTurnAround() {
        tasksList
            .selectTaskByName(Task.timedWalkWithTurnAround.description)
        let instructionStep = InstructionStepScreen()
        
        while instructionStep.stepViewExists(timeout: 3) {
            instructionStep.tap(.continueButton)
        }
        
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

// MARK: - Internal Tasks

final class OpenAndCancelInternalTasksUITests: OpenAndCancelBaseUITest {
    
    func testLaunchPredefinedAVJournalingTask() {
        openThenCancel(task: Task.predefinedAVJournalingTask.description)
    }
    
    func testLaunchBLETask() {
        openThenCancel(task: Task.ble.description)
    }
    
    func testLaunchFamilyHistoryTask() {
        openThenCancel(task: Task.familyHistory.description)
    }
    
    func testCustomStepTask() {
        openThenCancel(task: Task.customStepTask.description)
    }
    
    func testLaunchStudyPromoVCTask() {
        tasksList.selectTaskByName(Task.studyPromoTask.description)
        let step = Step()
        step.tap(.continueButton)
    }
    
    func testLaunchStudySignPostStep() {
        tasksList.selectTaskByName(Task.studySignPostStep.description)
        let step = Step()
        step.tap(.continueButton)
    }
}
