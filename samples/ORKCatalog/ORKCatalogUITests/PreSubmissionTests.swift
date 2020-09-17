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

    func testWrittenMultipleChoice() throws {
        XCTAssert(helpers.verifyElement(taskScreen.mainTaskScreen))
        let options = ["Choice 1", "Choice 2", "Choice 3", "Other"]
        let task = app.tables.staticTexts["Text Choice Question"]
        let required = ["Text Choice", "Additional text can go here.", "Your question here."]
        
        XCTAssert(task.exists, "Unable to find \(task) element")
        task.tap()
        
        for item in required {
            XCTAssert(app.tables.staticTexts[item].exists, "Unable to locate the \(item) element.")
        }
        
        let choice = app.tables.staticTexts[options.randomElement()!]
        XCTAssert(choice.exists, "Unable to find \(choice) element")
        choice.tap()

        guard let done = commonElements.doneButton else {
            XCTFail("Unable to find the Done button")
            return
        }
        done.tap()
        return
    }
    
    func testImageMultipleChoice() throws {
        XCTAssert(helpers.verifyElement(taskScreen.mainTaskScreen))
        
        let task = app.tables.staticTexts["Image Choice Question"]
        XCTAssert(task.exists, "Unable to find \(task) element")
        task.tap()
        
        let required = ["Image Choice", "Additional text can go here."]
        for item in required {
            XCTAssert(app.scrollViews.staticTexts[item].exists, "Unable to locate the \(item) element.")
        }
        
        let square = app.buttons["Square Shape"]
        let circle = app.buttons["Round Shape"]
        
        XCTAssert(square.exists)
        XCTAssert(circle.exists)
        
        square.tap()
        
        guard let next = commonElements.nextButton else {
            XCTFail("Unable to locate the Next button")
            return
        }
        
        next.tap()
        
        XCTAssert(app.navigationBars["2 of 2"].exists)
        
        guard let back = commonElements.backButton else {
            XCTFail("Unable to locate the Back Button")
            return
        }
        back.tap()
        
        XCTAssert(app.navigationBars["1 of 2"].exists)
        square.tap()
        next.tap()
        XCTAssertFalse(app.navigationBars["2 of 2"].exists)
        
        circle.tap()
        next.tap()
        
        XCTAssert(app.navigationBars["2 of 2"].exists)
        
        square.tap()
        circle.tap()
        
        guard let done = commonElements.doneButton else {
            XCTFail("Unable to locate Done button")
            return
        }
        done.tap()
        
        XCTAssert(helpers.verifyElement(taskScreen.mainTaskScreen))
        return
    }
  
    func testSQPickerWheel() throws {
        XCTAssert(helpers.verifyElement(taskScreen.mainTaskScreen))
        
        let dateTimeElement = app.tables.staticTexts["Date and Time Question"]
        let elementsQuery = app.scrollViews.otherElements.staticTexts
        
        dateTimeElement.tap()
        XCTAssert(elementsQuery["Date and Time"].exists)
        XCTAssert(elementsQuery["Additional text can go here."].exists)
        XCTAssert(elementsQuery["Your question here."].exists)
        
        guard let skip = commonElements.skipButton else {
            XCTFail("Unable to locate Skip butotn")
            return
        }
        XCTAssert(skip.isEnabled)
        
        guard let done = commonElements.doneButton else {
            XCTFail("Unable to locate Done button")
            return
        }
        XCTAssert(done.isEnabled)
        
        let firstPredicate = NSPredicate(format: "value BEGINSWITH 'Today'")
        let firstPicker = app.pickerWheels.element(matching: firstPredicate)
        XCTAssert(firstPicker.isEnabled)
        firstPicker.adjust(toPickerWheelValue: "Aug 25")
        
        let secondPredicate = NSPredicate(format: "value CONTAINS 'clock'")
        let secondPicker = app.pickerWheels.element(matching: secondPredicate)
        XCTAssert((secondPicker.isEnabled))
        secondPicker.adjust(toPickerWheelValue: "5")
        
        let thirdPredicatre = NSPredicate(format: "value CONTAINS 'minute'")
        let thirdPicker = app.pickerWheels.element(matching: thirdPredicatre)
        XCTAssert(thirdPicker.isEnabled)
        thirdPicker.adjust(toPickerWheelValue: "23")
        
        let now = Date()
        let formatter = DateFormatter()
        formatter.setLocalizedDateFormatFromTemplate("a")
        let datetime = formatter.string(from: now)
        
        let fourthPredicate = NSPredicate(format: "value CONTAINS '\(datetime)'")
        let fourthPicker = app.pickerWheels.element(matching: fourthPredicate)
        XCTAssert(fourthPicker.isEnabled)
        if datetime == "AM" {
            fourthPicker.adjust(toPickerWheelValue: "PM")
        } else {
            fourthPicker.adjust(toPickerWheelValue: "AM")
        }
        
        XCTAssert(done.isEnabled)
        done.tap()
        XCTAssert(helpers.verifyElement(taskScreen.mainTaskScreen))
        
        dateTimeElement.tap()
        skip.tap()
        XCTAssert(helpers.verifyElement(taskScreen.mainTaskScreen))
    
        return
    }
}
