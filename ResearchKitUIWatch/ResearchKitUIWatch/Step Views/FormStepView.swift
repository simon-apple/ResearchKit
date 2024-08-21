/*
 Copyright (c) 2020, Apple Inc. All rights reserved.
 
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

// apple-internal

import ResearchKit
import SwiftUI

struct FormStepView: View {

    @ObservedObject
    private var viewModel: FormStepViewModel
    
    @Environment(\.completion) var completion
    @Environment(\.dismiss) var dismiss
    
    public init(viewModel: FormStepViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        StickyScrollView(allowsExtendedLayout: true) {
            VStack(alignment: .leading) {
                ListHeaderView {
                    let image: Image? = {
                        let image: Image?
                        
                        if let uiImage = viewModel.step.iconImage {
                            image = Image(uiImage: uiImage)
                        } else {
                            image = nil
                        }
                        return image
                    }()
                    
                    let title: Text? = {
                        let title: Text?
                        if let stepTitle = viewModel.step.title {
                            title = Text(stepTitle)
                        } else {
                            title = nil
                        }
                        return title
                    }()
                    
                    let subtitle: Text? = {
                        let subtitle: Text?
                        if let subtitleTitle = viewModel.step.text {
                            subtitle = Text(subtitleTitle)
                        } else {
                            subtitle = nil
                        }
                        return subtitle
                    }()
                    
                    StepHeaderView(
                        image: image,
                        title: title,
                        subtitle: subtitle
                    )
                }
                ForEach(Array($viewModel.formRows.enumerated()), id: \.offset) { index, $formRow in
                    FormRowContent(
                        detail: "Step \(index + 1) of \(viewModel.formRows.count)",
                        formRow: $formRow
                    )
                }
            }
            .padding()
        } footerContent: {
            Button {
                completion(true)
                dismiss()
            } label: {
                HStack {
                    Text("Done")
                        .fontWeight(.bold)
                        .frame(maxWidth: maxWidthForDoneButton)
                }
                .padding(.vertical, 8)
            }
            .buttonStyle(.borderedProminent)
            .padding(.top, 16)
        }
        .background(Color.choice(for: .secondaryBackground))
    }
    
    private var maxWidthForDoneButton: CGFloat {
#if os(visionOS)
        300
#else
        .infinity
#endif
    }
}
