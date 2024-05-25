//
//  ListHeaderView.swift
//  ResearchKitUI(Watch)
//
//  Created by Simon Tsai on 5/23/24.
//

import SwiftUI

// TODO(x-plat): Add documentation.
struct ListHeaderView: View {
    
    @ObservedObject
    private var viewModel: FormStepViewModel
    
    init(viewModel: FormStepViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        Section(
            content: {
                EmptyView()
            },
            header: {
                StepHeaderView(viewModel: viewModel)
            }
        )
    }
    
}

// TODO(x-plat): Update to make preview compile.
//#Preview {
//    ListHeaderView()
//}
