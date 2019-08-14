//
//  BWInferenceEngine_Private.h
//  Celestial4
//
//  Created by Benjamin Englert on 4/4/19.
//

#import "BWInferenceEngine.h"

@interface BWInferenceEngine ()

/*!
 @method initWithCaptureDevice:scheduler:
 @abstract Creates a new inference engine, which will perform inferences using the given scheduler
 
 @param captureDevice A capture device only used to lazily provide a FigCaptureISPProcessingSessionRef
 @param scheduler An inference scheduler, for coordinating inference execution
 @param priority The priority this engine's inferences should be executed at
 @param shareIntermediateBuffer A flag to enable intermediate buffer sharing between networks running sequentially on supported hardware
 */
- (instancetype)initWithCaptureDevice:(BWFigVideoCaptureDevice *)captureDevice scheduler:(BWInferenceScheduler *)scheduler priority:(BWInferenceSchedulerPriority)priority shareIntermediateBuffer:(BOOL)shareIntermediateBuffer;

#if ! FIG_DISABLE_ALL_EXPERIMENTS

/*!
 @property preparedWorkloadDescription
 @abstract A string describing the engine's configured workload once
 
 @discussion For testing and debugging only
*/
@property (nonatomic, readonly, strong) NSString *preparedWorkloadDescription;
 
#endif // ! FIG_DISABLE_ALL_EXPERIMENTS
@end
