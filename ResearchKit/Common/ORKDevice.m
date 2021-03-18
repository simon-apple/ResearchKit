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


#import "ORKDevice.h"
#import "ORKHelpers_Internal.h"

#if TARGET_OS_IOS
#import <UIKit/UIDevice.h>
#elif TARGET_OS_WATCH
#import <WatchKit/WKInterfaceDevice.h>
#endif
#import <sys/types.h>
#import <sys/sysctl.h>

#if !TARGET_OS_SIMULATOR
static NSString * ORK_SYSCTL(int tl, int sl) {

    int mib[] = { tl, sl };
    size_t size;

    sysctl(mib, 2, NULL, &size, NULL, 0);

    char *cStr = malloc(size);

    sysctl(mib, 2, cStr, &size, NULL, 0);

    NSString *str = [NSString stringWithCString:cStr encoding:NSASCIIStringEncoding];

    free(cStr);

    return [str copy];
}
#endif

@implementation ORKDevice

+ (instancetype)currentDevice {
    return [[ORKDevice alloc] init];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self _init];
    }
    return self;
}

- (void)_init {
    NSOperatingSystemVersion version = [[NSProcessInfo processInfo] operatingSystemVersion];
    self->_osVersion = [NSString stringWithFormat:@"%li.%li.%li", version.majorVersion, version.minorVersion, version.patchVersion];
    self->_product = [self _product];
    self->_osBuild = [self _osBuild];
#if TARGET_OS_IOS
    self->_platform = [[UIDevice currentDevice] systemName];
#elif TARGET_OS_WATCH
    self->_platform = [[WKInterfaceDevice currentDevice] systemName];
#endif
}

- (instancetype)initWithProduct:(NSString *)product
                      osVersion:(NSString *)osVersion
                        osBuild:(NSString *)osBuild
                       platform:(NSString *)platform
{
    self = [super init];
    if (self) {
        self->_product = [product copy];
        self->_osVersion = [osVersion copy];
        self->_osBuild = [osBuild copy];
        self->_platform = [platform copy];
    }
    return self;
}

- (nullable NSString *)_product {
#if !TARGET_OS_SIMULATOR
    return ORK_SYSCTL(CTL_HW, HW_PRODUCT);
#else
    return nil;
#endif
}

- (nullable NSString *)_osBuild {
#if !TARGET_OS_SIMULATOR
    return ORK_SYSCTL(CTL_KERN, KERN_OSVERSION);
#else
    return nil;
#endif
}

#pragma mark - NSObjectProtocol

- (BOOL)isEqual:(id)object {
    __typeof(self) castObject = object;
    return (ORKEqualObjects(self.product, castObject.product) &&
            ORKEqualObjects(self.platform, castObject.platform) &&
            ORKEqualObjects(self.osBuild, castObject.osBuild) &&
            ORKEqualObjects(self.osVersion, castObject.osVersion));
}

- (NSUInteger)hash {
    return super.hash ^ self.product.hash ^ self.platform.hash ^ self.osBuild.hash ^ self.osVersion.hash;
}

#pragma mark - NSSecureCoding

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    ORK_ENCODE_OBJ(coder, product);
    ORK_ENCODE_OBJ(coder, platform);
    ORK_ENCODE_OBJ(coder, osBuild);
    ORK_ENCODE_OBJ(coder, osVersion);
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        ORK_DECODE_OBJ(coder, product);
        ORK_DECODE_OBJ(coder, platform);
        ORK_DECODE_OBJ(coder, osBuild);
        ORK_DECODE_OBJ(coder, osVersion);
    }
    return self;
}

#pragma mark - NSCopying

- (instancetype)copyWithZone:(nullable NSZone *)zone {
    return self;
}

@end
