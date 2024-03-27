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

// apple-internal

#import <Foundation/Foundation.h>
#import <XCTest/XCTest.h>
#import <ResearchKit/ResearchKit_Private.h>
#import <ResearchKitActiveTask/ResearchKitActiveTask.h>
#import <ResearchKitActiveTask/ResearchKitActiveTask_Private.h>
#if RK_APPLE_INTERNAL
#import <ResearchKitInternal/ResearchKitInternal.h>
#import <ResearchKitInternal/ResearchKitInternal_Private.h>
#endif
#import <ResearchKitUI/ResearchKitUI.h>

#import "ORKESerialization.h"
#import <objc/runtime.h>

@interface ORKIJSONSerializationTests : XCTestCase <NSKeyedUnarchiverDelegate>

@end

@implementation ORKIJSONSerializationTests

@end

@interface ORKIJSONSerializationTests (Tests)

@end

@implementation ORKIJSONSerializationTests (Tests)

- (void)setUp {
    [super setUp];
    [ORKInternalClassMapper removeUseInternalMapperUserDefaultsValues];
}

- (void)tearDown {
    [super tearDown];
    [ORKInternalClassMapper removeUseInternalMapperUserDefaultsValues];
}

#pragma mark - Tests

- (void)testInternalMapper {
    // test questionStep mapping
    Class mappedQuestionStep = [ORKInternalClassMapper getInternalClassForPublicClass:[ORKQuestionStep class]];
    NSString *mappedQuestionStepString = (NSString *)[ORKInternalClassMapper getInternalClassStringForPublicClass:NSStringFromClass([ORKQuestionStep class])];

    XCTAssertTrue([NSStringFromClass(mappedQuestionStep) isEqualToString:NSStringFromClass([ORKIQuestionStep class])], @"Failed to map %@", NSStringFromClass([ORKQuestionStep class]));
    XCTAssertTrue([mappedQuestionStepString isEqualToString:NSStringFromClass([ORKIQuestionStep class])], @"Failed to map %@", NSStringFromClass([ORKQuestionStep class]));
    
    // test instructionStep mapping
    Class mappedInstructionStep = [ORKInternalClassMapper getInternalClassForPublicClass:[ORKInstructionStep class]];
    NSString *mappedInstructionStepString = (NSString *)[ORKInternalClassMapper getInternalClassStringForPublicClass:NSStringFromClass([ORKInstructionStep class])];
    
    XCTAssertTrue([NSStringFromClass(mappedInstructionStep) isEqualToString:NSStringFromClass([ORKIInstructionStep class])], @"Failed to map %@", NSStringFromClass([ORKInstructionStep class]));
    XCTAssertTrue([mappedInstructionStepString isEqualToString:NSStringFromClass([ORKIInstructionStep class])], @"Failed to map %@", NSStringFromClass([ORKInstructionStep class]));
    
    // test dBHLToneAudiometryStep mapping
    Class mappeddBHLToneAudiometryStepClass = [ORKInternalClassMapper getInternalClassForPublicClass:[ORKdBHLToneAudiometryStep class]];
    NSString *mappeddBHLToneAudiometryStepString = (NSString *)[ORKInternalClassMapper getInternalClassStringForPublicClass:NSStringFromClass([ORKdBHLToneAudiometryStep class])];
    
    XCTAssertTrue([NSStringFromClass(mappeddBHLToneAudiometryStepClass) isEqualToString:NSStringFromClass([ORKIdBHLToneAudiometryStep class])], @"Failed to map %@", NSStringFromClass([ORKdBHLToneAudiometryStep class]));
    XCTAssertTrue([mappeddBHLToneAudiometryStepString isEqualToString:NSStringFromClass([ORKIdBHLToneAudiometryStep class])], @"Failed to map %@", NSStringFromClass([ORKdBHLToneAudiometryStep class]));
    
    // test dBHLToneAudiometryResult mapping
    Class mappeddBHLToneAudiometryResultClass = [ORKInternalClassMapper getInternalClassForPublicClass:[ORKdBHLToneAudiometryResult class]];
    NSString *mappeddBHLToneAudiometryResultString = (NSString *)[ORKInternalClassMapper getInternalClassStringForPublicClass:NSStringFromClass([ORKdBHLToneAudiometryResult class])];
    
    XCTAssertTrue([NSStringFromClass(mappeddBHLToneAudiometryResultClass) isEqualToString:NSStringFromClass([ORKIdBHLToneAudiometryResult class])], @"Failed to map %@", NSStringFromClass([ORKdBHLToneAudiometryResult class]));
    XCTAssertTrue([mappeddBHLToneAudiometryResultString isEqualToString:NSStringFromClass([ORKIdBHLToneAudiometryResult class])], @"Failed to map %@", NSStringFromClass([ORKdBHLToneAudiometryResult class]));
    
    // test speechInNoise mapping
    Class mappeddSINClass = [ORKInternalClassMapper getInternalClassForPublicClass:[ORKSpeechInNoiseStep class]];
    NSString *mappedSINString = (NSString *)[ORKInternalClassMapper getInternalClassStringForPublicClass:NSStringFromClass([ORKSpeechInNoiseStep class])];
    
    XCTAssertTrue([NSStringFromClass(mappeddSINClass) isEqualToString:NSStringFromClass([ORKISpeechInNoiseStep class])], @"Failed to map %@", NSStringFromClass([ORKSpeechInNoiseStep class]));
    XCTAssertTrue([mappedSINString isEqualToString:NSStringFromClass([ORKISpeechInNoiseStep class])], @"Failed to map %@", NSStringFromClass([ORKSpeechInNoiseStep class]));
    
    // test environmentSPLMeterStep mapping
    Class mappedEnvironmentSPLMeterStep = [ORKInternalClassMapper getInternalClassForPublicClass:[ORKEnvironmentSPLMeterStep class]];
    NSString *mappedEnvironmentSPLMeterStepString = (NSString *)[ORKInternalClassMapper getInternalClassStringForPublicClass:NSStringFromClass([ORKEnvironmentSPLMeterStep class])];
    
    XCTAssertTrue([NSStringFromClass(mappedEnvironmentSPLMeterStep) isEqualToString:NSStringFromClass([ORKIEnvironmentSPLMeterStep class])], @"Failed to map %@", NSStringFromClass([ORKEnvironmentSPLMeterStep class]));
    XCTAssertTrue([mappedEnvironmentSPLMeterStepString isEqualToString:NSStringFromClass([ORKIEnvironmentSPLMeterStep class])], @"Failed to map %@", NSStringFromClass([ORKEnvironmentSPLMeterStep class]));
    
    // test completionStep mapping
    Class mappedCompletionStep = [ORKInternalClassMapper getInternalClassForPublicClass:[ORKCompletionStep class]];
    NSString *mappedCompletionStepString = (NSString *)[ORKInternalClassMapper getInternalClassStringForPublicClass:NSStringFromClass([ORKCompletionStep class])];
    
    XCTAssertTrue([NSStringFromClass(mappedCompletionStep) isEqualToString:NSStringFromClass([ORKICompletionStep class])], @"Failed to map %@", NSStringFromClass([ORKCompletionStep class]));
    XCTAssertTrue([mappedCompletionStepString isEqualToString:NSStringFromClass([ORKICompletionStep class])], @"Failed to map %@", NSStringFromClass([ORKCompletionStep class]));
    
    // test speechRecognitionStep mapping
    Class mappedSpeechRecognitionStep = [ORKInternalClassMapper getInternalClassForPublicClass:[ORKSpeechRecognitionStep class]];
    NSString *mappedSpeechRecognitionStepString = (NSString *)[ORKInternalClassMapper getInternalClassStringForPublicClass:NSStringFromClass([ORKSpeechRecognitionStep class])];
    
    XCTAssertTrue([NSStringFromClass(mappedSpeechRecognitionStep) isEqualToString:NSStringFromClass([ORKISpeechRecognitionStep class])], @"Failed to map %@", NSStringFromClass([ORKSpeechRecognitionStep class]));
    XCTAssertTrue([mappedSpeechRecognitionStepString isEqualToString:NSStringFromClass([ORKISpeechRecognitionStep class])], @"Failed to map %@", NSStringFromClass([ORKSpeechRecognitionStep class]));
    
    // test orderedTask mapping
    Class mappedOrderedTask = [ORKInternalClassMapper getInternalClassForPublicClass:[ORKOrderedTask class]];
    NSString *mappedOrderedTaskString = (NSString *)[ORKInternalClassMapper getInternalClassStringForPublicClass:NSStringFromClass([ORKOrderedTask class])];
    
    XCTAssertTrue([NSStringFromClass(mappedOrderedTask) isEqualToString:NSStringFromClass([ORKIOrderedTask class])], @"Failed to map %@", NSStringFromClass([ORKOrderedTask class]));
    XCTAssertTrue([mappedOrderedTaskString isEqualToString:NSStringFromClass([ORKIOrderedTask class])], @"Failed to map %@", NSStringFromClass([ORKOrderedTask class]));
    
    // test navigableOrderedTask mapping
    Class mappedNavigableOrderedTask = [ORKInternalClassMapper getInternalClassForPublicClass:[ORKNavigableOrderedTask class]];
    NSString *mappedNavigableOrderedTaskString = (NSString *)[ORKInternalClassMapper getInternalClassStringForPublicClass:NSStringFromClass([ORKNavigableOrderedTask class])];
    
    XCTAssertTrue([NSStringFromClass(mappedNavigableOrderedTask) isEqualToString:NSStringFromClass([ORKINavigableOrderedTask class])], @"Failed to map %@", NSStringFromClass([ORKNavigableOrderedTask class]));
    XCTAssertTrue([mappedNavigableOrderedTaskString isEqualToString:NSStringFromClass([ORKINavigableOrderedTask class])], @"Failed to map %@", NSStringFromClass([ORKNavigableOrderedTask class]));
}

