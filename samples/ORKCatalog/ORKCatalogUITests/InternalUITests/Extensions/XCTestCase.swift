//  XCTestCase.swift
//  ORKCatalogUITests
//
//  Created by Albina Kashapova on 10/25/23.
//  Copyright © 2023 researchkit.org. All rights reserved.
//

import Foundation
import XCTest

extension XCTestCase {
    /// This method improves test and xcresult test report readability when lot's of verifications required
    func test(_ description: String, block: () throws -> Void) rethrows {
        try XCTContext.runActivity(named: description, block: { _ in try block() })
    }
}
