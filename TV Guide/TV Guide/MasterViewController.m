//
//  MasterViewController.m
//  TV Guide
//
//  Created by James Valaitis on 12/11/2012.
//  Copyright (c) 2012 &Beyond. All rights reserved.
//

#import "AppCalendar.h"
#import "MasterViewController.h"

@interface MasterViewController ()

@end

@implementation MasterViewController

#pragma mark - View Lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil
			   bundle:(NSBundle *)nibBundleOrNil
{
	if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])
	{
		self.title					= @"TV Guide";
	}
	
	return self;
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	NSString *listPath				= [[NSBundle mainBundle].resourcePath stringByAppendingPathComponent:@"showList.plist"];
	
	_shows							= [NSArray arrayWithContentsOfFile:listPath];
	
	[[AppCalendar eventStore] requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error)
	{
		if (!error && granted)
			NSLog(@"I think this should work fine.");
	}];
}

#pragma mark - Calendar Methods

- (void)addShow:(NSDictionary *)show
	 toCalendar:(EKCalendar *)calendar
{
	//	create an event in our event store and define which calendar it belongs to
	EKEvent *event					= [EKEvent eventWithEventStore:[AppCalendar eventStore]];
	event.calendar					= calendar;
	
	//	set an alarm for six minutes before the show starts
	EKAlarm *myAlarm				= [EKAlarm alarmWithRelativeOffset:-06 * 60];
	[event addAlarm:myAlarm];
	
	NSDateFormatter *from			= [[NSDateFormatter alloc] init];
	[from setDateFormat:@"MM/dd/yy HH:mm zzz"];
	[from setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en-US"]];
	event.startDate					= [from dateFromString:[show objectForKey:@"startDate"]];
	event.endDate					= [from dateFromString:[show objectForKey:@"endDate"]];
	event.title						= [show objectForKey:@"title"];
	event.URL						= [NSURL URLWithString:[show objectForKey:@"url"]];
	event.location					= @"The Living Room";
	event.notes						= [show objectForKey:@"tip"];
	
	//	define a recurrence rule
	NSNumber *weekDay				= [show objectForKey:@"dayOfTheWeek"];
	EKRecurrenceDayOfWeek *showDay	= [EKRecurrenceDayOfWeek dayOfWeek:[weekDay integerValue]];
	EKRecurrenceEnd *runFor3Months	= [EKRecurrenceEnd recurrenceEndWithOccurrenceCount:12];
	EKRecurrenceRule *myRecurrence	= [[EKRecurrenceRule alloc] initRecurrenceWithFrequency:EKRecurrenceFrequencyWeekly
																				   interval:1
																			  daysOfTheWeek:[NSArray arrayWithObject:showDay]
																			 daysOfTheMonth:nil
																		    monthsOfTheYear:nil
																			 weeksOfTheYear:nil
																			  daysOfTheYear:nil
																			   setPositions:nil
																					    end:runFor3Months];
	
	[event addRecurrenceRule:myRecurrence];
	
	//	save the event to the calendar
	NSError *error;
	[[AppCalendar eventStore] saveEvent:event span:EKSpanFutureEvents commit:YES error:&error];
	
	//	show the event dialogue		
	EKEventEditViewController *editEvent;
	editEvent						= [[EKEventEditViewController alloc] init];
	editEvent.eventStore			= [AppCalendar eventStore];
	editEvent.event					= event;
	editEvent.editViewDelegate		= self;
	[self presentViewController:editEvent animated:YES completion:
	^{
		UINavigationItem *cancel	= [editEvent.navigationBar.items objectAtIndex:0];
		cancel.leftBarButtonItem	= nil;
	}];
}

#pragma mark - EKCalendarChooserDelegate Methods

- (void)calendarChooserDidFinish:(EKCalendarChooser *)calendarChooser
{
	EKCalendar *selectedCalendar	= calendarChooser.selectedCalendars.anyObject;
	int row							= [self.tableView indexPathForSelectedRow].row;
	[self addShow:[_shows objectAtIndex:row] toCalendar:selectedCalendar];
	[self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark - EKEventEditViewDelegate Methods

- (void)eventEditViewController:(EKEventEditViewController *)controller
		  didCompleteWithAction:(EKEventEditViewAction)action
{
	NSError *error;
	
	switch (action)
	{
		case EKEventEditViewActionCanceled:
			[[AppCalendar eventStore] reset];
			break;
		default:
			break;
	}
	
	[controller dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - UIAlertViewDelegate Methods

- (void)		alertView:(UIAlertView *)alertView
didDismissWithButtonIndex:(NSInteger)buttonIndex
{
	if (buttonIndex == 0)
	{
		EKCalendarChooser *chooseCalendar;
		chooseCalendar				= [[EKCalendarChooser alloc]
									   initWithSelectionStyle:EKCalendarChooserSelectionStyleSingle
												 displayStyle:EKCalendarChooserDisplayWritableCalendarsOnly
												   entityType:EKEntityTypeEvent
												   eventStore:[AppCalendar eventStore]];
		[chooseCalendar setDelegate:self];
		[chooseCalendar setShowsDoneButton:YES];
		[self.navigationController pushViewController:chooseCalendar animated:YES];
	}
	else
	{
		//	use the app's default calendar
		int row						= [self.tableView indexPathForSelectedRow].row;
		
		[self addShow:[_shows objectAtIndex:row] toCalendar:[AppCalendar calendar]];
	}
}

#pragma mark - UITableViewDataSource Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
		 cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *CellIdentifier	= @"Cell";
	
	UITableViewCell *cell			= [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
	if (!cell)
		cell						= [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
															 reuseIdentifier:CellIdentifier];
	
	NSDictionary *show				= [_shows objectAtIndex:indexPath.row];
	cell.textLabel.text				= [show objectForKey:@"title"];
	
	return cell;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
	return _shows.count;
}

#pragma mark - UITableViewDelegate Methods

- (void)	  tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[[[UIAlertView alloc] initWithTitle:@"Import TV Show Schedule"
								message:@"Do you want to import to:"
							   delegate:self
					  cancelButtonTitle:@"Existing Calendar"
					  otherButtonTitles:@"TV Guide's Calendar", nil] show];
}

@end
