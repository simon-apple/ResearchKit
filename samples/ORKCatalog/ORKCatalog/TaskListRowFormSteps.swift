//  TaskListRowFormSteps.swift
//  ORKCatalog
//
//  Created by Pariece Mckinney on 1/3/24.
//  Copyright © 2024 researchkit.org. All rights reserved.
//

import ResearchKit

enum TaskListRowSteps {
    
    static var booleanExample: ORKFormStep {
        let booleanQuestionAnswerFormat = ORKBooleanAnswerFormat()
        let question1 = NSLocalizedString("Would you like to subscribe to our newsletter?", comment: "")

        let booleanQuestionFormItem = ORKFormItem(identifier: String(describing: Identifier.booleanFormItem), text: question1, answerFormat: booleanQuestionAnswerFormat)
        booleanQuestionFormItem.learnMoreItem = self.learnMoreItemExample
        
        let booleanQuestionFormStep = ORKFormStep(identifier: String(describing: Identifier.booleanFormStep), title: "Questionnaire", text: TaskListRowStrings.exampleDetailText)
        booleanQuestionFormStep.formItems = [booleanQuestionFormItem]
        
        return booleanQuestionFormStep
    }
    
    static var textChoiceExample: ORKFormStep {
        let textChoices: [ORKTextChoice] = [
            ORKTextChoice(text: "choice 1", detailText: "detail 1", value: 1 as NSNumber, exclusive: false),
            ORKTextChoice(text: "choice 2", detailText: "detail 2", value: 2 as NSNumber, exclusive: false),
            ORKTextChoice(text: "choice 3", detailText: "detail 3", value: 3 as NSNumber, exclusive: false),
            ORKTextChoice(text: "choice 4", detailText: "detail 4", value: 4 as NSNumber, exclusive: false),
            ORKTextChoice(text: "choice 5", detailText: "detail 5", value: 5 as NSNumber, exclusive: false),
            ORKTextChoice(text: "choice 6", detailText: "detail 6", value: 6 as NSNumber, exclusive: false),
            ORKTextChoiceOther.choice(withText: "choice 7", detailText: "detail 7", value: "choice 7" as NSString, exclusive: true, textViewPlaceholderText: "enter additional information")
        ]
        
        let textChoiceQuestion = NSLocalizedString("Select an option below.", comment: "")
        let textChoiceAnswerFormat = ORKTextChoiceAnswerFormat(style: .singleChoice, textChoices: textChoices)
        
        let textChoiceFormItem = ORKFormItem(identifier: String(describing: Identifier.textChoiceFormItem), text: textChoiceQuestion, answerFormat: textChoiceAnswerFormat)
        textChoiceFormItem.learnMoreItem = self.learnMoreItemExample
        let textChoiceFormStep = ORKFormStep(identifier: String(describing: Identifier.textChoiceFormStep), title: "Questionnaire", text: TaskListRowStrings.exampleDetailText)
        textChoiceFormStep.formItems = [textChoiceFormItem]
        
        return textChoiceFormStep
    }
    
    static var heightExample: ORKFormStep {
        let stepIdentifier = String(describing: Identifier.heightQuestionFormStep1)
        let heightAnswerFormat = ORKAnswerFormat.heightAnswerFormat()
        let title = NSLocalizedString("Height", comment: "")
        let stepText =  NSLocalizedString("Local system", comment: "")
        
        let formStep = self.heightWeightFormStepExample(identifier:stepIdentifier, answerFormat:heightAnswerFormat, title:title, text:stepText)
        
        return formStep
    }
    
    static var heightMetricSystemExample: ORKFormStep {
        let stepIdentifier = String(describing: Identifier.heightQuestionFormStep2)
        let heightAnswerFormat = ORKAnswerFormat.heightAnswerFormat(with: .metric)
        let title = NSLocalizedString("Height", comment: "")
        let stepText = NSLocalizedString("Metric system", comment: "")
        
        let formStep = self.heightWeightFormStepExample(identifier:stepIdentifier, answerFormat:heightAnswerFormat, title:title, text:stepText)
        
        return formStep
    }
    
