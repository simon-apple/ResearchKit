//  AccessibilityIdentifiers.swift
//  ORKCatalogUITests
//
//  Created by Albina Kashapova on 10/25/23.
//  Copyright © 2023 researchkit.org. All rights reserved.
//

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
}
