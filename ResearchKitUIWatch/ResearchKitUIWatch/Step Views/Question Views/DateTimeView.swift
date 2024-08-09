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
    
    let id: String
    let header: Header
    @Binding var selection: Date
    let pickerPrompt: String
    let displayedComponents: DatePicker.Components
    let range: ClosedRange<Date>

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
        self._selection = selection
        self.pickerPrompt = pickerPrompt
        self.displayedComponents = displayedComponents
        self.range = range
    }

    public var body: some View {
        FormItemCardView {
            header
        } content: {
            DatePicker(
                pickerPrompt,
                selection: $selection,
                in: range,
                displayedComponents: displayedComponents
            )
#if os(watchOS)
            .datePickerStyle(.automatic)
#else
            .datePickerStyle(.compact)
#endif
            .foregroundStyle(.primary)
            .padding()
        }
    }
}

public extension DateTimeView where Header == _SimpleFormItemViewHeader {
    init(
        id: String,
        title: String,
        detail: String?,
        selection: Binding<Date>,
        pickerPrompt: String,
        displayedComponents: DatePicker.Components,
        range: ClosedRange<Date>
    ) {
        self.id = id
        self.header = _SimpleFormItemViewHeader(title: title, detail: detail)
        self._selection = selection
        self.pickerPrompt = pickerPrompt
        self.displayedComponents = displayedComponents
        self.range = range
    }
}

struct DateTimeView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.choice(for: .secondaryBackground)
                .ignoresSafeArea()
            DateTimeView(
                id: UUID().uuidString,
                title: "What is your age",
                detail: nil,
                selection: .constant(Date()),
                pickerPrompt: "Select Date and Time",
                displayedComponents: [.date, .hourAndMinute],
                range: Date.distantPast...Date.distantFuture
            )
            .padding(.horizontal)
        }
    }
}

public struct InputManagedDateTimeQuestion: View {
    
    private let id: String
    private let title: String
    private let detail: String?
    private let pickerPrompt: String
    private let displayedComponents: DatePicker.Components
    private let range: ClosedRange<Date>
    @State private var date: Date
    
    public init(
        id: String,
        title: String,
        detail: String? = nil,
        pickerPrompt: String,
        displayedComponents: DatePicker.Components,
        range: ClosedRange<Date>,
        date: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.detail = detail
        self.pickerPrompt = pickerPrompt
        self.displayedComponents = displayedComponents
        self.range = range
        self.date = date
    }
    
    public var body: some View {
        DateTimeView(
            id: id,
            title: title,
            detail: detail,
            selection: $date,
            pickerPrompt: pickerPrompt,
            displayedComponents: .date,
            range: Date.distantPast...Date.distantFuture
        )
    }
    
}
