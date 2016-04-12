//
//  TweetController.m
//  RazeTweet
//
//  Created by James Valaitis on 22/11/2012.
//  Copyright (c) 2012 &Beyond. All rights reserved.
//

#import "AppDelegate.h"
#import "TweetController.h"
#import <Social/Social.h>

@interface TweetController ()

@property (nonatomic, assign) BOOL	isAttached;

- (void)dismissKeyboard;

@end

@implementation TweetController

/**
 *	called once this controller's view has been loaded into memory
 */
- (void)viewDidLoad
{
	[super viewDidLoad];
	
	//	initialise is attached bool as no because nothing attached yet
	self.isAttached							= NO;
	
	//	allow user to dismiss keyboard by tapping anywhere in view
	UITapGestureRecognizer *tapRecogniser	= [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
	tapRecogniser.numberOfTapsRequired		= 1;
	tapRecogniser.cancelsTouchesInView		= NO;
	[self.view addGestureRecognizer:tapRecogniser];
}

/**
 *	notifies the view controller that its view is about to be added to a view hierarchy
 *
 *	@param	animated					whether the view needs to be added to the window with an animation
 */
- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
}

#pragma mark - Action & Selector Methods

- (IBAction)attachTapped
{
	//	if image already attached, unattach it, otherwise attach it
	if (self.isAttached)
		self.attachedLabel.text	= @"", self.isAttached			= NO;
	else
		self.attachedLabel.text	= @"Attached", self.isAttached	= YES;
}

- (IBAction)tweetTapped
{
	self.successLabel.text		= @"";
	
	//	store url for status update
	NSURL *tweetURL;
	
	//	depending on attachment store correct url
	if (self.isAttached)
		tweetURL				= [NSURL URLWithString:@"https://api.twitter.com/1.1/statuses/update_with_media.json"];
	else
		tweetURL				= [NSURL URLWithString:@"https://api.twitter.com/1.1/statuses/update"];
	
	//	dictionary with the api call's parameters
	NSDictionary *parameters	=[NSDictionary dictionaryWithObjectsAndKeys:self.statusTextField.text, @"status", nil];
	
	//	create new request and pass in parameters and url
	SLRequest *tweetRequest		= [SLRequest requestForServiceType:SLServiceTypeTwitter
												  requestMethod:SLRequestMethodPOST
															   URL:tweetURL
														parameters:parameters];
	
	//	if user has selected image add to request
	if (self.isAttached)
	{
		[tweetRequest addMultipartData:UIImagePNGRepresentation([UIImage imageNamed:@"TweetImage"])
							  withName:@"media"
								  type:@"image/png"
							  filename:nil];
		[tweetRequest addMultipartData:[self.statusTextField.text dataUsingEncoding:NSUTF8StringEncoding]
							  withName:@"status"
								  type:@"text/plain"
							  filename:nil];
	}
	
	//	get shared instance of app delegate
	AppDelegate *appDelegate			= [UIApplication sharedApplication].delegate;
	
	//	sets user account to one downloaded in app delegate
	tweetRequest.account				= appDelegate.userAccount;
	
	//	inform user we're downloading tweets
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
	
	//	perform twitter request
	[tweetRequest performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error)
	{
		if (!error)
		{
			self.successLabel.text		= @"Tweeted Successfully";
			self.statusTextField.text	= @"";
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

#pragma mark Autorotation

/**
 *	returns all of the interface orientations that the view controller supports
 */
- (NSUInteger)supportedInterfaceOrientations
{
	return UIInterfaceOrientationMaskPortrait;
}

#pragma mark - Convenience Methods

- (void)dismissKeyboard
{
	//	dismiss the keyboard if it is visible
	if (self.statusTextField.isFirstResponder)
		[self.statusTextField resignFirstResponder];
}

@end
