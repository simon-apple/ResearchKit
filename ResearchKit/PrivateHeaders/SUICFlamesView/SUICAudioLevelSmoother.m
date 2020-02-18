//
//  SUICAudioLevelSmoother.m
//  SiriUICore
//
//  Created by Noah Witherspoon on 6/17/14.
//  Copyright (c) 2014 Apple Inc. All rights reserved.
//
#import "SUICAudioLevelSmoother.h"

@interface SUICAudioLevelSmoother ()
{
    float _minimumPower;
    float _maximumPower;
    NSInteger _historyLength;
    NSInteger _samplesSinceLastCleared; // goes from 0 to _historyLength; after that we don’t care
    float *_runningPowerLevels;
    unsigned _powerPointer;
    
    float _previousLevel;
    
    float _attackVelocity;
    float _decayVelocity;
}

@end

@implementation SUICAudioLevelSmoother
- (instancetype)initWithMinimumPower:(float)minPower maximumPower:(float)maxPower historyLength:(NSInteger)length {
    self = [self _initWithHistoryLength:length];
    if (self) {
        _minimumPower = minPower;
        _maximumPower = maxPower;
    }
    return self;
}
- (instancetype)initWithMinimumPower:(float)minPower maximumPower:(float)maxPower historyLength:(NSInteger)length attackSpeed:(float)attackSpeed decaySpeed:(float)decaySpeed {
    self = [self initWithMinimumPower:minPower maximumPower:maxPower historyLength:length];
    
    if (self) {
        _previousLevel = 0;
        _attackVelocity = 0;
        _decayVelocity = 0;
        _attackSpeed = attackSpeed;
        _decaySpeed = decaySpeed;
        _usesAttackAndDecaySpeed = YES;
    }
    
    return self;
}
- (instancetype)initWithBaseValue:(float)base exponentMultiplier:(float)multiplier historyLength:(NSInteger)length {
    self = [self _initWithHistoryLength:length];
    if (self) {
        _baseValue = base;
        _exponentMultiplier = multiplier;
        _usesExponentialCurve = YES;
    }
    return self;
}
- (instancetype)_initWithHistoryLength:(NSInteger)length {
    self = [super init];
    if (self) {
        _runningPowerLevels = calloc(sizeof(float), length);
        _powerPointer = 0;
        _samplesSinceLastCleared = 0;
        _historyLength = length;
    }
    return self;
}
- (void)clearHistory {
    memset(_runningPowerLevels, 0, sizeof(float) * _historyLength);
    _powerPointer = 0;
    _samplesSinceLastCleared = 0;
}
- (void)dealloc {
    free(_runningPowerLevels);
}
// this is the same math used for _UISiriWaveyView in Purple
- (float)_updateMedianWithNewValue:(float)power {
    // Put our new value into the ring buffer.
    _runningPowerLevels[_powerPointer++] = power;
    if (_powerPointer >= _historyLength) _powerPointer = 0;
    NSInteger relevantHistoryLength = _historyLength;
    if (_samplesSinceLastCleared < _historyLength) {
        _samplesSinceLastCleared++;
        relevantHistoryLength = _samplesSinceLastCleared;
    }
    // A non-insertion-sorted version of this should be ~30% faster, but
    // time here is dwarfed by time elsewhere.
    float *sortedLevels = calloc(sizeof(float), relevantHistoryLength);
    for (int i = 0; i < relevantHistoryLength; i++) {
        BOOL didInsert = NO;
        for (NSInteger j = 0; j < relevantHistoryLength; j++) {
            if (_runningPowerLevels[i] < sortedLevels[j]) {
                // Shift everything over by one.
                for (NSInteger k = relevantHistoryLength - 1; k > j; k--) {
                    sortedLevels[k] = sortedLevels[k-1];
                }
                sortedLevels[j] = _runningPowerLevels[i];
                didInsert = YES;
                break;
            }
        }
        if (!didInsert) {
            sortedLevels[relevantHistoryLength - 1] = _runningPowerLevels[i];
        }
    }
    float median = sortedLevels[(int)(relevantHistoryLength / 2)];
    free(sortedLevels);
    return median;
}
- (float)smoothedLevelForMicPower:(float)power {
    // when the mic is off, the value is 0.00000. this should be set to _minimumPower to perceptually set mic to muted
    power = (power >= -0.01) ? _minimumPower : power;
    float currentPowerLevel = [self _updateMedianWithNewValue:power];
    
    float result;
    if (_usesExponentialCurve) {
        result = powf(_baseValue, currentPowerLevel * _exponentMultiplier);
    } else if (_usesAttackAndDecaySpeed) {
        currentPowerLevel = (currentPowerLevel - _minimumPower) / (_maximumPower - _minimumPower);
        float vel = MAX(0, currentPowerLevel - _previousLevel);
        _attackVelocity += (vel - _attackVelocity) * _attackSpeed;
        _previousLevel += _attackVelocity;
        result = _previousLevel;
        _previousLevel *= _decaySpeed;
    } else {
        result = (currentPowerLevel - _minimumPower) / (_maximumPower - _minimumPower);
    }
    result = MIN(1.0, result);
    result = MAX(0.0, result);
    return result;
}
@end
