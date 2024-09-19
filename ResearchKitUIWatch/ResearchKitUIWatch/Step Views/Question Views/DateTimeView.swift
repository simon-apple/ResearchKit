/*
 Copyright (c) 2024, Apple Inc. All rights reserved.

 Redistribution and use in source and binary forms, with or without modification,
 are permitted provided that the following conditions are met:

 1.  Redistributions of source code must retain the above copyright notice, this
 list of conditions and the following disclaimer.

 2.  Redistributions in binary form must reproduce the above copyright notice,
 this list of conditions and the following disclaimer in the documentation and/or
 other materials provided with the distribution.

 3.  Neither the name of the copyright holder(s) nor the names of any contributors
 may be used to endorse or promote products derived from this software without
 specific prior written permission. No license is granted to the trademarks of
 the copyright holders even if such marks are included in this software.

 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
 FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

import SwiftUI

public struct DateQuestion: Identifiable {
    public let id: String
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
    @EnvironmentObject
    private var managedTaskResult: ResearchTaskResult
    
    @Environment(\.questionRequired)
    private var isRequired: Bool

    @State
    private var showDatePickerModal = false
    
    @State
    private var showTimePickerModal = false
    let id: String
    let header: Header
    let pickerPrompt: String
    let displayedComponents: DatePicker.Components
    let range: ClosedRange<Date>
    let result: StateManagementType<Date?>

    private var resolvedResult: Binding<Date?> {
        switch result {
        case let .automatic(key: key):
            return Binding(
                get: { managedTaskResult.resultForStep(key: key) ?? Date() },
                set: { managedTaskResult.setResultForStep(.date($0 ?? nil), key: key) }
            )
        case let .manual(value):
            return value
        }
    }

    public init(
        id: String,
        @ViewBuilder header: () -> Header,
        selection: Date = Date(),
        pickerPrompt: String,
        displayedComponents: DatePicker.Components,
        range: ClosedRange<Date>
    ) {
        self.id = id
        self.header = header()
        self.pickerPrompt = pickerPrompt
        self.displayedComponents = displayedComponents
        self.range = range
        self.result = .automatic(key: .date(id: id))
    }

    public init(
        id: String,
        @ViewBuilder header: () -> Header,
        selection: Binding<Date?>,
        pickerPrompt: String,
        displayedComponents: DatePicker.Components,
        range: ClosedRange<Date>
    ) {
        self.id = id
        self.header = header()
        self.pickerPrompt = pickerPrompt
        self.displayedComponents = displayedComponents
        self.range = range
        self.result = .manual(selection)
    }

    public var body: some View {
        FormItemCardView {
            header
        } content: {
#if os(watchOS)
            VStack {
                if displayedComponents.contains(.date) {
                    Button {
                        showDatePickerModal.toggle()
                    } label: {
                        Text(
                            resolvedResult.wrappedValue ?? Date(),
                            format: .dateTime.day().month().year()
                        )
                    }
                }
                
                if displayedComponents.contains(.hourMinuteAndSecond) {
                    Button {
                        showTimePickerModal.toggle()
                    } label: {
                        Text(
                            resolvedResult.wrappedValue ?? Date(),
                            format: .dateTime.hour().minute().second()
                        )
                    }
                } else if displayedComponents.contains(.hourAndMinute){
                    Button {
                        showTimePickerModal.toggle()
                    } label: {
                        Text(
                            resolvedResult.wrappedValue ?? Date(),
                            format: .dateTime.hour().minute()
                        )
                    }
                }
            }
            .buttonBorderShape(.roundedRectangle)
            .buttonStyle(.bordered)
            .padding()
            .navigationDestination(isPresented: $showDatePickerModal) {
                watchDatePicker(displayedComponents: .date)
            }
            .navigationDestination(isPresented: $showTimePickerModal) {
                watchDatePicker(displayedComponents: displayedComponents.contains(.hourMinuteAndSecond) ? .hourMinuteAndSecond : .hourAndMinute)
            }
#else
            DatePicker(
                pickerPrompt,
                selection: resolvedResult.unwrapped(defaultValue: Date()),
                in: range,
                displayedComponents: displayedComponents
            )
            .datePickerStyle(.compact)
            .foregroundStyle(.primary)
            .padding()
#endif
        }
        .preference(key: QuestionRequiredPreferenceKey.self, value: isRequired)
        .preference(key: QuestionAnsweredPreferenceKey.self, value: isAnswered)
    }
    
    @ViewBuilder
    private func watchDatePicker(displayedComponents: DatePicker.Components) -> some View {
        VStack(alignment: .leading) {
            header
            DatePicker(
                pickerPrompt,
                selection: resolvedResult.unwrapped(defaultValue: Date()),
                in: range,
                displayedComponents: displayedComponents
            )
            .padding(.horizontal)
        }
    }
    
    private var isAnswered: Bool {
        return resolvedResult.wrappedValue != nil
    }
}

public extension DateTimeView where Header == _SimpleFormItemViewHeader {
    
    init(
        id: String,
        title: String,
        detail: String? = nil,
        selection: Date = Date(),
        pickerPrompt: String,
        displayedComponents: DatePicker.Components,
        range: ClosedRange<Date>
    ) {
        self.id = id
        self.header = _SimpleFormItemViewHeader(title: title, detail: detail)
        self.pickerPrompt = pickerPrompt
        self.displayedComponents = displayedComponents
        self.range = range
        self.result = .automatic(key: .date(id: id))
    }
    
    init(
        id: String,
        title: String,
        detail: String? = nil,
        selection: Binding<Date?>,
        pickerPrompt: String,
        displayedComponents: DatePicker.Components,
        range: ClosedRange<Date>
    ) {
        self.id = id
        self.header = _SimpleFormItemViewHeader(title: title, detail: detail)
        self.pickerPrompt = pickerPrompt
        self.displayedComponents = displayedComponents
        self.range = range
        self.result = .manual(selection)
    }
    
}

#Preview("Date Only") {
    @Previewable @State var date: Date? = Date()
    NavigationStack {
        ScrollView {
            DateTimeView(
                id: UUID().uuidString,
                title: "What is your birthday?",
                detail: "Question 1 of 4",
                selection: $date,
                pickerPrompt: "Select Date",
                displayedComponents: [.date],
                range: Date.distantPast...Date.distantFuture
            )
            .padding(.horizontal)
        }
    }
}

#Preview("Time Only") {
    @Previewable @State var date: Date? = Date()
    NavigationStack {
        ScrollView {
            DateTimeView(
                id: UUID().uuidString,
                title: "What time is it?",
                detail: "Question 2 of 4",
                selection: $date,
                pickerPrompt: "Select Time",
                displayedComponents: [.hourAndMinute],
                range: Date.distantPast...Date.distantFuture
            )
            .padding(.horizontal)
        }
    }
}

#Preview("Time and Date") {
    @Previewable @State var date: Date? = Date()
    NavigationStack {
        ScrollView {
            DateTimeView(
                id: UUID().uuidString,
                title: "What is the time and date?",
                detail: "Question 2 of 4",
                selection: $date,
                pickerPrompt: "Select Time and Date",
                displayedComponents: [.date, .hourAndMinute],
                range: Date.distantPast...Date.distantFuture
            )
            .padding(.horizontal)
        }
    }
}

