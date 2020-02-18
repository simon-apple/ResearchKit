//
//  SUICFlamesViewMetal.h
//
//  Created by Brandon Newendorp on 3/5/13.
//  Copyright (c) 2013-2014 Apple Inc. All rights reserved.
//

#import <MetalKit/MTKView.h>
#import "SUICFlamesViewProviding.h"

NS_CLASS_AVAILABLE_IOS(13_0)
@interface SUICFlamesViewMetal : MTKView <SUICFlamesViewProviding>

// The frame passed here is the space to render the aura.

// screenScale is the scale that Metal should use when configuring itself

// fidelity: quality of the renderer. This value is ignored when setting mode to SUICFlamesViewModeDictation because this mode generates a fidelity based on the activeFrame's width.

// Low fidelity is intended to be used by Apple Watch

- (id)initWithFrame:(CGRect)frame screenScale:(CGFloat)screenScale fidelity:(SUICFlamesViewFidelity)fidelity NS_DEPRECATED_IOS(9_0, 9_0, "Please use initWithFrame:screen:fidelity: instead");

- (id)initWithFrame:(CGRect)frame screen:(UIScreen *)screen fidelity:(SUICFlamesViewFidelity)fidelity;

@end
