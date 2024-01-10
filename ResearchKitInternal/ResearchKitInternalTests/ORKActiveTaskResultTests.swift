/*
 Copyright (c) 2015, Apple Inc. All rights reserved.
 
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
@testable import ResearchKit
@testable import ResearchKitActiveTask
@testable import ResearchKitInternal
@testable import ResearchKitInternal_Private
@testable import ResearchKitUI
@testable import ResearchKitActiveTask
@testable import ResearchKitActiveTask_Private


class ORKHeadphoneDetectResultTests: XCTestCase {
    var result: ORKHeadphoneDetectResult!
    var identifier: String!
    let date = Date()
    
    override func setUp() {
        super.setUp()
        identifier = "RESULT"
        result = ORKHeadphoneDetectResult(identifier: identifier)
        
        result.headphoneType = ORKHeadphoneTypeIdentifier.airPodsGen2
        result.vendorID = "0x004C"
        result.productID = "0x200f"
        result.deviceSubType = 1
    }
 
    func testProperties() {
        XCTAssertEqual(result.identifier, identifier)
        XCTAssertEqual(result.headphoneType, ORKHeadphoneTypeIdentifier.airPodsGen2)
    }
    
    func testIsEqual() {
        result.startDate = date
        result.endDate = date
        
        let newResult = ORKHeadphoneDetectResult(identifier: identifier)
        newResult.headphoneType = ORKHeadphoneTypeIdentifier.airPodsGen2
        newResult.vendorID = "0x004C"
        newResult.productID = "0x200f"
        newResult.deviceSubType = 1
        newResult.startDate = date
        newResult.endDate = date
        
        XCTAssert(result.isEqual(newResult))
    }
}
