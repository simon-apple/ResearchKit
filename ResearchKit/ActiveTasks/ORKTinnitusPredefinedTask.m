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

#import "ORKTinnitusPredefinedTask.h"
#import "ORKContext.h"
#import "ORKTinnitusPredefinedTaskConstants.h"
#import "ORKTinnitusPureToneStep.h"
#import "ORKTinnitusCalibrationStep.h"
#import "ORKTinnitusTypeStep.h"
#import "ORKTinnitusMaskingSoundStep.h"
#import "ORKTinnitusLoudnessMatchingStep.h"
#import "ORKTinnitusWhiteNoiseMatchingSoundStep.h"
#import "ORKTinnitusTypeResult.h"
#import "ORKTinnitusAudioSample.h"
#import <ResearchKit/ResearchKit_Private.h>

static NSString *const ORKTinnitusTestingInstructionStepIdentifier = @"tinnitus.instruction.2";
static NSString *const ORKTinnitusHeadphoneDetectStepIdentifier = @"tinnitus.headphonedetect";
static NSString *const ORKTinnitusSPLMeterStepIdentifier = @"tinnitus.splmeter";
static NSString *const ORKTinnitusTypeStepIdentifier = @"tinnitus.type";
static NSString *const ORKTinnitusVolumeCalibrationStepIdentifier = @"tinnitus.volume.calibration";
static NSString *const ORKTinnitusRound1StepIdentifier = @"tinnitus.puretone.1";
static NSString *const ORKTinnitusRound1SuccessCompletedStepIdentifier = @"tinnitus.puretone.success.roundcomplete.1";
static NSString *const ORKTinnitusRound1NoSuccessCompletedStepIdentifier = @"tinnitus.puretone.no.success.roundcomplete.1";
static NSString *const ORKTinnitusRound2StepIdentifier = @"tinnitus.puretone.2";
static NSString *const ORKTinnitusRound2SuccessCompletedStepIdentifier = @"tinnitus.puretone.success.roundcomplete.2";
static NSString *const ORKTinnitusRound2NoSuccessCompletedStepIdentifier = @"tinnitus.puretone.no.success.roundcomplete.2";
static NSString *const ORKTinnitusRound3StepIdentifier = @"tinnitus.puretone.3";
static NSString *const ORKTinnitusPuretoneNoSuccessStepIdentifier = @"tinnitus.puretone.no.success";
static NSString *const ORKTinnitusPuretoneSuccessStepIdentifier = @"tinnitus.puretone.success";
static NSString *const ORKTinnitusLoudnessMatchingStepIdentifier = @"tinnitus.loudness.matching";
static NSString *const ORKTinnitusSoundLoudnessMatchingStepIdentifier = @"tinnitus.soundloudness.matching";
static NSString *const ORKTinnitusMaskingCampfireIdentifier = @"tinnitus.masking.fire";
static NSString *const ORKTinnitusMaskingCampfireNotchIdentifier = @"tinnitus.masking.fire.notch";
static NSString *const ORKTinnitusMaskingWhiteNoiseIdentifier = @"tinnitus.masking.whitenoise";
static NSString *const ORKTinnitusMaskingWhiteNoiseNotchIdentifier = @"tinnitus.masking.whitenoise.notch";
static NSString *const ORKTinnitusMaskingRainIdentifier = @"tinnitus.masking.rain";
static NSString *const ORKTinnitusMaskingRainNotchIdentifier = @"tinnitus.masking.rain.notch";
static NSString *const ORKTinnitusMaskingForestIdentifier = @"tinnitus.masking.forest";
static NSString *const ORKTinnitusMaskingForestNotchIdentifier = @"tinnitus.masking.forest.notch";
static NSString *const ORKTinnitusMaskingOceanIdentifier = @"tinnitus.masking.ocean";
static NSString *const ORKTinnitusMaskingOceanNotchIdentifier = @"tinnitus.masking.ocean.notch";
static NSString *const ORKTinnitusMaskingCrowdIdentifier = @"tinnitus.masking.crowd";
static NSString *const ORKTinnitusMaskingCrowdNotchIdentifier = @"tinnitus.masking.crowd.notch";
static NSString *const ORKTinnitusMaskingAudiobookIdentifier = @"tinnitus.masking.audiobook";
static NSString *const ORKTinnitusMaskingAudiobookNotchIdentifier = @"tinnitus.masking.audiobook.notch";
static NSString *const ORKTinnitusWhiteNoiseMatchingIdentifier = @"tinnitus.whitenoise.matching";
static NSString *const ORKTinnitusPitchMatchingStepIdentifier = @"tinnitus.instruction.5";

@interface NSMutableArray (Shuffling)
- (void)shuffle;
@end

@implementation NSMutableArray (Shuffling)

- (void)shuffle {
    NSUInteger count = [self count];
    if (count <= 1) return;
    for (NSUInteger i = 0; i < count - 1; ++i) {
        NSInteger remainingCount = count - i;
        NSInteger exchangeIndex = i + arc4random_uniform((u_int32_t )remainingCount);
        [self exchangeObjectAtIndex:i withObjectAtIndex:exchangeIndex];
    }
}

