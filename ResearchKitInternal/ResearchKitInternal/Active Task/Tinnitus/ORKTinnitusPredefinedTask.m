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
// apple-internal

#import "ORKContext+ResearchKitInternal.h"
#import "ORKHeadphoneDetector.h"
#import "ORKHeadphoneDetectResult.h"
#import "ORKHeadphonesRequiredCompletionStep.h"
#import "ORKTinnitusAudioSample.h"
#import "ORKTinnitusMaskingSoundStep.h"
#import "ORKTinnitusOverallAssessmentStep.h"
#import "ORKTinnitusPredefinedTask.h"
#import "ORKTinnitusPureToneResult.h"
#import "ORKTinnitusPureToneStep.h"
#import "ORKTinnitusTypeResult.h"
#import "ORKTinnitusTypeStep.h"
#import "ORKVolumeCalibrationStep.h"

#import "AAPLUtils.h"

#import <ResearchKitUI/ORKTaskViewController.h>

#if TARGET_OS_IOS
#import <UIKit/UIKit.h>
#endif
#import <ResearchKit/ORKContext.h>
#import <ResearchKit/ORKStepNavigationRule.h>
#import <ResearchKit/ResearchKit_Private.h>
#import <ResearchKit/ORKTypes.h>

#import <ResearchKitInternal/AAPLEnvironmentSPLMeterStep.h>

NSString *const ORKHeadphoneNotificationSuspendActivity = @"ORKHeadphoneNotificationSuspendActivity";

static NSString *const ORKTinnitusHeadphoneDetectStepIdentifier = @"tinnitus_headphonedetect";
static NSString *const ORKTinnitusHeadphonesRequiredStepIdentifier = @"tinnitus_headphone_required";
static NSString *const ORKTinnitusSPLMeterStepIdentifier = @"tinnitus_splmeter";
static NSString *const ORKTinnitusTypeStepIdentifier = @"tinnitus_type";
static NSString *const ORKTinnitusVolumeCalibrationStepIdentifier = @"tinnitus_volume_calibration";
static NSString *const ORKTinnitusRoundStepIdentifier = @"tinnitus_puretone";
static NSString *const ORKTinnitusRoundSuccessCompletedStepIdentifier = @"tinnitus_puretone_success_roundcomplete";
static NSString *const ORKTinnitusPuretoneLoudnessMatchingStepIdentifier = @"tinnitus_loudness_matching";
static NSString *const ORKTinnitusWhitenoiseLoudnessMatchingStepIdentifier = @"tinnitus_whitenoise_loudness_matching";
static NSString *const ORKTinnitusPitchMatchingInstructionStepIdentifier = @"tinnitus_pitch_matching_instruction";
static NSString *const ORKTinnitusOverallAssessmentStepIdentifier = @"tinnitus_overall_assessment";
static NSString *const ORKTinnitusHeadphoneRequiredStepIdentifier = @"ORKTinnitusHeadphoneRequiredStepIdentifier";

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

@interface ORKTinnitusPredefinedTaskContext ()  <ORKHeadphoneDetectorDelegate> {
    ORKHeadphoneDetector *_headphoneDetector;
    BOOL _showingAlert;
    ORKTaskViewController *_taskViewController;
    UIAlertAction *_continueAction;
}

@end

@implementation ORKTinnitusPredefinedTaskContext

- (NSString *)headphoneRequiredIdentifier {
    return ORKTinnitusHeadphoneRequiredStepIdentifier;
}

- (NSString *)didSkipHeadphoneDetectionStep:(ORKStep *)step forTask:(id<ORKTask>)task
{
    if ([task isKindOfClass:[ORKNavigableOrderedTask class]] && self.headphoneRequiredIdentifier != nil) {
        ORKNavigableOrderedTask *currentTask = (ORKNavigableOrderedTask *)task;
        ORKHeadphonesRequiredCompletionStep *completionStep = (ORKHeadphonesRequiredCompletionStep *)[task stepWithIdentifier:self.headphoneRequiredIdentifier];
        
        if (completionStep) {
            [currentTask removeSkipNavigationRuleForStepIdentifier:self.headphoneRequiredIdentifier];
        } else {
            completionStep = [[ORKHeadphonesRequiredCompletionStep alloc] initWithIdentifier:self.headphoneRequiredIdentifier requiredHeadphoneTypes:ORKHeadphoneTypesSupported];
            [currentTask insertStep:completionStep atIndex:[currentTask indexOfStep:step]+1];
        }
        
        return self.headphoneRequiredIdentifier;
    }
    
    return nil;
}

