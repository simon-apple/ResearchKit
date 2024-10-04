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

import ResearchKit
import ResearchKitSwiftUI
import SwiftUI
import ResearchKitSwiftUI

public extension ResearchForm where Content == ResearchFormDataAdapter {
    
    init(
        taskIdentifier: String,
        surveyData: Data,
        restorationResult: ResearchFormResult? = nil,
        onResearchFormCompletion: ((ResearchFormCompletion) -> Void)? = nil
    ) {
        self.init(
            taskIdentifier: taskIdentifier,
            restorationResult: restorationResult,
            steps: {
                ResearchFormDataAdapter(surveyData: surveyData)
            },
            onResearchFormCompletion: onResearchFormCompletion
        )
    }
    
}

public struct ResearchFormDataAdapter: View {
    
    private let surveyData: Data
    
    init(surveyData: Data) {
        self.surveyData = surveyData
    }
    
    public var body: some View {
        if let task = ORKIESerializer.swiftUI_object(fromJSONData: surveyData, error: nil) as? ORKOrderedTask {
            ResearchFormAdapter(task: task)
        }
    }
    
}

struct ResearchFormAdapter: View {
    
    private let task: ORKOrderedTask
    
    init(task: ORKOrderedTask) {
        self.task = task
    }
    
    var body: some View {
        ForEach(task.steps, id: \.identifier) { step in
            researchFormStep(for: step)
        }
    }
    
    @ViewBuilder
    private func researchFormStep(for step: ORKStep) -> some View {
        switch step {
        case let formStep as ORKFormStep:
            build(formStep)
        case let questionStep as ORKQuestionStep:
            build(questionStep)
        case let instructionStep as ORKInstructionStep:
            build(instructionStep)
        default:
            EmptyView()
        }
    }
    
