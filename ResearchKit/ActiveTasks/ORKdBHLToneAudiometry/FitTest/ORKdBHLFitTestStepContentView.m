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

#import "ORKdBHLFitTestStepContentView.h"

static NSString * const fitTestLeft = @"FitTest-Left";
static NSString * const fitTestRight = @"FitTest-Right";

static NSString * const appearanceModeLight = @"-light";
static NSString * const appearanceModeDark = @"-dark";

#define LEFT_RIGHT_IM_SEPARATION    40.0

#define BUD_LABEL_SIZE                18.0
#define BUD_LABEL_IMAGE_SEPARATION    14.0
#define LABEL_IMAGE_V_SEPARATION    20.0

#define RESULT_LABEL_WIDTH            113.0
#define RESULT_LABEL_SEPARATION        16.0

#define HEADER_CONTENT_SEPARATION    100.0

@interface ORKdBHLFitTestStepContentView () {
    UIImageView *_leftImView;
    UIView *_spacerView;
    UIImageView *_rightImView;

    UIView *_leftBudLabel;
    UILabel *_leftBudLabelText;
    UIView *_rightBudLabel;
    UILabel *_rightBudLabelText;

    UILabel *_leftBudResultLabel;
    UILabel *_rightBudResultLabel;
    
    UILabel *_resultDetailLabel;
    
    NSLayoutConstraint *_leftTopConstraint;
    NSLayoutConstraint *_rightTopConstraint;
    
    bool _darkMode;
}

@end

@implementation ORKdBHLFitTestStepContentView

