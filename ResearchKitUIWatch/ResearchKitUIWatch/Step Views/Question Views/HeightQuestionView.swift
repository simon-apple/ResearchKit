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

public enum MeasurementSystem {
    case USC, local, metric
}

public struct HeightQuestion: Identifiable {

    public let id: String
    public let title: String
    public let detail: String?
    public let measurementSystem: MeasurementSystem
    public let selection: (Int?, Int?)

    let footToCentimetersMultiplier: Double = 30.48
    let inchToCentimetersMultiplier: Double = 2.54

    public init(
        id: String,
        title: String,
        detail: String?,
        measurementSystem: MeasurementSystem,
        selection: (Int?, Int?)
    ) {
        self.id = id
        self.title = title
        self.detail = detail
        self.measurementSystem = measurementSystem
        self.selection = selection
    }

    public var usesMetricSystem: Bool {
        switch measurementSystem {
        case .USC:
            return false
        case .local:
            if Locale.current.measurementSystem == .us {
                return false
            } else {
                return true
            }
        case .metric:
            return true
        }
    }

    public var number: NSNumber {
        if usesMetricSystem == false {
            let centimeters = (Double(selection.0 ?? 0) * footToCentimetersMultiplier) + (Double(selection.1 ?? 0) * inchToCentimetersMultiplier)
            return NSNumber(floatLiteral: centimeters)
        } else {
            return NSNumber(floatLiteral: Double(selection.0 ?? 0))
        }
    }
}

public struct HeightQuestionView: View {
    @EnvironmentObject
    private var managedTaskResult: ResearchTaskResult

    @State var isInputActive = false
    @State var hasChanges: Bool

    let id: String
    let title: String
    let detail: String?
    let measurementSystem: MeasurementSystem
    let result: StateManagementType<(Int, Int)>

    var initialPrimaryValue: Int  {
        // To set the picker at a nice middle of the road height
        // we will set it to 5 feet initially
        if measurementSystem == .USC {
            return 5
        }

        // Similar to above, this equate to 5'4" which
        // is a good starting point for the picker.
        if measurementSystem == .metric {
            return 162
        }

        return Locale.current.measurementSystem == .us ? 5 : 162
    }

    private var resolvedResult: Binding<(Int, Int)> {
        switch result {
        case let .automatic(key: key):
            return Binding(
                get: { managedTaskResult.resultForStep(key: key) ?? (initialPrimaryValue, 4) },
                set: { managedTaskResult.setResultForStep(.height($0), key: key) }
            )
        case let .manual(value):
            return value
        }
    }

    public init(
        id: String,
        title: String,
        detail: String? = nil,
        measurementSystem: MeasurementSystem
    ) {
        self.id = id
        self.hasChanges = false
        self.title = title
        self.detail = detail

        let system: MeasurementSystem = {
            switch measurementSystem {
            case .USC:
                return .USC
            case .local:
                if Locale.current.measurementSystem == .us {
                    return .USC
                } else {
                    return .metric
                }
            case .metric:
                return .metric
            }
        }()
        self.measurementSystem = system
        self.result = .automatic(key: .height(id: id))
    }
    
    public init(
        id: String,
        title: String,
        detail: String? = nil,
        measurementSystem: MeasurementSystem,
        selection: Binding<(Int, Int)>
    ) {
        self.id = id
        self.hasChanges = false
        self.title = title
        self.detail = detail

        let system: MeasurementSystem = {
            switch measurementSystem {
            case .USC:
                return .USC
            case .local:
                if Locale.current.measurementSystem == .us {
                    return .USC
                } else {
                    return .metric
                }
            case .metric:
                return .metric
            }
        }()
        self.measurementSystem = system
        self.result = .manual(selection)
    }

    var selectionString: String {
        if measurementSystem == .USC {
            return "\(Int(resolvedResult.wrappedValue.0))' \(Int(resolvedResult.wrappedValue.1))\""
        } else {
            return "\(resolvedResult.0) cm"
        }
    }

    public var body: some View {
        FormItemCardView(title: title, detail: detail) {
            HStack {
                Text("Select Height")
                    .foregroundStyle(Color.primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Button {
                    isInputActive = true
                } label: {
                    Text(selectionString)
                        .foregroundStyle(Color.primary)
                }
                .buttonStyle(.bordered)
                .buttonBorderShape(.roundedRectangle)
                .popover(
                    isPresented: $isInputActive,
                    attachmentAnchor: .point(.bottom),
                    arrowEdge: .top
                ) {
                    HeightPickerView(
                        measurementSystem: measurementSystem,
                        selection: resolvedResult,
                        hasChanges: $hasChanges
                    )
                    .frame(width: 300)
                    .presentationCompactAdaptation((.popover))
                }
            }
            .padding()
        }
    }
}

struct HeightPickerView: View {
    @Environment(\.dismiss) var dismiss

    let measurementSystem: MeasurementSystem

    @Binding var selection: (Int, Int)
    @Binding var hasChanges: Bool

    var upperValue: Int {
        if measurementSystem == .USC {
            return 10
        } else {
            return 300
        }
    }

    var secondaryUpperValue: Int {
        // Numbers up to 1 foot or 12 inches
        return 12
    }

    var primaryUnit: String {
        if measurementSystem == .USC {
            return "ft"
        } else {
            return "cm"
        }
    }

    var secondaryUnit: String {
        return "in"
    }

    var body: some View {
        HStack(spacing: .zero) {
            Picker(selection: $selection.0) {
                ForEach(0..<upperValue, id: \.self) { i in
                    Text("\(i) \(primaryUnit)")
                        .tag(i)
                }
            } label: {
                Text("Tap Here")
            }
            .pickerStyle(.wheel)
            .onChange(of: selection.0) { _, _ in
                hasChanges = true
            }

            if measurementSystem == .USC {
                Picker(selection: $selection.1) {
                    ForEach(0..<secondaryUpperValue, id: \.self) { i in
                        Text("\(i) \(secondaryUnit)")
                            .tag(i)
                    }
                } label: {
                    Text("Tap Here")
                }
                .pickerStyle(.wheel)
                .onChange(of: selection.1) { _, _ in
                    hasChanges = true
                }
            }
        }
    }
}


@available(iOS 18.0, *)
#Preview {
    @Previewable @State var selection: (Int, Int) = (22, 2)
    HeightQuestionView(
        id: UUID().uuidString,
        title: "Height question here",
        detail: nil,
        measurementSystem: .USC,
        selection: $selection
    )
}
