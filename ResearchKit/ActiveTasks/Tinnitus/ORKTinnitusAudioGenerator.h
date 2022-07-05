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

#if RK_APPLE_INTERNAL

@import UIKit;
@import AVFoundation;
#import <ResearchKit/ORKTypes.h>
#import "ORKTinnitusTypes.h"
#import "ORKContext.h"

NS_ASSUME_NONNULL_BEGIN

@class ORKTinnitusHeadphoneTable;

/**
 The `ORKTinnitusAudioGenerator` class represents an audio tone generator or white noise generator.
 The `type` will define what type of sound will be generated.
 */
ORK_CLASS_AVAILABLE
@interface ORKTinnitusAudioGenerator : NSObject

@property (readonly) NSTimeInterval fadeDuration;
@property (readonly, getter=isPlaying) BOOL playing;
@property (nonatomic, strong) ORKTinnitusHeadphoneTable *headphoneTable;

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithHeadphoneType:(ORKHeadphoneTypeIdentifier)headphoneType;
- (instancetype)initWithHeadphoneType:(ORKHeadphoneTypeIdentifier)headphoneType fadeDuration:(NSTimeInterval)fadeDuration;

/**
 Plays a tone at a specific frequency in stereo. Only works if instantiated with pure tone kind.
 
 The sound is a "pure" sinusoid tone.

 @param frequency The audio frequency in hertz.
 */
- (void)playSoundAtFrequency:(double)frequency;

/**
Plays a white noise audio. Only works if instantiated with white noise kind.
*/
- (void)playWhiteNoise;

/**
 Stops the audio being played.
 */
- (void)stop;

/**
 Returns the peak audio volume being currently played, in decibels (dB).

 @return The current audio volume in decibels.
 */
- (double)volumeInDecibels;

/**
 Returns the peak audio volume amplitude being currently played (from 0 to 1).

 @return The current audio volume amplitude.
 */
- (double)volumeAmplitude;

/**
Returns the system audio volume.

@return The current system audio volume amplitude between 0.0 and 1.0
*/
- (float)getCurrentSystemVolume;

/**
Returns the system audio volume in decibels.

@return The current system audio volume amplitude in decibels.
*/
- (float)getCurrentSystemVolumeInDecibels;

/**
 Returns the system volume in decibels adjusted with dbSPL table for puretone sounds.
 
 @return the current volume with the frequency and dbSPL table applied
 */
- (float)getPuretoneSystemVolumeIndBSPL;

/**
 Adjusts the maximum audio buffer amplitude (the default amplitude value is 0.03). This value will be clamped between 0.0 and 1.0
 */
- (void)adjustBufferAmplitude:(double)newAmplitude;

@end

NS_ASSUME_NONNULL_END

#endif
