//  FormStepScreen.swift
//  ORKCatalogUITests
//
//  Created by Albina Kashapova on 10/25/23.
//  Copyright © 2023 researchkit.org. All rights reserved.
//

import Foundation
import XCTest
import OSLog

/// This class corresponds to a single screen that displays questions or form items:`ORKFormStep`
/// https://github.com/ResearchKit/ResearchKit/blob/main/docs/Survey/CreatingSurveys-template.markdown#form-step
final class FormStepScreen: Step {
    
    /**
     - parameter Id: Step Identifier
     - parameter itemIds: Array of string that identifies the form item, which should be unique within the form step.
     */
    var itemIds: [String]
    var answer: Any?
    init(id: String = "", itemIds: [String] = [], answer: Any? = nil) {
        self.itemIds = itemIds
        self.answer = answer
        super.init(id: id)
    }
   
    static var stepView: XCUIElement {
        app.otherElements[AccessibilityIdentifiers.FormStep.view].firstMatch
    }
    
    /// Verifies that step type did not change
    @discardableResult
    func verifyStepView(_ exists: Bool = true) -> Self {
        wait(for: Self.stepView, toExists: exists)
        return self
    }
    
    func stepViewExists(timeout: TimeInterval) -> Bool {
        return Self.stepView.waitForExistence(timeout: timeout)
    }
    
    // MARK: - Question Card View
    
    static var questionTitleQuery: XCUIElementQuery {
        Self.stepView.staticTexts.matching(identifier: AccessibilityIdentifiers.Question.title)
    }
    
    /// Verifies the question title is present and not empty for the case when only one question is on screen
    @discardableResult
    func verifySingleQuestionTitleExists() -> Self {
        let title = Self.questionTitleQuery.element(boundBy: 0)
        wait(for: title, failureMessage: "Question title not found")
        XCTAssertTrue(!title.label.isEmpty, "Question title should not be empty")
        return self
    }
    
    /// Verifies the question title is present with specified index for the case when multiple questions are on screen
    @discardableResult
    func verifyQuestionTitleExists(atIndex index: Int) -> Self {
        let uiIndex = index + 1
        let id = "\(AccessibilityIdentifiers.Question.title)_\(uiIndex)"
        let title = Self.stepView.staticTexts[id].firstMatch
        wait(for: title, failureMessage: "Question title at specified index \(index) not found")
        XCTAssertTrue(!title.label.isEmpty, "Question title should not be empty")
        return self
    }
    
    /// Verifies the question label if only one question should be present on screen
    @discardableResult
    func verifySingleQuestionTitleLabel(expectedLabel: String) -> Self {
        let title = Self.questionTitleQuery.element(boundBy: 0)
        wait(for: title, failureMessage: "Question title not found")
        XCTAssertEqual(title.label, expectedLabel)
        return self
    }
    
    /// Verifies the question label with specified index for the case when multiple questions are on screen
    @discardableResult
    func verifyQuestionTitleLabel(atIndex index: Int, expectedLabel: String) -> Self {
        let uiIndex = index + 1
        let id = "\(AccessibilityIdentifiers.Question.title)_\(uiIndex)"
        let title = Self.stepView.staticTexts[id].firstMatch
        wait(for: title, failureMessage: "Question title at specified index \(index) not found")
        XCTAssertEqual(title.label, expectedLabel)
        return self
    }
    
    /// Verifies that "Select All That Apply" label is present
    @discardableResult
    func verifySelectAllThatApplyExists() -> Self {
        let label = Self.stepView.staticTexts[AccessibilityIdentifiers.Question.selectAllThatApplyLabel].firstMatch
        wait(for: label, failureMessage: "\"Select All That Apply\" Label not found")
        return self
    }
    
    @discardableResult
    func scrollToQuestionTitle(atIndex index: Int, direction: SwipeDirection = .up) -> Self {
        let uiIndex = index + 1
        let id = "\(AccessibilityIdentifiers.Question.title)_\(uiIndex)"
        let title = Self.stepView.staticTexts[id].firstMatch
        if !title.visible {
            title.scrollUntilVisible(direction: direction)
        }
        return self
    }
    
    @discardableResult
    func verifyQuestionProgressLabelExists(atIndex index: Int) -> Self {
        let uiIndex = index + 1
        let id = "\(AccessibilityIdentifiers.Question.progressLabel)_\(uiIndex)"
        let label = Self.stepView.staticTexts[id].firstMatch
        wait(for: label, failureMessage: "Question progress label at specified index \(index) not found")
        XCTAssertTrue(!label.label.isEmpty, "Question progress label should not be empty")
        return self
    }
    
    @discardableResult
    func verifyQuestionProgressLabelText(atIndex index: Int, totalQuestions: Int) -> Self {
        let uiIndex = index + 1
        let id = "\(AccessibilityIdentifiers.Question.progressLabel)_\(uiIndex)"
        let label = Self.stepView.staticTexts[id].firstMatch
        wait(for: label, failureMessage: "Question progress label at specified index \(index) not found")
        let expectedText = "Question \(index) of \(totalQuestions)" /// TODO: rdar://117821622 (Add localization support for UI Tests)
        XCTAssertEqual(label.label, expectedText)
        return self
    }
    
    // MARK: - Form Items Methods
    
    /**
     Returns form item cell by it's form item identifier and index
     - parameter formItemId:The string that identifies the form item, which should be unique within the form step
     - parameter index:form item cell index. Usually form item cell index is 0 unless it's from item within a section or form item choice view cell
     */
    func getFormItemCell(withId formItemId: String, atIndex index: Int = 0) -> XCUIElement {
        let id = "\(formItemId)_\(index)"
       // let cell = Self.app.tables.cells.ending(with: id).firstMatch
        let cell = Self.stepView.cells[id].firstMatch
        return cell
    }
    
    func getFormItemCells(withID formItemId: String) -> XCUIElementQuery {
        return Self.stepView.cells.beginning(with: formItemId)
    }
    
    /**
     Selects form item cell by it's id and index (in order to enable/toggle keyboard to provide an answer).
     If autoscroll is triggered, there is no need to select form item
     - parameter formItemId:The string that identifies the form item, which should be unique within the form step
     - parameter index:form item cell index that should be selected. Usually form item cell index is 0 unless it's from item within a section or form item choice view cell
     */
    @discardableResult
    func selectFormItemCell(withID formItemId: String, atIndex index: Int = 0) -> Self {
        let cell = getFormItemCell(withId: formItemId, atIndex: index)
        if !cell.visible {
            cell.scrollUntilVisible()
        }
        cell.tap()
        return self
    }
    
    // All methods below handling different answer format interactions: https://github.com/ResearchKit/ResearchKit/blob/main/docs/Survey/CreatingSurveys-template.markdown#answer-formats
    // MARK: - Text Choice Answer Format
    