@end

@interface ORKTinnitusPredefinedTask () {
    ORKTinnitusPredefinedTaskContext *_context;
    
    NSDictionary *_stepAfterStepDict;
    NSArray<NSArray <ORKTinnitusMaskingSoundStep*>*> *_maskingSteps;

    ORKTinnitusType _type;
    ORKTinnitusNoiseType _noiseType;
    double _predominantFrequency;
}

@end

@implementation ORKTinnitusPredefinedTaskContext

@end

@implementation ORKTinnitusPredefinedTask

#pragma mark - Initialization

- (instancetype)initWithIdentifier:(nonnull NSString *)identifier
              audioSetManifestPath:(nonnull NSString *)audioSetManifestPath
                      prependSteps:(nullable NSArray<ORKStep *> *)prependSteps
                       appendSteps:(nullable NSArray<ORKStep *> *)appendSteps {

    NSError *error = nil;
    
    ORKTinnitusAudioManifest *manifest = [ORKTinnitusPredefinedTask prefetchAudioSamplesFromManifest:audioSetManifestPath error:&error];
    
    if (error)
    {
        ORK_Log_Error("An error occurred while fetching audio assets. %@", error);
        return nil;
    }
    
    NSArray<ORKStep *> *steps = [ORKTinnitusPredefinedTask tinnitusPredefinedStepsWithPrependSteps:prependSteps appendSteps:appendSteps];

    self = [super initWithIdentifier:identifier steps:steps];
    if (self) {
        _audioSetManifestPath = [audioSetManifestPath copy];
        _prependSteps = [prependSteps copy];
        _appendSteps = [appendSteps copy];

        _context = [[ORKTinnitusPredefinedTaskContext alloc] init];
        _context.audioManifest = manifest;
        
        for (ORKStep *step in self.steps)
        {
            if ([step isKindOfClass:[ORKStep class]])
            {
                [step setTask:self];
                [step setContext:_context];
            }
        }
    }
    return self;
    
}

- (instancetype)initWithIdentifier:(NSString *)identifier steps:(nullable NSArray<ORKStep *> *)steps
{
    ORKThrowMethodUnavailableException();
}

#pragma mark - NSSecureCoding

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder];
    ORK_ENCODE_OBJ(aCoder, audioSetManifestPath);
    ORK_ENCODE_OBJ(aCoder, prependSteps);
    ORK_ENCODE_OBJ(aCoder, appendSteps);
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        ORK_DECODE_OBJ_CLASS(aDecoder, audioSetManifestPath, NSString);
        ORK_DECODE_OBJ_ARRAY(aDecoder, prependSteps, ORKStep);
        ORK_DECODE_OBJ_ARRAY(aDecoder, appendSteps, ORKStep);
    }
    return self;
}

#pragma mark - ORKTinnitus Predefined Task Creation

+ (NSArray<ORKStep *> *)tinnitusPredefinedStepsWithPrependSteps:(NSArray<ORKStep *> *)prependSteps
                                                    appendSteps:(NSArray<ORKStep *> *)appendSteps
{
    NSMutableArray<ORKStep *> *steps = [[NSMutableArray alloc] init];
    
    if (prependSteps.count > 0)
    {
        [steps addObjectsFromArray:[prependSteps copy]];
    }
    
    NSArray *predefinedSteps = [ORKTinnitusPredefinedTask tinnitusPredefinedTaskSteps];

    if (predefinedSteps != nil)
    {
        [steps addObjectsFromArray:predefinedSteps];
    }
    if (appendSteps.count > 0)
    {
        [steps addObjectsFromArray:[appendSteps copy]];
    }
    
    return [steps copy];
}

+ (NSArray<ORKStep *> *)tinnitusPredefinedTaskSteps {
        
    NSMutableArray<ORKStep *> *steps = [[NSMutableArray alloc] init];
    
    [steps addObjectsFromArray:@[[self headphone],
                                 [self splmeter],
                                 [self tinnitusType],
                                 [self calibration],
                                 [self pitchMatching]]];
    
    return [steps copy];
}

+ (nullable ORKTinnitusAudioManifest *)prefetchAudioSamplesFromManifest:(nonnull NSString *)path error:(NSError * _Nullable * _Nullable)error
{
    NSArray *maskingSoundSamples = [ORKTinnitusPredefinedTask prefetchAudioSamplesFromManifestAtPath:path withKey:@"maskingSounds" error:error];
    NSArray *noiseTypeSamples = [ORKTinnitusPredefinedTask prefetchAudioSamplesFromManifestAtPath:path withKey:@"noiseTypes" error:error];

    if (maskingSoundSamples && noiseTypeSamples)
    {
        return [ORKTinnitusAudioManifest manifestWithMaskingSamples:maskingSoundSamples noiseTypeSamples:noiseTypeSamples];
    }
    
    return nil;
}

