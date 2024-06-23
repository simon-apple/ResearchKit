//
//  ORKESerializableTableEntry.h
//  ORKCatalog
//
//  Created by Pariece Mckinney on 6/23/24.
//  Copyright © 2024 researchkit.org. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class ORKESerializationContext;

typedef _Nullable id (^ORKESerializationPropertyGetter)(NSDictionary *dict, NSString *property);
typedef _Nullable id (^ORKESerializationInitBlock)(NSDictionary *dict, ORKESerializationPropertyGetter getter);
typedef _Nullable id (^ORKESerializationObjectToJSONBlock)(id object, ORKESerializationContext *context);
typedef _Nullable id (^ORKESerializationJSONToObjectBlock)(id jsonObject, ORKESerializationContext *context);

@interface ORKESerializableProperty : NSObject

- (instancetype)initWithPropertyName:(NSString *)propertyName
                          valueClass:(Class)valueClass
                      containerClass:(Class)containerClass
                      writeAfterInit:(BOOL)writeAfterInit
                   objectToJSONBlock:(ORKESerializationObjectToJSONBlock)objectToJSON
                   jsonToObjectBlock:(ORKESerializationJSONToObjectBlock)jsonToObjectBlock
                   skipSerialization:(BOOL)skipSerialization;

@property (nonatomic, copy) NSString *propertyName;
@property (nonatomic) Class valueClass;
@property (nonatomic) Class containerClass;
@property (nonatomic) BOOL writeAfterInit;
@property (nonatomic, copy) ORKESerializationObjectToJSONBlock objectToJSONBlock;
@property (nonatomic, copy) ORKESerializationJSONToObjectBlock jsonToObjectBlock;
@property (nonatomic) BOOL skipSerialization;

@end

@interface ORKESerializableTableEntry : NSObject

- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithClass:(Class)class
                    initBlock:(ORKESerializationInitBlock)initBlock
                   properties:(NSDictionary<NSString *, ORKESerializableProperty *> *)properties NS_DESIGNATED_INITIALIZER;

@property (nonatomic) Class class;
@property (nonatomic, copy) ORKESerializationInitBlock initBlock;
@property (nonatomic, strong) NSMutableDictionary<NSString *, ORKESerializableProperty *> *properties;

@end

@interface ORKSerializationEntryProvider : NSObject

- (NSMutableDictionary<NSString *, ORKESerializableTableEntry *> *)serializationEncodingTable;

@end

NS_ASSUME_NONNULL_END