- (void)testCastingToInternalClasses {
    NSString *bundlePath = [[NSBundle bundleForClass:[ORKIJSONSerializationTests class]] pathForResource:@"samples" ofType:@"bundle"];
    NSBundle *bundle = [NSBundle bundleWithPath:bundlePath];
    NSError *error;
    
    // test instructionStep casting
    NSString *instructionStepJSONFilePath = [bundle pathForResource:NSStringFromClass([ORKInstructionStep class]) ofType:@"json"];
    NSDictionary *instructionStepDict = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:instructionStepJSONFilePath] options:0 error:NULL];
    ORKInstructionStep *instructionStep = (ORKInstructionStep *)[ORKESerializer objectFromJSONObject:instructionStepDict error:&error];
    ORKIInstructionStep *mappedInstructionStep = [ORKInternalClassMapper getInternalInstanceForPublicInstance:instructionStep];
    
    XCTAssertNil(error);
    XCTAssertNotNil(instructionStep);
    XCTAssertNotNil(mappedInstructionStep);
    XCTAssertTrue([NSStringFromClass([mappedInstructionStep class]) isEqualToString:NSStringFromClass([ORKIInstructionStep class])]);
    
    // test questionStep casting
    NSString *questionStepJSONFilePath = [bundle pathForResource:NSStringFromClass([ORKQuestionStep class]) ofType:@"json"];
    NSDictionary *questionStepDict = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:questionStepJSONFilePath] options:0 error:NULL];
    ORKQuestionStep *questionStep = (ORKQuestionStep *)[ORKESerializer objectFromJSONObject:questionStepDict error:&error];
    ORKIQuestionStep *mappedQuestionStep = [ORKInternalClassMapper getInternalInstanceForPublicInstance:questionStep];
    
    XCTAssertNil(error);
    XCTAssertNotNil(questionStep);
    XCTAssertNotNil(mappedQuestionStep);
    XCTAssertTrue([NSStringFromClass([mappedQuestionStep class]) isEqualToString:NSStringFromClass([ORKIQuestionStep class])]);
    
    // ORKdBHLToneAudiometryStep casting
    NSString *dBHLStepJSONFilePath = [bundle pathForResource:NSStringFromClass([ORKdBHLToneAudiometryStep class]) ofType:@"json"];
    NSDictionary *dBHLStepStepDict = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:dBHLStepJSONFilePath] options:0 error:NULL];
    ORKdBHLToneAudiometryStep *dBHLStep = (ORKdBHLToneAudiometryStep *)[ORKESerializer objectFromJSONObject:dBHLStepStepDict error:&error];
    ORKIdBHLToneAudiometryStep *mappeddBHLStep = [ORKInternalClassMapper getInternalInstanceForPublicInstance:dBHLStep];
    
    XCTAssertNil(error);
    XCTAssertNotNil(dBHLStep);
    XCTAssertNotNil(mappeddBHLStep);
    XCTAssertTrue([NSStringFromClass([mappeddBHLStep class]) isEqualToString:NSStringFromClass([ORKIdBHLToneAudiometryStep class])]);
    
    // ORKSpeechInNoiseStep casting
    NSString *speechInNoiseJSONFilePath = [bundle pathForResource:NSStringFromClass([ORKSpeechInNoiseStep class]) ofType:@"json"];
    NSDictionary *speechInNoiseStepDict = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:speechInNoiseJSONFilePath] options:0 error:NULL];
    ORKSpeechInNoiseStep *speechInNoiseStep = (ORKSpeechInNoiseStep *)[ORKESerializer objectFromJSONObject:speechInNoiseStepDict error:&error];
    ORKISpeechRecognitionStep *mappedSpeechInNoiseStep = [ORKInternalClassMapper getInternalInstanceForPublicInstance:speechInNoiseStep];
    
    XCTAssertNil(error);
    XCTAssertNotNil(speechInNoiseStep);
    XCTAssertNotNil(mappedSpeechInNoiseStep);
    XCTAssertTrue([NSStringFromClass([mappedSpeechInNoiseStep class]) isEqualToString:NSStringFromClass([ORKISpeechInNoiseStep class])]);
    
    // ORKSpeechRecognitionStep casting
    NSString *speechRecognitionJSONFilePath = [bundle pathForResource:NSStringFromClass([ORKSpeechRecognitionStep class]) ofType:@"json"];
    NSDictionary *speechRecognitionStepDict = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:speechRecognitionJSONFilePath] options:0 error:NULL];
    ORKSpeechRecognitionStep *speechRecognitionStep = (ORKSpeechRecognitionStep *)[ORKESerializer objectFromJSONObject:speechRecognitionStepDict error:&error];
    ORKISpeechRecognitionStep *mappedSpeechRecognitionStep = [ORKInternalClassMapper getInternalInstanceForPublicInstance:speechRecognitionStep];
    
    XCTAssertNil(error);
    XCTAssertNotNil(speechRecognitionStep);
    XCTAssertNotNil(mappedSpeechRecognitionStep);
    XCTAssertTrue([NSStringFromClass([mappedSpeechRecognitionStep class]) isEqualToString:NSStringFromClass([ORKISpeechRecognitionStep class])]);
    
    // ORKEnvironmentSPLMeterStep casting
    NSString *environmentSPLMeterJSONFilePath = [bundle pathForResource:NSStringFromClass([ORKEnvironmentSPLMeterStep class]) ofType:@"json"];
    NSDictionary *environmentSPLMeterStepDict = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:environmentSPLMeterJSONFilePath] options:0 error:NULL];
    ORKEnvironmentSPLMeterStep *environmentSPLMeterStep = (ORKEnvironmentSPLMeterStep *)[ORKESerializer objectFromJSONObject:environmentSPLMeterStepDict error:&error];
    ORKIEnvironmentSPLMeterStep *mappedEnvironmentSPLMeterStep = [ORKInternalClassMapper getInternalInstanceForPublicInstance:environmentSPLMeterStep];
    
    XCTAssertNil(error);
    XCTAssertNotNil(environmentSPLMeterStep);
    XCTAssertNotNil(mappedEnvironmentSPLMeterStep);
    XCTAssertTrue([NSStringFromClass([mappedEnvironmentSPLMeterStep class]) isEqualToString:NSStringFromClass([ORKIEnvironmentSPLMeterStep class])]);
    
    // ORKCompletionStep casting
    NSString *completionStepJSONFilePath = [bundle pathForResource:NSStringFromClass([ORKCompletionStep class]) ofType:@"json"];
    NSDictionary *completionStepDict = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:completionStepJSONFilePath] options:0 error:NULL];
    ORKCompletionStep *completionStep = (ORKCompletionStep *)[ORKESerializer objectFromJSONObject:completionStepDict error:&error];
    ORKICompletionStep *mappedCompletionStep = [ORKInternalClassMapper getInternalInstanceForPublicInstance:completionStep];
    
    XCTAssertNil(error);
    XCTAssertNotNil(completionStep);
    XCTAssertNotNil(mappedCompletionStep);
    XCTAssertTrue([NSStringFromClass([mappedCompletionStep class]) isEqualToString:NSStringFromClass([ORKICompletionStep class])]);
    
    // ORKOrderedTask casting
    NSString *orderedTaskJSONFilePath = [bundle pathForResource:NSStringFromClass([ORKOrderedTask class]) ofType:@"json"];
    NSDictionary *orderedTaskDict = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:orderedTaskJSONFilePath] options:0 error:NULL];
    ORKOrderedTask *orderedTask = (ORKOrderedTask *)[ORKESerializer objectFromJSONObject:orderedTaskDict error:&error];
    ORKICompletionStep *mappedOrderedTask = [ORKInternalClassMapper getInternalInstanceForPublicInstance:orderedTask];
    
    XCTAssertNil(error);
    XCTAssertNotNil(orderedTask);
    XCTAssertNotNil(mappedOrderedTask);
    XCTAssertTrue([NSStringFromClass([mappedOrderedTask class]) isEqualToString:NSStringFromClass([ORKIOrderedTask class])]);
    
    // ORKNavigableOrderedTask casting
    NSString *navigableOrderedTaskJSONFilePath = [bundle pathForResource:NSStringFromClass([ORKNavigableOrderedTask class]) ofType:@"json"];
    NSDictionary *navigableOrderedTaskDict = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:navigableOrderedTaskJSONFilePath] options:0 error:NULL];
    ORKNavigableOrderedTask *navigableOrderedTask = (ORKNavigableOrderedTask *)[ORKESerializer objectFromJSONObject:navigableOrderedTaskDict error:&error];
    ORKINavigableOrderedTask *mappedNavigableOrderedTask = [ORKInternalClassMapper getInternalInstanceForPublicInstance:navigableOrderedTask];
    
    XCTAssertNil(error);
    XCTAssertNotNil(navigableOrderedTask);
    XCTAssertNotNil(mappedNavigableOrderedTask);
    XCTAssertTrue([NSStringFromClass([mappedNavigableOrderedTask class]) isEqualToString:NSStringFromClass([ORKINavigableOrderedTask class])]);
    
    // Testing that a class without a internal version will return nil when trying to cast
    NSString *stroopStepJSONFilePath = [bundle pathForResource:NSStringFromClass([ORKStroopStep class]) ofType:@"json"];
    NSDictionary *stroopStepDict = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:stroopStepJSONFilePath] options:0 error:NULL];
    ORKStroopStep *stroopStep = (ORKStroopStep *)[ORKESerializer objectFromJSONObject:stroopStepDict error:&error];
    id internalInstance = [ORKInternalClassMapper getInternalInstanceForPublicInstance:stroopStep];
    
    XCTAssertNil(error);
    XCTAssertNotNil(stroopStep);
    XCTAssertNil(internalInstance);
}

