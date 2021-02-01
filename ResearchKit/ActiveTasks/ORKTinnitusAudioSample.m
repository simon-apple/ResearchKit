/*
 Copyright (c) 2021, Apple Inc. All rights reserved.
 
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

#import "ORKTinnitusAudioSample.h"
#import "ORKHelpers_Internal.h"
#import <AVFoundation/AVFoundation.h>

@implementation ORKTinnitusAudioSample

+ (instancetype)sampleWithPath:(nonnull NSString *)path name:(nonnull NSString *)name identifier:(nonnull NSString *)identifier
{
    return [[ORKTinnitusAudioSample alloc] initWithPath:path name:name identifier:identifier];
}

- (instancetype)initWithPath:(nonnull NSString *)path name:(nonnull NSString *)name identifier:(nonnull NSString *)identifier
{
    self = [super init];
    if (self)
    {
        _path = [path copy];
        _name = [name copy];
        _identifier = [identifier copy];
    }
    return self;
}

- (AVAudioFile *)getFile:(NSError **)outError {
    NSURL *path = [NSURL fileURLWithPath:self.path];
    AVAudioFile *file = [[AVAudioFile alloc] initForReading:path error:outError];
    return file;
}

- (AVAudioPCMBuffer *)getBuffer:(NSError **)outError {
    AVAudioFile *file = [self getFile:outError];
    if (file) {
        AVAudioPCMBuffer *buffer = [[AVAudioPCMBuffer alloc] initWithPCMFormat:file.processingFormat frameCapacity:(AVAudioFrameCount)file.length];
        if ([file readIntoBuffer:buffer error:outError]) {
            return buffer;
        }
    }
    return nil;
}

@end


@implementation ORKTinnitusAudioManifest

+ (instancetype)manifestWithMaskingSamples:(NSArray<ORKTinnitusAudioSample *> *)maskingSamples noiseTypeSamples:(NSArray<ORKTinnitusAudioSample *> *)noiseTypeSamples
{
    return [[ORKTinnitusAudioManifest alloc] initWithMaskingSamples:maskingSamples noiseTypeSamples:noiseTypeSamples];
}

- (instancetype)initWithMaskingSamples:(NSArray<ORKTinnitusAudioSample *> *)maskingSamples noiseTypeSamples:(NSArray<ORKTinnitusAudioSample *> *)noiseTypeSamples
{
    self = [super init];
    if (self)
    {
        _maskingSamples = [maskingSamples copy];
        _noiseTypeSamples = [noiseTypeSamples copy];
    }
    return self;
}

- (ORKTinnitusAudioSample *)sampleWithIdentifier:(NSString *)identifier onArray:(NSArray<ORKTinnitusAudioSample *> *)sampleArray error:(NSError **)outError {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"identifier ==[c] %@", identifier];
    ORKTinnitusAudioSample *audioSample = [[sampleArray filteredArrayUsingPredicate:predicate] firstObject];
    
    if (!audioSample) {
        if (outError != NULL) {
            *outError = [NSError errorWithDomain:NSCocoaErrorDomain
                                            code:NSFeatureUnsupportedError
                                        userInfo:@{NSLocalizedDescriptionKey:[NSString stringWithFormat:ORKLocalizedString(@"TINNITUS_SAMPLE_NOT_FOUND_ERROR", nil), identifier]}];
        }
        return nil;
    }
    
    return audioSample;
}

- (ORKTinnitusAudioSample *)noiseTypeSampleWithIdentifier:(NSString *)identifier error:(NSError **)outError {
    return [self sampleWithIdentifier:identifier onArray:_noiseTypeSamples error:outError];
}

- (ORKTinnitusAudioSample *)maskingSampleWithIdentifier:(NSString *)identifier error:(NSError **)outError {
    return [self sampleWithIdentifier:identifier onArray:_maskingSamples error:outError];
}

@end
