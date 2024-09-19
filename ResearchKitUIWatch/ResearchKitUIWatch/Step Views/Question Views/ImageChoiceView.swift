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

import SwiftUI

public struct ImageChoice: Identifiable, Equatable {
    public let id: String
    public let normalImage: UIImage
    public let selectedImage: UIImage?
    public let text: String
    public let value: ResultValue

    public init(
        normalImage: UIImage,
        selectedImage: UIImage?,
        text: String,
        value: ResultValue
    ) {
        self.id = String(describing: value)
        self.normalImage = normalImage
        self.selectedImage = selectedImage
        self.text = text
        self.value = value
    }

    public static func == (lhs: ImageChoice, rhs: ImageChoice) -> Bool {
        return lhs.id == rhs.id && lhs.text == rhs.text
    }
}
public struct ImageChoiceQuestion: Identifiable {
    public enum ChoiceSelectionType {
        case single, multiple
    }
    public let title: String
    public let detail: String?
    public let id: String
    public let choices: [ImageChoice]
    public let style: ChoiceSelectionType
    public let vertical: Bool
    public let selections: [ResultValue]
}

public struct ImageChoiceView: View {
    
    @Environment(\.questionProgress)
    private var questionProgress
    
    @EnvironmentObject
    private var managedTaskResult: ResearchTaskResult

    let id: String
    let title: String
    let detail: String?
    let choices: [ImageChoice]
    let style: ImageChoiceQuestion.ChoiceSelectionType
    let vertical: Bool
    private let result: StateManagementType<[ResultValue]>

    private var resolvedResult: Binding<[ResultValue]> {
        switch result {
        case .automatic(let key):
            return Binding(
                get: { managedTaskResult.resultForStep(key: key) ?? [] },
                set: { managedTaskResult.setResultForStep(.image($0), key: key) }
            )
        case .manual(let value):
            return value
        }
    }

    public init(
        id: String,
        title: String,
        detail: String?,
        choices: [ImageChoice],
        style: ImageChoiceQuestion.ChoiceSelectionType,
        vertical: Bool,
        result: Binding<[ResultValue]>
    ) {
        self.id = id
        self.title = title
        self.detail = detail
        self.choices = choices
        self.style = style
        self.vertical = vertical
        self.result = .manual(result)
    }

    public init(
        id: String,
        title: String,
        detail: String?,
        choices: [ImageChoice],
        style: ImageChoiceQuestion.ChoiceSelectionType,
        vertical: Bool
    ) {
        self.id = id
        self.title = title
        self.detail = detail
        self.choices = choices
        self.style = style
        self.vertical = vertical
        self.result = .automatic(key: .imageChoice(id: id))
    }

    public var body: some View {
        QuestionCardView {
            QuestionView(title: title) {
                VStack {
                    if style == .multiple {
                        multipleSelectionHeader()
                    }
                    
                    if vertical {
                        VStack {
                            imageChoices()
                        }
                        .padding()
                    } else {
                        HStack {
                            imageChoices()
                        }
                        .padding()
                    }
                    selectionText()
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding()
                }
            }
        }
        .preference(key: IDPreferenceKey.self, value: id)
    }

    @ViewBuilder
    func selectionText() -> some View {
        if resolvedResult.wrappedValue.isEmpty {
            Text("Tap to select")
                    .foregroundStyle(.secondary)
        } else {
            let strings: [String] = {
                var strings: [String] = []
                for i in resolvedResult.wrappedValue {
                    if let choice = choices.first(where: { $0.value == i }) {
                        strings.append(choice.text)
                    }
                }
                return strings
            }()

            Text(strings.joined(separator: ", "))
                    .foregroundStyle(.primary)
        }
    }

    @ViewBuilder
    func imageChoices() -> some View {
        ForEach(choices, id: \.id) { choice in
            Button {
                if let index = resolvedResult.wrappedValue.firstIndex(where: { $0 == choice.value }) {
                    resolvedResult.wrappedValue.remove(at: index)
                } else {
                    resolvedResult.wrappedValue.append(choice.value)
                }
            } label: {
                if resolvedResult.wrappedValue.contains(where: { $0 == choice.value }) {
                    Image(uiImage: choice.selectedImage ?? choice.normalImage)
                        .resizable()
                        .imageSizeConstraints()
                        .scaledToFit()
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(choice.selectedImage == nil ? Color.choice(for: .systemGray5) : Color.clear)
                        .cornerRadius(24)
                        .imageChoiceHoverEffect()
                } else {
                    Image(uiImage: choice.normalImage)
                        .resizable()
                        .imageSizeConstraints()
                        .scaledToFit()
                        .padding()
                        .frame(maxWidth: .infinity)
                        .cornerRadius(24)
                        .imageChoiceHoverEffect()
                        .contentShape(Capsule())
                }
                
            }
            .buttonStyle(.plain)
        }
    }
    
    @ViewBuilder
    private func multipleSelectionHeader() -> some View {
#if !os(watchOS)
        Text("SELECT ALL THAT APPLY")
            .font(.caption)
            .fontWeight(.semibold)
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding([.horizontal, .top])
        Divider()
#else
        Text("SELECT ALL THAT APPLY")
            .lineLimit(1)
            .minimumScaleFactor(0.5)
            .font(.caption2)
            .fontWeight(.semibold)
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)
#endif
    }
}

fileprivate extension View {
    func imageChoiceHoverEffect() -> some View {
        self
#if !os(watchOS)
            .contentShape(.hoverEffect, RoundedRectangle(cornerRadius: 24))
            .hoverEffect()
#endif
    }
    
    func imageSizeConstraints() -> some View {
        self
#if !os(watchOS)
            .frame(
                minWidth: 10, maxWidth: 50,
                minHeight: 10, maxHeight: 50
            )
#else
            .frame(
                minWidth: 10, maxWidth: 30,
                minHeight: 10, maxHeight: 30
            )
#endif
    }
}

#Preview {
    @Previewable @State var selection: [ResultValue] = []
    ScrollView {
        ImageChoiceView(
            id: UUID().uuidString,
            title: "Which do you prefer?",
            detail: nil,
            choices: [
                ImageChoice(
                    normalImage: UIImage(systemName: "carrot")!,
                    selectedImage: nil,
                    text: "carrot",
                    value: .int(0)
                ),
                ImageChoice(
                    normalImage: UIImage(systemName: "birthday.cake")!,
                    selectedImage: nil,
                    text: "cake",
                    value: .int(1)
                ),
            ],
            style: .multiple,
            vertical: false,
            result: $selection
        )
    }
}
