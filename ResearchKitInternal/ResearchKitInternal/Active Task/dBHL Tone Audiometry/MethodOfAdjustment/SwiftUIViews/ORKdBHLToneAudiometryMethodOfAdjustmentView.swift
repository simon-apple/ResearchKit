/*
 Copyright (c) 2022, Apple Inc. All rights reserved.
 
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
import Combine
import UIKit

public struct ChangeObserver<V: Equatable>: ViewModifier {
    public init(newValue: V, action: @escaping (V) -> Void) {
        self.newValue = newValue
        self.newAction = action
    }

    private typealias Action = (V) -> Void

    private let newValue: V
    private let newAction: Action

    @State private var state: (V, Action)?

    public func body(content: Content) -> some View {
        if #available(iOS 14, *) {
            assertionFailure("Please don't use this ViewModifer directly and use the `onChange(of:perform:)` modifier instead.")
        }
        return content
            .onAppear()
            .onReceive(Just(newValue)) { newValue in
                if let (currentValue, action) = state, newValue != currentValue {
                    action(newValue)
                }
                state = (newValue, newAction)
            }
    }
}

extension View {
    @_disfavoredOverload
    @ViewBuilder public func onChange<V>(of value: V, perform action: @escaping (V) -> Void) -> some View where V: Equatable {
        if #available(iOS 14, *) {
            onChange(of: value, perform: action)
        } else {
            modifier(ChangeObserver(newValue: value, action: action))
        }
    }
}

extension NSNotification.Name {
    static let sliderValueChanged = NSNotification.Name("sliderValueChanged")
    static let resetView = NSNotification.Name("resetView")
    static let nextButtonTapped = NSNotification.Name("nextButtonTapped")
}

class SliderViewModel: ObservableObject {
    @Environment(\.sizeCategory) var sizeCategory
    
    @Published var sliderValue: Float = 0
    @Published var sliderRange: ClosedRange<Float>
    @Published var hasMadeChanges: Bool = false
    @Published var sourceOfInteraction: ORKdBHLToneAudiometryMethodOfAdjustmentSourceOfInteraction = .reset
    
    var numDBSteps: Int = 0
    var numFrequencies: Int = 0
    var audioChannel: ORKAudioChannel = .left
    
    public init(numSteps: Int, numFrequencies: Int, audioChannel: ORKAudioChannel) {
        self.numDBSteps = numSteps
        self.numFrequencies = numFrequencies
        self.audioChannel = audioChannel
        self.sliderRange = 0...Float(numSteps - 1)
        self.sliderValue = Float((numSteps - 1) / 2 )
    }
}

struct ORKdBHLToneAudiometryMethodOfAdjustmentView: View {
    let ctFont = CTFontCreateUIFontForLanguage(.system, 12, nil)!
    
    var height: CGFloat = UIScreen.main.bounds.size.height * 0.25
    
    @State private var showingSheet = false
    @State private var currentFrequency = 1

    @State private var hasMadeChanges = false
    
    @ObservedObject var viewModel = SliderViewModel(numSteps: 14, numFrequencies: 6, audioChannel: .left)
    
    let resetViewPublisher = NotificationCenter.default.publisher(for: .resetView)
    let nextButtonTappedPublisher = NotificationCenter.default.publisher(for: .nextButtonTapped)
    
    var body: some View {
        VStack(spacing: 15) {
            Spacer().frame(height: 15)
            
            LevelStack(sliderValue: $viewModel.sliderValue,
                       numDBSteps: viewModel.numDBSteps,
                       height: height,
                       bounds: $viewModel.sliderRange,
                       sourceOfInteraction: $viewModel.sourceOfInteraction
            ).frame(maxHeight: 140)
            .background(Color.clear)
            Spacer(minLength: 10)
            
            StepperView(onIncrement: {
                if (viewModel.sliderValue < viewModel.sliderRange.upperBound) {
                    viewModel.sliderValue = viewModel.sliderValue.rounded(.toNearestOrAwayFromZero) + 1
                }
            }, onDecrement: {
                if (viewModel.sliderValue > viewModel.sliderRange.lowerBound) {
                    viewModel.sliderValue = viewModel.sliderValue.rounded(.toNearestOrAwayFromZero) - 1
                }
            }, sourceOfInteraction: $viewModel.sourceOfInteraction)
            
            Spacer(minLength: 35)
            
            Spacer().frame(height: 20)
            
            nextButton()
            
            progressLabel()
            Spacer().frame(height: 5)
        }
        .onReceive(resetViewPublisher) { _ in
            self.resetView()
        }
        .onChange(of: viewModel.sliderValue) { _ in
            if (!viewModel.hasMadeChanges) {
                viewModel.hasMadeChanges = true
                print(viewModel.hasMadeChanges)
            }
            NotificationCenter.default.post(
                name: .sliderValueChanged,
                object: nil,
                userInfo: [ "sliderValue" : Int($viewModel.sliderValue.wrappedValue),
                            "sourceOfInteraction" : viewModel.sourceOfInteraction.rawValue]
            )
        }
        .background(Color.clear)
    }

    func nextButton() -> some View {
        CustomButton("Next") {
            sendNextNotification()
        }.disabled(!viewModel.hasMadeChanges)
    }
    
    var earText: String {
        switch viewModel.audioChannel {
        case .left: return "Left Ear: "
        case .right: return "Right Ear: "
        default: return ""
        }
    }
    
    var frequencyText: String {
        return "Frequency \(min(currentFrequency, viewModel.numFrequencies)) of \(viewModel.numFrequencies)"
    }
    
    func progressLabel() -> some View {
        Text(earText + frequencyText)
            .foregroundColor(.gray)
    }
    
    func sendNextNotification() {
        NotificationCenter.default.post(
            name: .nextButtonTapped,
            object: nil
        )
    }
    
    func resetView() {
        viewModel.sourceOfInteraction = .reset
        viewModel.sliderValue = Float((viewModel.numDBSteps - 1) / 2)
        
        // Wait just a bit before changing the hasMadeChanges flag so it isn't changed by the slider update
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
            viewModel.hasMadeChanges = false
        }
        
        if (currentFrequency <= viewModel.numFrequencies) {
            currentFrequency += 1
        }
    }
}

struct StepperView: View {
    
    @State var isPressing = false
    @State private var timer: Timer?
    @Binding private var sourceOfInteraction: ORKdBHLToneAudiometryMethodOfAdjustmentSourceOfInteraction

    private let onIncrement: (() -> Void)?
    private let onDecrement: (() -> Void)?
    
    public init(
        onIncrement: (() -> Void)? = nil,
        onDecrement: (() -> Void)? = nil,
        sourceOfInteraction: Binding<ORKdBHLToneAudiometryMethodOfAdjustmentSourceOfInteraction>
    ) {
        self.onIncrement = onIncrement
        self.onDecrement = onDecrement
        _sourceOfInteraction = sourceOfInteraction
    }
    
    var body: some View {
        HStack {
            Spacer().frame(width: 20)
            stepperButton(isIncrement: false)
            Spacer()
            stepperButton(isIncrement: true)
            Spacer().frame(width: 20)
        }
    }
    
    func stepperButton(isIncrement: Bool) -> some View {
        VStack {
            Button {
                if (self.isPressing) {
                    self.isPressing = false
                    self.timer?.invalidate()
                } else {
                    sourceOfInteraction = .stepper
                    if (isIncrement) {
                        onIncrement?()
                    } else {
                        onDecrement?()
                    }
                }
            } label: {
                Image(systemName: isIncrement ? "plus" : "minus")
                    .font(.system(size: 35).bold())
                    .frame(width: 100, height: 100)
                    .foregroundColor(Color.white)
                    .background(Color.blue)
                    .clipShape(Circle())
            }
            
            Text(isIncrement ? "Louder" : "Quieter")
                .font(.system(size: 18))
                .foregroundColor(Color.blue)
        }
        .simultaneousGesture(LongPressGesture(minimumDuration: 0.2)
            .onEnded { _ in
                if (isIncrement) {
                    onIncrement?()
                } else {
                    onDecrement?()
                }
                self.isPressing = true
                self.timer = Timer.scheduledTimer(withTimeInterval: 0.25, repeats: true, block: { _ in
                    sourceOfInteraction = .stepper
                    if (isIncrement) {
                        onIncrement?()
                    } else {
                        onDecrement?()
                    }
                })
            }
        )
    }
}

struct DecibelRectangle : Identifiable, View {
    var id = UUID()
    let cornerRadius : CGFloat = 15
    
    var opacity: Double = 1.0
    var height: CGFloat = 0
    
    var body : some View {
        VStack {
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(.blue)
                .opacity(opacity)
                .frame(height: height)
                .animation(.spring().speed(5.0), value: height)
                .animation(.spring().speed(10.0), value: opacity)
        }
    }
}

struct LevelStack : View {
    var height: CGFloat
    @Binding private var sliderValue: Float
    @Binding private var bounds: ClosedRange<Float>
    @Binding private var sourceOfInteraction: ORKdBHLToneAudiometryMethodOfAdjustmentSourceOfInteraction
    
    private var numDBSteps: Int = 0
    
    private var rectRange: ClosedRange<Int> {
        Int(bounds.lowerBound)...Int(bounds.upperBound)
    }
    
    private var baselineHeight: CGFloat = 120
    
    init(sliderValue: Binding<Float>, numDBSteps: Int, height: CGFloat, bounds: Binding<ClosedRange<Float>>, sourceOfInteraction: Binding<ORKdBHLToneAudiometryMethodOfAdjustmentSourceOfInteraction>) {
        _sliderValue = sliderValue
        self.height = height
        self.numDBSteps = numDBSteps
        _bounds = bounds
        _sourceOfInteraction = sourceOfInteraction
    }
    
    var body: some View {
        ZStack {
            HStack(alignment: .center, spacing: 5.0) {
                ForEach(rectRange, id: \.self) { index in
                    DecibelRectangle(
                        opacity: opacity(index: index, sliderValue: sliderValue),
                        height: heightForIndex(index: index, viewHeight: height, sliderValue: sliderValue)
                    )
                }
            }
            
            // Invisible layer for tapping
            HStack(alignment: .center, spacing: 0.0) {
                GeometryReader { reader in
                    ForEach(rectRange, id: \.self) { index in
                        Rectangle()
                            .opacity(0.001)
                            .gesture(DragGesture(minimumDistance: 0).onChanged { gesture in
                                self.sourceOfInteraction = .slider
                                let hitBoxWidth = reader.size.width / CGFloat(rectRange.count - 1)
                                // only select values within the range
                                self.sliderValue = min(max(Float(gesture.location.x / hitBoxWidth), 0), Float(rectRange.count - 1))
                            })
                    }
                }
            }
        }
    }
    
    func heightForIndex(index: Int, viewHeight: CGFloat, sliderValue: Float) -> CGFloat {
        return CGFloat(Int(sliderValue) == index ? baselineHeight + 20 : baselineHeight)
    }
    
    func opacity(index: Int, sliderValue: Float) -> Double {
        return (Int(sliderValue) >= index ? 1 : 0.2)
    }
}

public struct CustomButton: View {
    private let text: String
    private let icon: Image?
    private let action: (() -> Void)

    @Environment(\.isEnabled) var isEnabled

    public var body: some View {
        Button {
            action()
        } label: {
            HStack {
                icon
                Text(text).customStyle(.title2, weight: .regular)
                    .frame(width: 200 , height: 40, alignment: .center)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(8)
        }
        .buttonStyle(CustomButtonStyle(isEnabled: isEnabled))
    }

    public init(_ text: String,
                @ViewBuilder icon: () -> Image? = { nil },
                action: @escaping() -> Void) {
        self.icon = icon()
        self.text = text
        self.action = action
    }
}

private struct CustomButtonStyle: ButtonStyle {
    let isEnabled: Bool

    @ViewBuilder
    func makeBody(configuration: Configuration) -> some View {
        let backgroundColor = isEnabled ? Color.blue : Color(UIColor.lightGray)
        let pressedBackgroundColor = Color.blue.opacity(0.5)
        let pressedTextColor = Color.white.opacity(0.5)
        let background = configuration.isPressed ? pressedBackgroundColor : backgroundColor
        let textColor = configuration.isPressed ? pressedTextColor : Color.white

        configuration.label
            .foregroundColor(textColor)
            .background(background)
            .cornerRadius(18)
    }
}

extension Text {
    func customStyle(_ textStyle: UIFont.TextStyle, weight: Font.Weight) -> Text {
        self.font(
            .system(size: UIFont.preferredFont(forTextStyle: textStyle).pointSize))
            .fontWeight(weight)
    }
}
