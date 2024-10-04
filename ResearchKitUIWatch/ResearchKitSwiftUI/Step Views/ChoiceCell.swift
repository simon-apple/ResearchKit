//
//  ChoiceCell.swift
//  ResearchKitUI(Watch)
//
//  Created by Jessi Aboukasm on 3/4/24.
//

import SwiftUI

public struct ChoiceCell: View {

    private var selected = false

    var title: String

    var action: () -> Void

    public init(title: String, selected: Bool = false, selection: @escaping () -> Void) {
        self.title = title
        self.action = selection
        self.selected = selected
    }

    @ViewBuilder
    public var body: some View {
        Button(action: {
            selected = !selected
            action()
        }) {
            HStack {
                Text(title)
                    .fontWeight(.medium)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .font(.body)
                Image(systemName: selected ? "checkmark.circle.fill" : "circle")
                    .frame(alignment: .trailing)
                    .imageScale(.large)
                    .foregroundColor(selected ? .blue : .gray)
                    .font(.body)
            }
        }.buttonBorderShape(.roundedRectangle)
    }
}