    static var heightUSCSystemExample: ORKFormStep {
        let stepIdentifier = String(describing: Identifier.heightQuestionFormStep3)
        let heightAnswerFormat = ORKAnswerFormat.heightAnswerFormat(with: .USC)
        let title = NSLocalizedString("Height", comment: "")
        let stepText = NSLocalizedString("USC system", comment: "")
        
        let formStep = self.heightWeightFormStepExample(identifier:stepIdentifier, answerFormat:heightAnswerFormat, title:title, text:stepText)
        
        return formStep
    }
    
    static var heightHealthKitExample: ORKFormStep {
        let stepIdentifier = String(describing: Identifier.heightQuestionFormStep4)
        let heightAnswerFormat = ORKHealthKitQuantityTypeAnswerFormat(quantityType: HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.height)!, unit: HKUnit.meterUnit(with: .centi), style: .decimal)
        let title = NSLocalizedString("Height", comment: "")
        let stepText = NSLocalizedString("HealthKit, height", comment: "")
        
        let formStep = self.heightWeightFormStepExample(identifier:stepIdentifier, answerFormat:heightAnswerFormat, title:title, text:stepText)
        
        return formStep
    }
    
    static var weightExample: ORKFormStep {
        let stepIdentifier = String(describing: Identifier.weightQuestionFormStep1)
        let weightAnswerFormat = ORKAnswerFormat.weightAnswerFormat()
        let title = NSLocalizedString("Weight", comment: "")
        let stepText =  NSLocalizedString("Local system, default precision", comment: "")
        
        let formStep = self.heightWeightFormStepExample(identifier:stepIdentifier, answerFormat:weightAnswerFormat, title:title, text:stepText)
        
        return formStep
    }
    
    static var weightMetricSystemExample: ORKFormStep {
        let stepIdentifier = String(describing: Identifier.weightQuestionFormStep2)
        let weightAnswerFormat = ORKAnswerFormat.weightAnswerFormat(with: .metric)
        let title = NSLocalizedString("Weight", comment: "")
        let stepText =  NSLocalizedString("Metric system, default precision", comment: "")
        
        let formStep = self.heightWeightFormStepExample(identifier:stepIdentifier, answerFormat:weightAnswerFormat, title:title, text:stepText)
        
        return formStep
    }
    
    static var weightMetricSystemLowPrecisionExample: ORKFormStep {
        let stepIdentifier = String(describing: Identifier.weightQuestionFormStep3)
        let weightAnswerFormat = ORKAnswerFormat.weightAnswerFormat(with: ORKMeasurementSystem.metric, numericPrecision: ORKNumericPrecision.low, minimumValue: ORKDoubleDefaultValue, maximumValue: ORKDoubleDefaultValue, defaultValue: ORKDoubleDefaultValue)
        let title = NSLocalizedString("Weight", comment: "")
        let stepText =  NSLocalizedString("Metric system, low precision", comment: "")
        
        let formStep = self.heightWeightFormStepExample(identifier:stepIdentifier, answerFormat:weightAnswerFormat, title:title, text:stepText)
        
        return formStep
    }
    
    static var weightMetricSystemHighPrecisionExample: ORKFormStep {
        let stepIdentifier = String(describing: Identifier.weightQuestionFormStep4)
        let weightAnswerFormat = ORKAnswerFormat.weightAnswerFormat(with: ORKMeasurementSystem.metric, numericPrecision: ORKNumericPrecision.high, minimumValue: ORKDoubleDefaultValue, maximumValue: ORKDoubleDefaultValue, defaultValue: ORKDoubleDefaultValue)
        let title = NSLocalizedString("Weight", comment: "")
        let stepText =  NSLocalizedString("Metric system, high precision", comment: "")
        
        let formStep = self.heightWeightFormStepExample(identifier:stepIdentifier, answerFormat:weightAnswerFormat, title:title, text:stepText)
        
        return formStep
    }
    
    static var weightUSCSystemExample: ORKFormStep {
        let stepIdentifier = String(describing: Identifier.weightQuestionFormStep5)
        let weightAnswerFormat = ORKAnswerFormat.weightAnswerFormat(with: .USC)
        let title = NSLocalizedString("Weight", comment: "")
        let stepText =  NSLocalizedString("USC system, default precision", comment: "")
        
        let formStep = self.heightWeightFormStepExample(identifier:stepIdentifier, answerFormat:weightAnswerFormat, title:title, text:stepText)
        
        return formStep
    }
    
    static var weightUSCSystemHighPrecisionExample: ORKFormStep {
        let stepIdentifier = String(describing: Identifier.weightQuestionFormStep6)
        let weightAnswerFormat = ORKAnswerFormat.weightAnswerFormat(with: ORKMeasurementSystem.USC, numericPrecision: ORKNumericPrecision.high, minimumValue: ORKDoubleDefaultValue, maximumValue: ORKDoubleDefaultValue, defaultValue: ORKDoubleDefaultValue)
        let title = NSLocalizedString("Weight", comment: "")
        let stepText =  NSLocalizedString("USC system, high precision", comment: "")
        
        let formStep = self.heightWeightFormStepExample(identifier:stepIdentifier, answerFormat:weightAnswerFormat, title:title, text:stepText)
        
        return formStep
    }
    
    static var weightHealthKitBodyMassExample: ORKFormStep {
        let stepIdentifier = String(describing: Identifier.weightQuestionFormStep7)
        let weightAnswerFormat = ORKHealthKitQuantityTypeAnswerFormat(quantityType: HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bodyMass)!, unit: HKUnit.gramUnit(with: .kilo), style: .decimal)
        let title = NSLocalizedString("Weight", comment: "")
        let stepText =  NSLocalizedString("HealthKit, body mass", comment: "")
        
        let formStep = self.heightWeightFormStepExample(identifier:stepIdentifier, answerFormat:weightAnswerFormat, title:title, text:stepText)
        
        return formStep
    }
    
    static var heartRateExample: ORKFormStep {
        let heartRateType = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)!
        let heartRateAnswerFormat = ORKHealthKitQuantityTypeAnswerFormat(quantityType: heartRateType,
                                                                         unit: nil,
                                                                         style: .decimal)
        
        let formItemSectionHeader = ORKFormItem(sectionTitle: String(describing: TaskListRowStrings.exampleHeartRateQuestion))
        let heartRateFormItem = ORKFormItem(identifier: String(describing: Identifier.healthQuantityFormItem), 
                                            text: nil, 
                                            answerFormat:heartRateAnswerFormat)
        
        let heartRateFormStep = ORKFormStep(identifier: String(describing: Identifier.healthQuantityFormStep1), 
                                            title: NSLocalizedString("Heart Rate", comment: ""),
                                            text: TaskListRowStrings.exampleDetailText)
        heartRateFormStep.formItems = [formItemSectionHeader, heartRateFormItem]
        
        return heartRateFormStep
    }
    
    static var bloodTypeExample: ORKFormStep {
        let bloodType = HKCharacteristicType.characteristicType(forIdentifier: HKCharacteristicTypeIdentifier.bloodType)!
        let bloodTypeAnswerFormat = ORKHealthKitCharacteristicTypeAnswerFormat(characteristicType: bloodType)
        
        let formItemSectionHeader = ORKFormItem(sectionTitle: String(describing: TaskListRowStrings.exampleBloodTypeQuestion))
        let bloodTypeFormItem = ORKFormItem(identifier: String(describing: Identifier.healthQuantityFormItem),
                                            text: String(describing: TaskListRowStrings.exampleTapHereText),
                                            answerFormat: bloodTypeAnswerFormat)
        
        let bloodTypeFormStep = ORKFormStep(identifier: String(describing: Identifier.healthQuantityFormStep2),
                                            title: NSLocalizedString("Blood Type", comment: ""),
                                            text: TaskListRowStrings.exampleDetailText)
        bloodTypeFormStep.formItems = [formItemSectionHeader, bloodTypeFormItem]
        
        return bloodTypeFormStep
    }
    
    static var imageChoiceExample: ORKFormStep {
        let imageChoices = self.imageChoicesExample
        let imageChoiceAnswerFormat = ORKAnswerFormat.choiceAnswerFormat(with: imageChoices)
        
        let imageChoiceFormItem = ORKFormItem(identifier: String(describing: Identifier.imageChoiceFormItem),
                                              text: TaskListRowStrings.exampleQuestionText,
                                              answerFormat: imageChoiceAnswerFormat)
        
        let imageChoiceFormStep = ORKFormStep(identifier: String(describing: Identifier.imageChoiceFormStep1),
                                              title: NSLocalizedString("Image Choice", comment: ""),
                                              text: TaskListRowStrings.exampleDetailText)
        imageChoiceFormStep.formItems = [imageChoiceFormItem]
        
        return imageChoiceFormStep
    }
    
    static var imageChoiceVerticalExample: ORKFormStep {
        let imageChoices = self.imageChoicesExample
        let imageChoiceAnswerFormat = ORKAnswerFormat.choiceAnswerFormat(with: imageChoices, style: .multipleChoice, vertical: true)
    
        let imageChoiceFormItem = ORKFormItem(identifier: String(describing: Identifier.imageChoiceFormItem),
                                              text: TaskListRowStrings.exampleQuestionText,
                                              answerFormat: imageChoiceAnswerFormat)
        
        let imageChoiceFormStep = ORKFormStep(identifier: String(describing: Identifier.imageChoiceFormStep2),
                                              title: NSLocalizedString("Image Choice", comment: ""),
                                              text: TaskListRowStrings.exampleDetailText)
        imageChoiceFormStep.formItems = [imageChoiceFormItem]
        
        return imageChoiceFormStep
    }
    
    static var locationExample: ORKFormStep {
        let locationAnswerFormat = ORKLocationAnswerFormat()
        let locationFormItem = ORKFormItem(identifier: String(describing: Identifier.locationQuestionFormItem),
                                           text: TaskListRowStrings.exampleQuestionText,
                                           answerFormat: locationAnswerFormat)
        
        let locationFormStep = ORKFormStep(identifier: String(describing: Identifier.locationQuestionFormStep),
                                           title: NSLocalizedString("Location", comment: ""),
                                           text: TaskListRowStrings.exampleDetailText)
        locationFormStep.formItems = [locationFormItem]
        
        return locationFormStep
    }
    
    private static var formItemSectionHeaderExample: ORKFormItem {
        return ORKFormItem(sectionTitle: TaskListRowStrings.exampleQuestionText)
    }
    
    private static var learnMoreItemExample: ORKLearnMoreItem {
        let learnMoreInstructionStep = ORKLearnMoreInstructionStep(identifier: "LearnMoreInstructionStep01")
        learnMoreInstructionStep.title = NSLocalizedString("Learn more title", comment: "")
        learnMoreInstructionStep.text = NSLocalizedString("Learn more text", comment: "")
        let learnMoreItem = ORKLearnMoreItem(text: nil, learnMoreInstructionStep: learnMoreInstructionStep)
        
        return learnMoreItem
    }
    
    private static func heightWeightFormStepExample(identifier: String, answerFormat: ORKAnswerFormat, title: String, text: String) -> ORKFormStep {
        let formItemSectionHeader = self.formItemSectionHeaderExample
        let heightQuestionFormItem = ORKFormItem(identifier: String(describing: Identifier.heightQuestionFormItem1), text: TaskListRowStrings.exampleTapHereText, answerFormat: answerFormat)
        
        let heightQuestionFormStep = ORKFormStep(identifier: String(describing: identifier), title: title, text: text)
        heightQuestionFormStep.formItems = [formItemSectionHeader, heightQuestionFormItem]
        
        return heightQuestionFormStep
    }
    
    private static var imageChoicesExample: [ORKImageChoice] {
        let roundShapeImage = UIImage(named: "round_shape")!
        let roundShapeText = NSLocalizedString("Round Shape", comment: "")
        
        let squareShapeImage = UIImage(named: "square_shape")!
        let squareShapeText = NSLocalizedString("Square Shape", comment: "")
        
        let imageChoices = [
            ORKImageChoice(normalImage: roundShapeImage, selectedImage: nil, text: roundShapeText, value: roundShapeText as NSString),
            ORKImageChoice(normalImage: squareShapeImage, selectedImage: nil, text: squareShapeText, value: squareShapeText as NSString)
        ]
        
        return imageChoices
    }
    
}
