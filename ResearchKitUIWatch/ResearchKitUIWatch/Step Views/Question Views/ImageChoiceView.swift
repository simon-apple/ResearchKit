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

struct ImageChoice: Identifiable {
    let id: UUID
    let normalImage: UIImage
    let selectedImage: UIImage?
    let text: String
    let value: Int
}

struct ImageChoiceQuestion {
    public enum ChoiceSelectionType {
        case single, multiple
    }

    let choices: [ImageChoice]
    let style: ChoiceSelectionType
    let vertical: Bool
}

struct ImageChoiceView: View {
    let title: String
    let detail: String?
    let choices: [ImageChoice]
    let style: ImageChoiceQuestion.ChoiceSelectionType
    let vertical: Bool

    @Binding var selection: [Int]

    var selectionText: String {
        guard selection.isEmpty == false else {
            return ""
        }
        let strings: [String] = {
            var strings: [String] = []
            for i in selection.sorted() {
                if let choice = choices.first(where: { $0.value == i }) {
                    strings.append(choice.text)
                }
            }
            return strings
        }()

        return strings.joined(separator: ", ")
    }

    var body: some View {
        FormItemCardView(title: title, detail: detail) {
            VStack {
                if style == .multiple {
                    Text("SELECT ALL THAT APPLY")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
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
                Text(selectionText)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .frame(minHeight: 24)
            }
        }
    }

    @ViewBuilder
    func imageChoices() -> some View {
        ForEach(choices, id: \.id) { choice in
            Button {
                if let index = selection.firstIndex(where: { $0 == choice.value }) {
                    selection.remove(at: index)
                } else {
                    selection.append(choice.value)
                }
            } label: {
                if selection.contains(choice.value) {
                    Image(uiImage: choice.selectedImage ?? choice.normalImage)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(choice.selectedImage == nil ? Color(uiColor: .systemGray5) : Color.clear)
                        .cornerRadius(12)
                } else {
                    Image(uiImage: choice.normalImage)
                        .padding()
                        .frame(maxWidth: .infinity)
                }

            }
        }
    }
}

#Preview {
    @Previewable @State var selection: [Int] = []
    ImageChoiceView(
        title: "Which do you prefer?",
        detail: nil,
        choices: [
            ImageChoice(
                id: UUID(),
                normalImage: UIImage(systemName: "checkmark.circle")!,
                selectedImage: nil,
                text: "Circle",
                value: 0
            ),
            ImageChoice(
                id: UUID(),
                normalImage: UIImage(systemName: "checkmark.square")!,
                selectedImage: nil,
                text: "Square",
                value: 1
            ),
        ],
        style: .single,
        vertical: false,
        selection: $selection
    )
}
