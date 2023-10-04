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
@import Foundation;

NS_ASSUME_NONNULL_BEGIN

/**
 The `ORKSecondaryActionStepNavigationRule` class is the class for secondary action navigation
 rules, for use in a secondary action on an ORKStep
 
 The `SecondaryActionButton`also known as the `Skip` button title will be replaced with `text` provided here
 The `destinationStepIdentifier` will be used to forward the user to that `stepIdentifier` if the button is tapped.
 */
ORK_CLASS_AVAILABLE
@interface ORKSecondaryActionStepNavigationRule : ORKDirectStepNavigationRule <NSCopying, NSSecureCoding>

/**
 Returns the title text for the rule, which will be displayed as the secondary button's text.
 Subclasses must implement this property if they would like to provide a title for the secondary button.
*/
@property(nonatomic, readwrite, copy) NSString* text;

/**
 Returns an initialized secondary action navigation rule using the specified destination step identifier and text.
 
 @param destinationStepIdentifier  The identifier of the destination step.
 @param text  The title text for the rule, which will be displayed as the secondary button's text.

 @return A secondary action navigation rule.
 */
- (instancetype)initWithDestinationStepIdentifier:(NSString *)destinationStepIdentifier
                                             text:(NSString *)text NS_DESIGNATED_INITIALIZER;
/**
 Returns an initialized secondary action navigation rule set for skip mode.
 Meaning the `Skip` button will appear on the step, and tapping will skip to the next question.
 
 @return An initialized secondary action navigation rule set to skip mode.
 */
- (instancetype)init;

/**
 Returns a new ORKSecondaryActionStepNavigationRule initialized from data in a given unarchiver.
 
 @param aDecoder  The coder from which to initialize the step navigation rule.
 
 @return A secondary action navigation rule.
 */
- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_DESIGNATED_INITIALIZER;

- (instancetype)initWithDestinationStepIdentifier:(NSString *)destinationStepIdentifier NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
