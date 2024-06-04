//  ListRowSeparatorInsetStyle.swift
//  ResearchKitUI(Watch)
//
//  Created by Simon Tsai on 5/30/24.
//

import SwiftUI

extension View {
    
    /// This style is applicable to the List type. It modifies the list row separator associated with the modified view
    /// such that the leading edge of said list row separator extends to the leading edge of the list containing
    /// the modified view.
    ///
    /// While this style serves a very specific purpose at the time of writing, it can be generalized to account for
    /// additional use cases.
    func listRowSeparatorSectionInsetStyle() -> some View {
        modifier(
            ListRowSeparatorSectionInsetStyle()
        )
    }
    
}

/// This style is applicable to the List type. It modifies the list row separator associated with the modified view
/// such that the leading edge of said list row separator extends to the leading edge of the list containing
/// the modified view.
///
/// While this style serves a very specific purpose at the time of writing, it can be generalized to account for
/// additional use cases.
struct ListRowSeparatorSectionInsetStyle: ViewModifier {
    
    private let defaultLeadingPadding: CGFloat = 20
    
    func body(content: Content) -> some View {
        content
            .alignmentGuide(
                .listRowSeparatorLeading,
                computeValue: { dimension in
                    dimension[.leading] - defaultLeadingPadding
                }
            )
    }
    
}