+ (nullable NSArray<ORKTinnitusAudioSample *> *)prefetchAudioSamplesFromManifestAtPath:(nonnull NSString *)path withKey:(nonnull NSString *)key error:(NSError * _Nullable * _Nullable)error
{
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    
    if (![fileManager fileExistsAtPath:path])
    {
        if (error != NULL)
        {
            *error = [NSError errorWithDomain:ORKErrorDomain
                                         code:ORKErrorException
                                     userInfo:@{NSLocalizedFailureReasonErrorKey: [NSString stringWithFormat:@"Could not locate file at path %@", path]}];
        }
        return nil;
    }
    
    NSData *data = [NSData dataWithContentsOfFile:path options:0 error:error];
    if (!data)
    {
        return nil;
    }
    
    NSDictionary *manifest = [NSJSONSerialization JSONObjectWithData:data options:0 error:error];
    if (!manifest)
    {
        return nil;
    }
    
    NSString *parentDirectory = [path stringByDeletingLastPathComponent];
    BOOL isDir;
    if (![fileManager fileExistsAtPath:parentDirectory isDirectory:&isDir] || !isDir)
    {
        if (error != NULL)
        {
            *error = [NSError errorWithDomain:ORKErrorDomain
                                         code:ORKErrorException
                                     userInfo:@{NSLocalizedFailureReasonErrorKey: [NSString stringWithFormat:@"Could not locate parent directory at path %@", parentDirectory]}];
        }
        return nil;
    }
    
//    NSString * const ManifestJSONKeyAudioFilename = @"filename";
//    NSString * const ManifestJSONKeyName = @"name";
//
//    NSMutableArray<ORKTinnitusAudioSample *> *audioFileSamples = [[NSMutableArray alloc] init];
//
//    __block BOOL success;
//    __block NSError *err;
//    [manifest enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//
//        NSString *audioFilename = (NSString *)[obj objectForKey:ManifestJSONKeyAudioFilename];
//        NSString *audioFilePath = [parentDirectory stringByAppendingPathComponent:audioFilename];
//        NSString *audioFileName = (NSString *)[obj objectForKey:ManifestJSONKeyName];
//
//        if ([fileManager fileExistsAtPath:audioFilePath])
//        {
//            [audioFileSamples addObject:[ORKTinnitusAudioSample sampleWithPath:audioFilePath name:audioFileName]];
//            success = YES;
//        }
//        else
//        {
//            *stop = YES;
//            err = [NSError errorWithDomain:ORKErrorDomain
//                                      code:ORKErrorException
//                                  userInfo:@{NSLocalizedFailureReasonErrorKey: [NSString stringWithFormat:@"Could not locate file at path %@", audioFilePath]}];
//            success = NO;
//        }
//    }];
//
//    if (success)
//    {
//        return [audioFileSamples copy];
//    }
//    else
//    {
//        if (error != NULL)
//        {
//            *error = err;
//        }
//        return nil;
//    }
    return nil;
}

#pragma mark - NSCopying

- (instancetype)copyWithZone:(NSZone *)zone
{
    return [[[self class] allocWithZone:zone] initWithIdentifier:[self.identifier copy]
                                            audioSetManifestPath:[self.audioSetManifestPath copy]
                                                     prependSteps:[[NSArray alloc] initWithArray:self.prependSteps copyItems:YES]
                                                      appendSteps:[[NSArray alloc] initWithArray:self.appendSteps copyItems:YES]];
}

- (BOOL)isEqual:(id)object
{
    __typeof(self) castObject = object;
    
    return
    [super isEqual:object] &&
    [self.audioSetManifestPath isEqualToString:castObject.audioSetManifestPath] &&
    [self.prependSteps isEqualToArray:castObject.prependSteps] &&
    [self.appendSteps isEqualToArray:castObject.appendSteps];
}

- (NSUInteger)hash
{
    return [super hash] ^ [_audioSetManifestPath hash] ^ [_prependSteps hash] ^ [_appendSteps hash];
}

#pragma mark - Task Methods

- (ORKStep *)prependedStepAfterStep:(ORKStep *)step {
    ORKStep *firstPredefinedStep = [ORKTinnitusPredefinedTask splmeter];
    
    if (step == nil) {
        ORKStep *firstPrependedStep = [_prependSteps firstObject];
        if (firstPrependedStep) {
            return firstPrependedStep;
        }
        return firstPredefinedStep;
    } else {
        NSUInteger currentPrependedStepIndex = [_prependSteps indexOfObject:step];
        if (_prependSteps && currentPrependedStepIndex != NSNotFound) {
            if (currentPrependedStepIndex+1 < [_prependSteps count]) {
                return [_prependSteps objectAtIndex:currentPrependedStepIndex+1];
            } else {
                return firstPredefinedStep;
            }
        }
        return nil;
    }
}