-(void)insertTaskViewController:(ORKTaskViewController *)viewController {
    _taskViewController = viewController;
}

- (void)resetVariables {
    _taskViewController = nil;
    _userVolume = 0.0;
    _headphoneType = nil;
    _showingAlert = NO;
    _type = ORKTinnitusTypeUnknown;
    _tinnitusIdentifier = nil;
    [self stopMonitoringHeadphoneChanges];
}

- (void)dealloc {
    [self resetVariables];
}

- (void)showAlert {
    if (_taskViewController != nil) {
        if (!_showingAlert) {
            _showingAlert = YES;
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertAction *cancelAction = [UIAlertAction
                                               actionWithTitle:AAPLLocalizedString(@"TINNITUS_ALERT_BUTTON_CANCEL", nil)
                                               style:UIAlertActionStyleDefault
                                               handler:^(UIAlertAction *action) {
                    _showingAlert = NO;
                    _continueAction = nil;
                    ORKStrongTypeOf(_taskViewController.delegate) strongDelegate = _taskViewController.delegate;
                    if ([strongDelegate respondsToSelector:@selector(taskViewController:didFinishWithReason:error:)]) {
                        [strongDelegate taskViewController:_taskViewController didFinishWithReason:ORKTaskFinishReasonDiscarded error:nil];
                    }
                }];
                UIAlertController *alertController = [UIAlertController
                                                      alertControllerWithTitle:AAPLLocalizedString(@"PACHA_ALERT_TITLE_TASK_INTERRUPTED", nil)
                                                      message:[self getInterruptMessage]
                                                      preferredStyle:UIAlertControllerStyleAlert];
                _continueAction = [UIAlertAction
                                   actionWithTitle:AAPLLocalizedString(@"TINNITUS_ALERT_BUTTON_CONTINUE", nil)
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction *action) {
                    _showingAlert = NO;
                    _continueAction = nil;
                }];
                [alertController addAction:_continueAction];
                [_continueAction setEnabled:NO];
                
                [alertController addAction:cancelAction];
                alertController.preferredAction = cancelAction;
                
                [_taskViewController presentViewController:alertController animated:YES completion:nil];
            });
        } else {
            [_continueAction setEnabled:NO];
        }
    }
}

- (NSString *)getInterruptMessage {
    if ([_headphoneType isEqualToString:ORKHeadphoneTypeIdentifierAirPodsGen1] ||
        [_headphoneType isEqualToString:ORKHeadphoneTypeIdentifierAirPodsGen2] ||
        [_headphoneType isEqualToString:ORKHeadphoneTypeIdentifierAirPodsGen3]) {
        return AAPLLocalizedString(@"TINNITUS_ALERT_TEXT_AIRPODS", nil);
    } else if ([_headphoneType isEqualToString:ORKHeadphoneTypeIdentifierAirPodsPro]) {
        return AAPLLocalizedString(@"TINNITUS_ALERT_TEXT_AIRPODSPRO", nil);
    } else if ([_headphoneType isEqualToString:ORKHeadphoneTypeIdentifierAirPodsMax]) {
        return AAPLLocalizedString(@"TINNITUS_ALERT_TEXT_AIRPODSMAX", nil);
    } else {
        return AAPLLocalizedString(@"TINNITUS_ALERT_TEXT_EARPODS", nil);
    }
}

#pragma mark - Headphone Detector

- (void)startMonitoringHeadphoneChanges {
    if (_headphoneDetector == nil) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            _headphoneDetector = [[ORKHeadphoneDetector alloc] initWithDelegate:self
                                                 supportedHeadphoneChipsetTypes:[ORKHeadphoneDetectStep dBHLTypes]];
        });
    }
}

