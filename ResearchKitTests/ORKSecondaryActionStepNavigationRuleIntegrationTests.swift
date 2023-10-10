/*
 Copyright (c) 2023, Apple Inc. All rights reserved.
 
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

import XCTest

final class ORKSecondaryActionStepNavigationRuleIntegrationTests: XCTestCase {
    
    var sampleTask: ORKNavigableOrderedTask {
        let step1 = ORKInstructionStep(identifier: "id1")
        let step2 = ORKInstructionStep(identifier: "id2")
        let step3 = ORKInstructionStep(identifier: "id3")

        let task = ORKNavigableOrderedTask(identifier: "orderedTask", steps: [step1, step2, step3])
        
        return task
    }
    
    func testSecondaryActionNavigationRuleIntegration() throws {
        do {
            let task = sampleTask
            let secondaryActionNavigationRule = ORKSecondaryActionStepNavigationRule(destinationStepIdentifier: "id3", text: "Opt Out")
            task.setNavigationRule(secondaryActionNavigationRule, forTriggerStepIdentifier: "id1")
            
            XCTAssertEqual(task.stepNavigationRules.count, 1)
            XCTAssertEqual(task.stepNavigationRules.first!.value, secondaryActionNavigationRule)
        }
    }
    
    func testSecondaryActionNavigationLogic() throws {
        do {
            let task = sampleTask
            let secondaryActionNavigationRule = ORKSecondaryActionStepNavigationRule(destinationStepIdentifier: "id3", text: "Opt Out")
            task.setNavigationRule(secondaryActionNavigationRule, forTriggerStepIdentifier: "id1")
            let taskResult = ORKTaskResult(taskIdentifier: task.identifier, taskRun: UUID(), outputDirectory: nil)
            let nextStep = task.step(after: task.steps[0], with: taskResult)
            
            XCTAssertEqual(nextStep, task.steps[1])
        }
    }
    
    func testNavigationLogicWithDirectStep() throws {
        do {
            let task = sampleTask
            let secondaryActionNavigationRule = ORKDirectStepNavigationRule(destinationStepIdentifier: "id3")
            task.setNavigationRule(secondaryActionNavigationRule, forTriggerStepIdentifier: "id1")
            let taskResult = ORKTaskResult(taskIdentifier: task.identifier, taskRun: UUID(), outputDirectory: nil)
            let nextStep = task.step(after: task.steps[0], with: taskResult)
            
            XCTAssertEqual(nextStep, task.steps[2])
        }
    }
    
    func testSecondaryActionNavigationViewControllerLogic() throws {
        do {
            let task = sampleTask
            let secondaryActionNavigationRule = ORKSecondaryActionStepNavigationRule(destinationStepIdentifier: "id3", text: "Opt Out")
            task.setNavigationRule(secondaryActionNavigationRule, forTriggerStepIdentifier: "id1")
            verifyNavigationFlowIsWorkingAsExpected(task: task, secondaryActionNavigationRule: secondaryActionNavigationRule)
        }
    }
    
    func testSecondaryActionNavigationInSkipModeViewControllerLogic() throws {
        do {
            let task = sampleTask
            let secondaryActionNavigationRule = ORKSecondaryActionStepNavigationRule()
            task.setNavigationRule(secondaryActionNavigationRule, forTriggerStepIdentifier: "id1")
            verifyNavigationFlowIsWorkingAsExpected(task: task, secondaryActionNavigationRule: secondaryActionNavigationRule)
        }
    }
    
    func verifyNavigationFlowIsWorkingAsExpected(task: ORKNavigableOrderedTask, secondaryActionNavigationRule: ORKSecondaryActionStepNavigationRule) {
        let taskViewController = ORKTaskViewController(task: task, taskRun: nil)
        
        taskViewController.viewDidLoad()
        taskViewController.flipToPage(withIdentifier: task.steps[0].identifier, forward: true, animated: false)
        var currentStepViewController = taskViewController.currentStepViewController
        taskViewController.stepViewControllerWillAppear(currentStepViewController!)
        // Lets check that our ORKSecondaryActionStepNavigationRule title has shown up.
        XCTAssertEqual(currentStepViewController?.skipButtonTitle, secondaryActionNavigationRule.text)
        
        taskViewController.step(currentStepViewController!, didFinishWith: .skip, animated: true)
        currentStepViewController = taskViewController.currentStepViewController
        // Lets verify that tapping our ORKSecondaryActionStepNavigation Button will take us to our  secondaryActionNavigationRule.destinationStepIdentifier
        if (secondaryActionNavigationRule.isSkipMode()) {
            XCTAssertEqual(currentStepViewController?.step?.identifier, task.steps[1].identifier)
        } else {
            XCTAssertEqual(currentStepViewController?.step?.identifier, secondaryActionNavigationRule.destinationStepIdentifier)
        }
        
        taskViewController.step(currentStepViewController!, didFinishWith: .reverse, animated: true)
        currentStepViewController = taskViewController.currentStepViewController
        // Lets verify that tapping back will take us to where we started
        XCTAssertEqual(currentStepViewController?.step?.identifier, task.steps[0].identifier)
        
        taskViewController.step(currentStepViewController!, didFinishWith: .forward, animated: true)
        currentStepViewController = taskViewController.currentStepViewController
        // Lets verify that tapping next will go to the next step
        XCTAssertEqual(currentStepViewController?.step?.identifier, task.steps[1].identifier)
    }
}
