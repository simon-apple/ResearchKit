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

#import "ORKVolumeCalibrationStep.h"
#import "ORKVolumeCalibrationStepViewController.h"

#import "ORKHelpers_Internal.h"

@implementation ORKVolumeCalibrationStep

+ (Class)stepViewControllerClass {
    return [ORKVolumeCalibrationStepViewController class];
}

- (instancetype)initWithIdentifier:(NSString *)identifier maskingSoundName:(NSString *)name maskingSoundIdentifier:(NSString *)soundIdentifier {
    self = [super initWithIdentifier:identifier];
    if (self) {
        self.maskingSoundName = name;
        self.maskingSoundIdentifier = soundIdentifier;
    }
    return self;
}

- (instancetype)copyWithZone:(NSZone *)zone {
    ORKVolumeCalibrationStep *step = [super copyWithZone:zone];
    step.maskingSoundName = [self.maskingSoundName copy];
    step.maskingSoundIdentifier = [self.maskingSoundIdentifier copy];
    return step;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        ORK_DECODE_OBJ(aDecoder, maskingSoundName);
        ORK_DECODE_OBJ(aDecoder, maskingSoundIdentifier);
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    ORK_ENCODE_OBJ(aCoder, maskingSoundName);
    ORK_ENCODE_OBJ(aCoder, maskingSoundIdentifier);
}

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (BOOL)shouldContinueOnFinish {
    return YES;
}

- (BOOL)startsFinished {
    return NO;
}

- (NSUInteger)hash {
    return super.hash ^ self.maskingSoundName.hash ^ self.maskingSoundIdentifier.hash;
}

- (BOOL)isEqual:(id)object {
    BOOL isParentSame = [super isEqual:object];
    
    __typeof(self) castObject = object;
    return (isParentSame
            && ORKEqualObjects(self.maskingSoundName, castObject.maskingSoundName)
            && ORKEqualObjects(self.maskingSoundIdentifier, castObject.maskingSoundIdentifier)
            );
}

@end
