//
//  SUICIndexCacheEntry.m
//  SiriUICore
//
//  Created by Tin Tran on 3/15/18.
//  Copyright © 2018 Apple Inc. All rights reserved.
//
#import "SUICIndexCacheEntry.h"
NSString *SUICGetIndexCacheEntryKey(CGRect activeFrame, SUICFlamesViewFidelity fidelity, CGFloat horizontalScaleFactor, SUICFlamesViewMode mode, int32_t viewWidth, int32_t viewHeight) {
    return [NSString stringWithFormat:@"%@.%ld.%.2f.%ld.%d.%d", NSStringFromCGRect(activeFrame), (long)fidelity, horizontalScaleFactor, (long)mode, viewWidth, viewHeight];
}
@implementation SUICIndexCacheEntry
- (void)dealloc {
    free(_metal_indices);
}
@end

