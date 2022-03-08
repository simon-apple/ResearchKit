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

#if RK_APPLE_INTERNAL

#import "AVAudioMixerNode+Fade.h"

@implementation AVAudioMixerNode (Fade)

- (void)fadeSampleUsingDelta:(float)delta interval:(NSTimeInterval)interval completion:(void (^ __nullable)(void))completion {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(interval * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        float newOutputVolume = self.outputVolume + delta;
        if ((delta >= 0.0 && newOutputVolume >= 1.0) || (delta < 0.0 && newOutputVolume <= 0.0)) {
            newOutputVolume = (delta >= 0.0) ? 1.0 : 0.0;
            if (completion) {
                completion();
            }
        }
        self.outputVolume = newOutputVolume;
        
        if ((delta >= 0.0 && newOutputVolume < 1.0) || (delta < 0.0 && newOutputVolume > 0.0)) {
            [self fadeSampleUsingDelta:delta interval:interval completion:completion];
        }
    });
}

- (void)fadeInWithDuration:(NSTimeInterval)duration stepInterval:(NSTimeInterval)interval completion:(void (^ __nullable)(void))completion {
    float volumeOffset = (float)(interval / duration);
    [self fadeSampleUsingDelta:volumeOffset interval:interval completion:completion];
}

- (void)fadeOutWithDuration:(NSTimeInterval)duration stepInterval:(NSTimeInterval)interval completion:(void (^ __nullable)(void))completion {
    float volumeOffset = (float)(interval / duration);
    [self fadeSampleUsingDelta:-volumeOffset interval:interval completion:completion];
}

@end

#endif
