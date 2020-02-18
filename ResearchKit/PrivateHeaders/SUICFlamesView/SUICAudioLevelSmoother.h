//
//  SUICAudioLevelSmoother.h
//  SiriUICore
//
//  Created by Noah Witherspoon on 6/17/14.
//  Copyright (c) 2014 Apple Inc. All rights reserved.
//

@import Foundation;

@interface SUICAudioLevelSmoother : NSObject
// minPower and maxPower are in dB; historyLength is the number of samples with which to calculate the current median to map power levels around (10 is a reasonable default)
- (instancetype)initWithMinimumPower:(float)minPower maximumPower:(float)maxPower historyLength:(NSInteger)length;
// dB is a logarithmic scale, so this option provides a more accurate mapping to the sound’s perceived amplitude: baseValue ^ (exponentMultiplier * micPower). historyLength is as above.
// for reference, ChatKit on iOS uses this formula with a base value of 10 and an exponent multiplier of .05
- (instancetype)initWithBaseValue:(float)base exponentMultiplier:(float)multiplier historyLength:(NSInteger)length;
// uses two dampening variables to determine amplitude velocity
- (instancetype)initWithMinimumPower:(float)minPower maximumPower:(float)maxPower historyLength:(NSInteger)length attackSpeed:(float)attackSpeed decaySpeed:(float)decaySpeed;
- (float)smoothedLevelForMicPower:(float)power;
- (void)clearHistory;
@property (nonatomic, readonly) BOOL usesExponentialCurve;
@property (nonatomic, readonly) BOOL usesAttackAndDecaySpeed;
@property (nonatomic, assign) float minimumPower; // only applicable if you use the minimumPower/maximumPower initializer
@property (nonatomic, assign) float maximumPower; // only applicable if you use the minimumPower/maximumPower initializer
@property (nonatomic, assign) float attackSpeed; // only applicable if you use the attackSpeed/decaySpeed initializer
@property (nonatomic, assign) float decaySpeed; // only applicable if you use the attackSpeed/decaySpeed initializer
@property (nonatomic, assign) float baseValue; // only applicable if you use the baseValue/exponentMultiplier initializer
@property (nonatomic, assign) float exponentMultiplier; // only applicable if you use the baseValue/exponentMultiplier initializer
@end
