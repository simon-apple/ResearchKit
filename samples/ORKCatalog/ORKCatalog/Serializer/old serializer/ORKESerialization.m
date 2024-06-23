/*
 Copyright (c) 2015, Apple Inc. All rights reserved.
 Copyright (c) 2015-2016, Ricardo Sánchez-Sáez.
 Copyright (c) 2018, Brian Ganninger.
 
 Redistribution and use in source and binary forms, with or without modification,
 are permitted provided that the following conditions are met:
 
 1.  Redistributions of source code must retain the above copyright notice, this
 list of conditions and the following disclaimer.
 
 2.  Redistributions in binary form must reproduce the above copyright notice,
 this list of conditions and the following disclaimer in the documentation and/or
 other materials provided with the distribution.
 
 3.  Neither the name of the copyright holder(s) nor the names of any contributors
 may be used to endorse or promote products derived from this software without
 specific prior written permission. No license is granted to the trademarks of
 the copyright holders even if such marks are included in this software.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
 FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */


#import "ORKESerialization.h"

#import "ORKSerializationEntryProvider.h"

#import <ResearchKit/ResearchKit.h>
#import <ResearchKit/ResearchKit_Private.h>
#import <ResearchKitActiveTask/ResearchKitActiveTask.h>
#import <ResearchKitActiveTask/ResearchKitActiveTask_Private.h>

#if RK_APPLE_INTERNAL
#import <ResearchKitInternal/ResearchKitInternal.h>
#import <ResearchKitInternal/ResearchKitInternal_Private.h>
#endif

#import <MapKit/MapKit.h>
#import <Speech/Speech.h>

ORKESerializationKey const ORKESerializationKeyImageName = @"imageName";

static NSString *_ClassKey = @"_class";

static NSString *ORKEStringFromDateISO8601(NSDate *date) {
    static NSDateFormatter *formatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZ"];
        [formatter setLocale:[NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"]];
    });
    return [formatter stringFromDate:date];
}

static NSDate *ORKEDateFromStringISO8601(NSString *string) {
    static NSDateFormatter *formatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZ"];
        [formatter setLocale:[NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"]];
    });
    return [formatter dateFromString:string];
}

static NSArray *ORKNumericAnswerStyleTable(void) {
    static NSArray *table = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        table = @[@"decimal", @"integer"];
    });
    return table;
}

static NSArray *ORKImageChoiceAnswerStyleTable(void) {
    static NSArray *table = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        table = @[@"singleChoice", @"multipleChoice"];
    });
    return table;
}

static NSArray *ORKMeasurementSystemTable(void) {
    static NSArray *table = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        table = @[@"local", @"metric", @"USC"];
    });
    return table;
}

static id tableMapForward(NSInteger index, NSArray *table) {
    return table[(NSUInteger)index];
}

static NSInteger tableMapReverse(id value, NSArray *table) {
    NSUInteger idx = [table indexOfObject:value];
    if (idx == NSNotFound)
    {
        idx = 0;
    }
    return (NSInteger)idx;
}

static NSDictionary *dictionaryFromCGPoint(CGPoint p) {
    return @{ @"x": @(p.x), @"y": @(p.y) };
}

static NSDictionary *dictionaryFromNSRange(NSRange r) {
    return @{ @"location": @(r.location) , @"length": @(r.length) };
}

API_AVAILABLE(ios(13.0))
static NSDictionary *dictionaryFromSFAcousticFeature(SFAcousticFeature *acousticFeature) {
    if (acousticFeature == nil) { return @{}; }
    return @{ @"acousticFeatureValuePerFrame" : acousticFeature.acousticFeatureValuePerFrame,
              @"frameDuration" : @(acousticFeature.frameDuration)
              };
}

API_AVAILABLE(ios(13.0))
static NSDictionary *dictionaryFromSFVoiceAnalytics(SFVoiceAnalytics *voiceAnalytics) {
    if (voiceAnalytics == nil) { return @{}; }
    return @{
             @"jitter" : dictionaryFromSFAcousticFeature(voiceAnalytics.jitter),
             @"shimmer" : dictionaryFromSFAcousticFeature(voiceAnalytics.shimmer),
             @"pitch" : dictionaryFromSFAcousticFeature(voiceAnalytics.pitch),
             @"voicing" : dictionaryFromSFAcousticFeature(voiceAnalytics.voicing)
             };
}

static NSDictionary *dictionaryFromSFTranscriptionSegment(SFTranscriptionSegment *segment) {
    if (segment == nil) { return @{}; }
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    
    [dict setObject:segment.substring forKey:@"substring"];
    [dict setObject:dictionaryFromNSRange(segment.substringRange) forKey:@"substringRange"];
    [dict setObject:@(segment.timestamp) forKey:@"timestamp"];
    [dict setObject:@(segment.duration) forKey:@"duration"];
    [dict setObject:@(segment.confidence) forKey:@"confidence"];
    [dict setObject:segment.alternativeSubstrings.copy forKey:@"alternativeSubstrings"];
    
    if (@available(iOS 14.5, *)) { }
    else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        [dict setObject:dictionaryFromSFVoiceAnalytics(segment.voiceAnalytics) forKey:@"voiceAnalytics"];
#pragma clang diagnostic pop
    }
    
    return [dict copy];
}

