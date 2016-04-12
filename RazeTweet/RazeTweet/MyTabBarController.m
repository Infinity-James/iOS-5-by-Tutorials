//
//  MyTabBarController.m
//  RazeTweet
//
//  Created by James Valaitis on 23/11/2012.
//  Copyright (c) 2012 &Beyond. All rights reserved.
//

#import "MyTabBarController.h"
#import "FeedController.h"
#import "FollowUsController.h"
#import "MentionsController.h"
#import "ProfileController.h"
#import "TweetController.h"

@interface MyTabBarController ()

@end

@implementation MyTabBarController

- (id)init
{
	if (self = [super init])
	{
		FeedController *feedController			= [[FeedController alloc] initWithStyle:UITableViewStylePlain];
		FollowUsController *followUsController	= [[FollowUsController alloc] initWithNibName:@"FollowUsView" bundle:nil];
		MentionsController *mentionsController	= [[MentionsController alloc] initWithStyle:UITableViewStylePlain];
		ProfileController *profileController	= [[ProfileController alloc] initWithNibName:@"ProfileView" bundle:nil];
		TweetController *tweetController		= [[TweetController alloc] initWithNibName:@"TweetView" bundle:nil];
		
		feedController.tabBarItem.title			= @"Feed";
		followUsController.tabBarItem.title		= @"Follow Us";
		mentionsController.tabBarItem.title		= @"Mentions";
		profileController.tabBarItem.title		= @"Profile";
		tweetController.tabBarItem.title		= @"Tweet";
		
		self.viewControllers					= @[feedController, mentionsController, tweetController, followUsController, profileController];
	}
	
	return self;
}

@end
