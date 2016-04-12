//
//  FeedController.m
//  RazeTweet
//
//  Created by James Valaitis on 22/11/2012.
//  Copyright (c) 2012 &Beyond. All rights reserved.
//

#import <Social/Social.h>
#import "AppDelegate.h"
#import "FeedController.h"
#import "TweetCell.h"

#define TweetCellIdentifier					@"TweetCell"

@interface FeedController ()

@property (nonatomic, strong)	NSArray		*tweetsArray;

@end

@implementation FeedController

#pragma mark - View Lifecycle

/**
 *	indicates whether the receiver can become first responder
 */
- (BOOL)canBecomeFirstResponder
{
	return YES;
}

/**
 *	notifies the view controller that its view was added to a view hierarchy
 */
- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	
	[self becomeFirstResponder];
}

/**
 *	notifies the view controller that its view was removed from a view hierarchy
 */
- (void)viewDidDisappear:(BOOL)animated
{
	[self resignFirstResponder];
	
	[super viewDidDisappear:animated];
}

/**
 *	called once this controller's view has been loaded into memory
 */
- (void)viewDidLoad
{
	[super viewDidLoad];
	
	[self.tableView setDataSource:self];
	[self.tableView setDelegate:self];
	
	[self.tableView registerNib:[UINib nibWithNibName:TweetCellIdentifier bundle:nil] forCellReuseIdentifier:TweetCellIdentifier];
	
	AppDelegate *appDelegate		= [UIApplication sharedApplication].delegate;
	
	if (appDelegate.userAccount)
		[self getFeed];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(getFeed)
												 name:@"TwitterAccountAcquiredNotification"
											   object:nil];
}

#pragma mark Autorotation

/**
 *	returns all of the interface orientations that the view controller supports
 */
- (NSUInteger)supportedInterfaceOrientations
{
	return UIInterfaceOrientationMaskPortrait;
}

#pragma mark - Motion Events

/**
 *	tells the receiver that a motion event has ended
 *
 *	@param	motion						event-subtype constant indicating the kind of motion
 *	@param	event						object representing the event associated with the motion
 */
- (void)motionEnded:(UIEventSubtype)motion
		  withEvent:(UIEvent *)event
{
	[self getFeed];
}

#pragma mark - Twitter Methods

/**
 *	get the user's twitter feed
 */
- (void)getFeed
{
	//	store url for home timeline
	NSURL *feedURL						= [NSURL URLWithString:@"https://api.twitter.com/1.1/statuses/home_timeline.json"];
	
	//	create dictionary for twitter request parameters - we want 30 tweets
	NSDictionary *parameters			= [NSDictionary dictionaryWithObjectsAndKeys:@"30", @"count", nil];
	
	//	creat twitter request with url and parameters
	SLRequest *twitterFeed				= [SLRequest requestForServiceType:SLServiceTypeTwitter
															 requestMethod:SLRequestMethodGET
																	   URL:feedURL
																 parameters:parameters];
	
	//	set request's account to the one we downloaded inside our app delegate
	AppDelegate *appDelegate			= [UIApplication sharedApplication].delegate;
	twitterFeed.account					= appDelegate.userAccount;
	
	//	inform user we're downloading tweets
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
	
	//	perform twitter request
	[twitterFeed performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error)
	{
		if (!error)
		{
			//	if no errors were found we parse json into a foundation object
			__autoreleasing NSError *jsonError;
			
			id feedData					= [NSJSONSerialization JSONObjectWithData:responseData options:0 error:&jsonError];
			
			if (!jsonError)
				[self updateFeed:feedData];
			else
				[[[UIAlertView alloc] initWithTitle:@"Error"
											message:jsonError.localizedDescription
										   delegate:nil
								  cancelButtonTitle:@"Okay"
								  otherButtonTitles:nil] show];
		}
		else
			[[[UIAlertView alloc] initWithTitle:@"Error"
										message:error.localizedDescription
									   delegate:nil
							  cancelButtonTitle:@"Okay"
							  otherButtonTitles:nil] show];
		
		[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
	}];
}

/**
 *	update the user's twitter feed
 */
- (void)updateFeed:(id)feedData
{
	self.tweetsArray					= (NSArray *)feedData;
	[self.tableView reloadData];
}

#pragma mark - UITableViewDataSource Methods

/**
 *	create and return the cells for each row of the table view
 *
 *	@param	tableView					the table view for which we are creating cells
 *	@param	indexPath					the index path of the row we are creating a cell for
 */
- (UITableViewCell *)tableView:(UITableView *)tableView
		 cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	TweetCell *cell						= [tableView dequeueReusableCellWithIdentifier:TweetCellIdentifier forIndexPath:indexPath];
	
	//	get dictionary for current tweet and user
	NSDictionary *currentTweet			= [self.tweetsArray objectAtIndex:indexPath.row];
	NSDictionary *currentUser			= [currentTweet objectForKey:@"user"];
	
	//	set tweet cell properties
	cell.userNameLabel.text				= [currentUser objectForKey:@"name"];
	cell.tweetLabel.text				= [currentTweet objectForKey:@"text"];
	cell.userImage.image				= [UIImage imageNamed:@"ProfileImage_Default.png"];
	
	//	get app delegates
	AppDelegate *appDelegate			= [UIApplication sharedApplication].delegate;
	
	//	store username in string
	NSString *userName					= cell.userNameLabel.text;
	
	//	if current user image is inside profile then get it, otherwise download it
	if ([appDelegate.profileImages objectForKey:userName])
		cell.userImage.image			= [appDelegate.profileImages objectForKey:userName];
	else
	{
		//	get concurrent queue from system
		dispatch_queue_t concurrentQueue= dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
		
		//	perform asynchronous operation using concurrent queue to get users image from web
		dispatch_async(concurrentQueue,
		^{
			NSURL *imageURL				= [NSURL URLWithString:[currentUser objectForKey:@"profile_image_url"]];
			
			//	create nsdata object to store image data and download image synchronously
			__block NSData *imageData;
			dispatch_sync(concurrentQueue,
			^{
				imageData				= [NSData dataWithContentsOfURL:imageURL];
				
				//	after downloading image store it in app delegate profile image dictionary with username as key
				[appDelegate.profileImages setObject:[UIImage imageWithData:imageData] forKey:userName];
			});
			
			//	update cell user image on main thread
			dispatch_sync(dispatch_get_main_queue(),
			^{
				cell.userImage.image	= [appDelegate.profileImages objectForKey:userName];
			});
		});
	}
	
	return cell;
}

/**
 *	define how many rows for each section there are in this table view
 *
 *	@param	tableView					the table view for which we are creating cells
 *	@param	section						the particular section for which we must define the rows
 */
- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
	return self.tweetsArray.count;
}

#pragma mark - UITableViewDelegate Methods

/**
 *	define the height of the cell
 *
 *	@param	tableView				the view which owns the cell for which we need to define the height
 *	@param	indexPath				index path of the cell
 */
- (CGFloat)	  tableView:(UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 90;
}

@end
