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
}

- (void)testCastingToInternalClasses {
    NSString *bundlePath = [[NSBundle bundleForClass:[ORKIJSONSerializationTests class]] pathForResource:@"samples" ofType:@"bundle"];
    NSBundle *bundle = [NSBundle bundleWithPath:bundlePath];
    NSError *error;

    
    // ORKdBHLToneAudiometryStep casting
    NSString *dBHLStepJSONFilePath = [bundle pathForResource:NSStringFromClass([ORKdBHLToneAudiometryStep class]) ofType:@"json"];
    NSDictionary *dBHLStepStepDict = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:dBHLStepJSONFilePath] options:0 error:NULL];
    ORKdBHLToneAudiometryStep *dBHLStep = (ORKdBHLToneAudiometryStep *)[ORKESerializer objectFromJSONObject:dBHLStepStepDict error:&error];
    ORKIdBHLToneAudiometryStep *mappeddBHLStep = [ORKInternalClassMapper getInternalInstanceForPublicInstance:dBHLStep];
    
    XCTAssertNil(error);
    XCTAssertNotNil(dBHLStep);
    XCTAssertNotNil(mappeddBHLStep);
    XCTAssertTrue([NSStringFromClass([mappeddBHLStep class]) isEqualToString:NSStringFromClass([ORKIdBHLToneAudiometryStep class])]);
    
    
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
    
    
    // ORKdBHLToneAudiometryStep casting
    NSString *dBHLStepJSONFilePath = [bundle pathForResource:NSStringFromClass([ORKdBHLToneAudiometryStep class]) ofType:@"json"];
    NSDictionary *dBHLStepStepDict = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:dBHLStepJSONFilePath] options:0 error:NULL];
    ORKIdBHLToneAudiometryStep *mappeddBHLStep = (ORKIdBHLToneAudiometryStep *)[ORKESerializer objectFromJSONObject:dBHLStepStepDict error:&error];
    
    XCTAssertNil(error);
    XCTAssertNotNil(mappeddBHLStep);
    XCTAssertTrue([NSStringFromClass([mappeddBHLStep class]) isEqualToString:NSStringFromClass([ORKIdBHLToneAudiometryStep class])]);

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

- (void)testJSONTaskInternalMapping {
    [ORKInternalClassMapper setUseInternalMapperUserDefaultsValue:YES];
    
    NSString *bundlePath = [[NSBundle bundleForClass:[ORKIJSONSerializationTests class]] pathForResource:@"samples" ofType:@"bundle"];
    NSBundle *bundle = [NSBundle bundleWithPath:bundlePath];
    NSError *error;
    
    // indigo: hormonal_symptoms_survey
    // a971ba39-3d42-4223-b355-744d73cf2f44
    NSString *hormonalSymptomsSurveyJSONFilePath = [bundle pathForResource:@"mapper_navigableTaskExample1" ofType:@"json"];
    NSDictionary *hormonalSymptomsSurveyDictionary = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:hormonalSymptomsSurveyJSONFilePath] options:0 error:NULL];
    ORKNavigableOrderedTask *hormonalSymptomsSurveyTask = (ORKNavigableOrderedTask *)[ORKESerializer objectFromJSONObject:hormonalSymptomsSurveyDictionary error:&error];

    XCTAssertNil(error);
    XCTAssertNotNil(hormonalSymptomsSurveyTask);
    XCTAssertTrue([NSStringFromClass([hormonalSymptomsSurveyTask class]) isEqualToString:NSStringFromClass([ORKNavigableOrderedTask class])]);
    
    // Pacha: ras_acute_environment
    // 7c9d9cce-5327-4a15-aecd-93aab0d6f78f
    NSString *rasAcuteEnvironmentSurveyJSONFilePath = [bundle pathForResource:@"mapper_ras_acute_environment" ofType:@"json"];
    NSDictionary *rasAcuteEnvironmentSurveyDictionary = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:rasAcuteEnvironmentSurveyJSONFilePath] options:0 error:NULL];
    ORKNavigableOrderedTask *rasAcuteEnvironmentSymptomsSurveyTask = (ORKNavigableOrderedTask *)[ORKESerializer objectFromJSONObject:rasAcuteEnvironmentSurveyDictionary error:&error];
    
    XCTAssertNil(error);
    XCTAssertNotNil(rasAcuteEnvironmentSymptomsSurveyTask);
    XCTAssertTrue([NSStringFromClass([rasAcuteEnvironmentSymptomsSurveyTask class]) isEqualToString:NSStringFromClass([ORKNavigableOrderedTask class])]);
    XCTAssertTrue([self _totalMatchesInStepsForClass:[ORKIdBHLToneAudiometryStep class] step:rasAcuteEnvironmentSymptomsSurveyTask.steps] == 2);
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