typedef id (*mapFunction)(id);
static NSArray *mapArray(NSArray *input, mapFunction function) {
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:[input count]];
    for (id value in input) {
        [result addObject:function(value)];
    }
    return result;
}

static NSDictionary *dictionaryFromSFTranscription(SFTranscription *transcription) {
    
    if (transcription == nil) { return @{}; };
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    
    [dict setObject:transcription.formattedString forKey:@"formattedString"];
    [dict setObject:mapArray(transcription.segments, dictionaryFromSFTranscriptionSegment) forKey:@"segments"];
    
    if (@available(iOS 14.5, *)) { }
    else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        [dict setObject:@(transcription.speakingRate) forKey:@"speakingRate"];
        [dict setObject:@(transcription.averagePauseDuration) forKey:@"averagePauseDuration"];
#pragma clang diagnostic pop
    }
    
    return [dict copy];
}

#if defined(__IPHONE_14_5) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_14_5
API_AVAILABLE(ios(14.5))
static NSDictionary *dictionaryFromSFSpeechRecognitionMetadata(SFSpeechRecognitionMetadata *metadata) {
    if (metadata == nil) { return @{}; }
    return @{
        @"speakingRate": @(metadata.speakingRate),
        @"averagePauseDuration": @(metadata.averagePauseDuration),
        @"speechStartTimestamp": @(metadata.speechStartTimestamp),
        @"speechDuration": @(metadata.speechDuration),
        @"voiceAnalytics": dictionaryFromSFVoiceAnalytics(metadata.voiceAnalytics)
    };
}
#endif

static NSDictionary *dictionaryFromCGSize(CGSize s) {
    return @{ @"h": @(s.height), @"w": @(s.width) };
}

static NSDictionary *dictionaryFromCGRect(CGRect r) {
    return @{ @"origin": dictionaryFromCGPoint(r.origin), @"size": dictionaryFromCGSize(r.size) };
}

static NSDictionary *dictionaryFromUIEdgeInsets(UIEdgeInsets i) {
    return @{ @"top": @(i.top), @"left": @(i.left), @"bottom": @(i.bottom), @"right": @(i.right) };
}

static CGSize sizeFromDictionary(NSDictionary *dict) {
    return (CGSize){.width = ((NSNumber *)dict[@"w"]).doubleValue, .height = ((NSNumber *)dict[@"h"]).doubleValue };
}

static CGPoint pointFromDictionary(NSDictionary *dict) {
    return (CGPoint){.x = ((NSNumber *)dict[@"x"]).doubleValue, .y = ((NSNumber *)dict[@"y"]).doubleValue};
}

static CGRect rectFromDictionary(NSDictionary *dict) {
    return (CGRect){.origin = pointFromDictionary(dict[@"origin"]), .size = sizeFromDictionary(dict[@"size"])};
}

static UIEdgeInsets edgeInsetsFromDictionary(NSDictionary *dict) {
    return (UIEdgeInsets){.top = ((NSNumber *)dict[@"top"]).doubleValue, .left = ((NSNumber *)dict[@"left"]).doubleValue, .bottom = ((NSNumber *)dict[@"bottom"]).doubleValue, .right = ((NSNumber *)dict[@"right"]).doubleValue};
}

static NSDictionary *dictionaryFromCoordinate (CLLocationCoordinate2D coordinate) {
    return @{ @"latitude": @(coordinate.latitude), @"longitude": @(coordinate.longitude) };
}

static CLLocationCoordinate2D coordinateFromDictionary(NSDictionary *dict) {
    return (CLLocationCoordinate2D){.latitude = ((NSNumber *)dict[@"latitude"]).doubleValue, .longitude = ((NSNumber *)dict[@"longitude"]).doubleValue };
}

static ORKNumericAnswerStyle ORKNumericAnswerStyleFromString(NSString *s) {
    return tableMapReverse(s, ORKNumericAnswerStyleTable());
}

static NSString *ORKNumericAnswerStyleToString(ORKNumericAnswerStyle style) {
    return tableMapForward(style, ORKNumericAnswerStyleTable());
}

static ORKNumericAnswerStyle ORKImageChoiceAnswerStyleFromString(NSString *s) {
    return tableMapReverse(s, ORKImageChoiceAnswerStyleTable());
}

static NSString *ORKImageChoiceAnswerStyleToString(ORKNumericAnswerStyle style) {
    return tableMapForward(style, ORKImageChoiceAnswerStyleTable());
}

static ORKMeasurementSystem ORKMeasurementSystemFromString(NSString *s) {
    return tableMapReverse(s, ORKMeasurementSystemTable());
}

static NSString *ORKMeasurementSystemToString(ORKMeasurementSystem measurementSystem) {
    return tableMapForward(measurementSystem, ORKMeasurementSystemTable());
}

#if ORK_FEATURE_CLLOCATIONMANAGER_AUTHORIZATION
static NSDictionary *dictionaryFromCircularRegion(CLCircularRegion *region) {
    NSDictionary *dictionary = region ?
    @{
      @"coordinate": dictionaryFromCoordinate(region.center),
      @"radius": @(region.radius),
      @"identifier": region.identifier
      } :
    @{};
    return dictionary;
}

