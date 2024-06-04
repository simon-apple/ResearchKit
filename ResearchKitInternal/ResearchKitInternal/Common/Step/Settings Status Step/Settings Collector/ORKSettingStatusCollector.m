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

#import "ORKSettingStatusCollector.h"

#import "AudioDataAnalysis_Private.h"
#import "ORKSettingStatusSnapshot.h"
#import "ORKSoftLinking.h"


ORK_SOFT_LINK_FRAMEWORK(PrivateFrameworks, AudioDataAnalysis)

ORK_SOFT_LINK_CLASS(AudioDataAnalysis, ADASManager)

ORK_SOFT_LINK_CONSTANT(AudioDataAnalysis, ADAFPreferenceKeyVolumeLimitEnabled, NSString *)
#define ADAFPreferenceKeyVolumeLimitEnabled getADAFPreferenceKeyVolumeLimitEnabled()

ORK_SOFT_LINK_CONSTANT(AudioDataAnalysis, ADAFPreferenceKeyVolumeLimitThreshold, NSString *)
#define ADAFPreferenceKeyVolumeLimitThreshold getADAFPreferenceKeyVolumeLimitThreshold()

ORK_SOFT_LINK_CONSTANT(AudioDataAnalysis, ADAFPreferenceKeyHAESampleTransient, NSString *)
#define ADAFPreferenceKeyHAESampleTransient getADAFPreferenceKeyHAESampleTransient()

@implementation ORKSettingStatusCollector

- (ORKSettingStatusSnapshot *)getSettingStatusForSettingType:(ORKSettingType)settingType {
    [NSException raise:@"getSettingStatus not overwritten" format:@"Subclasses must overwrite the getSettingStatus function"];
    return nil;
}

@end


@implementation ORKAudioSettingStatusCollector

- (ORKSettingStatusSnapshot *)getSettingStatusForSettingType:(ORKSettingType)settingType {
    ORKSettingStatusSnapshot *settingStatusSnapshot = [ORKSettingStatusSnapshot new];
    
    switch (settingType) {
        case ORKSettingTypeReduceLoudSounds:
            settingStatusSnapshot = [self _getSettingStatusForReduceLoudSounds];
            break;
            
        default:
            [NSException raise:@"Unsupported ORKSettingType" format:@"ORKAudioSettingStatusCollector does not support the provided ORKSettingType"];
            break;
    }
    
    return settingStatusSnapshot;
}

- (ORKSettingStatusSnapshot *)_getSettingStatusForReduceLoudSounds {
    ORKSettingStatusSnapshot *settingStatusSnapshot = [ORKSettingStatusSnapshot new];
    settingStatusSnapshot.isEnabled = [self _isVolumeLimitEnabled];
    return settingStatusSnapshot;
}

- (BOOL)_isVolumeLimitEnabled {
    NSDictionary* domainSettings = [[[[getADASManagerClass() alloc] init] getPreferencesFor:@[
        ADAFPreferenceKeyVolumeLimitEnabled,
        ADAFPreferenceKeyVolumeLimitThreshold
    ]] copy];
    
    if (domainSettings[ADAFPreferenceKeyVolumeLimitEnabled] != nil) {
        return [domainSettings[ADAFPreferenceKeyVolumeLimitEnabled] boolValue];
    } else {
        return NO;
    }
}

@end
