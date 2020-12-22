/*
 Copyright (c) 2020, Apple Inc. All rights reserved.
 
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

#import "ORKTinnitusPredefinedTask.h"
#import "ORKTinnitusPredefinedTaskConstants.h"
#import "ORKHeadphoneDetectStep.h"
#import "ORKEnvironmentSPLMeterStep.h"
#import "ORKCompletionStep.h"
#import "ORKQuestionStep.h"

#import "ORKTinnitusPureToneInstructionStep.h"
#import "ORKTinnitusPureToneStep.h"
#import "ORKTinnitusCalibrationStep.h"
#import "ORKTinnitusTypeStep.h"
#import "ORKTinnitusMaskingSoundStep.h"
#import "ORKTinnitusLoudnessMatchingStep.h"
#import "ORKTinnitusWhitenoiseMatchingSoundStep.h"
#import "ORKTinnitusTypeResult.h"

#import "ORKSkin.h"

#import <ResearchKit/ResearchKit_Private.h>

@interface NSMutableArray (Shuffling)
- (void)shuffle;
@end

@implementation NSMutableArray (Shuffling)

- (void)shuffle {
    NSUInteger count = [self count];
    if (count <= 1) return;
    for (NSUInteger i = 0; i < count - 1; ++i) {
        NSInteger remainingCount = count - i;
        NSInteger exchangeIndex = i + arc4random_uniform((u_int32_t )remainingCount);
        [self exchangeObjectAtIndex:i withObjectAtIndex:exchangeIndex];
    }
}

@end

@interface ORKTinnitusPredefinedTask () {
    UIColor *_cachedBGColor;
    NSDictionary *_stepAfterStepDict;
    NSDictionary *_stepBeforeStepDict;
    
    ORKInstructionStep *_instruction1;
    ORKQuestionStep *_surveyQuestion1;
    ORKQuestionStep *_surveyQuestion2;
    ORKQuestionStep *_surveyQuestion3;
    ORKQuestionStep *_surveyQuestion4;
    ORKQuestionStep *_surveyQuestion5;
    ORKQuestionStep *_surveyQuestion6;
    ORKQuestionStep *_surveyQuestion7;
    ORKQuestionStep *_surveyQuestion8;
    ORKQuestionStep *_surveyQuestion9;
    ORKQuestionStep *_surveyQuestion10;
    ORKCompletionStep *_surveyCompletion;
    
    ORKInstructionStep *_testingInstruction;
    ORKInstructionStep *_beforeStart;
    ORKHeadphoneDetectStep *_headphone;
    ORKEnvironmentSPLMeterStep *_splmeter;
    ORKTinnitusTypeStep *_tinnitusType;
    ORKTinnitusCalibrationStep *_calibration;
    ORKTinnitusPureToneInstructionStep *_pitchMatching;
    
    double _predominantFrequency;
    
    ORKTinnitusPureToneStep *_round1;
    ORKInstructionStep *_round1SuccessCompleted;
    ORKTinnitusPureToneStep *_round2;
    ORKInstructionStep *_round2SuccessCompleted;
    ORKTinnitusPureToneStep *_round3;
    
    ORKTinnitusLoudnessMatchingStep *_loudnessMatching;
    ORKTinnitusLoudnessMatchingStep *_soundLoudnessMatching;
    
    ORKTinnitusMaskingSoundStep *_fireMasking;
    ORKTinnitusMaskingSoundStep *_fireMaskingNotch;
    ORKTinnitusMaskingSoundStep *_whitenoiseMasking;
    ORKTinnitusMaskingSoundStep *_whitenoiseMaskingNotch;
    ORKTinnitusMaskingSoundStep *_rainMasking;
    ORKTinnitusMaskingSoundStep *_rainMaskingNotch;
    ORKTinnitusMaskingSoundStep *_forestMasking;
    ORKTinnitusMaskingSoundStep *_forestMaskingNotch;
    ORKTinnitusMaskingSoundStep *_oceanMasking;
    ORKTinnitusMaskingSoundStep *_oceanMaskingNotch;
    ORKTinnitusMaskingSoundStep *_crowdMasking;
    ORKTinnitusMaskingSoundStep *_crowdMaskingNotch;
    ORKTinnitusMaskingSoundStep *_audiobookMasking;
    ORKTinnitusMaskingSoundStep *_audiobookMaskingNotch;
    
    ORKCompletionStep *_completionSuccess;
    
    ORKTinnitusWhitenoiseMatchingSoundStep *_whitenoiseMatching;
    
    ORKTinnitusType _type;
    ORKTinnitusNoiseType _noiseType;
    
    NSArray<NSArray <ORKTinnitusMaskingSoundStep*>*> *_maskingSteps;
}

@end

@implementation ORKTinnitusPredefinedTask

- (instancetype)initWithIdentifier:(NSString *)identifier {
    self = [super initWithIdentifier:identifier steps:nil];
    if (self) {
        _predominantFrequency = 0.0;
    }
    return self;
}

- (void)initMaskingSteps {
    NSMutableArray<ORKStep *> *steps = [[NSMutableArray alloc] initWithObjects:
                                        @[self.fireMasking, self.fireMaskingNotch],
                                        @[self.whitenoiseMasking, self.whitenoiseMaskingNotch],
                                        @[self.rainMasking, self.rainMaskingNotch],
                                        @[self.forestMasking, self.forestMaskingNotch],
                                        @[self.oceanMasking, self.oceanMaskingNotch],
                                        @[self.crowdMasking, self.crowdMaskingNotch],
                                        @[self.audiobookMasking, self.audiobookMaskingNotch], nil];
    [steps shuffle];
    
    _maskingSteps = [steps copy];
}

- (ORKStep *)stepAfterStep:(ORKStep *)step withResult:(id<ORKTaskResultSource>)result {
    NSString *identifier = step.identifier;
    if (step == nil) {
        [self setupStraightStepAfterStepDict];
        [self setupBGColor];
        
        return self.instruction1;
    }
    
    ORKStep *nextStep = _stepAfterStepDict[identifier];

    // cases that treats changes of flow
    if (!nextStep) {
        if ([identifier isEqualToString:ORKTinnitusSurvey1StepIdentifier]) {
            // Special case, the user never heard tinnitus
            ORKStepResult *stepResult = [result stepResultForStepIdentifier:ORKTinnitusSurvey1StepIdentifier];
            ORKQuestionResult *questionResult = (ORKQuestionResult *)(stepResult.results.count > 0 ? stepResult.results.firstObject : nil);
            if (questionResult.answer != nil) {
                if ([((NSArray *)questionResult.answer).firstObject isEqualToString:ORKTinnitusSurveyAnswerNever]) {
                    return self.surveyCompletion;
                }
            }
            return self.surveyQuestion2;
        } else if ([identifier isEqualToString:ORKTinnitusSurvey5StepIdentifier]) {
            ORKStepResult *stepResult = [result stepResultForStepIdentifier:ORKTinnitusSurvey5StepIdentifier];
            ORKQuestionResult *questionResult = (ORKQuestionResult *)(stepResult.results.count > 0 ? stepResult.results.firstObject : nil);
            if (questionResult.answer != nil) {
                if ([((NSArray *)questionResult.answer).firstObject isEqualToString:ORKTinnitusSurveyAnswerYes]) {
                    return self.surveyQuestion6;
                }
            }
            // If user answers ‘No’ or ‘I prefer not to answer’ we jump the other survey questions
            return self.surveyQuestion10;
        } else if ([identifier isEqualToString:ORKTinnitusWhitenoiseMatchingIdentifier]) {
            if ([_type isEqualToString:ORKTinnitusTypeWhiteNoise]) {
                ORKStepResult *stepResult = [result stepResultForStepIdentifier:ORKTinnitusWhitenoiseMatchingIdentifier];
                ORKTinnitusWhitenoiseMatchingSoundResult *questionResult = (ORKTinnitusWhitenoiseMatchingSoundResult *)(stepResult.results.count > 0 ? stepResult.results.firstObject : nil);
                NSString *answer = questionResult.answer;
                if (answer != nil) {
                    _noiseType = answer;
                } else {
                    return self.loudnessMatching;
                }
            }
            if ([self checkValidMaskingSound:_noiseType]) {
                return self.soundLoudnessMatching;
            }
            return self.fireMasking;
        } else if ([identifier isEqualToString:ORKTinnitusBeforeStartStepIdentifier]) {
#if TARGET_IPHONE_SIMULATOR
            return self.tinnitusType;
#else
            return self.headphone;
#endif
        } else if ([identifier isEqualToString:ORKTinnitusVolumeCalibrationStepIdentifier]) {
            ORKStepResult *stepResult = [result stepResultForStepIdentifier:ORKTinnitusTypeStepIdentifier];
            ORKTinnitusTypeResult *questionResult = (ORKTinnitusTypeResult *)(stepResult.results.count > 0 ? stepResult.results.firstObject : nil);
            if (questionResult.type != nil) {
                _type = questionResult.type;
                if ([questionResult.type isEqualToString:ORKTinnitusTypePureTone]) {
                    return self.pitchMatching;
                }
            }
            return self.whitenoiseMatching;
        } else if ([identifier isEqualToString:ORKTinnitusRound3StepIdentifier]) {
            _predominantFrequency = [self predominantFrequencyForResult:result];
            if (_predominantFrequency > 0.0) {
                return self.loudnessMatching;
            }
            return [self stepForMaskingSoundNumber:0];
        } else if ([identifier isEqualToString:ORKTinnitusLoudnessMatchingStepIdentifier] ||
                   [identifier isEqualToString:ORKTinnitusSoundLoudnessMatchingStepIdentifier]) {
            return [self stepForMaskingSoundNumber:0];
        } else if ([identifier isEqualToString:ORKTinnitusPuretoneSuccessStepIdentifier]) {
            return nil;
        }
        
        nextStep = [self nextMaskingStepForIdentifier:identifier];
        
        if (!nextStep) {
            return self.completionSuccess;
        }
    }

    return nextStep;
}

- (ORKStep *)stepBeforeStep:(ORKStep *)step withResult:(ORKTaskResult *)result {
    NSString *identifier = step.identifier;
    if (identifier == nil || [identifier isEqualToString: ORKTinnitusInstruction1StepIdentifier]) {
        [self setupStraightStepBeforeStepDict];
        return nil;
    }
    
    ORKStep *previousStep = _stepBeforeStepDict[identifier];
    
    if (!previousStep) {
        if ([identifier isEqualToString:ORKTinnitusTestingInstructionStepIdentifier]) {
            ORKStepResult *stepResult = [result stepResultForStepIdentifier:ORKTinnitusSurvey5StepIdentifier];
            ORKQuestionResult *questionResult = (ORKQuestionResult *)(stepResult.results.count > 0 ? stepResult.results.firstObject : nil);
            if (questionResult.answer != nil) {
                if ([((NSArray *)questionResult.answer).firstObject isEqualToString:ORKTinnitusSurveyAnswerYes]) {
                    return self.surveyQuestion5;
                }
            }
            return self.surveyQuestion10;
        }
    }

    return previousStep;
}

- (void)setupStraightStepAfterStepDict {
    [self initMaskingSteps];
    _stepAfterStepDict = @{
        ORKTinnitusInstruction1StepIdentifier: self.surveyQuestion1,
        ORKTinnitusSurvey2StepIdentifier: self.surveyQuestion3,
        ORKTinnitusSurvey3StepIdentifier: self.surveyQuestion4,
        ORKTinnitusSurvey4StepIdentifier: self.surveyQuestion5,
        ORKTinnitusSurvey6StepIdentifier: self.surveyQuestion7,
        ORKTinnitusSurvey7StepIdentifier: self.surveyQuestion8,
        ORKTinnitusSurvey8StepIdentifier: self.testingInstruction,
        ORKTinnitusSurvey9StepIdentifier: self.surveyQuestion10,
        ORKTinnitusSurvey10StepIdentifier: self.testingInstruction,
        ORKTinnitusTestingInstructionStepIdentifier: self.beforeStart,
        ORKTinnitusHeadphoneDetectStepIdentifier: self.splmeter,
        ORKTinnitusSPLMeterStepIdentifier: self.tinnitusType,
        ORKTinnitusTypeStepIdentifier: self.calibration,
        ORKTinnitusPitchMatchingStepIdentifier: self.round1,
        ORKTinnitusRound1StepIdentifier: self.round1SuccessCompleted,
        ORKTinnitusRound1SuccessCompletedStepIdentifier: self.round2,
        ORKTinnitusRound2StepIdentifier: self.round2SuccessCompleted,
        ORKTinnitusRound2SuccessCompletedStepIdentifier: self.round3
    };
}

- (void)setupStraightStepBeforeStepDict {
    _stepBeforeStepDict = @{
        ORKTinnitusSurvey1StepIdentifier: self.instruction1,
        ORKTinnitusSurvey2StepIdentifier: self.surveyQuestion1,
        ORKTinnitusSurvey3StepIdentifier: self.surveyQuestion2,
        ORKTinnitusSurvey4StepIdentifier: self.surveyQuestion3,
        ORKTinnitusSurvey5StepIdentifier: self.surveyQuestion4,
        ORKTinnitusSurvey6StepIdentifier: self.surveyQuestion5,
        ORKTinnitusSurvey7StepIdentifier: self.surveyQuestion6,
        ORKTinnitusSurvey8StepIdentifier: self.surveyQuestion7,
        ORKTinnitusSurvey10StepIdentifier: self.surveyQuestion5,
        ORKTinnitusBeforeStartStepIdentifier: self.testingInstruction
    };
}

- (nullable ORKTinnitusMaskingSoundStep *)stepForMaskingSoundNumber:(NSUInteger)index {
    if (index < _maskingSteps.count) {
        return _maskingSteps[index][0];
    }
    return nil;
}

- (nullable ORKTinnitusMaskingSoundStep *)stepForNotchMaskingSoundNumber:(NSUInteger)index {
    if (index < _maskingSteps.count) {
        return _maskingSteps[index][1];
    }
    return nil;
}

- (nullable ORKTinnitusMaskingSoundStep *)nextMaskingStepForIdentifier:(NSString *)identifier {
    __block NSUInteger index = 0;
    [_maskingSteps objectsAtIndexes:[_maskingSteps indexesOfObjectsPassingTest:^BOOL(NSArray <ORKTinnitusMaskingSoundStep *> *steps, NSUInteger idx, BOOL *stop) {
        if ([steps[0].identifier isEqualToString:identifier] ||
            [steps[1].identifier isEqualToString:identifier]) {
            index = idx;
            *stop = YES;
            return YES;
        }
        return NO;
    }]];
    if ([identifier isEqualToString:[self stepForMaskingSoundNumber:index].identifier]) {
        if (_predominantFrequency > 0.0) {
            ORKTinnitusMaskingSoundStep *maskingSoundStep = [self stepForNotchMaskingSoundNumber:index];
            maskingSoundStep.notchFrequency = _predominantFrequency;
            return maskingSoundStep;
        }
        return [self stepForMaskingSoundNumber:index+1];
    } else if ([identifier isEqualToString:[self stepForNotchMaskingSoundNumber:index].identifier]) {
        return [self stepForMaskingSoundNumber:index+1];
    }
    return nil;
}

- (void)setupBGColor {
    if (_cachedBGColor == nil) {
        _cachedBGColor = ORKColor(ORKBackgroundColorKey);
        if (@available(iOS 13.0, *)) {
            UIColor *adaptativeColor = [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull traitCollection) {
                if (traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) {
                    return [UIColor colorWithRed:18/255.0 green:18/255.0 blue:20/255.0 alpha:1.0];
                }
                return UIColor.whiteColor;
            }];
            ORKColorSetColorForKey(ORKBackgroundColorKey, adaptativeColor);
        } else {
            ORKColorSetColorForKey(ORKBackgroundColorKey, UIColor.whiteColor);
        }
    }
}

- (void)dealloc {
    if (_cachedBGColor != nil) {
        ORKColorSetColorForKey(ORKBackgroundColorKey, _cachedBGColor);
        _cachedBGColor = nil;
    }
}

- (BOOL)checkValidMaskingSound:(ORKTinnitusNoiseType)type {
    return [type isEqualToString:ORKTinnitusNoiseTypeCicadas]
    || [type isEqualToString:ORKTinnitusNoiseTypeCrickets]
    || [type isEqualToString:ORKTinnitusNoiseTypeWhitenoise]
    || [type isEqualToString:ORKTinnitusNoiseTypeTeakettle];
}

- (double)predominantFrequencyForResult:(id<ORKTaskResultSource>)result {
    ORKStepResult *stepResult = [result stepResultForStepIdentifier:ORKTinnitusRound1StepIdentifier];
    ORKTinnitusPureToneResult *round1Result = (ORKTinnitusPureToneResult *)(stepResult.results.count > 0 ? stepResult.results.firstObject : nil);
    stepResult = [result stepResultForStepIdentifier:ORKTinnitusRound2StepIdentifier];
    ORKTinnitusPureToneResult *round2Result = (ORKTinnitusPureToneResult *)(stepResult.results.count > 0 ? stepResult.results.firstObject : nil);
    stepResult = [result stepResultForStepIdentifier:ORKTinnitusRound3StepIdentifier];
    ORKTinnitusPureToneResult *round3Result = (ORKTinnitusPureToneResult *)(stepResult.results.count > 0 ? stepResult.results.firstObject : nil);
    
    NSNumber *predominantFrequency;
    
    if (round3Result) {
        NSNumber *round1ChosenFrequency = [NSNumber numberWithDouble:round1Result.chosenFrequency];
        NSNumber *round2ChosenFrequency = [NSNumber numberWithDouble:round2Result.chosenFrequency];
        NSNumber *round3ChosenFrequency = [NSNumber numberWithDouble:round3Result.chosenFrequency];
        NSArray *resultChosenFrequencies = [NSArray arrayWithObjects:round1ChosenFrequency, round2ChosenFrequency, round3ChosenFrequency, nil];
        
        NSCountedSet *set = [[NSCountedSet alloc] initWithArray:resultChosenFrequencies];
        
        for (NSNumber* freq in set) {
            if ([set countForObject:freq] > 1) {
                predominantFrequency = freq;
            }
        }
    }
    
    return predominantFrequency ? [predominantFrequency doubleValue] : 0.0;
}

// Explicitly hide progress indication for all steps in this dynamic task.
- (ORKTaskProgress)progressOfCurrentStep:(ORKStep *)step withResultProvider:(NSArray *)surveyResults {
    return (ORKTaskProgress){.total = 0, .current = 0};
}

- (ORKInstructionStep *)instruction1 {
    if (_instruction1 == nil) {
        _instruction1 = [[ORKInstructionStep alloc] initWithIdentifier:ORKTinnitusInstruction1StepIdentifier];
        _instruction1.title = ORKLocalizedString(@"TINNITUS_INTRO_TITLE", nil);
        _instruction1.detailText = ORKLocalizedString(@"TINNITUS_INTRO_TEXT_2", nil);
        _instruction1.iconImage = [UIImage imageNamed:@"tinnitus-icon" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
        _instruction1.imageContentMode = UIViewContentModeTopLeft;
        _instruction1.shouldTintImages = YES;
        
        UIImage *img1;
        UIImage *img2;
        UIImage *img3;

        if (@available(iOS 13.0, *)) {
            img1 = [UIImage systemImageNamed:@"1.circle.fill"];
            img2 = [UIImage systemImageNamed:@"2.circle.fill"];
            img3 = [UIImage systemImageNamed:@"3.circle.fill"];
        } else {
            // not implemeted
        }
        
        ORKBodyItem * item1 = [[ORKBodyItem alloc] initWithText:ORKLocalizedString(@"TINNITUS_BODY_ITEM_TEXT_1", nil) detailText:nil image:img1 learnMoreItem:nil bodyItemStyle:ORKBodyItemStyleImage];
        ORKBodyItem * item2 = [[ORKBodyItem alloc] initWithHorizontalRule];
        ORKBodyItem * item3 = [[ORKBodyItem alloc] initWithText:ORKLocalizedString(@"TINNITUS_BODY_ITEM_TEXT_2", nil) detailText:nil image:img2 learnMoreItem:nil bodyItemStyle:ORKBodyItemStyleImage];
        ORKBodyItem * item4 = [[ORKBodyItem alloc] initWithHorizontalRule];
        ORKBodyItem * item5 = [[ORKBodyItem alloc] initWithText:ORKLocalizedString(@"TINNITUS_BODY_ITEM_TEXT_3", nil) detailText:nil image:img3 learnMoreItem:nil bodyItemStyle:ORKBodyItemStyleImage];
        _instruction1.bodyItems = @[item1,item2, item3, item4, item5];
    }
    return _instruction1;
}

- (ORKQuestionStep *)surveyQuestion1 {
    if (_surveyQuestion1 == nil) {
        ORKTextChoice *never = [ORKTextChoice choiceWithText:ORKLocalizedString(@"TINNITUS_SURVEY_QUESTION1_ITEM1", nil)
                                                       value:ORKTinnitusSurveyAnswerNever];
        ORKTextChoice *rarely = [ORKTextChoice choiceWithText:ORKLocalizedString(@"TINNITUS_SURVEY_QUESTION1_ITEM2", nil)
                                                        value:ORKTinnitusSurveyAnswerRarely];
        ORKTextChoice *sometimes = [ORKTextChoice choiceWithText:ORKLocalizedString(@"TINNITUS_SURVEY_QUESTION1_ITEM3", nil)
                                                           value:ORKTinnitusSurveyAnswerSometimes];
        ORKTextChoice *often = [ORKTextChoice choiceWithText:ORKLocalizedString(@"TINNITUS_SURVEY_QUESTION1_ITEM4", nil)
                                                       value:ORKTinnitusSurveyAnswerOften];
        ORKTextChoice *always = [ORKTextChoice choiceWithText:ORKLocalizedString(@"TINNITUS_SURVEY_QUESTION1_ITEM5", nil)
                                                        value:ORKTinnitusSurveyAnswerAlways];
        ORKTextChoice *pnta = [ORKTextChoice choiceWithText:ORKLocalizedString(@"TINNITUS_SURVEY_IPNTA", nil)
                                                      value:ORKTinnitusSurveyAnswerPNTA];
        
        ORKAnswerFormat *answerFormat = [ORKAnswerFormat choiceAnswerFormatWithStyle:ORKChoiceAnswerStyleSingleChoice
                                                                         textChoices:@[never, rarely, sometimes, often, always, pnta]];
        _surveyQuestion1 = [ORKQuestionStep questionStepWithIdentifier:ORKTinnitusSurvey1StepIdentifier
                                                                 title:ORKLocalizedString(@"TINNITUS_SURVEY_TITLE", nil)
                                                              question:ORKLocalizedString(@"TINNITUS_SURVEY_QUESTION1_TEXT", nil)
                                                                answer:answerFormat];
        _surveyQuestion1.optional = NO;
    }
    return _surveyQuestion1;
}

- (ORKQuestionStep *)surveyQuestion2 {
    if (_surveyQuestion2 == nil) {
        ORKTextChoice *yes = [ORKTextChoice choiceWithText:ORKLocalizedString(@"TINNITUS_SURVEY_YES", nil)
                                                     value:ORKTinnitusSurveyAnswerYes];
        ORKTextChoice *no = [ORKTextChoice choiceWithText:ORKLocalizedString(@"TINNITUS_SURVEY_NO", nil)
                                                    value:ORKTinnitusSurveyAnswerNo];
        ORKTextChoice *pnta = [ORKTextChoice choiceWithText:ORKLocalizedString(@"TINNITUS_SURVEY_IPNTA", nil)
                                                      value:ORKTinnitusSurveyAnswerPNTA];
        
        ORKAnswerFormat *answerFormat = [ORKAnswerFormat choiceAnswerFormatWithStyle:ORKChoiceAnswerStyleSingleChoice
                                                                         textChoices:@[yes, no, pnta]];
        _surveyQuestion2 = [ORKQuestionStep questionStepWithIdentifier:ORKTinnitusSurvey2StepIdentifier
                                                                 title:ORKLocalizedString(@"TINNITUS_SURVEY_TITLE", nil)
                                                              question:ORKLocalizedString(@"TINNITUS_SURVEY_QUESTION2_TEXT", nil)
                                                                answer:answerFormat];
        _surveyQuestion2.optional = NO;
    }
    return _surveyQuestion2;
}

- (ORKCompletionStep *)surveyCompletion {
    if (_surveyCompletion == nil) {
        _surveyCompletion = [[ORKCompletionStep alloc] initWithIdentifier:ORKTinnitusSurveyEndStepIdentifier];
        _surveyCompletion.title = ORKLocalizedString(@"TINNITUS_COMPLETION_NO_TINNITUS_TITLE", nil);
        _surveyCompletion.text = ORKLocalizedString(@"TINNITUS_COMPLETION_NO_TINNITUS_TEXT", nil);
        _surveyCompletion.shouldTintImages = YES;
    }
    return _surveyCompletion;
}

- (ORKQuestionStep *)surveyQuestion3 {
    if (_surveyQuestion3 == nil) {
        ORKTextChoice *leftSide = [ORKTextChoice choiceWithText:ORKLocalizedString(@"TINNITUS_SURVEY_QUESTION3_ITEM1", nil)
                                                          value:ORKTinnitusSurveyAnswerLeft];
        ORKTextChoice *rightSide = [ORKTextChoice choiceWithText:ORKLocalizedString(@"TINNITUS_SURVEY_QUESTION3_ITEM2", nil)
                                                           value:ORKTinnitusSurveyAnswerRight];
        ORKTextChoice *center = [ORKTextChoice choiceWithText:ORKLocalizedString(@"TINNITUS_SURVEY_QUESTION3_ITEM3", nil)
                                                        value:ORKTinnitusSurveyAnswerBoth];
        ORKTextChoice *pnta = [ORKTextChoice choiceWithText:ORKLocalizedString(@"TINNITUS_SURVEY_IPNTA", nil)
                                                      value:ORKTinnitusSurveyAnswerPNTA];
        
        ORKAnswerFormat *answerFormat = [ORKAnswerFormat choiceAnswerFormatWithStyle:ORKChoiceAnswerStyleSingleChoice
                                                                         textChoices:@[leftSide, rightSide, center, pnta]];
        _surveyQuestion3 = [ORKQuestionStep questionStepWithIdentifier:ORKTinnitusSurvey3StepIdentifier
                                                                 title:ORKLocalizedString(@"TINNITUS_SURVEY_TITLE", nil)
                                                              question:ORKLocalizedString(@"TINNITUS_SURVEY_QUESTION3_TEXT", nil)
                                                                answer:answerFormat];
        _surveyQuestion3.optional = NO;
    }
    return _surveyQuestion3;
}

- (ORKQuestionStep *)surveyQuestion4 {
    if (_surveyQuestion4 == nil) {
        ORKTextChoice *extremely = [ORKTextChoice choiceWithText:ORKLocalizedString(@"TINNITUS_SURVEY_QUESTION4_ITEM1", nil)
                                                     value:ORKTinnitusSurveyAnswerExtremely];
        ORKTextChoice *very = [ORKTextChoice choiceWithText:ORKLocalizedString(@"TINNITUS_SURVEY_QUESTION4_ITEM2", nil)
                                                    value:ORKTinnitusSurveyAnswerVery];
        ORKTextChoice *moderately = [ORKTextChoice choiceWithText:ORKLocalizedString(@"TINNITUS_SURVEY_QUESTION4_ITEM3", nil)
                                                           value:ORKTinnitusSurveyAnswerModerately];
        ORKTextChoice *notvery = [ORKTextChoice choiceWithText:ORKLocalizedString(@"TINNITUS_SURVEY_QUESTION4_ITEM4", nil)
                                                      value:ORKTinnitusSurveyAnswerNotVery];
        ORKTextChoice *barely = [ORKTextChoice choiceWithText:ORKLocalizedString(@"TINNITUS_SURVEY_QUESTION4_ITEM5", nil)
                                                      value:ORKTinnitusSurveyAnswerBarely];
        
        ORKTextChoice *pnta = [ORKTextChoice choiceWithText:ORKLocalizedString(@"TINNITUS_SURVEY_IPNTA", nil)
                                                      value:ORKTinnitusSurveyAnswerPNTA];
        
        ORKAnswerFormat *answerFormat = [ORKAnswerFormat choiceAnswerFormatWithStyle:ORKChoiceAnswerStyleSingleChoice
                                                                         textChoices:@[extremely, very, moderately, notvery, barely, pnta]];
        _surveyQuestion4 = [ORKQuestionStep questionStepWithIdentifier:ORKTinnitusSurvey4StepIdentifier
                                                                 title:ORKLocalizedString(@"TINNITUS_SURVEY_TITLE", nil)
                                                              question:ORKLocalizedString(@"TINNITUS_SURVEY_QUESTION4_TEXT", nil)
                                                                answer:answerFormat];
        _surveyQuestion4.optional = NO;
    }
    return _surveyQuestion4;
}

- (ORKQuestionStep *)surveyQuestion5 {
    if (_surveyQuestion5 == nil) {
        ORKTextChoice *yes = [ORKTextChoice choiceWithText:ORKLocalizedString(@"TINNITUS_SURVEY_YES", nil)
                                                     value:ORKTinnitusSurveyAnswerYes];
        ORKTextChoice *no = [ORKTextChoice choiceWithText:ORKLocalizedString(@"TINNITUS_SURVEY_NO", nil)
                                                    value:ORKTinnitusSurveyAnswerNo];
        ORKTextChoice *pnta = [ORKTextChoice choiceWithText:ORKLocalizedString(@"TINNITUS_SURVEY_IPNTA", nil)
                                                      value:ORKTinnitusSurveyAnswerPNTA];
        
        ORKAnswerFormat *answerFormat = [ORKAnswerFormat choiceAnswerFormatWithStyle:ORKChoiceAnswerStyleSingleChoice
                                                                         textChoices:@[yes, no, pnta]];
        _surveyQuestion5 = [ORKQuestionStep questionStepWithIdentifier:ORKTinnitusSurvey5StepIdentifier
                                                                 title:ORKLocalizedString(@"TINNITUS_SURVEY_TITLE", nil)
                                                              question:ORKLocalizedString(@"TINNITUS_SURVEY_QUESTION5_TEXT", nil)
                                                                answer:answerFormat];
        _surveyQuestion5.optional = NO;
    }
    return _surveyQuestion5;
}

- (ORKQuestionStep *)surveyQuestion6 {
    if (_surveyQuestion6 == nil) {
        ORKTextChoice *app = [ORKTextChoice choiceWithText:ORKLocalizedString(@"TINNITUS_SURVEY_QUESTION6_ITEM1", nil)
                                                     value:ORKTinnitusSurveyAnswerApp];
        ORKTextChoice *fan = [ORKTextChoice choiceWithText:ORKLocalizedString(@"TINNITUS_SURVEY_QUESTION6_ITEM2", nil)
                                                     value:ORKTinnitusSurveyAnswerFan];
        ORKTextChoice *noise = [ORKTextChoice choiceWithText:ORKLocalizedString(@"TINNITUS_SURVEY_QUESTION6_ITEM3", nil)
                                                       value:ORKTinnitusSurveyAnswerNoise];
        ORKTextChoice *hearingAids = [ORKTextChoice choiceWithText:ORKLocalizedString(@"TINNITUS_SURVEY_QUESTION6_ITEM4", nil)
                                                       value:ORKTinnitusSurveyAnswerHearingAid];
        ORKTextChoice *pnta = [ORKTextChoice choiceWithText:ORKLocalizedString(@"TINNITUS_SURVEY_IPNTA", nil)
                                                 detailText:nil value:ORKTinnitusSurveyAnswerPNTA exclusive:YES];
        
        ORKAnswerFormat *answerFormat = [ORKAnswerFormat choiceAnswerFormatWithStyle:ORKChoiceAnswerStyleMultipleChoice
                                                                         textChoices:@[app, fan, noise, hearingAids, pnta]];
        
        _surveyQuestion6 = [ORKQuestionStep questionStepWithIdentifier:ORKTinnitusSurvey6StepIdentifier
                                                                 title:ORKLocalizedString(@"TINNITUS_SURVEY_TITLE", nil)
                                                              question:ORKLocalizedString(@"TINNITUS_SURVEY_QUESTION6_TEXT", nil)
                                                                answer:answerFormat];
        _surveyQuestion6.optional = NO;
    }
    return _surveyQuestion6;
}

- (ORKQuestionStep *)surveyQuestion7 {
    if (_surveyQuestion7 == nil) {
        ORKTextChoice *blog = [ORKTextChoice choiceWithText:ORKLocalizedString(@"TINNITUS_SURVEY_QUESTION7_ITEM1", nil)
                                                       value:ORKTinnitusSurveyAnswerBlog];
        ORKTextChoice *research = [ORKTextChoice choiceWithText:ORKLocalizedString(@"TINNITUS_SURVEY_QUESTION7_ITEM2", nil)
                                                        value:ORKTinnitusSurveyAnswerResearch];
        ORKTextChoice *audiologist = [ORKTextChoice choiceWithText:ORKLocalizedString(@"TINNITUS_SURVEY_QUESTION7_ITEM3", nil)
                                                       value:ORKTinnitusSurveyAnswerAudiologist];
        ORKTextChoice *word = [ORKTextChoice choiceWithText:ORKLocalizedString(@"TINNITUS_SURVEY_QUESTION7_ITEM4", nil)
                                                        value:ORKTinnitusSurveyAnswerWord];
        ORKTextChoice *pnta = [ORKTextChoice choiceWithText:ORKLocalizedString(@"TINNITUS_SURVEY_IPNTA", nil)
                                                 detailText:nil
                                                      value:ORKTinnitusSurveyAnswerPNTA
                                                  exclusive:YES];
        ORKAnswerFormat *answerFormat = [ORKAnswerFormat choiceAnswerFormatWithStyle:ORKChoiceAnswerStyleMultipleChoice
                                                                         textChoices:@[blog, research, audiologist, word, pnta]];
        
        _surveyQuestion7 = [ORKQuestionStep questionStepWithIdentifier:ORKTinnitusSurvey7StepIdentifier
                                                                 title:ORKLocalizedString(@"TINNITUS_SURVEY_TITLE", nil)
                                                              question:ORKLocalizedString(@"TINNITUS_SURVEY_QUESTION7_TEXT", nil)
                                                                answer:answerFormat];
        _surveyQuestion7.optional = NO;
    }
    return _surveyQuestion7;
}

- (ORKQuestionStep *)surveyQuestion8 {
    if (_surveyQuestion8 == nil) {
        ORKTextChoice *music = [ORKTextChoice choiceWithText:ORKLocalizedString(@"TINNITUS_SURVEY_QUESTION8_ITEM1", nil)
                                                       value:ORKTinnitusSurveyAnswerMusic];
        ORKTextChoice *speech = [ORKTextChoice choiceWithText:ORKLocalizedString(@"TINNITUS_SURVEY_QUESTION8_ITEM2", nil)
                                                        value:ORKTinnitusSurveyAnswerSpeech];
        ORKTextChoice *noise = [ORKTextChoice choiceWithText:ORKLocalizedString(@"TINNITUS_SURVEY_QUESTION8_ITEM3", nil)
                                                       value:ORKTinnitusSurveyAnswerNoise];
        ORKTextChoice *nature = [ORKTextChoice choiceWithText:ORKLocalizedString(@"TINNITUS_SURVEY_QUESTION8_ITEM4", nil)
                                                        value:ORKTinnitusSurveyAnswerNature];
        ORKTextChoice *tones = [ORKTextChoice choiceWithText:ORKLocalizedString(@"TINNITUS_SURVEY_QUESTION8_ITEM5", nil)
                                                       value:ORKTinnitusSurveyAnswerModulatedTones];
        ORKTextChoice *pnta = [ORKTextChoice choiceWithText:ORKLocalizedString(@"TINNITUS_SURVEY_IPNTA", nil)
                                                 detailText:nil
                                                      value:ORKTinnitusSurveyAnswerPNTA
                                                  exclusive:YES];
        ORKAnswerFormat *answerFormat = [ORKAnswerFormat choiceAnswerFormatWithStyle:ORKChoiceAnswerStyleMultipleChoice
                                                                         textChoices:@[music, speech, noise, nature, tones, pnta]];
        
        _surveyQuestion8 = [ORKQuestionStep questionStepWithIdentifier:ORKTinnitusSurvey8StepIdentifier
                                                                 title:ORKLocalizedString(@"TINNITUS_SURVEY_TITLE", nil)
                                                              question:ORKLocalizedString(@"TINNITUS_SURVEY_QUESTION8_TEXT", nil)
                                                                answer:answerFormat];
        _surveyQuestion8.optional = NO;
    }
    return _surveyQuestion8;
}

- (ORKQuestionStep *)surveyQuestion9 {
    if (_surveyQuestion9 == nil) {
        ORKTextChoice *focus = [ORKTextChoice choiceWithText:ORKLocalizedString(@"TINNITUS_SURVEY_QUESTION9_ITEM1", nil)
                                                       value:ORKTinnitusSurveyAnswerFocus];
        ORKTextChoice *asleep = [ORKTextChoice choiceWithText:ORKLocalizedString(@"TINNITUS_SURVEY_QUESTION9_ITEM2", nil)
                                                        value:ORKTinnitusSurveyAnswerAsleep];
        ORKTextChoice *exercising = [ORKTextChoice choiceWithText:ORKLocalizedString(@"TINNITUS_SURVEY_QUESTION9_ITEM3", nil)
                                                            value:ORKTinnitusSurveyAnswerExercising];
        ORKTextChoice *relax = [ORKTextChoice choiceWithText:ORKLocalizedString(@"TINNITUS_SURVEY_QUESTION9_ITEM4", nil)
                                                       value:ORKTinnitusSurveyAnswerRelax];
        ORKTextChoice *pnta = [ORKTextChoice choiceWithText:ORKLocalizedString(@"TINNITUS_SURVEY_IPNTA", nil)
                                                 detailText:nil
                                                      value:ORKTinnitusSurveyAnswerPNTA
                                                  exclusive:YES];
        ORKAnswerFormat *answerFormat = [ORKAnswerFormat choiceAnswerFormatWithStyle:ORKChoiceAnswerStyleMultipleChoice
                                                                         textChoices:@[focus, asleep, exercising, relax, pnta]];
        
        _surveyQuestion9 = [ORKQuestionStep questionStepWithIdentifier:ORKTinnitusSurvey9StepIdentifier
                                                                 title:ORKLocalizedString(@"TINNITUS_SURVEY_TITLE", nil)
                                                              question:ORKLocalizedString(@"TINNITUS_SURVEY_QUESTION9_TEXT", nil)
                                                                answer:answerFormat];
        _surveyQuestion9.optional = NO;
    }
    return _surveyQuestion9;
}

- (ORKQuestionStep *)surveyQuestion10 {
    if (_surveyQuestion10 == nil) {
        ORKTextChoice *didNotKnow = [ORKTextChoice choiceWithText:ORKLocalizedString(@"TINNITUS_SURVEY_QUESTION10_ITEM1", nil)
                                                       value:ORKTinnitusSurveyAnswerDidNotKnow];
        ORKTextChoice *doNotNeed = [ORKTextChoice choiceWithText:ORKLocalizedString(@"TINNITUS_SURVEY_QUESTION10_ITEM2", nil)
                                                           value:ORKTinnitusSurveyAnswerDidNotKnow];
        ORKTextChoice *doctorAgainst = [ORKTextChoice choiceWithText:ORKLocalizedString(@"TINNITUS_SURVEY_QUESTION10_ITEM3", nil)
                                                            value:ORKTinnitusSurveyAnswerDoctorAgainst];
        ORKTextChoice *pnta = [ORKTextChoice choiceWithText:ORKLocalizedString(@"TINNITUS_SURVEY_IPNTA", nil)
                                                 detailText:nil
                                                      value:ORKTinnitusSurveyAnswerPNTA
                                                  exclusive:YES];
        ORKAnswerFormat *answerFormat = [ORKAnswerFormat choiceAnswerFormatWithStyle:ORKChoiceAnswerStyleMultipleChoice
                                                                         textChoices:@[didNotKnow, doNotNeed, doctorAgainst, pnta]];
        
        _surveyQuestion10 = [ORKQuestionStep questionStepWithIdentifier:ORKTinnitusSurvey10StepIdentifier
                                                                 title:ORKLocalizedString(@"TINNITUS_SURVEY_TITLE", nil)
                                                              question:ORKLocalizedString(@"TINNITUS_SURVEY_QUESTION10_TEXT", nil)
                                                                answer:answerFormat];
        _surveyQuestion10.optional = NO;
    }
    return _surveyQuestion10;
}

- (ORKInstructionStep *)testingInstruction {
    if (_testingInstruction == nil) {
        _testingInstruction = [[ORKInstructionStep alloc] initWithIdentifier:ORKTinnitusTestingInstructionStepIdentifier];
        _testingInstruction.title = ORKLocalizedString(@"TINNITUS_TESTING_INTRO_TITLE", nil);
        _testingInstruction.detailText = ORKLocalizedString(@"TINNITUS_TESTING_INTRO_TEXT", nil);
        _testingInstruction.shouldTintImages = YES;
        
        UIImage *img1;
        UIImage *img2;
        UIImage *img3;
        
        if (@available(iOS 13.0, *)) {
            img1 = [UIImage systemImageNamed:@"ear"];
            img2 = [UIImage systemImageNamed:@"volume.2"];
            img3 = [UIImage systemImageNamed:@"stopwatch"];
        } else {
            // not implemeted
        }
        
        ORKBodyItem * item1 = [[ORKBodyItem alloc] initWithText:ORKLocalizedString(@"TINNITUS_TESTING_BODY_ITEM_TEXT_1", nil) detailText:nil image:img1 learnMoreItem:nil bodyItemStyle:ORKBodyItemStyleImage];
        ORKBodyItem * item2 = [[ORKBodyItem alloc] initWithHorizontalRule];
        ORKBodyItem * item3 = [[ORKBodyItem alloc] initWithText:ORKLocalizedString(@"TINNITUS_TESTING_BODY_ITEM_TEXT_2", nil) detailText:nil image:img2 learnMoreItem:nil bodyItemStyle:ORKBodyItemStyleImage];
        ORKBodyItem * item4 = [[ORKBodyItem alloc] initWithHorizontalRule];
        ORKBodyItem * item5 = [[ORKBodyItem alloc] initWithText:ORKLocalizedString(@"TINNITUS_TESTING_BODY_ITEM_TEXT_3", nil) detailText:nil image:img3 learnMoreItem:nil bodyItemStyle:ORKBodyItemStyleImage];
        
        _testingInstruction.bodyItems = @[item1,item2, item3, item4, item5];
    }
    return _testingInstruction;
}

- (ORKInstructionStep *)beforeStart {
    if (_beforeStart == nil) {
        _beforeStart = [[ORKInstructionStep alloc] initWithIdentifier:ORKTinnitusBeforeStartStepIdentifier];
        _beforeStart.title = ORKLocalizedString(@"TINNITUS_BEFORE_TITLE", nil);
        _beforeStart.detailText = ORKLocalizedString(@"TINNITUS_BEFORE_TEXT", nil);
        _beforeStart.shouldTintImages = YES;
        
        UIImage *img1;
        UIImage *img2;
        
        if (@available(iOS 13.0, *)) {
            img1 = [UIImage systemImageNamed:@"1.circle.fill"];
            img2 = [UIImage systemImageNamed:@"2.circle.fill"];
        } else {
            img1 = [[UIImage imageNamed:@"1.circle.fill" inBundle:ORKBundle() compatibleWithTraitCollection:nil] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            img2 = [[UIImage imageNamed:@"2.circle.fill" inBundle:ORKBundle() compatibleWithTraitCollection:nil] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        }
        
        ORKBodyItem * item1 = [[ORKBodyItem alloc] initWithText:ORKLocalizedString(@"TINNITUS_BEFORE_BODY_ITEM_TEXT_1", nil) detailText:nil image:img1 learnMoreItem:nil bodyItemStyle:ORKBodyItemStyleImage];
        ORKBodyItem * item2 = [[ORKBodyItem alloc] initWithHorizontalRule];
        ORKBodyItem * item3 = [[ORKBodyItem alloc] initWithText:ORKLocalizedString(@"TINNITUS_BEFORE_BODY_ITEM_TEXT_2", nil) detailText:nil image:img2 learnMoreItem:nil bodyItemStyle:ORKBodyItemStyleImage];
        _beforeStart.bodyItems = @[item1,item2, item3];
    }
    return _beforeStart;
}

- (ORKHeadphoneDetectStep *)headphone {
    if (_headphone == nil) {
        _headphone= [[ORKHeadphoneDetectStep alloc] initWithIdentifier:ORKTinnitusHeadphoneDetectStepIdentifier headphoneTypes:ORKHeadphoneTypesSupported];
        _headphone.title = ORKLocalizedString(@"HEADPHONE_DETECT_TITLE", nil);
        _headphone.detailText = ORKLocalizedString(@"HEADPHONE_DETECT_TEXT", nil);
    }
    return _headphone;
}

- (ORKEnvironmentSPLMeterStep *)splmeter {
    if (_splmeter == nil) {
        _splmeter = [[ORKEnvironmentSPLMeterStep alloc] initWithIdentifier:ORKTinnitusSPLMeterStepIdentifier];
        _splmeter.requiredContiguousSamples = 5;
        _splmeter.thresholdValue = 45;//27.9; TODO: review the value with engineers.
        _splmeter.title = ORKLocalizedString(@"ENVIRONMENTSPL_TITLE_2", nil);
        _splmeter.text = ORKLocalizedString(@"ENVIRONMENTSPL_INTRO_TEXT_2", nil);
    }
    return _splmeter;
}

- (ORKTinnitusTypeStep *)tinnitusType {
    if (_tinnitusType == nil) {
        _tinnitusType = [ORKTinnitusTypeStep stepWithIdentifier:ORKTinnitusTypeStepIdentifier
                                                          title:ORKLocalizedString(@"TINNITUS_KIND_TITLE", nil)
                                                      frequency:ORKTinnitusTypeDefaultFrequency];
        _tinnitusType.text = ORKLocalizedString(@"TINNITUS_KIND_DETAIL", nil);
        _tinnitusType.optional = NO;
    }
    return _tinnitusType;
}

- (ORKTinnitusCalibrationStep *)calibration {
    if (_calibration == nil) {
        _calibration = [[ORKTinnitusCalibrationStep alloc] initWithIdentifier:ORKTinnitusVolumeCalibrationStepIdentifier];
        _calibration.title = ORKLocalizedString(@"TINNITUS_CALIBRATION_TITLE", nil);
        _calibration.text = ORKLocalizedString(@"TINNITUS_CALIBRATION_TEXT", nil);
    }
    return _calibration;
}

- (ORKTinnitusPureToneInstructionStep *)pitchMatching {
    if (_pitchMatching == nil) {
        _pitchMatching = [[ORKTinnitusPureToneInstructionStep alloc] initWithIdentifier:ORKTinnitusPitchMatchingStepIdentifier];
        _pitchMatching.title = ORKLocalizedString(@"TINNITUS_FREQUENCY_MATCHING_TITLE", nil);
        _pitchMatching.text = ORKLocalizedString(@"TINNITUS_FREQUENCY_MATCHING_DETAIL", nil);
    }
    return _pitchMatching;
}

- (ORKTinnitusPureToneStep *)round1 {
    if (_round1 == nil) {
        _round1 = [[ORKTinnitusPureToneStep alloc] initWithIdentifier:ORKTinnitusRound1StepIdentifier];
        _round1.title = ORKLocalizedString(@"TINNITUS_PURETONE_TITLE2", nil);
        _round1.detailText = ORKLocalizedString(@"TINNITUS_PURETONE_TEXT", nil);
        _round1.roundNumber = 1;
    }
    return _round1;
}

- (ORKInstructionStep *)round1SuccessCompleted {
    if (_round1SuccessCompleted == nil) {
        _round1SuccessCompleted = [[ORKInstructionStep alloc] initWithIdentifier:ORKTinnitusRound1SuccessCompletedStepIdentifier];
        _round1SuccessCompleted.title = ORKLocalizedString(@"TINNITUS_ROUND_COMPLETE_TITLE", nil);
        _round1SuccessCompleted.text = ORKLocalizedString(@"TINNITUS_ROUND_COMPLETE_TEXT", nil);
        _round1SuccessCompleted.detailText = ORKLocalizedString(@"TINNITUS_ROUND_COMPLETE_DETAIL", nil);
        
        UIImage *iconImage;
        if (@available(iOS 13.0, *)) {
            UIImageConfiguration *configuration = [UIImageSymbolConfiguration configurationWithFont:[UIFont preferredFontForTextStyle:UIFontTextStyleBody] scale:UIImageSymbolScaleLarge];
            iconImage = [UIImage systemImageNamed:@"checkmark.circle.fill" withConfiguration:configuration];
        } else {
            iconImage = [[UIImage imageNamed:@"checkmark" inBundle:ORKBundle() compatibleWithTraitCollection:nil] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        }
        _round1SuccessCompleted.iconImage = iconImage;
        _round1SuccessCompleted.imageContentMode = UIViewContentModeTopLeft;
        _round1SuccessCompleted.shouldTintImages = YES;
    }
    return _round1SuccessCompleted;
}

- (ORKTinnitusPureToneStep *)round2 {
    if (_round2 == nil) {
        _round2 = [[ORKTinnitusPureToneStep alloc] initWithIdentifier:ORKTinnitusRound2StepIdentifier];
        _round2.title = ORKLocalizedString(@"TINNITUS_PURETONE_TITLE2", nil);
        _round2.detailText = ORKLocalizedString(@"TINNITUS_PURETONE_TEXT", nil);
        _round2.roundNumber = 2;
    }
    return _round2;
}

- (ORKInstructionStep *)round2SuccessCompleted {
    if (_round2SuccessCompleted == nil) {
        _round2SuccessCompleted = [[ORKInstructionStep alloc] initWithIdentifier:ORKTinnitusRound2SuccessCompletedStepIdentifier];
        _round2SuccessCompleted.title = ORKLocalizedString(@"TINNITUS_ROUND_COMPLETE_TITLE", nil);
        _round2SuccessCompleted.text = ORKLocalizedString(@"TINNITUS_ROUND_COMPLETE_TEXT", nil);
        _round2SuccessCompleted.detailText = ORKLocalizedString(@"TINNITUS_ROUND_COMPLETE_DETAIL", nil);
        UIImage *iconImage;
        if (@available(iOS 13.0, *)) {
            UIImageConfiguration *configuration = [UIImageSymbolConfiguration configurationWithFont:[UIFont preferredFontForTextStyle:UIFontTextStyleBody] scale:UIImageSymbolScaleLarge];
            iconImage = [UIImage systemImageNamed:@"checkmark.circle.fill" withConfiguration:configuration];
        } else {
            iconImage = [[UIImage imageNamed:@"checkmark" inBundle:ORKBundle() compatibleWithTraitCollection:nil] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        }
        _round2SuccessCompleted.iconImage = iconImage;
        _round2SuccessCompleted.imageContentMode = UIViewContentModeTopLeft;
        _round2SuccessCompleted.shouldTintImages = YES;
    }
    return _round2SuccessCompleted;
}

- (ORKTinnitusPureToneStep *)round3 {
    if (_round3 == nil) {
        _round3 = [[ORKTinnitusPureToneStep alloc] initWithIdentifier:ORKTinnitusRound3StepIdentifier];
        _round3.title = ORKLocalizedString(@"TINNITUS_PURETONE_TITLE2", nil);
        _round3.detailText = ORKLocalizedString(@"TINNITUS_PURETONE_TEXT", nil);
        _round3.roundNumber = 3;
    }
    return _round3;
}

- (ORKTinnitusLoudnessMatchingStep *)loudnessMatching {
    if (_loudnessMatching == nil) {
        _loudnessMatching = [[ORKTinnitusLoudnessMatchingStep alloc] initWithIdentifier:ORKTinnitusLoudnessMatchingStepIdentifier frequency:_predominantFrequency];
        _loudnessMatching.title = ORKLocalizedString(@"TINNITUS_FINAL_CALIBRATION_TITLE", nil);
        _loudnessMatching.text = ORKLocalizedString(@"TINNITUS_FINAL_CALIBRATION_TEXT", nil);
    }
    return _loudnessMatching;
}

- (ORKTinnitusLoudnessMatchingStep *)soundLoudnessMatching {
    if (_soundLoudnessMatching == nil) {
        _soundLoudnessMatching = [[ORKTinnitusLoudnessMatchingStep alloc] initWithIdentifier:ORKTinnitusSoundLoudnessMatchingStepIdentifier noiseType:_noiseType];
        _soundLoudnessMatching.title = ORKLocalizedString(@"TINNITUS_FINAL_CALIBRATION_TITLE", nil);
        _soundLoudnessMatching.text = ORKLocalizedString(@"TINNITUS_FINAL_CALIBRATION_TEXT", nil);
    }
    return _soundLoudnessMatching;
}

- (ORKCompletionStep *)completionSuccess {
    if (_completionSuccess == nil) {
        _completionSuccess = [[ORKCompletionStep alloc] initWithIdentifier:ORKTinnitusPuretoneSuccessStepIdentifier];
        NSString *title = ORKLocalizedString(@"TINNITUS_WHITENOISE_SUCCESS_TITLE", nil);
        NSString *text = ORKLocalizedString(@"TINNITUS_WHITENOISE_SUCCESS_TEXT", nil);
        if ([_type isEqualToString:ORKTinnitusTypePureTone]) {
            title = ORKLocalizedString(@"TINNITUS_PURETONE_SUCCESS_TITLE", nil);
            text = ORKLocalizedString(@"TINNITUS_PURETONE_SUCCESS_TEXT", nil);
        }
        _completionSuccess.title = title;
        _completionSuccess.text = text;
        _completionSuccess.shouldTintImages = YES;
    }
    return _completionSuccess;
}

- (ORKTinnitusMaskingSoundStep *)fireMasking {
    if (_fireMasking == nil) {
        _fireMasking = [[ORKTinnitusMaskingSoundStep alloc]
                        initWithIdentifier:ORKTinnitusMaskingCampfireIdentifier
                        maskingSoundType:ORKTinnitusMaskingSoundTypeCampfire];
        _fireMasking.title = ORKLocalizedString(@"TINNITUS_MASKING_TITLE", nil);
        _fireMasking.text = ORKLocalizedString(@"TINNITUS_MASKING_TEXT", nil);
        _fireMasking.shouldTintImages = YES;
    }
    return _fireMasking;
}

- (ORKTinnitusMaskingSoundStep *)fireMaskingNotch {
    if (_fireMaskingNotch == nil) {
        _fireMaskingNotch = [[ORKTinnitusMaskingSoundStep alloc]
                             initWithIdentifier:ORKTinnitusMaskingCampfireNotchIdentifier
                             maskingSoundType:ORKTinnitusMaskingSoundTypeCampfire
                             notchFrequency:_predominantFrequency];
        _fireMaskingNotch.title = ORKLocalizedString(@"TINNITUS_MASKING_TITLE", nil);
        _fireMaskingNotch.text = ORKLocalizedString(@"TINNITUS_MASKING_TEXT", nil);
        _fireMaskingNotch.shouldTintImages = YES;
    }
    return _fireMaskingNotch;
}

- (ORKTinnitusMaskingSoundStep *)whitenoiseMasking {
    if (_whitenoiseMasking == nil) {
        _whitenoiseMasking = [[ORKTinnitusMaskingSoundStep alloc]
                              initWithIdentifier:ORKTinnitusMaskingWhitenoiseIdentifier
                              maskingSoundType:ORKTinnitusMaskingSoundTypeWhitenoise];
        _whitenoiseMasking.title = ORKLocalizedString(@"TINNITUS_MASKING_TITLE", nil);
        _whitenoiseMasking.text = ORKLocalizedString(@"TINNITUS_MASKING_TEXT", nil);
        _whitenoiseMasking.shouldTintImages = YES;
    }
    return _whitenoiseMasking;
}

- (ORKTinnitusMaskingSoundStep *)whitenoiseMaskingNotch {
    if (_whitenoiseMaskingNotch == nil) {
        _whitenoiseMaskingNotch = [[ORKTinnitusMaskingSoundStep alloc]
                                   initWithIdentifier:ORKTinnitusMaskingWhitenoiseNotchIdentifier
                                   maskingSoundType:ORKTinnitusMaskingSoundTypeWhitenoise
                                   notchFrequency:_predominantFrequency];
        _whitenoiseMaskingNotch.title = ORKLocalizedString(@"TINNITUS_MASKING_TITLE", nil);
        _whitenoiseMaskingNotch.text = ORKLocalizedString(@"TINNITUS_MASKING_TEXT", nil);
        _whitenoiseMaskingNotch.shouldTintImages = YES;
    }
    return _whitenoiseMaskingNotch;
}

- (ORKTinnitusMaskingSoundStep *)rainMasking {
    if (_rainMasking == nil) {
        _rainMasking = [[ORKTinnitusMaskingSoundStep alloc]
                        initWithIdentifier:ORKTinnitusMaskingRainIdentifier
                        maskingSoundType:ORKTinnitusMaskingSoundTypeRain];
        _rainMasking.title = ORKLocalizedString(@"TINNITUS_MASKING_TITLE", nil);
        _rainMasking.text = ORKLocalizedString(@"TINNITUS_MASKING_TEXT", nil);
        _rainMasking.shouldTintImages = YES;
    }
    return _rainMasking;
}

- (ORKTinnitusMaskingSoundStep *)rainMaskingNotch {
    if (_rainMaskingNotch == nil) {
        _rainMaskingNotch = [[ORKTinnitusMaskingSoundStep alloc]
                             initWithIdentifier:ORKTinnitusMaskingRainNotchIdentifier
                             maskingSoundType:ORKTinnitusMaskingSoundTypeRain
                             notchFrequency:_predominantFrequency];
        _rainMaskingNotch.title = ORKLocalizedString(@"TINNITUS_MASKING_TITLE", nil);
        _rainMaskingNotch.text = ORKLocalizedString(@"TINNITUS_MASKING_TEXT", nil);
        _rainMaskingNotch.shouldTintImages = YES;
    }
    return _rainMaskingNotch;
}

- (ORKTinnitusMaskingSoundStep *)forestMasking {
    if (_forestMasking == nil) {
        _forestMasking = [[ORKTinnitusMaskingSoundStep alloc]
                          initWithIdentifier:ORKTinnitusMaskingForestIdentifier
                          maskingSoundType:ORKTinnitusMaskingSoundTypeForest];
        _forestMasking.title = ORKLocalizedString(@"TINNITUS_MASKING_TITLE", nil);
        _forestMasking.text = ORKLocalizedString(@"TINNITUS_MASKING_TEXT", nil);
        _forestMasking.shouldTintImages = YES;
    }
    return _forestMasking;
}

- (ORKTinnitusMaskingSoundStep *)forestMaskingNotch {
    if (_forestMaskingNotch == nil) {
        _forestMaskingNotch = [[ORKTinnitusMaskingSoundStep alloc]
                               initWithIdentifier:ORKTinnitusMaskingForestNotchIdentifier
                               maskingSoundType:ORKTinnitusMaskingSoundTypeForest
                               notchFrequency:_predominantFrequency];
        _forestMaskingNotch.title = ORKLocalizedString(@"TINNITUS_MASKING_TITLE", nil);
        _forestMaskingNotch.text = ORKLocalizedString(@"TINNITUS_MASKING_TEXT", nil);
        _forestMaskingNotch.shouldTintImages = YES;
    }
    return _forestMaskingNotch;
}

- (ORKTinnitusMaskingSoundStep *)oceanMasking {
    if (_oceanMasking == nil) {
        _oceanMasking = [[ORKTinnitusMaskingSoundStep alloc]
                         initWithIdentifier:ORKTinnitusMaskingOceanIdentifier
                         maskingSoundType:ORKTinnitusMaskingSoundTypeOcean];
        _oceanMasking.title = ORKLocalizedString(@"TINNITUS_MASKING_TITLE", nil);
        _oceanMasking.text = ORKLocalizedString(@"TINNITUS_MASKING_TEXT", nil);
        _oceanMasking.shouldTintImages = YES;
    }
    return _oceanMasking;
}

- (ORKTinnitusMaskingSoundStep *)oceanMaskingNotch {
    if (_oceanMaskingNotch == nil) {
        _oceanMaskingNotch = [[ORKTinnitusMaskingSoundStep alloc]
                              initWithIdentifier:ORKTinnitusMaskingOceanNotchIdentifier
                              maskingSoundType:ORKTinnitusMaskingSoundTypeOcean
                              notchFrequency:_predominantFrequency];
        _oceanMaskingNotch.title = ORKLocalizedString(@"TINNITUS_MASKING_TITLE", nil);
        _oceanMaskingNotch.text = ORKLocalizedString(@"TINNITUS_MASKING_TEXT", nil);
        _oceanMaskingNotch.shouldTintImages = YES;
    }
    return _oceanMaskingNotch;
}

- (ORKTinnitusMaskingSoundStep *)crowdMasking {
    if (_crowdMasking == nil) {
        _crowdMasking = [[ORKTinnitusMaskingSoundStep alloc]
                         initWithIdentifier:ORKTinnitusMaskingCrowdIdentifier
                         maskingSoundType:ORKTinnitusMaskingSoundTypeCrowd];
        _crowdMasking.title = ORKLocalizedString(@"TINNITUS_MASKING_TITLE", nil);
        _crowdMasking.text = ORKLocalizedString(@"TINNITUS_MASKING_TEXT", nil);
        _crowdMasking.shouldTintImages = YES;
    }
    return _crowdMasking;
}

- (ORKTinnitusMaskingSoundStep *)crowdMaskingNotch {
    if (_crowdMaskingNotch == nil) {
        _crowdMaskingNotch = [[ORKTinnitusMaskingSoundStep alloc]
                              initWithIdentifier:ORKTinnitusMaskingCrowdNotchIdentifier
                              maskingSoundType:ORKTinnitusMaskingSoundTypeCrowd
                              notchFrequency:_predominantFrequency];
        _crowdMaskingNotch.title = ORKLocalizedString(@"TINNITUS_MASKING_TITLE", nil);
        _crowdMaskingNotch.text = ORKLocalizedString(@"TINNITUS_MASKING_TEXT", nil);
        _crowdMaskingNotch.shouldTintImages = YES;
    }
    return _crowdMaskingNotch;
}

- (ORKTinnitusMaskingSoundStep *)audiobookMasking {
    if (_audiobookMasking == nil) {
        _audiobookMasking = [[ORKTinnitusMaskingSoundStep alloc]
                             initWithIdentifier:ORKTinnitusMaskingAudiobookIdentifier
                             maskingSoundType:ORKTinnitusMaskingSoundTypeAudiobook];
        _audiobookMasking.title = ORKLocalizedString(@"TINNITUS_MASKING_TITLE", nil);
        _audiobookMasking.text = ORKLocalizedString(@"TINNITUS_MASKING_TEXT", nil);
        _audiobookMasking.shouldTintImages = YES;
    }
    return _audiobookMasking;
}

- (ORKTinnitusMaskingSoundStep *)audiobookMaskingNotch {
    if (_audiobookMaskingNotch == nil) {
        _audiobookMaskingNotch = [[ORKTinnitusMaskingSoundStep alloc]
                                  initWithIdentifier:ORKTinnitusMaskingAudiobookNotchIdentifier
                                  maskingSoundType:ORKTinnitusMaskingSoundTypeAudiobook
                                  notchFrequency:_predominantFrequency];
        _audiobookMaskingNotch.title = ORKLocalizedString(@"TINNITUS_MASKING_TITLE", nil);
        _audiobookMaskingNotch.text = ORKLocalizedString(@"TINNITUS_MASKING_TEXT", nil);
        _audiobookMaskingNotch.shouldTintImages = YES;
    }
    return _audiobookMaskingNotch;
}

- (ORKTinnitusWhitenoiseMatchingSoundStep *)whitenoiseMatching {
    if (_whitenoiseMatching == nil) {
        _whitenoiseMatching = [[ORKTinnitusWhitenoiseMatchingSoundStep alloc]
                               initWithIdentifier:ORKTinnitusWhitenoiseMatchingIdentifier];
        _whitenoiseMatching.title = ORKLocalizedString(@"TINNITUS_WHITENOISE_MATCHINGSOUND_TITLE", nil);
        _whitenoiseMatching.text = ORKLocalizedString(@"TINNITUS_WHITENOISE_MATCHINGSOUND_TEXT", nil);
        _whitenoiseMatching.shouldTintImages = YES;
    }
    return _whitenoiseMatching;
}

@end
