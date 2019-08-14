/*
	AVClientNames.h
	
	$Log$
	1march2007 jsam
	Add three more client names -- <rdar://problem/5032857>.  <jb>
	
	30oct2006 jim
	Added AVClientName_Phone (will remove AVClientName_Ringtone after app moves over)
	
	19sept2006 jsam + jim
	first time
*/

#ifndef __AVCLIENTNAMES__
#define __AVCLIENTNAMES__

#define AVClientName_MusicPlayer		@"MusicPlayer"
#define AVClientName_MoviePlayer		@"MoviePlayer"
#define AVClientName_Safari				@"Safari"
#define AVClientName_Mail				@"Mail"
#define AVClientName_SlideShow			@"SlideShow"
#define AVClientName_Ringtone			@"Phone"
#define AVClientName_Phone				@"Phone"
#define AVClientName_Voicemail			@"Voicemail"
#define AVClientName_AlarmClock			@"AlarmClock"
#define AVClientName_CountdownAlarm		@"CountdownAlarm"
#define AVClientName_SleepTimerAlarm	@"SleepTimerAlarm"

#define AVClientPriority_SuperDuper		10
#define AVClientPriority_Plain			0
#define AVClientPriority_NotSoCrucial	-10

#endif // __AVCLIENTNAMES__
