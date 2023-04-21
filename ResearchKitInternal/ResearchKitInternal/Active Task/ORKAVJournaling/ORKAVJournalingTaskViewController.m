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

// apple-internal

#import "ORKAVJournalingTaskViewController.h"
#import "ORKContext.h"

#import "AAPLUtils.h"

#if ORK_FEATURE_AV_JOURNALING

#import "ORKAVJournalingPredefinedTask_Internal.h"
#import "ORKFaceDetectionStep.h"

#import <ResearchKit/ORKHelpers_Internal.h>

#import <ResearchKitUI/ORKStepViewController_Internal.h>
#import <ResearchKitUI/ORKTaskViewController_Internal.h>


@implementation ORKAVJournalingTaskViewController {
    ORKStepResult *_removedManagedVideoRecordingStepResult;
    BOOL _lowMemoryStepDetected;
    NSMutableArray *_internalManagedResults;
}

- (instancetype)initWithTask:(id<ORKTask>)task restorationData:(NSData *)data delegate:(id<ORKTaskViewControllerDelegate>)delegate error:(NSError* __autoreleasing *)errorOut {
    
    if (![task isKindOfClass:[ORKAVJournalingPredefinedTask class]]) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"task must be of ORKAVJournalingPredefinedTask class" userInfo:nil];
    }
    
    self = [self initWithTask:task taskRunUUID:nil];
    
    if (self) {
        self.delegate = delegate;
        if (data != nil) {
            self.restorationClass = [self class];
            NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
            
            [self decodeRestorableStateWithCoder:unarchiver];
            [self updateAVJournalingTaskArrayForResumption];
            [self applicationFinishedRestoringState];
            
            if (unarchiver == nil) {
                *errorOut = [NSError errorWithDomain:ORKErrorDomain code:ORKErrorException userInfo:@{NSLocalizedDescriptionKey: AAPLLocalizedString(@"RESTORE_ERROR_CANNOT_DECODE", nil)}];
            }
        }
    }
    return self;
}

- (instancetype)initWithTask:(id<ORKTask>)task
               ongoingResult:(nullable ORKTaskResult *)ongoingResult
         defaultResultSource:(nullable id<ORKTaskResultSource>)defaultResultSource
                    delegate:(id<ORKTaskViewControllerDelegate>)delegate {
    
    if (![task isKindOfClass:[ORKAVJournalingPredefinedTask class]]) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"task must be of ORKAVJournalingPredefinedTask class." userInfo:nil];
    }
    
    if ([task stepWithIdentifier:ORKAVJournalingStepIdentifierLowMemoryCompletion] != nil) {
        self = [[super initWithNibName:nil bundle:nil] commonInitWithTask:task taskRunUUID:nil];
        
        if (self) {
            _lowMemoryStepDetected = YES;
            self.delegate = delegate;
            self.defaultResultSource = defaultResultSource;
            _internalManagedResults = ongoingResult ? [ongoingResult.results copy] : nil;
        }
        
    } else {
        
        // TODO: remove this check in Nectarine
        if ([self resultContainLowMemoryIdentifier:ongoingResult]) {
            ongoingResult.results = [self removeLowMemoryResultFromArray:ongoingResult];
        }
        
        self = [super initWithTask:task
                     ongoingResult:ongoingResult
               defaultResultSource:defaultResultSource
                          delegate:delegate];
    }
    
    
    
    if (self) {
        [self updateAVJournalingTaskArrayForResumption];
    }
    return self;
}

- (BOOL)resultContainLowMemoryIdentifier:(nullable ORKTaskResult *)taskResult {
    if (!taskResult) {
        return NO;
    }
    
    NSArray *identifiers = [taskResult.results valueForKey:@"identifier"];
    return [identifiers containsObject:ORKAVJournalingStepIdentifierLowMemoryCompletion];
}

- (NSMutableArray *)removeLowMemoryResultFromArray:(ORKTaskResult *)taskResult {
    NSMutableArray *updatedStepResults = [NSMutableArray new];
    
    for (ORKStepResult *stepResult in taskResult.results) {
        NSString *stepIdentifier = stepResult.identifier;
        
        if (!([stepIdentifier isEqualToString:ORKAVJournalingStepIdentifierLowMemoryCompletion])) {
            [updatedStepResults addObject:stepResult];
        }
    }
    
    return [updatedStepResults copy];
}

