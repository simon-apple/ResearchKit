//
//  SUICFlamesViewTypes.h
//  SiriUICore
//
//  Created by Peter Bohac on 5/28/19.
//  Copyright © 2019 Apple Inc. All rights reserved.
//

#ifndef SUICFlamesViewTypes_h
#define SUICFlamesViewTypes_h

typedef NS_ENUM(NSInteger, SUICFlamesViewMode) {
    SUICFlamesViewModeSiri = 0,
    SUICFlamesViewModeDictation,
    SUICFlamesViewModeDictationPrototype = SUICFlamesViewModeDictation,
    SUICFlamesViewModeHeySiriTraining,
    SUICFlamesViewModeAura,
    SUICFlamesViewModeNumModes,
};
typedef NS_ENUM(NSInteger, SUICFlamesViewState) {
    SUICFlamesViewStateAboutToListen,
    SUICFlamesViewStateListening,
    SUICFlamesViewStateThinking,
    SUICFlamesViewStateSuccess,
    SUICFlamesViewStateDisabled,
};
typedef NS_ENUM(NSInteger, SUICFlamesViewFidelity) {
    SUICFlamesViewFidelityLow,
    SUICFlamesViewFidelityMedium,
    SUICFlamesViewFidelityHigh,
};

#endif /* SUICFlamesViewTypes_h */
