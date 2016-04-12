//
//  AppDelegate.m
//  CITest
//
//  Created by James Valaitis on 07/11/2012.
//  Copyright (c) 2012 &Beyond. All rights reserved.
//

#import "AppDelegate.h"

#import "ViewController.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window						= [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
	    self.viewController			= [[ViewController alloc] initWithNibName:@"ViewController_iPhone" bundle:nil];
	else
	    self.viewController			= [[ViewController alloc] initWithNibName:@"ViewController_iPad" bundle:nil];
	
	self.window.rootViewController	= self.viewController;
	
    [self.window makeKeyAndVisible];
	
	//	hide status bar
	[[UIApplication sharedApplication] setStatusBarHidden:YES];
	
    return YES;
}

@end
