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

#import "ORKTinnitusCalibrationContentView.h"
#import "ORKHelpers_Internal.h"
#import "ORKSkin.h"
#import "ORKTinnitusButtonView.h"

@interface ORKTinnitusCalibrationContentView () {
    UIImageView *_imageView;
    UILabel *_textLabel;
}

@end

@implementation ORKTinnitusCalibrationContentView

- (instancetype)initWithType:(ORKTinnitusType)type isLoudnessMatching:(BOOL) isLoudnessMatching
{
    self = [super init];
    if (self) {
        NSString *buttonTitle;
        NSString *buttonDetail= nil;
        if (isLoudnessMatching) {
            buttonTitle = ORKLocalizedString(@"TINNITUS_FINAL_CALIBRATION_BUTTON_TITLE", nil);
        } else {
            buttonTitle = [type isEqualToString:ORKTinnitusTypeWhiteNoise] ? ORKLocalizedString(@"TINNITUS_WHITENOISE_TITLE", nil) : ORKLocalizedString(@"TINNITUS_PURETONE_TITLE", nil);
            buttonDetail = [type isEqualToString:ORKTinnitusTypeWhiteNoise] ? ORKLocalizedString(@"TINNITUS_WHITENOISE_DETAIL", nil) : ORKLocalizedString(@"TINNITUS_PURETONE_DETAIL", nil);
        }
        _playButtonView = [[ORKTinnitusButtonView alloc] initWithTitle: buttonTitle detail:buttonDetail];
        _playButtonView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_playButtonView];
        self.translatesAutoresizingMaskIntoConstraints = NO;
        
        if (@available(iOS 13.0, *)) {
            UIImageConfiguration *configuration = [UIImageSymbolConfiguration configurationWithFont:[UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline] scale:UIImageSymbolScaleDefault];
            UIImage *speaker = [[UIImage systemImageNamed:@"speaker.2" withConfiguration:configuration] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            _imageView = [[UIImageView alloc] initWithImage:speaker];
            _imageView.tintColor = UIColor.systemGrayColor;
        } else {
            _imageView.tintColor = UIColor.grayColor;
        }
        [self addSubview:_imageView];
        _imageView.translatesAutoresizingMaskIntoConstraints = NO;
        
        _textLabel = [UILabel new];
        _textLabel.text = ORKLocalizedString(@"TINNITUS_CALIBRATION_TEXT2", nil);
        _textLabel.numberOfLines = 0;
        _textLabel.lineBreakMode = NSLineBreakByClipping;
        if (@available(iOS 13.0, *)) {
            _textLabel.textColor = UIColor.systemGrayColor;
        } else {
            _textLabel.textColor = UIColor.grayColor;
        }
        _textLabel.font = [self subheadlineFontBold];
        _textLabel.textAlignment = NSTextAlignmentLeft;
        [self addSubview:_textLabel];
        _textLabel.translatesAutoresizingMaskIntoConstraints = NO;
        
        [self setUpConstraints];
    }
    
    return self;
}

- (UIFont *)subheadlineFontBold {
    return [UIFont systemFontOfSize:14.0 weight:UIFontWeightRegular];
}

- (void)setUpConstraints {
    [_playButtonView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor].active = YES;
    [_playButtonView.topAnchor constraintEqualToAnchor:self.topAnchor].active = YES;
    [_playButtonView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor].active = YES;
    
    [_imageView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor].active = YES;
    [_imageView.topAnchor constraintEqualToAnchor:_playButtonView.bottomAnchor constant:16.0].active = YES;
    
    [_textLabel.leadingAnchor constraintEqualToAnchor:_imageView.trailingAnchor constant:5.0].active = YES;
    [_textLabel.centerYAnchor constraintEqualToAnchor:_imageView.centerYAnchor].active = YES;
    [_textLabel.trailingAnchor constraintEqualToAnchor:self.trailingAnchor].active = YES;
}


@end
