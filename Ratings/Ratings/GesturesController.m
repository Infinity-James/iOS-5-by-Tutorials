//
//  GesturesController.m
//  Ratings
//
//  Created by James Valaitis on 22/11/2012.
//  Copyright (c) 2012 &Beyond. All rights reserved.
//

#import "GesturesController.h"
#import "Player.h"
#import "PlayerRankingController.h"

@interface GesturesController ()

@end

@implementation GesturesController

#pragma mark - Segue Methods

/**
 *	notifies view controller that segue is about to be performed
 *
 *	@param	segue				segue object containing information about the view controllers involved in the segue
 *	@param	sender				object that initiated the segue
 */
- (void)prepareForSegue:(UIStoryboardSegue *)segue
				 sender:(id)sender
{
	if ([segue.identifier isEqualToString:@"BestPlayers"])
	{
		UINavigationController *navigationController;
		navigationController	= segue.destinationViewController;
		PlayerRankingController *playerRankingController;
		playerRankingController	= [navigationController.viewControllers objectAtIndex:0];
		
		[playerRankingController setRankedPlayers:[self playersWithRating:5]];
		[playerRankingController setRequiredRating:5];
		[playerRankingController setTitle:@"Best Players"];
	}
	
	else if ([segue.identifier isEqualToString:@"WorstPlayers"])
	{
		UINavigationController *navigationController;
		navigationController	= segue.destinationViewController;
		PlayerRankingController *playerRankingController;
		playerRankingController	= [navigationController.viewControllers objectAtIndex:0];
		
		[playerRankingController setRankedPlayers:[self playersWithRating:1]];
				[playerRankingController setRequiredRating:1];
		[playerRankingController setTitle:@"Worst Players"];
	}
}
		 
#pragma mark - Convenience Methods
		 
- (NSMutableArray *)playersWithRating:(int)rating
{
	NSMutableArray *rankedPlayers;
	rankedPlayers				= [NSMutableArray arrayWithCapacity:self.players.count];
	
	for (Player *player in self.players)
		if (player.rating == rating)
			[rankedPlayers addObject:player];
	
	return rankedPlayers;
}

@end
