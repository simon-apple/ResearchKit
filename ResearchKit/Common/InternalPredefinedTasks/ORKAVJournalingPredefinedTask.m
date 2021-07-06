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

//apple-internal

#import "ORKAVJournalingPredefinedTask.h"

#if ORK_FEATURE_AV_JOURNALING

#import "ORKAnswerFormat.h"
#import "ORKBodyItem.h"
#import "ORKCompletionStep.h"
#import "ORKHelpers_Internal.h"
#import "ORKStep.h"
#import "ORKFaceDetectionStep.h"
#import "ORKAVJournalingStep.h"
#import "ORKContext.h"
#import "ORKStepNavigationRule.h"
#import "ORKLearnMoreItem.h"
#import "ORKLearnMoreInstructionStep.h"
#import "ORKLearnMoreView.h"

static const double MinByteLimitForTask = 3000000000; //3GB Min Available Storage Limit

ORKAVJournalingStepIdentifier const ORKAVJournalingStepIdentifierFaceDetection = @"ORKAVJournalingStepIdentifierFaceDetection";
ORKAVJournalingStepIdentifier const ORKAVJournalingStepIdentifierCompletion = @"ORKAVJournalingStepIdentifierCompletion";
ORKAVJournalingStepIdentifier const ORKAVJournalingStepIdentifierMaxLimitHitCompletion = @"ORKAVJournalingStepIdentifierMaxLimitHitCompletion";
ORKAVJournalingStepIdentifier const ORKAVJournalingStepIdentifierFinishLaterCompletion = @"ORKAVJournalingStepIdentifierFinishLaterCompletion";
ORKAVJournalingStepIdentifier const ORKAVJournalingStepIdentifierFinishLaterFaceDetection = @"ORKAVJournalingStepIdentifierFinishLaterFaceDetection";
ORKAVJournalingStepIdentifier const ORKAVJournalingStepIdentifierLowMemoryCompletion = @"ORKAVJournalingStepIdentifierLowMemoryCompletion";
ORKAVJournalingStepIdentifier const ORKAVJournalingStepIdentifierVideoAudioAccessDeniedCompletion = @"ORKAVJournalingStepIdentifierVideoAudioAccessDeniedCompletion";
ORKAVJournalingStepIdentifier const ORKAVJournalingStepIdentifierLowStorageLearnMore = @"ORKAVJournalingStepIdentifierLowStorageLearnMore";
ORKAVJournalingStepIdentifier const ORKAVJournalingStepIdentifierInstructionStepPlaceHolderVideoAudioAccessDenied = @"ORKAVJournalingStepIdentifierInstructionStepPlaceHolderVideoAudioAccessDenied";

@interface ORKAVJournalingPredfinedTaskContext()<ORKLearnMoreViewDelegate>
@end

@implementation ORKAVJournalingPredfinedTaskContext

- (NSString *)didSkipHeadphoneDetectionStepForTask:(id<ORKTask>)task {
    NSAssert(NO, @"Not Implemented");
    return nil;
}

- (void)didReachDetectionTimeLimitForTask:(id<ORKTask>)task currentStepIdentifier:(NSString *)currentStepIdentifier {
    
    if ([task isKindOfClass:[ORKNavigableOrderedTask class]]) {
        // If the user reaches the max limit for face detection, append a new step to the end of the task and skip to the end.
        
        // Add a navigation rule to end the current task.
        ORKNavigableOrderedTask *currentTask = (ORKNavigableOrderedTask *)task;
        
        ORKCompletionStep *step = [[ORKCompletionStep alloc] initWithIdentifier:ORKAVJournalingStepIdentifierMaxLimitHitCompletion];
        step.title = ORKLocalizedString(@"AV_JOURNALING_FACE_DETECTION_STEP_TIME_LIMIT_REACHED_TITLE", nil);
        step.text = ORKLocalizedString(@"AV_JOURNALING_STEP_FINISH_LATER_TEXT", nil);
        step.optional = NO;
        step.reasonForCompletion = ORKTaskViewControllerFinishReasonDiscarded;
        [currentTask addStep:step];

        ORKDirectStepNavigationRule *endNavigationRule = [[ORKDirectStepNavigationRule alloc] initWithDestinationStepIdentifier:ORKNullStepIdentifier];
        [currentTask setNavigationRule:endNavigationRule forTriggerStepIdentifier:step.identifier];
    }
}

