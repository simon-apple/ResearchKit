/*
 Copyright (c) 2023, Apple Inc. All rights reserved.
 
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

#import <ResearchKitUI/ResearchKitUI.h>
#import <ResearchKitUI/ORKStepViewController.h>

@class ORKSensitiveURLLearnMoreInstructionStep;

NS_ASSUME_NONNULL_BEGIN

@protocol AAPLTaskViewControllerDelegate <NSObject>

- (void)taskViewController:(ORKTaskViewController *)taskViewController sensitiveURLLearnMoreButtonPressedWithStep:(ORKSensitiveURLLearnMoreInstructionStep *)sensitiveURLLearnMoreStep forStepViewController:(ORKStepViewController *)stepViewController;

@end


@interface AAPLTaskViewController : ORKTaskViewController

/**
 Locks the device volume to a specific value. Will ignore a new locked value if the method was called before.
 */
- (void)lockDeviceVolume:(float)volume;

// Save the current system volume for restoration after the task end
- (void)saveVolume;

// will return YES if the sensitive URL step is shown
- (BOOL)showSensitiveURLLearMoreStepViewControllerForStep:(ORKActiveStep *)step;

/**
 Forces the task to finish with the specified reason and error.

 Call this method to force task completion, override this method to perform specific actions to wrap up your task.

 @param reason          The reason tbe task is finished.
 @param error            An error associated with the finish reason of the task, or nil if no error is provided.
 */
- (void)finishWithReason:(ORKTaskFinishReason)reason error:(nullable NSError *)error;

@property (nonatomic, weak, nullable) id<AAPLTaskViewControllerDelegate> aaplDelegate;

@end

NS_ASSUME_NONNULL_END
