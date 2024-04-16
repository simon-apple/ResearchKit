//
//  TextChoiceCell.swift
//  ResearchKitUI(Watch)
//
//  Created by Jessi Aboukasm on 3/5/24.
//

import SwiftUI

public struct TextChoiceCell: View {

    var isSelected: Bool

    var title: Text

    var selection: () -> Void

    public init(title: Text, isSelected: Bool, selection: @escaping () -> Void) {
        self.title = title
        self.selection = selection
        self.isSelected = isSelected
    }

    @ViewBuilder
    public var body: some View {
        Button(action: {
            selection()
        }) {
            HStack {
                title
                    .fontWeight(.medium)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .font(.body)
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .frame(alignment: .trailing)
                    .imageScale(.large)
                    .foregroundColor(isSelected ? .blue : .gray)
                    .font(.body)
            }
        }.buttonBorderShape(.roundedRectangle)
    }
}
