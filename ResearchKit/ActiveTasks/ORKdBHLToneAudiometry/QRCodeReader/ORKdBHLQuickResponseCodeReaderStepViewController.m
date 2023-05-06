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

#import "ORKdBHLQuickResponseCodeReaderStepViewController.h"
#import "ORKdBHLQuickResponseCodeReaderStep.h"
#import "ORKdBHLQuickResponseCodeReaderResult.h"

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

typedef void (^_quickResponseCodeCompletionHandler)(NSString* codeString);

@interface QRViewController : UIViewController

@property (nonatomic, strong) UILabel *findACodeLabel;
@property (nonatomic, strong) UIImageView *scanCodeImageView;
@property (nonatomic, strong) UIButton *flashlightButton;
@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic, strong) UIButton *typeButton;
@property (nonatomic, strong) UIView *overlayView;
@property (nonatomic, weak) ORKTaskViewController *taskViewController;

- (instancetype)initWithNumberOfLetters:(NSUInteger)numberOfLetters
                     taskViewController:(ORKTaskViewController*)taskVC andHandler:(_quickResponseCodeCompletionHandler)handler;
    
- (void)startReading;
    
@end

@interface QRViewController () <AVCaptureMetadataOutputObjectsDelegate> {
    _quickResponseCodeCompletionHandler _handler;
    NSUInteger _numberOfLetters; // TODO: bad name, change it later
}
    
@property (nonatomic) BOOL isReading;
    
@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *videoPreviewPlayer;

@end

@implementation QRViewController

- (instancetype)initWithNumberOfLetters:(NSUInteger)numberOfLetters
                     taskViewController:(ORKTaskViewController*)taskVC andHandler:(_quickResponseCodeCompletionHandler)handler {
    self = [super init];
    
    if (self) {
        _handler = handler;
        _numberOfLetters = numberOfLetters;
        _taskViewController = taskVC;
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
        AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        switch (authStatus) {
            case AVAuthorizationStatusAuthorized:
            {
                [self startReading];
                break;
            }
            case AVAuthorizationStatusDenied:
            case AVAuthorizationStatusRestricted:
            case AVAuthorizationStatusNotDetermined:
            {
                ORKWeakTypeOf(self) weakSelf = self;
                [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                    ORKStrongTypeOf(weakSelf) strongSelf = weakSelf;
                    if(granted){
                        [strongSelf startReading];
                    } else {
                        // User has denied access to the camera
                        [strongSelf showNoCameraWarning];
                    }
                }];
            }
            default:
                break;
        }
    }
}

- (void)showNoCameraWarning {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Camera Access Required"
                                                                                     message:@"This app requires camera access to function properly. Please enable camera access in your device settings."
                                                                              preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *settingsAction = [UIAlertAction actionWithTitle:@"Settings"
                                                                  style:UIAlertActionStyleDefault
                                                                handler:^(UIAlertAction * _Nonnull action) {
            NSURL *settingsURL = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
            [[UIApplication sharedApplication] openURL:settingsURL options:@{} completionHandler:nil];
        }];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                                 style:UIAlertActionStyleCancel
                                                               handler:^(UIAlertAction * _Nonnull action) {
            [self performSelectorOnMainThread:@selector(cancel) withObject:nil waitUntilDone:NO];
        }];
        [alertController addAction:settingsAction];
        [alertController addAction:cancelAction];
        [self presentViewController:alertController animated:YES completion:nil];
    });
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

- (void)cancel {
    [_captureSession stopRunning];
    _captureSession = nil;
    
    [_videoPreviewPlayer removeFromSuperlayer];

    [self.presentingViewController dismissViewControllerAnimated:YES completion:^{
        [_taskViewController removeAndAddObservers];
    }];
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
    dispatch_async(dispatch_get_main_queue(), ^{
        [_videoPreviewPlayer setFrame:_overlayView.layer.bounds];
        [self.view.layer insertSublayer:_videoPreviewPlayer below:_overlayView.layer];
    });
    
    [_captureSession startRunning];
    _isReading = !_isReading;
}

- (BOOL)qrCodeStringIsValid:(NSString*)string {
    BOOL isValid = NO;
    NSString *regexString;
    
    if (_numberOfLetters == CHAND1_NUMBER_OF_LETTERS) {
        regexString = @"^[a-zA-Z]{2}\\d{6}$";
    } else {
        regexString = @"^[a-zA-Z]{4}\\d{4}$";
    }
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regexString options:0 error:&error];

    if (regex != nil) {
        NSTextCheckingResult *match = [regex firstMatchInString:string options:0 range:NSMakeRange(0, [string length])];
        if (match) {
            ORK_Log_Info("ParticipantID matched regex.");
            isValid = YES;
        }
    }
    return isValid;
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    for (AVMetadataObject *metadata in metadataObjects) {
        if ([metadata.type isEqualToString:AVMetadataObjectTypeQRCode]) {
            // Handle QR code data here
            NSString *quickResponseCodeData = [(AVMetadataMachineReadableCodeObject *)metadata stringValue];
            if ([self qrCodeStringIsValid:quickResponseCodeData]) {
                if (_handler) {
                    _handler(quickResponseCodeData);
                    [self performSelectorOnMainThread:@selector(cancel) withObject:nil waitUntilDone:NO];
                }
            } else {
                [self performSelectorOnMainThread:@selector(showInvalidCode) withObject:nil waitUntilDone:NO];
            }
        }
    }
}

