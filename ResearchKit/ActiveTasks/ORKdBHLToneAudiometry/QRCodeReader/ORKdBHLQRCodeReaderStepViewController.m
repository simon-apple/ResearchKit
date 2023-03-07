/*
 Copyright (c) 2023, Apple Inc. All rights reserved.
 
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

#import "ORKdBHLQRCodeReaderStepViewController.h"
#import "ORKdBHLQRCodeReaderStep.h"
#import "ORKdBHLQRCodeReaderResult.h"

#import "ORKActiveStepView.h"
#import "ORKActiveStep_Internal.h"
#import "ORKCustomStepView_Internal.h"

#import "ORKStepHeaderView_Internal.h"
#import "ORKNavigationContainerView.h"
#import "ORKStepContainerView.h"

#import "ORKStepContainerView_Private.h"

#import "ORKActiveStepViewController_Internal.h"
#import "ORKStepViewController_Internal.h"

#import "ORKCollectionResult_Private.h"

#import "ORKHelpers_Internal.h"
#import "ORKTaskViewController_Private.h"
#import "ORKTaskViewController_Internal.h"
#import "ORKOrderedTask.h"

#import <ResearchKit/ResearchKit-Swift.h>
#import "ORKNavigationContainerView_Internal.h"

typedef void (^_QRCodeCompletionHandler)(NSString* codeString);

@interface QRViewController : UIViewController

@property (nonatomic, strong) UILabel *findACodeLabel;
@property (nonatomic, strong) UIImageView *scanCodeImageView;
@property (nonatomic, strong) UIButton *flashlightButton;
@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic, strong) UIButton *typeButton;
@property (nonatomic, strong) UIView *overlayView;

- (instancetype)initWithHandler:(_QRCodeCompletionHandler)handler;
    
- (void)startReading;
    
@end

@interface QRViewController () <AVCaptureMetadataOutputObjectsDelegate> {
    _QRCodeCompletionHandler _handler;
}
    
@property (nonatomic) BOOL isReading;
    
@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *videoPreviewPlayer;

@end

@implementation QRViewController

- (instancetype)initWithHandler:(_QRCodeCompletionHandler)handler {
    self = [super init];
    
    if (self) {
        _handler = handler;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _isReading = NO;
    _captureSession = nil;
    
    [self configureOverlay];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (_captureSession.isRunning == NO) {
        [self startReading];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.captureSession stopRunning];
}

- (void)configureOverlay {
    self.overlayView = [[UIView alloc] initWithFrame:self.view.frame];
    self.view.backgroundColor = UIColor.blackColor;
    self.overlayView.translatesAutoresizingMaskIntoConstraints = NO;

    NSMutableArray *constraints = [NSMutableArray new];
    
    // Close Button
    
    UIImageSymbolConfiguration *imageConfig = [UIImageSymbolConfiguration configurationWithPointSize:15
                                                                                              weight:UIImageSymbolWeightSemibold
                                                                                               scale:UIImageSymbolScaleMedium];
    UIImage *xMarkImage = [UIImage systemImageNamed:@"xmark"];
    UIImage *configuredImage = [[xMarkImage imageByApplyingSymbolConfiguration:imageConfig] imageWithTintColor:UIColor.whiteColor
                                                                                                 renderingMode:UIImageRenderingModeAlwaysTemplate];

    self.closeButton = [UIButton systemButtonWithImage:xMarkImage target:self action:@selector(cancel)];
    self.closeButton.tintColor = UIColor.whiteColor;
    
    _closeButton.translatesAutoresizingMaskIntoConstraints = NO;
    
    [_overlayView addSubview:_closeButton];
    
    [constraints addObject:[self.closeButton.trailingAnchor constraintEqualToAnchor:self.overlayView.trailingAnchor constant:-40]];
    [constraints addObject:[self.closeButton.topAnchor constraintEqualToAnchor:self.overlayView.topAnchor constant:40]];
    
    // "Scan Code" label
    self.findACodeLabel = [[UILabel alloc] init];
    _findACodeLabel.text = @"Find a code to scan";
    _findACodeLabel.textColor = UIColor.whiteColor;
    _findACodeLabel.textAlignment = NSTextAlignmentCenter;
    _findACodeLabel.font = [self bodyTextFont];
    _findACodeLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [_overlayView addSubview:_findACodeLabel];

    [constraints addObject:[self.findACodeLabel.centerXAnchor constraintEqualToAnchor:self.overlayView.centerXAnchor]];
    [constraints addObject:[self.findACodeLabel.topAnchor constraintEqualToAnchor:self.closeButton.bottomAnchor constant:80]];
    [constraints addObject:[self.findACodeLabel.trailingAnchor constraintLessThanOrEqualToAnchor:self.overlayView.trailingAnchor]];
    [constraints addObject:[self.findACodeLabel.leadingAnchor constraintGreaterThanOrEqualToAnchor:self.overlayView.leadingAnchor]];

    // Viewfinder image view
    UIImageSymbolConfiguration *symbolConfiguration = [UIImageSymbolConfiguration
                                                       configurationWithPointSize:_overlayView.frame.size.width - 100
                                                       weight:UIImageSymbolWeightUltraLight];
    self.scanCodeImageView = [[UIImageView alloc] initWithImage:[UIImage systemImageNamed:@"viewfinder" withConfiguration:symbolConfiguration]];

    _scanCodeImageView.translatesAutoresizingMaskIntoConstraints = NO;
    _scanCodeImageView.tintColor = UIColor.whiteColor;
    _scanCodeImageView.contentMode = UIViewContentModeScaleAspectFit;
    [_overlayView addSubview:_scanCodeImageView];

    [constraints addObject:[self.scanCodeImageView.centerXAnchor constraintEqualToAnchor:self.overlayView.centerXAnchor]];
    [constraints addObject:[self.scanCodeImageView.centerYAnchor constraintEqualToAnchor:self.overlayView.centerYAnchor]];
    [constraints addObject:[self.scanCodeImageView.leadingAnchor constraintEqualToAnchor:self.overlayView.leadingAnchor constant:50]];
    [constraints addObject:[self.scanCodeImageView.trailingAnchor constraintEqualToAnchor:self.overlayView.trailingAnchor constant:-50]];
    
//    // type participantID button
//    self.typeButton = [[UIButton alloc] init];
//    [_typeButton setTitle:@"Type participant ID" forState:UIControlStateNormal];
//    [_typeButton setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
//
//    UIFontDescriptor *buttonDescriptor = [UIFontDescriptor preferredFontDescriptorWithTextStyle:UIFontTextStyleBody];
//    UIFontDescriptor *boldDescriptor = [buttonDescriptor fontDescriptorWithSymbolicTraits:UIFontDescriptorTraitBold];
//    [_typeButton.titleLabel setFont:[UIFont fontWithDescriptor:boldDescriptor size:0.0]];
//
//    [_typeButton addTarget:self action:@selector(typeParticipantID) forControlEvents:UIControlEventTouchUpInside];
//
//    _typeButton.translatesAutoresizingMaskIntoConstraints = NO;
//    [_overlayView addSubview:_typeButton];
//    [constraints addObject:[self.typeButton.centerXAnchor constraintEqualToAnchor:self.overlayView.centerXAnchor]];
//    [constraints addObject:[self.typeButton.bottomAnchor constraintEqualToAnchor:self.overlayView.bottomAnchor constant:-55]];
//
//    // Flashlight button
//    UIImageSymbolConfiguration *lightConfiguration = [UIImageSymbolConfiguration
//                                                      configurationWithPointSize:30
//                                                      weight:UIImageSymbolWeightUltraLight];
//    UIImage *onFlashlightImage = [UIImage systemImageNamed:@"flashlight.on.fill" withConfiguration:lightConfiguration];
//    UIImage *offFlashlightImage = [UIImage systemImageNamed:@"flashlight.off.fill" withConfiguration:lightConfiguration];
//
//    self.flashlightButton = [[UIButton alloc] init];
//
//    [_flashlightButton setImage:onFlashlightImage forState:UIControlStateNormal];
//    [_flashlightButton setImage:offFlashlightImage forState:UIControlStateHighlighted];
//    [_flashlightButton setImage:offFlashlightImage forState:UIControlStateSelected];
//
//    [_flashlightButton addTarget:self action:@selector(toggleFlashLight:) forControlEvents:UIControlEventTouchUpInside];
//    _flashlightButton.translatesAutoresizingMaskIntoConstraints = NO;
//
//    [_overlayView addSubview:_flashlightButton];
//
//    [constraints addObject:[self.flashlightButton.centerXAnchor constraintEqualToAnchor:self.overlayView.centerXAnchor]];
//    [constraints addObject:[self.flashlightButton.bottomAnchor constraintEqualToAnchor:self.overlayView.bottomAnchor constant:-55]];
    
    [self.view addSubview:_overlayView];

    [constraints addObject:[self.overlayView.topAnchor constraintEqualToAnchor:self.view.topAnchor]];
    [constraints addObject:[self.overlayView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor]];
    [constraints addObject:[self.overlayView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor]];
    [constraints addObject:[self.overlayView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor]];

    [NSLayoutConstraint activateConstraints:constraints];
}

- (UIFont *)bodyTextFont {
    UIFontDescriptor *descriptor = [UIFontDescriptor preferredFontDescriptorWithTextStyle:UIFontTextStyleBody];
    return [UIFont fontWithDescriptor:descriptor size:[[descriptor objectForKey: UIFontDescriptorSizeAttribute] doubleValue]];
}

/*
- (void)skipButtonTapped:(id)sender {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:ORKLocalizedString(@"TINNITUS_PURETONE_SKIP_ALERT_TITLE", nil)
                                                                             message:ORKLocalizedString(@"TINNITUS_PURETONE_SKIP_ALERT_DETAIL", nil)
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *continueAction = [UIAlertAction actionWithTitle:ORKLocalizedString(@"TINNITUS_PURETONE_SKIP_ALERT_CANCEL", nil)
                                                             style:UIAlertActionStyleDefault handler:nil];
    [alertController addAction:continueAction];
    
    [alertController addAction:[UIAlertAction actionWithTitle:ORKLocalizedString(@"TINNITUS_PURETONE_SKIP_ALERT_SKIP", nil)
                                                        style:UIAlertActionStyleDestructive
                                                      handler:^(UIAlertAction *action) {
        self.wasSkipped = YES;
        [[self taskViewController] flipToPageWithIdentifier:ORKTinnitusMaskingSoundInstructionStepIdentifier forward:YES animated:YES];
    }]];
    
    alertController.preferredAction = continueAction;
    [self presentViewController:alertController animated:YES completion:nil];

}
*/

