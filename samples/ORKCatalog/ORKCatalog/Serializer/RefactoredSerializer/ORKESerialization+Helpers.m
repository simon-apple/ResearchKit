//  ORKESerialization+Helpers.m
//  ORKCatalog
//
//  Created by Pariece Mckinney on 6/28/24.
//  Copyright © 2024 researchkit.org. All rights reserved.
//

#import "ORKESerialization+Helpers.h"

#import <ResearchKit/ORKAnswerFormat.h>

static NSString *_ClassKey = @"_class";


@implementation ORKESerializationBundleLocalizer

- (instancetype)initWithBundle:(NSBundle *)bundle tableName:(NSString *)tableName {
    self = [super init];
    if (self) {
        _bundle = bundle;
        _tableName = [tableName copy];
    }
    return self;
}

- (NSString *)localizedStringForKey:(NSString *)string
{
    // Keys that exist in the localization table will be localized.
    //
    // If the key is not found in the table the provided key string will be returned as is,
    // supporting the expected functionality for inputs that contain both strings to be
    // localized as well as strings to be displayed as is.
    return [self.bundle localizedStringForKey:string value:string table:self.tableName];
}

@end


@implementation ORKESerializationPropertyModifier

- (instancetype)initWithKeypath:(NSString *)keypath value:(id)value type:(ORKESerializationPropertyModifierType)type {
    self = [super init];
    if (self) {
        _keypath = [keypath copy];
        _value = [value copy];
        _type = type;
    }
    return self;
}

@end


@implementation ORKESerializationPropertyInjector

- (instancetype)initWithBasePath:(NSString *)basePath modifiers:(NSArray<ORKESerializationPropertyModifier *> *)modifiers {
    self = [super init];
    if (self) {
        _basePath = [basePath copy];
        NSMutableDictionary *propertyValues = [NSMutableDictionary dictionary];
        [modifiers enumerateObjectsUsingBlock:^(ORKESerializationPropertyModifier * _Nonnull obj, __unused NSUInteger idx, __unused BOOL * _Nonnull stop) {
            if (obj.type == ORKESerializationPropertyModifierTypePath && [obj.value isKindOfClass:[NSString class]]) {
                propertyValues[obj.keypath] = [_basePath stringByAppendingPathComponent:(NSString *)obj.value];
            } else {
                propertyValues[obj.keypath] = obj.value;
            }
        }];
        _propertyValues = [propertyValues copy];
        
    }
    return self;
}

- (NSDictionary *)injectedDictionaryWithDictionary:(NSDictionary *)inputDictionary {
    NSMutableDictionary *mutatedDictionary = [inputDictionary mutableCopy];
    [_propertyValues enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull keypath, id  _Nonnull obj, __unused BOOL * _Nonnull stop) {
        NSArray<NSString *> *components = [keypath componentsSeparatedByString:@"."];
        NSCAssert(components.count == 2, @"Unexpected number of components in keypath %@", keypath);
        NSString *class = components[0];
        NSString *key = components[1];
        // Only inject the property if it's the corresponding class,and the key exists in the dictionary
        if ([class isEqualToString:mutatedDictionary[_ClassKey]] && mutatedDictionary[key] != nil) {
            mutatedDictionary[key] = obj;
        }
    }];
    return [mutatedDictionary copy];
}

@end


@implementation ORKESerializationBundleImageProvider

- (instancetype)initWithBundle:(NSBundle *)bundle {
    self = [super init];
    if (self) {
        _bundle = bundle;
    }
    return self;
}

- (UIImage *)imageForReference:(NSDictionary *)reference {
    NSString *imageName = [reference objectForKey:ORKESerializationKeyImageName];
    // Try to get a system symbol image first
    UIImage *image = [UIImage systemImageNamed:imageName];
    if (image == nil) {
        image = [UIImage imageNamed:imageName inBundle:_bundle compatibleWithTraitCollection:[UITraitCollection traitCollectionWithUserInterfaceIdiom:[UIDevice currentDevice].userInterfaceIdiom]];
    }
    return image;
}

// Writing to bundle is not supported: supply a placeholder
- (nullable NSDictionary *)referenceBySavingImage:(UIImage __unused *)image {
    return @{ORKESerializationKeyImageName : @""};
}

@end

@implementation ORKESerializationContext

- (instancetype)initWithLocalizer:(nullable id<ORKESerializationLocalizer>)localizer
                    imageProvider:(nullable id<ORKESerializationImageProvider>)imageProvider
               stringInterpolator:(nullable id<ORKESerializationStringInterpolator>)stringInterpolator
                 propertyInjector:(nullable ORKESerializationPropertyInjector *)propertyInjector {
    self = [super init];
    if (self) {
        _localizer = localizer;
        _imageProvider = imageProvider;
        _stringInterpolator = stringInterpolator;
        _propertyInjector = propertyInjector;
    }
    return self;
}

