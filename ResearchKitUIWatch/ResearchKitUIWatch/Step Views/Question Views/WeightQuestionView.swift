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

public struct WeightQuestionView: View {
    @EnvironmentObject
    private var managedTaskResult: ResearchTaskResult
    @State var isInputActive = false
    @State var hasChanges: Bool

    let id: String
    let title: String
    let detail: String?
    let measurementSystem: MeasurementSystem
    let precision: NumericPrecision
    let defaultValue: Double?
    let minimumValue: Double?
    let maximumValue: Double?
    let result: StateManagementType<(Double, Double)>

    private var resolvedResult: Binding<(Double, Double)> {
        switch result {
        case let .automatic(key: key):
            return Binding(
                get: { managedTaskResult.resultForStep(key: key) ?? (defaultValue ?? 0, 0) },
                set: { managedTaskResult.setResultForStep(.weight($0), key: key) }
            )
        case let .manual(value):
            return value
        }
    }

    public init(
        id: String,
        title: String,
        detail: String? = nil,
        measurementSystem: MeasurementSystem,
        precision: NumericPrecision = .default,
        defaultValue: Double?,
        minimumValue: Double?,
        maximumValue: Double?
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
        self.precision = precision
        self.defaultValue = defaultValue
        self.minimumValue = minimumValue
        self.maximumValue = maximumValue
        self.result = .automatic(key: .weight(id: id))
    }
    
    public init(
        id: String,
        title: String,
        detail: String? = nil,
        measurementSystem: MeasurementSystem,
        precision: NumericPrecision = .default,
        defaultValue: Double?,
        minimumValue: Double?,
        maximumValue: Double?,
        selection: Binding<(Double, Double)>
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
        self.precision = precision
        self.defaultValue = defaultValue
        self.minimumValue = minimumValue
        self.maximumValue = maximumValue
        self.result = .manual(selection)
    }

    var selectionString: String {
        if measurementSystem == .USC {
            switch precision {
            case .default, .low:
                return "\(Int(resolvedResult.wrappedValue.0)) lb"
            case .high:
                return "\(Int(resolvedResult.wrappedValue.0)) lb \(Int(resolvedResult.wrappedValue.1)) oz"
            }
        } else {
            switch precision {
            case .default, .low:
                return "\(resolvedResult.wrappedValue.0) kg"
            case .high:
                return "\(resolvedResult.wrappedValue.0 + resolvedResult.wrappedValue.1) kg"
            }
        }
    }

    public var body: some View {
        FormItemCardView(title: title, detail: detail) {
            HStack {
                Text("Select Weight")
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
                    WeightPickerView(
                        measurementSystem: measurementSystem,
                        precision: precision,
                        defaultValue: defaultValue,
                        minimumValue: minimumValue,
                        maximumValue: maximumValue,
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

struct WeightPickerView: View {
    @Environment(\.dismiss) var dismiss

    let measurementSystem: MeasurementSystem
    let precision: NumericPrecision
    let defaultValue: Double?
    let minimumValue: Double?
    let maximumValue: Double?

    @Binding var selection: (Double, Double)
    @Binding var hasChanges: Bool

    @State var highPrecisionSelection: Int = 0

    var lowerValue: Double {
        guard let minimumValue else { return 0 }
        return minimumValue
    }

    var upperValue: Double {
        if measurementSystem == .USC {
            guard let maximumValue else { return 1_450}
            return maximumValue
        } else {
            guard let maximumValue else {
                switch precision {
                case .low, .high:
                    return 657
                case .default:
                    return 657.5
                }
            }
            return maximumValue
        }
    }

    var secondaryUpperValue: Double {
        if measurementSystem == .USC {
            return 15
        } else {
            return 0.99
        }
    }

    var primaryStep: Double {
        if measurementSystem != .USC {
            switch precision {
            case .default:
                return 0.5
            case .low, .high:
                return 1
            }
        } else {
            return 1
        }
    }

    var secondaryStep: Double {
        if measurementSystem == .USC {
            return 1
        } else {
            return 0.01
        }
    }

    var primaryUnit: String {
        if measurementSystem == .USC {
            return "lb"
        } else {
            return "kg"
        }
    }

    var secondaryUnit: String {
        return "oz"
    }

    var primaryRange: [Double] {
        var range:[Double] = []
        for i in stride(from: lowerValue, through: upperValue, by: primaryStep) {
            range.append(i)
        }
        return range
    }

    var secondaryRange: [Double] {
        var range: [Double] = []
        for i in stride(from: lowerValue, through: secondaryUpperValue, by: secondaryStep) {
            range.append(i)
        }
        return range
    }

    var body: some View {
        HStack(spacing: .zero) {

            Picker(selection: $selection.0) {
                ForEach(primaryRange, id: \.self) { i in
                    Text(primaryPickerString(for: i))
                        .tag(i)
                }
            } label: {
                Text("Tap Here")
            }
            .pickerStyle(.wheel)
            .onChange(of: selection.0) { _, _ in
                hasChanges = true
            }

            if precision == .high {
                Picker(selection: $selection.1) {
                    ForEach(secondaryRange, id: \.self) { i in
                        Text(secondaryPickerString(for: i))
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

            if measurementSystem != .USC,
               precision == .high {
                Picker(selection: $highPrecisionSelection) {
                    ForEach(0..<1, id: \.self) { i in
                        Text("\(primaryUnit)")
                            .tag(i)
                    }
                } label: {
                    Text("Tap Here")
                }
                .pickerStyle(.wheel)
            }
        }
    }

    private func primaryPickerString(
        for value: Double
    ) -> String {
        let formatter = NumberFormatter()

        let fractionalDigits : Int = {
            if measurementSystem != .USC && precision == .default {
                return 1
            }
            return 0
        }()

        formatter.minimumFractionDigits = fractionalDigits
        formatter.minimumIntegerDigits = measurementSystem != .USC && self.precision == .high ? 0 : 1

        let string = formatter.string(for: value) ?? "Unknown"

        let includeUnit: Bool = {
            if measurementSystem != .USC && precision == .high {
                return false
            }
            return true
        }()

        let finalString = includeUnit ? "\(string) \(primaryUnit)" : string
        return finalString
    }

    private func secondaryPickerString(
        for value: Double
    ) -> String {
        let formatter = NumberFormatter()

        let fractionalDigits : Int = {
            if measurementSystem != .USC && precision == .high {
                return 2
            }
            return 0
        }()

        formatter.minimumFractionDigits = fractionalDigits
        formatter.minimumIntegerDigits = measurementSystem != .USC && self.precision == .high ? 0 : 1

        let string = formatter.string(for: value) ?? "Unknown"

        let includeUnit: Bool = {
            if measurementSystem == .USC && precision == .high {
                return true
            }
            return false
        }()

        let finalString = includeUnit ? "\(string) \(secondaryUnit)" : string
        return finalString
    }
}


@available(iOS 18.0, *)
#Preview {
    @Previewable @State var selection: (Double, Double) = (133, 0)
    WeightQuestionView(
        id: UUID().uuidString,
        title: "Weight question here",
        detail: nil,
        measurementSystem: .USC,
        precision: .high,
        defaultValue: 150,
        minimumValue: 0,
        maximumValue: 1430,
        selection: $selection
    )
}