- (void)cancel {
    [_captureSession stopRunning];

    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)toggleFlashLight:(UIButton *)sender {
    sender.selected = !sender.selected;
    
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    if (device.hasTorch) {
        if (device.torchMode == AVCaptureTorchModeOn) {
            [device lockForConfiguration:nil];
            device.torchMode = AVCaptureTorchModeOff;
            [device unlockForConfiguration];
        } else {
            [device lockForConfiguration:nil];
            device.torchMode = AVCaptureTorchModeOn;
            [device unlockForConfiguration];
        }
    }
}
    
- (void)startReading {
    NSError *error;
    
    AVCaptureDevice *captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    AVCaptureDeviceInput *deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:captureDevice error:&error];
    
    if(!deviceInput) {
        NSLog(@"Error %@", error.localizedDescription);
    }
    
    _captureSession = [[AVCaptureSession alloc]init];
    [_captureSession addInput:deviceInput];
    
    AVCaptureMetadataOutput *capturedMetadataOutput = [[AVCaptureMetadataOutput alloc] init];
    [_captureSession addOutput:capturedMetadataOutput];
    
    dispatch_queue_t dispatchQueue;
    dispatchQueue = dispatch_queue_create("scannerQueue", NULL);
    [capturedMetadataOutput setMetadataObjectsDelegate:self queue:dispatchQueue];
    [capturedMetadataOutput setMetadataObjectTypes:[NSArray arrayWithObject:AVMetadataObjectTypeQRCode]];
    
    _videoPreviewPlayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:_captureSession];
    
    [_videoPreviewPlayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    [_videoPreviewPlayer setFrame:_overlayView.layer.bounds];
    
    [self.view.layer insertSublayer:_videoPreviewPlayer below:_overlayView.layer];
    
    [_captureSession startRunning];
    _isReading = !_isReading;
}
    
