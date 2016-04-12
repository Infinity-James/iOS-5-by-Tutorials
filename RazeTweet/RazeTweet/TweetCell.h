//
//  TweetCell.h
//  RazeTweet
//
//  Created by James Valaitis on 22/11/2012.
//  Copyright (c) 2012 &Beyond. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TweetCell : UITableViewCell

@property (nonatomic, weak) IBOutlet	UILabel		*tweetLabel;
@property (nonatomic, weak) IBOutlet	UIImageView	*userImage;
@property (nonatomic, weak) IBOutlet	UILabel		*userNameLabel;

@end
