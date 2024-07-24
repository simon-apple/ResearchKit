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

struct AccessibilityIdentifiers {
    
    struct TabBar {
        struct TasksTab {
            static let title = "ORKCatalog"
            // TODO: rdar://117821622 (Add localization support for UI Tests)
            static let tasksTabButton = "Tasks"
        }
        struct ResultsTab {
            // TODO: rdar://117821622 (Add localization support for UI Tests)
            static let resultsTabButton = "Results"
        }
        struct SettingsTab {
            // TODO: rdar://117821622 (Add localization support for UI Tests)
            static let settingsTabButton = "Settings"
        }
    }
    
    struct Step {
        static let title = "ORKStepContentView_titleLabel"
        static let text = "ORKStepContentView_textLabel"
        static let detailText = "ORKStepContentView_detailTextLabel"
        
        static let continueButton = "ORKContinueButton"
        static let nextButton = "ORKContinueButton.Next"
        static let skipButton = "ORKNavigationContainerView_skipButton"
        
        // TODO: rdar://117821622 (Add localization support for UI Tests)
        static let backButton = "Back"
        static let cancelButton = "Cancel"
        
        // TODO: rdar://117821622 (Add localization support for UI Tests)
        struct CancelActionSheetModal {
            static let endTask = "End Task"
            static let discardResults = "Discard Results"
        }
    }
    
    struct InstructionStep {
        static let view = "ORKInstructionStepView"
        static let bodyView = "ORKStepBodyContainerView"
    }
    
    struct QuestionStep {
        static let view = "ORKQuestionStepView"
        static let bodyContainerView = "ORKStepBodyContainerView"
    }
    
    struct FormStep {
        static let view = "ORKFormStepView"
        
        struct FormItem {
            static let clearTextViewButton = "ORKClearTextViewButton"
        }
    }
    
    struct Question {
        static let title = "ORKSurveyCardHeaderView_titleLabel"
        static let detailText = "ORKSurveyCardHeaderView_detailTextLabel"
        static let progressLabel = "ORKSurveyCardHeaderView_progressLabel"
        static let selectAllThatApplyLabel = "ORKSurveyCardHeaderView_selectAllThatApplyLabel"
    }
    
    struct RequestPermissionsStep {
        static let view = "ORKRequestPermissionsStepView"
        static let permissionButtonLabelDefault = "ORKRequestPermissionButtonDefaultLabel"
        static let permissionButtonLabelConnected = "ORKRequestPermissionButtonConnectedLabel"
        static let permissionButton = "ORKRequestPermissionButton"
    }
    
    struct ActiveStep {
        static let view = "ORKActiveStepView"
    }
    
    struct LearnMoreStep {
        static let view = "ORKLearnMoreStepView"
        static let learnMoreButton = "ORKLearnMoreDetailDisclosureButton"
        static let doneButtonNavigationBar = "ORKLearnMoreStepViewDoneButton"
    }
    
    struct WebView {
        static let signatureView = "ORKSignatureView"
        static let signatureViewClearButton = "ORKSignatureViewClearButton"
    }
    
    struct PDFViewerStep {
        static let view = "ORKPDFViewerStepView"
        static let showPDFThumbnailActionButton = "ORKPDFViewerStep_showPDF_thumbnailActionButton"
        static let hidePDFThumbnailActionButton = "ORKPDFViewerStep_hidePDF_thumbnailActionButton"
        static let annotationActionButton = "ORKPDFViewerStep_annotationActionButton"
        static let showSearchActionButton = "ORKPDFViewerStep_showSearchActionButton"
        static let hideSearchActionButton = "ORKPDFViewerStep_hideSearchActionButton"
        static let shareActionButton = "ORKPDFViewerStep_shareActionButton"
        static let exitButton = "ORKPDFViewerActionView_exitButton"
        static let applyButton = "ORKPDFViewerActionView_applyButton"
        static let clearButton = "ORKPDFViewerActionView_clearButton"
    }
    
    struct WaitStep {
        static let view = "ORKWaitStepView"
    }
    
    struct PasscodeStep {
        static let view = "ORKPasscodeStepView"
    }
    
    struct VerificationStep {
        static let view = "ORKVerificationStepView"
        static let resendEmailButton = "ORKVerificationStepViewResendEmailButton"
    }
    
    struct CustomStep {
        static let view = "ORKCustomStepView"
    }
    
    struct EnvironmentSPLMeterStep {
        static var view = "ORKEnvironmentSPLMeterStepView"
        static var optimumNoiseOKLabel = "ORKEnvironmentSPLMeterOptimumNoiseLevelLabel"
    }
    
    struct DBHLToneAudiometryStep {
        static var view = "ORKdBHLToneAudiometryStepView"
        static var progressLabel = "ORKdBHLToneAudiometryTestInProgressLabel"
    }
    
    struct HeadphoneDetectStep {
        static var view = "ORKHeadphoneDetectStepView"
        static var headphoneTypeLabel = "ORKHeadphoneTypeTextLabel"
        static var noiseCancellationRequiredLabel = "ORKNoiseCancellationRequiredLabel"
    }
    
    // Identifier for the cell label in the Results Tab (based on "ResultRow" text in "ORKCatalog/Results/ResultTableViewProviders.swift")
    enum ResultRow {
        case bool  // ORKBooleanQuestionResult
        case choices  // ORKChoiceQuestionResult
        case dateAnswer // ORKDateQuestionResult - The date the user entered
        case calendar // ORKDateQuestionResult - The calendar that was used when the date picker was presented.
        case timeZone // ORKDateQuestionResult - The timezone when the user answered.
        case latitude // ORKLocationQuestionResult
        case longitude // ORKLocationQuestionResult
        case address // ORKLocationQuestionResult
        case numericAnswer // ORKNumericQuestionResult - The numeric value the user entered
        case unit  // ORKNumericQuestionResult - The unit string with the numeric value
        case displayUnit // ORKNumericQuestionResult - The unit string that was displayed with the numeric value
        case rungPicked // ORKSESQuestionResult - The value returned from the socieoeconomic rung selected.
        case scaleAnswer // ORKScaleQuestionResult - The numeric value returned from the discrete or continuous slider.
        case textAnswer // ORKTextQuestionResult - The text the user typed into the text view.
        case intervalAnswer  // ORKTimeIntervalQuestionResult -  The time interval the user answered.
        case dateComponentsAnswer  // ORKTimeOfDayQuestionResult -  String summarizing the date components the user entered.
        
        var detailTextLabelIdentifier: String {
            return "\(String(describing: self))_value"
        }
    }
}
