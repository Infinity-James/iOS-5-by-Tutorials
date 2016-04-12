//
//  GamePickerController.m
//  Ratings
//
//  Created by James Valaitis on 21/11/2012.
//  Copyright (c) 2012 &Beyond. All rights reserved.
//

#import "GamePickerController.h"

@interface GamePickerController ()

@end

@implementation GamePickerController
{
	NSArray				*_games;
	NSUInteger			_selectedIndex;
}

#pragma mark - View Lifecycle

/**
 *	called once this controller's view has been loaded into memory
 */
- (void)viewDidLoad
{
	[super viewDidLoad];
	
	_games				= [NSArray arrayWithObjects:@"Angry Birds", @"Chess", @"Russian Roulette", @"Spin the Bottle", @"Plays with Themselves", @"Texas Hold'em Poker", @"Tic-tac-Toe", nil];
	
	_selectedIndex		= [_games indexOfObject:self.game];
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
	UITableViewCell *cell		= [tableView dequeueReusableCellWithIdentifier:@"GameCell"];
	cell.textLabel.text			= [_games objectAtIndex:indexPath.row];
	
	if (indexPath.row == _selectedIndex)
		cell.accessoryType		= UITableViewCellAccessoryCheckmark;
	else
		cell.accessoryType		= UITableViewCellAccessoryNone;
	
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
	return _games.count;
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
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	if (_selectedIndex != NSNotFound)
	{
		UITableViewCell *cell	= [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:_selectedIndex inSection:0]];
		cell.accessoryType		= UITableViewCellAccessoryNone;
	}
	
	_selectedIndex				= indexPath.row;
	UITableViewCell *cell		= [tableView cellForRowAtIndexPath:indexPath];
	cell.accessoryType			= UITableViewCellAccessoryCheckmark;
	NSString *theGame			= [_games objectAtIndex:indexPath.row];
	[self.delegate gamePickerViewController:self didSelectGame:theGame];
}

@end
