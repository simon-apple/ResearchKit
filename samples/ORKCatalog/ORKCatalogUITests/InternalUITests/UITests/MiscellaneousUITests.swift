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

final class MiscellaneousUITests: BaseUITest {
    
    let tasksList = TasksTab()
    
    override func setUpWithError() throws {
        
        try super.setUpWithError()
        // Verify that before we start our test we are on Tasks tab
        tasksList
            .assertTitle()
    }
    
    func testPDFViewerStep() {
        tasksList
            .selectTaskByName(Task.PDFViewer.description)
        let pdfStep = PDFViewerStepScreen()
        pdfStep
            .verifyStepView()
            .verify(.showPDFThumbnailActionButton, exists: true)
            .verify(.annotationActionButton, exists: true)
            .verify(.showSearchActionButton, exists: true)
            .verify(.shareActionButton, exists: true)
            .verify(.continueButton, isEnabled: true)
            .tap(.continueButton)
    }
    
    /// rdar://tsc/21847966 ([Survey Questions] Wait Step)
    func testWaitStep() {
        tasksList
            .selectTaskByName(Task.wait.description)
        
        let step = WaitStepScreen()
        step
            .verifyActivityIndicator(exists: true) // Step 1
            .verifyProgressIndicator(exists: true) // Step 2
    }
    
    func testWebView() {
        tasksList
            .selectTaskByName(Task.webView.description)
        let webView = WebViewStepScreen()
        webView
            .verifyView() // Wait for web view to load
        app.swipeUp() // Accelerate scrolling up, a preparatory step for next method
        webView
            .scrollUpToSignatureView()
            .verify(.continueButton, isEnabled: false)
            .drawSignature()
            .verify(.continueButton, isEnabled: true)
            .tap(.continueButton)
    }
}
