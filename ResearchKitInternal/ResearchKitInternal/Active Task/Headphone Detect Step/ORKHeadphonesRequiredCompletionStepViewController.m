/*
 Copyright (c) 2021, Apple Inc. All rights reserved.
 
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

#import "ORKHeadphonesRequiredCompletionStepViewController.h"
#import "ORKHeadphonesRequiredCompletionStep.h"

#import "ORKIUtils.h"

#import <ResearchKit/ORKHelpers_Internal.h>
#import <ResearchKitUI/ORKInstructionStepContainerView.h>
#import <ResearchKitUI/ORKInstructionStepViewController_Internal.h>
#import <ResearchKitUI/ORKNavigationContainerView_Internal.h>
#import <ResearchKitUI/ORKStepViewController_Internal.h>

struct ORKHeadphonesRequiredViewModel {
    NSString *continueButtonTitle;
    NSString *skipButtonTitle;
};

@implementation ORKHeadphonesRequiredCompletionStepViewController {
    struct ORKHeadphonesRequiredViewModel viewModel;
}

- (ORKHeadphonesRequiredCompletionStep *)headphonesRequiredCompletionStep {
    
    if ([self.step isKindOfClass:[ORKHeadphonesRequiredCompletionStep class]]) {
        
        return (ORKHeadphonesRequiredCompletionStep *)self.step;
    }
    
    return nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.stepView.navigationFooterView.optional = YES;
}

- (void)setSkipButtonItem:(UIBarButtonItem *)skipButtonItem {
    [skipButtonItem setTitle:viewModel.skipButtonTitle];
    skipButtonItem.target = self;
    skipButtonItem.action = @selector(skipTaskAction);
    
    [super setSkipButtonItem:skipButtonItem];
}

- (void)setContinueButtonItem:(UIBarButtonItem *)continueButtonItem {
    [continueButtonItem setTitle:viewModel.continueButtonTitle];
    continueButtonItem.target = self;
    continueButtonItem.action = @selector(finishTaskLaterAction);
    
     [super setContinueButtonItem:continueButtonItem];
}

- (void)finishTaskLaterAction {
    ORKStrongTypeOf(self.taskViewController.delegate) strongDelegate = self.taskViewController.delegate;
    if ([strongDelegate respondsToSelector:@selector(taskViewController:didFinishWithReason:error:)]) {
        [strongDelegate taskViewController:self.taskViewController didFinishWithReason:ORKTaskFinishReasonDiscarded error:nil];
    }
}

- (void)skipTaskAction {
    ORKStrongTypeOf(self.taskViewController.delegate) strongDelegate = self.taskViewController.delegate;
    if ([strongDelegate respondsToSelector:@selector(taskViewController:didFinishWithReason:error:)]) {
        [strongDelegate taskViewController:self.taskViewController didFinishWithReason:ORKTaskFinishReasonCompleted error:nil];
    }
}

- (void)stepDidChange {
    [super stepDidChange];

    switch ([[self headphonesRequiredCompletionStep] requiredHeadphoneTypes]) {
        case ORKHeadphoneTypesAny:
            viewModel.continueButtonTitle = ORKILocalizedString(@"BUTTON_DONE", nil);
            break;
        case ORKHeadphoneTypesSupported:
            viewModel.continueButtonTitle = ORKILocalizedString(@"dBHL_NO_COMPATIBLE_HEADPHONES_COMPLETION_DO_LATER", nil);
            viewModel.skipButtonTitle = ORKILocalizedString(@"dBHL_NO_COMPATIBLE_HEADPHONES_COMPLETION_SKIP", nil);
            break;
    }
}

- (BOOL)hasPreviousStep {
    return YES;
}

@end
