/*
 Copyright (c) 2021, Apple Inc. All rights reserved.
 
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
// apple-internal

#if APPLE_INTERNAL

#ifndef ORKTinnitusTypes_h
#define ORKTinnitusTypes_h
#import <ResearchKit/ORKDefines.h>

static NSString *const ORKTinnitusMaskingSoundInstructionStepIdentifier = @"tinnitus_masking_sound_instruction";

/**
 Type of tinnitus.
 */
typedef NS_ENUM(NSInteger, ORKTinnitusType) {
    ORKTinnitusTypeUnknown = 0,
    ORKTinnitusTypeWhiteNoise,
    ORKTinnitusTypePureTone
} ORK_ENUM_AVAILABLE;

/**
 Possible answers for probability of using a specific tinnitus masking sound.
 */
typedef NSString *ORKTinnitusMaskingAnswer NS_STRING_ENUM;
ORK_EXTERN ORKTinnitusMaskingAnswer const ORKTinnitusMaskingAnswerVeryEffective;
ORK_EXTERN ORKTinnitusMaskingAnswer const ORKTinnitusMaskingAnswerSomewhatEffective;
ORK_EXTERN ORKTinnitusMaskingAnswer const ORKTinnitusMaskingAnswerNotEffective;
ORK_EXTERN ORKTinnitusMaskingAnswer const ORKTinnitusMaskingAnswerNoneOfTheAbove;

/**
 Possible answers for tinnitus sound assessment.
 */
typedef NSString *ORKTinnitusAssessmentAnswer NS_STRING_ENUM;
ORK_EXTERN ORKTinnitusAssessmentAnswer const ORKTinnitusAssessmentAnswerVerySimilar;
ORK_EXTERN ORKTinnitusAssessmentAnswer const ORKTinnitusAssessmentAnswerSomewhatSimilar;
ORK_EXTERN ORKTinnitusAssessmentAnswer const ORKTinnitusAssessmentAnswerNotSimilar;
ORK_EXTERN ORKTinnitusAssessmentAnswer const ORKTinnitusAssessmentAnswerNoneOfTheAbove;

/**
 A set of error types associated with tinnitus pure tone results.
 */
typedef NSString *ORKTinnitusError NS_STRING_ENUM;
ORK_EXTERN ORKTinnitusError const ORKTinnitusErrorNone;                 // @"None"
ORK_EXTERN ORKTinnitusError const ORKTinnitusErrorInconsistency;        // @"Inconsistency"
ORK_EXTERN ORKTinnitusError const ORKTinnitusErrorTooHigh;              // @"TooHighFrequency"
ORK_EXTERN ORKTinnitusError const ORKTinnitusErrorTooLow;               // @"TooLowFrequency"

typedef NS_ENUM(NSUInteger, ORKTinnitusSelectedPureTonePosition) {
    ORKTinnitusSelectedPureTonePositionNone,
    ORKTinnitusSelectedPureTonePositionA,
    ORKTinnitusSelectedPureTonePositionB,
    ORKTinnitusSelectedPureTonePositionC
};

typedef NS_ENUM(NSUInteger, PureToneButtonsStage) {
    PureToneButtonsStageOne,
    PureToneButtonsStageTwo,
    PureToneButtonsStageThree
};

#endif /* ORKTinnitusTypes_h */

#endif