- (void)finishLaterWasPressedForTask:(id<ORKTask>)task currentStepIdentifier:(NSString *)currentStepIdentifier {
    if ([task isKindOfClass:[ORKNavigableOrderedTask class]]) {
        // If the user presses finish later, append a new step to the end of the task and skip to the end.
        
        // Add a navigation rule to end the current task.
        ORKNavigableOrderedTask *currentTask = (ORKNavigableOrderedTask *)task;
        
        ORKCompletionStep *step = [[ORKCompletionStep alloc] initWithIdentifier:ORKAVJournalingStepIdentifierFinishLaterCompletion];
        step.title = ORKLocalizedString(@"AV_JOURNALING_STEP_FINISH_LATER_TITLE", nil);
        step.text = ORKLocalizedString(@"AV_JOURNALING_STEP_FINISH_LATER_TEXT", nil);
        step.optional = NO;
        step.reasonForCompletion = ORKTaskViewControllerFinishReasonDiscarded;
        [currentTask addStep:step];

        ORKDirectStepNavigationRule *endNavigationRule = [[ORKDirectStepNavigationRule alloc] initWithDestinationStepIdentifier:ORKNullStepIdentifier];
        [currentTask setNavigationRule:endNavigationRule forTriggerStepIdentifier:step.identifier];
    }
}

- (void)videoOrAudioAccessDeniedForTask:(id<ORKTask>)task {
    // If video or audio access is denied, append a new step to the end of the task and skip to the end.
    
    // Add a navigation rule to end the current task.
    ORKNavigableOrderedTask *currentTask = (ORKNavigableOrderedTask *)task;
    
    ORKCompletionStep *completionStep = [[ORKCompletionStep alloc] initWithIdentifier:ORKAVJournalingStepIdentifierVideoAudioAccessDeniedCompletion];
    completionStep.title = ORKLocalizedString(@"AV_JOURNALING_PREDEFINED_AUDIO_VIDEO_ACCESS_TITLE", nil);
    completionStep.text = ORKLocalizedString(@"AV_JOURNALING_PREDEFINED_AUDIO_VIDEO_ACCESS_TEXT", nil);
    completionStep.reasonForCompletion = ORKTaskViewControllerFinishReasonDiscarded;
    
    if (@available(iOS 13.0, *)) {
        completionStep.iconImage = [UIImage systemImageNamed:@"video.slash"];
    }
    
    ORKLearnMoreInstructionStep *learnMoreInstructionStep = [[ORKLearnMoreInstructionStep alloc] initWithIdentifier:ORKAVJournalingStepIdentifierInstructionStepPlaceHolderVideoAudioAccessDenied];
    ORKLearnMoreItem *learnMoreItem = [[ORKLearnMoreItem alloc] initWithText:ORKLocalizedString(@"AV_JOURNALING_PREDEFINED_AUDIO_VIDEO_ACCESS_SETTINGS_LINK_TEXT", nil)
                                                    learnMoreInstructionStep:learnMoreInstructionStep];
    learnMoreItem.delegate = self;
    
    ORKBodyItem *settingsLinkBodyItem = [[ORKBodyItem alloc] initWithText:nil
                                                               detailText:nil
                                                                    image:nil
                                                            learnMoreItem:learnMoreItem
                                                            bodyItemStyle:ORKBodyItemStyleText];
    
    completionStep.bodyItems = @[settingsLinkBodyItem];

    
    [currentTask addStep:completionStep];

    ORKDirectStepNavigationRule *endNavigationRule = [[ORKDirectStepNavigationRule alloc] initWithDestinationStepIdentifier:ORKNullStepIdentifier];
    [currentTask setNavigationRule:endNavigationRule forTriggerStepIdentifier:completionStep.identifier];
}

#pragma mark - Helper Methods (private)