- (void)stopReading {
    [_captureSession stopRunning];
    _captureSession = nil;
    
    [_videoPreviewPlayer removeFromSuperlayer];
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    for (AVMetadataObject *metadata in metadataObjects) {
        if ([metadata.type isEqualToString:AVMetadataObjectTypeQRCode]) {
            // Handle QR code data here
            NSString *qrCodeData = [(AVMetadataMachineReadableCodeObject *)metadata stringValue];
            if (_handler) {
                _handler(qrCodeData);
            }
            [self performSelectorOnMainThread:@selector(cancel) withObject:nil waitUntilDone:NO];
        }
    }
}

@end

typedef NS_ENUM(NSUInteger, ORKdBHLQRCodeReaderStage) {
    ORKdBHLQRCodeReaderStageWillScan,
    ORKdBHLQRCodeReaderStageDidScan
};

@interface ORKdBHLQRCodeReaderStepViewController() <UITextFieldDelegate> {
    ORKActiveStepCustomView *_participantIDView;
    UILabel *_participantIDLabel;
    ORKdBHLQRCodeReaderStage _stage;
    
    NSString *_participantID;
    UIAlertAction *_continueAction;
    
    UITextField *_typedParticipantID;
    //UITextField *_validatedParticipantID;
}

@end

@implementation ORKdBHLQRCodeReaderStepViewController

