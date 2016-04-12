//
//  GamePickerController.h
//  Ratings
//
//  Created by James Valaitis on 21/11/2012.
//  Copyright (c) 2012 &Beyond. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GamePickerController;

@protocol GamePickerControllerDelegate <NSObject>

- (void)gamePickerViewController:(GamePickerController *)	controller
				   didSelectGame:(NSString *)				theGame;

@end

@interface GamePickerController : UITableViewController

@property (nonatomic, weak)		id <GamePickerControllerDelegate>	delegate;
@property (nonatomic, strong)	NSString							*game;

@end
