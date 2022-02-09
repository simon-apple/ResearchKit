//
/*
 Copyright (c) 2022, Apple Inc. All rights reserved.
 
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

class ORKSecureCodingTests: XCTestCase {
    
    // start-omit-internal-code

    // This test ensures that `NSSecureDecoding` of `ORKWebViewStepResult`, which tries to decode
    // an `userDictionary`, is correctly implemented and doesn't regress.
    // On iOS 14, a missing plist type when secure decoding was treated as a warning, but it changed
    // to an exception (crashing the app) under some circumstances on iOS 15.
    // We're using the '_enforceExplicitPlistTypes' SPI to ensure the test doesn't succeed when missing plist types,
    // because when we run this test from internal Xcodes with iOS 15 SDKs, missing plist types are treated as a warning
    // instead of an exception again.
    func testSecureDecodingOfResultUserInfoIsCorrect() throws {
        let taskResult = ORKTaskResult(taskIdentifier: UUID().uuidString, taskRun: UUID(), outputDirectory: nil)
        let webStepResult = ORKWebViewStepResult(identifier: UUID().uuidString)
        webStepResult.userInfo = ["html": "test"]
        webStepResult.result = "test"
        let stepResult = ORKStepResult(stepIdentifier: UUID().uuidString, results: [webStepResult])
        taskResult.results = [stepResult]
        
        let data = try NSKeyedArchiver.archivedData(withRootObject: taskResult, requiringSecureCoding: true)
        XCTAssertNotNil(data)
        
        let unarchiver = try NSKeyedUnarchiver(forReadingFrom: data)
        // SPI only available in iOS 15.0+
        let selector = NSSelectorFromString("_enforceExplicitPlistTypes")
        if (unarchiver.responds(to: selector)) {
            _ = unarchiver.perform(selector)
        }
        let taskResultB = unarchiver.decodeObject(of: ORKTaskResult.self, forKey: "root")
        XCTAssertEqual(taskResult, taskResultB)
    }
    
    // end-omit-internal-code

}
