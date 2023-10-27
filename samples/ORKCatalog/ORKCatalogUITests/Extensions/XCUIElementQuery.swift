//
//  XCUIElementQuery.swift
//  ORKCatalogUITests
//
//  Created by Albina Kashapova on 10/25/23.
//  Copyright © 2023 researchkit.org. All rights reserved.
//

import Foundation
import XCTest

extension XCUIElementQuery {
    
    /// Return a new query that matches all elements with the specific identifier that begins with the given prefix
    func beginning(with prefix: String) -> XCUIElementQuery {
        return matching(NSPredicate(format: "identifier BEGINSWITH %@", prefix))
    }
    
    /// Return a new query that matches all elements with the specific identifier that ends with the given suffix
    func ending(with suffix: String) -> XCUIElementQuery {
        return matching(NSPredicate(format: "identifier ENDSWITH %@", suffix))
    }
}
