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

@interface ORKHeadphoneDetector ()

@property (nonatomic, readwrite, nullable) NSSet<NSString *> *supportedHeadphoneTypes;

@end

@implementation ORKHeadphoneDetector {
    NSString *_newRoute;
}

- (instancetype)initWithDelegate:(id<ORKHeadphoneDetectorDelegate>)delegate
       supportedHeadphoneTypes:(NSSet<NSString *> *)supportedHeadphoneTypes {
    self = [super init];
    if (self) {
        _newRoute = nil;
        self.delegate = delegate;
        self.supportedHeadphoneTypes = supportedHeadphoneTypes;
        [self registerNotifications];
        [self updateHeadphoneState];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Headphone Monitoring

- (void)registerNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(headphoneStateChangedNotification:) name:@"AVSystemController_HeadphoneJackIsConnectedDidChangeNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(headphoneStateChangedNotification:) name:@"AVAudioSessionRouteChangeNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(headphoneStateChangedNotification:) name:@"AVSystemController_ActiveAudioRouteDidChangeNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mediaServerDied) name:@"AVSystemController_ServerConnectionDiedNotification" object:nil];
}

- (void)mediaServerDied
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self performSelector:@selector(registerNotifications) withObject:nil afterDelay:2.0];
    [self headphoneStateChangedNotification:nil];
}

- (void)headphoneStateChangedNotification:(NSNotification *)note
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_global_queue(QOS_CLASS_DEFAULT, 0), ^{
        [self updateHeadphoneState];
    });
}

- (BOOL)isRouteSupported {
    __block BOOL routeSupported = NO;
    
    [[[getAVSystemControllerClass() sharedAVSystemController] attributeForKey:getAVSystemController_PickableRoutesAttribute()] enumerateObjectsUsingBlock:^(NSDictionary *route, NSUInteger idx, BOOL *stop) {
        if ( [[route valueForKey:getAVSystemController_RouteDescriptionKey_RouteCurrentlyPicked()] boolValue] )
        {
            NSString *subtype = [route valueForKey:getAVSystemController_RouteDescriptionKey_RouteSubtype()];
            NSSet *supportedRoutes = [_supportedHeadphoneTypes objectsPassingTest:^BOOL(NSString * _Nonnull obj, BOOL * _Nonnull routesStop) {
                return [subtype containsString:obj];
            }];
            _newRoute =  subtype;
            routeSupported = ( [supportedRoutes count] > 0 || _supportedHeadphoneTypes == nil );
            *stop = YES;
        }
    }];
    return routeSupported;
}

- (void)updateHeadphoneState
{
    BOOL routeIsSupported = ([self isRouteSupported] && _newRoute != nil);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        ORKStrongTypeOf(self.delegate) strongDelegate = self.delegate;
        if (strongDelegate &&
            [strongDelegate respondsToSelector:@selector(headphoneTypeDetected: isSupported:)]) {
            [strongDelegate headphoneTypeDetected:_newRoute isSupported:routeIsSupported];
        }
    });
}

@end
