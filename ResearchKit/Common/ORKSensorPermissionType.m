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

#import <SensorKit/SensorKit.h>

#import "ORKSensorPermissionType.h"
#import "ORKRequestPermissionView.h"
#import "ORKHelpers_Internal.h"

@interface ORKSensorPermissionType ()

@property NSSet<SRSensor> *sensors;

@end

@implementation ORKSensorPermissionType {
    NSSet<SRSensorReader *> *_readers;
}

+ (instancetype)new {
    ORKThrowMethodUnavailableException();
}

- (instancetype)init {
    ORKThrowMethodUnavailableException();
}

- (instancetype)initWithSensors:(nonnull NSSet<SRSensor> *)sensors {
    NSAssert(sensors.count != 0, @"Sensors set must not be empty!");
    self = [super init];
    if (self) {
        self.sensors = sensors;
        NSMutableSet *readers = [[NSMutableSet alloc] init];
        for (SRSensor sensor in sensors) {
            SRSensorReader *reader = [[SRSensorReader alloc] initWithSensor:sensor];
            [readers addObject:reader];
        }
        _readers = [readers copy];
        [self setupCardView];
    }
    return self;
}

- (void)setupCardView {
    UIImage *image = [UIImage systemImageNamed:@"gauge"];

    self.cardView = [[ORKRequestPermissionView alloc] initWithIconImage:image
                                                                  title:ORKLocalizedString(@"REQUEST_SENSOR_STEP_VIEW_TITLE", nil)
                                                             detailText:ORKLocalizedString(@"REQUEST_SENSOR_STEP_VIEW_DESCRIPTION", nil)];

    [self.cardView.requestPermissionButton setTitle:ORKLocalizedString(@"REQUEST_PERMISSION_BUTTON_STATE_DEFAULT", nil) forState:UIControlStateNormal];
    [self.cardView.requestPermissionButton setTitle:ORKLocalizedString(@"REQUEST_PERMISSION_BUTTON_STATE_CONNECTED", nil) forState:UIControlStateDisabled];
    [self.cardView.requestPermissionButton addTarget:self action:@selector(requestPermissionButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.cardView updateIconTintColor:[UIColor systemGreenColor]];

    [self setRequestPermissionRequested:[self hasRequestedAllSensors]];
}

- (BOOL)hasRequestedAllSensors {
    for (SRSensorReader *reader in _readers) {
        if (reader.authorizationStatus == SRAuthorizationStatusNotDetermined) {
            return NO;
        }
    }
    return YES;
}

- (void)requestPermissionButtonPressed {
    [SRSensorReader requestAuthorizationForSensors:self.sensors completion:^(NSError * _Nullable error) {
        if (error) {
            ORK_Log_Error("Error requesting sensor permissions: %@", error);
            return;
        }
        [self setRequestPermissionRequested:YES];
    }];
}

- (void)setRequestPermissionRequested:(BOOL)state {
    [self.cardView setEnableContinueButton:state];
    [self.cardView.requestPermissionButton setEnabled:!state];
    [self.cardView.requestPermissionButton setBackgroundColor: state ? [UIColor grayColor] : [UIColor systemBlueColor]];
}

@end
