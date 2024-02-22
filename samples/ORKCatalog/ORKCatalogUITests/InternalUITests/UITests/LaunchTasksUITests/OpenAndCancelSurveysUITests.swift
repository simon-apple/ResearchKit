//  OpenAndCancelSurveysUITests.swift
//  ORKCatalogUITests
//
//  Created by Albina Kashapova on 2/7/24.
//  Copyright © 2024 researchkit.org. All rights reserved.
//

import Foundation
import XCTest

final class OpenAndCancelSurveysUITests: OpenAndCancelBaseUITest {
    
    func testLaunchFormSurvey() {
        func testLaunchHolePegTask() {
            openThenCancelActiveTask(task: Task.form.description, ifExpectFormStep: true)
        }
    }
    
    func testLaunchGroupedFormSurvey() {
        func testLaunchHolePegTask() {
            openThenCancelActiveTask(task: Task.groupedForm.description, ifExpectFormStep: true)
        }
    }
    
    func testLaunchSimpleSurvey() {
        func testLaunchHolePegTask() {
            openThenCancelActiveTask(task: Task.survey.description, ifExpectFormStep: true)
        }
    }
    
    func testLaunchDontKnowSurvey() {
        func testLaunchHolePegTask() {
            openThenCancelActiveTask(task: Task.dontknowSurvey.description, ifExpectFormStep: true)
        }
    }
    
    func testLaunchSurveyWithMultipleOptions() {
        func testLaunchHolePegTask() {
            openThenCancelActiveTask(task: Task.surveyWithMultipleOptions.description, ifExpectFormStep: true)
        }
    }
}