- (int)numberOfCompletedAVJournalingStepsFromTask:(ORKNavigableOrderedTask *)task currentStepIdentifier:(NSString *)currentStepIdentifier {
    int numberOfCompleted = 0;
    
    for(ORKStep *step in task.steps) {
        if ([step isKindOfClass:[ORKAVJournalingStep class]]) {
            if (step.identifier == currentStepIdentifier) {
                break;
            } else {
                numberOfCompleted += 1;
            }
        }
    }
    
    return numberOfCompleted;
}

- (int)totalAVJournalingStepsWithinTask:(ORKNavigableOrderedTask *)task {
    int total = 0;
    
    for(ORKStep *step in task.steps) {
        if ([step isKindOfClass:[ORKAVJournalingStep class]]) {
            total += 1;
        }
    }
    
    return total;
}

#pragma mark - ORKLearnMoreViewDelegate

- (void)learnMoreButtonPressedWithStep:(ORKLearnMoreInstructionStep *)learnMoreStep {
    if ([learnMoreStep.identifier isEqual:ORKAVJournalingStepIdentifierInstructionStepPlaceHolderVideoAudioAccessDenied]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString] options:@{} completionHandler:^(BOOL success) {}];
    }
}

@end


@implementation ORKAVJournalingPredefinedTask {
    NSSet<NSString *> *_prependStepIdentifiers;
    NSSet<NSString *> *_appendStepIdentifiers;
}

- (instancetype)initWithIdentifier:(NSString *)identifier
    journalQuestionSetManifestPath:(NSString *)journalQuestionSetManifestPath
                      prependSteps:(nullable NSArray<ORKStep *> *)prependSteps
                       appendSteps:(nullable NSArray<ORKStep *> *)appendSteps  {
    
    NSError *error = nil;
    NSArray<ORKStep *> *steps = nil;
    
    steps = [ORKAVJournalingPredefinedTask predefinedStepsWithManifestPath:journalQuestionSetManifestPath
                                                              prependSteps:prependSteps
                                                               appendSteps:appendSteps
                                                                     error:&error];
    
    if (error) {
        ORK_Log_Error("An error occurred while creating the predefined task. %@", error);
        return nil;
    }
    
    self = [super initWithIdentifier:identifier steps:steps];
    if (self) {
        _journalQuestionSetManifestPath = [journalQuestionSetManifestPath copy];
        _prependSteps = [prependSteps copy];
        _appendSteps = [appendSteps copy];
        
        NSMutableSet<NSString *> *prependStepIdentifiers = [NSMutableSet new];
        for (ORKStep *step in prependSteps) {
            [prependStepIdentifiers addObject:step.identifier];
        }
        _prependStepIdentifiers = [prependStepIdentifiers copy];
        
        NSMutableSet<NSString *> *appendStepIdentifiers = [NSMutableSet new];
        for (ORKStep *step in appendSteps) {
            [appendStepIdentifiers addObject:step.identifier];
        }
        _appendStepIdentifiers = [appendStepIdentifiers copy];
        
        for (ORKStep *step in self.steps) {
            if ([step isKindOfClass:[ORKStep class]]) {
                [step setTask:self];
            }
        }
        
    }
    
    return self;
}

- (instancetype)initWithIdentifier:(NSString *)identifier steps:(nullable NSArray<ORKStep *> *)steps {
    ORKThrowMethodUnavailableException();
}

