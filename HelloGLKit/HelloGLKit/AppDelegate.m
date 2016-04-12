//
//  AppDelegate.m
//  HelloGLKit
//
//  Created by James Valaitis on 22/10/2012.
//  Copyright (c) 2012 &Beyond. All rights reserved.
//

#import "AppDelegate.h"
#import "HelloGLKitViewController.h"

@implementation AppDelegate
{
	float		_curRed;
	BOOL		_increasing;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window								= [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	
	HelloGLKitViewController *GLController	= [[HelloGLKitViewController alloc] initWithNibName:@"HelloGLKitViewController" bundle:nil];
	
	//	this view controller should be the first thng to show up
	self.window.rootViewController			= GLController;
    
    self.window.backgroundColor				= [UIColor whiteColor];
	
    [self.window makeKeyAndVisible];
	
    return YES;
}

@end