- (ORKdBHLQRCodeReaderStep *)QRCodeReaderStep {
    return (ORKdBHLQRCodeReaderStep *)self.step;
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
    
    _stage = ORKdBHLQRCodeReaderStageWillScan;
    
    _participantIDView = [ORKActiveStepCustomView new];
    _participantIDView.translatesAutoresizingMaskIntoConstraints = NO;
    self.activeStepView.activeCustomView = _participantIDView;
    
    _participantIDLabel = [[UILabel alloc] init];
    
    _participantIDLabel = [[UILabel alloc] init];
    _participantIDLabel.text = @"";
    _participantIDLabel.textAlignment = NSTextAlignmentCenter;
    _participantIDLabel.font = [self bodyTextFont];
    _participantIDLabel.translatesAutoresizingMaskIntoConstraints = NO;
    
    [_participantIDView addSubview:_participantIDLabel];
    
    NSMutableArray *constraints = [NSMutableArray new];
    [constraints addObject:[_participantIDLabel.centerXAnchor constraintEqualToAnchor:_participantIDView.centerXAnchor]];
    [constraints addObject:[_participantIDLabel.leadingAnchor constraintEqualToAnchor:_participantIDView.leadingAnchor]];
    [constraints addObject:[_participantIDLabel.trailingAnchor constraintEqualToAnchor:_participantIDView.trailingAnchor]];
    [constraints addObject:[_participantIDLabel.centerYAnchor constraintEqualToAnchor:_participantIDView.centerYAnchor constant:50]];
    
    [NSLayoutConstraint activateConstraints:constraints];
    
    self.activeStepView.stepTitle = self.QRCodeReaderStep.title;
    self.activeStepView.stepText = self.QRCodeReaderStep.text;
    self.activeStepView.centeredVerticallyImage = self.QRCodeReaderStep.iconImage;
    
    [self setNavigationFooterView];
}

