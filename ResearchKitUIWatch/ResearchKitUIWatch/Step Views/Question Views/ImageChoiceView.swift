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

public struct ImageChoice: Identifiable {
    public let id: UUID
    public let normalImage: UIImage
    public let selectedImage: UIImage?
    public let text: String
    public let value: Int
    
    public init(id: UUID, normalImage: UIImage, selectedImage: UIImage?, text: String, value: Int) {
        self.id = id
        self.normalImage = normalImage
        self.selectedImage = selectedImage
        self.text = text
        self.value = value
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
    public let selections: [Int]
}

public struct ImageChoiceView: View {
    @EnvironmentObject
    private var managedTaskResult: ResearchTaskResult

    let id: String
    let title: String
    let detail: String?
    let choices: [ImageChoice]
    let style: ImageChoiceQuestion.ChoiceSelectionType
    let vertical: Bool
    private let result: StateManagementType<[Int]>

    private var resolvedResult: Binding<[Int]> {
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
        result: Binding<[Int]>
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
        FormItemCardView(title: title, detail: detail) {
            VStack {
                if style == .multiple {
                    Text("SELECT ALL THAT APPLY")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding([.horizontal, .top])
                    Divider()
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

    @ViewBuilder
    func selectionText() -> some View {
        if resolvedResult.wrappedValue.isEmpty {
            Text("Tap to select")
                    .foregroundStyle(.secondary)
        } else {
            let strings: [String] = {
                var strings: [String] = []
                for i in resolvedResult.wrappedValue.sorted() {
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
                if resolvedResult.wrappedValue.contains(choice.value) {
                    Image(uiImage: choice.selectedImage ?? choice.normalImage)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(choice.selectedImage == nil ? Color.choice(for: .systemGray5) : Color.clear)
                        .cornerRadius(24)
#if !os(watchOS)
                       .contentShape(.hoverEffect, RoundedRectangle(cornerRadius: 24))
                       .hoverEffect()
#endif
                }
            }
            .buttonStyle(.plain)
        }
    }
}

#Preview {
    @Previewable @State var selection: [Int] = []
    ImageChoiceView(
        id: UUID().uuidString,
        title: "Which do you prefer?",
        detail: nil,
        choices: [
            ImageChoice(
                id: UUID(),
                normalImage: UIImage(named: "carrot")!,
                selectedImage: nil,
                text: "carrot",
                value: 0
            ),
            ImageChoice(
                id: UUID(),
                normalImage: UIImage(systemName: "cake")!,
                selectedImage: nil,
                text: "cake",
                value: 1
            ),
        ],
        style: .single,
        vertical: true,
        result: $selection
    )
}
