//
//  AppDelegate.m
//  Ratings
//
//  Created by James Valaitis on 21/11/2012.
//  Copyright (c) 2012 &Beyond. All rights reserved.
//

#import "AppDelegate.h"
#import "GesturesController.h"
#import "Player.h"
#import "PlayersController.h"

@implementation AppDelegate
{
	NSMutableArray			*players;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	players				= [NSMutableArray arrayWithCapacity:20];
	
	Player *player		= [[Player alloc] init];
	player.name			= @"Bill Evans";
	player.game			= @"Tic-Tac-Toe";
	player.rating		= 4;
	[players addObject:player];
	
	player				= [[Player alloc] init];
	player.name			= @"Oscar Peterson";
	player.game			= @"Spin the Bottle";
	player.rating		= 5;
	[players addObject:player];
	
	player				= [[Player alloc] init];
	player.name			= @"Dave Brubeck";
	player.game			= @"Texas Hold’em Poker"; player.rating = 2;
	[players addObject:player];
	
	UITabBarController *tabBarController;
	
	if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
	{
		tabBarController							= (UITabBarController *)self.window.rootViewController;
	}
	
	else
	{
		UISplitViewController *splitViewController	= (UISplitViewController *)self.window.rootViewController;
		splitViewController.delegate				= splitViewController.viewControllers.lastObject;
		
		UIStoryboard *storyboard					= [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
		tabBarController							= [storyboard instantiateInitialViewController];
		
		tabBarController.contentSizeForViewInPopover= CGSizeMake(320, 460);
		
		NSArray *viewControllers					= [NSArray arrayWithObjects:tabBarController,
																	splitViewController.viewControllers.lastObject, nil];
		splitViewController.viewControllers			= viewControllers;
	}
	
	UINavigationController *navigationController	= [tabBarController.viewControllers objectAtIndex:0];
	GesturesController *gesturesController			= [tabBarController.viewControllers objectAtIndex:1];
	PlayersController *playersController			= [navigationController.viewControllers objectAtIndex:0];
	playersController.players						= players;
	gesturesController.players						= players;
	
    return YES;
}

@end
