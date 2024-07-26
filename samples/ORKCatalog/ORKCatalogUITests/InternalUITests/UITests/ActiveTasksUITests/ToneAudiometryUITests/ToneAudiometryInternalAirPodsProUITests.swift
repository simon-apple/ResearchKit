/*
 Copyright (c) 20202415, Apple Inc. All rights reserved.
 
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

import Foundation
import XCTest

final class ToneAudiometryInternalAirPodsProUITests: ToneAudiometryInternalBaseUITests {
    
    /// rdar://tsc/26029193 ([Internal] dBHL Tone Audiometry (New Algorithm))
    /// Verifies that no unexpected alert interrupts the test before 10% progress : rdar://118144128 (IQVIA: Pacha - Participants unable to complete Tone Exercise: Task interrupted)
    func testToneAudiometryNewAlgorithmAirPodsPro10Percent() {
        verifyDBHLToneAudiometryTask(
            headphoneType: .airPodsPro,
            testProgressLevelNeeded: "10%",
            blueButtonTapsLimit: 30 // Usually, 12-15 taps correspond to 10% of test progress
        )
    }
    
    /// rdar://tsc/26029193 ([Internal] dBHL Tone Audiometry (New Algorithm))
    /// Verifies that no unexpected alert interrupts the test: rdar://118144128 (IQVIA: Pacha - Participants unable to complete Tone Exercise: Task interrupted)
    func testToneAudiometryNewAlgorithmAirPodsProFullFlow() {
        verifyDBHLToneAudiometryTask(
            headphoneType: .airPodsPro,
            blueButtonTapsLimit: 60 // Usually, 47-56 taps required to complete the test
        )
    }
    
    func testToneAudiometryNewAlgorithmNoiseCancellationRequired() {
        SettingsAppScreens().turnOnAirPodsModeFromSettingsScreen(mode: .transparency)
        app.activate()
        // Launch the task
        tasksList.selectTaskByName(Task.newdBHLToneAudiometryTask.description)
        // "Tone & Volume" step
        let instructionStep = InstructionStepScreen()
        instructionStep
            .verifyStepView()
            .tap(.continueButton)
        // "Connect your Headphones" step
        let headphoneDetectStep = HeadphoneDetectStepScreen()
        headphoneDetectStep
            .verifyStepView(exists: true)
            .verifyHeadphoneIsConnected(headphoneType: .airPodsPro, enableNoiseCancellation: false)
            .verifyNoiseCancellationRequiredLabel(exists: true)
        headphoneDetectStep
            .verify(.continueButton, isEnabled: false)
    }
}
