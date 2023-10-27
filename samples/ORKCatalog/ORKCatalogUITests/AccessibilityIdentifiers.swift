//
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
            // TODO: Add support for l10n (identifier)
            static var tasksTabButton = "Tasks"
        }
        struct ResultsTab {
            // TODO: Add support for l10n (identifier)
            static var resultsTabButton = "Results"
        }
        struct SettingsTab {
            // TODO: Add support for l10n (identifier)
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
        
        // TODO: l10n support
        static var backButton = "Back"
        static var cancelButton = "Cancel"
        
        // TODO: l10n support
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
    }
    
    struct FormStep {
        static var view = "ORKFormStepView"
    }
    
    struct Question {
        static var title = "ORKSurveyCardHeaderView_titleLabel"
    }
}
