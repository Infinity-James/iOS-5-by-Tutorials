//
//  PlayerDetailsController.h
//  Ratings
//
//  Created by James Valaitis on 21/11/2012.
//  Copyright (c) 2012 &Beyond. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GamePickerController.h"
#import "Player.h"

@class PlayerDetailsController;

@protocol PlayerDetailsControllerDelegate <NSObject>

- (void)	playerDetailsDidCancel:	(PlayerDetailsController *)	controller;
- (void)	playerDetails:			(PlayerDetailsController *)	controller
			 didAddPlayer:			(Player *)					player;
- (void)	playerDetails:			(PlayerDetailsController *)	controller
			didEditPlayer:			(Player *)					player;

@end

@interface PlayerDetailsController : UITableViewController <GamePickerControllerDelegate>

@property (nonatomic, weak)				id <PlayerDetailsControllerDelegate>	delegate;
@property (nonatomic, strong) IBOutlet	UILabel									*detailLabel;
@property (nonatomic, strong) IBOutlet	UITextField								*nameTextField;
@property (nonatomic, strong)			Player									*playerToEdit;

- (IBAction)cancel:	(id)sender;
- (IBAction)done:	(id)sender;

@end
