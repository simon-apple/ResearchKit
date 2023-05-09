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

#import "ORKAVFoundationSoftLink.h"
#import "ORKCelestialSoftLink.h"
#import "ORKHeadphoneDetector.h"

#import <ResearchKitInternal/AAPLTypes.h>

#import <MediaPlayer/MediaPlayer.h>
#import <ResearchKit/ORKHelpers_Internal.h>

static const NSTimeInterval ORKBTListeningModeCheckInterval = 0.1;
static const double LOW_BATTERY_LEVEL_THRESHOLD_VALUE = 0.1;

@interface ORKHeadphoneDetector ()

@property (nonatomic, readwrite, nullable) NSSet<NSString *> *supportedHeadphoneChipsetTypes;

@end

@implementation ORKHeadphoneDetector {
    NSString                            *_lastDetectedDevice;
    NSString                            *_vendorID;
    NSString                            *_productID;
    NSInteger                           _deviceSubType;
    NSTimer                             *_btListeningModeCheckTimer;
    dispatch_queue_t                    _tickQueue;
    BOOL                                _avFoundationSPIOk;
    BOOL                                _celestialSPIOk;
    
    NSUInteger                          _wirelessSplitterNumberOfDevices;
    
    AVAudioPlayer                       *_workaroundPlayer;
    NSUInteger                          _workaroundPoolingCounter;
}

+ (NSSet<ORKHeadphoneChipsetIdentifier> *)appleHeadphoneSet {
    return [NSSet setWithArray:@[ORKHeadphoneChipsetIdentifierLightningEarPods,
                                ORKHeadphoneChipsetIdentifierAudioJackEarPods,
                                ORKHeadphoneChipsetIdentifierAirPods]];
}

- (instancetype)initWithDelegate:(id<ORKHeadphoneDetectorDelegate>)delegate
  supportedHeadphoneChipsetTypes:(NSSet<ORKHeadphoneChipsetIdentifier> *)supportedHeadphoneChipsetTypes {
    self = [super init];
    if (self) {
        _lastDetectedDevice = nil;
        _wirelessSplitterNumberOfDevices = 0;
        _avFoundationSPIOk = [self checkAVFoundationSPI];
        _celestialSPIOk = [self checkCelestial];
        self.delegate = delegate;
        self.supportedHeadphoneChipsetTypes = supportedHeadphoneChipsetTypes;
        
        [self registerNotifications];
        [self updateHeadphoneState];
        
        [self startBTListeningModeCheckTimer];
        
        [self initializeSmartRouteWorkaround];
        _workaroundPoolingCounter = 0;
    }
    return self;
}

- (void)initializeSmartRouteWorkaround {
    NSError *error;
    NSURL *path = [[NSBundle bundleForClass:[self class]] URLForResource:@"VolumeCalibration" withExtension:@"wav"];
    _workaroundPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:path
                                                               error:&error];
    if (error != nil) {
        ORK_Log_Error("Error fetching audio: %@", error);
    }
    _workaroundPlayer.numberOfLoops = -1;
    _workaroundPlayer.volume = 0.0;
    [_workaroundPlayer prepareToPlay];
    [_workaroundPlayer play];
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

- (void)discard {
    _lastDetectedDevice = nil;
    _delegate = nil;
    [_workaroundPlayer stop];
    _workaroundPlayer = nil;
    _tickQueue = nil;
    [self stopBTListeningModeCheckTimer];
    [self removeObservers];
}

