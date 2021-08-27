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

#import "ORKBluetoothPermissionType.h"
#import "ORKRequestPermissionView.h"
#import "ORKHelpers_Internal.h"

@import CoreBluetooth;

static NSString *const Symbol = @"iphone.radiowaves.left.and.right";
static const uint32_t IconLightTintColor = 0x0096FF;
static const uint32_t IconDarkTintColor = 0x6495ED;

@interface ORKBluetoothPermissionType()  <CBCentralManagerDelegate>

@property (nonatomic) CBCentralManager *bluetoothManager;

@end

@implementation ORKBluetoothPermissionType

+ (instancetype)new {
    return [[ORKBluetoothPermissionType alloc] init];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setupCardView];
    }
    return self;
}

- (void)setupCardView {
    
    UIImage *image;
    if (@available(iOS 13, *)) {
        image = [UIImage systemImageNamed:Symbol];
    }
    
    self.cardView = [[ORKRequestPermissionView alloc]
                     initWithIconImage:image
                     title:ORKLocalizedString(@"REQUEST_BLUETOOTH_STEP_VIEW_TITLE", nil)
                     detailText:ORKLocalizedString(@"REQUEST_BLUETOOTH_STEP_VIEW_DESCRIPTION", nil)];

    [self.cardView.requestPermissionButton addTarget:self action:@selector(requestPermissionButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    
    // Set the tint color for the icon
    if (@available(iOS 13, *)) {
        UIColor *dynamicTint = [[UIColor alloc] initWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull traitCollection) {
            return traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark ? ORKRGB(IconDarkTintColor) : ORKRGB(IconLightTintColor);
        }];
        [self.cardView updateIconTintColor:dynamicTint];
    } else {
        [self.cardView updateIconTintColor:ORKRGB(IconLightTintColor)];
    }
}

// Asks for permission when CBCentralManager is allocated.
- (void)requestPermissionButtonPressed {
    if(!_bluetoothManager)
    {
        _bluetoothManager = [[CBCentralManager alloc] initWithDelegate:self queue:dispatch_get_main_queue()];
    }
    [self centralManagerDidUpdateState:_bluetoothManager];
    NSLog(@"updating state");
}


- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    NSLog(@"updating state: %ld", (long)central.state);
    switch (central.state) {
        case CBManagerStateUnknown:
            [self setState:ORKRequestPermissionsButtonStateDefault canContinue:NO];
            break;
            
        case CBManagerStateResetting:
        case CBManagerStateUnsupported:
        case CBManagerStateUnauthorized:
        case CBManagerStatePoweredOff:
        case CBManagerStatePoweredOn:
            [self setState:ORKRequestPermissionsButtonStateConnected canContinue:YES];
            break;
    }
}

- (void)setState:(ORKRequestPermissionsButtonState)state canContinue:(BOOL)canContinue {
    [self.cardView setEnableContinueButton:canContinue];
    [self.cardView.requestPermissionButton setState:state];
}

- (BOOL)isEqual:(id)object {
    if ([self class] != [object class]) {
        return NO;
    }
    return YES;
}

@end
