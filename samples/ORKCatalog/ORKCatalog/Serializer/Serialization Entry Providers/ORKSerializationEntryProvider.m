//  ORKESerializableTableEntry.m
//  ORKCatalog
//
//  Created by Pariece Mckinney on 6/23/24.
//  Copyright © 2024 researchkit.org. All rights reserved.
//

#import "ORKSerializationEntryProvider.h"

//#import "ORKESerialization.h"

#import <ResearchKit/ResearchKit.h>


@implementation ORKSerializationEntryProvider

- (nonnull NSMutableDictionary<NSString *,ORKESerializableTableEntry *> *)serializationEncodingTable {
    return [NSMutableDictionary new];
}

@end
