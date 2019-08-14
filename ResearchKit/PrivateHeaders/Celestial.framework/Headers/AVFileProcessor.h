/*
	AVFileProcessor.h
	Celestial
	Created by Jeremy Jones on 7/24/07.
	Copyright 2007 Apple Inc. All rights reserved.

	$Id:
	$Log$
	25jan2019 ABB
	<rdar://problem/46079018> Now includes CMBasePrivate.h. externs now use CM_EXPORT <moritz>

	03jun2011 pietsch
	rdar://9531075 Expose progress in AVFileProcessor. <elee>
	
	14jul2010 ABB
	[8173278] Added AVFileProcessorKeys and -sinfInfoFromFilePath. <jim>
	
	03mar2010 jim + gregc
	Merged changes from iPhone-Wildcat to trunk.

		25feb2010 jim
		<rdar://problem/7639404> that's really sinfsFromFilePath: <RNP>
		
		22feb2010 jim + ABB
		<rdar://problem/7639404> add sinfsFromPath: <gew>
	
	5jun2009 wmay
	[6922154] Provide new keys for purchase bundle <jsam>
	
	19oct2007 jeremyj
	[5550353] renamed voodoo attributes <jim>

	9aug2007 jim
	add build time flag to disable rental apis <jsam>
	
	8aug2007 jeremyj
	[5396891] added resultInfo out parameter. <jim>

	27jul2007 jeremyj
	Fix typo in comments. <jim>

	27jul2007 jeremyj
	[5358478] Added -rentalInfo: <jim>
 
	24july2007 jsam
	Fix typo in API name.
	
	24jul2007 jeremyj
	Initial check-in. <jim>

*/

#import <CoreMedia/CMBasePrivate.h>
#import <Foundation/Foundation.h>
#import <MediaToolbox/FigPostPurchaseErrors.h>

CM_EXPORT NSString* AVFileProcessorAttribute_Sinfs;  //NSArray of NSDictionary with keys ("id" <int>, "sinf" <NSData>)
CM_EXPORT NSString* AVFileProcessorAttribute_KeyBag; //NSData
CM_EXPORT NSString* AVFileProcessorAttribute_FileMD5; 		 //NSData
CM_EXPORT NSString* AVFileProcessorAttribute_ChunkMD5Array; // NSArray of NSData
CM_EXPORT NSString* AVFileProcessorAttribute_MD5ChunkSize;  //NSNumber

#if CELESTE_SUPPORT_RENTALS
//Keys of the dictionary returned by -rentalInfo:
CM_EXPORT NSString* AVFileProcessorAttribute_RentalStartDate;         //NSDate
CM_EXPORT NSString* AVFileProcessorAttribute_RentalPeriod;            //NSNumber (NSTimeInterval)
CM_EXPORT NSString* AVFileProcessorAttribute_RentalPlaybackStartDate; //NSDate
CM_EXPORT NSString* AVFileProcessorAttribute_RentalPlaybackPeriod;    //NSNumber (NSTimeInterval)
#endif // CELESTE_SUPPORT_RENTALS

// Keys of the dictionary returned by -sinfInfoFromFilePath
CM_EXPORT NSString* AVFileProcessorKey_Sinf;
CM_EXPORT NSString* AVFileProcessorKey_Sinf2;
CM_EXPORT NSString* AVFileProcessorKey_MediaType;

CM_EXPORT NSString* AVFileProcessorAttribute_NewFileExtension;  //NSString

@interface AVFileProcessor : NSObject {
@private
	float _percentComplete;
}

+(AVFileProcessor*)fileProcessor;

-(NSError*)processPurchasedItem:(NSString*)filePath withAttributes:(NSDictionary*)attributes;
-(NSError*)processPurchasedItem:(NSString*)filePath withAttributes:(NSDictionary*)attributes progressBlock:(void (^)(float))progress;
-(NSError*)processPurchasedItem:(NSString*)filePath withAttributes:(NSDictionary*)attributes resultInfo:(NSDictionary**)resultInfo;
-(NSError*)processPurchasedItem:(NSString*)filePath withAttributes:(NSDictionary*)attributes resultInfo:(NSDictionary**)resultInfo progressBlock:(void (^)(float))progress;

#if CELESTE_SUPPORT_RENTALS
-(NSDictionary*)rentalInfo:(NSString*)filePath;
#endif // CELESTE_SUPPORT_RENTALS

-(NSArray*)sinfsFromFilePath:(NSString*)filePath;
-(NSArray*)sinfInfoFromFilePath:(NSString*)filePath;

@end