- (void)setNavigationFooterView {
    self.continueButtonItem.title = @"Scan";
    self.activeStepView.navigationFooterView.continueButtonItem = self.continueButtonItem;
    self.activeStepView.navigationFooterView.continueEnabled = YES;
    [self.activeStepView.navigationFooterView showActivityIndicator:NO];
    [self.activeStepView.navigationFooterView updateContinueAndSkipEnabled];
    
    [self.activeStepView.navigationFooterView.continueButton removeTarget:self.activeStepView.navigationFooterView action:nil forControlEvents:UIControlEventTouchUpInside];
    [self.activeStepView.navigationFooterView.continueButton addTarget:self action:@selector(continueButtonAction:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)setSkipButtonItem:(UIBarButtonItem *)skipButtonItem {
    [skipButtonItem setTitle:@"Type Participant ID"];
    skipButtonItem.target = self;
    skipButtonItem.action = @selector(typeParticipantID:);
    
    self.activeStepView.navigationFooterView.optional = YES;
    self.activeStepView.navigationFooterView.skipButtonItem = skipButtonItem;
    self.activeStepView.navigationFooterView.skipEnabled = YES;

    [super setSkipButtonItem:skipButtonItem];
}

/*
 let ac = UIAlertController(title: "Enter answer", message: nil, preferredStyle: .alert)
     ac.addTextField()

     let submitAction = UIAlertAction(title: "Submit", style: .default) { [unowned ac] _ in
         let answer = ac.textFields![0]
         // do something interesting with "answer" here
     }

     ac.addAction(submitAction)
 */
- (void)typeParticipantID:(id)sender {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertController *alertController = [UIAlertController
                                              alertControllerWithTitle:@"Type your Participant ID"
                                              message:@"Please type your participant ID on the textfields below. Note the values must match."
                                              preferredStyle:UIAlertControllerStyleAlert];
        [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            
            
            
        }];
        _typedParticipantID = [alertController textFields][0];
        _typedParticipantID.placeholder = @"Type your participant ID";
        _typedParticipantID.delegate = self;
        [_typedParticipantID addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
//        [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
//            NSLog(@"validation textField %@",textField.text);
//        }];
//        _validatedParticipantID = [alertController textFields][1];
//        _validatedParticipantID.placeholder = @"retype your "
        UIAlertAction *cancelAction = [UIAlertAction
                                       actionWithTitle:@"Cancel"
                                       style:UIAlertActionStyleDefault
                                       handler:^(UIAlertAction *action) {
            _continueAction = nil;
        }];
        
        ORKWeakTypeOf(self) weakSelf = self;
        _continueAction = [UIAlertAction
                           actionWithTitle:@"Continue"
                           style:UIAlertActionStyleDefault
                           handler:^(UIAlertAction *action) {
            _continueAction = nil;
            _participantIDLabel.text = [NSString stringWithFormat:@"Participant ID: %@", _typedParticipantID.text];
            _participantID = _typedParticipantID.text;
            _stage = ORKdBHLQRCodeReaderStageDidScan;
            ORKStrongTypeOf(weakSelf) strongSelf = weakSelf;
            strongSelf.continueButtonItem.title = @"Next";
            strongSelf.activeStepView.navigationFooterView.continueButtonItem = self.continueButtonItem;
            [strongSelf.activeStepView.navigationFooterView updateContinueAndSkipEnabled];
        }];
        [alertController addAction:_continueAction];
        [_continueAction setEnabled:NO];
        
        [alertController addAction:cancelAction];
        alertController.preferredAction = cancelAction;
        
        [self presentViewController:alertController animated:YES completion:nil];
    });
}

