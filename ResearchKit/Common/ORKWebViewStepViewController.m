/*
 Copyright (c) 2017, CareEvolution, Inc.
 
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

#import "ORKWebViewStepViewController.h"
#import "ORKStepViewController_Internal.h"
#import "ORKWebViewStep.h"

#import "ORKResult_Private.h"
#import "ORKCollectionResult_Private.h"
#import "ORKWebViewStepResult.h"
#import "ORKNavigationContainerView_Internal.h"
#import "ORKSkin.h"
#import "ORKHelpers_Internal.h"
#import "ORKSignatureResult_Private.h"

static const CGFloat ORKSignatureTopPadding = 37.0;
static const CGFloat ORKSignatureToClearPadding = 15.0;

@implementation ORKWebViewStepViewController {
    UIScrollView *_scrollView;
    WKWebView *_webView;
    NSString *_result;
    ORKNavigationContainerView *_navigationFooterView;
    NSMutableArray<NSLayoutConstraint *> *_constraints;
    
    ORKSignatureView *_signatureView;
    UIButton *_clearButton;
    
    CGFloat _leftRightPadding;
}

- (ORKWebViewStep *)webViewStep {
    return (ORKWebViewStep *)self.step;
}

- (void)stepDidChange {
    
    _result = nil;
    [_webView removeFromSuperview];
    _webView = nil;
    
    [_scrollView removeFromSuperview];
    _scrollView = nil;
    
    if (self.step && [self isViewLoaded]) {
        
        _scrollView = [[UIScrollView alloc] init];
        [_scrollView setDelegate:self];
        [self.view addSubview:_scrollView];
        
        if ([self webViewStep].showSignatureAfterContent) {
            _signatureView = [[ORKSignatureView alloc] initWithoutDefaultWidth];
            _signatureView.delegate = self;
            [_scrollView addSubview:_signatureView];
            
            _clearButton = [[ORKTextButton alloc] init];
            [_clearButton.titleLabel setFont:[UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline]];
            [_clearButton setTitle:ORKLocalizedString(@"BUTTON_CLEAR_SIGNATURE", nil) forState:UIControlStateNormal];
            [_clearButton addTarget:self action:@selector(clearSignature) forControlEvents:UIControlEventTouchUpInside];
            [_scrollView addSubview:_clearButton];
        }
        
        WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
        config.allowsInlineMediaPlayback = true;
        if ([config respondsToSelector:@selector(mediaTypesRequiringUserActionForPlayback)]) {
            config.mediaTypesRequiringUserActionForPlayback = WKAudiovisualMediaTypeNone;
        }
        
        WKUserContentController *controller = [[WKUserContentController alloc] init];
        [controller addScriptMessageHandler:self name:@"ResearchKit"];
        config.userContentController = controller;
        
        _leftRightPadding = self.step.useExtendedPadding ? ORKStepContainerExtendedLeftRightPaddingForWindow(self.view.window) : ORKStepContainerLeftRightPaddingForWindow(self.view.window);
        
        UIColor *backgroundColor;
        UIColor *textColor;
        if (@available(iOS 13.0, *)) {
            backgroundColor = [UIColor systemBackgroundColor];
            textColor = [UIColor labelColor];
        } else {
            backgroundColor = [UIColor whiteColor];
            textColor = [UIColor blackColor];
        }
        
        NSString *backgroundColorString = [self hexStringForColor:backgroundColor];
        NSString *textColorString = [self hexStringForColor:textColor];
        
        NSString *css = [NSString stringWithFormat:@"body { margin: 0px; font-size: 17px; font-family: \"-apple-system\"; padding-left: %fpx; padding-right: %fpx; background-color: %@; color: %@; }",
                         _leftRightPadding,
                         _leftRightPadding,
                         backgroundColorString,
                         textColorString];
        
        if ([self webViewStep].customCSS != nil) {
            css = [self webViewStep].customCSS;
        }
        
        NSString *js = @"var style = document.createElement('style'); style.innerHTML = '%@'; document.head.appendChild(style);";
        NSString *formattedString = [NSString stringWithFormat:js, css];
        WKUserScript *userScript = [[WKUserScript alloc] initWithSource:formattedString injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:true];
        [controller addUserScript:userScript];
        
        _webView = [[WKWebView alloc] initWithFrame:self.view.bounds configuration:config];
        _webView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        _webView.navigationDelegate = self;
        _webView.scrollView.scrollEnabled = NO;
        _webView.scrollView.delegate = self;
        
        [_scrollView addSubview:_webView];
        [self setupNavigationFooterView];
        [self setupConstraints];
        [_webView loadHTMLString:[self webViewStep].html baseURL:nil];
    }
}

- (void)setupNavigationFooterView {
    if (!_navigationFooterView) {
        _navigationFooterView = [ORKNavigationContainerView new];
        [_navigationFooterView removeStyling];
    }
    
    _navigationFooterView.continueButtonItem = self.continueButtonItem;
    _navigationFooterView.continueEnabled = YES;
    [_navigationFooterView updateContinueAndSkipEnabled];
    [_navigationFooterView setUseExtendedPadding:[self.step useExtendedPadding]];
    
    if ([self webViewStep].showSignatureAfterContent) {
        _navigationFooterView.continueEnabled = NO;
    }
    
    if ([self webViewStep].showSignatureAfterContent) {
        [_scrollView addSubview:_navigationFooterView];
    } else {
        [self.view addSubview:_navigationFooterView];
    }
}

- (void)setupConstraints {
    
    if (_constraints) {
        [NSLayoutConstraint deactivateConstraints:_constraints];
    }

    UIView *viewForiPad = [self viewForiPadLayoutConstraints];

    _constraints = nil;
    _webView.translatesAutoresizingMaskIntoConstraints = NO;
    _navigationFooterView.translatesAutoresizingMaskIntoConstraints = NO;
    _scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    _signatureView.translatesAutoresizingMaskIntoConstraints = NO;
    _clearButton.translatesAutoresizingMaskIntoConstraints = NO;
    
    _constraints = [[NSMutableArray alloc] initWithArray:@[
        [NSLayoutConstraint constraintWithItem:_scrollView
                                     attribute:NSLayoutAttributeTop
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:viewForiPad ? : self.view.safeAreaLayoutGuide
                                     attribute:NSLayoutAttributeTop
                                    multiplier:1.0
                                      constant:0.0],
        [NSLayoutConstraint constraintWithItem:_scrollView
                                     attribute:NSLayoutAttributeLeading
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:viewForiPad ? : self.view
                                     attribute:NSLayoutAttributeLeading
                                    multiplier:1.0
                                      constant:0.0],
        [NSLayoutConstraint constraintWithItem:_scrollView
                                     attribute:NSLayoutAttributeTrailing
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:viewForiPad ? : self.view
                                     attribute:NSLayoutAttributeTrailing
                                    multiplier:1.0
                                      constant:0.0],
        [NSLayoutConstraint constraintWithItem:_scrollView
                                     attribute:NSLayoutAttributeBottom
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:viewForiPad ? : self.view
                                     attribute:NSLayoutAttributeBottom
                                    multiplier:1.0
                                      constant:0.0],
        
        [NSLayoutConstraint constraintWithItem:_webView
                                     attribute:NSLayoutAttributeTop
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:_scrollView
                                     attribute:NSLayoutAttributeTop
                                    multiplier:1.0
                                      constant:0.0],
        [NSLayoutConstraint constraintWithItem:_webView
                                     attribute:NSLayoutAttributeLeft
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:self.view
                                     attribute:NSLayoutAttributeLeft
                                    multiplier:1.0
                                      constant:0.0],
        [NSLayoutConstraint constraintWithItem:_webView
                                     attribute:NSLayoutAttributeRight
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:self.view
                                     attribute:NSLayoutAttributeRight
                                    multiplier:1.0
                                      constant:0.0],
        [NSLayoutConstraint constraintWithItem:_navigationFooterView
                                     attribute:NSLayoutAttributeLeft
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:viewForiPad ? : self.view
                                     attribute:NSLayoutAttributeLeft
                                    multiplier:1.0
                                      constant:0],
        [NSLayoutConstraint constraintWithItem:_navigationFooterView
                                     attribute:NSLayoutAttributeRight
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:viewForiPad ? : self.view
                                     attribute:NSLayoutAttributeRight
                                    multiplier:1.0
                                      constant:0]
    ]];
    
    if ([self webViewStep].showSignatureAfterContent) {
        [_constraints addObjectsFromArray:@[
            [NSLayoutConstraint constraintWithItem:_signatureView
                                         attribute:NSLayoutAttributeTop
                                         relatedBy:NSLayoutRelationEqual
                                            toItem:_webView
                                         attribute:NSLayoutAttributeBottom
                                        multiplier:1.0
                                          constant:ORKSignatureTopPadding],
            [NSLayoutConstraint constraintWithItem:_signatureView
                                         attribute:NSLayoutAttributeLeading
                                         relatedBy:NSLayoutRelationEqual
                                            toItem:self.view
                                         attribute:NSLayoutAttributeLeading
                                        multiplier:1.0
                                          constant:_leftRightPadding],
            [NSLayoutConstraint constraintWithItem:_signatureView
                                         attribute:NSLayoutAttributeTrailing
                                         relatedBy:NSLayoutRelationEqual
                                            toItem:self.view
                                         attribute:NSLayoutAttributeTrailing
                                        multiplier:1.0
                                          constant:-_leftRightPadding],
            [NSLayoutConstraint constraintWithItem:_clearButton
                                         attribute:NSLayoutAttributeTop
                                         relatedBy:NSLayoutRelationEqual
                                            toItem:_signatureView
                                         attribute:NSLayoutAttributeBottom
                                        multiplier:1.0
                                          constant:ORKSignatureToClearPadding],
            [NSLayoutConstraint constraintWithItem:_clearButton
                                         attribute:NSLayoutAttributeLeading
                                         relatedBy:NSLayoutRelationEqual
                                            toItem:self.view
                                         attribute:NSLayoutAttributeLeading
                                        multiplier:1.0
                                          constant:_leftRightPadding],
            [NSLayoutConstraint constraintWithItem:_clearButton
                                         attribute:NSLayoutAttributeTrailing
                                         relatedBy:NSLayoutRelationEqual
                                            toItem:self.view
                                         attribute:NSLayoutAttributeTrailing
                                        multiplier:1.0
                                          constant:-_leftRightPadding],
            [NSLayoutConstraint constraintWithItem:_navigationFooterView
                                         attribute:NSLayoutAttributeTop
                                         relatedBy:NSLayoutRelationEqual
                                            toItem:_clearButton
                                         attribute:NSLayoutAttributeBottom
                                        multiplier:1.0
                                          constant:ORKSignatureTopPadding],
            [NSLayoutConstraint constraintWithItem:_navigationFooterView
                                         attribute:NSLayoutAttributeBottom
                                         relatedBy:NSLayoutRelationEqual
                                            toItem:_scrollView
                                         attribute:NSLayoutAttributeBottom
                                        multiplier:1.0
                                          constant:0.0],
        ]];
    } else {
        [_constraints addObjectsFromArray:@[
            [NSLayoutConstraint constraintWithItem:_webView
                                         attribute:NSLayoutAttributeBottom
                                         relatedBy:NSLayoutRelationLessThanOrEqual
                                            toItem:_scrollView
                                         attribute:NSLayoutAttributeBottom
                                        multiplier:1.0
                                          constant:0.0],
            [NSLayoutConstraint constraintWithItem:_navigationFooterView
                                         attribute:NSLayoutAttributeBottom
                                         relatedBy:NSLayoutRelationEqual
                                            toItem:viewForiPad ? : self.view
                                         attribute:NSLayoutAttributeBottom
                                        multiplier:1.0
                                          constant:0.0],
        ]];
    }
    
    [NSLayoutConstraint activateConstraints:_constraints];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self stepDidChange];
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    _webView.scrollView.contentOffset = CGPointZero;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    if (![self webViewStep].showSignatureAfterContent) {
        [_scrollView setContentInset:UIEdgeInsetsMake(0, 0, _navigationFooterView.frame.size.height, 0)];
    } else {
        [_scrollView setContentInset:UIEdgeInsetsZero];
    }
}

- (void)setContinueButtonItem:(UIBarButtonItem *)continueButtonItem {
    [super setContinueButtonItem:continueButtonItem];
    _navigationFooterView.continueButtonItem = continueButtonItem;
}

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message
{
    if ([message.body isKindOfClass:[NSString class]]){
        _result = (NSString *)message.body;
        [self goForward];
    }
}

- (ORKStepResult *)result {
    ORKStepResult *parentResult = [super result];
    
    if (parentResult) {
        ORKWebViewStepResult *childResult = [[ORKWebViewStepResult alloc] initWithIdentifier:self.step.identifier];
        childResult.result = _result;
        childResult.endDate = parentResult.endDate;
        childResult.userInfo = @{@"html": [self webViewStep].html};
        parentResult.results = [parentResult.results arrayByAddingObject:childResult] ? : @[childResult];
        
        if ([self webViewStep].showSignatureAfterContent && _signatureView.signatureExists) {
            ORKSignatureResult *signatureResult = [[ORKSignatureResult alloc] initWithSignatureImage:_signatureView.signatureImage signaturePath:_signatureView.signaturePath];
            parentResult.results = [parentResult.results arrayByAddingObject:signatureResult] ? : @[signatureResult];
        }
    }
    return parentResult;
}

- (void)displaySpinnerInContinueButton:(BOOL)enabled {
    [_navigationFooterView setSpinnerEnabled:enabled];
}

// MARK: WKWebViewDelegate

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(null_unspecified WKNavigation *)navigation {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = true;
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation {
    [webView evaluateJavaScript:@"document.readyState" completionHandler:^(id complete, NSError *readyError) {
        if (complete != nil) {
            [webView evaluateJavaScript:@"document.body.scrollHeight" completionHandler:^(id result, NSError *error) {
                if (result != nil) {
                    NSString *resultString = [NSString stringWithFormat:@"%@", result];
                    CGFloat height = [resultString floatValue];
                    [_webView.heightAnchor constraintEqualToConstant:height].active = YES;
                }
            }];
        }
    }];
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = false;
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    if (navigationAction.navigationType == WKNavigationTypeLinkActivated) {
        if (_webViewDelegate != nil && [_webViewDelegate respondsToSelector:@selector(handleLinkNavigationWithURL:)]) {
            decisionHandler([_webViewDelegate handleLinkNavigationWithURL:[navigationAction.request mainDocumentURL]]);
            return;
        }
    }
    
    decisionHandler(WKNavigationActionPolicyAllow);
}

// MARK: UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [_signatureView setEnabled:scrollView.isDecelerating];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [_signatureView setEnabled:YES];
}

// MARK: Signature

- (void)clearSignature {
    [_signatureView clear];
    _navigationFooterView.continueEnabled = NO;
}


- (void)signatureViewDidEditImage:(nonnull ORKSignatureView *)signatureView {
    _navigationFooterView.continueEnabled = YES;
}

// MARK: Color

- (NSString *)hexStringForColor:(UIColor *)color {
    const CGFloat *components = CGColorGetComponents(color.CGColor);
    size_t count = CGColorGetNumberOfComponents(color.CGColor);
    
    CGFloat r = components[0];
    
    if (count == 2) {
        return [NSString stringWithFormat:@"#%02lX%02lX%02lX", lroundf(r * 255), lroundf(r * 255), lroundf(r * 255)];
    }
    
    CGFloat g = components[1];
    CGFloat b = components[2];
    
    return [NSString stringWithFormat:@"#%02lX%02lX%02lX", lroundf(r * 255), lroundf(g * 255), lroundf(b * 255)];
}

@end
