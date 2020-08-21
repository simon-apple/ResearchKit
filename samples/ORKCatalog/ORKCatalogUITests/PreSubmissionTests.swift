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

class PreSubmissionTests: XCTestCase {
    let app = XCUIApplication()
    let commonElements = CommonElements()
    let allowScreens = AllowScreens()
    let helpers = Helpers()
    let taskScreen = TaskScreen()
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        helpers.monitorAlerts()
        app.launch()
        
        
        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        //helpers.deleteORKCatalog()
    }
    
    func testAccessSurveyTasks() throws {
        XCTAssert(helpers.verifyElement(taskScreen.mainTaskScreen))
        
        for task in taskScreen.surveyTasks {
            XCTAssert(helpers.launchAndLeave(task))
        }
    }
    
    func testAccessSurveyQuestions() throws {
        XCTAssert(allowScreens.triggerAllowScreens())
        
        for task in taskScreen.surveyQuestions {
            XCTAssert(helpers.launchAndLeave(task))
        }
        
        return
    }
    
    func testAccessActiveTasks() throws {
        XCTAssert(helpers.verifyElement(taskScreen.mainTaskScreen))
        
        for task in taskScreen.activeTasks {
            XCTAssert(helpers.launchAndLeave(task))
        }
        
        return
    }

}
