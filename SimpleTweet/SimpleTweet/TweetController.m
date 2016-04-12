//
//  TweetController.m
//  SimpleTweet
//
//  Created by James Valaitis on 22/11/2012.
//  Copyright (c) 2012 &Beyond. All rights reserved.
//

#import <Social/Social.h>
#import <Twitter/Twitter.h>
#import "TweetController.h"

@interface TweetController ()
{
	NSString		*_imageString;
	NSString		*_urlString;
}

@property (weak, nonatomic) IBOutlet UILabel *button1Label;
@property (weak, nonatomic) IBOutlet UILabel *button2Label;
@property (weak, nonatomic) IBOutlet UILabel *button3Label;
@property (weak, nonatomic) IBOutlet UILabel *button4Label;

- (IBAction)button1Tapped;
- (IBAction)button2Tapped;
- (IBAction)button3Tapped;
- (IBAction)button4Tapped;
- (void)	clearLabels;
- (IBAction)tweetTapped;

@end

@implementation TweetController

#pragma mark - Convenience Methods

- (void)clearLabels
{
	self.button1Label.textColor	= [UIColor whiteColor];
	self.button2Label.textColor	= [UIColor whiteColor];
	self.button3Label.textColor	= [UIColor whiteColor];
	self.button4Label.textColor	= [UIColor whiteColor];
}

#pragma mark - Action & Selector Methods

- (IBAction)button1Tapped
{
	[self clearLabels];
	
	_imageString				= @"CheatSheetButton.png";
	_urlString					= @"http://www.raywenderlich.com/4872/objective-c-cheat-sheet-and-quick-reference";
	
	self.button1Label.textColor	= [UIColor purpleColor];
}

- (IBAction)button2Tapped
{
	[self clearLabels];
	
	_imageString				= @"HorizontalTablesButton.png";
	_urlString					= @"http://www.raywenderlich.com/4723/how-to-make-an-interface-with-horizontal-tables-like-the- pulse-news-app-part-2";
	
	self.button2Label.textColor	= [UIColor purpleColor];
}

- (IBAction)button3Tapped
{
	[self clearLabels];
	
	_imageString				= @"PathFindingButton.png";
	_urlString					= @"http://www.raywenderlich.com/4946/introduction-to-a-pathfinding";
	
	self.button3Label.textColor	= [UIColor purpleColor];
}

- (IBAction)button4Tapped
{
	[self clearLabels];
	
	_imageString				= @"UIKitButton.png";
	_urlString					= @"http://www.raywenderlich.com/4817/how-to-integrate-cocos2d-and-uikit";
	
	self.button4Label.textColor	= [UIColor purpleColor];
}

- (IBAction)tweetTapped
{
	//	check if twitter is available on this device
	if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
	{
		SLComposeViewController *tweetSheet		= [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
		[tweetSheet setInitialText:@"Tweeting from iOS 5 by Tutorials."];
		tweetSheet.completionHandler			= ^(SLComposeViewControllerResult result)
		{
			if (result == SLComposeViewControllerResultCancelled)
			{
				
			}
			
			else if (result == SLComposeViewControllerResultDone)
			{
				
			}
			
			[self dismissViewControllerAnimated:YES completion:nil];
		};
		
		if (_imageString)
			[tweetSheet addImage:[UIImage imageNamed:_imageString]];
		if (_urlString)
			[tweetSheet addURL:[NSURL URLWithString:_urlString]];
		
		[self presentViewController:tweetSheet animated:YES completion:nil];
	}
	
	else
		[[[UIAlertView alloc] initWithTitle:@"Sorry"
									message:@"You can't send a tweet right. Check your connection man."
								   delegate:self
						  cancelButtonTitle:@"Fine"
						  otherButtonTitles:nil] show];
}

@end