- (void)testJSONInternalMapping {
    [ORKInternalClassMapper setUseInternalMapperUserDefaultsValue:YES];
    
    NSString *bundlePath = [[NSBundle bundleForClass:[ORKIJSONSerializationTests class]] pathForResource:@"samples" ofType:@"bundle"];
    NSBundle *bundle = [NSBundle bundleWithPath:bundlePath];
    NSError *error;
    
    // test instructionStep casting
    NSString *instructionStepJSONFilePath = [bundle pathForResource:NSStringFromClass([ORKInstructionStep class]) ofType:@"json"];
    NSDictionary *instructionStepDict = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:instructionStepJSONFilePath] options:0 error:NULL];
    ORKIInstructionStep *mappedInstructionStep = (ORKIInstructionStep *)[ORKESerializer objectFromJSONObject:instructionStepDict error:&error];
    
    XCTAssertNil(error);
    XCTAssertTrue([NSStringFromClass([mappedInstructionStep class]) isEqualToString:NSStringFromClass([ORKIInstructionStep class])]);
    
    // test questionStep casting
    NSString *questionStepJSONFilePath = [bundle pathForResource:NSStringFromClass([ORKQuestionStep class]) ofType:@"json"];
    NSDictionary *questionStepDict = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:questionStepJSONFilePath] options:0 error:NULL];
    ORKIQuestionStep *mappedQuestionStep = (ORKIQuestionStep *)[ORKESerializer objectFromJSONObject:questionStepDict error:&error];
    
    XCTAssertNil(error);
    XCTAssertNotNil(mappedQuestionStep);
    XCTAssertTrue([NSStringFromClass([mappedQuestionStep class]) isEqualToString:NSStringFromClass([ORKIQuestionStep class])]);
    
    // ORKdBHLToneAudiometryStep casting
    NSString *dBHLStepJSONFilePath = [bundle pathForResource:NSStringFromClass([ORKdBHLToneAudiometryStep class]) ofType:@"json"];
    NSDictionary *dBHLStepStepDict = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:dBHLStepJSONFilePath] options:0 error:NULL];
    ORKIdBHLToneAudiometryStep *mappeddBHLStep = (ORKIdBHLToneAudiometryStep *)[ORKESerializer objectFromJSONObject:dBHLStepStepDict error:&error];
    
    XCTAssertNil(error);
    XCTAssertNotNil(mappeddBHLStep);
    XCTAssertTrue([NSStringFromClass([mappeddBHLStep class]) isEqualToString:NSStringFromClass([ORKIdBHLToneAudiometryStep class])]);
    
    // ORKSpeechInNoiseStep casting
    NSString *speechInNoiseJSONFilePath = [bundle pathForResource:NSStringFromClass([ORKSpeechInNoiseStep class]) ofType:@"json"];
    NSDictionary *speechInNoiseStepDict = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:speechInNoiseJSONFilePath] options:0 error:NULL];
    ORKISpeechInNoiseStep *mappedSpeechInNoiseStep = (ORKISpeechInNoiseStep *)[ORKESerializer objectFromJSONObject:speechInNoiseStepDict error:&error];

    XCTAssertNil(error);
    XCTAssertNotNil(mappedSpeechInNoiseStep);
    XCTAssertTrue([NSStringFromClass([mappedSpeechInNoiseStep class]) isEqualToString:NSStringFromClass([ORKISpeechInNoiseStep class])]);
    
    // ORKSpeechRecognitionStep casting
    NSString *speechRecognitionJSONFilePath = [bundle pathForResource:NSStringFromClass([ORKSpeechRecognitionStep class]) ofType:@"json"];
    NSDictionary *speechRecognitionStepDict = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:speechRecognitionJSONFilePath] options:0 error:NULL];
    ORKISpeechRecognitionStep *mappedSpeechRecognitionStep = (ORKISpeechRecognitionStep *)[ORKESerializer objectFromJSONObject:speechRecognitionStepDict error:&error];
    
    XCTAssertNil(error);
    XCTAssertNotNil(mappedSpeechRecognitionStep);
    XCTAssertTrue([NSStringFromClass([mappedSpeechRecognitionStep class]) isEqualToString:NSStringFromClass([ORKISpeechRecognitionStep class])]);
    
    // ORKEnvironmentSPLMeterStep casting
    NSString *environmentSPLMeterJSONFilePath = [bundle pathForResource:NSStringFromClass([ORKEnvironmentSPLMeterStep class]) ofType:@"json"];
    NSDictionary *environmentSPLMeterStepDict = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:environmentSPLMeterJSONFilePath] options:0 error:NULL];
    ORKIEnvironmentSPLMeterStep *mappedEnvironmentSPLMeterStep = (ORKIEnvironmentSPLMeterStep *)[ORKESerializer objectFromJSONObject:environmentSPLMeterStepDict error:&error];
    
    XCTAssertNil(error);
    XCTAssertNotNil(mappedEnvironmentSPLMeterStep);
    XCTAssertTrue([NSStringFromClass([mappedEnvironmentSPLMeterStep class]) isEqualToString:NSStringFromClass([ORKIEnvironmentSPLMeterStep class])]);
    
    // ORKCompletionStep casting
    NSString *completionStepJSONFilePath = [bundle pathForResource:NSStringFromClass([ORKCompletionStep class]) ofType:@"json"];
    NSDictionary *completionStepDict = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:completionStepJSONFilePath] options:0 error:NULL];
    ORKICompletionStep *mappedCompletionStep = (ORKICompletionStep *)[ORKESerializer objectFromJSONObject:completionStepDict error:&error];
    
    XCTAssertNil(error);
    XCTAssertNotNil(mappedCompletionStep);
    XCTAssertTrue([NSStringFromClass([mappedCompletionStep class]) isEqualToString:NSStringFromClass([ORKICompletionStep class])]);
    
    // ORKOrderedTask casting
    NSString *orderedTaskJSONFilePath = [bundle pathForResource:NSStringFromClass([ORKOrderedTask class]) ofType:@"json"];
    NSDictionary *orderedTaskDict = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:orderedTaskJSONFilePath] options:0 error:NULL];
    ORKIOrderedTask *mappedOrderedTask = (ORKIOrderedTask *)[ORKESerializer objectFromJSONObject:orderedTaskDict error:&error];
    
    XCTAssertNil(error);
    XCTAssertNotNil(mappedOrderedTask);
    XCTAssertTrue([NSStringFromClass([mappedOrderedTask class]) isEqualToString:NSStringFromClass([ORKIOrderedTask class])]);
    
    // ORKNavigableOrderedTask casting
    NSString *navigableOrderedTaskJSONFilePath = [bundle pathForResource:NSStringFromClass([ORKNavigableOrderedTask class]) ofType:@"json"];
    NSDictionary *navigableOrderedTaskDict = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:navigableOrderedTaskJSONFilePath] options:0 error:NULL];
    ORKINavigableOrderedTask *mappednavigableOrderedTask = (ORKINavigableOrderedTask *)[ORKESerializer objectFromJSONObject:navigableOrderedTaskDict error:&error];
    
    XCTAssertNil(error);
    XCTAssertNotNil(mappednavigableOrderedTask);
    XCTAssertTrue([NSStringFromClass([mappednavigableOrderedTask class]) isEqualToString:NSStringFromClass([ORKINavigableOrderedTask class])]);
    
    // Testing that a class without a internal version will return nil when trying to cast
    NSString *stroopStepJSONFilePath = [bundle pathForResource:NSStringFromClass([ORKStroopStep class]) ofType:@"json"];
    NSDictionary *stroopStepDict = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:stroopStepJSONFilePath] options:0 error:NULL];
    
    ORKStroopStep *stroopStep = (ORKStroopStep *)[ORKESerializer objectFromJSONObject:stroopStepDict error:&error];
    id internalInstance = [ORKInternalClassMapper getInternalInstanceForPublicInstance:stroopStep];
    
    XCTAssertNil(error);
    XCTAssertNotNil(stroopStep);
    XCTAssertNil(internalInstance);
}

