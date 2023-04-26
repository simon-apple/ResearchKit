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

#import <ResearchKit/ORKResult.h>

NS_ASSUME_NONNULL_BEGIN

ORK_CLASS_AVAILABLE
@interface ORKdBHLFitTestResultSample : NSObject <NSCopying, NSSecureCoding>

@property (nonatomic, assign) double sealLeftEar;

@property (nonatomic, assign) double sealRightEar;

@property (nonatomic, assign) double confidenceLeftEar;

@property (nonatomic, assign) double confidenceRightEar;

@property (nonatomic, assign) double sealThreshold;

@property (nonatomic, assign) double confidenceThreshold;

/**
 A boolean indicating if the left seal passed the test
 */
@property (nonatomic, assign) BOOL leftSealSuccess;

/**
 A boolean indicating if the right seal passed the test
 */
@property (nonatomic, assign) BOOL rightSealSuccess;

/**
 A boolean indicating if the condifence is too low. It happens if confidenceLeftEar OR confidenceRightEar is lower then confidenceThreshold
 */
@property (nonatomic, assign) BOOL lowConfidence;

@end

ORK_CLASS_AVAILABLE
@interface ORKdBHLFitTestResult : ORKResult

@property (nonatomic, copy) NSArray<ORKdBHLFitTestResultSample *> *fitTestResultSamples;

@end

NS_ASSUME_NONNULL_END
