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

// Tasks tab on the bottom tab bar
final class TasksTab {
    static let app = XCUIApplication()
    static var title: XCUIElement {
        app.navigationBars[AccessibilityIdentifiers.TabBar.TasksTab.title].firstMatch
    }
    
    @discardableResult
    func assertTitle(exists: Bool = true, hittable: Bool = true) -> Self {
        wait(for: Self.title, toExists: exists, failureMessage: "Please ensure that the app is navigated to Tasks Tab")
        wait(for: Self.title, toBeHittable: hittable, failureMessage: "Please ensure that the app is navigated to Tasks Tab") // We need to verify that the view is hittable as well to make sure that we are indeed on task tab (because the view could technically exist but be below another view)
        return self
    }
    
    func selectTaskByName(_ taskName: String) {
        let taskToSelect = Self.app.staticTexts[taskName]
        if !taskToSelect.visible {
            taskToSelect.scrollUntilVisible()
        }
        taskToSelect.tap()
    }
}

/// Based on ORKCatalog TaskListRow enum
enum Task {
    case form
    case groupedForm
    case groupedFormNoScroll
    case survey
    case dontknowSurvey
    case surveyWithMultipleOptions
    case platterUIQuestion
    case booleanQuestion
    case customBooleanQuestion
    case dateQuestion
    case dateTimeQuestion
    case date3DayLimitQuestionTask
    case imageChoiceQuestion
    case locationQuestion
    case numericQuestion
    case scaleQuestion
    case textQuestion
    case textChoiceQuestion
    case textChoiceQuestionWithImageTask
    case colorChoiceQuestion
    case timeIntervalQuestion
    case timeOfDayQuestion
    case valuePickerChoiceQuestion
    case validatedTextQuestion
    case imageCapture
    case videoCapture
    case frontFacingCamera
    case wait
    case PDFViewer
    case requestPermissions
    case usdzModel
    case familyHistory
    case eligibilityTask
    case accountCreation
    case login
    case passcode
    case biometricPasscode
    case review
    case audio
    case amslerGrid
    case tecumsehCubeTest
    case sixMinuteWalk
    case fitness
    case holePegTest
    case psat
    case reactionTime
    case normalizedReactionTime
    case shortWalk
    case spatialSpanMemory
    case speechRecognition
    case speechInNoise
    case stroop
    case timedWalkWithTurnAround
    case toneAudiometry
    case dBHLToneAudiometry
    case splMeter
    case towerOfHanoi
    case tremorTest
    case twoFingerTappingInterval
    case walkBackAndForth
    case healthQuantity
    case heightQuestion
    case weightQuestion
    case ageQuestion
    case kneeRangeOfMotion
    case shoulderRangeOfMotion
    case trailMaking
    case videoInstruction
    case webView
    
    case predefinedSpeechInNoiseTask
    case predefinedAVJournalingTask
    case predefinedTinnitusTask
    case predefinedSelectableHeadphoneTask
    case ble
    case textQuestionPIIScrubbing
    case methodOfAdjustmentdBHLToneAudiometryTask
    case newdBHLToneAudiometryTask
    case customStepTask
    case settingStatusStepTask
    case studyPromoTask
    case studySignPostStep
    case consentTask
    case consentDoc
    case familyHistoryReviewTask
    case longHeaderTask
    case booleanConditionalFormTask
    