    // Known issue: When the cell to be selected is at the bottom of the screen (it is even barely visible, but visible for XCUITest). XCUITest incorrectly taps previous cell, resulting the wrong cell index being selected
    func selectTextChoiceCell(_ cell: XCUIElement) {
        if !cell.visible {
            cell.scrollUntilVisible()
        }
        cell.tap()
        wait(for: cell, toBeSelected: true, failureMessage: "Choice cell \(cell) with identifier \(cell.identifier)")
    }
    
    /// Count cells and compare with the expected count
    @discardableResult
    func assertNumOfTextChoiceCells(withId formItemId: String, expectedCount: Int) -> Self {
        let firstCell = getFormItemCell(withId: formItemId, atIndex: 0)
        wait(for: firstCell, toExists: true)
        let actualCount = getFormItemCells(withID: formItemId).count
        XCTAssertEqual(actualCount, expectedCount, "Number of cell choices is not equal to expected count \(expectedCount)")
        return self
    }
    
    @discardableResult
    func verifyCellLabel(withId formItemId: String, atIndex index: Int, expectedLabel: String) -> Self {
        let cellToSelect = getFormItemCell(withId: formItemId, atIndex: index)
        let cellLabel = cellToSelect.label
        XCTAssertEqual(cellLabel, expectedLabel, "Cell label at index \(index) is not equal to the expected label")
        return self
    }
    
    // MARK: - Single Choice Style Answer Format
    
    /**
     Selects cell by it's index.
     Handle ORKTextChoiceAnswerFormat with single choice style (an answer format that lets participants choose from a fixed set of text choices). The text choices are presented in a table view, using one row for each answer.
     - parameter formItemId: The string that identifies the form item, which should be unique within the form step
     - parameter index: index of cell that will be selected
     */
    @discardableResult
    func answerSingleChoiceTextQuestion(withId formItemId: String, atIndex index: Int) -> Self {
        let cellToSelect = getFormItemCell(withId: formItemId, atIndex: index)
        selectTextChoiceCell(cellToSelect)
        return self
    }
    
    /**
     Handles ORKBooleanAnswerFormat (an answer format that lets participants choose from yes/no choices). The text choices are presented in a table view, using one row for each answer.
     - parameter index: index of cell that will be selected (0 or 1)
     - parameter yesString: A string that describes the Yes answer. For custom boolean questions expected button labels need to be provided.
     - parameter noString: A string that describes the No answer. For custom boolean questions expected button labels need to be provided.
     */
    @discardableResult
    func answerBooleanQuestion(
        withId formItemId: String,
        atIndex index: Int,
        yesString: String = "Yes",
        noString: String = "No" /// TODO: rdar://117821622 (Add localization support for UI Tests)
    ) -> Self {
        guard index <= 1 else {
            XCTFail("Cell index should be in range between 0 and 1")
            return self
        }
        verifyCellLabel(withId: formItemId, atIndex: 0, expectedLabel: yesString)
        verifyCellLabel(withId: formItemId, atIndex: 1, expectedLabel: noString)
        answerSingleChoiceTextQuestion(withId: formItemId, atIndex: index)
        return self
    }

    /**
     Verifies that we only have 1 cell selected across several cells (we need specific range because other questions may also be selected)
     - parameter formItemId: The string that identifies the form item, which should be unique within the form step
     - parameter index: index that should be selected
     - parameter cellsRange: the range of cells that will be verified
     */
    @discardableResult
    func verifyOnlyOneCellSelected(
        withId formItemId: String,
        atIndex index: Int,
        cellsChoiceRange cellsRange: (
            start: Int,
            end: Int
        )
    ) -> Self {
        var currentCell: XCUIElement
        for i in cellsRange.start...cellsRange.end {
            currentCell = getFormItemCell(withId: formItemId, atIndex: i)
            if !currentCell.visible {
                currentCell.scrollUntilVisible()
            }
            if i == index {
                XCTAssert(currentCell.isSelected, "Cell at index \(i) should be selected, but was found unselected")
            } else {
                XCTAssert(!currentCell.isSelected, "Cell at index \(i) should not be selected, but was found selected")
            }
            XCTAssert(!currentCell.label.isEmpty, "Text choice cell should not be empty")
        }
        return self
    }
    
