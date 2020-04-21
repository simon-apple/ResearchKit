/*
 Copyright (c) 2019, Apple Inc. All rights reserved.
 
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

#import "ORKHeadphoneDetector.h"
#import "ORKHelpers_Internal.h"

#import "ORKCelestialSoftLink.h"
#import "ORKAVFoundationSoftLink.h"

static const NSTimeInterval ORKBTListeningModeCheckInterval = 0.1;
static const double LOW_BATTERY_LEVEL_THRESHOLD_VALUE = 0.1;

@interface ORKHeadphoneDetector ()

@property (nonatomic, readwrite, nullable) NSSet<NSString *> *supportedHeadphoneChipsetTypes;

@end

@implementation ORKHeadphoneDetector {
    NSString                            *_lastDetectedDevice;
    NSTimer                             *_btListeningModeCheckTimer;
    BOOL                                _avFoundationSPIOk;
    BOOL                                _celestialSPIOk;
}

- (instancetype)initWithDelegate:(id<ORKHeadphoneDetectorDelegate>)delegate
  supportedHeadphoneChipsetTypes:(NSSet<ORKHeadphoneChipsetIdentifier> *)supportedHeadphoneChipsetTypes {
    self = [super init];
    if (self) {
        _lastDetectedDevice = nil;
        _avFoundationSPIOk = [self checkAVFoundationSPI];
        _celestialSPIOk = [self checkCelestial];
        self.delegate = delegate;
        self.supportedHeadphoneChipsetTypes = supportedHeadphoneChipsetTypes;
        
        [self registerNotifications];
        [self updateHeadphoneState];
        
        [self startBTListeningModeCheckTimer];
    }
    return self;
}

- (void)stopBTListeningModeCheckTimer {
    [_btListeningModeCheckTimer invalidate];
    _btListeningModeCheckTimer = nil;
}

- (void)startBTListeningModeCheckTimer {
    if (_avFoundationSPIOk) {
        _btListeningModeCheckTimer = [NSTimer scheduledTimerWithTimeInterval: ORKBTListeningModeCheckInterval
                                                                      target: self
                                                                    selector: @selector(checkTick:)
                                                                    userInfo: nil repeats:YES];
    }
}

- (void)dealloc {
    _lastDetectedDevice = nil;
    [self stopBTListeningModeCheckTimer];
    [self removeObservers];
}

-(void)appWillResignActive:(NSNotification*)note {
    [self stopBTListeningModeCheckTimer];
}

-(void)appDidBecomeActive:(NSNotification*)note {
    [self startBTListeningModeCheckTimer];
}

-(void)appWillTerminate:(NSNotification*)note {
    [self stopBTListeningModeCheckTimer];
    [self removeObservers];
}

#pragma mark - Headphone Monitoring

- (void)registerNotifications {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(headphoneStateChangedNotification:) name:@"AVSystemController_HeadphoneJackIsConnectedDidChangeNotification" object:nil];
    [center addObserver:self selector:@selector(headphoneStateChangedNotification:) name:@"AVAudioSessionRouteChangeNotification" object:nil];
    [center addObserver:self selector:@selector(headphoneStateChangedNotification:) name:@"AVSystemController_ActiveAudioRouteDidChangeNotification" object:nil];
    [center addObserver:self selector:@selector(mediaServerDied) name:@"AVSystemController_ServerConnectionDiedNotification" object:nil];
    
    [center addObserver:self selector:@selector(appWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
    [center addObserver:self selector:@selector(appWillTerminate:) name:UIApplicationWillTerminateNotification object:nil];
    [center addObserver:self selector:@selector(appDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)mediaServerDied {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self performSelector:@selector(registerNotifications) withObject:nil afterDelay:2.0];
    [self headphoneStateChangedNotification:nil];
}

- (void)headphoneStateChangedNotification:(NSNotification *)note {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_global_queue(QOS_CLASS_DEFAULT, 0), ^{
        [self updateHeadphoneState];
    });
}

- (void)removeObservers {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center removeObserver:self name:@"AVSystemController_HeadphoneJackIsConnectedDidChangeNotification" object:nil];
    [center removeObserver:self name:@"AVAudioSessionRouteChangeNotification" object:nil];
    [center removeObserver:self name:@"AVSystemController_ActiveAudioRouteDidChangeNotification" object:nil];
    [center removeObserver:self name:@"AVSystemController_ServerConnectionDiedNotification" object:nil];
    
    [center removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
    [center removeObserver:self name:UIApplicationWillTerminateNotification object:nil];
    [center removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
}

#pragma mark - SPI Checking

- (BOOL)checkAVFoundationSPI {
    return (getAVOutputDeviceClass() != nil &&
            getAVOutputContextClass() != nil);
}

- (BOOL)checkCelestial {
    id avSystemControllerClass = getAVSystemControllerClass();
    BOOL controllerOk = YES;
    if ([avSystemControllerClass respondsToSelector:@selector(sharedAVSystemController)]) {
        id avSystemControllerObject = [avSystemControllerClass sharedAVSystemController];
        if (![avSystemControllerObject respondsToSelector:@selector(attributeForKey:)]) {
            controllerOk = NO;
        }
    } else {
        controllerOk = NO;
    }
    BOOL routesAttributeOK = [getAVSystemController_PickableRoutesAttribute() isKindOfClass:[NSString class]];
    BOOL routeCurrentlyPickedOk = [getAVSystemController_RouteDescriptionKey_RouteCurrentlyPicked() isKindOfClass:[NSString class]];
    BOOL routeDescriptionKeyOk = [getAVSystemController_RouteDescriptionKey_RouteSubtype() isKindOfClass:[NSString class]];

    return controllerOk && routesAttributeOK && routeCurrentlyPickedOk && routeDescriptionKeyOk;
}

- (ORKHeadphoneTypeIdentifier)getCurrentBTHeadphoneType {
    if (_avFoundationSPIOk) {
        BOOL wirelessSplitterHasMoreThenOneDevice = ([[getAVOutputContextClass() sharedSystemAudioContext] outputDevices].count > 1);
        NSString* modelId = [[[getAVOutputContextClass() sharedSystemAudioContext] outputDevice] modelID];
        if (modelId != nil && !wirelessSplitterHasMoreThenOneDevice) {
            if ([modelId containsString:ORKHeadphoneVendorAndProductIdIdentifierAirPodsGen1]) {
                return ORKHeadphoneTypeIdentifierAirPodsGen1;
            }
            if ([modelId containsString:ORKHeadphoneVendorAndProductIdIdentifierAirPodsGen2]) {
                return ORKHeadphoneTypeIdentifierAirPodsGen2;
            }
            if ([modelId containsString:ORKHeadphoneVendorAndProductIdIdentifierAirPodsPro]) {
                return ORKHeadphoneTypeIdentifierAirPodsPro;
            }
        }
    }
    return nil;
}

- (BOOL)checkLowBatteryLevelForPods {
    if (_avFoundationSPIOk) {
        BOOL wirelessSplitterHasMoreThenOneDevice = ([[getAVOutputContextClass() sharedSystemAudioContext] outputDevices].count > 1);
        NSDictionary *modelSpecificInformation = [[[getAVOutputContextClass() sharedSystemAudioContext] outputDevice] modelSpecificInformation];
        if ([modelSpecificInformation objectForKey:getAVOutputDeviceBatteryLevelLeftKey()] != nil &&
            [modelSpecificInformation objectForKey:getAVOutputDeviceBatteryLevelRightKey()] != nil &&
            !wirelessSplitterHasMoreThenOneDevice) {
            double leftValue = [[modelSpecificInformation objectForKey:getAVOutputDeviceBatteryLevelLeftKey()] doubleValue];
            double rightValue = [[modelSpecificInformation objectForKey:getAVOutputDeviceBatteryLevelRightKey()] doubleValue];
            return (leftValue < LOW_BATTERY_LEVEL_THRESHOLD_VALUE || rightValue < LOW_BATTERY_LEVEL_THRESHOLD_VALUE);
        }
    }
    return NO;
}

- (BOOL)isRouteSupported
{
    __block BOOL routeSupported = NO;
    
    if (_celestialSPIOk)
    {
        NSArray *routesAttributes = [[getAVSystemControllerClass() sharedAVSystemController] attributeForKey:getAVSystemController_PickableRoutesAttribute()];
        
        if (routesAttributes != nil)
        {
            [routesAttributes enumerateObjectsUsingBlock:^(NSDictionary *route, NSUInteger idx, BOOL *stop)
            {
                if ([[route valueForKey:getAVSystemController_RouteDescriptionKey_RouteCurrentlyPicked()] boolValue])
                {
                    NSSet *supportedRoutes = [self supportedHeadphoneChipsetTypesForRoute:route];
                    
                    if (supportedRoutes.count > 0)
                    {
                        ORKHeadphoneTypeIdentifier btHeadphoneType = [self getCurrentBTHeadphoneType];
                        if (btHeadphoneType == nil)
                        {
                            NSSet *lightningSet = [NSSet setWithObject:ORKHeadphoneChipsetIdentifierLightningEarPods];
                            NSSet *audioJackSet = [NSSet setWithObject:ORKHeadphoneChipsetIdentifierAudioJackEarPods];

                            BOOL isWiredPod = [lightningSet isSubsetOfSet:supportedRoutes] || [audioJackSet isSubsetOfSet:supportedRoutes];
                            
                            if (isWiredPod)
                            {
                                routeSupported = YES;
                                _lastDetectedDevice = ORKHeadphoneTypeIdentifierEarPods;
                            }
                        }
                        else
                        {
                            routeSupported = YES;
                            _lastDetectedDevice = btHeadphoneType;
                        }
                    }
                    else if ([[route objectForKey:getAVSystemController_RouteDescriptionKey_AVAudioRouteName()] isEqualToString:@"Speaker"])
                    {
                        routeSupported = NO;
                        _lastDetectedDevice = nil;
                    }
                    else
                    {
                        routeSupported = _supportedHeadphoneChipsetTypes == nil;
                        _lastDetectedDevice = ORKHeadphoneTypeIdentifierUnknown;
                    }
                    *stop = YES;
                }
            }];
        }
    }
    
    return routeSupported;
}

- (NSSet *)supportedHeadphoneChipsetTypesForRoute:(NSDictionary *)route
{
    NSString *subtype = [route valueForKey:getAVSystemController_RouteDescriptionKey_RouteSubtype()];
    
    NSSet *supportedChipsetTypes = _supportedHeadphoneChipsetTypes;
    
    // If we are supporting any type of headphones, we can still try to classify them!
    if (_supportedHeadphoneChipsetTypes == nil)
    {
        supportedChipsetTypes = [NSSet setWithArray:@[ORKHeadphoneChipsetIdentifierLightningEarPods,
                                                      ORKHeadphoneChipsetIdentifierAudioJackEarPods,
                                                      ORKHeadphoneChipsetIdentifierAirPods]];
    }
    
    NSSet *supportedRoutes = [supportedChipsetTypes objectsPassingTest:^BOOL(NSString * _Nonnull obj, BOOL * _Nonnull routesStop) {
        return [subtype containsString:obj];
    }];
    
    return supportedRoutes;
}

- (void)updateHeadphoneState {
    BOOL routeIsSupported = ([self isRouteSupported] && _lastDetectedDevice != nil);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        ORKStrongTypeOf(self.delegate) strongDelegate = self.delegate;
        if (strongDelegate &&
            [strongDelegate respondsToSelector:@selector(headphoneTypeDetected: isSupported:)]) {
            [strongDelegate headphoneTypeDetected:_lastDetectedDevice isSupported:routeIsSupported];
        }
    });
}

- (void)checkTick:(NSNotification *)notification {
    ORKStrongTypeOf(self.delegate) strongDelegate = self.delegate;
    if ([self checkLowBatteryLevelForPods]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (strongDelegate &&
                [strongDelegate respondsToSelector:@selector(podLowBatteryLevelDetected)]) {
                [strongDelegate podLowBatteryLevelDetected];
            }
        });
    }
    if (@available(iOS 13.0, *)) {
        if ([self getCurrentBTHeadphoneType] == ORKHeadphoneTypeIdentifierAirPodsPro &&
            _lastDetectedDevice == ORKHeadphoneTypeIdentifierAirPodsPro &&
            strongDelegate && [strongDelegate respondsToSelector:@selector(bluetoothModeChanged:)]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSString* listeningMode = [[[getAVOutputContextClass() sharedSystemAudioContext] outputDevice] currentBluetoothListeningMode];
                ORKBluetoothMode btMode = ORKBluetoothModeNone;
                if (listeningMode != nil) {
                    if ([listeningMode isEqualToString:getAVOutputDeviceBluetoothListeningModeNormal()]) {
                        btMode = ORKBluetoothModeNormal;
                    } else if ([listeningMode isEqualToString:getAVOutputDeviceBluetoothListeningModeAudioTransparency()]) {
                        btMode = ORKBluetoothModeTransparency;
                    } else if ([listeningMode isEqualToString:getAVOutputDeviceBluetoothListeningModeActiveNoiseCancellation()]) {
                        btMode = ORKBluetoothModeNoiseCancellation;
                    }
                }
                [strongDelegate bluetoothModeChanged:btMode];
            });
        }
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (strongDelegate &&
                [strongDelegate respondsToSelector:@selector(bluetoothModeChanged:)]) {
                [strongDelegate bluetoothModeChanged:ORKBluetoothModeNoiseCancellation];
            }
        });
    }
}

@end
