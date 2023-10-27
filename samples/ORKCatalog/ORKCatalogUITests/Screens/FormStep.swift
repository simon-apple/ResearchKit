//
//  FormStep.swift
//  ORKCatalogUITests
//
//  Created by Albina Kashapova on 10/25/23.
//  Copyright © 2023 researchkit.org. All rights reserved.
//

import Foundation
import XCTest

/// This class corresponds to a single screen that displays multiple questions or items (`ORKFormStep`). Form steps support all the same answer formats as question steps, but can contain multiple items (ORKFormItem), each with its own answer format.
/// https://github.com/ResearchKit/ResearchKit/blob/main/docs/Survey/CreatingSurveys-template.markdown#form-step
final class FormStep: AnswerableStep {
    
    // Array of string that identifies the form item, which should be unique within the form step.
    var items: [String]
    init(id: String = "", items: [String] = []) {
        self.items = items
        super.init(id: id)
    }
   
    static var stepView: XCUIElement {
        app.otherElements[AccessibilityIdentifiers.FormStep.view].firstMatch
    }
    
    /// Verify that step type did not change
    func verifyStepView(_ exists: Bool = true) -> Self {
        wait(for: Self.stepView, toExists: exists)
        return self
    }
    
    /**
     Returns form item cell
     - parameter formItemId:The string that identifies the form item, which should be unique within the form step
     - parameter index:form item cell index. Usually form item cell index is 0 unless it's from item within a section or form item choice view cell
     */
    func getFormItemCell(withID formItemId: String, atIndex index: Int = 0) -> XCUIElement {
        let id = "\(formItemId)_\(index)"
       // let cell = Self.app.tables.cells.ending(with: id).firstMatch
        let cell = Self.stepView.cells[id].firstMatch
        return cell
    }
    
    /**
     Selects form item cell by it's id and index (in order to enable keyboard).
     If autoscroll is triggered, there is no need to select form item
     - parameter formItemId:The string that identifies the form item, which should be unique within the form step
     - parameter index:form item cell index that should be selected. Usually form item cell index is 0 unless it's from item within a section or form item choice view cell
     */
    @discardableResult
    func selectFormItemCell(withID formItemId: String, atIndex index: Int = 0) -> Self {
        let cell = getFormItemCell(withID: formItemId, atIndex: index)
        if !cell.visible {
            cell.scrollUntilVisible()
        }
        cell.tap()
        return self
    }
    
    /// Sometimes this method does not work because view hierarchy changes. It works when the structure includes:  Other, 0x12bd3a490, {{0.0, 113.0}, {390.0, 82.0}}, identifier: 'Question 3 of 4' and question title identifier exists.
    /// Verify the existence and correctness of question progress label out of total questions
    @discardableResult
    func verifyQuestionProgressAndTitleExists(questionIndex: Int, totalQuestions: Int) -> Self {
        let currentProgress = questionIndex + 1
        // TODO: l10n support
        let currentProgressLabel = "Question \(currentProgress) of \(totalQuestions)"
        let currentProgressElement = Self.stepView.tables.otherElements[currentProgressLabel].firstMatch
        wait(for: currentProgressElement, failureMessage: "Question progress label \(currentProgressLabel) not found at index")
        let currentQuestionTitle = currentProgressElement.staticTexts[AccessibilityIdentifiers.Question.title].firstMatch
        
        wait(for: currentQuestionTitle, failureMessage: "Question title not found at index \(questionIndex)")
        return self
    }
    
    /// Verify the existence of question progress label (current question number out of the total number of questions)
    @discardableResult
    func verifyQuestionProgressLabelExists(questionIndex: Int, totalQuestions: Int) -> Self {
        let currentProgress = questionIndex + 1
        // TODO: l10n support
        let currentProgressLabel = "Question \(currentProgress) of \(totalQuestions)"
        let currentProgressLabelElement = Self.stepView.otherElements[currentProgressLabel].firstMatch
        wait(for: currentProgressLabelElement, failureMessage: "Question progress label \(currentProgressLabel) not found at index")
        return self
    }
    
    @discardableResult
    func scrollDownToStepTitle(maxSwipes: Int = 15) -> Self {
        let stepTitle = Self.StepComponent.title.element
        if !stepTitle.visible {
            stepTitle.scrollUntilVisible(direction: .down, maxSwipes: maxSwipes)
        }
        return self
    }
    
    @discardableResult
    func scrollTo(_ stepComponent: StepComponent, direction: SwipeDirection = .up) -> Self {
        let stepComponent = stepComponent.element
        if !stepComponent.visible {
            stepComponent.scrollUntilVisible(direction: direction)
        }
        return self
    }
}
