/*
    File:          AVCommon.h

    Copyright:     © Copyright 2006-2007 Apple Computer, Inc. All rights reserved.

	$Log$
	11mar2016 smorampudi
	<rdar://24940712> Update file encoding to utf-8 <jdecoodt, jsam, kcalhoun, jalliot>

	12nov2007 jim+jsam
	Merge LittleBear to trunk.
	
		22oct2007 jsam
		Add AVAlternate* strings.
		also, added log.  <jb,abb>
*/

#ifndef __AVCOMMON_M_H__
#define __AVCOMMON_M_H__

#ifndef AV_EXTERN
#ifdef __cplusplus
#define AV_EXTERN extern "C"
#else
#define AV_EXTERN extern
#endif
#endif

#if !NSINTEGER_DEFINED
typedef int				NSInteger;
typedef unsigned int	NSUInteger;
#endif


//JSJ: These are "magical" numbers.
enum {
	kAVControllerEQPreset_Disabled		= 0,
	kAVControllerEQPreset_Acoustic,
	kAVControllerEQPreset_BassBooster,
	kAVControllerEQPreset_BassReducer,
	kAVControllerEQPreset_Classical,
	kAVControllerEQPreset_Dance,
	kAVControllerEQPreset_Deep,
	kAVControllerEQPreset_Electronic,
	kAVControllerEQPreset_Flat,
	kAVControllerEQPreset_HipHop,
	kAVControllerEQPreset_Jazz,
	kAVControllerEQPreset_Latin,
	kAVControllerEQPreset_Loudness,
	kAVControllerEQPreset_Lounge,
	kAVControllerEQPreset_Piano,
	kAVControllerEQPreset_Pop,
	kAVControllerEQPreset_RandB,
	kAVControllerEQPreset_Rock,
	kAVControllerEQPreset_SmallSpeakers,
	kAVControllerEQPreset_SpokenWord,
	kAVControllerEQPreset_TrebleBooster,
	kAVControllerEQPreset_TrebleReducer,
	kAVControllerEQPreset_VocalBooster,
	kAVControllerEQPreset_NumPresets
} ;
typedef NSInteger AVControllerEQPresetType;

// Alternate track support -- keys used in various AVItem and AVController properties

AV_EXTERN NSString *AVAlternateType_Audio;
AV_EXTERN NSString *AVAlternateType_Subtitle;

AV_EXTERN NSString *AVAlternateInfo_TrackID; // NSNumber
AV_EXTERN NSString *AVAlternateInfo_Language; // NSString (ISO 639-2/T lowercase three-char-code)
AV_EXTERN NSString *AVAlternateInfo_Name; // NSString (optional)
AV_EXTERN NSString *AVAlternateInfo_AudioFormat; // NSString (optional)
AV_EXTERN NSString *AVAlternateInfo_ExcludeFromAutoSelection; // kCFBooleanTrue if this alternate should be excluded from automatic language-based selection (eg, commentary track)


#endif //__AVCOMMON_M_H__
