//  Answers.swift
//  ORKCatalogUITests
//
//  Created by Albina Kashapova on 11/17/23.
//  Copyright © 2023 researchkit.org. All rights reserved.
//

import Foundation

struct Answers {
    static let loremIpsumText = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua."
    static let loremIpsumOneLineText = "Lorem ipsum dolor"
    static let loremIpsumShortText = "Lorem ipsum dolor sit amet, consectetur adipiscing elit."
    static let loremIpsumMediumText = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nam adhuc, meo fortasse vitio, quid ego quaeram non perspicis. Plane idem, inquit, et maxima quidem, qua fieri nulla maior potest. Quonam, inquit, modo?"
    static let loremIpsumLongText = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nam adhuc, meo fortasse vitio, quid ego quaeram non perspicis. Plane idem, inquit, et maxima quidem, qua fieri nulla maior potest. Quonam, inquit, modo? An potest, inquit ille, quicquam esse suavius quam nihil dolere? Cave putes quicquam esse verius. Quonam, inquit, modo?"
    
    static let exampleValidEmail = "user@example.com"
    static let exampleEmailCapitalized = "User@example.com"
    static let exampleDomainName = "apple.com"
    static let exampleTextPassword = "password"
    static let passwordAlphabeticPart = "pass"
    static let passwordNumericPart = 123
}

// Value picker choices are based on textChoicesExample in ORKCatalog/TaskListRowSteps.swift
let textChoices: [(text: String, value: String)] = [("Poor", "[1]"), ("Fair", "[2]") , ("Good", "[3]"), ("Above Average", "[10]"), ("Excellent", "[5]")]