static NSDictionary *dictionaryFromPostalAddress(CNPostalAddress *address) {
   return @{ @"city": address.city, @"street": address.street };
}
#endif

static NSString *identifierFromClinicalType(HKClinicalType *type) {
    return type.identifier;
}

#if ORK_FEATURE_CLLOCATIONMANAGER_AUTHORIZATION
static CLCircularRegion *circularRegionFromDictionary(NSDictionary *dict) {
    CLCircularRegion *circularRegion;
    if (dict.count == 3) {
        circularRegion = [[CLCircularRegion alloc] initWithCenter:coordinateFromDictionary(dict[@"coordinate"])
                                                           radius:((NSNumber *)dict[@"radius"]).doubleValue
                                                       identifier:dict[@"identifier"]];
    }
    return circularRegion;
}
#endif

static NSArray *arrayFromRegularExpressionOptions(NSRegularExpressionOptions regularExpressionOptions) {
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

static NSRegularExpressionOptions regularExpressionOptionsFromArray(NSArray *array) {
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

static NSDictionary *dictionaryFromRegularExpression(NSRegularExpression *regularExpression) {
    NSDictionary *dictionary = regularExpression ?
    @{
      @"pattern": regularExpression.pattern ?: @"",
      @"options": arrayFromRegularExpressionOptions(regularExpression.options)
      } :
    @{};
    return dictionary;
}

static NSRegularExpression *regularExpressionsFromDictionary(NSDictionary *dict) {
    NSRegularExpression *regularExpression;
    if (dict.count == 2) {
        regularExpression = [NSRegularExpression regularExpressionWithPattern:dict[@"pattern"]
                                                                      options:regularExpressionOptionsFromArray(dict[@"options"])
                                                                        error:nil];
    }
    return regularExpression;
}

static NSDictionary *dictionaryFromPasswordRules(UITextInputPasswordRules *passwordRules) {
    NSDictionary *dictionary = passwordRules ?
    @{
      @"rules": passwordRules.passwordRulesDescriptor ?: @""
      } :
    @{};
    return dictionary;
}

static UITextInputPasswordRules *passwordRulesFromDictionary(NSDictionary *dict) {
    UITextInputPasswordRules *passwordRules;
    if (dict.count == 1) {
        passwordRules = [UITextInputPasswordRules passwordRulesWithDescriptor:dict[@"rules"]];
    }
    return passwordRules;
}

#if ORK_FEATURE_CLLOCATIONMANAGER_AUTHORIZATION
static CNPostalAddress *postalAddressFromDictionary(NSDictionary *dict) {
    CNMutablePostalAddress *postalAddress = [[CNMutablePostalAddress alloc] init];
    postalAddress.city = dict[@"city"];
    postalAddress.street = dict[@"street"];
    return [postalAddress copy];
}
#endif

static HKClinicalType *typeFromIdentifier(NSString *identifier) {
    return [HKClinicalType clinicalTypeForIdentifier:identifier];
}

static UIColor * _Nullable colorFromDictionary(NSDictionary *dict) {
    CGFloat r = [[dict objectForKey:@"r"] floatValue];
    CGFloat g = [[dict objectForKey:@"g"] floatValue];
    CGFloat b = [[dict objectForKey:@"b"] floatValue];
    CGFloat a = [[dict objectForKey:@"a"] floatValue];
    return [UIColor colorWithRed:r green:g blue:b alpha:a];
}

static NSDictionary * _Nullable dictionaryFromColor(UIColor *color) {
    CGFloat r, g, b, a;
    if ([color getRed:&r green:&g blue:&b alpha:&a]) {
        return @{@"r":@(r), @"g":@(g), @"b":@(b), @"a":@(a)};
    }
    return nil;
}

static NSMutableDictionary *ORKESerializationEncodingTable(void);
static id propFromDict(NSDictionary *dict, NSString *propName, ORKESerializationContext *context);
static NSArray *classEncodingsForClass(Class c) ;
static id objectForJsonObject(id input, Class expectedClass, ORKESerializationJSONToObjectBlock converterBlock, ORKESerializationContext *context);

__unused static NSInteger const SerializationVersion = 1; // Will be used moving forward as we get additional versions

//#define ESTRINGIFY2(x) #x
//#define ESTRINGIFY(x) ESTRINGIFY2(x)
//
//#define ENTRY(entryName, mInitBlock, mProperties) \
//    @ESTRINGIFY(entryName) : [[ORKESerializableTableEntry alloc] initWithClass: [entryName class] \
//                                                                     initBlock: mInitBlock \
//                                                                    properties: mProperties]
//
//#define PROPERTY(propertyName, mValueClass, mContainerClass, mWriteAfterInit, mObjectToJSONBlock, mJsonToObjectBlock) \
//    @ESTRINGIFY(propertyName) : ([[ORKESerializableProperty alloc] initWithPropertyName: @ESTRINGIFY(propertyName) \
//                                                                             valueClass: [mValueClass class] \
//                                                                         containerClass: [mContainerClass class] \
//                                                                         writeAfterInit: mWriteAfterInit \
//                                                                      objectToJSONBlock: mObjectToJSONBlock \
//                                                                      jsonToObjectBlock: mJsonToObjectBlock \
//                                                                      skipSerialization: NO])
//
//#define SKIP_PROPERTY(propertyName, mValueClass, mContainerClass, mWriteAfterInit, mObjectToJSONBlock, mJsonToObjectBlock) \
//@ESTRINGIFY(propertyName) : ([[ORKESerializableProperty alloc] initWithPropertyName: @ESTRINGIFY(propertyName) \
//                                                                         valueClass: [mValueClass class] \
//                                                                     containerClass: [mContainerClass class] \
//                                                                     writeAfterInit: mWriteAfterInit \
//                                                                  objectToJSONBlock: mObjectToJSONBlock \
//                                                                  jsonToObjectBlock: mJsonToObjectBlock \
//                                                                  skipSerialization: YES])
//
//#define IMAGEPROPERTY(propertyName, containerClass, writeAfterInit) @ESTRINGIFY(propertyName) : \
//                                                                        imagePropertyObject(@ESTRINGIFY(propertyName), \
//                                                                                            [containerClass class], \
//                                                                                            writeAfterInit, \
//                                                                                            NO)

//#define DYNAMICCAST(x, c) ((c *) ([x isKindOfClass:[c class]] ? x : nil))

@class ORKESerializableProperty;

//@interface ORKESerializableTableEntry : NSObject
//
//- (instancetype)init NS_UNAVAILABLE;
//
//- (instancetype)initWithClass:(Class)class
//                    initBlock:(ORKESerializationInitBlock)initBlock
//                   properties:(NSDictionary<NSString *, ORKESerializableProperty *> *)properties NS_DESIGNATED_INITIALIZER;
//
//@property (nonatomic) Class class;
//@property (nonatomic, copy) ORKESerializationInitBlock initBlock;
//@property (nonatomic, strong) NSMutableDictionary<NSString *, ORKESerializableProperty *> *properties;
//
//@end

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

//@interface ORKESerializableProperty : NSObject
//
//- (instancetype)initWithPropertyName:(NSString *)propertyName
//                          valueClass:(Class)valueClass
//                      containerClass:(Class)containerClass
//                      writeAfterInit:(BOOL)writeAfterInit
//                   objectToJSONBlock:(ORKESerializationObjectToJSONBlock)objectToJSON
//                   jsonToObjectBlock:(ORKESerializationJSONToObjectBlock)jsonToObjectBlock
//                   skipSerialization:(BOOL)skipSerialization;
//
//@property (nonatomic, copy) NSString *propertyName;
//@property (nonatomic) Class valueClass;
//@property (nonatomic) Class containerClass;
//@property (nonatomic) BOOL writeAfterInit;
//@property (nonatomic, copy) ORKESerializationObjectToJSONBlock objectToJSONBlock;
//@property (nonatomic, copy) ORKESerializationJSONToObjectBlock jsonToObjectBlock;
//@property (nonatomic) BOOL skipSerialization;
//
//@end

static ORKESerializableProperty *imagePropertyObject(NSString *propertyName,
                                                     Class containerClass,
                                                     BOOL writeAfterInit,
                                                     BOOL skipSerialization) {
    return [[ORKESerializableProperty alloc] initWithPropertyName:propertyName
                                                       valueClass:[UIImage class]
                                                   containerClass:containerClass
                                                   writeAfterInit:writeAfterInit
                                                objectToJSONBlock:^id _Nullable(id object, ORKESerializationContext *context) {
        return [context.imageProvider referenceBySavingImage:object];
    }
                                                jsonToObjectBlock:^id _Nullable(id jsonObject, ORKESerializationContext *context) {
        return [context.imageProvider imageForReference:jsonObject];
    }
                                                skipSerialization:skipSerialization];
}

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

static id propFromDict(NSDictionary *dict, NSString *propName, ORKESerializationContext *context) {
    Class class = NSClassFromString(dict[_ClassKey]);

#if RK_APPLE_INTERNAL
    if (IS_FEATURE_INTERNAL_CLASS_MAPPER_ON) {
        class = [ORKInternalClassMapper getInternalClassForPublicClass:class] ?: class;
    } else if ([ORKInternalClassMapper getUseInternalMapperUserDefaultsValue] == YES) {
        class = [ORKInternalClassMapper getInternalClassForPublicClass:class] ?: class;
    }
#endif
    NSArray *classEncodings = classEncodingsForClass(class);
    ORKESerializableProperty *propertyEntry = nil;
    for (ORKESerializableTableEntry *classEncoding in classEncodings) {
        
        NSDictionary *propertyEncoding = classEncoding.properties;
        propertyEntry = propertyEncoding[propName];
        if (propertyEntry != nil) {
            break;
        }
    }
    NSCAssert(propertyEntry != nil, @"Unexpected property %@ for class %@", propName, dict[_ClassKey]);
    
    Class containerClass = propertyEntry.containerClass;
    Class propertyClass = propertyEntry.valueClass;
    ORKESerializationJSONToObjectBlock converterBlock = propertyEntry.jsonToObjectBlock;
    
    id input = dict[propName];
    id output = nil;
    if (input != nil) {
        if ([containerClass isSubclassOfClass:[NSArray class]]) {
            NSMutableArray *outputArray = [NSMutableArray array];
            for (id value in DYNAMICCAST(input, NSArray)) {
                id convertedValue = objectForJsonObject(value, propertyClass, converterBlock, context);
                NSCAssert(convertedValue != nil, @"Could not convert to object of class %@", propertyClass);
                [outputArray addObject:convertedValue];
            }
            output = outputArray;
        } else if ([containerClass isSubclassOfClass:[NSDictionary class]]) {
            NSMutableDictionary *outputDictionary = [NSMutableDictionary dictionary];
            for (NSString *key in [DYNAMICCAST(input, NSDictionary) allKeys]) {
                id convertedValue = objectForJsonObject(DYNAMICCAST(input, NSDictionary)[key], propertyClass, converterBlock, nil);
                NSCAssert(convertedValue != nil, @"Could not convert to object of class %@", propertyClass);
                outputDictionary[key] = convertedValue;
            }
            output = outputDictionary;
        } else {
            NSCAssert(containerClass == [NSObject class], @"Unexpected container class %@", containerClass);
            
            output = objectForJsonObject(input, propertyClass, converterBlock, context);

            // Edge case for ORKAnswerFormat options. Certain formats (e.g. ORKTextChoiceAnswerFormat) contain
            // text strings (e.g. 'Yes', 'No') that need to be localized but are already of the expected type.
            //
            // Remaining localization/interpolication is done in `objectForJsonObject`.
            if ([output isKindOfClass:[NSString class]] && ![propName isEqualToString:@"identifier"]) {
                id<ORKESerializationLocalizer> localizer = context.localizer;
                id<ORKESerializationStringInterpolator> stringInterpolator = context.stringInterpolator;

                if (localizer != nil) {
                    output =  [localizer localizedStringForKey:output];
                }

                if (stringInterpolator != nil) {
                    output = [stringInterpolator interpolatedStringForString:output];
                }
            }
        }
    }
    return output;
}

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


#define NUMTOSTRINGBLOCK(table) ^id(id num, __unused ORKESerializationContext *context) { return table[((NSNumber *)num).unsignedIntegerValue]; }
#define STRINGTONUMBLOCK(table) ^id(id string, __unused ORKESerializationContext *context) { NSUInteger index = [table indexOfObject:string]; \
NSCAssert(index != NSNotFound, @"Expected valid entry from table %@", table); \
return @(index); \
}

@implementation ORKESerializer {
    NSArray<ORKSerializationEntryProvider *> *_entryProviders;
}

static NSArray *ORKChoiceAnswerStyleTable(void) {
    static NSArray *table;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        table = @[@"singleChoice", @"multipleChoice"];
    });
    
    return table;
}