@end

@implementation ORKESerializableProperty

- (instancetype)initWithPropertyName:(NSString *)propertyName
                          valueClass:(Class)valueClass
                      containerClass:(Class)containerClass
                      writeAfterInit:(BOOL)writeAfterInit
                   objectToJSONBlock:(ORKESerializationObjectToJSONBlock)objectToJSON
                   jsonToObjectBlock:(ORKESerializationJSONToObjectBlock)jsonToObjectBlock
                   skipSerialization:(BOOL)skipSerialization {
    self = [super init];
    if (self) {
        _propertyName = propertyName;
        _valueClass = valueClass;
        _containerClass = containerClass;
        _writeAfterInit = writeAfterInit;
        _objectToJSONBlock = objectToJSON;
        _jsonToObjectBlock = jsonToObjectBlock;
        _skipSerialization = skipSerialization;
    }
    return self;
}

- (instancetype)imagePropertyObjectWithPropertyName:(NSString *)propertyName 
                                     containerClass:(Class)containerClass
                                     writeAfterInit:(BOOL)writeAfterInit
                                  skipSerialization:(BOOL)skipSerialization {
    return [[ORKESerializableProperty alloc] initWithPropertyName:propertyName
                                                       valueClass:[UIImage class]
                                                   containerClass:containerClass
                                                   writeAfterInit:writeAfterInit
                                                objectToJSONBlock:^id _Nullable(id object, ORKESerializationContext *context) { return [context.imageProvider referenceBySavingImage:object]; }
                                                jsonToObjectBlock:^id _Nullable(id jsonObject, ORKESerializationContext *context) { return [context.imageProvider imageForReference:jsonObject]; }
                                                skipSerialization:skipSerialization];
}

@end

@implementation ORKESerializableTableEntry

- (instancetype)initWithClass:(Class)class
                    initBlock:(ORKESerializationInitBlock)initBlock
                   properties:(NSDictionary *)properties {
    self = [super init];
    if (self) {
        _class = class;
        _initBlock = initBlock;
        _properties = [properties mutableCopy];
    }
    return self;
}

@end


@implementation ORKESerializerHelper

+ (NSArray *)ORKChoiceAnswerStyleTable {
    static NSArray *table;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        table = @[@"singleChoice", @"multipleChoice"];
    });
    
    return table;
}

+ (NSArray *)ORKDateAnswerStyleTable {
    static NSArray *table = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        table = @[@"dateTime", @"date"];
    });
    return table;
}

+ (NSArray *)ORKNumericAnswerStyleTable {
    static NSArray *table = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        table = @[@"decimal", @"integer"];
    });
    return table;
}

+ (ORKNumericAnswerStyle)ORKNumericAnswerStyleFromString:(NSString *)string {
    return (ORKNumericAnswerStyle)[self tableMapReverseWithValue:string table:[self ORKNumericAnswerStyleTable]];
}

+ (NSString *)ORKNumericAnswerStyleToStringWithStyle:(ORKNumericAnswerStyle)style {
    return [self tableMapForwardWithIndex:style table:[self ORKNumericAnswerStyleTable]];
}

+ (id)tableMapForwardWithIndex:(NSInteger)index table:(NSArray *)table {
    return table[(NSUInteger)index];
}

+ (NSInteger)tableMapReverseWithValue:(id)value table:(NSArray *)table {
    NSUInteger idx = [table indexOfObject:value];
    if (idx == NSNotFound) {
        idx = 0;
    }
    return (NSInteger)idx;
}

+ (NSArray *)numberFormattingStyleTable {
    static NSArray *table = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        table = @[@"default", @"percent"];
    });
    return table;
}

+ (NSDictionary *)dictionaryFromRegularExpression:(NSRegularExpression *)regularExpression {
    NSDictionary *dictionary = regularExpression ?
    @{
      @"pattern": regularExpression.pattern ?: @"",
      @"options": [self arrayFromRegularExpressionOptions:regularExpression.options]
      } :
    @{};
    return dictionary;
}

