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

#import "ORKAVJournalingPredefinedTask.h"
#import "ORKAnswerFormat.h"
#import "ORKBodyItem.h"
#import "ORKCompletionStep.h"
#import "ORKHelpers_Internal.h"
#import "ORKStep.h"

@implementation ORKAVJournalingPredefinedTask

- (instancetype)initWithIdentifier:(NSString *)identifier maxRecordingTime:(NSInteger)maxRecordingtime journalQuestionSetManifestPath:(NSString *)journalQuestionSetManifestPath {
    NSError *error = nil;
    NSArray<ORKStep *> *steps = [self setupStepsFromManifestPath:journalQuestionSetManifestPath
                                                maxRecordingTime:maxRecordingtime
                                                           error:&error];
    
    if (error) {
        //throw error
    }
    
    self = [super initWithIdentifier:identifier steps:steps];
    
    if (self) {
        _journalQuestionSetManifestPath = journalQuestionSetManifestPath;
        _maxRecordingTime = maxRecordingtime;
    }
    
    return self;
}

- (nullable NSArray<ORKStep *> *)setupStepsFromManifestPath:(NSString *)manifestPath maxRecordingTime:(NSInteger)maxRecordingTime error:(NSError * _Nullable * _Nullable)error {
    NSMutableArray<ORKStep *> *steps = [[NSMutableArray alloc] init];
    
    ORKInstructionStep *instructionStep = [[ORKInstructionStep alloc] initWithIdentifier:@"InstructionStepIdentifier"];
    instructionStep.title = ORKLocalizedString(@"AV_JOURNALING_PREDEFINED_TASK_INSTRUCTION_STEP_TITLE", nil);
    instructionStep.text = [NSString stringWithFormat:ORKLocalizedString(@"AV_JOURNALING_PREDEFINED_TASK_INSTRUCTION_STEP_TEXT", nil), 2];
    
    [steps addObject:instructionStep];
    
    ORKCompletionStep *completionStep = [[ORKCompletionStep alloc] initWithIdentifier:@"CompletionStepIdentifier"];
    completionStep.title = ORKLocalizedString(@"AV_JOURNALING_PREDEFINED_TASK_COMPLETION_TITLE", "");
    completionStep.text = ORKLocalizedString(@"AV_JOURNALING_PREDEFINED_TASK_COMPLETION_TEXT", "");
    
    [steps addObject:completionStep];
    
    return [steps copy];
}

#pragma mark - NSSecureCoding

+ (BOOL)supportsSecureCoding {
    return [super supportsSecureCoding];
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    ORK_ENCODE_OBJ(aCoder, journalQuestionSetManifestPath);
    ORK_ENCODE_DOUBLE(aCoder, maxRecordingTime);
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        ORK_DECODE_OBJ_CLASS(aDecoder, journalQuestionSetManifestPath, NSString);
        ORK_DECODE_DOUBLE(aDecoder, maxRecordingTime);
    }
    return self;
}

#pragma mark - NSCopying

- (instancetype)copyWithZone:(NSZone *)zone {    
    return [[[self class] allocWithZone:zone] initWithIdentifier: [self.identifier copy]
                                                maxRecordingTime: self.maxRecordingTime
                                  journalQuestionSetManifestPath: [self.journalQuestionSetManifestPath copy]];
}

- (BOOL)isEqual:(id)object {
    BOOL isParentSame = [super isEqual:object];
    
    __typeof(self) castObject = object;
    
    return (isParentSame &&
            ORKEqualObjects(self.journalQuestionSetManifestPath, castObject.journalQuestionSetManifestPath) &&
            (self.maxRecordingTime == castObject.maxRecordingTime));
}

- (NSUInteger)hash {
    return [super hash] ^ [_journalQuestionSetManifestPath hash];
}


@end
