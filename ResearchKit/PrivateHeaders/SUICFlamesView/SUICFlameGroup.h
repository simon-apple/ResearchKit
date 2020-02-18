//
//  SUICFlameGroup.h
//  SiriUICore
//
//  Created by Peter Bohac on 5/26/19.
//  Copyright © 2019 Apple Inc. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <simd/simd.h>
NS_ASSUME_NONNULL_BEGIN
NS_CLASS_AVAILABLE_IOS(9_0) @interface SUICFlameGroup : NSObject
@property (nonatomic, assign) float stateTime;
@property (nonatomic, assign) float zTime;
@property (nonatomic, assign) float globalAlpha;
@property (nonatomic, assign) float transitionPhase;
@property (nonatomic, assign) float* transitionPhasePtr;
@property (nonatomic, assign) vector_float4 stateModifiers;
@property (nonatomic, assign) vector_float4* stateModifiersPtr;
@property (nonatomic, assign) BOOL isAura;
@property (nonatomic, assign) BOOL isDyingOff;
@end
NS_ASSUME_NONNULL_END