+ (NSArray *)arrayFromRegularExpressionOptions:(NSRegularExpressionOptions)regularExpressionOptions {
    NSMutableArray *optionsArray = [NSMutableArray new];
    if (regularExpressionOptions & NSRegularExpressionCaseInsensitive) {
        [optionsArray addObject:@"NSRegularExpressionCaseInsensitive"];
    }
    if (regularExpressionOptions & NSRegularExpressionAllowCommentsAndWhitespace) {
        [optionsArray addObject:@"NSRegularExpressionAllowCommentsAndWhitespace"];
    }
    if (regularExpressionOptions & NSRegularExpressionIgnoreMetacharacters) {
        [optionsArray addObject:@"NSRegularExpressionIgnoreMetacharacters"];
    }
    if (regularExpressionOptions & NSRegularExpressionDotMatchesLineSeparators) {
        [optionsArray addObject:@"NSRegularExpressionDotMatchesLineSeparators"];
    }
    if (regularExpressionOptions & NSRegularExpressionAnchorsMatchLines) {
        [optionsArray addObject:@"NSRegularExpressionAnchorsMatchLines"];
    }
    if (regularExpressionOptions & NSRegularExpressionUseUnixLineSeparators) {
        [optionsArray addObject:@"NSRegularExpressionUseUnixLineSeparators"];
    }
    if (regularExpressionOptions & NSRegularExpressionUseUnicodeWordBoundaries) {
        [optionsArray addObject:@"NSRegularExpressionUseUnicodeWordBoundaries"];
    }
    return [optionsArray copy];
}

+ (NSRegularExpression *)regularExpressionsFromDictionary:(NSDictionary *)dict {
    NSRegularExpression *regularExpression;
    if (dict.count == 2) {
        regularExpression = [NSRegularExpression regularExpressionWithPattern:dict[@"pattern"]
                                                                      options:[self regularExpressionOptionsFromArray:dict[@"options"]]
                                                                        error:nil];
    }
    return regularExpression;
}

+ (NSRegularExpressionOptions)regularExpressionOptionsFromArray:(NSArray *)array {
    NSRegularExpressionOptions regularExpressionOptions = 0;
    for (NSString *optionString in array) {
        if ([optionString isEqualToString:@"NSRegularExpressionCaseInsensitive"]) {
            regularExpressionOptions |= NSRegularExpressionCaseInsensitive;
        }
        else if ([optionString isEqualToString:@"NSRegularExpressionAllowCommentsAndWhitespace"]) {
            regularExpressionOptions |= NSRegularExpressionAllowCommentsAndWhitespace;
        }
        else if ([optionString isEqualToString:@"NSRegularExpressionIgnoreMetacharacters"]) {
            regularExpressionOptions |= NSRegularExpressionIgnoreMetacharacters;
        }
        else if ([optionString isEqualToString:@"NSRegularExpressionDotMatchesLineSeparators"]) {
            regularExpressionOptions |= NSRegularExpressionDotMatchesLineSeparators;
        }
        else if ([optionString isEqualToString:@"NSRegularExpressionAnchorsMatchLines"]) {
            regularExpressionOptions |= NSRegularExpressionAnchorsMatchLines;
        }
        else if ([optionString isEqualToString:@"NSRegularExpressionUseUnixLineSeparators"]) {
            regularExpressionOptions |= NSRegularExpressionUseUnixLineSeparators;
        }
        else if ([optionString isEqualToString:@"NSRegularExpressionUseUnicodeWordBoundaries"]) {
            regularExpressionOptions |= NSRegularExpressionUseUnicodeWordBoundaries;
        }
    }
    return regularExpressionOptions;
}

+ (NSDictionary *)dictionaryFromPasswordRules:(UITextInputPasswordRules *)passwordRules {
    NSDictionary *dictionary = passwordRules ?
    @{
      @"rules": passwordRules.passwordRulesDescriptor ?: @""
      } :
    @{};
    return dictionary;
}

+ (UITextInputPasswordRules *)passwordRulesFromDictionary:(NSDictionary *)dict {
    UITextInputPasswordRules *passwordRules;
    if (dict.count == 1) {
        passwordRules = [UITextInputPasswordRules passwordRulesWithDescriptor:dict[@"rules"]];
    }
    return passwordRules;
}

+ (NSString *)ORKMeasurementSystemToString:(ORKMeasurementSystem)measurementSystem {
    return [self tableMapForwardWithIndex:measurementSystem table:[self ORKMeasurementSystemTable]];
}

+ (NSArray *)ORKMeasurementSystemTable {
    static NSArray *table = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        table = @[@"local", @"metric", @"USC"];
    });
    return table;
}

+ (ORKMeasurementSystem)ORKMeasurementSystemFromString:(NSString *)string {
    return [self tableMapReverseWithValue:string table:[self ORKMeasurementSystemTable]];
}

+ (NSString *)ORKEStringFromDateISO8601:(NSDate *)date {
    static NSDateFormatter *formatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZ"];
        [formatter setLocale:[NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"]];
    });
    return [formatter stringFromDate:date];
}

+ (NSDate *)ORKEDateFromStringISO8601:(NSString *)string {
    static NSDateFormatter *formatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZ"];
        [formatter setLocale:[NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"]];
    });
    return [formatter dateFromString:string];
}

@end
