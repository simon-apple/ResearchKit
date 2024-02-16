//  OpenAndCancelSurveys.swift
//  ORKCatalogUITests
//
//  Created by Albina Kashapova on 2/7/24.
//  Copyright © 2024 researchkit.org. All rights reserved.
//

import Foundation
import XCTest

final class OpenAndCancelSurveys: OpenAndCancelBaseUITest {
    
    func testLaunchFormSurvey() {
        func testLaunchHolePegTask() {
            openAndCancelActiveTask(task: Task.form.description, ifExpectFormStep: true)
        }
    }
    
    func testLaunchGroupedFormSurvey() {
        func testLaunchHolePegTask() {
            openAndCancelActiveTask(task: Task.groupedForm.description, ifExpectFormStep: true)
        }
    }
    
    func testLaunchSimpleSurvey() {
        func testLaunchHolePegTask() {
            openAndCancelActiveTask(task: Task.survey.description, ifExpectFormStep: true)
        }
    }
    
    func testLaunchDontKnowSurvey() {
        func testLaunchHolePegTask() {
            openAndCancelActiveTask(task: Task.dontknowSurvey.description, ifExpectFormStep: true)
        }
    }
    
    func testLaunchSurveyWithMultipleOptions() {
        func testLaunchHolePegTask() {
            openAndCancelActiveTask(task: Task.surveyWithMultipleOptions.description, ifExpectFormStep: true)
        }
    }
}
