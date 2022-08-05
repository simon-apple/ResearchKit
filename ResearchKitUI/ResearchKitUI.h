/*
 Copyright (c) 2020, Apple Inc. All rights reserved.
 
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

#import <ResearchKitUI/AVAudioMixerNode+Fade.h>
//#import <ResearchKitUI/ORK3DModelManager_Internal.h>
//#import <ResearchKitUI/ORK3DModelStepContentView.h>
#import <ResearchKitUI/ORK3DModelStepViewController.h>
//#import <ResearchKitUI/ORKAVJournalingStepContentView.h>
#import <ResearchKitUI/ORKAVJournalingStepViewController.h>
#import <ResearchKitUI/ORKAVJournalingTaskViewController.h>
#import <ResearchKitUI/ORKAccessibility.h>
#import <ResearchKitUI/ORKAccessibilityFunctions.h>
#import <ResearchKitUI/ORKAccuracyStroopStepViewController.h>
//#import <ResearchKitUI/ORKActiveStepQuantityView.h>
//#import <ResearchKitUI/ORKActiveStepTimerView.h>
//#import <ResearchKitUI/ORKActiveStepView.h>
//#import <ResearchKitUI/ORKActiveStepViewController.h>
//#import <ResearchKitUI/ORKActiveStepViewController_Internal.h>
//#import <ResearchKitUI/ORKAmslerGridContentView.h>
#import <ResearchKitUI/ORKAmslerGridStepViewController.h>
#import <ResearchKitUI/ORKAnswerTextField.h>
//#import <ResearchKitUI/ORKAnswerTextView.h>
//#import <ResearchKitUI/ORKAudioContentView.h>
//#import <ResearchKitUI/ORKAudioDictationView.h>
#import <ResearchKitUI/ORKAudioFitnessStepViewController.h>
//#import <ResearchKitUI/ORKAudioGraphView.h>
//#import <ResearchKitUI/ORKAudioMeteringView.h>
#import <ResearchKitUI/ORKAudioStepViewController.h>
#import <ResearchKitUI/ORKBLEScanPeripheralsStepViewController.h>
//#import <ResearchKitUI/ORKBodyContainerView.h>
#import <ResearchKitUI/ORKBodyLabel.h>
#import <ResearchKitUI/ORKBorderedButton.h>
#import <ResearchKitUI/ORKCaption1Label.h>
//#import <ResearchKitUI/ORKCheckmarkView.h>
#import <ResearchKitUI/ORKChoiceViewCell.h>
//#import <ResearchKitUI/ORKChoiceViewCell_Internal.h>
//#import <ResearchKitUI/ORKCompletionCheckmarkView.h>
#import <ResearchKitUI/ORKCompletionStepViewController.h>
#import <ResearchKitUI/ORKConsentLearnMoreViewController.h>
#import <ResearchKitUI/ORKConsentReviewController.h>
#import <ResearchKitUI/ORKConsentReviewStepViewController.h>
#import <ResearchKitUI/ORKConsentSharingStepViewController.h>
#import <ResearchKitUI/ORKContinueButton.h>
#import <ResearchKitUI/ORKCountdownLabel.h>
#import <ResearchKitUI/ORKCountdownStepViewController.h>
//#import <ResearchKitUI/ORKCustomSignatureFooterView.h>
//#import <ResearchKitUI/ORKCustomStepView.h>
#import <ResearchKitUI/ORKCustomStepViewController.h>
//#import <ResearchKitUI/ORKCustomStepView_Internal.h>
#import <ResearchKitUI/ORKDateTimePicker.h>
#import <ResearchKitUI/ORKDefaultFont.h>
//#import <ResearchKitUI/ORKDirectionView.h>
#import <ResearchKitUI/ORKDontKnowButton.h>
//#import <ResearchKitUI/ORKEAGLMoviePlayerView.h>
//#import <ResearchKitUI/ORKEnvironmentSPLMeterBarView.h>
//#import <ResearchKitUI/ORKEnvironmentSPLMeterContentView.h>
#import <ResearchKitUI/ORKEnvironmentSPLMeterStepViewController.h>
//#import <ResearchKitUI/ORKFaceDetectionStepContentView.h>
#import <ResearchKitUI/ORKFaceDetectionStepViewController.h>
//#import <ResearchKitUI/ORKFitnessContentView.h>
#import <ResearchKitUI/ORKFitnessStepViewController.h>
#import <ResearchKitUI/ORKFootnoteLabel.h>
#import <ResearchKitUI/ORKFormItemCell.h>
#import <ResearchKitUI/ORKFormSectionTitleLabel.h>
#import <ResearchKitUI/ORKFormStepViewController.h>
//#import <ResearchKitUI/ORKFormStepViewController_Internal.h>
//#import <ResearchKitUI/ORKFormTextView.h>
//#import <ResearchKitUI/ORKFreehandDrawingView.h>
//#import <ResearchKitUI/ORKFrontFacingCameraStepContentView.h>
#import <ResearchKitUI/ORKFrontFacingCameraStepViewController.h>
#import <ResearchKitUI/ORKGraphChartAccessibilityElement.h>
#import <ResearchKitUI/ORKHeadlineLabel.h>
#import <ResearchKitUI/ORKHeadphoneDetectStepViewController.h>
#import <ResearchKitUI/ORKHeadphonesRequiredCompletionStepViewController.h>
#import <ResearchKitUI/ORKHeightPicker.h>
//#import <ResearchKitUI/ORKHolePegTestPlaceContentView.h>
//#import <ResearchKitUI/ORKHolePegTestPlaceHoleView.h>
//#import <ResearchKitUI/ORKHolePegTestPlacePegView.h>
#import <ResearchKitUI/ORKHolePegTestPlaceStepViewController.h>
//#import <ResearchKitUI/ORKHolePegTestRemoveContentView.h>
//#import <ResearchKitUI/ORKHolePegTestRemovePegView.h>
#import <ResearchKitUI/ORKHolePegTestRemoveStepViewController.h>
#import <ResearchKitUI/ORKIconButton.h>
//#import <ResearchKitUI/ORKImageCaptureCameraPreviewView.h>
#import <ResearchKitUI/ORKImageCaptureStepViewController.h>
//#import <ResearchKitUI/ORKImageCaptureView.h>
#import <ResearchKitUI/ORKImageChoiceLabel.h>
//#import <ResearchKitUI/ORKImageSelectionView.h>
//#import <ResearchKitUI/ORKInstructionStepContainerView.h>
//#import <ResearchKitUI/ORKInstructionStepView.h>
#import <ResearchKitUI/ORKInstructionStepViewController.h>
//#import <ResearchKitUI/ORKInstructionStepViewController_Internal.h>
#import <ResearchKitUI/ORKLabel.h>
#import <ResearchKitUI/ORKLearnMoreStepViewController.h>
//#import <ResearchKitUI/ORKLearnMoreView.h>
//#import <ResearchKitUI/ORKLocationSelectionView.h>
#import <ResearchKitUI/ORKLoginStepViewController.h>
#import <ResearchKitUI/ORKMultipleValuePicker.h>
//#import <ResearchKitUI/ORKNavigationContainerView.h>
//#import <ResearchKitUI/ORKNavigationContainerView_Internal.h>
#import <ResearchKitUI/ORKObserver.h>
//#import <ResearchKitUI/ORKPDFViewerStepView.h>
#import <ResearchKitUI/ORKPDFViewerStepViewController.h>
//#import <ResearchKitUI/ORKPDFViewerStepView_Internal.h>
//#import <ResearchKitUI/ORKPSATContentView.h>
//#import <ResearchKitUI/ORKPSATKeyboardView.h>
#import <ResearchKitUI/ORKPSATStepViewController.h>
#import <ResearchKitUI/ORKPageStepViewController.h>
//#import <ResearchKitUI/ORKPasscodeStepView.h>
#import <ResearchKitUI/ORKPasscodeStepViewController.h>
//#import <ResearchKitUI/ORKPasscodeStepViewController_Internal.h>
#import <ResearchKitUI/ORKPasscodeViewController.h>
#import <ResearchKitUI/ORKPicker.h>
#import <ResearchKitUI/ORKPlaybackButton.h>
//#import <ResearchKitUI/ORKPlaybackButton_Internal.h>
//#import <ResearchKitUI/ORKProgressView.h>
#import <ResearchKitUI/ORKRangeOfMotionStepViewController.h>
//#import <ResearchKitUI/ORKReactionTimeContentView.h>
//#import <ResearchKitUI/ORKReactionTimeStimulusView.h>
#import <ResearchKitUI/ORKReactionTimeViewController.h>
#import <ResearchKitUI/ORKRecordButton.h>
//#import <ResearchKitUI/ORKRequestPermissionsStepContainerView.h>
#import <ResearchKitUI/ORKRequestPermissionsStepViewController.h>
#import <ResearchKitUI/ORKReviewIncompleteCell.h>
#import <ResearchKitUI/ORKReviewStepViewController.h>
//#import <ResearchKitUI/ORKReviewStepViewController_Internal.h>
#import <ResearchKitUI/ORKReviewViewController.h>
//#import <ResearchKitUI/ORKRingView.h>
#import <ResearchKitUI/ORKRoundTappingButton.h>
//#import <ResearchKitUI/ORKSESSelectionView.h>
#import <ResearchKitUI/ORKScaleRangeDescriptionLabel.h>
//#import <ResearchKitUI/ORKScaleRangeImageView.h>
#import <ResearchKitUI/ORKScaleRangeLabel.h>
#import <ResearchKitUI/ORKScaleSlider.h>
//#import <ResearchKitUI/ORKScaleSliderView.h>
#import <ResearchKitUI/ORKScaleValueLabel.h>
#import <ResearchKitUI/ORKSecondaryTaskStepViewController.h>
#import <ResearchKitUI/ORKSelectionSubTitleLabel.h>
#import <ResearchKitUI/ORKSelectionTitleLabel.h>
//#import <ResearchKitUI/ORKSeparatorView.h>
#import <ResearchKitUI/ORKShoulderRangeOfMotionStepViewController.h>
#import <ResearchKitUI/ORKSignatureStepViewController.h>
//#import <ResearchKitUI/ORKSignatureView.h>
//#import <ResearchKitUI/ORKSpatialSpanMemoryContentView.h>
#import <ResearchKitUI/ORKSpatialSpanMemoryStepViewController.h>
//#import <ResearchKitUI/ORKSpatialSpanTargetView.h>
//#import <ResearchKitUI/ORKSpeechInNoiseContentView.h>
#import <ResearchKitUI/ORKSpeechInNoiseStepViewController.h>
//#import <ResearchKitUI/ORKSpeechRecognitionContentView.h>
#import <ResearchKitUI/ORKSpeechRecognitionStepViewController.h>
//#import <ResearchKitUI/ORKStepContainerView.h>
//#import <ResearchKitUI/ORKStepContentView.h>
//#import <ResearchKitUI/ORKStepHeaderView.h>
//#import <ResearchKitUI/ORKStepHeaderView_Internal.h>
//#import <ResearchKitUI/ORKStepView.h>
#import <ResearchKitUI/ORKStepViewController.h>
//#import <ResearchKitUI/ORKStepViewController_Internal.h>
//#import <ResearchKitUI/ORKStroopContentView.h>
#import <ResearchKitUI/ORKStroopStepViewController.h>
#import <ResearchKitUI/ORKSubheadlineLabel.h>
#import <ResearchKitUI/ORKSurveyAnswerCell.h>
#import <ResearchKitUI/ORKSurveyAnswerCellForImageSelection.h>
#import <ResearchKitUI/ORKSurveyAnswerCellForLocation.h>
#import <ResearchKitUI/ORKSurveyAnswerCellForNumber.h>
#import <ResearchKitUI/ORKSurveyAnswerCellForPicker.h>
#import <ResearchKitUI/ORKSurveyAnswerCellForSES.h>
#import <ResearchKitUI/ORKSurveyAnswerCellForScale.h>
#import <ResearchKitUI/ORKSurveyAnswerCellForText.h>
//#import <ResearchKitUI/ORKSurveyCardHeaderView.h>
//#import <ResearchKitUI/ORKTableContainerView.h>
#import <ResearchKitUI/ORKTableStepViewController.h>
//#import <ResearchKitUI/ORKTableStepViewController_Internal.h>
#import <ResearchKitUI/ORKTableViewCell.h>
#import <ResearchKitUI/ORKTagLabel.h>
#import <ResearchKitUI/ORKTapCountLabel.h>
//#import <ResearchKitUI/ORKTappingContentView.h>
#import <ResearchKitUI/ORKTappingIntervalStepViewController.h>
#import <ResearchKitUI/ORKTaskReviewViewController.h>
#import <ResearchKitUI/ORKTaskViewController.h>
//#import <ResearchKitUI/ORKTaskViewController_Internal.h>
#import <ResearchKitUI/ORKTextButton.h>
//#import <ResearchKitUI/ORKTextButton_Internal.h>
#import <ResearchKitUI/ORKTextChoiceCellGroup.h>
//#import <ResearchKitUI/ORKTextFieldView.h>
#import <ResearchKitUI/ORKTimeIntervalPicker.h>
//#import <ResearchKitUI/ORKTimedWalkContentView.h>
#import <ResearchKitUI/ORKTimedWalkStepViewController.h>
//#import <ResearchKitUI/ORKTinnitusAssessmentContentView.h>
//#import <ResearchKitUI/ORKTinnitusButtonView.h>
#import <ResearchKitUI/ORKTinnitusMaskingSoundStepViewController.h>
#import <ResearchKitUI/ORKTinnitusOverallAssessmentStepViewController.h>
//#import <ResearchKitUI/ORKTinnitusPureToneContentView.h>
#import <ResearchKitUI/ORKTinnitusPureToneStepViewController.h>
//#import <ResearchKitUI/ORKTinnitusTypeContentView.h>
#import <ResearchKitUI/ORKTinnitusTypeStepViewController.h>
//#import <ResearchKitUI/ORKTintedImageView.h>
//#import <ResearchKitUI/ORKTintedImageView_Internal.h>
#import <ResearchKitUI/ORKTitleLabel.h>
//#import <ResearchKitUI/ORKToneAudiometryContentView.h>
#import <ResearchKitUI/ORKToneAudiometryStepViewController.h>
#import <ResearchKitUI/ORKTouchAnywhereStepViewController.h>
#import <ResearchKitUI/ORKTowerOfHanoiStepViewController.h>
//#import <ResearchKitUI/ORKTowerOfHanoiTowerView.h>
//#import <ResearchKitUI/ORKTrailmakingContentView.h>
#import <ResearchKitUI/ORKTrailmakingStepViewController.h>
#import <ResearchKitUI/ORKTypingStepViewController.h>
#import <ResearchKitUI/ORKUSDZModelManager.h>
#import <ResearchKitUI/ORKUSDZModelManagerResult.h>
#import <ResearchKitUI/ORKUSDZModelManagerScene.h>
#import <ResearchKitUI/ORKUnitLabel.h>
#import <ResearchKitUI/ORKValuePicker.h>
//#import <ResearchKitUI/ORKVerificationStepView.h>
#import <ResearchKitUI/ORKVerificationStepViewController.h>
//#import <ResearchKitUI/ORKVerticalContainerView.h>
//#import <ResearchKitUI/ORKVerticalContainerView_Internal.h>
//#import <ResearchKitUI/ORKVideoCaptureCameraPreviewView.h>
#import <ResearchKitUI/ORKVideoCaptureStepViewController.h>
//#import <ResearchKitUI/ORKVideoCaptureView.h>
#import <ResearchKitUI/ORKVideoInstructionStepViewController.h>
//#import <ResearchKitUI/ORKVolumeCalibrationContentView.h>
#import <ResearchKitUI/ORKVolumeCalibrationStepViewController.h>
//#import <ResearchKitUI/ORKWaitStepView.h>
#import <ResearchKitUI/ORKWaitStepViewController.h>
#import <ResearchKitUI/ORKWalkingTaskStepViewController.h>
#import <ResearchKitUI/ORKWebViewStepViewController.h>
#import <ResearchKitUI/ORKWeightPicker.h>
#import <ResearchKitUI/ORKdBHLToneAudiometryAudioGenerator.h>
//#import <ResearchKitUI/ORKdBHLToneAudiometryContentView.h>
#import <ResearchKitUI/ORKdBHLToneAudiometryOnboardingStepViewController.h>
#import <ResearchKitUI/ORKdBHLToneAudiometryStepViewController.h>
#import <ResearchKitUI/UIBarButtonItem+ORKBarButtonItem.h>
#import <ResearchKitUI/UIColor+Custom.h>
#import <ResearchKitUI/UIColor+String.h>
#import <ResearchKitUI/UIImage+ResearchKit.h>
#import <ResearchKitUI/UIResponder+ResearchKit.h>
#import <ResearchKitUI/UIView+ORKAccessibility.h>
