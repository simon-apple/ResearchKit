//  UITestLogger.swift
//  ORKCatalogUITests
//
//  Created by Albina Kashapova on 2/21/24.
//  Copyright © 2024 researchkit.org. All rights reserved.
//

import os
import os.log
import Foundation

struct UITestLogger {
    static func logDebugMessage(_ message: String) {
        if #available(iOS 14.0, *) {
            let logger = Logger(subsystem: "ORKCatalogUITests", category: "ORKCatalogUIAutomation")
            logger.debug("\(message)")
        } else {
            os_log("%@", log: OSLog.default, type: .debug, message)
        }
    }
}
