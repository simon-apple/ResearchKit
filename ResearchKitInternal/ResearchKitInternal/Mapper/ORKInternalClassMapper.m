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

#import "ORKICompletionStep.h"
#import "ORKIdBHLToneAudiometryResult.h"
#import "ORKIdBHLToneAudiometryStep.h"
#import "ORKIEnvironmentSPLMeterStep.h"
#import "ORKIInstructionStep.h"
#import "ORKIQuestionStep.h"
#import "ORKISpeechInNoiseStep.h"
#import "ORKISpeechRecognitionStep.h"

#import <ResearchKit/ORKCompletionStep.h>
#import <ResearchKit/ORKInstructionStep.h>
#import <ResearchKit/ORKQuestionStep.h>
@import ResearchKit_Private;

#import <ResearchKitActiveTask/ORKdBHLToneAudiometryStep.h>
#import <ResearchKitActiveTask/ORKdBHLToneAudiometryResult.h>
#import <ResearchKitActiveTask/ORKEnvironmentSPLMeterStep.h>
#import <ResearchKitActiveTask/ORKSpeechInNoiseStep.h>
#import <ResearchKitActiveTask/ORKSpeechRecognitionStep.h>


@implementation ORKInternalClassMapper

+ (nullable Class)getInternalClassForPublicClass:(Class)class {
    NSDictionary<NSString *, Class> *dict = @{
        NSStringFromClass([ORKInstructionStep class]) : [ORKIInstructionStep class],
        NSStringFromClass([ORKQuestionStep class]) : [ORKIQuestionStep class],
        NSStringFromClass([ORKdBHLToneAudiometryStep class]) : [ORKIdBHLToneAudiometryStep class],
        NSStringFromClass([ORKdBHLToneAudiometryResult class]) : [ORKIdBHLToneAudiometryResult class],
        NSStringFromClass([ORKSpeechInNoiseStep class]) : [ORKISpeechInNoiseStep class],
        NSStringFromClass([ORKEnvironmentSPLMeterStep class]) : [ORKIEnvironmentSPLMeterStep class],
        NSStringFromClass([ORKSpeechRecognitionStep class]) : [ORKISpeechRecognitionStep class],
        NSStringFromClass([ORKCompletionStep class]) : [ORKICompletionStep class]
    };
    
    return [dict valueForKey:NSStringFromClass(class)];
}

+ (nullable NSString *)getInternalClassStringForPublicClass:(NSString *)class {
    NSDictionary<NSString *, NSString *> *dict = @{
        NSStringFromClass([ORKInstructionStep class]) : NSStringFromClass([ORKIInstructionStep class]),
        NSStringFromClass([ORKQuestionStep class]) : NSStringFromClass([ORKIQuestionStep class]),
        NSStringFromClass([ORKdBHLToneAudiometryStep class]) : NSStringFromClass([ORKIdBHLToneAudiometryStep class]),
        NSStringFromClass([ORKdBHLToneAudiometryResult class]) : NSStringFromClass([ORKIdBHLToneAudiometryResult class]),
        NSStringFromClass([ORKSpeechInNoiseStep class]) : NSStringFromClass([ORKISpeechInNoiseStep class]),
        NSStringFromClass([ORKEnvironmentSPLMeterStep class]) : NSStringFromClass([ORKIEnvironmentSPLMeterStep class]),
        NSStringFromClass([ORKSpeechRecognitionStep class]) : NSStringFromClass([ORKISpeechRecognitionStep class]),
        NSStringFromClass([ORKCompletionStep class]) : NSStringFromClass([ORKICompletionStep class])
    };
    
    return [dict valueForKey:class];
}

+ (nullable id)getInternalInstanceForPublicClass:(id)class {
    // attempt instruction step mapping
    ORKIInstructionStep *internalInstructionStep = [ORKInternalClassMapper _mapPublicInstructionStep:class];
    if (internalInstructionStep != nil) {
        return internalInstructionStep;
    }
    
    // attempt question step mapping
    ORKIQuestionStep *internalQuestionStep = [ORKInternalClassMapper _mapPublicQuestionStep:class];
    if (internalQuestionStep != nil) {
        return internalQuestionStep;
    }
    
    // attempt dBHL step mapping
    ORKIdBHLToneAudiometryStep *internaldBHLStep = [ORKInternalClassMapper _mapPublicdBHLToneAudiometryStep:class];
    if (internaldBHLStep != nil) {
        return internaldBHLStep;
    }
    
    // attempt speech in noise step mapping
    ORKISpeechInNoiseStep *internalSpeechInNoiseStep = [ORKInternalClassMapper _mapPublicSpeechInNoiseStep:class];
    if (internalSpeechInNoiseStep != nil) {
        return internalSpeechInNoiseStep;
    }
    
    // attempt speech recognition step mapping
    ORKISpeechRecognitionStep *internalSpeechRecognitionStep = [ORKInternalClassMapper _mapPublicSpeechRecognitionStep:class];
    if (internalSpeechRecognitionStep != nil) {
        return internalSpeechRecognitionStep;
    }
    
    // attempt environment spl meter step mapping
    ORKIEnvironmentSPLMeterStep *internalEnvironmentSPLMeterStep = [ORKInternalClassMapper _mapPublicEnvironmentSPLMeterStep:class];
    if (internalEnvironmentSPLMeterStep != nil) {
        return internalEnvironmentSPLMeterStep;
    }
    
    // attempt completion step mapping
    ORKICompletionStep *internalCompletionStep = [ORKInternalClassMapper _mapPublicCompletionStep:class];
    if (internalCompletionStep != nil) {
        return internalCompletionStep;
    }
    
    return nil;
}

