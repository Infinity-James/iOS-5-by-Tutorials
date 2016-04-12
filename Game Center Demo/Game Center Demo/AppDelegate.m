//
//  AppDelegate.m
//  Game Center Demo
//
//  Created by James Valaitis on 09/11/2012.
//  Copyright (c) 2012 &Beyond. All rights reserved.
//

#import "AppDelegate.h"
#import "MainController.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window						= [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

	self.viewController				= [[MainController alloc] initWithNibName:@"MainView" bundle:nil];
	
	self.window.rootViewController	= self.viewController;
	
    [self.window makeKeyAndVisible];
	
    return YES;
}

@end