    @ViewBuilder
    private func build(_ formStep: ORKFormStep) -> some View {
        ResearchFormStep(title: formStep.title, subtitle: formStep.detailText) {
            if let formItems = formStep.formItems {
                ForEach(groupItems(formItems), id: \.identifier) { formItem in
                    if let answerFormat = formItem.answerFormat {
                        build(answerFormat, id: formItem.identifier, title: formItem.text, placeholder: formItem.placeholder, detail: formItem.detailText)
                            .questionRequired(!formItem.isOptional)
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private func build(_ questionStep: ORKQuestionStep) -> some View {
        ResearchFormStep(title: questionStep.title, subtitle: questionStep.detailText) {
            if let answerFormat = questionStep.answerFormat {
                build(answerFormat, id: questionStep.identifier, title: questionStep.question, detail: questionStep.detailText)
                    .questionRequired(!questionStep.isOptional)
            }
        }
    }
    
    @ViewBuilder
    private func build(
        _ answerFormat: ORKAnswerFormat,
        id: String,
        title: String?,
        placeholder: String? = nil,
        detail: String? = nil
    ) -> some View {
        switch answerFormat {
        case let textChoiceAnswerFormat as ORKTextChoiceAnswerFormat:
            MultipleChoiceQuestion(
                id: id,
                title: title ?? "",
                choices: answerOptions(for: textChoiceAnswerFormat.textChoices),
                selectionType: textChoiceAnswerFormat.style == .singleChoice ? .single : .multiple
            )
        case let scaleAnswerFormat as ORKScaleAnswerFormat:
            SliderQuestion(
                id: id,
                title: title ?? "",
                range: scaleAnswerFormat.minimum...scaleAnswerFormat.maximum,
                step: Double(scaleAnswerFormat.step),
                selection: scaleAnswerFormat.defaultValue
            )
        case let continuousScaleAnswerFormat as ORKContinuousScaleAnswerFormat:
            let stepSize: Double = {
                // Current ORKContinuousScaleAnswerFormat does not allow user to specify step size so we can create an approximation,
                // falling back on 0.01 as our step size if required.
                var stepSize = 0.01
                let numberOfValues = continuousScaleAnswerFormat.maximum - continuousScaleAnswerFormat.minimum
                if numberOfValues > 0 {
                    stepSize = 1.0 / numberOfValues
                }
                return stepSize
            }()
            
            SliderQuestion(
                id: id,
                title: title ?? "",
                range: continuousScaleAnswerFormat.minimum...continuousScaleAnswerFormat.maximum,
                step: stepSize,
                selection: continuousScaleAnswerFormat.defaultValue
            )
#if !os(watchOS)
        case let textChoiceScaleAnswerFormat as ORKTextScaleAnswerFormat:
            let answerOptions = answerOptions(for: textChoiceScaleAnswerFormat.textChoices)
            
            if answerOptions.indices.contains(textChoiceScaleAnswerFormat.defaultIndex) {
                SliderQuestion(
                    id: id,
                    title: title ?? "",
                    multipleChoiceOptions: answerOptions,
                    selection: answerOptions[textChoiceScaleAnswerFormat.defaultIndex]
                )
            }
#endif
        case let textAnswerFormat as ORKTextAnswerFormat:
            TextQuestion(
                id: id,
                title: title ?? "",
                detail: "",
                prompt: placeholder,
                textFieldType: textAnswerFormat.multipleLines ? .multiline : .singleLine,
                characterLimit: textAnswerFormat.maximumLength,
                hideCharacterCountLabel: textAnswerFormat.hideCharacterCountLabel,
                hideClearButton: textAnswerFormat.hideClearButton,
                defaultTextAnswer: textAnswerFormat.defaultTextAnswer
            )
        case let dateTimeAnswerFormat as ORKDateAnswerFormat:
            let prompt: String = {
                
                if let placeholder {
                    return placeholder
                }
                
                if dateTimeAnswerFormat.style == .dateAndTime {
                    return "Select Date and Time"
                } else {
                    return "Select Date"
                }
            }()
            
            let startDate: Date = {
                if let date = dateTimeAnswerFormat.minimumDate {
                    return date
                }
                return Date.distantPast
            }()
            
            let endDate: Date = {
                if let date = dateTimeAnswerFormat.maximumDate {
                    return date
                }
                return Date.distantFuture
            }()
            
            let components: DatePicker.Components = {
                switch dateTimeAnswerFormat.style {
                case .date:
                    return [.date]
                case .dateAndTime:
                    return [.date, .hourAndMinute]
                default:
                    return [.date]
                }
            }()
            
            DateTimeQuestion(
                id: id,
                title: title ?? "",
                pickerPrompt: prompt,
                displayedComponents: components,
                range: startDate...endDate
            )
#if !os(watchOS)
        case let numericAnswerFormat as ORKNumericAnswerFormat:
            NumericQuestion(
                id: id,
                text: numericAnswerFormat.defaultNumericAnswer?.decimalValue,
                title: title ?? "",
                prompt: numericAnswerFormat.placeholder ?? "Tap to answer"
            )
#endif
        case let heightAnswerFormat as ORKHeightAnswerFormat:
            let measurementSystem: MeasurementSystem = {
                switch heightAnswerFormat.measurementSystem {
                case .USC:
                    return .USC
                case .local:
                    return .local
                case .metric:
                    return .metric
                @unknown default:
                    return .metric
                }
            }()
            
            HeightQuestion(
                id: id,
                title: title ?? "",
                measurementSystem: measurementSystem
            )
        case let weightAnswerFormat as ORKWeightAnswerFormat:
            let measurementSystem: MeasurementSystem = {
                switch weightAnswerFormat.measurementSystem {
                case .USC:
                    return .USC
                case .local:
                    return .local
                case .metric:
                    return .metric
                @unknown default:
                    return .metric
                }
            }()
            
            let precision: NumericPrecision = {
                switch weightAnswerFormat.numericPrecision {
                case .default:
                    return .default
                case .high:
                    return .high
                case .low:
                    return .low
                @unknown default:
                    return .default
                }
            }()
            
            // At the moment the RK API for weight answer format defaults these values
            // to the `greatestFiniteMagnitude` if you don't explicitly pass them in.
            // We want to check for that here and pass in a valid value.
            let defaultValue: Double = {
                if weightAnswerFormat.defaultValue == Double.greatestFiniteMagnitude {
                    if measurementSystem == .USC {
                        return 133
                    } else {
                        return 60
                    }
                }
                
                return weightAnswerFormat.defaultValue
            }()
            
            let minimumValue: Double? = {
                if weightAnswerFormat.minimumValue == Double.greatestFiniteMagnitude {
                    return nil
                }
                
                return weightAnswerFormat.minimumValue
            }()
            
            let maximumValue: Double? = {
                if weightAnswerFormat.maximumValue == Double.greatestFiniteMagnitude {
                    return nil
                }
                
                return weightAnswerFormat.maximumValue
            }()
            
            WeightQuestion(
                id: id,
                title: title ?? "",
                measurementSystem: measurementSystem,
                precision: precision,
                defaultValue: defaultValue,
                minimumValue: minimumValue,
                maximumValue: maximumValue
            )
        case let imageChoiceAnswerFormat as ORKImageChoiceAnswerFormat:
            let choices = imageChoiceAnswerFormat.imageChoices.compactMap { choice in
                let imageChoice: ImageChoice?
                
                if let number = choice.value as? NSNumber {
                    imageChoice = ImageChoice(
                        normalImage: choice.normalStateImage,
                        selectedImage: choice.selectedStateImage,
                        text: choice.text!,
                        value: number.intValue
                    )
                } else if let string = choice.value as? NSString {
                    imageChoice = ImageChoice(
                        normalImage: choice.normalStateImage,
                        selectedImage: choice.selectedStateImage,
                        text: choice.text!,
                        value: String(string)
                    )
                } else if let date = choice.value as? Date {
                    imageChoice = ImageChoice(
                        normalImage: choice.normalStateImage,
                        selectedImage: choice.selectedStateImage,
                        text: choice.text!,
                        value: date
                    )
                } else {
                    imageChoice = nil
                }
                
                return imageChoice
            }
            
            let style: ChoiceSelectionType = {
                switch imageChoiceAnswerFormat.style {
                case .singleChoice:
                    return .single
                case .multipleChoice:
                    return .multiple
                default: return .single
                }
            }()
            
            ImageChoiceQuestion(
                id: id,
                title: title ?? "",
                detail: detail,
                choices: choices,
                style: style,
                vertical: imageChoiceAnswerFormat.isVertical
            )
        default:
            EmptyView()
        }
    }
    
    private func answerOptions(for textChoices: [ORKTextChoice]) -> [MultipleChoiceOption] {
        textChoices.compactMap { textChoice in
            let multipleChoiceOption: MultipleChoiceOption?
            
            if let number = textChoice.value as? NSNumber {
                multipleChoiceOption = MultipleChoiceOption(
                    id: UUID().uuidString,
                    choiceText: textChoice.text,
                    value: number.intValue
                )
            } else if let string = textChoice.value as? NSString {
                multipleChoiceOption = MultipleChoiceOption(
                    id: UUID().uuidString,
                    choiceText: textChoice.text,
                    value: String(string)
                )
            } else if let date = textChoice.value as? Date {
                multipleChoiceOption = MultipleChoiceOption(
                    id: UUID().uuidString,
                    choiceText: textChoice.text,
                    value: date
                )
            } else {
                multipleChoiceOption = nil
            }
            
            return multipleChoiceOption
        }
    }
    
    @ViewBuilder
    private func build(_ instructionStep: ORKInstructionStep) -> some View {
        let image: Image? = {
            let image: Image?
            if let iconImage = instructionStep.iconImage {
                image = Image(uiImage: iconImage)
            } else {
                image = nil
            }
            return image
        }()
        
        ResearchFormStep(
            image: image,
            title: instructionStep.title,
            subtitle: instructionStep.text
        ) {
#if !os(watchOS)
            if let bodyItems = instructionStep.bodyItems {
                ForEach(Array(bodyItems.enumerated()), id: \.offset) { _, bodyItem in
                    let image: Image? = {
                        let image: Image?
                        if let bodyItemImage = bodyItem.image {
                            image = Image(uiImage: bodyItemImage)
                        } else {
                            image = nil
                        }
                        return image
                    }()
                    
                    let text: Text? = {
                        let text: Text?
                        if let bodyItemText = bodyItem.text, !bodyItemText.isEmpty {
                            text = Text(bodyItemText)
                        } else {
                            text = nil
                        }
                        return text
                    }()
                    
                    InstructionBodyItem(image: image, text: text)
                }
            }
#endif
        }
    }
    
    private func groupItems(_ items: [ORKFormItem]) -> [ORKFormItem] {
        var groupedItems: [ORKFormItem] = []
        var builder: ORKFormItem?

        for item in items {
            if builder == nil {
                builder = item
                continue
            }

            if hasMatchingIdentifiers(firstIdentifier: item.identifier, secondIdentifier: builder?.identifier ?? "") {
                let newFormItem = ORKFormItem(
                    identifier: item.identifier,
                    text: builder?.text,
                    answerFormat: item.answerFormat
                )
                newFormItem.placeholder = item.placeholder

                groupedItems.append(
                    newFormItem
                )
                builder = nil
            } else {
                if let safeBuilder = builder {
                    groupedItems.append(safeBuilder)
                    builder = item
                }
            }
        }
        if let builder {
            groupedItems.append(builder)
        }
        return groupedItems
    }
    
    private func hasMatchingIdentifiers(firstIdentifier: String, secondIdentifier: String) -> Bool {
        guard let firstUUID = extractUUID(firstIdentifier),
              let secondUUID = extractUUID(secondIdentifier) else { return false }

        return firstUUID == secondUUID
    }
    
    private func extractUUID(_ string: String) -> String? {
        let uuidRegex = "[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}"
        guard let range = string.range(of: uuidRegex, options: .regularExpression, range: nil, locale: nil) else {
            return nil
        }
        let uuidString = String(string[range])
        return uuidString
    }
    
}