- (void)testInternalMapperUserDefaults {
    // test setting key to true
    [ORKInternalClassMapper setUseInternalMapperUserDefaultsValue:YES];
    XCTAssertTrue([ORKInternalClassMapper getUseInternalMapperUserDefaultsValue]);
    
    // test setting key to false
    [ORKInternalClassMapper setUseInternalMapperUserDefaultsValue:NO];
    XCTAssertFalse([ORKInternalClassMapper getUseInternalMapperUserDefaultsValue]);
}

- (void)testInternalStepsSanitizer {
    [ORKInternalClassMapper setUseInternalMapperUserDefaultsValue:YES];
    NSArray<ORKStep *> *taskSteps = [self _getExampleListOfClassesForMapping];
    
    // sanitzier used directly
    NSArray<ORKStep *> *sanitizedSteps = [ORKInternalClassMapper sanitizeOrderedTaskSteps:taskSteps];
    XCTAssertTrue(sanitizedSteps.count == taskSteps.count);
    XCTAssertTrue([self _totalMatchesInStepsForClass:[ORKIInstructionStep class] step:sanitizedSteps] == 1);
    XCTAssertTrue([self _totalMatchesInStepsForClass:[ORKIQuestionStep class] step:sanitizedSteps] == 1);
    XCTAssertTrue([self _totalMatchesInStepsForClass:[ORKIEnvironmentSPLMeterStep class] step:sanitizedSteps] == 1);
    XCTAssertTrue([self _totalMatchesInStepsForClass:[ORKIdBHLToneAudiometryStep class] step:sanitizedSteps] == 1);
    XCTAssertTrue([self _totalMatchesInStepsForClass:[ORKISpeechInNoiseStep class] step:sanitizedSteps] == 1);
    XCTAssertTrue([self _totalMatchesInStepsForClass:[ORKISpeechRecognitionStep class] step:sanitizedSteps] == 1);
    XCTAssertTrue([self _totalMatchesInStepsForClass:[ORKICompletionStep class] step:sanitizedSteps] == 1);
    
    // passing steps to internal ordered task
    ORKIOrderedTask *orderedTask = [[ORKIOrderedTask alloc] initWithIdentifier:@"OrderedTaskIdentifier" steps:taskSteps];
    XCTAssertTrue(orderedTask.steps.count == taskSteps.count);
    XCTAssertTrue([self _totalMatchesInStepsForClass:[ORKIInstructionStep class] step:orderedTask.steps] == 1);
    XCTAssertTrue([self _totalMatchesInStepsForClass:[ORKIQuestionStep class] step:orderedTask.steps] == 1);
    XCTAssertTrue([self _totalMatchesInStepsForClass:[ORKIEnvironmentSPLMeterStep class] step:orderedTask.steps] == 1);
    XCTAssertTrue([self _totalMatchesInStepsForClass:[ORKIdBHLToneAudiometryStep class] step:orderedTask.steps] == 1);
    XCTAssertTrue([self _totalMatchesInStepsForClass:[ORKISpeechInNoiseStep class] step:orderedTask.steps] == 1);
    XCTAssertTrue([self _totalMatchesInStepsForClass:[ORKISpeechRecognitionStep class] step:orderedTask.steps] == 1);
    XCTAssertTrue([self _totalMatchesInStepsForClass:[ORKICompletionStep class] step:orderedTask.steps] == 1);
    
    // passing steps to internal navigable ordered task
    ORKINavigableOrderedTask *navigableOrderedTask = [[ORKINavigableOrderedTask alloc] initWithIdentifier:@"NavigableOrderedTask" steps:taskSteps];
    XCTAssertTrue(orderedTask.steps.count == taskSteps.count);
    XCTAssertTrue([self _totalMatchesInStepsForClass:[ORKIInstructionStep class] step:navigableOrderedTask.steps] == 1);
    XCTAssertTrue([self _totalMatchesInStepsForClass:[ORKIQuestionStep class] step:navigableOrderedTask.steps] == 1);
    XCTAssertTrue([self _totalMatchesInStepsForClass:[ORKIEnvironmentSPLMeterStep class] step:navigableOrderedTask.steps] == 1);
    XCTAssertTrue([self _totalMatchesInStepsForClass:[ORKIdBHLToneAudiometryStep class] step:navigableOrderedTask.steps] == 1);
    XCTAssertTrue([self _totalMatchesInStepsForClass:[ORKISpeechInNoiseStep class] step:navigableOrderedTask.steps] == 1);
    XCTAssertTrue([self _totalMatchesInStepsForClass:[ORKISpeechRecognitionStep class] step:navigableOrderedTask.steps] == 1);
    XCTAssertTrue([self _totalMatchesInStepsForClass:[ORKICompletionStep class] step:navigableOrderedTask.steps] == 1);
    
    // test that original array was not modified at all
    XCTAssertTrue([self _totalMatchesInStepsForClass:[ORKIInstructionStep class] step:taskSteps] == 0);
    XCTAssertTrue([self _totalMatchesInStepsForClass:[ORKIQuestionStep class] step:taskSteps] == 0);
    XCTAssertTrue([self _totalMatchesInStepsForClass:[ORKIEnvironmentSPLMeterStep class] step:taskSteps] == 0);
    XCTAssertTrue([self _totalMatchesInStepsForClass:[ORKIdBHLToneAudiometryStep class] step:taskSteps] == 0);
    XCTAssertTrue([self _totalMatchesInStepsForClass:[ORKISpeechInNoiseStep class] step:taskSteps] == 0);
    XCTAssertTrue([self _totalMatchesInStepsForClass:[ORKISpeechRecognitionStep class] step:taskSteps] == 0);
    XCTAssertTrue([self _totalMatchesInStepsForClass:[ORKICompletionStep class] step:taskSteps] == 0);
}

