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


#import <ResearchKitActiveTask/ORKdBHLToneAudiometryResult.h>

@class ORKdBHLToneAudiometryFrequencySample;
@class ORKdBHLToneAudiometryUnit;

typedef NS_ENUM(NSInteger, ORKdBHLToneAudiometryMethodOfAdjustmentSourceOfInteraction) {
    ORKdBHLToneAudiometryMethodOfAdjustmentSourceOfInteractionSlider = 0,
    ORKdBHLToneAudiometryMethodOfAdjustmentSourceOfInteractionStepper = 1,
    ORKdBHLToneAudiometryMethodOfAdjustmentSourceOfInteractionReset = 2, // will not go to results, used as a flag to reset the slider.
} ORK_ENUM_AVAILABLE;

typedef NS_ENUM(NSInteger, ORKdBHLToneAudiometryMeasurementMethod) {
    ORKdBHLToneAudiometryMeasurementMethodLimits = 0,
    ORKdBHLToneAudiometryMeasurementMethodAdjustment = 1,
} ORK_ENUM_AVAILABLE;

NS_ASSUME_NONNULL_BEGIN

ORK_CLASS_AVAILABLE
@interface ORKIdBHLToneAudiometryResult : ORKdBHLToneAudiometryResult

//These data are related to the new algorithm only
@property (nonatomic, copy, nullable) NSArray<ORKdBHLToneAudiometryFrequencySample *> *discreteUnits;

@property (nonatomic, copy, nullable) NSDictionary<NSString *, NSNumber *> *fitMatrix;

@property (nonatomic, assign) NSInteger algorithmVersion;

@property (nonatomic, assign) ORKdBHLToneAudiometryMeasurementMethod measurementMethod;

@end

ORK_CLASS_AVAILABLE
@interface ORKdBHLToneAudiometryMethodOfAdjustmentInteraction : NSObject <NSCopying, NSSecureCoding>

@property (nonatomic, assign) double dBHLValue;

@property (nonatomic, assign) NSTimeInterval timeStamp;

@property (nonatomic, assign) ORKdBHLToneAudiometryMethodOfAdjustmentSourceOfInteraction sourceOfInteraction;

@end

ORK_CLASS_AVAILABLE
@interface ORKIdBHLToneAudiometryFrequencySample : ORKdBHLToneAudiometryFrequencySample

@property (nonatomic, copy, nullable) NSArray<ORKdBHLToneAudiometryMethodOfAdjustmentInteraction *> *methodOfAdjustmentInteractions;

@end

NS_ASSUME_NONNULL_END
