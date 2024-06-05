//  SurveyQuestionsLocaleDependentUITests.swift
//  ORKCatalogUITests
//
//  Created by Albina Kashapova on 1/10/24.
//  Copyright © 2024 researchkit.org. All rights reserved.
//

import Foundation
import XCTest

final class SurveyQuestionsLocaleDependentUITests: LocaleDependentBaseUITests {
    
    /// <rdar://tsc/21847950> [Survey Questions] Height Question
    func testHeightQuestion() {
        tasksList
            .selectTaskByName(Task.heightQuestion.description)
        
        let healthAccessScreen = HealthAccess()
        healthAccessScreen
            .verifyHealthAuthorizationView(exists: true)
            .tapAllowToRead(for: .height)
            .tapAllowButton()
        
        let heightMetricAnswer = 170
        let heightUSAnswerFeet = 5
        let heightUSAnswerInches = 7
        
        // Task consists of following steps: localSystem, localSystemNonOptional, metricSystem, metricSystemNonOptional, USCSystem, USCSystemNonOptional, healthKitHeight
        let questionStep = FormStepScreen()
        let formItemId = "heightQuestionFormItem1"
        // Local system Optional Question
        questionStep
            .verify(.title)
            .verify(.text)
            .verify(.skipButton)
            .verify(.skipButton, isEnabled: true)
            .verify(.continueButton, isEnabled: true)
            .verifySingleQuestionTitleExists()
        
        if shouldUseUIPickerWorkaround {
            questionStep.selectFormItemCell(withID: formItemId)
            dismissPicker = true
        }
        
        if measurementSystem == metricSignature {
            questionStep.answerHeighQuestion(cm: heightMetricAnswer, dismissPicker: dismissPicker)
        } else if measurementSystem == usSignature {
            questionStep.answerHeighQuestion(feet: heightUSAnswerFeet, inches: heightUSAnswerInches, dismissPicker: dismissPicker)
        }
        questionStep
            .verify(.continueButton, isEnabled: true)
            .tap(.continueButton)
        
        if expectingNonOptionalStep {
            // Local system NonOptional Question
            questionStep
                .verify(.title)
                .verify(.text)
                .verify(.skipButton, exists: false)
                .verify(.continueButton, isEnabled: false)
                .verifySingleQuestionTitleExists()
            
            if shouldUseUIPickerWorkaround {
                questionStep.selectFormItemCell(withID: formItemId)
                dismissPicker = true
            }
            
            if measurementSystem == metricSignature {
                questionStep.answerHeighQuestion(cm: heightMetricAnswer, dismissPicker: dismissPicker)
            } else if measurementSystem == usSignature {
                questionStep.answerHeighQuestion(feet: heightUSAnswerFeet, inches: heightUSAnswerInches, dismissPicker: dismissPicker)
            }
            questionStep
                .verify(.continueButton, isEnabled: true)
                .tap(.continueButton)
        }
        
        // Metric system Optional Question
        questionStep
            .verify(.title)
            .verify(.text)
            .verify(.skipButton)
            .verify(.skipButton, isEnabled: true)
            .verify(.continueButton, isEnabled: true)
            .verifySingleQuestionTitleExists()
        
        if shouldUseUIPickerWorkaround {
            questionStep.selectFormItemCell(withID: formItemId)
            dismissPicker = true
        }
        
        questionStep
            .answerHeighQuestion(cm: heightMetricAnswer, dismissPicker: dismissPicker)
            .verify(.continueButton, isEnabled: true)
            .tap(.continueButton)
        
        if expectingNonOptionalStep {
            // Metric system NonOptional Question
            questionStep
                .verify(.title)
                .verify(.text)
                .verify(.skipButton, exists: false)
                .verify(.continueButton, isEnabled: false)
                .verifySingleQuestionTitleExists()
            
            if shouldUseUIPickerWorkaround {
                questionStep.selectFormItemCell(withID: formItemId)
                dismissPicker = true
            }
            
            questionStep
                .answerHeighQuestion(cm: heightMetricAnswer, dismissPicker: dismissPicker)
                .verify(.continueButton, isEnabled: true)
                .tap(.continueButton)
        }
        
        // USCSystem system Optional Question
        questionStep
            .verify(.title)
            .verify(.text)
            .verify(.skipButton)
            .verify(.skipButton, isEnabled: true)
            .verify(.continueButton, isEnabled: true)
            .verifySingleQuestionTitleExists()
        
        if shouldUseUIPickerWorkaround {
            questionStep.selectFormItemCell(withID: formItemId)
            dismissPicker = true
        }
        
        questionStep
            .answerHeighQuestion(feet: heightUSAnswerFeet, inches: heightUSAnswerInches, dismissPicker: dismissPicker)
            .verify(.continueButton, isEnabled: true)
            .tap(.continueButton)
        
        if expectingNonOptionalStep {
            // USCSystem system NonOptional Question
            questionStep
                .verify(.title)
                .verify(.text)
                .verify(.skipButton, exists: false)
                .verify(.continueButton, isEnabled: false)
                .verifySingleQuestionTitleExists()
            
            if shouldUseUIPickerWorkaround {
                questionStep.selectFormItemCell(withID: formItemId)
                dismissPicker = true
            }
            
            questionStep
                .answerHeighQuestion(feet: heightUSAnswerFeet, inches: heightUSAnswerInches, dismissPicker: dismissPicker)
                .verify(.continueButton, isEnabled: true)
                .tap(.continueButton)
        }
        
        if expectingNonOptionalStep {
            // HealthKit integration NonOptional
            // TODO: rdar://118141808 (Height/Weight Questions should prefill with HealthKit value)
            questionStep
                .verify(.title)
                .verify(.text)
                .verify(.skipButton, exists: false)
                .verify(.continueButton, isEnabled: false)
                .verifySingleQuestionTitleExists()
            
            if shouldUseUIPickerWorkaround {
                questionStep.selectFormItemCell(withID: formItemId)
                dismissPicker = true
            }
            
            if measurementSystem == metricSignature {
                questionStep.answerHeighQuestion(cm: heightMetricAnswer, dismissPicker: dismissPicker)
            } else if measurementSystem == usSignature {
                questionStep.answerHeighQuestion(feet: heightUSAnswerFeet, inches: heightUSAnswerInches, dismissPicker: dismissPicker)
            }
            questionStep
                .verify(.continueButton, isEnabled: true)
                .tap(.continueButton)
        }
        
        // HealthKit integration Optional
        // TODO: rdar://118141808 (Height/Weight Questions should prefill with HealthKit value)
        questionStep
            .verify(.title)
            .verify(.text)
            .verify(.skipButton)
            .verify(.skipButton, isEnabled: true)
            .verify(.continueButton, isEnabled: true)
            .verifySingleQuestionTitleExists()
        
        if shouldUseUIPickerWorkaround {
            questionStep.selectFormItemCell(withID: formItemId)
            dismissPicker = true
        }
        
        if measurementSystem == metricSignature {
            questionStep.answerHeighQuestion(cm: heightMetricAnswer, dismissPicker: dismissPicker)
        } else if measurementSystem == usSignature {
            questionStep.answerHeighQuestion(feet: heightUSAnswerFeet, inches: heightUSAnswerInches, dismissPicker: dismissPicker)
        }
        questionStep
            .verify(.continueButton, isEnabled: true)
            .tap(.continueButton)
        
        let resultsTab = TabBar().navigateToResults()
   
        let expectedHeightInCentimeters = feetAndInchesToCentimeters(feet: Double(heightUSAnswerFeet), inches: Double(heightUSAnswerInches))
        
        // result 1
        resultsTab
            .selectResultsCell(withId: String(describing: Identifier.heightQuestionFormStep1))
            .selectResultsCell(withId: formItemId)
        
        if measurementSystem == metricSignature {
            resultsTab.verifyResultsCellValue(resultType: .numericAnswer, expectedValue: "\(heightMetricAnswer)")
        } else if measurementSystem == usSignature {
            resultsTab.verifyResultsCellValue(resultType: .numericAnswer, expectedValue: "\(expectedHeightInCentimeters)")
        }
        
        resultsTab
            .verifyResultsCellValue(resultType: .unit, expectedValue: "cm")
            .verifyResultsCellValue(resultType: .displayUnit, expectedValue: "nil")
            .navigateToResultsStepBack()
            .navigateToResultsStepBack()
            
        // result 2
        resultsTab
            .selectResultsCell(withId: String(describing: Identifier.heightQuestionFormStep2))
            .selectResultsCell(withId: formItemId)
            .verifyResultsCellValue(resultType: .numericAnswer, expectedValue: "\(heightMetricAnswer)")
            .verifyResultsCellValue(resultType: .unit, expectedValue: "cm")
            .verifyResultsCellValue(resultType: .displayUnit, expectedValue: "nil")
            .navigateToResultsStepBack()
            .navigateToResultsStepBack()
        
        // result 3
        resultsTab
            .selectResultsCell(withId: String(describing: Identifier.heightQuestionFormStep3))
            .selectResultsCell(withId: formItemId)
            .verifyResultsCellValue(resultType: .numericAnswer, expectedValue: "\(expectedHeightInCentimeters)")
            .verifyResultsCellValue(resultType: .unit, expectedValue: "cm")
            .verifyResultsCellValue(resultType: .displayUnit, expectedValue: "nil")
            .navigateToResultsStepBack()
            .navigateToResultsStepBack()
        
        // result 4
        resultsTab
            .selectResultsCell(withId: String(describing: Identifier.heightQuestionFormStep4))
            .selectResultsCell(withId: formItemId)
        
        if measurementSystem == metricSignature {
            resultsTab.verifyResultsCellValue(resultType: .numericAnswer, expectedValue: "\(heightMetricAnswer)")
        } else if measurementSystem == usSignature {
            resultsTab.verifyResultsCellValue(resultType: .numericAnswer, expectedValue: "\(expectedHeightInCentimeters)")
        }
        
        resultsTab
            .verifyResultsCellValue(resultType: .unit, expectedValue: "cm")
            .verifyResultsCellValue(resultType: .displayUnit, expectedValue: "nil")
    }
    
