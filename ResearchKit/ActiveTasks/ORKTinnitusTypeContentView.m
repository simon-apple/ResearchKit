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

#import "ORKTinnitusTypeContentView.h"
#import "ORKHelpers_Internal.h"

@implementation ORKTinnitusTypeContentView

- (instancetype)init
{
    self = [super init];
    if (self) {
        _pureToneButtonView = [[ORKTinnitusButtonView alloc]
                               initWithTitle:ORKLocalizedString(@"TINNITUS_PURETONE_TITLE", nil)
                               detail:ORKLocalizedString(@"TINNITUS_PURETONE_DETAIL", nil)];
        _pureToneButtonView.translatesAutoresizingMaskIntoConstraints = NO;
      
        [self addSubview:_pureToneButtonView];
        
        _whiteNoiseButtonView = [[ORKTinnitusButtonView alloc]
                                 initWithTitle:ORKLocalizedString(@"TINNITUS_WHITENOISE_TITLE", nil)
                                 detail:ORKLocalizedString(@"TINNITUS_WHITENOISE_DETAIL", nil)];
        
        _whiteNoiseButtonView.translatesAutoresizingMaskIntoConstraints = NO;
        
        [self addSubview:_whiteNoiseButtonView];
          
        self.translatesAutoresizingMaskIntoConstraints = NO;
        
        [self setUpConstraints];
    }
    
    return self;
}

- (void)unselectButtons
{
    [_whiteNoiseButtonView setSelected:NO];
    [_pureToneButtonView setSelected:NO];
}

- (void)setUpConstraints
{
    [_whiteNoiseButtonView.topAnchor constraintEqualToAnchor:self.topAnchor].active = YES;
    [_whiteNoiseButtonView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:0.0].active = YES;
    [_whiteNoiseButtonView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:0.0].active = YES;
    
    [_pureToneButtonView.topAnchor constraintEqualToAnchor:_whiteNoiseButtonView.bottomAnchor constant:12.0].active = YES;
    [_pureToneButtonView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:0.0].active = YES;
    [_pureToneButtonView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:0.0].active = YES;
}

@end