- (ORKStep *)apendedStepAfterStep:(ORKStep *)step {
    ORKStep *completionStep = [self completionSuccess];
    NSUInteger currentApendedStepIndex = [_appendSteps indexOfObject:step];
    
    if (_appendSteps && currentApendedStepIndex == NSNotFound) {
        ORKStep *firstApendedStep = [_appendSteps firstObject];
        if (firstApendedStep) {
            return firstApendedStep;
        }
        return completionStep;
    } else {
        if (currentApendedStepIndex+1 < [_appendSteps count]) {
            return [_prependSteps objectAtIndex:currentApendedStepIndex+1];
        } else if (![step.identifier isEqualToString:ORKTinnitusPuretoneSuccessStepIdentifier]) {
            return completionStep;
        }
        return nil;
    }
}

- (ORKStep *)dynamicStepAfterStep:(ORKStep *)step withResult:(id<ORKTaskResultSource>)result {
    NSString *identifier = step.identifier;
    ORKStep *nextStep = _stepAfterStepDict[identifier];

    // cases that treats changes of flow
    if (!nextStep) {
        if ([identifier isEqualToString:ORKTinnitusWhiteNoiseMatchingIdentifier]) {
            if ([_type isEqualToString:ORKTinnitusTypeWhiteNoise]) {
                ORKStepResult *stepResult = [result stepResultForStepIdentifier:ORKTinnitusWhiteNoiseMatchingIdentifier];
                ORKTinnitusWhiteNoiseMatchingSoundResult *questionResult = (ORKTinnitusWhiteNoiseMatchingSoundResult *)(stepResult.results.count > 0 ? stepResult.results.firstObject : nil);
                NSString *answer = questionResult.answer;
                if (answer != nil) {
                    _noiseType = answer;
                } else {
                    return [self loudnessMatching];
                }
            }
            if ([self checkValidMaskingSound:_noiseType]) {
                return [self soundLoudnessMatching];
            }
            return nil;
        } else if ([identifier isEqualToString:ORKTinnitusSPLMeterStepIdentifier]) {
#if TARGET_IPHONE_SIMULATOR
            return [ORKTinnitusPredefinedTask tinnitusType];
#else
            return [ORKTinnitusPredefinedTask headphone];
#endif
        } else if ([identifier isEqualToString:ORKTinnitusVolumeCalibrationStepIdentifier]) {
            ORKStepResult *stepResult = [result stepResultForStepIdentifier:ORKTinnitusTypeStepIdentifier];
            ORKTinnitusTypeResult *questionResult = (ORKTinnitusTypeResult *)(stepResult.results.count > 0 ? stepResult.results.firstObject : nil);
            if (questionResult.type != nil) {
                _type = questionResult.type;
                if ([questionResult.type isEqualToString:ORKTinnitusTypePureTone]) {
                    return [ORKTinnitusPredefinedTask pitchMatching];
                }
            }
            return [ORKTinnitusPredefinedTask whiteNoiseMatching];
        } else if ([identifier isEqualToString:ORKTinnitusRound3StepIdentifier]) {
            _predominantFrequency = [self predominantFrequencyForResult:result];
            if (_predominantFrequency > 0.0) {
                return [self loudnessMatching];
            }
            return [self stepForMaskingSoundNumber:0];
        } else if ([identifier isEqualToString:ORKTinnitusLoudnessMatchingStepIdentifier] ||
                   [identifier isEqualToString:ORKTinnitusSoundLoudnessMatchingStepIdentifier]) {
            return [self stepForMaskingSoundNumber:0];
        } else if ([identifier isEqualToString:ORKTinnitusPuretoneSuccessStepIdentifier]) {
            return nil;
        }
        
        nextStep = [self nextMaskingStepForIdentifier:identifier];
    }
    
    return nextStep;
}

- (ORKStep *)stepAfterStep:(ORKStep *)step withResult:(id<ORKTaskResultSource>)result {
    if (step == nil) {
        [self setupStraightStepAfterStepDict];
    }
    
    ORKStep *prependedStep = [self prependedStepAfterStep:step];
    if (prependedStep) {
        return prependedStep;
    }
    
    ORKStep *nextStep = [self dynamicStepAfterStep:step withResult:result];
    nextStep.context = _context;

    if (nextStep) {
        return nextStep;
    }
    
    return [self apendedStepAfterStep:step];
}