// KAGRATODO: remove this from here and include on the study editor.
// Use 1 for PRE CV and 3 for CV
#define NUMBER_OF_LETTERS 1

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    const char * _char = [string cStringUsingEncoding:NSUTF8StringEncoding];
    int isBackSpace = strcmp(_char, "\b");

    if (isBackSpace == -8) {
        return YES;
    }
    
    string = [string uppercaseString];
    BOOL firstFourAreLetters = NO;
    BOOL lastFourAreNumbers = NO;
    if (textField.text.length <= NUMBER_OF_LETTERS) { // change number to 3 to test LLLLNNNN pattern
        NSCharacterSet *validChars = [NSCharacterSet characterSetWithCharactersInString:@"ABCDEFGHIJKLMNOPQRSTUVWXYZ"];
        validChars = [validChars invertedSet];
        
        firstFourAreLetters = [string rangeOfCharacterFromSet:validChars].location == NSNotFound;
    }
    if (textField.text.length > NUMBER_OF_LETTERS) { // change number to 3 to test LLLLNNNN pattern
        NSCharacterSet *validChars = [NSCharacterSet characterSetWithCharactersInString:@"1234567890"];
        validChars = [validChars invertedSet];
        
        lastFourAreNumbers = [string rangeOfCharacterFromSet:validChars].location == NSNotFound;
    }
    
    BOOL tooBig = textField.text.length > 7;
    
    if (textField.text.length <= NUMBER_OF_LETTERS) { // change number to 3 to test LLLLNNNN pattern
        return firstFourAreLetters;
    } else {
        return lastFourAreNumbers && !tooBig;
    }
}

- (BOOL)validateString:(NSString *)string withPattern:(NSString *)pattern {
    string = [string uppercaseString];
    NSError *error              = nil;
    NSRegularExpression *regex  = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:&error];

    NSAssert(regex, @"Unable to create regular expression");

    NSRange textRange   = NSMakeRange(0, string.length);
    NSRange matchRange  = [regex rangeOfFirstMatchInString:string options:NSMatchingReportProgress range:textRange];

    BOOL didValidate    = NO;

    // Did we find a matching range
    if (matchRange.location != NSNotFound)  didValidate = YES;

    return didValidate;
}

- (void)textFieldDidChange:(UITextField *)textField {
    textField.text = [textField.text uppercaseString];
    [_continueAction setEnabled:(textField.text.length == 8)];
}

- (void)continueButtonAction:(id)sender {
    switch (_stage) {
        case ORKdBHLQRCodeReaderStageWillScan: {
            ORKWeakTypeOf(self) weakSelf = self;
            QRViewController *vc = [[QRViewController alloc] initWithHandler:^(NSString *codeString) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    _participantIDLabel.text = [NSString stringWithFormat:@"Participant ID: %@", codeString];
                    _participantID = codeString;
                    _stage = ORKdBHLQRCodeReaderStageDidScan;
                    ORKStrongTypeOf(weakSelf) strongSelf = weakSelf;
                    strongSelf.continueButtonItem.title = @"Next";
                    strongSelf.activeStepView.navigationFooterView.continueButtonItem = self.continueButtonItem;
                    [strongSelf.activeStepView.navigationFooterView updateContinueAndSkipEnabled];
                });
            }];
            
            vc.modalPresentationStyle = UIModalPresentationFullScreen;
            
            [self.taskViewController presentViewController:vc animated:YES completion:nil];
            break;
        }
        case ORKdBHLQRCodeReaderStageDidScan: {
            [self finish];
        }
        default:
            break;
    }
}

- (void)stepDidFinish {
    [super stepDidFinish];

    [self goForward];
}

- (ORKStepResult *)result {
    ORKStepResult *sResult = [super result];
    
    NSDate *now = sResult.endDate;
    
    NSMutableArray *results = [NSMutableArray arrayWithArray:sResult.results];
    
    ORKdBHLQRCodeReaderResult *qrCodeResult = [[ORKdBHLQRCodeReaderResult alloc] initWithIdentifier:self.step.identifier];
    qrCodeResult.startDate = sResult.startDate;
    qrCodeResult.endDate = now;
    qrCodeResult.participantID = _participantID ? _participantID : @"";
    
    [results addObject:qrCodeResult];
    
    sResult.results = [results copy];
    
    return sResult;
}

- (UIFont *)bodyTextFont {
    UIFontDescriptor *descriptor = [UIFontDescriptor preferredFontDescriptorWithTextStyle:UIFontTextStyleTitle3];
    UIFontDescriptor *fontDescriptor = [descriptor fontDescriptorWithSymbolicTraits:(UIFontDescriptorTraitBold)];
    return [UIFont fontWithDescriptor:fontDescriptor size:[[fontDescriptor objectForKey: UIFontDescriptorSizeAttribute] doubleValue]];
}

@end
