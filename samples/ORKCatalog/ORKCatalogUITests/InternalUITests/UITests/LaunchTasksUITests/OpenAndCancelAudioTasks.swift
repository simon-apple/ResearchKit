//  OpenAndCancelAudioTasks.swift
//  ORKCatalogUITests
//
//  Created by Albina Kashapova on 2/7/24.
//  Copyright © 2024 researchkit.org. All rights reserved.
//

import Foundation
import XCTest

// Note: in case of tests flakiness or unexpected failures it's good idea to use openThenCancel method that cancels task on first step just for sanity
final class OpenAndCancelAudioTasks: OpenAndCancelBaseUITest {
    
    func testLaunchAudioTask() {
        tasksList
            .selectTaskByName(Task.audio.description)
        let instructionStep = InstructionStep()
        
        while instructionStep.isStepViewExists(timeout: 3) {
            instructionStep.tap(.continueButton)
            // Handle system alert to grant access to the microphone
            sleep(5) // Allow time for the permission alert to appear as system alerts are not part of the app's a11y hierarchy and may have a delay in presentation
            instructionStep.tapCenterCoordinateScreen() // Required for automatic detection and handling the alert: see Helpers().monitorAlerts() method
        }
        
        sleep(5) // "Starting activity in 5 sec" screen
        sleep(20) // Wait for 20 sec to complete audio task
        
        // Completion step
        if InstructionStep.stepView.waitForExistence(timeout: 20) {
            instructionStep
                .tap(.continueButton)
        }
    }
    
    // In this specific test we might end up in form step instead of active step due to speech recognition being disabled so handling both cases
    func testLaunchSpeechRecognitionTask() {
        tasksList
            .selectTaskByName(Task.speechRecognition.description)
        let instructionStep = InstructionStep()
        while instructionStep.isStepViewExists(timeout: 3) {
            instructionStep.tap(.continueButton)
            // Handle system alert to grant access to the microphone
            sleep(5) // Allow time for the permission alert to appear as system alerts are not part of the app's a11y hierarchy and may have a delay in presentation
            instructionStep.tapCenterCoordinateScreen() // Required for automatic detection and handling the alert: see Helpers().monitorAlerts() method
        }
                
        let activeStep = ActiveStep()
        let formStep = FormStep()
        if activeStep.isStepViewExists(timeout: 7) {
            activeStep
                .cancelTask()
            // "Edit Transcript" Screen
        } else if formStep.isStepViewExists(timeout: 30) {
            let formStep = FormStep()
            formStep
                .verifyStepView()
                .cancelTask()
        } else {
            // Handling ORKQuestionStep
            Step().cancelTask()
        }
    }
    
    func testLaunchSpeechInNoiseTask() {
        openAndCancelActiveTask(task: Task.speechInNoise.description, isAudioAccessRequired: true)
    }
    
    func testLaunchSplMeterTask() {
        openAndCancelActiveTask(task: Task.splMeter.description, isAudioAccessRequired: true)
    }
    
    func testLaunchToneAudiometryTask() {
        openAndCancelActiveTask(task: Task.toneAudiometry.description, isAudioAccessRequired: true)
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