    /// <rdar://tsc/21847951> [Survey Questions] Weight Question
    func testWeightQuestion() {
        tasksList
            .selectTaskByName(Task.weightQuestion.description)
        
        let healthAccessScreen = HealthAccess()
        healthAccessScreen
            .verifyHealthAuthorizationView(exists: true)
            .tapAllowToRead(for: .weight)
            .tapAllowButton()
        
        let weightMetricAnswerKg = 62
        let weightMetricAnswerKgPrecise = 62.5
        let weightMetricAnswerKgHighlyPrecise = 62.57
        let weightUSAnswerLb = 136
        let weightUSAnswerOz = 12
        
        let questionStep = FormStepScreen()
        let formItemId = "heightQuestionFormItem1"
        // Local system Optional Question
        questionStep
            .verify(.title)
            .verify(.text)
            .verify(.skipButton)
            .verify(.skipButton, isEnabled: true)
            .verify(.continueButton, isEnabled: true)
            .verifySingleQuestionTitleExists()
        
        if shouldUseUIPickerWorkaround {
            questionStep.selectFormItemCell(withID: formItemId)
            dismissPicker = true
        }
        
        if measurementSystem == metricSignature {
            questionStep.answerWeighQuestion(kg: weightMetricAnswerKg, dismissPicker: dismissPicker)
        } else if measurementSystem == usSignature {
            questionStep.answerWeighQuestion(lb: weightUSAnswerLb, dismissPicker: dismissPicker)
        }
        questionStep
            .verify(.continueButton, isEnabled: true)
            .tap(.continueButton)
        
        if expectingNonOptionalStep {
            // Local system NonOptional Question
            questionStep
                .verify(.title)
                .verify(.text)
                .verify(.skipButton, exists: false)
                .verify(.continueButton, isEnabled: false)
                .verifySingleQuestionTitleExists()
            
            if shouldUseUIPickerWorkaround {
                questionStep.selectFormItemCell(withID: formItemId)
                dismissPicker = true
            }
            
            if measurementSystem == metricSignature {
                questionStep.answerWeighQuestion(kg: weightMetricAnswerKg, dismissPicker: dismissPicker)
            } else if measurementSystem == usSignature {
                questionStep.answerWeighQuestion(lb: weightUSAnswerLb, dismissPicker: dismissPicker)
            }
            questionStep
                .verify(.continueButton, isEnabled: true)
                .tap(.continueButton)
        }
        
        // Metric system Optional Question - default precision
        questionStep
            .verify(.title)
            .verify(.text)
            .verify(.skipButton)
            .verify(.skipButton, isEnabled: true)
            .verify(.continueButton, isEnabled: true)
            .verifySingleQuestionTitleExists()
        
        if shouldUseUIPickerWorkaround {
            questionStep.selectFormItemCell(withID: formItemId)
            dismissPicker = true
        }
        
        questionStep.answerWeighQuestion(kg: weightMetricAnswerKgPrecise, dismissPicker: dismissPicker)
        
        questionStep
            .verify(.continueButton, isEnabled: true)
            .tap(.continueButton)
        
        if expectingNonOptionalStep {
            // Metric system Non Optional Question - default precision
            questionStep
                .verify(.title)
                .verify(.text)
                .verify(.skipButton, exists: false)
                .verify(.continueButton, isEnabled: false)
                .verifySingleQuestionTitleExists()
            
            if shouldUseUIPickerWorkaround {
                questionStep.selectFormItemCell(withID: formItemId)
                dismissPicker = true
            }
            
            questionStep.answerWeighQuestion(kg: weightMetricAnswerKgPrecise, dismissPicker: dismissPicker)
            
            questionStep
                .verify(.continueButton, isEnabled: true)
                .tap(.continueButton)
        }
        
        // Metric system Optional Question - low precision
        questionStep
            .verify(.title)
            .verify(.text)
            .verify(.skipButton)
            .verify(.skipButton, isEnabled: true)
            .verify(.continueButton, isEnabled: true)
            .verifySingleQuestionTitleExists()
        
        if shouldUseUIPickerWorkaround {
            questionStep.selectFormItemCell(withID: formItemId)
            dismissPicker = true
        }
        
        questionStep.answerWeighQuestion(kg: weightMetricAnswerKg, dismissPicker: dismissPicker)
        
        questionStep
            .verify(.continueButton, isEnabled: true)
            .tap(.continueButton)
        
        if expectingNonOptionalStep {
            // Metric system Non Optional Question - low precision
            questionStep
                .verify(.title)
                .verify(.text)
                .verify(.skipButton, exists: false)
                .verify(.continueButton, isEnabled: false)
                .verifySingleQuestionTitleExists()
            
            if shouldUseUIPickerWorkaround {
                questionStep.selectFormItemCell(withID: formItemId)
                dismissPicker = true
            }
            
            questionStep.answerWeighQuestion(kg: weightMetricAnswerKg, dismissPicker: dismissPicker)
            
            questionStep
                .verify(.continueButton, isEnabled: true)
                .tap(.continueButton)
        }
        
        // Metric system Optional Question - high precision
        questionStep
            .verify(.title)
            .verify(.text)
            .verify(.skipButton)
            .verify(.skipButton, isEnabled: true)
            .verify(.continueButton, isEnabled: true)
            .verifySingleQuestionTitleExists()
        
        if shouldUseUIPickerWorkaround {
            questionStep.selectFormItemCell(withID: formItemId)
            dismissPicker = true
        }
        
        questionStep.answerWeighQuestion(kg: weightMetricAnswerKgHighlyPrecise, highPrecision: true, dismissPicker: dismissPicker)
        
        questionStep
            .verify(.continueButton, isEnabled: true)
            .tap(.continueButton)
        
        if expectingNonOptionalStep {
            // Metric system Non Optional Question - high precision
            questionStep
                .verify(.title)
                .verify(.text)
                .verify(.skipButton, exists: false)
                .verify(.continueButton, isEnabled: false)
                .verifySingleQuestionTitleExists()
            
            if shouldUseUIPickerWorkaround {
                questionStep.selectFormItemCell(withID: formItemId)
                dismissPicker = true
            }
            
            questionStep.answerWeighQuestion(kg: weightMetricAnswerKgHighlyPrecise, highPrecision: true, dismissPicker: dismissPicker)
            
            questionStep
                .verify(.continueButton, isEnabled: true)
                .tap(.continueButton)
        }
        
        // USC system Optional Question - default precision
        questionStep
            .verify(.title)
            .verify(.text)
            .verify(.skipButton)
            .verify(.skipButton, isEnabled: true)
            .verify(.continueButton, isEnabled: true)
            .verifySingleQuestionTitleExists()
        
        if shouldUseUIPickerWorkaround {
            questionStep.selectFormItemCell(withID: formItemId)
            dismissPicker = true
        }
        
        questionStep
            .answerWeighQuestion(lb: weightUSAnswerLb, dismissPicker: dismissPicker)
            .verify(.continueButton, isEnabled: true)
            .tap(.continueButton)
        
        if expectingNonOptionalStep {
            // USC system NonOptional Question - default precision
            questionStep
                .verify(.title)
                .verify(.text)
                .verify(.skipButton, exists: false)
                .verify(.continueButton, isEnabled: false)
                .verifySingleQuestionTitleExists()
            
            if shouldUseUIPickerWorkaround {
                questionStep.selectFormItemCell(withID: formItemId)
                dismissPicker = true
            }
            
            questionStep
                .answerWeighQuestion(lb: weightUSAnswerLb, dismissPicker: dismissPicker)
                .verify(.continueButton, isEnabled: true)
                .tap(.continueButton)
        }
        
        // USC system Optional Question - high precision
        questionStep
            .verify(.title)
            .verify(.text)
            .verify(.skipButton)
            .verify(.skipButton, isEnabled: true)
            .verify(.continueButton, isEnabled: true)
            .verifySingleQuestionTitleExists()
        
        if shouldUseUIPickerWorkaround {
            questionStep.selectFormItemCell(withID: formItemId)
            dismissPicker = true
        }
        
        questionStep
            .answerWeighQuestion(lb: weightUSAnswerLb, oz: weightUSAnswerOz, dismissPicker: dismissPicker)
            .verify(.continueButton, isEnabled: true)
            .tap(.continueButton)
        
        if expectingNonOptionalStep {
            // USC system NonOptional Question - default precision
            questionStep
                .verify(.title)
                .verify(.text)
                .verify(.skipButton, exists: false)
                .verify(.continueButton, isEnabled: false)
                .verifySingleQuestionTitleExists()
            
            if shouldUseUIPickerWorkaround {
                questionStep.selectFormItemCell(withID: formItemId)
                dismissPicker = true
            }
            
            questionStep
                .answerWeighQuestion(lb: weightUSAnswerLb, oz: weightUSAnswerOz, dismissPicker: dismissPicker)
                .verify(.continueButton, isEnabled: true)
                .tap(.continueButton)
        }
        
        if expectingNonOptionalStep {
            // HealthKit integration - Non Optional // TODO: rdar://118141808 (Height/Weight Questions should prefill with HealthKit value)
            questionStep
                .verify(.title)
                .verify(.text)
                .verify(.skipButton, exists: false)
                .verify(.continueButton, isEnabled: false)
                .verifySingleQuestionTitleExists()
            
            if shouldUseUIPickerWorkaround {
                questionStep.selectFormItemCell(withID: formItemId)
                dismissPicker = true
            }
            
            if measurementSystem == metricSignature {
                questionStep.answerWeighQuestion(kg: weightMetricAnswerKg, dismissPicker: dismissPicker)
            } else if measurementSystem == usSignature {
                questionStep.answerWeighQuestion(lb: weightUSAnswerLb, dismissPicker: dismissPicker)
            }
            questionStep
                .verify(.continueButton, isEnabled: true)
                .tap(.continueButton)
        }
        
        // HealthKit integration - Optional // TODO: rdar://118141808 (Height/Weight Questions should prefill with HealthKit value)
        questionStep
            .verify(.title)
            .verify(.text)
            .verify(.skipButton)
            .verify(.skipButton, isEnabled: true)
            .verify(.continueButton, isEnabled: true)
            .verifySingleQuestionTitleExists()
        
        if shouldUseUIPickerWorkaround {
            questionStep.selectFormItemCell(withID: formItemId)
            dismissPicker = true
        }
        if measurementSystem == metricSignature {
            questionStep.answerWeighQuestion(kg: weightMetricAnswerKg, dismissPicker: dismissPicker)
        } else if measurementSystem == usSignature {
            questionStep.answerWeighQuestion(lb: weightUSAnswerLb, dismissPicker: dismissPicker)
        }
        questionStep
            .verify(.continueButton, isEnabled: true)
            .tap(.continueButton)
        
        let resultsTab = TabBar().navigateToResults()
        let expectedWeightInKilograms = poundsAndOuncesToKilograms(pounds: Double(weightUSAnswerLb))
        
        // result 1
        resultsTab
            .selectResultsCell(withId: String(describing: Identifier.weightQuestionFormStep1))
            .selectResultsCell(withId: formItemId)
        
        if measurementSystem == metricSignature {
            resultsTab.verifyResultsCellValue(resultType: .numericAnswer, expectedValue: "\(weightMetricAnswerKg)")
        } else if measurementSystem == usSignature {
            resultsTab.verifyResultsCellValue(resultType: .numericAnswer, expectedValue: "\(expectedWeightInKilograms)")
        }
        
        resultsTab
            .verifyResultsCellValue(resultType: .unit, expectedValue: "kg")
            .navigateToResultsStepBack()
            .navigateToResultsStepBack()
            
        // result 2
        resultsTab
            .selectResultsCell(withId: String(describing: Identifier.weightQuestionFormStep2))
            .selectResultsCell(withId: formItemId)
            .verifyResultsCellValue(resultType: .numericAnswer, expectedValue: "\(weightMetricAnswerKgPrecise)")
            .verifyResultsCellValue(resultType: .unit, expectedValue: "kg")
            .navigateToResultsStepBack()
            .navigateToResultsStepBack()
        
        // result 3
        resultsTab
            .selectResultsCell(withId: String(describing: Identifier.weightQuestionFormStep3))
            .selectResultsCell(withId: formItemId)
            .verifyResultsCellValue(resultType: .numericAnswer, expectedValue: "\(weightMetricAnswerKg)")
            .verifyResultsCellValue(resultType: .unit, expectedValue: "kg")
            .navigateToResultsStepBack()
            .navigateToResultsStepBack()
        
        // result 4
        resultsTab
            .selectResultsCell(withId: String(describing: Identifier.weightQuestionFormStep4))
            .selectResultsCell(withId: formItemId)
            .verifyResultsCellValue(resultType: .numericAnswer, expectedValue: "\(weightMetricAnswerKgHighlyPrecise)")
            .verifyResultsCellValue(resultType: .unit, expectedValue: "kg")
            .navigateToResultsStepBack()
            .navigateToResultsStepBack()
        
        // result 5
        resultsTab
            .selectResultsCell(withId: String(describing: Identifier.weightQuestionFormStep5))
            .selectResultsCell(withId: formItemId)
            .verifyResultsCellValue(resultType: .numericAnswer, expectedValue: "\(expectedWeightInKilograms)")
            .verifyResultsCellValue(resultType: .unit, expectedValue: "kg")
            .navigateToResultsStepBack()
            .navigateToResultsStepBack()
        
        // result 6
        let convertedPoundsAndOuncesToKgValue = poundsAndOuncesToKilograms(pounds: Double(weightUSAnswerLb), ounces: Double(weightUSAnswerOz))
        
        resultsTab
            .selectResultsCell(withId: String(describing: Identifier.weightQuestionFormStep6))
            .selectResultsCell(withId: formItemId)
            .verifyResultsCellValue(resultType: .numericAnswer, expectedValue: "\(convertedPoundsAndOuncesToKgValue)")
            .verifyResultsCellValue(resultType: .unit, expectedValue: "kg")
            .navigateToResultsStepBack()
            .navigateToResultsStepBack()
        
        // result 7
        resultsTab
            .selectResultsCell(withId: String(describing: Identifier.weightQuestionFormStep7))
            .selectResultsCell(withId: formItemId)
            .verifyResultsCellValue(resultType: .unit, expectedValue: "kg")
        
        if measurementSystem == metricSignature {
            resultsTab.verifyResultsCellValue(resultType: .numericAnswer, expectedValue: "\(weightMetricAnswerKg)")
        } else if measurementSystem == usSignature {
            resultsTab.verifyResultsCellValue(resultType: .numericAnswer, expectedValue: "\(expectedWeightInKilograms)")
        }
    }
    
