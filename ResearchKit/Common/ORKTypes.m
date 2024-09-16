/*
 Copyright (c) 2017, Apple Inc. All rights reserved.
 Copyright (c) 2017, Sage Bionetworks
 
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


#import "ORKTypes.h"
#import "ORKHelpers_Internal.h"

ORKHeadphoneTypeIdentifier const ORKHeadphoneTypeIdentifierAirPods = @"AIRPODS";

ORKHeadphoneTypeIdentifier const ORKHeadphoneTypeIdentifierAirPodsGen1 = @"AIRPODSV1";

ORKHeadphoneTypeIdentifier const ORKHeadphoneTypeIdentifierAirPodsGen2 = @"AIRPODSV2";

ORKHeadphoneTypeIdentifier const ORKHeadphoneTypeIdentifierAirPodsGen3 = @"AIRPODSV3";

ORKHeadphoneTypeIdentifier const ORKHeadphoneTypeIdentifierAirPodsPro = @"AIRPODSPRO";

ORKHeadphoneTypeIdentifier const ORKHeadphoneTypeIdentifierAirPodsProGen2 = @"AIRPODSPROV2";

ORKHeadphoneTypeIdentifier const ORKHeadphoneTypeIdentifierAirPodsMax = @"AIRPODSMAX";

ORKHeadphoneTypeIdentifier const ORKHeadphoneTypeIdentifierAirPodsMaxUSBC = @"AIRPODSMAXUSBC";

ORKHeadphoneTypeIdentifier const ORKHeadphoneTypeIdentifierEarPods = @"EARPODS";

ORKHeadphoneTypeIdentifier const ORKHeadphoneTypeIdentifierUnknown = @"UNKNOWN";
#if RK_APPLE_INTERNAL
ORKHeadphoneChipsetIdentifier const ORKHeadphoneChipsetIdentifierAirPods = @"aa2d";

ORKHeadphoneChipsetIdentifier const ORKHeadphoneChipsetIdentifierLightningEarPods = @"b225";

ORKHeadphoneChipsetIdentifier const ORKHeadphoneChipsetIdentifierAudioJackEarPods = @"b60";

ORKHeadphoneVendorAndProductIdIdentifier const ORKHeadphoneVendorAndProductIdIdentifierAirPodsGen1 = @"76,8194";

ORKHeadphoneVendorAndProductIdIdentifier const ORKHeadphoneVendorAndProductIdIdentifierAirPodsGen2 = @"76,8207";

ORKHeadphoneVendorAndProductIdIdentifier const ORKHeadphoneVendorAndProductIdIdentifierAirPodsGen3 = @"76,8211";

ORKHeadphoneVendorAndProductIdIdentifier const ORKHeadphoneVendorAndProductIdIdentifierAirPodsPro = @"76,8206";

ORKHeadphoneVendorAndProductIdIdentifier const ORKHeadphoneVendorAndProductIdIdentifierAirPodsProGen2 = @"76,8212";

ORKHeadphoneVendorAndProductIdIdentifier const ORKHeadphoneVendorAndProductIdIdentifierAirPodsProGen2USBC = @"76,8228";

ORKHeadphoneVendorAndProductIdIdentifier const ORKHeadphoneVendorAndProductIdIdentifierAirPodsMax = @"76,8202";

ORKHeadphoneVendorAndProductIdIdentifier const ORKHeadphoneVendorAndProductIdIdentifierAirPodsMaxUSBC = @"76,8223";
#endif
ORKTrailMakingTypeIdentifier const ORKTrailMakingTypeIdentifierA = @"A";

ORKTrailMakingTypeIdentifier const ORKTrailMakingTypeIdentifierB = @"B";

ORKSpeechRecognizerLocale const ORKSpeechRecognizerLocaleArabic = @"ar-SA";

ORKSpeechRecognizerLocale const ORKSpeechRecognizerLocaleCatalan = @"ca-ES";

ORKSpeechRecognizerLocale const ORKSpeechRecognizerLocaleCzech = @"cs-CZ";

ORKSpeechRecognizerLocale const ORKSpeechRecognizerLocaleDanish = @"da-DK";

ORKSpeechRecognizerLocale const ORKSpeechRecognizerLocaleGermanAT = @"de-AT";

ORKSpeechRecognizerLocale const ORKSpeechRecognizerLocaleGermanCH = @"de-CH";

ORKSpeechRecognizerLocale const ORKSpeechRecognizerLocaleGermanDE = @"de-DE";

ORKSpeechRecognizerLocale const ORKSpeechRecognizerLocaleGreek = @"el-GR";

ORKSpeechRecognizerLocale const ORKSpeechRecognizerLocaleEnglishAE = @"en-AE";

ORKSpeechRecognizerLocale const ORKSpeechRecognizerLocaleEnglishAU = @"en-AU";

ORKSpeechRecognizerLocale const ORKSpeechRecognizerLocaleEnglishCA = @"en-CA";

ORKSpeechRecognizerLocale const ORKSpeechRecognizerLocaleEnglishGB = @"en-GB";

ORKSpeechRecognizerLocale const ORKSpeechRecognizerLocaleEnglishID = @"en-ID";

ORKSpeechRecognizerLocale const ORKSpeechRecognizerLocaleEnglishIE = @"en-IE";

ORKSpeechRecognizerLocale const ORKSpeechRecognizerLocaleEnglishIN = @"en-IN";

ORKSpeechRecognizerLocale const ORKSpeechRecognizerLocaleEnglishNZ = @"en-NZ";

ORKSpeechRecognizerLocale const ORKSpeechRecognizerLocaleEnglishPH = @"en-PH";

ORKSpeechRecognizerLocale const ORKSpeechRecognizerLocaleEnglishSA = @"en-SA";

ORKSpeechRecognizerLocale const ORKSpeechRecognizerLocaleEnglishSG = @"en-SG";

ORKSpeechRecognizerLocale const ORKSpeechRecognizerLocaleEnglishUS = @"en-US";

ORKSpeechRecognizerLocale const ORKSpeechRecognizerLocaleEnglishZA = @"en-ZA";

ORKSpeechRecognizerLocale const ORKSpeechRecognizerLocaleSpanishCL = @"es-CL";

ORKSpeechRecognizerLocale const ORKSpeechRecognizerLocaleSpanishCO = @"es-CO";

ORKSpeechRecognizerLocale const ORKSpeechRecognizerLocaleSpanishES = @"es-ES";

ORKSpeechRecognizerLocale const ORKSpeechRecognizerLocaleSpanishMX = @"es-MX";

ORKSpeechRecognizerLocale const ORKSpeechRecognizerLocaleSpanishUS = @"es-US";

ORKSpeechRecognizerLocale const ORKSpeechRecognizerLocaleFinnish = @"fi-FI";

ORKSpeechRecognizerLocale const ORKSpeechRecognizerLocaleFrenchBE = @"fr-BE";

ORKSpeechRecognizerLocale const ORKSpeechRecognizerLocaleFrenchCA = @"fr-CA";

ORKSpeechRecognizerLocale const ORKSpeechRecognizerLocaleFrenchCH = @"fr-CH";

ORKSpeechRecognizerLocale const ORKSpeechRecognizerLocaleFrenchFR = @"fr-FR";

ORKSpeechRecognizerLocale const ORKSpeechRecognizerLocaleHebrew = @"he-IL";

ORKSpeechRecognizerLocale const ORKSpeechRecognizerLocaleHindi = @"hi-IN";

ORKSpeechRecognizerLocale const ORKSpeechRecognizerLocaleHindiINTRANSLIT = @"hi-IN-translit";

ORKSpeechRecognizerLocale const ORKSpeechRecognizerLocaleHindiLATN = @"hi-Latn";

ORKSpeechRecognizerLocale const ORKSpeechRecognizerLocaleCroatian = @"hr-HR";

ORKSpeechRecognizerLocale const ORKSpeechRecognizerLocaleHungarian = @"hu-HU";

ORKSpeechRecognizerLocale const ORKSpeechRecognizerLocaleIndonesian = @"id-ID";

ORKSpeechRecognizerLocale const ORKSpeechRecognizerLocaleItalianCH = @"it-CH";

ORKSpeechRecognizerLocale const ORKSpeechRecognizerLocaleItalianIT = @"it-IT";

ORKSpeechRecognizerLocale const ORKSpeechRecognizerLocaleJapanese = @"ja-JP";

ORKSpeechRecognizerLocale const ORKSpeechRecognizerLocaleKorean = @"ko-KR";

ORKSpeechRecognizerLocale const ORKSpeechRecognizerLocaleMalay = @"ms-MY";

ORKSpeechRecognizerLocale const ORKSpeechRecognizerLocaleNorwegian = @"nb-NO";

ORKSpeechRecognizerLocale const ORKSpeechRecognizerLocaleDutchBE = @"nl-BE";

ORKSpeechRecognizerLocale const ORKSpeechRecognizerLocaleDutchNL = @"nl-NL";

ORKSpeechRecognizerLocale const ORKSpeechRecognizerLocalePolish = @"pl-PL";

ORKSpeechRecognizerLocale const ORKSpeechRecognizerLocalePortugeseBR = @"pt-BR";

ORKSpeechRecognizerLocale const ORKSpeechRecognizerLocalePortugesePT = @"pt-PT";

ORKSpeechRecognizerLocale const ORKSpeechRecognizerLocaleRomanian = @"ro-RO";

ORKSpeechRecognizerLocale const ORKSpeechRecognizerLocaleRussian = @"ru-RU";

ORKSpeechRecognizerLocale const ORKSpeechRecognizerLocaleSlovak = @"sk-SK";

ORKSpeechRecognizerLocale const ORKSpeechRecognizerLocaleSwedish = @"sv-SE";

ORKSpeechRecognizerLocale const ORKSpeechRecognizerLocaleThai = @"th-TH";

ORKSpeechRecognizerLocale const ORKSpeechRecognizerLocaleTurkish = @"tr-TR";

ORKSpeechRecognizerLocale const ORKSpeechRecognizerLocaleUkranian = @"uk-UA";

ORKSpeechRecognizerLocale const ORKSpeechRecognizerLocaleVietnamese = @"vi-VN";

ORKSpeechRecognizerLocale const ORKSpeechRecognizerLocaleShanghainese = @"wuu-CN";

ORKSpeechRecognizerLocale const ORKSpeechRecognizerLocaleCantonese = @"yue-CN";

ORKSpeechRecognizerLocale const ORKSpeechRecognizerLocaleChineseCN = @"zh-CN";

ORKSpeechRecognizerLocale const ORKSpeechRecognizerLocaleChineseHK = @"zh-HK";

ORKSpeechRecognizerLocale const ORKSpeechRecognizerLocaleChineseTW = @"zh-TW";

const double ORKDoubleDefaultValue = DBL_MAX;

const CGFloat ORKCGFloatDefaultValue = CGFLOAT_MAX;

@implementation ORKNoAnswer

+ (instancetype)new {
    ORKThrowMethodUnavailableException();
}

- (instancetype)init {
    ORKThrowMethodUnavailableException();
}

- (instancetype)init_ork {
   return [super init];
}

- (nonnull id)copyWithZone:(nullable NSZone *)zone {
    return self;
}

- (void)encodeWithCoder:(nonnull NSCoder *)coder {
    return;
}

- (nullable instancetype)initWithCoder:(nonnull NSCoder *)coder {
    return [[self class] answer];
}

+ (BOOL)supportsSecureCoding {
    return YES;
}

@end

@implementation ORKDontKnowAnswer

+ (instancetype)answer {
    static ORKDontKnowAnswer *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init_ork];
    });
    return instance;
}

@end
