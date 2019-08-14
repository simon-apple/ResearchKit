/*
	File:			FigCaptureObfuscation.h
	Description: 	A place to obfuscate all of our strings/methods/functions with names that span objects and implementations
	Authors:		Brad Ford
	Creation Date:	04/28/15
	Copyright: 		© Copyright 2015-2017 Apple, Inc. All rights reserved.
*/

#ifndef FIGCAPTUREOBFUSCATION_H
#define FIGCAPTUREOBFUSCATION_H

#import <CoreMedia/FigCaptureHideFeatures.h>
#import <CoreMedia/CMBasePrivate.h> // for FIG_PHOTO_SUPPORT_HEIF define

// For string obfuscation:
// If you want to stringify the result of expansion of a macro argument, you have to use two levels of macros.
//
// NOTE: Be aware of conflicts with a redefinition of xstr or stringify when other frameworks use this file.
#define xstr(s) stringify(s)
#define stringify(s) @#s

// ObjectTracking
#define FIG_CAPTURE_OBJECT_TRACKING_SUPPORTED									( 0 )
#if FIG_CAPTURE_OBJECT_TRACKING_SUPPORTED
#define FIG_HIDE_OBJECT_TRACKING_SYMBOL( RealSymbol, ReplacementSymbol )		RealSymbol
#else
#define FIG_HIDE_OBJECT_TRACKING_SYMBOL( RealSymbol, ReplacementSymbol )		ReplacementSymbol
#endif

#endif // FIGCAPTUREOBFUSCATION_H
