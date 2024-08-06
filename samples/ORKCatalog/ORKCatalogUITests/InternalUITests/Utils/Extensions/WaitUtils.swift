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
import XCTest

fileprivate let defaultTimeout = 30.0

/// All methods below implemented with test readability in mind (I made methods fileprivate to avoid inconsistency)
/**
 Waits for the specified XCUIElement to be in particular state within the provided timeout.
 If the condition is not met within the timeout, the test will fail.
 Depending on the specific method, the condition being waited for could be element's existence/hittability/selection state
 - parameter element: The XCUIElement to wait for
 - parameter timeout: The maximum time (in seconds) to wait
 - parameter file: The file in which failure occurred
 - parameter line: The line number on which failure occurred
 - parameter failureMessage: Message to be logged upon fail.
 */

func wait(
    for element: XCUIElement,
    toExists exists: Bool = true,
    withTimeout timeout: TimeInterval = defaultTimeout,
    file: StaticString = #file,
    line: UInt = #line,
    failureMessage: String = ""
) {
    let elementCondition: ElementState = exists ? .exists : .doesNotExist
    wait(
        for: element,
        to: elementCondition,
        withTimeout: timeout,
        file: file,
        line: line,
        failureMessage: failureMessage
    )
}

func wait(
    for element: XCUIElement,
    toBeHittable hittable: Bool,
    withTimeout timeout: TimeInterval = defaultTimeout,
    file: StaticString = #file,
    line: UInt = #line,
    failureMessage: String = ""
) {
    let elementCondition: ElementState = hittable ? .hittable : .notHittable
    wait(
        for: element,
        to: elementCondition,
        withTimeout: timeout,
        file: file,
        line: line
    )
}

func wait(
    for element: XCUIElement,
    toBeSelected selected: Bool,
    withTimeout timeout: TimeInterval = defaultTimeout,
    file: StaticString = #file,
    line: UInt = #line,
    failureMessage: String = ""
) {
    let elementCondition: ElementState = selected ? .selected : .notSelected
    wait(
        for: element,
        to: elementCondition,
        withTimeout: timeout,
        file: file,
        line: line
    )
}

func wait(
    for element: XCUIElement,
    toBeEnabled enabled: Bool,
    withTimeout timeout: TimeInterval = defaultTimeout,
    file: StaticString = #file,
    line: UInt = #line,
    failureMessage: String = ""
) {
    let elementCondition: ElementState = enabled ? .enabled : .notEnabled
    wait(
        for: element,
        to: elementCondition,
        withTimeout: timeout,
        file: file,
        line: line
    )
}

/**
 Enum representing different XCUIElement states to validate for
 */
enum ElementState {
    case exists
    case doesNotExist
    case hittable
    case notHittable
    case selected
    case notSelected
    case enabled
    case notEnabled
    
    var predicate: NSPredicate {
        switch self {
        case .exists:
            return NSPredicate(format: "exists == true")
        case .doesNotExist:
            return NSPredicate(format: "exists == false")
        case .hittable:
            return NSPredicate(format: "isHittable == true")
        case .notHittable:
            return NSPredicate(format: "isHittable == false")
        case .selected:
            return NSPredicate(format: "isSelected == true")
        case .notSelected:
            return NSPredicate(format: "isSelected == false")
        case .enabled:
            return NSPredicate(format: "isEnabled == true")
        case .notEnabled:
            return NSPredicate(format: "isEnabled == false")
        }
    }
    
    func errorMessage(element: XCUIElement, timeout: TimeInterval) -> String {
        switch self {
        case .exists:
            return "Failed to find element \(element.description) after \(timeout) seconds."
        case .doesNotExist:
            return "Unexpectedly element \(element.description) exists after \(timeout) seconds."
        case .hittable:
            return "Element \(element.description) is not hittable after \(timeout) seconds."
        case .notHittable:
            return "Unexpectedly element \(element.description) is hittable after \(timeout) seconds."
        case .selected:
            return "Element \(element.description) is not selected after \(timeout) seconds."
        case .notSelected:
            return "Unexpectedly element \(element.description) is selected after \(timeout) seconds."
        case .enabled:
            return "Element \(element.description) is not enabled after \(timeout) seconds."
        case .notEnabled:
            return "Unexpectedly element \(element.description) is enabled after \(timeout) seconds."
        }
    }
}

/**
 Waits for the given NSPredicate condition to be satisfied for the specified XCUIElement within the provided timeout
 This method is a utility function to abstract the waiting condition mechanism
 - parameter predicate: The  NSPredicate defining the condition to wait for
 - parameter element: The XCUIElement to apply the predicate to
 - parameter timeout: The maximum time (in seconds) to wait for the condition to be satisfied
 - returns: A Bool indicating whether condition was satisfied or not
 */
fileprivate func waitForPredicate(
    _ predicate: NSPredicate,
    withElement element: XCUIElement,
    withTimeout timeout: TimeInterval
) -> Bool {
    let expectation = XCTNSPredicateExpectation(predicate: predicate, object: element)
    return XCTWaiter.wait(for: [expectation], timeout: timeout).rawValue == XCTWaiter.Result.completed.rawValue
}

fileprivate func wait(
    for element: XCUIElement,
    to elementState: ElementState,
    withTimeout timeout: TimeInterval = defaultTimeout,
    file: StaticString = #file,
    line: UInt = #line,
    failureMessage: String = ""
) {
    let result = waitForPredicate(
        elementState.predicate,
        withElement: element,
        withTimeout: timeout
    )
    var message = elementState.errorMessage(element: element, timeout: timeout)
    if !failureMessage.isEmpty {
        message += " \(failureMessage)"
    }
    XCTAssert(result, message, file: file, line: line)
}
