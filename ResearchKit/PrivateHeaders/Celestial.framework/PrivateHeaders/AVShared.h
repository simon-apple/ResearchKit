/*
 File:          AVShared.h
 
 Description:   Project shared headers.
 
 Author:        Jeremy Jones
 
 Copyright:     © Copyright 2007-2013 Apple, Inc. All rights reserved.
 
 $Log$
    11mar2016 smorampudi
    <rdar://24940712> Update file encoding to utf-8 <jdecoodt, jsam, kcalhoun, jalliot>

 16may2013 jdecoodt
 <rdar://problem/12951732> Bump copyright to 2013. <jsam>

 28feb2013 jeremyj
 [12314867] use objc weak references. <jsam, sgoldrei>
 
	19feb2010 jim + gregc
	Merged changes from iPhone-Wildcat to trunk.

		18feb2010 jeremyj
		[7651820] remove per thread object registration. <eric>
		
	12feb2010 jim + jeremyj
	Merged changes from iPhone-Wildcat to trunk.

		 12feb2010 jeremyj
		 [7615175] added safeRetainObject and related methods <eric>
		
 17mar2009 jeremyj
 [6682882] Added safe perfrom selector after delay. <nikhil>

 23feb2009 jeremyj
 [6605332] Make AVValue available. <nikhil>

 19nov2008 jeremyj
 [6318828] fix leaked NSSet <jim>

 03apr2008 jeremyj
 [5825075] allow targeting other threads than the main thread <eric>

 15jan2008 jeremyj
 [5333729] add -safePerformOnMainThreadTarget:selector:object:delay: <jim>

 19june2007 jim
 Merge fix for [5203659] into trunk from users/jeremy/iPhoneSU. <jeremyj>
	
	 21may2007 jeremyj
	 [5203659] Added support for safe posting of notifications.

 1may2007 jeremyj
 added AVObjectRegistry <jsam>
	
 25apr2007 jeremyj
 new notification mech <jsam>

 23feb2007 jeremyj
 first checked in <jim>
 
 */

#import <Foundation/Foundation.h>

@interface NSObject (NSObject_AVShared)

-(void)allowSafePerformSelector;
-(void)disallowSafePerformSelector;

-(BOOL)okToNotifyFromThisThread;
-(void)fromNotifySafeThreadPerformSelector:(SEL)selector withObject:(id)obj;
-(void)fromNotifySafeThreadPostNotificationName:(NSString*)notificationName object:(id)obj userInfo:(NSDictionary*)userInfo;
-(void)fromMainThreadPostNotificationName:(NSString*)notificationName object:(id)obj userInfo:(NSDictionary*)userInfo;

@end

@interface AVValue : NSObject
{
	SEL _selector;
}

+(AVValue*)valueWithSelector:(SEL)selector;
-(id)initWithSelector:(SEL)selector;
-(SEL)selectorValue;

@end


@interface AVObjectRegistry : NSObject
{
	NSHashTable*         _registeredObjects;
	NSRecursiveLock*     _lock;
}

+(AVObjectRegistry*)defaultObjectRegistry;

//call this from init
-(void)registerObjectForSafeRetain:(id)obj; 

//call this anywhere you have a pointer but no retain count
//return YES means you successfully retained the object
-(BOOL)safeRetainObject:(id)obj;

-(void)registerObject:(id)obj;
-(void)unregisterObject:(id)obj;

-(void)safePerformTarget:(id)target selector:(SEL)selector object:(id)obj delay:(NSTimeInterval)delay;
-(void)safePerformOnMainThreadTarget:(id)target selector:(SEL)selector object:(id)obj delay:(NSTimeInterval)delay;
-(void)safePerformOnMainThreadTarget:(id)target selector:(SEL)selector object:(id)obj;
-(void)safeInvokeWithDescription:(NSDictionary*)desc;

-(void)safePostDelayedNotificationFromMainThreadTarget:(id)target name:(NSString*)name userInfo:(NSDictionary*)userInfo;
-(void)safePostNotificationFromMainThreadTarget:(id)target name:(NSString*)name userInfo:(NSDictionary*)userInfo;

-(void)safePerformOnThread:(NSThread*)thread target:(id)target selector:(SEL)selector object:(id)obj;
-(void)safePostDelayedNotificationFromThread:(NSThread*)thread target:(id)target name:(NSString*)name userInfo:(NSDictionary*)userInfo;
-(void)safePostNotificationFromThread:(NSThread*)thread target:(id)target name:(NSString*)name userInfo:(NSDictionary*)userInfo;

@end
