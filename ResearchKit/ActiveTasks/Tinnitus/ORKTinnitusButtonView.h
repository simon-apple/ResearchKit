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

#if APPLE_INTERNAL

@import UIKit;
#import <ResearchKit/ResearchKit.h>

typedef void (^ORKTinnitusButtonFinishedLayoutBlock)(void);

@class ORKTinnitusButtonView;

@protocol ORKTinnitusButtonViewDelegate <NSObject>

@required
- (void)tinnitusButtonViewPressed:(ORKTinnitusButtonView *_Nonnull)tinnitusButtonView;

@end

NS_ASSUME_NONNULL_BEGIN

ORK_CLASS_AVAILABLE
@interface ORKTinnitusButtonView : UIView

@property (nonatomic, weak, nullable)id<ORKTinnitusButtonViewDelegate> delegate;

@property (nonatomic, copy) ORKTinnitusButtonFinishedLayoutBlock didFinishLayoutBlock;

@property (readonly) BOOL isSelected;
@property (readonly) BOOL isShowingPause;

/**
 Indicates if that button was tapped at least once
 */
@property (readonly) BOOL playedOnce;

/**
 If not enabled: user interaction disabled and alpha = 0.5.
 */
@property (getter = isEnabled, readonly) BOOL enabled;

@property (nonatomic, copy, nullable) id answer;

@property (getter = isSimulatedTap, readonly) BOOL simulatedTap;

- (instancetype _Nonnull )initWithTitle:(nonnull NSString *)title detail:(nullable NSString *)detail answer:(nullable id)answer;
- (instancetype _Nonnull )initWithTitle:(nonnull NSString *)title detail:(nullable NSString *)detail;

/**
 Restores the button to unselected state (gray color, and play button image)
 */
- (void)restoreButton;

/**
 Restores the button and sets played once to NO).
 */
- (void)resetButton;

- (void)togglePlayButton;

- (void)setSelected:(BOOL)isSelected;

- (BOOL)buttonFinishedAutoLayout;

- (void)simulateTap;

- (void)enableAccessibilityAnnouncements:(BOOL)shouldAnnouce;

@end

@interface ORKTinnitusButtonView(NSArrayUtils)
- (void)setEnabledWithNSNumber:(NSNumber *)boolNum;
@end

NS_ASSUME_NONNULL_END

#endif
