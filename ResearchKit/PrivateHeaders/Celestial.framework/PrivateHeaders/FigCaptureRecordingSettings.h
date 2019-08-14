/*
	File:			FigCaptureRecordingSettings.h
	Description: 	Abstraction for recording settings designed to impedance match the AVCaptureFileOutput APIs
	Authors:		Brad Ford and Walker Eagleston
	Creation Date:	10/11/13
	Copyright: 		© Copyright 2013-2016 Apple, Inc. All rights reserved.
*/

// This is conceptually a wrapper for a dictionary, with formalized API, so required fields are known.
// The object supports NSCoding, so it can be easily serialized, making it usable on both client and server.

#import <Celestial/FigCaptureCommon.h>

@interface FigCaptureRecordingSettings : NSObject <NSSecureCoding, NSCopying>

- (instancetype)init; // designated initializer

@property(nonatomic) int64_t settingsID; // unique identifier used by the client to track this recording session, must be non-zero

@property(nonatomic, copy) NSURL *outputURL;
@property(nonatomic, copy) NSString *outputFileType; // @"com.apple.quicktime-movie", @"com.microsoft.waveform-audio", etc.

// recording limits (whichever one triggers first will halt the recording)
@property(nonatomic) CMTime maxDuration;
@property(nonatomic) int64_t maxFileSize;
@property(nonatomic) int64_t minFreeDiskSpaceLimit;

// @property(nonatomic) BOOL clientWantsSampleBuffers;
// on the desktop, we let clients inspect each sbuf while recording (for frame accurate file switching)

@end


@interface FigCaptureMovieFileRecordingSettings : FigCaptureRecordingSettings

// If the codec type is different than the session configuration's capture connection an error will be returned
@property(nonatomic, copy) NSDictionary *videoSettings; // same keys as AVVideoSettings (or should we split them out and keep properties flat?)
@property(nonatomic, copy) NSDictionary *audioSettings; // same keys as AVAudioSettings (same question)
/*
	NOTE - by only having one video settings and one audio settings, I'm essentially giving up on making
	multiple video or audio tracks work.  Desktop clients could still record all channels from multiple input
	devices into a single track.  Multiple video tracks has never worked, and is still not supported by CoreMedia.
*/
// I don't think we need any compression settings for metadata/closed-captions, etc.
@property(nonatomic) BOOL videoMirrored;
@property(nonatomic) FigCaptureVideoOrientation videoOrientation;
@property(nonatomic) BOOL recordVideoOrientationAndMirroringChanges;

@property(nonatomic) CMTime movieFragmentInterval;
@property(nonatomic, copy) NSArray *movieLevelMetadata; // Matches the format accepted by FigAssetWriter's kFigAssetWriterProperty_Metadata property
// kFigCaptureSessionMovieFileSinkProperty_MovieLevelMetadata can be used to update this metadata after recording starts, which can be useful when including GPS metadata

@property(nonatomic) BOOL sendPreviewIOSurface;

@property(nonatomic, getter=isIrisRecording) BOOL irisRecording;

@property(nonatomic) BOOL debugMetadataSidecarFileEnabled;

@property(nonatomic) FigCaptureBravoCameraSelectionBehavior bravoCameraSelectionBehavior;

#if FIG_CAPTURE_THE_MOMENT_SUPPORTED
@property(nonatomic, getter=isIrisMovieRecording) BOOL irisMovieRecording; // aka "long press movie recording in CTM"
@property(nonatomic, copy) NSURL *spatialOverCaptureMovieURL;
@property(nonatomic, copy) NSArray *spatialOverCaptureMovieLevelMetadata;
@property(nonatomic) uint64_t movieStartTimeOverride; // if this is set to non-zero, preroll should be trimmed and discarded, and the movie start time (mach_absolute_time) should be no earlier than movieStartTimeOverride (Japan/Korea CTM long press movie behavior)
#endif // FIG_CAPTURE_THE_MOMENT_SUPPORTED

@end


@interface FigCaptureAudioFileRecordingSettings : FigCaptureRecordingSettings

@property(nonatomic, copy) NSDictionary *audioSettings; // same keys as AVAudioSettings (or should we split them out and keep properties flat?)
@property(nonatomic, copy) NSArray *metadata; // currently only used in certain audio file types (ID3 tag insertion, for instance), matches the format accepted by FigAssetWriter's kFigAssetWriterProperty_Metadata property

@end

