//
//  ViewController.m
//  Game Center Demo
//
//  Created by James Valaitis on 09/11/2012.
//  Copyright (c) 2012 &Beyond. All rights reserved.
//

#import <GameKit/GameKit.h>
#import "AppDelegate.h"
#import "MainController.h"

@implementation MainController

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	[self authenticateLocalUser];
}

#pragma mark - Game Centre Methods

/**
 *	called to authenticate the players game centre id
 */
- (void)authenticateLocalUser
{
	NSLog(@"Authenticating Local User.");
	
	if ([GKLocalPlayer localPlayer].authenticated == NO)
	{
		[[GKLocalPlayer localPlayer] setAuthenticateHandler:^(UIViewController* viewcontroller, NSError *error)
		 {
			 NSLog(@"Inside Authentication Handler.");
			 
			 //	if there was no error, and we got a valid view controller to display
			 if (!error && viewcontroller)
			 {
				 //	use the view controller in the app delegate to present the authentication view controller
				 [self presentViewController:viewcontroller animated:YES completion:
				  ^{
					 dispatch_async(dispatch_get_main_queue(),
					 ^{
						 [self signedIntoGameCenter];
						 
					 });
				  }];
			 }
			 else
			 {
				 [self signedIntoGameCenter];
			 }
		 }];
	}
	else
		[self signedIntoGameCenter];
}

#pragma mark - Convenience Methods

- (void)loadPlayerPhoto
{
	[[GKLocalPlayer localPlayer] loadPhotoForSize:GKPhotoSizeNormal withCompletionHandler:^(UIImage *photo, NSError *error)
	{
		dispatch_async(dispatch_get_main_queue(),
		^{
			if (!error)
			{
				_photoView.image		= photo;
				[self showMessage:@"Photo Downloaded"];
			}
			else
				_nameLabel.text			= @"No Player Photo.";
		});
	}];
}

- (void)showMessage:(NSString *)message
{
	[GKNotificationBanner showBannerWithTitle:@"Game Kit Message Test" message:message completionHandler:
	^{
		 
	}];
}

- (void)signedIntoGameCenter
{
	_nameLabel.text			= [GKLocalPlayer localPlayer].alias;
	[self loadPlayerPhoto];
	[self showMessage:@"User Successfully Authenticated"];
}

#pragma mark - Action & Selector Methods

- (IBAction)doAnAchievement
{
	GKAchievement *achievement			= [[GKAchievement alloc]
										   initWithIdentifier:@"com.andbeyond.jamesvalaitis.achievements_createdachievement"];
	
	achievement.percentComplete			= 100;
	
	achievement.showsCompletionBanner	= YES;
	[achievement reportAchievementWithCompletionHandler:^(NSError *error)
	{
		 
	}];
}

@end
