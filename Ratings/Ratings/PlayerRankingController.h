//
//  PlayerRankingController.h
//  Ratings
//
//  Created by James Valaitis on 22/11/2012.
//  Copyright (c) 2012 &Beyond. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PlayerRatingController.h"

@interface PlayerRankingController : UITableViewController <PlayerRatingDelegate>

@property (nonatomic, strong)	NSMutableArray	*rankedPlayers;
@property (nonatomic, assign)	int				requiredRating;

- (IBAction)done;

@end
