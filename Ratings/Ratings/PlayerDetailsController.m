//
//  PlayerDetailsController.m
//  Ratings
//
//  Created by James Valaitis on 21/11/2012.
//  Copyright (c) 2012 &Beyond. All rights reserved.
//

#import "Player.h"
#import "PlayerDetailsController.h"

@interface PlayerDetailsController ()

@end

@implementation PlayerDetailsController
{
	NSString		*_game;
}

#pragma mark - Initialisation

/**
 *	allows the decoding of object when initialising
 *
 *	@param	aDecoder					the object used to decode our properties
 */
- (id)initWithCoder:(NSCoder *)aDecoder
{
	if (self = [super initWithCoder:aDecoder])
	{
		_game					= @"Chess";
	}
	
	return self;
}

#pragma mark - View Lifecycle

/**
 *	called once this controller's view has been loaded into memory
 */
- (void)viewDidLoad
{
	[super viewDidLoad];
	
	if (self.playerToEdit)
	{
		self.title				= @"Edit Player";
		self.nameTextField.text	= self.playerToEdit.name;
		_game					= self.playerToEdit.game;
	}
	
	self.detailLabel.text		= _game;
}

#pragma mark - Action & Selector Methods

- (IBAction)cancel:(id)sender
{
	[self.delegate playerDetailsDidCancel:self];
}

- (IBAction)done:(id)sender
{
	if (self.playerToEdit)
	{
		self.playerToEdit.name	= self.nameTextField.text;
		self.playerToEdit.game	= _game;
		
		[self.delegate playerDetails:self didEditPlayer:self.playerToEdit];
	}
	
	else
	{
		Player *player				= [[Player alloc] init];
		player.name					= self.nameTextField.text;
		player.game					= _game;
		player.rating				= 1;
		
		[self.delegate playerDetails:self didAddPlayer:player];
	}
}

#pragma mark - Segue Methods

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	if ([segue.identifier isEqualToString:@"PickGame"])
	{
		GamePickerController *gamePickerController;
		gamePickerController	= segue.destinationViewController;
		[gamePickerController setDelegate:self];
		[gamePickerController setGame:_game];
	}
}

#pragma mark - GamePickerControllerDelegate Methods

- (void)gamePickerViewController:(GamePickerController *)controller
				   didSelectGame:(NSString *)theGame
{
	_game						= theGame;
	self.detailLabel.text		= _game;
	[self.navigationController popViewControllerAnimated:YES];
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
	if (indexPath.section == 0)
		[self.nameTextField becomeFirstResponder];
}

@end
