//
//  TextChoiceCell.swift
//  ResearchKitUI(Watch)
//
//  Created by Jessi Aboukasm on 3/5/24.
//

import SwiftUI

public struct TextChoiceCell: View {

    var selected: Bool

    var title: Text

    var selection: (Bool) -> Void

    public init(title: Text, selected: Bool, selection: @escaping (Bool) -> Void) {
        self.title = title
        self.selection = selection
        self.selected = selected
    }

    @ViewBuilder
    public var body: some View {
        Button(action: {
            selection(!selected)
        }) {
            HStack {
                title
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
