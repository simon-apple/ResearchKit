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
#import "ORKTinnitusPureToneStep.h"
#import "ORKVolumeCalibrationStep.h"
#import "ORKTinnitusTypeStep.h"
#import "ORKTinnitusMaskingSoundStep.h"
#import "ORKTinnitusTypeResult.h"
#import "ORKTinnitusAudioSample.h"
#import "ORKHeadphonesRequiredCompletionStep.h"
#import "ResearchKit_Private.h"

static NSString *const ORKTinnitusHeadphoneDetectStepIdentifier = @"tinnitus_headphonedetect";
static NSString *const ORKTinnitusHeadphonesRequiredStepIdentifier = @"tinnitus_headphone_required";
static NSString *const ORKTinnitusSPLMeterStepIdentifier = @"tinnitus_splmeter";
static NSString *const ORKTinnitusTypeStepIdentifier = @"tinnitus_type";
static NSString *const ORKTinnitusVolumeCalibrationStepIdentifier = @"tinnitus_volume_calibration";
static NSString *const ORKTinnitusRoundStepIdentifier = @"tinnitus_puretone";
static NSString *const ORKTinnitusRoundSuccessCompletedStepIdentifier = @"tinnitus_puretone_success_roundcomplete";
static NSString *const ORKTinnitusPuretoneSuccessStepIdentifier = @"tinnitus_puretone_success";
static NSString *const ORKTinnitusPuretoneLoudnessMatchingStepIdentifier = @"tinnitus_loudness_matching";
static NSString *const ORKTinnitusWhitenoiseLoudnessMatchingStepIdentifier = @"tinnitus_whitenoise_loudness_matching";
static NSString *const ORKTinnitusPitchMatchingInstructionStepIdentifier = @"tinnitus_pitch_matching_instruction";
static NSString *const ORKTinnitusMaskingSoundInstructionStepIdentifier = @"tinnitus_masking_sound_instruction";

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
    NSArray<ORKTinnitusMaskingSoundStep*> *_maskingSteps;
}

@end

@implementation ORKTinnitusPredefinedTaskContext

- (NSString *)didSkipHeadphoneDetectionStepForTask:(id<ORKTask>)task
{
    if ([task isKindOfClass:[ORKNavigableOrderedTask class]])
    {
        ORKHeadphonesRequiredCompletionStep *step = [[ORKHeadphonesRequiredCompletionStep alloc] initWithIdentifier:ORKTinnitusHeadphonesRequiredStepIdentifier requiredHeadphoneTypes:ORKHeadphoneTypesSupported];
        
        ORKNavigableOrderedTask *currentTask = (ORKNavigableOrderedTask *)task;
        [currentTask addStep:step];
        
        ORKDirectStepNavigationRule *endNavigationRule = [[ORKDirectStepNavigationRule alloc] initWithDestinationStepIdentifier:ORKNullStepIdentifier];
        [currentTask setNavigationRule:endNavigationRule forTriggerStepIdentifier:ORKTinnitusHeadphonesRequiredStepIdentifier];
        
        return ORKTinnitusHeadphonesRequiredStepIdentifier;
    }
    
    return nil;
}

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

    self = [super initWithIdentifier:identifier steps:nil];
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
    
    NSString * const ManifestJSONKeyAudioFilename = @"filename";
    NSString * const ManifestJSONKeyIdentifier = @"identifier";
    NSString * const ManifestJSONKeyName = @"name";
    NSString * const ManifestJSONKeyTinnitusType = @"tinnitusType";

    NSMutableArray<ORKTinnitusAudioSample *> *audioFileSamples = [[NSMutableArray alloc] init];

    __block BOOL success;
    __block NSError *err;
    [[manifest objectForKey:key] enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {

        NSString *audioIdentifier = (NSString *)[obj objectForKey:ManifestJSONKeyIdentifier];
        NSString *audioName = (NSString *)[obj objectForKey:ManifestJSONKeyName];
        NSString *audioFileName = (NSString *)[obj objectForKey:ManifestJSONKeyAudioFilename];
        NSString *audioFilePath = [parentDirectory stringByAppendingPathComponent:audioFileName];
        ORKTinnitusType audioType = (ORKTinnitusType)[[obj valueForKey:ManifestJSONKeyTinnitusType] integerValue];

        if ([fileManager fileExistsAtPath:audioFilePath])
        {
            [audioFileSamples addObject:[ORKTinnitusAudioSample sampleWithPath:audioFilePath name:audioName identifier:audioIdentifier type:audioType]];
            success = YES;
        }
        else
        {
            *stop = YES;
            err = [NSError errorWithDomain:ORKErrorDomain
                                      code:ORKErrorException
                                  userInfo:@{NSLocalizedFailureReasonErrorKey: [NSString stringWithFormat:@"Could not locate file at path %@", audioFilePath]}];
            success = NO;
        }
    }];

    if (success)
    {
        return [audioFileSamples copy];
    }
    else
    {
        if (error != NULL)
        {
            *error = err;
        }
        return nil;
    }
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
    
