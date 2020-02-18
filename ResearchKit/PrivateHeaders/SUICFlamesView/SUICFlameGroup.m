//
//  SUICFlameGroup.m
//  SiriUICore
//
//  Created by Peter Bohac on 5/26/19.
//  Copyright © 2019 Apple Inc. All rights reserved.
//
#import "SUICFlameGroup.h"
@implementation SUICFlameGroup
- (id)init {
    self = [super init];
    if (!self) {
        return nil;
    }
    _stateTime = 0.0;
    _zTime = 0.0;
    _transitionPhase = 0.0;
    _transitionPhasePtr = &_transitionPhase;
    _stateModifiers = (vector_float4){1.0, 0.0, 0.0, 0.0};
    _stateModifiersPtr = &_stateModifiers;
    _globalAlpha = 1.0;
    _isAura = NO;
    _isDyingOff = NO;
    return self;
}
- (NSString *)description {
    return [NSString stringWithFormat:@"stateTime: %f  zTime: %f  transitionPhase: %f  stateModifiers: %f, %f, %f, %f  globalAlpha: %f  isAura: %@  isDyingOff: %@", _stateTime, _zTime, _transitionPhase, _stateModifiers.x, _stateModifiers.y, _stateModifiers.z, _stateModifiers.w, _globalAlpha, @(_isAura), @(_isDyingOff)];
}
@end
