//  BaseUITest.swift
//  ORKCatalogUITests
//
//  Created by Albina Kashapova on 10/25/23.
//  Copyright © 2023 researchkit.org. All rights reserved.
//

import Foundation
import XCTest

class BaseUITest: XCTestCase {
    let app = XCUIApplication()
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        Helpers().monitorAlerts()
        app.launchArguments = ["UITest"]
        app.launch()
    }
}
