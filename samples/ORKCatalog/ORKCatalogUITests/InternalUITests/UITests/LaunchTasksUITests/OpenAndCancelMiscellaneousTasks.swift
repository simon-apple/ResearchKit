//  OpenAndCancelMiscellaneousTasks.swift
//  ORKCatalogUITests
//
//  Created by Albina Kashapova on 2/7/24.
//  Copyright © 2024 researchkit.org. All rights reserved.
//

import Foundation
import XCTest

final class OpenAndCancelMiscellaneousTasks: OpenAndCancelBaseUITest {
    
    func testLaunchImageCaptureTask() {
        openThenCancel(task: Task.imageCapture.description)
    }
    
    func testLaunchFrontFacingCameraTask() {
        openThenCancel(task: Task.frontFacingCamera.description)
    }
    
    func testLaunchVideoCaptureTask() {
        openThenCancel(task: Task.videoCapture.description)
    }
    
    func testLaunchVideoInstructionTask() {
        openThenCancel(task: Task.videoInstruction.description)
    }
}
