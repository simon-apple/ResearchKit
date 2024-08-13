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
    
    private let stateManagementType: StateManagementType<Date>
    
    @State
    private var managedResult: Date?
    
    private var resolvedManagedResult: Binding<Date> {
        Binding(
            get: { managedResult ?? Date() },
            set: { managedResult = $0 }
        )
    }
    
    private var selection: Binding<Date> {
        let selection: Binding<Date>
        switch stateManagementType {
        case .automatic:
            selection = resolvedManagedResult
        case .manual(let binding):
            selection = binding
        }
        return selection
    }
    
    let id: String
    let header: Header
    let pickerPrompt: String
    let displayedComponents: DatePicker.Components
    let range: ClosedRange<Date>
    
    @State
    private var showDatePickerModal = false
    
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
        self.managedResult = selection
        self.stateManagementType = .automatic
    }

    public init(
        id: String,
        @ViewBuilder header: () -> Header,
        selection: Binding<Date>,
        pickerPrompt: String,
        displayedComponents: DatePicker.Components,
        range: ClosedRange<Date>
    ) {
        self.id = id
        self.header = header()
        self.pickerPrompt = pickerPrompt
        self.displayedComponents = displayedComponents
        self.range = range
        self.stateManagementType = .manual(selection)
    }

    public var body: some View {
        FormItemCardView {
            header
        } content: {
#if os(watchOS)
            Button {
                showDatePickerModal.toggle()
            } label: {
                Text(selection.wrappedValue, format: .dateTime.day().month().year())
            }
            .buttonBorderShape(.roundedRectangle)
            .buttonStyle(.bordered)
            .padding()
            .navigationDestination(isPresented: $showDatePickerModal) {
                VStack(alignment: .leading) {
                    header
                    WatchDataPickerDetailView(
                        pickerPrompt: pickerPrompt,
                        selection: selection,
                        displayedComponents: displayedComponents,
                        range: range
                    )
                    .padding(.horizontal)
                }
            }
#else
            DatePicker(
                pickerPrompt,
                selection: selection,
                in: range,
                displayedComponents: displayedComponents
            )
            .datePickerStyle(.compact)
            .foregroundStyle(.primary)
            .padding()
#endif
        }
    }
}

private struct WatchDataPickerDetailView: View {
    let pickerPrompt: String
    var selection: Binding<Date>
    let displayedComponents: DatePicker.Components
    let range: ClosedRange<Date>
    
    var body: some View {
        DatePicker(
            pickerPrompt,
            selection: selection,
            in: range,
            displayedComponents: displayedComponents
        )
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
        self.managedResult = selection
        self.stateManagementType = .automatic
    }
    
    init(
        id: String,
        title: String,
        detail: String? = nil,
        selection: Binding<Date>,
        pickerPrompt: String,
        displayedComponents: DatePicker.Components,
        range: ClosedRange<Date>
    ) {
        self.id = id
        self.header = _SimpleFormItemViewHeader(title: title, detail: detail)
        self.pickerPrompt = pickerPrompt
        self.displayedComponents = displayedComponents
        self.range = range
        self.stateManagementType = .manual(selection)
    }
    
}

#Preview {
    @Previewable @State var date: Date = Date()
    NavigationStack {
        DateTimeView(
            id: UUID().uuidString,
            title: "What is your birthday?",
            detail: "Question 1 of 4",
            selection: $date,
            pickerPrompt: "Select Date and Time",
            displayedComponents: [.date, .hourAndMinute],
            range: Date.distantPast...Date.distantFuture
        )
        .padding(.horizontal)
    }
}

