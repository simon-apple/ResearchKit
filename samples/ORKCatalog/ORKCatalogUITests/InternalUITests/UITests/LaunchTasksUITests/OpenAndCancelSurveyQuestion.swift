//  OpenAndCancelSurveyQuestion.swift
//  ORKCatalogUITests
//
//  Created by Albina Kashapova on 2/7/24.
//  Copyright © 2024 researchkit.org. All rights reserved.
//

import Foundation
import XCTest

final class OpenAndCancelSurveyQuestion: OpenAndCancelBaseUITest {
    
    func testLaunchSurveysQuestions() {
        let surveyQuestionsTask: [Task] = [
            .booleanQuestion,
            .customBooleanQuestion,
            .dateQuestion,
            .dateTimeQuestion,
            .date3DayLimitQuestionTask,
            .imageChoiceQuestion,
            .numericQuestion,
            .scaleQuestion,
            .textChoiceQuestion,
            .textChoiceQuestionWithImageTask,
            .textQuestion,
            .timeIntervalQuestion,
            .timeOfDayQuestion,
            .validatedTextQuestion,
            .valuePickerChoiceQuestion]
        
        for task in surveyQuestionsTask {
            let taskLabel = task.description
            tasksList.selectTaskByName(taskLabel)
            let step = FormStep()
            step
                .verifyStepView()
                .tapCancelButton()
                .tapDiscardResultsButton()
            // For each survey question verify that we end up on Tasks tab
            tasksList
                .assertTitle()
        }
    }
}
