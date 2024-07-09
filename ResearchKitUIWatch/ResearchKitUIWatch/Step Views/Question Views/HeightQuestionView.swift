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

public struct HeightQuestion: Identifiable {

    public let id: String
    public let title: String
    public let detail: String?
    public let prompt: String
    public let primarySelection: Double?
    public let secondarySelection: Double?

    public init(
        id: String,
        title: String,
        detail: String?,
        prompt: String,
        primarySelection: Double?,
        secondarySelection: Double?
    ) {
        self.id = id
        self.title = title
        self.detail = detail
        self.prompt = prompt
        self.primarySelection = primarySelection
        self.secondarySelection = secondarySelection
    }

    public var number: NSNumber {
        return NSNumber(integerLiteral: 0)
    }
}

struct HeightQuestionView: View {
    @State var isInputActive = false
    @State var hasChanges: Bool

    let title: String
    let detail: String?

    @Binding var primarySelection: Double
    @Binding var secondarySelection: Double

    init(title: String,
         detail: String?,
         primarySelection: Binding<Double>,
         secondarySelection: Binding<Double>
    ) {
        self.hasChanges = false
        self.title = title
        self.detail = detail
        self._primarySelection = primarySelection
        self._secondarySelection = secondarySelection
    }

    var body: some View {
        FormItemCardView(title: title, detail: detail) {
            HStack {
                Button {
                    isInputActive = true
                } label: {
                    Text(hasChanges ? "\(primarySelection) \(secondarySelection)" : "Tap Here")
                        .foregroundStyle(Color.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                if hasChanges {
                    Button {
                        hasChanges = false
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(Color.gray)
                    }
                }
            }
            .padding()
            .sheet(isPresented: $isInputActive) {
                HeightPickerView(
                    primarySelection: $primarySelection,
                    secondarySelection: $secondarySelection,
                    hasChanges: $hasChanges
                )
                    .presentationDetents([.height(300)])
            }
        }
    }
}

struct HeightPickerView: View {
    @Environment(\.dismiss) var dismiss

    @Binding var primarySelection: Double
    @Binding var secondarySelection: Double
    @Binding var hasChanges: Bool

    var body: some View {
        VStack {
            HStack {
                Button {
                    dismiss()
                } label: {
                    Text("Done")
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
            }
            .padding(.horizontal)
            HStack(spacing: .zero) {
                Picker(selection: $primarySelection) {
                    ForEach(0..<400) { i in
                        Text("\(i)")
                    }
                } label: {
                    Text("Tap Here")
                }
                .pickerStyle(.wheel)
                .onChange(of: primarySelection) { _, _ in
                    hasChanges = true
                }
                Picker(selection: $secondarySelection) {
                    ForEach(0..<400) { i in
                        Text("\(i)")
                    }
                } label: {
                    Text("Tap Here")
                }
                .pickerStyle(.wheel)
                .onChange(of: secondarySelection) { _, _ in
                    hasChanges = true
                }
            }
        }
    }
}


@available(iOS 18.0, *)
#Preview {
    @Previewable @State var primarySelection: Double = 22
    @Previewable @State var secondarySelection: Double = 2
    HeightQuestionView(
        title: "Height question here",
        detail: nil,
        primarySelection: $primarySelection,
        secondarySelection: $secondarySelection
    )
}

