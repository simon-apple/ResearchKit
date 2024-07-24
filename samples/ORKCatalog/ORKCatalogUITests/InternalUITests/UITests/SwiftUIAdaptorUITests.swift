//  SwiftUIAdaptorUITests.swift
//  ORKCatalogUITests
//
//  Created by Albina Kashapova on 3/7/24.
//  Copyright © 2024 researchkit.org. All rights reserved.
//

import Foundation

#if RK_APPLE_INTERNAL
final class SwiftUIAdaptorUITests: BaseUITest {
    
    let tabBar = TabBar()
    
    override func tearDownWithError() throws {
        // Verify that after test is completed, switch is disabled
        let settingsTab = tabBar.navigateToSettings()
        settingsTab.toggleSwitch(toState: false)
    }
    
    ///rdar://102491992 ([PUBLIC] Keyboard Safe Area Covers Input Fields (public issue #1520)) for more details
    func testSwiftUIAdaptorInputFields() {
        let settingsTab = tabBar.navigateToSettings()
        settingsTab.toggleSwitch(toState: true)
        let tasksList = tabBar.navigateToTasks()
        tasksList
            .selectTaskByName(Task.numericQuestion.description)
        
        let questionStep = FormStepScreen()
        let formItemId = "numericFormItem"
        let numericValue = 123.0
        questionStep
            .selectFormItemCell(withID: formItemId)
            .answerNumericQuestion(number: numericValue, dismissKeyboard: true)
            .verify(.continueButton, isEnabled: true)
            .tap(.continueButton)
        
        questionStep
            .selectFormItemCell(withID: formItemId)
            .answerNumericQuestion(number: numericValue, dismissKeyboard: true)
            .verify(.continueButton, isEnabled: true)
            .tap(.continueButton)
        
        questionStep
            .selectFormItemCell(withID: formItemId)
            .answerNumericQuestion(number: numericValue, dismissKeyboard: true)
            .verify(.continueButton, isEnabled: true)
            .tap(.continueButton)
    }
}
#endif
