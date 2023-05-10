//
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


final class ORKFormStepViewControllerConditionalFormItemsTests: XCTestCase {

    static let SectionTitle = "This is a Section"

    private var formStepViewController: ORKFormStepViewController!
    
    override func setUp() {
        let step = ORKFormStep(identifier: "test-form-step")
        step.formItems = [
            ORKFormItem(sectionTitle: Self.SectionTitle), // section should not be answerable
            ORKFormItem(identifier: "item1", text:"none", answerFormat: .booleanAnswerFormat(), optional: true),
            ORKFormItem(identifier: "item2", text: "text", answerFormat: ORKTextAnswerFormat()),
            ORKFormItem(identifier: "item3", text: "more text", answerFormat: ORKTextAnswerFormat())
        ]
        formStepViewController = ORKFormStepViewController(step: step)
    }
        
    // [RDLS:TODO] update this once visibleFormItems is implemented fully
    // - What you'd expect is that
    //      - allFormItems has all the formItems, even ones that were just section formItems
    //      - visibleFormItems has all the formItems. At this point really testing that this doesn't crash in infinite recursion from calling _delegate_ongoingTaskResult in visibleFormItems implementation
    //      - allFormItems has all the visibleFormItems but not the section formItems

    func testFormItemsAccessors() throws {
        let formStepVC = formStepViewController!
        
        let allFormItems = formStepVC.allFormItems()
        let visibleFormItems = formStepVC.visibleFormItems()
        let answerableFormItems = formStepVC.answerableFormItems()

        XCTAssertEqual(allFormItems, visibleFormItems, "all formItems should be visible")

        XCTAssertEqual(answerableFormItems.count, visibleFormItems.count - 1, "there's one formItem that shouldn't be answerable")
        XCTAssertEqual(visibleFormItems[0].text, Self.SectionTitle, "Expected the first visible formItem to be an unanswerable section formItem with text")
    }
    
    func testEmptyTaskResult() throws {

        let mainTask = ORKOrderedTask(identifier: "mainTaskIdentifier", steps: [
            ORKQuestionStep(identifier: "SimpleQuestion", title: nil, question: nil, answer: .booleanAnswerFormat()),
            formStepViewController!.step! // reuse the existing step
        ])
        let mainTaskVC = ORKTaskViewController(task: mainTask, taskRun: nil)
        
        // go to the first step to generate results
        mainTaskVC.flipToPage(withIdentifier: "SimpleQuestion", forward: true, animated: false)

        // generate results for the formStep
        mainTaskVC.flipToPage(withIdentifier: "test-form-step", forward: true, animated: false)

        // test that the taskViewController.result contains everything, including formStep results
        do {
            let result = mainTaskVC.result
            XCTAssertEqual(result.results?.count, 2)
            
            let simpleQuestionResult = result.results?[0] as? ORKStepResult
            XCTAssertEqual(simpleQuestionResult?.identifier, "SimpleQuestion")
            
            let formStepResult = result.results?[1] as? ORKStepResult
            XCTAssertEqual(formStepResult?.identifier, "test-form-step")
            XCTAssertEqual(formStepResult?.results?.count, 3, "expected to have 3 results in the formStep stepResult")

            // because we forcibly skipped to the viewController without answering, all the answers should be nil
            do {
                let formItemResult = formStepResult?.results?[0] as? ORKBooleanQuestionResult
                XCTAssertEqual(formItemResult?.booleanAnswer, nil)
            }

            do {
                let formItemResult = formStepResult?.results?[1] as? ORKTextQuestionResult
                XCTAssertEqual(formItemResult?.textAnswer, nil)
            }

            do {
                let formItemResult = formStepResult?.results?[2] as? ORKTextQuestionResult
                XCTAssertEqual(formItemResult?.textAnswer, nil)
            }

        }

        // formStepViewController's delegate hook should provide results for *only* the question step
        do {
            let formStepViewController = mainTaskVC.currentStepViewController as? ORKFormStepViewController
            let result = formStepViewController?._delegate_ongoingTaskResult()
            XCTAssertEqual(result?.results?.count, 1)
            XCTAssertEqual(result?.results?[0].identifier, "SimpleQuestion")
        }
    }

}
