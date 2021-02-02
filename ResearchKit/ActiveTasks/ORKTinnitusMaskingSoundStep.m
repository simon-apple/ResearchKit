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

#import "ORKTinnitusMaskingSoundStep.h"
#import "ORKTinnitusMaskingSoundStepViewController.h"

#import "ORKHelpers_Internal.h"

#define ORKTinnitusTaskMaskingBandwidth 0.34
#define ORKTinnitusTaskMaskingGain -96.0

@implementation ORKTinnitusMaskingSoundStep

+ (Class)stepViewControllerClass {
    return [ORKTinnitusMaskingSoundStepViewController class];
}

- (instancetype)initWithIdentifier:(NSString *)identifier
                              name:(NSString *)name
                   soundIdentifier:(NSString *)soundIdentifier {
    self = [super initWithIdentifier:identifier];
    if (self) {
        [self commonInit];
        self.name = name;
        self.soundIdentifier = soundIdentifier;
    }
    return self;
}

- (instancetype)initWithIdentifier:(NSString *)identifier
                              name:(NSString *)name
                   soundIdentifier:(NSString *)soundIdentifier
                    notchFrequency:(double)notchFrequency {
    self = [super initWithIdentifier:identifier];
    if (self) {
        [self commonInit];
        self.name = name;
        self.soundIdentifier = soundIdentifier;
        self.notchFrequency = notchFrequency;
    }
    return self;
}

- (void)commonInit {
    self.notchFrequency = 0.0;
    self.bandwidth = ORKTinnitusTaskMaskingBandwidth;
    self.gain = ORKTinnitusTaskMaskingGain;
}

- (void)validateParameters {
    [super validateParameters];
    
    if ( !self.soundIdentifier || self.soundIdentifier.length == 0) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Matching sound identifier cannot be nil or empty" userInfo:nil];
    }
}

- (BOOL)startsFinished {
    return NO;
}

- (BOOL)shouldContinueOnFinish {
    return YES;
}

- (instancetype)copyWithZone:(NSZone *)zone {
    ORKTinnitusMaskingSoundStep *step = [super copyWithZone:zone];
    step.name = [self.name copy];
    step.soundIdentifier = [self.soundIdentifier copy];
    step.notchFrequency = self.notchFrequency;
    step.bandwidth = self.bandwidth;
    step.gain = self.gain;
    return step;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        ORK_DECODE_DOUBLE(aDecoder, bandwidth);
        ORK_DECODE_DOUBLE(aDecoder, gain);
        ORK_DECODE_OBJ(aDecoder, name);
        ORK_DECODE_OBJ(aDecoder, soundIdentifier);
        ORK_DECODE_DOUBLE(aDecoder, notchFrequency);
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    ORK_ENCODE_DOUBLE(aCoder, bandwidth);
    ORK_ENCODE_DOUBLE(aCoder, gain);
    ORK_ENCODE_OBJ(aCoder, name);
    ORK_ENCODE_OBJ(aCoder, soundIdentifier);
    ORK_ENCODE_DOUBLE(aCoder, notchFrequency);
}

+ (BOOL)supportsSecureCoding {
    return YES;
}
- (NSUInteger)hash {
    return super.hash ^ self.name.hash ^ self.soundIdentifier.hash;
}

- (BOOL)isEqual:(id)object {
    BOOL isParentSame = [super isEqual:object];
    
    __typeof(self) castObject = object;
    return (isParentSame
            && [self.name isEqual:castObject.name]
            && [self.soundIdentifier isEqual:castObject.soundIdentifier]
            && (self.notchFrequency == castObject.notchFrequency)
            && (self.bandwidth == castObject.bandwidth)
            && (self.gain == castObject.gain)
            );
}


@end
