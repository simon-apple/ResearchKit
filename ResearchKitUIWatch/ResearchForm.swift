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

public struct ResearchForm: View {
    
    @State private var navigationPaths: [String] = []
    
    private let content: [InstructionStepp]
    
    public init(@ResearchFormBuilder content: () -> [InstructionStepp]) {
        self.content = content()
    }
    
    public var body: some View {
        NavigationStack(path: $navigationPaths) {
            step(
                content: {
                    if let firstContent = content.first {
                        firstContent
                    }
                },
                action: {
                    navigationPaths.append(content[1].id.uuidString)
                }
            )
            .navigationDestination(for: String.self) { navigationPath in
                step(
                    content: {
                        content.first(where: { $0.id.uuidString == navigationPath })
                    },
                    action: {
                        
                    }
                )
            }
        }
    }
    
    @ViewBuilder
    private func step(@ViewBuilder content: @escaping () -> some View, action: @escaping () -> Void) -> some View {
        StickyScrollView(
            bodyContent: {
                content()
                    .padding()
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button {
                                
                            } label: {
                                Text("Cancel")
                            }
                        }
                    }
            },
            footerContent: {
                Button(
                    action: action,
                    label: {
                        Text("Next")
                    }
                )
            }
        )
    }
    
}

#Preview {
    ResearchForm {
        InstructionStepp(
            image: Image(systemName: "hand.wave"),
            title: Text("Welcome"),
            subtitle: Text("Thank you for joining our study. Tap Next to learn more before signing up.")
        )
    }
}

public struct InstructionStepp: View {
    
    let id = UUID()
    private let image: Image?
    private let title: Text?
    private let subtitle: Text?
    
    public init(image: Image?, title: Text?, subtitle: Text?) {
        self.image = image
        self.title = title
        self.subtitle = subtitle
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HeaderView(
                image: image,
                title: title,
                subtitle: subtitle
            )
        }
    }
    
}

@resultBuilder
public struct ResearchFormBuilder {
    
    public static func buildBlock(_ components: InstructionStepp...) -> [InstructionStepp] {
        components
    }
    
}