- (void)stopMonitoringHeadphoneChanges {
    [_headphoneDetector discard];
    _headphoneDetector = nil;
    _bluetoothMode = ORKBluetoothModeNone;
}

- (void)headphoneTypeDetected:(nonnull ORKHeadphoneTypeIdentifier)headphoneType vendorID:(nonnull NSString *)vendorID productID:(nonnull NSString *)productID deviceSubType:(NSInteger)deviceSubType isSupported:(BOOL)isSupported {
    if (![_headphoneType isEqualToString:headphoneType]) {
        [self showAlert];
        [[NSNotificationCenter defaultCenter]
         postNotificationName:ORKHeadphoneNotificationSuspendActivity
         object:self
         userInfo:nil];
    } else {
        [_continueAction setEnabled:YES];
    }
}

- (void)bluetoothModeChanged:(ORKBluetoothMode)bluetoothMode {
    if ([[_headphoneType uppercaseString] isEqualToString:ORKHeadphoneTypeIdentifierAirPodsPro] ||
        [[_headphoneType uppercaseString] isEqualToString:ORKHeadphoneTypeIdentifierAirPodsProGen2] ||
        [[_headphoneType uppercaseString] isEqualToString:ORKHeadphoneTypeIdentifierAirPodsMax]) {
        if (_bluetoothMode == ORKBluetoothModeNone) {
            // save bluetooth mode for the first time
            _bluetoothMode = bluetoothMode;
        } else {
            if (bluetoothMode != ORKBluetoothModeNoiseCancellation && _bluetoothMode == ORKBluetoothModeNoiseCancellation) {
                [self showAlert];
                [[NSNotificationCenter defaultCenter]
                 postNotificationName:ORKHeadphoneNotificationSuspendActivity
                 object:self
                 userInfo:nil];
            } else {
                [_continueAction setEnabled:YES];
            }
        }
    }
}

- (void)podLowBatteryLevelDetected {
    [self showAlert];
    [[NSNotificationCenter defaultCenter]
     postNotificationName:ORKHeadphoneNotificationSuspendActivity
     object:self
     userInfo:nil];
}

- (void)oneAirPodRemoved {
    [self showAlert];
    [[NSNotificationCenter defaultCenter]
     postNotificationName:ORKHeadphoneNotificationSuspendActivity
     object:self
     userInfo:nil];
}

- (void)oneAirPodInserted {
    [_continueAction setEnabled:YES];
}

@end

@interface ORKTinnitusPredefinedTask () {
    ORKTinnitusPredefinedTaskContext *_context;
    
    NSDictionary *_stepAfterStepDict;
    NSArray<NSString *> *_maskingIdentifiers;
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
    