    @discardableResult
    func verifyOnlyOneCellSelected(withId formItemId: String, atIndex index: Int, cellShouldContainImage: Bool = false) -> Self {
        let firstCell = getFormItemCell(withId: formItemId, atIndex: 0)
        wait(for: firstCell, toExists: true)
        let actualCount = getFormItemCells(withID: formItemId).count
        var currentCell: XCUIElement
        for i in 0..<actualCount {
            currentCell = getFormItemCell(withId: formItemId, atIndex: i)
            if !currentCell.visible {
                currentCell.scrollUntilVisible()
            }
            if i == index {
                XCTAssert(currentCell.isSelected, "Cell at index \(i) should be selected, but was found unselected")
            } else {
                XCTAssert(!currentCell.isSelected, "Cell at index \(i) should not be selected, but was found selected")
            }
            if !cellShouldContainImage {
                XCTAssert(!currentCell.label.isEmpty, "Text choice cell should not be empty at index \(i)")
            } else {
                XCTAssert(currentCell.images.firstMatch.exists, "Image choice cell should not be empty at index \(i)")
            }
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
    func answerMultipleChoiceTextQuestion(withId formItemId: String, indices: [Int]) -> Self {
        var cellToSelect: XCUIElement
        for index in indices {
            cellToSelect = getFormItemCell(withId: formItemId, atIndex: index)
            selectTextChoiceCell(cellToSelect)
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
        withId formItemId: String,
        indices: [Int],
        cellsChoiceRange cellsRange: (
            start: Int,
            end: Int
        )
    ) -> Self {
        var currentCell: XCUIElement
        for i in cellsRange.start...cellsRange.end {
            currentCell = getFormItemCell(withId: formItemId, atIndex: i)
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
    @discardableResult
    func verifyNoCellsSelected(withId formItemId: String, _ numberOfTextChoices: Int) -> Self {
        for index in 0..<numberOfTextChoices {
            let currentCell = getFormItemCell(withId: formItemId, atIndex: index)
            if !currentCell.visible {
                currentCell.scrollUntilVisible()
            }
            XCTAssert(!currentCell.isSelected, "Cell at index \(index) should not be selected")
        }
        return self
    }
    
    // MARK: - Text Choice Other Answer Format
    
    @discardableResult
    func answerTextChoiceOtherQuestion(withId formItemId: String, atIndex index: Int, text: String, dismissKeyboard: Bool = true, clearIfNeeded: Bool = false) -> Self {
        let formItem = FormStepScreen().getFormItemCell(withId: formItemId, atIndex: index)
       // let textView = formItem.textViews.firstMatch
        let textView = formItem.textViews.element(boundBy: 0)
        wait(for: textView)
        textView.typeText(text, clearIfNeeded: clearIfNeeded, dismissKeyboard: dismissKeyboard)
        return self
    }
    
    @discardableResult
    func verifyTextBoxIsHidden(_ isHidden: Bool, withId formItemId: String, atIndex index: Int ) -> Self {
        let formItem = FormStepScreen().getFormItemCell(withId: formItemId, atIndex: index)
        let textView = formItem.textViews.firstMatch
        if !isHidden {
            wait(for: textView, failureMessage: "TextBox for form item with id: \(formItemId) should not be hidden")
        } else {
            wait(for: textView, toExists: false, failureMessage: "TextBox for form item with id: \(formItemId) should be hidden")
        }
        return self
    }
    
    @discardableResult
    func verifyTextBoxValue(withId formItemId: String, atIndex index: Int, expectedValue: String, isPlaceholderExpected: Bool = false) -> Self {
        let formItem = FormStepScreen().getFormItemCell(withId: formItemId, atIndex: index)
        let textView = formItem.textViews.firstMatch
        
        /// Verifies placeholder text instead of entered text
        if isPlaceholderExpected {
            textView.textViews.element.verifyElementValue(expectedValue: expectedValue)
            return self
        }
        textView.verifyElementValue(expectedValue: expectedValue)
        return self
    }
    
    // MARK: - Text Answer Format (Free Form Textview)
    
    static var clearButton: XCUIElement {
        Self.stepView.buttons[AccessibilityIdentifiers.FormStep.FormItem.clearTextViewButton].firstMatch
    }
    
    func tapClearButton() -> Self {
        wait(for: Self.clearButton)
        Self.clearButton.tap()
        return self
    }
    
    @discardableResult
    func answerTextQuestionTextView(withId formItemId: String, text inputText: String, dismissKeyboard: Bool = true) -> Self {
        let textView = FormStepScreen().getFormItemCell(withId: formItemId).textViews.firstMatch
        wait(for: textView)
        textView.typeText(inputText, clearIfNeeded: true, dismissKeyboard: dismissKeyboard)
        textView.verifyElementValue(expectedValue: inputText, failureMessage: "Textfield value is expected to be \(inputText)")
        return self
    }
    
    // Multiple verification test method
    func answerTextQuestionTextView(withId formItemId: String, text: String, dismissKeyboard: Bool = true, maximumLength: Int, expectedPlaceholderValue: String) -> Self {
        let textView = FormStepScreen().getFormItemCell(withId: formItemId).textViews.firstMatch
        wait(for: textView)
        // Verify character limiter indicator initial state
        var characterLimitIndicator = Self.stepView.staticTexts["0/\(maximumLength)"]
        wait(for: characterLimitIndicator)
        // Verify placeholder value
        textView.textViews.element.verifyElementValue(expectedValue: expectedPlaceholderValue)
        textView.typeText(text, dismissKeyboard: dismissKeyboard)
        // Verify character limiter indicator after providing text
        let answerCurrentLength = text.count
        characterLimitIndicator = Self.stepView.staticTexts["\(answerCurrentLength)/\(maximumLength)"]
        wait(for: characterLimitIndicator)
        return self
    }
    
    @discardableResult
    func verifyTextViewValue(withId formItemId: String, expectedText inputText: String) -> Self {
        let textView = getFormItemCell(withId: formItemId).textViews.firstMatch
        wait(for: textView)
        textView.verifyElementValue(expectedValue: inputText)
        return self
    }
    
    // MARK: - Numeric and Text Answer Format
    
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
    
    @discardableResult
    func answerNumericQuestion(number: Double, dismissKeyboard: Bool = false, clearIfNeeded: Bool = false) -> Self {
        Keyboards.enterNumber(number, dismissKeyboard: dismissKeyboard, clearIfNeeded: clearIfNeeded)
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
    
    @discardableResult
    func verifyErrorMessage(exists: Bool, withId formItemId: String, atIndex index: Int = 0, expectedMessage: String) -> Self {
        let formItemCell = getFormItemCell(withId: formItemId, atIndex: index)
        let errorMessageElement = formItemCell.staticTexts[expectedMessage].firstMatch // TODO: rdar://121345903 (Create AX Id for an error message when invalid values are entered)
        guard exists else {
            wait(for: errorMessageElement, toExists: false)
            return self
        }
        wait(for: errorMessageElement)
        XCTAssertEqual(errorMessageElement.label, expectedMessage)
        return self
    }
    
    // MARK: - Date and Time Answer Format
    
    // Usually, there is only one UI picker  presented on the screen
    static var firstPicker = app.pickers.element(boundBy: 0).firstMatch
    let uiPickerTimeout: TimeInterval = 60
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
        wait(for: picker, withTimeout: uiPickerTimeout)
        let hourWheel = picker.pickerWheels.element(boundBy: 0)
        wait(for: hourWheel, withTimeout: uiPickerTimeout)
        let minuteWheel = picker.pickerWheels.element(boundBy: 1)
        
        hourWheel.adjust(toPickerWheelValue: String(hours))
        minuteWheel.adjust(toPickerWheelValue: String(minutes))
        if dismissPicker {
            Keyboards.tapDoneButtonOnToolbar()
        }
    }
    
    /**
     Method for US Time Zone
     - parameter hours: hours to be entered
     - parameter minutes: minutes to be entered
     - parameter isAM: indicating the time of day to be entered (before noon, after noon)
     */
    func adjustPickerWheels(hours: String, minutes: String, isAM: Bool = false, dismissPicker: Bool = false) {
        let picker = Self.firstPicker
        wait(for: picker)
        let hourWheel = picker.pickerWheels.element(boundBy: 0)
        let minuteWheel = picker.pickerWheels.element(boundBy: 1)
        let amPmWheel = picker.pickerWheels.element(boundBy: 2)
        hourWheel.adjust(toPickerWheelValue: hours)
        minuteWheel.adjust(toPickerWheelValue: minutes)
        if isAM {
            amPmWheel.adjust(toPickerWheelValue: "AM")
        } else {amPmWheel.adjust(toPickerWheelValue: "PM")}
        if dismissPicker { Keyboards.tapDoneButtonOnToolbar() }
    }
    
    /**
     Adjusts picker wheels to provided date
     Handles ORKDateAnswerFormat dateAnswerFormat
     - parameter year: year to be entered
     - parameter month: month to be entered
     - parameter dismissPicker: whether the ui picker should be dismissed after selection
     */
    @discardableResult
    func answerDateQuestion(year: String, month: String, day: String, dismissPicker: Bool = false) -> Self {
        let picker = Self.firstPicker
        wait(for: picker, withTimeout: uiPickerTimeout)
        let yearPickerWheel = picker.pickerWheels.element(boundBy: 2)
        wait(for: yearPickerWheel, withTimeout: uiPickerTimeout)
        picker.pickerWheels.element(boundBy: 2).adjust(toPickerWheelValue: year)
        picker.pickerWheels.element(boundBy: 1).adjust(toPickerWheelValue: day)
        picker.pickerWheels.element(boundBy: 0).adjust(toPickerWheelValue: month)
        if dismissPicker {
            Keyboards.tapDoneButtonOnToolbar()
        }
        return self
    }
    
    /**
     Adjusts picker wheels based on offsets from the current date
     Handles ORKDateAnswerFormat dateAnswerFormat
     - parameter offsetDays: the number of days to add to the current date . A positive value moves forward in time, a negative value moves backward
     - parameter offsetYears: the number of years to add to the current date. A positive value moves forward in time, a negative value moves backward
     - parameter dismissPicker: whether the ui picker should be dismissed after selection
     */
    func answerDateQuestion(offsetDays: Int, offsetYears: Int, dismissPicker: Bool = false) -> Self {
        let (month, day, year) = getPickerValues(offsetDays: offsetDays, offsetYears: offsetYears)
        let picker = Self.firstPicker
        wait(for: picker, withTimeout: uiPickerTimeout)
        picker.pickerWheels.element(boundBy: 0).adjust(toPickerWheelValue: month)
        picker.pickerWheels.element(boundBy: 1).adjust(toPickerWheelValue: day)
        picker.pickerWheels.element(boundBy: 2).adjust(toPickerWheelValue: year)
        if dismissPicker {
            Keyboards.tapDoneButtonOnToolbar()
        }
        return self
    }
    
    /**
     Adjusts picker wheels to provided date
     Handles ORKTimeOfDayAnswerFormat timeOfDayAnswerFormat
     - parameter hours: hours to be entered
     - parameter minutes: minutes to be entered
     - parameter isUSTimeZone: whether AM/PM picker wheels need to be adjusted
     - parameter isAM: indicating the time of day to be entered (before noon, after noon)
     */
    @discardableResult
    func answerTimeOfDayQuestion(hours: Int, minutes: Int, isUSTimeZone: Bool, isAM: Bool = false, dismissPicker: Bool = false) -> Self {
        var formattedHours: String
        // Keep leading zeroes for minutes
        let formattedMinutes = String(format: "%02d", minutes)
        
        if isUSTimeZone {
            formattedHours = String(hours)
            guard isAM else {
                adjustPickerWheels(hours: formattedHours, minutes: formattedMinutes, isAM: false, dismissPicker: dismissPicker)
                return self
            }
            adjustPickerWheels(hours: formattedHours, minutes: formattedMinutes, isAM: true, dismissPicker: dismissPicker)
        } else {
            // Keep leading zeroes for continental Time Zone
            formattedHours = String(format: "%02d", hours)
            adjustPickerWheels(hours: formattedHours, minutes: formattedMinutes, dismissPicker: dismissPicker)
        }
        return self
    }
    
    /// Handles ORKDateAnswerFormat dateTimeAnswerFormat
    /// Adjusts the picker wheels to provided date
    @discardableResult
    func answerDateAndTimeQuestion(year: String, month: String, day: String, hour: String, isUSTimeZOne: Bool = true, dismissPicker: Bool = false) -> Self {
        let picker = Self.firstPicker
        wait(for: picker, withTimeout: uiPickerTimeout)
        var formattedHours: String
        if isUSTimeZOne {
            // Do not add leading zeros for US Time Zone
            formattedHours = String(hour)
            // Add leading zeroes for continental Time Zone
        } else { formattedHours = String(format: "%02d", hour) }
        picker.pickerWheels.element(boundBy: 3).adjust(toPickerWheelValue: formattedHours)
        picker.pickerWheels.element(boundBy: 2).adjust(toPickerWheelValue: year)
        picker.pickerWheels.element(boundBy: 1).adjust(toPickerWheelValue: day)
        picker.pickerWheels.element(boundBy: 0).adjust(toPickerWheelValue: month)
        if dismissPicker {
            Keyboards.tapDoneButtonOnToolbar()
        }
        return self
    }
    
    /**
     Adjusts picker wheels based on offsets from the current date
     Handles ORKDateAnswerFormat dateTimeAnswerFormat
     - parameter offsetDays: the number of days to add to the current date . A positive value moves forward in time, a negative value moves backward
     - parameter offsetHours: the number of hours to add to the current date. A positive value moves forward in time, a negative value moves backward
     - parameter dismissPicker: whether the ui picker should be dismissed after selection
     */
    @discardableResult
    func answerDateAndTimeQuestion(offsetDays: Int, offsetHours: Int, isUSTimeZone: Bool, dismissPicker: Bool = false) -> Self {
        let picker = Self.firstPicker
        wait(for: picker, withTimeout: uiPickerTimeout)
        let (day, hour, minute, amPm) = getPickerValues(offsetDays: offsetDays, offsetHours: offsetHours)
        var formattedHours = hour
        if !isUSTimeZone {
            // Add leading zeroes for continental Time Zone
            formattedHours = String(format: "%02d", Int(hour) ?? 0)
        }
        picker.pickerWheels.element(boundBy: 0).adjust(toPickerWheelValue: day)
        picker.pickerWheels.element(boundBy: 1).adjust(toPickerWheelValue: formattedHours)
        picker.pickerWheels.element(boundBy: 2).adjust(toPickerWheelValue: minute)
        if  isUSTimeZone {
            picker.pickerWheels.element(boundBy: 3).adjust(toPickerWheelValue: amPm)
        }
        if dismissPicker {
            Keyboards.tapDoneButtonOnToolbar()
        }
        return self
    }
    
    func verifyDatePickerWheelValues(expectedYear: String, expectedMonth: String, expectedDay: String) -> Self {
        let picker = Self.firstPicker
        wait(for: picker, withTimeout: uiPickerTimeout)
        let actualYear = picker.pickerWheels.element(boundBy: 2).value as? String ?? ""
        let actualDay = picker.pickerWheels.element(boundBy: 1).value as? String ?? ""
        let actualMonth = picker.pickerWheels.element(boundBy: 0).value as? String ?? ""
        
        XCTAssertEqual(actualYear, expectedYear, "The year picker wheel is not showing correct value. Expected \(expectedYear) but got \(actualYear)")
        XCTAssertEqual(actualDay, expectedDay, "The day picker wheel is not showing correct value. Expected \(expectedDay) but got \(actualDay)")
        XCTAssertEqual(actualMonth, expectedMonth, "The month picker wheel is not showing correct value. Expected \(expectedMonth) but got \(actualMonth)")
        return self
    }
    
    func verifyDatePickerRestrictedTo3days(offsetDays: Int, offsetYears: Int, dismissPicker: Bool = false) -> Self {
        let (month, day, year) = getPickerValues(offsetDays: offsetDays, offsetYears: offsetYears)
        let picker = Self.firstPicker
        wait(for: picker, withTimeout: uiPickerTimeout)
        picker.pickerWheels.element(boundBy: 0).adjust(toPickerWheelValue: month)
        picker.pickerWheels.element(boundBy: 1).adjust(toPickerWheelValue: day)
        picker.pickerWheels.element(boundBy: 2).adjust(toPickerWheelValue: year)
        
        let dayDisplayed = picker.pickerWheels.element(boundBy: 1).value as? String ?? ""
        XCTAssertNotEqual(day, dayDisplayed, "The date picker should be restricted to 3 days")
        if dismissPicker {
            Keyboards.tapDoneButtonOnToolbar()
        }
        return self
    }
    
    /// Verifies that the UI date picker defaults to the current date
    @discardableResult
    func verifyDatePickerDefaultsToCurrentDate() -> Self {
        let currentDate = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d yyyy"
        let currentDateComponents = formatter.string(from: currentDate).components(separatedBy: " ")
        let expectedMonth = currentDateComponents[0]
        let expectedDay = currentDateComponents[1]
        let expectedYear = currentDateComponents[2]
        
        let picker = Self.firstPicker
        wait(for: picker, withTimeout: uiPickerTimeout)
        let yearPickerWheel = picker.pickerWheels.element(boundBy: 2)
        wait(for: yearPickerWheel, withTimeout: uiPickerTimeout)
        let actualYear = picker.pickerWheels.element(boundBy: 2).value as? String ?? ""
        let actualDay = picker.pickerWheels.element(boundBy: 1).value as? String ?? ""
        let actualMonth = picker.pickerWheels.element(boundBy: 0).value as? String ?? ""
        XCTAssertEqual(actualYear, expectedYear, "The year picker wheel is not showing correct value. Expected \(expectedYear) but got \(actualYear)")
        XCTAssertEqual(actualDay, expectedDay, "The day picker wheel is not showing correct value. Expected \(expectedDay) but got \(actualDay)")
        XCTAssertEqual(actualMonth, expectedMonth, "The month picker wheel is not showing correct value. Expected \(expectedMonth) but got \(actualMonth)")
        return self
    }
    
    /**
     Gets picker wheels values based on offsets from the current date
     - parameter offsetDays: the number of days to add to the current date . A positive value moves forward in time, a negative value moves backward
     - parameter offsetHours: the number of hours to add to the current date. A positive value moves forward in time, a negative value moves backward
     */
    func getPickerValues(offsetDays: Int, offsetHours: Int) -> (day: String, hour: String, minute: String, amPm: String) {
        let calendar = Calendar.current
        let now = Date()
        let adjustedDate = calendar.date(byAdding: .day, value: offsetDays, to: now)!
        let adjustedDateTime = calendar.date(byAdding: .hour, value: offsetHours, to: adjustedDate)!
        let dateFormatter = DateFormatter()

        dateFormatter.dateFormat = "MMM d"
        let day = dateFormatter.string(from: adjustedDateTime)
        
        let hourFormatter = DateFormatter()
        hourFormatter.dateFormat = "h"
        let hour = hourFormatter.string(from: adjustedDateTime)
        
        let minuteFormatter = DateFormatter()
        minuteFormatter.dateFormat = "mm"
        let minute = minuteFormatter.string(from: adjustedDateTime)
        
        let amPmFormatter = DateFormatter()
        amPmFormatter.dateFormat = "a"
        let amPm = amPmFormatter.string(from: adjustedDateTime)
        
        return (day, hour, minute, amPm)
    }
    
    /**
     Gets picker wheels values based on offsets from the current date
     - parameter offsetDays: the number of days to add to the current date . A positive value moves forward in time, a negative value moves backward
     - parameter offsetYears: the number of years to add to the current date. A positive value moves forward in time, a negative value moves backward
     */
    func getPickerValues(offsetDays: Int, offsetYears: Int) -> (month: String, day: String, year: String) {
        let calendar = Calendar.current
        let now = Date()
        let adjustedDate = calendar.date(byAdding: .day, value: offsetDays, to: now)!
        let adjustedDateTime = calendar.date(byAdding: .year, value: offsetYears, to: adjustedDate)!
        
        let monthFormatter = DateFormatter()
        monthFormatter.dateFormat = "MMMM"
        let month = monthFormatter.string(from: adjustedDateTime)
        
        let dayFormatter = DateFormatter()
        dayFormatter.dateFormat = "d"
        let day = dayFormatter.string(from: adjustedDateTime)
        
        let yearFormatter = DateFormatter()
        yearFormatter.dateFormat = "yyyy"
        let year = yearFormatter.string(from: adjustedDateTime)
        
        return (month, day, year)
    }
    
    // MARK: - Picker Value Choice Format
    
    /// Handles ORKAnswerFormat.valuePickerAnswerFormat
    @discardableResult
    func answerPickerValueChoiceQuestion(value: String, verifyResultValue: Bool = false, dismissPicker: Bool = false) -> Self {
        let picker = Self.firstPicker
        wait(for: picker, withTimeout: 70)
        let pickerWheel = picker.pickerWheels.element(boundBy: 0).firstMatch // There is only one picker wheel
        wait(for: pickerWheel, withTimeout: uiPickerTimeout)
        pickerWheel.adjust(toPickerWheelValue: value)
        if verifyResultValue {
            pickerWheel.verifyElementValue(expectedValue: value, failureMessage: "The choice picker is displaying incorrect value")
        }
        if dismissPicker {
            Keyboards.tapDoneButtonOnToolbar()
        }
        return self
    }
    
    // MARK: -  SES Answer Format
    
    /// Handles SES ladder question ORKSESAnswerFormat
    /// - parameter formItemId: The string that identifies the form item, which should be unique within the form step
    @discardableResult
    func answerSESladder(withID formItemId: String, buttonIndexToSelect: Int) -> Self {
        guard buttonIndexToSelect <= 9 else {
            XCTFail("Button index should be in range between 0 and 9")
            return self
        }
        let cell = getFormItemCell(withId: formItemId, atIndex: 0)
        let radioButton = cell.buttons.element(boundBy: buttonIndexToSelect)
        wait(for: radioButton)
        wait(for: radioButton, toBeSelected: false)
        radioButton.tap()
        wait(for: radioButton, toBeSelected: true)
        return self
    }
    
    // MARK: - Height/Weight Answer Format
    
    /// Handles heightAnswerFormat: ORKMeasurementSystem.USC
    @discardableResult
    func answerHeighQuestion(feet: Int, inches: Int, dismissPicker: Bool) -> Self {
        let picker = Self.firstPicker
        wait(for: picker, withTimeout: uiPickerTimeout)
        let footPickerValue = "\(feet) ft"
        let inchPickerValue = "\(inches) in"
        let footWheel = picker.pickerWheels.element(boundBy: 0)
        wait(for: footWheel, withTimeout: uiPickerTimeout)
        let inchWheel = picker.pickerWheels.element(boundBy: 1)
        footWheel.adjust(toPickerWheelValue: footPickerValue)
        inchWheel.adjust(toPickerWheelValue: inchPickerValue)
       
        if dismissPicker {
            Keyboards.tapDoneButtonOnToolbar()
        }
        return self
    }
    
    /// Handles heightAnswerFormat: ORKMeasurementSystem.metric
    @discardableResult
    func answerHeighQuestion(cm: Int, dismissPicker: Bool) -> Self {
        let picker = Self.firstPicker
        wait(for: picker, withTimeout: uiPickerTimeout)
        let cmPickerValue = "\(cm) cm"
        let cmWheel = picker.pickerWheels.element.firstMatch /// There is only one picker wheel(cm)
        wait(for: cmWheel, withTimeout: uiPickerTimeout)
        cmWheel.adjust(toPickerWheelValue: cmPickerValue)
        
        if dismissPicker {
            Keyboards.tapDoneButtonOnToolbar()
        }
        
        return self
    }
    
    /// Handles weightAnswerFormat ORKMeasurementSystem.USC
    /// Default Precision
    @discardableResult
    func answerWeighQuestion(lb: Int, dismissPicker: Bool) -> Self {
        let picker = Self.firstPicker
        wait(for: picker, withTimeout: uiPickerTimeout)
        let lbPickerValue = "\(lb) lb"
        let lbWheel = picker.pickerWheels.element.firstMatch /// There is only one picker wheel(lb)
        wait(for: lbWheel, withTimeout: uiPickerTimeout)
        lbWheel.adjust(toPickerWheelValue: lbPickerValue)
        
        if dismissPicker {
            Keyboards.tapDoneButtonOnToolbar()
        }
        
        return self
    }
    
    /// Handles weightAnswerFormat ORKMeasurementSystem.USC
    /// High Precision
    @discardableResult
    func answerWeighQuestion(lb: Int, oz: Int, dismissPicker: Bool) -> Self {
        let picker = Self.firstPicker
        wait(for: picker, withTimeout: uiPickerTimeout)
        let lbPickerValue = "\(lb) lb"
        let ozPickerValue = "\(oz) oz"
        let lbWheel = picker.pickerWheels.element(boundBy: 0)
        wait(for: lbWheel, withTimeout: uiPickerTimeout)
        lbWheel.adjust(toPickerWheelValue: lbPickerValue)
        let ozWheel = picker.pickerWheels.element(boundBy: 1)
        ozWheel.adjust(toPickerWheelValue: ozPickerValue)
        
        if dismissPicker {
            Keyboards.tapDoneButtonOnToolbar()
        }
        
        return self
    }
    
    /// Handles weightAnswerFormat ORKMeasurementSystem.metric
    /// Low precision
    @discardableResult
    func answerWeighQuestion(kg: Int, dismissPicker: Bool) -> Self {
        let picker = Self.firstPicker
        wait(for: picker, withTimeout: uiPickerTimeout)
        let kgPickerValue = "\(kg) kg"
        let kgWheel = picker.pickerWheels.element.firstMatch /// There is only one picker wheel(kg)
        wait(for: kgWheel, withTimeout: uiPickerTimeout)
        kgWheel.adjust(toPickerWheelValue: kgPickerValue)
        
        if dismissPicker {
            Keyboards.tapDoneButtonOnToolbar()
        }
        
        return self
    }
    
    /// Handles weightAnswerFormat ORKMeasurementSystem.metric
    /// Default and high precision
    @discardableResult
    func answerWeighQuestion(kg: Double, highPrecision: Bool = false, dismissPicker: Bool) -> Self {
        let picker = Self.firstPicker
        wait(for: picker, withTimeout: uiPickerTimeout)
        var kgPickerValue: String
        let kgString = String(describing: kg)
        let components = kgString.components(separatedBy: ".")
        let fractionalPart = components[1]
        if highPrecision {
            guard fractionalPart.count == 2 else {
                XCTFail("Please provide the value with the high precision")
                return self
            }
            let integerPart = components[0]
            let kgWheel = picker.pickerWheels.element(boundBy: 0)
            wait(for: kgWheel, withTimeout: uiPickerTimeout)
            kgWheel.adjust(toPickerWheelValue: integerPart)
            let gWheel = picker.pickerWheels.element(boundBy: 1)
            gWheel.adjust(toPickerWheelValue: ".\(fractionalPart)")
        } else {
            guard fractionalPart.count == 1 else {
                XCTFail("Please provide the value with the default precision")
                return self
            }
            kgPickerValue = "\(kg) kg"
            let kgWheel = picker.pickerWheels.element.firstMatch /// There is only one picker wheel(kg)
            wait(for: kgWheel, withTimeout: uiPickerTimeout)
            kgWheel.adjust(toPickerWheelValue: kgPickerValue)
        }
        
        if dismissPicker {
            Keyboards.tapDoneButtonOnToolbar()
        }
        
        return self
    }
    // MARK: - Choice Answer Format With Image Choices
    
    @discardableResult
    func answerImageChoiceQuestion(withId formItemId: String, imageIndex: Int, expectedLabel: String? = nil) -> Self {
        if imageIndex > 1 {
            XCTFail("Selected index out of range of actual choices")
        }
        let imageButton = FormStepScreen().getFormItemCell(withId: formItemId).buttons.element(boundBy: imageIndex)
        wait(for: imageButton)
        imageButton.tap()
        wait(for: imageButton, toBeSelected: true)
        // Verify Selected Image Choice Label
        guard let label = expectedLabel  else {
            return self
        }
        XCTAssertEqual(imageButton.label,  label, "Expected Image label: \(label) at index \(imageIndex), but found: \(imageButton.label)")
        return self
    }
    
    @discardableResult
    func verifyImageChoiceQuestion(withId formItemId: String, imageIndex: Int, expectedLabel: String) -> Self {
        let imageButton = getFormItemCell(withId: formItemId).buttons.element(boundBy: imageIndex)
        wait(for: imageButton, toBeSelected: true)
        XCTAssertEqual(imageButton.label,  expectedLabel, "Expected Image label: \(expectedLabel) at index \(imageIndex), but found: \(imageButton.label)")
        return self
    }
    
    enum ImageButtonLabel: String {
        case squareShape = "Square Shape"
        case roundShape = "Round Shape"
    }
    
    // MARK: - Scale Answer Format
    
    // As per apple documentation: The adjustment is a “best effort” to move the indicator to the desired position; absolute fidelity is not guaranteed. https://developer.apple.com/documentation/xctest/xcuielement/1501022-adjust
    
    static var firstSlider = app.sliders.firstMatch
    
    /// Adjusts the first slider found to normalized position
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
    func adjustQuestionSlider(withId formItemId: String, atIndex index: Int = 0, withNormalizedPosition: CGFloat) -> Self {
        let cell = getFormItemCell(withId: formItemId, atIndex: index)
        if !cell.visible {
            cell.scrollUntilVisible()
        }
        let slider = cell.sliders.firstMatch
        slider.adjust(toNormalizedSliderPosition: withNormalizedPosition)
        
        return self
    }
    
    /// Normalizes slider value to the range [0, 1]
    /// Adding half of step because slider is not precise
    func normalizeSliderValue(sliderValue: Double, stepValue: Double, minValue: Double, maxValue: Double) -> CGFloat {
        var normalizedValue: Double
        if sliderValue != maxValue {
            normalizedValue = ((sliderValue + stepValue/2) - minValue)/(maxValue - minValue)
        }
        else {
            normalizedValue = 1.0
        }
        return normalizedValue
    }
    
    @discardableResult
    func verifySliderValue(withId formItemId: String, atIndex index: Int = 0, expectedValue: String) -> Self {
        let slider = getFormItemCell(withId: formItemId, atIndex: index).sliders.firstMatch
        wait(for: slider)
        slider.verifyElementValue(expectedValue: expectedValue)
        return self
    }
    
    /**
     Adjusts slider and verifies slider result value. Handles  ORKAnswerFormat scale
     - parameter formItemId: The string that identifies the form item, which should be unique within the form step
     - parameter index: form item cell index. Usually form item cell index is 0 unless it's from item within a section
     - parameter sliderValue: value that move slider to
     - parameter stepValue: slider step
     */
    @discardableResult
    func answerScaleQuestion(withId formItemId: String, atIndex index: Int = 0, sliderValue: Double, stepValue: Double, minValue: Double, maxValue: Double) -> Self {
        
        let cell = getFormItemCell(withId: formItemId, atIndex: index)
        let slider = cell.sliders.firstMatch
        wait(for: slider)
        let normalizedValue = normalizeSliderValue(sliderValue: sliderValue, stepValue: stepValue, minValue: minValue, maxValue :maxValue)
        UITestLogger.logDebugMessage("Normalized value: \(normalizedValue)")
        
        slider.adjust(toNormalizedSliderPosition: normalizedValue)
        let actualSliderValue = slider.value as? String ?? ""
        let actualSliderValueDouble = Double(actualSliderValue) ?? 0
        
        XCTAssertEqual(actualSliderValueDouble, sliderValue)
        return self
    }
    
    @discardableResult
    func answerTextScaleQuestion(withId formItemId: String, atIndex index: Int = 0, sliderValue: Double, expectedSliderValue: String, stepValue: Double, minValue: Double, maxValue: Double) -> Self {
        
        let cell = getFormItemCell(withId: formItemId, atIndex: index)
        let slider = cell.sliders.firstMatch
        wait(for: slider)
        let normalizedValue = normalizeSliderValue(sliderValue: sliderValue, stepValue: stepValue, minValue: minValue, maxValue :maxValue)
        UITestLogger.logDebugMessage("Normalized value: \(normalizedValue)")
        
        slider.adjust(toNormalizedSliderPosition: normalizedValue)
        let actualSliderValue = slider.value as? String ?? ""
        
        XCTAssertEqual(actualSliderValue, expectedSliderValue)
        return self
    }
    
    /// ORKAnswerFormat continuousScale numberStyle = .percent
    @discardableResult
    func answerScaleQuestionPercentStyle(withId formItemId: String, atIndex index: Int = 0, sliderValue: Int, stepValue: Double, minValue: Double, maxValue: Double) -> Self {
        let formItemCell = getFormItemCell(withId: formItemId, atIndex: index)
        let slider = formItemCell .sliders.firstMatch
        wait(for: slider)
        let normalizedValue = (Double(sliderValue) - minValue)/(maxValue - minValue)
        slider.adjust(toNormalizedSliderPosition: normalizedValue)
        var actualSliderValue = slider.value as? String ?? ""
        let sliderValueString = String(sliderValue)
        let sliderValuePercent = "\(sliderValueString)%"
        var retry = 0
        while actualSliderValue != sliderValuePercent && retry < 5 {
            if retry > 0 { sleep(1) }
            slider.adjust(toNormalizedSliderPosition: normalizedValue)
            actualSliderValue = slider.value as? String ?? ""
            retry += 1
        }
        XCTAssertEqual(actualSliderValue, sliderValuePercent)
        return self
    }
    
    /// Vertical sliders don't work with XCUITest slider method (adjust(toNormalizedSliderPosition), so we have to use workaround with coords
    @discardableResult
    func answerVerticalScaleQuestion(withId formItemId: String, atIndex index: Int = 0, expectedSliderValue: Double, dx: Double, dy: Double) -> Self {
        let cell = getFormItemCell(withId: formItemId, atIndex: index)
        let slider = cell.sliders.firstMatch
        wait(for: slider)
        let sliderCoordinate = slider.coordinate(withNormalizedOffset: CGVector(dx: dx, dy: dy))
        var actualSliderValue = slider.value as? String ?? ""
        var actualSliderValueDouble = Double(actualSliderValue) ?? 0
        
        // As per apple documentation: The adjustment is a “best effort” to move the indicator to the desired position; absolute fidelity is not guaranteed. https://developer.apple.com/documentation/xctest/xcuielement/1501022-adjust
        // So we need to call slider adjustment method several times in order to set slider to desired position:
        var retry = 0
        while  actualSliderValueDouble != expectedSliderValue && retry < 5 {
            if retry > 0 { sleep(1) }
            sliderCoordinate.press(forDuration: 0.1)
            actualSliderValue = slider.value as? String ?? ""
            actualSliderValueDouble = Double(actualSliderValue) ?? 0
            retry += 1
        }
        
        XCTAssertEqual(actualSliderValueDouble, expectedSliderValue)
        return self
    }
    
    /// Adjusts slider to the end. Expected value of slider is Double
    /// Start and end positions won't work properly so we need separate workaround for those
    func adjustVerticalSliderToEndPosition(withId formItemId: String, atIndex index: Int = 0, expectedValue: Double) -> Self {
        let cell = getFormItemCell(withId: formItemId, atIndex: index)
        let slider = cell.sliders.firstMatch
        wait(for: slider)
        
        let sliderCenter = slider.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
        let sliderEnd = slider.coordinate(withNormalizedOffset: CGVector(dx: -0.1, dy: 0.0))
        // When we need to adjust slider to the end of the slider we set the target coordinate a little bit further to make sure that dragging will hit the end of the slider
        var actualSliderValue = slider.value as? String ?? ""
        var actualSliderValueDouble = Double(actualSliderValue) ?? 0
        
        var retry = 0
        while  actualSliderValueDouble != expectedValue && retry < 5 {
            if retry > 0 { sleep(1) }
            sliderCenter.press(forDuration: 0.1, thenDragTo: sliderEnd, withVelocity: .slow, thenHoldForDuration: 0.1)
            actualSliderValue = slider.value as? String ?? ""
            actualSliderValueDouble = Double(actualSliderValue) ?? 0
            retry += 1
        }
        
        XCTAssertEqual(actualSliderValueDouble, expectedValue)
        
        return self
    }
    
    /// Adjusts slider to the end. Expected value of slider is String
    func adjustVerticalSliderToEndPosition(withId formItemId: String, atIndex index: Int = 0, expectedValue: String) -> Self {
        let cell = getFormItemCell(withId: formItemId, atIndex: index)
        let slider = cell.sliders.firstMatch
        wait(for: slider)
        
        let sliderCenter = slider.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
        let sliderEnd = slider.coordinate(withNormalizedOffset: CGVector(dx: -0.1, dy: 0.0))
        // When we need to adjust slider to the end of the slider we set the target coordinate a little bit further to make sure that dragging will hit the end of the slider
        var actualSliderValue = slider.value as? String ?? ""
        
        var retry = 0
        while  actualSliderValue != expectedValue && retry < 5 {
            if retry > 0 { sleep(1) }
            sliderCenter.press(forDuration: 0.1, thenDragTo: sliderEnd, withVelocity: .slow, thenHoldForDuration: 0.1)
            actualSliderValue = slider.value as? String ?? ""
            retry += 1
        }
        
        XCTAssertEqual(actualSliderValue, expectedValue)
        return self
    }
    
    /// Adjusts vertical slider without verifying resulting value
    func adjustVerticalSlider(withId formItemId: String, atIndex index: Int = 0, dx: Double, dy: Double) -> Self {
        let cell = getFormItemCell(withId: formItemId, atIndex: index)
        let slider = cell.sliders.firstMatch
        wait(for: slider)
        
        let sliderCoordinate = slider.coordinate(withNormalizedOffset: CGVector(dx: dx, dy: dy))
        sliderCoordinate.press(forDuration: 0.1)
        return self
    }
    
    // MARK: -  Spacing Verification
    
    @discardableResult
    func verifyPaddingBetweenContinueButtonAndCell(withId formItemId: String = "", maximumAllowedDistance: Double) -> Self {
        let continueButton = Step.StepComponent.continueButton.element
        let lastCell = getLastCell(withId: formItemId)
        let currentDistance = abs(continueButton.frame.origin.y - lastCell.frame.maxY)
        XCTAssert(currentDistance <= maximumAllowedDistance, "Unexpected large space between continue button and table last cell: \(currentDistance)")
        return self
    }
    
    func getLastCell(withId formItemId: String = "") -> XCUIElement {
        let cellCount = FormStepScreen.stepView.cells.beginning(with: formItemId).count
        let lastCell = cellCount - 1
        let cell = FormStepScreen().getFormItemCell(withId: formItemId, atIndex: lastCell)
        return cell
    }
    
    // MARK: -  Learn More Button
    
    /**
     Observed behavior: twice more "Learn more" buttons in hierarchy than expected. In this case "index" variable should have different value in order to tap expected button. That's why we provide buttons count and adjust index as needed
     - parameter index: 0-based button index
     - parameter buttonsCount: number of "Learn more" buttons in hierarchy
     */
    func tapLearnMoreButton(withIndex index: Int, buttonsCount: Int) -> LearnMoreStepScreen {
        let adjustedIndex = buttonsCount + index
        let learnMoreIconButton = Self.stepView.buttons.matching(identifier: "More Info").element(boundBy: adjustedIndex)
        wait(for: learnMoreIconButton)
        learnMoreIconButton.tap()
        return LearnMoreStepScreen()
    }
    
    // MARK: -  Don't Know Button
    
    func tapDontKnowButton(withId formItemId: String) -> Self {
        let dontKnowButton = getFormItemCell(withId: formItemId).buttons.element(boundBy: 0)
        wait(for: dontKnowButton)
        // XCTAssert(!dontKnowButton.isSelected)
        // TODO: rdar://124189155 ([Blocked] Verify Don't Know Button State (Selected/Unselected)). Currently blocked by: rdar://121157828 ([Accessibility] [ORKCatalog] "I Don't Know" button choice is inaccessible with VoiceOver)
        dontKnowButton.tap()
        // wait(for: dontKnowButton, toBeSelected: true)
        return self
    }
    
    // MARK: - Location Answer Format
    
    func verifyCellTextFieldValue(withId formItemId: String, expectedValue: String) -> Self {
        let textfield = getFormItemCell(withId: formItemId).textFields.firstMatch
        wait(for: textfield)
        textfield.verifyElementValue(expectedValue: expectedValue, failureMessage: "Textfield value is expected to be \(expectedValue)")
        return self
    }
    
    @discardableResult
    func clearTextFieldWithXButton(withId formItemId: String, atIndex index: Int = 0) -> Self {
        let textfield = getFormItemCell(withId: formItemId, atIndex: index).textFields.firstMatch
        wait(for: textfield)
        let xButton = textfield.buttons.firstMatch // There is only one button in textfield
        xButton.tap()
        return self
    }
    
    @discardableResult
    func enterTextInTextField(withId formItemId: String, text inputText: String, dismissKeyboard: Bool = true) -> Self {
        let textView = getFormItemCell(withId: formItemId).textFields.firstMatch
        wait(for: textView)
        textView.typeText(inputText, clearIfNeeded: true, dismissKeyboard: dismissKeyboard)
        textView.verifyElementValue(expectedValue: inputText, failureMessage: "Textfield value is expected to be \(inputText)")
        return self
    }
    
    func verifyMapExists(withId formItemId: String) -> Self {
        let mapCell = getFormItemCell(withId: formItemId).maps.firstMatch
        wait(for: mapCell)
        return self
    }
    
    @discardableResult
    func verifyLocationPinIconExists(withId formItemId: String) -> Self {
        let locationImageId = "balloon_shadow"
        let locationPin = getFormItemCell(withId: formItemId).images[locationImageId]
        wait(for: locationPin)
        return self
    }
}
