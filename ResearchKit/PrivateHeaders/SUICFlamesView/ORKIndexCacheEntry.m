//
//  ORKIndexCacheEntry.m
//  SiriUICore
//
//  Created by Tin Tran on 3/15/18.
//  Copyright © 2018 Apple Inc. All rights reserved.
//
// apple-internal

#if RK_APPLE_INTERNAL

#import "ORKIndexCacheEntry.h"
NSString *ORKGetIndexCacheEntryKey(CGRect activeFrame, ORKFlamesViewFidelity fidelity, CGFloat horizontalScaleFactor, ORKFlamesViewMode mode, int32_t viewWidth, int32_t viewHeight) {
    return [NSString stringWithFormat:@"%@.%ld.%.2f.%ld.%d.%d", NSStringFromCGRect(activeFrame), (long)fidelity, horizontalScaleFactor, (long)mode, viewWidth, viewHeight];
}
@implementation ORKIndexCacheEntry
- (void)dealloc {
    free(_metal_indices);
}
@end

#endif
