//
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

@available(iOS 14.0, *)
@objc public class SwiftUIViewFactoryMOA: NSObject {
    
    var numSteps: Int = 0
    var isMultiStep: Bool = false
    
    var view: ORKdBHLToneAudiometrySliderView {
        ORKdBHLToneAudiometrySliderView(
            viewModel: SliderViewModel(numSteps: self.numSteps, isMultiStep: self.isMultiStep)
        )
    }
    
    @objc public func makeSwiftUIView(numSteps: Int, isMultiStep: Bool) -> UIViewController {
        self.numSteps = numSteps
        self.isMultiStep = isMultiStep
        return UIHostingController(rootView: view)
    }
}

extension NSNotification.Name {
    static let sliderValueChanged = NSNotification.Name("sliderValueChanged")
    static let isRefinementStep = NSNotification.Name("isRefinementStep")
    static let resetView = NSNotification.Name("resetView")
}

@available(iOS 13.0, *)
class SliderViewModel: ObservableObject {
    @Published var sliderValue: Float = 0
    @Published var isRefinementStep: Bool = false
    @Published var isMultiStep: Bool = false
    
    @Published var sliderRange: ClosedRange<Float>
    
    var numDBSteps: Int = 0
        
    public init(numSteps: Int, isMultiStep: Bool) {
        self.numDBSteps = numSteps
        self.sliderValue = 0
        self.sliderRange = 0...Float(numSteps - 1)
        self.isMultiStep = isMultiStep
    
        UIStepper.appearance().setDecrementImage(UIImage(systemName: "minus"), for: .normal)
        UIStepper.appearance().setIncrementImage(UIImage(systemName: "plus"), for: .normal)
    }
}

@available(iOS 14.0, *)
struct ORKdBHLToneAudiometrySliderView: View {
        
    var height: CGFloat = UIScreen.main.bounds.size.height * 0.25
        
    @StateObject var viewModel = SliderViewModel(numSteps: 14, isMultiStep: false)
    
    let resetViewPublisher = NotificationCenter.default.publisher(for: .resetView)
    let refinementStepPublisher = NotificationCenter.default.publisher(for: .isRefinementStep)

    
    var body: some View {
        VStack(spacing: 15) {
            LevelStack(sliderValue: $viewModel.sliderValue,
                       numDBSteps: viewModel.numDBSteps,
                       height: height,
                       isRefinement: $viewModel.isRefinementStep,
                       bounds: $viewModel.sliderRange
            )
            
            Spacer()
                        
            CustomSlider(value:  $viewModel.sliderValue, in: $viewModel.sliderRange)
                .frame(height: 30)
            
            HStack {
                Image(systemName: "speaker.fill")
                    .opacity(0.3)
                Spacer()
                Image(systemName: "speaker.wave.3.fill")
                    .opacity(0.3)
            }
            
            // Only show stepper for single step
            if (!viewModel.isMultiStep) {
                CustomStepper(value: $viewModel.sliderValue, in: viewModel.sliderRange) {
                    viewModel.sliderValue = viewModel.sliderValue.rounded(.toNearestOrAwayFromZero)
                } onDecrement: {
                    viewModel.sliderValue = viewModel.sliderValue.rounded(.toNearestOrAwayFromZero)
                }
                .labelsHidden()
                .accentColor(.blue)
            }
            
        }.padding(10)
        .onReceive(resetViewPublisher) { _ in
            self.resetView()
        }
        .onReceive(refinementStepPublisher) { notification in
            if let userInfo = notification.userInfo?["isRefinementStep"] as? String {
                if (userInfo == "true") {
                    viewModel.isRefinementStep = true
                } else if (userInfo == "false") {
                    viewModel.isRefinementStep = false
                }
            }
        }
        .onChange(of: viewModel.sliderValue) { _ in
            NotificationCenter.default.post(
                name: .sliderValueChanged,
                object: nil,
                userInfo: [ "sliderValue" : Int( $viewModel.sliderValue.wrappedValue ) ]
            )
        }
        .onChange(of: viewModel.isRefinementStep) { newValue in
            if (viewModel.sliderValue < 1) {
                // keep the first rectangle if slider is at 0
                viewModel.sliderRange = newValue ? 0...Float(viewModel.numDBSteps - 3)  : 0...Float(viewModel.numDBSteps - 1)
            } else if (Int(viewModel.sliderValue) == viewModel.numDBSteps) {
                // keep the last rectangle if slider is at max
                viewModel.sliderRange = newValue ? 2...Float(viewModel.numDBSteps - 1)  : 0...Float(viewModel.numDBSteps - 1)
            } else {
                // otherwise just trim off two rectangles
                viewModel.sliderRange = newValue ? 1...Float(viewModel.numDBSteps - 2)  : 0...Float(viewModel.numDBSteps - 1)
            }
        }
    }
    
    func resetView() {
        viewModel.sliderValue = 0
    }
}

@available(iOS 13.0, *)
struct CustomStepper<Value>: View where Value: Strideable {
    @Binding private var value: Value
    private let bounds: ClosedRange<Value>
    private let step: Value.Stride
    private let onIncrement: (() -> Void)?
    private let onDecrement: (() -> Void)?

    @State private var previousValue: Value

    public init(
        value: Binding<Value>,
        in bounds: ClosedRange<Value>,
        step: Value.Stride = 1,
        onIncrement: (() -> Void)? = nil,
        onDecrement: (() -> Void)? = nil
    ) {
        self._value = value
        self.bounds = bounds
        self.step = step
        self.onIncrement = onIncrement
        self.onDecrement = onDecrement
        self._previousValue = .init(initialValue: value.wrappedValue)
    }

    var body: some View {
        Stepper(
            "",
            value: $value,
            in: bounds,
            step: step,
            onEditingChanged: onEditingChanged
        )
    }

