//  XCUIElement.swift
//  ORKCatalogUITests
//
//  Created by Albina Kashapova on 10/25/23.
//  Copyright © 2023 researchkit.org. All rights reserved.
//

import Foundation
import XCTest

enum SwipeDirection {
    case up, down
}

extension XCUIElement {
    
    func verifyElementValue(expectedValue: String, failureMessage: String = "") {
        guard let currentValue = self.value as? String else {
            XCTFail("The current value for \(self) was found to be nil")
            return
        }
        XCTAssertEqual(currentValue, expectedValue, failureMessage)
    }
    
    func verifyElementValueContains(expectedValue: String, failureMessage: String = "") {
        guard let currentValue = self.value as? String else {
            XCTFail("The current value for \(self) was found to be nil")
            return
        }
        XCTAssert(currentValue.contains(expectedValue), failureMessage)
    }
    
    var visible: Bool {
        guard exists && !frame.isEmpty else { return false }
        return XCUIApplication().windows.element(boundBy: 0).frame.contains(frame)
    }
    
    /**
     A default swipeUp()/swipeDown() methods have a large offset so sometimes the element gets scrolled away because of the excessive scroll. In order to control the scroll you can use the following method.
     Scrolls to a particular element until it is visible in screen rect. Scroll starts from the point, which is located in the center of the screen (start coord).
     The yOffset represents the position after scroll (end coord). The distance between the start coord and end coord represents the scroll distance.
     - parameter yOffset:vertical offset in screen points. The value determines how much the simulated scroll will move. Default value 262 provides an optimal speed.
     */
    func scrollUntilVisible(direction: SwipeDirection = .up, maxSwipes: Int = 10, yOffset: Double = 262) {
        var swipes = 0
        var yOffsetSigned: Double
        while !self.visible && swipes < maxSwipes {
            let startCoord = XCUIApplication().windows.element.firstMatch.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
            switch direction {
                //dy: y position in the end of the scroll
            case .up:
                yOffsetSigned = -yOffset
                let endCoord = startCoord.withOffset(CGVector(dx: 0.0, dy: yOffsetSigned))
                startCoord.press(forDuration: 0.01, thenDragTo: endCoord)
                sleep(2)
            case .down:
                yOffsetSigned = yOffset
                let endCoord = startCoord.withOffset(CGVector(dx: 0.0, dy: yOffsetSigned))
                startCoord.press(forDuration: 0.01, thenDragTo: endCoord)
                sleep(2)
            }
            swipes += 1
        }
        XCTAssertLessThan(swipes, maxSwipes, "Exceeded maximum amount of \(maxSwipes) swipes. Element \(self) is not visible")
    }
    
    /**
     Custom single scroll
     - parameter initialDx: initial x position
     - parameter initialDy: initial y position
     - parameter offsetDx: x position in the end of the scroll
     - parameter offsetDy: y position in the end of the scroll
     */
    func singleScroll(initialDx: Double = 0.5, initialDy: Double = 0.5, offsetDx: Double, offsetDy: Double) {
        let startCoord = XCUIApplication().windows.element.coordinate(withNormalizedOffset: CGVector(dx: initialDx, dy: initialDy))
        let endCoord = startCoord.withOffset(CGVector(dx: offsetDx, dy: offsetDy))
        startCoord.press(forDuration: 0.01, thenDragTo: endCoord, withVelocity: 40, thenHoldForDuration: 1)
        sleep(2)
    }
    
    // MARK: - TextField methods
    
    func clearText() {
        guard let stringValue = self.value as? String else {
            XCTFail("Tried to clear and enter text into a non string value")
            return
        }
        let deleteString = String(repeating: XCUIKeyboardKey.delete.rawValue, count: stringValue.count)
        self.typeText(deleteString)
    }
    
    func typeText(_ text: String, clearIfNeeded: Bool = false, dismissKeyboard: Bool) {
        self.tap()
        if clearIfNeeded { clearText()}
        self.typeText(text)
        if dismissKeyboard {
            Keyboards.tapDoneButtonOnToolbar()
        }
    }
    
    func typeTextAndVerify(_ text: String) {
        self.tap()
        self.typeText(text)
        let enteredText = self.value as? String
        XCTAssertEqual(enteredText, text, "Entered text does not match the expected text")
    }
}

// MARK: - Keyboards methods

class Keyboards {
    
    /**
     Enters number using a numeric keyboard
     - parameter number: number to be entered
     - parameter dismissKeyboard: Keyboard should be dismissed in FormStep
     */
    static func enterNumber(_ number: Int, dismissKeyboard: Bool = false, clearIfNeeded: Bool = false) {
        let numberString = String(number)
        for digitCharacter in numberString {
            let digit = String(digitCharacter)
            let key = XCUIApplication().keyboards.keys[digit]
            wait(for: key)
            if !key.isHittable {
                dismissKeyboardOnboarding()
            }
            key.tap()
        }
        if dismissKeyboard {
            tapDoneButtonOnToolbar()
        }
    }
    
    static func enterNumber(_ number: Double, dismissKeyboard: Bool = false, clearIfNeeded: Bool = false) {
        let numberString = String(number)
        if clearIfNeeded {
            deleteValue(characterCount: numberString.count)
        }
        for digitCharacter in numberString {
            let digit = String(digitCharacter)
            let key = XCUIApplication().keyboards.keys[digit]
            wait(for: key)
            if !key.isHittable {
                dismissKeyboardOnboarding()
            }
            key.tap()
        }
        if dismissKeyboard {
            tapDoneButtonOnToolbar()
        }
    }
    
    static func enterText(_ text: String, dismissKeyboard: Bool = false, clearIfNeeded: Bool = false) {
        if clearIfNeeded {
            deleteValue(characterCount: text.count)
        }
        for character in text {
            let ch = String(character)
            let key = XCUIApplication().keyboards.keys[ch]
            wait(for: key)
            if !key.isHittable {
                dismissKeyboardOnboarding()
            }
            key.tap()
        }
        if dismissKeyboard {
            tapDoneButtonOnToolbar()
        }
    }
    
    static func deleteValue(characterCount: Int) {
        for _ in 0..<characterCount {
            let key = XCUIApplication().keyboards.keys["Delete"]
            if !key.isHittable {
                dismissKeyboardOnboarding()
            }
            key.tap()
        }
    }
    
    static func deleteValueCaseSensitive(characterCount: Int) {
        for _ in 0..<characterCount {
            let deleteKeyCapitalized = XCUIApplication().keyboards.keys["Delete"]
            let deleteKeyLowercase = XCUIApplication().keyboards.keys["delete"]
            
            if deleteKeyCapitalized.waitForExistence(timeout: 15) {
                if !deleteKeyCapitalized.isHittable {
                    dismissKeyboardOnboarding()
                }
                deleteKeyCapitalized.tap()
            } else if deleteKeyLowercase.exists {
                if !deleteKeyLowercase.isHittable {
                    dismissKeyboardOnboarding()
                }
                deleteKeyLowercase.tap()
            }
        }
    }
    
    static func tapDoneButtonOnToolbar() {
        // There is only one button ("Done") on toolbar
        let doneButton = XCUIApplication().toolbars["Toolbar"].buttons.firstMatch
        wait(for: doneButton)
        doneButton.tap()
    }
    
    /// Handles the keyboard onboarding interruption ("Speed up your typing by sliding your finger across the letters to compose a word"), if it exists: https://developer.apple.com/forums/thread/650826
    static func dismissKeyboardOnboarding() {
        // TODO: rdar://117821622 (Add localization support for UI Tests)
        XCUIApplication().buttons["Continue"].tap()
    }
}
