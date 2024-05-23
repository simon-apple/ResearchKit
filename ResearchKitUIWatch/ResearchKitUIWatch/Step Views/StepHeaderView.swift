//
//  StepHeaderView.swift
//  ResearchKitUI(Watch)
//
//  Created by Simon Tsai on 5/23/24.
//

import SwiftUI

// TODO(x-plat): Add documentation.
struct StepHeaderView: View {
    
    @State
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
            
            if let text = viewModel.step.text {
                Text(text)
                    .foregroundStyle(Color(uiColor: .label))
                    .font(.body)
            }
        }
        .textCase(.none)
#else
        if let text = viewModel.step.text {
            HStack {
                Spacer()
                
                // TODO(x-plat): Ensure same colors are used as in ORKCatalog.
                Text(text)
                    .multilineTextAlignment(.center)
                    .font(.body)
                    .fontWeight(.semibold)
                
                Spacer()
            }
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