- (void)initMaskingSteps {
    NSMutableArray<ORKStep *> *steps =
        [[NSMutableArray alloc] initWithObjects:
            @[[self maskingSoundStepForIdentifier:ORKTinnitusMaskingCampfireIdentifier
                                   maskingSoundType:ORKTinnitusMaskingSoundTypeCampfire
                                            isNotch:NO],
                [self maskingSoundStepForIdentifier:ORKTinnitusMaskingCampfireNotchIdentifier
                                   maskingSoundType:ORKTinnitusMaskingSoundTypeCampfire
                                            isNotch:YES]],
             @[[self maskingSoundStepForIdentifier:ORKTinnitusMaskingWhiteNoiseIdentifier
                                  maskingSoundType:ORKTinnitusMaskingSoundTypeWhiteNoise
                                           isNotch:NO],
               [self maskingSoundStepForIdentifier:ORKTinnitusMaskingWhiteNoiseNotchIdentifier
                                  maskingSoundType:ORKTinnitusMaskingSoundTypeWhiteNoise
                                           isNotch:YES]],
             @[[self maskingSoundStepForIdentifier:ORKTinnitusMaskingRainIdentifier
                                  maskingSoundType:ORKTinnitusMaskingSoundTypeRain
                                           isNotch:NO],
               [self maskingSoundStepForIdentifier:ORKTinnitusMaskingRainNotchIdentifier
                                  maskingSoundType:ORKTinnitusMaskingSoundTypeRain
                                           isNotch:YES]],
             @[[self maskingSoundStepForIdentifier:ORKTinnitusMaskingForestIdentifier
                                  maskingSoundType:ORKTinnitusMaskingSoundTypeForest
                                           isNotch:NO],
               [self maskingSoundStepForIdentifier:ORKTinnitusMaskingForestNotchIdentifier
                                  maskingSoundType:ORKTinnitusMaskingSoundTypeForest
                                           isNotch:YES]],
             @[[self maskingSoundStepForIdentifier:ORKTinnitusMaskingOceanIdentifier
                                  maskingSoundType:ORKTinnitusMaskingSoundTypeOcean
                                           isNotch:NO],
               [self maskingSoundStepForIdentifier:ORKTinnitusMaskingOceanNotchIdentifier
                                  maskingSoundType:ORKTinnitusMaskingSoundTypeOcean
                                           isNotch:YES]],
             @[[self maskingSoundStepForIdentifier:ORKTinnitusMaskingCrowdIdentifier
                                  maskingSoundType:ORKTinnitusMaskingSoundTypeCrowd
                                           isNotch:NO],
               [self maskingSoundStepForIdentifier:ORKTinnitusMaskingCrowdNotchIdentifier
                                  maskingSoundType:ORKTinnitusMaskingSoundTypeCrowd
                                           isNotch:YES]],
             @[[self maskingSoundStepForIdentifier:ORKTinnitusMaskingAudiobookIdentifier
                                  maskingSoundType:ORKTinnitusMaskingSoundTypeAudiobook
                                           isNotch:NO],
               [self maskingSoundStepForIdentifier:ORKTinnitusMaskingAudiobookNotchIdentifier
                                  maskingSoundType:ORKTinnitusMaskingSoundTypeAudiobook
                                           isNotch:YES]], nil];
    [steps shuffle];
    
    _maskingSteps = [steps copy];
}

- (void)setupStraightStepAfterStepDict {
    [self initMaskingSteps];
    _stepAfterStepDict = @{
        ORKTinnitusHeadphoneDetectStepIdentifier: [ORKTinnitusPredefinedTask tinnitusType],
        ORKTinnitusTypeStepIdentifier: [ORKTinnitusPredefinedTask calibration],
        ORKTinnitusPitchMatchingStepIdentifier: [ORKTinnitusPredefinedTask round1],
        ORKTinnitusRound1StepIdentifier: [ORKTinnitusPredefinedTask round1SuccessCompleted],
        ORKTinnitusRound1SuccessCompletedStepIdentifier: [ORKTinnitusPredefinedTask round2],
        ORKTinnitusRound2StepIdentifier: [ORKTinnitusPredefinedTask round2SuccessCompleted],
        ORKTinnitusRound2SuccessCompletedStepIdentifier: [ORKTinnitusPredefinedTask round3]
    };
}

- (double)predominantFrequency {
    return _predominantFrequency;
}

- (nullable ORKTinnitusMaskingSoundStep *)stepForMaskingSoundNumber:(NSUInteger)index {
    if (index < _maskingSteps.count) {
        return _maskingSteps[index][0];
    }
    return nil;
}

- (nullable ORKTinnitusMaskingSoundStep *)stepForNotchMaskingSoundNumber:(NSUInteger)index {
    if (index < _maskingSteps.count) {
        return _maskingSteps[index][1];
    }
    return nil;
}

- (nullable ORKTinnitusMaskingSoundStep *)nextMaskingStepForIdentifier:(NSString *)identifier {
    __block NSUInteger index = 0;
    [_maskingSteps objectsAtIndexes:[_maskingSteps indexesOfObjectsPassingTest:^BOOL(NSArray <ORKTinnitusMaskingSoundStep *> *steps, NSUInteger idx, BOOL *stop) {
        if ([steps[0].identifier isEqualToString:identifier] ||
            [steps[1].identifier isEqualToString:identifier]) {
            index = idx;
            *stop = YES;
            return YES;
        }
        return NO;
    }]];
    if ([identifier isEqualToString:[self stepForMaskingSoundNumber:index].identifier]) {
        if (_predominantFrequency > 0.0) {
            ORKTinnitusMaskingSoundStep *maskingSoundStep = [self stepForNotchMaskingSoundNumber:index];
            maskingSoundStep.notchFrequency = _predominantFrequency;
            return maskingSoundStep;
        }
        return [self stepForMaskingSoundNumber:index+1];
    } else if ([identifier isEqualToString:[self stepForNotchMaskingSoundNumber:index].identifier]) {
        return [self stepForMaskingSoundNumber:index+1];
    }
    return nil;
}

