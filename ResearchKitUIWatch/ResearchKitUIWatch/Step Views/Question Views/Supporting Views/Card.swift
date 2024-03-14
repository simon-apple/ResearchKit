//
//  Card.swift
//  ORKVisionTestApp
//
//  Created by Jessi Aboukasm on 3/1/24.
//

import SwiftUI

public struct CardView<Content: View>: View {

    // MARK: - Properties

    private var stackedContent: some View {
        VStack(alignment: .leading, content: {
            content
        })
    }

    private let content: Content

    @ViewBuilder public var body: some View {
        stackedContent
            .modifier(CardModifier())
    }

    // MARK: - Init

    /// Create a card with injected content.
    /// - Parameter content: Content view injected into the card.
    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
}

private struct CardModifier: ViewModifier {

    private var cardShape: RoundedRectangle {
        RoundedRectangle(cornerRadius: 12, style: .continuous)
    }

    func body(content: Content) -> some View {
        content
            .background(
                cardShape
                    .foregroundStyle(.background)
            )
            .clipShape(cardShape)
    }
}
