//  MiscellaneousUITests.swift
//  ORKCatalogUITests
//
//  Created by Albina Kashapova on 2/26/24.
//  Copyright © 2024 researchkit.org. All rights reserved.
//

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