- (BOOL)checkValidMaskingSound:(ORKTinnitusNoiseType)type {
    return [type isEqualToString:ORKTinnitusNoiseTypeCicadas]
    || [type isEqualToString:ORKTinnitusNoiseTypeCrickets]
    || [type isEqualToString:ORKTinnitusNoiseTypeWhiteNoise]
    || [type isEqualToString:ORKTinnitusNoiseTypeTeakettle];
}

- (double)predominantFrequencyForResult:(id<ORKTaskResultSource>)result {
    ORKStepResult *stepResult = [result stepResultForStepIdentifier:ORKTinnitusRound1StepIdentifier];
    ORKTinnitusPureToneResult *round1Result = (ORKTinnitusPureToneResult *)(stepResult.results.count > 0 ? stepResult.results.firstObject : nil);
    stepResult = [result stepResultForStepIdentifier:ORKTinnitusRound2StepIdentifier];
    ORKTinnitusPureToneResult *round2Result = (ORKTinnitusPureToneResult *)(stepResult.results.count > 0 ? stepResult.results.firstObject : nil);
    stepResult = [result stepResultForStepIdentifier:ORKTinnitusRound3StepIdentifier];
    ORKTinnitusPureToneResult *round3Result = (ORKTinnitusPureToneResult *)(stepResult.results.count > 0 ? stepResult.results.firstObject : nil);
    
    NSNumber *predominantFrequency;
    
    if (round3Result) {
        NSNumber *round1ChosenFrequency = [NSNumber numberWithDouble:round1Result.chosenFrequency];
        NSNumber *round2ChosenFrequency = [NSNumber numberWithDouble:round2Result.chosenFrequency];
        NSNumber *round3ChosenFrequency = [NSNumber numberWithDouble:round3Result.chosenFrequency];
        NSArray *resultChosenFrequencies = [NSArray arrayWithObjects:round1ChosenFrequency, round2ChosenFrequency, round3ChosenFrequency, nil];
        
        NSCountedSet *set = [[NSCountedSet alloc] initWithArray:resultChosenFrequencies];
        
        for (NSNumber* freq in set) {
            if ([set countForObject:freq] > 1) {
                predominantFrequency = freq;
            }
        }
    }
    
    return predominantFrequency ? [predominantFrequency doubleValue] : 0.0;
}

// Explicitly hide progress indication for all steps in this dynamic task.
- (ORKTaskProgress)progressOfCurrentStep:(ORKStep *)step withResultProvider:(NSArray *)surveyResults {
    return (ORKTaskProgress){.total = 0, .current = 0};
}

#pragma mark - Steps

+ (ORKHeadphoneDetectStep *)headphone {
    
    ORKHeadphoneDetectStep *headphone = [[ORKHeadphoneDetectStep alloc] initWithIdentifier:ORKTinnitusHeadphoneDetectStepIdentifier headphoneTypes:ORKHeadphoneTypesSupported];
    headphone.title = ORKLocalizedString(@"HEADPHONE_DETECT_TITLE", nil);
    headphone.detailText = ORKLocalizedString(@"HEADPHONE_DETECT_TEXT", nil);
    
    return [headphone copy];
}

+ (ORKEnvironmentSPLMeterStep *)splmeter {
    
    ORKEnvironmentSPLMeterStep *splmeter = [[ORKEnvironmentSPLMeterStep alloc] initWithIdentifier:ORKTinnitusSPLMeterStepIdentifier];
    splmeter.requiredContiguousSamples = 5;
    splmeter.thresholdValue = 45;//27.9; TODO: review the value with engineers.
    splmeter.title = ORKLocalizedString(@"ENVIRONMENTSPL_TITLE_2", nil);
    splmeter.text = ORKLocalizedString(@"ENVIRONMENTSPL_INTRO_TEXT_2", nil);
    
    return [splmeter copy];
}

+ (ORKTinnitusTypeStep *)tinnitusType {
    
    ORKTinnitusTypeStep *tinnitusType = [ORKTinnitusTypeStep stepWithIdentifier:ORKTinnitusTypeStepIdentifier
                                                                          title:ORKLocalizedString(@"TINNITUS_KIND_TITLE", nil)
                                                                      frequency:ORKTinnitusTypeDefaultFrequency];
    tinnitusType.text = ORKLocalizedString(@"TINNITUS_KIND_DETAIL", nil);
    tinnitusType.optional = NO;
    return [tinnitusType copy];
}

