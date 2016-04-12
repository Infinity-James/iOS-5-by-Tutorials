//
//  PlayersController.h
//  Ratings
//
//  Created by James Valaitis on 21/11/2012.
//  Copyright (c) 2012 &Beyond. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PlayerDetailsController.h"
#import "PlayerRatingController.h"

@interface PlayersController : UITableViewController <PlayerDetailsControllerDelegate, PlayerRatingDelegate>

@property (nonatomic, strong)	NSMutableArray	*players;

@end
