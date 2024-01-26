/*
 Copyright (c) 2016, Sage Bionetworks
 
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


#import "ORKSignatureResult_Private.h"

#import "ORKResult_Private.h"
#import "ORKHelpers_Internal.h"


@implementation ORKSignatureResult

- (instancetype)initWithIdentifier:(NSString *)identifier
                    signatureImage:(UIImage *)signatureImage
                     signaturePath:(NSArray <UIBezierPath *> *)signaturePath {
    self = [super initWithIdentifier:identifier];
    if (self) {
        _signatureImage = [signatureImage copy];
        _signaturePath = ORKArrayCopyObjects(signaturePath);
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    ORK_ENCODE_IMAGE(aCoder, signatureImage);
    ORK_ENCODE_OBJ(aCoder, signaturePath);
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        ORK_DECODE_IMAGE(aDecoder, signatureImage);
        ORK_DECODE_OBJ_ARRAY(aDecoder, signaturePath, UIBezierPath);
    }
    return self;
}

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (NSUInteger)hash {
    return super.hash ^ self.signatureImage.hash ^ self.signaturePath.hash;
}

- (BOOL)isEqual:(id)object {
    BOOL isParentSame = [super isEqual:object];
    
    __typeof(self) castObject = object;
    return (isParentSame &&
            ORKEqualObjects(self.signatureImage, castObject.signatureImage) &&
            ORKEqualObjects(self.signaturePath, castObject.signaturePath));
}

- (instancetype)copyWithZone:(NSZone *)zone {
    ORKSignatureResult *result = [super copyWithZone:zone];
    result->_signatureImage = [_signatureImage copy];
    result->_signaturePath = ORKArrayCopyObjects(_signaturePath);
    return result;
}

- (NSString *)applyToHTML:(NSString *)html {
    if (![html containsString:@"</body>"] || ![html containsString:@"</html>"]) {
        return nil;
    }
    
    NSRange bodyReplaceRangeRange = [html rangeOfString:@"</body>"];
    NSString *newString = [html stringByReplacingCharactersInRange:bodyReplaceRangeRange withString:@""];
    
    NSRange htmlReplaceRangeRange = [newString rangeOfString:@"</html>"];
    newString = [newString stringByReplacingCharactersInRange:htmlReplaceRangeRange withString:@""];
    
    NSMutableString *body = [NSMutableString new];

    NSString *hr = @"<hr align='left' width='100%' style='height:1px; border:none; color:#000; background-color:#000; margin-top: -10px; margin-bottom: 0px;' />";
    NSString *signatureElementWrapper = @"<p><br/><div class='sigbox'><div class='inbox'>%@</div></div>%@%@</p>";
    NSString *signatureImageWrapper = @"<p><br/><div class='sigbox'><div class='inboxImage'>%@</div></div>%@%@</p>";
    
    NSMutableArray *signatureElements = [NSMutableArray array];
    
    NSString *base64 = [UIImagePNGRepresentation(self.signatureImage) base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    NSString *imageTag = [NSString stringWithFormat:@"<img width='100%%' alt='star' src='data:image/png;base64,%@' />", base64];
    
    [signatureElements addObject:[NSString stringWithFormat:signatureImageWrapper, imageTag, hr, ORKLocalizedString(@"CONSENT_DOC_LINE_SIGNATURE", nil)]];
    [body appendString:[NSString stringWithFormat:@"<div width='200'>%@</div>", signatureElements.lastObject]];
    
    
    newString = [newString stringByAppendingString:body];
    newString = [newString stringByAppendingString:@"</body></html>"];
    
    return newString;
}

@end
