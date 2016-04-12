//
//  AppDelegate.m
//  PhotoAlbum
//
//  Created by James Valaitis on 30/10/2012.
//  Copyright (c) 2012 &Beyond. All rights reserved.
//

#import "AppDelegate.h"
#import "RootController.h"

@implementation AppDelegate

/**
 *	this message is received when launch process is almost finished
 *
 *	@param	application					the delegating application object
 *	@param	launchOptions				dictionary indicating reason app was launched (if any)
 */
- (BOOL)		  application:(UIApplication *)application
didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	//	initialise and set up the window
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	self.window.backgroundColor			= [UIColor whiteColor];

	//	initialise the root view controller
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
		self.rootController				= [[RootController alloc] initWithNibName:@"RootView_iPhone" bundle:nil];
	else
		self.rootController				= [[RootController alloc] initWithNibName:@"RootView_iPad" bundle:nil];
	
	//	set root view controller as the root view controller of the window
	self.window.rootViewController		= self.rootController;
	
	//	make the window visible, and return the fact that the launch went fine
    [self.window makeKeyAndVisible];
    return YES;
}


@end
