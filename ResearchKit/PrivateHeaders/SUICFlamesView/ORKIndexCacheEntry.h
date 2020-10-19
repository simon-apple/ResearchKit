//
//  ORKIndexCacheEntry.h
//  SiriUICore
//
//  Created by Tin Tran on 3/15/18.
//  Copyright © 2018 Apple Inc. All rights reserved.
//
#import "ORKFlamesView.h"

extern NSString *ORKGetIndexCacheEntryKey(CGRect activeFrame, ORKFlamesViewFidelity fidelity, CGFloat horizontalScaleFactor, ORKFlamesViewMode mode, int32_t viewWidth, int32_t viewHeight);
@interface ORKIndexCacheEntry : NSObject
@property (nonatomic, assign) uint32_t numAuraIndices;
@property (nonatomic, assign) uint32_t numAuraIndicesCulled;
@property (nonatomic, assign) uint32_t numWaveIndices;
// This is expected to be a manually memory managed pointer.
// free will be called on this pointer when the cache entry is dealloc'd.
@property (nonatomic, assign) uint32_t *metal_indices;
@end
