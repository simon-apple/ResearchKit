/*
 Copyright (c) 2023, Apple Inc. All rights reserved.
 
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

import XCTest

final class ORKSecondaryActionStepNavigationRuleTests: XCTestCase {
    
    func testSecondaryActionNavigationRuleCreation() throws {
        do {
            let id = UUID().uuidString
            let secondaryActionNavigationRule = ORKSecondaryActionStepNavigationRule(destinationStepIdentifier: id, text: "Opt Out")
            XCTAssertNotNil(secondaryActionNavigationRule)
            XCTAssertNotNil(secondaryActionNavigationRule.text)
            XCTAssertNotNil(secondaryActionNavigationRule.destinationStepIdentifier)
            XCTAssertEqual(secondaryActionNavigationRule.text, "Opt Out")
            XCTAssertEqual(secondaryActionNavigationRule.destinationStepIdentifier, id)
        }
    }
    
    func testSecondaryActionNavigationRuleSkippable() throws {
        do {
            let skipActionNavigationRule = ORKSecondaryActionStepNavigationRule()
            XCTAssertNotNil(skipActionNavigationRule)
            XCTAssertNotNil(skipActionNavigationRule.text)
            XCTAssertNotNil(skipActionNavigationRule.destinationStepIdentifier)
            XCTAssertEqual(skipActionNavigationRule.text, "Skip")
            XCTAssertEqual(skipActionNavigationRule.destinationStepIdentifier, ORKSkipStepIdentifier)
        }
    }
        
    func testSecondaryActionNavigationRuleCopying() throws {
        do {
            let skipActionNavigationRule = ORKSecondaryActionStepNavigationRule()
            let copy = skipActionNavigationRule.copy() as? ORKSecondaryActionStepNavigationRule
            XCTAssertNotNil(copy)
            XCTAssertEqual(copy, skipActionNavigationRule)
        }

        do {
            let id = UUID().uuidString
            let secondaryActionNavigationRule = ORKSecondaryActionStepNavigationRule(destinationStepIdentifier: id, text: "Opt Out")
            
            let copy = secondaryActionNavigationRule.copy() as? ORKSecondaryActionStepNavigationRule
            XCTAssertNotNil(copy)
            XCTAssertNotNil(copy?.text)
            XCTAssertNotNil(copy?.destinationStepIdentifier)
            XCTAssertEqual(copy, secondaryActionNavigationRule)
        }
    }
    
    func testIsEqual() throws {
        do {
            let skipActionNavigationRule = ORKSecondaryActionStepNavigationRule()
            let secondaryActionNavigationRule = ORKSecondaryActionStepNavigationRule(destinationStepIdentifier: "some_id", text: "Opt Out")
            XCTAssertNotEqual(skipActionNavigationRule, secondaryActionNavigationRule)
        }

        do {
            let id = UUID().uuidString
            let secondaryActionNavigationRule1 = ORKSecondaryActionStepNavigationRule(destinationStepIdentifier: id, text: "Opt Out")
            let secondaryActionNavigationRule2 = ORKSecondaryActionStepNavigationRule(destinationStepIdentifier: id, text: "Opt Out")
            XCTAssertEqual(secondaryActionNavigationRule1, secondaryActionNavigationRule2)
        }
    }
    
    func testHashing() throws {
        let id = UUID().uuidString
        let secondaryActionNavigationRule1 = ORKSecondaryActionStepNavigationRule(destinationStepIdentifier: id, text: "Opt Out")
        let secondaryActionNavigationRule2 = ORKSecondaryActionStepNavigationRule(destinationStepIdentifier: id, text: "Opt Out")
        let secondaryActionNavigationRule3 = ORKSecondaryActionStepNavigationRule(destinationStepIdentifier: id, text: "Opt In")

        do {
            let set = NSSet(array: [secondaryActionNavigationRule1, secondaryActionNavigationRule2])
            XCTAssertEqual(set.count, 1, "equal rules should replace hash to one object in a set")
        }
        do {
            let set = NSSet(array: [secondaryActionNavigationRule1, secondaryActionNavigationRule3])
            XCTAssertEqual(set.count, 2, "unequal rules should coexist in a set")
        }
        do {
            let set = NSSet(array: [secondaryActionNavigationRule1, id])
            XCTAssertEqual(set.count, 2, "The two types should occupy two slots in a set")
        }
        do {
            let set = Set([secondaryActionNavigationRule1, secondaryActionNavigationRule2, secondaryActionNavigationRule3])
            XCTAssertEqual(set.count, 2)
        }
        do {
            let set = Set<NSObject>([secondaryActionNavigationRule1, id as NSString])
            XCTAssertEqual(set.count, 2)
        }
    }
}
