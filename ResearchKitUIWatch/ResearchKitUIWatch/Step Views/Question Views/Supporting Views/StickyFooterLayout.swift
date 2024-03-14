//
//  StickyFooterLayout.swift
//  ResearchKitUI(Watch)
//
//  Created by Jessi Aboukasm on 3/13/24.
//


//
//  StickyScrollView+StickyFooterLayout.swift
//  HARPUI
//
//  Created by Andrew Plummer on 9/10/2022.
//

import SwiftUI

extension StickyScrollView {

    struct StickyFooterLayout: Layout {

        let safeAreaInsets: EdgeInsets

        func sizeThatFits(
            proposal: ProposedViewSize,
            subviews: Subviews,
            cache: inout Void
        ) -> CGSize {

            let contentHeight = subviews[0].dimensions(in: proposal).height

            return CGSize(
                width: proposal.replacingUnspecifiedDimensions().width,
                height: contentHeight + safeAreaInsets.bottom
            )
        }

        func placeSubviews(
            in bounds: CGRect,
            proposal: ProposedViewSize,
            subviews: Subviews,
            cache: inout Void
        ) {
            let content = subviews[0]
            let contentPlacementProposal = ProposedViewSize(
                width: bounds.width,
                height: .infinity
            )
            content.place(
                at: CGPoint(
                    x: bounds.origin.x,
                    y: bounds.origin.y
                ),
                anchor: .topLeading,
                proposal: contentPlacementProposal
            )
        }
    }

}