+ (nullable NSArray<ORKStep *> *)predefinedStepsWithManifestPath:(NSString *)manifestPath
                                                    prependSteps:(nullable NSArray<ORKStep *> *)prependSteps
                                                     appendSteps:(nullable NSArray<ORKStep *> *)appendSteps
                                                           error:(NSError * _Nullable * _Nullable)error {
    
    NSMutableArray<ORKStep *> *steps = [[NSMutableArray alloc] init];
    
    BOOL lowMemoryDetected = NO;
    
    NSFileManager *fileManager = NSFileManager.defaultManager;
    NSString *filePath = [NSString stringWithFormat:@"%@/Documents/avjournaling_temp.txt", NSHomeDirectory()];
    
    if ([fileManager createFileAtPath:filePath contents:nil attributes:nil]) {
        // file was created successfully
        NSError *availableCapacityError = nil;
        NSURL *fileURL = [[NSURL alloc] initFileURLWithPath:filePath];
        NSDictionary *results = [fileURL resourceValuesForKeys:@[NSURLVolumeAvailableCapacityForImportantUsageKey] error:&availableCapacityError];
        
        if (!results) {
            ORK_Log_Error("Error retrieving resource keys: %@\n%@", [availableCapacityError localizedDescription], [availableCapacityError userInfo]);
        } else {
            
            double availableBytes = [((NSString *)results[NSURLVolumeAvailableCapacityForImportantUsageKey]) doubleValue];
            
            if (availableBytes < MinByteLimitForTask) {
                lowMemoryDetected = YES;
                
                ORKCompletionStep *completionStep = [[ORKCompletionStep alloc] initWithIdentifier:ORKAVJournalingStepIdentifierLowMemoryCompletion];
                completionStep.title = ORKLocalizedString(@"AV_JOURNALING_PREDEFINED_LOW_MEMORY_TITLE", nil);
                completionStep.text = ORKLocalizedString(@"AV_JOURNALING_PREDEFINED_LOW_MEMORY_TEXT", nil);
                completionStep.reasonForCompletion = ORKTaskViewControllerFinishReasonDiscarded;
                
                if (@available(iOS 13.0, *)) {
                    completionStep.iconImage = [UIImage systemImageNamed:@"bin.xmark"];
                }
                
                ORKLearnMoreInstructionStep *learnMoreInstructionStep = [[ORKLearnMoreInstructionStep alloc] initWithIdentifier:ORKAVJournalingStepIdentifierLowStorageLearnMore];
                ORKLearnMoreItem *learnMoreItem = [[ORKLearnMoreItem alloc] initWithText:ORKLocalizedString(@"AV_JOURNALING_PREDEFINED_LOW_MEMORY_SETTINGS_LINK_TEXT", nil)
                                                                learnMoreInstructionStep:learnMoreInstructionStep];
                
                ORKBodyItem *settingsLinkBodyItem = [[ORKBodyItem alloc] initWithText:nil
                                                                           detailText:nil
                                                                                image:nil
                                                                        learnMoreItem:learnMoreItem
                                                                        bodyItemStyle:ORKBodyItemStyleText];
                
                completionStep.bodyItems = @[settingsLinkBodyItem];
                
                steps = [NSMutableArray arrayWithObject:completionStep];
            }
        }
        
        
    } else {
        ORK_Log_Error("Unsuccessfully created avjournaling_temp.txt file");
    }
    
    // remove temp file if detected
    if ([fileManager fileExistsAtPath:filePath]){
        NSError *fileDeletionError = nil;
        [fileManager removeItemAtPath:filePath error:&fileDeletionError];
        
        if (fileDeletionError) {
            ORK_Log_Error("Error deleting avjournaling_temp.txt file: %@\n%@", [fileDeletionError localizedDescription], [fileDeletionError userInfo]);
        }
    }
    
    if (!lowMemoryDetected) {
        if (prependSteps.count > 0) {
            [steps addObjectsFromArray:[prependSteps copy]];
        }
        
        //Fetch AVJournalSteps from manifest file
        NSArray<ORKAVJournalingStep *> *avJournalingSteps = [self journalingStepsWithManifestPath:manifestPath error:error];
        
        //Face Detection Step
        ORKAVJournalingPredfinedTaskContext *avJournalingPredefinedContext = [[ORKAVJournalingPredfinedTaskContext alloc] init];
        ORKFaceDetectionStep *faceDetectionStep = [[ORKFaceDetectionStep alloc] initWithIdentifier:ORKAVJournalingStepIdentifierFaceDetection];
        faceDetectionStep.title = ORKLocalizedString(@"AV_JOURNALING_PREDEFINED_TASK_FACE_DETECTION_STEP_TITLE", nil);
        faceDetectionStep.context = avJournalingPredefinedContext;
        
        [steps addObject:faceDetectionStep];
        
        //add AVJournalSteps
        for (ORKAVJournalingStep* avJournalingStep in avJournalingSteps) {
            avJournalingStep.context = avJournalingPredefinedContext;
            [steps addObject:avJournalingStep];
        }
        
        if (appendSteps.count > 0) {
            [steps addObjectsFromArray:[appendSteps copy]];
        }
        
        //Completion Step
        ORKCompletionStep *completionStep = [[ORKCompletionStep alloc] initWithIdentifier:ORKAVJournalingStepIdentifierCompletion];
        completionStep.title = ORKLocalizedString(@"AV_JOURNALING_PREDEFINED_TASK_COMPLETION_TITLE", "");
        completionStep.text = ORKLocalizedString(@"AV_JOURNALING_PREDEFINED_TASK_COMPLETION_TEXT", "");
        
        [steps addObject:completionStep];
    }
    
    
    return [steps copy];
}

