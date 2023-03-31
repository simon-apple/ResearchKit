/*
 Copyright (c) 2023, Apple Inc. All rights reserved.
 
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

// swiftlint:disable identifier_name

import SwiftUI
import AVFoundation

extension NSNotification.Name {
    static let buttonTapped = NSNotification.Name("buttonTapped")
    static let skipTapped = NSNotification.Name("skipTapped")
    static let updateProgress = NSNotification.Name("updateProgress")
}

extension Bundle {
    static var current: Bundle {
        class __ { }
        return Bundle(for: __.self)
    }
}

@available(iOS 13.0.0, *)
struct Wave: Shape {
    // allow SwiftUI to animate the wave phase
    var animatableData: Double {
        get { phase }
        set { self.phase = newValue }
    }
    
    // how high our waves should be
    var amplitude: Double
    
    // how frequent our waves should be
    var frequency: Double
    
    // how much to offset our waves horizontally
    var phase: Double
        
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath()
        
        // calculate some important values up front
        let width = Double(rect.width)
        let height = Double(rect.height)
        let midWidth = width / 2
        let midHeight = height / 2
        let oneOverMidWidth = 1 / midWidth
        
        // split our total width up based on the frequency
        let wavelength = width / frequency
        
        // start at the left center
        path.move(to: CGPoint(x: 0, y: midHeight))
        
        // now count across individual horizontal points one by one
        for x in stride(from: 0, through: width, by: 1) {
            // find our current position relative to the wavelength
            let relativeX = x / wavelength
            
            // find how far we are from the horizontal center
            let distanceFromMidWidth = x - midWidth
            
            // bring that into the range of -1 to 1
            let normalDistance = oneOverMidWidth * distanceFromMidWidth
            
            let parabola = -(normalDistance * normalDistance) + 1
            
            // calculate the sine of that position, adding our phase offset
            let sine = sin(relativeX + phase)
            
            // multiply that sine by our strength to determine final offset, then move it down to the middle of our view
            let y = parabola * amplitude * sine + midHeight
            
            // add a line to here
            path.addLine(to: CGPoint(x: x, y: y))
        }
        return Path(path.cgPath)
    }
}

@available(iOS 16.0.0, *)
struct ORKdBHLToneAudiometryMethodOfLimitsView: View {
    @State private var phase = 0.0
    @State private var progress = 0.0
    @State private var nextProgress = 0.0
    @State private var isComplete = false
    
    @State var player: AVAudioPlayer?
    @State private var timer: Timer?
    
    @AppStorage("enable_skipButton") var enableSkipButton: Bool = false
    
    var audioChannel: ORKAudioChannel = .left
    var channelProgress = ProgressData(progressValue: 0.0, status: .notStarted)

    var height: CGFloat = 150
    var width: CGFloat = 250
    
    let buttonTappedPublisher = NotificationCenter.default.publisher(for: .nextButtonTapped)
//    let skipTappedPublisher = NotificationCenter.default.publisher(for: .skipTapped)
    let updateProgressPublisher = NotificationCenter.default.publisher(for: .updateProgress)

    var showWaveAnimation: Bool {
        let defs = UserDefaults.standard
        let indicatorConfig = defs.string(forKey: "progress_indicator")
        
        switch (indicatorConfig, audioChannel) {
        case ("Wave (Both)", _):
            return true
        case ("Circle (Both)", _):
            return false
        case ("Wave (L) - Circle (R)", .left):
            return true
        case ("Wave (L) - Circle (R)", .right):
            return false
        case ("Circle (L) - Wave (R)", .right):
            return true
        case ("Circle (L) - Wave (R)", .left):
            return false
        default:
            return true
        }
    }
    
    var inProgressText: String {
        switch audioChannel {
        case .left:
            return "Listen for Tones in Your Left Ear"
        case .right:
            return "Listen for Tones in Your Right Ear"
        default: return ""
        }
    }
    
    var completeText: String {
        switch audioChannel {
        case .left:
            return "Left Side Complete"
        case .right:
            return "Right Side Complete"
        default: return ""
        }
    }
    
    var circularProgressText: String {
        switch audioChannel {
        case .left:
            return "L"
        case .right:
            return "R"
        default: return ""
        }
    }
    
    var circularProgressStatus: ProgressStatus {
        if (channelProgress.progressValue <= 0) {
            return .notStarted
        } else if (channelProgress.progressValue > 0.0 && channelProgress.progressValue < 1.0) {
            return .inProgress
        } else if (channelProgress.progressValue >= 1.0) {
            return .completed
        } else {
            return .started
        }
    }
    
    var body: some View {
        VStack {
            Spacer().frame(height: 10)

            if (isComplete) {
                Spacer().frame(height: 50)

                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                    .font(.system(size: 75))

                Spacer().frame(height: 50)
            } else {
                if (showWaveAnimation) {
                    ZStack {
                        Wave(amplitude: 30, frequency: 25, phase: phase)
                            .trim(from: 0, to: progress)
                            .stroke(style: StrokeStyle(lineWidth: 6, lineCap: .round, lineJoin: .round))
                            .foregroundColor(Color.blue.opacity(1))
                            .frame(width: width, height: height)
                            .onAppear {
                                withAnimation(Animation.linear(duration: 2).repeatForever(autoreverses: false)) {
                                    phase = .pi * 2
                                }
                            }

                        Wave(amplitude: 30, frequency: 25, phase: phase)
                            .stroke(style: StrokeStyle(lineWidth: 6, lineCap: .round, lineJoin: .round))
                            .fill(Color.blue.opacity(0.35))
                            .frame(width:width, height:height)
                            .onAppear {
                                withAnimation(Animation.linear(duration: 2).repeatForever(autoreverses: false)) {
                                    phase = .pi * 2
                                }
                            }
                    }
                } else {
                    CircularProgressView(progressData: channelProgress, title: circularProgressText)
                        .scaleEffect(1.5)
                        .padding(.bottom, 30)
                }
            }
            
            Spacer().frame(height: 10)

            HStack {
                Text(isComplete ? completeText : inProgressText)
                    .font(.largeTitle).bold()
                    .multilineTextAlignment(.center)
            }.padding([.leading, .trailing])

            Spacer()
            
            if enableSkipButton {
                Button {
                    NotificationCenter.default.post(
                        name: .skipTapped,
                        object: nil,
                        userInfo: nil
                    )
                    isComplete = true
                } label: {
                    HStack {
                        Text("Skip Step")
                            .frame(minHeight: 170)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                            .background(Color.clear)
                            .font(.title)
                            .lineLimit(2)
                            .foregroundColor(Color.blue)
                            .cornerRadius(10)
                    }
                }.padding([.bottom], 50)
                Spacer()
            }
            
            Button {
                NotificationCenter.default.post(
                    name: .buttonTapped,
                    object: nil,
                    userInfo: nil
                )
            } label: {
                HStack {
                    Text("Tap when you \n hear the tone")
                        .frame(minHeight: 170)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 80)
                        .background(isComplete ? Color.gray : Color.blue)
                        .font(.title)
                        .lineLimit(2)
                        .foregroundColor(Color.white)
                        .cornerRadius(30)
                }
            }.padding([.bottom], 50)
            .disabled(isComplete)
        }.onReceive(updateProgressPublisher) { update in
            update.userInfo.map { info in
                if let progress = info["progress"] as? Double {
                    if (progress >= 1.0) {
                        isComplete = true
                    }
                    self.nextProgress = progress

                    if (showWaveAnimation) {
                        // Slowly animate progress changes
                        self.timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true, block: { time in
                            if (self.progress >= nextProgress) {
                                time.invalidate()
                            } else {
                                self.progress += 0.0002
                            }
                            
                            if (self.progress >= 1.0) {
                                isComplete = true
                            }
                        })
                    } else {
                        self.timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true, block: { time in
                            if (self.channelProgress.progressValue >= Float(nextProgress)) {
                                time.invalidate()
                            } else {
                                self.channelProgress.progressValue += 0.0001
                                self.channelProgress.status = circularProgressStatus
                            }
                            
                            if (self.channelProgress.progressValue >= 1.0) {
                                isComplete = true
                            }
                        })
                    }
                }
            }
        }.onChange(of: isComplete) { _ in
            playSound()
        }
    }
    
    func playSound() {
        guard let path = Bundle.current.path(forResource: "health_notification", ofType: "wav") else {
            print("error finding sound resource")
            return
        }
        let url = URL(fileURLWithPath: path)
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.prepareToPlay()
            player?.volume = 0.01
            player?.play()
        } catch let error {
            print("error playing sound file: \(error.localizedDescription)")
        }
    }
}

// Taken from CircularProgessView.swift in HealthSoftware/HearingTestUI

@available(iOS 15.0.0, *)
enum ProgressStatus {
    case notStarted
    case started
    case inProgress
    case completed
    
    var textColor: Color {
        switch self {
        case .notStarted:
            return Color.blue.opacity(0.3)
        case .started, .inProgress:
            return Color.blue
        case .completed:
            return Color.brown
        }
    }
    
    var bgColor: Color {
        switch self {
        case .completed:
            return Color.blue.opacity(0.3)
        default:
            return Color.clear
        }
    }
    
    var progressColor: Color {
        switch self {
        case .completed:
            return Color.clear
        default:
            return Color.blue
        }
    }
}

@available(iOS 15.0.0, *)
class ProgressData: ObservableObject {
    @Published var progressValue: Float
    @Published var status: ProgressStatus
    
    init(progressValue: Float, status: ProgressStatus) {
        self.progressValue = progressValue
        self.status = status
    }
}

/*
 Circular Progress View with a label that's displayed in the circle.
 Progress is indicated by a circular stroke. Shows progress in clock wise direction.
 Updates display attributes based on ProgressStatus.
 */

@available(iOS 16.0.0, *)
struct CircularProgressView: View {
    @ObservedObject var progressData: ProgressData
    @State var progress: Float = 0.0
    @State var status: ProgressStatus = .notStarted
    var title: String
    
    var body: some View {
        Gauge(value: progress) {
        } currentValueLabel: {
            Text(self.title)
                .font(.largeTitle)
                .bold()
                .foregroundColor(status.textColor)
        }
        .gaugeStyle(.accessoryCircularCapacity)
        .tint(status.progressColor)
        .background(status.bgColor, in: Circle())
        .onReceive(progressData.$progressValue) { progressValue in
            withAnimation {
                progress = progressValue
            }
        }
        .onReceive(progressData.$status) { status in
            withAnimation {
                self.status = status
            }
        }
    }
}



@available(iOS 16.0.0, *)
struct ORKdBHLToneAudiometryMethodOfLimitsView_Previews: PreviewProvider {
    static var previews: some View {
        ORKdBHLToneAudiometryMethodOfLimitsView()
    }
}
