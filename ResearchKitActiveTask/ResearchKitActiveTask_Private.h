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

#import <ResearchKitActiveTask/ORKAccelerometerRecorder.h>
#import <ResearchKitActiveTask/ORKActiveStepTimer.h>
#import <ResearchKitActiveTask/ORKActiveStepViewController_Internal.h>
#import <ResearchKitActiveTask/ORKAmslerGridStep.h>
#import <ResearchKitActiveTask/ORKAudioFitnessStep.h>
#import <ResearchKitActiveTask/ORKAudioLevelNavigationRule.h>
#import <ResearchKitActiveTask/ORKAudiometry.h>
#import <ResearchKitActiveTask/ORKAudioRecorder.h>
#import <ResearchKitActiveTask/ORKAudioStep.h>
#import <ResearchKitActiveTask/ORKCountdownStep.h>
#import <ResearchKitActiveTask/ORKDeviceMotionRecorder.h>
#import <ResearchKitActiveTask/ORKFitnessStep.h>
#import <ResearchKitActiveTask/ORKHealthClinicalTypeRecorder.h>
#import <ResearchKitActiveTask/ORKHealthQuantityTypeRecorder.h>
#import <ResearchKitActiveTask/ORKHolePegTestPlaceStep.h>
#import <ResearchKitActiveTask/ORKHolePegTestRemoveStep.h>
#import <ResearchKitActiveTask/ORKLocationRecorder.h>
#import <ResearchKitActiveTask/ORKPedometerRecorder.h>
#import <ResearchKitActiveTask/ORKPSATStep.h>
#import <ResearchKitActiveTask/ORKRangeOfMotionStep.h>
#import <ResearchKitActiveTask/ORKReactionTimeStep.h>
#import <ResearchKitActiveTask/ORKNormalizedReactionTimeStep.h>
#import <ResearchKitActiveTask/ORKShoulderRangeOfMotionStep.h>
#import <ResearchKitActiveTask/ORKSpatialSpanMemoryStep.h>
#import <ResearchKitActiveTask/ORKSpeechInNoiseStep.h>
#import <ResearchKitActiveTask/ORKSpeechRecognitionStep.h>
#import <ResearchKitActiveTask/ORKStreamingAudioRecorder.h>
#import <ResearchKitActiveTask/ORKStroopStep.h>
#import <ResearchKitActiveTask/ORKTappingIntervalStep.h>
#import <ResearchKitActiveTask/ORKTimedWalkStep.h>
#import <ResearchKitActiveTask/ORKToneAudiometryStep.h>
#import <ResearchKitActiveTask/ORKTouchRecorder.h>
#import <ResearchKitActiveTask/ORKTowerOfHanoiStep.h>
#import <ResearchKitActiveTask/ORKTrailmakingStep.h>
#import <ResearchKitActiveTask/ORKVoiceEngine.h>
#import <ResearchKitActiveTask/ORKWalkingTaskStep.h>
#import <ResearchKitActiveTask/ORKdBHLToneAudiometryOnboardingStep.h>
#import <ResearchKitActiveTask/ORKdBHLToneAudiometryStep.h>
#import <ResearchKitActiveTask/ORKSpeechInNoiseStepViewController_Private.h>

// [WIP]: exposed for the internal framework
// may need to be permanent, but we shall see
#import <ResearchKitActiveTask/ORKActiveStepView.h>
#import <ResearchKitActiveTask/ORKAudioMeteringView.h>
#import <ResearchKitActiveTask/ORKdBHLToneAudiometryAudioGenerator.h>
#if RK_APPLE_INTERNAL
#import <ResearchKitActiveTask/UIColor+Custom.h>
#endif
