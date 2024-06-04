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
                    .font(.subheadline)
                    .foregroundStyle(Color(.label))
                
                Spacer()
                
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .imageScale(.large)
                    .foregroundColor(isSelected ? .blue : deselectedCheckmarkColor)
                    .font(.body)
            }
        }
    }
    
    // TODO(rdar://129073682): Update checkmark to more accurately match designs for both iOS and visionOS.
    private var deselectedCheckmarkColor: Color {
#if os(iOS)
        Color(.systemGray3)
#else
        .gray
#endif
    }
}