+ (nullable NSArray<ORKAVJournalingStep *> *)journalingStepsWithManifestPath:(nonnull NSString *)manifestPath error:(NSError * _Nullable * _Nullable)error {
    
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    
    if (![fileManager fileExistsAtPath:manifestPath]) {
        if (error != NULL) {
            *error = [NSError errorWithDomain:ORKErrorDomain
                                         code:ORKErrorException
                                     userInfo:@{NSLocalizedFailureReasonErrorKey: [NSString stringWithFormat:@"Could not locate file at path %@", manifestPath]}];
        }
        return nil;
    }
    
    NSData *data = [NSData dataWithContentsOfFile:manifestPath options:0 error:error];
    if (!data) {
        return nil;
    }
    
    NSArray<NSDictionary *> *manifest = [NSJSONSerialization JSONObjectWithData:data options:0 error:error];
    if (!manifest) {
        return nil;
    }
    
    NSString *parentDirectory = [manifestPath stringByDeletingLastPathComponent];
    BOOL isDir;
    if (![fileManager fileExistsAtPath:parentDirectory isDirectory:&isDir] || !isDir) {
        if (error != NULL) {
            *error = [NSError errorWithDomain:ORKErrorDomain
                                         code:ORKErrorException
                                     userInfo:@{NSLocalizedFailureReasonErrorKey: [NSString stringWithFormat:@"Could not locate parent directory at path %@", parentDirectory]}];
        }
        return nil;
    }
    
    NSString * const ManifestJSONKeyIdentifier = @"identifier";
    NSString * const ManifestJSONKeyQuestion = @"question";
    NSString * const ManifestJSONKeyMaxRecordingTime = @"maxRecordingTime";
    NSString * const ManifestJSONKeyCountDownStartTime = @"countDownStartTime";
    NSString * const ManifestJSONKeySaveDepthDataIfAvailable = @"saveDepthDataIfAvailable";
    
    NSMutableArray<ORKAVJournalingStep *> *avJournalingSteps = [[NSMutableArray alloc] init];
    
    __block BOOL success;
    __block NSError *err;
    [manifest enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        NSString *avJournalStepIdentifier = (NSString *)[obj objectForKey:ManifestJSONKeyIdentifier];
        NSString *avJournalStepQuestion = (NSString *)[obj objectForKey:ManifestJSONKeyQuestion];
        NSString *avJournalStepMaxRecordingTime = (NSString *)[obj objectForKey:ManifestJSONKeyMaxRecordingTime];
        NSString *avJournalStepCountDownStartTime = (NSString *)[obj objectForKey:ManifestJSONKeyCountDownStartTime];
        
        NSTimeInterval maxRecordingtime = [avJournalStepMaxRecordingTime doubleValue];
        NSTimeInterval countDownStartTime = avJournalStepCountDownStartTime ? [avJournalStepCountDownStartTime integerValue] : 30;
        
        if (avJournalStepIdentifier && avJournalStepQuestion && [obj objectForKey:ManifestJSONKeyMaxRecordingTime] && [obj objectForKey:ManifestJSONKeySaveDepthDataIfAvailable]) {
            ORKAVJournalingStep *avJournalingStep = [[ORKAVJournalingStep alloc] initWithIdentifier:avJournalStepIdentifier];
            avJournalingStep.title = [NSString stringWithFormat:ORKLocalizedString(@"AV_JOURNALING_STEP_QUESTION_NUMBER_TEXT", nil), avJournalingSteps.count + 1, manifest.count];
            avJournalingStep.text = avJournalStepQuestion;
            avJournalingStep.maximumRecordingLimit = maxRecordingtime;
            avJournalingStep.countDownStartTime = countDownStartTime;
            
#if ORK_FEATURE_AV_JOURNALING_DEPTH_DATA_COLLECTION
            NSString *avJournalStepSaveDepthDataIfAvailable = (NSString *)[obj objectForKey:ManifestJSONKeySaveDepthDataIfAvailable];
            avJournalingStep.saveDepthDataIfAvailable = [avJournalStepSaveDepthDataIfAvailable boolValue];
#else
            avJournalingStep.saveDepthDataIfAvailable = NO;
#endif
            
            [avJournalingSteps addObject: avJournalingStep];
            success = YES;
        } else {
            *stop = YES;
            err = [NSError errorWithDomain:ORKErrorDomain
                                      code:ORKErrorException
                                  userInfo:@{NSLocalizedFailureReasonErrorKey: [NSString stringWithFormat:@"Could not locate identifier or question value within the manifest.json file"]}];
            success = NO;
        }
    }];
    
    if (success) {
        return [avJournalingSteps copy];
    } else {
        if (error != NULL) {
            *error = err;
        }
        return nil;
    }
}

