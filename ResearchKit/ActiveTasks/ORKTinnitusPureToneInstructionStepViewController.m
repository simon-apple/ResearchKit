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

#import "ORKTinnitusPureToneInstructionStepViewController.h"
#import "ORKInstructionStepContainerView.h"
#import "ORKInstructionStepView.h"
#import "ORKNavigationContainerView.h"
#import "ORKNavigationContainerView_Internal.h"

#import "ORKInstructionStepViewController_Internal.h"
#import "ORKStepViewController_Internal.h"
#import "ORKSkin.h"
#import "ORKHelpers_Internal.h"
#import "ORKContext.h"
#import "ORKTaskViewController_Internal.h"

@interface ORKTinnitusPureToneInstructionStepView : UIStackView

@end

@implementation ORKTinnitusPureToneInstructionStepView {
    UILabel *_infoLabel;
    UIView *_infolabelContainer;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.axis = UILayoutConstraintAxisHorizontal;
        self.distribution = UIStackViewDistributionEqualCentering;
        self.alignment = UIStackViewAlignmentTop;
        self.layoutMargins = UIEdgeInsetsMake(0.0, ORKStepContainerLeftRightPaddingForWindow(self.window), 0.0, ORKStepContainerLeftRightPaddingForWindow(self.window));
        self.layoutMarginsRelativeArrangement = YES;
        [self setupInfoLabel];
        
    }
    return self;
}

- (void)setupInfoLabel {
    if (!_infolabelContainer) {
        _infolabelContainer =  [UIView new];
    }
    if (!_infoLabel) {
        _infoLabel = [UILabel new];
    }
    
    NSMutableAttributedString *infoString = [NSMutableAttributedString new];
    
    UIColor *infoLabelColor;
    if (@available(iOS 13.0, *)) {
        infoLabelColor = [UIColor systemGrayColor];
    } else {
        infoLabelColor = [UIColor colorWithRed:142.0/255.0 green:142.0/255.0 blue:147.0/255.0 alpha:1];
    }
    NSDictionary *infoLabelAttrs = @{ NSForegroundColorAttributeName : infoLabelColor };
    NSTextAttachment *infoAttachment = [NSTextAttachment new];    
    
    if (@available(iOS 13.0, *)) {
        UIImageConfiguration *configuration = [UIImageSymbolConfiguration configurationWithFont:[UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline] scale:UIImageSymbolScaleDefault];
        
        UIImage *infoImg = [[UIImage systemImageNamed:@"info.circle"
                                           withConfiguration:configuration] imageWithTintColor:infoLabelColor];
        infoAttachment.image = infoImg;
    }
    
    [infoString appendAttributedString:[NSAttributedString attributedStringWithAttachment:infoAttachment]];
    [infoString appendAttributedString:
     [[NSAttributedString alloc] initWithString:
      [NSString stringWithFormat:@" %@", ORKLocalizedString(@"TINNITUS_VOLUME_ADJUST_TEXT", nil)] attributes:infoLabelAttrs]];
    
    _infoLabel.attributedText = infoString;
    _infoLabel.numberOfLines = 0;
    _infoLabel.textAlignment = NSTextAlignmentLeft;
    _infoLabel.translatesAutoresizingMaskIntoConstraints = NO;
    
    _infolabelContainer.translatesAutoresizingMaskIntoConstraints = NO;
    [_infolabelContainer addSubview:_infoLabel];
    
    [[_infoLabel.topAnchor constraintEqualToAnchor:_infolabelContainer.topAnchor] setActive:YES];
    [[_infoLabel.leadingAnchor constraintEqualToAnchor:_infolabelContainer.leadingAnchor] setActive:YES];
    [[_infoLabel.trailingAnchor constraintEqualToAnchor:_infolabelContainer.trailingAnchor constant: -12.0] setActive:YES];
    
    [self addArrangedSubview:_infolabelContainer];
}

- (UIFont *)subheadlineFontBold {
    UIFontDescriptor *descriptor = [UIFontDescriptor preferredFontDescriptorWithTextStyle:UIFontTextStyleSubheadline];
    UIFontDescriptor *fontDescriptor = [descriptor fontDescriptorWithSymbolicTraits:(UIFontDescriptorTraitBold)];
    return [UIFont fontWithDescriptor:fontDescriptor size:[[fontDescriptor objectForKey: UIFontDescriptorSizeAttribute] doubleValue]];
}

@end


@interface ORKTinnitusPureToneInstructionStepViewController () {
    ORKTinnitusPureToneInstructionStepView *_instructionStepContentView;
}
@end

@implementation ORKTinnitusPureToneInstructionStepViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _instructionStepContentView = [[ORKTinnitusPureToneInstructionStepView alloc] init];
    
    self.stepView.customContentFillsAvailableSpace = NO;
    self.stepView.customContentView = _instructionStepContentView;
    [self.stepView removeCustomContentPadding];
}

@end