+ (ORKTinnitusCalibrationStep *)calibration {
    
    ORKTinnitusCalibrationStep *calibration = [[ORKTinnitusCalibrationStep alloc] initWithIdentifier:ORKTinnitusVolumeCalibrationStepIdentifier];
    calibration.title = ORKLocalizedString(@"TINNITUS_CALIBRATION_TITLE", nil);
    calibration.text = ORKLocalizedString(@"TINNITUS_CALIBRATION_TEXT", nil);
    return [calibration copy];
}

+ (ORKInstructionStep *)pitchMatching {
    ORKInstructionStep *pitchMatching = [[ORKInstructionStep alloc] initWithIdentifier:ORKTinnitusPitchMatchingStepIdentifier];
    pitchMatching.title = ORKLocalizedString(@"TINNITUS_FREQUENCY_MATCHING_TITLE", nil);
    pitchMatching.text = ORKLocalizedString(@"TINNITUS_FREQUENCY_MATCHING_DETAIL", nil);
    
    ORKBodyItem *item = [[ORKBodyItem alloc] initWithText:ORKLocalizedString(@"TINNITUS_VOLUME_ADJUST_TEXT", nil) detailText:nil image:nil learnMoreItem:nil bodyItemStyle:ORKBodyItemStyleBulletPoint];
    pitchMatching.bodyItems = @[item];

    return [pitchMatching copy];
}

+ (ORKTinnitusPureToneStep *)round1 {
    ORKTinnitusPureToneStep *round1 = [[ORKTinnitusPureToneStep alloc] initWithIdentifier:ORKTinnitusRound1StepIdentifier];
    round1.title = ORKLocalizedString(@"TINNITUS_PURETONE_TITLE2", nil);
    round1.detailText = ORKLocalizedString(@"TINNITUS_PURETONE_TEXT", nil);
    round1.roundNumber = 1;
    return [round1 copy];
}

