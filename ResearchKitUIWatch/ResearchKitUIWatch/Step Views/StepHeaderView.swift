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

struct StepHeaderView: View {
    
    private let stepTitleTopSpacing: CGFloat = 15
    private let stepDescriptionTopSpacing: CGFloat = 15
    private let bottomSpacing: CGFloat = 35
    
    @ObservedObject
    private var viewModel: FormStepViewModel
    
    init(viewModel: FormStepViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        VStack(alignment: alignment) {
#if os(iOS)
            if let stepTitle = viewModel.step.title {
                Spacer()
                    .frame(height: stepTitleTopSpacing)
                
                Text(stepTitle)
                    .foregroundStyle(Color(uiColor: .label))
                    .font(.largeTitle)
                    .fontWeight(.bold)
            }
#endif
            
            if let stepDescription = viewModel.step.text {
                topSpacingForStepDescription()
                
                text(for: stepDescription)
                
                Spacer()
                    .frame(height: bottomSpacing)
            }
        }
        .textCase(.none)
    }
    
    @ViewBuilder
    private func text(for stepDescription: String) -> some View {
        Text(stepDescription)
            .foregroundStyle(Color.choice(for: .label))
            .font(.body)
#if os(visionOS)
            .fontWeight(.semibold)
#endif
    }
    
    @ViewBuilder
    private func topSpacingForStepDescription() -> some View {
#if os(visionOS)
        EmptyView()
#else
        Spacer()
            .frame(height: stepDescriptionTopSpacing)
#endif
    }
    
    private var alignment: HorizontalAlignment {
#if os(visionOS)
        .center
#else
        .leading
#endif
    }
}

// StepHeaderView and HeaderView can potentially be merged in the future.
struct HeaderView: View {
    
    private let image: Image?
    private let title: Text?
    private let subtitle: Text?
    
    init(image: Image? = nil, title: Text? = nil, subtitle: Text? = nil) {
        self.image = image
        self.title = title
        self.subtitle = subtitle
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            image?
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 80, height: 80)
                .foregroundStyle(.stepIconForegroundStyle)
            
            title?
                .font(.title)
                .fontWeight(.bold)
            
            subtitle
        }
    }
    
}
