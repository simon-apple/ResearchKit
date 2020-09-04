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

#import "ORKAnswerFormat.h"
#import "ORKBodyItem.h"
#import "ORKCompletionStep.h"
#import "ORKContext.h"
#import "ORKEnvironmentSPLMeterStep.h"
#import "ORKHeadphoneDetectStep.h"
#import "ORKHelpers_Internal.h"
#import "ORKQuestionStep.h"
#import "ORKRecorder_Private.h"
#import "ORKSpeechInNoisePredefinedTask.h"
#import "ORKSpeechInNoiseStep.h"
#import "ORKSpeechRecognitionStep.h"
#import "ORKStep.h"
#import "ORKStepNavigationRule.h"
#import "ORKVolumeCalibrationStep.h"

typedef NSString * ORKSpeechInNoiseStepIdentifier NS_STRING_ENUM;
ORKSpeechInNoiseStepIdentifier const ORKSpeechInNoiseStepIdentifierHeadphoneDetectStep = @"ORKSpeechInNoiseStepIdentifierHeadphoneDetectStep";
ORKSpeechInNoiseStepIdentifier const ORKSpeechInNoiseStepIdentifierVolumeCalibrationStep = @"ORKSpeechInNoiseStepIdentifierVolumeCalibrationStep";
ORKSpeechInNoiseStepIdentifier const ORKSpeechInNoiseStepIdentifierEnvironmentSPLStep = @"ORKSpeechInNoiseStepIdentifierEnvironmentSPLStep";
ORKSpeechInNoiseStepIdentifier const ORKSpeechInNoiseStepIdentifierSpeechInNoiseStep = @"playback";
ORKSpeechInNoiseStepIdentifier const ORKSpeechInNoiseStepIdentifierSpeechRecognitionStep = @"speech_recognition";
ORKSpeechInNoiseStepIdentifier const ORKSpeechInNoiseStepIdentifierEditSpeechTranscriptStep = @"transcript";
ORKSpeechInNoiseStepIdentifier const ORKSpeechInNoiseStepIdentifierSuffixPractice = @"practice";
ORKSpeechInNoiseStepIdentifier const ORKSpeechInNoiseStepIdentifierPracticeCompletionStep = @"ORKSpeechInNoiseStepIdentifierPracticeCompletionStep";


@implementation ORKSpeechInNoisePredefinedTaskContext

- (void)didSkipHeadphoneDetectionStepForTask:(id<ORKTask>)task
{
    if ([task isKindOfClass:[ORKNavigableOrderedTask class]])
    {
        // If the user selects to skip here, append a new step to the end of the task and skip to the end.
        // Add a navigation rule to end the current task.
        ORKNavigableOrderedTask *currentTask = (ORKNavigableOrderedTask *)task;
        
        ORKSpeechInNoiseStepIdentifier const ORKSpeechInNoiseStepIdentifierHeadphonesRequired = @"ORKSpeechInNoiseStepIdentifierHeadphonesRequired";
                
        ORKCompletionStep *step = [[ORKCompletionStep alloc] initWithIdentifier:ORKSpeechInNoiseStepIdentifierHeadphonesRequired];
        step.title = ORKLocalizedString(@"SPEECH_IN_NOISE_PREDEFINED_HEADPHONES_REQUIRED_TITLE", nil);
        step.text = ORKLocalizedString(@"SPEECH_IN_NOISE_PREDEFINED_HEADPHONES_REQUIRED_TEXT", nil);
        step.optional = NO;
        step.reasonForCompletion = ORKTaskViewControllerFinishReasonDiscarded;
        [currentTask addStep:step];
        
        ORKDirectStepNavigationRule *endNavigationRule = [[ORKDirectStepNavigationRule alloc] initWithDestinationStepIdentifier:ORKNullStepIdentifier];
        [currentTask setNavigationRule:endNavigationRule forTriggerStepIdentifier:ORKSpeechInNoiseStepIdentifierHeadphonesRequired];
    }
}

