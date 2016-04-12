//
//  AppDelegate.m
//  Dox-Again
//
//  Created by James Valaitis on 24/10/2012.
//  Copyright (c) 2012 &Beyond. All rights reserved.
//

#import "AppDelegate.h"
#import "NoteDetailController.h"
#import "NoteListController.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window								= [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	
	NoteListController *noteListController;

	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
	    noteListController					= [[NoteListController alloc] initWithNibName:@"NoteListView_iPhone" bundle:nil];
	else 
	    noteListController					= [[NoteListController alloc] initWithNibName:@"NoteListView_iPad" bundle:nil];
	
	UINavigationController *navController	= [[UINavigationController alloc] initWithRootViewController:noteListController];
	
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
	{
		self.window.rootViewController		= navController;
	}
	
	else
	{
		NoteDetailController *detail		= [[NoteDetailController alloc] initWithNibName:@"NoteDetailView_iPad" bundle:nil];
		self.splitController				= [[UISplitViewController alloc] init];
		self.splitController.viewControllers= @[navController, detail];
		self.window.rootViewController		= self.splitController;
	}
	
    [self.window makeKeyAndVisible];
	
    return YES;
}

@end
