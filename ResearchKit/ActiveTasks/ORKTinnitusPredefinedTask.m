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
#import "ORKTinnitusPredefinedTaskConstants.h"
#import "ORKTinnitusPureToneInstructionStep.h"
#import "ORKTinnitusPureToneStep.h"
#import "ORKTinnitusCalibrationStep.h"
#import "ORKTinnitusTypeStep.h"
#import "ORKTinnitusTypeResult.h"
#import <ResearchKit/ResearchKit_Private.h>

static NSString *const ORKTinnitusBeforeStartStepIdentifier = @"tinnitus.instruction.3";
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
static NSString *const ORKTinnitusMaskingWhitenoiseIdentifier = @"tinnitus.masking.whitenoise";
static NSString *const ORKTinnitusMaskingWhitenoiseNotchIdentifier = @"tinnitus.masking.whitenoise.notch";
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
static NSString *const ORKTinnitusWhitenoiseMatchingIdentifier = @"tinnitus.whitenoise.matching";
static NSString *const ORKTinnitusPitchMatchingStepIdentifier = @"tinnitus.instruction.5";

@implementation ORKTinnitusPredefinedTask

#pragma mark - Initialization

- (instancetype)initWithIdentifier:(nonnull NSString *)identifier
              audioSetManifestPath:(nonnull NSString *)audioSetManifestPath
                      prependSteps:(nullable NSArray<ORKStep *> *)prependSteps
                       appendSteps:(nullable NSArray<ORKStep *> *)appendSteps {

    NSError *error = nil;
    NSArray<ORKStep *> *steps = [ORKTinnitusPredefinedTask tinnitusPredefinedStepsWithAudioSetManifestPath:audioSetManifestPath
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

+ (NSArray<ORKStep *> *)tinnitusPredefinedStepsWithAudioSetManifestPath:(nonnull NSString *)audioSetManifestPath
                                                           prependSteps:(NSArray<ORKStep *> *)prependSteps
                                                            appendSteps:(NSArray<ORKStep *> *)appendSteps
                                                                  error:(NSError * _Nullable * _Nullable)error
{
    NSMutableArray<ORKStep *> *steps = [[NSMutableArray alloc] init];
    
    if (prependSteps.count > 0)
    {
        [steps addObjectsFromArray:[prependSteps copy]];
    }
    
    NSArray *predefinedSteps = [ORKTinnitusPredefinedTask tinnitusPredefinedTaskStepsWithAudioSetManifestPath:audioSetManifestPath error:error];

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

+ (NSArray<ORKStep *> *)tinnitusPredefinedTaskStepsWithAudioSetManifestPath:(nonnull NSString *)manifestPath error:(NSError * _Nullable * _Nullable)error {
      
    NSMutableArray<ORKStep *> *steps = [[NSMutableArray alloc] init];
    
    [steps addObjectsFromArray:@[[self beforeStart],
                                 [self headphone],
                                 [self splmeter],
                                 [self tinnitusType],
                                 [self calibration],
                                 [self pitchMatching]]];
    
    return [steps copy];
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

+ (ORKInstructionStep *)beforeStart {
    
    ORKInstructionStep *beforeStart = [[ORKInstructionStep alloc] initWithIdentifier:ORKTinnitusBeforeStartStepIdentifier];
    beforeStart.title = ORKLocalizedString(@"TINNITUS_BEFORE_TITLE", nil);
    beforeStart.detailText = ORKLocalizedString(@"TINNITUS_BEFORE_TEXT", nil);
    beforeStart.shouldTintImages = YES;
        
    UIImage *img1;
    UIImage *img2;
        
    if (@available(iOS 13.0, *)) {
        img1 = [UIImage systemImageNamed:@"1.circle.fill"];
        img2 = [UIImage systemImageNamed:@"2.circle.fill"];
    } else {
        img1 = [[UIImage imageNamed:@"1.circle.fill" inBundle:ORKBundle() compatibleWithTraitCollection:nil] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        img2 = [[UIImage imageNamed:@"2.circle.fill" inBundle:ORKBundle() compatibleWithTraitCollection:nil] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    }
        
    ORKBodyItem *item1 = [[ORKBodyItem alloc] initWithText:ORKLocalizedString(@"TINNITUS_BEFORE_BODY_ITEM_TEXT_1", nil) detailText:nil image:img1 learnMoreItem:nil bodyItemStyle:ORKBodyItemStyleImage];
    ORKBodyItem *item2 = [[ORKBodyItem alloc] initWithHorizontalRule];
    ORKBodyItem *item3 = [[ORKBodyItem alloc] initWithText:ORKLocalizedString(@"TINNITUS_BEFORE_BODY_ITEM_TEXT_2", nil) detailText:nil image:img2 learnMoreItem:nil bodyItemStyle:ORKBodyItemStyleImage];
    beforeStart.bodyItems = @[item1, item2, item3];

    return [beforeStart copy];
}

+ (ORKHeadphoneDetectStep *)headphone {
    
    ORKHeadphoneDetectStep *headphone = [[ORKHeadphoneDetectStep alloc] initWithIdentifier:ORKTinnitusHeadphoneDetectStepIdentifier headphoneTypes:ORKHeadphoneTypesSupported]
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

+ (ORKTinnitusPureToneInstructionStep *)pitchMatching {
    
    ORKTinnitusPureToneInstructionStep *pitchMatching = [[ORKTinnitusPureToneInstructionStep alloc] initWithIdentifier:ORKTinnitusPitchMatchingStepIdentifier];
    pitchMatching.title = ORKLocalizedString(@"TINNITUS_FREQUENCY_MATCHING_TITLE", nil);
    pitchMatching.text = ORKLocalizedString(@"TINNITUS_FREQUENCY_MATCHING_DETAIL", nil);
    return [pitchMatching copy];
}

@end
