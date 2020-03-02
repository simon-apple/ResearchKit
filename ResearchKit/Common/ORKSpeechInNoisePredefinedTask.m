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

#import "ORKSpeechInNoisePredefinedTask.h"
#import "ORKHelpers_Internal.h"
#import "ORKStep.h"
#import "ORKBodyItem.h"
#import "ORKRecorder.h"
#import "ORKSpeechInNoiseStep.h"
#import "ORKSpeechRecognitionStep.h"
#import "ORKAnswerFormat.h"
#import "ORKQuestionStep.h"
#import "ORKHeadphoneDetectStep.h"
#import "ORKEnvironmentSPLMeterStep.h"
#import "ORKVolumeCalibrationStep.h"

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
    NSArray *audioFileSamples = [ORKSpeechInNoisePredefinedTask prefetchAudioSamplesFromManifestAtPath:manifestPath error:&localError];
    if (localError)
    {
        if (error != NULL)
        {
            *error = localError;
        }
        return nil;
    }
    
    typedef NSString * ORKSpeechInNoiseStepIdentifier NS_STRING_ENUM;

    NSMutableArray<ORKStep *> *steps = [[NSMutableArray alloc] init];
    
#if !HIDE_HEADPHONE_DETECT_STEP
    {
        ORKSpeechInNoiseStepIdentifier const ORKSpeechInNoiseStepIdentifierHeadphoneDetectStep = @"ORKSpeechInNoiseStepIdentifierHeadphoneDetectStep";
        ORKHeadphoneDetectStep *step = [[ORKHeadphoneDetectStep alloc] initWithIdentifier:ORKSpeechInNoiseStepIdentifierHeadphoneDetectStep headphoneTypes:ORKHeadphoneTypesAny];
        step.title = ORKLocalizedString(@"SPEECH_IN_NOISE_PREDEFINED_HEADPHONES_DETECT_TITLE", nil);
        step.detailText = ORKLocalizedString(@"SPEECH_IN_NOISE_PREDEFINED_HEADPHONES_DETECT_TEXT", nil);
        step.optional = NO;
        [steps addObject:step];
    }
#endif
    
#if !HIDE_VOLUME_CALIBRATION_STEP
    {
        ORKSpeechInNoiseStepIdentifier const ORKSpeechInNoiseStepIdentifierVolumeCalibrationStep = @"ORKSpeechInNoiseStepIdentifierVolumeCalibrationStep";
        ORKVolumeCalibrationStep *step = [[ORKVolumeCalibrationStep alloc] initWithIdentifier:ORKSpeechInNoiseStepIdentifierVolumeCalibrationStep];
        step.title = ORKLocalizedString(@"SPEECH_IN_NOISE_PREDEFINED_VOLUME_CALIBRATION_TITLE", nil);
        step.detailText = ORKLocalizedString(@"SPEECH_IN_NOISE_PREDEFINED_VOLUME_CALIBRATION_TEXT", nil);
        step.optional = NO;
        [steps addObject:step];
    }
#endif
    
#if !HIDE_ENVIRONMENT_SPL_STEP
    {
        ORKSpeechInNoiseStepIdentifier const ORKSpeechInNoiseStepIdentifierEnvironmentSPLStep = @"ORKSpeechInNoiseStepIdentifierEnvironmentSPLStep";
        ORKEnvironmentSPLMeterStep *step = [[ORKEnvironmentSPLMeterStep alloc] initWithIdentifier:ORKSpeechInNoiseStepIdentifierEnvironmentSPLStep];
        step.title = ORKLocalizedString(@"ENVIRONMENTSPL_TITLE_2", nil);
        step.text = ORKLocalizedString(@"ENVIRONMENTSPL_INTRO_TEXT_2", nil);
        step.thresholdValue = 60;
        step.requiredContiguousSamples = 5;
        step.samplingInterval = 1;
        step.optional = NO;
        [steps addObject:step];
    }
#endif
    
    {
        ORKSpeechInNoiseStepIdentifier const ORKSpeechInNoiseStepIdentifierSpeechInNoiseStep = @"PLAYBACK";
        ORKSpeechInNoiseStepIdentifier const ORKSpeechInNoiseStepIdentifierSpeechRecognitionStep = @"SPEECH_RECOGNITION";
        ORKSpeechInNoiseStepIdentifier const ORKSpeechInNoiseStepIdentifierEditSpeechTranscriptStep = @"TRANSCRIPT";
        
        [audioFileSamples enumerateObjectsUsingBlock:^(ORKSpeechInNoiseSample * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            NSString *fileName = [[obj.path stringByDeletingPathExtension] lastPathComponent];
            NSString *listName = [[obj.path stringByDeletingLastPathComponent] lastPathComponent];
            
            // Speech In Noise
            {
                ORKSpeechInNoiseStepIdentifier stepIdentifier = [NSString stringWithFormat:@"%@_%@_%@", listName.uppercaseString, fileName.uppercaseString, ORKSpeechInNoiseStepIdentifierSpeechInNoiseStep];
                ORKSpeechInNoiseStep *step = [[ORKSpeechInNoiseStep alloc] initWithIdentifier:stepIdentifier];
                step.speechFilePath = obj.path;
                step.gainAppliedToNoise = 0.51;
                step.title = ORKLocalizedString(@"SPEECH_IN_NOISE_PREDEFINED_LISTEN_TITLE", nil);
                step.text = ORKLocalizedString(@"SPEECH_IN_NOISE_PREDEFINED_LISTEN_TEXT", nil);
                step.detailText = [NSString stringWithFormat:ORKLocalizedString(@"SPEECH_IN_NOISE_PREDEFINED_LISTEN_SENTENCE_X_OF_Y", nil), idx + 1, audioFileSamples.count];
                step.optional = NO;
                step.hideGraphView = NO;
                [steps addObject:step];
            }
            
            // Speech Recognition
            {
                ORKSpeechInNoiseStepIdentifier stepIdentifier = [NSString stringWithFormat:@"%@_%@_%@", listName.uppercaseString, fileName.uppercaseString, ORKSpeechInNoiseStepIdentifierSpeechRecognitionStep];
                ORKStreamingAudioRecorderConfiguration *config = [[ORKStreamingAudioRecorderConfiguration alloc] initWithIdentifier:@"streamingAudio"];
                ORKSpeechRecognitionStep *step = [[ORKSpeechRecognitionStep alloc] initWithIdentifier:stepIdentifier image:nil text:nil];
                step.shouldHideTranscript = YES;
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
                
                ORKSpeechInNoiseStepIdentifier stepIdentifier = [NSString stringWithFormat:@"%@_%@_%@", listName.uppercaseString, fileName.uppercaseString, ORKSpeechInNoiseStepIdentifierEditSpeechTranscriptStep];
                ORKQuestionStep *step = [ORKQuestionStep questionStepWithIdentifier:stepIdentifier
                                                                              title:ORKLocalizedString(@"SPEECH_IN_NOISE_PREDEFINED_REVIEW_TITLE", nil)
                                                                           question:nil
                                                                             answer:answerFormat];
                step.text = ORKLocalizedString(@"SPEECH_IN_NOISE_PREDEFINED_REVIEW_TEXT", nil);
                step.optional = NO;
                [steps addObject:step];
            }
        }];
    }
    
    return [steps copy];
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