- (void)showInvalidCode{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(restoreLabel) object:nil];
    _findACodeLabel.text = @"Invalid QRCode.";
    [self performSelector:@selector(restoreLabel) withObject:nil afterDelay:1.0];
}

- (void)restoreLabel {
    _findACodeLabel.text = @"Find a code to scan";
}

@end

typedef NS_ENUM(NSUInteger, ORKdBHLQuickResponseCodeReaderStage) {
    ORKdBHLQuickResponseCodeReaderStageWillScan,
    ORKdBHLQuickResponseCodeReaderStageDidScan
};

@interface ORKdBHLQuickResponseCodeReaderStepViewController() <UITextFieldDelegate> {
    ORKActiveStepCustomView *_participantIDView;
    UILabel *_participantIDLabel;
    ORKdBHLQuickResponseCodeReaderStage _stage;
    
    NSString *_participantID;
    UIAlertAction *_continueAction;
    
    UITextField *_typedParticipantID;
    //UITextField *_validatedParticipantID;
}

@end

@implementation ORKdBHLQuickResponseCodeReaderStepViewController

- (ORKdBHLQuickResponseCodeReaderStep *)quickResponseCodeReaderStep {
    return (ORKdBHLQuickResponseCodeReaderStep *)self.step;
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
    
    _stage = ORKdBHLQuickResponseCodeReaderStageWillScan;
    
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
    
    self.activeStepView.stepTitle = self.quickResponseCodeReaderStep.title;
    self.activeStepView.stepText = self.quickResponseCodeReaderStep.text;
    self.activeStepView.centeredVerticallyImage = self.quickResponseCodeReaderStep.iconImage;
    
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
            [[NSUserDefaults standardUserDefaults] setObject:_participantID forKey:@"kagraParticipantID"];
            _stage = ORKdBHLQuickResponseCodeReaderStageDidScan;
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

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    const char * _char = [string cStringUsingEncoding:NSUTF8StringEncoding];
    int isBackSpace = strcmp(_char, "\b");

    if (isBackSpace == -8) {
        return YES;
    }
    
    string = [string uppercaseString];
    BOOL firstAreLetters = NO;
    BOOL lastAreNumbers = NO;
    if (textField.text.length <= self.quickResponseCodeReaderStep.numberOfLetters - 1) {
        NSCharacterSet *validChars = [NSCharacterSet characterSetWithCharactersInString:@"ABCDEFGHIJKLMNOPQRSTUVWXYZ"];
        validChars = [validChars invertedSet];
        
        firstAreLetters = [string rangeOfCharacterFromSet:validChars].location == NSNotFound;
    }
    if (textField.text.length > self.quickResponseCodeReaderStep.numberOfLetters - 1) { // change number to 3 to test LLLLNNNN pattern
        NSCharacterSet *validChars = [NSCharacterSet characterSetWithCharactersInString:@"1234567890"];
        validChars = [validChars invertedSet];
        
        lastAreNumbers = [string rangeOfCharacterFromSet:validChars].location == NSNotFound;
    }
    
    BOOL tooBig = textField.text.length > 7;
    
    if (textField.text.length <= self.quickResponseCodeReaderStep.numberOfLetters - 1) { // change number to 3 to test LLLLNNNN pattern
        return firstAreLetters;
    } else {
        return lastAreNumbers && !tooBig;
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
        case ORKdBHLQuickResponseCodeReaderStageWillScan: {
            ORKWeakTypeOf(self) weakSelf = self;
            QRViewController *vc = [[QRViewController alloc]
                                    initWithNumberOfLetters:self.quickResponseCodeReaderStep.numberOfLetters
                                    taskViewController:self.taskViewController
                                    andHandler:^(NSString *codeString) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    _participantIDLabel.text = [NSString stringWithFormat:@"Participant ID: %@", codeString];
                    _participantID = codeString;
                    [[NSUserDefaults standardUserDefaults] setObject:_participantID forKey:@"kagraParticipantID"];
                    _stage = ORKdBHLQuickResponseCodeReaderStageDidScan;
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
        case ORKdBHLQuickResponseCodeReaderStageDidScan: {
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
    
    ORKdBHLQuickResponseCodeReaderResult *quickResponseCodeResult = [[ORKdBHLQuickResponseCodeReaderResult alloc] initWithIdentifier:self.step.identifier];
    quickResponseCodeResult.startDate = sResult.startDate;
    quickResponseCodeResult.endDate = now;
    quickResponseCodeResult.participantID = _participantID ? _participantID : @"";
    
    [results addObject:quickResponseCodeResult];
    
    sResult.results = [results copy];
    
    return sResult;
}

- (UIFont *)bodyTextFont {
    UIFontDescriptor *descriptor = [UIFontDescriptor preferredFontDescriptorWithTextStyle:UIFontTextStyleTitle3];
    UIFontDescriptor *fontDescriptor = [descriptor fontDescriptorWithSymbolicTraits:(UIFontDescriptorTraitBold)];
    return [UIFont fontWithDescriptor:fontDescriptor size:[[fontDescriptor objectForKey: UIFontDescriptorSizeAttribute] doubleValue]];
}

@end
