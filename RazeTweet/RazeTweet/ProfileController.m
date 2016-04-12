//
//  ProfileController.m
//  RazeTweet
//
//  Created by James Valaitis on 22/11/2012.
//  Copyright (c) 2012 &Beyond. All rights reserved.
//

#import "AppDelegate.h"
#import "ProfileController.h"
#import <Social/Social.h>

@interface ProfileController ()

@end

@implementation ProfileController

#pragma mark - View Lifecycle

/**
 *	notifies the view controller that its view is about to be added to a view hierarchy
 *
 *	@param	animated					whether the view needs to be added to the window with an animation
 */
- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	[self loadProfile];
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

- (void)loadProfile
{
	//	store url for profile call
	NSURL *profileURL			= [NSURL URLWithString:@"http://api.twitter.com/1.1/users/show.json"];
	
	//	get shared instance of app delegate
	AppDelegate *appDelegate	= [UIApplication sharedApplication].delegate;
	
	//	create parameters of api request
	NSDictionary *parameters	= [NSDictionary dictionaryWithObjectsAndKeys:appDelegate.userAccount.username, @"screen_name", nil];
	
	//	set the user name label in the view
	self.usernameLabel.text		= appDelegate.userAccount.username;
	
	//	create new request and pass in parameters and url
	SLRequest *profileRequest	= [SLRequest requestForServiceType:SLServiceTypeTwitter
													 requestMethod:SLRequestMethodGET
															   URL:profileURL
														parameters:parameters];
	
	//	sets user account to one downloaded in app delegate
	profileRequest.account	= appDelegate.userAccount;
	
	//	inform user we're downloading tweets
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
	
	//	perform twitter request
	[profileRequest performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error)
	{
		if (!error)
		{
			 //	if no errors were found we parse json into a foundation object
			__autoreleasing NSError *jsonError;
			 
			//	get the profile dictionary
			id jsonObject							= [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:&jsonError];
			 
			if (!jsonError)
			{
				NSDictionary *profileDictionary	= (NSDictionary *)jsonObject;
				 
				NSLog(@"Profile Dictionary: %@", profileDictionary);
				 
				self.descriptionLabel.text			= [profileDictionary objectForKey:@"description"];
				self.favouritesLabel.text			= [[profileDictionary objectForKey:@"favourites_count"] stringValue];
				self.followersLabel.text			= [[profileDictionary objectForKey:@"followers_count"] stringValue];
				self.followingLabel.text			= [[profileDictionary objectForKey:@"friends_count"] stringValue];
				self.tweetsLabel.text				= [[profileDictionary objectForKey:@"statuses_count"] stringValue];
			}
			 
			else
				[[[UIAlertView alloc] initWithTitle:@"Error" message:jsonError.localizedDescription delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil] show];
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
