//
/*
 Copyright (c) 2022, Apple Inc. All rights reserved.
 
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

#ifndef ORKUILeaks_h
#define ORKUILeaks_h

@import Foundation;

// TODO: rdar://98200174 (rename and re-home these definitions)

/*
 The definitions in this file were associated with the UI classes, but are needed by the core classes as well.
 They should probably be renamed to something more appropriate and then moved to their appropriate location.
 */

typedef NS_ENUM(NSInteger, ORKRequestPermissionsButtonState) {
    ORKRequestPermissionsButtonStateDefault = 0,
    ORKRequestPermissionsButtonStateConnected,
    ORKRequestPermissionsButtonStateNotSupported,
    ORKRequestPermissionsButtonStateError,
};

/**
 The `ORKTaskViewControllerFinishReason` value indicates how the task view controller has finished
 the task.
 */
typedef NS_ENUM(NSInteger, ORKTaskViewControllerFinishReason) {
    
    /// The task was canceled by the participant or the developer, and the participant asked to save the current result.
    ORKTaskViewControllerFinishReasonSaved,
    
    /// The task was canceled by the participant or the developer, and the participant asked to discard the current result.
    ORKTaskViewControllerFinishReasonDiscarded,
    
    /// The task has completed successfully, because all steps have been completed.
    ORKTaskViewControllerFinishReasonCompleted,
    
    /// An error was detected during the current step.
    ORKTaskViewControllerFinishReasonFailed,
    
    /// Interntional early termination of a task
    ORKTaskViewControllerFinishReasonEarlyTermination
};

#endif /* ORKUILeaks_h */
