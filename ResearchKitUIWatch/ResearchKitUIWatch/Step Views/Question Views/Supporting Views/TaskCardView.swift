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

public struct TaskCardView<Content: View>: View {
    @Environment(\.colorScheme) var colorScheme

    let title: Text?
    let detail: Text?
    let content: Content

    public init(title: Text?,
         detail: Text?,
         @ViewBuilder content: () -> Content
    ) {
        self.content = content()
        self.title = title
        self.detail = detail
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let detail {
                detail
                    .foregroundColor(.secondary)
                    .font(.footnote)
                    .fontWeight(.bold)
            }

            if let title {
                title
                    .foregroundStyle(Color(.label))
                    .font(.body)
                    .fontWeight(.bold)
            }

            if title != nil || detail != nil {
                Divider()
                    .padding(.vertical, 8)
            }

            content
        }
        .padding()
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
#if os(iOS)
        environment.colorScheme == .dark ? Color(uiColor: .systemGray5) : .white
#elseif os(visionOS)
        .regularMaterial
#endif
    }
    
}

struct TaskCardView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Spacer()
            TaskCardView(title: Text("What is your name?"), detail: Text("Question 1 of 3")) {
                Text("Specific component content will show up here")
            }
            Spacer()
        }
        .background {
            Color(.secondarySystemBackground)
        }
        .ignoresSafeArea()
    }
}
