//
//  StepHeaderView.swift
//  ResearchKitUI(Watch)
//
//  Created by Simon Tsai on 5/23/24.
//

import SwiftUI

struct StepHeaderView: View {
    
    private let stepTitleTopSpacing: CGFloat = 15
    private let stepDescriptionTopSpacing: CGFloat = 15
    
    @ObservedObject
    private var viewModel: FormStepViewModel
    
    init(viewModel: FormStepViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
#if os(iOS)
        // TODO(rdar://128955005): Make biz logic exactly like in ORKCatalog.
        VStack(alignment: .leading) {
            // TODO(rdar://128955005): Ensure same colors are used as in ORKCatalog.
            if let stepTitle = viewModel.step.title {
                Spacer()
                    .frame(height: stepTitleTopSpacing)
                
                Text(stepTitle)
                    .foregroundStyle(Color(uiColor: .label))
                    .font(.largeTitle)
                    .fontWeight(.bold)
            }
            
            if let stepDescription = viewModel.step.text {
                Spacer()
                    .frame(height: stepDescriptionTopSpacing)
                
                Text(stepDescription)
                    .foregroundStyle(Color(uiColor: .label))
                    .font(.body)
            }
            
            Spacer()
                .frame(height: 35)
        }
        .textCase(.none)
#else
        if let stepDescription = viewModel.step.text {
            VStack {
                Text(stepDescription)
                    .foregroundStyle(Color(uiColor: .label))
                    .font(.body)
                    .fontWeight(.semibold)
                
                Spacer()
                    .frame(height: 35)
            }
        }
#endif
    }
    
}