- (void)testJSONTaskInternalMapping {
    [ORKInternalClassMapper setUseInternalMapperUserDefaultsValue:YES];
    
    NSString *bundlePath = [[NSBundle bundleForClass:[ORKIJSONSerializationTests class]] pathForResource:@"samples" ofType:@"bundle"];
    NSBundle *bundle = [NSBundle bundleWithPath:bundlePath];
    NSError *error;
    
    // indigo: hormonal_symptoms_survey
    // a971ba39-3d42-4223-b355-744d73cf2f44
    NSString *hormonalSymptomsSurveyJSONFilePath = [bundle pathForResource:@"mapper_navigableTaskExample1" ofType:@"json"];
    NSDictionary *hormonalSymptomsSurveyDictionary = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:hormonalSymptomsSurveyJSONFilePath] options:0 error:NULL];
    ORKINavigableOrderedTask *hormonalSymptomsSurveyTask = (ORKINavigableOrderedTask *)[ORKESerializer objectFromJSONObject:hormonalSymptomsSurveyDictionary error:&error];

    XCTAssertNil(error);
    XCTAssertNotNil(hormonalSymptomsSurveyTask);
    XCTAssertTrue([NSStringFromClass([hormonalSymptomsSurveyTask class]) isEqualToString:NSStringFromClass([ORKINavigableOrderedTask class])]);
    XCTAssertTrue([self _totalMatchesInStepsForClass:[ORKIInstructionStep class] step:hormonalSymptomsSurveyTask.steps] == 1);
    XCTAssertTrue([self _totalMatchesInStepsForClass:[ORKIQuestionStep class] step:hormonalSymptomsSurveyTask.steps] == 3);
    XCTAssertTrue([self _totalMatchesInStepsForClass:[ORKICompletionStep class] step:hormonalSymptomsSurveyTask.steps] == 1);
    
    // Pacha: ras_acute_environment
    // 7c9d9cce-5327-4a15-aecd-93aab0d6f78f
    NSString *rasAcuteEnvironmentSurveyJSONFilePath = [bundle pathForResource:@"mapper_ras_acute_environment" ofType:@"json"];
    NSDictionary *rasAcuteEnvironmentSurveyDictionary = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:rasAcuteEnvironmentSurveyJSONFilePath] options:0 error:NULL];
    ORKINavigableOrderedTask *rasAcuteEnvironmentSymptomsSurveyTask = (ORKINavigableOrderedTask *)[ORKESerializer objectFromJSONObject:rasAcuteEnvironmentSurveyDictionary error:&error];
    
    XCTAssertNil(error);
    XCTAssertNotNil(rasAcuteEnvironmentSymptomsSurveyTask);
    XCTAssertTrue([NSStringFromClass([rasAcuteEnvironmentSymptomsSurveyTask class]) isEqualToString:NSStringFromClass([ORKINavigableOrderedTask class])]);
    XCTAssertTrue([self _totalMatchesInStepsForClass:[ORKIInstructionStep class] step:rasAcuteEnvironmentSymptomsSurveyTask.steps] == 5);
    XCTAssertTrue([self _totalMatchesInStepsForClass:[ORKIEnvironmentSPLMeterStep class] step:rasAcuteEnvironmentSymptomsSurveyTask.steps] == 1);
    XCTAssertTrue([self _totalMatchesInStepsForClass:[ORKIdBHLToneAudiometryStep class] step:rasAcuteEnvironmentSymptomsSurveyTask.steps] == 2);
    XCTAssertTrue([self _totalMatchesInStepsForClass:[ORKICompletionStep class] step:rasAcuteEnvironmentSymptomsSurveyTask.steps] == 2);
}

