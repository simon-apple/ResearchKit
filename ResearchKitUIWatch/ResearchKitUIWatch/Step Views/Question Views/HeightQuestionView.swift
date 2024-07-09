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
    public let primarySelection: Int?
    public let secondarySelection: Int?

    public init(
        id: String,
        title: String,
        detail: String?,
        measurementSystem: MeasurementSystem,
        primarySelection: Int?,
        secondarySelection: Int?
    ) {
        self.id = id
        self.title = title
        self.detail = detail
        self.measurementSystem = measurementSystem
        self.primarySelection = primarySelection
        self.secondarySelection = secondarySelection
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
            let centimeters = (Double(primarySelection ?? 0) * 30.48) + (Double(secondarySelection ?? 0) * 2.54)
            return NSNumber(floatLiteral: centimeters)
        } else {
            return NSNumber(floatLiteral: Double(primarySelection ?? 0))
        }
    }
}

struct HeightQuestionView: View {
    @State var isInputActive = false
    @State var hasChanges: Bool

    let title: String
    let detail: String?
    let measurementSystem: MeasurementSystem
    @Binding var primarySelection: Int
    @Binding var secondarySelection: Int

    init(title: String,
         detail: String?,
         measurementSystem: MeasurementSystem,
         primarySelection: Binding<Int>,
         secondarySelection: Binding<Int>
    ) {
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
        self._primarySelection = primarySelection
        self._secondarySelection = secondarySelection
    }

    var selectionString: String {
        if hasChanges == false { return "Tap Here" }

        if measurementSystem == .USC {
            return "\(Int(primarySelection))' \(Int(secondarySelection))\""
        } else {
            return "\(primarySelection) cm"
        }
    }

    var body: some View {
        FormItemCardView(title: title, detail: detail) {
            HStack {
                Button {
                    isInputActive = true
                } label: {
                    Text(selectionString)
                        .foregroundStyle(hasChanges ? Color.primary : Color.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                if hasChanges {
                    Button {
                        hasChanges = false
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(Color.gray)
                    }
                }
            }
            .padding()
            .sheet(isPresented: $isInputActive) {
                HeightPickerView(
                    measurementSystem: measurementSystem,
                    primarySelection: $primarySelection,
                    secondarySelection: $secondarySelection,
                    hasChanges: $hasChanges
                )
                    .presentationDetents([.height(300)])
            }
        }
    }
}

struct HeightPickerView: View {
    @Environment(\.dismiss) var dismiss

    let measurementSystem: MeasurementSystem

    @Binding var primarySelection: Int
    @Binding var secondarySelection: Int
    @Binding var hasChanges: Bool

    var upperValue: Int {
        if measurementSystem == .USC {
            return 10
        } else {
            return 300
        }
    }

    var secondaryUpperValue: Int {
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
        VStack {
            HStack {
                Button {
                    hasChanges = true
                    dismiss()
                } label: {
                    Text("Done")
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
            }
            .padding(.horizontal)
            HStack(spacing: .zero) {
                Picker(selection: $primarySelection) {
                    ForEach(0..<upperValue, id: \.self) { i in
                        Text("\(i) \(primaryUnit)")
                            .tag(i)
                    }
                } label: {
                    Text("Tap Here")
                }
                .pickerStyle(.wheel)
                .onChange(of: primarySelection) { _, _ in
                    hasChanges = true
                }

                if measurementSystem == .USC {
                    Picker(selection: $secondarySelection) {
                        ForEach(0..<secondaryUpperValue, id: \.self) { i in
                            Text("\(i) \(secondaryUnit)")
                                .tag(i)
                        }
                    } label: {
                        Text("Tap Here")
                    }
                    .pickerStyle(.wheel)
                    .onChange(of: secondarySelection) { _, _ in
                        hasChanges = true
                    }
                }
            }
        }
    }
}


@available(iOS 18.0, *)
#Preview {
    @Previewable @State var primarySelection: Int = 22
    @Previewable @State var secondarySelection: Int = 2
    HeightQuestionView(
        title: "Height question here",
        detail: nil,
        measurementSystem: .USC,
        primarySelection: $primarySelection,
        secondarySelection: $secondarySelection
    )
}