- (NSString *)didNotAllowRequiredHealthPermissionsForTask:(id<ORKTask>)task
{
    NSAssert([task isKindOfClass:[ORKNavigableOrderedTask class]], @"Unexpected task type.");
    if ([task isKindOfClass:[ORKNavigableOrderedTask class]])
    {
        // If the user opts out of health access, append a new step to the end of the task and skip to the end.
        // Add a navigation rule to end the current task.
        ORKNavigableOrderedTask *currentTask = (ORKNavigableOrderedTask *)task;
        
        ORKSpeechInNoiseStepIdentifier const ORKSpeechInNoiseStepIdentifierHealthPermissionsRequired = @"ORKSpeechInNoiseStepIdentifierHealthPermissionsRequired";
        
        ORKCompletionStep *step = [[ORKCompletionStep alloc] initWithIdentifier:ORKSpeechInNoiseStepIdentifierHealthPermissionsRequired];
        step.title = ORKLocalizedString(@"SPEECH_IN_NOISE_PREDEFINED_MICROPHONE_SPEECH_RECOGNITION_REQUIRED_TITLE", nil);
        step.text = ORKLocalizedString(@"SPEECH_IN_NOISE_PREDEFINED_MICROPHONE_SPEECH_RECOGNITION_REQUIRED_TEXT", nil);
        step.optional = NO;
        step.reasonForCompletion = ORKTaskViewControllerFinishReasonDiscarded;
        [currentTask addStep:step];
        
        ORKDirectStepNavigationRule *endNavigationRule = [[ORKDirectStepNavigationRule alloc] initWithDestinationStepIdentifier:ORKNullStepIdentifier];
        [currentTask setNavigationRule:endNavigationRule forTriggerStepIdentifier:ORKSpeechInNoiseStepIdentifierHealthPermissionsRequired];
        
        return ORKSpeechInNoiseStepIdentifierHealthPermissionsRequired;
    }
    
    return (NSString * _Nonnull)nil;
}

@end

@interface ORKSpeechInNoiseSample : NSObject

@property (nonatomic, readonly, nonnull) NSString *path;

@property (nonatomic, readonly, nonnull) NSString *transcript;

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

+ (instancetype)sampleWithPath:(nonnull NSString *)path transcript:(nonnull NSString *)transcript;
- (instancetype)initWithPath:(nonnull NSString *)path transcript:(nonnull NSString *)transcript;

@end

@implementation ORKSpeechInNoiseSample

+ (instancetype)sampleWithPath:(nonnull NSString *)path transcript:(nonnull NSString *)transcript
{
    return [[ORKSpeechInNoiseSample alloc] initWithPath:path transcript:transcript];
}

- (instancetype)initWithPath:(nonnull NSString *)path transcript:(nonnull NSString *)transcript
{
    self = [super init];
    if (self)
    {
        _path = [path copy];
        _transcript = [transcript copy];
    }
    return self;
}

@end

@interface ORKSpeechInNoiseManifest : NSObject

@property (nonatomic, readonly, nonnull) NSArray<ORKSpeechInNoiseSample *> *samples;
@property (nonatomic, readonly, nullable) NSArray<ORKSpeechInNoiseSample *> *practiceSamples;

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

+ (instancetype)manifestWithSamples:(NSArray<ORKSpeechInNoiseSample *> *)samples
                    practiceSamples:(nullable NSArray<ORKSpeechInNoiseSample *> *)practiceSmaples;

- (instancetype)initWithSamples:(NSArray<ORKSpeechInNoiseSample *> *)samples
                practiceSamples:(nullable NSArray<ORKSpeechInNoiseSample *> *)practiceSamples;

@end

@implementation ORKSpeechInNoiseManifest

+ (instancetype)manifestWithSamples:(NSArray<ORKSpeechInNoiseSample *> *)samples
                    practiceSamples:(nullable NSArray<ORKSpeechInNoiseSample *> *)practiceSmaples
{
    return [[ORKSpeechInNoiseManifest alloc] initWithSamples:samples practiceSamples:practiceSmaples];
}

- (instancetype)initWithSamples:(NSArray<ORKSpeechInNoiseSample *> *)samples
                practiceSamples:(nullable NSArray<ORKSpeechInNoiseSample *> *)practiceSamples
{
    self = [super init];
    if (self)
    {
        _samples = [samples copy];
        _practiceSamples = [practiceSamples copy];
    }
    return self;
}

@end

@implementation ORKSpeechInNoisePredefinedTask

