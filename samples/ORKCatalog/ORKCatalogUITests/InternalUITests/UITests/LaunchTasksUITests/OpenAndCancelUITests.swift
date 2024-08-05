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

// MARK: - Active Tasks

final class OpenAndCancelActiveTasksUITests: OpenAndCancelBaseUITest {
    
    func testLaunchAudioTask() {
        openThenCancel(task: Task.audio.description)
    }
    
    func testLaunchAmslerGrid() {
        openThenCancel(task: Task.amslerGrid.description)
    }
    
    func testLaunchDBHLToneAudiometryTask() {
        openThenCancel(task: Task.dBHLToneAudiometry.description)
    }
    
    func testLaunchFitnessTask() {
        openThenCancel(task: Task.fitness.description)
    }
    
    func testLaunchHolePegTask() {
        openThenCancel(task: Task.holePegTest.description)
    }
    
    func testLaunchKneeRangeOfMotionTask() {
        openThenCancel(task: Task.kneeRangeOfMotion.description)
    }
    
    func testLaunchNormalizedReactionTimeTask() {
        openThenCancel(task: Task.normalizedReactionTime.description)
    }
    
    func testLaunchPsatTimeTask() {
        openThenCancel(task: Task.psat.description)
    }
    
    func testLaunchReactionTimeTask() {
        openThenCancel(task: Task.reactionTime.description)
    }
    
    func testLaunchShortWalkTask() {
        openThenCancel(task: Task.shortWalk.description)
    }
    
    func testLaunchShoulderRangeOfMotionTask() {
        openThenCancel(task: Task.shoulderRangeOfMotion.description)
    }
    
    func testLaunchSixMinuteWalkTask() {
        openThenCancel(task: Task.sixMinuteWalk.description)
    }
    
    func testLaunchSpatialSpanMemoryTask() {
        openThenCancel(task: Task.spatialSpanMemory.description)
    }
    
    func testLaunchSpeechInNoiseTask() {
        openThenCancel(task: Task.speechInNoise.description)
    }
    
    func testLaunchSpeechRecognitionTask() {
        openThenCancel(task: Task.speechRecognition.description)
    }
    
    func testLaunchSplMeterTask() {
        openThenCancel(task: Task.splMeter.description)
    }
    
    func testLaunchStroopTask() {
        openThenCancel(task: Task.stroop.description)
    }
    
    func testLaunchTecumsehCubeTestTask() {
        openThenCancel(task: Task.tecumsehCubeTest.description)
    }
    
    func testLaunchTimedWalkWithTurnAround() {
        openThenCancel(task: Task.timedWalkWithTurnAround.description)
    }
    
    func testLaunchToneAudiometryTask() {
        openThenCancel(task: Task.toneAudiometry.description)
    }
    
    func testLaunchTowerOfHanoiTask() {
        openThenCancel(task: Task.towerOfHanoi.description)
    }
    
    func testLaunchTremorTest() {
        openThenCancel(task: Task.tremorTest.description)
    }
    
    func testLaunchTwoFingerTappingIntervalTask() {
        openThenCancel(task: Task.twoFingerTappingInterval.description)
    }
    
    func testLaunchWalkBackAndForthTask() {
        openThenCancel(task: Task.walkBackAndForth.description)
    }
}

// MARK: - Tasks In Onboarding Section

final class OpenAndCancelOnboardingTasksUITests: OpenAndCancelBaseUITest {
    
    func testLaunchAccountCreationTask() {
        openThenCancel(task: Task.accountCreation.description)
    }
    
    func testLaunchBiometricPasscodeCreationTask() {
        openThenCancel(task: Task.biometricPasscode.description)
    }
    
    func testLaunchPasscodeCreationTask() {
        openThenCancel(task: Task.passcode.description)
    }
    
    func testLaunchConsentDocumentReviewTask() {
        openThenCancel(task: Task.consentDoc.description)
    }
    
    func testLaunchConsentTask() {
        openThenCancel(task: Task.consentTask.description)
    }
    
    func testLaunchEligibilityTask() {
        openThenCancel(task: Task.eligibilityTask.description)
    }
    
    func testLaunchLoginTask() {
        /// Discard Results / End Task button won't appear in this task: rdar://107763161 ([ORKCatalog] Discard Results module doesn't popup when cancel out of Login activity)
        tasksList.selectTaskByName(Task.login.description)
        let step = Step()
        step.tapCancelButton()
    }
    
    func testLaunchReviewStepTask() {
        openThenCancel(task: Task.review.description)
    }
}

// MARK: - Tasks In Miscellaneous Section

final class OpenAndCancelMiscellaneousTasksUITests: OpenAndCancelBaseUITest {
    
    func testLaunchFrontFacingCameraTask() {
        openThenCancel(task: Task.frontFacingCamera.description)
    }
    
