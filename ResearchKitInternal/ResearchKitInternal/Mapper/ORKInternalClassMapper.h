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

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ORKInternalClassMapper : NSObject

/**
 Maps and returns the internal subclass of the class passed in.
 
 Returns nil if the class doesn't have an internal counterpart.
 */
+ (nullable Class)getInternalClassForPublicClass:(Class)class;

/**
 Maps and returns the class string for internal subclass
 of the class passed in.
 
 Returns nil if the class doesn't have an internal counterpart.
 */
+ (nullable NSString *)getInternalClassStringForPublicClass:(NSString *)class;

/**
 Maps and returns and instance for internal subclass
 of the class passed in.
 
 Returns nil if the class doesn't have an internal counterpart.
 */
+ (nullable id)getInternalInstanceForPublicClass:(id)class;

/**
 Sets a value for the ORKUseInternalClassMapper key for user defautls.
 */
+ (void)setUseInternalMapperUserDefaultsValue:(BOOL)value;

/**
 Boolean value for the ORKUseInternalClassMapper key for user defautls.
 */
+ (BOOL)getUseInternalMapperUserDefaultsValue;

/**
 Removes ORKUseInternalClassMapper key from user defautls.
 */
+ (void)removeUseInternalMapperUserDefaultsValue;

@end

NS_ASSUME_NONNULL_END
