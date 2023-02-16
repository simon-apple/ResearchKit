/*
 Copyright (c) 2018, Apple Inc. All rights reserved.
 
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

NS_ASSUME_NONNULL_BEGIN

ORK_CLASS_AVAILABLE
@interface ORKdBHLToneAudiometryScreenerStep : ORKActiveStep

@property (nonatomic, assign) NSTimeInterval toneDuration;

@property (nonatomic, assign) NSTimeInterval postStimulusDelay;

@property (nonatomic, assign) double initialdBHLValue;

@property (nonatomic, assign) double dBHLRateUp;

@property (nonatomic, assign) double dBHLRateDown;

@property (nonatomic, assign) double octaveRate;

@property (nonatomic, assign) double stepSize;

@property (nonatomic, assign) double dBHLMinimumThreshold;

@property (nonatomic, assign) double dBHLCalculatedThreshold;

@property (nonatomic, assign) NSUInteger numberOfInversions;

@property (nonatomic, strong) ORKHeadphoneTypeIdentifier headphoneType;

@property (nonatomic, assign) ORKAudioChannel earPreference;

@property (nonatomic, assign) double frequency;

@property (nonatomic, assign) BOOL usePicker;

@property (nonatomic, assign) BOOL useSlider;

@property (nonatomic, assign) BOOL isMultiStep;

@property (nonatomic, assign) NSUInteger minimumdBHL;

@property (nonatomic, assign) NSUInteger maximumdBHL;

@property (nonatomic, copy, nullable) NSArray *frequencyList;

@end

NS_ASSUME_NONNULL_END
