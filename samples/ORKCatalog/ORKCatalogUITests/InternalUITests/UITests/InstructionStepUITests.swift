//  InstructionStepUITests.swift
//  ORKCatalogUITests
//
//  Created by Albina Kashapova on 3/5/24.
//  Copyright © 2024 researchkit.org. All rights reserved.
//

import Foundation

final class InstructionStepUITests: BaseUITest {
    
    let tasksList = TasksTab()
    
    override func setUpWithError() throws {
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
    
    func testImageBodyItemsInConsentTask() {
        tasksList
            .selectTaskByName(Task.consentTask.description)
        
        let instructionStep = InstructionStepScreen()
        instructionStep // First Step
            .verify(.title)
            .verify(.detailText)
            .verifyImage()
            .tap(.continueButton)
        
        instructionStep // Second Step
            .verify(.title)
            .verifyImageBodyItems(expectedCount: 4)
            .tap(.continueButton)
    }
}
