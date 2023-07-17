//
//  Use this file to import your target's public headers that you would like to expose to Swift.
//

#import "ResearchKit.h"
#import "ResearchKit_Private.h"
#import "ORKFormStepViewController+TestingSupport.h"
#import "ORKQuestionStepViewController+TestingSupport.h"

NS_INLINE NSException * _Nullable ExecuteWithObjCExceptionHandling(void(NS_NOESCAPE^_Nonnull tryBlock)(void)) {
    @try {
        tryBlock();
    }
    @catch (NSException *exception) {
        return exception;
    }
    return nil;
}
