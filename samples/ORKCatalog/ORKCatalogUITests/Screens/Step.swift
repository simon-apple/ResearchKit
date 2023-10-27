//  Step.swift
//  ORKCatalogUITests
//
//  Created by Albina Kashapova on 10/25/23.
//  Copyright © 2023 researchkit.org. All rights reserved.
//

import Foundation
import XCTest

/// Base class that contains methods and elements that are common for all Steps: Instruction Step, Question Step, Form Step
/// It corresponds to `ORKStep` that represents the primary unit of work in any task
class Step {
    static let app = XCUIApplication()
    let id: String
    /// Sometimes we need step id to verify steps order in survey tasks when needed
    init(id: String = "") {
        self.id = id
    }
    
    enum StepComponent {
        case title, text, detailText, continueButton, nextButton, skipButton, backButton, cancelButton, endTaskButton, discardResultsButton
        
        var identifier: String {
            switch self {
            case .title:
                return AccessibilityIdentifiers.Step.title
            case .text: /// it is related to the text that shown below the step title
                return AccessibilityIdentifiers.Step.text
            case .detailText:
                return AccessibilityIdentifiers.Step.detailText
            case .continueButton:
                return AccessibilityIdentifiers.Step.continueButton
            case .nextButton:
                return AccessibilityIdentifiers.Step.nextButton
            case .skipButton:
                return AccessibilityIdentifiers.Step.skipButton
            case .backButton:
                return AccessibilityIdentifiers.Step.backButton
            case .cancelButton:
                return AccessibilityIdentifiers.Step.cancelButton
            case .endTaskButton:
                return AccessibilityIdentifiers.Step.CancelActionSheetModal.endTask
            case .discardResultsButton:
                return AccessibilityIdentifiers.Step.CancelActionSheetModal.discardResults
            }
        }
        
        /// Query for elements
        var element: XCUIElement {
            switch self {
            case .title, .text, .detailText:
                return app.staticTexts[self.identifier].firstMatch
            case .skipButton, .nextButton:
                return app.buttons[self.identifier].firstMatch
            case .cancelButton, .backButton:
                return app.navigationBars.buttons[self.identifier].firstMatch
            case .discardResultsButton, .endTaskButton:
                return app.scrollViews.buttons[self.identifier].firstMatch
            case .continueButton:
                return app.buttons.beginning(with: self.identifier).firstMatch
            }
        }
    }
    
    /// All methods below implemented with test readability in mind (therefore I pass StepComponent and not generic XCUIElement type) in order to not define UI elements in UI tests itself
    
    @discardableResult
    func verify(_ element: StepComponent, exists: Bool = true, shouldWait: Bool = true) -> Self {
        let additionalFailureMessage = "Step component: \(element), Element identifier:  \(element.identifier)"
        if shouldWait {
            wait(for: element.element, toExists: exists, failureMessage: additionalFailureMessage)
        } else {
            XCTAssert(element.element.exists == exists, additionalFailureMessage)
        }
        return self
    }
    
    /// Method for buttons
    @discardableResult
    func verify(_ button: StepComponent, isEnabled: Bool, shouldWait: Bool = true) -> Self {
        let additionalFailureMessage  = "Step button: \(button), Identifier:  \(button.identifier)"
        let button = button.element
        if shouldWait {
            wait(for: button, toExists: true, failureMessage: additionalFailureMessage)
            wait(for: button, toBeEnabled: isEnabled, failureMessage: additionalFailureMessage)
        } else {
            XCTAssert(button.isEnabled == isEnabled, additionalFailureMessage)
        }
        return self
    }
    
    /// Method for buttons
    @discardableResult
    func tap(_ button: StepComponent, shouldWait: Bool = true) -> Self {
        let button = button.element
        if shouldWait {
            wait(for: button, toExists: true)
        }
        button.tap()
        return self
    }
    
    /// Taps "Cancel" button on the navigation bar and subsequently taps "End Task" button in action sheet modal view
    func cancelTask() -> TasksTab {
        let cancelButton = Self.StepComponent.cancelButton.element
        wait(for: cancelButton)
        cancelButton.tap()
        // At this point, action sheet modal view is presented
        let endTaskButton = Self.StepComponent.endTaskButton.element
        let discardResultsButton = Self.StepComponent.discardResultsButton.element
        // Button label can be different for different tasks ("End Task" or "Discard Results") we cover both variants
        if endTaskButton.waitForExistence(timeout: 20) {
            endTaskButton.tap()
        } else {
            discardResultsButton.tap()
        }
        return TasksTab()
    }
    
    // TODO: l10n support
    /// Most steps display a button that enables forward navigation. This button can have titles such as:
    enum ContinueButtonLabel: String {
        case next = "Next"
        case getStarted = "Get Started"
        case done = "Done"
    }
    
    /**
     Continue Button label is dynamic, we verify actual label vs expected
     - parameter expectedLabel: expected label of Continue Button
     */
    @discardableResult
    func verifyContinueButtonLabel(expectedLabel: ContinueButtonLabel) -> Self {
        let continueButton = Self.StepComponent.continueButton.element
        XCTAssertEqual(continueButton.label, expectedLabel.rawValue, "Expected label \(expectedLabel.rawValue) for Continue Button, but found \(continueButton.label)")
        return self
    }
    
    // TODO: add an identifier to step progress label to enable more generic verification (verify just existence of label)
    // Verify if step progress label is present on navigation bar
    // func verifyStepProgressLabelExistsAndNotEmpty() {}

    /**
     Verifies the existence and correctness of step progress label on navigation bar
     - parameter currentProgress: current step number  (index starts with 1)
     - parameter totalProgress: expected total number of steps in task
     */
    func verifyCurrentStepProgress(currentProgress: Int, totalProgress: Int) -> Self {
        // TODO: L10n support
        let currentProgressLabel = "\(currentProgress) of \(totalProgress)"
        let currentProgressElement = Self.app.navigationBars.staticTexts[currentProgressLabel].firstMatch
        wait(for: currentProgressElement)
        return self
    }
}