- (void)updateAVJournalingTaskArrayForResumption {
    if (_lowMemoryStepDetected || self.restoredStepIdentifier == nil) {
        return;
    }
    NSString *restoredStepIdentifier = self.restoredStepIdentifier;
    ORKAVJournalingPredefinedTask *avJournalingTask = (ORKAVJournalingPredefinedTask *)self.task;

    if ([avJournalingTask isAppendStepIdentifier:restoredStepIdentifier]) {
        // If restoring to an appendStep, all the video recordings have been done, resume task normally
        return;
    } else if (![avJournalingTask isVideoRecordingStepIdentifier:restoredStepIdentifier]) {
        // If restoring to non video step (prepend or face detection), start task from scratch)
        [self.managedStepIdentifiers removeAllObjects];
        [self.managedResults removeAllObjects];
        self.restoredStepIdentifier = nil;
        return;
    }
    
    // Restoring to a video recording step
    if (self.managedStepIdentifiers.count <= 1) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Something has gone wrong when updating the task for resumption, the restoredStepIdentifier is a video step, but less than 2 managedStepIdentifiers found." userInfo:nil];
    }
    
    // Store and remove last ongoing video step result
    if (![self.managedStepIdentifiers.lastObject isEqualToString:restoredStepIdentifier]) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Something has gone wrong when updating the task for resumption, the restoredStepIdentifier should be the last managed step identifier." userInfo:nil];
    }
    _removedManagedVideoRecordingStepResult = self.managedResults[restoredStepIdentifier];
    [self.managedStepIdentifiers removeObject:restoredStepIdentifier];
    self.managedResults[restoredStepIdentifier] = nil;

    // Current video step was removed from managedStepIdentifiers and managedResults
    NSString *updatedLastStepIdentifier = self.managedStepIdentifiers.lastObject;
    if ([updatedLastStepIdentifier isEqualToString:ORKAVJournalingStepIdentifierFaceDetection]) {
        // The removed step was the first video recording step, restore to normal Face Detection Step
        self.restoredStepIdentifier = ORKAVJournalingStepIdentifierFaceDetection;
    } else if ([avJournalingTask isVideoRecordingStepIdentifier:self.restoredStepIdentifier]) {
        // The removed step was not the first video recording step,
        // add Finish Later Face Detection Step before it and restore to it
        ORKAVJournalingPredfinedTaskContext *avJournalingPredefinedContext = [[ORKAVJournalingPredfinedTaskContext alloc] init];
        ORKFaceDetectionStep *faceDetectionStep = [[ORKFaceDetectionStep alloc] initWithIdentifier:ORKAVJournalingStepIdentifierFinishLaterFaceDetection];
        faceDetectionStep.title = AAPLLocalizedString(@"AV_JOURNALING_PREDEFINED_TASK_FACE_DETECTION_STEP_TITLE", nil);
        faceDetectionStep.context = avJournalingPredefinedContext;
        NSUInteger insertionIndex = 0;
        BOOL identifierFound = NO;
        for (ORKStep *step in avJournalingTask.steps) {
            if ([step.identifier isEqualToString:restoredStepIdentifier]) {
                identifierFound = YES;
                break;
            }
            insertionIndex++;
        }
        if (!identifierFound) {
            @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Something has gone wrong when updating the task for resumption, expected video recording step not found in task." userInfo:nil];
        }
        [avJournalingTask insertStep:faceDetectionStep atIndex:insertionIndex];
        self.restoredStepIdentifier = ORKAVJournalingStepIdentifierFinishLaterFaceDetection;

    } else {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Something has gone wrong when updating the task for resumption, expected video recording step preceding restoredStepIdentifier but found other kind of step." userInfo:nil];
    }
}

- (ORKTaskResult *)result {
    // Remove all synthetic task-flow controlling results
    ORKTaskResult *taskResult = [super result];
    
    if (_lowMemoryStepDetected) {
        if (_internalManagedResults) {
            taskResult.results = [_internalManagedResults copy];
        }
        
        if ([self resultContainLowMemoryIdentifier:taskResult]) {
            taskResult.results = [self removeLowMemoryResultFromArray:taskResult];
        }
        
    } else {
        NSMutableArray *updatedStepResults = [NSMutableArray new];
        BOOL removedResultFound = NO;
        for (ORKStepResult *stepResult in taskResult.results) {
            NSString *stepIdentifier = stepResult.identifier;
            if ([stepIdentifier isEqualToString:_removedManagedVideoRecordingStepResult.identifier]) {
                removedResultFound = YES;
            }
            if (!([stepIdentifier isEqualToString:ORKAVJournalingStepIdentifierFinishLaterCompletion] ||
                  [stepIdentifier isEqualToString:ORKAVJournalingStepIdentifierMaxLimitHitCompletion] ||
                  [stepIdentifier isEqualToString:ORKAVJournalingStepIdentifierFinishLaterFaceDetection] ||
                  [stepIdentifier isEqualToString:ORKAVJournalingStepIdentifierVideoAudioAccessDeniedCompletion] ||
                  [stepIdentifier isEqualToString:ORKAVJournalingStepIdentifierLowMemoryCompletion])) {
                [updatedStepResults addObject:stepResult];
            }
        }
        // The following ensures the removed result is re-added if not seen in the newest task run.
        // It keeps state restoration working if you resume the task, and then cancel on the face calibration step.
        if (_removedManagedVideoRecordingStepResult != nil && !removedResultFound) {
            [updatedStepResults addObject:_removedManagedVideoRecordingStepResult];
        }
        taskResult.results = [updatedStepResults copy];
    }
    
    return taskResult;
}

- (void)stepViewControllerWillAppear:(ORKStepViewController *)stepViewController {
    ORKAVJournalingPredefinedTask *avJournalingTask = (ORKAVJournalingPredefinedTask *)self.task;
    if ([avJournalingTask isVideoRecordingStepIdentifier:stepViewController.step.identifier]) {
        stepViewController.cancelButtonItem = nil;
    }
}

@end

#endif
