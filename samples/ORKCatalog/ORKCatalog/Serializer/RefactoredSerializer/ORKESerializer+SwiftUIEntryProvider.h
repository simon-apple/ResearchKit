//  ORKESerializer+SwiftUIEntryProvider.h
//  ORKCatalog
//
//  Created by Pariece Mckinney on 7/5/24.
//  Copyright © 2024 researchkit.org. All rights reserved.
//

#import "ORKIESerializer.h"

NS_ASSUME_NONNULL_BEGIN

@interface ORKIESerializer (SerializationEntryProvider)

+ (id)swiftUI_objectFromJSONData:(NSData *)data error:(NSError **)error;

@end

NS_ASSUME_NONNULL_END
