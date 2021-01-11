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

#import <ResearchKit/ResearchKit_Private.h>

static NSString *const ORKTinnitusSurvey1StepIdentifier = @"tinnitus.survey.1";
static NSString *const ORKTinnitusSurvey2StepIdentifier = @"tinnitus.survey.2";
static NSString *const ORKTinnitusSurveyEndStepIdentifier = @"tinnitus.completion.survey";
static NSString *const ORKTinnitusSurvey3StepIdentifier = @"tinnitus.survey.3";
static NSString *const ORKTinnitusSurvey4StepIdentifier = @"tinnitus.survey.4";
static NSString *const ORKTinnitusSurvey5StepIdentifier = @"tinnitus.survey.5";
static NSString *const ORKTinnitusSurvey6StepIdentifier = @"tinnitus.survey.6";
static NSString *const ORKTinnitusSurvey7StepIdentifier = @"tinnitus.survey.7";
static NSString *const ORKTinnitusSurvey8StepIdentifier = @"tinnitus.survey.8";
static NSString *const ORKTinnitusSurvey9StepIdentifier = @"tinnitus.survey.9";
static NSString *const ORKTinnitusSurvey10StepIdentifier = @"tinnitus.survey.10";

static NSString *const ORKTinnitusInstruction1StepIdentifier = @"tinnitus.instruction.1";
static NSString *const ORKTinnitusTestingInstructionStepIdentifier = @"tinnitus.instruction.2";
static NSString *const ORKTinnitusBeforeStartStepIdentifier = @"tinnitus.instruction.3";
static NSString *const ORKTinnitusUnderstandingStepIdentifier = @"tinnitus.instruction.4";
static NSString *const ORKTinnitusPitchMatchingStepIdentifier = @"tinnitus.instruction.5";
static NSString *const ORKTinnitusInstruction6StepIdentifier = @"tinnitus.instruction.6";
static NSString *const ORKTinnitusInstruction7StepIdentifier = @"tinnitus.instruction.7";

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
    return nil;
}

@end
