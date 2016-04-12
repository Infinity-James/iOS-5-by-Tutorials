//
//  AppDelegate.m
//  iCloud Test
//
//  Created by James Valaitis on 14/11/2012.
//  Copyright (c) 2012 &Beyond. All rights reserved.
//

#import "AppDelegate.h"
#import "NoteController.h"
#import "NoteListController.h"



@implementation AppDelegate

/**
 *	launch process is almost done and the app is almost ready to run
 */
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window									= [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	
	NoteListController *noteListController		= [[NoteListController alloc] initWithStyle:UITableViewStylePlain];
	UINavigationController *navController		= [[UINavigationController alloc] initWithRootViewController:noteListController];

	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
	{
	    self.noteController						= [[NoteController alloc] initWithNibName:@"NoteView_iPad" bundle:nil];
		self.detailNavController				= [[UINavigationController alloc] initWithRootViewController:self.noteController];
		
		UISplitViewController *splitController	= [[UISplitViewController alloc] init];
		[splitController setDelegate:self.noteController];
		splitController.viewControllers			= @[navController, self.detailNavController];
		
		self.window.rootViewController			= splitController;
	}
	else
	{
		self.window.rootViewController			= navController;
	}
	
	
	
    [self.window makeKeyAndVisible];
	
    return YES;
}

@end