    func onEditingChanged(isEditing: Bool) {
        guard !isEditing else {
            previousValue = value
            return
        }
        if previousValue < value {
            onIncrement?()
        } else if previousValue > value {
            onDecrement?()
        }
    }
}

@available(iOS 14.0, *)
struct DecibelRectangle : Identifiable, View {
    var id = UUID()
    let cornerRadius : CGFloat = 15
    
    var opacity: Double = 1.0
    var height: CGFloat = 0
    var shouldAnimate: Bool = false
    
    var body : some View {
        VStack {
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(.blue)
                .opacity(opacity)
                .frame(height: height)
                .animation(shouldAnimate ? .spring() : .none, value: height)
        }
    }
}

@available(iOS 14.0, *)
struct LevelStack : View {
    var height: CGFloat
    @Binding private var sliderValue: Float
    @Binding private var isRefinement: Bool
    @Binding private var bounds: ClosedRange<Float>
    
    private var multiStep: Bool = false
    
    private var numDBSteps: Int = 0
    private var scalar: CGFloat {
        isRefinement ? 0.6 : 1.0
    }
    
    private var rectRange: ClosedRange<Int> {
        Int(bounds.lowerBound)...Int(bounds.upperBound)
    }
    
    private var baselineHeight: CGFloat {
        isRefinement ? 100 : 10
    }
    
    init(sliderValue: Binding<Float>, numDBSteps: Int, height: CGFloat, isRefinement: Binding<Bool>, bounds: Binding<ClosedRange<Float>>) {
        _sliderValue = sliderValue
        self.height = height
        self.numDBSteps = numDBSteps
        _isRefinement = isRefinement
        _bounds = bounds
    }
        
    var body: some View {
        HStack(alignment: .bottom, spacing: 5.0) {
            ForEach(rectRange, id: \.self) { index in
                DecibelRectangle(
                    opacity: opacity(index: index, sliderValue: sliderValue),
                    height: heightForIndex(index: index, viewHeight: height),
                    shouldAnimate: isRefinement
                )
            }
        }
    }
    
    func heightForIndex(index: Int, viewHeight: CGFloat) -> CGFloat {
        let baseHeight = Int(viewHeight) / rectRange.count
        return CGFloat(baseHeight) * CGFloat(index + 1) * scalar + baselineHeight
    }
    
    func opacity(index: Int, sliderValue: Float) -> Double {
        return (Int(sliderValue) >= index ? 1 : 0.2)
    }
}

@available(iOS 14.0, *)
struct CustomSlider<V>: View where V : BinaryFloatingPoint {
    
    // MARK: - Value
    // MARK: Private
    @Binding private var value: V
    @Binding private var bounds: ClosedRange<V>
    
    private let length: CGFloat    = 30
    private let lineWidth: CGFloat = 2
    
    @State private var ratio: CGFloat   = 0
    @State private var startX: CGFloat? = nil
    
    @State private var currentlyEditing: Bool = false
        
    // MARK: - Initializer
    init(value: Binding<V>, in bounds: Binding<ClosedRange<V>>) {
        _value  = value
        _bounds = bounds
    }
    // MARK: - View
    // MARK: Public
    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .leading) {
                // Track
                RoundedRectangle(cornerRadius: 30)
                    .frame(height: 10)
                    .foregroundColor(Color(
                        red: 239.0/255.0,
                        green: 239.0/255.0,
                        blue: 244.0/225.0)
                    )

                // Thumb
                Circle()
                    .foregroundColor(Color(
                        red: 52.0/255.0,
                        green: 120.0/255.0,
                        blue: 247.0/225.0)
                    ).shadow(radius: 4.0)
                
                    .frame(width: length, height: length)
                    .offset(x: (proxy.size.width - length) * ratio)
                    .gesture(DragGesture(minimumDistance: 0)
                        .onChanged({
                            updateStatus(value: $0, proxy: proxy)
                            currentlyEditing = true
                        })
                        .onEnded {
                            _ in startX = nil
                            currentlyEditing = false
                        })

            }
            .frame(height: length)
            .simultaneousGesture(DragGesture(minimumDistance: 0)
                .onChanged({
                    update(value: $0, proxy: proxy)
                }))
            .onAppear {
                ratio = min(1, max(0,CGFloat(value / bounds.upperBound)))
            }
            .onChange(of: value) { _ in
                if (!currentlyEditing) {
                    ratio = min(1, max(0, CGFloat(value / bounds.upperBound)))
                }
            }
        }
    }
    
    private func updateStatus(value: DragGesture.Value, proxy: GeometryProxy) {
        guard startX == nil else { return }
        
        let delta = value.startLocation.x - (proxy.size.width - length) * ratio
        startX = (length < value.startLocation.x && 0 < delta) ? delta : value.startLocation.x
    }
    
    private func update(value: DragGesture.Value, proxy: GeometryProxy) {
        guard let xStart = startX else { return }
        startX = min(length, max(0, xStart))
        
        var point = value.location.x - xStart
        let delta = proxy.size.width - length
        
        // Check the boundary
        if point < 0 {
            startX = value.location.x
            point = 0
            
        } else if delta < point {
            startX = value.location.x - delta
            point = delta
        }
        
        // Ratio
        self.ratio = point / delta
        self.value = V(bounds.upperBound) * V(ratio) + V(bounds.lowerBound)
    }
}

@available(iOS 14.0, *)
extension View {
    @ViewBuilder
    // This helper function allows if statements to be applied as a modifier on a view.
    // This makes it easier to conditionally modify or embed views inside an existing view.
    func `if`<Content: View>(_ condition: Bool, content: (Self) -> Content) -> some View {
        if condition {
            content(self)
        } else {
            self
        }
    }
}
