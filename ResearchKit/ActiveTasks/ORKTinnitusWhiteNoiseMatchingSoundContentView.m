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

#import "ORKTinnitusWhiteNoiseMatchingSoundContentView.h"
#import "ORKTinnitusPredefinedTaskConstants.h"
#import "ORKHelpers_Internal.h"
#import "ORKAnswerTextField.h"
#import "ORKTinnitusTypes.h"
#import "ORKSkin.h"

#import "ORKCheckmarkView.h"

static const CGFloat ORKTinnitusGlowAdjustment = 16.0;

@interface ORKTinnitusWhiteNoiseMatchingSoundContentView () {
    NSArray *_buttonsViewArray;
    UIScrollView *_scrollView;
}

@property (nonatomic, strong) ORKTinnitusButtonView *whitenoiseButtonView;
@property (nonatomic, strong) ORKTinnitusButtonView *cicadasButtonView;
@property (nonatomic, strong) ORKTinnitusButtonView *cricketsButtonView;
@property (nonatomic, strong) ORKTinnitusButtonView *teakettleButtonView;

@end

@implementation ORKTinnitusWhiteNoiseMatchingSoundContentView

- (instancetype)init {
    self = [super init];
    if (self) {
        [self commonInit];
    }
    
    return self;
}

- (void)commonInit
{
    [self setupScrollView];
    _whitenoiseButtonView = [[ORKTinnitusButtonView alloc]
                             initWithTitle:ORKLocalizedString(@"TINNITUS_WHITENOISE_TITLE", nil)
                             detail:nil];
    _whitenoiseButtonView.translatesAutoresizingMaskIntoConstraints = NO;
    [_scrollView addSubview:_whitenoiseButtonView];
    [_whitenoiseButtonView.leadingAnchor constraintEqualToAnchor:_scrollView.leadingAnchor constant:ORKTinnitusGlowAdjustment].active = YES;
    [_whitenoiseButtonView.trailingAnchor constraintEqualToAnchor:_scrollView.trailingAnchor constant:-ORKTinnitusGlowAdjustment].active = YES;
    [_whitenoiseButtonView.widthAnchor constraintEqualToAnchor:_scrollView.widthAnchor constant:-2*ORKTinnitusGlowAdjustment].active = YES;
    [_whitenoiseButtonView.topAnchor constraintEqualToAnchor:_scrollView.topAnchor constant:5.0].active = YES;
    
    _cicadasButtonView = [[ORKTinnitusButtonView alloc]
                          initWithTitle:ORKLocalizedString(@"TINNITUS_WHITENOISE_MATCHINGSOUND_CICACAS_TITLE", nil)
                          detail:nil];
    _cicadasButtonView.translatesAutoresizingMaskIntoConstraints = NO;
    [_scrollView addSubview:_cicadasButtonView];
    [_cicadasButtonView.leadingAnchor constraintEqualToAnchor:_scrollView.leadingAnchor constant:ORKTinnitusGlowAdjustment].active = YES;
    [_cicadasButtonView.trailingAnchor constraintEqualToAnchor:_scrollView.trailingAnchor constant:-ORKTinnitusGlowAdjustment].active = YES;
    [_cicadasButtonView.topAnchor constraintEqualToAnchor:_whitenoiseButtonView.bottomAnchor constant: 16.0].active = YES;
    
    _cricketsButtonView = [[ORKTinnitusButtonView alloc]
                           initWithTitle:ORKLocalizedString(@"TINNITUS_WHITENOISE_MATCHINGSOUND_CRICKETS_TITLE", nil)
                           detail:nil];
    _cricketsButtonView.translatesAutoresizingMaskIntoConstraints = NO;
    [_scrollView addSubview:_cricketsButtonView];
    [_cricketsButtonView.leadingAnchor constraintEqualToAnchor:_scrollView.leadingAnchor constant:ORKTinnitusGlowAdjustment].active = YES;
    [_cricketsButtonView.trailingAnchor constraintEqualToAnchor:_scrollView.trailingAnchor constant:-ORKTinnitusGlowAdjustment].active = YES;
    [_cricketsButtonView.topAnchor constraintEqualToAnchor:_cicadasButtonView.bottomAnchor constant: 16.0].active = YES;
    
    _teakettleButtonView = [[ORKTinnitusButtonView alloc]
                            initWithTitle:ORKLocalizedString(@"TINNITUS_WHITENOISE_MATCHINGSOUND_TEAKETTLE_TITLE", nil)
                            detail:nil];
    _teakettleButtonView.translatesAutoresizingMaskIntoConstraints = NO;
    [_scrollView addSubview:_teakettleButtonView];
    [_teakettleButtonView.leadingAnchor constraintEqualToAnchor:_scrollView.leadingAnchor constant:ORKTinnitusGlowAdjustment].active = YES;
    [_teakettleButtonView.trailingAnchor constraintEqualToAnchor:_scrollView.trailingAnchor constant:-ORKTinnitusGlowAdjustment].active = YES;
    [_teakettleButtonView.topAnchor constraintEqualToAnchor:_cricketsButtonView.bottomAnchor constant: 16.0].active = YES;
    [_teakettleButtonView.bottomAnchor constraintEqualToAnchor:_scrollView.bottomAnchor].active = YES;
    
    _buttonsViewArray = @[_whitenoiseButtonView, _cicadasButtonView, _cricketsButtonView, _teakettleButtonView];
    
    self.translatesAutoresizingMaskIntoConstraints = NO;
    
    self.clipsToBounds = NO;
    
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    _scrollView.contentSize = CGSizeMake(_scrollView.frame.size.width, _teakettleButtonView.frame.origin.y + _teakettleButtonView.frame.size.height + 32.0);
}

- (void)setupScrollView {
    if (!_scrollView) {
        _scrollView = [UIScrollView new];
    }
    [self addSubview:_scrollView];
    _scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    [[_scrollView.topAnchor constraintEqualToAnchor:self.topAnchor] setActive:YES];
    [[_scrollView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:-ORKTinnitusGlowAdjustment] setActive:YES];
    [[_scrollView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:ORKTinnitusGlowAdjustment] setActive:YES];
    [[_scrollView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor] setActive:YES];

    _scrollView.scrollEnabled = YES;
}

- (void)selectButton:(ORKTinnitusButtonView *)buttonView
{
    NSArray *unselectArray = [_buttonsViewArray
                              filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id object, NSDictionary *bindings) {
        return (object != buttonView);
    }]];
    [unselectArray makeObjectsPerformSelector:@selector(restoreButton)];
}

- (nullable ORKTinnitusNoiseType)getAnswer {
    if (_cicadasButtonView.isSelected) {
        return ORKTinnitusNoiseTypeCicadas;
    } else if (_cricketsButtonView.isSelected) {
        return ORKTinnitusNoiseTypeCrickets;
    } else if (_whitenoiseButtonView.isSelected) {
        return ORKTinnitusNoiseTypeWhiteNoise;
    } else if (_teakettleButtonView.isSelected) {
        return ORKTinnitusNoiseTypeTeakettle;
    }
    return nil;
}

@end
