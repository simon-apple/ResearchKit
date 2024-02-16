//  OpenAndCancelActiveTaskOther.swift
//  ORKCatalogUITests
//
//  Created by Albina Kashapova on 2/7/24.
//  Copyright © 2024 researchkit.org. All rights reserved.
//

import Foundation
import XCTest

// Not fitness related active tasks
// Note: in case of tests flakiness or unexpected failures it's good idea to use openThenCancel method that cancels task on first step just for sanity
final class OpenAndCancelActiveTaskOther: OpenAndCancelBaseUITest {
    
    func testLaunchHolePegTask() {
        openAndCancelActiveTask(task: Task.holePegTest.description)
    }
    
    func testLaunchKneeRangeOfMotionTask() {
        openAndCancelActiveTask(task: Task.holePegTest.description)
    }
    
    func testLaunchNormalizedReactionTimeTask() {
        openAndCancelActiveTask(task: Task.normalizedReactionTime.description)
    }
    
    func testLaunchPsatTimeTask() {
        openAndCancelActiveTask(task: Task.psat.description)
    }
    
    func testLaunchReactionTimeTask() {
        openAndCancelActiveTask(task: Task.reactionTime.description)
    }
    
    func testLaunchShoulderRangeOfMotionTask() {
        openAndCancelActiveTask(task: Task.shoulderRangeOfMotion.description)
    }
    
    func testLaunchSpatialSpanMemoryTask() {
        openAndCancelActiveTask(task: Task.spatialSpanMemory.description)
    }
    
    func testLaunchStroopTask() {
        openAndCancelActiveTask(task: Task.stroop.description)
    }
    
    func testLaunchTowerOfHanoiTask() {
        openAndCancelActiveTask(task: Task.towerOfHanoi.description)
    }
    
    func testLaunchTwoFingerTappingIntervalTask() {
        openAndCancelActiveTask(task: Task.twoFingerTappingInterval.description)
    }
    
    func testLaunchAmslerGrid() {
        tasksList
            .selectTaskByName(Task.amslerGrid.description)
        
        // Skip Instruction Steps
        // Note: No system permission alerts here
        let instructionStep = InstructionStep()
        while instructionStep.isStepViewExists(timeout: 3) {
            instructionStep.tap(.continueButton)
        }

        let activeStep = ActiveStep()
        activeStep
            .verifyStepImage() // we check for an image not for a view
            .cancelTask()
    }
    
    func testLaunchTremorTest() {
        tasksList
            .selectTaskByName(Task.tremorTest.description)
        
        // Skip Instruction Steps
        // Note: No system permission alerts here
        let instructionStep = InstructionStep()
        while instructionStep.isStepViewExists(timeout: 3) {
            instructionStep.tap(.continueButton)
        }
        
        if app.navigationBars["ORKQuestionStepView"].waitForExistence(timeout: 3) {
            Step().cancelTask()
            return
        } else {
            let formStep = FormStep()
            formStep
                .verifyStepView()
                .answerSingleChoiceTextQuestion(withId: "skipHand", atIndex: 0)
                .tap(.continueButton)
            
            while instructionStep.isStepViewExists(timeout: 3) {
                instructionStep.tap(.continueButton)
            }

            let activeStep = ActiveStep()
            activeStep
                .verifyStepView()
                .cancelTask()
        }
    }
}
