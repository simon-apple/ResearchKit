/*
 Copyright (c) 2018, Apple Inc. All rights reserved.
 
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


@import AVFoundation;
@import Accelerate;

#import "ORKSpeechRecognitionStepViewController.h"

#import "ORKQuestionStep.h"
#import "ORKAnswerFormat.h"
#import "ORKTask.h"
#import "ORKActiveStepView.h"
#import "ORKActiveStepViewController_Internal.h"
#import "ORKBodyItem_Internal.h"
#import "ORKStepContainerView_Private.h"

#import "ORKSpeechRecognitionContentView.h"
#import "ORKStreamingAudioRecorder.h"
#import "ORKSpeechRecognizer.h"
#import "ORKSpeechRecognitionStep.h"
#import "ORKSpeechRecognitionError.h"

#import "ORKHelpers_Internal.h"
#import "ORKBorderedButton.h"
#import "ORKRecordButton.h"
#import "ORKSpeechRecognitionResult.h"
#import "ORKResult_Private.h"
#import "ORKCollectionResult_Private.h"
#import "ORKStepViewController_Internal.h"
#import "ORKTaskViewController_Internal.h"
#import "ORKTaskViewController.h"

#import "ORKOrderedTask.h"
#import "ORKContext.h"

@interface ORKSpeechRecognitionStepViewController () <ORKStreamingAudioResultDelegate, ORKSpeechRecognitionDelegate, UITextFieldDelegate, ORKSpeechRecognitionContentViewDelegate>

@end

@implementation ORKSpeechRecognitionStepViewController {
    ORKSpeechRecognitionContentView *_speechRecognitionContentView;
    ORKStreamingAudioRecorder *_audioRecorder;
    ORKSpeechRecognizer *_speechRecognizer;
    
    dispatch_queue_t _speechRecognitionQueue;
    ORKSpeechRecognitionResult *_localResult;
    BOOL _errorState;
    float _peakPower;
    BOOL _allowUserToRecordInsteadOnNextStep;
}

- (instancetype)initWithStep:(ORKStep *)step {
    self = [super initWithStep:step];
    if (self) {
        self.suspendIfInactive = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setAllowUserToRecordInsteadOnNextStep:NO];
    ORKSpeechRecognitionStep *step = (ORKSpeechRecognitionStep *) self.step;
    _speechRecognitionContentView = [ORKSpeechRecognitionContentView new];
    _speechRecognitionContentView.shouldHideTranscript = step.shouldHideTranscript;
    self.activeStepView.customContentFillsAvailableSpace = YES;
    self.activeStepView.activeCustomView = _speechRecognitionContentView;
    _speechRecognitionContentView.speechRecognitionImage = step.speechRecognitionImage;
    _speechRecognitionContentView.speechRecognitionText = step.speechRecognitionText;
    _speechRecognitionContentView.delegate = self;
    
    _errorState = NO;
   
    [self requestSpeechRecognizerAuthorizationIfNeeded];

    _localResult = [[ORKSpeechRecognitionResult alloc] initWithIdentifier:self.step.identifier];
    _speechRecognitionQueue = dispatch_queue_create("SpeechRecognitionQueue", DISPATCH_QUEUE_SERIAL);
}

- (void)requestSpeechRecognizerAuthorizationIfNeeded
{
    [self handleSpeechRecognizerAuthorizationStatus:[ORKSpeechRecognizer authorizationStatus]];
}

- (void)handleSpeechRecognizerAuthorizationStatus:(SFSpeechRecognizerAuthorizationStatus)status
{
    switch (status)
    {
        case SFSpeechRecognizerAuthorizationStatusAuthorized:
        {
            [_speechRecognitionContentView.recordButton setButtonState:ORKRecordButtonStateEnabled];
            break;
        }
        case SFSpeechRecognizerAuthorizationStatusRestricted:
        case SFSpeechRecognizerAuthorizationStatusDenied:
        {
            id<ORKTask> task = self.step.task;
            
            ORKSpeechInNoisePredefinedTaskContext *context = [self currentSpeechInNoisePredefinedTaskContext];
            
            if (context && task)
            {
                NSString *identifier = [context didNotAllowRequiredHealthPermissionsForTask:task];
                [[self taskViewController] flipToPageWithIdentifier:identifier forward:YES animated:NO];
            }
            else
            {
                [_speechRecognitionContentView.recordButton setButtonState:ORKRecordButtonStateDisabled];
            }
            break;
        }
        case SFSpeechRecognizerAuthorizationStatusNotDetermined:
        {
            [ORKSpeechRecognizer requestAuthorization:^(SFSpeechRecognizerAuthorizationStatus authorizationStatus)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self handleSpeechRecognizerAuthorizationStatus:authorizationStatus == SFSpeechRecognizerAuthorizationStatusAuthorized ?: SFSpeechRecognizerAuthorizationStatusDenied];
                });
            }];
            break;
        }
    }
}

- (void)initializeRecognizer {
    _speechRecognizer = [[ORKSpeechRecognizer alloc] init];
    
    if (_speechRecognizer) {
        [_speechRecognizer startRecognitionWithLocale:[NSLocale localeWithLocaleIdentifier:((ORKSpeechRecognitionStep *)self.step).speechRecognizerLocale] reportPartialResults:YES responseDelegate:self errorHandler:^(NSError *error) {
            if (error) {
                [self stopWithError:error];
            }
        }];
    }
}

- (void)start
{
    [super start];
    
    // Remove any errors on the content view.
    [_speechRecognitionContentView addRecognitionError:nil];
}

- (void)didPressRecordButton:(ORKRecordButton *)recordButton
{
    switch ([recordButton buttonType])
    {
        case ORKRecordButtonTypeRecord:
            
            [self initializeRecognizer];
            [self start];
            break;
            
        default:
            [self stopWithError:nil];
            break;
    }
}

- (void)didPressUseKeyboardButton
{
    [self setAllowUserToRecordInsteadOnNextStep:YES];
    
    [self goForward];
}

- (ORKSpeechInNoisePredefinedTaskContext * _Nullable)currentSpeechInNoisePredefinedTaskContext
{
    if (self.step.context && [self.step.context isKindOfClass:[ORKSpeechInNoisePredefinedTaskContext class]])
    {
        return (ORKSpeechInNoisePredefinedTaskContext *)self.step.context;
    }
    
    return nil;
}

- (void)setAllowUserToRecordInsteadOnNextStep:(BOOL)allowUserToRecordInsteadOnNextStep
{
    _allowUserToRecordInsteadOnNextStep = allowUserToRecordInsteadOnNextStep;
    
    ORKSpeechInNoisePredefinedTaskContext *currentContext = [self currentSpeechInNoisePredefinedTaskContext];
    if (currentContext)
    {
        currentContext.prefersKeyboard = allowUserToRecordInsteadOnNextStep;
    }
}

- (CAShapeLayer *)recordingShapeLayer
{
    CAShapeLayer *layer = [CAShapeLayer layer];
    UIBezierPath *circlePath = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0, 0, 30, 30)];
    layer.path = circlePath.CGPath;
    layer.strokeColor = UIColor.systemRedColor.CGColor;
    return layer;
}

- (UIImage *)imageFromLayer:(CALayer *)layer
{
    UIGraphicsBeginImageContextWithOptions(layer.frame.size, NO, 0);
    [layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (UIFont *)buttonTextFont
{
    CGFloat fontSize = [[UIFontDescriptor preferredFontDescriptorWithTextStyle:UIFontTextStyleCallout] pointSize];
    return [UIFont systemFontOfSize:fontSize weight:UIFontWeightSemibold];
}

- (void)recordersDidChange {
    ORKStreamingAudioRecorder *audioRecorder = nil;
    for (ORKRecorder *recorder in self.recorders) {
        if ([recorder isKindOfClass:[ORKStreamingAudioRecorder class]]) {
            audioRecorder = (ORKStreamingAudioRecorder *)recorder;
            break;
        }
    }
    _audioRecorder = audioRecorder;
}

- (ORKStepResult *)result
{
    ORKStepResult *sResult = [super result];
    
    ORKSpeechInNoisePredefinedTaskContext *currentContext = [self currentSpeechInNoisePredefinedTaskContext];
    
    if (currentContext)
    {
        if ([currentContext isPracticeTest] || currentContext.prefersKeyboard)
        {
            // If we are in the speech in noise predefined context and we are in a practice test or the user elected to use keyboard entry, do not save their result.
            return sResult;
        }
    }
    
    if (_speechRecognitionQueue) {
        dispatch_sync(_speechRecognitionQueue, ^{
            if (_localResult != nil) {
                NSMutableArray *results = [NSMutableArray arrayWithArray:sResult.results];
                [results addObject:_localResult];
                sResult.results = [results copy];
            }
        });
    }
    return sResult;
}

- (void)stopWithError:(NSError *)error
{
    if (_speechRecognizer)
    {
        [_speechRecognizer endAudio];
    }
    
    if (error)
    {
        ORK_Log_Error("Speech recognition failed with error message: \"%@\"", error.localizedDescription);
        
        if (error.code == ORKSpeechRecognitionErrorRecognitionFailed)
        {
            // Speech Recognition Failed, let the user try again.
            [_speechRecognitionContentView addRecognitionError:ORKLocalizedString(@"SPEECH_RECOGNITION_FAILED_TRY_AGAIN", nil)];
            return;
        }
        
        // Speech Recogntion Failed (Fatal)
        // In this case, the user can't try again and they will need to cancel out of the task.
        // Disable the Record button.
        [_speechRecognitionContentView addRecognitionError:error.localizedDescription];
        _speechRecognitionContentView.recordButton.userInteractionEnabled = NO;
        [_speechRecognitionContentView.recordButton setButtonState:ORKRecordButtonStateDisabled];
        _errorState = YES;
    }
    
    [self stopRecorders];
}

- (void)resume {
    // Background processing is not supported
}

- (void)goForward
{
    [self setupNextStepForAllowingUserToRecordInstead:_allowUserToRecordInsteadOnNextStep];
    [super goForward];
}

- (void)setupNextStepForAllowingUserToRecordInstead:(BOOL)allowUserToRecordInsteadOnNextStep
{
    ORKSpeechInNoisePredefinedTaskContext *currentContext = [self currentSpeechInNoisePredefinedTaskContext];
    if (currentContext)
    {
        ORKQuestionStep *nextStep = [self nextStep];
        if (nextStep)
        {
            [((ORKTextAnswerFormat *)nextStep.answerFormat) setDefaultTextAnswer: [_localResult.transcription formattedString]];
            
            if (allowUserToRecordInsteadOnNextStep)
            {
                nextStep.title = ORKLocalizedString(@"SPEECH_IN_NOISE_PREDEFINED_TYPE_TITLE", nil);
                nextStep.text = nil;
                
                ORKSpeechInNoisePredefinedTaskContext *context = [[ORKSpeechInNoisePredefinedTaskContext alloc] init];
                context.prefersKeyboard = YES;
                nextStep.context = context;
                
                ORKBodyItem *buttonItem = [[ORKBodyItem alloc] initWithCustomButtonConfigurationHandler:^(UIButton * _Nonnull button) {
                    
                    if (@available(iOS 13.0, *))
                    {
                        [button setImage:[UIImage systemImageNamed:@"smallcircle.fill.circle"] forState:UIControlStateNormal];
                        [[button imageView] setTintColor:UIColor.systemRedColor];
                    }
                    button.adjustsImageWhenHighlighted = NO;
                    NSAttributedString *attributedTitle = [[NSAttributedString alloc] initWithString:ORKLocalizedString(@"SPEECH_IN_NOISE_PREDEFINED_RECORD_INSTEAD", nil)
                                                                                          attributes:@{NSFontAttributeName:[self buttonTextFont],
                                                                                                       NSForegroundColorAttributeName:self.view.tintColor}];
                    [button setAttributedTitle:attributedTitle forState:UIControlStateNormal];
                    [button addTarget:self.taskViewController action:@selector(goBackward) forControlEvents:UIControlEventTouchUpInside];
                    [button setTitleEdgeInsets:UIEdgeInsetsMake(0, 5, 0, -5)];
                    [button setContentEdgeInsets:UIEdgeInsetsMake(0, 0, 0, -5)];
                }];
                
                nextStep.bodyItems = @[buttonItem];
            }
            else
            {
                nextStep.title = ORKLocalizedString(@"SPEECH_IN_NOISE_PREDEFINED_REVIEW_TITLE", nil);
                nextStep.text = ORKLocalizedString(@"SPEECH_IN_NOISE_PREDEFINED_REVIEW_TEXT", nil);
                nextStep.bodyItems = nil;
                
                ORKSpeechInNoisePredefinedTaskContext *context = [[ORKSpeechInNoisePredefinedTaskContext alloc] init];
                nextStep.context = context;
            }
        }
    }
}

- (nullable ORKQuestionStep *)nextStep {
    ORKOrderedTask *task = (ORKOrderedTask *)[self.taskViewController task];
    NSUInteger nextStepIndex = [task indexOfStep:[self step]] + 1;
    ORKStep *nextStep = [task steps][nextStepIndex];
    
    if ([nextStep isKindOfClass:[ORKQuestionStep class]]) {
        return (ORKQuestionStep *)nextStep;
    } else {
        return nil;
    }
}

- (void)stepDidFinish {
    _speechRecognitionContentView.finished = YES;
}

- (void)recorder:(ORKRecorder *)recorder didFailWithError:(NSError *)error {
    [super recorder:recorder didFailWithError:error];
    [self stopWithError:error];
}

// Methods running on a different thread

#pragma mark - ORKStreamingAudioResultDelegate
- (void)audioAvailable:(AVAudioPCMBuffer *)buffer {
    if (_errorState) {
        return;
    }
    [_speechRecognizer addAudio:buffer];
    
    // audio metering display
    float * const *channelData = [buffer floatChannelData];
    if (channelData[0]) {
        float avgValue = 0;
        unsigned long nFrames = [buffer frameLength];
        vDSP_maxmgv(channelData[0], 1 , &avgValue, nFrames);
        float lvlLowPassTrig = 0.3;
        _peakPower = lvlLowPassTrig * ((avgValue == 0)? -100 : 20* log10(avgValue)) + (1 - lvlLowPassTrig) * _peakPower;
        float clampedValue = MAX(_peakPower / 60.0, -1) + 1;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [_speechRecognitionContentView addSample:@(clampedValue)];
        });
    }
}

#pragma mark - ORKSpeechRecognitionDelegate

- (void)didFinishRecognitionWithError:(NSError *)error {
    if (_errorState) {
        return;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (error) {
            ORK_Log_Error("Speech framework failed with error code: %ld, and error description: %@", (long)error.code, error.localizedDescription);
            NSError *recognitionError = [NSError errorWithDomain:ORKErrorDomain
                                                            code:ORKSpeechRecognitionErrorRecognitionFailed
                                                        userInfo:@{NSLocalizedDescriptionKey:ORKLocalizedString(@"SPEECH_RECOGNITION_FAILED", nil)}];
            [self stopWithError:recognitionError];
        } else {
            [self stopWithError:nil];
            [self finish];
        }
    });
}

- (void)didHypothesizeTranscription:(SFTranscription *)transcription {
    if (_errorState) {
        return;
    }
    dispatch_sync(_speechRecognitionQueue, ^{
        _localResult.transcription = transcription;
    });
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [_speechRecognitionContentView updateRecognitionText:[transcription formattedString]];
    });
}

- (void)availabilityDidChange:(BOOL)available {
    if (!available) {
        dispatch_async(dispatch_get_main_queue(), ^{
        [self stopWithError:[NSError errorWithDomain:ORKErrorDomain
                                                code:ORKSpeechRecognitionErrorLanguageNotAvailable
                                            userInfo:@{NSLocalizedDescriptionKey:ORKLocalizedString(@"Speech recognizer not available", nil)}]];
        });
    }
}

- (void)recordersWillStart {
    ORK_Log_Debug("Recorder is starting");
}

@end