+ (nullable id)_mapPublicInstructionStep:(id)class {
    ORKInstructionStep *instructionStep = (ORKInstructionStep *)class;

    if ([NSStringFromClass([instructionStep class]) isEqualToString:NSStringFromClass([ORKInstructionStep class])]) {
        ORKIInstructionStep *internalInstructionStep = [[ORKIInstructionStep alloc] initWithIdentifier:[instructionStep.identifier copy]];
        
        // ORKInstructionStep properties
        internalInstructionStep.attributedDetailText = [instructionStep.attributedDetailText copy];
        internalInstructionStep.centerImageVertically = instructionStep.centerImageVertically;
        internalInstructionStep.type = instructionStep.type;
        
        // ORKStep properties
        internalInstructionStep.optional = instructionStep.optional;
        internalInstructionStep.title = [instructionStep.title copy];
        internalInstructionStep.text = [instructionStep.text copy];
        internalInstructionStep.detailText = [instructionStep.detailText copy];
        internalInstructionStep.headerTextAlignment = instructionStep.headerTextAlignment;
        internalInstructionStep.footnote = [instructionStep.footnote copy];
        internalInstructionStep.iconImage = [instructionStep.iconImage copy];
        internalInstructionStep.shouldAutomaticallyAdjustImageTintColor = instructionStep.shouldAutomaticallyAdjustImageTintColor;
        internalInstructionStep.showsProgress = instructionStep.showsProgress;
        internalInstructionStep.useExtendedPadding = instructionStep.useExtendedPadding;
        internalInstructionStep.earlyTerminationConfiguration = [instructionStep.earlyTerminationConfiguration copy];
        internalInstructionStep.task = instructionStep.task;
        
        return internalInstructionStep;
    }
    
    return nil;
}

+ (nullable id)_mapPublicQuestionStep:(id)class {
    ORKQuestionStep *questionStep = (ORKQuestionStep *)class;
    
    if ([NSStringFromClass([questionStep class]) isEqualToString:NSStringFromClass([ORKQuestionStep class])]) {
        ORKIQuestionStep *internalQuestionStep = [[ORKIQuestionStep alloc] initWithIdentifier:[questionStep.identifier copy]];
        
        // ORKQuestionStep properties
        internalQuestionStep.answerFormat = [questionStep.answerFormat copy];
        internalQuestionStep.question = [questionStep.question copy];
        internalQuestionStep.placeholder = [questionStep.placeholder copy];
        internalQuestionStep.useCardView = questionStep.useCardView;
        internalQuestionStep.learnMoreItem = [questionStep.learnMoreItem copy];
        internalQuestionStep.tagText = [questionStep.tagText copy];
        internalQuestionStep.presentationStyle = questionStep.presentationStyle;
        
        // ORKStep properties
        internalQuestionStep.optional = questionStep.optional;
        internalQuestionStep.title = [questionStep.title copy];
        internalQuestionStep.text = [questionStep.text copy];
        internalQuestionStep.detailText = [questionStep.detailText copy];
        internalQuestionStep.headerTextAlignment = questionStep.headerTextAlignment;
        internalQuestionStep.footnote = [questionStep.footnote copy];
        internalQuestionStep.iconImage = [questionStep.iconImage copy];
        internalQuestionStep.shouldAutomaticallyAdjustImageTintColor = questionStep.shouldAutomaticallyAdjustImageTintColor;
        internalQuestionStep.showsProgress = questionStep.showsProgress;
        internalQuestionStep.useExtendedPadding = questionStep.useExtendedPadding;
        internalQuestionStep.earlyTerminationConfiguration = [questionStep.earlyTerminationConfiguration copy];
        internalQuestionStep.task = questionStep.task;
        
        return internalQuestionStep;
    }
    
    return nil;
}

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

