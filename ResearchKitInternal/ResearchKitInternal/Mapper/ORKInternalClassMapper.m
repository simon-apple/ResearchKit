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

#import "ORKInternalClassMapper.h"

#import "ORKIdBHLToneAudiometryResult.h"
#import "ORKIdBHLToneAudiometryStep.h"

@import ResearchKit_Private;
#import <ResearchKit/ORKCompletionStep.h>
#import <ResearchKit/ORKInstructionStep.h>
#import <ResearchKit/ORKQuestionStep.h>

#import <ResearchKitActiveTask/ORKdBHLToneAudiometryStep.h>
#import <ResearchKitActiveTask/ORKdBHLToneAudiometryResult.h>
#import <ResearchKitActiveTask/ORKEnvironmentSPLMeterStep.h>
#import <ResearchKitActiveTask/ORKSpeechInNoiseStep.h>
#import <ResearchKitActiveTask/ORKSpeechRecognitionStep.h>

#import "ORKIQuestionStepViewController.h"
#import "ORKICompletionStepViewController.h"
#import "ORKIInstructionStepViewController.h"
#import "ORKISpeechRecognitionStepViewController.h"
#import "ORKISpeechInNoiseStepViewController.h"
#import "ORKIEnvironmentSPLMeterStepViewController.h"

NSString * const ORKUseInternalClassMapperKey = @"ORKUseInternalClassMapperKey";

@implementation ORKInternalClassMapper

+ (void)setUseInternalMapperUserDefaultsValue:(BOOL)value {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:value forKey:ORKUseInternalClassMapperKey];
}

+ (BOOL)getUseInternalMapperUserDefaultsValue {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults boolForKey:ORKUseInternalClassMapperKey];
}

+ (void)removeUseInternalMapperUserDefaultsValues {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults removeObjectForKey:ORKUseInternalClassMapperKey];
}

+ (nullable Class)getInternalClassForPublicClass:(Class)class {
    NSDictionary<NSString *, Class> *mappedClassesWithInternalVersions = [ORKInternalClassMapper _getMappedClassesWithInternalVersions];
    return [mappedClassesWithInternalVersions valueForKey:NSStringFromClass(class)];
}

+ (nullable NSString *)getInternalClassStringForPublicClass:(NSString *)class {
    NSDictionary<NSString *, NSString *> *dict = @{
        NSStringFromClass([ORKdBHLToneAudiometryStep class]) : NSStringFromClass([ORKIdBHLToneAudiometryStep class]),
        NSStringFromClass([ORKdBHLToneAudiometryResult class]) : NSStringFromClass([ORKIdBHLToneAudiometryResult class]),
    };
    
    return [dict valueForKey:class];
}

+ (nullable id)getInternalInstanceForPublicInstance:(id)class {
    // attempt dBHL step mapping
    ORKIdBHLToneAudiometryStep *internaldBHLStep = [ORKInternalClassMapper _mapPublicdBHLToneAudiometryStep:class];
    if (internaldBHLStep != nil) {
        return internaldBHLStep;
    }
        
    return nil;
}

+ (NSArray *)sanitizeOrderedTaskSteps:(NSArray *)steps {
    NSMutableArray<ORKStep *> *sanitizedArray = [NSMutableArray new];
    
    for (ORKStep *step in steps) {
        [sanitizedArray addObject:[ORKInternalClassMapper getInternalInstanceForPublicInstance:step] ?: [step copy]];
    }
    
    return sanitizedArray;
}

#pragma mark - Private Methods

