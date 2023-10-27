//
//  TasksTab.swift
//  ORKCatalogUITests
//
//  Created by Albina Kashapova on 10/25/23.
//  Copyright © 2023 researchkit.org. All rights reserved.
//

import Foundation
import XCTest

// Tasks tab on the bottom tab bar
class TasksTab {
    static let app = XCUIApplication()
    static var title: XCUIElement {
        app.navigationBars[AccessibilityIdentifiers.TabBar.TasksTab.title].firstMatch
    }
    
    @discardableResult
    func assertTitle(exists: Bool = true) -> Self {
        wait(for: Self.title, toExists: exists, failureMessage: "Please ensure that the app is navigated to Tasks Tab")
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
    case familyHistory
    case eligibilityTask
    case accountCreation
    case login
    case passcode
    case biometricPasscode
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
    case heightQuestion
    case weightQuestion
    case ageQuestion
    case kneeRangeOfMotion
    case shoulderRangeOfMotion
    case trailMaking
    case videoInstruction
    case webView
    
#if RK_APPLE_INTERNAL
    case catalogVersion
    case predefinedSpeechInNoiseTask
    case predefinedAVJournalingTask
    case predefinedTinnitusTask
    case ble
    case textQuestionPIIScrubbing
    case newdBHLToneAudiometryTask
    case customStepTask
    case studyPromoTask
    case studySignPostStep
    case consentTask
    case consentDoc
    case familyHistoryReviewTask
    case booleanConditionalFormTask
#endif
    
    var description: String {
        switch self {
        case .form:
            return NSLocalizedString("Form Survey Example", comment: "")
            
        case .groupedForm:
            return NSLocalizedString("Grouped Form Survey Example", comment: "")
            
        case .survey:
            return NSLocalizedString("Simple Survey Example", comment: "")
            
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
            return NSLocalizedString("Video Instruction Task", comment: "")
            
        case .kneeRangeOfMotion:
            return NSLocalizedString("Knee Range of Motion", comment: "")
            
        case .shoulderRangeOfMotion:
            return NSLocalizedString("Shoulder Range of Motion", comment: "")
            
        case .trailMaking:
            return NSLocalizedString("Trail Making Test", comment: "")
            
        case .webView:
            return NSLocalizedString("Web View", comment: "")
            
#if RK_APPLE_INTERNAL
        case .catalogVersion:
            return NSLocalizedString("Catalog App Version History", comment: "")
            
        case .predefinedSpeechInNoiseTask:
            return NSLocalizedString("Predefined Speech In Noise", comment: "")
            
        case .predefinedAVJournalingTask:
            return NSLocalizedString("Predefined AVJournaling", comment: "")
            
        case .predefinedTinnitusTask:
            return NSLocalizedString("Predefined Tinnitus", comment: "")
            
        case .ble:
            return NSLocalizedString("BLE", comment: "")
            
        case .consentTask:
            return NSLocalizedString("Consent Task", comment: "")
            
        case .consentDoc:
            return NSLocalizedString("Consent Document Review", comment: "")
            
        case .textQuestionPIIScrubbing:
            return NSLocalizedString("Text Question PII Scrubbing", comment: "")
            
        case .newdBHLToneAudiometryTask:
            return NSLocalizedString("dBHL Tone Audiometry (New Algorithm)", comment: "")
            
        case .customStepTask:
            return NSLocalizedString("Custom Step Task", comment: "")
            
        case .studyPromoTask:
            return NSLocalizedString("Study Promo View Controller", comment: "")
            
        case .studySignPostStep:
            return NSLocalizedString("Study Sign Post Step", comment: "")
            
        case .familyHistoryReviewTask:
            return NSLocalizedString("Family History Review Controller", comment: "")
            
        case .booleanConditionalFormTask:
                    return NSLocalizedString("Boolean Conditional Form Task", comment: "")
#endif
        case .surveyWithMultipleOptions:
            return NSLocalizedString("Survey With Multiple Options", comment: "")
        }
    }
}
