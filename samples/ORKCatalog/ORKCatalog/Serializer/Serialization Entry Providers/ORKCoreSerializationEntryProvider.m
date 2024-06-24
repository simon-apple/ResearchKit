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
                      })),
           ENTRY(ORKStep,
                 ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
                     ORKStep *step = [[ORKStep alloc] initWithIdentifier:GETPROP(dict, identifier)];
                     return step;
                 },
                 (@{
                    PROPERTY(identifier, NSString, NSObject, NO, nil, nil),
                    PROPERTY(optional, NSNumber, NSObject, YES, nil, nil),
                    PROPERTY(title, NSString, NSObject, YES, nil, nil),
                    PROPERTY(text, NSString, NSObject, YES, nil, nil),
                    PROPERTY(detailText, NSString, NSObject, YES, nil, nil),
                    PROPERTY(headerTextAlignment, NSNumber, NSObject, YES, nil, nil),
                    PROPERTY(footnote, NSString, NSObject, YES, nil, nil),
                    PROPERTY(shouldTintImages, NSNumber, NSObject, YES, nil, nil),
                    PROPERTY(useSurveyMode, NSNumber, NSObject, YES, nil, nil),
                    PROPERTY(bodyItems, ORKBodyItem, NSArray, YES, nil, nil),
                    PROPERTY(imageContentMode, NSNumber, NSObject, YES, nil, nil),
                    IMAGEPROPERTY(iconImage, NSObject, YES),
                    IMAGEPROPERTY(auxiliaryImage, NSObject, YES),
                    IMAGEPROPERTY(image, NSObject, YES),
                    PROPERTY(bodyItemTextAlignment, NSNumber, NSObject, YES, nil, nil),
                    PROPERTY(buildInBodyItems, NSNumber, NSObject, YES, nil, nil),
                    PROPERTY(useExtendedPadding, NSNumber, NSObject, YES, nil, nil),
                    PROPERTY(earlyTerminationConfiguration, ORKEarlyTerminationConfiguration, NSObject, YES, nil, nil),
                    PROPERTY(shouldAutomaticallyAdjustImageTintColor, NSNumber, NSObject, YES, nil, nil),
                    })),
        } mutableCopy];
    
    return internalEncodingTable;
}

@end