static NSArray *ORKDateAnswerStyleTable(void) {
    static NSArray *table = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        table = @[@"dateTime", @"date"];
    });
    return table;
}

static NSArray *buttonIdentifierTable(void) {
    static NSArray *table = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        table = @[@"none", @"left", @"right"];
    });
    return table;
}

static NSArray *memoryGameStatusTable(void) {
    static NSArray *table = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        table = @[@"unknown", @"success", @"failure", @"timeout"];
    });
    return table;
}

static NSArray *numberFormattingStyleTable(void) {
    static NSArray *table = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        table = @[@"default", @"percent"];
    });
    return table;
}

static NSDictionary *dictionaryForORKSpeechRecognitionResult(void) {
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    
    [dict addEntriesFromDictionary:@{PROPERTY(transcription, SFTranscription, NSObject, NO,
                                                 (^id(id transcription, __unused ORKESerializationContext *context) { return dictionaryFromSFTranscription(transcription); }),
                                                 // Decode not supported: SFTranscription is immmutable
                                              (^id(id __unused transcriptionDict, __unused ORKESerializationContext *context) { return nil; }))}];
#if defined(__IPHONE_14_5) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_14_5
    if (@available(iOS 14.5, *)) {
        [dict addEntriesFromDictionary:@{PROPERTY(recognitionMetadata, SFSpeechRecognitionMetadata, NSObject, NO,
                                                  (^id(id recognitionMetadata, __unused ORKESerializationContext *context) { return dictionaryFromSFSpeechRecognitionMetadata(recognitionMetadata); }),
                                                  (^id(id __unused recognitionMetadataDict, __unused ORKESerializationContext *context) { return nil; }))}];
    }
#endif
    
    return [dict copy];
}

