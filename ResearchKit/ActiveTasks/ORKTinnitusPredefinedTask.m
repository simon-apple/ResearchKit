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

#import "ORKCompletionStep.h"
#import "ORKQuestionStep.h"

#import <ResearchKit/ResearchKit_Private.h>

@interface ORKTinnitusPredefinedTask ()

@property (nonatomic, strong) UIColor *cachedBGColor;
@property (nonatomic, copy) NSDictionary *stepAfterStepDict;
@property (nonatomic, copy) NSDictionary *stepBeforeStepDict;

@property (nonatomic, strong) ORKInstructionStep *instruction1;
@property (nonatomic, strong) ORKQuestionStep *surveyQuestion1;
@property (nonatomic, strong) ORKQuestionStep *surveyQuestion2;
@property (nonatomic, strong) ORKQuestionStep *surveyQuestion3;
@property (nonatomic, strong) ORKQuestionStep *surveyQuestion4;
@property (nonatomic, strong) ORKQuestionStep *surveyQuestion5;
@property (nonatomic, strong) ORKQuestionStep *surveyQuestion6;
@property (nonatomic, strong) ORKQuestionStep *surveyQuestion7;
@property (nonatomic, strong) ORKQuestionStep *surveyQuestion8;
@property (nonatomic, strong) ORKQuestionStep *surveyQuestion9;
@property (nonatomic, strong) ORKQuestionStep *surveyQuestion10;
@property (nonatomic, strong) ORKCompletionStep *surveyCompletion;

@property (nonatomic, strong) ORKInstructionStep *testingInstruction;

@end

@implementation ORKTinnitusPredefinedTask

- (instancetype)initWithIdentifier:(NSString *)identifier {
    ORKTinnitusPredefinedTask *task = [[ORKTinnitusPredefinedTask alloc] initWithIdentifier:identifier steps:nil];
    return task;
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

- (void)setupBGColor {
    if (self.cachedBGColor == nil) {
        self.cachedBGColor = ORKColor(ORKBackgroundColorKey);
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
            img1 = [[UIImage imageNamed:@"1.circle.fill" inBundle:ORKBundle() compatibleWithTraitCollection:nil] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            img2 = [[UIImage imageNamed:@"2.circle.fill" inBundle:ORKBundle() compatibleWithTraitCollection:nil] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            img3 = [[UIImage imageNamed:@"3.circle.fill" inBundle:ORKBundle() compatibleWithTraitCollection:nil] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
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
            img1 = [[UIImage imageNamed:@"ear" inBundle:ORKBundle() compatibleWithTraitCollection:nil] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            img2 = [[UIImage imageNamed:@"speaker.2" inBundle:ORKBundle() compatibleWithTraitCollection:nil] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            img3 = [[UIImage imageNamed:@"stopwatch" inBundle:ORKBundle() compatibleWithTraitCollection:nil] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
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

@end
