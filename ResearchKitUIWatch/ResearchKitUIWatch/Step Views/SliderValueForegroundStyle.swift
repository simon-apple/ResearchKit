//  SliderValueForegroundStyle.swift
//  ResearchKitUI(Watch)
//
//  Created by Simon Tsai on 6/5/24.
//

import SwiftUI

extension View {
    
    /// This foreground style is used for labels that display values associated with sliders.
    func sliderValueForegroundStyle() -> some View {
        modifier(
            SliderValueForegroundStyle()
        )
    }
    
}

/// This foreground style is used for labels that display values associated with sliders.
struct SliderValueForegroundStyle: ViewModifier {
    
    func body(content: Content) -> some View {
        content
#if os(iOS)
            .foregroundStyle(.blue)
#elseif os(visionOS)
            .foregroundStyle(Color(.label))
#endif
    }
    
}
