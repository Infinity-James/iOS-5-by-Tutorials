//
//  PlayerRankingController.m
//  Ratings
//
//  Created by James Valaitis on 22/11/2012.
//  Copyright (c) 2012 &Beyond. All rights reserved.
//

#import "Player.h"
#import "PlayerRankingController.h"

@interface PlayerRankingController ()

@end

@implementation PlayerRankingController

#pragma mark - Action & Selector Methods

- (IBAction)done
{
	[self dismissViewControllerAnimated:YES completion:nil];	
}

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
	if ([segue.identifier isEqualToString:@"RatePlayer"])
	{
		PlayerRatingController *ratePlayerController;
		ratePlayerController	= segue.destinationViewController;
		[ratePlayerController setDelegate:self];
		[ratePlayerController setPlayer:sender];
	}
}

#pragma mark - PlayerRatingDelegate Methods

- (void)playerRatingController:(PlayerRatingController *)ratingController
				 didRatePlayer:(Player *)player
{
	if (player.rating != self.requiredRating)
	{
		NSUInteger index			= [self.rankedPlayers indexOfObject:player];
		[self.rankedPlayers removeObjectAtIndex:index];
		NSIndexPath *indexPath		= [NSIndexPath indexPathForRow:index inSection:0];
		[self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
	}
	
	[self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UITableViewDataSource Methods

/**
 *	as the data source, we must define how many sections we want the table view to have
 *
 *	@param	tableView			the table view for which are defining the sections number
 */
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

/**
 *	create and return the cells for each row of the table view
 *
 *	@param	tableView			the table view for which we are creating cells
 *	@param	indexPath			the index path of the row we are creating a cell for
 */
- (UITableViewCell *)tableView:(UITableView *)tableView
		 cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *CellIdentifier	= @"Cell";
	
	UITableViewCell *cell			= [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
	if (!cell)
		cell						= [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
	
	Player *player					= [self.rankedPlayers objectAtIndex:indexPath.row];
	cell.textLabel.text				= player.name;
	cell.detailTextLabel.text		= player.game;
	
	return cell;
}

/**
 *	define how many rows for each section there are in this table view
 *
 *	@param	tableView			the table view for which we are creating cells
 *	@param	section				the particular section for which we must define the rows
 */
- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
	return self.rankedPlayers.count;
}

#pragma mark - UITableViewDelegate Methods

/**
*	handle the fact that a cell was just selected
*
*	@param	tableView			the table view containing selected cell
*	@param	indexPath			the index path of the cell that was selected
*/
- (void)	  tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	Player *player					= [self.rankedPlayers objectAtIndex:indexPath.row];
	[self performSegueWithIdentifier:@"RatePlayer" sender:player];
}


@end
