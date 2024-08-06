//  ORKESerializableTableEntry.h
//  ORKCatalog
//
//  Created by Pariece Mckinney on 6/23/24.
//  Copyright © 2024 researchkit.org. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class ORKESerializableTableEntry;

@interface ORKSerializationEntryProvider : NSObject

- (NSMutableDictionary<NSString *, ORKESerializableTableEntry *> *)serializationEncodingTable;

@end

NS_ASSUME_NONNULL_END
