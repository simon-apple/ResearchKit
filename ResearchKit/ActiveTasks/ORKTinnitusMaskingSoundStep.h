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

@import Foundation;
#import <ResearchKit/ORKDefines.h>
#import <ResearchKit/ORKActiveStep.h>
#import <ResearchKit/ORKTinnitusTypes.h>
#import <ResearchKit/ORKTypes.h>

NS_ASSUME_NONNULL_BEGIN

ORK_CLASS_AVAILABLE
@interface ORKTinnitusMaskingSoundStep : ORKActiveStep

@property (nonatomic, strong) ORKTinnitusMaskingSoundType maskingSoundType;

/**
 The tinnitus frequency in Hertz that will be subtracted by the notch filter
 */
@property (nonatomic, assign) double notchFrequency;

/**
 Bandwidth in octaves (defaults to 0.17).
 */
@property (nonatomic) float bandwidth;

/**
 Gain in dB (defaults to -96).
 */
@property (nonatomic) float gain;

- (instancetype)initWithIdentifier:(NSString *)identifier __attribute__((unavailable("initWithIdentifier not available. Use initWithIdentifier: soundFilename: instead.")));

/**
 Initialize the ORKTinnitusMaskingSoundStep. The value of notchFrequency will be set to 0.0
 */
- (instancetype)initWithIdentifier:(NSString *)identifier maskingSoundType:(ORKTinnitusMaskingSoundType)maskingSoundType;

/**
 Initialize the ORKTinnitusMaskingSoundStep. Side effect:  To enable the notch filter, the value of notchFrequency must be greater then 0.0
 */
- (instancetype)initWithIdentifier:(NSString *)identifier maskingSoundType:(ORKTinnitusMaskingSoundType)maskingSoundType notchFrequency:(double)notchFrequency;

@end

NS_ASSUME_NONNULL_END
