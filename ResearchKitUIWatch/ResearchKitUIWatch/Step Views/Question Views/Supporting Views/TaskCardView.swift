//
//  TaskCardView.swift
//  ResearchKitUI(Watch)
//
//  Created by Johnny Hicks on 6/11/24.
//

import SwiftUI

struct TaskCardView<Content: View>: View {
    @Environment(\.colorScheme) var colorScheme

    let title: String?
    let detail: String?
    let content: Content

    init(title: String?,
         detail: String?,
         @ViewBuilder content: () -> Content
    ) {
        self.content = content()
        self.title = title
        self.detail = detail
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let detail {
                Text(detail)
                    .foregroundColor(.secondary)
                    .font(.footnote)
                    .fontWeight(.bold)
            }

            if let title {
                Text(title)
                    .foregroundStyle(Color(.label))
                    .font(.body)
                    .fontWeight(.bold)
            }

            if title != nil || detail != nil {
                Divider()
            }

            content
        }
        .padding()
        .background(colorScheme == .dark ? Color(uiColor: .systemGray5) : .white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct TaskCardView_Previews: PreviewProvider {
    static var previews: some View {
        TaskCardView(title: "What is your name?", detail: "Question 1 of 3") {
            Text("Specific component content will show up here")
        }
    }
}
