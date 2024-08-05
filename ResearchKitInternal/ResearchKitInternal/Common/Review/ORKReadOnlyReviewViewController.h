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

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, ORKReadOnlyStepType) {
    /**
     Will parse and display the results of all ORKFormSteps within 
     the provided task.
     */
    ORKReadOnlyStepTypeFormStep,
    
    /**
     Will parse and display the results of all ORKFormSteps and
     ORKQuestionSteps within the provided task.
     */
    ORKReadOnlyStepTypeSurveyStep,
    
    /**
     Will parse and display the results of all ORKFamilyHistorySteps
     within the provided task.
     */
    ORKReadOnlyStepTypeFamilyHistoryStep
} ORK_ENUM_AVAILABLE;

@class ORKOrderedTask;
@class ORKTaskResult;

/**
 A view controller that presents results for specific ResearchKit steps.
 */

@interface ORKReadOnlyReviewViewController : UIViewController

- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_UNAVAILABLE;
- (instancetype)initWithFrame:(CGRect)frame NS_UNAVAILABLE;

/**
 Returns a new ORKReadOnlyReviewViewController with the provided task
 and result.
 
 @param task    The ORKTask that should contain the targeted steps.
 @param result    The ORKTaskResult generated from the provided ``task``.
 @param readOnlyStepType    Enum specifying the type of step to extract results from.
 @param title    The primary text to display for the step.
 @param detailText    The detail text displayed below the content of the ``text`` property.
 @param navTitle    The text displayed via the navigationItem's title.
 */
- (instancetype)initWithTask:(ORKOrderedTask *)task
                      result:(ORKTaskResult *)result
            readOnlyStepType:(ORKReadOnlyStepType)readOnlyStepType
                       title:(nullable NSString *)title
                  detailText:(nullable NSString *)detailText
                    navTitle:(nullable NSString *)navTitle NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
