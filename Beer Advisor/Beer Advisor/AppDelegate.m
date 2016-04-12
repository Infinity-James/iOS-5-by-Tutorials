//
//  AppDelegate.m
//  Beer Advisor
//
//  Created by James Valaitis on 09/11/2012.
//  Copyright (c) 2012 &Beyond. All rights reserved.
//

#import "AppDelegate.h"
#import "BeerAdvisorController.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window										= [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor						= [UIColor whiteColor];
	
	BeerAdvisorController *beerAdvisorController	= [[BeerAdvisorController alloc] initWithNibName:@"BeerAdvisorView" bundle:nil];
	self.window.rootViewController					= beerAdvisorController;
	
    [self.window makeKeyAndVisible];
	
    return YES;
}

@end
