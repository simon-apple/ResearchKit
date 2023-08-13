//
/*
 Copyright (c) 2023, Apple Inc. All rights reserved.
 
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

#include <dlfcn.h>

#import <Foundation/Foundation.h>
#import "ORKSoftLinking.h"
#import "ORKHearingTest-Swift.h"

#if defined(__OBJC__)
#import <objc/runtime.h>

@interface ORKHearingTestBundleClass : NSObject
@end
@implementation ORKHearingTestBundleClass
@end

@interface HearingTestBundleClass : NSObject
@end
@implementation HearingTestBundleClass
@end

#pragma mark - Softlink ORKHearingTest Library

static void* ORKHearingTestLibrary(void)
{
    static void* frameworkLibrary = nil;
    if (!frameworkLibrary) {
        NSBundle *bundle = [NSBundle bundleForClass:[ORKHearingTestBundleClass class]];
        NSString *path = [bundle pathForResource:@"ORKHearingTest" ofType:@"framework"];
        NSString *binPath = [path stringByAppendingPathComponent:@"ORKHearingTest"];
        NSLog(@"ORKHearingTestLibrary bin path: %@", binPath);
        
        frameworkLibrary = dlopen([binPath UTF8String], RTLD_NOW);
        
        if (!frameworkLibrary) {
            NSLog(@"dlerror: %@", [NSString stringWithUTF8String:dlerror()]);
        }
    }
    return frameworkLibrary;
}

static void* HearingTestLibrary(void)
{
    static void* HTFrameworkLibrary = nil;
    if (!HTFrameworkLibrary) {
        NSBundle *bundle = [NSBundle bundleForClass:[HearingTestBundleClass class]];
        NSString *path = [bundle pathForResource:@"ORKHearingTest.framework/HearingTest" ofType:@"framework"];
        NSString *binPath = [path stringByAppendingPathComponent:@"HearingTest"];
        NSLog(@"HearingTestLibrary bin path: %@", binPath);
        
        HTFrameworkLibrary = dlopen([binPath UTF8String], RTLD_NOW);
        
        if (!HTFrameworkLibrary) {
            NSLog(@"dlerror: %@", [NSString stringWithUTF8String:dlerror()]);
        }
    }
    return HTFrameworkLibrary;
}


#pragma mark - Softlink ORKTonePlayer Class

static Class initORKTonePlayer(void);
static Class (*getORKTonePlayerClass)(void) = initORKTonePlayer;
static Class classORKTonePlayer;

static Class ORKTonePlayerFunction(void)
{
    return classORKTonePlayer;
}

static Class initORKTonePlayer(void)
{
    HearingTestLibrary();
    ORKHearingTestLibrary();
    classORKTonePlayer = objc_getClass("_TtC14ORKHearingTest13ORKTonePlayer");
    getORKTonePlayerClass = ORKTonePlayerFunction;
    return classORKTonePlayer;
}
#endif