- (instancetype)init {
    self = [super init];
    if (self) {
        _leftBudLabel = [[UIView alloc] initWithFrame:CGRectZero];
        _rightBudLabel = [[UIView alloc] initWithFrame:CGRectZero];

        _leftBudLabelText = [[UILabel alloc] initWithFrame:CGRectZero];
        _rightBudLabelText = [[UILabel alloc] initWithFrame:CGRectZero];

        [_leftBudLabel  setBounds:CGRectMake(0, 0, BUD_LABEL_SIZE, BUD_LABEL_SIZE)];
        _leftBudLabel.layer.cornerRadius = BUD_LABEL_SIZE /2.0;
        _leftBudLabel.backgroundColor = [UIColor systemGrayColor];

        [_rightBudLabel  setBounds:CGRectMake(0, 0, BUD_LABEL_SIZE, BUD_LABEL_SIZE)];
        _rightBudLabel.layer.cornerRadius = BUD_LABEL_SIZE /2.0;
        _rightBudLabel.backgroundColor = [UIColor systemGrayColor];

        _leftBudLabelText.text = @"L";
        _leftBudLabelText.textColor = [UIColor whiteColor];
        _leftBudLabelText.textAlignment = NSTextAlignmentCenter;
        _leftBudLabelText.font = [UIFont boldSystemFontOfSize:12];
        _leftBudLabelText.alpha = 1.0;

        _rightBudLabelText.text = @"R";
        _rightBudLabelText.textColor = [UIColor whiteColor];
        _rightBudLabelText.textAlignment = NSTextAlignmentCenter;
        _rightBudLabelText.font = [UIFont boldSystemFontOfSize:12];
        _rightBudLabelText.alpha = 1.0;

        [_leftBudLabel addSubview:_leftBudLabelText];
        [_rightBudLabel addSubview:_rightBudLabelText];

        _leftBudResultLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _rightBudResultLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _resultDetailLabel = [[UILabel alloc] initWithFrame:CGRectZero];

        _leftBudResultLabel.text = @"";
        _leftBudResultLabel.textColor = [UIColor blackColor];
        _leftBudResultLabel.textAlignment = NSTextAlignmentCenter;
        _leftBudResultLabel.numberOfLines = 0;
        _leftBudResultLabel.lineBreakMode = NSLineBreakByWordWrapping;
        _leftBudResultLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
        _leftBudResultLabel.alpha = 1.0;

        _rightBudResultLabel.text = @"";
        _rightBudResultLabel.textColor = [UIColor blackColor];
        _rightBudResultLabel.textAlignment = NSTextAlignmentCenter;
        _rightBudResultLabel.numberOfLines = 0;
        _rightBudResultLabel.lineBreakMode = NSLineBreakByWordWrapping;
        _rightBudResultLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
        _rightBudResultLabel.alpha = 1.0;

        _resultDetailLabel.text = @"";
        _resultDetailLabel.textColor = [UIColor blackColor];
        _resultDetailLabel.textAlignment = NSTextAlignmentCenter;
        _resultDetailLabel.numberOfLines = 0;
        _resultDetailLabel.lineBreakMode = NSLineBreakByWordWrapping;
        _resultDetailLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
        _resultDetailLabel.alpha = 1.0;
        
        _darkMode = (self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark);

        NSString *leftImageFileName = [NSString stringWithFormat:@"FitTest-Left-%s", _darkMode ? "dark" : "light"];
        NSString *rightImageFileName = [NSString stringWithFormat:@"FitTest-Right-%s", _darkMode ? "dark" : "light"];
        
        UIImage *leftImage = [UIImage imageNamed:leftImageFileName
                                        inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
        _leftImView = [[UIImageView alloc] initWithImage:leftImage];

        UIImage *rightImage = [UIImage imageNamed:rightImageFileName
                                        inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
        _rightImView = [[UIImageView alloc] initWithImage:rightImage];

        [self setupView];
        self.translatesAutoresizingMaskIntoConstraints = NO;

        [self setupConstraints];
    }
    
    return self;
}

- (void)setupView {

    _leftBudLabelText.frame = _leftBudLabel.bounds;
    _rightBudLabelText.frame = _rightBudLabel.bounds;

    _leftImView.translatesAutoresizingMaskIntoConstraints = false;
    _rightImView.translatesAutoresizingMaskIntoConstraints = false;

    _leftBudLabel.translatesAutoresizingMaskIntoConstraints = false;
    _rightBudLabel.translatesAutoresizingMaskIntoConstraints = false;

    _leftBudResultLabel.translatesAutoresizingMaskIntoConstraints = false;
    _rightBudResultLabel.translatesAutoresizingMaskIntoConstraints = false;
    _resultDetailLabel.translatesAutoresizingMaskIntoConstraints = false;

    [_leftBudResultLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
    [_rightBudResultLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];

    _spacerView = [[UIView alloc] init];
    _spacerView.translatesAutoresizingMaskIntoConstraints = false;

    [self addSubview:_leftBudLabel];
    [self addSubview:_rightBudLabel];
    [self addSubview:_leftBudResultLabel];
    [self addSubview:_rightBudResultLabel];
    [self addSubview:_resultDetailLabel];
    [self addSubview:_leftImView];
    [self addSubview:_spacerView];
    [self addSubview:_rightImView];
    

    [self bringSubviewToFront:_leftBudLabel];
    [self bringSubviewToFront:_rightBudLabel];
}

- (void)setupConstraints {
    NSMutableArray *constraints = [NSMutableArray new];

    float space = 0.4;
    
    // horizontal images
    [constraints addObject:[_spacerView.centerXAnchor constraintEqualToAnchor:self.centerXAnchor]];
    [constraints addObject:[_spacerView.widthAnchor constraintEqualToConstant:LEFT_RIGHT_IM_SEPARATION]];
    [constraints addObject:[_spacerView.centerYAnchor constraintEqualToAnchor:self.centerYAnchor]];
    
    _leftTopConstraint = [_leftImView.topAnchor constraintEqualToAnchor:self.safeAreaLayoutGuide.topAnchor constant:LEFT_RIGHT_IM_SEPARATION];
    _rightTopConstraint = [_rightImView.topAnchor constraintEqualToAnchor:self.safeAreaLayoutGuide.topAnchor constant:LEFT_RIGHT_IM_SEPARATION];
    
    [constraints addObject:[_leftImView.widthAnchor constraintEqualToConstant:339*space]];
    [constraints addObject:[_leftImView.heightAnchor constraintEqualToConstant:426*space]];
    [constraints addObject:[_rightImView.widthAnchor constraintEqualToConstant:339*space]];
    [constraints addObject:[_rightImView.heightAnchor constraintEqualToConstant:426*space]];

    [constraints addObject:[_leftImView.rightAnchor constraintEqualToAnchor:_spacerView.leftAnchor]];
    [constraints addObject:[_rightImView.leftAnchor constraintEqualToAnchor:_spacerView.rightAnchor]];
    
    [constraints addObject:_leftTopConstraint];
    [constraints addObject:_rightTopConstraint];
    
    // labels
    [constraints addObject:[_leftBudLabel.widthAnchor constraintEqualToConstant:BUD_LABEL_SIZE]];
    [constraints addObject:[_leftBudLabel.heightAnchor constraintEqualToConstant:BUD_LABEL_SIZE]];
    [constraints addObject:[_leftBudLabel.topAnchor constraintEqualToAnchor:_leftImView.bottomAnchor constant:LABEL_IMAGE_V_SEPARATION]];
    [constraints addObject:[_leftBudLabel.centerXAnchor constraintEqualToAnchor:_leftImView.centerXAnchor constant:BUD_LABEL_IMAGE_SEPARATION]];
    [constraints addObject:[_leftBudResultLabel.topAnchor constraintEqualToAnchor:_leftBudLabel.bottomAnchor constant:1.0]];
    [constraints addObject:[_leftBudResultLabel.centerXAnchor constraintEqualToAnchor:_leftBudLabel.centerXAnchor]];
    [constraints addObject:[_leftBudResultLabel.widthAnchor constraintLessThanOrEqualToConstant:RESULT_LABEL_WIDTH]];
    
    [constraints addObject:[_rightBudLabel.widthAnchor constraintEqualToConstant:BUD_LABEL_SIZE]];
    [constraints addObject:[_rightBudLabel.heightAnchor constraintEqualToConstant:BUD_LABEL_SIZE]];
    [constraints addObject:[_rightBudLabel.topAnchor constraintEqualToAnchor:_rightImView.bottomAnchor constant:LABEL_IMAGE_V_SEPARATION]];
    [constraints addObject:[_rightBudLabel.centerXAnchor constraintEqualToAnchor:_rightImView.centerXAnchor constant:-BUD_LABEL_IMAGE_SEPARATION]];
    [constraints addObject:[_rightBudResultLabel.centerXAnchor constraintEqualToAnchor:_rightBudLabel.centerXAnchor]];
    [constraints addObject:[_rightBudResultLabel.topAnchor constraintEqualToAnchor:_rightBudLabel.bottomAnchor constant:1.0]];
    [constraints addObject:[_rightBudResultLabel.widthAnchor constraintLessThanOrEqualToConstant:RESULT_LABEL_WIDTH]];
    
    CGFloat deviceHeight = UIScreen.mainScreen.bounds.size.height;
    [constraints addObject:[_resultDetailLabel.topAnchor constraintEqualToAnchor:_leftImView.bottomAnchor constant:deviceHeight < 813 ? 80 : 120.0]];
    [constraints addObject:[_resultDetailLabel.leadingAnchor constraintEqualToAnchor:self.leadingAnchor]];
    [constraints addObject:[_resultDetailLabel.trailingAnchor constraintEqualToAnchor:self.trailingAnchor]];
    [constraints addObject:[_resultDetailLabel.bottomAnchor constraintEqualToAnchor:self.bottomAnchor constant:10]];

    [NSLayoutConstraint activateConstraints:constraints];
}

-(void)resetLabelsBackgroundColors {
    _leftBudLabelText.textColor = [UIColor systemBackgroundColor];
    _rightBudLabelText.textColor = [UIColor systemBackgroundColor];
}

-(void)setStart {
    [UIView animateWithDuration:0.5 animations:^{
        _leftBudLabel.backgroundColor = [UIColor systemGrayColor];
        _leftBudResultLabel.textColor = [UIColor blackColor];
        _leftBudResultLabel.text = @"";
        
        _rightBudLabel.backgroundColor = [UIColor systemGrayColor];
        _rightBudResultLabel.textColor = [UIColor blackColor];
        _rightBudResultLabel.text = @"";
    }];
}

-(void)setResultDetailLabelText:(NSString *)text {
    _resultDetailLabel.text = text;
}

-(void)setWithLeftOk:(BOOL)leftOk rightOk:(BOOL)rightOk {
    [UIView animateWithDuration:0.5 animations:^{
        _leftBudLabel.backgroundColor = leftOk ? [UIColor systemGreenColor] : [UIColor systemYellowColor];
        _leftBudResultLabel.textColor = leftOk ? [UIColor systemGreenColor] : [UIColor systemYellowColor];
        _leftBudResultLabel.text = leftOk ? @"Good Seal" : @"Adjust or Try a Different Ear Tip";
        
        _rightBudLabel.backgroundColor = rightOk ? [UIColor systemGreenColor] : [UIColor systemYellowColor];
        _rightBudResultLabel.textColor = rightOk ? [UIColor systemGreenColor] : [UIColor systemYellowColor];
        _rightBudResultLabel.text = rightOk ? @"Good Seal" : @"Adjust or Try a Different Ear Tip";
    }];
}

@end