- (void)testOrderedTaskMapping {
    [ORKInternalClassMapper setUseInternalMapperUserDefaultsValue:YES];
    NSArray<ORKStep *> *taskSteps = [self _getExampleListOfClassesForMapping];
    
    // passing steps to ordered task
    ORKOrderedTask *orderedTask = [[ORKOrderedTask alloc] initWithIdentifier:@"OrderedTaskIdentifier" steps:taskSteps];
    ORKITaskViewController *taskViewController = [[ORKITaskViewController alloc] initWithTask:orderedTask taskRunUUID:nil];
    NSArray<ORKStep *> *orderedTaskMappedSteps = ((ORKIOrderedTask *)taskViewController.task).steps;

    XCTAssertTrue(orderedTask.steps.count == orderedTaskMappedSteps.count);
    XCTAssertTrue([NSStringFromClass([taskViewController.task class]) isEqualToString:NSStringFromClass([ORKIOrderedTask class])]);
    XCTAssertTrue([self _totalMatchesInStepsForClass:[ORKIInstructionStep class] step:orderedTaskMappedSteps] == 1);
    XCTAssertTrue([self _totalMatchesInStepsForClass:[ORKIQuestionStep class] step:orderedTaskMappedSteps] == 1);
    XCTAssertTrue([self _totalMatchesInStepsForClass:[ORKIEnvironmentSPLMeterStep class] step:orderedTaskMappedSteps] == 1);
    XCTAssertTrue([self _totalMatchesInStepsForClass:[ORKIdBHLToneAudiometryStep class] step:orderedTaskMappedSteps] == 1);
    XCTAssertTrue([self _totalMatchesInStepsForClass:[ORKISpeechInNoiseStep class] step:orderedTaskMappedSteps] == 1);
    XCTAssertTrue([self _totalMatchesInStepsForClass:[ORKISpeechRecognitionStep class] step:orderedTaskMappedSteps] == 1);
    XCTAssertTrue([self _totalMatchesInStepsForClass:[ORKICompletionStep class] step:orderedTaskMappedSteps] == 1);
    
    // passing steps to navigable ordered task
    ORKNavigableOrderedTask *navigableOrderedTask = [[ORKNavigableOrderedTask alloc] initWithIdentifier:@"NavigableOrderedTaskIdentifier" steps:taskSteps];
    ORKITaskViewController *taskViewController2 = [[ORKITaskViewController alloc] initWithTask:navigableOrderedTask taskRunUUID:nil];
    NSArray<ORKStep *> *navigableOrderedTaskMappedSteps = ((ORKINavigableOrderedTask *)taskViewController2.task).steps;
    
    XCTAssertTrue(navigableOrderedTask.steps.count == navigableOrderedTaskMappedSteps.count);
    XCTAssertTrue([NSStringFromClass([taskViewController2.task class]) isEqualToString:NSStringFromClass([ORKINavigableOrderedTask class])]);
    XCTAssertTrue([self _totalMatchesInStepsForClass:[ORKIInstructionStep class] step:navigableOrderedTaskMappedSteps] == 1);
    XCTAssertTrue([self _totalMatchesInStepsForClass:[ORKIQuestionStep class] step:navigableOrderedTaskMappedSteps] == 1);
    XCTAssertTrue([self _totalMatchesInStepsForClass:[ORKIEnvironmentSPLMeterStep class] step:navigableOrderedTaskMappedSteps] == 1);
    XCTAssertTrue([self _totalMatchesInStepsForClass:[ORKIdBHLToneAudiometryStep class] step:navigableOrderedTaskMappedSteps] == 1);
    XCTAssertTrue([self _totalMatchesInStepsForClass:[ORKISpeechInNoiseStep class] step:navigableOrderedTaskMappedSteps] == 1);
    XCTAssertTrue([self _totalMatchesInStepsForClass:[ORKISpeechRecognitionStep class] step:navigableOrderedTaskMappedSteps] == 1);
    XCTAssertTrue([self _totalMatchesInStepsForClass:[ORKICompletionStep class] step:navigableOrderedTaskMappedSteps] == 1);
}