+ (nullable id)_mapPublicSpeechInNoiseStep:(id)class {
    ORKSpeechInNoiseStep *speechInNoiseStep = (ORKSpeechInNoiseStep *)class;
    
    if ([NSStringFromClass([speechInNoiseStep class]) isEqualToString:NSStringFromClass([ORKSpeechInNoiseStep class])]) {
        ORKISpeechInNoiseStep *internalSpeechInNoiseStep = [[ORKISpeechInNoiseStep alloc] initWithIdentifier:[speechInNoiseStep.identifier copy]];
        
        // ORKSpeechInNoiseStep properties
        internalSpeechInNoiseStep.speechFilePath = [speechInNoiseStep.speechFilePath copy];
        internalSpeechInNoiseStep.targetSentence = [speechInNoiseStep.targetSentence copy];
        internalSpeechInNoiseStep.speechFileNameWithExtension = [speechInNoiseStep.speechFileNameWithExtension copy];
        internalSpeechInNoiseStep.noiseFileNameWithExtension = [speechInNoiseStep.noiseFileNameWithExtension copy];
        internalSpeechInNoiseStep.filterFileNameWithExtension = [speechInNoiseStep.filterFileNameWithExtension copy];
        internalSpeechInNoiseStep.gainAppliedToNoise = speechInNoiseStep.gainAppliedToNoise;
        internalSpeechInNoiseStep.willAudioLoop = speechInNoiseStep.willAudioLoop;
        internalSpeechInNoiseStep.hideGraphView = speechInNoiseStep.hideGraphView;
        
        // ORKStep properties
        internalSpeechInNoiseStep.optional = speechInNoiseStep.optional;
        internalSpeechInNoiseStep.title = [speechInNoiseStep.title copy];
        internalSpeechInNoiseStep.text = [speechInNoiseStep.text copy];
        internalSpeechInNoiseStep.detailText = [speechInNoiseStep.detailText copy];
        internalSpeechInNoiseStep.headerTextAlignment = speechInNoiseStep.headerTextAlignment;
        internalSpeechInNoiseStep.footnote = [speechInNoiseStep.footnote copy];
        internalSpeechInNoiseStep.iconImage = [speechInNoiseStep.iconImage copy];
        internalSpeechInNoiseStep.shouldAutomaticallyAdjustImageTintColor = speechInNoiseStep.shouldAutomaticallyAdjustImageTintColor;
        internalSpeechInNoiseStep.showsProgress = speechInNoiseStep.showsProgress;
        internalSpeechInNoiseStep.useExtendedPadding = speechInNoiseStep.useExtendedPadding;
        internalSpeechInNoiseStep.earlyTerminationConfiguration = [speechInNoiseStep.earlyTerminationConfiguration copy];
        internalSpeechInNoiseStep.task = speechInNoiseStep.task;
        
        return internalSpeechInNoiseStep;
    }
    
    return nil;
}

+ (nullable id)_mapPublicSpeechRecognitionStep:(id)class {
    ORKSpeechRecognitionStep *speechRecognitionStep = (ORKSpeechRecognitionStep *)class;
    
    if ([NSStringFromClass([speechRecognitionStep class]) isEqualToString:NSStringFromClass([ORKSpeechRecognitionStep class])]) {
        ORKISpeechRecognitionStep *internalSpeechRecognitionStep = [[ORKISpeechRecognitionStep alloc] initWithIdentifier:[speechRecognitionStep.identifier copy]];
        
        // ORKSpeechRecognitionStep properties
        internalSpeechRecognitionStep.speechRecognizerLocale = [speechRecognitionStep.speechRecognizerLocale copy];
        internalSpeechRecognitionStep.shouldHideTranscript = speechRecognitionStep.shouldHideTranscript;
        
        // ORKStep properties
        internalSpeechRecognitionStep.optional = speechRecognitionStep.optional;
        internalSpeechRecognitionStep.title = [speechRecognitionStep.title copy];
        internalSpeechRecognitionStep.text = [speechRecognitionStep.text copy];
        internalSpeechRecognitionStep.detailText = [speechRecognitionStep.detailText copy];
        internalSpeechRecognitionStep.headerTextAlignment = speechRecognitionStep.headerTextAlignment;
        internalSpeechRecognitionStep.footnote = [speechRecognitionStep.footnote copy];
        internalSpeechRecognitionStep.iconImage = [speechRecognitionStep.iconImage copy];
        internalSpeechRecognitionStep.shouldAutomaticallyAdjustImageTintColor = speechRecognitionStep.shouldAutomaticallyAdjustImageTintColor;
        internalSpeechRecognitionStep.showsProgress = speechRecognitionStep.showsProgress;
        internalSpeechRecognitionStep.useExtendedPadding = speechRecognitionStep.useExtendedPadding;
        internalSpeechRecognitionStep.earlyTerminationConfiguration = [speechRecognitionStep.earlyTerminationConfiguration copy];
        internalSpeechRecognitionStep.task = speechRecognitionStep.task;
        
        return internalSpeechRecognitionStep;
    }
    
    return nil;
}

