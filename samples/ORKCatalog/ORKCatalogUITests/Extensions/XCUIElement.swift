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
    
    var visible: Bool {
        guard exists && !frame.isEmpty else { return false }
        return XCUIApplication().windows.element(boundBy: 0).frame.contains(frame)
    }
    
    /**
    Scrolls to a particular element until it is visible in screen rect:
    */
    func scrollUntilVisible(direction: SwipeDirection = .up, maxSwipes: Int = 10) {
        var swipes = 0
        while !self.visible && swipes < maxSwipes {
            let startCoord = XCUIApplication().windows.element.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
            switch direction {
            //dy: y position in the end of the scroll
            case .up:
                let endCoord = startCoord.withOffset(CGVector(dx: 0.0, dy: -262))
                startCoord.press(forDuration: 0.01, thenDragTo: endCoord)
                sleep(2)
            case .down:
                let endCoord = startCoord.withOffset(CGVector(dx: 0.0, dy: 262))
                startCoord.press(forDuration: 0.01, thenDragTo: endCoord)
                sleep(2)
            }
            swipes += 1
        }
        XCTAssertLessThan(swipes, maxSwipes, "Exceeded maximum amount of \(maxSwipes) swipes")
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
    static func enterNumber(_ number: Int, dismissKeyboard: Bool = false) {
        let numberString = String(number)
        for digitCharacter in numberString {
            let digit = String(digitCharacter)
            let key = XCUIApplication().keyboards.keys[digit]
            if !key.isHittable {
                dismissKeyboardOnboarding()
            }
            key.tap()
        }
        if dismissKeyboard {
            tapDoneButtonOnToolbar()
        }
    }
    
    static func enterText(_ text: String, dismissKeyboard: Bool = false) {
        for character in text {
            let ch = String(character)
            let key = XCUIApplication().keyboards.keys[ch]
            if !key.isHittable {
                dismissKeyboardOnboarding()
            }
            key.tap()
        }
        if dismissKeyboard {
            tapDoneButtonOnToolbar()
        }
    }
    
    static func tapDoneButtonOnToolbar() {
        // There is only one button ("Done") on toolbar
        let doneButton = XCUIApplication().toolbars["Toolbar"].buttons.firstMatch
        wait(for: doneButton)
        doneButton.tap()
    }
    
    // Handles the keyboard onboarding interruption ("Speed up your typing by sliding your finger across the letters to compose a word"), if it exists: https://developer.apple.com/forums/thread/650826
    static func dismissKeyboardOnboarding() {
        // TODO: L10n support
        XCUIApplication().buttons["Continue"].tap()
    }
}
