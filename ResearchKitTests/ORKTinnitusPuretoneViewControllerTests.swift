/*
 Copyright (c) 2021, Apple Inc. All rights reserved.
 
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
@testable import ResearchKit_Private

class ORKTinnitusPuretoneViewControllerTests: XCTestCase {
    var puretoneController: ORKTinnitusPureToneStepViewController!
    var step: ORKTinnitusPureToneStep!
    var result: ORKResult!
    var utilities: TopLevelUIUtilities<ORKTinnitusPureToneStepViewController>!
    let possibleFrequencies = [315.0, 354.0, 400, 449, 500, 561, 630.0, 707.0, 800.0, 898.0, 1000.0, 1122.0, 1250.0, 1403.0, 1600.0, 1796.0, 2000.0, 2245.0, 2500.0, 2806.0, 3150.0, 3536.0, 4000.0, 4490.0, 5000.0, 5612.0, 6300.0, 7072.0, 8000.0, 8980.0, 10000.0, 11224.0, 12500.0] as [NSNumber]
    
    override func setUp() {
        super.setUp()
        
        result = ORKResult(identifier: "RESULT")
        step = ORKTinnitusPureToneStep(identifier: "STEP")
        
        utilities = TopLevelUIUtilities<ORKTinnitusPureToneStepViewController>()
    }
    
    override func tearDown() {
        super.tearDown()
        utilities.tearDownTopLevelUI()
    }
    
    // TEST 1 (Inconsistencies and Frequencies too low)
    func testInconsistenciesAndTooLow() {
        step.roundNumber = 1
        puretoneController = ORKTinnitusPureToneStepViewController(step: step, result: result)
        
        utilities.setupTopLevelUI(withViewController: puretoneController)
        
        var lowerFrequencyLimit:Double = Double(truncating: possibleFrequencies[puretoneController.bFrequencyIndex])
        
        /*
         High
         Lower
         Lower
         Lower
         Lower
         Lower
         Lower
         Lower
         Lower
         Lower ??
         */
        puretoneController.getFrequencyAndCalculateIndexes(for: .A)
        XCTAssertEqual(puretoneController.lastChosenFrequency, 5000.0)
        XCTAssertEqual(puretoneController.lastError, "None")
        puretoneController.getFrequencyAndCalculateIndexes(for: .B)
        XCTAssertEqual(puretoneController.lastChosenFrequency, 5000.0)
        XCTAssertEqual(puretoneController.lastError, "None")
        puretoneController.getFrequencyAndCalculateIndexes(for: .B)
        XCTAssertEqual(puretoneController.lastChosenFrequency, 4000.0)
        XCTAssertEqual(puretoneController.lastError, "None")
        puretoneController.getFrequencyAndCalculateIndexes(for: .B)
        XCTAssertEqual(puretoneController.lastChosenFrequency, 3150.0)
        XCTAssertEqual(puretoneController.lastError, "None")
        puretoneController.getFrequencyAndCalculateIndexes(for: .B)
        XCTAssertEqual(puretoneController.lastChosenFrequency, 2500.0)
        XCTAssertEqual(puretoneController.lastError, "None")
        puretoneController.getFrequencyAndCalculateIndexes(for: .B)
        XCTAssertEqual(puretoneController.lastChosenFrequency, 2000.0)
        XCTAssertEqual(puretoneController.lastError, "None")
        puretoneController.getFrequencyAndCalculateIndexes(for: .B)
        XCTAssertEqual(puretoneController.lastChosenFrequency, 1600.0)
        XCTAssertEqual(puretoneController.lastError, "None")
        puretoneController.getFrequencyAndCalculateIndexes(for: .B)
        XCTAssertEqual(puretoneController.lastChosenFrequency, 1250.0)
        XCTAssertEqual(puretoneController.lastError, "None")
        puretoneController.getFrequencyAndCalculateIndexes(for: .B)
        XCTAssertEqual(puretoneController.lastChosenFrequency, 1000.0)
        let firstChosenFrequency = puretoneController.lastChosenFrequency;
        XCTAssertEqual(firstChosenFrequency, lowerFrequencyLimit)
        
        XCTAssertEqual(puretoneController.lastError, "Inconsistency")
        
        step.roundNumber = 2
        puretoneController = ORKTinnitusPureToneStepViewController(step: step, result: result)
        
        utilities.setupTopLevelUI(withViewController: puretoneController)
        
        lowerFrequencyLimit = Double(truncating: possibleFrequencies[puretoneController.cFrequencyIndex])
        
        /*
         Mid
         Lower
         Lower
         Lower
         Lower
         Lower
         Lower ??
         */
        puretoneController.getFrequencyAndCalculateIndexes(for: .B)
        XCTAssertEqual(puretoneController.lastChosenFrequency, 1250.0)
        XCTAssertEqual(puretoneController.lastError, "None")
        puretoneController.getFrequencyAndCalculateIndexes(for: .B)
        XCTAssertEqual(puretoneController.lastChosenFrequency, 1250.0)
        XCTAssertEqual(puretoneController.lastError, "None")
        puretoneController.getFrequencyAndCalculateIndexes(for: .B)
        XCTAssertEqual(puretoneController.lastChosenFrequency, 1000.0)
        XCTAssertEqual(puretoneController.lastError, "None")
        puretoneController.getFrequencyAndCalculateIndexes(for: .B)
        XCTAssertEqual(puretoneController.lastChosenFrequency, 800.0)
        XCTAssertEqual(puretoneController.lastError, "None")
        puretoneController.getFrequencyAndCalculateIndexes(for: .B)
        XCTAssertEqual(puretoneController.lastChosenFrequency, 630.0)
        XCTAssertEqual(puretoneController.lastError, "None")
        puretoneController.getFrequencyAndCalculateIndexes(for: .B)
        XCTAssertEqual(puretoneController.lastChosenFrequency, 500.0)
        let secondChosenFrequency = puretoneController.lastChosenFrequency
        XCTAssertEqual(secondChosenFrequency, lowerFrequencyLimit)
        XCTAssertEqual(puretoneController.lastError, "Inconsistency")
        
        step.roundNumber = 3
        puretoneController = ORKTinnitusPureToneStepViewController(step: step, result: result)
        
        utilities.setupTopLevelUI(withViewController: puretoneController)
        
        lowerFrequencyLimit = Double(truncating: possibleFrequencies[0])
        
        /*
         Low
         Lower
         Lower
         Lower
         Lower
         */
        puretoneController.getFrequencyAndCalculateIndexes(for: .C)
        XCTAssertEqual(puretoneController.lastChosenFrequency, 630.0)
        XCTAssertEqual(puretoneController.lastError, "None")
        puretoneController.getFrequencyAndCalculateIndexes(for: .B)
        XCTAssertEqual(puretoneController.lastChosenFrequency, 630.0)
        XCTAssertEqual(puretoneController.lastError, "None")
        puretoneController.getFrequencyAndCalculateIndexes(for: .B)
        XCTAssertEqual(puretoneController.lastChosenFrequency, 500.0)
        XCTAssertEqual(puretoneController.lastError, "None")
        puretoneController.getFrequencyAndCalculateIndexes(for: .B)
        XCTAssertEqual(puretoneController.lastChosenFrequency, 400.0)
        XCTAssertEqual(puretoneController.lastError, "None")
        puretoneController.getFrequencyAndCalculateIndexes(for: .B)
        XCTAssertEqual(puretoneController.lastChosenFrequency, 315.0)
        let thirdChosenFrequency = puretoneController.lastChosenFrequency
        XCTAssertEqual(thirdChosenFrequency, lowerFrequencyLimit)
        
        XCTAssertEqual(puretoneController.lastError, "TooLowFrequency")
        
        let hasPredominantFrequency = (firstChosenFrequency == secondChosenFrequency || firstChosenFrequency == thirdChosenFrequency || secondChosenFrequency == thirdChosenFrequency)
        
        XCTAssertNotEqual(hasPredominantFrequency, true)
    }
    
    // TEST 2 (Inconsistencies and Frequencies too high)
    func testHighFrequencyInconsistence() {
        puretoneController = ORKTinnitusPureToneStepViewController(step: step, result: result)
        
        utilities.setupTopLevelUI(withViewController: puretoneController)
        
        var higherFrequencyLimit:Double = Double(truncating: possibleFrequencies.last!)
        
        /*
         High
         Upper
         Upper
         Upper
         Upper
         */
        puretoneController.getFrequencyAndCalculateIndexes(for: .A)
        XCTAssertEqual(puretoneController.lastChosenFrequency, 5000.0)
        XCTAssertEqual(puretoneController.lastError, "None")
        puretoneController.getFrequencyAndCalculateIndexes(for: .A)
        XCTAssertEqual(puretoneController.lastChosenFrequency, 6300.0)
        XCTAssertEqual(puretoneController.lastError, "None")
        puretoneController.getFrequencyAndCalculateIndexes(for: .A)
        XCTAssertEqual(puretoneController.lastChosenFrequency, 8000.0)
        XCTAssertEqual(puretoneController.lastError, "None")
        puretoneController.getFrequencyAndCalculateIndexes(for: .A)
        XCTAssertEqual(puretoneController.lastChosenFrequency, 10000.0)
        XCTAssertEqual(puretoneController.lastError, "None")
        puretoneController.getFrequencyAndCalculateIndexes(for: .A)
        XCTAssertEqual(puretoneController.lastChosenFrequency, 12500.0)
        let firstChosenFrequency = puretoneController.lastChosenFrequency
        XCTAssertEqual(firstChosenFrequency, higherFrequencyLimit)
        
        XCTAssertEqual(puretoneController.lastError, "TooHighFrequency")
        
        step.roundNumber = 2
        puretoneController = ORKTinnitusPureToneStepViewController(step: step, result: result)
        
        utilities.setupTopLevelUI(withViewController: puretoneController)
        
        higherFrequencyLimit = Double(truncating: possibleFrequencies[puretoneController.aFrequencyIndex])
        
        /*
         Mid
         Upper
         Upper
         Upper
         Upper
         Upper
         Upper
         Upper
         */
        puretoneController.getFrequencyAndCalculateIndexes(for: .B)
        XCTAssertEqual(puretoneController.lastChosenFrequency, 1250.0)
        XCTAssertEqual(puretoneController.lastError, "None")
        puretoneController.getFrequencyAndCalculateIndexes(for: .A)
        XCTAssertEqual(puretoneController.lastChosenFrequency, 1600.0)
        XCTAssertEqual(puretoneController.lastError, "None")
        puretoneController.getFrequencyAndCalculateIndexes(for: .A)
        XCTAssertEqual(puretoneController.lastChosenFrequency, 2000.0)
        XCTAssertEqual(puretoneController.lastError, "None")
        puretoneController.getFrequencyAndCalculateIndexes(for: .A)
        XCTAssertEqual(puretoneController.lastChosenFrequency, 2500.0)
        XCTAssertEqual(puretoneController.lastError, "None")
        puretoneController.getFrequencyAndCalculateIndexes(for: .A)
        XCTAssertEqual(puretoneController.lastChosenFrequency, 3150.0)
        XCTAssertEqual(puretoneController.lastError, "None")
        puretoneController.getFrequencyAndCalculateIndexes(for: .A)
        XCTAssertEqual(puretoneController.lastChosenFrequency, 4000.0)
        XCTAssertEqual(puretoneController.lastError, "None")
        puretoneController.getFrequencyAndCalculateIndexes(for: .A)
        XCTAssertEqual(puretoneController.lastChosenFrequency, 5000.0)
        XCTAssertEqual(puretoneController.lastError, "None")
        puretoneController.getFrequencyAndCalculateIndexes(for: .A)
        XCTAssertEqual(puretoneController.lastChosenFrequency, 6300.0)
        let secondChosenFrequency = puretoneController.lastChosenFrequency
        XCTAssertEqual(secondChosenFrequency, higherFrequencyLimit)
        
        XCTAssertEqual(puretoneController.lastError, "Inconsistency")
        
        step.roundNumber = 3
        puretoneController = ORKTinnitusPureToneStepViewController(step: step, result: result)
        
        utilities.setupTopLevelUI(withViewController: puretoneController)
        
        higherFrequencyLimit = Double(truncating: possibleFrequencies[puretoneController.bFrequencyIndex])
        
        /*
         Low
         Upper
         Upper
         Upper
         Upper
         Upper
         */
        puretoneController.getFrequencyAndCalculateIndexes(for: .C)
        XCTAssertEqual(puretoneController.lastChosenFrequency, 630.0)
        XCTAssertEqual(puretoneController.lastError, "None")
        puretoneController.getFrequencyAndCalculateIndexes(for: .A)
        XCTAssertEqual(puretoneController.lastChosenFrequency, 800.0)
        XCTAssertEqual(puretoneController.lastError, "None")
        puretoneController.getFrequencyAndCalculateIndexes(for: .A)
        XCTAssertEqual(puretoneController.lastChosenFrequency, 1000.0)
        XCTAssertEqual(puretoneController.lastError, "None")
        puretoneController.getFrequencyAndCalculateIndexes(for: .A)
        XCTAssertEqual(puretoneController.lastChosenFrequency, 1250.0)
        XCTAssertEqual(puretoneController.lastError, "None")
        puretoneController.getFrequencyAndCalculateIndexes(for: .A)
        XCTAssertEqual(puretoneController.lastChosenFrequency, 1600.0)
        let thirdChosenFrequency = puretoneController.lastChosenFrequency
        XCTAssertEqual(thirdChosenFrequency, higherFrequencyLimit)
        
        XCTAssertEqual(puretoneController.lastError, "Inconsistency")
        
        let hasPredominantFrequency = (firstChosenFrequency == secondChosenFrequency || firstChosenFrequency == thirdChosenFrequency || secondChosenFrequency == thirdChosenFrequency)
        
        XCTAssertNotEqual(hasPredominantFrequency, true)
    }
    
    // TEST 3 (Frequencies too low high through octave confusion step)
    func testtooLowHighThroughOctaveConfusion() {
        step.roundNumber = 1
        puretoneController = ORKTinnitusPureToneStepViewController(step: step, result: result)
        
        utilities.setupTopLevelUI(withViewController: puretoneController)
        
        /*
         High
         Upper
         Lower
         Lower
         Upper
         Upper (=12500)
         
         Expected result = move to next round (frequency too high)
         */
        puretoneController.getFrequencyAndCalculateIndexes(for: .A)
        XCTAssertEqual(puretoneController.lastChosenFrequency, 5000.0)
        XCTAssertEqual(puretoneController.lastError, "None")
        puretoneController.getFrequencyAndCalculateIndexes(for: .A)
        XCTAssertEqual(puretoneController.lastChosenFrequency, 6300.0)
        XCTAssertEqual(puretoneController.lastError, "None")
        puretoneController.getFrequencyAndCalculateIndexes(for: .B)
        XCTAssertEqual(puretoneController.lastChosenFrequency, 6300.0)
        XCTAssertEqual(puretoneController.lastError, "None")
        puretoneController.getFrequencyAndCalculateIndexes(for: .B)
        XCTAssertEqual(puretoneController.lastChosenFrequency, 6300.0)
        XCTAssertEqual(puretoneController.lastError, "None")
        puretoneController.getFrequencyAndCalculateIndexes(for: .A)
        XCTAssertEqual(puretoneController.lastChosenFrequency, 6300.0)
        XCTAssertEqual(puretoneController.lastError, "None")
        puretoneController.getFrequencyAndCalculateIndexes(for: .A)
        XCTAssertEqual(puretoneController.lastChosenFrequency, 12500)
        XCTAssertEqual(puretoneController.lastError, "TooHighFrequency")
        
        /*
         Low
         Upper
         Lower
         Lower
         Upper
         Lower
         Lower
         
         Expected result = move to next round (frequency too low)

         */
        step.roundNumber = 2
        puretoneController = ORKTinnitusPureToneStepViewController(step: step, result: result)
        
        utilities.setupTopLevelUI(withViewController: puretoneController)

        puretoneController.getFrequencyAndCalculateIndexes(for: .C) // A:6300, B:1250, C: 500
        XCTAssertEqual(puretoneController.lastChosenFrequency, 500.0)
        XCTAssertEqual(puretoneController.lastError, "None")
        puretoneController.getFrequencyAndCalculateIndexes(for: .A) // A:630, B:500
        XCTAssertEqual(puretoneController.lastChosenFrequency, 630.0)
        XCTAssertEqual(puretoneController.lastError, "None")
        puretoneController.getFrequencyAndCalculateIndexes(for: .B) // A:800, B:630
        XCTAssertEqual(puretoneController.lastChosenFrequency, 630.0)
        XCTAssertEqual(puretoneController.lastError, "None")
        puretoneController.getFrequencyAndCalculateIndexes(for: .B) // A:707, B:630
        XCTAssertEqual(puretoneController.lastChosenFrequency, 630.0)
        XCTAssertEqual(puretoneController.lastError, "None")
        puretoneController.getFrequencyAndCalculateIndexes(for: .A) // A:630, B:561
        XCTAssertEqual(puretoneController.lastChosenFrequency, 630.0)
        XCTAssertEqual(puretoneController.lastError, "None")
        puretoneController.getFrequencyAndCalculateIndexes(for: .B) // A:1250, B:630
        XCTAssertEqual(puretoneController.lastChosenFrequency, 630.0)
        XCTAssertEqual(puretoneController.lastError, "None")
        puretoneController.getFrequencyAndCalculateIndexes(for: .B) // A:630, B:315.0
        XCTAssertEqual(puretoneController.lastError, "TooLowFrequency")
    }
    
    // TEST 4 (Convergence, 3 of 3 target = 4490 Hz)
    func testConvergence4490() {
        step.roundNumber = 1
        puretoneController = ORKTinnitusPureToneStepViewController(step: step, result: result)
        
        utilities.setupTopLevelUI(withViewController: puretoneController)
        
        /*
         High
         Lower
         Lower
         Upper
         Upper
         Lower
         Upper

         */
        puretoneController.getFrequencyAndCalculateIndexes(for: .A)
        XCTAssertEqual(puretoneController.lastChosenFrequency, 5000.0)
        XCTAssertEqual(puretoneController.lastError, "None")
        puretoneController.getFrequencyAndCalculateIndexes(for: .B)
        XCTAssertEqual(puretoneController.lastChosenFrequency, 5000.0)
        XCTAssertEqual(puretoneController.lastError, "None")
        puretoneController.getFrequencyAndCalculateIndexes(for: .B)
        XCTAssertEqual(puretoneController.lastChosenFrequency, 4000.0)
        XCTAssertEqual(puretoneController.lastError, "None")
        puretoneController.getFrequencyAndCalculateIndexes(for: .A)
        XCTAssertEqual(puretoneController.lastChosenFrequency, 4000.0)
        XCTAssertEqual(puretoneController.lastError, "None")
        puretoneController.getFrequencyAndCalculateIndexes(for: .A)
        XCTAssertEqual(puretoneController.lastChosenFrequency, 4490.0)
        XCTAssertEqual(puretoneController.lastError, "None")
        puretoneController.getFrequencyAndCalculateIndexes(for: .B)
        XCTAssertEqual(puretoneController.lastChosenFrequency, 4490.0)
        XCTAssertEqual(puretoneController.lastError, "None")
        puretoneController.getFrequencyAndCalculateIndexes(for: .A)
        XCTAssertEqual(puretoneController.lastChosenFrequency, 4490.0)
        XCTAssertEqual(puretoneController.lastError, "None")
        puretoneController.getFrequencyAndCalculateIndexes(for: .A)
        XCTAssertEqual(puretoneController.lastChosenFrequency, 4490.0)
        XCTAssertEqual(puretoneController.lastError, "None")
        let firstChosenFrequency = puretoneController.lastChosenFrequency
        
        step.roundNumber = 2
        puretoneController = ORKTinnitusPureToneStepViewController(step: step, result: result)
        
        utilities.setupTopLevelUI(withViewController: puretoneController)
        
        /*
         Mid
         Upper
         Upper
         Upper
         Upper
         Upper
         Lower
         Upper
         Lower
         Upper

         */
        puretoneController.getFrequencyAndCalculateIndexes(for: .B) // A:6300, B:1250, C:500.0
        XCTAssertEqual(puretoneController.lastChosenFrequency, 1250.0)
        XCTAssertEqual(puretoneController.lastError, "None")
        puretoneController.getFrequencyAndCalculateIndexes(for: .A) // A:1600, B:1250
        XCTAssertEqual(puretoneController.lastChosenFrequency, 1600.0)
        XCTAssertEqual(puretoneController.lastError, "None")
        puretoneController.getFrequencyAndCalculateIndexes(for: .A) // A:2000, B:1600
        XCTAssertEqual(puretoneController.lastChosenFrequency, 2000.0)
        XCTAssertEqual(puretoneController.lastError, "None")
        puretoneController.getFrequencyAndCalculateIndexes(for: .A) // A:2500, B:2000
        XCTAssertEqual(puretoneController.lastChosenFrequency, 2500.0)
        XCTAssertEqual(puretoneController.lastError, "None")
        puretoneController.getFrequencyAndCalculateIndexes(for: .A) // A:3150, B:2500
        XCTAssertEqual(puretoneController.lastChosenFrequency, 3150.0)
        XCTAssertEqual(puretoneController.lastError, "None")
        puretoneController.getFrequencyAndCalculateIndexes(for: .A) // A:4000, B:3150
        XCTAssertEqual(puretoneController.lastChosenFrequency, 4000.0)
        XCTAssertEqual(puretoneController.lastError, "None")
        puretoneController.getFrequencyAndCalculateIndexes(for: .B) // A:5000, B:4000
        XCTAssertEqual(puretoneController.lastChosenFrequency, 4000.0)
        XCTAssertEqual(puretoneController.lastError, "None")
        puretoneController.getFrequencyAndCalculateIndexes(for: .A) // A:4490, B:4000
        XCTAssertEqual(puretoneController.lastChosenFrequency, 4490.0)
        XCTAssertEqual(puretoneController.lastError, "None")
        puretoneController.getFrequencyAndCalculateIndexes(for: .B) // A:8980, B:4490
        XCTAssertEqual(puretoneController.lastChosenFrequency, 4490.0)
        XCTAssertEqual(puretoneController.lastError, "None")
        puretoneController.getFrequencyAndCalculateIndexes(for: .A) // A:4490, B:2245
        XCTAssertEqual(puretoneController.lastChosenFrequency, 4490.0)
        
        
        let secondChosenFrequency = puretoneController.lastChosenFrequency
        XCTAssertEqual(puretoneController.lastError, "None")
        
        step.roundNumber = 3
        puretoneController = ORKTinnitusPureToneStepViewController(step: step, result: result)
        
        utilities.setupTopLevelUI(withViewController: puretoneController)
        
        /*
         High
         Lower
         Lower
         Lower
         Lower
         Upper
         Upper
         Lower
         Upper

         */
        puretoneController.getFrequencyAndCalculateIndexes(for: .A) // A:8000, B:1600, C:630
        XCTAssertEqual(puretoneController.lastChosenFrequency, 8000.0)
        XCTAssertEqual(puretoneController.lastError, "None")
        puretoneController.getFrequencyAndCalculateIndexes(for: .B) // A:10000, B:8000
        XCTAssertEqual(puretoneController.lastChosenFrequency, 8000.0)
        XCTAssertEqual(puretoneController.lastError, "None")
        puretoneController.getFrequencyAndCalculateIndexes(for: .B) // A:8000, B:6300
        XCTAssertEqual(puretoneController.lastChosenFrequency, 6300.0)
        XCTAssertEqual(puretoneController.lastError, "None")
        puretoneController.getFrequencyAndCalculateIndexes(for: .B) // A:6300, B:5000
        XCTAssertEqual(puretoneController.lastChosenFrequency, 5000.0)
        XCTAssertEqual(puretoneController.lastError, "None")
        puretoneController.getFrequencyAndCalculateIndexes(for: .B) // A:5000, B:4000
        XCTAssertEqual(puretoneController.lastChosenFrequency, 4000.0)
        XCTAssertEqual(puretoneController.lastError, "None")
        puretoneController.getFrequencyAndCalculateIndexes(for: .A) // A:4000, B:3150
        XCTAssertEqual(puretoneController.lastChosenFrequency, 4000.0)
        XCTAssertEqual(puretoneController.lastError, "None")
        puretoneController.getFrequencyAndCalculateIndexes(for: .A) // A:4490, B:4000
        XCTAssertEqual(puretoneController.lastChosenFrequency, 4490)
        XCTAssertEqual(puretoneController.lastError, "None")
        puretoneController.getFrequencyAndCalculateIndexes(for: .B) // A:8980, B:4490
        XCTAssertEqual(puretoneController.lastChosenFrequency, 4490)
        XCTAssertEqual(puretoneController.lastError, "None")
        puretoneController.getFrequencyAndCalculateIndexes(for: .A) // A:4490, B:2245
        XCTAssertEqual(puretoneController.lastChosenFrequency, 4490)
        XCTAssertEqual(puretoneController.lastError, "None") // no erors
        
        let thirdChosenFrequency = puretoneController.lastChosenFrequency
        
        let hasPredominantFrequency = (firstChosenFrequency == secondChosenFrequency && secondChosenFrequency == thirdChosenFrequency)
        
        XCTAssertEqual(hasPredominantFrequency, true)
    }
    
    // TEST 5 (Convergence, 3 of 3 target = 400 Hz)
    func testConverge400() {
        step.roundNumber = 1
        puretoneController = ORKTinnitusPureToneStepViewController(step: step, result: result)
        
        utilities.setupTopLevelUI(withViewController: puretoneController)
        
        /*
         Low
         Lower
         Upper
         Lower
         Upper
         Lower
         */
        puretoneController.getFrequencyAndCalculateIndexes(for: .C) // A:5000, B:1000, C:400
        XCTAssertEqual(puretoneController.lastChosenFrequency, 400.0)
        XCTAssertEqual(puretoneController.lastError, "None")
        puretoneController.getFrequencyAndCalculateIndexes(for: .B) // A:500, B:400
        XCTAssertEqual(puretoneController.lastChosenFrequency, 400.0)
        XCTAssertEqual(puretoneController.lastError, "None")
        puretoneController.getFrequencyAndCalculateIndexes(for: .A) // A:400, B:315
        XCTAssertEqual(puretoneController.lastChosenFrequency, 400.0)
        XCTAssertEqual(puretoneController.lastError, "None")
        puretoneController.getFrequencyAndCalculateIndexes(for: .B) // A:449, B:400
        XCTAssertEqual(puretoneController.lastChosenFrequency, 400.0)
        XCTAssertEqual(puretoneController.lastError, "None")
        puretoneController.getFrequencyAndCalculateIndexes(for: .A) // A:400, B:354
        XCTAssertEqual(puretoneController.lastChosenFrequency, 400.0)
        XCTAssertEqual(puretoneController.lastError, "None")
        puretoneController.getFrequencyAndCalculateIndexes(for: .B) // A:800, B:400
        XCTAssertEqual(puretoneController.lastChosenFrequency, 400.0)
        XCTAssertEqual(puretoneController.lastError, "None")
        let firstChosenFrequency = puretoneController.lastChosenFrequency
        
        step.roundNumber = 2
        puretoneController = ORKTinnitusPureToneStepViewController(step: step, result: result)
        
        utilities.setupTopLevelUI(withViewController: puretoneController)
        
        /*
         Low
         Lower
         Lower
         Upper
         Lower
         Upper
         Lower

         */
        puretoneController.getFrequencyAndCalculateIndexes(for: .C)
        XCTAssertEqual(puretoneController.lastChosenFrequency, 500.0)
        XCTAssertEqual(puretoneController.lastError, "None")
        puretoneController.getFrequencyAndCalculateIndexes(for: .B)
        XCTAssertEqual(puretoneController.lastChosenFrequency, 500.0)
        XCTAssertEqual(puretoneController.lastError, "None")
        puretoneController.getFrequencyAndCalculateIndexes(for: .B)
        XCTAssertEqual(puretoneController.lastChosenFrequency, 400.0)
        XCTAssertEqual(puretoneController.lastError, "None")
        puretoneController.getFrequencyAndCalculateIndexes(for: .A)
        XCTAssertEqual(puretoneController.lastChosenFrequency, 400.0)
        XCTAssertEqual(puretoneController.lastError, "None")
        puretoneController.getFrequencyAndCalculateIndexes(for: .B)
        XCTAssertEqual(puretoneController.lastChosenFrequency, 400.0)
        XCTAssertEqual(puretoneController.lastError, "None")
        puretoneController.getFrequencyAndCalculateIndexes(for: .A)
        XCTAssertEqual(puretoneController.lastChosenFrequency, 400.0)
        XCTAssertEqual(puretoneController.lastError, "None")
        puretoneController.getFrequencyAndCalculateIndexes(for: .B)
        XCTAssertEqual(puretoneController.lastChosenFrequency, 400.0)
        XCTAssertEqual(puretoneController.lastError, "None")
        let secondChosenFrequency = puretoneController.lastChosenFrequency
        
        step.roundNumber = 3
        puretoneController = ORKTinnitusPureToneStepViewController(step: step, result: result)
        
        utilities.setupTopLevelUI(withViewController: puretoneController)
        
        /*
         Low
         Lower
         Lower
         Lower
         Upper
         Lower
         Upper
         Lower

         */
        puretoneController.getFrequencyAndCalculateIndexes(for: .C)
        XCTAssertEqual(puretoneController.lastChosenFrequency, 630.0)
        XCTAssertEqual(puretoneController.lastError, "None")
        puretoneController.getFrequencyAndCalculateIndexes(for: .B)
        XCTAssertEqual(puretoneController.lastChosenFrequency, 630.0)
        XCTAssertEqual(puretoneController.lastError, "None")
        puretoneController.getFrequencyAndCalculateIndexes(for: .B)
        XCTAssertEqual(puretoneController.lastChosenFrequency, 500.0)
        XCTAssertEqual(puretoneController.lastError, "None")
        puretoneController.getFrequencyAndCalculateIndexes(for: .B)
        XCTAssertEqual(puretoneController.lastChosenFrequency, 400.0)
        XCTAssertEqual(puretoneController.lastError, "None")
        puretoneController.getFrequencyAndCalculateIndexes(for: .A)
        XCTAssertEqual(puretoneController.lastChosenFrequency, 400.0)
        XCTAssertEqual(puretoneController.lastError, "None")
        puretoneController.getFrequencyAndCalculateIndexes(for: .B)
        XCTAssertEqual(puretoneController.lastChosenFrequency, 400.0)
        XCTAssertEqual(puretoneController.lastError, "None")
        puretoneController.getFrequencyAndCalculateIndexes(for: .A)
        XCTAssertEqual(puretoneController.lastChosenFrequency, 400.0)
        XCTAssertEqual(puretoneController.lastError, "None")
        puretoneController.getFrequencyAndCalculateIndexes(for: .B)
        XCTAssertEqual(puretoneController.lastChosenFrequency, 400.0)
        XCTAssertEqual(puretoneController.lastError, "None") // no erors
        
        let thirdChosenFrequency = puretoneController.lastChosenFrequency
        
        let hasPredominantFrequency = (firstChosenFrequency == secondChosenFrequency && secondChosenFrequency == thirdChosenFrequency)
        
        XCTAssertEqual(hasPredominantFrequency, true)
    }
    
    // TEST 6 (Convergence, 3 of 3 target = 1250 Hz)
    func testConverge1250() {
        step.roundNumber = 1
        puretoneController = ORKTinnitusPureToneStepViewController(step: step, result: result)
        
        utilities.setupTopLevelUI(withViewController: puretoneController)
        
        /*
         Mid
         Upper
         Lower
         Lower
         Upper
         Lower
         Upper

         */
        
        puretoneController.getFrequencyAndCalculateIndexes(for: .B) // A:5000, B:1000, C:400
        XCTAssertEqual(puretoneController.lastChosenFrequency, 1000.0)
        XCTAssertEqual(puretoneController.lastError, "None")
        puretoneController.getFrequencyAndCalculateIndexes(for: .A) // A:1250, B:1000
        XCTAssertEqual(puretoneController.lastChosenFrequency, 1250.0)
        XCTAssertEqual(puretoneController.lastError, "None")
        puretoneController.getFrequencyAndCalculateIndexes(for: .B) // A:1600, B:1250
        XCTAssertEqual(puretoneController.lastChosenFrequency, 1250.0)
        XCTAssertEqual(puretoneController.lastError, "None")
        puretoneController.getFrequencyAndCalculateIndexes(for: .B) // A:1403, B:1250
        XCTAssertEqual(puretoneController.lastChosenFrequency, 1250.0)
        XCTAssertEqual(puretoneController.lastError, "None")
        puretoneController.getFrequencyAndCalculateIndexes(for: .A) // A:1250, B:1122
        XCTAssertEqual(puretoneController.lastChosenFrequency, 1250.0)
        XCTAssertEqual(puretoneController.lastError, "None")
        puretoneController.getFrequencyAndCalculateIndexes(for: .B) // A:2500, B:1250
        XCTAssertEqual(puretoneController.lastChosenFrequency, 1250.0)
        XCTAssertEqual(puretoneController.lastError, "None")
        puretoneController.getFrequencyAndCalculateIndexes(for: .A) // A:1250, B:630
        XCTAssertEqual(puretoneController.lastChosenFrequency, 1250.0)
        XCTAssertEqual(puretoneController.lastError, "None")
        let firstChosenFrequency = puretoneController.lastChosenFrequency
        
        step.roundNumber = 2
        puretoneController = ORKTinnitusPureToneStepViewController(step: step, result: result)
        
        utilities.setupTopLevelUI(withViewController: puretoneController)
        
        /*
         Mid
         Lower
         Upper
         Lower
         Upper
         Lower
         Upper
         */
        
        puretoneController.getFrequencyAndCalculateIndexes(for: .B) // A:6300, B:1250, C:500
        XCTAssertEqual(puretoneController.lastChosenFrequency, 1250.0)
        XCTAssertEqual(puretoneController.lastError, "None")
        puretoneController.getFrequencyAndCalculateIndexes(for: .B) // A:1600, B:1250
        XCTAssertEqual(puretoneController.lastChosenFrequency, 1250.0)
        XCTAssertEqual(puretoneController.lastError, "None")
        puretoneController.getFrequencyAndCalculateIndexes(for: .A) // A:1250.0, B:1000.0
        XCTAssertEqual(puretoneController.lastChosenFrequency, 1250.0)
        XCTAssertEqual(puretoneController.lastError, "None")
        puretoneController.getFrequencyAndCalculateIndexes(for: .B) // A:1403, B:1250
        XCTAssertEqual(puretoneController.lastChosenFrequency, 1250.0)
        XCTAssertEqual(puretoneController.lastError, "None")
        puretoneController.getFrequencyAndCalculateIndexes(for: .A) // A:1250, B:1122
        XCTAssertEqual(puretoneController.lastChosenFrequency, 1250.0)
        XCTAssertEqual(puretoneController.lastError, "None")
        puretoneController.getFrequencyAndCalculateIndexes(for: .B) // A:2500, B:1250
        XCTAssertEqual(puretoneController.lastChosenFrequency, 1250.0)
        XCTAssertEqual(puretoneController.lastError, "None")
        puretoneController.getFrequencyAndCalculateIndexes(for: .A) // A:1250, B:630
        XCTAssertEqual(puretoneController.lastChosenFrequency, 1250.0)
        XCTAssertEqual(puretoneController.lastError, "None")
        let secondChosenFrequency = puretoneController.lastChosenFrequency
        
        step.roundNumber = 3
        puretoneController = ORKTinnitusPureToneStepViewController(step: step, result: result)
        
        utilities.setupTopLevelUI(withViewController: puretoneController)
        
        /*
         Mid
         Lower
         Lower
         Upper
         Lower
         Upper
         Lower
         Upper

         */
        
        puretoneController.getFrequencyAndCalculateIndexes(for: .B) // A:8000, B:1600, C:630
        XCTAssertEqual(puretoneController.lastChosenFrequency, 1600.0)
        XCTAssertEqual(puretoneController.lastError, "None")
        puretoneController.getFrequencyAndCalculateIndexes(for: .B) // A:2000, B:1600
        XCTAssertEqual(puretoneController.lastChosenFrequency, 1600.0)
        XCTAssertEqual(puretoneController.lastError, "None")
        puretoneController.getFrequencyAndCalculateIndexes(for: .B) // A:1600, B:1250
        XCTAssertEqual(puretoneController.lastChosenFrequency, 1250.0)
        XCTAssertEqual(puretoneController.lastError, "None")
        puretoneController.getFrequencyAndCalculateIndexes(for: .A) // A:1250, B:1000
        XCTAssertEqual(puretoneController.lastChosenFrequency, 1250.0)
        XCTAssertEqual(puretoneController.lastError, "None")
        puretoneController.getFrequencyAndCalculateIndexes(for: .B) // A:1250, B:1122
        XCTAssertEqual(puretoneController.lastChosenFrequency, 1250.0)
        XCTAssertEqual(puretoneController.lastError, "None")
        puretoneController.getFrequencyAndCalculateIndexes(for: .A) // A:2500, B:1250
        XCTAssertEqual(puretoneController.lastChosenFrequency, 1250.0)
        XCTAssertEqual(puretoneController.lastError, "None")
        puretoneController.getFrequencyAndCalculateIndexes(for: .B) // A:1250, B:630
        XCTAssertEqual(puretoneController.lastChosenFrequency, 1250.0)
        XCTAssertEqual(puretoneController.lastError, "None")
        puretoneController.getFrequencyAndCalculateIndexes(for: .A) // A:2500, B:1250
        XCTAssertEqual(puretoneController.lastChosenFrequency, 1250.0)
        XCTAssertEqual(puretoneController.lastError, "None")
        let thirdChosenFrequency = puretoneController.lastChosenFrequency
        
        let hasPredominantFrequency = (firstChosenFrequency == secondChosenFrequency && secondChosenFrequency == thirdChosenFrequency)
        
        XCTAssertEqual(hasPredominantFrequency, true)
    }
    
    // TEST 7 (Convergence, 3 of 3 target = 561 Hz)
    func testConverge561() {
        step.roundNumber = 1
        puretoneController = ORKTinnitusPureToneStepViewController(step: step, result: result)
        
        utilities.setupTopLevelUI(withViewController: puretoneController)
        
        /*
         Low
         Upper
         Lower
         Upper
         Lower
         
         */
        
        puretoneController.getFrequencyAndCalculateIndexes(for: .C) // A:5000, B:1000, C:400
        XCTAssertEqual(puretoneController.lastChosenFrequency, 400.0)
        XCTAssertEqual(puretoneController.lastError, "None")
        puretoneController.getFrequencyAndCalculateIndexes(for: .A) // A:500, B:400
        XCTAssertEqual(puretoneController.lastChosenFrequency, 500.0)
        XCTAssertEqual(puretoneController.lastError, "None")
        puretoneController.getFrequencyAndCalculateIndexes(for: .B) // A:630, B:500
        XCTAssertEqual(puretoneController.lastChosenFrequency, 500.0)
        XCTAssertEqual(puretoneController.lastError, "None")
        puretoneController.getFrequencyAndCalculateIndexes(for: .A) // A:561, B:500
        XCTAssertEqual(puretoneController.lastChosenFrequency, 561.0)
        XCTAssertEqual(puretoneController.lastError, "None")
        puretoneController.getFrequencyAndCalculateIndexes(for: .B) // A:1250, B:561
        XCTAssertEqual(puretoneController.lastChosenFrequency, 561.0)
        XCTAssertEqual(puretoneController.lastError, "None")
        let firstChosenFrequency = puretoneController.lastChosenFrequency
        
        step.roundNumber = 2
        puretoneController = ORKTinnitusPureToneStepViewController(step: step, result: result)
        
        utilities.setupTopLevelUI(withViewController: puretoneController)
        
        /*
         Low
         Upper
         Lower
         Lower
         Lower
         Lower

         */
        
        puretoneController.getFrequencyAndCalculateIndexes(for: .C) // A:6300, B:1250, C:500
        XCTAssertEqual(puretoneController.lastChosenFrequency, 500.0)
        XCTAssertEqual(puretoneController.lastError, "None")
        puretoneController.getFrequencyAndCalculateIndexes(for: .A) // A:630, B:500
        XCTAssertEqual(puretoneController.lastChosenFrequency, 630.0)
        XCTAssertEqual(puretoneController.lastError, "None")
        puretoneController.getFrequencyAndCalculateIndexes(for: .B) // A:800, B:630
        XCTAssertEqual(puretoneController.lastChosenFrequency, 630.0)
        XCTAssertEqual(puretoneController.lastError, "None")
        puretoneController.getFrequencyAndCalculateIndexes(for: .B) // A:707, B:630
        XCTAssertEqual(puretoneController.lastChosenFrequency, 630.0)
        XCTAssertEqual(puretoneController.lastError, "None")
        puretoneController.getFrequencyAndCalculateIndexes(for: .B) // A:630, B:561
        XCTAssertEqual(puretoneController.lastChosenFrequency, 561.0)
        XCTAssertEqual(puretoneController.lastError, "None")
        puretoneController.getFrequencyAndCalculateIndexes(for: .B) // A:1122, B:561
        XCTAssertEqual(puretoneController.lastChosenFrequency, 561.0)
        XCTAssertEqual(puretoneController.lastError, "None")
        let secondChosenFrequency = puretoneController.lastChosenFrequency
        
        step.roundNumber = 3
        puretoneController = ORKTinnitusPureToneStepViewController(step: step, result: result)
        
        utilities.setupTopLevelUI(withViewController: puretoneController)
        
        /*
         Low
         Lower
         Lower
         Upper
         Upper
         Lower
         
         */
        
        puretoneController.getFrequencyAndCalculateIndexes(for: .C) // A:8000, B:1600, C:630
        XCTAssertEqual(puretoneController.lastChosenFrequency, 630.0)
        XCTAssertEqual(puretoneController.lastError, "None")
        puretoneController.getFrequencyAndCalculateIndexes(for: .B) // A:800, B:630
        XCTAssertEqual(puretoneController.lastChosenFrequency, 630.0)
        XCTAssertEqual(puretoneController.lastError, "None")
        puretoneController.getFrequencyAndCalculateIndexes(for: .B) // A:630, B:500
        XCTAssertEqual(puretoneController.lastChosenFrequency, 500.0)
        XCTAssertEqual(puretoneController.lastError, "None")
        puretoneController.getFrequencyAndCalculateIndexes(for: .A) // A:500, B:400
        XCTAssertEqual(puretoneController.lastChosenFrequency, 500.0)
        XCTAssertEqual(puretoneController.lastError, "None")
        puretoneController.getFrequencyAndCalculateIndexes(for: .A) // A:561, B:500
        XCTAssertEqual(puretoneController.lastChosenFrequency, 561.0)
        XCTAssertEqual(puretoneController.lastError, "None")
        puretoneController.getFrequencyAndCalculateIndexes(for: .B) // A:1122, B:561
        XCTAssertEqual(puretoneController.lastChosenFrequency, 561.0)
        XCTAssertEqual(puretoneController.lastError, "None")
        let thirdChosenFrequency = puretoneController.lastChosenFrequency
        
        let hasPredominantFrequency = (firstChosenFrequency == secondChosenFrequency && secondChosenFrequency == thirdChosenFrequency)
        
        XCTAssertEqual(hasPredominantFrequency, true)
    }
    
    // TEST 8 (Convergence, 3 of 3 target = 6300 Hz)
    func testConverge6300() {
        step.roundNumber = 1
        puretoneController = ORKTinnitusPureToneStepViewController(step: step, result: result)
        
        utilities.setupTopLevelUI(withViewController: puretoneController)
        
        /*
         High
         Upper
         Lower
         Lower
         Upper
         Lower
         Upper

         */
        
        puretoneController.getFrequencyAndCalculateIndexes(for: .A) // A:5000, B:1000, C:400
        XCTAssertEqual(puretoneController.lastChosenFrequency, 5000.0)
        XCTAssertEqual(puretoneController.lastError, "None")
        puretoneController.getFrequencyAndCalculateIndexes(for: .A) // A:6300, B:5000
        XCTAssertEqual(puretoneController.lastChosenFrequency, 6300.0)
        XCTAssertEqual(puretoneController.lastError, "None")
        puretoneController.getFrequencyAndCalculateIndexes(for: .B) // A:8000, B:6300
        XCTAssertEqual(puretoneController.lastChosenFrequency, 6300.0)
        XCTAssertEqual(puretoneController.lastError, "None")
        puretoneController.getFrequencyAndCalculateIndexes(for: .B) // A:7072, B:6300
        XCTAssertEqual(puretoneController.lastChosenFrequency, 6300.0)
        XCTAssertEqual(puretoneController.lastError, "None")
        puretoneController.getFrequencyAndCalculateIndexes(for: .A) // A:6300, B:5612
        XCTAssertEqual(puretoneController.lastChosenFrequency, 6300.0)
        XCTAssertEqual(puretoneController.lastError, "None")
        puretoneController.getFrequencyAndCalculateIndexes(for: .B) // A:12500, B:6300
        XCTAssertEqual(puretoneController.lastChosenFrequency, 6300.0)
        XCTAssertEqual(puretoneController.lastError, "None")
        puretoneController.getFrequencyAndCalculateIndexes(for: .A) // A:1250, B:561
        XCTAssertEqual(puretoneController.lastChosenFrequency, 6300.0)
        XCTAssertEqual(puretoneController.lastError, "None")
        let firstChosenFrequency = puretoneController.lastChosenFrequency
        
        step.roundNumber = 2
        puretoneController = ORKTinnitusPureToneStepViewController(step: step, result: result)
        
        utilities.setupTopLevelUI(withViewController: puretoneController)
        
        /*
         High
         Lower
         Upper
         Lower
         Upper
         Lower
         Upper
         
         */
        
        puretoneController.getFrequencyAndCalculateIndexes(for: .A) // A:6300, B:1250, C:500
        XCTAssertEqual(puretoneController.lastChosenFrequency, 6300.0)
        XCTAssertEqual(puretoneController.lastError, "None")
        puretoneController.getFrequencyAndCalculateIndexes(for: .B) // A:8000, B:6300
        XCTAssertEqual(puretoneController.lastChosenFrequency, 6300.0)
        XCTAssertEqual(puretoneController.lastError, "None")
        puretoneController.getFrequencyAndCalculateIndexes(for: .A) // A:6300, B:5000
        XCTAssertEqual(puretoneController.lastChosenFrequency, 6300.0)
        XCTAssertEqual(puretoneController.lastError, "None")
        puretoneController.getFrequencyAndCalculateIndexes(for: .B) // A:7072, B:6300
        XCTAssertEqual(puretoneController.lastChosenFrequency, 6300.0)
        XCTAssertEqual(puretoneController.lastError, "None")
        puretoneController.getFrequencyAndCalculateIndexes(for: .A) // A:6300, B:5612
        XCTAssertEqual(puretoneController.lastChosenFrequency, 6300.0)
        XCTAssertEqual(puretoneController.lastError, "None")
        puretoneController.getFrequencyAndCalculateIndexes(for: .B) // A:12500, B:6300
        XCTAssertEqual(puretoneController.lastChosenFrequency, 6300.0)
        XCTAssertEqual(puretoneController.lastError, "None")
        puretoneController.getFrequencyAndCalculateIndexes(for: .A) // A:6300, B:3150
        XCTAssertEqual(puretoneController.lastChosenFrequency, 6300.0)
        XCTAssertEqual(puretoneController.lastError, "None")
        let secondChosenFrequency = puretoneController.lastChosenFrequency
        
        step.roundNumber = 3
        puretoneController = ORKTinnitusPureToneStepViewController(step: step, result: result)
        
        utilities.setupTopLevelUI(withViewController: puretoneController)
        
        /*
         High
         Lower
         Lower
         Upper
         Lower
         Upper
         Lower
         Upper
         
         */
        
        puretoneController.getFrequencyAndCalculateIndexes(for: .A) // A:8000, B:1600, C:630
        XCTAssertEqual(puretoneController.lastChosenFrequency, 8000.0)
        XCTAssertEqual(puretoneController.lastError, "None")
        puretoneController.getFrequencyAndCalculateIndexes(for: .B) // A:10000, B:8000
        XCTAssertEqual(puretoneController.lastChosenFrequency, 8000.0)
        XCTAssertEqual(puretoneController.lastError, "None")
        puretoneController.getFrequencyAndCalculateIndexes(for: .B) // A:8000, B:6300
        XCTAssertEqual(puretoneController.lastChosenFrequency, 6300.0)
        XCTAssertEqual(puretoneController.lastError, "None")
        puretoneController.getFrequencyAndCalculateIndexes(for: .A) // A:6300, B:400
        XCTAssertEqual(puretoneController.lastChosenFrequency, 6300.0)
        XCTAssertEqual(puretoneController.lastError, "None")
        puretoneController.getFrequencyAndCalculateIndexes(for: .B) // A:7072, B:6300
        XCTAssertEqual(puretoneController.lastChosenFrequency, 6300.0)
        XCTAssertEqual(puretoneController.lastError, "None")
        puretoneController.getFrequencyAndCalculateIndexes(for: .A) // A:6300, B:5612
        XCTAssertEqual(puretoneController.lastChosenFrequency, 6300.0)
        XCTAssertEqual(puretoneController.lastError, "None")
        puretoneController.getFrequencyAndCalculateIndexes(for: .B) // A:12500, B:6300
        XCTAssertEqual(puretoneController.lastChosenFrequency, 6300.0)
        XCTAssertEqual(puretoneController.lastError, "None")
        puretoneController.getFrequencyAndCalculateIndexes(for: .A) // A:6300, B:3150
        XCTAssertEqual(puretoneController.lastChosenFrequency, 6300.0)
        XCTAssertEqual(puretoneController.lastError, "None")
        let thirdChosenFrequency = puretoneController.lastChosenFrequency
        
        let hasPredominantFrequency = (firstChosenFrequency == secondChosenFrequency && secondChosenFrequency == thirdChosenFrequency)
        
        XCTAssertEqual(hasPredominantFrequency, true)
    }
    
    // TEST 9 (Convergence, 2 of 3 target = 8000 Hz)
    func testConverge8000() {
        step.roundNumber = 1
        puretoneController = ORKTinnitusPureToneStepViewController(step: step, result: result)
        
        utilities.setupTopLevelUI(withViewController: puretoneController)
        
        /*
         High
         Upper
         Upper
         Lower
         Lower
         Upper
         Upper
         
         */
        
        puretoneController.getFrequencyAndCalculateIndexes(for: .A) // A:5000, B:1000, C:400
        XCTAssertEqual(puretoneController.lastChosenFrequency, 5000.0)
        XCTAssertEqual(puretoneController.lastError, "None")
        puretoneController.getFrequencyAndCalculateIndexes(for: .A)
        XCTAssertEqual(puretoneController.lastChosenFrequency, 6300.0)
        XCTAssertEqual(puretoneController.lastError, "None")
        puretoneController.getFrequencyAndCalculateIndexes(for: .A)
        XCTAssertEqual(puretoneController.lastChosenFrequency, 8000.0)
        XCTAssertEqual(puretoneController.lastError, "None")
        puretoneController.getFrequencyAndCalculateIndexes(for: .B)
        XCTAssertEqual(puretoneController.lastChosenFrequency, 8000.0)
        XCTAssertEqual(puretoneController.lastError, "None")
        puretoneController.getFrequencyAndCalculateIndexes(for: .B)
        XCTAssertEqual(puretoneController.lastChosenFrequency, 8000.0)
        XCTAssertEqual(puretoneController.lastError, "None")
        puretoneController.getFrequencyAndCalculateIndexes(for: .A)
        XCTAssertEqual(puretoneController.lastChosenFrequency, 8000.0)
        XCTAssertEqual(puretoneController.lastError, "None")
        puretoneController.getFrequencyAndCalculateIndexes(for: .A)
        XCTAssertEqual(puretoneController.lastChosenFrequency, 8000.0)
        XCTAssertEqual(puretoneController.lastError, "None")
        let firstChosenFrequency = puretoneController.lastChosenFrequency
        
        step.roundNumber = 2
        puretoneController = ORKTinnitusPureToneStepViewController(step: step, result: result)
        
        utilities.setupTopLevelUI(withViewController: puretoneController)
        
        /*
         High
         Upper
         Lower
         Lower
         Upper
         Lower (-> 4000)
         
         */
        
        puretoneController.getFrequencyAndCalculateIndexes(for: .A) // A:6300, B:1250, C:500
        XCTAssertEqual(puretoneController.lastChosenFrequency, 6300.0)
        XCTAssertEqual(puretoneController.lastError, "None")
        puretoneController.getFrequencyAndCalculateIndexes(for: .A)
        XCTAssertEqual(puretoneController.lastChosenFrequency, 8000.0)
        XCTAssertEqual(puretoneController.lastError, "None")
        puretoneController.getFrequencyAndCalculateIndexes(for: .B)
        XCTAssertEqual(puretoneController.lastChosenFrequency, 8000.0)
        XCTAssertEqual(puretoneController.lastError, "None")
        puretoneController.getFrequencyAndCalculateIndexes(for: .B)
        XCTAssertEqual(puretoneController.lastChosenFrequency, 8000.0)
        XCTAssertEqual(puretoneController.lastError, "None")
        puretoneController.getFrequencyAndCalculateIndexes(for: .A)
        XCTAssertEqual(puretoneController.lastChosenFrequency, 8000.0)
        XCTAssertEqual(puretoneController.lastError, "None")
        puretoneController.getFrequencyAndCalculateIndexes(for: .B)
        XCTAssertEqual(puretoneController.lastChosenFrequency, 4000.0)
        XCTAssertEqual(puretoneController.lastError, "None")
        let secondChosenFrequency = puretoneController.lastChosenFrequency
        
        step.roundNumber = 3
        puretoneController = ORKTinnitusPureToneStepViewController(step: step, result: result)
        
        utilities.setupTopLevelUI(withViewController: puretoneController)
        
        /*
         High
         Lower
         Upper
         Lower
         Upper
         Upper
         
         */
        
        puretoneController.getFrequencyAndCalculateIndexes(for: .A) // A:8000, B:1600, C:630
        XCTAssertEqual(puretoneController.lastChosenFrequency, 8000.0)
        XCTAssertEqual(puretoneController.lastError, "None")
        puretoneController.getFrequencyAndCalculateIndexes(for: .B) // A:10000, B:8000
        XCTAssertEqual(puretoneController.lastChosenFrequency, 8000.0)
        XCTAssertEqual(puretoneController.lastError, "None")
        puretoneController.getFrequencyAndCalculateIndexes(for: .A) // A:8000, B:6300
        XCTAssertEqual(puretoneController.lastChosenFrequency, 8000.0)
        XCTAssertEqual(puretoneController.lastError, "None")
        puretoneController.getFrequencyAndCalculateIndexes(for: .B)
        XCTAssertEqual(puretoneController.lastChosenFrequency, 8000.0)
        XCTAssertEqual(puretoneController.lastError, "None")
        puretoneController.getFrequencyAndCalculateIndexes(for: .A)
        XCTAssertEqual(puretoneController.lastChosenFrequency, 8000.0)
        XCTAssertEqual(puretoneController.lastError, "None")
        puretoneController.getFrequencyAndCalculateIndexes(for: .A)
        XCTAssertEqual(puretoneController.lastChosenFrequency, 8000.0)
        XCTAssertEqual(puretoneController.lastError, "None")
        let thirdChosenFrequency = puretoneController.lastChosenFrequency
        
        let hasPredominantFrequency = (firstChosenFrequency == secondChosenFrequency || secondChosenFrequency == thirdChosenFrequency || firstChosenFrequency == thirdChosenFrequency)
        
        XCTAssertEqual(hasPredominantFrequency, true)
    }
    
    // TEST 10 (Convergence, 2 of 3 target = 3536  Hz)
    func testConverge3536() {
        step.roundNumber = 1
        puretoneController = ORKTinnitusPureToneStepViewController(step: step, result: result)
        
        utilities.setupTopLevelUI(withViewController: puretoneController)
        
        /*
         High
         Lower
         Lower
         Lower
         Upper
         Upper
         Lower
         Upper
         
         */
        
        puretoneController.getFrequencyAndCalculateIndexes(for: .A) // A:5000, B:1000, C:400
        XCTAssertEqual(puretoneController.lastChosenFrequency, 5000.0)
        XCTAssertEqual(puretoneController.lastError, "None")
        puretoneController.getFrequencyAndCalculateIndexes(for: .B)
        XCTAssertEqual(puretoneController.lastChosenFrequency, 5000.0)
        XCTAssertEqual(puretoneController.lastError, "None")
        puretoneController.getFrequencyAndCalculateIndexes(for: .B)
        XCTAssertEqual(puretoneController.lastChosenFrequency, 4000.0)
        XCTAssertEqual(puretoneController.lastError, "None")
        puretoneController.getFrequencyAndCalculateIndexes(for: .B)
        XCTAssertEqual(puretoneController.lastChosenFrequency, 3150.0)
        XCTAssertEqual(puretoneController.lastError, "None")
        puretoneController.getFrequencyAndCalculateIndexes(for: .A)
        XCTAssertEqual(puretoneController.lastChosenFrequency, 3150.0)
        XCTAssertEqual(puretoneController.lastError, "None")
        puretoneController.getFrequencyAndCalculateIndexes(for: .A)
        XCTAssertEqual(puretoneController.lastChosenFrequency, 3536.0)
        XCTAssertEqual(puretoneController.lastError, "None")
        puretoneController.getFrequencyAndCalculateIndexes(for: .B)
        XCTAssertEqual(puretoneController.lastChosenFrequency, 3536.0)
        XCTAssertEqual(puretoneController.lastError, "None")
        puretoneController.getFrequencyAndCalculateIndexes(for: .A)
        XCTAssertEqual(puretoneController.lastChosenFrequency, 3536.0)
        XCTAssertEqual(puretoneController.lastError, "None")
        let firstChosenFrequency = puretoneController.lastChosenFrequency
        
        
        step.roundNumber = 2
        puretoneController = ORKTinnitusPureToneStepViewController(step: step, result: result)
        
        utilities.setupTopLevelUI(withViewController: puretoneController)
        
        /*
         Mid
         Upper
         Upper
         Upper
         Upper
         Upper
         Lower
         Lower
         Lower
         Lower
         Upper
         
         */
        
        puretoneController.getFrequencyAndCalculateIndexes(for: .B) // A:6300, B:1250, C:500
        XCTAssertEqual(puretoneController.lastChosenFrequency, 1250.0)
        XCTAssertEqual(puretoneController.lastError, "None")
        puretoneController.getFrequencyAndCalculateIndexes(for: .A)
        XCTAssertEqual(puretoneController.lastChosenFrequency, 1600.0)
        XCTAssertEqual(puretoneController.lastError, "None")
        puretoneController.getFrequencyAndCalculateIndexes(for: .A)
        XCTAssertEqual(puretoneController.lastChosenFrequency, 2000.0)
        XCTAssertEqual(puretoneController.lastError, "None")
        puretoneController.getFrequencyAndCalculateIndexes(for: .A)
        XCTAssertEqual(puretoneController.lastChosenFrequency, 2500.0)
        XCTAssertEqual(puretoneController.lastError, "None")
        puretoneController.getFrequencyAndCalculateIndexes(for: .A)
        XCTAssertEqual(puretoneController.lastChosenFrequency, 3150.0)
        XCTAssertEqual(puretoneController.lastError, "None")
        puretoneController.getFrequencyAndCalculateIndexes(for: .A)
        XCTAssertEqual(puretoneController.lastChosenFrequency, 4000.0)
        XCTAssertEqual(puretoneController.lastError, "None")
        puretoneController.getFrequencyAndCalculateIndexes(for: .B)
        XCTAssertEqual(puretoneController.lastChosenFrequency, 4000.0)
        XCTAssertEqual(puretoneController.lastError, "None")
        puretoneController.getFrequencyAndCalculateIndexes(for: .B)
        XCTAssertEqual(puretoneController.lastChosenFrequency, 4000.0)
        XCTAssertEqual(puretoneController.lastError, "None")
        puretoneController.getFrequencyAndCalculateIndexes(for: .B)
        XCTAssertEqual(puretoneController.lastChosenFrequency, 3536.0)
        XCTAssertEqual(puretoneController.lastError, "None")
        puretoneController.getFrequencyAndCalculateIndexes(for: .B)
        XCTAssertEqual(puretoneController.lastChosenFrequency, 3536.0)
        XCTAssertEqual(puretoneController.lastError, "None")
        puretoneController.getFrequencyAndCalculateIndexes(for: .A)
        XCTAssertEqual(puretoneController.lastChosenFrequency, 3536.0)
        XCTAssertEqual(puretoneController.lastError, "None")
        let secondChosenFrequency = puretoneController.lastChosenFrequency
        
        step.roundNumber = 3
        puretoneController = ORKTinnitusPureToneStepViewController(step: step, result: result)
        
        utilities.setupTopLevelUI(withViewController: puretoneController)
        
        /*
         Mid
         Upper
         Upper
         Upper
         Lower
         Lower
         Upper
         Lower
         Upper (-> 3150)
         
         */
        
        puretoneController.getFrequencyAndCalculateIndexes(for: .B) // A:8000, B:1600, C:630
        XCTAssertEqual(puretoneController.lastChosenFrequency, 1600.0)
        XCTAssertEqual(puretoneController.lastError, "None")
        puretoneController.getFrequencyAndCalculateIndexes(for: .A)
        XCTAssertEqual(puretoneController.lastChosenFrequency, 2000.0)
        XCTAssertEqual(puretoneController.lastError, "None")
        puretoneController.getFrequencyAndCalculateIndexes(for: .A)
        XCTAssertEqual(puretoneController.lastChosenFrequency, 2500.0)
        XCTAssertEqual(puretoneController.lastError, "None")
        puretoneController.getFrequencyAndCalculateIndexes(for: .A)
        XCTAssertEqual(puretoneController.lastChosenFrequency, 3150.0)
        XCTAssertEqual(puretoneController.lastError, "None")
        puretoneController.getFrequencyAndCalculateIndexes(for: .B)
        XCTAssertEqual(puretoneController.lastChosenFrequency, 3150.0)
        XCTAssertEqual(puretoneController.lastError, "None")
        puretoneController.getFrequencyAndCalculateIndexes(for: .B)
        XCTAssertEqual(puretoneController.lastChosenFrequency, 3150.0)
        XCTAssertEqual(puretoneController.lastError, "None")
        puretoneController.getFrequencyAndCalculateIndexes(for: .A)
        XCTAssertEqual(puretoneController.lastChosenFrequency, 3150.0)
        XCTAssertEqual(puretoneController.lastError, "None")
        puretoneController.getFrequencyAndCalculateIndexes(for: .B)
        XCTAssertEqual(puretoneController.lastChosenFrequency, 3150.0)
        XCTAssertEqual(puretoneController.lastError, "None")
        puretoneController.getFrequencyAndCalculateIndexes(for: .A)
        XCTAssertEqual(puretoneController.lastChosenFrequency, 3150.0)
        XCTAssertEqual(puretoneController.lastError, "None")
        let thirdChosenFrequency = puretoneController.lastChosenFrequency
        
        let hasPredominantFrequency = (firstChosenFrequency == secondChosenFrequency || secondChosenFrequency == thirdChosenFrequency || firstChosenFrequency == thirdChosenFrequency)
        
        XCTAssertEqual(hasPredominantFrequency, true)
 
    }
    
    // TEST 11 (Convergence, 1 of 3 target = 5000  Hz)
    func testConverge5000() {
        step.roundNumber = 1
        puretoneController = ORKTinnitusPureToneStepViewController(step: step, result: result)
        
        utilities.setupTopLevelUI(withViewController: puretoneController)
        
        /*
         High
         Lower
         Upper
         Lower
         Upper
         Lower
         Upper (->5000)

         
         */
        
        puretoneController.getFrequencyAndCalculateIndexes(for: .A) // A:5000, B:1000, C:400
        XCTAssertEqual(puretoneController.lastChosenFrequency, 5000.0)
        XCTAssertEqual(puretoneController.lastError, "None")
        puretoneController.getFrequencyAndCalculateIndexes(for: .B) // A:6300, B:5000
        XCTAssertEqual(puretoneController.lastChosenFrequency, 5000.0)
        XCTAssertEqual(puretoneController.lastError, "None")
        puretoneController.getFrequencyAndCalculateIndexes(for: .A) // A:5000, B:4000
        XCTAssertEqual(puretoneController.lastChosenFrequency, 5000.0)
        XCTAssertEqual(puretoneController.lastError, "None")
        puretoneController.getFrequencyAndCalculateIndexes(for: .B) // A:5612, B:5000
        XCTAssertEqual(puretoneController.lastChosenFrequency, 5000.0)
        XCTAssertEqual(puretoneController.lastError, "None")
        puretoneController.getFrequencyAndCalculateIndexes(for: .A) // A:5000, B:4490
        XCTAssertEqual(puretoneController.lastChosenFrequency, 5000.0)
        XCTAssertEqual(puretoneController.lastError, "None")
        puretoneController.getFrequencyAndCalculateIndexes(for: .B) // A:10000, B:5000
        XCTAssertEqual(puretoneController.lastChosenFrequency, 5000.0)
        XCTAssertEqual(puretoneController.lastError, "None")
        puretoneController.getFrequencyAndCalculateIndexes(for: .A) // A:5000, B:2500
        XCTAssertEqual(puretoneController.lastChosenFrequency, 5000.0)
        XCTAssertEqual(puretoneController.lastError, "None")
        let firstChosenFrequency = puretoneController.lastChosenFrequency
        
        step.roundNumber = 2
        puretoneController = ORKTinnitusPureToneStepViewController(step: step, result: result)
        
        utilities.setupTopLevelUI(withViewController: puretoneController)
        
        /*
         High
         Lower
         Upper
         Lower
         Upper
         Lower
         Upper (-> 6300)
         
         */
        
        puretoneController.getFrequencyAndCalculateIndexes(for: .A) // A:6300, B:1250, C:500
        XCTAssertEqual(puretoneController.lastChosenFrequency, 6300.0)
        XCTAssertEqual(puretoneController.lastError, "None")
        puretoneController.getFrequencyAndCalculateIndexes(for: .B)
        XCTAssertEqual(puretoneController.lastChosenFrequency, 6300.0)
        XCTAssertEqual(puretoneController.lastError, "None")
        puretoneController.getFrequencyAndCalculateIndexes(for: .A)
        XCTAssertEqual(puretoneController.lastChosenFrequency, 6300.0)
        XCTAssertEqual(puretoneController.lastError, "None")
        puretoneController.getFrequencyAndCalculateIndexes(for: .B)
        XCTAssertEqual(puretoneController.lastChosenFrequency, 6300.0)
        XCTAssertEqual(puretoneController.lastError, "None")
        puretoneController.getFrequencyAndCalculateIndexes(for: .A)
        XCTAssertEqual(puretoneController.lastChosenFrequency, 6300.0)
        XCTAssertEqual(puretoneController.lastError, "None")
        puretoneController.getFrequencyAndCalculateIndexes(for: .B)
        XCTAssertEqual(puretoneController.lastChosenFrequency, 6300.0)
        XCTAssertEqual(puretoneController.lastError, "None")
        let secondChosenFrequency = puretoneController.lastChosenFrequency
        

        step.roundNumber = 3
        puretoneController = ORKTinnitusPureToneStepViewController(step: step, result: result)
        
        utilities.setupTopLevelUI(withViewController: puretoneController)
        
        /*
         High
         Lower
         Lower
         Lower
         Upper
         Lower
         Upper
         Lower
         Lower (->2500)
         
         */
        
        puretoneController.getFrequencyAndCalculateIndexes(for: .A) // A:8000, B:1600, C:630
        XCTAssertEqual(puretoneController.lastChosenFrequency, 8000.0)
        XCTAssertEqual(puretoneController.lastError, "None")
        puretoneController.getFrequencyAndCalculateIndexes(for: .B)
        XCTAssertEqual(puretoneController.lastChosenFrequency, 8000.0)
        XCTAssertEqual(puretoneController.lastError, "None")
        puretoneController.getFrequencyAndCalculateIndexes(for: .B)
        XCTAssertEqual(puretoneController.lastChosenFrequency, 6300.0)
        XCTAssertEqual(puretoneController.lastError, "None")
        puretoneController.getFrequencyAndCalculateIndexes(for: .B)
        XCTAssertEqual(puretoneController.lastChosenFrequency, 5000.0)
        XCTAssertEqual(puretoneController.lastError, "None")
        puretoneController.getFrequencyAndCalculateIndexes(for: .A)
        XCTAssertEqual(puretoneController.lastChosenFrequency, 5000.0)
        XCTAssertEqual(puretoneController.lastError, "None")
        puretoneController.getFrequencyAndCalculateIndexes(for: .B)
        XCTAssertEqual(puretoneController.lastChosenFrequency, 5000.0)
        XCTAssertEqual(puretoneController.lastError, "None")
        puretoneController.getFrequencyAndCalculateIndexes(for: .A)
        XCTAssertEqual(puretoneController.lastChosenFrequency, 5000.0)
        XCTAssertEqual(puretoneController.lastError, "None")
        puretoneController.getFrequencyAndCalculateIndexes(for: .B)
        XCTAssertEqual(puretoneController.lastChosenFrequency, 5000.0)
        XCTAssertEqual(puretoneController.lastError, "None")
        puretoneController.getFrequencyAndCalculateIndexes(for: .B)
        XCTAssertEqual(puretoneController.lastChosenFrequency, 2500.0)
        XCTAssertEqual(puretoneController.lastError, "None")
        let thirdChosenFrequency = puretoneController.lastChosenFrequency
        
        let hasPredominantFrequency = (firstChosenFrequency == secondChosenFrequency || secondChosenFrequency == thirdChosenFrequency || firstChosenFrequency == thirdChosenFrequency)
        
        XCTAssertEqual(hasPredominantFrequency, false)
        
    }
    
    func testMissingLowerOctaveConfusionWithoutErrors() {
        step.roundNumber = 1
        puretoneController = ORKTinnitusPureToneStepViewController(step: step, result: result)
        
        utilities.setupTopLevelUI(withViewController: puretoneController)
        
        var lowerFrequencyLimit:Double = Double(truncating: possibleFrequencies[puretoneController.cFrequencyIndex])
        
        /*
         Low
         Option B (lower)
         Option A (upper)
         Option B (lower)
         Option A (upper)
         Option B (lower)
         */
        puretoneController.getFrequencyAndCalculateIndexes(for: .C)
        XCTAssertEqual(puretoneController.lastChosenFrequency, 400.0)
        XCTAssertEqual(puretoneController.lastError, "None")
        puretoneController.getFrequencyAndCalculateIndexes(for: .B)
        XCTAssertEqual(puretoneController.lastChosenFrequency, 400.0)
        XCTAssertEqual(puretoneController.lastError, "None")
        puretoneController.getFrequencyAndCalculateIndexes(for: .A)
        XCTAssertEqual(puretoneController.lastChosenFrequency, 400.0)
        XCTAssertEqual(puretoneController.lastError, "None")
        puretoneController.getFrequencyAndCalculateIndexes(for: .B)
        XCTAssertEqual(puretoneController.lastChosenFrequency, 400.0)
        XCTAssertEqual(puretoneController.lastError, "None")
        puretoneController.getFrequencyAndCalculateIndexes(for: .A)
        XCTAssertEqual(puretoneController.lastChosenFrequency, 400.0)
        XCTAssertEqual(puretoneController.lastError, "None")
        puretoneController.getFrequencyAndCalculateIndexes(for: .B)
        XCTAssertEqual(puretoneController.lastChosenFrequency, 400.0)
        XCTAssertEqual(puretoneController.lastError, "None")
        let firstChosenFrequency = puretoneController.lastChosenFrequency;
        XCTAssertEqual(firstChosenFrequency, lowerFrequencyLimit)
        
        puretoneController = ORKTinnitusPureToneStepViewController(step: step, result: result)
        
        utilities.setupTopLevelUI(withViewController: puretoneController)
        
        lowerFrequencyLimit = Double(truncating: possibleFrequencies[puretoneController.cFrequencyIndex])
        
        /*
         Low
         Option A (upper)
         Option B (lower)
         Option A (upper)
         Option B (lower)
         */
        puretoneController.getFrequencyAndCalculateIndexes(for: .C)
        XCTAssertEqual(puretoneController.lastChosenFrequency, 400.0)
        XCTAssertEqual(puretoneController.lastError, "None")
        puretoneController.getFrequencyAndCalculateIndexes(for: .A)
        XCTAssertEqual(puretoneController.lastChosenFrequency, 500.0)
        XCTAssertEqual(puretoneController.lastError, "None")
        puretoneController.getFrequencyAndCalculateIndexes(for: .B)
        XCTAssertEqual(puretoneController.lastChosenFrequency, 500.0)
        XCTAssertEqual(puretoneController.lastError, "None")
        puretoneController.getFrequencyAndCalculateIndexes(for: .A)
        XCTAssertEqual(puretoneController.lastChosenFrequency, 561.0)
        XCTAssertEqual(puretoneController.lastError, "None")
        puretoneController.getFrequencyAndCalculateIndexes(for: .B)
        XCTAssertEqual(puretoneController.lastChosenFrequency, 561.0)
        XCTAssertEqual(puretoneController.lastError, "None")
    }
    
    func testInitialVariables() {
        step.roundNumber = 1;
        puretoneController = ORKTinnitusPureToneStepViewController(step: step, result: result)
       
        utilities.setupTopLevelUI(withViewController: puretoneController)

        let lowerThresholdIndex: Int = -1
        let higherThresholdIndex: Int = -1
        let indexOffset:Int = 2;
        var lowerFrequency = possibleFrequencies[puretoneController.cFrequencyIndex]
        var middleFrequency = possibleFrequencies[puretoneController.bFrequencyIndex]
        var higherFrequency = possibleFrequencies[puretoneController.aFrequencyIndex]
        
        XCTAssertEqual(puretoneController.frequencies, possibleFrequencies)
        XCTAssertEqual(puretoneController.lowerThresholdIndex, lowerThresholdIndex)
        XCTAssertEqual(puretoneController.higherThresholdIndex, higherThresholdIndex)
        XCTAssertEqual(puretoneController.indexOffset, indexOffset)
        XCTAssertEqual(lowerFrequency, 400.0)
        XCTAssertEqual(middleFrequency, 1000.0)
        XCTAssertEqual(higherFrequency, 5000.0)

        step = ORKTinnitusPureToneStep(identifier: "STEP")
        step.roundNumber = 2;

        puretoneController = ORKTinnitusPureToneStepViewController(step: step, result: result)
        
        utilities.setupTopLevelUI(withViewController: puretoneController)
        
        lowerFrequency = possibleFrequencies[puretoneController.cFrequencyIndex]
        middleFrequency = possibleFrequencies[puretoneController.bFrequencyIndex]
        higherFrequency = possibleFrequencies[puretoneController.aFrequencyIndex]
        
        XCTAssertEqual(lowerFrequency, 500.0)
        XCTAssertEqual(middleFrequency, 1250.0)
        XCTAssertEqual(higherFrequency, 6300.0)
        
        step = ORKTinnitusPureToneStep(identifier: "STEP")
        step.roundNumber = 3;
        
        puretoneController = ORKTinnitusPureToneStepViewController(step: step, result: result)
        
        utilities.setupTopLevelUI(withViewController: puretoneController)
        
        lowerFrequency = possibleFrequencies[puretoneController.cFrequencyIndex]
        middleFrequency = possibleFrequencies[puretoneController.bFrequencyIndex]
        higherFrequency = possibleFrequencies[puretoneController.aFrequencyIndex]
        
        XCTAssertEqual(lowerFrequency, 630.0)
        XCTAssertEqual(middleFrequency, 1600.0)
        XCTAssertEqual(higherFrequency, 8000.0)
    }
}
