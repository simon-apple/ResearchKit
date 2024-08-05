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

// MARK: - Slider Values

let formStepsSliderValues: [(minValue: Double, midValue: Double, maxValue: Double)] = [(1, 6, 10), (0, 50, 100), (1, 6, 10), (1, 3, 5), (1, 3, 5), (1, 3, 5)]
let formStepsSliderResultValues: [(minValue: String, midValue: String, maxValue: String)] = [("1", "6",  "10"), ("0", "0.5", "1"), ("1", "6", "10"), ("1", "3", "5"), ("[1]", "[3]", "[5]"), ("[1]", "[3]", "[5]")]
let defaultStep: Double = 1
let textValues = ["Poor", "Fair", "Good", "Above Average", "Excellent"]

// MARK: - Value Picker Choices
// Value picker choices are based on textChoicesExample in ORKCatalog/TaskListRowSteps.swift

let textChoices: [(text: String, value: String)] = [("Poor", "[1]"), ("Fair", "[2]") , ("Good", "[3]"), ("Above Average", "[10]"), ("Excellent", "[5]")]
let textChoicesMaxValueIndex = textChoices.count - 1
let textChoicesMinValueIndex = 0