    NSArray<ORKStep *> *steps = [ORKTinnitusPredefinedTask tinnitusPredefinedStepsWithPrependSteps:prependSteps appendSteps:appendSteps manifest:manifest];

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
                                                       manifest:(ORKTinnitusAudioManifest *)manifest
{
    NSMutableArray<ORKStep *> *steps = [[NSMutableArray alloc] init];
    
    if (prependSteps.count > 0)
    {
        [steps addObjectsFromArray:[prependSteps copy]];
    }
    
    NSArray *predefinedSteps = [ORKTinnitusPredefinedTask tinnitusPredefinedTaskStepsWithManifest:manifest];

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

+ (NSArray<ORKStep *> *)tinnitusPredefinedTaskStepsWithManifest:(ORKTinnitusAudioManifest *)manifest {
        
    NSMutableArray<ORKStep *> *steps = [[NSMutableArray alloc] init];
    
    [steps addObjectsFromArray:@[
        [self headphone],
        [self splmeter],
        [self calibration],
        [self tinnitusType],
        [self pitchMatchingInstruction],
        [self getPureToneRound:1],
        [self getPureToneRoundComplete:1],
        [self getPureToneRound:2],
        [self getPureToneRoundComplete:2],
        [self getPureToneRound:3],
        [self puretoneLoudnessMatching],
        [self whitenoiseLoudnessMatching],
        [self overallAssessmentStep],
        [self maskingSoundInstructionStep],
    ]];
    
    [steps addObjectsFromArray:[self createMaskingStepsForSamples:manifest.maskingSamples]];
    
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
    ORKStep *firstPredefinedStep = [self stepWithIdentifier:ORKTinnitusSPLMeterStepIdentifier];
    _context.headphoneType = ORKHeadphoneTypeIdentifierAirPodsMax;
    _context.bluetoothMode = ORKBluetoothModeNoiseCancellation;
#else
    ORKStep *firstPredefinedStep = [self stepWithIdentifier:ORKTinnitusHeadphoneDetectStepIdentifier];
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
            return [self stepWithIdentifier:ORKTinnitusSPLMeterStepIdentifier];
        } else if ([identifier isEqualToString:ORKTinnitusVolumeCalibrationStepIdentifier]) {
#if !TARGET_IPHONE_SIMULATOR
            [_context startMonitoringHeadphoneChanges];
#endif
            return [self stepWithIdentifier:ORKTinnitusTypeStepIdentifier];
        } else if ([identifier isEqualToString:ORKTinnitusTypeStepIdentifier]) {
            ORKStepResult *stepResult = [result stepResultForStepIdentifier:ORKTinnitusTypeStepIdentifier];
            ORKTinnitusTypeResult *typeResult = (ORKTinnitusTypeResult *)(stepResult.results.count > 0 ? stepResult.results.firstObject : nil);
            NSString *tinnitusIdentifier = typeResult.tinnitusIdentifier;
            ORKTinnitusType type = typeResult.type;
            if (tinnitusIdentifier != nil) {
                _context.type = type;
                _context.tinnitusIdentifier = tinnitusIdentifier;
                ORKStepResult *roundResult = [result stepResultForStepIdentifier:[ORKTinnitusPredefinedTask getRoundIdentifierForNumber:3]];
                if (_context.type == ORKTinnitusTypePureTone && !roundResult) {
                    return [self stepWithIdentifier:ORKTinnitusPitchMatchingInstructionStepIdentifier];
                } else if (_context.type == ORKTinnitusTypeWhiteNoise) {
                    return [self stepWithIdentifier:ORKTinnitusWhitenoiseLoudnessMatchingStepIdentifier];
                }
            }
            return [self stepWithIdentifier:ORKTinnitusMaskingSoundInstructionStepIdentifier];
        } else if ([identifier isEqualToString:[ORKTinnitusPredefinedTask getRoundIdentifierForNumber:3]]) {
            _context.predominantFrequency = [self predominantFrequencyForResult:result];
            // getting maximum and minimum frequencies used by the puretone step
            ORKTinnitusPureToneStep *lastPuretoneStep = (ORKTinnitusPureToneStep *)[self stepWithIdentifier:[ORKTinnitusPredefinedTask getRoundIdentifierForNumber:3]];
            NSNumber *max = [lastPuretoneStep.listOfChoosableFrequencies valueForKeyPath:@"@max.self"];
            NSNumber *min = [lastPuretoneStep.listOfChoosableFrequencies valueForKeyPath:@"@min.self"];
            if (_context.predominantFrequency > 0.0 &&
                _context.predominantFrequency != [max doubleValue] &&
                _context.predominantFrequency != [min doubleValue]) {
                return [self stepWithIdentifier:ORKTinnitusPuretoneLoudnessMatchingStepIdentifier];
            }
            return [self stepWithIdentifier:ORKTinnitusMaskingSoundInstructionStepIdentifier];
        } else if ([identifier isEqualToString:ORKTinnitusMaskingSoundInstructionStepIdentifier]) {
            return [self stepWithIdentifier:_maskingIdentifiers[0]];
        }
        
        nextStep = [self nextMaskingStepForIdentifier:identifier];
        if (nextStep == nil) {
            // The user may want to remove the headphones on the appendSteps
            [_context stopMonitoringHeadphoneChanges];
        }
    }
    
