//
//  AppDelegate.m
//  RazeTweet
//
//  Created by James Valaitis on 22/11/2012.
//  Copyright (c) 2012 &Beyond. All rights reserved.
//

#import "AppDelegate.h"
#import "MyTabBarController.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window								= [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	
	[self setupAccounts];
    
	MyTabBarController *tabBarController	= [[MyTabBarController alloc] init];
	self.window.rootViewController			= tabBarController;
	
    self.window.backgroundColor				= [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)setupAccounts
{
	self.accountStore						= [[ACAccountStore alloc] init];
	self.profileImages						= [NSMutableDictionary dictionary];
	ACAccountType *twitterType				= [self.accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
	
	[self.accountStore requestAccessToAccountsWithType:twitterType options:nil completion:^(BOOL granted, NSError *error)
	{
		if (granted)
		{
			NSArray *twitterAccounts		= [self.accountStore accountsWithAccountType:twitterType];
			 
			if (twitterAccounts.count)
			{
				self.userAccount			= [twitterAccounts objectAtIndex:0];
				 
				[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"TwitterAccountAcquiredNotification"
																									 object:nil]];
			}
			 
			else
				NSLog(@"No Twitter Accounts");
		}
	}];
}

@end
