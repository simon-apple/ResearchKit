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

/// A card that displays a header view, a divider line, and an answer view.

public struct FormItemCardView<Header: View, Content: View>: View {
    @Environment(\.colorScheme) var colorScheme
    let header: Header
    let content: Content

    init(
        @ViewBuilder header: () -> Header,
        @ViewBuilder content: () -> Content
    ) {
        self.header = header()
        self.content = content()
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: .zero) {
            header

            Divider()
                .padding(.horizontal)

            content
        }
        .background(.cardColor)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

extension ShapeStyle where Self == CardColor {
    
    static var cardColor: CardColor {
        CardColor()
    }
    
}

struct CardColor: ShapeStyle {
    
    func resolve(in environment: EnvironmentValues) -> some ShapeStyle {
#if os(visionOS)
        .regularMaterial
#else
        environment.colorScheme == .dark ? Color.choice(for: .systemGray4) : .white
#endif
    }
    
}

public extension FormItemCardView where Header == _SimpleFormItemViewHeader {
    init(
        title: String,
        detail: String?,
        content: () -> Content
    ) {
        self.header = _SimpleFormItemViewHeader(title: title, detail: detail)
        self.content = content()
    }
}

/// The default header used by a `FormItemCardView`
public struct _SimpleFormItemViewHeader: View {
    @Environment(\.researchQuestionIsOptional)
    private var isOptional
    
    let title: String
    let detail: String?
    
    private var showDetailText: Bool {
        detail?.isEmpty == false
    }

    public var body: some View {
        VStack(alignment: .leading) {
            if !isOptional {
                Text("Required")
            }
            
            if let detail, showDetailText {
                detailText(detail)
            }

            titleText(title)
        }
    }
    
    @ViewBuilder
    private func detailText(_ text: String) -> some View {
        Text(text)
            .foregroundColor(.secondary)
            .font(.footnote)
        #if os(watchOS)
            .padding([.horizontal])
            .padding(.top, 4)
        #else
            .fontWeight(.bold)
            .padding([.horizontal, .top])
        #endif
    }
    
    @ViewBuilder
    private func titleText(_ text: String) -> some View {
        Text(title)
            .foregroundStyle(Color.choice(for: .label))
            .fontWeight(.bold)
        #if os(watchOS)
            .font(.footnote)
            .padding(.horizontal)
            .padding(.bottom, 4)
            .padding(.top, showDetailText ? 0 : 4)
        #else
            .font(.body)
            .padding()
        #endif
    }
}

#Preview("Detail and Title") {
    VStack {
        Spacer()
        FormItemCardView(title: "What is your name?", detail: "Question 1 of 3") {
            Text("Specific component content will show up here")
        }
        Spacer()
    }
    .padding()
    .background {
        Color.choice(for: .secondaryBackground)
    }
    .ignoresSafeArea()
}

#Preview("Just title") {
    VStack {
        Spacer()
        FormItemCardView(title: "What is your name?", detail: nil) {
            Text("Specific component content will show up here")
        }
        Spacer()
    }
    .padding()
    .background {
        Color.choice(for: .secondaryBackground)
    }
    .ignoresSafeArea()
}