- (void)testThrowingWhenPublicClassEncountered {
    [ORKInternalClassMapper setUseInternalMapperThrowsUserDefaultsValue:YES];
    NSArray<ORKStep *> *taskSteps = [self _getExampleListOfClassesForMapping];
    
    // passing public steps to public ordered task
    ORKOrderedTask *orderedTask = [[ORKOrderedTask alloc] initWithIdentifier:@"OrderedTaskIdentifier" steps:taskSteps];
    
    XCTAssertThrows([[ORKITaskViewController alloc] initWithTask:orderedTask taskRunUUID:nil]);
    
    // passing public steps to internal ordered task
    ORKIOrderedTask *internalOrderedTask = [[ORKIOrderedTask alloc] initWithIdentifier:@"InternalOrderedTaskIdentifier" steps:taskSteps];
    
    XCTAssertThrows([[ORKITaskViewController alloc] initWithTask:internalOrderedTask taskRunUUID:nil]);
    
    // passing internal steps to internal ordered task
    NSArray<ORKStep *> *sanitizedSteps = [ORKInternalClassMapper sanitizeOrderedTaskSteps:[taskSteps copy]];
    ORKINavigableOrderedTask *internalNavigableOrderedTask = [[ORKINavigableOrderedTask alloc] initWithIdentifier:@"InternalNavigableOrderedTaskIdentifier" steps:sanitizedSteps];
    
    XCTAssertNoThrow([[ORKITaskViewController alloc] initWithTask:internalNavigableOrderedTask taskRunUUID:nil]);
}

