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

import Foundation
import ResearchKitUI
import ResearchKitActiveTask_Private

@objcMembers public class ORKActiveTaskRegisterHelper: NSObject {
    private static let activeTaskSteps: Void = {
        ORKStepMapper.registerClass(ORK3DModelStep.self) { ORK3DModelStepViewController(step: $0, result: $1) }
        ORKStepMapper.registerClass(ORKAVJournalingStep.self) { ORKAVJournalingStepViewController(step: $0, result: $1) }
        ORKStepMapper.registerClass(ORKAccuracyStroopStep.self) { ORKAccuracyStroopStepViewController(step: $0, result: $1) }
        ORKStepMapper.registerClass(ORKActiveStep.self) { ORKActiveStepViewController(step: $0, result: $1) }
        ORKStepMapper.registerClass(ORKAmslerGridStep.self) { ORKAmslerGridStepViewController(step: $0, result: $1) }
        ORKStepMapper.registerClass(ORKAudioFitnessStep.self) { ORKAudioFitnessStepViewController(step: $0, result: $1) }
        ORKStepMapper.registerClass(ORKAudioStep.self) { ORKAudioStepViewController(step: $0, result: $1) }
        ORKStepMapper.registerClass(ORKBLEScanPeripheralsStep.self) { ORKBLEScanPeripheralsStepViewController(step: $0, result: $1) }
        ORKStepMapper.registerClass(ORKCountdownStep.self) { ORKCountdownStepViewController(step: $0, result: $1) }
        ORKStepMapper.registerClass(ORKEnvironmentSPLMeterStep.self) { ORKEnvironmentSPLMeterStepViewController(step: $0, result: $1) }
        ORKStepMapper.registerClass(ORKFaceDetectionStep.self) { ORKFaceDetectionStepViewController(step: $0, result: $1) }
        ORKStepMapper.registerClass(ORKFitnessStep.self) { ORKFitnessStepViewController(step: $0, result: $1) }
        ORKStepMapper.registerClass(ORKFrontFacingCameraStep.self) { ORKFrontFacingCameraStepViewController(step: $0, result: $1) }
        ORKStepMapper.registerClass(ORKHeadphoneDetectStep.self) { ORKHeadphoneDetectStepViewController(step: $0, result: $1) }
        ORKStepMapper.registerClass(ORKHeadphonesRequiredCompletionStep.self) { ORKHeadphonesRequiredCompletionStepViewController(step: $0, result: $1) }
        ORKStepMapper.registerClass(ORKHolePegTestPlaceStep.self) { ORKHolePegTestPlaceStepViewController(step: $0, result: $1) }
        ORKStepMapper.registerClass(ORKHolePegTestRemoveStep.self) { ORKHolePegTestRemoveStepViewController(step: $0, result: $1) }
        ORKStepMapper.registerClass(ORKPSATStep.self) { ORKPSATStepViewController(step: $0, result: $1) }
        ORKStepMapper.registerClass(ORKRangeOfMotionStep.self) { ORKRangeOfMotionStepViewController(step: $0, result: $1) }
        ORKStepMapper.registerClass(ORKReactionTimeStep.self) { ORKReactionTimeViewController(step: $0, result: $1) }
        ORKStepMapper.registerClass(ORKShoulderRangeOfMotionStep.self) { ORKShoulderRangeOfMotionStepViewController(step: $0, result: $1) }
        ORKStepMapper.registerClass(ORKSpatialSpanMemoryStep.self) { ORKSpatialSpanMemoryStepViewController(step: $0, result: $1) }
        ORKStepMapper.registerClass(ORKSpeechInNoiseStep.self) { ORKSpeechInNoiseStepViewController(step: $0, result: $1) }
        ORKStepMapper.registerClass(ORKSpeechRecognitionStep.self) { ORKSpeechRecognitionStepViewController(step: $0, result: $1) }
        ORKStepMapper.registerClass(ORKStroopStep.self) { ORKStroopStepViewController(step: $0, result: $1) }
        ORKStepMapper.registerClass(ORKTappingIntervalStep.self) { ORKTappingIntervalStepViewController(step: $0, result: $1) }
        ORKStepMapper.registerClass(ORKTimedWalkStep.self) { ORKTimedWalkStepViewController(step: $0, result: $1) }
        ORKStepMapper.registerClass(ORKTinnitusMaskingSoundStep.self) { ORKTinnitusMaskingSoundStepViewController(step: $0, result: $1) }
        ORKStepMapper.registerClass(ORKTinnitusOverallAssessmentStep.self) { ORKTinnitusOverallAssessmentStepViewController(step: $0, result: $1) }
        ORKStepMapper.registerClass(ORKTinnitusPureToneStep.self) { ORKTinnitusPureToneStepViewController(step: $0, result: $1) }
        ORKStepMapper.registerClass(ORKTinnitusTypeStep.self) { ORKTinnitusTypeStepViewController(step: $0, result: $1) }
        ORKStepMapper.registerClass(ORKToneAudiometryStep.self) { ORKToneAudiometryStepViewController(step: $0, result: $1) }
        ORKStepMapper.registerClass(ORKTouchAnywhereStep.self) { ORKTouchAnywhereStepViewController(step: $0, result: $1) }
        ORKStepMapper.registerClass(ORKTowerOfHanoiStep.self) { ORKTowerOfHanoiViewController(step: $0, result: $1) }
        ORKStepMapper.registerClass(ORKTrailmakingStep.self) { ORKTrailmakingStepViewController(step: $0, result: $1) }
        ORKStepMapper.registerClass(ORKTypingStep.self) { ORKTypingStepViewController(step: $0, result: $1) }
        ORKStepMapper.registerClass(ORKVolumeCalibrationStep.self) { ORKVolumeCalibrationStepViewController(step: $0, result: $1) }
        ORKStepMapper.registerClass(ORKWalkingTaskStep.self) { ORKWalkingTaskStepViewController(step: $0, result: $1) }
        ORKStepMapper.registerClass(ORKdBHLToneAudiometryOnboardingStep.self) { ORKdBHLToneAudiometryOnboardingStepViewController(step: $0, result: $1) }
        ORKStepMapper.registerClass(ORKdBHLToneAudiometryStep.self) { ORKdBHLToneAudiometryStepViewController(step: $0, result: $1) }
    }()

    public static func registerActiveTaskStepsIfNeeded() {
        _ = activeTaskSteps
    }
}