#define GETPROP(d,x) getter(d, @ESTRINGIFY(x))
static NSMutableDictionary<NSString *, ORKESerializableTableEntry *> *ORKESerializationEncodingTable(void) {
    static dispatch_once_t onceToken;
    static NSMutableDictionary<NSString *, ORKESerializableTableEntry *> *internalEncodingTable = nil;
    dispatch_once(&onceToken, ^{
        internalEncodingTable = [NSMutableDictionary new];
    });
    return internalEncodingTable;
}
#undef GETPROP

static NSArray<ORKESerializableTableEntry *> *classEncodingsForClass(Class class) {
    NSDictionary<NSString *, ORKESerializableTableEntry *> *encodingTable = ORKESerializationEncodingTable();
    
    NSMutableArray<ORKESerializableTableEntry *> *classEncodings = [NSMutableArray array];
    Class currentClass = class;
    while (currentClass != nil) {
        NSString *className = NSStringFromClass(currentClass);
        ORKESerializableTableEntry *classEncoding = encodingTable[className];
        if (classEncoding) {
            [classEncodings addObject:classEncoding];
        }
        currentClass = [currentClass superclass];
    }
    return [classEncodings copy];
}


- (NSArray<ORKESerializableTableEntry *> *)classEncodingsForClass:(Class)class {
    NSDictionary<NSString *, ORKESerializableTableEntry *> *encodingTable = [self _getEncodingTable];
    
    NSMutableArray<ORKESerializableTableEntry *> *classEncodings = [NSMutableArray array];
    Class currentClass = class;
    while (currentClass != nil) {
        NSString *className = NSStringFromClass(currentClass);
        ORKESerializableTableEntry *classEncoding = encodingTable[className];
        if (classEncoding) {
            [classEncodings addObject:classEncoding];
        }
        currentClass = [currentClass superclass];
    }
    return [classEncodings copy];
}