    var description: String {
        switch self {
        case .form:
            return NSLocalizedString("Form Survey", comment: "")
            
        case .groupedForm:
            return NSLocalizedString("Grouped Form Survey", comment: "")
            
        case .groupedFormNoScroll:
            return NSLocalizedString("Grouped Form Survey No AutoScroll", comment: "")
            
        case .survey:
            return NSLocalizedString("Simple Survey", comment: "")
            
        case .dontknowSurvey:
            return NSLocalizedString("Don't Know Survey", comment: "")
            
        case .platterUIQuestion:
            return NSLocalizedString("Platter UI Question", comment: "")
            
        case .booleanQuestion:
            return NSLocalizedString("Boolean Question", comment: "")
            
        case .customBooleanQuestion:
            return NSLocalizedString("Custom Boolean Question", comment: "")
            
        case .dateQuestion:
            return NSLocalizedString("Date Question", comment: "")
            
        case .dateTimeQuestion:
            return NSLocalizedString("Date and Time Question", comment: "")
            
        case .date3DayLimitQuestionTask:
            return NSLocalizedString("Date and Time 3 day Limit Question", comment: "")
            
        case .healthQuantity:
            return NSLocalizedString("Health Quantity Question", comment: "")
            
        case .heightQuestion:
            return NSLocalizedString("Height Question", comment: "")
            
        case .weightQuestion:
            return NSLocalizedString("Weight Question", comment: "")
            
        case .ageQuestion:
            return NSLocalizedString("Age Question", comment: "")
            
        case .imageChoiceQuestion:
            return NSLocalizedString("Image Choice Question", comment: "")
            
        case .locationQuestion:
            return NSLocalizedString("Location Question", comment: "")
            
        case .numericQuestion:
            return NSLocalizedString("Numeric Question", comment: "")
            
        case .scaleQuestion:
            return NSLocalizedString("Scale Question", comment: "")
            
        case .textQuestion:
            return NSLocalizedString("Text Question", comment: "")
            
        case .textChoiceQuestion:
            return NSLocalizedString("Text Choice Question", comment: "")
            
        case .textChoiceQuestionWithImageTask:
            return NSLocalizedString("Text Choice Image Question", comment: "")
            
        case .colorChoiceQuestion:
            return NSLocalizedString("Color Choice Question", comment: "")
            
        case .timeIntervalQuestion:
            return NSLocalizedString("Time Interval Question", comment: "")
            
        case .timeOfDayQuestion:
            return NSLocalizedString("Time of Day Question", comment: "")
            
        case .valuePickerChoiceQuestion:
            return NSLocalizedString("Value Picker Choice Question", comment: "")
            
        case .validatedTextQuestion:
            return NSLocalizedString("Validated Text Question", comment: "")
            
        case .imageCapture:
            return NSLocalizedString("Image Capture Step", comment: "")
            
        case .videoCapture:
            return NSLocalizedString("Video Capture Step", comment: "")
            
        case .frontFacingCamera:
            return NSLocalizedString("Front Facing Camera Step", comment: "")
            
        case .wait:
            return NSLocalizedString("Wait Step", comment: "")
            
        case .PDFViewer:
            return NSLocalizedString("PDF Viewer Step", comment: "")
            
        case .requestPermissions:
            return NSLocalizedString("Request Permissions Step", comment: "")
            
        case .usdzModel:
            return NSLocalizedString("USDZ Model", comment: "")
            
        case .familyHistory:
            return NSLocalizedString("Family History Step", comment: "")
            
        case .eligibilityTask:
            return NSLocalizedString("Eligibility Task Example", comment: "")
            
        case .accountCreation:
            return NSLocalizedString("Account Creation", comment: "")
            
        case .login:
            return NSLocalizedString("Login", comment: "")
            
        case .passcode:
            return NSLocalizedString("Passcode Creation", comment: "")
            
        case .biometricPasscode:
            return NSLocalizedString("Biometric Passcode Creation and Authorization", comment: "")
            
        case .review:
            return NSLocalizedString("Review Step", comment: "")
            
        case .audio:
            return NSLocalizedString("Audio", comment: "")
            
        case .amslerGrid:
            return NSLocalizedString("Amsler Grid", comment: "")
            
        case .tecumsehCubeTest:
            return NSLocalizedString("Tecumseh Cube Test", comment: "")
            
        case .sixMinuteWalk:
            return NSLocalizedString("Six Minute Walk", comment: "")
            
        case .fitness:
            return NSLocalizedString("Fitness Check", comment: "")
            
        case .holePegTest:
            return NSLocalizedString("Hole Peg Test", comment: "")
            
        case .psat:
            return NSLocalizedString("PSAT", comment: "")
            
        case .reactionTime:
            return NSLocalizedString("Reaction Time", comment: "")
            
        case .normalizedReactionTime:
            return NSLocalizedString("Normalized Reaction Time", comment: "")
            
        case .shortWalk:
            return NSLocalizedString("Short Walk", comment: "")
            
        case .spatialSpanMemory:
            return NSLocalizedString("Spatial Span Memory", comment: "")
            
        case .speechRecognition:
            return NSLocalizedString("Speech Recognition", comment: "")
            
        case .speechInNoise:
            return NSLocalizedString("Speech in Noise", comment: "")
            
        case .stroop:
            return NSLocalizedString("Stroop", comment: "")
            
        case .timedWalkWithTurnAround:
            return NSLocalizedString("Timed Walk with Turn Around", comment: "")
            
        case .toneAudiometry:
            return NSLocalizedString("Tone Audiometry", comment: "")
            
        case .dBHLToneAudiometry:
            return NSLocalizedString("dBHL Tone Audiometry", comment: "")
            
        case .splMeter:
            return NSLocalizedString("Environment SPL Meter", comment: "")
            
        case .towerOfHanoi:
            return NSLocalizedString("Tower of Hanoi", comment: "")
            
        case .twoFingerTappingInterval:
            return NSLocalizedString("Two Finger Tapping Interval", comment: "")
            
        case .walkBackAndForth:
            return NSLocalizedString("Walk Back and Forth", comment: "")
            
        case .tremorTest:
            return NSLocalizedString("Tremor Test", comment: "")
            
        case .videoInstruction:
            return NSLocalizedString("Video Instruction", comment: "")
            
        case .kneeRangeOfMotion:
            return NSLocalizedString("Knee Range of Motion", comment: "")
            
        case .shoulderRangeOfMotion:
            return NSLocalizedString("Shoulder Range of Motion", comment: "")
            
        case .trailMaking:
            return NSLocalizedString("Trail Making Test", comment: "")
            
        case .webView:
            return NSLocalizedString("Web View", comment: "")
            
        case .predefinedSpeechInNoiseTask:
            return NSLocalizedString("Predefined Speech In Noise", comment: "")
            
        case .predefinedAVJournalingTask:
            return NSLocalizedString("Predefined AVJournaling", comment: "")
            
        case .predefinedTinnitusTask:
            return NSLocalizedString("Predefined Tinnitus", comment: "")
            
        case .predefinedSelectableHeadphoneTask:
            return NSLocalizedString("Selectable Headphone Detector", comment: "")
            
        case .ble:
            return NSLocalizedString("BLE", comment: "")
            
        case .consentTask:
            return NSLocalizedString("Consent Task", comment: "")
            
        case .consentDoc:
            return NSLocalizedString("Consent Document Review", comment: "")
            
        case .textQuestionPIIScrubbing:
            return NSLocalizedString("Text Question PII Scrubbing", comment: "")
            
        case .methodOfAdjustmentdBHLToneAudiometryTask:
            return NSLocalizedString("Method Of Adjustment Tone Audiometry", comment: "")
            
        case .newdBHLToneAudiometryTask:
            return NSLocalizedString("dBHL Tone Audiometry (New Algorithm)", comment: "")
            
        case .settingStatusStepTask:
            return NSLocalizedString("Setting Status Step Task", comment: "")
            
        case .customStepTask:
            return NSLocalizedString("Custom Step Task", comment: "")
            
        case .studyPromoTask:
            return NSLocalizedString("Study Promo View Controller", comment: "")
            
        case .studySignPostStep:
            return NSLocalizedString("Study Sign Post Step", comment: "")
            
        case .familyHistoryReviewTask:
            return NSLocalizedString("Family History Review Controller", comment: "")
            
        case .longHeaderTask:
            return NSLocalizedString("Long Header Task", comment: "")
            
        case .booleanConditionalFormTask:
                    return NSLocalizedString("Boolean Conditional Form Task", comment: "")
            
        case .surveyWithMultipleOptions:
            return NSLocalizedString("Survey With Multiple Options", comment: "")
        }
    }
}
