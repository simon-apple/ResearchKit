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

@import ResearchKit;
@import ResearchKit_Private;
@import ResearchKitActiveTask;

#import "ORKIdBHLToneAudiometryStep.h"
#import "ORKIUtils.h"
#import "ORKOrderedTask+ResearchKitInternal.h"
#import "ResearchKitInternal.h"
#import "ResearchKitInternal_Private.h"

NSString *const ORKdBHLToneAudiometryHeadphoneDetectStepIdentifier = @"dBHL.tone.audiometry.headphonedetect";

NSString *const ORKInstruction1StepIdentifier = @"instruction1";
NSString *const ORKInstruction2StepIdentifier = @"instruction2";
NSString *const ORKInstruction3StepIdentifier = @"instruction3";

NSString *const ORKdBHLToneAudiometryStep1Identifier = @"dBHL1.tone.audiometry";
NSString *const ORKdBHLToneAudiometryStep2Identifier = @"dBHL2.tone.audiometry";

NSString *const ORKdBHLToneAudiometryMethodOfAdjustmentStep1Identifier = @"dBHL1.MOA.tone.audiometry";
NSString *const ORKdBHLToneAudiometryMethodOfAdjustmentStep2Identifier = @"dBHL2.MOA.tone.audiometry";

@implementation ORKOrderedTask (ResearchKitInternal)

