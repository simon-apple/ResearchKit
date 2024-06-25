/*
 Copyright (c) 20202415, Apple Inc. All rights reserved.
 
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

class LocaleDependentBaseUITests: BaseUITest {
    
    let tasksList = TasksTab()
    var measurementSystem: String = ""
    var hourCycle: String = ""
    var dismissPicker = false
    var isUSTimeZone = true
    
    let metricSignature = "metric"
    let usSignature = "ussystem"
    let continentalTimeSignature = "h23"
    let usTimeSignature = "h12"
    
    /// rdar://111132091 ([Modularization] [ORKCatalog] Date Picker won't display on the question card)
    /// This issue required extra button tap to dismiss picker to continue
    let shouldUseUIPickerWorkaround = true
    
    let expectingNonOptionalStep = false
    
    override func setUpWithError() throws {
        /// Start with clean state. Reset authorization status for health and location
        app.resetAuthorizationStatus(for: .location)
        if #available(iOS 14.0, *) { app.resetAuthorizationStatus(for: .health) }
        
        if #available(iOS 16, *) {
            measurementSystem = String(Locale.current.measurementSystem.identifier) // "ussystem" or "metric"
            hourCycle = String(Locale.current.hourCycle.rawValue) // "h12" or "h23"
        } else {
            measurementSystem = usSignature
            hourCycle = usTimeSignature
        }
        isUSTimeZone = hourCycle == usTimeSignature ? true : false
        
        try super.setUpWithError()
        // Verify that before we start our test we are on Tasks tab
        tasksList
            .assertTitle()
    }
    
    override func tearDownWithError() throws {
        if testRun?.hasSucceeded == false {
            return
        }
        // Verify that after test is completed, we end up on Tasks tab
        tasksList
            .assertTitle()
    }
}
