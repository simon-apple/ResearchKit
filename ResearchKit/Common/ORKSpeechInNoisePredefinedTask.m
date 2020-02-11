//
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
    if (error != nil) {
        ORK_Log_Error("%@", error);
        return nil;
    }
    if (steps == nil) {
        // Something went wrong fetching audio files, return a null task.
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

//TODO: Error arg support.
+ (nullable NSArray<ORKStep *> *)speechInNoisePredefinedTaskStepsWithAudioSetManifestPath:(nonnull NSString *)manifestPath
                                                                                    error:(__unused NSError **)error
{
    return nil;    
}

+ (nullable NSArray<ORKStep *> *)speechInNoisePredefinedTaskStepsWithAudioSetManifestPath:(nonnull NSString *)manifestPath
                                                                             prependSteps:(nullable NSArray<ORKStep *> *)prependSteps
                                                                              appendSteps:(nullable NSArray<ORKStep *> *)appendSteps
                                                                                    error:(__unused NSError **)error {
    NSMutableArray<ORKStep *> *steps = [[NSMutableArray alloc] init];
    if (prependSteps.count > 0) {
        [steps addObjectsFromArray:[prependSteps copy]];
    }
    NSArray *predefinedSteps = [ORKSpeechInNoisePredefinedTask speechInNoisePredefinedTaskStepsWithAudioSetManifestPath:manifestPath error:error];
    NSAssert(predefinedSteps.count > 0, @"Predefined steps count cannot be 0");
    if (predefinedSteps != nil) {
        [steps addObjectsFromArray:predefinedSteps];
    }
    if (appendSteps.count > 0) {
        [steps addObjectsFromArray:[appendSteps copy]];
    }
    return [steps copy];
}

@end
