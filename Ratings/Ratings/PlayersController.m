//
//  PlayersController.m
//  Ratings
//
//  Created by James Valaitis on 21/11/2012.
//  Copyright (c) 2012 &Beyond. All rights reserved.
//

#import "Player.h"
#import "PlayerCell.h"
#import "PlayerDetailsController.h"
#import "PlayersController.h"

@interface PlayersController ()

@end

@implementation PlayersController

#pragma mark - Convenience Methods

- (UIImage *)imageForRating:(int)rating
{
	switch (rating)
	{
		case 1:		return [UIImage imageNamed:@"1StarSmall"];
		case 2:		return [UIImage imageNamed:@"2StarsSmall"];
		case 3:		return [UIImage imageNamed:@"3StarsSmall"];
		case 4:		return [UIImage imageNamed:@"4StarsSmall"];
		case 5:		return [UIImage imageNamed:@"5StarsSmall"];
		default:	return nil;
	}
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
	if ([segue.identifier isEqualToString:@"AddPlayer"])
	{
		UINavigationController *navigationController;
		PlayerDetailsController *playerDetailsController;
		navigationController	= segue.destinationViewController;
		playerDetailsController	= [navigationController.viewControllers objectAtIndex:0];
		[playerDetailsController setDelegate:self];
	}
	
	else if ([segue.identifier isEqualToString:@"EditPlayer"])
	{
		UINavigationController *navigationController;
		PlayerDetailsController *playerDetailsController;
		navigationController	= segue.destinationViewController;
		playerDetailsController	= [navigationController.viewControllers objectAtIndex:0];
		[playerDetailsController setDelegate:self];
		NSIndexPath *indexPath	= sender;	
		Player *player			= [self.players objectAtIndex:indexPath.row];
		[playerDetailsController setPlayerToEdit:player];
	}
	
	else if ([segue.identifier isEqualToString:@"RatePlayer"])
	{
		PlayerRatingController *playerRatingController;
		playerRatingController	= segue.destinationViewController;
		[playerRatingController setDelegate:self];
		NSIndexPath *indexPath	= [self.tableView indexPathForCell:sender];
		Player *player			= [self.players objectAtIndex:indexPath.row];
		[playerRatingController setPlayer:player];
	}
}

#pragma mark - PlayerDetailsControllerDelegate Methods

- (void)playerDetailsDidCancel:(PlayerDetailsController *)controller
{
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (void)playerDetails:(PlayerDetailsController *)controller
		 didAddPlayer:(Player *)player
{
	[self.players addObject:player];
	NSIndexPath *indexPath		= [NSIndexPath indexPathForRow:self.players.count - 1 inSection:0];
	[self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
	
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (void)playerDetails:(PlayerDetailsController *)controller
		didEditPlayer:(Player *)player
{
	NSUInteger index			= [self.players indexOfObject:player];
	NSIndexPath *indexPath		= [NSIndexPath indexPathForRow:index inSection:0];
	[self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
	
	[self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - PlayerRatingDelegate Methods

- (void)playerRatingController:(PlayerRatingController *)ratingController
				 didRatePlayer:(Player *)player
{
	NSUInteger index			= [self.players indexOfObject:player];
	NSIndexPath *indexPath		= [NSIndexPath indexPathForRow:index inSection:0];
	[self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
	
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
	PlayerCell *cell			= [tableView dequeueReusableCellWithIdentifier:@"PlayerCell"];
	
	Player *player				= [self.players objectAtIndex:indexPath.row];
	cell.nameLabel.text			= player.name;
	cell.gameLabel.text			= player.game;
	cell.ratingImageView.image	= [self imageForRating:player.rating];
	cell.detailTextLabel.text	= player.game;
	
	return cell;
}

/**
 *	called to commit the insertion or deletion of a specified row in the receiver
 *
 *	@param	tableView			table view object requesting the insertion or deletion
 *	@param	editingStyle		cell editing style corresponding to a insertion or deletion
 *	@param	indexPath			index path of row requesting editing
 */
- (void) tableView:(UITableView *)				tableView
commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
 forRowAtIndexPath:(NSIndexPath *)				indexPath

{
	if (editingStyle == UITableViewCellEditingStyleDelete)
	{
		[self.players removeObjectAtIndex:indexPath.row];
		[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
	}
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
	return self.players.count;
}

#pragma mark - UITableViewDelegate Methods

/**
 *	user tapped the accessory (disclosure) view associated with a given row
 *
 *	@param	tableView			the table view object informing us of this event
 *	@param	indexPath			index path location row in table view
 */
- (void)					   tableView:(UITableView *)tableView
accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
	UINavigationController *navigationController;
	navigationController		= [self.storyboard instantiateViewControllerWithIdentifier:@"PlayerDetailsNavigationController"];
	PlayerDetailsController *playerDetailsController;
	playerDetailsController	= [navigationController.viewControllers objectAtIndex:0];
	[playerDetailsController setDelegate:self];
	Player *player			= [self.players objectAtIndex:indexPath.row];
	[playerDetailsController setPlayerToEdit:player];
	[self presentViewController:navigationController animated:YES completion:nil];
}

@end