#if TARGET_IPHONE_SIMULATOR
    ORKStep *firstPredefinedStep = [ORKTinnitusPredefinedTask splmeter];
    _context.headphoneType = ORKHeadphoneTypeIdentifierAirPodsMax;
#else
    ORKStep *firstPredefinedStep = [ORKTinnitusPredefinedTask headphone];
#endif
    
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
    if (_appendSteps) {
        NSUInteger currentApendedStepIndex = [_appendSteps indexOfObject:step];

        if (currentApendedStepIndex == NSNotFound) {
            ORKStep *firstApendedStep = [_appendSteps firstObject];
            if (firstApendedStep) {
                return firstApendedStep;
            }
        } else if (currentApendedStepIndex+1 < [_appendSteps count]) {
            return [_appendSteps objectAtIndex:currentApendedStepIndex+1];
        }
    }
    return nil;
}

- (ORKStep *)dynamicStepAfterStep:(ORKStep *)step withResult:(id<ORKTaskResultSource>)result {
    NSString *identifier = step.identifier;
    ORKStep *nextStep = _stepAfterStepDict[identifier];
    
    // cases that treats changes of flow
    if (!nextStep) {
        if ([identifier isEqualToString:ORKTinnitusHeadphoneDetectStepIdentifier]) {
            ORKStepResult *stepResult = [result stepResultForStepIdentifier:ORKTinnitusHeadphoneDetectStepIdentifier];
            ORKHeadphoneDetectResult *headphoneResult = (ORKHeadphoneDetectResult *)(stepResult.results.count > 0 ? stepResult.results.firstObject : nil);
            ORKHeadphoneTypeIdentifier headphoneType = headphoneResult.headphoneType;
            if (headphoneType) {
                _context.headphoneType = headphoneType;
            }
            return [ORKTinnitusPredefinedTask splmeter];
        } else if ([identifier isEqualToString:ORKTinnitusTypeStepIdentifier]) {
            ORKStepResult *stepResult = [result stepResultForStepIdentifier:ORKTinnitusTypeStepIdentifier];
            ORKTinnitusTypeResult *typeResult = (ORKTinnitusTypeResult *)(stepResult.results.count > 0 ? stepResult.results.firstObject : nil);
            NSString *tinnitusIdentifier = typeResult.tinnitusIdentifier;
            ORKTinnitusType type = typeResult.type;
            if (tinnitusIdentifier != nil) {
                _context.type = type;
                _context.tinnitusIdentifier = tinnitusIdentifier;
                ORKStepResult *roundResult = [result stepResultForStepIdentifier:[self getRoundIdentifierForNumber:3]];
                if (_context.type == ORKTinnitusTypePureTone && !roundResult) {
                    return [self pitchMatchingInstruction];
                }
            } else {
                return nil;
            }
            return [self maskingSoundInstructionStep];
        } else if ([identifier isEqualToString:[self getRoundIdentifierForNumber:3]]) {
              _context.predominantFrequency = [self predominantFrequencyForResult:result];
              if (_context.predominantFrequency > 0.0) {
                  return [ORKTinnitusPredefinedTask puretoneLoudnessMatching];
              }
              return [self maskingSoundInstructionStep];
          } else if ([identifier isEqualToString:ORKTinnitusPuretoneLoudnessMatchingStepIdentifier] ||
                     [identifier isEqualToString:ORKTinnitusWhitenoiseLoudnessMatchingStepIdentifier]) {
              return [self maskingSoundInstructionStep];
          } else if ([identifier isEqualToString:ORKTinnitusMaskingSoundInstructionStepIdentifier]) {
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
    [prependedStep setTask:self];
    [prependedStep setContext:_context];
    if (prependedStep) {
        return prependedStep;
    }
    
    ORKStep *nextStep = [self dynamicStepAfterStep:step withResult:result];
    [nextStep setTask:self];
    [nextStep setContext:_context];
    if (nextStep) {
        return nextStep;
    }
    
    ORKStep *returnStep = [self apendedStepAfterStep:step];
    [returnStep setTask:self];
    [returnStep setContext:_context];
    return returnStep;
}

- (void)initMaskingSteps {
    NSMutableArray *steps = [[NSMutableArray alloc] init];
    
    for (ORKTinnitusAudioSample *sample in _context.audioManifest.maskingSamples) {
        [steps addObject:[self maskingSoundStepForIdentifier:sample.identifier name:sample.name soundIdentifier:sample.identifier ]];
    }
    
    [steps shuffle];
    
    _maskingSteps = [steps copy];
}

- (void)setupStraightStepAfterStepDict {
    [self initMaskingSteps];
    NSString *round1Identifier = [self getRoundIdentifierForNumber:1];
    NSString *round2Identifier = [self getRoundIdentifierForNumber:2];
    NSString *round1SuccessIdentifier = [self getRoundSuccessIdentifierForNumber:1];
    NSString *round2SuccessIdentifier = [self getRoundSuccessIdentifierForNumber:2];
    
    _stepAfterStepDict = @{
        ORKTinnitusSPLMeterStepIdentifier: [ORKTinnitusPredefinedTask calibration],
        ORKTinnitusVolumeCalibrationStepIdentifier: [ORKTinnitusPredefinedTask tinnitusType],
        ORKTinnitusPitchMatchingInstructionStepIdentifier: [self getPureToneRound:1],
        round1Identifier: [self getPureToneRoundComplete:1],
        round1SuccessIdentifier: [self getPureToneRound:2],
        round2Identifier: [self getPureToneRoundComplete:2],
        round2SuccessIdentifier: [self getPureToneRound:3]
    };
}

- (double)predominantFrequency {
    return _context.predominantFrequency;
}

- (nullable ORKTinnitusMaskingSoundStep *)stepForMaskingSoundNumber:(NSUInteger)index {
    if (index < _maskingSteps.count) {
        return _maskingSteps[index];
    }
    return nil;
}

- (nullable ORKTinnitusMaskingSoundStep *)nextMaskingStepForIdentifier:(NSString *)identifier {
    __block NSUInteger index = 0;
    [_maskingSteps objectsAtIndexes:[_maskingSteps indexesOfObjectsPassingTest:^BOOL(ORKTinnitusMaskingSoundStep *step, NSUInteger idx, BOOL *stop) {
        if ([step.identifier isEqualToString:identifier]) {
            index = idx;
            *stop = YES;
            return YES;
        }
        return NO;
    }]];
    if ([identifier isEqualToString:[self stepForMaskingSoundNumber:index].identifier]) {
        return [self stepForMaskingSoundNumber:index+1];
    }
    return nil;
}

- (BOOL)checkValidMatchingSound:(NSString *)type {
    BOOL isValid = NO;
    for (ORKTinnitusAudioSample *noiseTypeSample in _context.audioManifest.noiseTypeSamples) {
        if ( [type isEqualToString:noiseTypeSample.identifier] ) {
            isValid = YES;
        }
    }
    return isValid;
}

- (double)predominantFrequencyForResult:(id<ORKTaskResultSource>)result {
    ORKStepResult *stepResult = [result stepResultForStepIdentifier:[self getRoundIdentifierForNumber:1]];
    ORKTinnitusPureToneResult *round1Result = (ORKTinnitusPureToneResult *)(stepResult.results.count > 0 ? stepResult.results.firstObject : nil);
    stepResult = [result stepResultForStepIdentifier:[self getRoundIdentifierForNumber:2]];
    ORKTinnitusPureToneResult *round2Result = (ORKTinnitusPureToneResult *)(stepResult.results.count > 0 ? stepResult.results.firstObject : nil);
    stepResult = [result stepResultForStepIdentifier:[self getRoundIdentifierForNumber:3]];
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
    
    _context.predominantFrequency = predominantFrequency ? [predominantFrequency doubleValue] : 0.0;
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
    splmeter.thresholdValue = 55;
    splmeter.title = ORKLocalizedString(@"ENVIRONMENTSPL_TITLE_2", nil);
    splmeter.text = ORKLocalizedString(@"ENVIRONMENTSPL_INTRO_TEXT_2", nil);
    
    return [splmeter copy];
}

+ (ORKTinnitusTypeStep *)tinnitusType {
    ORKTinnitusTypeStep *tinnitusType = [[ORKTinnitusTypeStep alloc] initWithIdentifier:ORKTinnitusTypeStepIdentifier];
    tinnitusType.title = ORKLocalizedString(@"TINNITUS_TYPE_TITLE", nil);
    tinnitusType.text = ORKLocalizedString(@"TINNITUS_TYPE_DETAIL", nil);
    tinnitusType.optional = NO;
    return [tinnitusType copy];
}

+ (ORKVolumeCalibrationStep *)calibration {
    ORKVolumeCalibrationStep *calibration = [[ORKVolumeCalibrationStep alloc] initWithIdentifier:ORKTinnitusVolumeCalibrationStepIdentifier];
    calibration.title = ORKLocalizedString(@"TINNITUS_CALIBRATION_TITLE", nil);
    calibration.text = ORKLocalizedString(@"TINNITUS_CALIBRATION_TEXT", nil);
    return [calibration copy];
}

+ (ORKVolumeCalibrationStep *)puretoneLoudnessMatching {
    ORKVolumeCalibrationStep *puretoneLoudnessMatching = [[ORKVolumeCalibrationStep alloc] initWithIdentifier:ORKTinnitusPuretoneLoudnessMatchingStepIdentifier];
    puretoneLoudnessMatching.title = ORKLocalizedString(@"TINNITUS_FINAL_CALIBRATION_TITLE", nil);
    puretoneLoudnessMatching.text = ORKLocalizedString(@"TINNITUS_FINAL_CALIBRATION_TEXT", nil);
    return [puretoneLoudnessMatching copy];
}

+ (ORKVolumeCalibrationStep *)whitenoiseLoudnessMatching {
    ORKVolumeCalibrationStep *whitenoiseLoudnessMatching = [[ORKVolumeCalibrationStep alloc] initWithIdentifier:ORKTinnitusWhitenoiseLoudnessMatchingStepIdentifier];
    whitenoiseLoudnessMatching.title = ORKLocalizedString(@"TINNITUS_FINAL_CALIBRATION_TITLE", nil);
    whitenoiseLoudnessMatching.text = ORKLocalizedString(@"TINNITUS_FINAL_CALIBRATION_TEXT", nil);
    return [whitenoiseLoudnessMatching copy];
}

- (ORKInstructionStep *)pitchMatchingInstruction {
    ORKInstructionStep *pitchMatchingInstruction = [[ORKInstructionStep alloc] initWithIdentifier:ORKTinnitusPitchMatchingInstructionStepIdentifier];
    pitchMatchingInstruction.title = ORKLocalizedString(@"TINNITUS_FREQUENCY_MATCHING_TITLE", nil);
    pitchMatchingInstruction.text = ORKLocalizedString(@"TINNITUS_FREQUENCY_MATCHING_DETAIL", nil);
    
    if (@available(iOS 13.0, *)) {
        ORKBodyItem *item = [[ORKBodyItem alloc] initWithText:ORKLocalizedString(@"TINNITUS_VOLUME_ADJUST_TEXT", nil) detailText:nil image:[UIImage systemImageNamed:@"speaker.wave.3.fill"] learnMoreItem:nil bodyItemStyle:ORKBodyItemStyleImage];
        ORKBodyItem *item2 = [[ORKBodyItem alloc] initWithText:ORKLocalizedString(@"TINNITUS_VOLUME_ADJUST_TEXT2", nil) detailText:nil image:[UIImage systemImageNamed:@"timer"] learnMoreItem:nil bodyItemStyle:ORKBodyItemStyleImage];
        pitchMatchingInstruction.bodyItems = @[item,item2];
    }

    return [pitchMatchingInstruction copy];
}

- (NSString *)getRoundIdentifierForNumber:(NSInteger)roundNumber {
    return [NSString stringWithFormat:@"%@_%li",ORKTinnitusRoundStepIdentifier,(long)roundNumber];
}

- (NSString *)getRoundSuccessIdentifierForNumber:(NSInteger)roundNumber {
    return [NSString stringWithFormat:@"%@_%li",ORKTinnitusRoundSuccessCompletedStepIdentifier,(long)roundNumber];
}

- (ORKTinnitusPureToneStep *)getPureToneRound:(NSInteger)roundNumber {
    NSString *identifier = [self getRoundIdentifierForNumber:roundNumber];
    ORKTinnitusPureToneStep *round = [[ORKTinnitusPureToneStep alloc] initWithIdentifier:identifier];
    round.title = ORKLocalizedString(@"TINNITUS_PURETONE_TITLE", nil);
    round.detailText = ORKLocalizedString(@"TINNITUS_PURETONE_TEXT", nil);
    round.roundNumber = roundNumber;
    return [round copy];
}

- (ORKInstructionStep *)getPureToneRoundComplete:(NSInteger)roundNumber {
    NSString *identifier = [self getRoundSuccessIdentifierForNumber:roundNumber];
    ORKInstructionStep *roundSuccessCompleted = [[ORKInstructionStep alloc] initWithIdentifier:identifier];
    roundSuccessCompleted.title = [NSString localizedStringWithFormat:ORKLocalizedString(@"TINNITUS_ROUND_COMPLETE_TITLE", nil),(long)roundNumber];
    roundSuccessCompleted.text = roundNumber == 1 ?  ORKLocalizedString(@"TINNITUS_ROUND_COMPLETE_TEXT", nil) : ORKLocalizedString(@"TINNITUS_FINAL_ROUND_COMPLETE_TEXT", nil) ;
    
    UIImage *iconImage;
    if (@available(iOS 13.0, *)) {
        UIImageConfiguration *configuration = [UIImageSymbolConfiguration configurationWithFont:[UIFont preferredFontForTextStyle:UIFontTextStyleBody] scale:UIImageSymbolScaleLarge];
        iconImage = [UIImage systemImageNamed:@"checkmark.circle.fill" withConfiguration:configuration];
    } else {
        iconImage = [[UIImage imageNamed:@"checkmark" inBundle:ORKBundle() compatibleWithTraitCollection:nil] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    }
    roundSuccessCompleted.iconImage = iconImage;
    roundSuccessCompleted.imageContentMode = UIViewContentModeTopLeft;
    roundSuccessCompleted.shouldTintImages = YES;
    return [roundSuccessCompleted copy];
}

#pragma mark - Masking Sounds Steps

- (ORKInstructionStep *)maskingSoundInstructionStep {
    ORKInstructionStep *maskingSoundInstructionStep = [[ORKInstructionStep alloc] initWithIdentifier:ORKTinnitusMaskingSoundInstructionStepIdentifier];
    maskingSoundInstructionStep.title = ORKLocalizedString(@"TINNITUS_MASKING_INSTRUCTION_TITLE", nil);
    maskingSoundInstructionStep.text = ORKLocalizedString(@"TINNITUS_MASKING_INSTRUCTION_TEXT", nil);
    
    if (@available(iOS 13.0, *)) {
        ORKBodyItem * item1 = [[ORKBodyItem alloc] initWithText:ORKLocalizedString(@"TINNITUS_MASKING_INSTRUCTION_BODY1", nil) detailText:nil image:[UIImage systemImageNamed:@"ear.badge.checkmark"] learnMoreItem:nil bodyItemStyle:ORKBodyItemStyleImage];
        ORKBodyItem * item2 = [[ORKBodyItem alloc] initWithText:ORKLocalizedString(@"TINNITUS_MASKING_INSTRUCTION_BODY2", nil) detailText:nil image:[UIImage systemImageNamed:@"timer"] learnMoreItem:nil bodyItemStyle:ORKBodyItemStyleImage];
        maskingSoundInstructionStep.bodyItems = @[item1, item2];
    }
    
    return [maskingSoundInstructionStep copy];
}

- (ORKTinnitusMaskingSoundStep *)maskingSoundStepForIdentifier:(NSString *)identifier
                                                          name:(NSString *)name
                                               soundIdentifier:(NSString *)soundIdentifier {
    ORKTinnitusMaskingSoundStep *maskingSoundStep = [[ORKTinnitusMaskingSoundStep alloc] initWithIdentifier:identifier name:name soundIdentifier:soundIdentifier];
    maskingSoundStep.title = ORKLocalizedString(@"TINNITUS_MASKING_TITLE", nil);
    maskingSoundStep.text = ORKLocalizedString(@"TINNITUS_MASKING_TEXT", nil);
    maskingSoundStep.shouldTintImages = YES;
    return [maskingSoundStep copy];
}

@end
