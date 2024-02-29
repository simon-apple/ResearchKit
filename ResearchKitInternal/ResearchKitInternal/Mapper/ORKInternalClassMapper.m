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
    
    
    return nil;
}

+ (nullable id)_mapPublicInstructionStep:(id)class {
    ORKInstructionStep *instructionStep = (ORKInstructionStep *)class;
    
    if ([instructionStep isKindOfClass:[ORKInstructionStep class]]) {
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
    
    if ([questionStep isKindOfClass:[ORKQuestionStep class]]) {
        ORKIQuestionStep *internalQuestionStep = [[ORKIQuestionStep alloc] initWithIdentifier:[questionStep.identifier copy]];
        
        // ORKInstructionStep properties
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
//        @property (nonatomic, strong, nullable) ORKAnswerFormat *answerFormat;
//        @property (nonatomic, strong, nullable) NSString *question;
//        @property (nonatomic, readonly) ORKQuestionType questionType;
//        @property (nonatomic, copy, nullable) NSString *placeholder;
//        @property (nonatomic) BOOL useCardView;
//        @property (nonatomic, copy, nullable) ORKLearnMoreItem *learnMoreItem;
//        @property (nonatomic, copy, nullable) NSString *tagText;
    }
    
    return nil;
}

@end


//@property (nonatomic, getter=isOptional) BOOL optional;
//@property (nonatomic, copy, nullable) NSString *title;
//@property (nonatomic, copy, nullable) NSString *text;
//@property (nonatomic, copy, nullable) NSString *detailText;
//@property (nonatomic) NSTextAlignment headerTextAlignment;
//@property (nonatomic, copy, nullable) NSString *footnote;
//@property (nonatomic, copy, nullable) UIImage *iconImage;
//@property (nonatomic) BOOL shouldAutomaticallyAdjustImageTintColor;
//@property (nonatomic, assign) BOOL showsProgress;
//@property (nonatomic, assign) BOOL useExtendedPadding;
//@property (nonatomic, copy, nullable) ORKEarlyTerminationConfiguration *earlyTerminationConfiguration;
//@property (nonatomic, weak, nullable) id<ORKTask> task;
//@property (nonatomic, readonly) ORKPermissionMask requestedPermissions;
//@property (nonatomic, readonly, nullable) NSSet<HKObjectType *> *requestedHealthKitTypesForReading;
