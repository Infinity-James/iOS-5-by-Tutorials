//
//  FollowUsController.m
//  RazeTweet
//
//  Created by James Valaitis on 22/11/2012.
//  Copyright (c) 2012 &Beyond. All rights reserved.
//

#import "AppDelegate.h"
#import "FollowUsController.h"
#import <Social/Social.h>

#define kAccountToFollow		@"Ihnatko"

@interface FollowUsController ()

@property (nonatomic, assign)	BOOL	isFollowing;

- (void)checkFollowing;

@end

@implementation FollowUsController

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	[self checkFollowing];
}

#pragma mark Autorotation

/**
 *	returns all of the interface orientations that the view controller supports
 */
- (NSUInteger)supportedInterfaceOrientations
{
	return UIInterfaceOrientationMaskPortrait;
}

#pragma mark - Convenience Methods

- (void)checkFollowing
{
	//	store url for checking profile
	NSURL *followURL			= [NSURL URLWithString:@"http://api.twitter.com/1.1/friendships/lookup.json"];
	
	//	get shared instance of app delegate
	AppDelegate *appDelegate	= [UIApplication sharedApplication].delegate;
	
	//	create parameters of api request
	NSDictionary *parameters	= [NSDictionary dictionaryWithObjectsAndKeys:kAccountToFollow, @"screen_name", nil];
	
	//	create new request and pass in parameters and url
	SLRequest *twitterFollowing	= [SLRequest requestForServiceType:SLServiceTypeTwitter
													 requestMethod:SLRequestMethodGET
															   URL:followURL
														parameters:parameters];
	
	//	sets user account to one downloaded in app delegate
	twitterFollowing.account	= appDelegate.userAccount;
	
	//	inform user we're downloading tweets
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
	
	//	perform twitter request
	[twitterFollowing performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error)
	 {
		 if (!error)
		 {
			 //	if no errors were found we parse json into a foundation object
			 __autoreleasing NSError *jsonError;
			 
			 NSDictionary *twitterData		= [(NSArray *)[NSJSONSerialization JSONObjectWithData:responseData
																						  options:0
																							error:&jsonError] objectAtIndex:0];
			 
			 NSArray *connections			= [twitterData objectForKey:@"connections"];
			 
			 //	get the response
			 NSString *responseString		= [connections objectAtIndex:0];
			 
			 NSLog(@"Reponse Data: %@", twitterData);
			 NSLog(@"Connections: %@", connections);
			 NSLog(@"Reponse String: %@", responseString);
			 
			 //	set text depending on whether we are already a follower or not
			 if ([responseString isEqualToString:@"following"])
				 self.textLabel.text		= @"Unfollow James Valaitis on Twitter", self.isFollowing	= YES;
			 else
				 self.textLabel.text		= @"Follow James Valaitis on Twitter", self.isFollowing		= NO;
		 }
		 
		 //	if we couldn't perform request properly, alert user
		 else
			 [[[UIAlertView alloc] initWithTitle:@"Error"
										 message:error.localizedDescription
										delegate:nil
							   cancelButtonTitle:@"Okay"
							   otherButtonTitles:nil] show];
		 
		 [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
	 }];

}

#pragma mark - Action & Selector Methods

- (IBAction)followTapped
{
	//	store url for follow call
	NSURL *followURL;
	
	//	use proper url depending on whether following or not
	if (self.isFollowing)
		followURL				= [NSURL URLWithString:@"https://api.twitter.com/1.1/friendships/destroy.json"];
	else
		followURL				= [NSURL URLWithString:@"https://api.twitter.com/1.1/friendships/create.json"];
	
	//	get shared instance of app delegate
	AppDelegate *appDelegate	= [UIApplication sharedApplication].delegate;
	
	
	//	create parameters of api request
	NSDictionary *parameters	= [NSDictionary dictionaryWithObjectsAndKeys:@"true", @"follow", kAccountToFollow, @"screen_name", nil];
	
	//	create new request and pass in parameters and url
	SLRequest *twitterFollowing	= [SLRequest requestForServiceType:SLServiceTypeTwitter
													 requestMethod:SLRequestMethodPOST
															   URL:followURL
														parameters:parameters];
	
	//	sets user account to one downloaded in app delegate
	twitterFollowing.account	= appDelegate.userAccount;
	
	//	inform user we're downloading tweets
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
	
	//	perform twitter request
	[twitterFollowing performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error)
	{
		if (!error)
		{
			//	set text depending on whether we are already a follower or not
			if (!self.isFollowing)
				self.textLabel.text		= @"Unfollow James Valaitis on Twitter", self.isFollowing	= YES;
			else
				self.textLabel.text		= @"Follow James Valaitis on Twitter", self.isFollowing		= NO;
		}
		 
		 //	if we couldn't perform request properly, alert user
		else
			[[[UIAlertView alloc] initWithTitle:@"Error"
										message:error.localizedDescription
									   delegate:nil
							  cancelButtonTitle:@"Okay"
							  otherButtonTitles:nil] show];
		 
		[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
	}];

}

@end
