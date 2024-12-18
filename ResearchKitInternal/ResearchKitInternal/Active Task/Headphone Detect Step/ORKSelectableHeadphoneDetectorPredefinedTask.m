/*
 Copyright (c) 2024, Apple Inc. All rights reserved.
 
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

@import ResearchKit_Private;

#import "ORKSelectableHeadphoneDetectorPredefinedTask.h"
#import "ORKIUtils.h"
#import "ResearchKitInternal_Private.h"

NSString *const ORKSelectableFormStepIdentifier = @"FormStep";
NSString *const ORKSelectableFormItemIdentifier = @"FormItem";
NSString *const ORKSelectableHeadphoneDetectStepIdentifier = @"HeadphoneDetectStep";

static NSString *const kAirPodsGen1 = @"AirPods Gen 1";
static NSString *const kAirPodsGen2 = @"AirPods Gen 2";
static NSString *const kAirPodsGen3 = @"AirPods Gen 3";
static NSString *const kAirPodsGen4E = @"AirPods Gen 4 Economic";
static NSString *const kAirPodsGen4CHE = @"AirPods Gen 4 Economic (CH)";
static NSString *const kAirPodsGen4M = @"AirPods Gen 4 withANC";
static NSString *const kAirPodsGen4CHM = @"AirPods Gen 4 withANC (CH)";
static NSString *const kAirPodsProGen1 = @"AirPods Pro Gen 1";
static NSString *const kAirPodsProGen2 = @"AirPods Pro Gen 2";
static NSString *const kAirPodsMax = @"AirPods Max";
static NSString *const kAirPodsMaxUSBC = @"AirPods Max USBC";
static NSString *const kEarPods = @"EarPods";

@implementation ORKSelectableHeadphoneDetectorPredefinedTask

- (instancetype)initWithIdentifier:(NSString *)identifier steps:(nullable NSArray<ORKStep *> *)steps {
    NSArray<ORKStep *> *overriddenSteps = [ORKSelectableHeadphoneDetectorPredefinedTask selectableHeaphoneSteps];
    
    self = [super initWithIdentifier:identifier steps:overriddenSteps];
    
    return self;
}

+ (NSArray<ORKStep *> *)selectableHeaphoneSteps {
    NSMutableArray<ORKStep *> *steps = [[NSMutableArray alloc] init];
    
    ORKFormStep *formStep = [[ORKFormStep alloc] initWithIdentifier:ORKSelectableFormStepIdentifier];
    formStep.title = ORKILocalizedString(@"HEADPHONE_DETECT_FORM_TITLE", nil);
    
    NSArray *textChoices = @[ [ORKTextChoice choiceWithText:kAirPodsGen1        value:ORKHeadphoneTypeIdentifierAirPodsGen1],
                              [ORKTextChoice choiceWithText:kAirPodsGen2        value:ORKHeadphoneTypeIdentifierAirPodsGen2],
                              [ORKTextChoice choiceWithText:kAirPodsGen3        value:ORKHeadphoneTypeIdentifierAirPodsGen3],
                              [ORKTextChoice choiceWithText:kAirPodsGen4E        value:ORKHeadphoneTypeIdentifierAirPodsGen4E],
                              [ORKTextChoice choiceWithText:kAirPodsGen4CHE        value:ORKHeadphoneTypeIdentifierAirPodsGen4CHE],
                              [ORKTextChoice choiceWithText:kAirPodsGen4M        value:ORKHeadphoneTypeIdentifierAirPodsGen4M],
                              [ORKTextChoice choiceWithText:kAirPodsGen4CHM        value:ORKHeadphoneTypeIdentifierAirPodsGen4CHM],
                              [ORKTextChoice choiceWithText:kAirPodsProGen1     value:ORKHeadphoneTypeIdentifierAirPodsPro],
                              [ORKTextChoice choiceWithText:kAirPodsProGen2     value:ORKHeadphoneTypeIdentifierAirPodsProGen2],
                              [ORKTextChoice choiceWithText:kAirPodsMax         value:ORKHeadphoneTypeIdentifierAirPodsMax],
                              [ORKTextChoice choiceWithText:kAirPodsMaxUSBC     value:ORKHeadphoneTypeIdentifierAirPodsMaxUSBC],
                              [ORKTextChoice choiceWithText:kEarPods            value:ORKHeadphoneTypeIdentifierEarPods]];
    
    ORKAnswerFormat *answerFormat = [ORKAnswerFormat choiceAnswerFormatWithStyle:ORKChoiceAnswerStyleSingleChoice textChoices:textChoices];

    formStep.showsProgress = NO;
    formStep.optional = NO;

    formStep.formItems = @[
        [[ORKFormItem alloc] initWithIdentifier:ORKSelectableFormItemIdentifier
                                           text:ORKILocalizedString(@"HEADPHONE_DETECT_FORM_ITEM_TEXT", nil)
                                     detailText:nil
                                  learnMoreItem:nil
                                  showsProgress:NO
                                   answerFormat:answerFormat
                                        tagText:nil
                                       optional:NO]
    ];
    
    [steps addObject:formStep];
    
    ORKHeadphoneDetectStep *step = [[ORKHeadphoneDetectStep alloc] initWithIdentifier:ORKSelectableHeadphoneDetectStepIdentifier headphoneTypes:ORKHeadphoneTypesSupported];
    step.title = ORKILocalizedString(@"HEADPHONE_DETECT_TITLE", nil);
    [steps addObject:step];
    
    return steps;
}

- (BOOL)stepIsHeadphoneDetectStep:(ORKStep *)step {
    if ([[step identifier] isEqualToString:ORKSelectableHeadphoneDetectStepIdentifier]) {
        return YES;
    }
    return NO;
}

- (ORKHeadphoneTypeIdentifier)getHeadphoneTypeSelectedFromResult:(ORKTaskResult *)result {
    ORKHeadphoneTypeIdentifier headphoneTypeSelected = ORKHeadphoneTypeIdentifierUnknown;
    for (ORKStepResult *stepResult in result.results) {
        if ([stepResult.identifier isEqualToString:ORKSelectableFormStepIdentifier]) {
            ORKChoiceQuestionResult *questionResult = (ORKChoiceQuestionResult *)stepResult.results[0];
            if (questionResult.answer != nil) {
                NSArray *answers = (NSArray *)questionResult.answer;
                if (answers.count > 0) {
                    headphoneTypeSelected = (ORKHeadphoneTypeIdentifier)answers.lastObject;
                    break;
                }
            }
        }
    }
    return headphoneTypeSelected;
}

- (void)configureHeadphoneDetectStep:(ORKHeadphoneDetectStep *)step withHeadphoneType:(ORKHeadphoneTypeIdentifier)type {
    step.lockedToAppleHeadphoneType = type;
    NSDictionary *headphoneStepDetailText = @{
        ORKHeadphoneTypeIdentifierAirPodsGen1:      ORKILocalizedString(@"HEADPHONE_DETECT_TEXT_AIRPODSGEN1", nil),
        ORKHeadphoneTypeIdentifierAirPodsGen2:      ORKILocalizedString(@"HEADPHONE_DETECT_TEXT_AIRPODSGEN2", nil),
        ORKHeadphoneTypeIdentifierAirPodsGen3:      ORKILocalizedString(@"HEADPHONE_DETECT_TEXT_AIRPODSGEN3", nil),
        ORKHeadphoneTypeIdentifierAirPodsGen4E:     ORKILocalizedString(@"HEADPHONE_DETECT_TEXT_AIRPODSGEN4E", nil),
        ORKHeadphoneTypeIdentifierAirPodsGen4CHE:   ORKILocalizedString(@"HEADPHONE_DETECT_TEXT_AIRPODSGEN4CHE", nil),
        ORKHeadphoneTypeIdentifierAirPodsGen4M:     ORKILocalizedString(@"HEADPHONE_DETECT_TEXT_AIRPODSGEN4M", nil),
        ORKHeadphoneTypeIdentifierAirPodsGen4CHM:   ORKILocalizedString(@"HEADPHONE_DETECT_TEXT_AIRPODSGEN4CHM", nil),
        ORKHeadphoneTypeIdentifierAirPodsPro:       ORKILocalizedString(@"HEADPHONE_DETECT_TEXT_AIRPODSPRO1", nil),
        ORKHeadphoneTypeIdentifierAirPodsProGen2:   ORKILocalizedString(@"HEADPHONE_DETECT_TEXT_AIRPODSPRO2", nil),
        ORKHeadphoneTypeIdentifierAirPodsMax:       ORKILocalizedString(@"HEADPHONE_DETECT_TEXT_AIRPODSMAX", nil),
        ORKHeadphoneTypeIdentifierAirPodsMaxUSBC:   ORKILocalizedString(@"HEADPHONE_DETECT_TEXT_AIRPODSMAX", nil),
        ORKHeadphoneTypeIdentifierEarPods:          ORKILocalizedString(@"HEADPHONE_DETECT_TEXT_EARPODS", nil)
    };
    step.detailText = headphoneStepDetailText[type];
}

- (ORKStep *)stepAfterStep:(ORKStep *)step withResult:(ORKTaskResult *)result {
    if (step == nil) {
        return self.steps[0];
    }
    
    ORKStep *nextStep = nil;
    NSUInteger index = [self indexOfStep:step];
    
    if (NSNotFound != index && index != (self.steps.count - 1)) {
        nextStep = self.steps[index + 1];
    }
    
    if ([self stepIsHeadphoneDetectStep:nextStep]) {
        ORKHeadphoneDetectStep *headphoneDetectStep = (ORKHeadphoneDetectStep *)nextStep;
        ORKHeadphoneTypeIdentifier headphoneTypeSelected = [self getHeadphoneTypeSelectedFromResult:result];
        [self configureHeadphoneDetectStep:headphoneDetectStep withHeadphoneType:headphoneTypeSelected];
    }
    
    return nextStep;
}

@end
