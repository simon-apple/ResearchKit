/*
 Copyright (c) 2015, Apple Inc. All rights reserved.
 
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


#import <ResearchKit/ORKTaskViewController.h>

NS_ASSUME_NONNULL_BEGIN

ORK_EXTERN NSString * const ORKdBHLHeadphonesInEarsNotification;
ORK_EXTERN NSString * const ORKdBHLBluetoothSealValueChangedNotification;

#define APPLE_B698_PRODUCTID                8212
#define APPLE_B698C_PRODUCTID               8228
#define CHAND_FFANC_FWVERSION               @"5E102"
#define CELLO_FWVERSION                     @"6A" // CVTODO: change this to point to the final firmware version
#define LOW_BATTERY_LEVEL_THRESHOLD_VALUE   0.20

typedef NS_ENUM(NSUInteger, ORKdBHLHeadphonesStatus) {
    ORKdBHLHeadphonesStatusNotInEars,
    ORKdBHLHeadphonesStatusInEars,
    ORKdBHLHeadphonesStatusWrongDevice,
    ORKdBHLHeadphonesStatusWrongFirmware,
    ORKdBHLHeadphonesStatusEnablingHearingTest,
    ORKdBHLHeadphonesStatusHearingTestEnabled,
    ORKdBHLHeadphonesStatusHearingTestDisabled
};

@class BluetoothDevice;
@interface ORKTaskViewController (ORKActiveTaskSupport)

@property (nonatomic, readonly) BOOL headphonesInEars;
@property (nonatomic, readonly) BOOL callActive;
@property (nonatomic, readonly) ORKdBHLHeadphonesStatus hearingModeStatus;
@property (nonatomic, readonly) BluetoothDevice *currentDevice;
@property (nonatomic, strong, readonly) NSString *caseSerial;
@property (nonatomic, strong, readonly) NSString *leftHeadphoneSerial;
@property (nonatomic, strong, readonly) NSString *rightHeadphoneSerial;
@property (nonatomic, strong, readonly) NSString *fwVersion;
@property (nonatomic, readonly) double leftBattery;
@property (nonatomic, readonly) double rightBattery;

// This method is necessary because the QRCodeReader was removing the bluetooth manager observers
- (void)removeAndAddObservers;

/**
 Suspends the task.
 
 Call this method to suspend an active step. To resume later, call
 `resume`. Not all active steps will respond to `suspend` / `resume`, so test
 thoroughly to verify correct behavior in your tasks.
 
 This method will disable any background audio prompt session, and suspend
 any active step in progress.
 */
- (void)suspend;

/**
 Resumes any current active step.
 
 Call this method to force resuming an active step may call this
 method. Should be paired with a call to `suspend`.
 
 This method re-enables background audio prompts, if needed, and resumes
 any active step. If not in an active step, it has no effect.
 
 See also: `suspend`
 */
- (void)resume;


/**
 Creates a default step view controller suitable for presenting the passed step,
 and, if applicable, prefills its results using the `defaultResultSource`.
 */
- (ORKStepViewController *)viewControllerForStep:(ORKStep *)step;
#if RK_APPLE_INTERNAL
/**
 Locks the device volume to a specific value. Will ignore a new locked value if the method was called before.
 */
- (void)lockDeviceVolume:(float)volume;

/**
 Enables the HearingTestMode on AirPods, returns false if something went wrong
 */
- (void)enableHearingTestModeWithCompletion:(void(^)(BOOL hearingModeEnabled))handler;

- (void)disableHearingTestMode;

/**
 Plays a tone using the HearingTest framework tone player, returns an error if the play fails
 */
- (void)playWithFrequency:(double)frequency level:(double)level channel:(ORKAudioChannel)channel completion:(void(^)(NSError * _Nonnull error))completion;

/**
 Stops the tone using being played by the tone player of the HearingTest framework.
 */
- (void)stopAudio;
#endif
- (void)stepViewController:(ORKStepViewController *)stepViewController didFinishWithNavigationDirection:(ORKStepViewControllerNavigationDirection)direction
                  animated:(BOOL)animated;

/**
 Forces navigation to the step with the specified identifier.
 
 Call this method to force navigation to the specified step. Any skipped steps are not part of the navigation stack,
 so going back will go back to the step that was current when this method was called. Any skipped steps will not be part
 of the task result either.
 */
- (void)goToStepWithIdentifier:(NSString *)identifier;

@end

NS_ASSUME_NONNULL_END
