//  AnswerableStep.swift
//  ORKCatalogUITests
//
//  Created by Albina Kashapova on 10/25/23.
//  Copyright © 2023 researchkit.org. All rights reserved.
//

import Foundation
import XCTest

/// Parent class for Question Step and Form Step containing common methods for handling different answer format interactions
/// https://github.com/ResearchKit/ResearchKit/blob/main/docs/Survey/CreatingSurveys-template.markdown#answer-formats
class AnswerableStep: Step {
    
    // MARK: - Question title verification
    
    static var firstQuestionTitle: XCUIElement {
        app.staticTexts[AccessibilityIdentifiers.Question.title].firstMatch
    }
    
    static var questionTitleQuery: XCUIElementQuery {
        app.staticTexts.matching(identifier: AccessibilityIdentifiers.Question.title)
    }
    
    /// Verify first question title is present and not empty
    @discardableResult
    func verifyQuestionTitleExistsAndNotEmpty() -> Self {
        wait(for: Self.firstQuestionTitle)
        XCTAssertTrue(!Self.firstQuestionTitle.label.isEmpty, "Question title should not be empty")
        return self
    }
    
    /// Verify question title is present with specified index
    @discardableResult
    func verifyQuestionTitleExists(questionIndex index: Int) -> Self {
        let title = Self.questionTitleQuery.element(boundBy: index)
        wait(for: title, failureMessage: "Question title at specified index \(index) not found")
        
        return self
    }
    
    /// Verify question title is present and not empty
    @discardableResult
    func verifyQuestionTitleExistsAndNotEmpty(questionIndex index: Int) -> Self {
        let title = Self.questionTitleQuery.element(boundBy: index)
        wait(for: title, failureMessage: "Question title at specified index \(index) not found")
        XCTAssertTrue(!title.label.isEmpty, "Question title should not be empty")
        return self
    }
    
    // MARK: - Text Choice Answer Format methods
    
    // Known issue: When the cell to be selected is at the bottom of the screen (it is even barely visible, but visible for XCUITest). XCUITest incorrectly taps previous cell, resulting the wrong cell index being selected
    func selectChoiceCell(_ cell: XCUIElement) {
        if !cell.visible {
            cell.scrollUntilVisible()
        }
        cell.tap()
        wait(for: cell, toBeSelected: true, failureMessage: "Choice cell \(cell) with identifier \(cell.identifier)")
    }
    
    /**
     Returns cell element by it's index and form item identifier (if present)
     - parameter formItemId: The string that identifies the form item, which should be unique within the form step.
     - parameter index: Index of cell that will be returned
     */
    func getCell(withId formItemId: String = "", atIndex index: Int) -> XCUIElement {
        var cell: XCUIElement
        if formItemId.isEmpty {
            cell = QuestionStep().getCell(atIndex: index)
        } else {
            cell = FormStep().getFormItemCell(withID: formItemId, atIndex: index)
        }
        return cell
    }
    
    // MARK: - Single Choice Style Answer Format
    
    /**
     Handles ORKBooleanAnswerFormat (an answer format that lets participants choose from yes/no choices). The text choices are presented in a table view, using one row for each answer.
     - parameter index: index of cell that will be selected (0 or 1)
     - parameter yesString: A string that describes the Yes answer. For custom boolean questions expected button labels need to be provided.
     - parameter noString: A string that describes the No answer. For custom boolean questions expected button labels need to be provided.
     */
    // TODO: rdar://117821622 (Add localization support for UI Tests)
    @discardableResult
    func answerBooleanQuestion(
        withId formItemId: String = "",
        atIndex index: Int,
        yesString: String = "Yes",
        noString: String = "No"
    ) -> Self {
        guard index <= 1 else {
            XCTFail("Cell index should be in range between 0 and 1")
            return self
        }
        let firstCell = getCell(withId: formItemId, atIndex: 0)
        let secondCell = getCell(withId: formItemId, atIndex: 1)
        XCTAssertEqual(firstCell.label, yesString)
        XCTAssertEqual(secondCell.label, noString)
        
        answerSingleChoiceTextQuestion(atIndex: index)
        return self
    }
    /**
     Selects cell by it's index.
     Handle ORKTextChoiceAnswerFormat with single choice style (an answer format that lets participants choose from a fixed set of text choices). The text choices are presented in a table view, using one row for each answer.
     - parameter formItemId: The string that identifies the form item, which should be unique within the form step
     - parameter index: index of cell that will be selected
     */
    @discardableResult
    func answerSingleChoiceTextQuestion(withId formItemId: String = "", atIndex index: Int) -> Self {
        let cellToSelect = getCell(withId: formItemId, atIndex: index)
        selectChoiceCell(cellToSelect)
        return self
    }
    
