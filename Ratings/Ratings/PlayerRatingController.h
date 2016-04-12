//
//  PlayerRatingController.h
//  Ratings
//
//  Created by James Valaitis on 22/11/2012.
//  Copyright (c) 2012 &Beyond. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Player;
@class PlayerRatingController;

@protocol PlayerRatingDelegate <NSObject>

- (void)playerRatingController:(PlayerRatingController *)ratingController
				 didRatePlayer:(Player *)player;

@end

@interface PlayerRatingController : UIViewController

@property (nonatomic, weak)		id <PlayerRatingDelegate>	delegate;
@property (nonatomic, strong)	Player						*player;

- (IBAction)rateAction:	(UIButton *)	sender;

@end
