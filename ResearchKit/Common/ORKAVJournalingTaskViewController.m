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

#import "ORKAVJournalingTaskViewController.h"
#import "ORKHelpers_Internal.h"
#import "ORKTaskViewController_Internal.h"
#import "ORKStepViewController_Internal.h"
#import "ORKAVJournalingPredefinedTask_Internal.h"
#import "ORKFaceDetectionStep.h"


@implementation ORKAVJournalingTaskViewController

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
                *errorOut = [NSError errorWithDomain:ORKErrorDomain code:ORKErrorException userInfo:@{NSLocalizedDescriptionKey: ORKLocalizedString(@"RESTORE_ERROR_CANNOT_DECODE", nil)}];
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
    
    self = [super initWithTask:task
                 ongoingResult:ongoingResult
           defaultResultSource:defaultResultSource
                      delegate:delegate];
    
    if (self) {
        [self updateAVJournalingTaskArrayForResumption];
    }
    return self;
}


- (void)updateAVJournalingTaskArrayForResumption {
    if (self.restoredStepIdentifier == nil) {
        return;
    }
    NSString *restoredStepIdentifier = self.restoredStepIdentifier;
    ORKAVJournalingPredefinedTask *avJournalingTask = (ORKAVJournalingPredefinedTask *)self.task;
    // If video step
    if ([avJournalingTask isVideoRecordingStepIdentifier:restoredStepIdentifier]) {
        // Remove last ongoing video step
        if (![self.managedStepIdentifiers.lastObject isEqualToString:restoredStepIdentifier]) {
            @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Something has gone wrong when updating the task for resumption, the restoredStepIdentifier should be the last managed step identifier." userInfo:nil];
        }
        [self.managedStepIdentifiers removeObject:restoredStepIdentifier];
        self.managedResults[restoredStepIdentifier] = nil;
    } else if ([avJournalingTask isAppendStepIdentifier:restoredStepIdentifier]) {
        // If restoring to an appendStep, all the video recordings have been done, resume task normally
        return;
    } else {
        // If restoring to non video step (prepend or face detection), start task from scratch)
        [self.managedStepIdentifiers removeAllObjects];
        [self.managedResults removeAllObjects];
        self.restoredStepIdentifier = nil;
        return;
    }
    
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
        faceDetectionStep.title = ORKLocalizedString(@"AV_JOURNALING_PREDEFINED_TASK_FACE_DETECTION_STEP_TITLE", nil);
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
    NSMutableArray *filteredStepResults = [NSMutableArray new];
    for (ORKStepResult *stepResult in taskResult.results) {
        NSString *stepIdentifier = stepResult.identifier;
        if (!([stepIdentifier isEqualToString:ORKAVJournalingStepIdentifierFinishLaterCompletion] ||
              [stepIdentifier isEqualToString:ORKAVJournalingStepIdentifierMaxLimitHitCompletion] ||
              [stepIdentifier isEqualToString:ORKAVJournalingStepIdentifierFinishLaterFaceDetection] ||
              [stepIdentifier isEqualToString:ORKAVJournalingStepIdentifierVideoAudioAccessDeniedCompletion])) {
            [filteredStepResults addObject:stepResult];
        }
    }
    taskResult.results = [filteredStepResults copy];
    return taskResult;
}

- (void)stepViewControllerWillAppear:(ORKStepViewController *)stepViewController {
    ORKAVJournalingPredefinedTask *avJournalingTask = (ORKAVJournalingPredefinedTask *)self.task;
    if ([avJournalingTask isVideoRecordingStepIdentifier:stepViewController.step.identifier]) {
        stepViewController.cancelButtonItem = nil;
    }
}

@end