- (instancetype)initWithIdentifier:(nonnull NSString *)identifier
              audioSetManifestPath:(nonnull NSString *)audioSetManifestPath
                      prependSteps:(nullable NSArray<ORKStep *> *)prependSteps
                       appendSteps:(nullable NSArray<ORKStep *> *)appendSteps
{
    NSError *error = nil;
    NSArray<ORKStep *> *steps = [ORKSpeechInNoisePredefinedTask speechInNoisePredefinedTaskStepsWithAudioSetManifestPath:audioSetManifestPath
                                                                                                            prependSteps:prependSteps
                                                                                                             appendSteps:appendSteps
                                                                                                                   error:&error];
    
    if (error)
    {
        ORK_Log_Error("An error occurred while creating the predefined task. %@", error);
        return nil;
    }
    
    self = [super initWithIdentifier:identifier steps:steps];
    if (self) {
        _audioSetManifestPath = [audioSetManifestPath copy];
        _prependSteps = [prependSteps copy];
        _appendSteps = [appendSteps copy];
        
        for (ORKStep *step in self.steps)
        {
            if ([step isKindOfClass:[ORKStep class]])
            {
                [step setTask:self];
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

+ (BOOL)supportsSecureCoding
{
    return [super supportsSecureCoding];
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

#pragma mark - Speech In Noise

+ (nullable NSArray<ORKStep *> *)speechInNoisePredefinedTaskStepsWithAudioSetManifestPath:(nonnull NSString *)manifestPath
                                                                             prependSteps:(nullable NSArray<ORKStep *> *)prependSteps
                                                                              appendSteps:(nullable NSArray<ORKStep *> *)appendSteps
                                                                                    error:(NSError * _Nullable * _Nullable)error
{
    NSMutableArray<ORKStep *> *steps = [[NSMutableArray alloc] init];
    
    if (prependSteps.count > 0)
    {
        [steps addObjectsFromArray:[prependSteps copy]];
    }
    
    NSArray *predefinedSteps = [ORKSpeechInNoisePredefinedTask speechInNoisePredefinedTaskStepsWithAudioSetManifestPath:manifestPath error:error];
    
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

#define HIDE_HEADPHONE_DETECT_STEP 0
#define HIDE_ENVIRONMENT_SPL_STEP 0
#define HIDE_VOLUME_CALIBRATION_STEP 0

+ (nullable NSArray<ORKStep *> *)speechInNoisePredefinedTaskStepsWithAudioSetManifestPath:(nonnull NSString *)manifestPath error:(NSError * _Nullable * _Nullable)error
{
    NSError *localError = nil;
    
    ORKSpeechInNoiseManifest *manifest = [ORKSpeechInNoisePredefinedTask prefetchAudioSamplesFromManifest:manifestPath error:error];
    
    if (localError)
    {
        if (error != NULL)
        {
            *error = localError;
        }
        return nil;
    }
    
    NSArray *audioFileSamples = manifest.samples;
    NSArray *audioFilePracticeSamples = manifest.practiceSamples;
    
    NSMutableArray<ORKStep *> *steps = [[NSMutableArray alloc] init];
    
#if !HIDE_HEADPHONE_DETECT_STEP
    {
        ORKSpeechInNoisePredefinedTaskContext *context = [[ORKSpeechInNoisePredefinedTaskContext alloc] init];
        ORKHeadphoneDetectStep *step = [[ORKHeadphoneDetectStep alloc] initWithIdentifier:ORKSpeechInNoiseStepIdentifierHeadphoneDetectStep headphoneTypes:ORKHeadphoneTypesAny];
        step.context = context;
        step.title = ORKLocalizedString(@"SPEECH_IN_NOISE_PREDEFINED_HEADPHONES_DETECT_TITLE", nil);
        step.optional = NO;
        [steps addObject:step];
    }
#endif
    
#if !HIDE_VOLUME_CALIBRATION_STEP
    {
        ORKVolumeCalibrationStep *step = [[ORKVolumeCalibrationStep alloc] initWithIdentifier:ORKSpeechInNoiseStepIdentifierVolumeCalibrationStep];
        step.title = ORKLocalizedString(@"SPEECH_IN_NOISE_PREDEFINED_VOLUME_CALIBRATION_TITLE", nil);
        step.detailText = ORKLocalizedString(@"SPEECH_IN_NOISE_PREDEFINED_VOLUME_CALIBRATION_TEXT", nil);
        step.optional = NO;
        [steps addObject:step];
    }
#endif
    
#if !HIDE_ENVIRONMENT_SPL_STEP
    {
        ORKEnvironmentSPLMeterStep *step = [[ORKEnvironmentSPLMeterStep alloc] initWithIdentifier:ORKSpeechInNoiseStepIdentifierEnvironmentSPLStep];
        step.title = ORKLocalizedString(@"ENVIRONMENTSPL_TITLE_2", nil);
        step.text = ORKLocalizedString(@"ENVIRONMENTSPL_INTRO_TEXT_2", nil);
        step.thresholdValue = 45;
        step.requiredContiguousSamples = 5;
        step.samplingInterval = 1;
        step.optional = NO;
        [steps addObject:step];
    }
#endif
        
    // SIN Practice Flow
    [steps addObjectsFromArray:[self speechInNoiseStepsFromAudioSamples:audioFilePracticeSamples isPractice:YES]];
        
    // SIN Flow
    [steps addObjectsFromArray:[self speechInNoiseStepsFromAudioSamples:audioFileSamples isPractice:NO]];
    
    return [steps copy];
}

+ (NSArray<ORKStep *> *)speechInNoiseStepsFromAudioSamples:(NSArray<ORKSpeechInNoiseSample *> *)audioSamples isPractice:(BOOL)isPractice
{
    NSAssert((audioSamples.count <= 7), @"the number of audio files cannot exceed 7");
    
    NSMutableArray<ORKStep *> *steps = [[NSMutableArray alloc] init];
    
    // SNR ranging from 18 dB to 0 dB with a 3 dB step
    NSMutableArray *gainValues = [NSMutableArray new];
    [gainValues addObject:[NSNumber numberWithDouble:0.18]];
    [gainValues addObject:[NSNumber numberWithDouble:0.25]];
    [gainValues addObject:[NSNumber numberWithDouble:0.36]];
    [gainValues addObject:[NSNumber numberWithDouble:0.51]];
    [gainValues addObject:[NSNumber numberWithDouble:0.73]];
    [gainValues addObject:[NSNumber numberWithDouble:1.03]];
    [gainValues addObject:[NSNumber numberWithDouble:1.46]];
    
    ORKSpeechInNoisePredefinedTaskContext *context = [[ORKSpeechInNoisePredefinedTaskContext alloc] init];
    context.practiceTest = isPractice;
    
    [audioSamples enumerateObjectsUsingBlock:^(ORKSpeechInNoiseSample * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
        NSString *fileName = [[obj.path stringByDeletingPathExtension] lastPathComponent];
            
        // Speech In Noise
        {
            ORKSpeechInNoiseStepIdentifier stepIdentifier = [NSString stringWithFormat:@"%@_%@", fileName.lowercaseString, ORKSpeechInNoiseStepIdentifierSpeechInNoiseStep];
            ORKSpeechInNoiseStep *step = [[ORKSpeechInNoiseStep alloc] initWithIdentifier:stepIdentifier];
            step.context = context;
            step.speechFilePath = obj.path;
            step.targetSentence = obj.transcript;
            step.gainAppliedToNoise = isPractice ? [gainValues[1] doubleValue] : [gainValues[idx] doubleValue];
            step.title = ORKLocalizedString(@"SPEECH_IN_NOISE_PREDEFINED_LISTEN_TITLE", nil);
            step.text = ORKLocalizedString(@"SPEECH_IN_NOISE_PREDEFINED_LISTEN_TEXT", nil);
            if (!isPractice)
            {
                step.detailText = [NSString stringWithFormat:ORKLocalizedString(@"SPEECH_IN_NOISE_PREDEFINED_LISTEN_SENTENCE_X_OF_Y", nil), idx + 1, audioSamples.count];
            }
            
            step.optional = NO;
            step.hideGraphView = NO;
            [steps addObject:step];
            
            if (isPractice && idx == 0)
            {
                context.practiceAgainStepIdentifier = step.identifier;
            }
        }
            
        // Speech Recognition
        {
            ORKSpeechInNoiseStepIdentifier stepIdentifier = [NSString stringWithFormat:@"%@_%@", fileName.lowercaseString, ORKSpeechInNoiseStepIdentifierSpeechRecognitionStep];
            ORKAudioStreamerConfiguration *config = [[ORKAudioStreamerConfiguration alloc] initWithIdentifier:@"streamingAudio"];
            ORKSpeechRecognitionStep *step = [[ORKSpeechRecognitionStep alloc] initWithIdentifier:stepIdentifier image:nil text:nil];
            step.shouldHideTranscript = YES;
            step.context = context;
            step.recorderConfigurations = @[config];
            step.speechRecognizerLocale = @"en-US";
            step.title = ORKLocalizedString(@"SPEECH_IN_NOISE_PREDEFINED_REPEAT_TITLE", nil);
            step.optional = NO;
            [steps addObject:step];
        }
            
        // Edit Transcript
        {
            ORKTextAnswerFormat *answerFormat = [ORKTextAnswerFormat new];
            answerFormat.spellCheckingType = UITextSpellCheckingTypeNo;
            answerFormat.autocorrectionType = UITextAutocorrectionTypeNo;
            answerFormat.multipleLines = YES;
            answerFormat.maximumLength = 300;
            answerFormat.hideClearButton = YES;
            answerFormat.hideCharacterCountLabel = YES;
            
            ORKSpeechInNoiseStepIdentifier stepIdentifier = [NSString stringWithFormat:@"%@_%@", fileName.lowercaseString, ORKSpeechInNoiseStepIdentifierEditSpeechTranscriptStep];
            ORKQuestionStep *step = [ORKQuestionStep questionStepWithIdentifier:stepIdentifier
                                                                              title:ORKLocalizedString(@"SPEECH_IN_NOISE_PREDEFINED_REVIEW_TITLE", nil)
                                                                           question:nil
                                                                             answer:answerFormat];
            step.context = context;
            step.text = ORKLocalizedString(@"SPEECH_IN_NOISE_PREDEFINED_REVIEW_TEXT", nil);
            step.optional = NO;
            [steps addObject:step];
        }
        
        if (isPractice)
        {
            // The practice flow should only be 1 audio sample
            *stop = YES;
        }
    }];
    
    if (isPractice)
    {
        // Completion (Practice)
        {
            ORKCompletionStep *step = [[ORKCompletionStep alloc] initWithIdentifier:ORKSpeechInNoiseStepIdentifierPracticeCompletionStep];
            step.context = context;
            step.title = ORKLocalizedString(@"SPEECH_IN_NOISE_PREDEFINED_PRACTICE_COMPLETION_TITLE", nil);
            step.optional = YES;
            [steps addObject:step];
        }
    }
    
    return [steps copy];
    
}

+ (nullable ORKSpeechInNoiseManifest *)prefetchAudioSamplesFromManifest:(nonnull NSString *)path error:(NSError * _Nullable * _Nullable)error
{
    NSArray *samples = [ORKSpeechInNoisePredefinedTask prefetchAudioSamplesFromManifestAtPath:path error:error];
    
    NSString *practiceManifest = [[[[path stringByDeletingLastPathComponent] stringByDeletingLastPathComponent] stringByAppendingPathComponent:@"PracticeList"] stringByAppendingPathComponent:@"manifest.json"];
    
    NSArray *practiceSamples = [ORKSpeechInNoisePredefinedTask prefetchAudioSamplesFromManifestAtPath:practiceManifest error:error];
    
    if (samples && practiceSamples)
    {
        return [ORKSpeechInNoiseManifest manifestWithSamples:samples practiceSamples:practiceSamples];
    }
    
    return nil;
}

+ (nullable NSArray<ORKSpeechInNoiseSample *> *)prefetchAudioSamplesFromManifestAtPath:(nonnull NSString *)path error:(NSError * _Nullable * _Nullable)error
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
    
    NSArray<NSDictionary *> *manifest = [NSJSONSerialization JSONObjectWithData:data options:0 error:error];
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
    NSString * const ManifestJSONKeyTranscript = @"targetSentence";
    
    NSMutableArray<ORKSpeechInNoiseSample *> *audioFileSamples = [[NSMutableArray alloc] init];
    
    __block BOOL success;
    __block NSError *err;
    [manifest enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        NSString *audioFilename = (NSString *)[obj objectForKey:ManifestJSONKeyAudioFilename];
        NSString *audioFilePath = [parentDirectory stringByAppendingPathComponent:audioFilename];
        NSString *audioFileTranscript = (NSString *)[obj objectForKey:ManifestJSONKeyTranscript];
        
        if ([fileManager fileExistsAtPath:audioFilePath])
        {
            [audioFileSamples addObject:[ORKSpeechInNoiseSample sampleWithPath:audioFilePath transcript:audioFileTranscript]];
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

@end