#pragma mark - Helpers

- (NSArray<ORKStep *> *)_getExampleListOfClassesForMapping {
    NSArray<ORKStep *> *exampleSteps = @[
        [[ORKInstructionStep alloc] initWithIdentifier:@"InstructionStepIdentifier"],
        [[ORKQuestionStep alloc] initWithIdentifier:@"QuestionStepIdentifier"],
        [[ORKEnvironmentSPLMeterStep alloc] initWithIdentifier:@"EnvironmentSPLMeterStepIdentifier"],
        [[ORKdBHLToneAudiometryStep alloc] initWithIdentifier:@"AudiometryStepIdentifier"],
        [[ORKSpeechInNoiseStep alloc] initWithIdentifier:@"SpeechInNoiseStepIdentifier"],
        [[ORKSpeechRecognitionStep alloc] initWithIdentifier:@"SpeechRecognitionStepIdentifier"],
        [[ORKCompletionStep alloc] initWithIdentifier:@"CompletionStepIdentifier"]
    ];
    return [exampleSteps copy];
}

- (int)_totalMatchesInStepsForClass:(Class)class step:(NSArray<ORKStep *> *)steps {
    int totalMatches = 0;
    for (ORKStep *step in steps) {
        if ([NSStringFromClass(class) isEqualToString:NSStringFromClass([step class])]) {
            totalMatches += 1;
        }
    }
    return totalMatches;
}

@end