    private func poundsAndOuncesToKilograms(pounds: Double, ounces: Double = 0) -> Double {
        let poundsToKg = pounds * 0.453592
        let ouncesToKg = ounces * 0.0283495
        let kg = poundsToKg + ouncesToKg
        return round(value: kg, places: 2)
    }
    
    private func feetAndInchesToCentimeters(feet: Double, inches: Double) -> Double {
        let cm = ((feet * 12) + inches) * 2.54
        return round(value: cm, places: 2)
    }
    
    private func round(value: Double,  places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (value * divisor).rounded() / divisor
    }
    
    ///<rdar://tsc/21847949> [Survey Questions] Date & Time Question
    func testDateAndTimeQuestion() {
        tasksList
            .selectTaskByName(Task.dateTimeQuestion.description)
        
        let questionStep = FormStepScreen()
        questionStep
            .verify(.title)
            .verify(.text)
            .verify(.skipButton) // Optional Question
            .verify(.continueButton, isEnabled: true) // Picker value defaults to current date so continue button is enabled
            .verifySingleQuestionTitleExists()
        
        if shouldUseUIPickerWorkaround {
            questionStep.selectFormItemCell(withID: "dateTimeQuestionFormStep")
            dismissPicker = true
        }
        
        if hourCycle  == usTimeSignature {
            questionStep
                .answerDateAndTimeQuestion(offsetDays: 1, offsetHours: 5, isUSTimeZone: true)
                .answerDateAndTimeQuestion(offsetDays: -2, offsetHours: 7, isUSTimeZone: true, dismissPicker: dismissPicker)
            // TODO: Verifying entered values is blocked by rdar://120826508 ([Accessibility][ORKCatalog] Unable to access cell value after entering it)
            
        } else if hourCycle == continentalTimeSignature {
            questionStep
                .answerDateAndTimeQuestion(offsetDays: 1, offsetHours: 5, isUSTimeZone: false)
                .answerDateAndTimeQuestion(offsetDays: -2, offsetHours: 7, isUSTimeZone: false, dismissPicker: dismissPicker)
            // TODO: Verifying entered values is blocked by rdar://120826508 ([Accessibility][ORKCatalog] Unable to access cell value after entering it)
        }
        
        questionStep
            .verify(.continueButton,isEnabled: true)
            .tap(.continueButton)
    }
    