    return nextStep;
}

- (ORKStep *)stepAfterStep:(ORKStep *)step withResult:(ORKTaskResult *)result {
    if (step == nil) {
        [self setupStraightStepAfterStepDict];
    }
        
    ORKStep *nextStep = [self prependedStepAfterStep:step];

    if (!nextStep) {
        nextStep = [self dynamicStepAfterStep:step withResult:result];
    }

    if (!nextStep) {
        nextStep = [self apendedStepAfterStep:step];
    }
    
    if (nextStep) {
        ORKSkipStepNavigationRule *skipNavigationRule = self.skipStepNavigationRules[nextStep.identifier];
        if ([skipNavigationRule stepShouldSkipWithTaskResult:result]) {
            nextStep = [self stepAfterStep:nextStep withResult:result];
        }
    }
    
    if (nextStep) {
        ORKStepModifier *stepModifier = [self stepModifierForStepIdentifier:nextStep.identifier];
        [stepModifier modifyStep:nextStep withTaskResult:result];
    }
    
    [nextStep setTask:self];
    [nextStep setContext:_context];
    return nextStep;
}

- (void)setupStraightStepAfterStepDict {
    [self initMaskingStepsIdentifiers];
    NSString *round1Identifier = [ORKTinnitusPredefinedTask getRoundIdentifierForNumber:1];
    NSString *round2Identifier = [ORKTinnitusPredefinedTask getRoundIdentifierForNumber:2];
    NSString *round3Identifier = [ORKTinnitusPredefinedTask getRoundIdentifierForNumber:3];
    NSString *round1SuccessIdentifier = [ORKTinnitusPredefinedTask getRoundSuccessIdentifierForNumber:1];
    NSString *round2SuccessIdentifier = [ORKTinnitusPredefinedTask getRoundSuccessIdentifierForNumber:2];
    
    _stepAfterStepDict = @{
        ORKTinnitusSPLMeterStepIdentifier: [self stepWithIdentifier:ORKTinnitusVolumeCalibrationStepIdentifier],
        ORKTinnitusPitchMatchingInstructionStepIdentifier: [self stepWithIdentifier:round1Identifier],
        round1Identifier: [self stepWithIdentifier:round1SuccessIdentifier],
        round1SuccessIdentifier: [self stepWithIdentifier:round2Identifier],
        round2Identifier: [self stepWithIdentifier:round2SuccessIdentifier],
        round2SuccessIdentifier: [self stepWithIdentifier:round3Identifier],
        ORKTinnitusPuretoneLoudnessMatchingStepIdentifier: [self stepWithIdentifier:ORKTinnitusOverallAssessmentStepIdentifier],
        ORKTinnitusWhitenoiseLoudnessMatchingStepIdentifier: [self stepWithIdentifier:ORKTinnitusOverallAssessmentStepIdentifier],
        ORKTinnitusOverallAssessmentStepIdentifier: [self stepWithIdentifier:ORKTinnitusMaskingSoundInstructionStepIdentifier]
    };
}

- (void)initMaskingStepsIdentifiers {
    NSMutableArray *maskingSamples = [_context.audioManifest.maskingSamples mutableCopy];
    [maskingSamples shuffle];

    NSMutableArray *stepsIdentifiers = [[NSMutableArray alloc] init];
    for (ORKTinnitusAudioSample *sample in maskingSamples) {
        [stepsIdentifiers addObject:[NSString stringWithFormat:@"%@_calibration", sample.identifier]];
        [stepsIdentifiers addObject:[NSString stringWithFormat:@"%@_assessment", sample.identifier]];
    }
    
    _maskingIdentifiers = [stepsIdentifiers copy];
}