static id objectForJsonObject(id input,
                              Class expectedClass,
                              ORKESerializationJSONToObjectBlock converterBlock,
                              ORKESerializationContext *context) {
    id output = nil;
    // not sure what this converter block is for
    if (converterBlock != nil) {
        input = converterBlock(input, context);
        if (input == nil) {
            // Object converted to nothing
            return nil;
        }
    }

    id<ORKESerializationLocalizer> localizer = context.localizer;
    id<ORKESerializationStringInterpolator> stringInterpolator = context.stringInterpolator;
    
#if RK_APPLE_INTERNAL
    if (IS_FEATURE_INTERNAL_CLASS_MAPPER_ON) {
        if (expectedClass != nil) {
            expectedClass = [ORKInternalClassMapper getInternalClassForPublicClass:expectedClass] ?: expectedClass;
        }
    } else if ([ORKInternalClassMapper getUseInternalMapperUserDefaultsValue] == YES && expectedClass != nil) {
        expectedClass = [ORKInternalClassMapper getInternalClassForPublicClass:expectedClass] ?: expectedClass;
    }
#endif
    
    if (expectedClass != nil && [input isKindOfClass:expectedClass]) {
        // Input is already of the expected class, do nothing
        output = input;
    } else if ([input isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dict = (NSDictionary *)input;
        NSString *className = input[_ClassKey]; // todo: might be a spot to convert class
        
#if RK_APPLE_INTERNAL
        if (IS_FEATURE_INTERNAL_CLASS_MAPPER_ON) {
            className = [ORKInternalClassMapper getInternalClassStringForPublicClass:className] ?: className;
        } else if ([ORKInternalClassMapper getUseInternalMapperUserDefaultsValue] == YES) {
            className = [ORKInternalClassMapper getInternalClassStringForPublicClass:className] ?: className;
        }
#endif
        
        ORKESerializationPropertyInjector *propertyInjector = context.propertyInjector;
        if (propertyInjector != nil) {
            NSDictionary *dictionary = (NSDictionary *)input;
            dict = [propertyInjector injectedDictionaryWithDictionary:dictionary];
        }

        if (expectedClass != nil) {
            NSCAssert([NSClassFromString(className) isSubclassOfClass:expectedClass], @"Expected subclass of %@ but got %@", expectedClass, className);
        }
        NSArray *classEncodings = classEncodingsForClass(NSClassFromString(className));
        NSCAssert([classEncodings count] > 0, @"Expected serializable class but got %@", className);
        
        ORKESerializableTableEntry *leafClassEncoding = classEncodings.firstObject;
        ORKESerializationInitBlock initBlock = leafClassEncoding.initBlock;
        BOOL writeAllProperties = YES;
        if (initBlock != nil) {
            output = initBlock(dict,
                               ^id(NSDictionary *propDict, NSString *param) {
                                   return propFromDict(propDict, param, context); });
            writeAllProperties = NO;
        } else {
            Class class = NSClassFromString(className);
            output = [[class alloc] init];
        }
        
        for (NSString *key in [dict allKeys]) {
            if ([key isEqualToString:_ClassKey]) {
                continue;
            }
            
            BOOL haveSetProp = NO;
            for (ORKESerializableTableEntry *encoding in classEncodings) {
                NSDictionary *propertyTable = encoding.properties;
                ORKESerializableProperty *propertyEntry = propertyTable[key];
                if (propertyEntry != nil) {
                    // Only write the property if it has not already been set during init
                    if (writeAllProperties || propertyEntry.writeAfterInit) {
                        id property = propFromDict(dict, key, context);
                        if ([property isKindOfClass: [NSString class]] && ![key isEqualToString:@"identifier"]) {
                            if (localizer != nil) {
                                property = [localizer localizedStringForKey:property];
                            }

                            if (stringInterpolator != nil) {
                                property = [stringInterpolator interpolatedStringForString:property];
                            }
                        }
                        [output setValue:property forKey:key];
                    }
                    haveSetProp = YES;
                    break;
                }
            }
            NSCAssert(haveSetProp, @"Unexpected property on %@: %@", className, key);
        }
    } else {
        NSCAssert(0, @"Unexpected input of class %@ for %@", [input class], expectedClass);
    }
    return output;
}

static BOOL isValid(id object) {
    return [NSJSONSerialization isValidJSONObject:object] || [object isKindOfClass:[NSNumber class]] || [object isKindOfClass:[NSString class]] || [object isKindOfClass:[NSNull class]] || [object isKindOfClass:[ORKNoAnswer class]];
}

static id jsonObjectForObject(id object, ORKESerializationContext *context) {
    if (object == nil) {
        // Leaf: nil
        return nil;
    }
    
    id jsonOutput = nil;
    Class c = [object class];
    
    NSArray *classEncodings = classEncodingsForClass(c);
    
    if ([classEncodings count]) {
        NSMutableDictionary *encodedDict = [NSMutableDictionary dictionary];
        encodedDict[_ClassKey] = NSStringFromClass(c);
        
        NSMutableSet<NSString *> *excludedPoperties = [NSMutableSet set];
        for (ORKESerializableTableEntry *encoding in classEncodings) {
            NSDictionary<NSString *, ORKESerializableProperty *> *propertyTable = encoding.properties;
            for (NSString *propertyName in [propertyTable allKeys]) {
                ORKESerializableProperty *propertyEntry = propertyTable[propertyName];
                if (propertyEntry.skipSerialization) {
                    [excludedPoperties addObject:propertyEntry.propertyName];
                    continue;
                }
                if ([excludedPoperties containsObject:propertyEntry.propertyName]) {
                    continue;
                }
                ORKESerializationObjectToJSONBlock converter = propertyEntry.objectToJSONBlock;
                Class containerClass = propertyEntry.containerClass;
                id valueForKey = [object valueForKey:propertyName];
                if (valueForKey != nil) {
                    if ([containerClass isSubclassOfClass:[NSArray class]]) {
                        NSMutableArray *a = [NSMutableArray array];
                        for (id valueItem in valueForKey) {
                            id outputItem;
                            if (converter != nil) {
                                outputItem = converter(valueItem, context);
                                NSCAssert(isValid(valueItem), @"Expected valid JSON object");
                            } else {
                                // Recurse for each property
                                outputItem = jsonObjectForObject(valueItem, context);
                            }
                            [a addObject:outputItem];
                        }
                        valueForKey = a;
                    } else {
                        if (converter != nil) {
                            valueForKey = converter(valueForKey, context);
                            NSCAssert((valueForKey == nil) || isValid(valueForKey), @"Expected valid JSON object");
                        } else {
                            // Recurse for each property
                            valueForKey = jsonObjectForObject(valueForKey, context);
                        }
                    }
                }
                
                if (valueForKey != nil) {
                    encodedDict[propertyName] = valueForKey;
                }
            }
        }
        
        jsonOutput = encodedDict;
    } else if ([c isSubclassOfClass:[NSArray class]]) {
        NSArray *inputArray = (NSArray *)object;
        NSMutableArray *encodedArray = [NSMutableArray arrayWithCapacity:[inputArray count]];
        for (id input in inputArray) {
            // Recurse for each array element
            [encodedArray addObject:jsonObjectForObject(input, context)];
        }
        jsonOutput = encodedArray;
    } else if ([c isSubclassOfClass:[NSDictionary class]]) {
        NSDictionary *inputDict = (NSDictionary *)object;
        NSMutableDictionary *encodedDictionary = [NSMutableDictionary dictionaryWithCapacity:[inputDict count]];
        for (NSString *key in [inputDict allKeys] ) {
            // Recurse for each dictionary value
            encodedDictionary[key] = jsonObjectForObject(inputDict[key], context);
        }
        jsonOutput = encodedDictionary;
    } else if (![c isSubclassOfClass:[NSPredicate class]]) {  // Ignore NSPredicate which cannot be easily serialized for now
        NSCAssert(isValid(object), @"Expected valid JSON object");
        // Leaf: native JSON object
        jsonOutput = object;
    }
    
    return jsonOutput;
}

- (instancetype)initWithEntryProviders:(NSArray<ORKSerializationEntryProvider *> *)entryProviders {
    self = [super init];
    
    if (self) {
        _entryProviders = [entryProviders copy];
    }
    
    return self;
}

- (NSMutableDictionary<NSString *,ORKESerializableTableEntry *> *)_getEncodingTable {
    static NSMutableDictionary<NSString *, ORKESerializableTableEntry *> *encodingTable = nil;
    encodingTable = [NSMutableDictionary new];
    
    for (ORKSerializationEntryProvider *entryProvider in _entryProviders) {
        [encodingTable addEntriesFromDictionary:[entryProvider serializationEncodingTable]];
    }
    
    return encodingTable;
}

- (id)objectFromJSONData:(NSData *)data error:(NSError * __autoreleasing *)error {
    id json = [NSJSONSerialization JSONObjectWithData:data options:(NSJSONReadingOptions)0 error:error];
    id ret = nil;
    
    if (json != nil) {
        ret = objectForJsonObject(json, nil, nil, [[ORKESerializationContext alloc] initWithLocalizer:nil imageProvider:nil stringInterpolator:nil propertyInjector:nil]);
    }
    return ret;
}


+ (NSDictionary *)JSONObjectForObject:(id)object error:(__unused NSError * __autoreleasing *)error {
    return [self JSONObjectForObject:object context:[[ORKESerializationContext alloc] initWithLocalizer:nil imageProvider:nil stringInterpolator:nil propertyInjector:nil] error:error];
}

+ (NSDictionary *)JSONObjectForObject:(id)object context:(ORKESerializationContext *)context error:(__unused NSError * __autoreleasing *)error {
    id json = jsonObjectForObject(object, context);
    return json;
}

+ (id)objectFromJSONObject:(NSDictionary *)object error:(__unused NSError * __autoreleasing *)error {
    return objectForJsonObject(object, nil, nil, [[ORKESerializationContext alloc] initWithLocalizer:nil imageProvider:nil stringInterpolator:nil propertyInjector:nil]);
}

+ (id)objectFromJSONObject:(NSDictionary *)object context:(ORKESerializationContext *)context error:(__unused NSError * __autoreleasing *)error {
    return objectForJsonObject(object, nil, nil, context);
}

+ (NSData *)JSONDataForObject:(id)object error:(NSError * __autoreleasing *)error {
    id json = jsonObjectForObject(object, [[ORKESerializationContext alloc] initWithLocalizer:nil imageProvider:nil stringInterpolator:nil propertyInjector:nil]);
    return [NSJSONSerialization dataWithJSONObject:json options:NSJSONWritingSortedKeys error:error];
}

+ (id)objectFromJSONData:(NSData *)data error:(NSError * __autoreleasing *)error {
    id json = [NSJSONSerialization JSONObjectWithData:data options:(NSJSONReadingOptions)0 error:error];
    id ret = nil;
    if (json != nil) {
        ret = objectForJsonObject(json, nil, nil, [[ORKESerializationContext alloc] initWithLocalizer:nil imageProvider:nil stringInterpolator:nil propertyInjector:nil]);
    }
    return ret;
}

+ (NSArray *)serializableClasses {
    NSMutableArray *a = [NSMutableArray array];
    NSDictionary *table = ORKESerializationEncodingTable();
    for (NSString *key in [table allKeys]) {
        [a addObject:NSClassFromString(key)];
    }
    return a;
}

+ (NSArray<NSString *> *)serializedPropertiesForClass:(Class)c {
    NSArray<ORKESerializableTableEntry *> *entries = classEncodingsForClass(c);
    NSMutableArray *properties = [NSMutableArray array];
    for (ORKESerializableTableEntry *entry in entries) {
        [properties addObjectsFromArray:[entry.properties allKeys]];
    }
    return properties;
}

@end


@implementation ORKESerializer(Registration)

+ (void)registerSerializableClass:(Class)serializableClass
                        initBlock:(ORKESerializationInitBlock)initBlock {
    NSMutableDictionary *encodingTable = ORKESerializationEncodingTable();
    
    ORKESerializableTableEntry *entry = encodingTable[NSStringFromClass(serializableClass)];
    if (entry) {
        entry.class = serializableClass;
        entry.initBlock = initBlock;
    } else {
        entry = [[ORKESerializableTableEntry alloc] initWithClass:serializableClass initBlock:initBlock properties:@{}];
        encodingTable[NSStringFromClass(serializableClass)] = entry;
    }
}

+ (void)registerSerializableClassPropertyName:(NSString *)propertyName
                                     forClass:(Class)serializableClass
                                   valueClass:(Class)valueClass
                               containerClass:(Class)containerClass
                               writeAfterInit:(BOOL)writeAfterInit
                            objectToJSONBlock:(ORKESerializationObjectToJSONBlock)objectToJSON
                            jsonToObjectBlock:(ORKESerializationJSONToObjectBlock)jsonToObjectBlock
                            skipSerialization:(BOOL)skipSerialization {
    NSMutableDictionary *encodingTable = ORKESerializationEncodingTable();
    
    ORKESerializableTableEntry *entry = encodingTable[NSStringFromClass(serializableClass)];
    if (!entry) {
        entry = [[ORKESerializableTableEntry alloc] initWithClass:serializableClass initBlock:nil properties:@{}];
        encodingTable[NSStringFromClass(serializableClass)] = entry;
    }
    
    ORKESerializableProperty *property = entry.properties[propertyName];
    if (property == nil) {
        property = [[ORKESerializableProperty alloc] initWithPropertyName:propertyName
                                                               valueClass:valueClass
                                                           containerClass:containerClass
                                                           writeAfterInit:writeAfterInit
                                                        objectToJSONBlock:objectToJSON
                                                        jsonToObjectBlock:jsonToObjectBlock
                                                        skipSerialization:skipSerialization];
        entry.properties[propertyName] = property;
    } else {
        property.propertyName = propertyName;
        property.valueClass = valueClass;
        property.containerClass = containerClass;
        property.writeAfterInit = writeAfterInit;
        property.objectToJSONBlock = objectToJSON;
        property.jsonToObjectBlock = jsonToObjectBlock;
        property.skipSerialization = skipSerialization;
    }
}

@end
