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

#import <ResearchKit/ORKFeatureFlags.h>

#if ORK_FEATURE_BLE_SCAN_PERIPHERALS

#import "ORKBLEScanPeripheralsStep.h"
#import "ORKBLEScanPeripheralsStepViewController.h"
#import "ORKHelpers_Internal.h"

NSString * const ORKBLEScanPeripheralsRestorationIdentifierKey = @"ORKBLEScanPeripheralsRestorationIdentifierKey";

NSString * const ORKBLEScanPeripheralsMinimumConnectionCountKey = @"ORKBLEScanPeripheralsMinimumConnectionCountKey";

NSString * const ORKBLEScanPeripheralsCapacityKey = @"ORKBLEScanPeripheralsCapacityKey";

NSString * const ORKBLEScanPeripheralsFilterDeviceNameKey = @"ORKBLEScanPeripheralsFilterDeviceNameKey";

NSString * const ORKBLEScanPeripheralsFilterServiceUUIDKey = @"ORKBLEScanPeripheralsFilterServiceUUIDKey";

@implementation ORKBLEScanPeripheralsStep

- (instancetype)initWithIdentifier:(NSString *)identifier scanOptions:(NSDictionary<NSString *, id> *)scanOptions {
    self = [super initWithIdentifier:identifier];
    if (self) {
        _scanOptions = [scanOptions copy];
    }
    return self;
}

- (Class)stepViewControllerClass {
    return [ORKBLEScanPeripheralsStepViewController class];
}

#pragma mark - NSCoding

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [super encodeWithCoder:coder];
    ORK_ENCODE_OBJ(coder, scanOptions);
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        ORK_DECODE_OBJ_PLIST(coder, scanOptions);
    }
    return self;
}

@end

#endif

#endif
