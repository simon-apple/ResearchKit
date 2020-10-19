//
//  ORKFlamesViewTypes.h
//  SiriUICore
//
//  Created by Peter Bohac on 5/28/19.
//  Copyright © 2019 Apple Inc. All rights reserved.
//

#ifndef ORKFlamesViewTypes_h
#define ORKFlamesViewTypes_h

typedef NS_ENUM(NSInteger, ORKFlamesViewMode) {
    ORKFlamesViewModeSiri = 0,
    ORKFlamesViewModeDictation,
    ORKFlamesViewModeDictationPrototype = ORKFlamesViewModeDictation,
    ORKFlamesViewModeHeySiriTraining,
    ORKFlamesViewModeAura,
    ORKFlamesViewModeNumModes,
};
typedef NS_ENUM(NSInteger, ORKFlamesViewState) {
    ORKFlamesViewStateAboutToListen,
    ORKFlamesViewStateListening,
    ORKFlamesViewStateThinking,
    ORKFlamesViewStateSuccess,
    ORKFlamesViewStateDisabled,
};
typedef NS_ENUM(NSInteger, ORKFlamesViewFidelity) {
    ORKFlamesViewFidelityLow,
    ORKFlamesViewFidelityMedium,
    ORKFlamesViewFidelityHigh,
};

#endif /* ORKFlamesViewTypes_h */