+ (ORKInstructionStep *)round1SuccessCompleted {
    ORKInstructionStep *round1SuccessCompleted = [[ORKInstructionStep alloc] initWithIdentifier:ORKTinnitusRound1SuccessCompletedStepIdentifier];
    round1SuccessCompleted.title = ORKLocalizedString(@"TINNITUS_ROUND_COMPLETE_TITLE", nil);
    round1SuccessCompleted.text = ORKLocalizedString(@"TINNITUS_ROUND_COMPLETE_TEXT", nil);
    round1SuccessCompleted.detailText = ORKLocalizedString(@"TINNITUS_ROUND_COMPLETE_DETAIL", nil);
    
    UIImage *iconImage;
    if (@available(iOS 13.0, *)) {
        UIImageConfiguration *configuration = [UIImageSymbolConfiguration configurationWithFont:[UIFont preferredFontForTextStyle:UIFontTextStyleBody] scale:UIImageSymbolScaleLarge];
        iconImage = [UIImage systemImageNamed:@"checkmark.circle.fill" withConfiguration:configuration];
    } else {
        iconImage = [[UIImage imageNamed:@"checkmark" inBundle:ORKBundle() compatibleWithTraitCollection:nil] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    }
    round1SuccessCompleted.iconImage = iconImage;
    round1SuccessCompleted.imageContentMode = UIViewContentModeTopLeft;
    round1SuccessCompleted.shouldTintImages = YES;
    return [round1SuccessCompleted copy];
}

+ (ORKTinnitusPureToneStep *)round2 {
    ORKTinnitusPureToneStep *round2 = [[ORKTinnitusPureToneStep alloc] initWithIdentifier:ORKTinnitusRound2StepIdentifier];
    round2.title = ORKLocalizedString(@"TINNITUS_PURETONE_TITLE2", nil);
    round2.detailText = ORKLocalizedString(@"TINNITUS_PURETONE_TEXT", nil);
    round2.roundNumber = 2;
    return [round2 copy];
}

+ (ORKInstructionStep *)round2SuccessCompleted {
    ORKInstructionStep *round2SuccessCompleted = [[ORKInstructionStep alloc] initWithIdentifier:ORKTinnitusRound2SuccessCompletedStepIdentifier];
    round2SuccessCompleted.title = ORKLocalizedString(@"TINNITUS_ROUND_COMPLETE_TITLE", nil);
    round2SuccessCompleted.text = ORKLocalizedString(@"TINNITUS_ROUND_COMPLETE_TEXT", nil);
    round2SuccessCompleted.detailText = ORKLocalizedString(@"TINNITUS_ROUND_COMPLETE_DETAIL", nil);
    UIImage *iconImage;
    if (@available(iOS 13.0, *)) {
        UIImageConfiguration *configuration = [UIImageSymbolConfiguration configurationWithFont:[UIFont preferredFontForTextStyle:UIFontTextStyleBody] scale:UIImageSymbolScaleLarge];
        iconImage = [UIImage systemImageNamed:@"checkmark.circle.fill" withConfiguration:configuration];
    } else {
        iconImage = [[UIImage imageNamed:@"checkmark" inBundle:ORKBundle() compatibleWithTraitCollection:nil] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    }
    round2SuccessCompleted.iconImage = iconImage;
    round2SuccessCompleted.imageContentMode = UIViewContentModeTopLeft;
    round2SuccessCompleted.shouldTintImages = YES;
    return [round2SuccessCompleted copy];
}

+ (ORKTinnitusPureToneStep *)round3 {
    ORKTinnitusPureToneStep *round3 = [[ORKTinnitusPureToneStep alloc] initWithIdentifier:ORKTinnitusRound3StepIdentifier];
    round3.title = ORKLocalizedString(@"TINNITUS_PURETONE_TITLE2", nil);
    round3.detailText = ORKLocalizedString(@"TINNITUS_PURETONE_TEXT", nil);
    round3.roundNumber = 3;
    return [round3 copy];
}

- (ORKTinnitusLoudnessMatchingStep *)loudnessMatching {
    ORKTinnitusLoudnessMatchingStep *loudnessMatching = [[ORKTinnitusLoudnessMatchingStep alloc] initWithIdentifier:ORKTinnitusLoudnessMatchingStepIdentifier frequency:_predominantFrequency];
    loudnessMatching.title = ORKLocalizedString(@"TINNITUS_FINAL_CALIBRATION_TITLE", nil);
    loudnessMatching.text = ORKLocalizedString(@"TINNITUS_FINAL_CALIBRATION_TEXT", nil);
    return [loudnessMatching copy];
}

- (ORKTinnitusLoudnessMatchingStep *)soundLoudnessMatching {
    ORKTinnitusLoudnessMatchingStep *soundLoudnessMatching = [[ORKTinnitusLoudnessMatchingStep alloc] initWithIdentifier:ORKTinnitusSoundLoudnessMatchingStepIdentifier noiseType:_noiseType];
    soundLoudnessMatching.title = ORKLocalizedString(@"TINNITUS_FINAL_CALIBRATION_TITLE", nil);
    soundLoudnessMatching.text = ORKLocalizedString(@"TINNITUS_FINAL_CALIBRATION_TEXT", nil);
    return [soundLoudnessMatching copy];
}

+ (ORKTinnitusWhiteNoiseMatchingSoundStep *)whiteNoiseMatching {
    ORKTinnitusWhiteNoiseMatchingSoundStep *whitenoiseMatching = [[ORKTinnitusWhiteNoiseMatchingSoundStep alloc]
                                                       initWithIdentifier:ORKTinnitusWhiteNoiseMatchingIdentifier];
    whitenoiseMatching.title = ORKLocalizedString(@"TINNITUS_WHITENOISE_MATCHINGSOUND_TITLE", nil);
    whitenoiseMatching.text = ORKLocalizedString(@"TINNITUS_WHITENOISE_MATCHINGSOUND_TEXT", nil);
    whitenoiseMatching.shouldTintImages = YES;
    return [whitenoiseMatching copy];
}

- (ORKCompletionStep *)completionSuccess {
    ORKCompletionStep *completionSuccess = [[ORKCompletionStep alloc] initWithIdentifier:ORKTinnitusPuretoneSuccessStepIdentifier];
    NSString *title = ORKLocalizedString(@"TINNITUS_WHITENOISE_SUCCESS_TITLE", nil);
    NSString *text = ORKLocalizedString(@"TINNITUS_WHITENOISE_SUCCESS_TEXT", nil);
    if ([_type isEqualToString:ORKTinnitusTypePureTone]) {
        title = ORKLocalizedString(@"TINNITUS_PURETONE_SUCCESS_TITLE", nil);
        text = ORKLocalizedString(@"TINNITUS_PURETONE_SUCCESS_TEXT", nil);
    }
    completionSuccess.title = title;
    completionSuccess.text = text;
    completionSuccess.shouldTintImages = YES;
    return [completionSuccess copy];
}

#pragma mark - Masking Sounds Steps

- (ORKTinnitusMaskingSoundStep *)maskingSoundStepForIdentifier:(NSString *)identifier
                                              maskingSoundType:(NSString *)maskingSoundType isNotch:(BOOL)isNotch {
    ORKTinnitusMaskingSoundStep *maskingSoundStep;
    if (isNotch) {
        maskingSoundStep = [[ORKTinnitusMaskingSoundStep alloc]
                            initWithIdentifier:identifier
                            maskingSoundType:maskingSoundType
                            notchFrequency:_predominantFrequency];
    } else {
        maskingSoundStep = [[ORKTinnitusMaskingSoundStep alloc]
                                                    initWithIdentifier:identifier
                                                    maskingSoundType:maskingSoundType];
    }
    maskingSoundStep.title = ORKLocalizedString(@"TINNITUS_MASKING_TITLE", nil);
    maskingSoundStep.text = ORKLocalizedString(@"TINNITUS_MASKING_TEXT", nil);
    maskingSoundStep.shouldTintImages = YES;
    return [maskingSoundStep copy];
}

@end
