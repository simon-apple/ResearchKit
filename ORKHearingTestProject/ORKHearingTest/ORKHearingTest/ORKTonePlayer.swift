//
//  ORKTonePlayer.swift
//  ORKHearingTest
//
//  Created by Paulo Cesar Saito Lopes on 03/07/23.
//

import Foundation
@_weakLinked import HearingTest

let tonePlayer = HTTonePlayer()
  
@objcMembers
public class ORKTonePlayer: NSObject {
    public func startSession(for retryTimes: Int = 5, completion: @escaping (Bool) -> Void) {
        Task {
            let result = await tonePlayer.startSession(for: retryTimes)
            completion(result)
        }
    }

    public func stopSession() {
        tonePlayer.stopSession()
    }
    
    public func enableANCHearingTestMode(for retryTimes: Int = 5, completion: @escaping (Bool) -> Void) {
        Task {
            let result = await tonePlayer.enableANCHearingTestMode(for: retryTimes)
            completion(result)
        }
    }
    
    public func disableANCHearingTestMode() {
        tonePlayer.disableANCHearingTestMode()
    }
    
    public func play(frequency: Double, level: Double, channel: Int, completion: @escaping (Error?) -> Void) {
        let ch = (channel == 0) ? HTHearingChannel.leftEar : HTHearingChannel.rightEar
        
        if let newTone = HTHearingTestTone(freq: frequency, level: level, channel: ch, dur: 1) {
            tonePlayer.play(tone: newTone, completion: completion)
        }
    }
    
    public func stop() {
        tonePlayer.stop()
    }
}

// Workarround as the original initializer is not available on this context
private extension HTHearingTestTone {
    init?(freq: Double, level: Double, channel: HTHearingChannel, dur: TimeInterval) {
        let chan = (channel == .leftEar) ? 0 : 1
        let json = "{\"frequency\": \(freq), \"soundLevel\": \(level), \"channel\": \(chan), \"toneDuration\": \(dur)}"
        
        guard let data = json.data(using: .utf8), let tone = try? JSONDecoder().decode(Self.self, from: data) else {
            return nil
        }
        
        self = tone
    }
}