    /**
     Verify that we only have 1 cell selected across several cells (we need specific range because other questions may also be selected)
     - parameter formItemId: The string that identifies the form item, which should be unique within the form step
     - parameter index: index that should be selected
     - parameter cellsRange: the range of cells that will be verified
     */
    @discardableResult
    func verifyOnlyOneCellSelected(
        withId formItemId: String = "",
        atIndex index: Int,
        cellsChoiceRange cellsRange: (
            start: Int,
            end: Int
        )
    ) -> Self {
        var currentCell: XCUIElement
        for i in cellsRange.start...cellsRange.end {
            currentCell = getCell(withId: formItemId, atIndex: i)
            if !currentCell.visible {
                currentCell.scrollUntilVisible()
            }
            if i == index {
                XCTAssert(currentCell.isSelected, "Cell at index \(i) should be selected")
            } else {
                XCTAssert(!currentCell.isSelected, "Cell at index \(i) should not be selected")
            }
            XCTAssert(!currentCell.label.isEmpty, "Text choice cell should not be empty")
        }
        return self
    }
    
    // MARK: - Multiple Choice Style Answer Format
    
    /**
     Selects cells by it's index.
     Handle ORKTextChoiceAnswerFormat with multiple choice style.
     - parameter formItemId: The string that identifies the form item, which should be unique within the form step
     - parameter indices: indices of cells that will be selected
     */
    @discardableResult
    func answerMultipleChoiceTextQuestion(withId formItemId: String = "", indices: [Int]) -> Self {
        var cellToSelect: XCUIElement
        for index in indices {
            cellToSelect = getCell(withId: formItemId, atIndex: index)
            selectChoiceCell(cellToSelect)
        }
        return self
    }
    
    /**
     Verifies that only the necessary cells are selected
     - parameter formItemId: The string that identifies the form item, which should be unique within the form step
     - parameter indices: indices that should be selected
     - parameter cellsRange: the range of cells that will be verified
     */
    @discardableResult
    func verifyMultipleCellsSelected(
        withId formItemId: String = "",
        indices: [Int],
        cellsChoiceRange cellsRange: (
            start: Int,
            end: Int
        )
    ) -> Self {
        var currentCell: XCUIElement
        for i in cellsRange.start...cellsRange.end {
            currentCell = getCell(withId: formItemId, atIndex: i)
            if !currentCell.visible {
                currentCell.scrollUntilVisible()
            }
            if indices.contains(i) {
                XCTAssert(currentCell.isSelected, "Cell at index \(i) should be selected")
            } else {
                XCTAssert(!currentCell.isSelected, "Cell at index \(i) should not be selected")
            }
            XCTAssert(!currentCell.label.isEmpty, "Text choice cell should not be empty")
        }
        return self
    }
    
    /// Verify that user did not select any answer
    func verifyNoCellsSelected(withId formItemId: String = "", _ numberOfTextChoices: Int) -> Self {
        for index in 0..<numberOfTextChoices {
            let currentCell = getCell(withId: formItemId, atIndex: index)
            if !currentCell.visible {
                currentCell.scrollUntilVisible()
            }
            XCTAssert(!currentCell.isSelected, "Cell at index \(index) should not be selected")
        }
        return self
    }
    
    // MARK: - Integer and Text Answer Format methods
    
    /**
     Enters number. Handle ORKNumericAnswerFormat integerAnswerFormat (a numeric answer format that participants enter using a numeric keyboard)
     - parameter number: number to be entered
     - parameter dismissKeyboard: whether the keyboard should be dismissed and hidden after entering number
     */
    @discardableResult
    func answerIntegerQuestion(number: Int, dismissKeyboard: Bool = false) -> Self {
        Keyboards.enterNumber(number, dismissKeyboard: dismissKeyboard)
        return self
    }
    
    /**
     Enters text. Handle ORKTextAnswerFormat the answer format for questions that collect a text response from the user.
     - parameter text: text to be entered
     - parameter dismissKeyboard: whether the keyboard should be dismissed and hidden
     */
    @discardableResult
    func answerTextQuestion(text: String, dismissKeyboard: Bool = false) -> Self {
        Keyboards.enterText(text, dismissKeyboard: dismissKeyboard)
        return self
    }
    
    // MARK: - Scale Answer Format methods
    
    static var firstSlider = app.sliders.firstMatch
    
    /// Adjusts first found slider to normalized position
    @discardableResult
    func adjustFirstSlider(toNormalizedSliderPosition: CGFloat) -> Self {
        wait(for: Self.firstSlider)
        Self.firstSlider.adjust(toNormalizedSliderPosition: toNormalizedSliderPosition)
        return self
    }
    
