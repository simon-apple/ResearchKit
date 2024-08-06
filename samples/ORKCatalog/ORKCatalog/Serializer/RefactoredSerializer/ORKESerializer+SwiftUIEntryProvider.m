//  ORKESerializer+SwiftUIEntryProvider.m
//  ORKCatalog
//
//  Created by Pariece Mckinney on 7/5/24.
//  Copyright © 2024 researchkit.org. All rights reserved.
//

#import "ORKESerializer+SwiftUIEntryProvider.h"

#import "ORKSwiftUISerializationEntryProvider.h"

@implementation ORKIESerializer (SerializationEntryProvider)

+ (id)swiftUI_objectFromJSONData:(NSData *)data error:(NSError *__autoreleasing  _Nullable *)error {
    ORKSwiftUISerializationEntryProvider *swiftUIEntryProvider = [ORKSwiftUISerializationEntryProvider new];
    ORKIESerializer *serializer = [[ORKIESerializer alloc] initWithEntryProviders:@[swiftUIEntryProvider]];
    return [serializer objectFromJSONData:data error:error];
}

@end
