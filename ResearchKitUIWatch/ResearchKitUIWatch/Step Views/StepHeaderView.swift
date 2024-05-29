//
//  StepHeaderView.swift
//  ResearchKitUI(Watch)
//
//  Created by Simon Tsai on 5/23/24.
//

import SwiftUI

// TODO(x-plat): Add documentation.
struct StepHeaderView: View {
    
    @ObservedObject
    private var viewModel: FormStepViewModel
    
    init(viewModel: FormStepViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
#if os(iOS)
        // TODO(x-plat): Make biz logic exactly like in ORKCatalog.
        VStack(alignment: .leading) {
            // TODO(x-plat): Ensure same colors are used as in ORKCatalog.
            if let stepTitle = viewModel.step.title {
                Text(stepTitle)
                    .foregroundStyle(Color(uiColor: .label))
                    .font(.largeTitle)
                    .fontWeight(.bold)
            }
            
            if let stepDescription = viewModel.step.text {
                Text(stepDescription)
                    .foregroundStyle(Color(uiColor: .label))
                    .font(.body)
            }
        }
        .textCase(.none)
#else
        if let stepDescription = viewModel.step.text {
            // TODO(x-plat): Ensure same colors are used as in ORKCatalog.
            Text(stepDescription)
                .font(.body)
                .fontWeight(.semibold)
        }
#endif
    }
    
}

// TODO(x-plat): Update to make preview compile.
//#Preview {
//    @State
//    private var viewModel = FormStepViewModel(step: ORKFOrmS, result: <#T##ORKStepResult#>)
//    
//    StepHeaderView()
//}
