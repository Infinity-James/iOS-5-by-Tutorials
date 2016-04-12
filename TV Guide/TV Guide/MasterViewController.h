//
//  MasterViewController.h
//  TV Guide
//
//  Created by James Valaitis on 12/11/2012.
//  Copyright (c) 2012 &Beyond. All rights reserved.
//

#import <EventKitUI/EventKitUI.h>
#import <UIKit/UIKit.h>

@interface MasterViewController : UITableViewController <EKCalendarChooserDelegate, EKEventEditViewDelegate, UIAlertViewDelegate>
{
	NSArray				*_shows;
}

@end