- (void)dealloc {
    [self discard];
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
    if (@available(iOS 15.0, *)) {
        [[getAVSystemControllerClass() sharedAVSystemController] setAttribute:@[getAVSystemController_HeadphoneJackIsConnectedDidChangeNotification(),
                                                                                getAVSystemController_ActiveAudioRouteDidChangeNotification(),
                                                                                getAVSystemController_ServerConnectionDiedNotification()]
                                                                       forKey:getAVSystemController_SubscribeToNotificationsAttribute() error:nil];
    }
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(headphoneStateChangedNotification:) name:AVAudioSessionRouteChangeNotification object:nil];
    [center addObserver:self selector:@selector(headphoneStateChangedNotification:) name:getAVSystemController_HeadphoneJackIsConnectedDidChangeNotification() object:nil];
    [center addObserver:self selector:@selector(headphoneStateChangedNotification:) name:getAVSystemController_ActiveAudioRouteDidChangeNotification() object:nil];
    [center addObserver:self selector:@selector(mediaServerDied) name:getAVSystemController_ServerConnectionDiedNotification() object:nil];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    });
    
    [[[MPRemoteCommandCenter sharedCommandCenter] pauseCommand] addTarget:self action:@selector(pauseDetected:)];
    [[[MPRemoteCommandCenter sharedCommandCenter] playCommand] addTarget:self action:@selector(playDetected:)];
    
    [center addObserver:self selector:@selector(appWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
    [center addObserver:self selector:@selector(appWillTerminate:) name:UIApplicationWillTerminateNotification object:nil];
    [center addObserver:self selector:@selector(appDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
}

-(MPRemoteCommandHandlerStatus)pauseDetected:(MPRemoteCommandEvent*)event {
    dispatch_async(dispatch_get_main_queue(), ^{
        ORKStrongTypeOf(self.delegate) strongDelegate = self.delegate;
        if (strongDelegate &&
            [strongDelegate respondsToSelector:@selector(oneAirPodRemoved)]) {
            [strongDelegate oneAirPodRemoved];
        }
    });
    return MPRemoteCommandHandlerStatusSuccess;
}

-(MPRemoteCommandHandlerStatus)playDetected:(MPRemoteCommandEvent*)event {
    dispatch_async(dispatch_get_main_queue(), ^{
        ORKStrongTypeOf(self.delegate) strongDelegate = self.delegate;
        if (strongDelegate &&
            [strongDelegate respondsToSelector:@selector(oneAirPodInserted)]) {
            [strongDelegate oneAirPodInserted];
        }
    });
    return MPRemoteCommandHandlerStatusSuccess;
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
    [center removeObserver:self name:AVAudioSessionRouteChangeNotification object:nil];
    [center removeObserver:self name:getAVSystemController_HeadphoneJackIsConnectedDidChangeNotification() object:nil];
    [center removeObserver:self name:getAVSystemController_ActiveAudioRouteDidChangeNotification() object:nil];
    [center removeObserver:self name:getAVSystemController_ServerConnectionDiedNotification() object:nil];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        // must be called on main thread
        [[UIApplication sharedApplication] endReceivingRemoteControlEvents];
    });
    
    [[[MPRemoteCommandCenter sharedCommandCenter] pauseCommand] removeTarget:self];
    [[[MPRemoteCommandCenter sharedCommandCenter] playCommand] removeTarget:self];
    
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
            if ([modelId containsString:ORKHeadphoneVendorAndProductIdIdentifierAirPodsGen3]) {
                return ORKHeadphoneTypeIdentifierAirPodsGen3;
            }
            if ([modelId containsString:ORKHeadphoneVendorAndProductIdIdentifierAirPodsPro]) {
                return ORKHeadphoneTypeIdentifierAirPodsPro;
            }
            if ([modelId containsString:ORKHeadphoneVendorAndProductIdIdentifierAirPodsProGen2]) {
                return ORKHeadphoneTypeIdentifierAirPodsProGen2;
            }
            if ([modelId containsString:ORKHeadphoneVendorAndProductIdIdentifierAirPodsMax]) {
                return ORKHeadphoneTypeIdentifierAirPodsMax;
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

- (void)updateDeviceInformationForRoute:(NSDictionary *)routeDict {
    _deviceSubType = [[[getAVOutputContextClass() sharedSystemAudioContext] outputDevice] deviceSubType];
    NSString *btDetails = [routeDict valueForKey:getAVSystemController_RouteDescriptionKey_BTDetails_ProductID()];
    NSArray *productIDComponents = [btDetails componentsSeparatedByString:@","];
    if (productIDComponents.count == 2) {
        NSString *vendorIDDec = [[productIDComponents[0] componentsSeparatedByCharactersInSet: [[NSCharacterSet decimalDigitCharacterSet] invertedSet]] componentsJoinedByString:@""];
        NSString *productIDDec = [[productIDComponents[1] componentsSeparatedByCharactersInSet: [[NSCharacterSet decimalDigitCharacterSet] invertedSet]] componentsJoinedByString:@""];
        _vendorID = [NSString stringWithFormat:@"0x%04lX", (unsigned long)[vendorIDDec integerValue]];
        _productID = [NSString stringWithFormat:@"0x%04lX", (unsigned long)[productIDDec integerValue]];
    }
}

- (BOOL)isRouteSupported {
    __block BOOL routeSupported = NO;
    
    if (_celestialSPIOk)
    {
        NSArray *routesAttributes = [[getAVSystemControllerClass() sharedAVSystemController] attributeForKey:getAVSystemController_PickableRoutesAttribute()];
        
        if (routesAttributes != nil) {
            ORKWeakTypeOf(self) weakSelf = self;
            [routesAttributes enumerateObjectsUsingBlock:^(NSDictionary *route, NSUInteger idx, BOOL *stop)
             {
                ORKStrongTypeOf(self) strongSelf = weakSelf;
                if ([[route valueForKey:getAVSystemController_RouteDescriptionKey_RouteCurrentlyPicked()] boolValue]) {
                    [strongSelf updateDeviceInformationForRoute:route];
                    NSSet *supportedRoutes = [strongSelf supportedHeadphoneChipsetTypesForRoute:route];
                    
                    NSString* modelId = [[[[getAVOutputContextClass() sharedSystemAudioContext] outputDevice] modelID] lowercaseString];
                    BOOL hasSpeakerOnModelId = [modelId containsString:@"speaker"];
                    
                    if ([[[getAVOutputContextClass() sharedSystemAudioContext] outputDevice] deviceSubType] != AVOutputDeviceSubTypeHeadphones || hasSpeakerOnModelId) {
                        routeSupported = NO;
                        _lastDetectedDevice = nil;
                    } else if (supportedRoutes.count > 0) {
                        ORKHeadphoneTypeIdentifier btHeadphoneType = [strongSelf getCurrentBTHeadphoneType];
                        if (btHeadphoneType == nil)
                        {
                            NSSet *lightningSet = [NSSet setWithObject:ORKHeadphoneChipsetIdentifierLightningEarPods];
                            NSSet *audioJackSet = [NSSet setWithObject:ORKHeadphoneChipsetIdentifierAudioJackEarPods];
                            
                            BOOL isWiredPod = [lightningSet isSubsetOfSet:supportedRoutes] || [audioJackSet isSubsetOfSet:supportedRoutes];
                            
                            if (isWiredPod)
                            {
                                routeSupported = YES;
                                _lastDetectedDevice = ORKHeadphoneTypeIdentifierEarPods;
                            } else {
                                routeSupported = _supportedHeadphoneChipsetTypes == nil;
                                _lastDetectedDevice = ORKHeadphoneTypeIdentifierUnknown;
                            }
                        } else {
                            routeSupported = YES;
                            _lastDetectedDevice = btHeadphoneType;
                        }
                    } else {
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

- (NSSet *)supportedHeadphoneChipsetTypesForRoute:(NSDictionary *)route {
    NSString *subtype = [route valueForKey:getAVSystemController_RouteDescriptionKey_RouteSubtype()];
    
    NSSet *supportedChipsetTypes = _supportedHeadphoneChipsetTypes;
    
    // If we are supporting any type of headphones, we can still try to classify them!
    if (_supportedHeadphoneChipsetTypes == nil)
    {
        supportedChipsetTypes = [ORKHeadphoneDetector appleHeadphoneSet];
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
            [strongDelegate respondsToSelector:@selector(headphoneTypeDetected: vendorID: productID: deviceSubType: isSupported:)]) {
            [strongDelegate headphoneTypeDetected:_lastDetectedDevice vendorID:_vendorID productID:_productID deviceSubType:_deviceSubType isSupported:routeIsSupported];
        }
    });
}

- (BOOL)headphoneHasNoiseCancellingFeature {
    ORKHeadphoneTypeIdentifier currentHeadphone = [self getCurrentBTHeadphoneType];
    return (currentHeadphone == ORKHeadphoneTypeIdentifierAirPodsPro ||
            currentHeadphone == ORKHeadphoneTypeIdentifierAirPodsProGen2 ||
            currentHeadphone == ORKHeadphoneTypeIdentifierAirPodsMax) &&
            (_lastDetectedDevice == ORKHeadphoneTypeIdentifierAirPodsPro ||
             _lastDetectedDevice == ORKHeadphoneTypeIdentifierAirPodsProGen2 ||
             _lastDetectedDevice == ORKHeadphoneTypeIdentifierAirPodsMax);
}

- (void)checkTick:(NSNotification *)notification {
    ORKWeakTypeOf(self) weakSelf = self;
    
    if (!_tickQueue) {
        _tickQueue = dispatch_queue_create("HeadphoneDetectorTickQueue", DISPATCH_QUEUE_SERIAL);
    }

    _workaroundPoolingCounter = _workaroundPoolingCounter + 1;
    
    if (_workaroundPoolingCounter == 10) {
        if ([_workaroundPlayer isPlaying]) {
            [_workaroundPlayer stop];
            _workaroundPlayer = nil;
            // will be faster to start tha audio again
            _workaroundPoolingCounter = 5;
        } else {
            [self initializeSmartRouteWorkaround];
            _workaroundPoolingCounter = 0;
        }
    }

    dispatch_async(_tickQueue, ^{
        ORKStrongTypeOf(self.delegate) strongDelegate = self.delegate;
        ORKStrongTypeOf(weakSelf) strongSelf = weakSelf;
        if ([strongSelf checkLowBatteryLevelForPods] && strongDelegate &&
            [strongDelegate respondsToSelector:@selector(podLowBatteryLevelDetected)]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [strongDelegate podLowBatteryLevelDetected];
            });
        }
        NSUInteger numberOfDevices = [[getAVOutputContextClass() sharedSystemAudioContext] outputDevices].count;
        if (_wirelessSplitterNumberOfDevices != numberOfDevices) {
            _wirelessSplitterNumberOfDevices = numberOfDevices;
            if (_lastDetectedDevice != nil && strongDelegate &&
                [strongDelegate respondsToSelector:@selector(wirelessSplitterMoreThanOneDeviceDetected:)]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [strongDelegate wirelessSplitterMoreThanOneDeviceDetected:(numberOfDevices > 1)];
                });
            }
        }
        if (@available(iOS 13.0, *)) {
            if ([strongSelf headphoneHasNoiseCancellingFeature] &&
                strongDelegate && [strongDelegate respondsToSelector:@selector(bluetoothModeChanged:)]) {
                
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
                dispatch_async(dispatch_get_main_queue(), ^{
                    [strongDelegate bluetoothModeChanged:btMode];
                });
            }
        } else {
            if (strongDelegate &&
                [strongDelegate respondsToSelector:@selector(bluetoothModeChanged:)]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [strongDelegate bluetoothModeChanged:ORKBluetoothModeNoiseCancellation];
                });
            }
        }
    });
}

@end
