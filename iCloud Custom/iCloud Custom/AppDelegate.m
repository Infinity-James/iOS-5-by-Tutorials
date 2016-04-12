//
//  AppDelegate.m
//  iCloud Custom
//
//  Created by James Valaitis on 15/11/2012.
//  Copyright (c) 2012 &Beyond. All rights reserved.
//

#import "AppDelegate.h"
#import "NoteController.h"
#import "NoteListController.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window									= [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	
	NoteListController *noteListController		= [[NoteListController alloc] initWithStyle:UITableViewStylePlain];
	UINavigationController *navController		= [[UINavigationController alloc] initWithRootViewController:noteListController];
	
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
	{
		UISplitViewController *splitController	= [[UISplitViewController alloc] init];
	    NoteController *noteController			= [[NoteController alloc] initWithNibName:@"NoteView_iPhone" bundle:nil];
		[splitController setDelegate:noteController];
		splitController.viewControllers			= @[navController, noteController];
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
