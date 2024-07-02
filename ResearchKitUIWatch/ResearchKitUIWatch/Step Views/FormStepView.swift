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
                    StepHeaderView(viewModel: viewModel)
                }
                ForEach(Array($viewModel.formRows.enumerated()), id: \.offset) { index, $formRow in
                    RKAdapter.content(
                        title: "\(formRow.title)",
                        detail: "Step \(index + 1) of \(viewModel.formRows.count)",
                        for: $formRow
                    )
                }
            }
            .padding()
    #if os(visionOS)
            .navigationTitle(
                Text(viewModel.step.title ?? "")
            )
    #endif
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
        .background(Color(uiColor: .secondarySystemBackground))
    }
    
    private var maxWidthForDoneButton: CGFloat {
#if os(iOS)
        .infinity
#elseif os(visionOS)
        300
#endif
    }
    
}
