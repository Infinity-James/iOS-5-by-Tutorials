//
//  PlayerCell.h
//  Ratings
//
//  Created by James Valaitis on 21/11/2012.
//  Copyright (c) 2012 &Beyond. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PlayerCell : UITableViewCell

@property (nonatomic, strong) IBOutlet	UILabel		*nameLabel;
@property (nonatomic, strong) IBOutlet	UILabel		*gameLabel;
@property (nonatomic, strong) IBOutlet	UIImageView	*ratingImageView;

@end
