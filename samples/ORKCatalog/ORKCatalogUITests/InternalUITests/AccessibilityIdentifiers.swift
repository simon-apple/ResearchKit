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
            static var title = "ORKCatalog"
            // TODO: rdar://117821622 (Add localization support for UI Tests)
            static var tasksTabButton = "Tasks"
        }
        struct ResultsTab {
            // TODO: rdar://117821622 (Add localization support for UI Tests)
            static var resultsTabButton = "Results"
        }
        struct SettingsTab {
            // TODO: rdar://117821622 (Add localization support for UI Tests)
            static var settingsTabButton = "Settings"
        }
    }
    
    struct Step {
        static var title = "ORKStepContentView_titleLabel"
        static var text = "ORKStepContentView_textLabel"
        static var detailText = "ORKStepContentView_detailTextLabel"
        
        static var continueButton = "ORKContinueButton"
        static var nextButton = "ORKContinueButton.Next"
        static var skipButton = "ORKNavigationContainerView_skipButton"
        
        // TODO: rdar://117821622 (Add localization support for UI Tests)
        static var backButton = "Back"
        static var cancelButton = "Cancel"
        
        // TODO: rdar://117821622 (Add localization support for UI Tests)
        struct CancelActionSheetModal {
            static var endTask = "End Task"
            static var discardResults = "Discard Results"
        }
    }
    
    struct InstructionStep {
        static var view = "ORKInstructionStepView"
    }
    
    struct QuestionStep {
        static var view = "ORKQuestionStepView"
        static var bodyContainerView = "ORKStepBodyContainerView"
    }
    
    struct FormStep {
        static var view = "ORKFormStepView"
        
        struct FormItem {
            static var clearTextViewButton = "ORKClearTextViewButton"
        }
    }
    
    struct Question {
        static var title = "ORKSurveyCardHeaderView_titleLabel"
        static var detailText = "ORKSurveyCardHeaderView_detailTextLabel"
        static var progressLabel = "ORKSurveyCardHeaderView_progressLabel"
        static var selectAllThatApplyLabel = "ORKSurveyCardHeaderView_selectAllThatApplyLabel"
        
    }
    
    struct RequestPermissionsStep {
        static var view = "ORKRequestPermissionsStepView"
        static var permissionButtonLabelDefault = "ORKRequestPermissionButtonDefaultLabel"
        static var permissionButtonLabelConnected = "ORKRequestPermissionButtonConnectedLabel"
        static var permissionButton = "ORKRequestPermissionButton"
    }
    
    struct ActiveStep {
        static var view = "ORKActiveStepView"
    }
}
