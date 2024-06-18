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

import XCTest

@testable import ResearchKitCore

public class WatchTask: NSObject, Identifiable, NSSecureCoding {
    public static var supportsSecureCoding: Bool = true
    
    enum CodingKeys: String {
        case orderedTask
    }
    
    public func encode(with coder: NSCoder) {
        coder.encode(
            orderedTask,
            forKey: CodingKeys.orderedTask.rawValue
        )
    }
    
    public required convenience init?(coder: NSCoder) {
        guard let task = coder.decodeObject(
            of: ORKOrderedTask.self,
            forKey: CodingKeys.orderedTask.rawValue
        ) as ORKOrderedTask? else {
            return nil
        }
        
        self.init(orderedTask: task)
    }
    
    public let orderedTask: ORKOrderedTask
    
    public init(
        orderedTask: ORKOrderedTask
    ) {
        self.orderedTask = orderedTask
    }
}


public class WatchResult: NSObject, Identifiable, NSSecureCoding {
    public static var supportsSecureCoding: Bool = true
    
    enum CodingKeys: String {
        case result
    }
    
    public func encode(with coder: NSCoder) {
        coder.encode(
            result,
            forKey: CodingKeys.result.rawValue
        )
    }
    
    public required convenience init?(coder: NSCoder) {
        guard let task = coder.decodeObject(
            of: ORKTaskResult.self,
            forKey: CodingKeys.result.rawValue
        ) as ORKTaskResult? else {
            return nil
        }
        
        self.init(result: task)
    }
    
    public let result: ORKTaskResult
    
    public init(
        result: ORKTaskResult
    ) {
        self.result = result
    }
}

final class ResearchKitCoreTests: XCTestCase {
    
    func testWatchDecodingOfAppTask() throws {
        let orderedTask = ORKOrderedTask(
            identifier: "sample",
            steps: [
                ORKInstructionStep(identifier: "test1"),
                ORKCompletionStep(identifier: "test2")
            ])
        let watchTask = WatchTask(orderedTask: orderedTask)
        let data = securelyEncodeObject(object: watchTask)
        
        guard let payloadObject = securelyUnarchiveData(
            data: data,
            classTypes:  [WatchTask.self]
        ) as? WatchTask else {
            return
        }
            
        XCTAssertEqual(
            payloadObject.orderedTask.identifier,
            watchTask.orderedTask.identifier,
            "Failed to properly decode watchTask"
        )
    }
    
    func testWatchDecodingOfAppResult() throws {
        let result = ORKTaskResult(
            taskIdentifier: "id",
            taskRun: UUID(),
            outputDirectory: nil
        )
        
        let watchResult = WatchResult(result: result)
        let data = securelyEncodeObject(object: watchResult)

        guard let payloadObject = securelyUnarchiveData(
            data: data,
            classTypes:  [WatchResult.self]
        ) as? WatchResult else {
            return
        }
            
        XCTAssertEqual(
            payloadObject.result.identifier,
            watchResult.result.identifier,
            "Failed to properly decode watchResult"
        )
    }
    
    func securelyEncodeObject(object: AnyObject) -> Data {
        let archiver = NSKeyedArchiver(requiringSecureCoding: true)
        archiver.encode(object, forKey: "root")
        archiver.finishEncoding()
        let data = archiver.encodedData
        if let error = archiver.error {
            XCTFail("Unable to archive WatchResult")
        }
        
        return data
    }
    
    func securelyUnarchiveData(data: Data, classTypes: [AnyClass]) -> Any? {
        do {
            let unarchiver = try NSKeyedUnarchiver(forReadingFrom: data)
            unarchiver.requiresSecureCoding = true
            let decodedObject = try unarchiver.decodeTopLevelObject(
                of: classTypes,
                forKey: "root"
            )
            return decodedObject
        } catch {
            XCTFail("unable to decode watch message \(error)")
            return nil
        }
    }
}