    /**
     Handles ORKContinuousScaleAnswerFormat
    - parameter formItemId: The string that identifies the form item, which should be unique within the form step
    - parameter index: form item cell index. Usually form item cell index is 0 unless it's from item within a section
    */
    @discardableResult
    func answerScaleQuestion(withId formItemId: String = "", atIndex index: Int = 0, withNormalizedPosition: CGFloat) -> Self {
        let cell = getCell(withId: formItemId, atIndex: index)
        if !cell.visible {
            cell.scrollUntilVisible()
        }
        let slider = cell.sliders.firstMatch
        slider.adjust(toNormalizedSliderPosition: withNormalizedPosition)
        
        return self
    }
    
    // MARK: - Date and Time Answer Format
    
    // Usually, there is only one UI picker  presented on the screen
    static var firstPicker = app.pickers.firstMatch
    /**
     Enters time interval
     Handles ORKTimeIntervalAnswerFormat
     - parameter hours: hours to be entered
     - parameter minutes: minutes to be entered
     */
    @discardableResult
    func answerTimeIntervalQuestion(hours: Int, minutes: Int, dismissPicker: Bool = false) -> Self {
        guard hours < 24 && minutes < 60 else {
            XCTFail("The time interval should be less than 24 hours")
            return self
        }
        adjustPickerWheels(hours: hours, minutes: minutes, dismissPicker: dismissPicker)
        return self
    }
    
    func adjustPickerWheels(hours: Int, minutes: Int, dismissPicker: Bool = false) {
        let picker = Self.firstPicker
        wait(for: picker)
        let hourWheel = picker.pickerWheels.element(boundBy: 0)
        let minuteWheel = picker.pickerWheels.element(boundBy: 1)
        
        hourWheel.adjust(toPickerWheelValue: String(hours))
        minuteWheel.adjust(toPickerWheelValue: String(minutes))
        if dismissPicker {
            Keyboards.tapDoneButtonOnToolbar()
        }
    }
    
    /// Adjusts the picker wheels to provided date
    @discardableResult
    func answerDateQuestion(year: String, month: String, day: String, dismissPicker: Bool = false) -> Self {
        let picker = Self.firstPicker
        picker.pickerWheels.element(boundBy: 2).adjust(toPickerWheelValue: year)
        picker.pickerWheels.element(boundBy: 1).adjust(toPickerWheelValue: day)
        picker.pickerWheels.element(boundBy: 0).adjust(toPickerWheelValue: month)
        if dismissPicker {
            Keyboards.tapDoneButtonOnToolbar()
        }
        return self
    }
    
    /// Verifies that the UI date picker defaults to the current date
    func verifyDatePickerDefaultsToCurrentDate() -> Self {
        let currentDate = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d yyyy"
        let currentDateComponents = formatter.string(from: currentDate).components(separatedBy: " ")
        let expectedMonth = currentDateComponents[0]
        let expectedDay = currentDateComponents[1]
        let expectedYear = currentDateComponents[2]
        
        let picker = Self.firstPicker
        let actualYear = picker.pickerWheels.element(boundBy: 2).value as? String ?? ""
        let actualDay = picker.pickerWheels.element(boundBy: 1).value as? String ?? ""
        let actualMonth = picker.pickerWheels.element(boundBy: 0).value as? String ?? ""
        
        XCTAssertEqual(actualYear, expectedYear, "The year picker wheel is not showing correct value. Expected \(expectedYear) but got \(actualYear)")
        XCTAssertEqual(actualDay, expectedDay, "The day picker wheel is not showing correct value. Expected \(expectedDay) but got \(actualDay)")
        XCTAssertEqual(actualMonth, expectedMonth, "The month picker wheel is not showing correct value. Expected \(expectedMonth) but got \(actualMonth)")
        return self
    }
    
    // MARK: -  SES Answer Format
    
    /// Handles SES ladder question ORKSESAnswerFormat
    /// - parameter formItemId: The string that identifies the form item, which should be unique within the form step
    @discardableResult
    func answerSESladder(withID formItemId: String = "", buttonIndexToSelect: Int) -> Self {
        guard buttonIndexToSelect <= 9 else {
            XCTFail("Button index should be in range between 0 and 9")
            return self
        }
        let cell = getCell(withId: formItemId, atIndex: 0)
        let radioButton = cell.buttons.element(boundBy: buttonIndexToSelect)
        wait(for: radioButton)
        wait(for: radioButton, toBeSelected: false)
        radioButton.tap()
        wait(for: radioButton, toBeSelected: true)
        return self
    }
}