+ (nullable id)_mapPublicdBHLToneAudiometryStep:(id)class {
    ORKdBHLToneAudiometryStep *dBHLStep = (ORKdBHLToneAudiometryStep *)class;
    
    if ([NSStringFromClass([dBHLStep class]) isEqualToString:NSStringFromClass([ORKdBHLToneAudiometryStep class])]) {
        ORKIdBHLToneAudiometryStep *internaldBHLStep = [[ORKIdBHLToneAudiometryStep alloc] initWithIdentifier:[dBHLStep.identifier copy]];
        
        // ORKdBHLStep properties
        internaldBHLStep.toneDuration = dBHLStep.toneDuration;
        internaldBHLStep.maxRandomPreStimulusDelay = dBHLStep.maxRandomPreStimulusDelay;
        internaldBHLStep.postStimulusDelay = dBHLStep.postStimulusDelay;
        internaldBHLStep.maxNumberOfTransitionsPerFrequency = dBHLStep.maxNumberOfTransitionsPerFrequency;
        internaldBHLStep.initialdBHLValue = dBHLStep.initialdBHLValue;
        internaldBHLStep.dBHLStepUpSize = dBHLStep.dBHLStepUpSize;
        internaldBHLStep.dBHLStepUpSizeFirstMiss = dBHLStep.dBHLStepUpSizeFirstMiss;
        internaldBHLStep.dBHLStepUpSizeSecondMiss = dBHLStep.dBHLStepUpSizeSecondMiss;
        internaldBHLStep.dBHLStepUpSizeThirdMiss = dBHLStep.dBHLStepUpSizeThirdMiss;
        internaldBHLStep.dBHLStepDownSize = dBHLStep.dBHLStepDownSize;
        internaldBHLStep.dBHLMinimumThreshold = dBHLStep.dBHLMinimumThreshold;
        internaldBHLStep.headphoneType = dBHLStep.headphoneType;
        internaldBHLStep.earPreference = dBHLStep.earPreference;
        internaldBHLStep.frequencyList = [dBHLStep.frequencyList copy];
        
        // ORKStep properties
        internaldBHLStep.optional = dBHLStep.optional;
        internaldBHLStep.title = [dBHLStep.title copy];
        internaldBHLStep.text = [dBHLStep.text copy];
        internaldBHLStep.detailText = [dBHLStep.detailText copy];
        internaldBHLStep.headerTextAlignment = dBHLStep.headerTextAlignment;
        internaldBHLStep.footnote = [dBHLStep.footnote copy];
        internaldBHLStep.iconImage = [dBHLStep.iconImage copy];
        internaldBHLStep.shouldAutomaticallyAdjustImageTintColor = dBHLStep.shouldAutomaticallyAdjustImageTintColor;
        internaldBHLStep.showsProgress = dBHLStep.showsProgress;
        internaldBHLStep.useExtendedPadding = dBHLStep.useExtendedPadding;
        internaldBHLStep.earlyTerminationConfiguration = [dBHLStep.earlyTerminationConfiguration copy];
        internaldBHLStep.task = dBHLStep.task;
        
        return internaldBHLStep;
    }
    
    return nil;
}

+ (NSDictionary<NSString *, Class> *)_getMappedClassesWithInternalVersions {
    NSDictionary<NSString *, Class> *dict = @{
        NSStringFromClass([ORKdBHLToneAudiometryStep class]) : [ORKIdBHLToneAudiometryStep class],
        NSStringFromClass([ORKdBHLToneAudiometryResult class]) : [ORKIdBHLToneAudiometryResult class]
    };
    
    return [dict copy];
}

+ (nullable ORKStepViewController *)mappedStepViewControllerForStep:(ORKStep *)step fromTaskViewController:(ORKTaskViewController *)taskViewController {
    ORKResult *result = [taskViewController getCurrentStepResult:step];

    if ([step class] == [ORKQuestionStep class]) {
        ORK_Log_Debug("mapping ORKIQuestionStepViewController");
        return [[ORKIQuestionStepViewController alloc] initWithStep:step result:result];
    } else if ([step class] == [ORKCompletionStep class]) {
        ORK_Log_Debug("mapping ORKICompletionStepViewController");
        return [[ORKICompletionStepViewController alloc] initWithStep:step result:result];
    } else if ([step class] == [ORKInstructionStep class]) {
        ORK_Log_Debug("mapping ORKIInstructionStepViewController");
        return [[ORKIInstructionStepViewController alloc] initWithStep:step result:result];
    } else if ([step class] == [ORKSpeechRecognitionStep class]) {
        ORK_Log_Debug("mapping ORKISpeechRecognitionStepViewController");
        return [[ORKISpeechRecognitionStepViewController alloc] initWithStep:step result:result];
    } else if ([step class] == [ORKSpeechInNoiseStep class]) {
        ORK_Log_Debug("mapping ORKISpeechInNoiseStepViewController");
        return [[ORKISpeechInNoiseStepViewController alloc] initWithStep:step result:result];
    } else if ([step class] == [ORKEnvironmentSPLMeterStep class]) {
        ORK_Log_Debug("mapping ORKIEnvironmentSPLMeterStepViewController");
        return [[ORKIEnvironmentSPLMeterStepViewController alloc] initWithStep:step result:result];
    } 
    ORK_Log_Debug("no class found for %@ - %@", step.class, step.superclass);
    return nil;
}

@end
