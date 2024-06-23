//  ORKCoreSerializationEntryProvider.m
//  ORKCatalog
//
//  Created by Pariece Mckinney on 6/23/24.
//  Copyright © 2024 researchkit.org. All rights reserved.
//

#import "ORKCoreSerializationEntryProvider.h"

#import <ResearchKit/ResearchKit.h>
#import <ResearchKit/ResearchKit_Private.h>


@implementation ORKCoreSerializationEntryProvider

- (NSMutableDictionary<NSString *,ORKESerializableTableEntry *> *)serializationEncodingTable {
    static NSMutableDictionary<NSString *, ORKESerializableTableEntry *> *internalEncodingTable = nil;
    
    internalEncodingTable =
        [@{
           ENTRY(ORKResultSelector,
                 ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
                     ORKResultSelector *selector = [[ORKResultSelector alloc] initWithTaskIdentifier:GETPROP(dict, taskIdentifier)
                                                                                      stepIdentifier:GETPROP(dict, stepIdentifier)
                                                                                    resultIdentifier:GETPROP(dict, resultIdentifier)];
                     return selector;
                 },
                 (@{
                      PROPERTY(taskIdentifier, NSString, NSObject, YES, nil, nil),
                      PROPERTY(stepIdentifier, NSString, NSObject, YES, nil, nil),
                      PROPERTY(resultIdentifier, NSString, NSObject, YES, nil, nil),
                      }))
        } mutableCopy];
    
    return internalEncodingTable;
}

@end