    func testDate3DayLimitQuestion() {
        tasksList
            .selectTaskByName(Task.date3DayLimitQuestionTask.description)
        
        let questionStep = FormStepScreen()
        let formItemId = "dateQuestionFormItem"
        questionStep
            .verify(.title)
            .verify(.text)
            .verify(.skipButton) // Optional Question
            .verify(.continueButton, isEnabled: true) // Picker value defaults to current date so continue button is enabled
            .verifySingleQuestionTitleExists()
        
        if shouldUseUIPickerWorkaround {
            questionStep.selectFormItemCell(withID: formItemId)
            dismissPicker = true
        }
        
        questionStep
            .verifyDatePickerDefaultsToCurrentDate(isUSTimeZone: isUSTimeZone)
            .answerDateQuestion(offsetDays: -3, offsetYears: 0, isUSTimeZone: isUSTimeZone, dismissPicker: dismissPicker)
            .verify(.continueButton, isEnabled: true)
        
        if shouldUseUIPickerWorkaround {
            questionStep.selectFormItemCell(withID: formItemId)
            dismissPicker = true
        }
        
        questionStep
            .answerDateQuestion(offsetDays: 3, offsetYears: 0, isUSTimeZone: isUSTimeZone)
            .verifyDatePickerRestrictedTo3days(offsetDays: -4, offsetYears: 0, isUSTimeZone: isUSTimeZone)
            .verifyDatePickerRestrictedTo3days(offsetDays: 4, offsetYears: 0, isUSTimeZone: isUSTimeZone, dismissPicker: dismissPicker)
            .verify(.continueButton,isEnabled: true)
        
        // TODO: Verifying entered values is blocked by rdar://120826508 ([Accessibility][ORKCatalog] Unable to access cell value after entering it)
        
        questionStep
            .tap(.continueButton)
    }
    
