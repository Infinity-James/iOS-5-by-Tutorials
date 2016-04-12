//
//  AppCalendar.m
//  TV Guide
//
//  Created by James Valaitis on 12/11/2012.
//  Copyright (c) 2012 &Beyond. All rights reserved.
//

#import "AppCalendar.h"

@implementation AppCalendar

#pragma mark - Singleton Method

+ (EKEventStore *)eventStore
{
	static dispatch_once_t	once;
	static EKEventStore		*eventStore;
	
	//	executes this only once (because it is a singleton after all)
	dispatch_once(&once,
	^{
		eventStore			= [[EKEventStore alloc] init];
	});
	
	return eventStore;
}

#pragma mark - Calendar Methods

+ (EKCalendar *)calendar
{
	//	prepare object to hold result and get our singleton event store instance
	EKCalendar *result;
	EKEventStore *store		= [self eventStore];
	
	//	checked for persisted calendar id
	NSUserDefaults *prefs	= [NSUserDefaults standardUserDefaults];
	NSString *calendarID	= [prefs stringForKey:@"appCalendar"];
	
	//	if there was a calendar id previously created, and we can get a calendar with it, return it
	if (calendarID && (result = [store calendarWithIdentifier:calendarID]))
		return result;
	
	//	get the array of the calendars assoicated with the event store
	NSArray *calendars		= [store calendarsForEntityType:EKEntityTypeEvent];
	
	//	just in case we did make a calendar, but failed to save the id, check for a calendar with the same name
	for (EKCalendar *calendar in calendars)
		if ([calendar.title isEqualToString:kAppCalendarTitle])
			if (!calendar.immutable)
			{
				//	save the calendar id for future reference so that we don't make this mistake again
				[prefs setValue:calendar.calendarIdentifier forKey:@"appCalendar"];
				[prefs synchronize];
				return calendar;
			}
	
	//	if no calendar is found, create one
	result					= [self createAppCalendar];
	
	return result;
}

+ (EKCalendar *)createAppCalendar
{
	//	get the singleto event store
	EKEventStore *store		= [self eventStore];
	
	//	fetch the local event store source
	EKSource *localSource;
	
	//	iterate over available sources
	for (EKSource *source in store.sources)
	{
		if (source.sourceType == EKSourceTypeCalDAV)
			localSource		= source;
		else if (source.sourceType == EKSourceTypeLocal)
			localSource		= source;
	}
	
	if (!localSource)		return nil;
	
	//	create a new calendar
	EKCalendar *newCalendar	= [EKCalendar calendarForEntityType:EKEntityTypeEvent eventStore:store];
	newCalendar.title		= kAppCalendarTitle;
	newCalendar.source		= localSource;
	newCalendar.CGColor		= [UIColor colorWithRed:0.8 green:0.251 blue:0.6 alpha:1].CGColor;
	
	//	save the calendar in the event store
	NSError *error;
	[store saveCalendar:newCalendar commit:YES error:&error];
	
	if (error)				return nil;
	
	//	store the calendar id
	NSUserDefaults *prefs	= [NSUserDefaults standardUserDefaults];
	[prefs setValue:newCalendar.calendarIdentifier forKey:@"appCalendar"];
	[prefs synchronize];
	
	return newCalendar;
}

@end
