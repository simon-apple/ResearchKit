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
import SwiftUI

public extension ResearchForm where Content == TaskAdaptation {
    
    init(
        taskIdentifier: String,
        task: ORKOrderedTask,
        onResearchTaskCompletion: ((ResearchTaskCompletion) -> Void)? = nil
    ) {
        self.init(
            taskIdentifier: taskIdentifier,
            steps: {
                TaskAdaptation(task: task)
            },
            onResearchTaskCompletion: onResearchTaskCompletion
        )
    }
    
}

public struct TaskAdaptation: View {
    
    private let task: ORKOrderedTask
    
    init(task: ORKOrderedTask) {
        self.task = task
    }
    
    public var body: some View {
        ForEach(task.steps, id: \.identifier) { step in
            researchFormStep(for: step)
        }
    }
    
    @ViewBuilder
    private func researchFormStep(for step: ORKStep) -> some View {
        if let formStep = step as? ORKFormStep {
            ResearchFormStep(title: formStep.title, subtitle: formStep.detailText) {
                if let formItems = formStep.formItems {
                    ForEach(groupItems(formItems), id: \.identifier) { formItem in
                        if let answerFormat = formItem.answerFormat {
                            switch answerFormat {
                            case let textChoiceAnswerFormat as ORKTextChoiceAnswerFormat:
                                MultipleChoiceQuestionView(
                                    id: formItem.identifier,
                                    title: formItem.text ?? "",
                                    choices: textChoiceAnswerFormat.textChoices.map { textChoice in
                                        MultipleChoiceOption(
                                            id: UUID().uuidString,
                                            choiceText: textChoice.text,
                                            value: textChoice.value
                                        )
                                    },
                                    selectionType: textChoiceAnswerFormat.style == .singleChoice ? .single : .multiple
                                )
                            case let scaleAnswerFormat as ORKScaleAnswerFormat:
                                InputManagedScaleSliderQuestion(
                                    id: formItem.identifier,
                                    title: formItem.text ?? "",
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
                                
                                InputManagedScaleSliderQuestion(
                                    id: formItem.identifier,
                                    title: formItem.text ?? "",
                                    range: continuousScaleAnswerFormat.minimum...continuousScaleAnswerFormat.maximum,
                                    step: stepSize,
                                    selection: continuousScaleAnswerFormat.defaultValue
                                )
                            case let textChoiceScaleAnswerFormat as ORKTextScaleAnswerFormat:
                                let answerOptions = textChoiceScaleAnswerFormat.textChoices.map { textChoice in
                                    MultipleChoiceOption(
                                        id: UUID().uuidString,
                                        choiceText: textChoice.text,
                                        value: textChoice.value
                                    )
                                }
                                
                                if answerOptions.indices.contains(textChoiceScaleAnswerFormat.defaultIndex) {
                                    InputManagedScaleSliderQuestion(
                                        id: formItem.identifier,
                                        title: formItem.text ?? "",
                                        multipleChoiceOptions: answerOptions,
                                        selection: answerOptions[textChoiceScaleAnswerFormat.defaultIndex]
                                    )
                                }
                            case let textAnswerFormat as ORKTextAnswerFormat:
                                TextQuestionView(
                                    id: formItem.identifier,
                                    title: formItem.text ?? "",
                                    detail: "",
                                    prompt: formItem.placeholder,
                                    textFieldType: textAnswerFormat.multipleLines ? .multiline : .singleLine,
                                    characterLimit: textAnswerFormat.maximumLength,
                                    hideCharacterCountLabel: textAnswerFormat.hideCharacterCountLabel,
                                    hideClearButton: textAnswerFormat.hideClearButton,
                                    defaultTextAnswer: textAnswerFormat.defaultTextAnswer
                                )
                            case let dateTimeAnswerFormat as ORKDateAnswerFormat:
                                let prompt: String = {
                                    if let placeholder = formItem.placeholder {
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
                                
                                DateTimeView(
                                    id: formItem.identifier,
                                    title: formItem.text ?? "",
                                    pickerPrompt: prompt,
                                    displayedComponents: components,
                                    range: startDate...endDate
                                )
#if !os(watchOS)
                            case let numericAnswerFormat as ORKNumericAnswerFormat:
                                NumericQuestionView(
                                    id: formItem.identifier,
                                    text: numericAnswerFormat.defaultNumericAnswer?.decimalValue,
                                    title: formItem.text ?? "",
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

                                HeightQuestionView(
                                    id: formItem.identifier,
                                    title: formItem.text ?? "",
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
                                
                                WeightQuestionView(
                                    id: formItem.identifier,
                                    title: formItem.text ?? "",
                                    measurementSystem: measurementSystem,
                                    precision: precision,
                                    defaultValue: defaultValue,
                                    minimumValue: minimumValue,
                                    maximumValue: maximumValue
                                )
                            case let imageChoiceAnswerFormat as ORKImageChoiceAnswerFormat:
                                let choices = imageChoiceAnswerFormat.imageChoices.map { choice in
                                    return ImageChoice(
                                        id: UUID(),
                                        normalImage: choice.normalStateImage,
                                        selectedImage: choice.selectedStateImage,
                                        text: choice.text!,
                                        value: choice.value
                                    )
                                }

                                let style: ImageChoiceQuestion.ChoiceSelectionType = {
                                    switch imageChoiceAnswerFormat.style {
                                        case .singleChoice:
                                        return .single
                                    case .multipleChoice:
                                        return .multiple
                                    default: return .single
                                    }
                                }()

                                ImageChoiceView(
                                    id: formItem.identifier,
                                    title: formItem.text ?? "",
                                    detail: formItem.detailText,
                                    choices: choices,
                                    style: style,
                                    vertical: imageChoiceAnswerFormat.isVertical
                                )
                            default:
                                EmptyView()
                            }
                        }
                    }
                }
            }
        } else if let questionStep = step as? ORKQuestionStep {
            ResearchFormStep(title: questionStep.title, subtitle: questionStep.detailText) {
                InputManagedQuestionView(
                    id: questionStep.identifier,
                    question: questionStep.question ?? "",
                    answer: RKAdapter.createFormRow(from: questionStep, for: questionStep.answerFormat!)!
                )
            }
        } else if let instructionStep = step as? ORKInstructionStep {
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
                        HStack {
                            if let image = bodyItem.image {
                                Image(uiImage: image)
                                    .frame(width: 40, height: 40)
                                    .foregroundStyle(.bodyItemIconForegroundStyle)
                            }
                            
                            Text(bodyItem.text ?? "")
                                .font(.subheadline)
                        }
                    }
                }
#endif
            }
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