- (BOOL)isAppendStepIdentifier:(NSString *)stepIdentifier {
    if (stepIdentifier == nil) {
        return NO;
    }

    return [_appendStepIdentifiers containsObject:stepIdentifier];
}

- (BOOL)isVideoRecordingStepIdentifier:(NSString *)stepIdentifier {
    if (stepIdentifier == nil) {
        return NO;
    }
    return !([_prependStepIdentifiers containsObject:stepIdentifier] ||
             [_appendStepIdentifiers containsObject:stepIdentifier] ||
             [stepIdentifier isEqualToString:ORKAVJournalingStepIdentifierFaceDetection] ||
             [stepIdentifier isEqualToString:ORKAVJournalingStepIdentifierCompletion] ||
             [stepIdentifier isEqualToString:ORKAVJournalingStepIdentifierMaxLimitHitCompletion] ||
             [stepIdentifier isEqualToString:ORKAVJournalingStepIdentifierFinishLaterCompletion] ||
             [stepIdentifier isEqualToString:ORKAVJournalingStepIdentifierFinishLaterFaceDetection] ||
             [stepIdentifier isEqualToString:ORKAVJournalingStepIdentifierLowMemoryCompletion] ||
             [stepIdentifier isEqualToString:ORKAVJournalingStepIdentifierVideoAudioAccessDeniedCompletion]);
}

#pragma mark - NSSecureCoding

+ (BOOL)supportsSecureCoding {
    return [super supportsSecureCoding];
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    ORK_ENCODE_OBJ(aCoder, journalQuestionSetManifestPath);
    ORK_ENCODE_OBJ(aCoder, prependSteps);
    ORK_ENCODE_OBJ(aCoder, appendSteps);
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        ORK_DECODE_OBJ_CLASS(aDecoder, journalQuestionSetManifestPath, NSString);
        ORK_DECODE_OBJ_ARRAY(aDecoder, prependSteps, ORKStep);
        ORK_DECODE_OBJ_ARRAY(aDecoder, appendSteps, ORKStep);
    }
    return self;
}

#pragma mark - NSCopying

- (instancetype)copyWithZone:(NSZone *)zone {    
    return [[[self class] allocWithZone:zone] initWithIdentifier:[self.identifier copy]
                                  journalQuestionSetManifestPath:[self.journalQuestionSetManifestPath copy]
                                                    prependSteps:[[NSArray alloc] initWithArray:self.prependSteps copyItems:YES]
                                                     appendSteps:[[NSArray alloc] initWithArray:self.appendSteps copyItems:YES]];
}

- (BOOL)isEqual:(id)object {
    BOOL isParentSame = [super isEqual:object];
    
    __typeof(self) castObject = object;
    
    return (isParentSame &&
            [self.journalQuestionSetManifestPath isEqualToString:castObject.journalQuestionSetManifestPath] &&
            [self.prependSteps isEqualToArray:castObject.prependSteps] &&
            [self.appendSteps isEqualToArray:castObject.appendSteps]);
}

- (NSUInteger)hash {
    return [super hash] ^ [_journalQuestionSetManifestPath hash] ^ [_prependSteps hash] ^ [_appendSteps hash];
}

@end

#endif
