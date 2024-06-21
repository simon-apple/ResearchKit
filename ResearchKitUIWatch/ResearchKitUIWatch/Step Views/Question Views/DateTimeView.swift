//
//  DateTimeView.swift
//  ResearchKitUI(Watch)
//
//  Created by Johnny Hicks on 6/17/24.
//

import SwiftUI

public struct DateQuestion: Identifiable {
    public var id: String
    public var title: String
    public var selection: Date
    public var pickerPrompt: String
    public var displayedComponents: DatePicker.Components
    public var range: ClosedRange<Date>

    public init(
        id: String,
        title: String,
        selection: Date,
        pickerPrompt: String,
        displayedComponents: DatePicker.Components,
        range: ClosedRange<Date>
    ) {
        self.id = id
        self.title = title
        self.selection = selection
        self.pickerPrompt = pickerPrompt
        self.displayedComponents = displayedComponents
        self.range = range
    }
}

public struct DateTimeView<Header: View>: View {
    let header: Header

    @Binding var selection: Date
    let pickerPrompt: String
    let displayedComponents: DatePicker.Components
    let range: ClosedRange<Date>

    public init(
        @ViewBuilder header: () -> Header,
        selection: Binding<Date>,
        pickerPrompt: String,
        displayedComponents: DatePicker.Components,
        range: ClosedRange<Date>
    ) {
        self.header = header()
        self._selection = selection
        self.pickerPrompt = pickerPrompt
        self.displayedComponents = displayedComponents
        self.range = range
    }

    public var body: some View {
        TaskCardView {
            header
        } content: {
            DatePicker(
                pickerPrompt,
                selection: $selection,
                in: range,
                displayedComponents: displayedComponents)
                .datePickerStyle(.compact)
                .foregroundStyle(.secondary)
        }
    }
}

public extension DateTimeView where Header == _SimpleTaskViewHeader {
    init(
        title: String,
        detail: String?,
        selection: Binding<Date>,
        pickerPrompt: String,
        displayedComponents: DatePicker.Components,
        range: ClosedRange<Date>
    ) {
        self.header = _SimpleTaskViewHeader(title: title, detail: detail)
        self._selection = selection
        self.pickerPrompt = pickerPrompt
        self.displayedComponents = displayedComponents
        self.range = range
    }
}

struct DateTimeView_Previews: PreviewProvider {
    static var previews: some View {
        DateTimeView(
            title: "What is your age",
            detail: nil,
            selection: .constant(Date()),
            pickerPrompt: "Select Date and Time",
            displayedComponents: [.date, .hourAndMinute],
            range: Date.distantPast...Date.distantFuture
        )
    }
}