+ (ORKNavigableOrderedTask *)newdBHLToneAudiometryTaskWithIdentifier:(NSString *)identifier
                                            intendedUseDescription:(nullable NSString *)intendedUseDescription
                                                           options:(ORKPredefinedTaskOption)options {
                  
    if (options & ORKPredefinedTaskOptionExcludeAudio) {
        @throw [NSException exceptionWithName:NSGenericException reason:@"Audio collection cannot be excluded from audio task" userInfo:nil];
    }

    NSMutableArray *steps = [NSMutableArray array];
    
    if (!(options & ORKPredefinedTaskOptionExcludeInstructions)) {
        {
            ORKInstructionStep *step = [[ORKInstructionStep alloc] initWithIdentifier:ORKInstruction0StepIdentifier];
            step.title = ORKLocalizedString(@"dBHL_TONE_AUDIOMETRY_INTRO_TITLE", nil);
            step.detailText = ORKLocalizedString(@"dBHL_TONE_AUDIOMETRY_INTRO_TEXT_2", nil);
            step.image = [UIImage imageNamed:@"audiometry" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
            step.imageContentMode = UIViewContentModeCenter;
            step.shouldTintImages = YES;

            ORKBodyItem * item1 = [[ORKBodyItem alloc] initWithText:ORKLocalizedString(@"dBHL_TONE_AUDIOMETRY_BODY_ITEM_TEXT_1", nil) detailText:nil image:[UIImage systemImageNamed:@"ear"] learnMoreItem:nil bodyItemStyle:ORKBodyItemStyleImage];
            ORKBodyItem * item2 = [[ORKBodyItem alloc] initWithText:ORKLocalizedString(@"dBHL_TONE_AUDIOMETRY_BODY_ITEM_TEXT_2", nil) detailText:nil image:[UIImage systemImageNamed:@"hand.draw.fill"] learnMoreItem:nil bodyItemStyle:ORKBodyItemStyleImage];
            ORKBodyItem * item3 = [[ORKBodyItem alloc] initWithText:ORKLocalizedString(@"dBHL_TONE_AUDIOMETRY_BODY_ITEM_TEXT_3", nil) detailText:nil image:[UIImage systemImageNamed:@"volume.2.fill"] learnMoreItem:nil bodyItemStyle:ORKBodyItemStyleImage];
            ORKBodyItem * item4 = [[ORKBodyItem alloc] initWithHorizontalRule];
            ORKBodyItem * item5 = [[ORKBodyItem alloc] initWithText:ORKLocalizedString(@"dBHL_TONE_AUDIOMETRY_BODY_ITEM_TEXT_4", nil) detailText:nil image:[UIImage systemImageNamed:@"stopwatch"] learnMoreItem:nil bodyItemStyle:ORKBodyItemStyleImage];
            item5.useSecondaryColor = YES;
            ORKBodyItem * item6 = [[ORKBodyItem alloc] initWithText:ORKLocalizedString(@"dBHL_TONE_AUDIOMETRY_BODY_ITEM_TEXT_5", nil) detailText:nil image:[UIImage systemImageNamed:@"moon.fill"] learnMoreItem:nil bodyItemStyle:ORKBodyItemStyleImage];
            item6.useSecondaryColor = YES;
            step.bodyItems = @[item1, item2, item3, item4, item5, item6];
            
            ORKStepArrayAddStep(steps, step);
        }
        
    }

    {
        ORKHeadphoneDetectStep *step = [[ORKHeadphoneDetectStep alloc] initWithIdentifier:ORKdBHLToneAudiometryHeadphoneDetectStepIdentifier headphoneTypes:ORKHeadphoneTypesSupported];
        step.title = ORKILocalizedString(@"HEADPHONE_DETECT_TITLE", nil);
        step.detailText = ORKILocalizedString(@"HEADPHONE_DETECT_TEXT", nil);
        [steps addObject:step];
    }
    
    if (!(options & ORKPredefinedTaskOptionExcludeInstructions)) {
        {
            ORKInstructionStep *step = [[ORKInstructionStep alloc] initWithIdentifier:ORKInstruction1StepIdentifier];
            step.title = ORKILocalizedString(@"dBHL_TONE_AUDIOMETRY_TASK_TITLE", nil);
            step.text = ORKILocalizedString(@"dBHL_TONE_AUDIOMETRY_INTRO_TEXT", nil);
            if (UIAccessibilityIsVoiceOverRunning()) {
                step.text = [NSString stringWithFormat:ORKILocalizedString(@"AX_dBHL_TONE_AUDIOMETRY_INTRO_TEXT", nil), step.text];
            }
            step.image = [UIImage imageNamed:@"audiometry" inBundle:ORKBundle() compatibleWithTraitCollection:nil];
            step.imageContentMode = UIViewContentModeCenter;
            step.shouldTintImages = YES;
            
            ORKStepArrayAddStep(steps, step);
        }
        
    }
    
    {
        ORKEnvironmentSPLMeterStep *step = [[ORKEnvironmentSPLMeterStep alloc] initWithIdentifier:@"splMeter"];
        step.requiredContiguousSamples = 5;
        step.thresholdValue = 45;
        step.title = ORKILocalizedString(@"ENVIRONMENTSPL_TITLE_2", nil);
        step.text = ORKILocalizedString(@"ENVIRONMENTSPL_INTRO_TEXT_2", nil);
        
        ORKStepArrayAddStep(steps, step);
    }
    
    {
        ORKInstructionStep *step = [[ORKInstructionStep alloc] initWithIdentifier:ORKInstruction2StepIdentifier];
        step.title = ORKILocalizedString(@"dBHL_TONE_AUDIOMETRY_STEP_TITLE_RIGHT_EAR", nil);
        step.shouldTintImages = YES;
        
        ORKStepArrayAddStep(steps, step);
    }
    
    {
        ORKIdBHLToneAudiometryStep *step = [[ORKIdBHLToneAudiometryStep alloc] initWithIdentifier:ORKdBHLToneAudiometryStep1Identifier];
        step.title = ORKILocalizedString(@"dBHL_TONE_AUDIOMETRY_TASK_TITLE_2", nil);
        step.stepDuration = CGFLOAT_MAX;
        step.algorithm = 1;
        step.earPreference = ORKAudioChannelRight;
        ORKStepArrayAddStep(steps, step);
    }
    
    {
        ORKInstructionStep *step = [[ORKInstructionStep alloc] initWithIdentifier:ORKInstruction3StepIdentifier];
        step.title = ORKILocalizedString(@"dBHL_TONE_AUDIOMETRY_STEP_TITLE_LEFT_EAR", nil);
        ORKStepArrayAddStep(steps, step);
    }
    
    {
        ORKIdBHLToneAudiometryStep *step = [[ORKIdBHLToneAudiometryStep alloc] initWithIdentifier:ORKdBHLToneAudiometryStep2Identifier];
        step.title = ORKILocalizedString(@"dBHL_TONE_AUDIOMETRY_TASK_TITLE_2", nil);
        step.stepDuration = CGFLOAT_MAX;
        step.algorithm = 1;
        step.earPreference = ORKAudioChannelLeft;
        ORKStepArrayAddStep(steps, step);
    }
    
    if (!(options & ORKPredefinedTaskOptionExcludeConclusion)) {
        ORKInstructionStep *step = [self makeCompletionStep];
        ORKStepArrayAddStep(steps, step);
    }
    
    ORKNavigableOrderedTask *task = [[ORKNavigableOrderedTask alloc] initWithIdentifier:identifier steps:steps];
    
    return task;
}

+ (ORKNavigableOrderedTask *)dBHLMethodOfAdjustmentsToneAudiometryTaskWithIdentifier:(NSString *)identifier
                                                              intendedUseDescription:(nullable NSString *)intendedUseDescription
                                                                             options:(ORKPredefinedTaskOption)options {
    if (options & ORKPredefinedTaskOptionExcludeAudio) {
        @throw [NSException exceptionWithName:NSGenericException reason:@"Audio collection cannot be excluded from audio task" userInfo:nil];
    }

    NSMutableArray *steps = [NSMutableArray array];

    {
        ORKHeadphoneDetectStep *step = [[ORKHeadphoneDetectStep alloc] initWithIdentifier:ORKdBHLToneAudiometryHeadphoneDetectStepIdentifier headphoneTypes:ORKHeadphoneTypesSupported];
        step.title = ORKILocalizedString(@"HEADPHONE_DETECT_TITLE", nil);
        step.detailText = ORKILocalizedString(@"HEADPHONE_DETECT_TEXT", nil);
        [steps addObject:step];
    }
    
    {
        ORKdBHLToneAudiometryMethodOfAdjustmentStep *step = [[ORKdBHLToneAudiometryMethodOfAdjustmentStep alloc] initWithIdentifier:ORKdBHLToneAudiometryMethodOfAdjustmentStep1Identifier];
        step.title = ORKILocalizedString(@"dBHL_TONE_AUDIOMETRY_METHOD_OF_ADJUSTMENTS_INTRO_TITLE", nil);
        step.text = ORKILocalizedString(@"dBHL_TONE_AUDIOMETRY_METHOD_OF_ADJUSTMENTS_INTRO_TEXT", nil);
        step.stepDuration = CGFLOAT_MAX;
        step.earPreference = ORKAudioChannelLeft;
        
        ORKStepArrayAddStep(steps, step);
    }
    
    {
        ORKdBHLToneAudiometryMethodOfAdjustmentStep *step = [[ORKdBHLToneAudiometryMethodOfAdjustmentStep alloc] initWithIdentifier:ORKdBHLToneAudiometryMethodOfAdjustmentStep2Identifier];
        step.title = ORKILocalizedString(@"dBHL_TONE_AUDIOMETRY_METHOD_OF_ADJUSTMENTS_INTRO_TITLE", nil);
        step.text = ORKILocalizedString(@"dBHL_TONE_AUDIOMETRY_METHOD_OF_ADJUSTMENTS_INTRO_TEXT", nil);
        step.stepDuration = CGFLOAT_MAX;
        step.earPreference = ORKAudioChannelRight;

        ORKStepArrayAddStep(steps, step);
    }

    if (!(options & ORKPredefinedTaskOptionExcludeConclusion)) {
        ORKInstructionStep *step = [self makeCompletionStep];
        ORKStepArrayAddStep(steps, step);
    }
    
    ORKNavigableOrderedTask *task = [[ORKNavigableOrderedTask alloc] initWithIdentifier:identifier steps:steps];
    
    return task;
}

@end