    ///<rdar://tsc/21847959> [Survey Questions] Time Of Day Question
    func testTimeOfDayQuestion() {
        tasksList
            .selectTaskByName(Task.timeOfDayQuestion.description)
        let questionStep = FormStepScreen()
        questionStep
            .verify(.title)
            .verify(.text)
            .verify(.skipButton) // Optional Question
            .verify(.skipButton, isEnabled: true) 
            .verify(.continueButton,isEnabled: true)
            .verifySingleQuestionTitleExists()
        
        if shouldUseUIPickerWorkaround {
            questionStep.selectFormItemCell(withID: "timeOfDayFormItem")
            dismissPicker = true
        }
        
        if hourCycle  == usTimeSignature {
            questionStep
                .answerTimeOfDayQuestion(hours: 01, minutes: 01, isUSTimeZone: true, isAM: true)
                .answerTimeOfDayQuestion(hours: 11, minutes: 59, isUSTimeZone: true, isAM: false, dismissPicker: dismissPicker)
                .verify(.continueButton, isEnabled: true)
            
            // TODO: Verify entered values blocked by rdar://120826508 ([Accessibility][ORKCatalog] Unable to access cell value after entering it)
            
        } else if hourCycle == continentalTimeSignature {
            questionStep
                .answerTimeOfDayQuestion(hours: 01, minutes: 01, isUSTimeZone: false)
                .answerTimeOfDayQuestion(hours: 11, minutes: 59, isUSTimeZone: false, dismissPicker: dismissPicker)
                .verify(.continueButton, isEnabled: true)
            // TODO: Verify entered values blocked by rdar://120826508 ([Accessibility][ORKCatalog] Unable to access cell value after entering it)
        }
        questionStep
            .verify(.continueButton,isEnabled: true)
            .tap(.continueButton)
    }
}
