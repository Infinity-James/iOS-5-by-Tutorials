//
//  AppCalendar.h
//  TV Guide
//
//  Created by James Valaitis on 12/11/2012.
//  Copyright (c) 2012 &Beyond. All rights reserved.
//

#import <EventKit/EventKit.h>
#import <Foundation/Foundation.h>

#define kAppCalendarTitle			@"TV Guide"

@interface AppCalendar : NSObject

+ (EKEventStore *)	eventStore;
+ (EKCalendar *)	calendar;
+ (EKCalendar *)	createAppCalendar;

@end
