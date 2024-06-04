//
//  ListHeaderView.swift
//  ResearchKitUI(Watch)
//
//  Created by Simon Tsai on 5/23/24.
//

import SwiftUI

struct ListHeaderView<Content: View>: View {
    
    private let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        Section(
            content: {
                EmptyView()
            },
            header: {
                content
            }
        )
        .listSectionSpacing(.custom(0))
        .listRowInsets(EdgeInsets())
    }
    
}

#Preview {
    ListHeaderView {
        Text("List header")
    }
}
