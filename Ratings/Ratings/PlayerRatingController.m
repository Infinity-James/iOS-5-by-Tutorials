//
//  PlayerRatingController.m
//  Ratings
//
//  Created by James Valaitis on 22/11/2012.
//  Copyright (c) 2012 &Beyond. All rights reserved.
//

#import "Player.h"
#import "PlayerRatingController.h"

@interface PlayerRatingController ()

@end

@implementation PlayerRatingController

#pragma mark - View Lifecycle

/**
 *	called once this controller's view has been loaded into memory
 */
- (void)viewDidLoad
{
	[super viewDidLoad];
	self.title			= self.player.name;
}

#pragma mark - Action & Selector Methods

- (IBAction)rateAction:(UIButton *)sender
{
	self.player.rating	= sender.tag;
	[self.delegate playerRatingController:self didRatePlayer:self.player];
}

@end