    func testLaunchImageCaptureTask() {
        openThenCancel(task: Task.imageCapture.description)
    }
    
    func testLaunchPDFViewerTask() {
        openThenCancel(task: Task.PDFViewer.description)
    }
    
    func testLaunchRequestPermissionStepTask() {
        openThenCancel(task: Task.requestPermissions.description)
    }
    
    func testLaunchUSDZModelTask() {
        openThenCancel(task: Task.usdzModel.description)
    }
    
    func testLaunchVideoCaptureTask() {
        openThenCancel(task: Task.videoCapture.description)
    }
    
    func testLaunchVideoInstructionTask() {
        openThenCancel(task: Task.videoInstruction.description)
    }
    
    func testLaunchWaitStepTask() {
        openThenCancel(task: Task.wait.description)
    }
    
    func testLaunchWebViewTask() {
        openThenCancel(task: Task.webView.description)
    }
}

// MARK: - Internal Tasks

#if RK_APPLE_INTERNAL
final class OpenAndCancelInternalTasksUITests: OpenAndCancelBaseUITest {
    
    func testLaunchBLETask() {
        openThenCancel(task: Task.ble.description)
    }
    
    func testLaunchBooleanConditionalFormTask() {
        openThenCancel(task: Task.booleanConditionalFormTask.description)
    }
    
    func testCustomStepTask() {
        openThenCancel(task: Task.customStepTask.description)
    }
    
    func testLaunchFamilyHistoryTask() {
        openThenCancel(task: Task.familyHistory.description)
    }
    
    func testLaunchFamilyHistoryReviewTask() {
        // This step doesn't include a cancel button
        // You can dismiss the view by tapping the "Complete Family History Task" cell
        tasksList.selectTaskByName(Task.familyHistoryReviewTask.description)
        let completeFamilyHistoryTaskCell = app.cells.firstMatch // There is only one cell on the screen
        if completeFamilyHistoryTaskCell.waitForExistence(timeout: 20) {
            completeFamilyHistoryTaskCell.tap()
        }
    }
    
    func testLaunchLongHeaderTask() {
        openThenCancel(task: Task.longHeaderTask.description)
    }
    
    func testLaunchPlatterQuestionTask() {
        openThenCancel(task: Task.platterUIQuestion.description)
    }
    
    func testLaunchMethodOfAdjustmentToneAudiometryTask() {
        openThenCancel(task: Task.methodOfAdjustmentdBHLToneAudiometryTask.description)
    }
    
    func testLaunchNewdBHLToneAudiometryTask() {
        openThenCancel(task: Task.newdBHLToneAudiometryTask.description)
    }
    
    func testLaunchPredefinedAVJournalingTask() {
        openThenCancel(task: Task.predefinedAVJournalingTask.description)
    }

    func testLaunchPredefinedSpeechInNoiseTask() {
        openThenCancel(task: Task.predefinedSpeechInNoiseTask.description)
    }

    func testLaunchPredefinedTinnitusTask() {
        openThenCancel(task: Task.predefinedTinnitusTask.description)
    }
    
    func testLaunchSelectableHeadphoneDetectorTask() {
        openThenCancel(task: Task.predefinedSelectableHeadphoneTask.description)
    }
    
    func testLaunchSettingStatusStepTaskTask() {
        openThenCancel(task: Task.settingStatusStepTask.description)
    }
    
    func testLaunchStudyPromoVCTask() {
        tasksList.selectTaskByName(Task.studyPromoTask.description)
        let step = Step()
        step.tap(.continueButton) // This step doesn't include a cancel button
    }
    
    func testLaunchStudySignPostStep() {
        tasksList.selectTaskByName(Task.studySignPostStep.description)
        let step = Step()
        step.tap(.continueButton) // This step doesn't include a cancel button
    }
}
#endif

// MARK: - Surveys

final class OpenAndCancelSurveysUITests: OpenAndCancelBaseUITest {
    
    func testLaunchSurveys() {
        let surveys: [Task] = [
            .form,
            .groupedForm,
            .groupedFormNoScroll,
            .survey,
            .dontknowSurvey,
            .surveyWithMultipleOptions
        ]
        
        for survey in surveys {
            openThenCancel(task:survey.description)
        }
    }
}

// MARK: - Survey Questions

final class OpenAndCancelSurveyQuestionUITests: OpenAndCancelBaseUITest {
    
    func testLaunchSurveysQuestions() {
        let surveyQuestionsTask: [Task] = [
            // .ageQuestion,
            .booleanQuestion,
            // .colorChoiceQuestion,
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
            //.textQuestionPIIScrubbing,
            .timeIntervalQuestion,
            .timeOfDayQuestion,
            .validatedTextQuestion,
            .valuePickerChoiceQuestion]
        
        for task in surveyQuestionsTask {
            let taskLabel = task.description
            tasksList.selectTaskByName(taskLabel)
            let step = FormStepScreen()
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