- (nullable ORKStep *)nextMaskingStepForIdentifier:(NSString *)identifier {
    NSUInteger currentMaskingStepIndex = [_maskingIdentifiers indexOfObject:identifier];
    
    if (currentMaskingStepIndex != NSNotFound && currentMaskingStepIndex+1 < [_maskingIdentifiers count]) {
        NSString *nextIdentifier = [_maskingIdentifiers objectAtIndex:currentMaskingStepIndex+1];
        return [self stepWithIdentifier:nextIdentifier];
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

- (double)predominantFrequency {
    return _context.predominantFrequency;
}

- (double)predominantFrequencyForResult:(id<ORKTaskResultSource>)result {
    ORKStepResult *stepResult = [result stepResultForStepIdentifier:[ORKTinnitusPredefinedTask getRoundIdentifierForNumber:1]];
    ORKTinnitusPureToneResult *round1Result = (ORKTinnitusPureToneResult *)(stepResult.results.count > 0 ? stepResult.results.firstObject : nil);
    stepResult = [result stepResultForStepIdentifier:[ORKTinnitusPredefinedTask getRoundIdentifierForNumber:2]];
    ORKTinnitusPureToneResult *round2Result = (ORKTinnitusPureToneResult *)(stepResult.results.count > 0 ? stepResult.results.firstObject : nil);
    stepResult = [result stepResultForStepIdentifier:[ORKTinnitusPredefinedTask getRoundIdentifierForNumber:3]];
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
    headphone.title = AAPLLocalizedString(@"HEADPHONE_DETECT_TITLE", nil);
    headphone.detailText = AAPLLocalizedString(@"HEADPHONE_DETECT_TEXT", nil);
    
    return [headphone copy];
}

+ (AAPLEnvironmentSPLMeterStep *)splmeter {
    AAPLEnvironmentSPLMeterStep *splmeter = [[AAPLEnvironmentSPLMeterStep alloc] initWithIdentifier:ORKTinnitusSPLMeterStepIdentifier];
    splmeter.requiredContiguousSamples = 5;
    splmeter.thresholdValue = 55;
    splmeter.title = AAPLLocalizedString(@"ENVIRONMENTSPL_TITLE_2", nil);
    splmeter.text = AAPLLocalizedString(@"ENVIRONMENTSPL_INTRO_TEXT_2", nil);
    
    return [splmeter copy];
}

+ (ORKTinnitusTypeStep *)tinnitusType {
    ORKTinnitusTypeStep *tinnitusType = [[ORKTinnitusTypeStep alloc] initWithIdentifier:ORKTinnitusTypeStepIdentifier];
    tinnitusType.title = AAPLLocalizedString(@"TINNITUS_TYPE_TITLE", nil);
    tinnitusType.text = AAPLLocalizedString(@"TINNITUS_TYPE_DETAIL", nil);
    tinnitusType.optional = NO;
    return [tinnitusType copy];
}

+ (ORKVolumeCalibrationStep *)calibration {
    ORKVolumeCalibrationStep *calibration = [[ORKVolumeCalibrationStep alloc] initWithIdentifier:ORKTinnitusVolumeCalibrationStepIdentifier];
    calibration.title = AAPLLocalizedString(@"TINNITUS_CALIBRATION_TITLE", nil);
    calibration.text = AAPLLocalizedString(@"TINNITUS_CALIBRATION_TEXT", nil);
    return [calibration copy];
}

+ (ORKVolumeCalibrationStep *)puretoneLoudnessMatching {
    ORKVolumeCalibrationStep *puretoneLoudnessMatching = [[ORKVolumeCalibrationStep alloc] initWithIdentifier:ORKTinnitusPuretoneLoudnessMatchingStepIdentifier];
    puretoneLoudnessMatching.title = AAPLLocalizedString(@"TINNITUS_FINAL_CALIBRATION_TITLE", nil);
    puretoneLoudnessMatching.text = AAPLLocalizedString(@"TINNITUS_FINAL_CALIBRATION_TEXT", nil);
    return [puretoneLoudnessMatching copy];
}

+ (ORKVolumeCalibrationStep *)whitenoiseLoudnessMatching {
    ORKVolumeCalibrationStep *whitenoiseLoudnessMatching = [[ORKVolumeCalibrationStep alloc] initWithIdentifier:ORKTinnitusWhitenoiseLoudnessMatchingStepIdentifier];
    whitenoiseLoudnessMatching.title = AAPLLocalizedString(@"TINNITUS_FINAL_CALIBRATION_TITLE", nil);
    whitenoiseLoudnessMatching.text = AAPLLocalizedString(@"TINNITUS_FINAL_CALIBRATION_TEXT", nil);
    return [whitenoiseLoudnessMatching copy];
}

+ (ORKInstructionStep *)pitchMatchingInstruction {
    ORKInstructionStep *pitchMatchingInstruction = [[ORKInstructionStep alloc] initWithIdentifier:ORKTinnitusPitchMatchingInstructionStepIdentifier];
    pitchMatchingInstruction.title = AAPLLocalizedString(@"TINNITUS_FREQUENCY_MATCHING_TITLE", nil);
    pitchMatchingInstruction.text = AAPLLocalizedString(@"TINNITUS_FREQUENCY_MATCHING_DETAIL", nil);
    
    if (@available(iOS 13.0, *)) {
        ORKBodyItem *item = [[ORKBodyItem alloc] initWithText:AAPLLocalizedString(@"TINNITUS_FREQUENCY_MATCHING_INSTRUCTION_BODY1", nil) detailText:nil image:[UIImage systemImageNamed:@"ear"] learnMoreItem:nil bodyItemStyle:ORKBodyItemStyleImage];
        ORKBodyItem *item2 = [[ORKBodyItem alloc] initWithText:AAPLLocalizedString(@"TINNITUS_FREQUENCY_MATCHING_INSTRUCTION_BODY2", nil) detailText:nil image:[UIImage systemImageNamed:@"timer"] learnMoreItem:nil bodyItemStyle:ORKBodyItemStyleImage];
        pitchMatchingInstruction.bodyItems = @[item,item2];
    }
    
    return [pitchMatchingInstruction copy];
}

+ (NSString *)getRoundIdentifierForNumber:(NSInteger)roundNumber {
    return [NSString stringWithFormat:@"%@_%li",ORKTinnitusRoundStepIdentifier,(long)roundNumber];
}

+ (NSString *)getRoundSuccessIdentifierForNumber:(NSInteger)roundNumber {
    return [NSString stringWithFormat:@"%@_%li",ORKTinnitusRoundSuccessCompletedStepIdentifier,(long)roundNumber];
}

+ (ORKTinnitusPureToneStep *)getPureToneRound:(NSInteger)roundNumber {
    NSString *identifier = [self getRoundIdentifierForNumber:roundNumber];
    ORKTinnitusPureToneStep *round = [[ORKTinnitusPureToneStep alloc] initWithIdentifier:identifier];
    round.title = AAPLLocalizedString(@"TINNITUS_PURETONE_TITLE", nil);
    round.detailText = AAPLLocalizedString(@"TINNITUS_PURETONE_TEXT", nil);
    round.roundNumber = roundNumber;
    return [round copy];
}

+ (ORKInstructionStep *)getPureToneRoundComplete:(NSInteger)roundNumber {
    NSString *identifier = [self getRoundSuccessIdentifierForNumber:roundNumber];
    ORKInstructionStep *roundSuccessCompleted = [[ORKInstructionStep alloc] initWithIdentifier:identifier];
    roundSuccessCompleted.title = [NSString localizedStringWithFormat:AAPLLocalizedString(@"TINNITUS_ROUND_COMPLETE_TITLE", nil),(long)roundNumber];
    roundSuccessCompleted.text = roundNumber == 1 ?  AAPLLocalizedString(@"TINNITUS_ROUND_COMPLETE_TEXT", nil) : AAPLLocalizedString(@"TINNITUS_FINAL_ROUND_COMPLETE_TEXT", nil) ;
    
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

+ (ORKTinnitusOverallAssessmentStep *)overallAssessmentStep {
    ORKTinnitusOverallAssessmentStep *tinnitusAssessmentStep = [[ORKTinnitusOverallAssessmentStep alloc] initWithIdentifier:ORKTinnitusOverallAssessmentStepIdentifier];
    tinnitusAssessmentStep.title = AAPLLocalizedString(@"TINNITUS_ASSESSMENT_TITLE", nil);
    tinnitusAssessmentStep.text = AAPLLocalizedString(@"TINNITUS_ASSESSMENT_TEXT", nil);
    tinnitusAssessmentStep.shouldTintImages = YES;
    return [tinnitusAssessmentStep copy];
}

#pragma mark - Masking Sounds Steps

+ (ORKInstructionStep *)maskingSoundInstructionStep {
    ORKInstructionStep *maskingSoundInstructionStep = [[ORKInstructionStep alloc] initWithIdentifier:ORKTinnitusMaskingSoundInstructionStepIdentifier];
    maskingSoundInstructionStep.title = AAPLLocalizedString(@"TINNITUS_MASKING_INSTRUCTION_TITLE", nil);
    maskingSoundInstructionStep.text = AAPLLocalizedString(@"TINNITUS_MASKING_INSTRUCTION_TEXT", nil);
    
    if (@available(iOS 13.0, *)) {
        ORKBodyItem * item1 = [[ORKBodyItem alloc] initWithText:AAPLLocalizedString(@"TINNITUS_MASKING_INSTRUCTION_BODY1", nil) detailText:nil image:[UIImage systemImageNamed:@"ear.badge.checkmark"] learnMoreItem:nil bodyItemStyle:ORKBodyItemStyleImage];
        ORKBodyItem * item2 = [[ORKBodyItem alloc] initWithText:AAPLLocalizedString(@"TINNITUS_MASKING_INSTRUCTION_BODY2", nil) detailText:nil image:[UIImage systemImageNamed:@"timer"] learnMoreItem:nil bodyItemStyle:ORKBodyItemStyleImage];
        maskingSoundInstructionStep.bodyItems = @[item1, item2];
    }
    
    return [maskingSoundInstructionStep copy];
}

+ (NSArray *)createMaskingStepsForSamples:(NSArray<ORKTinnitusAudioSample *> *)audioSamples {
    NSMutableArray *steps = [[NSMutableArray alloc] init];
    
    for (ORKTinnitusAudioSample *sample in audioSamples) {
        [steps addObject:[ORKTinnitusPredefinedTask maskingSoundCalibrationStepForSample:sample]];
        [steps addObject:[ORKTinnitusPredefinedTask maskingSoundAssessmentStepForSample:sample]];
    }
    return steps;
}

+ (ORKVolumeCalibrationStep *)maskingSoundCalibrationStepForSample:(ORKTinnitusAudioSample *)sample  {
    NSString *identifier = [NSString stringWithFormat:@"%@_calibration", sample.identifier];
    ORKVolumeCalibrationStep *maskingSoundCalibrationStep = [[ORKVolumeCalibrationStep alloc] initWithIdentifier:identifier
                                                                                                maskingSoundName:sample.name
                                                                                          maskingSoundIdentifier:sample.identifier];
    maskingSoundCalibrationStep.title = AAPLLocalizedString(@"TINNITUS_MASKING_TITLE", nil);
    maskingSoundCalibrationStep.text = AAPLLocalizedString(@"TINNITUS_MASKING_VOLUME_CALIBRATION_TEXT", nil);
    maskingSoundCalibrationStep.shouldTintImages = YES;
    return [maskingSoundCalibrationStep copy];
}

+ (ORKTinnitusMaskingSoundStep *)maskingSoundAssessmentStepForSample:(ORKTinnitusAudioSample *)sample {
    NSString *identifier = [NSString stringWithFormat:@"%@_assessment", sample.identifier];
    ORKTinnitusMaskingSoundStep *maskingSoundStep = [[ORKTinnitusMaskingSoundStep alloc] initWithIdentifier:identifier
                                                                                                       name:sample.name
                                                                                            soundIdentifier:sample.identifier];
    maskingSoundStep.title = AAPLLocalizedString(@"TINNITUS_MASKING_TITLE", nil);
    maskingSoundStep.text = AAPLLocalizedString(@"TINNITUS_MASKING_TEXT", nil);
    maskingSoundStep.shouldTintImages = YES;
    return [maskingSoundStep copy];
}

@end
