//
//  ORKFlamesViewLegacy.h
//
//  Created by Brandon Newendorp on 3/5/13.
//  Copyright (c) 2013-2014 Apple Inc. All rights reserved.
//
// apple-internal

#if APPLE_INTERNAL

#import <UIKit/UIKit.h>
#import "ORKFlamesViewProviding.h"

NS_CLASS_AVAILABLE_IOS(9_0)
@interface ORKFlamesViewLegacy : UIView <ORKFlamesViewProviding>

// The frame passed here is the space to render the aura.

// screenScale is the scale that GL should use when configuring itself

// fidelity: quality of the renderer. This value is ignored when setting mode to ORKFlamesViewModeDictation because this mode generates a fidelity based on the activeFrame's width.

// Low fidelity is intended to be used by Apple Watch

- (id)initWithFrame:(CGRect)frame screenScale:(CGFloat)screenScale fidelity:(ORKFlamesViewFidelity)fidelity NS_DEPRECATED_IOS(9_0, 9_0, "Please use initWithFrame:screen:fidelity: instead");

- (id)initWithFrame:(CGRect)frame screen:(UIScreen *)screen fidelity:(ORKFlamesViewFidelity)fidelity;

@end

#endif
