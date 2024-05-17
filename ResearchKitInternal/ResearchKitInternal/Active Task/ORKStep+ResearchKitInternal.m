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

#import <ResearchKit/ORKStep.h>
#import <ResearchKitUI/ORKStepContainerView.h>
#import <ResearchKitInternal/ResearchKitInternal.h>
#import <ResearchKitInternal/ResearchKitInternal_Private.h>

@implementation ORKIdBHLToneAudiometryStep (ViewControllerProviding)

- (ORKStepViewController *)makeViewControllerWithResult:(ORKResult *)result {
    return [[ORKIdBHLToneAudiometryStepViewController alloc] initWithStep:self result:result];
}

@end

@implementation ORKIEnvironmentSPLMeterStep (ViewControllerProviding)

- (ORKStepViewController *)makeViewControllerWithResult:(ORKResult *)result {
    return [[ORKIEnvironmentSPLMeterStepViewController alloc] initWithStep:self result:result];
}

@end

@implementation ORKdBHLToneAudiometryMethodOfAdjustmentStep (ViewControllerProviding)

- (ORKStepViewController *)makeViewControllerWithResult:(ORKResult *)result {
    return [[ORKdBHLToneAudiometryMethodOfAdjustmentStepViewController alloc] initWithStep:self result:result];
}

@end

@implementation ORKAVJournalingStep (ViewControllerProviding)

- (ORKStepViewController *)makeViewControllerWithResult:(ORKResult *)result {
    return [[ORKAVJournalingStepViewController alloc] initWithStep:self result:result];
}

@end

#if ORK_FEATURE_BLE_SCAN_PERIPHERALS
@implementation ORKBLEScanPeripheralsStep (ViewControllerProviding)

- (ORKStepViewController *)makeViewControllerWithResult:(ORKResult *)result {
    return [[ORKBLEScanPeripheralsStepViewController alloc] initWithStep:self result:result];
}

@end
#endif

@implementation ORKFaceDetectionStep (ViewControllerProviding)

- (ORKStepViewController *)makeViewControllerWithResult:(ORKResult *)result {
    return [[ORKFaceDetectionStepViewController alloc] initWithStep:self result:result];
}

@end

@implementation ORKHeadphoneDetectStep (ViewControllerProviding)

- (ORKStepViewController *)makeViewControllerWithResult:(ORKResult *)result {
    return [[ORKHeadphoneDetectStepViewController alloc] initWithStep:self result:result];
}

@end

@implementation ORKHeadphonesRequiredCompletionStep (ViewControllerProviding)

- (ORKStepViewController *)makeViewControllerWithResult:(ORKResult *)result {
    return [[ORKHeadphonesRequiredCompletionStepViewController alloc] initWithStep:self result:result];
}

@end

@implementation ORKTinnitusMaskingSoundStep (ViewControllerProviding)

- (ORKStepViewController *)makeViewControllerWithResult:(ORKResult *)result {
    return [[ORKTinnitusMaskingSoundStepViewController alloc] initWithStep:self result:result];
}

@end

@implementation ORKTinnitusOverallAssessmentStep (ViewControllerProviding)

- (ORKStepViewController *)makeViewControllerWithResult:(ORKResult *)result {
    return [[ORKTinnitusOverallAssessmentStepViewController alloc] initWithStep:self result:result];
}

@end

@implementation ORKTinnitusPureToneStep (ViewControllerProviding)

- (ORKStepViewController *)makeViewControllerWithResult:(ORKResult *)result {
    return [[ORKTinnitusPureToneStepViewController alloc] initWithStep:self result:result];
}

@end

@implementation ORKTinnitusTypeStep (ViewControllerProviding)

- (ORKStepViewController *)makeViewControllerWithResult:(ORKResult *)result {
    return [[ORKTinnitusTypeStepViewController alloc] initWithStep:self result:result];
}

@end

@implementation ORKTypingStep (ViewControllerProviding)

- (ORKStepViewController *)makeViewControllerWithResult:(ORKResult *)result {
    return [[ORKTypingStepViewController alloc] initWithStep:self result:result];
}

@end

@implementation ORKVolumeCalibrationStep (ViewControllerProviding)

- (ORKStepViewController *)makeViewControllerWithResult:(ORKResult *)result {
    return [[ORKVolumeCalibrationStepViewController alloc] initWithStep:self result:result];
}

@end

@implementation ORKISpeechInNoiseStep (ViewControllerProviding)

- (ORKStepViewController *)makeViewControllerWithResult:(ORKResult *)result {
    return [[ORKISpeechInNoiseStepViewController alloc] initWithStep:self result:result];
}

@end

@implementation ORKISpeechRecognitionStep (ViewControllerProviding)

- (ORKStepViewController *)makeViewControllerWithResult:(ORKResult *)result {
    return [[ORKISpeechRecognitionStepViewController alloc] initWithStep:self result:result];
}

@end

@implementation ORKIInstructionStep (ViewControllerProviding)

- (ORKStepViewController *)makeViewControllerWithResult:(ORKResult *)result {
    return [[ORKIInstructionStepViewController alloc] initWithStep:self result:result];
}

@end

@implementation ORKICompletionStep (ViewControllerProviding)

- (ORKStepViewController *)makeViewControllerWithResult:(ORKResult *)result {
    return [[ORKICompletionStepViewController alloc] initWithStep:self result:result];
}

@end

@implementation ORKSensitiveURLLearnMoreInstructionStep (ViewControllerProviding)

- (ORKStepViewController *)makeViewControllerWithResult:(ORKResult *)result {
    return [[ORKIInstructionStepViewController alloc] initWithStep:self result:result];
}

@end

@implementation ORKFamilyHistoryStep (ViewControllerProviding)

- (ORKStepViewController *)makeViewControllerWithResult:(ORKResult *)result {
    return [[ORKFamilyHistoryStepViewController alloc] initWithStep:self result:result];
}

@end

@implementation ORKIQuestionStep (ViewControllerProviding)

- (ORKStepViewController *)makeViewControllerWithResult:(ORKResult *)result {
    return [[ORKIQuestionStepViewController alloc] initWithStep:self result:result];
}

@end