+ (nullable id)_mapPublicEnvironmentSPLMeterStep:(id)class {
    ORKEnvironmentSPLMeterStep *environmentSPLMeterStep = (ORKEnvironmentSPLMeterStep *)class;
    
    if ([NSStringFromClass([environmentSPLMeterStep class]) isEqualToString:NSStringFromClass([ORKEnvironmentSPLMeterStep class])]) {
        ORKIEnvironmentSPLMeterStep *internalEnvironmentSPLMeterStep = [[ORKIEnvironmentSPLMeterStep alloc] initWithIdentifier:[environmentSPLMeterStep.identifier copy]];
        
        // ORKEnvironmentStep properties
        internalEnvironmentSPLMeterStep.thresholdValue = environmentSPLMeterStep.thresholdValue;
        internalEnvironmentSPLMeterStep.samplingInterval = environmentSPLMeterStep.samplingInterval;
        internalEnvironmentSPLMeterStep.requiredContiguousSamples = environmentSPLMeterStep.requiredContiguousSamples;
        
        // ORKStep properties
        internalEnvironmentSPLMeterStep.optional = environmentSPLMeterStep.optional;
        internalEnvironmentSPLMeterStep.title = [environmentSPLMeterStep.title copy];
        internalEnvironmentSPLMeterStep.text = [environmentSPLMeterStep.text copy];
        internalEnvironmentSPLMeterStep.detailText = [environmentSPLMeterStep.detailText copy];
        internalEnvironmentSPLMeterStep.headerTextAlignment = environmentSPLMeterStep.headerTextAlignment;
        internalEnvironmentSPLMeterStep.footnote = [environmentSPLMeterStep.footnote copy];
        internalEnvironmentSPLMeterStep.iconImage = [environmentSPLMeterStep.iconImage copy];
        internalEnvironmentSPLMeterStep.shouldAutomaticallyAdjustImageTintColor = environmentSPLMeterStep.shouldAutomaticallyAdjustImageTintColor;
        internalEnvironmentSPLMeterStep.showsProgress = environmentSPLMeterStep.showsProgress;
        internalEnvironmentSPLMeterStep.useExtendedPadding = environmentSPLMeterStep.useExtendedPadding;
        internalEnvironmentSPLMeterStep.earlyTerminationConfiguration = [environmentSPLMeterStep.earlyTerminationConfiguration copy];
        internalEnvironmentSPLMeterStep.task = environmentSPLMeterStep.task;
        
        return internalEnvironmentSPLMeterStep;
    }
    
    return nil;
}

+ (nullable id)_mapPublicCompletionStep:(id)class {
    ORKCompletionStep *completionStep = (ORKCompletionStep *)class;
    
    if ([NSStringFromClass([completionStep class]) isEqualToString:NSStringFromClass([ORKCompletionStep class])]) {
        ORKICompletionStep *internalCompletionStep = [[ORKICompletionStep alloc] initWithIdentifier:[completionStep.identifier copy]];
        
        // ORKCompletionStep properties
        internalCompletionStep.reasonForCompletion = completionStep.reasonForCompletion;

        // ORKStep properties
        internalCompletionStep.optional = completionStep.optional;
        internalCompletionStep.title = [completionStep.title copy];
        internalCompletionStep.text = [completionStep.text copy];
        internalCompletionStep.detailText = [completionStep.detailText copy];
        internalCompletionStep.headerTextAlignment = completionStep.headerTextAlignment;
        internalCompletionStep.footnote = [completionStep.footnote copy];
        internalCompletionStep.iconImage = [completionStep.iconImage copy];
        internalCompletionStep.shouldAutomaticallyAdjustImageTintColor = completionStep.shouldAutomaticallyAdjustImageTintColor;
        internalCompletionStep.showsProgress = completionStep.showsProgress;
        internalCompletionStep.useExtendedPadding = completionStep.useExtendedPadding;
        internalCompletionStep.earlyTerminationConfiguration = [completionStep.earlyTerminationConfiguration copy];
        internalCompletionStep.task = completionStep.task;
        
        return internalCompletionStep;
    }
    
    return nil;
}

@end
